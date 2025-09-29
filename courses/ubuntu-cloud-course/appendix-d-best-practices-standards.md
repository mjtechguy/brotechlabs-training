# Appendix D: Best Practices and Standards

## Security Best Practices

### System Hardening Checklist

#### Initial Setup Security
```bash
# 1. Update System
apt update && apt upgrade -y
apt dist-upgrade
apt autoremove

# 2. Configure Automatic Updates
dpkg-reconfigure --priority=low unattended-upgrades
# Enable:
# - "o=Ubuntu,a=${distro_codename}-security"
# - "o=Ubuntu,a=${distro_codename}-updates"

# 3. Set Strong Password Policy
# Install password quality tools
apt install libpam-pwquality

# Edit /etc/pam.d/common-password
password requisite pam_pwquality.so retry=3 minlen=12 difok=3 ucredit=-1 lcredit=-1 dcredit=-1 ocredit=-1

# 4. Configure Password Aging
# Edit /etc/login.defs
PASS_MAX_DAYS   90
PASS_MIN_DAYS   7
PASS_WARN_AGE   14

# 5. Disable Root Login
passwd -l root
usermod -s /usr/sbin/nologin root
```

#### Network Security
```bash
# 1. Configure Firewall
ufw default deny incoming
ufw default allow outgoing
ufw allow 22/tcp comment 'SSH'
ufw allow 443/tcp comment 'HTTPS'
ufw enable

# 2. Enable TCP SYN Cookies
echo "net.ipv4.tcp_syncookies = 1" >> /etc/sysctl.conf

# 3. Disable IP Forwarding
echo "net.ipv4.ip_forward = 0" >> /etc/sysctl.conf
echo "net.ipv6.conf.all.forwarding = 0" >> /etc/sysctl.conf

# 4. Ignore ICMP Redirects
echo "net.ipv4.conf.all.accept_redirects = 0" >> /etc/sysctl.conf
echo "net.ipv6.conf.all.accept_redirects = 0" >> /etc/sysctl.conf

# 5. Ignore Send Redirects
echo "net.ipv4.conf.all.send_redirects = 0" >> /etc/sysctl.conf

# 6. Disable Source Packet Routing
echo "net.ipv4.conf.all.accept_source_route = 0" >> /etc/sysctl.conf
echo "net.ipv6.conf.all.accept_source_route = 0" >> /etc/sysctl.conf

# 7. Log Martians
echo "net.ipv4.conf.all.log_martians = 1" >> /etc/sysctl.conf

# 8. Ignore ICMP Ping
echo "net.ipv4.icmp_echo_ignore_all = 1" >> /etc/sysctl.conf

sysctl -p
```

#### SSH Hardening
```bash
# /etc/ssh/sshd_config best practices
Port 22  # Consider changing to non-standard port
Protocol 2
HostKey /etc/ssh/ssh_host_ed25519_key
HostKey /etc/ssh/ssh_host_rsa_key

# Authentication
PermitRootLogin no
PubkeyAuthentication yes
PasswordAuthentication no
PermitEmptyPasswords no
ChallengeResponseAuthentication no
MaxAuthTries 3
MaxSessions 10

# Security
StrictModes yes
IgnoreRhosts yes
HostbasedAuthentication no
X11Forwarding no
AllowUsers admin deploy  # Whitelist specific users
#AllowGroups ssh-users

# Timing
LoginGraceTime 60
ClientAliveInterval 300
ClientAliveCountMax 2

# Logging
SyslogFacility AUTH
LogLevel VERBOSE

systemctl restart sshd
```

