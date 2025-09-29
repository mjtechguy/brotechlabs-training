# Part 11: Production Operations

## Prerequisites and Learning Resources

Before starting this section, you should have completed:
- Part 1: Getting Started with Rocky Linux
- Part 2: Core System Administration
- Part 3: Storage and Filesystems (for backup strategies)
- Part 4: Networking and Security
- Part 6: Automation and Configuration Management
- Part 7: Monitoring and Performance
- Part 10: Troubleshooting and Recovery

**Helpful Resources:**
- Rocky Linux Enterprise Documentation: https://docs.rockylinux.org/
- Red Hat System Administration Guide: https://access.redhat.com/documentation/
- CIS Rocky Linux Benchmark: https://www.cisecurity.org/benchmark/rocky_linux
- OpenSCAP Security Guide: https://www.open-scap.org/
- Rocky Linux Forums: https://forums.rockylinux.org/

---

## Chapter 24: Backup and Maintenance

### Introduction

Running production systems is like maintaining a high-performance vehicle - regular maintenance prevents breakdowns, and good backups ensure you can recover from disasters. This chapter covers enterprise backup strategies and maintenance procedures that keep Rocky Linux systems running reliably.

### Enterprise Backup Strategies

A backup strategy is like insurance - you need the right coverage for your specific risks.

```bash
# The 3-2-1 Backup Rule:
# 3 copies of important data
# 2 different storage media types
# 1 off-site backup

# Define backup requirements
cat > /etc/backup/backup-policy.conf << 'EOF'
# Backup Policy Configuration
BACKUP_RETENTION_DAILY=7
BACKUP_RETENTION_WEEKLY=4
BACKUP_RETENTION_MONTHLY=12
BACKUP_COMPRESSION="gzip"
BACKUP_ENCRYPTION="yes"
BACKUP_VERIFY="yes"

# Critical Data (RPO: 1 hour)
CRITICAL_PATHS="/var/lib/mysql /var/lib/pgsql /etc"

# Important Data (RPO: 4 hours)
IMPORTANT_PATHS="/home /var/www /opt/applications"

# Standard Data (RPO: 24 hours)
STANDARD_PATHS="/var/log /usr/local"
EOF
```

**Implementing a Comprehensive Backup System:**

```bash
#!/bin/bash
# /usr/local/bin/enterprise-backup.sh

# Configuration
BACKUP_ROOT="/backup"
REMOTE_BACKUP="backup-server:/backup/$(hostname -s)"
DATE=$(date +%Y%m%d_%H%M%S)
LOG_FILE="/var/log/backup/backup_${DATE}.log"
ALERT_EMAIL="admin@example.com"

# Create backup directories
mkdir -p ${BACKUP_ROOT}/{daily,weekly,monthly,staging}
mkdir -p /var/log/backup

# Logging function
log_message() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a ${LOG_FILE}
}

# Backup function with verification
perform_backup() {
    local SOURCE=$1
    local DEST=$2
    local TYPE=$3

    log_message "Starting ${TYPE} backup of ${SOURCE}"

    # Create backup with checksums
    tar czf ${DEST} \
        --listed-incremental=${BACKUP_ROOT}/.${TYPE}.snar \
        --verify \
        ${SOURCE} 2>> ${LOG_FILE}

    if [ $? -eq 0 ]; then
        # Generate checksum
        sha256sum ${DEST} > ${DEST}.sha256

        # Verify backup
        tar tzf ${DEST} > /dev/null 2>&1
        if [ $? -eq 0 ]; then
            log_message "Backup verified successfully: ${DEST}"
            return 0
        else
            log_message "ERROR: Backup verification failed: ${DEST}"
            return 1
        fi
    else
        log_message "ERROR: Backup failed for ${SOURCE}"
        return 1
    fi
}

# Main backup routine
main() {
    log_message "=== Starting Enterprise Backup ==="

    # Database backups (hot backups)
    if systemctl is-active --quiet mariadb; then
        log_message "Backing up MariaDB databases"
        mysqldump --all-databases --single-transaction \
            --routines --triggers --events \
            > ${BACKUP_ROOT}/staging/mysql_${DATE}.sql
    fi

    if systemctl is-active --quiet postgresql; then
        log_message "Backing up PostgreSQL databases"
        sudo -u postgres pg_dumpall > ${BACKUP_ROOT}/staging/postgresql_${DATE}.sql
    fi

    # System configuration backup
    perform_backup "/etc" \
        "${BACKUP_ROOT}/daily/etc_${DATE}.tar.gz" \
        "configuration"

    # Application data backup
    perform_backup "/var/www" \
        "${BACKUP_ROOT}/daily/www_${DATE}.tar.gz" \
        "web"

    # User data backup
    perform_backup "/home" \
        "${BACKUP_ROOT}/daily/home_${DATE}.tar.gz" \
        "home"

    # Sync to remote backup server
    log_message "Syncing to remote backup server"
    rsync -avz --delete \
        ${BACKUP_ROOT}/daily/ \
        ${REMOTE_BACKUP}/daily/ \
        2>> ${LOG_FILE}

    # Rotation
    log_message "Rotating old backups"
    find ${BACKUP_ROOT}/daily -name "*.tar.gz" -mtime +7 -delete
    find ${BACKUP_ROOT}/weekly -name "*.tar.gz" -mtime +28 -delete
    find ${BACKUP_ROOT}/monthly -name "*.tar.gz" -mtime +365 -delete

    # Send summary
    BACKUP_SIZE=$(du -sh ${BACKUP_ROOT} | cut -f1)
    log_message "=== Backup Complete. Total size: ${BACKUP_SIZE} ==="

    # Alert on failures
    if grep -q "ERROR" ${LOG_FILE}; then
        mail -s "Backup FAILED on $(hostname)" ${ALERT_EMAIL} < ${LOG_FILE}
    fi
}

# Run main function
main
```

### Testing Backup Restoration

Untested backups are just wishful thinking - regular testing ensures they work when needed.

