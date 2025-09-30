# Part 6: Automation and Configuration Management

## Chapter 14: Task Automation

### Understanding Automation in Rocky Linux

#### Why Automate?

Think of automation like setting up dominoes - you set them up once, then with one push, everything happens automatically:
- **Cron** = Traditional scheduler (like an alarm clock)
- **Systemd timers** = Modern scheduler (smart alarm with dependencies)
- **Shell scripts** = Recipe cards (step-by-step instructions)
- **anacron** = Catch-up scheduler (runs missed jobs)

Automation saves time, reduces errors, and ensures consistency!

```bash
# Quick automation check - what's already automated?

# See cron jobs:
crontab -l
# no crontab for user

sudo crontab -l
# # Rocky Linux system crontab
# 0 3 * * * /usr/bin/dnf-automatic /etc/dnf/automatic.conf --timer

# See systemd timers:
systemctl list-timers
# NEXT                         LEFT       LAST                         PASSED      UNIT                         ACTIVATES
# Tue 2023-12-12 11:00:00 EST  47min left Tue 2023-12-12 10:00:00 EST  12min ago   dnf-makecache.timer          dnf-makecache.service
# Tue 2023-12-12 15:47:32 EST  5h 34min   Mon 2023-12-11 15:47:32 EST  18h ago     systemd-tmpfiles-clean.timer systemd-tmpfiles-clean.service
# Wed 2023-12-13 00:00:00 EST  13h left   Tue 2023-12-12 00:00:00 EST  10h ago     logrotate.timer              logrotate.service

# See anacron jobs:
cat /etc/anacrontab
# /etc/anacrontab: configuration file for anacron
# period  delay  job-id  command
1         5      cron.daily    nice run-parts /etc/cron.daily
7         25     cron.weekly   nice run-parts /etc/cron.weekly
@monthly  45     cron.monthly  nice run-parts /etc/cron.monthly
```

### Cron Job Management

#### Understanding Cron

```bash
# Cron runs commands on a schedule using this format:
# ┌───────────── minute (0-59)
# │ ┌───────────── hour (0-23)
# │ │ ┌───────────── day of month (1-31)
# │ │ │ ┌───────────── month (1-12)
# │ │ │ │ ┌───────────── day of week (0-7, 0 and 7 are Sunday)
# │ │ │ │ │
# * * * * *  command to execute

# Examples:
# 0 3 * * *     = Every day at 3:00 AM
# */5 * * * *   = Every 5 minutes
# 0 */2 * * *   = Every 2 hours
# 0 9-17 * * *  = Every hour from 9 AM to 5 PM
# 0 2 * * 1     = Every Monday at 2 AM
# 0 0 1 * *     = First day of every month at midnight
# 0 0 1 1 *     = January 1st at midnight

# Special shortcuts:
# @reboot       = Run at startup
# @daily        = Run daily at midnight (same as 0 0 * * *)
# @weekly       = Run weekly on Sunday at midnight
# @monthly      = Run monthly on the 1st at midnight
# @yearly       = Run yearly on January 1st at midnight
# @hourly       = Run every hour
```

#### Managing Cron Jobs

```bash
# Edit your personal crontab:
crontab -e
# Opens in your default editor (usually vi)

# Add a job that backs up your home directory:
# Daily backup at 2 AM
0 2 * * * tar czf /backup/home-$(date +\%Y\%m\%d).tar.gz $HOME

# Note: In crontab, % must be escaped as \%

# List your cron jobs:
crontab -l

# Remove all your cron jobs:
crontab -r  # Careful! No confirmation!

# Edit another user's crontab (as root):
sudo crontab -u john -e

# System-wide cron jobs:
ls -la /etc/cron.*
# /etc/cron.d/       <- Package cron jobs
# /etc/cron.daily/   <- Daily scripts
# /etc/cron.hourly/  <- Hourly scripts
# /etc/cron.monthly/ <- Monthly scripts
# /etc/cron.weekly/  <- Weekly scripts

# System crontab (different format - includes user):
cat /etc/crontab
# SHELL=/bin/bash
# PATH=/sbin:/bin:/usr/sbin:/usr/bin
# MAILTO=root
#
# # For details see man 4 crontabs
#
# # Example of job definition:
# # .---------------- minute (0 - 59)
# # |  .------------- hour (0 - 23)
# # |  |  .---------- day of month (1 - 31)
# # |  |  |  .------- month (1 - 12) OR jan,feb,mar,apr ...
# # |  |  |  |  .---- day of week (0 - 6) (Sunday=0 or 7) OR sun,mon,tue,wed,thu,fri,sat
# # |  |  |  |  |
# # *  *  *  *  * user-name  command to be executed

# Add system-wide job:
sudo nano /etc/cron.d/backup
# Run backup script as root every night at 3 AM
0 3 * * * root /usr/local/bin/system-backup.sh

# Make sure permissions are correct:
sudo chmod 644 /etc/cron.d/backup
```

#### Cron Best Practices

```bash
# 1. ALWAYS USE FULL PATHS
# Cron has minimal PATH variable
# Bad:  backup.sh
# Good: /usr/local/bin/backup.sh

# 2. REDIRECT OUTPUT
# Cron emails output to user (annoying if frequent)
# Discard output:
0 * * * * /path/to/script.sh > /dev/null 2>&1

# Log output:
0 * * * * /path/to/script.sh >> /var/log/myscript.log 2>&1

# 3. SET ENVIRONMENT VARIABLES
# Add to top of crontab:
SHELL=/bin/bash
PATH=/usr/local/bin:/usr/bin:/bin
MAILTO=admin@example.com
HOME=/home/user

# 4. TEST YOUR COMMANDS
# Run manually first:
/usr/local/bin/backup.sh

# Test cron environment:
* * * * * env > /tmp/cron-env.txt
# Wait 1 minute, then check /tmp/cron-env.txt

# 5. USE LOCKING TO PREVENT OVERLAPS
# In your script:
#!/bin/bash
LOCKFILE=/var/lock/myscript.lock
if [ -f $LOCKFILE ]; then
    echo "Script already running"
    exit 1
fi
touch $LOCKFILE
trap "rm -f $LOCKFILE" EXIT

# Your script here

# 6. LOG EVERYTHING
#!/bin/bash
LOG=/var/log/myscript.log
echo "$(date): Starting backup" >> $LOG
# ... do work ...
echo "$(date): Backup completed" >> $LOG
```

### Systemd Timers and Units

#### Creating Systemd Timers

Systemd timers are more powerful than cron - they can depend on other services, handle missed runs, and have better logging.

