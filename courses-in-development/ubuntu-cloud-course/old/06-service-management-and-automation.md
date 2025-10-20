# Part 6: Service Management and Automation

## Prerequisites

Before starting this section, you should understand:
- Basic Linux commands and file permissions
- How to use systemctl to manage services
- Basic text editing with nano or vim
- How environment variables work
- Basic understanding of processes and services

**Learning Resources:**
- [Cron How-To Guide](https://help.ubuntu.com/community/CronHowto)
- [Bash Scripting Tutorial](https://www.gnu.org/software/bash/manual/)
- [Ansible Documentation](https://docs.ansible.com/ansible/latest/user_guide/index.html)
- [Cloud-init Documentation](https://cloudinit.readthedocs.io/)

---

## Chapter 14: Task Automation

### Introduction to Automation

Automation eliminates repetitive manual tasks, reduces errors, and ensures consistency. In Linux, we have multiple tools for automation:

1. **Cron**: Traditional scheduled task runner
2. **Systemd Timers**: Modern alternative to cron
3. **Shell Scripts**: Custom automation logic
4. **Configuration Management**: Tools like Ansible

Let's explore each method in detail.

### Cron Job Management

Cron is a time-based job scheduler that runs commands at specified times or intervals.

#### Understanding Cron

```bash
# Cron components:
# 1. Cron daemon (crond) - The service that runs jobs
# 2. Crontab - User-specific job definitions
# 3. System cron - System-wide job definitions

# Check if cron is running
systemctl status cron

# View your crontab
crontab -l

# Edit your crontab
crontab -e

# View root's crontab
sudo crontab -l -u root

# View system cron jobs
ls /etc/cron.*
cat /etc/crontab
```

#### Cron Syntax

The cron syntax consists of five time fields followed by the command:

```bash
# ┌───────────── minute (0 - 59)
# │ ┌───────────── hour (0 - 23)
# │ │ ┌───────────── day of the month (1 - 31)
# │ │ │ ┌───────────── month (1 - 12)
# │ │ │ │ ┌───────────── day of the week (0 - 7) (0 or 7 is Sun)
# │ │ │ │ │
# │ │ │ │ │
# * * * * * command to execute

# Examples:
30 2 * * *    /usr/local/bin/backup.sh         # 2:30 AM daily
0 */4 * * *   /usr/local/bin/check-disk.sh     # Every 4 hours
15 3 * * 1    /usr/local/bin/weekly-report.sh  # 3:15 AM every Monday
0 9-17 * * 1-5 /usr/local/bin/hourly-task.sh   # Every hour 9AM-5PM weekdays
*/5 * * * *   /usr/local/bin/monitor.sh        # Every 5 minutes
@reboot       /usr/local/bin/startup.sh        # At system startup
@daily        /usr/local/bin/daily-task.sh     # Once a day (midnight)
@weekly       /usr/local/bin/weekly-task.sh    # Once a week (Sunday midnight)
@monthly      /usr/local/bin/monthly-task.sh   # Once a month (1st at midnight)
```

#### Creating Cron Jobs

```bash
# Edit user crontab
crontab -e

# Add a backup job
0 3 * * * /usr/local/bin/backup-website.sh >> /var/log/backup.log 2>&1

# Understanding output redirection:
# >> /var/log/backup.log  - Append stdout to log file
# 2>&1                    - Redirect stderr to stdout
# > /dev/null 2>&1        - Discard all output

# Create the backup script
sudo nano /usr/local/bin/backup-website.sh
```

```bash
#!/bin/bash
# Website backup script

# Set variables
BACKUP_DIR="/backup/website"
WEB_DIR="/var/www/html"
DB_NAME="myapp"
DATE=$(date +%Y%m%d-%H%M%S)

# Create backup directory
mkdir -p "$BACKUP_DIR"

# Backup files
tar -czf "$BACKUP_DIR/files-$DATE.tar.gz" "$WEB_DIR"

# Backup database
mysqldump -u root "$DB_NAME" | gzip > "$BACKUP_DIR/db-$DATE.sql.gz"

# Keep only last 7 days of backups
find "$BACKUP_DIR" -name "*.tar.gz" -mtime +7 -delete
find "$BACKUP_DIR" -name "*.sql.gz" -mtime +7 -delete

echo "Backup completed: $DATE"
```

```bash
# Make script executable
sudo chmod +x /usr/local/bin/backup-website.sh

# Test the script
sudo /usr/local/bin/backup-website.sh
```

#### System Cron Jobs

```bash
# System-wide crontab
sudo nano /etc/crontab

# System cron directories
ls -la /etc/cron.d/       # Custom system cron jobs
ls -la /etc/cron.daily/   # Scripts run daily
ls -la /etc/cron.hourly/  # Scripts run hourly
ls -la /etc/cron.weekly/  # Scripts run weekly
ls -la /etc/cron.monthly/ # Scripts run monthly

# Create a system cron job
sudo nano /etc/cron.d/system-monitor
```

```bash
# System monitoring cron job
SHELL=/bin/bash
PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin
MAILTO=admin@example.com

# Check disk space every hour
0 * * * * root /usr/local/bin/check-disk-space.sh

# Monitor services every 5 minutes
*/5 * * * * root /usr/local/bin/check-services.sh

# System health report daily at 6 AM
0 6 * * * root /usr/local/bin/system-health-report.sh
```

#### Cron Best Practices

```bash
# 1. Always use absolute paths
# Good: /usr/local/bin/script.sh
# Bad: script.sh

# 2. Set PATH in crontab
PATH=/usr/local/bin:/usr/bin:/bin

# 3. Handle errors in scripts
#!/bin/bash
set -e  # Exit on error
set -u  # Exit on undefined variable

# 4. Log output
0 3 * * * /path/to/script.sh >> /var/log/myscript.log 2>&1

# 5. Use lock files to prevent overlapping
sudo nano /usr/local/bin/safe-backup.sh
```

```bash
#!/bin/bash
# Script with lock file to prevent concurrent execution

LOCKFILE="/var/run/backup.lock"
LOCKFD=99

# Private lock function
_lock() {
    flock -$1 $LOCKFD
}

# Create lock file
_lock x
exec {LOCKFD}>$LOCKFILE

# Try to acquire lock (non-blocking)
if ! _lock xn; then
    echo "Another instance is running"
    exit 1
fi

# Your actual script here
echo "Running backup..."
sleep 60  # Simulate long-running task

# Lock is automatically released when script exits
```

### Systemd Timers

Systemd timers are a modern alternative to cron with more features and better integration.

#### Creating a Systemd Timer

```bash
# Step 1: Create a service unit
sudo nano /etc/systemd/system/backup.service
```

```ini
[Unit]
Description=Website Backup Service
After=network.target

[Service]
Type=oneshot
ExecStart=/usr/local/bin/backup-website.sh
User=root
StandardOutput=journal
StandardError=journal

[Install]
WantedBy=multi-user.target
```

```bash
# Step 2: Create a timer unit
sudo nano /etc/systemd/system/backup.timer
```

```ini
[Unit]
Description=Daily Website Backup
Requires=backup.service

[Timer]
# Run daily at 3 AM
OnCalendar=daily
OnCalendar=*-*-* 03:00:00

# Run 10 minutes after boot if missed
Persistent=true

# Randomize start time by up to 5 minutes
RandomizedDelaySec=5m

[Install]
WantedBy=timers.target
```

```bash
# Enable and start the timer
sudo systemctl daemon-reload
sudo systemctl enable backup.timer
sudo systemctl start backup.timer

# Check timer status
systemctl status backup.timer
systemctl list-timers

# View timer logs
journalctl -u backup.service
journalctl -u backup.timer
```

#### Advanced Timer Examples

```bash
# Multiple schedule timer
sudo nano /etc/systemd/system/monitor.timer
```

```ini
[Unit]
Description=System Monitoring Timer

[Timer]
# Run every 15 minutes
OnCalendar=*:0/15
# Also run 5 minutes after boot
OnBootSec=5min
# Run immediately if system was off during scheduled time
Persistent=true

[Install]
WantedBy=timers.target
```

```bash
# Relative time timer
sudo nano /etc/systemd/system/cleanup.timer
```

```ini
[Unit]
Description=Cleanup Old Files Timer

[Timer]
# Run 1 hour after boot
OnBootSec=1h
# Then run every 24 hours
OnUnitActiveSec=24h

[Install]
WantedBy=timers.target
```

#### Timer Calendar Syntax

```bash
# Systemd timer calendar events
# Format: DayOfWeek Year-Month-Day Hour:Minute:Second

# Examples:
OnCalendar=minutely                    # Every minute
OnCalendar=hourly                      # Every hour
OnCalendar=daily                       # Every day at midnight
OnCalendar=weekly                      # Every Monday at midnight
OnCalendar=monthly                     # First day of month at midnight
OnCalendar=*-*-* 04:00:00             # Daily at 4 AM
OnCalendar=Mon..Fri 09:00:00          # Weekdays at 9 AM
OnCalendar=Sat,Sun 10:00:00           # Weekends at 10 AM
OnCalendar=*-*-01 00:00:00            # First of every month
OnCalendar=2024-*-* 00:00:00          # Every day in 2024
OnCalendar=*:0/30                     # Every 30 minutes

# Test calendar expression
systemd-analyze calendar "Mon..Fri 09:00:00"
systemd-analyze calendar --iterations=5 "daily"
```

### Shell Scripting Basics

Shell scripts automate complex tasks by combining commands with logic.

#### Script Structure

```bash
#!/bin/bash
# Script: system-maintenance.sh
# Purpose: Perform routine system maintenance
# Author: Admin
# Date: 2024-01-01

# Exit on any error
set -e

# Define variables
LOG_DIR="/var/log/maintenance"
DATE=$(date +%Y%m%d)
RETENTION_DAYS=30

# Create functions
log_message() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_DIR/maintenance-$DATE.log"
}

check_disk_space() {
    local threshold=80
    local usage=$(df / | tail -1 | awk '{print $5}' | sed 's/%//')

    if [ "$usage" -gt "$threshold" ]; then
        log_message "WARNING: Disk usage is ${usage}%"
        return 1
    else
        log_message "INFO: Disk usage is ${usage}%"
        return 0
    fi
}

# Main script
main() {
    # Create log directory
    mkdir -p "$LOG_DIR"

    log_message "Starting system maintenance"

    # Check disk space
    if ! check_disk_space; then
        log_message "Running cleanup due to high disk usage"
        apt-get clean
        journalctl --vacuum-time=7d
    fi

    # Update package index
    log_message "Updating package index"
    apt-get update

    # Remove old logs
    log_message "Removing old logs"
    find "$LOG_DIR" -name "*.log" -mtime +$RETENTION_DAYS -delete

    log_message "Maintenance completed"
}

# Run main function
main "$@"
```

#### Variables and Input

```bash
#!/bin/bash
# Script demonstrating variables and input

# Variable assignment (no spaces around =)
NAME="Ubuntu Server"
VERSION=22.04
IS_PRODUCTION=true

# Command substitution
CURRENT_USER=$(whoami)
TODAY=$(date +%Y-%m-%d)
FILE_COUNT=$(ls -1 | wc -l)

# Arithmetic
COUNT=$((5 + 3))
let "RESULT = 10 * 2"

# Arrays
SERVICES=("nginx" "mysql" "redis" "postgresql")
CONFIGS[0]="/etc/nginx/nginx.conf"
CONFIGS[1]="/etc/mysql/my.cnf"

# Reading user input
echo "Enter server name:"
read -r SERVER_NAME

# Reading with prompt
read -rp "Enter port number: " PORT

# Reading password (hidden)
read -rsp "Enter password: " PASSWORD
echo  # New line after password

# Command line arguments
SCRIPT_NAME=$0
FIRST_ARG=$1
SECOND_ARG=$2
ALL_ARGS=$@
ARG_COUNT=$#

# Using arguments with defaults
BACKUP_DIR=${1:-"/backup"}
DAYS_TO_KEEP=${2:-7}

echo "Backing up to: $BACKUP_DIR"
echo "Keeping backups for: $DAYS_TO_KEEP days"
```

#### Conditionals and Loops

```bash
#!/bin/bash
# Conditionals and loops demonstration

# If statement
if [ -f "/etc/nginx/nginx.conf" ]; then
    echo "Nginx config exists"
elif [ -f "/etc/apache2/apache2.conf" ]; then
    echo "Apache config exists"
else
    echo "No web server config found"
fi

# Numeric comparison
CPU_COUNT=$(nproc)
if [ "$CPU_COUNT" -gt 4 ]; then
    echo "High performance system"
fi

# String comparison
if [ "$USER" = "root" ]; then
    echo "Running as root"
fi

# File tests
if [ -d "/var/www" ]; then         # Directory exists
    echo "Web root exists"
fi

if [ -r "/etc/passwd" ]; then      # File is readable
    echo "Can read passwd file"
fi

if [ -x "/usr/bin/docker" ]; then  # File is executable
    echo "Docker is installed"
fi

# Combined conditions
if [ -f "$FILE" ] && [ -r "$FILE" ]; then
    echo "File exists and is readable"
fi

if [ "$USER" = "root" ] || [ "$UID" -eq 0 ]; then
    echo "Running with root privileges"
fi

# For loop
for service in nginx mysql redis; do
    systemctl status "$service" > /dev/null 2>&1
    if [ $? -eq 0 ]; then
        echo "$service is running"
    else
        echo "$service is not running"
    fi
done

# For loop with array
DIRS=("/var/log" "/tmp" "/var/cache")
for dir in "${DIRS[@]}"; do
    size=$(du -sh "$dir" 2>/dev/null | cut -f1)
    echo "$dir: $size"
done

# For loop with range
for i in {1..5}; do
    echo "Iteration $i"
done

# While loop
counter=0
while [ $counter -lt 10 ]; do
    echo "Counter: $counter"
    ((counter++))
done

# Reading file line by line
while IFS= read -r line; do
    echo "Processing: $line"
done < /etc/hosts

# Until loop
until [ -f "/tmp/ready.flag" ]; do
    echo "Waiting for ready flag..."
    sleep 5
done

# Case statement
read -rp "Enter option (start/stop/restart): " action
case $action in
    start)
        echo "Starting service..."
        systemctl start nginx
        ;;
    stop)
        echo "Stopping service..."
        systemctl stop nginx
        ;;
    restart|reload)
        echo "Restarting service..."
        systemctl restart nginx
        ;;
    *)
        echo "Invalid option"
        exit 1
        ;;
esac
```

### Error Handling in Scripts

Proper error handling makes scripts robust and reliable.

#### Basic Error Handling

```bash
#!/bin/bash
# Error handling demonstration

# Exit on error
set -e

# Exit on undefined variable
set -u

# Exit on pipe failure
set -o pipefail

# Enable debug output (optional)
# set -x

# Custom error handler
error_handler() {
    local line_no=$1
    local exit_code=$2
    echo "Error on line $line_no: Command exited with status $exit_code"
    # Cleanup code here
    exit $exit_code
}

# Set error trap
trap 'error_handler $LINENO $?' ERR

# Function with error checking
safe_copy() {
    local source=$1
    local dest=$2

    if [ ! -f "$source" ]; then
        echo "Error: Source file $source does not exist"
        return 1
    fi

    if ! cp "$source" "$dest"; then
        echo "Error: Failed to copy $source to $dest"
        return 1
    fi

    echo "Successfully copied $source to $dest"
    return 0
}

# Check command success
if ! command -v nginx &> /dev/null; then
    echo "Error: nginx is not installed"
    exit 1
fi

# Try-catch equivalent
{
    # Commands that might fail
    risky_command
} || {
    # Error handling
    echo "Command failed, attempting recovery..."
    recovery_action
}

# Cleanup on exit
cleanup() {
    echo "Cleaning up temporary files..."
    rm -f /tmp/temp_*
    echo "Cleanup completed"
}

trap cleanup EXIT

# Log errors to file
exec 2> >(tee -a /var/log/script_errors.log >&2)

# Main script logic here
echo "Script starting..."
# Your code here
echo "Script completed successfully"
```

#### Advanced Error Handling

```bash
#!/bin/bash
# Advanced error handling with logging

# Configuration
readonly SCRIPT_NAME=$(basename "$0")
readonly LOG_FILE="/var/log/${SCRIPT_NAME%.sh}.log"
readonly ERROR_LOG="/var/log/${SCRIPT_NAME%.sh}_errors.log"

# Color codes for output
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[0;33m'
readonly NC='\033[0m' # No Color

# Logging functions
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*" | tee -a "$LOG_FILE"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $*" | tee -a "$ERROR_LOG" >&2
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $*" | tee -a "$LOG_FILE"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $*" | tee -a "$LOG_FILE"
}

# Validation function
validate_prerequisites() {
    local errors=0

    # Check if running as root
    if [[ $EUID -ne 0 ]]; then
        log_error "This script must be run as root"
        ((errors++))
    fi

    # Check required commands
    local required_commands=("rsync" "tar" "mysqldump")
    for cmd in "${required_commands[@]}"; do
        if ! command -v "$cmd" &> /dev/null; then
            log_error "Required command '$cmd' is not installed"
            ((errors++))
        fi
    done

    # Check required directories
    local required_dirs=("/backup" "/var/www")
    for dir in "${required_dirs[@]}"; do
        if [[ ! -d "$dir" ]]; then
            log_warning "Directory '$dir' does not exist, creating..."
            mkdir -p "$dir" || {
                log_error "Failed to create directory '$dir'"
                ((errors++))
            }
        fi
    done

    return $errors
}

# Retry function
retry_command() {
    local max_attempts=$1
    shift
    local command=("$@")
    local attempt=1

    while [ $attempt -le $max_attempts ]; do
        log "Attempt $attempt of $max_attempts: ${command[*]}"

        if "${command[@]}"; then
            log_success "Command succeeded on attempt $attempt"
            return 0
        fi

        log_warning "Command failed on attempt $attempt"
        ((attempt++))

        if [ $attempt -le $max_attempts ]; then
            log "Waiting 5 seconds before retry..."
            sleep 5
        fi
    done

    log_error "Command failed after $max_attempts attempts"
    return 1
}

# Main execution
main() {
    log "Starting $SCRIPT_NAME"

    # Validate prerequisites
    if ! validate_prerequisites; then
        log_error "Prerequisites validation failed"
        exit 1
    fi

    # Example: Retry a command up to 3 times
    retry_command 3 wget -q https://example.com/file.tar.gz

    log_success "Script completed successfully"
}

# Run main function with error handling
if ! main "$@"; then
    log_error "Script failed"
    exit 1
fi
```

### Log Rotation

Log rotation prevents log files from consuming all disk space.

#### Configuring Logrotate

```bash
# Logrotate configuration location
ls /etc/logrotate.d/

# Main configuration
cat /etc/logrotate.conf

# Create custom logrotate configuration
sudo nano /etc/logrotate.d/myapp
```

```bash
# Logrotate configuration for myapp
/var/log/myapp/*.log {
    # Rotate logs daily
    daily

    # Keep 14 rotated logs
    rotate 14

    # Compress rotated logs
    compress

    # Delay compression until next rotation
    delaycompress

    # Don't rotate if empty
    notifempty

    # Create new log file with permissions
    create 0644 www-data www-data

    # Run commands after rotation
    postrotate
        # Reload application to use new log file
        systemctl reload myapp
    endscript

    # Size-based rotation (rotate when file reaches 100M)
    size 100M

    # Missing log file is ok
    missingok
}

# Multiple log files with shared configuration
/var/log/nginx/*.log
/var/log/nginx/*/*.log {
    weekly
    rotate 52
    compress
    delaycompress
    notifempty
    create 0640 www-data adm
    sharedscripts
    prerotate
        if [ -d /etc/logrotate.d/httpd-prerotate ]; then
            run-parts /etc/logrotate.d/httpd-prerotate
        fi
    endscript
    postrotate
        invoke-rc.d nginx rotate >/dev/null 2>&1 || true
    endscript
}
```

```bash
# Test logrotate configuration
sudo logrotate -d /etc/logrotate.d/myapp  # Debug mode (dry run)

# Force rotation
sudo logrotate -f /etc/logrotate.d/myapp

# Run all logrotate configurations
sudo logrotate -f /etc/logrotate.conf

# View logrotate status
cat /var/lib/logrotate/status
```

### Automated Maintenance

Create comprehensive maintenance scripts for routine tasks.

#### System Maintenance Script

```bash
sudo nano /usr/local/bin/system-maintenance.sh
```

```bash
#!/bin/bash
# Comprehensive system maintenance script

# Configuration
readonly MAINTENANCE_LOG="/var/log/maintenance.log"
readonly ALERT_EMAIL="admin@example.com"
readonly DISK_THRESHOLD=80
readonly MEMORY_THRESHOLD=90
readonly DAYS_TO_KEEP_LOGS=30

# Source common functions
source /usr/local/lib/bash-functions.sh 2>/dev/null || true

# Maintenance tasks
perform_disk_cleanup() {
    log "Starting disk cleanup"

    # Clean package cache
    apt-get clean
    apt-get autoremove -y

    # Clean journal logs
    journalctl --vacuum-time=${DAYS_TO_KEEP_LOGS}d

    # Clean temporary files
    find /tmp -type f -atime +7 -delete 2>/dev/null
    find /var/tmp -type f -atime +7 -delete 2>/dev/null

    # Clean old kernels
    dpkg -l 'linux-*' | sed '/^ii/!d;/'"$(uname -r | sed "s/\(.*\)-\([^0-9]\+\)/\1/")"'/d;s/^[^ ]* [^ ]* \([^ ]*\).*/\1/;/[0-9]/!d' | xargs sudo apt-get -y purge

    log "Disk cleanup completed"
}

check_disk_usage() {
    log "Checking disk usage"

    while IFS= read -r line; do
        usage=$(echo "$line" | awk '{print $5}' | sed 's/%//')
        partition=$(echo "$line" | awk '{print $6}')

        if [ "$usage" -gt "$DISK_THRESHOLD" ]; then
            alert="ALERT: Partition $partition is ${usage}% full"
            log "$alert"
            echo "$alert" | mail -s "Disk Space Alert on $(hostname)" "$ALERT_EMAIL"
        fi
    done < <(df -h | grep -E '^/dev/')
}

check_memory_usage() {
    log "Checking memory usage"

    memory_usage=$(free | grep Mem | awk '{print int($3/$2 * 100)}')

    if [ "$memory_usage" -gt "$MEMORY_THRESHOLD" ]; then
        alert="ALERT: Memory usage is ${memory_usage}%"
        log "$alert"

        # List top memory consumers
        ps aux --sort=-%mem | head -10 >> "$MAINTENANCE_LOG"
    fi
}

update_system() {
    log "Checking for system updates"

    apt-get update

    updates_available=$(apt list --upgradable 2>/dev/null | grep -c upgradable || true)

    if [ "$updates_available" -gt 0 ]; then
        log "Found $updates_available updates available"

        # Install security updates only
        unattended-upgrades -d
    fi
}

check_services() {
    log "Checking critical services"

    services=("nginx" "mysql" "ssh" "cron")

    for service in "${services[@]}"; do
        if systemctl is-active "$service" > /dev/null 2>&1; then
            log "Service $service is running"
        else
            log "WARNING: Service $service is not running"

            # Attempt to restart
            systemctl restart "$service" || {
                echo "CRITICAL: Failed to restart $service on $(hostname)" | \
                    mail -s "Service Alert" "$ALERT_EMAIL"
            }
        fi
    done
}

backup_configs() {
    log "Backing up system configurations"

    backup_dir="/backup/configs/$(date +%Y%m%d)"
    mkdir -p "$backup_dir"

    # Backup important configurations
    configs=(
        "/etc/nginx"
        "/etc/mysql"
        "/etc/ssh"
        "/etc/systemd/system"
        "/etc/cron.d"
        "/etc/logrotate.d"
    )

    for config in "${configs[@]}"; do
        if [ -e "$config" ]; then
            tar -czf "$backup_dir/$(basename $config).tar.gz" "$config" 2>/dev/null
        fi
    done

    # Keep only last 7 days of backups
    find /backup/configs -maxdepth 1 -type d -mtime +7 -exec rm -rf {} \;

    log "Configuration backup completed"
}

# Main execution
main() {
    log "=== Starting system maintenance ==="

    perform_disk_cleanup
    check_disk_usage
    check_memory_usage
    update_system
    check_services
    backup_configs

    log "=== System maintenance completed ==="
}

# Logging function
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*" >> "$MAINTENANCE_LOG"
}

# Run main function
main "$@"
```

```bash
# Schedule maintenance script
sudo crontab -e
# Add: 0 2 * * * /usr/local/bin/system-maintenance.sh
```

### Monitoring Scripts

Create scripts to monitor system health and performance.

#### Resource Monitoring Script

```bash
sudo nano /usr/local/bin/monitor-resources.sh
```

```bash
#!/bin/bash
# System resource monitoring script

# Thresholds
CPU_THRESHOLD=80
MEMORY_THRESHOLD=85
DISK_THRESHOLD=90
LOAD_THRESHOLD=4

# Check CPU usage
check_cpu() {
    cpu_usage=$(top -bn1 | grep "Cpu(s)" | awk '{print $2}' | cut -d'%' -f1)
    cpu_int=${cpu_usage%.*}

    if [ "$cpu_int" -gt "$CPU_THRESHOLD" ]; then
        echo "WARNING: CPU usage is ${cpu_usage}%"
        return 1
    fi
    return 0
}

# Check memory usage
check_memory() {
    memory_usage=$(free | grep Mem | awk '{printf "%.0f", $3/$2 * 100}')

    if [ "$memory_usage" -gt "$MEMORY_THRESHOLD" ]; then
        echo "WARNING: Memory usage is ${memory_usage}%"
        free -h
        return 1
    fi
    return 0
}

# Check disk usage
check_disk() {
    local warnings=0

    while IFS= read -r line; do
        usage=$(echo "$line" | awk '{print $5}' | sed 's/%//')
        partition=$(echo "$line" | awk '{print $6}')

        if [ "$usage" -gt "$DISK_THRESHOLD" ]; then
            echo "WARNING: Partition $partition is ${usage}% full"
            ((warnings++))
        fi
    done < <(df -h | grep -E '^/dev/')

    return $warnings
}

# Check load average
check_load() {
    cores=$(nproc)
    load_1min=$(uptime | awk '{print $10}' | cut -d',' -f1)

    if (( $(echo "$load_1min > $LOAD_THRESHOLD" | bc -l) )); then
        echo "WARNING: Load average is $load_1min (${cores} cores)"
        return 1
    fi
    return 0
}

# Check network connectivity
check_network() {
    if ! ping -c 1 -W 2 8.8.8.8 > /dev/null 2>&1; then
        echo "WARNING: No internet connectivity"
        return 1
    fi
    return 0
}

# Main monitoring
main() {
    echo "System Resource Monitor - $(date)"
    echo "================================"

    status=0

    check_cpu || ((status++))
    check_memory || ((status++))
    check_disk || ((status++))
    check_load || ((status++))
    check_network || ((status++))

    if [ $status -eq 0 ]; then
        echo "All systems operating normally"
    else
        echo "Found $status warnings"
    fi

    exit $status
}

main "$@"
```

---

## Chapter 15: Configuration Management

### Infrastructure as Code Concepts

Infrastructure as Code (IaC) treats infrastructure configuration as software code, enabling version control, testing, and automation.

#### Key Principles

1. **Declarative Configuration**: Describe the desired state, not the steps
2. **Idempotency**: Running the same configuration multiple times produces the same result
3. **Version Control**: Track all configuration changes
4. **Automation**: Eliminate manual configuration

### Ansible Basics for Single Servers

While Ansible is typically used for multiple servers, it's excellent for managing single servers too.

#### Installing Ansible

```bash
# Install Ansible
sudo apt update
sudo apt install ansible -y

# Verify installation
ansible --version

# Install additional collections
ansible-galaxy collection install community.general
```

#### Local Playbooks

```bash
# Create Ansible directory structure
mkdir -p ~/ansible/{playbooks,roles,inventory,group_vars,host_vars}

# Create local inventory
nano ~/ansible/inventory/local
```

```ini
[local]
localhost ansible_connection=local
```

```bash
# Create a simple playbook
nano ~/ansible/playbooks/setup-server.yml
```

```yaml
---
- name: Configure Ubuntu Server
  hosts: localhost
  connection: local
  become: yes

  vars:
    packages_to_install:
      - nginx
      - mysql-server
      - redis-server
      - python3-pip
      - git
      - htop
      - net-tools

    services_to_enable:
      - nginx
      - mysql
      - redis

  tasks:
    - name: Update apt cache
      apt:
        update_cache: yes
        cache_valid_time: 3600

    - name: Install required packages
      apt:
        name: "{{ packages_to_install }}"
        state: present

    - name: Ensure services are started and enabled
      service:
        name: "{{ item }}"
        state: started
        enabled: yes
      loop: "{{ services_to_enable }}"

    - name: Configure UFW firewall
      ufw:
        rule: allow
        port: "{{ item }}"
        proto: tcp
      loop:
        - '22'
        - '80'
        - '443'

    - name: Enable UFW
      ufw:
        state: enabled
        policy: deny
        direction: incoming
```

```bash
# Run the playbook
ansible-playbook -i ~/ansible/inventory/local ~/ansible/playbooks/setup-server.yml
```

#### Managing Configuration Files

```bash
# Create template directory
mkdir -p ~/ansible/templates

# Create nginx template
nano ~/ansible/templates/nginx-site.conf.j2
```

```jinja2
server {
    listen 80;
    server_name {{ domain_name }};
    root {{ document_root }};
    index index.html index.php;

    location / {
        try_files $uri $uri/ =404;
    }

    {% if enable_php %}
    location ~ \.php$ {
        include snippets/fastcgi-php.conf;
        fastcgi_pass unix:/var/run/php/php{{ php_version }}-fpm.sock;
    }
    {% endif %}

    {% if enable_ssl %}
    listen 443 ssl;
    ssl_certificate /etc/letsencrypt/live/{{ domain_name }}/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/{{ domain_name }}/privkey.pem;
    {% endif %}
}
```

```bash
# Playbook using template
nano ~/ansible/playbooks/configure-nginx.yml
```

```yaml
---
- name: Configure Nginx Sites
  hosts: localhost
  connection: local
  become: yes

  vars:
    sites:
      - domain_name: example.com
        document_root: /var/www/example
        enable_php: true
        php_version: "8.1"
        enable_ssl: false

      - domain_name: app.example.com
        document_root: /var/www/app
        enable_php: false
        enable_ssl: true

  tasks:
    - name: Create document roots
      file:
        path: "{{ item.document_root }}"
        state: directory
        owner: www-data
        group: www-data
        mode: '0755'
      loop: "{{ sites }}"

    - name: Deploy nginx configurations
      template:
        src: nginx-site.conf.j2
        dest: "/etc/nginx/sites-available/{{ item.domain_name }}"
        owner: root
        group: root
        mode: '0644'
      loop: "{{ sites }}"
      notify: reload nginx

    - name: Enable sites
      file:
        src: "/etc/nginx/sites-available/{{ item.domain_name }}"
        dest: "/etc/nginx/sites-enabled/{{ item.domain_name }}"
        state: link
      loop: "{{ sites }}"
      notify: reload nginx

  handlers:
    - name: reload nginx
      service:
        name: nginx
        state: reloaded
```

#### System Hardening Playbook

```bash
nano ~/ansible/playbooks/security-hardening.yml
```

```yaml
---
- name: Security Hardening Playbook
  hosts: localhost
  connection: local
  become: yes

  tasks:
    - name: Ensure SSH key-only authentication
      lineinfile:
        path: /etc/ssh/sshd_config
        regexp: "{{ item.regexp }}"
        line: "{{ item.line }}"
        state: present
      loop:
        - { regexp: '^#?PasswordAuthentication', line: 'PasswordAuthentication no' }
        - { regexp: '^#?PermitRootLogin', line: 'PermitRootLogin prohibit-password' }
        - { regexp: '^#?PubkeyAuthentication', line: 'PubkeyAuthentication yes' }
      notify: restart sshd

    - name: Configure sysctl for security
      sysctl:
        name: "{{ item.key }}"
        value: "{{ item.value }}"
        state: present
        reload: yes
      loop:
        - { key: 'net.ipv4.tcp_syncookies', value: '1' }
        - { key: 'net.ipv4.ip_forward', value: '0' }
        - { key: 'net.ipv6.conf.all.forwarding', value: '0' }
        - { key: 'net.ipv4.conf.all.send_redirects', value: '0' }
        - { key: 'net.ipv4.conf.all.accept_source_route', value: '0' }

    - name: Install security tools
      apt:
        name:
          - fail2ban
          - aide
          - rkhunter
          - lynis
        state: present

    - name: Configure fail2ban
      copy:
        dest: /etc/fail2ban/jail.local
        content: |
          [DEFAULT]
          bantime = 3600
          findtime = 600
          maxretry = 5

          [sshd]
          enabled = true
          port = ssh
          logpath = /var/log/auth.log
      notify: restart fail2ban

    - name: Set secure permissions on sensitive files
      file:
        path: "{{ item.path }}"
        mode: "{{ item.mode }}"
      loop:
        - { path: '/etc/passwd', mode: '0644' }
        - { path: '/etc/shadow', mode: '0640' }
        - { path: '/etc/gshadow', mode: '0640' }
        - { path: '/etc/group', mode: '0644' }

  handlers:
    - name: restart sshd
      service:
        name: sshd
        state: restarted

    - name: restart fail2ban
      service:
        name: fail2ban
        state: restarted
```

### Cloud-init Deep Dive

Cloud-init automatically configures cloud instances during boot.

#### Understanding Cloud-init

```bash
# Check cloud-init status
cloud-init status

# View cloud-init configuration
cat /etc/cloud/cloud.cfg

# View user data
cat /var/lib/cloud/instance/user-data.txt

# View cloud-init logs
sudo cat /var/log/cloud-init.log
sudo cat /var/log/cloud-init-output.log

# Re-run cloud-init
sudo cloud-init clean
sudo cloud-init init
```

#### Cloud-init Configuration

```yaml
# Example cloud-init user data
#cloud-config

# Set hostname
hostname: webserver
fqdn: webserver.example.com

# Create users
users:
  - name: admin
    groups: sudo
    shell: /bin/bash
    sudo: ALL=(ALL) NOPASSWD:ALL
    ssh_authorized_keys:
      - ssh-rsa AAAAB3NzaC1yc2EA... admin@example.com

# Update and upgrade packages
package_update: true
package_upgrade: true

# Install packages
packages:
  - nginx
  - mysql-server
  - php-fpm
  - git
  - htop

# Configure files
write_files:
  - path: /etc/nginx/sites-available/default
    content: |
      server {
          listen 80;
          server_name _;
          root /var/www/html;
          index index.php index.html;

          location ~ \.php$ {
              include snippets/fastcgi-php.conf;
              fastcgi_pass unix:/var/run/php/php8.1-fpm.sock;
          }
      }

  - path: /var/www/html/index.html
    content: |
      <!DOCTYPE html>
      <html>
      <head><title>Welcome</title></head>
      <body><h1>Server configured with cloud-init</h1></body>
      </html>

# Run commands
runcmd:
  - systemctl enable nginx
  - systemctl start nginx
  - ufw allow 'Nginx Full'
  - ufw allow 'OpenSSH'
  - ufw --force enable

# Configure swap
swap:
  filename: /swapfile
  size: 2G

# Set timezone
timezone: America/New_York

# Reboot after cloud-init completes
power_state:
  mode: reboot
  message: Rebooting after cloud-init completion
  timeout: 30
  condition: True
```

#### Advanced Cloud-init Examples

```yaml
#cloud-config
# Advanced cloud-init configuration

# Configure apt
apt:
  sources:
    docker:
      source: "deb [arch=amd64] https://download.docker.com/linux/ubuntu $RELEASE stable"
      keyid: 9DC858229FC7DD38854AE2D88D81803C0EBFCD88

# Mount additional volumes
mounts:
  - [ /dev/xvdb, /data, ext4, "defaults,nofail", "0", "2" ]

# Configure disk
disk_setup:
  /dev/xvdb:
    table_type: gpt
    layout: [100]
    overwrite: false

fs_setup:
  - device: /dev/xvdb
    filesystem: ext4
    label: data
    partition: 1

# Set up periodic tasks
cron:
  - name: backup
    user: root
    minute: 0
    hour: 3
    job: /usr/local/bin/backup.sh

# Configure bootcmd (runs on every boot)
bootcmd:
  - echo "Starting system..." >> /var/log/boot.log
  - date >> /var/log/boot.log

# Configure SSH
ssh_pwauth: false
disable_root: true
ssh_deletekeys: true
ssh_genkeytypes: ['rsa', 'ecdsa', 'ed25519']

# Install snaps
snap:
  commands:
    - snap install docker
    - snap install lxd

# Chef configuration (if using Chef)
chef:
  install_type: packages
  server_url: "https://chef.example.com"
  validation_name: "validator"
  validation_key: |
    -----BEGIN RSA PRIVATE KEY-----
    Your key here
    -----END RSA PRIVATE KEY-----

# Final message
final_message: "The system is ready after $UPTIME seconds"
```

### Template Management

Templates allow dynamic configuration generation.

#### Using Jinja2 Templates

```bash
# Install Jinja2 CLI
sudo apt install python3-jinja2-cli

# Create a template
nano /etc/templates/config.j2
```

```jinja2
# Application Configuration
# Generated on {{ timestamp }}

[application]
name = {{ app_name }}
version = {{ app_version }}
environment = {{ environment }}

[database]
host = {{ db_host }}
port = {{ db_port }}
name = {{ db_name }}
user = {{ db_user }}
{% if db_password %}
password = {{ db_password }}
{% endif %}

[features]
{% for feature, enabled in features.items() %}
{{ feature }} = {{ enabled }}
{% endfor %}

[servers]
{% for server in servers %}
server{{ loop.index }} = {{ server.name }}:{{ server.port }}
{% endfor %}
```

```bash
# Create variable file
nano /etc/templates/vars.json
```

```json
{
    "timestamp": "2024-01-01 10:00:00",
    "app_name": "MyApp",
    "app_version": "1.0.0",
    "environment": "production",
    "db_host": "localhost",
    "db_port": 3306,
    "db_name": "myapp_db",
    "db_user": "myapp",
    "db_password": "secret123",
    "features": {
        "cache": true,
        "debug": false,
        "ssl": true
    },
    "servers": [
        {"name": "web1", "port": 8080},
        {"name": "web2", "port": 8081}
    ]
}
```

```bash
# Generate configuration from template
jinja2 /etc/templates/config.j2 /etc/templates/vars.json > /etc/myapp/config.ini

# Using in a script
#!/bin/bash
python3 -c "
import jinja2
import json

with open('/etc/templates/vars.json') as f:
    vars = json.load(f)

with open('/etc/templates/config.j2') as f:
    template = jinja2.Template(f.read())

print(template.render(**vars))
" > /etc/myapp/config.ini
```

### Configuration Drift

Configuration drift occurs when systems deviate from their intended configuration.

#### Detecting Configuration Drift

```bash
# Create drift detection script
sudo nano /usr/local/bin/detect-drift.sh
```

```bash
#!/bin/bash
# Configuration drift detection

BASELINE_DIR="/etc/baseline"
REPORT_FILE="/var/log/drift-report.log"
ALERT_EMAIL="admin@example.com"

# Create baseline if it doesn't exist
create_baseline() {
    echo "Creating configuration baseline..."
    mkdir -p "$BASELINE_DIR"

    # Save package list
    dpkg -l > "$BASELINE_DIR/packages.txt"

    # Save service states
    systemctl list-unit-files --state=enabled > "$BASELINE_DIR/services.txt"

    # Save configuration checksums
    find /etc -type f -name "*.conf" -o -name "*.cfg" 2>/dev/null | \
        xargs md5sum > "$BASELINE_DIR/configs.md5"

    # Save user list
    getent passwd > "$BASELINE_DIR/users.txt"

    # Save group list
    getent group > "$BASELINE_DIR/groups.txt"

    # Save cron jobs
    for user in $(cut -f1 -d: /etc/passwd); do
        echo "=== Cron for $user ===" >> "$BASELINE_DIR/cron.txt"
        crontab -l -u "$user" 2>/dev/null >> "$BASELINE_DIR/cron.txt"
    done

    echo "Baseline created at $(date)"
}

# Check for drift
check_drift() {
    echo "Checking for configuration drift..."
    drift_found=0

    # Check packages
    dpkg -l > /tmp/current_packages.txt
    if ! diff -q "$BASELINE_DIR/packages.txt" /tmp/current_packages.txt > /dev/null; then
        echo "DRIFT: Package changes detected" | tee -a "$REPORT_FILE"
        diff "$BASELINE_DIR/packages.txt" /tmp/current_packages.txt >> "$REPORT_FILE"
        drift_found=1
    fi

    # Check services
    systemctl list-unit-files --state=enabled > /tmp/current_services.txt
    if ! diff -q "$BASELINE_DIR/services.txt" /tmp/current_services.txt > /dev/null; then
        echo "DRIFT: Service changes detected" | tee -a "$REPORT_FILE"
        diff "$BASELINE_DIR/services.txt" /tmp/current_services.txt >> "$REPORT_FILE"
        drift_found=1
    fi

    # Check configuration files
    find /etc -type f -name "*.conf" -o -name "*.cfg" 2>/dev/null | \
        xargs md5sum > /tmp/current_configs.md5

    while IFS= read -r line; do
        file=$(echo "$line" | awk '{print $2}')
        baseline_sum=$(echo "$line" | awk '{print $1}')
        current_sum=$(grep -E "\\s$file$" /tmp/current_configs.md5 | awk '{print $1}')

        if [ "$baseline_sum" != "$current_sum" ]; then
            echo "DRIFT: Configuration changed: $file" | tee -a "$REPORT_FILE"
            drift_found=1
        fi
    done < "$BASELINE_DIR/configs.md5"

    return $drift_found
}

# Main execution
main() {
    echo "=== Drift Detection Report - $(date) ===" | tee "$REPORT_FILE"

    if [ ! -d "$BASELINE_DIR" ]; then
        create_baseline
        echo "Baseline created. Run again to check for drift."
        exit 0
    fi

    if check_drift; then
        echo "No configuration drift detected"
    else
        echo "Configuration drift detected! Check $REPORT_FILE for details"

        # Send alert
        mail -s "Configuration Drift Detected on $(hostname)" "$ALERT_EMAIL" < "$REPORT_FILE"
    fi
}

# Command line options
case "$1" in
    baseline)
        create_baseline
        ;;
    check)
        main
        ;;
    *)
        echo "Usage: $0 {baseline|check}"
        exit 1
        ;;
esac
```

### Change Tracking

Track all system changes for audit and rollback purposes.

#### Git-based Change Tracking

```bash
# Initialize git repository for /etc
sudo apt install git
cd /etc
sudo git init

# Configure git
sudo git config user.name "System Admin"
sudo git config user.email "admin@example.com"

# Create .gitignore
sudo nano /etc/.gitignore
```

```gitignore
# Ignore sensitive and temporary files
shadow
shadow-
gshadow
gshadow-
*.swp
*.tmp
*.cache
*.log
*.pid
*.lock
machine-id
```

```bash
# Initial commit
sudo git add .
sudo git commit -m "Initial system configuration"

# Create change tracking script
sudo nano /usr/local/bin/track-changes.sh
```

```bash
#!/bin/bash
# Track configuration changes with git

CONFIG_DIR="/etc"
LOG_FILE="/var/log/config-changes.log"

cd "$CONFIG_DIR" || exit 1

# Check for changes
if [[ -n $(git status -s 2>/dev/null) ]]; then
    echo "[$(date)] Configuration changes detected:" | tee -a "$LOG_FILE"

    # Show what changed
    git status -s | tee -a "$LOG_FILE"

    # Show detailed changes
    git diff | head -100 >> "$LOG_FILE"

    # Commit changes
    git add -A
    git commit -m "Auto-commit: $(date '+%Y-%m-%d %H:%M:%S')" \
        -m "$(git status -s)" >> "$LOG_FILE" 2>&1

    echo "Changes committed to git repository" | tee -a "$LOG_FILE"
else
    echo "[$(date)] No configuration changes detected" >> "$LOG_FILE"
fi
```

```bash
# Schedule change tracking
sudo crontab -e
# Add: */30 * * * * /usr/local/bin/track-changes.sh

# View change history
cd /etc
sudo git log --oneline
sudo git show HEAD
sudo git diff HEAD~1
```

---

## Practice Exercises

### Exercise 1: Automation Setup
1. Create a cron job that backs up a directory daily
2. Convert the same task to a systemd timer
3. Compare the two methods and document pros/cons
4. Set up log rotation for your backup logs
5. Create email notifications for backup status

### Exercise 2: Shell Scripting
1. Write a script that monitors disk usage and sends alerts
2. Create a deployment script with zero-downtime deployment
3. Implement proper error handling and logging
4. Add command-line argument parsing
5. Create a test suite for your scripts

### Exercise 3: Ansible Configuration
1. Install Ansible and create a local inventory
2. Write a playbook to configure a web server
3. Use templates to manage configuration files
4. Create a role for common server setup
5. Implement idempotent configuration management

### Exercise 4: Drift Detection
1. Create a configuration baseline
2. Implement drift detection for packages and configs
3. Set up automated alerts for drift
4. Create a rollback mechanism
5. Document your drift management process

---

## Quick Reference

### Cron Syntax
```bash
# Cron fields
* * * * * command
│ │ │ │ │
│ │ │ │ └─ Day of week (0-7, Sun=0 or 7)
│ │ │ └─── Month (1-12)
│ │ └───── Day of month (1-31)
│ └─────── Hour (0-23)
└───────── Minute (0-59)

# Special strings
@reboot    # Run at startup
@daily     # Run daily at midnight
@weekly    # Run weekly on Sunday
@monthly   # Run monthly on the 1st
@yearly    # Run yearly on Jan 1st
```

### Systemd Timer Commands
```bash
systemctl list-timers              # List all timers
systemctl status timer.timer       # Check timer status
systemctl start timer.timer        # Start timer
systemctl enable timer.timer       # Enable on boot
journalctl -u timer.service        # View logs
systemd-analyze calendar "daily"   # Test calendar expression
```

### Ansible Commands
```bash
ansible-playbook playbook.yml     # Run playbook
ansible -m ping all              # Test connectivity
ansible -m setup localhost       # Gather facts
ansible-vault encrypt file.yml   # Encrypt sensitive data
ansible-galaxy init role_name    # Create role structure
```

### Shell Script Testing
```bash
bash -n script.sh                # Syntax check
bash -x script.sh                # Debug mode
shellcheck script.sh             # Static analysis
set -e                          # Exit on error
set -u                          # Exit on undefined variable
set -o pipefail                 # Pipe failure detection
```

---

## Additional Resources

### Documentation
- [Cron Manual](https://man7.org/linux/man-pages/man5/crontab.5.html)
- [Systemd Timer Documentation](https://www.freedesktop.org/software/systemd/man/systemd.timer.html)
- [Bash Scripting Guide](https://www.gnu.org/software/bash/manual/bash.html)
- [Ansible Best Practices](https://docs.ansible.com/ansible/latest/user_guide/playbooks_best_practices.html)

### Tools
- [ShellCheck](https://www.shellcheck.net/) - Shell script analysis
- [Ansible Lint](https://ansible-lint.readthedocs.io/) - Ansible playbook linting
- [Cloud-init Examples](https://cloudinit.readthedocs.io/en/latest/topics/examples.html)

### Learning Resources
- [Advanced Bash Scripting Guide](https://tldp.org/LDP/abs/html/)
- [Ansible for DevOps](https://www.ansiblefordevops.com/)
- [12 Factor App](https://12factor.net/) - Configuration best practices

### Next Steps
After completing this section, you should:
- Understand various automation methods
- Be able to write robust shell scripts
- Know how to use Ansible for configuration management
- Understand configuration drift and change tracking

Continue to Part 7: Monitoring and Performance to learn about system monitoring and optimization.