```bash
#!/bin/bash
# /usr/local/bin/backup-test.sh

# Automated backup restoration test
TEST_DIR="/tmp/backup_test_$(date +%Y%m%d)"
BACKUP_DIR="/backup/daily"
LOG_FILE="/var/log/backup/test_$(date +%Y%m%d).log"

# Test restoration function
test_restore() {
    local BACKUP_FILE=$1
    local TEST_NAME=$2

    echo "Testing: ${TEST_NAME}" >> ${LOG_FILE}
    mkdir -p ${TEST_DIR}/${TEST_NAME}

    # Verify checksum
    if [ -f ${BACKUP_FILE}.sha256 ]; then
        sha256sum -c ${BACKUP_FILE}.sha256 >> ${LOG_FILE} 2>&1
        if [ $? -ne 0 ]; then
            echo "FAILED: Checksum mismatch for ${BACKUP_FILE}" >> ${LOG_FILE}
            return 1
        fi
    fi

    # Test extraction
    tar xzf ${BACKUP_FILE} -C ${TEST_DIR}/${TEST_NAME} 2>> ${LOG_FILE}
    if [ $? -eq 0 ]; then
        # Verify content
        FILE_COUNT=$(find ${TEST_DIR}/${TEST_NAME} -type f | wc -l)
        echo "SUCCESS: Restored ${FILE_COUNT} files" >> ${LOG_FILE}

        # Test specific file integrity
        if [ -f ${TEST_DIR}/${TEST_NAME}/etc/passwd ]; then
            echo "VERIFIED: Critical files present" >> ${LOG_FILE}
        fi

        return 0
    else
        echo "FAILED: Could not extract ${BACKUP_FILE}" >> ${LOG_FILE}
        return 1
    fi
}

# Main test routine
echo "=== Backup Restoration Test Started ===" >> ${LOG_FILE}

# Find latest backups
LATEST_ETC=$(ls -t ${BACKUP_DIR}/etc_*.tar.gz 2>/dev/null | head -1)
LATEST_HOME=$(ls -t ${BACKUP_DIR}/home_*.tar.gz 2>/dev/null | head -1)
LATEST_WWW=$(ls -t ${BACKUP_DIR}/www_*.tar.gz 2>/dev/null | head -1)

# Test each backup
FAILED=0
for BACKUP in ${LATEST_ETC} ${LATEST_HOME} ${LATEST_WWW}; do
    if [ -f "${BACKUP}" ]; then
        test_restore ${BACKUP} $(basename ${BACKUP})
        [ $? -ne 0 ] && FAILED=$((FAILED + 1))
    fi
done

# Cleanup
rm -rf ${TEST_DIR}

# Report results
if [ ${FAILED} -eq 0 ]; then
    echo "=== All restoration tests PASSED ===" >> ${LOG_FILE}
else
    echo "=== WARNING: ${FAILED} restoration tests FAILED ===" >> ${LOG_FILE}
    mail -s "Backup Test FAILED on $(hostname)" admin@example.com < ${LOG_FILE}
fi

# Schedule next test
echo "Next test scheduled for: $(date -d '+7 days')" >> ${LOG_FILE}
```

### System Maintenance with yum-cron

Automatic updates keep systems secure, but need careful configuration in production.

```bash
# Install yum-cron for automatic updates
sudo dnf install yum-cron -y

# Configure yum-cron for production
sudo vi /etc/yum/yum-cron.conf
```

```ini
[commands]
# What updates to apply
update_cmd = security  # Only security updates in production
# update_cmd = default  # All updates (use in dev/test)

# Whether to apply updates
apply_updates = yes

# Random wait time to avoid thundering herd
random_sleep = 360

[emitters]
# How to report
emit_via = email
output_width = 160

[email]
# Email settings
email_from = root@$(hostname)
email_to = admin@example.com
email_host = localhost

[groups]
# Update groups
group_list = None
group_package_types = mandatory, default
```

```bash
# Enable and start yum-cron
sudo systemctl enable --now yum-cron

# Create custom update script for more control
cat > /usr/local/bin/controlled-update.sh << 'EOF'
#!/bin/bash
# Controlled system update with pre/post checks

LOG_FILE="/var/log/updates/update_$(date +%Y%m%d).log"
mkdir -p /var/log/updates

# Pre-update checks
echo "=== Pre-Update System Check ===" >> ${LOG_FILE}
df -h >> ${LOG_FILE}
free -h >> ${LOG_FILE}
systemctl --failed >> ${LOG_FILE}

# Create system snapshot if LVM
if lvs | grep -q root; then
    lvcreate -L 5G -s -n root_snap_$(date +%Y%m%d) /dev/vg/root
    echo "LVM snapshot created" >> ${LOG_FILE}
fi

# Check for security updates
echo "=== Checking for updates ===" >> ${LOG_FILE}
dnf check-update --security >> ${LOG_FILE} 2>&1

# Apply security updates
echo "=== Applying security updates ===" >> ${LOG_FILE}
dnf update --security -y >> ${LOG_FILE} 2>&1

# Check if reboot required
if [ -f /var/run/reboot-required ]; then
    echo "REBOOT REQUIRED" >> ${LOG_FILE}
    # Schedule reboot during maintenance window
    shutdown -r 02:00 "System reboot for security updates"
fi

# Post-update verification
echo "=== Post-Update Verification ===" >> ${LOG_FILE}
systemctl --failed >> ${LOG_FILE}
rpm -Va >> ${LOG_FILE} 2>&1

# Send report
mail -s "Update Report for $(hostname)" admin@example.com < ${LOG_FILE}
EOF

chmod +x /usr/local/bin/controlled-update.sh

# Schedule controlled updates
echo "0 2 * * 0 /usr/local/bin/controlled-update.sh" | crontab -
```

### Rocky Linux Documentation Standards

Good documentation is like a good map - it helps others (including future you) navigate the system.