```bash
# Example: Create a backup timer

# Step 1: Create the service unit
sudo nano /etc/systemd/system/backup.service

[Unit]
Description=System Backup Service
After=network.target

[Service]
Type=oneshot
ExecStart=/usr/local/bin/backup.sh
StandardOutput=journal
StandardError=journal
User=root

# Type=oneshot means it runs and exits (not a daemon)

# Step 2: Create the timer unit
sudo nano /etc/systemd/system/backup.timer

[Unit]
Description=Daily Backup Timer
Requires=backup.service

[Timer]
OnCalendar=daily
AccuracySec=1h
Persistent=true

[Install]
WantedBy=timers.target

# Understanding timer options:
# OnCalendar=daily         <- When to run
# AccuracySec=1h          <- Random delay up to 1 hour (spread load)
# Persistent=true         <- Run if missed (machine was off)

# Step 3: Create the backup script
sudo nano /usr/local/bin/backup.sh

#!/bin/bash
set -e  # Exit on error

BACKUP_DIR="/backup"
DATE=$(date +%Y%m%d_%H%M%S)
HOSTNAME=$(hostname -s)

echo "Starting backup at $(date)"

# Create backup directory
mkdir -p "$BACKUP_DIR"

# Backup system configs
tar czf "$BACKUP_DIR/etc-$HOSTNAME-$DATE.tar.gz" /etc/ 2>/dev/null

# Backup home directories
tar czf "$BACKUP_DIR/home-$HOSTNAME-$DATE.tar.gz" /home/ 2>/dev/null

# Remove backups older than 7 days
find "$BACKUP_DIR" -name "*.tar.gz" -mtime +7 -delete

echo "Backup completed at $(date)"

sudo chmod +x /usr/local/bin/backup.sh

# Step 4: Enable and start the timer
sudo systemctl daemon-reload
sudo systemctl enable backup.timer
sudo systemctl start backup.timer

# Check timer status:
systemctl status backup.timer
systemctl list-timers backup.timer

# See when it will run next:
systemctl list-timers
# NEXT                        LEFT     LAST  PASSED  UNIT         ACTIVATES
# Wed 2023-12-13 00:00:00 EST 13h left n/a   n/a     backup.timer backup.service

# Manually trigger the service:
sudo systemctl start backup.service

# View logs:
journalctl -u backup.service
```

#### Advanced Timer Configurations

```bash
# Different timer triggers:

# 1. CALENDAR EVENTS (like cron)
OnCalendar=*-*-* 02:00:00           # Daily at 2 AM
OnCalendar=Mon *-*-* 03:00:00       # Mondays at 3 AM
OnCalendar=*-*-01 00:00:00          # First of month
OnCalendar=quarterly                 # Jan 1, Apr 1, Jul 1, Oct 1
OnCalendar=*:0/15                    # Every 15 minutes
OnCalendar=Mon..Fri *-*-* 09:00:00  # Weekdays at 9 AM

# 2. RELATIVE TO ACTIVATION
OnActiveSec=5min                     # 5 minutes after timer activated
OnBootSec=10min                      # 10 minutes after boot
OnStartupSec=1h                      # 1 hour after systemd started
OnUnitActiveSec=1d                   # 1 day after service last ran

# 3. COMBINED EXAMPLE
sudo nano /etc/systemd/system/maintenance.timer

[Unit]
Description=Weekly Maintenance
Requires=maintenance.service

[Timer]
# Run every Sunday at 3 AM
OnCalendar=Sun *-*-* 03:00:00
# But also run 10 minutes after boot if missed
OnBootSec=10min
# Catch up if we missed a run
Persistent=true
# Don't run exactly at 3 AM (randomize within 30 min)
RandomizedDelaySec=30min

[Install]
WantedBy=timers.target
```

### Shell Scripting for Rocky Linux

#### Writing Robust Shell Scripts

```bash
# TEMPLATE FOR PRODUCTION SCRIPTS

#!/bin/bash
#
# Script: system-maintenance.sh
# Purpose: Perform system maintenance tasks
# Author: Admin Team
# Date: 2023-12-12
#

# Exit on error, undefined variable, or pipe failure
set -euo pipefail

# Enable debugging (comment out in production)
# set -x

# =====================
# CONFIGURATION
# =====================

readonly SCRIPT_NAME=$(basename "$0")
readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly LOG_DIR="/var/log/maintenance"
readonly LOG_FILE="${LOG_DIR}/${SCRIPT_NAME%.sh}.log"
readonly LOCK_FILE="/var/lock/${SCRIPT_NAME%.sh}.lock"
readonly CONFIG_FILE="/etc/maintenance/config.conf"

# =====================
# FUNCTIONS
# =====================

# Logging function
log() {
    local level="$1"
    shift
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] [${level}] $*" | tee -a "$LOG_FILE"
}

# Error handler
error_exit() {
    log "ERROR" "$1"
    exit "${2:-1}"
}

# Cleanup function
cleanup() {
    log "INFO" "Cleaning up..."
    rm -f "$LOCK_FILE"
}

# Check if script is already running
check_lock() {
    if [ -f "$LOCK_FILE" ]; then
        local pid=$(cat "$LOCK_FILE")
        if ps -p "$pid" > /dev/null 2>&1; then
            error_exit "Script already running with PID $pid" 2
        else
            log "WARN" "Removing stale lock file"
            rm -f "$LOCK_FILE"
        fi
    fi
    echo $$ > "$LOCK_FILE"
}

# Load configuration
load_config() {
    if [ -f "$CONFIG_FILE" ]; then
        # shellcheck source=/dev/null
        source "$CONFIG_FILE"
        log "INFO" "Configuration loaded from $CONFIG_FILE"
    else
        log "WARN" "Configuration file not found: $CONFIG_FILE"
    fi
}

# =====================
# MAIN
# =====================

main() {
    # Set up error handling
    trap cleanup EXIT
    trap 'error_exit "Script interrupted" 130' INT TERM

    # Create log directory
    mkdir -p "$LOG_DIR"

    # Start logging
    log "INFO" "Starting $SCRIPT_NAME"

    # Check lock
    check_lock

    # Load configuration
    load_config

    # Check if running as root
    if [[ $EUID -ne 0 ]]; then
        error_exit "This script must be run as root" 1
    fi

    # Perform maintenance tasks
    log "INFO" "Updating package cache"
    dnf makecache &>> "$LOG_FILE"

    log "INFO" "Checking for security updates"
    dnf check-update --security &>> "$LOG_FILE" || true

    log "INFO" "Cleaning temporary files"
    find /tmp -type f -atime +7 -delete 2>> "$LOG_FILE"
    find /var/tmp -type f -atime +7 -delete 2>> "$LOG_FILE"

    log "INFO" "Checking disk usage"
    df -h | awk '$5 > 80 {print $0}' | while read -r line; do
        log "WARN" "High disk usage: $line"
    done

    log "INFO" "Rotating logs"
    logrotate -f /etc/logrotate.conf &>> "$LOG_FILE"

    log "INFO" "$SCRIPT_NAME completed successfully"
}

# Run main function
main "$@"
```

#### Error Handling and Logging