#### File System Security
```bash
# 1. Set Secure Permissions
chmod 644 /etc/passwd
chmod 000 /etc/shadow
chmod 644 /etc/group
chmod 000 /etc/gshadow
chmod 600 /boot/grub/grub.cfg

# 2. Find and Secure SUID/SGID Files
find / -perm /4000 -type f -exec ls -la {} \; 2>/dev/null
find / -perm /2000 -type f -exec ls -la {} \; 2>/dev/null

# 3. Find World-Writable Files
find / -type f -perm -002 -exec ls -la {} \; 2>/dev/null

# 4. Enable Secure Shared Memory
echo "tmpfs /run/shm tmpfs defaults,noexec,nosuid 0 0" >> /etc/fstab

# 5. Disable Unused Filesystems
echo "install cramfs /bin/true" >> /etc/modprobe.d/disable-filesystems.conf
echo "install freevxfs /bin/true" >> /etc/modprobe.d/disable-filesystems.conf
echo "install jffs2 /bin/true" >> /etc/modprobe.d/disable-filesystems.conf
echo "install hfs /bin/true" >> /etc/modprobe.d/disable-filesystems.conf
echo "install hfsplus /bin/true" >> /etc/modprobe.d/disable-filesystems.conf
echo "install udf /bin/true" >> /etc/modprobe.d/disable-filesystems.conf
```

### Access Control Best Practices

#### User Management Standards
```bash
# User Creation Template
#!/bin/bash
# create-user.sh - Standardized user creation

USERNAME=$1
FULLNAME=$2
DEPARTMENT=$3

# Create user with standards
useradd -m \
  -s /bin/bash \
  -c "$FULLNAME - $DEPARTMENT" \
  -G users \
  $USERNAME

# Set password policy for user
chage -m 7 -M 90 -W 14 $USERNAME

# Create SSH directory
mkdir -p /home/$USERNAME/.ssh
chmod 700 /home/$USERNAME/.ssh

# Set quota (if enabled)
setquota -u $USERNAME 5G 6G 0 0 /home

# Log user creation
echo "$(date): User $USERNAME created by $USER" >> /var/log/user-management.log
```

#### Sudo Configuration Best Practices
```bash
# /etc/sudoers.d/best-practices

# Use aliases for better management
User_Alias ADMINS = admin, sysadmin
User_Alias DEVELOPERS = dev1, dev2
User_Alias OPERATORS = ops1, ops2

Cmnd_Alias SHUTDOWN = /sbin/halt, /sbin/reboot, /sbin/poweroff
Cmnd_Alias NETWORKING = /sbin/route, /sbin/ifconfig, /bin/ping, /sbin/iptables
Cmnd_Alias SOFTWARE = /bin/rpm, /usr/bin/yum, /usr/bin/apt, /usr/bin/snap
Cmnd_Alias SERVICES = /usr/bin/systemctl, /usr/sbin/service

# Admin group permissions
ADMINS ALL=(ALL) ALL

# Developer permissions
DEVELOPERS ALL=(ALL) NOPASSWD: SOFTWARE, SERVICES

# Operator permissions
OPERATORS ALL=(ALL) NOPASSWD: NETWORKING, !/usr/bin/passwd

# Require password for dangerous commands
ADMINS ALL=(ALL) PASSWD: SHUTDOWN

# Log sudo commands
Defaults logfile="/var/log/sudo.log"
Defaults log_input
Defaults log_output

# Security options
Defaults requiretty
Defaults use_pty
Defaults lecture="always"
Defaults timestamp_timeout=15
Defaults passwd_tries=3
```

### Logging and Monitoring Standards

#### Centralized Logging Configuration
```bash
# /etc/rsyslog.d/50-default.conf

# Log to remote syslog server
*.* @@syslog-server.example.com:514

# Local logging with proper rotation
auth,authpriv.*                 /var/log/auth.log
*.*;auth,authpriv.none          /var/log/syslog
kern.*                          /var/log/kern.log
mail.*                          /var/log/mail.log

# Application-specific logs
local0.*                        /var/log/application.log
local1.*                        /var/log/database.log

# Log rotation configuration
# /etc/logrotate.d/application
/var/log/application.log {
    daily
    rotate 30
    compress
    delaycompress
    notifempty
    create 640 syslog adm
    postrotate
        systemctl reload rsyslog > /dev/null
    endscript
}
```