```bash
# Create documentation structure
mkdir -p /usr/local/doc/{systems,procedures,incidents,changes}

# System documentation template
cat > /usr/local/doc/systems/$(hostname).md << 'EOF'
# System Documentation: $(hostname)

## System Overview
- **Purpose**: Web server for example.com
- **Environment**: Production
- **Criticality**: High
- **Owner**: IT Operations Team
- **Last Updated**: $(date)

## Hardware Specifications
- **Model**: Dell PowerEdge R740
- **CPU**: 2x Intel Xeon Gold 6248 (40 cores total)
- **RAM**: 256GB DDR4 ECC
- **Storage**:
  - 2x 480GB SSD (RAID1) - OS
  - 6x 2TB SAS (RAID10) - Data

## Network Configuration
- **Primary IP**: 192.168.1.100/24
- **Gateway**: 192.168.1.1
- **DNS**: 8.8.8.8, 8.8.4.4
- **Firewall Ports**:
  - 22/tcp (SSH)
  - 80/tcp (HTTP)
  - 443/tcp (HTTPS)

## Installed Services
- nginx 1.20.1
- MariaDB 10.5.16
- PHP-FPM 8.0.20
- Redis 6.2.7

## Backup Schedule
- **Full Backup**: Sunday 02:00
- **Incremental**: Daily 02:00
- **Retention**: 30 days local, 90 days remote
- **Location**: /backup and backup-server:/backup/

## Monitoring
- **Monitoring System**: Zabbix
- **Alerts Go To**: ops-team@example.com
- **Key Metrics**:
  - CPU Usage < 80%
  - Memory Usage < 90%
  - Disk Usage < 85%
  - Response Time < 200ms

## Maintenance Windows
- **Regular**: Sunday 02:00-04:00
- **Emergency**: As needed with 1-hour notice

## Recovery Procedures
1. See /usr/local/doc/procedures/disaster-recovery.md
2. Backup restore: /usr/local/bin/restore-backup.sh
3. Service recovery: systemctl restart <service>

## Change History
| Date | Change | Performed By |
|------|--------|--------------|
| 2024-01-15 | Initial deployment | Admin |
| 2024-02-01 | Added Redis cache | DevOps |
| 2024-03-10 | Security updates | Security Team |
EOF

# Create runbook for common tasks
cat > /usr/local/doc/procedures/runbook.md << 'EOF'
# Operations Runbook

## Daily Checks
```bash
# Morning health check
systemctl status
df -h
free -h
systemctl --failed
tail -f /var/log/messages
```

## Common Procedures

### Restart Web Service
```bash
# Check config first
nginx -t
# Graceful restart
systemctl reload nginx
# Hard restart if needed
systemctl restart nginx
```

### Clear Disk Space
```bash
# Check usage
du -sh /* | sort -h
# Clean package cache
dnf clean all
# Clean old logs
find /var/log -name "*.gz" -mtime +30 -delete
# Remove old kernels
package-cleanup --oldkernels --count=2
```

### Performance Issues
```bash
# Check load
top
htop
# Check I/O
iotop
iostat -x 1
# Check connections
ss -ant | awk '{print $1}' | sort | uniq -c
```

## Emergency Contacts
- On-call: +1-555-0100
- Manager: +1-555-0101
- Vendor Support: +1-555-0102
EOF
```

### Update and Patch Management

Managing updates in production requires careful planning and testing.

```bash
#!/bin/bash
# /usr/local/bin/patch-management.sh

# Patch management workflow
ENVIRONMENT=${1:-production}
TEST_SERVER="test-server.example.com"
PROD_SERVERS="prod1.example.com prod2.example.com prod3.example.com"

# Function to test updates
test_updates() {
    echo "=== Testing updates on ${TEST_SERVER} ==="

    # Apply updates to test server
    ssh ${TEST_SERVER} "sudo dnf update -y"

    # Run test suite
    ssh ${TEST_SERVER} "/usr/local/bin/run-tests.sh"

    if [ $? -eq 0 ]; then
        echo "Tests PASSED on test server"
        return 0
    else
        echo "Tests FAILED on test server"
        return 1
    fi
}

# Function to deploy updates
deploy_updates() {
    local SERVER=$1
    echo "=== Deploying updates to ${SERVER} ==="

    # Remove from load balancer
    curl -X POST "http://lb.example.com/api/disable/${SERVER}"

    # Wait for connections to drain
    sleep 30

    # Create snapshot
    ssh ${SERVER} "sudo lvcreate -L 5G -s -n pre_update /dev/vg/root"

    # Apply updates
    ssh ${SERVER} "sudo dnf update -y"

    # Verify services
    ssh ${SERVER} "sudo systemctl --failed"

    if [ $? -eq 0 ]; then
        # Add back to load balancer
        curl -X POST "http://lb.example.com/api/enable/${SERVER}"
        echo "Update successful on ${SERVER}"
    else
        # Rollback
        echo "Update failed on ${SERVER}, rolling back..."
        ssh ${SERVER} "sudo lvconvert --merge /dev/vg/pre_update"
        ssh ${SERVER} "sudo reboot"
    fi
}

# Main workflow
case ${ENVIRONMENT} in
    test)
        test_updates
        ;;
    production)
        # Test first
        if test_updates; then
            # Deploy to production servers one by one
            for SERVER in ${PROD_SERVERS}; do
                deploy_updates ${SERVER}
                sleep 300  # Wait 5 minutes between servers
            done
        else
            echo "Aborting production deployment due to test failures"
            exit 1
        fi
        ;;
    *)
        echo "Usage: $0 {test|production}"
        exit 1
        ;;
esac
```

### Repository Mirroring for Offline Systems

Some production systems can't access the internet - local mirrors provide updates.

```bash
# Set up local repository mirror
sudo dnf install createrepo httpd -y

# Create mirror structure
mkdir -p /var/www/html/repos/{baseos,appstream,extras}

# Sync repositories (run regularly)
cat > /usr/local/bin/sync-repos.sh << 'EOF'
#!/bin/bash
# Sync Rocky Linux repositories locally

MIRROR="rsync://mirrors.rockylinux.org/rocky/9/"
LOCAL="/var/www/html/repos/"

# Sync BaseOS
rsync -avz --delete \
    ${MIRROR}/BaseOS/x86_64/os/ \
    ${LOCAL}/baseos/

# Sync AppStream
rsync -avz --delete \
    ${MIRROR}/AppStream/x86_64/os/ \
    ${LOCAL}/appstream/

# Sync Extras
rsync -avz --delete \
    ${MIRROR}/extras/x86_64/os/ \
    ${LOCAL}/extras/

# Update repository metadata
for repo in baseos appstream extras; do
    createrepo --update ${LOCAL}/${repo}/
done

# Update repo files for clients
cat > ${LOCAL}/local-rocky.repo << 'REPO'
[local-baseos]
name=Rocky Linux $releasever - BaseOS (Local)
baseurl=http://repo.example.com/repos/baseos/
enabled=1
gpgcheck=1
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-Rocky-9

[local-appstream]
name=Rocky Linux $releasever - AppStream (Local)
baseurl=http://repo.example.com/repos/appstream/
enabled=1
gpgcheck=1
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-Rocky-9

[local-extras]
name=Rocky Linux $releasever - Extras (Local)
baseurl=http://repo.example.com/repos/extras/
enabled=1
gpgcheck=1
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-Rocky-9
REPO
EOF

chmod +x /usr/local/bin/sync-repos.sh

# Schedule daily sync
echo "0 2 * * * /usr/local/bin/sync-repos.sh" | crontab -

# Configure Apache
cat > /etc/httpd/conf.d/repos.conf << 'EOF'
<Directory "/var/www/html/repos">
    Options Indexes FollowSymLinks
    AllowOverride None
    Require all granted
</Directory>
EOF

sudo systemctl enable --now httpd
```

### Monitoring Integration

Production systems need comprehensive monitoring - integrate with enterprise tools.

```bash
#!/bin/bash
# /usr/local/bin/monitoring-integration.sh

# Zabbix agent configuration
sudo dnf install zabbix-agent -y

cat > /etc/zabbix/zabbix_agentd.conf << 'EOF'
Server=zabbix.example.com
ServerActive=zabbix.example.com
Hostname=$(hostname -f)
EnableRemoteCommands=0
LogFileSize=10
Include=/etc/zabbix/zabbix_agentd.d/*.conf

# Custom metrics
UserParameter=backup.status,tail -1 /var/log/backup/status
UserParameter=update.pending,dnf check-update --security -q | wc -l
UserParameter=disk.prediction,df -h / | awk 'NR==2 {print $5}' | sed 's/%//'
EOF

# Prometheus node exporter
sudo dnf install prometheus-node-exporter -y
sudo systemctl enable --now prometheus-node-exporter

# Custom metrics for Prometheus
cat > /usr/local/bin/custom-metrics.sh << 'METRICS'
#!/bin/bash
# Generate custom metrics in Prometheus format

cat << EOF
# HELP backup_last_success_timestamp Last successful backup
# TYPE backup_last_success_timestamp gauge
backup_last_success_timestamp $(stat -c %Y /backup/.last_success 2>/dev/null || echo 0)

# HELP system_updates_pending Number of pending security updates
# TYPE system_updates_pending gauge
system_updates_pending $(dnf check-update --security -q | wc -l)

# HELP certificate_expiry_days Days until SSL certificate expires
# TYPE certificate_expiry_days gauge
certificate_expiry_days $(openssl x509 -in /etc/ssl/certs/server.crt -noout -dates | grep notAfter | cut -d= -f2 | xargs -I {} date -d {} +%s | xargs -I {} expr {} - $(date +%s) | xargs -I {} expr {} / 86400)
EOF
METRICS

chmod +x /usr/local/bin/custom-metrics.sh

# Add to cron for text file collector
echo "* * * * * /usr/local/bin/custom-metrics.sh > /var/lib/prometheus/node_exporter/custom.prom" | crontab -
```

### Incident Response Procedures

When things go wrong in production, quick and organized response is critical.

```bash
# Create incident response toolkit
cat > /usr/local/bin/incident-response.sh << 'EOF'
#!/bin/bash
# Incident Response Automation

INCIDENT_ID="INC$(date +%Y%m%d%H%M)"
INCIDENT_DIR="/var/log/incidents/${INCIDENT_ID}"
SLACK_WEBHOOK="https://hooks.slack.com/services/YOUR/WEBHOOK/URL"

# Create incident directory
mkdir -p ${INCIDENT_DIR}

# Function to notify team
notify_team() {
    local MESSAGE=$1
    local SEVERITY=$2

    # Send to Slack
    curl -X POST ${SLACK_WEBHOOK} \
        -H 'Content-Type: application/json' \
        -d "{\"text\":\"${SEVERITY}: ${MESSAGE} - Incident ${INCIDENT_ID}\"}"

    # Send email
    echo "${MESSAGE}" | mail -s "${SEVERITY}: Incident ${INCIDENT_ID}" oncall@example.com

    # Log
    echo "$(date): ${SEVERITY} - ${MESSAGE}" >> ${INCIDENT_DIR}/timeline.txt
}

# Function to collect diagnostics
collect_diagnostics() {
    echo "Collecting system diagnostics..."

    # System state
    systemctl status > ${INCIDENT_DIR}/systemctl_status.txt
    ps auxf > ${INCIDENT_DIR}/processes.txt
    ss -tulnp > ${INCIDENT_DIR}/network_connections.txt

    # Resource usage
    df -h > ${INCIDENT_DIR}/disk_usage.txt
    free -m > ${INCIDENT_DIR}/memory_usage.txt
    top -b -n 1 > ${INCIDENT_DIR}/top.txt

    # Recent logs
    journalctl --since "1 hour ago" > ${INCIDENT_DIR}/recent_logs.txt
    dmesg -T > ${INCIDENT_DIR}/kernel_messages.txt

    # Configuration
    tar czf ${INCIDENT_DIR}/etc_backup.tar.gz /etc 2>/dev/null
}

# Function to attempt auto-remediation
auto_remediate() {
    local ISSUE=$1

    case ${ISSUE} in
        "high_memory")
            # Clear caches
            sync && echo 3 > /proc/sys/vm/drop_caches
            systemctl restart php-fpm
            ;;
        "disk_full")
            # Clean up
            dnf clean all
            find /var/log -name "*.gz" -mtime +7 -delete
            journalctl --vacuum-time=7d
            ;;
        "service_down")
            # Restart critical services
            for SERVICE in nginx mariadb redis; do
                if ! systemctl is-active --quiet ${SERVICE}; then
                    systemctl restart ${SERVICE}
                fi
            done
            ;;
    esac
}

# Main incident response
echo "=== Incident Response Started: ${INCIDENT_ID} ==="

# Detect issue type
if [ $(df / | awk 'NR==2 {print int($5)}') -gt 90 ]; then
    ISSUE="disk_full"
    notify_team "Disk usage critical" "HIGH"
elif [ $(free | awk '/^Mem:/ {print int($3/$2 * 100)}') -gt 95 ]; then
    ISSUE="high_memory"
    notify_team "Memory usage critical" "HIGH"
elif systemctl --failed | grep -q "failed"; then
    ISSUE="service_down"
    notify_team "Service failure detected" "MEDIUM"
else
    ISSUE="unknown"
    notify_team "Unknown issue detected" "LOW"
fi

# Collect diagnostics
collect_diagnostics

# Attempt remediation
auto_remediate ${ISSUE}

# Verify remediation
sleep 10
if [ ${ISSUE} != "unknown" ]; then
    # Re-check issue
    case ${ISSUE} in
        "disk_full")
            if [ $(df / | awk 'NR==2 {print int($5)}') -lt 85 ]; then
                notify_team "Disk space issue resolved" "INFO"
            else
                notify_team "Disk space issue persists - manual intervention required" "HIGH"
            fi
            ;;
        "high_memory")
            if [ $(free | awk '/^Mem:/ {print int($3/$2 * 100)}') -lt 90 ]; then
                notify_team "Memory issue resolved" "INFO"
            else
                notify_team "Memory issue persists - manual intervention required" "HIGH"
            fi
            ;;
        "service_down")
            if ! systemctl --failed | grep -q "failed"; then
                notify_team "Service issue resolved" "INFO"
            else
                notify_team "Service issue persists - manual intervention required" "HIGH"
            fi
            ;;
    esac
fi

echo "Incident response complete. Details in: ${INCIDENT_DIR}"
EOF

chmod +x /usr/local/bin/incident-response.sh
```

### Practical Exercise: Production Maintenance

Let's implement a complete maintenance procedure:

```bash
# 1. Create maintenance mode script
cat > /usr/local/bin/maintenance-mode.sh << 'EOF'
#!/bin/bash
ACTION=$1

case ${ACTION} in
    enable)
        # Create maintenance page
        cat > /var/www/html/maintenance.html << 'HTML'
<!DOCTYPE html>
<html>
<head>
    <title>Maintenance in Progress</title>
    <style>
        body { font-family: Arial; text-align: center; padding: 50px; }
        h1 { color: #ff6600; }
    </style>
</head>
<body>
    <h1>System Maintenance</h1>
    <p>We are currently performing scheduled maintenance.</p>
    <p>Expected completion: 04:00 UTC</p>
    <p>Thank you for your patience.</p>
</body>
</html>
HTML

        # Redirect traffic to maintenance page
        cat > /etc/nginx/maintenance.conf << 'NGINX'
        location / {
            return 503;
        }
        error_page 503 @maintenance;
        location @maintenance {
            root /var/www/html;
            rewrite ^.*$ /maintenance.html break;
        }
NGINX

        nginx -s reload
        echo "Maintenance mode ENABLED"
        ;;

    disable)
        rm -f /etc/nginx/maintenance.conf
        rm -f /var/www/html/maintenance.html
        nginx -s reload
        echo "Maintenance mode DISABLED"
        ;;

    *)
        echo "Usage: $0 {enable|disable}"
        exit 1
        ;;
esac
EOF

chmod +x /usr/local/bin/maintenance-mode.sh

# 2. Create comprehensive maintenance script
cat > /usr/local/bin/perform-maintenance.sh << 'EOF'
#!/bin/bash
# Complete maintenance procedure

LOG="/var/log/maintenance/maintenance_$(date +%Y%m%d).log"
mkdir -p /var/log/maintenance

echo "=== Starting Maintenance: $(date) ===" | tee -a ${LOG}

# Enable maintenance mode
/usr/local/bin/maintenance-mode.sh enable | tee -a ${LOG}

# Backup before maintenance
/usr/local/bin/enterprise-backup.sh | tee -a ${LOG}

# Apply updates
dnf update -y | tee -a ${LOG}

# Clean up old files
find /var/log -name "*.gz" -mtime +30 -delete
journalctl --vacuum-time=30d
dnf clean all

# Database maintenance
mysql -e "OPTIMIZE TABLE mysql.user;" 2>/dev/null
vacuumdb --all --analyze 2>/dev/null

# Check and repair filesystems
xfs_fsr /

# Update virus definitions (if applicable)
freshclam 2>/dev/null

# Restart services in correct order
systemctl restart mariadb
sleep 5
systemctl restart redis
systemctl restart php-fpm
systemctl restart nginx

# Verification
systemctl --failed | tee -a ${LOG}

# Disable maintenance mode
/usr/local/bin/maintenance-mode.sh disable | tee -a ${LOG}

echo "=== Maintenance Complete: $(date) ===" | tee -a ${LOG}

# Send report
mail -s "Maintenance Report - $(hostname)" admin@example.com < ${LOG}
EOF

chmod +x /usr/local/bin/perform-maintenance.sh
```

### Review Questions

1. What is the 3-2-1 backup rule?
2. How do you verify backup integrity?
3. What's the difference between yum-cron update_cmd options?
4. How do you create a local repository mirror?
5. What should be included in system documentation?
6. How do you implement rolling updates in production?
7. What metrics should be monitored in production?

### Practical Lab

Implement production maintenance:
1. Set up enterprise backup system with verification
2. Configure automated security updates
3. Create system documentation
4. Implement local repository mirror
5. Set up monitoring integration
6. Create incident response procedures
7. Test maintenance mode and procedures

---

## Chapter 25: Production Best Practices

### Introduction

Running production systems is like conducting an orchestra - every component must work in harmony, following best practices ensures beautiful music instead of chaos. This chapter covers enterprise standards, compliance, and patterns for reliable Rocky Linux operations.

### Rocky Linux Documentation Standards

Documentation in production is like leaving breadcrumbs - it helps others follow your path.

```bash
# Create comprehensive documentation framework
mkdir -p /opt/documentation/{architecture,runbooks,policies,compliance}

# System architecture documentation
cat > /opt/documentation/architecture/system-design.md << 'EOF'
# System Architecture Document

## Executive Summary
This document describes the production architecture for the Example Corp web platform running on Rocky Linux 9.

## Architecture Overview

```
Internet
    |
[Load Balancer]
    |
    +--- [Web Server 1] ---+
    |                      |
    +--- [Web Server 2] ---+--- [Database Primary]
    |                      |           |
    +--- [Web Server 3] ---+     [Database Replica]
                          |
                    [Cache Server]
```

## Component Details

### Web Servers (Rocky Linux 9)
- **Role**: Application hosting
- **Software**: Nginx 1.20, PHP-FPM 8.0
- **Configuration**: /etc/nginx/sites-available/
- **Logs**: /var/log/nginx/
- **Monitoring**: Port 80, 443, response time < 200ms

### Database Servers (Rocky Linux 9)
- **Role**: Data persistence
- **Software**: MariaDB 10.5 (Galera Cluster)
- **Configuration**: /etc/my.cnf.d/
- **Data**: /var/lib/mysql/
- **Backup**: Daily at 02:00 UTC
- **Replication**: Synchronous, 3 nodes

### Cache Server (Rocky Linux 9)
- **Role**: Performance optimization
- **Software**: Redis 6.2
- **Configuration**: /etc/redis.conf
- **Persistence**: AOF enabled
- **Memory**: 16GB allocated

## Network Architecture

### VLANs
- VLAN 100: Public DMZ (Web servers)
- VLAN 200: Application tier
- VLAN 300: Database tier
- VLAN 400: Management

### Firewall Rules
| Source | Destination | Port | Protocol | Purpose |
|--------|------------|------|----------|---------|
| Internet | Web Servers | 80,443 | TCP | Web traffic |
| Web Servers | Database | 3306 | TCP | Database queries |
| Web Servers | Cache | 6379 | TCP | Redis cache |
| Management | All | 22 | TCP | SSH administration |

## Security Measures
- SELinux: Enforcing mode
- Firewall: firewalld with strict zones
- Updates: Automated security patches
- Monitoring: Real-time intrusion detection
- Compliance: CIS Level 1 benchmark

## Disaster Recovery
- RPO: 1 hour
- RTO: 2 hours
- Backup Location: AWS S3 and local NAS
- Tested: Quarterly
EOF
```

### Change Management Process

Changes in production need careful planning - like surgery requires preparation.

```bash
#!/bin/bash
# /usr/local/bin/change-management.sh

# Change request system
CHANGE_DIR="/var/log/changes"
CHANGE_ID="CHG$(date +%Y%m%d%H%M)"

mkdir -p ${CHANGE_DIR}

# Create change request template
create_change_request() {
    cat > ${CHANGE_DIR}/${CHANGE_ID}.md << 'EOF'
# Change Request: ${CHANGE_ID}

## Change Details
- **Date**: $(date)
- **Requestor**: ${USER}
- **Type**: [ ] Standard [ ] Emergency [ ] Major
- **Risk Level**: [ ] Low [ ] Medium [ ] High
- **Environment**: [ ] Development [ ] Testing [ ] Production

## Description
What is being changed and why?

## Business Justification
Why is this change necessary?

## Technical Details
### Current State
Describe current configuration

### Desired State
Describe target configuration

### Implementation Steps
1. Step one
2. Step two
3. Step three

## Testing Plan
How will we verify the change works?

## Rollback Plan
How do we undo if something goes wrong?

## Impact Analysis
- **Services Affected**:
- **Users Affected**:
- **Downtime Required**:
- **Dependencies**:

## Approval
- [ ] Technical Lead: ________
- [ ] Operations Manager: ________
- [ ] Security Team: ________

## Post-Implementation
- [ ] Change implemented successfully
- [ ] Testing completed
- [ ] Documentation updated
- [ ] Stakeholders notified
EOF
}

# Pre-change validation
pre_change_checks() {
    echo "=== Pre-Change Validation ==="

    # Check system health
    if systemctl --failed | grep -q failed; then
        echo "ERROR: System has failed services"
        return 1
    fi

    # Check backup status
    if [ ! -f /backup/.last_success ]; then
        echo "ERROR: No recent successful backup"
        return 1
    fi

    # Check disk space
    if [ $(df / | awk 'NR==2 {print int($5)}') -gt 80 ]; then
        echo "WARNING: Low disk space"
    fi

    # Create snapshot
    if lvs | grep -q root; then
        lvcreate -L 5G -s -n change_${CHANGE_ID} /dev/vg/root
        echo "Snapshot created: change_${CHANGE_ID}"
    fi

    return 0
}

# Post-change validation
post_change_checks() {
    echo "=== Post-Change Validation ==="

    # Service verification
    for SERVICE in nginx mariadb redis; do
        if systemctl is-active --quiet ${SERVICE}; then
            echo "✓ ${SERVICE} is running"
        else
            echo "✗ ${SERVICE} is not running"
        fi
    done

    # Application verification
    curl -s http://localhost/health > /dev/null
    if [ $? -eq 0 ]; then
        echo "✓ Application responding"
    else
        echo "✗ Application not responding"
    fi

    # Check logs for errors
    if journalctl --since "10 minutes ago" | grep -i error; then
        echo "WARNING: Errors found in logs"
    fi
}

# Main change process
case $1 in
    create)
        create_change_request
        echo "Change request created: ${CHANGE_DIR}/${CHANGE_ID}.md"
        ;;
    pre-check)
        pre_change_checks
        ;;
    post-check)
        post_change_checks
        ;;
    *)
        echo "Usage: $0 {create|pre-check|post-check}"
        ;;
esac
```

### Security Compliance

Meeting security standards is like passing inspection - everything must be in order.

```bash
# Install OpenSCAP for compliance scanning
sudo dnf install openscap-scanner scap-security-guide -y

# Run CIS benchmark scan
oscap xccdf eval \
    --profile xccdf_org.ssgproject.content_profile_cis \
    --report /var/log/compliance/cis-report.html \
    /usr/share/xml/scap/ssg/content/ssg-rl9-ds.xml

# Create compliance automation
cat > /usr/local/bin/compliance-check.sh << 'EOF'
#!/bin/bash
# Automated compliance checking

COMPLIANCE_DIR="/var/log/compliance"
DATE=$(date +%Y%m%d)
REPORT="${COMPLIANCE_DIR}/compliance_${DATE}.txt"

mkdir -p ${COMPLIANCE_DIR}

echo "=== Rocky Linux Compliance Check ===" > ${REPORT}
echo "Date: $(date)" >> ${REPORT}
echo "" >> ${REPORT}

# PCI DSS Compliance Checks
echo "=== PCI DSS Compliance ===" >> ${REPORT}

# 2.2.2 - Enable only necessary services
UNNECESSARY_SERVICES="telnet rsh ypbind tftp"
for SERVICE in ${UNNECESSARY_SERVICES}; do
    if systemctl is-enabled ${SERVICE} 2>/dev/null | grep -q enabled; then
        echo "FAIL: ${SERVICE} is enabled" >> ${REPORT}
    else
        echo "PASS: ${SERVICE} is disabled" >> ${REPORT}
    fi
done

# 2.2.3 - Implement additional security features
if getenforce | grep -q Enforcing; then
    echo "PASS: SELinux is enforcing" >> ${REPORT}
else
    echo "FAIL: SELinux is not enforcing" >> ${REPORT}
fi

# 2.3 - Encrypt non-console access
if sshd -T | grep -q "protocol 2"; then
    echo "PASS: SSH protocol 2 only" >> ${REPORT}
else
    echo "FAIL: SSH protocol not restricted" >> ${REPORT}
fi

# 7.1 - Limit access to system components
if grep -q "TMOUT=900" /etc/profile; then
    echo "PASS: Session timeout configured" >> ${REPORT}
else
    echo "FAIL: Session timeout not configured" >> ${REPORT}
fi

# 8.2.3 - Strong password requirements
if grep -q "minlen=14" /etc/security/pwquality.conf; then
    echo "PASS: Password minimum length adequate" >> ${REPORT}
else
    echo "FAIL: Password minimum length inadequate" >> ${REPORT}
fi

# 10.2 - Implement audit trails
if systemctl is-active auditd | grep -q active; then
    echo "PASS: Audit daemon running" >> ${REPORT}
else
    echo "FAIL: Audit daemon not running" >> ${REPORT}
fi

# HIPAA Compliance Checks
echo "" >> ${REPORT}
echo "=== HIPAA Compliance ===" >> ${REPORT}

# Access controls
if [ -f /etc/pam.d/system-auth ]; then
    if grep -q "pam_faillock.so" /etc/pam.d/system-auth; then
        echo "PASS: Account lockout configured" >> ${REPORT}
    else
        echo "FAIL: Account lockout not configured" >> ${REPORT}
    fi
fi

# Encryption at rest
if lsblk -o NAME,FSTYPE | grep -q crypto_LUKS; then
    echo "PASS: Disk encryption enabled" >> ${REPORT}
else
    echo "WARNING: Disk encryption not detected" >> ${REPORT}
fi

# Generate score
PASS_COUNT=$(grep -c "PASS:" ${REPORT})
FAIL_COUNT=$(grep -c "FAIL:" ${REPORT})
SCORE=$((PASS_COUNT * 100 / (PASS_COUNT + FAIL_COUNT)))

echo "" >> ${REPORT}
echo "=== Compliance Score: ${SCORE}% ===" >> ${REPORT}
echo "Passed: ${PASS_COUNT}, Failed: ${FAIL_COUNT}" >> ${REPORT}

# Alert if score is low
if [ ${SCORE} -lt 80 ]; then
    mail -s "ALERT: Compliance score ${SCORE}% on $(hostname)" security@example.com < ${REPORT}
fi
EOF

chmod +x /usr/local/bin/compliance-check.sh

# Schedule daily compliance checks
echo "0 6 * * * /usr/local/bin/compliance-check.sh" | crontab -
```

### Performance Monitoring Baselines

Understanding normal performance is like knowing your resting heart rate - it helps identify problems.

```bash
#!/bin/bash
# /usr/local/bin/performance-baseline.sh

# Create performance baseline
BASELINE_DIR="/var/log/performance/baselines"
mkdir -p ${BASELINE_DIR}

# Collect baseline over 24 hours
collect_baseline() {
    local OUTPUT="${BASELINE_DIR}/baseline_$(date +%Y%m%d).csv"

    echo "timestamp,cpu_usage,memory_usage,disk_io,network_io,load_avg" > ${OUTPUT}

    for i in {1..1440}; do  # Every minute for 24 hours
        TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')
        CPU=$(top -b -n1 | grep "Cpu(s)" | awk '{print $2}' | cut -d'%' -f1)
        MEMORY=$(free | grep Mem | awk '{print int($3/$2 * 100)}')
        DISK_IO=$(iostat -x 1 2 | grep -A1 avg-cpu | tail -1 | awk '{print $4}')
        NETWORK_IO=$(ifstat 1 1 | tail -1 | awk '{print $1+$2}')
        LOAD=$(uptime | awk -F'load average:' '{print $2}' | awk '{print $1}')

        echo "${TIMESTAMP},${CPU},${MEMORY},${DISK_IO},${NETWORK_IO},${LOAD}" >> ${OUTPUT}

        sleep 60
    done
}

# Analyze baseline
analyze_baseline() {
    local INPUT="${BASELINE_DIR}/baseline_$(date +%Y%m%d).csv"
    local REPORT="${BASELINE_DIR}/analysis_$(date +%Y%m%d).txt"

    echo "=== Performance Baseline Analysis ===" > ${REPORT}
    echo "Date: $(date)" >> ${REPORT}
    echo "" >> ${REPORT}

    # Calculate statistics using awk
    awk -F',' 'NR>1 {
        cpu+=$2; mem+=$3; disk+=$4; net+=$5; load+=$6;
        if($2>max_cpu) max_cpu=$2;
        if($3>max_mem) max_mem=$3;
        if($4>max_disk) max_disk=$4;
        if($5>max_net) max_net=$5;
        if($6>max_load) max_load=$6;
    }
    END {
        count=NR-1;
        printf "Average CPU: %.2f%%\n", cpu/count;
        printf "Average Memory: %.2f%%\n", mem/count;
        printf "Average Disk I/O: %.2f\n", disk/count;
        printf "Average Network I/O: %.2f\n", net/count;
        printf "Average Load: %.2f\n\n", load/count;
        printf "Peak CPU: %.2f%%\n", max_cpu;
        printf "Peak Memory: %.2f%%\n", max_mem;
        printf "Peak Disk I/O: %.2f\n", max_disk;
        printf "Peak Network I/O: %.2f\n", max_net;
        printf "Peak Load: %.2f\n", max_load;
    }' ${INPUT} >> ${REPORT}

    # Set alert thresholds based on baseline
    echo "" >> ${REPORT}
    echo "=== Recommended Alert Thresholds ===" >> ${REPORT}
    awk -F',' 'NR>1 {cpu+=$2; mem+=$3; load+=$6}
    END {
        count=NR-1;
        printf "CPU Alert: > %.0f%%\n", (cpu/count)*1.5;
        printf "Memory Alert: > %.0f%%\n", (mem/count)*1.2;
        printf "Load Alert: > %.1f\n", (load/count)*2;
    }' ${INPUT} >> ${REPORT}

    cat ${REPORT}
}

# Generate capacity planning report
capacity_planning() {
    echo "=== Capacity Planning Report ==="

    # Disk growth trend
    echo "Disk Usage Trend (last 30 days):"
    for i in {30..1}; do
        DATE=$(date -d "$i days ago" +%Y%m%d)
        SIZE=$(find /var/log -name "*${DATE}*" 2>/dev/null | xargs du -sc 2>/dev/null | tail -1 | awk '{print $1}')
        [ ! -z "${SIZE}" ] && echo "$(date -d "$i days ago" +%Y-%m-%d): ${SIZE}KB"
    done | tail -5

    # Memory usage trend
    echo ""
    echo "Memory Usage Trend:"
    sar -r | tail -5

    # Projection
    echo ""
    echo "Projections:"
    echo "At current growth rate:"
    echo "- Disk will be full in: ~90 days"
    echo "- Memory upgrade needed in: ~180 days"
    echo "- CPU upgrade recommended in: ~365 days"
}

case $1 in
    collect)
        collect_baseline &
        echo "Baseline collection started (24 hours)"
        ;;
    analyze)
        analyze_baseline
        ;;
    capacity)
        capacity_planning
        ;;
    *)
        echo "Usage: $0 {collect|analyze|capacity}"
        ;;
esac
```

### Backup Verification Procedures

Untested backups are just hope - verification turns hope into confidence.

```bash
#!/bin/bash
# /usr/local/bin/backup-verification.sh

# Comprehensive backup verification
VERIFY_DIR="/tmp/backup_verify_$(date +%Y%m%d)"
BACKUP_DIR="/backup"
REPORT="/var/log/backup/verification_$(date +%Y%m%d).log"

# Create isolated verification environment
setup_verification() {
    mkdir -p ${VERIFY_DIR}

    # Create test database
    if command -v mysql &> /dev/null; then
        mysql -e "CREATE DATABASE IF NOT EXISTS backup_test;"
        mysql -e "CREATE TABLE IF NOT EXISTS backup_test.verify (id INT, data VARCHAR(100));"
        mysql -e "INSERT INTO backup_test.verify VALUES (1, 'test_data');"
    fi
}

# Verify file backup
verify_file_backup() {
    local BACKUP_FILE=$1
    echo "Verifying: ${BACKUP_FILE}" >> ${REPORT}

    # Check file exists
    if [ ! -f ${BACKUP_FILE} ]; then
        echo "FAIL: Backup file not found" >> ${REPORT}
        return 1
    fi

    # Verify checksum
    if [ -f ${BACKUP_FILE}.sha256 ]; then
        sha256sum -c ${BACKUP_FILE}.sha256 >> ${REPORT} 2>&1
        if [ $? -ne 0 ]; then
            echo "FAIL: Checksum mismatch" >> ${REPORT}
            return 1
        fi
    fi

    # Test extraction
    tar tzf ${BACKUP_FILE} > /dev/null 2>&1
    if [ $? -eq 0 ]; then
        echo "PASS: Archive is valid" >> ${REPORT}

        # Extract sample files
        tar xzf ${BACKUP_FILE} -C ${VERIFY_DIR} \
            --wildcards "*/passwd" "*/group" 2>/dev/null

        # Verify critical files
        if [ -f ${VERIFY_DIR}/etc/passwd ]; then
            echo "PASS: Critical files present" >> ${REPORT}
        else
            echo "WARNING: Some files missing" >> ${REPORT}
        fi
    else
        echo "FAIL: Archive corrupted" >> ${REPORT}
        return 1
    fi

    return 0
}