```bash
# ERROR HANDLING PATTERNS

# 1. Exit codes
# 0   = Success
# 1   = General error
# 2   = Misuse of shell command
# 126 = Command cannot execute
# 127 = Command not found
# 128+n = Fatal signal n

# 2. Error handling with trap
#!/bin/bash
error_handler() {
    local line_no=$1
    local exit_code=$2
    echo "Error on line $line_no: Command exited with status $exit_code"
    # Send alert email
    echo "Script $0 failed at line $line_no" | mail -s "Script Error" admin@example.com
}

trap 'error_handler $LINENO $?' ERR

# 3. Logging patterns
# Simple logging
LOG_FILE="/var/log/myscript.log"
echo "$(date): Starting process" >> "$LOG_FILE"

# Advanced logging with syslog
logger -t myscript -p user.info "Starting process"
logger -t myscript -p user.error "Error occurred: $error_msg"

# View syslog messages:
journalctl -t myscript

# 4. Debug mode
DEBUG=${DEBUG:-false}
debug() {
    if [ "$DEBUG" = true ]; then
        echo "DEBUG: $*" >&2
    fi
}

# Usage:
debug "Variable X = $X"

# Run with: DEBUG=true ./script.sh
```

### Log Rotation with logrotate

#### Configuring Log Rotation

```bash
# Logrotate prevents logs from filling up your disk

# Main configuration:
cat /etc/logrotate.conf
# see "man logrotate" for details
# rotate log files weekly
weekly

# keep 4 weeks worth of backlogs
rotate 4

# create new (empty) log files after rotating old ones
create

# use date as a suffix of the rotated file
dateext

# uncomment this if you want your log files compressed
#compress

# packages drop log rotation information into this directory
include /etc/logrotate.d

# Check current configurations:
ls -la /etc/logrotate.d/
# bootlog
# chrony
# httpd
# nginx
# syslog
# yum

# Create custom log rotation:
sudo nano /etc/logrotate.d/myapp

/var/log/myapp/*.log {
    # Rotate daily
    daily

    # Keep 14 days of logs
    rotate 14

    # Compress rotated logs
    compress

    # Don't compress yesterday's log
    delaycompress

    # Don't error if log missing
    missingok

    # Don't rotate empty logs
    notifempty

    # Create new log with permissions
    create 0640 myapp myapp

    # Run commands after rotation
    postrotate
        # Signal app to reopen log files
        systemctl reload myapp 2>/dev/null || true
    endscript
}

# Advanced configuration:
/var/log/custom/*.log {
    # Size-based rotation (rotate when > 100M)
    size 100M

    # Or time-based
    weekly

    # Keep specific number
    rotate 52

    # Or keep by time
    maxage 365

    # Copy then truncate (app keeps writing)
    copytruncate

    # Or create new and signal app
    create 0644 root root
    postrotate
        /usr/bin/killall -SIGUSR1 myapp
    endscript

    # Multiple scripts
    prerotate
        echo "About to rotate" | mail -s "Log rotation" admin@example.com
    endscript

    # Share scripts between files
    sharedscripts

    # Date in filename
    dateext
    dateformat -%Y%m%d

    # Compress with specific program
    compress
    compresscmd /usr/bin/xz
    compressext .xz
}

# Test configuration:
sudo logrotate -d /etc/logrotate.d/myapp  # Debug mode (dry run)

# Force rotation:
sudo logrotate -f /etc/logrotate.d/myapp

# Check status:
cat /var/lib/logrotate/logrotate.status
```

### Automated Maintenance Tasks

#### System Maintenance Automation

```bash
# CREATE COMPREHENSIVE MAINTENANCE SYSTEM

# 1. Daily maintenance script
sudo nano /usr/local/bin/daily-maintenance.sh

#!/bin/bash
set -euo pipefail

LOG="/var/log/maintenance/daily-$(date +%Y%m%d).log"
mkdir -p /var/log/maintenance

{
    echo "=== Daily Maintenance Started: $(date) ==="

    # Update package cache
    echo "Updating package cache..."
    dnf makecache

    # Check for security updates
    echo "Checking security updates..."
    dnf check-update --security || true

    # Clean package cache
    echo "Cleaning package cache..."
    dnf clean all

    # Update virus definitions (if ClamAV installed)
    if command -v freshclam &> /dev/null; then
        echo "Updating virus definitions..."
        freshclam
    fi

    # Update locate database
    echo "Updating locate database..."
    updatedb

    # Check and repair filesystems
    echo "Checking filesystems..."
    # Only check, don't repair automatically
    for fs in $(mount -t ext4,xfs | awk '{print $1}'); do
        if [ -b "$fs" ]; then
            echo "Checking $fs..."
            fsck -n "$fs" 2>&1 || echo "Filesystem $fs needs attention"
        fi
    done

    # Clean temporary files
    echo "Cleaning temporary files..."
    find /tmp -type f -atime +7 -delete
    find /var/tmp -type f -atime +7 -delete
    find /var/cache/PackageKit -type f -atime +30 -delete

    # Check disk space
    echo "Checking disk space..."
    df -h | awk 'NR==1 || $5~/[8-9][0-9]%|100%/'

    # Check for failed services
    echo "Checking for failed services..."
    systemctl list-units --failed

    # Verify important services are running
    for service in sshd firewalld NetworkManager; do
        if ! systemctl is-active --quiet $service; then
            echo "WARNING: $service is not running!"
            systemctl start $service
        fi
    done

    echo "=== Daily Maintenance Completed: $(date) ==="
} >> "$LOG" 2>&1

# Email results
mail -s "Daily Maintenance Report $(hostname)" admin@example.com < "$LOG"

sudo chmod +x /usr/local/bin/daily-maintenance.sh

# 2. Weekly maintenance script
sudo nano /usr/local/bin/weekly-maintenance.sh

#!/bin/bash
set -euo pipefail

LOG="/var/log/maintenance/weekly-$(date +%Y%m%d).log"

{
    echo "=== Weekly Maintenance Started: $(date) ==="

    # Full system backup
    echo "Running full backup..."
    /usr/local/bin/full-backup.sh

    # Update all packages
    echo "Updating all packages..."
    dnf update -y

    # Clean old kernels (keep last 2)
    echo "Cleaning old kernels..."
    dnf remove --oldinstallonly --setopt installonly_limit=2 kernel -y

    # Analyze logs for issues
    echo "Analyzing logs..."
    journalctl -p err --since="7 days ago" | head -100

    # Check for rootkits (if rkhunter installed)
    if command -v rkhunter &> /dev/null; then
        echo "Checking for rootkits..."
        rkhunter --check --skip-keypress
    fi

    # Defragment XFS filesystems
    for fs in $(mount -t xfs | awk '{print $3}'); do
        echo "Defragmenting $fs..."
        xfs_fsr -v "$fs"
    done

    # Check RAID status (if applicable)
    if [ -f /proc/mdstat ]; then
        echo "RAID Status:"
        cat /proc/mdstat
    fi

    echo "=== Weekly Maintenance Completed: $(date) ==="
} >> "$LOG" 2>&1

sudo chmod +x /usr/local/bin/weekly-maintenance.sh

# 3. Set up with systemd timers
# Daily timer
sudo nano /etc/systemd/system/daily-maintenance.timer
[Unit]
Description=Daily Maintenance Timer

[Timer]
OnCalendar=daily
AccuracySec=1h
Persistent=true

[Install]
WantedBy=timers.target

# Weekly timer
sudo nano /etc/systemd/system/weekly-maintenance.timer
[Unit]
Description=Weekly Maintenance Timer

[Timer]
OnCalendar=weekly
AccuracySec=12h
Persistent=true

[Install]
WantedBy=timers.target

# Enable timers
sudo systemctl daemon-reload
sudo systemctl enable --now daily-maintenance.timer
sudo systemctl enable --now weekly-maintenance.timer
```