#### Audit System Configuration
```bash
# Install and configure auditd
apt install auditd

# /etc/audit/rules.d/audit.rules

# Remove any existing rules
-D

# Buffer Size
-b 8192

# Failure Mode
-f 1

# Monitor authentication events
-w /var/log/faillog -p wa -k auth_failures
-w /var/log/lastlog -p wa -k logins
-w /var/log/tallylog -p wa -k logins

# Monitor user/group changes
-w /etc/group -p wa -k identity
-w /etc/passwd -p wa -k identity
-w /etc/gshadow -p wa -k identity
-w /etc/shadow -p wa -k identity
-w /etc/security/opasswd -p wa -k identity

# Monitor sudoers
-w /etc/sudoers -p wa -k sudoers
-w /etc/sudoers.d/ -p wa -k sudoers

# Monitor SSH configuration
-w /etc/ssh/sshd_config -p wa -k sshd_config

# Monitor system calls
-a always,exit -F arch=b64 -S execve -F success=1 -k execution
-a always,exit -F arch=b64 -S chmod -S fchmod -S fchmodat -F auid>=1000 -F auid!=4294967295 -k permissions
-a always,exit -F arch=b64 -S chown -S fchown -S fchownat -S lchown -F auid>=1000 -F auid!=4294967295 -k ownership

# Start auditd
systemctl enable auditd
systemctl start auditd
```

## Naming Conventions

### Hostname Standards
```bash
# Format: [environment]-[role]-[location]-[number]
# Examples:
prod-web-us-east-01
dev-db-us-west-02
stage-app-eu-central-01

# Environment codes:
# prod - Production
# stage - Staging
# dev - Development
# test - Testing

# Role codes:
# web - Web server
# app - Application server
# db - Database server
# cache - Cache server
# lb - Load balancer
# mon - Monitoring server
```

### File and Directory Naming
```bash
# Standard directory structure
/opt/
├── applications/           # Custom applications
│   ├── app-name-version/
│   └── current -> app-name-version/
├── scripts/                # Administrative scripts
│   ├── backup/
│   ├── monitoring/
│   └── maintenance/
├── configs/                # Configuration backups
│   └── YYYY-MM-DD/
└── data/                   # Application data
    ├── databases/
    └── uploads/

# Backup file naming
# Format: [type]-[scope]-[date]-[time].tar.gz
# Examples:
full-system-20240101-0200.tar.gz
incremental-database-20240101-1400.tar.gz
config-nginx-20240101-1000.tar.gz

# Log file naming
# Format: [application]-[type]-[date].log
# Examples:
nginx-access-20240101.log
mysql-slow-20240101.log
application-error-20240101.log

# Script naming conventions
backup-mysql.sh          # Verb-noun format
check-disk-space.sh      # Clear purpose
deploy-application.sh    # Action-oriented
```

### Network Naming Standards
```yaml
# Network configuration files
# /etc/netplan/[priority]-[type]-[interface].yaml
01-netcfg-eth0.yaml
10-netcfg-bond0.yaml
20-netcfg-vlan10.yaml

# Interface naming
eth0    # Primary physical interface
eth1    # Secondary physical interface
bond0   # First bond interface
vlan10  # VLAN with ID 10
br0     # First bridge interface
tun0    # First tunnel interface
```

## Documentation Standards

### System Documentation Template
```markdown
# System Documentation: [Server Name]

## Overview
- **Purpose**: [Primary function of the server]
- **Environment**: [Production/Staging/Development]
- **Created Date**: [YYYY-MM-DD]
- **Last Updated**: [YYYY-MM-DD]
- **Maintained By**: [Team/Person]

## Hardware Specifications
- **CPU**: [Model and cores]
- **RAM**: [Amount]
- **Storage**: [Type and capacity]
- **Network**: [Interface details]

## Software Stack
- **OS**: Ubuntu [Version]
- **Kernel**: [Version]
- **Key Services**:
  - Service 1: [Version]
  - Service 2: [Version]

## Network Configuration
- **Primary IP**: [IP Address]
- **Gateway**: [Gateway IP]
- **DNS Servers**: [DNS IPs]
- **Firewall Rules**: [Summary or link]

## Access Information
- **SSH Port**: [Port number]
- **Admin Users**: [List of admin users]
- **Sudo Access**: [Who has sudo]

## Backup Strategy
- **Schedule**: [When backups run]
- **Retention**: [How long kept]
- **Location**: [Where stored]
- **Recovery Time**: [RTO/RPO]

## Monitoring
- **Monitoring System**: [Prometheus/Nagios/etc]
- **Alert Recipients**: [Email/Slack]
- **Key Metrics**: [What's monitored]

## Dependencies
- **Depends On**: [List of dependencies]
- **Required By**: [What depends on this]

## Maintenance Procedures
- **Patching Schedule**: [When/How]
- **Restart Procedures**: [Steps]
- **Health Checks**: [Commands/URLs]

## Emergency Contacts
- **Primary**: [Name - Phone - Email]
- **Secondary**: [Name - Phone - Email]
- **Escalation**: [Manager - Phone - Email]

## Change Log
| Date | Change | Performed By |
|------|--------|--------------|
| YYYY-MM-DD | Initial setup | Admin |
| YYYY-MM-DD | Added monitoring | DevOps |
```