# Verify database backup
verify_database_backup() {
    local DB_BACKUP=$1
    echo "Verifying database backup: ${DB_BACKUP}" >> ${REPORT}

    if [ -f ${DB_BACKUP} ]; then
        # Test restore to temporary database
        mysql backup_test < ${DB_BACKUP} 2>> ${REPORT}

        if [ $? -eq 0 ]; then
            # Verify data
            RESULT=$(mysql -e "SELECT COUNT(*) FROM backup_test.verify;" 2>/dev/null)
            if [ ! -z "${RESULT}" ]; then
                echo "PASS: Database restore successful" >> ${REPORT}
            else
                echo "FAIL: Database restore incomplete" >> ${REPORT}
            fi
        else
            echo "FAIL: Database restore failed" >> ${REPORT}
        fi
    else
        echo "FAIL: Database backup not found" >> ${REPORT}
    fi
}

# Main verification
echo "=== Backup Verification Started: $(date) ===" > ${REPORT}

setup_verification

# Find and verify recent backups
for BACKUP in $(find ${BACKUP_DIR} -name "*.tar.gz" -mtime -1); do
    verify_file_backup ${BACKUP}
done

# Verify database backups
for DB_BACKUP in $(find ${BACKUP_DIR} -name "*.sql" -mtime -1); do
    verify_database_backup ${DB_BACKUP}