### Anacron for Irregular Schedules

#### Setting Up Anacron

```bash
# Anacron runs missed jobs - perfect for laptops/desktops that aren't always on

# Check if anacron is installed:
rpm -q cronie-anacron
# If not: sudo dnf install cronie-anacron

# Anacron configuration:
cat /etc/anacrontab
# /etc/anacrontab: configuration file for anacron
# See anacron(8) and anacrontab(5) for details.

SHELL=/bin/sh
PATH=/sbin:/bin:/usr/sbin:/usr/bin
MAILTO=root
# Maximum random delay added to base delay
RANDOM_DELAY=45
# Jobs start between 3am and 10:30pm
START_HOURS_RANGE=3-22

# period  delay  job-identifier  command
1         5      cron.daily      nice run-parts /etc/cron.daily
7         25     cron.weekly     nice run-parts /etc/cron.weekly
@monthly  45     cron.monthly    nice run-parts /etc/cron.monthly

# Understanding anacron:
# period = How often (days, or @monthly)
# delay = Wait minutes after boot
# job-identifier = Unique name
# command = What to run

# Add custom anacron job:
echo "30 10 backup-photos /usr/local/bin/backup-photos.sh" >> /etc/anacrontab

# This means:
# - Run every 30 days
# - Wait 10 minutes after anacron starts
# - Job ID is "backup-photos"
# - Run the backup-photos.sh script

# Check when jobs last ran:
sudo cat /var/spool/anacron/*
# cron.daily: 20231211
# cron.weekly: 20231210
# cron.monthly: 20231201

# Force anacron to run now:
sudo anacron -f -n

# Test specific job:
sudo anacron -f -n cron.daily

# Anacron vs Cron:
# CRON:
# - Assumes system is always on
# - Runs at exact times
# - Skips missed jobs
# - Good for servers

# ANACRON:
# - Handles intermittent uptime
# - Runs when system is available
# - Catches up on missed jobs
# - Good for workstations
```

---

## Chapter 15: Configuration Management Basics

### Advanced Bash Scripting for Configuration Management

#### Building a Configuration Management System

```bash
# CREATE A SIMPLE CONFIGURATION MANAGEMENT SYSTEM IN BASH

# 1. Configuration definition file
sudo nano /etc/sysconfig/app-config.conf

# Application Configuration
APP_NAME="myapp"
APP_VERSION="2.1.0"
APP_PORT="8080"
APP_USER="appuser"
APP_GROUP="appgroup"
APP_HOME="/opt/myapp"
APP_LOG_DIR="/var/log/myapp"
APP_DATA_DIR="/var/lib/myapp"
APP_CONF_DIR="/etc/myapp"

# Database settings
DB_HOST="localhost"
DB_PORT="5432"
DB_NAME="myapp_db"
DB_USER="myapp_user"

# Feature flags
ENABLE_SSL="true"
ENABLE_CACHE="true"
DEBUG_MODE="false"

# 2. Configuration management script
sudo nano /usr/local/bin/config-manager.sh

#!/bin/bash
set -euo pipefail

# Configuration Management System
VERSION="1.0.0"
CONFIG_FILE="/etc/sysconfig/app-config.conf"
BACKUP_DIR="/var/backup/configs"
STATE_FILE="/var/lib/config-manager/state.json"

# Load configuration
source "$CONFIG_FILE"

# Functions for state management
save_state() {
    local component=$1
    local state=$2
    local timestamp=$(date -Iseconds)

    mkdir -p "$(dirname "$STATE_FILE")"

    if [ ! -f "$STATE_FILE" ]; then
        echo "{}" > "$STATE_FILE"
    fi

    # Update state using Python (available in Rocky Linux)
    python3 -c "
import json
import sys

with open('$STATE_FILE', 'r') as f:
    data = json.load(f)

data['$component'] = {
    'state': '$state',
    'timestamp': '$timestamp',
    'version': '$VERSION'
}

with open('$STATE_FILE', 'w') as f:
    json.dump(data, f, indent=2)
"
}

get_state() {
    local component=$1

    if [ ! -f "$STATE_FILE" ]; then
        echo "unknown"
        return
    fi

    python3 -c "
import json
import sys

try:
    with open('$STATE_FILE', 'r') as f:
        data = json.load(f)
    print(data.get('$component', {}).get('state', 'unknown'))
except:
    print('unknown')
"
}

# Backup configuration
backup_config() {
    local backup_name="config-$(date +%Y%m%d-%H%M%S).tar.gz"
    mkdir -p "$BACKUP_DIR"

    echo "Creating configuration backup: $backup_name"
    tar czf "$BACKUP_DIR/$backup_name" \
        "$CONFIG_FILE" \
        "$APP_CONF_DIR" \
        "$STATE_FILE" 2>/dev/null || true

    # Keep only last 10 backups
    ls -t "$BACKUP_DIR"/config-*.tar.gz | tail -n +11 | xargs -r rm

    save_state "backup" "completed"
}

# Apply configuration
apply_config() {
    echo "Applying configuration for $APP_NAME v$APP_VERSION"

    # Create user and group
    if ! id "$APP_USER" &>/dev/null; then
        echo "Creating user: $APP_USER"
        groupadd -r "$APP_GROUP"
        useradd -r -g "$APP_GROUP" -d "$APP_HOME" -s /bin/false "$APP_USER"
        save_state "user" "created"
    fi

    # Create directories
    for dir in "$APP_HOME" "$APP_LOG_DIR" "$APP_DATA_DIR" "$APP_CONF_DIR"; do
        if [ ! -d "$dir" ]; then
            echo "Creating directory: $dir"
            mkdir -p "$dir"
            chown "$APP_USER:$APP_GROUP" "$dir"
        fi
    done
    save_state "directories" "created"

    # Apply feature flags
    if [ "$ENABLE_SSL" = "true" ]; then
        echo "Enabling SSL..."
        # SSL configuration logic here
        save_state "ssl" "enabled"
    fi

    if [ "$ENABLE_CACHE" = "true" ]; then
        echo "Enabling cache..."
        # Cache configuration logic here
        save_state "cache" "enabled"
    fi

    # Update application configuration file
    generate_app_config > "$APP_CONF_DIR/app.conf"
    save_state "app_config" "generated"

    echo "Configuration applied successfully"
}

# Generate application configuration
generate_app_config() {
    cat <<EOF
# Generated by config-manager.sh
# Do not edit manually

[server]
port = $APP_PORT
ssl_enabled = $ENABLE_SSL
cache_enabled = $ENABLE_CACHE
debug = $DEBUG_MODE

[database]
host = $DB_HOST
port = $DB_PORT
name = $DB_NAME
user = $DB_USER

[paths]
home = $APP_HOME
logs = $APP_LOG_DIR
data = $APP_DATA_DIR
config = $APP_CONF_DIR

[system]
user = $APP_USER
group = $APP_GROUP
version = $APP_VERSION
EOF
}

# Verify configuration
verify_config() {
    local errors=0

    echo "Verifying configuration..."

    # Check user exists
    if ! id "$APP_USER" &>/dev/null; then
        echo "ERROR: User $APP_USER does not exist"
        ((errors++))
    fi

    # Check directories exist
    for dir in "$APP_HOME" "$APP_LOG_DIR" "$APP_DATA_DIR" "$APP_CONF_DIR"; do
        if [ ! -d "$dir" ]; then
            echo "ERROR: Directory $dir does not exist"
            ((errors++))
        fi
    done

    # Check configuration file
    if [ ! -f "$APP_CONF_DIR/app.conf" ]; then
        echo "ERROR: Configuration file not found"
        ((errors++))
    fi

    # Check port availability
    if ss -tlpn | grep -q ":$APP_PORT "; then
        echo "WARNING: Port $APP_PORT is already in use"
    fi

    if [ $errors -eq 0 ]; then
        echo "Configuration verification passed"
        save_state "verification" "passed"
        return 0
    else
        echo "Configuration verification failed with $errors errors"
        save_state "verification" "failed"
        return 1
    fi
}

# Main menu
case "${1:-help}" in
    apply)
        backup_config
        apply_config
        verify_config
        ;;
    verify)
        verify_config
        ;;
    backup)
        backup_config
        ;;
    status)
        echo "Configuration Status:"
        echo "====================="
        cat "$STATE_FILE" 2>/dev/null | python3 -m json.tool
        ;;
    diff)
        # Show configuration changes
        if [ -f "$APP_CONF_DIR/app.conf" ]; then
            echo "Current configuration:"
            generate_app_config | diff -u "$APP_CONF_DIR/app.conf" - || true
        else
            echo "No existing configuration found"
        fi
        ;;
    rollback)
        if [ -z "${2:-}" ]; then
            echo "Usage: $0 rollback <backup-file>"
            exit 1
        fi
        echo "Rolling back to: $2"
        tar xzf "$BACKUP_DIR/$2" -C /
        ;;
    help|*)
        echo "Configuration Manager v$VERSION"
        echo "Usage: $0 {apply|verify|backup|status|diff|rollback|help}"
        echo ""
        echo "Commands:"
        echo "  apply    - Apply configuration"
        echo "  verify   - Verify current configuration"
        echo "  backup   - Backup current configuration"
        echo "  status   - Show configuration state"
        echo "  diff     - Show pending changes"
        echo "  rollback - Restore from backup"
        ;;
esac

sudo chmod +x /usr/local/bin/config-manager.sh
```