### Runbook Template
```markdown
# Runbook: [Service/Application Name]

## Service Overview
**Description**: [What the service does]
**Business Impact**: [Critical/High/Medium/Low]
**SLA**: [Uptime requirement]

## Architecture Diagram
[Include or link to architecture diagram]

## Normal Operations

### Startup Procedure
1. [Step 1]
2. [Step 2]
```bash
# Command example
systemctl start service-name
```

### Shutdown Procedure
1. [Step 1]
2. [Step 2]
```bash
# Command example
systemctl stop service-name
```

### Health Check
```bash
# Health check commands
curl http://localhost/health
systemctl status service-name
```

## Monitoring and Alerts

### Key Metrics
- CPU Usage: < 80%
- Memory Usage: < 90%
- Response Time: < 200ms

### Alert Responses

#### High CPU Usage
1. Check top processes: `top -b -n 1`
2. Review application logs
3. Scale horizontally if needed

#### Service Down
1. Check service status
2. Review error logs
3. Attempt restart
4. Escalate if not resolved in 15 minutes

## Troubleshooting

### Common Issues

#### Issue: Service won't start
**Symptoms**: [Description]
**Diagnosis**: [Commands to run]
**Solution**: [Steps to fix]

#### Issue: Performance degradation
**Symptoms**: [Description]
**Diagnosis**: [Commands to run]
**Solution**: [Steps to fix]

## Backup and Recovery

### Backup Procedure
```bash
# Backup commands
/opt/scripts/backup/backup-service.sh
```

### Recovery Procedure
```bash
# Recovery commands
/opt/scripts/recovery/restore-service.sh
```

## Maintenance Tasks

### Daily
- [ ] Check service health
- [ ] Review error logs

### Weekly
- [ ] Verify backups
- [ ] Review performance metrics

### Monthly
- [ ] Update documentation
- [ ] Test recovery procedure

## Escalation Path
1. L1 Support: [Contact]
2. L2 Support: [Contact]
3. Service Owner: [Contact]
4. Management: [Contact]
```

### Incident Response Documentation
```markdown
# Incident Report: [INC-YYYYMMDD-###]

## Incident Summary
- **Date/Time Detected**: [YYYY-MM-DD HH:MM UTC]
- **Date/Time Resolved**: [YYYY-MM-DD HH:MM UTC]
- **Duration**: [X hours Y minutes]
- **Severity**: [Critical/High/Medium/Low]
- **Impact**: [Business impact description]

## Timeline
| Time (UTC) | Event |
|------------|-------|
| HH:MM | Incident detected |
| HH:MM | First response |
| HH:MM | Root cause identified |
| HH:MM | Fix implemented |
| HH:MM | Service restored |

## Root Cause
[Detailed explanation of what caused the incident]

## Resolution
[Steps taken to resolve the incident]

## Impact Analysis
- **Affected Services**: [List]
- **Number of Users Affected**: [Count]
- **Data Loss**: [Yes/No - Details]
- **Financial Impact**: [If applicable]

## Lessons Learned
### What Went Well
- [Point 1]
- [Point 2]

### What Could Be Improved
- [Point 1]
- [Point 2]

## Action Items
| Action | Owner | Due Date | Status |
|--------|-------|----------|---------|
| [Action 1] | [Name] | [Date] | [Status] |
| [Action 2] | [Name] | [Date] | [Status] |

## Supporting Evidence
- Log files: [Location/Link]
- Monitoring graphs: [Location/Link]
- Configuration changes: [Location/Link]
```