done

# Cleanup
rm -rf ${VERIFY_DIR}
mysql -e "DROP DATABASE IF EXISTS backup_test;" 2>/dev/null

# Summary
PASS_COUNT=$(grep -c "PASS:" ${REPORT})
FAIL_COUNT=$(grep -c "FAIL:" ${REPORT})

echo "" >> ${REPORT}
echo "=== Verification Summary ===" >> ${REPORT}
echo "Passed: ${PASS_COUNT}" >> ${REPORT}
echo "Failed: ${FAIL_COUNT}" >> ${REPORT}

# Alert on failures
if [ ${FAIL_COUNT} -gt 0 ]; then
    mail -s "ALERT: Backup verification failures on $(hostname)" admin@example.com < ${REPORT}
fi
```

### System Hardening with OpenSCAP

Hardening is like reinforcing a fortress - multiple layers of defense.

```bash
#!/bin/bash
# /usr/local/bin/system-hardening.sh

# Apply CIS Level 1 hardening
apply_hardening() {
    echo "=== Applying Rocky Linux CIS Hardening ==="

    # 1.1.1 - Disable unused filesystems
    for FS in cramfs freevxfs jffs2 hfs hfsplus squashfs udf vfat; do
        echo "install ${FS} /bin/true" > /etc/modprobe.d/${FS}.conf
        rmmod ${FS} 2>/dev/null
    done

    # 1.3.1 - Ensure AIDE is installed
    dnf install aide -y
    aide --init
    mv /var/lib/aide/aide.db.new.gz /var/lib/aide/aide.db.gz

    # 1.4.1 - Ensure bootloader password is set
    grub2-setpassword

    # 1.5.1 - Ensure core dumps are restricted
    echo "* hard core 0" >> /etc/security/limits.conf
    echo "fs.suid_dumpable = 0" >> /etc/sysctl.d/99-hardening.conf

    # 2.2.1.1 - Ensure time synchronization is in use
    systemctl enable --now chronyd

    # 3.1.1 - Disable IPv6 if not needed
    if ! ip -6 addr | grep -q global; then
        echo "net.ipv6.conf.all.disable_ipv6 = 1" >> /etc/sysctl.d/99-hardening.conf
        echo "net.ipv6.conf.default.disable_ipv6 = 1" >> /etc/sysctl.d/99-hardening.conf
    fi

    # 3.2.1 - Ensure packet redirect sending is disabled
    cat >> /etc/sysctl.d/99-hardening.conf << 'EOF'
net.ipv4.conf.all.send_redirects = 0
net.ipv4.conf.default.send_redirects = 0
net.ipv4.conf.all.accept_source_route = 0
net.ipv4.conf.default.accept_source_route = 0
net.ipv4.conf.all.accept_redirects = 0
net.ipv4.conf.default.accept_redirects = 0
net.ipv4.conf.all.secure_redirects = 0
net.ipv4.conf.default.secure_redirects = 0
net.ipv4.conf.all.log_martians = 1
net.ipv4.conf.default.log_martians = 1
net.ipv4.icmp_echo_ignore_broadcasts = 1
net.ipv4.icmp_ignore_bogus_error_responses = 1
net.ipv4.conf.all.rp_filter = 1
net.ipv4.conf.default.rp_filter = 1
net.ipv4.tcp_syncookies = 1
EOF

    sysctl -p /etc/sysctl.d/99-hardening.conf

    # 4.1.1 - Ensure auditing is enabled
    systemctl enable --now auditd

    # 4.2.1 - Configure rsyslog
    systemctl enable --now rsyslog

    # 5.1.1 - Ensure cron daemon is enabled
    systemctl enable --now crond

    # 5.2.1 - Ensure SSH config is hardened
    cat >> /etc/ssh/sshd_config.d/99-hardening.conf << 'EOF'
Protocol 2
LogLevel INFO
X11Forwarding no
MaxAuthTries 4
IgnoreRhosts yes
HostbasedAuthentication no
PermitRootLogin no
PermitEmptyPasswords no
PermitUserEnvironment no
Ciphers chacha20-poly1305@openssh.com,aes128-ctr,aes192-ctr,aes256-ctr,aes128-gcm@openssh.com,aes256-gcm@openssh.com
MACs hmac-sha2-512-etm@openssh.com,hmac-sha2-256-etm@openssh.com,hmac-sha2-512,hmac-sha2-256
ClientAliveInterval 300
ClientAliveCountMax 2
LoginGraceTime 60
MaxStartups 10:30:60
MaxSessions 4
EOF

    systemctl reload sshd

    # 5.3.1 - Ensure password creation requirements
    cat > /etc/security/pwquality.conf << 'EOF'
minlen = 14
dcredit = -1
ucredit = -1
ocredit = -1
lcredit = -1
EOF

    # 5.4.1 - Set password expiration
    sed -i 's/^PASS_MAX_DAYS.*/PASS_MAX_DAYS   90/' /etc/login.defs
    sed -i 's/^PASS_MIN_DAYS.*/PASS_MIN_DAYS   7/' /etc/login.defs
    sed -i 's/^PASS_WARN_AGE.*/PASS_WARN_AGE   7/' /etc/login.defs

    echo "Hardening complete. Please review and test all changes."
}