### System Configuration with Native Tools

#### Using Rocky Linux Native Tools for Configuration

```bash
# SYSTEMD FOR CONFIGURATION MANAGEMENT

# 1. Systemd drop-in directories for configuration override
# Original service: /usr/lib/systemd/system/httpd.service
# Override with: /etc/systemd/system/httpd.service.d/override.conf

sudo mkdir -p /etc/systemd/system/httpd.service.d
sudo nano /etc/systemd/system/httpd.service.d/override.conf

[Service]
# Override specific settings without modifying original
Environment="HTTPD_LANG=C"
Environment="HTTPD_OPTIONS=-D SSL"
MemoryLimit=2G
CPUQuota=50%
Restart=always
RestartSec=10

# Apply changes:
sudo systemctl daemon-reload
sudo systemctl restart httpd

# 2. SYSTEMD TEMPLATES for multiple instances
sudo nano /etc/systemd/system/myapp@.service

[Unit]
Description=MyApp Instance %i
After=network.target

[Service]
Type=simple
User=myapp
Environment="INSTANCE=%i"
ExecStart=/opt/myapp/bin/start.sh --instance %i --port 80%i
Restart=always

[Install]
WantedBy=multi-user.target

# Start multiple instances:
sudo systemctl enable --now myapp@01
sudo systemctl enable --now myapp@02
sudo systemctl enable --now myapp@03

# Each runs on different port: 8001, 8002, 8003

# 3. SYSTEMD ENVIRONMENT GENERATORS
sudo nano /usr/local/bin/generate-env.sh

#!/bin/bash
# Generate environment based on system state

if [ -f /etc/production-mode ]; then
    echo "ENVIRONMENT=production"
    echo "LOG_LEVEL=warn"
else
    echo "ENVIRONMENT=development"
    echo "LOG_LEVEL=debug"
fi

echo "HOSTNAME=$(hostname -f)"
echo "CPU_COUNT=$(nproc)"
echo "MEMORY_GB=$(($(free -b | awk 'NR==2{print $2}') / 1073741824))"

sudo chmod +x /usr/local/bin/generate-env.sh

# Use in service:
[Service]
ExecStartPre=/bin/bash -c '/usr/local/bin/generate-env.sh > /run/myapp.env'
EnvironmentFile=/run/myapp.env

# 4. ALTERNATIVES SYSTEM for version management
# Install multiple versions
sudo dnf install java-1.8.0-openjdk java-11-openjdk java-17-openjdk

# Configure alternatives
sudo alternatives --config java
# There are 3 programs which provide 'java'.
#
#   Selection    Command
# -----------------------------------------------
# *+ 1           java-17-openjdk.x86_64 (/usr/lib/jvm/java-17-openjdk/bin/java)
#    2           java-11-openjdk.x86_64 (/usr/lib/jvm/java-11-openjdk/bin/java)
#    3           java-1.8.0-openjdk.x86_64 (/usr/lib/jvm/java-1.8.0-openjdk/bin/java)
#
# Enter to keep the current selection[+], or type selection number: 2

# Set programmatically:
sudo alternatives --set java /usr/lib/jvm/java-11-openjdk/bin/java

# Create custom alternatives:
sudo alternatives --install /usr/bin/python3 python3 /usr/bin/python3.6 50
sudo alternatives --install /usr/bin/python3 python3 /usr/bin/python3.9 60
```