## Deployment Best Practices

### Deployment Checklist
```bash
#!/bin/bash
# deployment-checklist.sh

echo "=== Pre-Deployment Checklist ==="

# 1. Backup current state
echo "[ ] Current application backed up"
echo "[ ] Database backed up"
echo "[ ] Configuration files backed up"

# 2. Testing
echo "[ ] Code passes all unit tests"
echo "[ ] Code passes integration tests"
echo "[ ] Security scan completed"
echo "[ ] Performance testing completed"

# 3. Documentation
echo "[ ] Release notes prepared"
echo "[ ] Runbook updated"
echo "[ ] Rollback plan documented"

# 4. Communication
echo "[ ] Maintenance window scheduled"
echo "[ ] Stakeholders notified"
echo "[ ] Support team briefed"

# 5. Environment preparation
echo "[ ] Dependencies updated"
echo "[ ] Configuration changes reviewed"
echo "[ ] Resource scaling verified"

echo ""
echo "=== Deployment Steps ==="
echo "1. Enable maintenance mode"
echo "2. Stop application services"
echo "3. Deploy new code"
echo "4. Run database migrations"
echo "5. Update configuration"
echo "6. Start application services"
echo "7. Verify health checks"
echo "8. Disable maintenance mode"

echo ""
echo "=== Post-Deployment Checklist ==="
echo "[ ] Application responding correctly"
echo "[ ] All health checks passing"
echo "[ ] No errors in logs"
echo "[ ] Performance metrics normal"
echo "[ ] User acceptance confirmed"
```

### Blue-Green Deployment Script
```bash
#!/bin/bash
# blue-green-deploy.sh

# Configuration
APP_DIR="/opt/applications"
BLUE_PORT=8000
GREEN_PORT=8001
NGINX_CONFIG="/etc/nginx/sites-available/app"
HEALTH_CHECK_URL="http://localhost:{PORT}/health"

# Functions
health_check() {
    local port=$1
    local url=${HEALTH_CHECK_URL/\{PORT\}/$port}
    curl -sf "$url" > /dev/null
    return $?
}

deploy_to_environment() {
    local env=$1
    local port=$2

    echo "Deploying to $env environment (port $port)..."

    # Deploy new code
    rsync -av --delete /tmp/new-release/ $APP_DIR/$env/

    # Install dependencies
    cd $APP_DIR/$env
    npm install --production

    # Run migrations
    npm run migrate

    # Start service
    systemctl start app-$env

    # Wait for startup
    sleep 10

    # Health check
    if health_check $port; then
        echo "$env environment healthy"
        return 0
    else
        echo "$env environment health check failed"
        return 1
    fi
}

switch_traffic() {
    local target=$1
    local port=$2

    echo "Switching traffic to $target..."

    # Update nginx configuration
    sed -i "s/proxy_pass http:\/\/localhost:[0-9]\+/proxy_pass http:\/\/localhost:$port/" $NGINX_CONFIG

    # Reload nginx
    nginx -t && systemctl reload nginx

    echo "Traffic switched to $target"
}

# Main deployment
main() {
    # Determine current active environment
    if grep -q "proxy_pass http://localhost:$BLUE_PORT" $NGINX_CONFIG; then
        ACTIVE="blue"
        INACTIVE="green"
        INACTIVE_PORT=$GREEN_PORT
    else
        ACTIVE="green"
        INACTIVE="blue"
        INACTIVE_PORT=$BLUE_PORT
    fi

    echo "Current active: $ACTIVE"
    echo "Deploying to: $INACTIVE"

    # Deploy to inactive environment
    if deploy_to_environment $INACTIVE $INACTIVE_PORT; then
        # Switch traffic
        switch_traffic $INACTIVE $INACTIVE_PORT

        # Stop old environment
        sleep 10
        systemctl stop app-$ACTIVE

        echo "Deployment successful"
    else
        echo "Deployment failed, keeping current environment"
        exit 1
    fi
}

main
```