# Verify hardening
verify_hardening() {
    echo "=== Verifying System Hardening ==="

    ISSUES=0

    # Check SSH configuration
    if sshd -T | grep -q "permitrootlogin yes"; then
        echo "WARNING: Root login still permitted via SSH"
        ((ISSUES++))
    fi

    # Check SELinux
    if ! getenforce | grep -q Enforcing; then
        echo "WARNING: SELinux not enforcing"
        ((ISSUES++))
    fi

    # Check firewall
    if ! systemctl is-active firewalld | grep -q active; then
        echo "WARNING: Firewall not active"
        ((ISSUES++))
    fi

    # Check audit
    if ! systemctl is-active auditd | grep -q active; then
        echo "WARNING: Audit daemon not active"
        ((ISSUES++))
    fi

    if [ ${ISSUES} -eq 0 ]; then
        echo "All hardening checks passed"
    else
        echo "${ISSUES} hardening issues found"
    fi
}

case $1 in
    apply)
        apply_hardening
        ;;
    verify)
        verify_hardening
        ;;
    *)
        echo "Usage: $0 {apply|verify}"
        ;;
esac
```

### Enterprise Integration Patterns

Rocky Linux fits seamlessly into enterprise environments - it's 100% compatible with RHEL.

```bash
# Active Directory Integration
sudo dnf install realmd sssd oddjob oddjob-mkhomedir adcli samba-common-tools -y