### Configuration File Templating with sed/awk

#### Creating Dynamic Configuration Files

```bash
# TEMPLATE ENGINE USING SED/AWK

# 1. Create template file
cat > /tmp/nginx.conf.template << 'EOF'
# Nginx Configuration Template
user {{NGINX_USER}};
worker_processes {{WORKER_PROCESSES}};
error_log {{ERROR_LOG_PATH}} {{LOG_LEVEL}};
pid /run/nginx.pid;

events {
    worker_connections {{WORKER_CONNECTIONS}};
}

http {
    log_format main '$remote_addr - $remote_user [$time_local] "$request" '
                    '$status $body_bytes_sent "$http_referer" '
                    '"$http_user_agent" "$http_x_forwarded_for"';

    access_log {{ACCESS_LOG_PATH}} main;

    server {
        listen {{SERVER_PORT}} {{SSL_CONFIG}};
        server_name {{SERVER_NAME}};
        root {{DOCUMENT_ROOT}};

        location / {
            index index.html index.htm;
        }

        {{ADDITIONAL_LOCATIONS}}
    }
}
EOF

# 2. Template processor script
sudo nano /usr/local/bin/template-processor.sh

#!/bin/bash
set -euo pipefail

process_template() {
    local template_file=$1
    local output_file=$2
    local config_file=${3:-/etc/sysconfig/template.conf}

    # Load configuration
    if [ -f "$config_file" ]; then
        source "$config_file"
    fi

    # Set defaults
    : ${NGINX_USER:=nginx}
    : ${WORKER_PROCESSES:=$(nproc)}
    : ${WORKER_CONNECTIONS:=1024}
    : ${ERROR_LOG_PATH:=/var/log/nginx/error.log}
    : ${ACCESS_LOG_PATH:=/var/log/nginx/access.log}
    : ${LOG_LEVEL:=warn}
    : ${SERVER_PORT:=80}
    : ${SERVER_NAME:=localhost}
    : ${DOCUMENT_ROOT:=/usr/share/nginx/html}
    : ${SSL_CONFIG:=}
    : ${ADDITIONAL_LOCATIONS:=}

    # Process template
    cp "$template_file" "$output_file.tmp"

    # Replace variables
    for var in NGINX_USER WORKER_PROCESSES WORKER_CONNECTIONS \
               ERROR_LOG_PATH ACCESS_LOG_PATH LOG_LEVEL \
               SERVER_PORT SERVER_NAME DOCUMENT_ROOT \
               SSL_CONFIG ADDITIONAL_LOCATIONS; do
        value=${!var}
        sed -i "s|{{${var}}}|${value}|g" "$output_file.tmp"
    done

    # Move to final location
    mv "$output_file.tmp" "$output_file"
    echo "Generated: $output_file"
}

# Usage
if [ $# -lt 2 ]; then
    echo "Usage: $0 <template-file> <output-file> [config-file]"
    exit 1
fi

process_template "$@"

sudo chmod +x /usr/local/bin/template-processor.sh

# 3. Configuration file
sudo nano /etc/sysconfig/nginx-template.conf

NGINX_USER="www-data"
WORKER_PROCESSES="auto"
WORKER_CONNECTIONS="2048"
ERROR_LOG_PATH="/var/log/nginx/error.log"
ACCESS_LOG_PATH="/var/log/nginx/access.log"
LOG_LEVEL="info"
SERVER_PORT="443 ssl http2"
SERVER_NAME="example.com www.example.com"
DOCUMENT_ROOT="/var/www/html"
SSL_CONFIG="ssl_certificate /etc/ssl/certs/example.crt; ssl_certificate_key /etc/ssl/private/example.key;"
ADDITIONAL_LOCATIONS="
    location /api {
        proxy_pass http://localhost:8080;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
    }
"

# 4. Generate configuration
sudo /usr/local/bin/template-processor.sh \
    /tmp/nginx.conf.template \
    /etc/nginx/nginx.conf \
    /etc/sysconfig/nginx-template.conf

# 5. Advanced AWK template processor
sudo nano /usr/local/bin/awk-template.sh

#!/bin/bash

process_with_awk() {
    local template=$1
    local config=$2

    awk '
    BEGIN {
        # Read configuration
        while ((getline line < "'"$config"'") > 0) {
            if (match(line, /^([A-Z_]+)=(.*)$/, arr)) {
                gsub(/^"|"$/, "", arr[2])
                vars[arr[1]] = arr[2]
            }
        }
    }
    {
        # Process template
        line = $0
        for (var in vars) {
            gsub("{{" var "}}", vars[var], line)
        }
        print line
    }
    ' "$template"
}

# Example with conditional sections
cat > /tmp/advanced.template << 'EOF'
server {
    listen {{PORT}};
    server_name {{HOSTNAME}};

    {{#IF_SSL}}
    ssl_certificate {{SSL_CERT}};
    ssl_certificate_key {{SSL_KEY}};
    {{#ENDIF_SSL}}

    {{#FOREACH_BACKEND}}
    upstream backend_{{INDEX}} {
        server {{BACKEND_{{INDEX}}}};
    }
    {{#ENDFOREACH_BACKEND}}
}
EOF

sudo chmod +x /usr/local/bin/awk-template.sh
```

### Kickstart for System Deployment

#### Automating Rocky Linux Installation