### Rollback Procedures
```bash
#!/bin/bash
# rollback.sh - Quick rollback procedure

# Configuration
BACKUP_DIR="/opt/backups"
APP_DIR="/opt/applications/current"
SERVICE_NAME="application"

# Find latest backup
LATEST_BACKUP=$(ls -t $BACKUP_DIR/*.tar.gz | head -1)

if [ -z "$LATEST_BACKUP" ]; then
    echo "No backup found!"
    exit 1
fi

echo "Rolling back to: $LATEST_BACKUP"

# Stop service
systemctl stop $SERVICE_NAME

# Backup current (failed) deployment
tar -czf $BACKUP_DIR/failed-$(date +%Y%m%d-%H%M%S).tar.gz -C $APP_DIR .

# Restore from backup
rm -rf $APP_DIR/*
tar -xzf $LATEST_BACKUP -C $APP_DIR

# Restore database if needed
if [ -f "$BACKUP_DIR/database-latest.sql" ]; then
    mysql < $BACKUP_DIR/database-latest.sql
fi

# Start service
systemctl start $SERVICE_NAME

# Verify
if systemctl is-active $SERVICE_NAME; then
    echo "Rollback successful"
else
    echo "Rollback failed - manual intervention required"
    exit 1
fi
```

## Monitoring Standards

### Monitoring Metrics Framework
```yaml
# monitoring-standards.yml

# Infrastructure Metrics
infrastructure:
  cpu:
    warning_threshold: 80
    critical_threshold: 95
    check_interval: 30s

  memory:
    warning_threshold: 85
    critical_threshold: 95
    check_interval: 30s

  disk:
    warning_threshold: 80
    critical_threshold: 90
    check_interval: 5m

  network:
    packet_loss_warning: 1
    packet_loss_critical: 5
    check_interval: 1m

# Application Metrics
application:
  response_time:
    warning_threshold: 500ms
    critical_threshold: 1000ms

  error_rate:
    warning_threshold: 1%
    critical_threshold: 5%

  throughput:
    minimum_threshold: 100req/s

  availability:
    target: 99.9%

# Business Metrics
business:
  transaction_success:
    minimum_threshold: 98%

  user_sessions:
    track: true

  conversion_rate:
    track: true
```

### Alert Configuration Standards
```yaml
# alerting-rules.yml

groups:
  - name: standard_alerts
    interval: 30s
    rules:
      # CPU Alert
      - alert: HighCPU
        expr: cpu_usage > 80
        for: 5m
        labels:
          severity: warning
          team: infrastructure
        annotations:
          summary: "High CPU on {{ $labels.instance }}"
          description: "CPU usage {{ $value }}%"
          runbook: "https://wiki/runbooks/high-cpu"

      # Memory Alert
      - alert: HighMemory
        expr: memory_usage > 85
        for: 5m
        labels:
          severity: warning
          team: infrastructure
        annotations:
          summary: "High memory on {{ $labels.instance }}"
          description: "Memory usage {{ $value }}%"
          runbook: "https://wiki/runbooks/high-memory"

      # Disk Alert
      - alert: DiskSpaceLow
        expr: disk_free < 10
        for: 5m
        labels:
          severity: critical
          team: infrastructure
        annotations:
          summary: "Low disk space on {{ $labels.instance }}"
          description: "Only {{ $value }}% free"
          runbook: "https://wiki/runbooks/low-disk"

      # Service Alert
      - alert: ServiceDown
        expr: up == 0
        for: 1m
        labels:
          severity: critical
          team: oncall
        annotations:
          summary: "Service down on {{ $labels.instance }}"
          description: "{{ $labels.job }} is not responding"
          runbook: "https://wiki/runbooks/service-down"
```

## Backup and Recovery Standards