# Join domain
sudo realm discover example.com
sudo realm join --user=admin example.com

# Configure SSSD for AD
cat > /etc/sssd/sssd.conf << 'EOF'
[sssd]
domains = example.com
config_file_version = 2
services = nss, pam

[domain/example.com]
ad_domain = example.com
krb5_realm = EXAMPLE.COM
realmd_tags = manages-system joined-with-adcli
cache_credentials = True
id_provider = ad
krb5_store_password_if_offline = True
default_shell = /bin/bash
ldap_id_mapping = True
use_fully_qualified_names = False
fallback_homedir = /home/%u
access_provider = ad
EOF

chmod 600 /etc/sssd/sssd.conf
systemctl restart sssd

# LDAP Integration
sudo dnf install openldap-clients nss-pam-ldapd -y

# Configure LDAP
authconfig --enableldap \
    --enableldapauth \
    --ldapserver="ldap://ldap.example.com" \
    --ldapbasedn="dc=example,dc=com" \
    --enablemkhomedir \
    --update

# Centralized logging with rsyslog
cat >> /etc/rsyslog.conf << 'EOF'
# Forward to central syslog server
*.* @@syslog.example.com:514

# Keep local copy
$ActionQueueType LinkedList
$ActionQueueFileName forward
$ActionResumeRetryCount -1
$ActionQueueSaveOnShutdown on
EOF

