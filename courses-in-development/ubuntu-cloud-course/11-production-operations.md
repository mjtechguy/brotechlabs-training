# Part 11: Production Operations

## Prerequisites

Before starting this section, you should understand:
- System administration fundamentals
- Backup and recovery concepts
- Service management with systemd
- Basic scripting and automation
- Monitoring and logging principles

**Learning Resources:**
- [ITIL Service Management](https://www.axelos.com/certifications/itil-service-management)
- [Site Reliability Engineering](https://sre.google/books/)
- [Production Readiness Checklist](https://gruntwork.io/devops-checklist/)
- [Linux System Administration Handbook](https://www.oreilly.com/library/view/linux-system-administration/9780134277554/)

---

## Chapter 24: Backup and Maintenance

### Comprehensive Backup Strategies

A robust backup strategy is essential for production systems. It should follow the 3-2-1 rule: 3 copies of data, on 2 different media, with 1 offsite copy.

#### Backup Strategy Framework

```bash
# Comprehensive backup strategy implementation
sudo nano /usr/local/bin/backup-strategy.sh
```

```bash
#!/bin/bash
# Production backup strategy implementation

# Configuration
BACKUP_ROOT="/backup"
REMOTE_BACKUP="backup-server:/remote-backup"
S3_BUCKET="s3://company-backups"
RETENTION_DAYS=30
RETENTION_WEEKS=12
RETENTION_MONTHS=12

# Logging
LOG_FILE="/var/log/backup-strategy.log"
ALERT_EMAIL="ops@example.com"

log_message() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

send_alert() {
    echo "$1" | mail -s "Backup Alert: $(hostname)" "$ALERT_EMAIL"
}

# Backup Types
perform_full_backup() {
    local backup_type="full"
    local timestamp=$(date +%Y%m%d-%H%M%S)
    local backup_dir="$BACKUP_ROOT/$backup_type/$timestamp"

    log_message "Starting full backup to $backup_dir"
    mkdir -p "$backup_dir"

    # System backup
    tar -czpf "$backup_dir/system.tar.gz" \
        --exclude=/proc \
        --exclude=/sys \
        --exclude=/dev \
        --exclude=/run \
        --exclude=/tmp \
        --exclude=/mnt \
        --exclude=/media \
        --exclude=/backup \
        --one-file-system \
        / 2>> "$LOG_FILE"

    # Database backups
    backup_databases "$backup_dir"

    # Application data
    backup_applications "$backup_dir"

    # Configuration files
    backup_configs "$backup_dir"

    # Create backup manifest
    create_manifest "$backup_dir"

    # Verify backup
    verify_backup "$backup_dir"

    log_message "Full backup completed: $backup_dir"
    return 0
}

perform_incremental_backup() {
    local backup_type="incremental"
    local timestamp=$(date +%Y%m%d-%H%M%S)
    local backup_dir="$BACKUP_ROOT/$backup_type/$timestamp"
    local last_full=$(ls -t "$BACKUP_ROOT/full" | head -1)

    log_message "Starting incremental backup based on $last_full"
    mkdir -p "$backup_dir"

    # Find changed files since last full backup
    find / -type f -newer "$BACKUP_ROOT/full/$last_full" \
        -not -path "/proc/*" \
        -not -path "/sys/*" \
        -not -path "/dev/*" \
        -not -path "/run/*" \
        -not -path "/tmp/*" \
        -not -path "/backup/*" \
        2>/dev/null > "$backup_dir/changed_files.list"

    # Backup changed files
    tar -czpf "$backup_dir/incremental.tar.gz" \
        -T "$backup_dir/changed_files.list" 2>> "$LOG_FILE"

    log_message "Incremental backup completed: $backup_dir"
    return 0
}

perform_differential_backup() {
    local backup_type="differential"
    local timestamp=$(date +%Y%m%d-%H%M%S)
    local backup_dir="$BACKUP_ROOT/$backup_type/$timestamp"

    log_message "Starting differential backup"
    mkdir -p "$backup_dir"

    # Use rsync for differential backup
    rsync -av --link-dest="$BACKUP_ROOT/full/latest" \
        --exclude="/proc/*" \
        --exclude="/sys/*" \
        --exclude="/dev/*" \
        --exclude="/run/*" \
        --exclude="/tmp/*" \
        --exclude="/backup/*" \
        / "$backup_dir/" 2>> "$LOG_FILE"

    log_message "Differential backup completed: $backup_dir"
    return 0
}

# Database Backups
backup_databases() {
    local backup_dir=$1
    mkdir -p "$backup_dir/databases"

    # MySQL/MariaDB
    if systemctl is-active --quiet mysql; then
        log_message "Backing up MySQL databases"
        mysqldump --all-databases --single-transaction --routines --triggers \
            | gzip > "$backup_dir/databases/mysql_all.sql.gz"

        # Individual database backups
        mysql -e "SHOW DATABASES;" | grep -v Database | while read db; do
            if [[ "$db" != "information_schema" && "$db" != "performance_schema" ]]; then
                mysqldump --single-transaction "$db" | \
                    gzip > "$backup_dir/databases/mysql_${db}.sql.gz"
            fi
        done
    fi

    # PostgreSQL
    if systemctl is-active --quiet postgresql; then
        log_message "Backing up PostgreSQL databases"
        sudo -u postgres pg_dumpall | gzip > "$backup_dir/databases/postgresql_all.sql.gz"

        # Individual database backups
        sudo -u postgres psql -t -c "SELECT datname FROM pg_database WHERE datistemplate = false;" | \
            while read db; do
                sudo -u postgres pg_dump "$db" | \
                    gzip > "$backup_dir/databases/postgresql_${db}.sql.gz"
            done
    fi

    # MongoDB
    if systemctl is-active --quiet mongod; then
        log_message "Backing up MongoDB"
        mongodump --out "$backup_dir/databases/mongodb" --gzip
    fi

    # Redis
    if systemctl is-active --quiet redis; then
        log_message "Backing up Redis"
        cp /var/lib/redis/dump.rdb "$backup_dir/databases/redis_dump.rdb"
    fi
}

# Application Backups
backup_applications() {
    local backup_dir=$1
    mkdir -p "$backup_dir/applications"

    # Web applications
    for app_dir in /var/www/*; do
        if [ -d "$app_dir" ]; then
            app_name=$(basename "$app_dir")
            log_message "Backing up application: $app_name"
            tar -czf "$backup_dir/applications/${app_name}.tar.gz" "$app_dir"
        fi
    done

    # Docker volumes
    if command -v docker &> /dev/null; then
        docker volume ls -q | while read volume; do
            docker run --rm -v "$volume":/data -v "$backup_dir/applications":/backup \
                alpine tar -czf "/backup/docker_${volume}.tar.gz" /data
        done
    fi
}

# Configuration Backups
backup_configs() {
    local backup_dir=$1
    mkdir -p "$backup_dir/configs"

    log_message "Backing up configuration files"

    # System configurations
    tar -czf "$backup_dir/configs/etc.tar.gz" /etc

    # Package lists
    dpkg --get-selections > "$backup_dir/configs/packages.list"
    apt-mark showauto > "$backup_dir/configs/packages_auto.list"
    snap list > "$backup_dir/configs/snap_packages.list" 2>/dev/null

    # Service configurations
    systemctl list-unit-files --state=enabled > "$backup_dir/configs/enabled_services.list"

    # User configurations
    getent passwd > "$backup_dir/configs/users.list"
    getent group > "$backup_dir/configs/groups.list"

    # Cron jobs
    for user in $(cut -f1 -d: /etc/passwd); do
        crontab -l -u "$user" > "$backup_dir/configs/cron_${user}.txt" 2>/dev/null
    done
}

# Backup Manifest
create_manifest() {
    local backup_dir=$1
    local manifest="$backup_dir/manifest.json"

    cat > "$manifest" << EOF
{
    "timestamp": "$(date -Iseconds)",
    "hostname": "$(hostname -f)",
    "type": "$(basename $(dirname $backup_dir))",
    "size": "$(du -sh $backup_dir | cut -f1)",
    "files": $(find "$backup_dir" -type f | wc -l),
    "checksum": "$(find $backup_dir -type f -exec md5sum {} \; | md5sum | cut -d' ' -f1)",
    "kernel": "$(uname -r)",
    "os_version": "$(lsb_release -ds)",
    "backup_version": "1.0"
}
EOF
}

# Backup Verification
verify_backup() {
    local backup_dir=$1

    log_message "Verifying backup integrity"

    # Check tar archives
    find "$backup_dir" -name "*.tar.gz" | while read archive; do
        if ! tar -tzf "$archive" > /dev/null 2>&1; then
            send_alert "Backup verification failed for $archive"
            return 1
        fi
    done

    # Check SQL dumps
    find "$backup_dir" -name "*.sql.gz" | while read dump; do
        if ! gzip -t "$dump" > /dev/null 2>&1; then
            send_alert "Backup verification failed for $dump"
            return 1
        fi
    done

    log_message "Backup verification passed"
    return 0
}

# Offsite Replication
replicate_offsite() {
    local backup_dir=$1

    log_message "Starting offsite replication"

    # Rsync to remote server
    if [ -n "$REMOTE_BACKUP" ]; then
        rsync -av --progress "$backup_dir" "$REMOTE_BACKUP/" 2>> "$LOG_FILE"
        if [ $? -eq 0 ]; then
            log_message "Remote replication completed"
        else
            send_alert "Remote replication failed"
        fi
    fi

    # Upload to S3
    if [ -n "$S3_BUCKET" ] && command -v aws &> /dev/null; then
        aws s3 sync "$backup_dir" "$S3_BUCKET/$(basename $backup_dir)" \
            --storage-class GLACIER 2>> "$LOG_FILE"
        if [ $? -eq 0 ]; then
            log_message "S3 upload completed"
        else
            send_alert "S3 upload failed"
        fi
    fi
}

# Backup Rotation
rotate_backups() {
    log_message "Starting backup rotation"

    # Daily backups - keep for RETENTION_DAYS
    find "$BACKUP_ROOT/incremental" -type d -mtime +$RETENTION_DAYS -exec rm -rf {} \; 2>/dev/null

    # Weekly backups - keep for RETENTION_WEEKS
    find "$BACKUP_ROOT/differential" -type d -mtime +$((RETENTION_WEEKS * 7)) -exec rm -rf {} \; 2>/dev/null

    # Monthly backups - keep for RETENTION_MONTHS
    find "$BACKUP_ROOT/full" -type d -mtime +$((RETENTION_MONTHS * 30)) -exec rm -rf {} \; 2>/dev/null

    log_message "Backup rotation completed"
}

# Main backup scheduler
main() {
    log_message "=== Starting backup job ==="

    # Determine backup type based on schedule
    DAY_OF_WEEK=$(date +%w)
    DAY_OF_MONTH=$(date +%d)

    if [ "$DAY_OF_MONTH" -eq 1 ]; then
        # Monthly full backup
        perform_full_backup
        BACKUP_DIR=$(ls -t "$BACKUP_ROOT/full" | head -1)
    elif [ "$DAY_OF_WEEK" -eq 0 ]; then
        # Weekly differential backup
        perform_differential_backup
        BACKUP_DIR=$(ls -t "$BACKUP_ROOT/differential" | head -1)
    else
        # Daily incremental backup
        perform_incremental_backup
        BACKUP_DIR=$(ls -t "$BACKUP_ROOT/incremental" | head -1)
    fi

    # Replicate offsite
    replicate_offsite "$BACKUP_ROOT/$(basename $(dirname $BACKUP_DIR))/$(basename $BACKUP_DIR)"

    # Rotate old backups
    rotate_backups

    log_message "=== Backup job completed ==="
}

# Run main function
main "$@"
```

### Testing Backup Restoration

#### Automated Restoration Testing

```bash
# Backup restoration testing framework
sudo nano /usr/local/bin/test-restore.sh
```

```bash
#!/bin/bash
# Automated backup restoration testing

TEST_DIR="/tmp/restore-test-$(date +%Y%m%d-%H%M%S)"
REPORT_FILE="/var/log/restore-test.log"

log_message() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$REPORT_FILE"
}

# Test file restoration
test_file_restore() {
    local backup_file=$1
    local test_restore="$TEST_DIR/files"

    log_message "Testing file restoration from $backup_file"
    mkdir -p "$test_restore"

    # Extract backup
    if tar -xzf "$backup_file" -C "$test_restore" 2>/dev/null; then
        # Verify critical files
        critical_files=(
            "etc/passwd"
            "etc/group"
            "etc/fstab"
            "etc/hostname"
        )

        for file in "${critical_files[@]}"; do
            if [ ! -f "$test_restore/$file" ]; then
                log_message "ERROR: Missing critical file $file"
                return 1
            fi
        done

        log_message "File restoration test PASSED"
        return 0
    else
        log_message "ERROR: File restoration failed"
        return 1
    fi
}

# Test database restoration
test_database_restore() {
    local backup_file=$1
    local db_type=$2

    log_message "Testing $db_type database restoration"

    case "$db_type" in
        mysql)
            # Create test database
            mysql -e "CREATE DATABASE IF NOT EXISTS restore_test;"

            # Restore backup
            if zcat "$backup_file" | mysql restore_test 2>/dev/null; then
                # Verify restoration
                tables=$(mysql -e "USE restore_test; SHOW TABLES;" | wc -l)
                if [ "$tables" -gt 1 ]; then
                    log_message "MySQL restoration test PASSED ($tables tables)"
                    mysql -e "DROP DATABASE restore_test;"
                    return 0
                fi
            fi
            log_message "ERROR: MySQL restoration failed"
            return 1
            ;;

        postgresql)
            # Create test database
            sudo -u postgres createdb restore_test

            # Restore backup
            if zcat "$backup_file" | sudo -u postgres psql restore_test 2>/dev/null; then
                # Verify restoration
                tables=$(sudo -u postgres psql restore_test -t -c "SELECT COUNT(*) FROM information_schema.tables WHERE table_schema='public';")
                if [ "$tables" -gt 0 ]; then
                    log_message "PostgreSQL restoration test PASSED ($tables tables)"
                    sudo -u postgres dropdb restore_test
                    return 0
                fi
            fi
            log_message "ERROR: PostgreSQL restoration failed"
            return 1
            ;;
    esac
}

# Test application restore
test_application_restore() {
    local backup_file=$1
    local test_restore="$TEST_DIR/app"

    log_message "Testing application restoration"
    mkdir -p "$test_restore"

    if tar -xzf "$backup_file" -C "$test_restore" 2>/dev/null; then
        # Check for application files
        if [ -d "$test_restore/var/www" ]; then
            app_files=$(find "$test_restore/var/www" -type f | wc -l)
            log_message "Application restoration test PASSED ($app_files files)"
            return 0
        fi
    fi

    log_message "ERROR: Application restoration failed"
    return 1
}

# Restoration speed test
test_restore_speed() {
    local backup_file=$1
    local size=$(du -h "$backup_file" | cut -f1)

    log_message "Testing restoration speed for $size backup"

    start_time=$(date +%s)
    tar -xzf "$backup_file" -C "$TEST_DIR" 2>/dev/null
    end_time=$(date +%s)

    duration=$((end_time - start_time))
    speed=$(echo "scale=2; $(stat -c%s $backup_file) / $duration / 1048576" | bc)

    log_message "Restoration completed in $duration seconds ($speed MB/s)"

    # Alert if restoration is too slow
    if [ "$duration" -gt 3600 ]; then
        log_message "WARNING: Restoration took more than 1 hour"
    fi
}

# Disaster recovery drill
disaster_recovery_drill() {
    log_message "=== Starting Disaster Recovery Drill ==="

    # Find latest full backup
    LATEST_BACKUP=$(ls -t /backup/full/*/system.tar.gz 2>/dev/null | head -1)

    if [ -z "$LATEST_BACKUP" ]; then
        log_message "ERROR: No backup found for testing"
        return 1
    fi

    log_message "Using backup: $LATEST_BACKUP"
    mkdir -p "$TEST_DIR"

    # Test scenarios
    TESTS_PASSED=0
    TESTS_FAILED=0

    # Test 1: File restoration
    if test_file_restore "$LATEST_BACKUP"; then
        ((TESTS_PASSED++))
    else
        ((TESTS_FAILED++))
    fi

    # Test 2: Database restoration
    for db_backup in /backup/full/*/databases/*.sql.gz; do
        if [ -f "$db_backup" ]; then
            db_type=$(basename "$db_backup" | cut -d_ -f1)
            if test_database_restore "$db_backup" "$db_type"; then
                ((TESTS_PASSED++))
            else
                ((TESTS_FAILED++))
            fi
        fi
    done

    # Test 3: Application restoration
    for app_backup in /backup/full/*/applications/*.tar.gz; do
        if [ -f "$app_backup" ]; then
            if test_application_restore "$app_backup"; then
                ((TESTS_PASSED++))
            else
                ((TESTS_FAILED++))
            fi
        fi
    done

    # Test 4: Restoration speed
    test_restore_speed "$LATEST_BACKUP"

    # Cleanup
    rm -rf "$TEST_DIR"

    # Report
    log_message "=== Disaster Recovery Drill Complete ==="
    log_message "Tests Passed: $TESTS_PASSED"
    log_message "Tests Failed: $TESTS_FAILED"

    if [ "$TESTS_FAILED" -gt 0 ]; then
        echo "DR Drill Failed: $TESTS_FAILED tests failed" | \
            mail -s "DR Drill Alert" ops@example.com
        return 1
    fi

    return 0
}

# Main execution
case "$1" in
    file)
        test_file_restore "$2"
        ;;
    database)
        test_database_restore "$2" "$3"
        ;;
    application)
        test_application_restore "$2"
        ;;
    speed)
        test_restore_speed "$2"
        ;;
    drill)
        disaster_recovery_drill
        ;;
    *)
        echo "Usage: $0 {file|database|application|speed|drill} [backup_file]"
        exit 1
        ;;
esac
```

### System Maintenance Tasks

#### Automated Maintenance Framework

```bash
# Comprehensive maintenance automation
sudo nano /usr/local/bin/system-maintenance.sh
```

```bash
#!/bin/bash
# Production system maintenance automation

MAINTENANCE_LOG="/var/log/maintenance.log"
MAINTENANCE_REPORT="/var/log/maintenance-report-$(date +%Y%m%d).html"

# Maintenance tasks registry
declare -A TASKS
TASKS[security_updates]="apply_security_updates"
TASKS[package_cleanup]="cleanup_packages"
TASKS[log_rotation]="rotate_logs"
TASKS[temp_cleanup]="cleanup_temp_files"
TASKS[database_optimization]="optimize_databases"
TASKS[disk_maintenance]="maintain_disks"
TASKS[service_restart]="restart_services"
TASKS[backup_verification]="verify_backups"
TASKS[monitoring_check]="check_monitoring"
TASKS[certificate_renewal]="renew_certificates"

# Task execution tracking
declare -A TASK_STATUS
declare -A TASK_DURATION

log_message() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$MAINTENANCE_LOG"
}

# Security updates
apply_security_updates() {
    log_message "Applying security updates"

    # Update package lists
    apt-get update

    # Apply security updates only
    apt-get upgrade -y --with-new-pkgs \
        $(apt-get upgrade -s | grep -i security | awk '{print $2}')

    # Check if reboot required
    if [ -f /var/run/reboot-required ]; then
        log_message "WARNING: System reboot required"
        return 2
    fi

    return 0
}

# Package cleanup
cleanup_packages() {
    log_message "Cleaning up packages"

    # Remove orphaned packages
    apt-get autoremove -y

    # Clean package cache
    apt-get autoclean -y

    # Remove old kernels (keep last 2)
    dpkg -l 'linux-image-[0-9]*' | grep '^ii' | awk '{print $2}' | \
        sort -V | head -n -2 | xargs -r apt-get purge -y

    # Clean snap cache
    if command -v snap &> /dev/null; then
        snap list --all | awk '/disabled/{print $1, $3}' | \
            while read name rev; do
                snap remove "$name" --revision="$rev"
            done
    fi

    return 0
}

# Log rotation and cleanup
rotate_logs() {
    log_message "Rotating and cleaning logs"

    # Force log rotation
    logrotate -f /etc/logrotate.conf

    # Clean old logs
    find /var/log -type f -name "*.log.*" -mtime +30 -delete
    find /var/log -type f -name "*.gz" -mtime +30 -delete

    # Truncate large logs
    find /var/log -type f -name "*.log" -size +100M | while read log; do
        echo "$(tail -n 10000 $log)" > "$log"
        log_message "Truncated large log: $log"
    done

    # Clean journal logs
    journalctl --vacuum-time=30d
    journalctl --vacuum-size=500M

    return 0
}

# Temporary files cleanup
cleanup_temp_files() {
    log_message "Cleaning temporary files"

    # Clean system temp
    find /tmp -type f -atime +7 -delete 2>/dev/null
    find /var/tmp -type f -atime +7 -delete 2>/dev/null

    # Clean user cache
    find /home -type d -name ".cache" | while read cache_dir; do
        find "$cache_dir" -type f -atime +30 -delete 2>/dev/null
    done

    # Clean package manager cache
    rm -rf /var/cache/apt/archives/*.deb
    rm -rf /var/cache/yum/* 2>/dev/null

    # Clean thumbnail cache
    find /home -type d -name ".thumbnails" -exec rm -rf {} \; 2>/dev/null

    return 0
}

# Database optimization
optimize_databases() {
    log_message "Optimizing databases"

    # MySQL/MariaDB
    if systemctl is-active --quiet mysql; then
        log_message "Optimizing MySQL databases"
        mysqlcheck --all-databases --optimize --silent
        mysql -e "PURGE BINARY LOGS BEFORE DATE_SUB(NOW(), INTERVAL 7 DAY);"
    fi

    # PostgreSQL
    if systemctl is-active --quiet postgresql; then
        log_message "Optimizing PostgreSQL databases"
        sudo -u postgres vacuumdb --all --analyze --quiet
        sudo -u postgres reindexdb --all --quiet
    fi

    # MongoDB
    if systemctl is-active --quiet mongod; then
        log_message "Optimizing MongoDB"
        mongo --eval "db.adminCommand({compact:'collection'})" --quiet
    fi

    return 0
}

# Disk maintenance
maintain_disks() {
    log_message "Performing disk maintenance"

    # Check and repair filesystems (if possible)
    for partition in $(mount | grep "^/dev" | awk '{print $1}'); do
        fs_type=$(mount | grep "^$partition" | awk '{print $5}')

        case "$fs_type" in
            ext4)
                # Run filesystem check (online)
                e2fsck -n "$partition" 2>&1 | grep -q "clean" || \
                    log_message "WARNING: $partition needs checking"
                ;;
            xfs)
                # XFS online scrub
                xfs_scrub "$partition" 2>/dev/null || \
                    log_message "WARNING: $partition scrub failed"
                ;;
        esac
    done

    # TRIM for SSDs
    if command -v fstrim &> /dev/null; then
        fstrim -av 2>&1 | tee -a "$MAINTENANCE_LOG"
    fi

    # Update locate database
    updatedb &

    return 0
}

# Service restart (for memory leaks)
restart_services() {
    log_message "Restarting services for maintenance"

    # Services that benefit from periodic restart
    RESTART_SERVICES="nginx apache2 php7.4-fpm php8.0-fpm"

    for service in $RESTART_SERVICES; do
        if systemctl is-active --quiet "$service"; then
            log_message "Restarting $service"
            systemctl restart "$service"
            sleep 2

            # Verify service is running
            if ! systemctl is-active --quiet "$service"; then
                log_message "ERROR: $service failed to restart"
                return 1
            fi
        fi
    done

    return 0
}

# Backup verification
verify_backups() {
    log_message "Verifying recent backups"

    # Find backups from last 24 hours
    find /backup -type f -name "*.tar.gz" -mtime -1 | while read backup; do
        if tar -tzf "$backup" > /dev/null 2>&1; then
            log_message "Backup verified: $backup"
        else
            log_message "ERROR: Backup corrupted: $backup"
            return 1
        fi
    done

    return 0
}

# Monitoring system check
check_monitoring() {
    log_message "Checking monitoring systems"

    # Check if monitoring agents are running
    MONITORING_SERVICES="node_exporter prometheus-agent datadog-agent"

    for service in $MONITORING_SERVICES; do
        if systemctl is-enabled "$service" 2>/dev/null; then
            if ! systemctl is-active --quiet "$service"; then
                log_message "WARNING: $service is not running"
                systemctl start "$service"
            fi
        fi
    done

    # Check monitoring endpoints
    if command -v curl &> /dev/null; then
        # Prometheus metrics
        curl -s http://localhost:9100/metrics > /dev/null 2>&1 || \
            log_message "WARNING: Prometheus metrics endpoint not responding"
    fi

    return 0
}

# Certificate renewal
renew_certificates() {
    log_message "Checking SSL certificates"

    # Let's Encrypt renewal
    if command -v certbot &> /dev/null; then
        certbot renew --quiet --non-interactive

        # Reload services using certificates
        systemctl reload nginx 2>/dev/null
        systemctl reload apache2 2>/dev/null
    fi

    # Check certificate expiry
    find /etc/letsencrypt/live -name "cert.pem" 2>/dev/null | while read cert; do
        expiry=$(openssl x509 -enddate -noout -in "$cert" | cut -d= -f2)
        expiry_epoch=$(date -d "$expiry" +%s)
        current_epoch=$(date +%s)
        days_left=$(( (expiry_epoch - current_epoch) / 86400 ))

        if [ "$days_left" -lt 30 ]; then
            log_message "WARNING: Certificate expires in $days_left days: $cert"
        fi
    done

    return 0
}

# Generate maintenance report
generate_report() {
    cat > "$MAINTENANCE_REPORT" << 'EOF'
<!DOCTYPE html>
<html>
<head>
    <title>Maintenance Report</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 20px; }
        h1 { color: #333; }
        table { border-collapse: collapse; width: 100%; }
        th, td { border: 1px solid #ddd; padding: 8px; text-align: left; }
        th { background-color: #4CAF50; color: white; }
        .success { color: green; }
        .warning { color: orange; }
        .error { color: red; }
    </style>
</head>
<body>
    <h1>System Maintenance Report</h1>
    <p>Date: $(date)</p>
    <p>Hostname: $(hostname -f)</p>

    <h2>Task Execution Summary</h2>
    <table>
        <tr>
            <th>Task</th>
            <th>Status</th>
            <th>Duration</th>
        </tr>
EOF

    for task in "${!TASKS[@]}"; do
        status_class="success"
        status_text="Completed"

        if [ "${TASK_STATUS[$task]}" -ne 0 ]; then
            if [ "${TASK_STATUS[$task]}" -eq 2 ]; then
                status_class="warning"
                status_text="Warning"
            else
                status_class="error"
                status_text="Failed"
            fi
        fi

        echo "<tr>" >> "$MAINTENANCE_REPORT"
        echo "<td>$task</td>" >> "$MAINTENANCE_REPORT"
        echo "<td class='$status_class'>$status_text</td>" >> "$MAINTENANCE_REPORT"
        echo "<td>${TASK_DURATION[$task]}s</td>" >> "$MAINTENANCE_REPORT"
        echo "</tr>" >> "$MAINTENANCE_REPORT"
    done

    cat >> "$MAINTENANCE_REPORT" << 'EOF'
    </table>

    <h2>System Status</h2>
    <pre>
$(df -h)
    </pre>

    <h2>Service Status</h2>
    <pre>
$(systemctl list-units --failed)
    </pre>

</body>
</html>
EOF

    log_message "Maintenance report generated: $MAINTENANCE_REPORT"
}

# Main maintenance execution
main() {
    log_message "=== Starting System Maintenance ==="

    TOTAL_START=$(date +%s)

    for task in "${!TASKS[@]}"; do
        START=$(date +%s)
        log_message "Executing: $task"

        # Execute task function
        ${TASKS[$task]}
        TASK_STATUS[$task]=$?

        END=$(date +%s)
        TASK_DURATION[$task]=$((END - START))

        if [ "${TASK_STATUS[$task]}" -eq 0 ]; then
            log_message "Task $task completed successfully (${TASK_DURATION[$task]}s)"
        else
            log_message "Task $task failed with status ${TASK_STATUS[$task]}"
        fi
    done

    TOTAL_END=$(date +%s)
    TOTAL_DURATION=$((TOTAL_END - TOTAL_START))

    log_message "=== Maintenance Complete (${TOTAL_DURATION}s) ==="

    # Generate report
    generate_report

    # Send report via email
    if command -v mail &> /dev/null; then
        mail -s "Maintenance Report - $(hostname)" -a "$MAINTENANCE_REPORT" \
            ops@example.com < "$MAINTENANCE_LOG"
    fi
}

# Schedule check
if [ "$1" == "--schedule" ]; then
    # Add to crontab
    (crontab -l 2>/dev/null; echo "0 2 * * 0 /usr/local/bin/system-maintenance.sh") | crontab -
    echo "Maintenance scheduled for weekly execution"
    exit 0
fi

# Run maintenance
main
```

### Documentation Requirements

#### Documentation Management System

```bash
# Documentation management system
sudo nano /usr/local/bin/doc-manager.sh
```

```bash
#!/bin/bash
# Production documentation management

DOC_ROOT="/opt/documentation"
DOC_CATEGORIES="infrastructure applications procedures runbooks"

# Initialize documentation structure
init_documentation() {
    for category in $DOC_CATEGORIES; do
        mkdir -p "$DOC_ROOT/$category"
    done

    # Create index
    cat > "$DOC_ROOT/index.md" << 'EOF'
# System Documentation Index

## Categories

### Infrastructure
- [Network Topology](infrastructure/network.md)
- [Server Inventory](infrastructure/servers.md)
- [Storage Architecture](infrastructure/storage.md)
- [Security Configuration](infrastructure/security.md)

### Applications
- [Application Inventory](applications/inventory.md)
- [Deployment Procedures](applications/deployment.md)
- [Configuration Guide](applications/configuration.md)
- [API Documentation](applications/api.md)

### Procedures
- [Backup Procedures](procedures/backup.md)
- [Recovery Procedures](procedures/recovery.md)
- [Maintenance Procedures](procedures/maintenance.md)
- [Emergency Procedures](procedures/emergency.md)

### Runbooks
- [Incident Response](runbooks/incident-response.md)
- [Troubleshooting Guide](runbooks/troubleshooting.md)
- [Performance Tuning](runbooks/performance.md)
- [Scaling Procedures](runbooks/scaling.md)

## Quick Links
- [On-Call Guide](on-call.md)
- [Contact List](contacts.md)
- [Change Log](changelog.md)

Last Updated: $(date)
EOF
}

# Generate infrastructure documentation
generate_infrastructure_docs() {
    echo "Generating infrastructure documentation..."

    # Network documentation
    cat > "$DOC_ROOT/infrastructure/network.md" << EOF
# Network Documentation

## Network Configuration
$(ip addr show)

## Routing Table
$(ip route show)

## Firewall Rules
$(sudo iptables -L -n -v)

## Open Ports
$(ss -tulpn)

Generated: $(date)
EOF

    # Server inventory
    cat > "$DOC_ROOT/infrastructure/servers.md" << EOF
# Server Inventory

## System Information
- Hostname: $(hostname -f)
- OS: $(lsb_release -ds)
- Kernel: $(uname -r)
- CPU: $(lscpu | grep "Model name" | cut -d: -f2)
- Memory: $(free -h | grep Mem | awk '{print $2}')
- Disk: $(df -h / | tail -1 | awk '{print $2}')

## Installed Services
$(systemctl list-units --type=service --state=running)

Generated: $(date)
EOF
}

# Generate application documentation
generate_application_docs() {
    echo "Generating application documentation..."

    cat > "$DOC_ROOT/applications/inventory.md" << EOF
# Application Inventory

## Web Applications
EOF

    for app in /var/www/*; do
        if [ -d "$app" ]; then
            echo "### $(basename $app)" >> "$DOC_ROOT/applications/inventory.md"
            echo "- Path: $app" >> "$DOC_ROOT/applications/inventory.md"
            echo "- Size: $(du -sh $app | cut -f1)" >> "$DOC_ROOT/applications/inventory.md"
            echo "" >> "$DOC_ROOT/applications/inventory.md"
        fi
    done

    echo "Generated: $(date)" >> "$DOC_ROOT/applications/inventory.md"
}

# Generate procedure documentation
generate_procedure_docs() {
    echo "Generating procedure documentation..."

    # Backup procedures
    cat > "$DOC_ROOT/procedures/backup.md" << 'EOF'
# Backup Procedures

## Daily Backup
1. Automated via cron at 02:00
2. Incremental backup to /backup/daily
3. Retention: 30 days

## Weekly Backup
1. Full backup every Sunday at 03:00
2. Stored in /backup/weekly
3. Retention: 12 weeks

## Monthly Backup
1. Full backup on 1st of each month
2. Stored in /backup/monthly
3. Retention: 12 months

## Backup Verification
```bash
/usr/local/bin/test-restore.sh drill
```

## Manual Backup
```bash
/usr/local/bin/backup-strategy.sh full
```
EOF
}

# Generate runbooks
generate_runbooks() {
    echo "Generating runbooks..."

    cat > "$DOC_ROOT/runbooks/incident-response.md" << 'EOF'
# Incident Response Runbook

## Severity Levels
- **P1**: Complete outage, no workaround
- **P2**: Major functionality impacted
- **P3**: Minor functionality impacted
- **P4**: Cosmetic or minor issue

## Response Process

### 1. Detection
- Alert received via monitoring
- User report
- System notification

### 2. Triage
- Assess impact
- Determine severity
- Notify stakeholders

### 3. Investigation
```bash
# Initial diagnosis
/usr/local/bin/system-diagnose.sh

# Check specific service
/usr/local/bin/debug-service.sh [service-name]

# Check logs
journalctl -xe -n 100
```

### 4. Resolution
- Implement fix
- Test solution
- Monitor for recurrence

### 5. Post-Incident
- Document root cause
- Update runbooks
- Implement preventive measures
EOF
}

# Update documentation
update_docs() {
    init_documentation
    generate_infrastructure_docs
    generate_application_docs
    generate_procedure_docs
    generate_runbooks

    # Version control
    cd "$DOC_ROOT"
    git add -A
    git commit -m "Documentation update - $(date +%Y%m%d)" 2>/dev/null

    echo "Documentation updated at $DOC_ROOT"
}

# Main execution
case "$1" in
    init)
        init_documentation
        ;;
    update)
        update_docs
        ;;
    *)
        echo "Usage: $0 {init|update}"
        exit 1
        ;;
esac
```

### Update and Patch Management

#### Patch Management System

```bash
# Automated patch management
sudo nano /usr/local/bin/patch-management.sh
```

```bash
#!/bin/bash
# Production patch management system

PATCH_LOG="/var/log/patch-management.log"
PATCH_REPORT="/var/log/patch-report.json"
MAINTENANCE_WINDOW_START="02:00"
MAINTENANCE_WINDOW_END="04:00"

log_message() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$PATCH_LOG"
}

# Check if in maintenance window
check_maintenance_window() {
    current_hour=$(date +%H)
    start_hour=$(echo "$MAINTENANCE_WINDOW_START" | cut -d: -f1)
    end_hour=$(echo "$MAINTENANCE_WINDOW_END" | cut -d: -f1)

    if [ "$current_hour" -ge "$start_hour" ] && [ "$current_hour" -lt "$end_hour" ]; then
        return 0
    fi

    return 1
}

# Analyze available updates
analyze_updates() {
    log_message "Analyzing available updates"

    apt-get update -qq

    # Categorize updates
    SECURITY_UPDATES=$(apt-get upgrade -s | grep -i security | wc -l)
    CRITICAL_UPDATES=$(apt-get upgrade -s | grep -iE "critical|urgent" | wc -l)
    REGULAR_UPDATES=$(apt-get upgrade -s | grep "^Inst" | wc -l)

    cat > "$PATCH_REPORT" << EOF
{
    "timestamp": "$(date -Iseconds)",
    "security_updates": $SECURITY_UPDATES,
    "critical_updates": $CRITICAL_UPDATES,
    "regular_updates": $REGULAR_UPDATES,
    "kernel_updates": $(apt-get upgrade -s | grep -c linux-image),
    "requires_reboot": $([ -f /var/run/reboot-required ] && echo "true" || echo "false")
}
EOF

    log_message "Found $SECURITY_UPDATES security, $CRITICAL_UPDATES critical, $REGULAR_UPDATES total updates"
}

# Apply patches based on policy
apply_patches() {
    local patch_level=$1

    case "$patch_level" in
        security)
            log_message "Applying security patches only"
            apt-get upgrade -y $(apt-get upgrade -s | grep -i security | awk '{print $2}')
            ;;
        critical)
            log_message "Applying critical patches"
            apt-get upgrade -y $(apt-get upgrade -s | grep -iE "security|critical" | awk '{print $2}')
            ;;
        all)
            log_message "Applying all patches"
            apt-get upgrade -y
            ;;
    esac

    # Check if reboot required
    if [ -f /var/run/reboot-required ]; then
        log_message "System reboot required"

        if check_maintenance_window; then
            log_message "Scheduling reboot in 5 minutes"
            shutdown -r +5 "System reboot for patches"
        else
            log_message "Reboot required but outside maintenance window"
        fi
    fi
}

# Pre-patch validation
pre_patch_validation() {
    log_message "Running pre-patch validation"

    # Check disk space
    available_space=$(df / | tail -1 | awk '{print $4}')
    if [ "$available_space" -lt 1048576 ]; then
        log_message "ERROR: Insufficient disk space"
        return 1
    fi

    # Backup critical configs
    tar -czf /backup/pre-patch-configs-$(date +%Y%m%d).tar.gz /etc 2>/dev/null

    # Snapshot if possible
    if command -v lvcreate &> /dev/null; then
        lvcreate -L 5G -s -n pre-patch-snapshot /dev/vg0/root 2>/dev/null || true
    fi

    return 0
}

# Post-patch validation
post_patch_validation() {
    log_message "Running post-patch validation"

    # Check critical services
    CRITICAL_SERVICES="ssh nginx mysql postgresql"

    for service in $CRITICAL_SERVICES; do
        if systemctl is-enabled "$service" 2>/dev/null; then
            if ! systemctl is-active --quiet "$service"; then
                log_message "ERROR: Service $service not running after patch"
                systemctl start "$service"
            fi
        fi
    done

    # Test network connectivity
    if ! ping -c 1 8.8.8.8 &> /dev/null; then
        log_message "ERROR: Network connectivity issue after patch"
    fi

    # Check for failed services
    failed_services=$(systemctl list-units --failed --no-legend | wc -l)
    if [ "$failed_services" -gt 0 ]; then
        log_message "WARNING: $failed_services failed services after patch"
    fi
}

# Main patch management
main() {
    log_message "=== Starting Patch Management ==="

    # Analyze updates
    analyze_updates

    # Determine patch policy
    if [ "$SECURITY_UPDATES" -gt 0 ]; then
        # Always apply security updates
        if pre_patch_validation; then
            apply_patches security
            post_patch_validation
        fi
    elif [ "$CRITICAL_UPDATES" -gt 0 ] && check_maintenance_window; then
        # Apply critical updates during maintenance window
        if pre_patch_validation; then
            apply_patches critical
            post_patch_validation
        fi
    elif check_maintenance_window && [ "$(date +%d)" -eq 1 ]; then
        # Monthly full patching on 1st of month
        if pre_patch_validation; then
            apply_patches all
            post_patch_validation
        fi
    fi

    log_message "=== Patch Management Complete ==="

    # Send report
    if [ -n "$SECURITY_UPDATES" ] && [ "$SECURITY_UPDATES" -gt 0 ]; then
        mail -s "Security Updates Applied - $(hostname)" ops@example.com < "$PATCH_LOG"
    fi
}

main "$@"
```

### Monitoring Setup

#### Comprehensive Monitoring Configuration

```bash
# Monitoring setup script
sudo nano /usr/local/bin/setup-monitoring.sh
```

```bash
#!/bin/bash
# Production monitoring setup

setup_prometheus_node_exporter() {
    echo "Setting up Prometheus Node Exporter..."

    # Download and install
    wget https://github.com/prometheus/node_exporter/releases/latest/download/node_exporter-*linux-amd64.tar.gz
    tar xvf node_exporter-*.tar.gz
    sudo cp node_exporter-*/node_exporter /usr/local/bin/
    rm -rf node_exporter-*

    # Create service
    cat > /etc/systemd/system/node_exporter.service << 'EOF'
[Unit]
Description=Node Exporter
After=network.target

[Service]
User=node_exporter
Group=node_exporter
Type=simple
ExecStart=/usr/local/bin/node_exporter \
    --collector.filesystem.mount-points-exclude="^/(dev|proc|sys|run)($|/)" \
    --collector.netdev.device-exclude="^(veth|docker|br-)" \
    --collector.diskstats.ignored-devices="^(ram|loop|fd)"

[Install]
WantedBy=multi-user.target
EOF

    # Create user
    useradd --no-create-home --shell /bin/false node_exporter

    # Start service
    systemctl daemon-reload
    systemctl enable --now node_exporter
}

setup_custom_metrics() {
    echo "Setting up custom metrics..."

    cat > /usr/local/bin/custom-metrics.sh << 'EOF'
#!/bin/bash
# Custom metrics collector

METRICS_FILE="/var/lib/node_exporter/custom.prom"
mkdir -p $(dirname "$METRICS_FILE")

while true; do
    # Application metrics
    APP_REQUESTS=$(grep "GET\|POST" /var/log/nginx/access.log | wc -l)
    APP_ERRORS=$(grep "5[0-9][0-9]" /var/log/nginx/access.log | wc -l)

    # Database metrics
    DB_CONNECTIONS=$(mysql -e "SHOW STATUS LIKE 'Threads_connected';" | tail -1 | awk '{print $2}')
    DB_QUERIES=$(mysql -e "SHOW STATUS LIKE 'Questions';" | tail -1 | awk '{print $2}')

    # Custom business metrics
    ACTIVE_USERS=$(who | wc -l)
    JOBS_QUEUED=$(redis-cli llen job_queue 2>/dev/null || echo 0)

    # Write metrics
    cat > "$METRICS_FILE" << METRICS
# HELP app_requests_total Total application requests
# TYPE app_requests_total counter
app_requests_total $APP_REQUESTS

# HELP app_errors_total Total application errors
# TYPE app_errors_total counter
app_errors_total $APP_ERRORS

# HELP db_connections Current database connections
# TYPE db_connections gauge
db_connections $DB_CONNECTIONS

# HELP db_queries_total Total database queries
# TYPE db_queries_total counter
db_queries_total $DB_QUERIES

# HELP active_users Number of active users
# TYPE active_users gauge
active_users $ACTIVE_USERS

# HELP jobs_queued Number of queued jobs
# TYPE jobs_queued gauge
jobs_queued $JOBS_QUEUED
METRICS

    sleep 60
done
EOF

    chmod +x /usr/local/bin/custom-metrics.sh

    # Create service
    cat > /etc/systemd/system/custom-metrics.service << 'EOF'
[Unit]
Description=Custom Metrics Collector
After=network.target

[Service]
Type=simple
ExecStart=/usr/local/bin/custom-metrics.sh
Restart=always

[Install]
WantedBy=multi-user.target
EOF

    systemctl daemon-reload
    systemctl enable --now custom-metrics
}

setup_alerts() {
    echo "Setting up alerting..."

    cat > /usr/local/bin/alert-manager.sh << 'EOF'
#!/bin/bash
# Alert management system

check_and_alert() {
    local metric=$1
    local threshold=$2
    local comparison=$3
    local message=$4

    value=$(cat /proc/loadavg | awk '{print $1}')

    case "$comparison" in
        gt)
            if (( $(echo "$value > $threshold" | bc -l) )); then
                send_alert "$message: $value"
            fi
            ;;
        lt)
            if (( $(echo "$value < $threshold" | bc -l) )); then
                send_alert "$message: $value"
            fi
            ;;
    esac
}

send_alert() {
    local message=$1

    # Email alert
    echo "$message" | mail -s "Alert: $(hostname)" ops@example.com

    # Slack webhook
    curl -X POST -H 'Content-type: application/json' \
        --data "{\"text\":\"$message\"}" \
        https://hooks.slack.com/services/YOUR/WEBHOOK/URL

    # Log alert
    logger -t alert "$message"
}

# Main monitoring loop
while true; do
    # CPU load
    load=$(cat /proc/loadavg | awk '{print $1}')
    cores=$(nproc)
    if (( $(echo "$load > $cores * 2" | bc -l) )); then
        send_alert "High CPU load: $load (cores: $cores)"
    fi

    # Memory usage
    mem_used=$(free | grep Mem | awk '{print int($3/$2 * 100)}')
    if [ "$mem_used" -gt 90 ]; then
        send_alert "High memory usage: ${mem_used}%"
    fi

    # Disk usage
    df -h | grep -E "^/dev" | while read line; do
        usage=$(echo "$line" | awk '{print $5}' | sed 's/%//')
        mount=$(echo "$line" | awk '{print $6}')
        if [ "$usage" -gt 85 ]; then
            send_alert "High disk usage on $mount: ${usage}%"
        fi
    done

    sleep 300
done
EOF

    chmod +x /usr/local/bin/alert-manager.sh
}

# Main execution
setup_prometheus_node_exporter
setup_custom_metrics
setup_alerts

echo "Monitoring setup complete"
```

### Incident Response Procedures

#### Incident Response Framework

```bash
# Incident response automation
sudo nano /usr/local/bin/incident-response.sh
```

```bash
#!/bin/bash
# Automated incident response system

INCIDENT_ID="INC-$(date +%Y%m%d-%H%M%S)"
INCIDENT_DIR="/var/log/incidents/$INCIDENT_ID"
RUNBOOK_DIR="/opt/runbooks"

mkdir -p "$INCIDENT_DIR"

# Incident classification
classify_incident() {
    local symptoms=$1

    if echo "$symptoms" | grep -qi "outage\|down\|unavailable"; then
        echo "P1"
    elif echo "$symptoms" | grep -qi "slow\|degraded\|timeout"; then
        echo "P2"
    elif echo "$symptoms" | grep -qi "error\|warning\|failed"; then
        echo "P3"
    else
        echo "P4"
    fi
}

# Initial response
initial_response() {
    local severity=$1

    echo "=== Incident Response Started ===" | tee "$INCIDENT_DIR/timeline.log"
    echo "Incident ID: $INCIDENT_ID" | tee -a "$INCIDENT_DIR/timeline.log"
    echo "Severity: $severity" | tee -a "$INCIDENT_DIR/timeline.log"
    echo "Start Time: $(date)" | tee -a "$INCIDENT_DIR/timeline.log"

    # Capture system state
    /usr/local/bin/system-diagnose.sh > "$INCIDENT_DIR/initial-state.log" 2>&1

    # Notify on-call
    case "$severity" in
        P1)
            # Page immediately
            send_page "P1 Incident: $INCIDENT_ID"
            ;;
        P2)
            # Notify via Slack
            send_slack "P2 Incident: $INCIDENT_ID"
            ;;
        *)
            # Email notification
            send_email "Incident: $INCIDENT_ID (Severity: $severity)"
            ;;
    esac
}

# Automated remediation
auto_remediate() {
    local issue_type=$1

    case "$issue_type" in
        service_down)
            service_name=$2
            echo "Attempting to restart $service_name" | tee -a "$INCIDENT_DIR/remediation.log"
            systemctl restart "$service_name"
            sleep 5
            if systemctl is-active --quiet "$service_name"; then
                echo "Service $service_name recovered" | tee -a "$INCIDENT_DIR/remediation.log"
                return 0
            fi
            ;;

        high_memory)
            echo "Clearing caches and restarting high-memory services" | tee -a "$INCIDENT_DIR/remediation.log"
            sync && echo 3 > /proc/sys/vm/drop_caches
            systemctl restart nginx mysql
            ;;

        disk_full)
            echo "Cleaning up disk space" | tee -a "$INCIDENT_DIR/remediation.log"
            /usr/local/bin/cleanup-disk.sh
            ;;

        high_load)
            echo "Identifying and managing high-load processes" | tee -a "$INCIDENT_DIR/remediation.log"
            ps aux --sort=-%cpu | head -10 | tee -a "$INCIDENT_DIR/high-cpu.log"
            ;;
    esac
}

# Incident documentation
document_incident() {
    cat > "$INCIDENT_DIR/incident-report.md" << EOF
# Incident Report: $INCIDENT_ID

## Summary
- **ID**: $INCIDENT_ID
- **Date**: $(date)
- **Severity**: $1
- **Status**: $2
- **Duration**: $3 minutes

## Timeline
$(cat $INCIDENT_DIR/timeline.log)

## Impact
- Services Affected: $4
- Users Impacted: $5
- Data Loss: None

## Root Cause
$6

## Resolution
$7

## Action Items
- [ ] Update monitoring
- [ ] Update runbooks
- [ ] Post-mortem meeting
- [ ] Preventive measures

## Lessons Learned
- What went well: Quick detection and response
- What could be improved: Better alerting coverage

Generated: $(date)
EOF
}

# Communication
send_page() {
    # PagerDuty integration
    curl -X POST https://events.pagerduty.com/v2/enqueue \
        -H "Content-Type: application/json" \
        -d "{
            \"routing_key\": \"YOUR_ROUTING_KEY\",
            \"event_action\": \"trigger\",
            \"payload\": {
                \"summary\": \"$1\",
                \"severity\": \"critical\",
                \"source\": \"$(hostname)\"
            }
        }"
}

send_slack() {
    curl -X POST -H 'Content-type: application/json' \
        --data "{\"text\":\"$1\"}" \
        https://hooks.slack.com/services/YOUR/WEBHOOK/URL
}

send_email() {
    echo "$1" | mail -s "Incident Alert" ops@example.com
}

# Main incident handler
main() {
    echo "Starting incident response..."

    # Get incident details
    read -p "Describe the issue: " description
    severity=$(classify_incident "$description")

    # Initial response
    initial_response "$severity"

    # Attempt auto-remediation
    echo "Attempting automated remediation..."
    # Logic to determine issue type and remediate

    # Document incident
    read -p "Root cause: " root_cause
    read -p "Resolution: " resolution
    document_incident "$severity" "Resolved" "30" "Web Application" "100" "$root_cause" "$resolution"

    echo "Incident response complete. Documentation saved to $INCIDENT_DIR"
}

main "$@"
```

---

## Chapter 25: Production Best Practices

### Documentation Standards

#### Documentation Framework

```bash
# Production documentation standards
sudo nano /usr/local/bin/doc-standards.sh
```

```bash
#!/bin/bash
# Documentation standards enforcement

DOC_ROOT="/opt/documentation"
TEMPLATES_DIR="$DOC_ROOT/templates"

# Create documentation templates
create_templates() {
    mkdir -p "$TEMPLATES_DIR"

    # Server documentation template
    cat > "$TEMPLATES_DIR/server-template.md" << 'EOF'
# Server Documentation: [SERVER_NAME]

## Overview
- **Purpose**: [Primary function of this server]
- **Environment**: [Production/Staging/Development]
- **Criticality**: [High/Medium/Low]
- **Owner**: [Team/Person responsible]

## Technical Specifications
- **Hardware/Instance Type**: [Details]
- **Operating System**: [OS and version]
- **CPU**: [Cores and type]
- **Memory**: [RAM amount]
- **Storage**: [Disk configuration]

## Network Configuration
- **IP Address**: [Private IP]
- **Public IP**: [If applicable]
- **DNS Names**: [FQDNs]
- **Firewall Rules**: [Key rules]

## Installed Software
| Software | Version | Purpose | Config Location |
|----------|---------|---------|-----------------|
| [Name] | [Version] | [Purpose] | [Path] |

## Services
| Service | Port | Status | Start Command |
|---------|------|--------|---------------|
| [Name] | [Port] | [Active/Inactive] | [Command] |

## Backup Information
- **Backup Schedule**: [Frequency]
- **Backup Location**: [Path/Remote]
- **Retention Policy**: [Days/Weeks]
- **Recovery Time Objective**: [RTO]
- **Recovery Point Objective**: [RPO]

## Monitoring
- **Monitoring System**: [Tool name]
- **Key Metrics**: [List of monitored metrics]
- **Alert Thresholds**: [Critical thresholds]
- **Dashboard URL**: [Link]

## Access Information
- **SSH Access**: [How to access]
- **Sudo Users**: [List of users]
- **Service Accounts**: [List of service accounts]

## Dependencies
- **Depends On**: [List of dependencies]
- **Dependent Systems**: [Systems that depend on this]

## Maintenance
- **Maintenance Window**: [Day and time]
- **Patch Schedule**: [Frequency]
- **Last Updated**: [Date]

## Emergency Procedures
- **Emergency Contact**: [Contact info]
- **Escalation Path**: [Escalation procedure]
- **Disaster Recovery**: [DR procedure]

## Change History
| Date | Change | By | Ticket |
|------|--------|----|----|
| [Date] | [Description] | [Person] | [Ticket#] |
EOF

    # Application documentation template
    cat > "$TEMPLATES_DIR/application-template.md" << 'EOF'
# Application Documentation: [APP_NAME]

## Overview
- **Name**: [Application name]
- **Version**: [Current version]
- **Type**: [Web/API/Service/Batch]
- **Language/Framework**: [Technology stack]
- **Repository**: [Git URL]

## Architecture
```
[ASCII or diagram of architecture]
```

## Deployment
### Production
- **Server(s)**: [List of servers]
- **URL**: [Production URL]
- **Deployment Method**: [Manual/CI/CD]
- **Deployment Command**: `[command]`

### Configuration
- **Config Location**: [Path to config]
- **Environment Variables**: [List key variables]
- **Secrets Management**: [How secrets are handled]

## Database
- **Type**: [MySQL/PostgreSQL/MongoDB/etc]
- **Host**: [Database host]
- **Name**: [Database name]
- **Schema Version**: [Version]
- **Migration Tool**: [Tool used]

## API Documentation
- **Base URL**: [API base URL]
- **Authentication**: [Auth method]
- **Documentation**: [Link to API docs]

### Endpoints
| Method | Endpoint | Description | Auth Required |
|--------|----------|-------------|---------------|
| [GET/POST] | [/path] | [Description] | [Yes/No] |

## Dependencies
### External Services
- [Service name]: [Purpose]

### Libraries
- [Library]: [Version] - [Purpose]

## Monitoring and Logging
- **Log Location**: [Path to logs]
- **Log Level**: [Current level]
- **Monitoring URL**: [Dashboard URL]
- **Key Metrics**: [Important metrics]
- **Alert Configuration**: [How alerts are configured]

## Troubleshooting
### Common Issues
1. **Issue**: [Description]
   - **Symptoms**: [What you see]
   - **Cause**: [Root cause]
   - **Solution**: [How to fix]

## Maintenance Procedures
### Backup
```bash
[Backup commands]
```

### Restore
```bash
[Restore commands]
```

### Update/Upgrade
```bash
[Update procedures]
```

## Security
- **Authentication**: [Method]
- **Authorization**: [Method]
- **Encryption**: [In transit/At rest]
- **Security Scanning**: [Tools and frequency]

## Performance
- **Expected Load**: [Requests/sec]
- **Response Time**: [Target response time]
- **Scaling**: [Horizontal/Vertical]
- **Caching**: [Strategy]

## Contact Information
- **Development Team**: [Team name]
- **Team Lead**: [Name and contact]
- **On-Call**: [How to reach on-call]
EOF

    # Runbook template
    cat > "$TEMPLATES_DIR/runbook-template.md" << 'EOF'
# Runbook: [PROCEDURE_NAME]

## Overview
**Purpose**: [What this runbook accomplishes]
**When to Use**: [Conditions that trigger this runbook]
**Expected Duration**: [Time estimate]
**Risk Level**: [Low/Medium/High]

## Prerequisites
- [ ] [Prerequisite 1]
- [ ] [Prerequisite 2]
- [ ] Access to [system/tool]

## Pre-Checks
```bash
# Commands to verify system state before starting
[command 1]
[command 2]
```

## Procedure

### Step 1: [Step Title]
**Objective**: [What this step accomplishes]

```bash
# Commands for this step
[command]
```

**Expected Output**:
```
[Example of expected output]
```

**If This Fails**:
- [Troubleshooting step 1]
- [Troubleshooting step 2]

### Step 2: [Step Title]
[Repeat format]

## Validation
```bash
# Commands to verify successful completion
[validation command 1]
[validation command 2]
```

## Rollback Procedure
If you need to rollback:

### Step 1: [Rollback step]
```bash
[rollback command]
```

## Post-Procedure
- [ ] Update documentation if procedure changed
- [ ] Notify stakeholders of completion
- [ ] Update ticket/incident

## Troubleshooting
| Error | Cause | Solution |
|-------|-------|----------|
| [Error message] | [Why it happens] | [How to fix] |

## References
- [Related documentation]
- [External resources]

## Change Log
| Date | Version | Changes | Author |
|------|---------|---------|--------|
| [Date] | [1.0] | [Initial version] | [Name] |
EOF

    echo "Documentation templates created in $TEMPLATES_DIR"
}

# Validate documentation
validate_documentation() {
    local doc_file=$1

    echo "Validating $doc_file..."

    # Check for required sections
    required_sections=(
        "Overview"
        "Configuration"
        "Monitoring"
        "Troubleshooting"
        "Change History"
    )

    for section in "${required_sections[@]}"; do
        if ! grep -q "## $section" "$doc_file"; then
            echo "WARNING: Missing section: $section"
        fi
    done

    # Check for outdated information
    last_updated=$(grep "Last Updated:" "$doc_file" | cut -d: -f2)
    if [ -n "$last_updated" ]; then
        days_old=$(( ($(date +%s) - $(date -d "$last_updated" +%s)) / 86400 ))
        if [ "$days_old" -gt 90 ]; then
            echo "WARNING: Documentation is $days_old days old"
        fi
    fi

    echo "Validation complete"
}

# Generate documentation index
generate_index() {
    echo "Generating documentation index..."

    cat > "$DOC_ROOT/INDEX.md" << EOF
# Documentation Index

Generated: $(date)

## Servers
$(find $DOC_ROOT/servers -name "*.md" -exec basename {} \; | sed 's/^/- /')

## Applications
$(find $DOC_ROOT/applications -name "*.md" -exec basename {} \; | sed 's/^/- /')

## Runbooks
$(find $DOC_ROOT/runbooks -name "*.md" -exec basename {} \; | sed 's/^/- /')

## Procedures
$(find $DOC_ROOT/procedures -name "*.md" -exec basename {} \; | sed 's/^/- /')

## Total Documents: $(find $DOC_ROOT -name "*.md" | wc -l)
EOF
}

# Main execution
case "$1" in
    create-templates)
        create_templates
        ;;
    validate)
        validate_documentation "$2"
        ;;
    index)
        generate_index
        ;;
    *)
        echo "Usage: $0 {create-templates|validate <file>|index}"
        exit 1
        ;;
esac
```

### Change Management Process

#### Change Management System

```bash
# Change management implementation
sudo nano /usr/local/bin/change-management.sh
```

```bash
#!/bin/bash
# Production change management system

CHANGE_LOG="/var/log/changes/change.log"
CHANGE_DB="/var/lib/changes/changes.db"
APPROVAL_REQUIRED="true"

# Initialize change database
init_database() {
    mkdir -p $(dirname "$CHANGE_DB")

    sqlite3 "$CHANGE_DB" << 'EOF'
CREATE TABLE IF NOT EXISTS changes (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    change_id TEXT UNIQUE,
    type TEXT,
    risk_level TEXT,
    description TEXT,
    requester TEXT,
    approver TEXT,
    status TEXT,
    scheduled_time TEXT,
    actual_time TEXT,
    rollback_plan TEXT,
    test_plan TEXT,
    impact TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS change_history (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    change_id TEXT,
    action TEXT,
    user TEXT,
    timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    notes TEXT
);
EOF
}

# Create change request
create_change() {
    local change_id="CHG-$(date +%Y%m%d-%H%M%S)"

    echo "=== Change Request Form ==="
    read -p "Change Type [standard/normal/emergency]: " type
    read -p "Risk Level [low/medium/high]: " risk
    read -p "Description: " description
    read -p "Requester: " requester
    read -p "Scheduled Time (YYYY-MM-DD HH:MM): " scheduled
    read -p "Impact: " impact
    read -p "Test Plan: " test_plan
    read -p "Rollback Plan: " rollback_plan

    # Validate risk assessment
    case "$risk" in
        high)
            APPROVAL_REQUIRED="true"
            echo "High risk change requires approval"
            ;;
        medium)
            APPROVAL_REQUIRED="true"
            echo "Medium risk change requires approval"
            ;;
        low)
            if [ "$type" = "standard" ]; then
                APPROVAL_REQUIRED="false"
                echo "Standard low-risk change - auto-approved"
            fi
            ;;
    esac

    # Insert into database
    sqlite3 "$CHANGE_DB" << EOF
INSERT INTO changes (
    change_id, type, risk_level, description, requester,
    status, scheduled_time, impact, test_plan, rollback_plan
) VALUES (
    '$change_id', '$type', '$risk', '$description', '$requester',
    'pending', '$scheduled', '$impact', '$test_plan', '$rollback_plan'
);
EOF

    # Log change request
    echo "[$(date)] Change $change_id created by $requester" >> "$CHANGE_LOG"

    if [ "$APPROVAL_REQUIRED" = "true" ]; then
        request_approval "$change_id"
    else
        approve_change "$change_id" "auto-approved"
    fi

    echo "Change request $change_id created"
}

# Request approval
request_approval() {
    local change_id=$1

    # Send approval request
    sqlite3 "$CHANGE_DB" "SELECT * FROM changes WHERE change_id='$change_id';" | \
        mail -s "Change Approval Required: $change_id" approvers@example.com

    # Update status
    sqlite3 "$CHANGE_DB" "UPDATE changes SET status='awaiting_approval' WHERE change_id='$change_id';"

    echo "Approval request sent for $change_id"
}

# Approve change
approve_change() {
    local change_id=$1
    local approver=$2

    sqlite3 "$CHANGE_DB" << EOF
UPDATE changes SET
    status='approved',
    approver='$approver'
WHERE change_id='$change_id';

INSERT INTO change_history (change_id, action, user, notes)
VALUES ('$change_id', 'approved', '$approver', 'Change approved');
EOF

    echo "Change $change_id approved by $approver"
}

# Implement change
implement_change() {
    local change_id=$1

    # Check if approved
    status=$(sqlite3 "$CHANGE_DB" "SELECT status FROM changes WHERE change_id='$change_id';")

    if [ "$status" != "approved" ]; then
        echo "ERROR: Change $change_id is not approved"
        return 1
    fi

    echo "Implementing change $change_id..."

    # Update status
    sqlite3 "$CHANGE_DB" << EOF
UPDATE changes SET
    status='in_progress',
    actual_time=CURRENT_TIMESTAMP
WHERE change_id='$change_id';

INSERT INTO change_history (change_id, action, user, notes)
VALUES ('$change_id', 'implementation_started', '$USER', 'Change implementation started');
EOF

    # Create change snapshot
    create_snapshot "$change_id"

    echo "Change implementation started. Remember to:"
    echo "1. Follow the approved plan"
    echo "2. Run tests after implementation"
    echo "3. Update status when complete"
}

# Create system snapshot
create_snapshot() {
    local change_id=$1
    local snapshot_dir="/var/lib/changes/snapshots/$change_id"

    mkdir -p "$snapshot_dir"

    # Capture system state
    dpkg -l > "$snapshot_dir/packages.txt"
    systemctl list-units --all > "$snapshot_dir/services.txt"
    ip addr > "$snapshot_dir/network.txt"
    df -h > "$snapshot_dir/disk.txt"

    # Backup critical configs
    tar -czf "$snapshot_dir/configs.tar.gz" /etc 2>/dev/null

    echo "System snapshot created: $snapshot_dir"
}

# Complete change
complete_change() {
    local change_id=$1

    read -p "Was the change successful? [yes/no]: " success
    read -p "Notes: " notes

    if [ "$success" = "yes" ]; then
        status="completed"
        action="completed"
    else
        status="failed"
        action="failed"

        read -p "Initiate rollback? [yes/no]: " rollback
        if [ "$rollback" = "yes" ]; then
            rollback_change "$change_id"
        fi
    fi

    sqlite3 "$CHANGE_DB" << EOF
UPDATE changes SET
    status='$status'
WHERE change_id='$change_id';

INSERT INTO change_history (change_id, action, user, notes)
VALUES ('$change_id', '$action', '$USER', '$notes');
EOF

    echo "Change $change_id marked as $status"
}

# Rollback change
rollback_change() {
    local change_id=$1

    echo "Initiating rollback for $change_id..."

    # Get rollback plan
    rollback_plan=$(sqlite3 "$CHANGE_DB" "SELECT rollback_plan FROM changes WHERE change_id='$change_id';")

    echo "Rollback Plan: $rollback_plan"
    echo "Restore from snapshot: /var/lib/changes/snapshots/$change_id"

    sqlite3 "$CHANGE_DB" << EOF
UPDATE changes SET
    status='rolled_back'
WHERE change_id='$change_id';

INSERT INTO change_history (change_id, action, user, notes)
VALUES ('$change_id', 'rolled_back', '$USER', 'Change rolled back');
EOF

    echo "Rollback initiated. Follow the rollback plan."
}

# Generate change report
generate_report() {
    echo "=== Change Management Report ==="
    echo "Generated: $(date)"
    echo ""

    echo "Recent Changes:"
    sqlite3 -header -column "$CHANGE_DB" << EOF
SELECT change_id, type, risk_level, status, scheduled_time
FROM changes
ORDER BY created_at DESC
LIMIT 10;
EOF

    echo ""
    echo "Change Statistics:"
    sqlite3 "$CHANGE_DB" << EOF
SELECT
    COUNT(*) as total_changes,
    SUM(CASE WHEN status='completed' THEN 1 ELSE 0 END) as successful,
    SUM(CASE WHEN status='failed' THEN 1 ELSE 0 END) as failed,
    SUM(CASE WHEN status='rolled_back' THEN 1 ELSE 0 END) as rolled_back
FROM changes;
EOF
}

# Main menu
case "$1" in
    init)
        init_database
        echo "Change management system initialized"
        ;;
    create)
        create_change
        ;;
    approve)
        approve_change "$2" "$3"
        ;;
    implement)
        implement_change "$2"
        ;;
    complete)
        complete_change "$2"
        ;;
    rollback)
        rollback_change "$2"
        ;;
    report)
        generate_report
        ;;
    *)
        echo "Usage: $0 {init|create|approve <id> <approver>|implement <id>|complete <id>|rollback <id>|report}"
        exit 1
        ;;
esac
```

### Security Best Practices

#### Security Hardening Checklist

```bash
# Security hardening automation
sudo nano /usr/local/bin/security-hardening.sh
```

```bash
#!/bin/bash
# Production security hardening

SECURITY_LOG="/var/log/security-hardening.log"
REPORT_FILE="/var/log/security-report.html"

log_message() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$SECURITY_LOG"
}

# OS Hardening
harden_os() {
    log_message "Starting OS hardening..."

    # Kernel parameters
    cat >> /etc/sysctl.d/99-security.conf << 'EOF'
# IP Spoofing protection
net.ipv4.conf.all.rp_filter = 1
net.ipv4.conf.default.rp_filter = 1

# Ignore ICMP redirects
net.ipv4.conf.all.accept_redirects = 0
net.ipv6.conf.all.accept_redirects = 0

# Ignore send redirects
net.ipv4.conf.all.send_redirects = 0

# Disable source packet routing
net.ipv4.conf.all.accept_source_route = 0
net.ipv6.conf.all.accept_source_route = 0

# Log Martians
net.ipv4.conf.all.log_martians = 1

# Ignore ICMP ping requests
net.ipv4.icmp_echo_ignore_broadcasts = 1

# SYN flood protection
net.ipv4.tcp_syncookies = 1
net.ipv4.tcp_syn_retries = 2
net.ipv4.tcp_synack_retries = 2
net.ipv4.tcp_max_syn_backlog = 4096

# Disable IPv6 if not needed
net.ipv6.conf.all.disable_ipv6 = 1
net.ipv6.conf.default.disable_ipv6 = 1
EOF

    sysctl -p /etc/sysctl.d/99-security.conf

    log_message "OS hardening completed"
}

# SSH Hardening
harden_ssh() {
    log_message "Hardening SSH configuration..."

    # Backup original config
    cp /etc/ssh/sshd_config /etc/ssh/sshd_config.backup

    # Apply secure settings
    cat >> /etc/ssh/sshd_config.d/99-hardening.conf << 'EOF'
# SSH Hardening
Protocol 2
Port 22
PermitRootLogin no
PasswordAuthentication no
PermitEmptyPasswords no
PubkeyAuthentication yes
AuthenticationMethods publickey
MaxAuthTries 3
MaxSessions 10
ClientAliveInterval 300
ClientAliveCountMax 2
LoginGraceTime 60
X11Forwarding no
IgnoreRhosts yes
HostbasedAuthentication no
AllowUsers ubuntu admin
DenyUsers root
Banner /etc/ssh/banner.txt
LogLevel VERBOSE
StrictModes yes
UsePrivilegeSeparation yes
Subsystem sftp internal-sftp
EOF

    # Create SSH banner
    cat > /etc/ssh/banner.txt << 'EOF'
**********************************************************************
*                                                                    *
* Unauthorized access to this system is forbidden and will be       *
* prosecuted by law. By accessing this system, you agree that your  *
* actions may be monitored and recorded.                            *
*                                                                    *
**********************************************************************
EOF

    # Restart SSH
    systemctl restart sshd

    log_message "SSH hardening completed"
}

# Firewall Configuration
configure_firewall() {
    log_message "Configuring firewall..."

    # UFW rules
    ufw --force reset
    ufw default deny incoming
    ufw default allow outgoing
    ufw default deny forward

    # Allow specific services
    ufw allow from any to any port 22 proto tcp comment "SSH"
    ufw allow from any to any port 80 proto tcp comment "HTTP"
    ufw allow from any to any port 443 proto tcp comment "HTTPS"

    # Rate limiting
    ufw limit ssh/tcp

    # Enable UFW
    ufw --force enable

    log_message "Firewall configured"
}

# User Account Security
secure_accounts() {
    log_message "Securing user accounts..."

    # Password policy
    apt-get install -y libpam-pwquality

    cat > /etc/security/pwquality.conf << 'EOF'
# Password quality requirements
minlen = 14
dcredit = -1
ucredit = -1
ocredit = -1
lcredit = -1
EOF

    # Account lockout policy
    cat >> /etc/pam.d/common-auth << 'EOF'
auth required pam_tally2.so onerr=fail audit silent deny=5 unlock_time=900
EOF

    # Password aging
    sed -i 's/^PASS_MAX_DAYS.*/PASS_MAX_DAYS   90/' /etc/login.defs
    sed -i 's/^PASS_MIN_DAYS.*/PASS_MIN_DAYS   7/' /etc/login.defs
    sed -i 's/^PASS_WARN_AGE.*/PASS_WARN_AGE   14/' /etc/login.defs

    # Remove unnecessary users
    for user in games gnats irc list news proxy uucp; do
        userdel -r $user 2>/dev/null
    done

    log_message "User accounts secured"
}

# File System Security
secure_filesystem() {
    log_message "Securing filesystem..."

    # Set secure permissions
    chmod 644 /etc/passwd
    chmod 640 /etc/shadow
    chmod 644 /etc/group
    chmod 640 /etc/gshadow

    # Find and fix world-writable files
    find / -type f -perm -002 2>/dev/null | while read file; do
        chmod o-w "$file"
        log_message "Fixed world-writable: $file"
    done

    # Find and report SUID/SGID files
    find / -type f \( -perm -4000 -o -perm -2000 \) 2>/dev/null > /tmp/suid_files.txt

    log_message "Filesystem secured"
}

# Audit Configuration
configure_audit() {
    log_message "Configuring audit system..."

    apt-get install -y auditd

    # Audit rules
    cat > /etc/audit/rules.d/hardening.rules << 'EOF'
# Delete all rules
-D

# Buffer Size
-b 8192

# Failure Mode
-f 1

# Audit successful and unsuccessful attempts to read/write/execute
-a always,exit -F arch=b64 -S open,openat -F exit=-EPERM -F auid>=1000 -F auid!=4294967295 -k access
-a always,exit -F arch=b64 -S open,openat -F exit=-EACCES -F auid>=1000 -F auid!=4294967295 -k access

# Audit privilege escalation
-a always,exit -F arch=b64 -S setuid -S setgid -S setreuid -S setregid -k privilege_escalation

# Audit system calls
-a always,exit -F arch=b64 -S adjtimex -S settimeofday -k time_change
-a always,exit -F arch=b64 -S mount -k mount
-a always,exit -F arch=b64 -S new_module -S delete_module -k modules

# Monitor specific files
-w /etc/passwd -p wa -k passwd_changes
-w /etc/shadow -p wa -k shadow_changes
-w /etc/sudoers -p wa -k sudoers_changes
EOF

    systemctl restart auditd

    log_message "Audit system configured"
}

# Generate security report
generate_security_report() {
    cat > "$REPORT_FILE" << 'EOF'
<!DOCTYPE html>
<html>
<head>
    <title>Security Hardening Report</title>
    <style>
        body { font-family: Arial, sans-serif; }
        .pass { color: green; }
        .fail { color: red; }
        table { border-collapse: collapse; width: 100%; }
        th, td { border: 1px solid #ddd; padding: 8px; }
    </style>
</head>
<body>
    <h1>Security Hardening Report</h1>
    <p>Generated: $(date)</p>

    <h2>Hardening Checklist</h2>
    <table>
        <tr><th>Check</th><th>Status</th></tr>
EOF

    # Perform security checks
    checks=(
        "SSH Root Login Disabled|grep -q 'PermitRootLogin no' /etc/ssh/sshd_config"
        "Password Authentication Disabled|grep -q 'PasswordAuthentication no' /etc/ssh/sshd_config"
        "Firewall Enabled|ufw status | grep -q 'Status: active'"
        "Automatic Updates Configured|test -f /etc/apt/apt.conf.d/50unattended-upgrades"
        "Audit System Running|systemctl is-active --quiet auditd"
        "Fail2ban Running|systemctl is-active --quiet fail2ban"
    )

    for check in "${checks[@]}"; do
        IFS='|' read -r description command <<< "$check"
        if eval $command; then
            echo "<tr><td>$description</td><td class='pass'>PASS</td></tr>" >> "$REPORT_FILE"
        else
            echo "<tr><td>$description</td><td class='fail'>FAIL</td></tr>" >> "$REPORT_FILE"
        fi
    done

    cat >> "$REPORT_FILE" << 'EOF'
    </table>
</body>
</html>
EOF

    log_message "Security report generated: $REPORT_FILE"
}

# Main execution
main() {
    log_message "=== Starting Security Hardening ==="

    harden_os
    harden_ssh
    configure_firewall
    secure_accounts
    secure_filesystem
    configure_audit
    generate_security_report

    log_message "=== Security Hardening Complete ==="
}

main "$@"
```

### System Hardening Checklist

```bash
# Create comprehensive hardening checklist
cat > /opt/documentation/security-hardening-checklist.md << 'EOF'
# Production Security Hardening Checklist

## Operating System
- [ ] Latest security patches installed
- [ ] Unnecessary services disabled
- [ ] Kernel parameters hardened
- [ ] SELinux/AppArmor enabled
- [ ] Core dumps disabled
- [ ] Unnecessary packages removed

## Network Security
- [ ] Firewall enabled and configured
- [ ] Default deny inbound policy
- [ ] Only necessary ports open
- [ ] Rate limiting configured
- [ ] DDoS protection enabled
- [ ] IPv6 disabled if not needed

## SSH Configuration
- [ ] Root login disabled
- [ ] Password authentication disabled
- [ ] Key-based authentication only
- [ ] Strong ciphers only
- [ ] Idle timeout configured
- [ ] Banner warning displayed
- [ ] Fail2ban configured

## User Management
- [ ] Strong password policy enforced
- [ ] Password aging configured
- [ ] Account lockout policy
- [ ] Sudo access restricted
- [ ] Unnecessary accounts removed
- [ ] Service accounts secured

## File System
- [ ] Appropriate file permissions
- [ ] No world-writable files
- [ ] SUID/SGID files audited
- [ ] /tmp mounted with noexec
- [ ] Separate partitions for /var, /home
- [ ] Disk encryption enabled

## Logging and Auditing
- [ ] Centralized logging configured
- [ ] Audit system enabled
- [ ] Log rotation configured
- [ ] Log monitoring active
- [ ] Security events tracked
- [ ] Log integrity protected

## Application Security
- [ ] Latest application versions
- [ ] Default credentials changed
- [ ] Unnecessary features disabled
- [ ] Input validation enabled
- [ ] Error messages sanitized
- [ ] Security headers configured

## Database Security
- [ ] Root access restricted
- [ ] Network access limited
- [ ] Strong authentication required
- [ ] Encryption at rest enabled
- [ ] Regular backups configured
- [ ] Audit logging enabled

## Monitoring
- [ ] System monitoring active
- [ ] Security monitoring enabled
- [ ] Intrusion detection system
- [ ] File integrity monitoring
- [ ] Performance baselines established
- [ ] Alert thresholds configured

## Backup and Recovery
- [ ] Regular backups scheduled
- [ ] Backup encryption enabled
- [ ] Offsite backups configured
- [ ] Recovery procedures tested
- [ ] RTO/RPO defined
- [ ] Disaster recovery plan

## Compliance
- [ ] Compliance requirements identified
- [ ] Security policies documented
- [ ] Access controls implemented
- [ ] Regular security assessments
- [ ] Incident response plan
- [ ] Security training completed

## Physical Security
- [ ] Server room access controlled
- [ ] Environmental monitoring
- [ ] UPS protection
- [ ] Fire suppression system
- [ ] Security cameras
- [ ] Asset inventory maintained
EOF
```

---

## Practice Exercises

### Exercise 1: Backup Strategy Implementation
1. Design a comprehensive 3-2-1 backup strategy
2. Implement automated backup scripts
3. Set up offsite replication
4. Test backup restoration procedures
5. Document recovery time and point objectives

### Exercise 2: Change Management
1. Implement a change management process
2. Create change request templates
3. Set up approval workflows
4. Practice emergency change procedures
5. Generate change reports

### Exercise 3: Security Hardening
1. Run security hardening scripts
2. Configure audit logging
3. Implement file integrity monitoring
4. Set up intrusion detection
5. Perform security assessment

### Exercise 4: Production Documentation
1. Document all production systems
2. Create runbooks for common procedures
3. Develop incident response playbooks
4. Maintain configuration documentation
5. Establish documentation review process

---

## Quick Reference

### Backup Commands
```bash
# Create full backup
tar -czpf /backup/full-$(date +%Y%m%d).tar.gz --exclude=/proc --exclude=/sys /

# MySQL backup
mysqldump --all-databases > backup.sql

# PostgreSQL backup
pg_dumpall > backup.sql

# Test restore
tar -xzf backup.tar.gz -C /restore/test/

# Verify backup
tar -tzf backup.tar.gz | head
```

### Maintenance Commands
```bash
# System updates
apt update && apt upgrade

# Clean packages
apt autoremove && apt autoclean

# Log rotation
logrotate -f /etc/logrotate.conf

# Service restart
systemctl restart service_name

# Check service health
systemctl status service_name
```

### Security Commands
```bash
# Check open ports
ss -tulpn

# Firewall status
ufw status verbose

# Failed logins
grep "Failed password" /var/log/auth.log

# Audit log review
aureport --summary

# Security scan
lynis audit system
```

---

## Additional Resources

### Best Practices Guides
- [NIST Cybersecurity Framework](https://www.nist.gov/cyberframework)
- [CIS Benchmarks](https://www.cisecurity.org/cis-benchmarks/)
- [OWASP Top 10](https://owasp.org/www-project-top-ten/)
- [ISO 27001 Standards](https://www.iso.org/isoiec-27001-information-security.html)

### Automation Tools
- [Ansible](https://www.ansible.com/) - Configuration management
- [Terraform](https://www.terraform.io/) - Infrastructure as Code
- [Jenkins](https://www.jenkins.io/) - CI/CD automation
- [GitLab CI](https://docs.gitlab.com/ee/ci/) - DevOps platform

### Monitoring Solutions
- [Prometheus](https://prometheus.io/) - Metrics and alerting
- [Grafana](https://grafana.com/) - Visualization
- [ELK Stack](https://www.elastic.co/elk-stack) - Log management
- [Nagios](https://www.nagios.org/) - Infrastructure monitoring

### Documentation Tools
- [Confluence](https://www.atlassian.com/software/confluence) - Team documentation
- [Docusaurus](https://docusaurus.io/) - Documentation sites
- [MkDocs](https://www.mkdocs.org/) - Project documentation
- [Read the Docs](https://readthedocs.org/) - Documentation hosting

### Next Steps
After completing this section, you should have:
- Robust backup and recovery procedures
- Comprehensive system documentation
- Automated maintenance processes
- Strong security posture
- Effective change management
- Production-ready monitoring

This completes your journey to becoming a production-ready Ubuntu system administrator!