### Backup Strategy Framework
```bash
# 3-2-1 Backup Rule Implementation
# 3 copies of data
# 2 different storage media
# 1 offsite backup

# Backup Types and Schedules
FULL_BACKUP_DAY="Sunday"
INCREMENTAL_BACKUP_DAYS="Monday,Tuesday,Wednesday,Thursday,Friday,Saturday"
DIFFERENTIAL_BACKUP_DAY="Wednesday"

# Retention Policies
DAILY_RETENTION=7        # Keep daily backups for 7 days
WEEKLY_RETENTION=4       # Keep weekly backups for 4 weeks
MONTHLY_RETENTION=12     # Keep monthly backups for 12 months
YEARLY_RETENTION=7       # Keep yearly backups for 7 years

# Backup Verification
VERIFY_PERCENTAGE=10     # Verify 10% of backups randomly
FULL_VERIFY_MONTHLY=yes  # Full verification once a month
```

### Recovery Time Standards
```yaml
# recovery-standards.yml

recovery_objectives:
  tier_1_critical:
    rto: 15m  # Recovery Time Objective
    rpo: 1h   # Recovery Point Objective
    test_frequency: monthly

  tier_2_important:
    rto: 4h
    rpo: 4h
    test_frequency: quarterly

  tier_3_standard:
    rto: 24h
    rpo: 24h
    test_frequency: semi-annually

  tier_4_archive:
    rto: 72h
    rpo: 7d
    test_frequency: annually

backup_testing:
  schedule: "First Sunday of month"
  procedure:
    - Restore random backup to test environment
    - Verify data integrity
    - Test application functionality
    - Document results
    - Update recovery procedures if needed
```

## Compliance and Regulatory Standards

### Data Protection Standards
```bash
# GDPR Compliance Checklist

# Data Encryption
- [ ] Data encrypted at rest (AES-256)
- [ ] Data encrypted in transit (TLS 1.2+)
- [ ] Encryption keys properly managed
- [ ] Key rotation implemented

# Access Control
- [ ] Role-based access control (RBAC)
- [ ] Multi-factor authentication (MFA)
- [ ] Regular access reviews
- [ ] Privilege access management (PAM)

# Data Retention
- [ ] Retention policies defined
- [ ] Automatic data purging
- [ ] Right to erasure implemented
- [ ] Backup retention aligned

# Audit and Logging
- [ ] Comprehensive audit logging
- [ ] Log integrity protection
- [ ] Log retention policy
- [ ] Regular audit reviews

# Incident Response
- [ ] Incident response plan
- [ ] Breach notification procedure
- [ ] Data recovery procedures
- [ ] Regular drills conducted
```

### Security Compliance Framework
```yaml
# security-compliance.yml

cis_benchmark:
  version: "Ubuntu Linux 22.04 LTS Benchmark v1.0.0"
  level_1_server:
    - filesystem_configuration
    - software_updates
    - filesystem_integrity
    - secure_boot
    - process_hardening
    - mandatory_access_control
    - warning_banners

  level_2_server:
    - advanced_auditing
    - kernel_hardening
    - network_parameters
    - ipv6_configuration

pci_dss:
  requirements:
    - build_secure_network
    - protect_cardholder_data
    - vulnerability_management
    - access_control
    - network_monitoring
    - security_policies

hipaa:
  safeguards:
    administrative:
      - security_officer
      - workforce_training
      - access_management
      - incident_procedures

    physical:
      - facility_access
      - workstation_use
      - device_controls

    technical:
      - access_control
      - audit_controls
      - integrity_controls
      - transmission_security
```

### Audit Trail Requirements
```bash
#!/bin/bash
# audit-requirements.sh

# What to log
AUDIT_EVENTS=(
    "Authentication attempts"
    "Authorization changes"
    "Data access"
    "Data modifications"
    "Configuration changes"
    "Administrative actions"
    "System events"
    "Security events"
)

# Log format standard
LOG_FORMAT='{
    "timestamp": "ISO8601",
    "event_type": "string",
    "user": "username",
    "source_ip": "IP address",
    "action": "string",
    "resource": "string",
    "result": "success|failure",
    "details": "object"
}'

# Log retention requirements
LOG_RETENTION=(
    "Security logs: 2 years"
    "Access logs: 1 year"
    "Application logs: 6 months"
    "System logs: 3 months"
    "Debug logs: 7 days"
)

# Log protection
LOG_PROTECTION=(
    "Write-once storage"
    "Cryptographic hashing"
    "Off-site replication"
    "Access restrictions"
    "Integrity monitoring"
)
```