systemctl restart rsyslog
```

### Practical Exercise: Production Deployment

Let's deploy a complete production system:

```bash
# Complete production deployment script
cat > /usr/local/bin/production-deploy.sh << 'EOF'
#!/bin/bash
# Production deployment automation

echo "=== Rocky Linux Production Deployment ==="

# 1. System hardening
/usr/local/bin/system-hardening.sh apply

# 2. Configure monitoring
/usr/local/bin/monitoring-integration.sh

# 3. Set up backups
/usr/local/bin/enterprise-backup.sh

# 4. Configure compliance scanning
/usr/local/bin/compliance-check.sh

# 5. Create documentation
/usr/local/bin/generate-docs.sh

# 6. Performance baseline
/usr/local/bin/performance-baseline.sh collect &

# 7. Configure maintenance
cat > /etc/cron.d/production-maintenance << 'CRON'
# Daily backups
0 2 * * * root /usr/local/bin/enterprise-backup.sh
# Weekly compliance check
0 6 * * 0 root /usr/local/bin/compliance-check.sh
# Monthly maintenance
0 3 1 * * root /usr/local/bin/perform-maintenance.sh
# Backup verification
0 4 * * * root /usr/local/bin/backup-verification.sh
CRON

# 8. Final verification
echo "=== Deployment Verification ==="
systemctl --failed
getenforce
firewall-cmd --list-all
df -h
free -h

echo "Production deployment complete!"
EOF

chmod +x /usr/local/bin/production-deploy.sh
```

### Review Questions

1. What documentation is essential for production systems?
2. How do you implement a change management process?
3. What are key PCI DSS compliance requirements?
4. How do you establish performance baselines?
5. What's included in CIS Level 1 hardening?
6. How do you integrate Rocky Linux with Active Directory?
7. What are the critical components of backup verification?

### Practical Lab

Implement production best practices:
1. Create comprehensive system documentation
2. Implement change management process
3. Configure compliance scanning and reporting
4. Establish performance baselines
5. Apply system hardening
6. Set up enterprise integration (AD/LDAP)
7. Create and test production deployment automation

### Course Conclusion

Congratulations! You've completed the Rocky Linux Server Administration course. You now have the knowledge to:

- Deploy and manage Rocky Linux in production
- Implement enterprise-grade security and compliance
- Automate system administration tasks
- Troubleshoot and recover from failures
- Maintain reliable, high-performance systems

Remember: Rocky Linux is 100% compatible with RHEL, completely free, and backed by a strong community. Your skills are transferable across the entire Enterprise Linux ecosystem.

Keep learning, keep practicing, and welcome to the Rocky Linux community!