```bash
# KICKSTART AUTOMATES ROCKY LINUX INSTALLATION

# 1. Create kickstart file
cat > /tmp/rocky-ks.cfg << 'EOF'
#version=RHEL8
# Rocky Linux 8 Kickstart Configuration

# System language
lang en_US.UTF-8

# Keyboard layouts
keyboard --xlayouts='us'

# System timezone
timezone America/New_York --isUtc

# Root password (encrypted with: python3 -c 'import crypt; print(crypt.crypt("password123"))')
rootpw --iscrypted $6$rounds=4096$saltstring$encryptedpassword

# Create user
user --name=admin --groups=wheel --iscrypted --password=$6$rounds=4096$salt$encrypted

# System bootloader configuration
bootloader --location=mbr --boot-drive=sda

# Partition clearing information
clearpart --all --initlabel --drives=sda

# Disk partitioning information
part /boot --fstype="xfs" --size=1024
part pv.01 --fstype="lvmpv" --ondisk=sda --size=1 --grow

volgroup vg_rocky pv.01
logvol / --fstype="xfs" --size=10240 --name=root --vgname=vg_rocky
logvol /var --fstype="xfs" --size=5120 --name=var --vgname=vg_rocky
logvol /home --fstype="xfs" --size=1024 --grow --name=home --vgname=vg_rocky
logvol swap --fstype="swap" --size=2048 --name=swap --vgname=vg_rocky

# Network information
network --bootproto=dhcp --device=eth0 --ipv6=auto --activate
network --hostname=rocky-server.local

# SELinux configuration
selinux --enforcing

# Firewall configuration
firewall --enabled --service=ssh

# System services
services --enabled="NetworkManager,sshd,chronyd"

# Package selection
%packages
@^minimal-environment
@standard
vim-enhanced
git
wget
curl
tmux
htop
net-tools
bind-utils
bash-completion
%end

# Post-installation script
%post --log=/root/ks-post.log
#!/bin/bash

# Update system
dnf update -y

# Configure SSH
sed -i 's/#PermitRootLogin yes/PermitRootLogin no/' /etc/ssh/sshd_config
sed -i 's/#PubkeyAuthentication yes/PubkeyAuthentication yes/' /etc/ssh/sshd_config

# Add SSH key for admin user
mkdir -p /home/admin/.ssh
cat > /home/admin/.ssh/authorized_keys << 'KEY'
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQ... admin@workstation
KEY
chmod 700 /home/admin/.ssh
chmod 600 /home/admin/.ssh/authorized_keys
chown -R admin:admin /home/admin/.ssh

# Configure sudo for wheel group
echo "%wheel ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/wheel

# Install EPEL
dnf install -y epel-release

# Custom message of the day
cat > /etc/motd << 'MOTD'
===============================================
  Rocky Linux Server
  Deployed via Kickstart
  $(date)
===============================================
MOTD

# Enable automatic updates
dnf install -y dnf-automatic
systemctl enable --now dnf-automatic.timer

%end

# Reboot after installation
reboot
EOF

# 2. Validate kickstart file
ksvalidator /tmp/rocky-ks.cfg

# 3. Use kickstart for installation
# Method A: Network boot (PXE)
# Add to PXE server boot menu:
# kernel vmlinuz
# append initrd=initrd.img inst.ks=http://server/rocky-ks.cfg

# Method B: USB/DVD with kickstart
# At boot prompt:
# linux ks=hd:sdb1:/rocky-ks.cfg

# Method C: Network kickstart
# linux ks=http://192.168.1.100/rocky-ks.cfg
# linux ks=nfs:192.168.1.100:/kickstart/rocky-ks.cfg

# 4. Generate kickstart from existing system
sudo dnf install -y pykickstart
sudo system-config-kickstart  # GUI tool (if desktop installed)
```

### Cloud-init on Rocky Linux

#### Automating Cloud Deployments

```bash
# CLOUD-INIT FOR CLOUD AND VM AUTOMATION

# Install cloud-init
sudo dnf install -y cloud-init

# Cloud-init configuration files
ls -la /etc/cloud/
# cloud.cfg           <- Main configuration
# cloud.cfg.d/        <- Additional configs
# templates/          <- Template files

# 1. User data example (runs on first boot)
cat > /tmp/user-data.yaml << 'EOF'
#cloud-config
hostname: rocky-cloud-server
fqdn: rocky-cloud-server.example.com
manage_etc_hosts: true

# Create users
users:
  - default
  - name: admin
    groups: wheel
    shell: /bin/bash
    sudo: ALL=(ALL) NOPASSWD:ALL
    ssh_authorized_keys:
      - ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQ... admin@workstation

# Install packages
packages:
  - nginx
  - git
  - vim
  - htop
  - firewalld

# Run commands
runcmd:
  - systemctl enable --now nginx
  - firewall-cmd --permanent --add-service=http
  - firewall-cmd --permanent --add-service=https
  - firewall-cmd --reload
  - curl -L https://example.com/setup.sh | bash

# Write files
write_files:
  - path: /etc/nginx/conf.d/app.conf
    content: |
      server {
          listen 80;
          server_name _;
          location / {
              proxy_pass http://localhost:8080;
          }
      }
    owner: root:root
    permissions: '0644'

# Configure networking
network:
  version: 2
  ethernets:
    eth0:
      dhcp4: true
      dhcp6: false

# Set timezone
timezone: America/New_York

# Enable services
systemd:
  units:
    - name: nginx.service
      enabled: true
      state: started

# Final message
final_message: "Rocky Linux system is ready after $UPTIME seconds"
EOF

# 2. Network data (static IP configuration)
cat > /tmp/network-config.yaml << 'EOF'
version: 2
ethernets:
  eth0:
    dhcp4: false
    addresses:
      - 192.168.1.100/24
    gateway4: 192.168.1.1
    nameservers:
      addresses:
        - 8.8.8.8
        - 8.8.4.4
EOF

# 3. Vendor data (cloud provider specific)
cat > /tmp/vendor-data.yaml << 'EOF'
#cloud-config
# Provider-specific configuration
datasource:
  Ec2:
    metadata_urls: ['http://169.254.169.254']
    timeout: 10
    max_wait: 120
EOF

# 4. Test cloud-init locally
# Create ISO with cloud-init data
sudo dnf install -y cloud-utils
cloud-localds -v cloud-init.iso /tmp/user-data.yaml /tmp/network-config.yaml

# Mount and verify
sudo mkdir /mnt/cloudinit
sudo mount cloud-init.iso /mnt/cloudinit
ls -la /mnt/cloudinit/

# 5. Debug cloud-init
# Check status
sudo cloud-init status
# status: done

# See what ran
sudo cloud-init query
sudo cloud-init analyze show

# View logs
sudo journalctl -u cloud-init
sudo cat /var/log/cloud-init.log
sudo cat /var/log/cloud-init-output.log

# Re-run cloud-init (testing)
sudo cloud-init clean
sudo cloud-init init
sudo cloud-init modules --mode=config
sudo cloud-init modules --mode=final
```

### Infrastructure as Code Concepts with Native Tools

#### Building IaC with Shell Scripts