## Change Management Standards

### Change Request Template
```markdown
# Change Request: [CR-YYYY-MM-DD-###]

## Change Summary
- **Requested By**: [Name]
- **Date Requested**: [YYYY-MM-DD]
- **Priority**: [Emergency/High/Normal/Low]
- **Type**: [Standard/Normal/Emergency]

## Change Description
[Detailed description of the change]

## Business Justification
[Why this change is needed]

## Risk Assessment
- **Risk Level**: [High/Medium/Low]
- **Impact if Not Implemented**: [Description]
- **Impact of Implementation**: [Description]

## Implementation Plan
1. [Step 1]
2. [Step 2]
3. [Step 3]

## Testing Plan
- [ ] Unit testing
- [ ] Integration testing
- [ ] User acceptance testing
- [ ] Performance testing

## Rollback Plan
[Detailed rollback procedure]

## Affected Systems
- System 1
- System 2

## Stakeholder Approval
- [ ] Technical Lead
- [ ] Security Team
- [ ] Business Owner
- [ ] Change Advisory Board

## Implementation Schedule
- **Start Time**: [YYYY-MM-DD HH:MM]
- **End Time**: [YYYY-MM-DD HH:MM]
- **Maintenance Window**: [Yes/No]
```

### Post-Implementation Review
```markdown
# Post-Implementation Review: [CR-YYYY-MM-DD-###]

## Implementation Summary
- **Actual Start**: [YYYY-MM-DD HH:MM]
- **Actual End**: [YYYY-MM-DD HH:MM]
- **Duration**: [X hours Y minutes]

## Success Criteria
- [ ] Change implemented as planned
- [ ] No unplanned outages
- [ ] Performance metrics normal
- [ ] No security incidents
- [ ] User acceptance confirmed

## Issues Encountered
[List any issues and how they were resolved]

## Lessons Learned
### What Went Well
- [Point 1]
- [Point 2]

### Areas for Improvement
- [Point 1]
- [Point 2]

## Follow-up Actions
| Action | Owner | Due Date |
|--------|-------|----------|
| [Action 1] | [Name] | [Date] |

## Sign-off
- [ ] Technical Lead
- [ ] Change Manager
- [ ] Business Owner
```

## Performance Standards

### Performance Baseline Metrics
```yaml
# performance-baselines.yml

web_servers:
  response_time:
    p50: 100ms
    p95: 500ms
    p99: 1000ms
  requests_per_second:
    minimum: 1000
    target: 5000
  error_rate:
    maximum: 0.1%

database_servers:
  query_time:
    p50: 10ms
    p95: 100ms
    p99: 500ms
  connections:
    maximum: 500
  cpu_usage:
    target: < 60%
  memory_usage:
    target: < 80%

application_servers:
  cpu_usage:
    target: < 70%
  memory_usage:
    target: < 75%
  garbage_collection:
    frequency: < 1/min
    duration: < 100ms
```

### Capacity Planning Standards
```bash
#!/bin/bash
# capacity-planning.sh

# Growth projections
MONTHLY_GROWTH_RATE=10  # Percent
PEAK_MULTIPLIER=3       # Peak traffic is 3x average

# Resource thresholds for scaling
CPU_SCALE_THRESHOLD=70
MEMORY_SCALE_THRESHOLD=75
DISK_SCALE_THRESHOLD=80
NETWORK_SCALE_THRESHOLD=80

# Capacity review schedule
REVIEW_FREQUENCY="Monthly"
FORECAST_PERIOD="6 months"

# Scaling policies
VERTICAL_SCALING_LIMIT="When to switch to horizontal"
HORIZONTAL_SCALING_TRIGGER="Auto-scaling rules"
```

---

This comprehensive best practices and standards guide provides frameworks and templates for maintaining professional, secure, and compliant Ubuntu server environments following industry standards.