```bash
# INFRASTRUCTURE AS CODE USING NATIVE TOOLS

# 1. System definition file (declarative)
cat > /etc/infrastructure/system.yaml << 'EOF'
---
system:
  hostname: app-server-01
  timezone: America/New_York
  selinux: enforcing

packages:
  install:
    - nginx
    - postgresql
    - redis
    - git
    - vim-enhanced
  remove:
    - telnet
    - ftp

services:
  enabled:
    - nginx
    - postgresql
    - redis
    - firewalld
  disabled:
    - bluetooth
    - cups

firewall:
  services:
    - ssh
    - http
    - https
  ports:
    - 8080/tcp
    - 9090/tcp
  zones:
    public:
      interfaces:
        - eth0

users:
  - name: appuser
    uid: 1001
    groups: [wheel, developers]
    shell: /bin/bash
    home: /home/appuser
  - name: dbuser
    uid: 1002
    groups: [postgres]
    shell: /bin/false

directories:
  - path: /opt/application
    owner: appuser
    group: developers
    mode: "0755"
  - path: /var/log/application
    owner: appuser
    group: developers
    mode: "0755"

files:
  - path: /etc/app.conf
    content: |
      server=production
      port=8080
    owner: root
    group: root
    mode: "0644"

mounts:
  - device: /dev/sdb1
    path: /data
    fstype: xfs
    options: defaults,noatime

cron:
  - minute: "0"
    hour: "2"
    command: /usr/local/bin/backup.sh
    user: root

sysctl:
  net.ipv4.ip_forward: 1
  vm.swappiness: 10
  net.core.somaxconn: 65535
EOF

# 2. IaC implementation script
sudo nano /usr/local/bin/iac-apply.sh

#!/bin/bash
set -euo pipefail

CONFIG_FILE="${1:-/etc/infrastructure/system.yaml}"
LOG_FILE="/var/log/iac-apply.log"
DRY_RUN="${DRY_RUN:-false}"

log() {
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] $*" | tee -a "$LOG_FILE"
}

run_command() {
    if [ "$DRY_RUN" = "true" ]; then
        log "DRY RUN: $*"
    else
        log "EXECUTING: $*"
        eval "$@" >> "$LOG_FILE" 2>&1
    fi
}

apply_system() {
    log "Applying system configuration..."

    # Parse YAML using Python
    python3 << 'PYTHON' | while IFS='=' read -r key value; do
import yaml
import sys

with open('$CONFIG_FILE', 'r') as f:
    config = yaml.safe_load(f)

system = config.get('system', {})
for k, v in system.items():
    print(f"{k}={v}")
PYTHON
        case "$key" in
            hostname)
                current_hostname=$(hostname)
                if [ "$current_hostname" != "$value" ]; then
                    run_command "hostnamectl set-hostname $value"
                fi
                ;;
            timezone)
                run_command "timedatectl set-timezone $value"
                ;;
            selinux)
                run_command "setenforce $([ $value = 'enforcing' ] && echo 1 || echo 0)"
                ;;
        esac
    done
}

apply_packages() {
    log "Applying package configuration..."

    # Install packages
    python3 -c "
import yaml
with open('$CONFIG_FILE', 'r') as f:
    config = yaml.safe_load(f)
packages = config.get('packages', {})
if 'install' in packages:
    print(' '.join(packages['install']))
" | while read -r packages; do
        if [ -n "$packages" ]; then
            run_command "dnf install -y $packages"
        fi
    done

    # Remove packages
    python3 -c "
import yaml
with open('$CONFIG_FILE', 'r') as f:
    config = yaml.safe_load(f)
packages = config.get('packages', {})
if 'remove' in packages:
    print(' '.join(packages['remove']))
" | while read -r packages; do
        if [ -n "$packages" ]; then
            run_command "dnf remove -y $packages"
        fi
    done
}

apply_services() {
    log "Applying service configuration..."

    # Enable services
    python3 -c "
import yaml
with open('$CONFIG_FILE', 'r') as f:
    config = yaml.safe_load(f)
services = config.get('services', {})
for service in services.get('enabled', []):
    print(service)
" | while read -r service; do
        run_command "systemctl enable --now $service"
    done

    # Disable services
    python3 -c "
import yaml
with open('$CONFIG_FILE', 'r') as f:
    config = yaml.safe_load(f)
services = config.get('services', {})
for service in services.get('disabled', []):
    print(service)
" | while read -r service; do
        run_command "systemctl disable --now $service"
    done
}

# Main execution
main() {
    log "Starting Infrastructure as Code application"
    log "Configuration file: $CONFIG_FILE"
    log "Dry run: $DRY_RUN"

    # Check prerequisites
    if ! command -v python3 &> /dev/null; then
        log "ERROR: Python 3 is required"
        exit 1
    fi

    if ! python3 -c "import yaml" &> /dev/null 2>&1; then
        log "Installing PyYAML..."
        dnf install -y python3-pyyaml
    fi

    # Apply configurations
    apply_system
    apply_packages
    apply_services
    # Add more apply_* functions as needed

    log "Infrastructure as Code application completed"
}

main "$@"

sudo chmod +x /usr/local/bin/iac-apply.sh

# 3. Run in dry-run mode
DRY_RUN=true sudo /usr/local/bin/iac-apply.sh

# 4. Apply configuration
sudo /usr/local/bin/iac-apply.sh

# 5. Version control your infrastructure
cd /etc/infrastructure
sudo git init
sudo git add .
sudo git commit -m "Initial infrastructure configuration"
```

## Practice Exercises

### Exercise 1: Automation Framework
1. Create a comprehensive backup system using systemd timers
2. Implement log rotation for custom applications
3. Build an automated security update system
4. Create system health monitoring with automated alerts
5. Set up automated certificate renewal
6. Implement automated user provisioning

### Exercise 2: Configuration Management
1. Build a template system for application configs
2. Create a system state tracking mechanism
3. Implement configuration rollback functionality
4. Build an inventory system for multiple servers
5. Create automated compliance checking
6. Implement configuration drift detection

### Exercise 3: Deployment Automation
1. Create a kickstart file for standard server build
2. Build cloud-init configurations for different roles
3. Implement blue-green deployment with native tools
4. Create automated testing after deployment
5. Build rollback mechanisms for failed deployments
6. Implement zero-downtime updates

### Exercise 4: Infrastructure as Code
1. Define complete system state in YAML
2. Build idempotent configuration scripts
3. Implement state comparison and reporting
4. Create infrastructure testing framework
5. Build configuration validation tools
6. Implement change tracking and auditing

## Summary

In Part 6, we've mastered automation and configuration management using Rocky Linux native tools:

**Task Automation:**
- Cron jobs for traditional scheduling
- Systemd timers for modern scheduling
- Shell scripting best practices
- Log rotation with logrotate
- Automated maintenance tasks
- Anacron for systems with irregular uptime

**Configuration Management:**
- Advanced bash scripting for configuration
- System configuration with native tools
- Systemd for automation and configuration
- Template processing with sed/awk
- Kickstart for automated installation
- Cloud-init for cloud deployments
- Infrastructure as Code concepts

These skills enable you to:
- Automate repetitive tasks efficiently
- Manage configurations without external tools
- Deploy systems consistently
- Track and manage system state
- Build Infrastructure as Code solutions
- Create self-healing systems

## Additional Resources

- [Rocky Linux Automation Guide](https://docs.rockylinux.org/guides/automation/)
- [Systemd Timer Documentation](https://www.freedesktop.org/software/systemd/man/systemd.timer.html)
- [Kickstart Reference](https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/8/html/performing_an_advanced_rhel_installation/kickstart-commands-and-options-reference_installing-rhel-as-an-experienced-user)
- [Cloud-init Documentation](https://cloudinit.readthedocs.io/)
- [Bash Scripting Guide](https://tldp.org/LDP/abs/html/)
- [Rocky Linux System Administration](https://docs.rockylinux.org/books/admin_guide/)
- [Cron Expression Generator](https://crontab.guru/)
- [Systemd by Example](https://systemd-by-example.org/)

---

*Continue to Part 7: Monitoring and Performance*