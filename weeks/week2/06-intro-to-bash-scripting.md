# Introduction to Bash Scripting

In this guide, you'll learn about Bash scripting - a powerful way to automate tasks on Linux servers. We'll cover why scripts are better than manual commands, common uses, and essential scripting techniques.

`Bash scripting is one of the most valuable skills for system administrators and DevOps engineers` {{ note }}

---

## Prerequisites

Before starting, you should understand:

- ✅ Basic Linux command line usage
- ✅ How to navigate directories (`cd`, `ls`, `pwd`)
- ✅ Basic file operations (`cat`, `nano`, `chmod`)
- ✅ How to run commands in terminal

---

## Part 1: What is Bash?

### Understanding Bash

**Bash** = "Bourne Again Shell"

**Shell** = The program that interprets commands you type

Think of it like this:
```
You type: ls -la
         ↓
Bash interprets and executes
         ↓
Result: List of files displayed
```

### What is a Bash Script?

A **Bash script** is simply a text file containing a series of commands that Bash will execute in order.

**Without script (manual commands):**
```bash
# You type each command one by one:
apt update
apt install -y nginx
systemctl start nginx
systemctl enable nginx
echo "Nginx installed!"
```

**With script (automated):**
```bash
# You create a file called install-nginx.sh:
#!/bin/bash
apt update
apt install -y nginx
systemctl start nginx
systemctl enable nginx
echo "Nginx installed!"

# Then run once:
bash install-nginx.sh
```

**Same result, but script is:**
- Reusable
- Documentable
- Shareable
- Less error-prone

---

## Part 2: Why Scripting is Better Than Manual Commands

### The Manual Approach Problems

**Scenario:** You need to set up 10 new servers

**Manual approach:**
1. SSH to server 1
2. Type 50+ commands carefully
3. Wait for each to complete
4. Hope you didn't make a typo
5. Repeat for servers 2-10
6. Realize you forgot a step on server 3
7. Try to remember what you did differently

**Time required:** 5-6 hours
**Error probability:** High
**Consistency:** Low

### The Scripting Approach Advantages

**With a script:**
1. Write script once (30 minutes)
2. Test on one server
3. Run same script on all 10 servers
4. Get identical results every time

**Time required:** 1-2 hours total
**Error probability:** Low (test once, use many times)
**Consistency:** Perfect

### Key Benefits of Scripting

**1. Automation**
```
Manual: Type 50 commands × 10 servers = 500 commands
Script: Run 1 script × 10 servers = 10 commands
```

**2. Consistency**
- Same commands executed in same order
- No variations based on who runs it
- Reproducible results

**3. Documentation**
- Script serves as documentation
- Shows exactly what was done
- Can add comments explaining why

**4. Version Control**
- Save scripts in Git
- Track changes over time
- Rollback if needed

**5. Error Handling**
- Script can check for errors
- Can retry failed operations
- Can send alerts if something fails

**6. Reduced Human Error**
```
Manual:  "Was that apt install nginx or apt install ngnix?"
         "Did I already run this command?"
         "What was the next step?"

Script:  Run once, same result every time
```

### Real-World Example

**Manual Task: Update 20 Production Servers**

Without script:
- 2 hours per server
- 40 hours total
- High risk of typos
- Inconsistent timing
- Potential downtime if mistakes made

With script:
- 1 hour to write/test script
- 10 minutes per server to run script
- 4 hours total (including writing time)
- 90% time savings
- Consistent, tested process

---

## Part 3: Common Uses for Bash Scripts

### 1. Server Setup and Configuration

**Example: Initial server hardening**

```bash
#!/bin/bash
# server-hardening.sh

# Update system
apt update && apt upgrade -y

# Configure firewall
ufw default deny incoming
ufw default allow outgoing
ufw allow 22/tcp
ufw allow 80/tcp
ufw allow 443/tcp
ufw enable

# Disable root SSH login
sed -i 's/PermitRootLogin yes/PermitRootLogin no/' /etc/ssh/sshd_config
systemctl restart sshd

# Install fail2ban
apt install -y fail2ban
systemctl enable fail2ban
systemctl start fail2ban

echo "Server hardening complete!"
```

**Use case:** Run on every new server for consistent security

### 2. Backup Automation

**Example: Database backup script**

```bash
#!/bin/bash
# backup-database.sh

# Configuration
DB_NAME="myapp"
BACKUP_DIR="/backups/mysql"
DATE=$(date +%Y%m%d_%H%M%S)

# Create backup
mysqldump $DB_NAME > "$BACKUP_DIR/backup_${DATE}.sql"

# Compress backup
gzip "$BACKUP_DIR/backup_${DATE}.sql"

# Delete backups older than 7 days
find $BACKUP_DIR -name "backup_*.sql.gz" -mtime +7 -delete

echo "Backup completed: backup_${DATE}.sql.gz"
```

**Use case:** Run daily via cron for automated backups

### 3. Application Deployment

**Example: Deploy web application**

```bash
#!/bin/bash
# deploy-app.sh

# Pull latest code
cd /var/www/myapp
git pull origin main

# Install dependencies
npm install

# Build application
npm run build

# Restart service
systemctl restart myapp

# Run health check
sleep 5
curl -f http://localhost:3000/health || echo "Health check failed!"

echo "Deployment complete!"
```

**Use case:** Deploy updates consistently across multiple servers

### 4. System Monitoring

**Example: Check disk space and send alert**

```bash
#!/bin/bash
# check-disk-space.sh

# Get disk usage percentage
USAGE=$(df -h / | awk 'NR==2 {print $5}' | sed 's/%//')

# Alert if over 80%
if [ $USAGE -gt 80 ]; then
    echo "WARNING: Disk usage at ${USAGE}%"
    # Send email or Slack notification
else
    echo "Disk usage OK: ${USAGE}%"
fi
```

**Use case:** Run every hour to monitor disk space

### 5. Log Management

**Example: Rotate and clean old logs**

```bash
#!/bin/bash
# clean-logs.sh

LOG_DIR="/var/log/myapp"

# Compress logs older than 1 day
find $LOG_DIR -name "*.log" -mtime +1 -exec gzip {} \;

# Delete compressed logs older than 30 days
find $LOG_DIR -name "*.log.gz" -mtime +30 -delete

echo "Log cleanup complete"
```

**Use case:** Run daily to manage log files

### 6. User Management

**Example: Create multiple users**

```bash
#!/bin/bash
# create-users.sh

# Read users from file
while IFS= read -r username; do
    # Create user
    useradd -m -s /bin/bash $username

    # Set password
    echo "$username:changeme123" | chpasswd

    # Force password change on first login
    chage -d 0 $username

    echo "Created user: $username"
done < users.txt
```

**Use case:** Onboard multiple employees at once

### 7. Docker Container Management

**Example: Clean up Docker resources**

```bash
#!/bin/bash
# docker-cleanup.sh

echo "Stopping all containers..."
docker stop $(docker ps -q) 2>/dev/null

echo "Removing stopped containers..."
docker container prune -f

echo "Removing unused images..."
docker image prune -a -f

echo "Removing unused volumes..."
docker volume prune -f

echo "Cleanup complete!"
docker system df
```

**Use case:** Free up disk space weekly

---

## Part 4: Script Structure and Basics

### Anatomy of a Bash Script

```bash
#!/bin/bash
# ↑ Shebang: tells system this is a bash script

################################################################################
# Script Name: example.sh
# Description: What this script does
# Author: Your name
# Version: 1.0
################################################################################

# Comments explain what's happening
# Lines starting with # are ignored by Bash

# Variables store data
MY_NAME="John"
SERVER_COUNT=5

# Commands execute operations
echo "Hello, $MY_NAME"

# Conditional logic makes decisions
if [ $SERVER_COUNT -gt 3 ]; then
    echo "We have many servers"
fi

# Loops repeat operations
for i in 1 2 3; do
    echo "Server $i"
done

# Functions organize reusable code
my_function() {
    echo "This is a function"
}

# Call the function
my_function

# Exit with status code (0 = success)
exit 0
```

### The Shebang Line

**Always start scripts with:**
```bash
#!/bin/bash
```

**What it does:**
- Tells the system to use Bash to interpret the script
- Must be the very first line
- Enables running script with `./script.sh` instead of `bash script.sh`

**Without shebang:**
```bash
bash script.sh    # Must specify bash
```

**With shebang:**
```bash
./script.sh       # System knows to use bash
```

### Making Scripts Executable

```bash
# Create script
echo '#!/bin/bash' > hello.sh
echo 'echo "Hello World"' >> hello.sh

# Without executable permission (won't work)
./hello.sh
# Error: Permission denied

# Make executable
chmod +x hello.sh

# Now it works!
./hello.sh
# Output: Hello World
```

---

## Part 5: Essential Scripting Concepts

### Variables

**Variables store data you can reuse:**

```bash
#!/bin/bash

# Define variables (no spaces around =)
NAME="Alice"
AGE=30
SERVER_IP="192.168.1.100"

# Use variables with $
echo "Name: $NAME"
echo "Age: $AGE"
echo "Server: $SERVER_IP"

# Command output as variable
CURRENT_DATE=$(date +%Y-%m-%d)
DISK_USAGE=$(df -h / | awk 'NR==2 {print $5}')

echo "Date: $CURRENT_DATE"
echo "Disk Usage: $DISK_USAGE"
```

**Variable naming rules:**
- Start with letter or underscore
- Only letters, numbers, underscores
- UPPERCASE for constants by convention
- lowercase for regular variables

**Good names:**
```bash
DATABASE_NAME="myapp"
backup_dir="/backups"
user_count=10
```

**Bad names:**
```bash
d="myapp"          # Too vague
backup-dir="..."   # Hyphens not allowed
1_user="test"      # Can't start with number
```

### User Input

**Get input from user:**

```bash
#!/bin/bash

# Ask for input
echo "What is your name?"
read NAME

echo "Hello, $NAME!"

# Read with prompt on same line
read -p "Enter server IP: " SERVER_IP
echo "Connecting to $SERVER_IP..."

# Read password (hidden)
read -sp "Enter password: " PASSWORD
echo ""  # New line after hidden input
echo "Password saved"
```

### Conditional Statements (If/Then/Else)

**Make decisions in scripts:**

```bash
#!/bin/bash

# Simple if statement
if [ $USER = "root" ]; then
    echo "Running as root"
fi

# If-else
if [ -f /etc/nginx/nginx.conf ]; then
    echo "Nginx is installed"
else
    echo "Nginx not found"
    apt install -y nginx
fi

# If-elif-else (multiple conditions)
DISK_USAGE=$(df -h / | awk 'NR==2 {print $5}' | sed 's/%//')

if [ $DISK_USAGE -lt 50 ]; then
    echo "Disk space OK: ${DISK_USAGE}%"
elif [ $DISK_USAGE -lt 80 ]; then
    echo "Warning: Disk at ${DISK_USAGE}%"
else
    echo "Critical: Disk at ${DISK_USAGE}%"
    # Send alert
fi
```

**Common comparison operators:**

For numbers:
```bash
-eq    # Equal to
-ne    # Not equal to
-lt    # Less than
-le    # Less than or equal
-gt    # Greater than
-ge    # Greater than or equal
```

For strings:
```bash
=      # Equal
!=     # Not equal
-z     # Is empty
-n     # Is not empty
```

For files:
```bash
-f     # File exists
-d     # Directory exists
-r     # File is readable
-w     # File is writable
-x     # File is executable
```

**Examples:**
```bash
# Check if number
if [ $COUNT -gt 10 ]; then
    echo "More than 10"
fi

# Check if string
if [ "$NAME" = "admin" ]; then
    echo "Admin user"
fi

# Check if file exists
if [ -f /etc/nginx/nginx.conf ]; then
    echo "Config exists"
fi

# Check if directory exists
if [ -d /var/www ]; then
    echo "Directory exists"
fi
```

### Loops

**Repeat operations multiple times:**

**For loop (known iterations):**
```bash
#!/bin/bash

# Loop through list
for SERVER in web1 web2 web3 db1; do
    echo "Processing $SERVER"
    ssh $SERVER "uptime"
done

# Loop through numbers
for i in {1..5}; do
    echo "Iteration $i"
done

# Loop through command output
for FILE in $(ls *.txt); do
    echo "Processing $FILE"
    cat $FILE
done

# Loop through files (better way)
for FILE in *.log; do
    gzip "$FILE"
done
```

**While loop (condition-based):**
```bash
#!/bin/bash

# Loop while condition is true
COUNT=1
while [ $COUNT -le 5 ]; do
    echo "Count: $COUNT"
    COUNT=$((COUNT + 1))
done

# Read file line by line
while IFS= read -r LINE; do
    echo "Processing: $LINE"
done < input.txt

# Infinite loop (use with caution)
while true; do
    echo "Checking server..."
    curl -f http://localhost || echo "Server down!"
    sleep 60  # Wait 60 seconds
done
```

### Functions

**Organize reusable code:**

```bash
#!/bin/bash

# Define function
backup_database() {
    local DB_NAME=$1  # First argument
    local BACKUP_DIR=$2  # Second argument

    echo "Backing up $DB_NAME..."
    mysqldump $DB_NAME > "$BACKUP_DIR/${DB_NAME}_$(date +%Y%m%d).sql"
    echo "Backup complete!"
}

# Call function with arguments
backup_database "myapp" "/backups"
backup_database "wordpress" "/backups"

# Function with return value
check_service() {
    local SERVICE_NAME=$1

    if systemctl is-active --quiet $SERVICE_NAME; then
        return 0  # Success (service running)
    else
        return 1  # Failure (service stopped)
    fi
}

# Use function return value
if check_service nginx; then
    echo "Nginx is running"
else
    echo "Nginx is stopped"
    systemctl start nginx
fi
```

**Function benefits:**
- Reuse code without repetition
- Make scripts more organized
- Easier to test individual parts
- Improve readability

### Error Handling

**Handle errors gracefully:**

```bash
#!/bin/bash

# Exit on any error
set -e

# Exit on undefined variable
set -u

# Show commands as they execute (debugging)
set -x

# Combine all three
set -euxo pipefail

# Custom error handling
command_that_might_fail || {
    echo "Command failed!"
    exit 1
}

# Check exit code
apt update
if [ $? -eq 0 ]; then
    echo "Update successful"
else
    echo "Update failed"
    exit 1
fi

# Trap errors
trap 'echo "Error occurred on line $LINENO"' ERR

# Cleanup on exit
cleanup() {
    echo "Cleaning up..."
    rm -f /tmp/tempfile
}
trap cleanup EXIT
```

---

## Part 6: Practical Examples

### Example 1: Server Setup Script

**Complete server initialization:**

```bash
#!/bin/bash
################################################################################
# Server Setup Script
# Configures a new Ubuntu server with essential tools
################################################################################

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if running as root
if [ "$EUID" -ne 0 ]; then
    print_error "Please run as root (use sudo)"
    exit 1
fi

# Update system
echo "Updating system packages..."
apt update && apt upgrade -y
print_success "System updated"

# Install essential tools
echo "Installing essential tools..."
apt install -y \
    curl \
    wget \
    git \
    vim \
    htop \
    net-tools \
    ufw
print_success "Essential tools installed"

# Configure firewall
echo "Configuring firewall..."
ufw default deny incoming
ufw default allow outgoing
ufw allow 22/tcp
ufw --force enable
print_success "Firewall configured"

# Create non-root user
read -p "Create a non-root user? (y/n): " CREATE_USER
if [ "$CREATE_USER" = "y" ]; then
    read -p "Enter username: " USERNAME
    useradd -m -s /bin/bash $USERNAME
    usermod -aG sudo $USERNAME
    passwd $USERNAME
    print_success "User $USERNAME created"
fi

# Set hostname
read -p "Set hostname? (y/n): " SET_HOSTNAME
if [ "$SET_HOSTNAME" = "y" ]; then
    read -p "Enter hostname: " NEW_HOSTNAME
    hostnamectl set-hostname $NEW_HOSTNAME
    print_success "Hostname set to $NEW_HOSTNAME"
fi

echo ""
print_success "Server setup complete!"
echo "Recommended next steps:"
echo "1. Reboot the server"
echo "2. Configure SSH keys"
echo "3. Install Docker or other services"
```

### Example 2: Automated Backup Script

**Backup files and databases:**

```bash
#!/bin/bash
################################################################################
# Backup Script
# Backs up files and databases with rotation
################################################################################

# Configuration
BACKUP_DIR="/backups"
RETENTION_DAYS=7
DATE=$(date +%Y%m%d_%H%M%S)
LOG_FILE="/var/log/backup.log"

# Logging function
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a $LOG_FILE
}

log "Backup started"

# Create backup directory
mkdir -p $BACKUP_DIR

# Backup directories
log "Backing up /var/www..."
tar -czf "$BACKUP_DIR/www_${DATE}.tar.gz" /var/www 2>/dev/null
if [ $? -eq 0 ]; then
    log "Web files backed up successfully"
else
    log "WARNING: Web backup failed"
fi

# Backup database
if command -v mysql &> /dev/null; then
    log "Backing up databases..."

    # Get list of databases
    DATABASES=$(mysql -e "SHOW DATABASES;" | grep -Ev "(Database|information_schema|performance_schema|mysql|sys)")

    for DB in $DATABASES; do
        log "Backing up database: $DB"
        mysqldump $DB | gzip > "$BACKUP_DIR/${DB}_${DATE}.sql.gz"
    done

    log "Database backups complete"
fi

# Remove old backups
log "Removing backups older than $RETENTION_DAYS days..."
find $BACKUP_DIR -name "*.tar.gz" -mtime +$RETENTION_DAYS -delete
find $BACKUP_DIR -name "*.sql.gz" -mtime +$RETENTION_DAYS -delete

# Calculate backup size
TOTAL_SIZE=$(du -sh $BACKUP_DIR | awk '{print $1}')
log "Total backup size: $TOTAL_SIZE"

log "Backup completed successfully"

# Optional: Upload to cloud storage
# aws s3 sync $BACKUP_DIR s3://my-backup-bucket/
```

### Example 3: Service Health Checker

**Monitor services and restart if needed:**

```bash
#!/bin/bash
################################################################################
# Service Health Checker
# Monitors critical services and restarts if down
################################################################################

# Services to monitor
SERVICES=("nginx" "mysql" "docker")

# Notification settings
ALERT_EMAIL="admin@example.com"
SLACK_WEBHOOK="https://hooks.slack.com/..."

# Alert function
send_alert() {
    local SERVICE=$1
    local MESSAGE=$2

    echo "$MESSAGE"

    # Send email (requires mailutils)
    # echo "$MESSAGE" | mail -s "Service Alert: $SERVICE" $ALERT_EMAIL

    # Send Slack notification
    # curl -X POST $SLACK_WEBHOOK -d "{\"text\":\"$MESSAGE\"}"
}

# Check each service
for SERVICE in "${SERVICES[@]}"; do
    echo "Checking $SERVICE..."

    if systemctl is-active --quiet $SERVICE; then
        echo "✓ $SERVICE is running"
    else
        echo "✗ $SERVICE is down"

        # Attempt restart
        echo "Attempting to restart $SERVICE..."
        systemctl restart $SERVICE

        # Wait a moment
        sleep 5

        # Check if restart succeeded
        if systemctl is-active --quiet $SERVICE; then
            send_alert "$SERVICE" "✓ $SERVICE was down but successfully restarted"
        else
            send_alert "$SERVICE" "✗ CRITICAL: $SERVICE failed to restart!"
        fi
    fi
done

# Check disk space
DISK_USAGE=$(df -h / | awk 'NR==2 {print $5}' | sed 's/%//')
if [ $DISK_USAGE -gt 80 ]; then
    send_alert "Disk Space" "⚠ Disk usage at ${DISK_USAGE}%"
fi

# Check memory
MEMORY_USAGE=$(free | awk 'NR==2 {printf "%.0f", $3/$2 * 100}')
if [ $MEMORY_USAGE -gt 90 ]; then
    send_alert "Memory" "⚠ Memory usage at ${MEMORY_USAGE}%"
fi

echo "Health check complete"
```

---

## Part 7: Best Practices

### 1. Always Use Shebang

```bash
#!/bin/bash
# First line of every script
```

### 2. Add Script Headers

```bash
#!/bin/bash
################################################################################
# Script Name: backup.sh
# Description: Backs up important files and databases
# Author: John Doe
# Created: 2024-01-15
# Modified: 2024-03-20
# Version: 2.1
################################################################################
```

### 3. Use Comments Liberally

```bash
# Good: Explain WHY, not just WHAT
# Check if running as root because we need to install packages
if [ "$EUID" -ne 0 ]; then
    exit 1
fi

# Less helpful: Just states the obvious
# Check if root
if [ "$EUID" -ne 0 ]; then
    exit 1
fi
```

### 4. Use Meaningful Variable Names

```bash
# Good
DATABASE_NAME="wordpress"
BACKUP_DIRECTORY="/var/backups"
MAX_RETRIES=3

# Bad
d="wordpress"
dir="/var/backups"
x=3
```

### 5. Quote Variables

```bash
# Always quote variables to handle spaces
FILE_NAME="my file.txt"

# Wrong - will fail with spaces
cat $FILE_NAME

# Correct
cat "$FILE_NAME"

# Also quote in conditions
if [ "$USER" = "root" ]; then
    echo "Root user"
fi
```

### 6. Check Exit Codes

```bash
# Check if command succeeded
apt update
if [ $? -ne 0 ]; then
    echo "Update failed"
    exit 1
fi

# Or use && for success, || for failure
apt update && echo "Success" || echo "Failed"

# Use set -e to exit on any error
set -e
apt update  # Script exits automatically if this fails
```

### 7. Use Functions for Repetitive Tasks

```bash
# Instead of repeating code
echo "Installing nginx..."
apt install -y nginx
systemctl start nginx
systemctl enable nginx

echo "Installing mysql..."
apt install -y mysql-server
systemctl start mysql
systemctl enable mysql

# Use a function
install_and_enable() {
    local SERVICE=$1
    echo "Installing $SERVICE..."
    apt install -y $SERVICE
    systemctl start $SERVICE
    systemctl enable $SERVICE
}

install_and_enable nginx
install_and_enable mysql-server
```

### 8. Make Scripts Idempotent

**Idempotent = Safe to run multiple times**

```bash
# Bad: Fails if directory exists
mkdir /etc/myapp

# Good: Only creates if doesn't exist
mkdir -p /etc/myapp

# Bad: Appends every time script runs
echo "export PATH=$PATH:/opt/bin" >> ~/.bashrc

# Good: Only adds if not already present
if ! grep -q "/opt/bin" ~/.bashrc; then
    echo "export PATH=$PATH:/opt/bin" >> ~/.bashrc
fi
```

### 9. Validate Input

```bash
# Check if required arguments provided
if [ $# -lt 1 ]; then
    echo "Usage: $0 <database_name>"
    exit 1
fi

DATABASE=$1

# Validate input format
if [[ ! "$DATABASE" =~ ^[a-zA-Z0-9_]+$ ]]; then
    echo "Error: Database name can only contain letters, numbers, and underscores"
    exit 1
fi

# Check if file exists before processing
if [ ! -f "$CONFIG_FILE" ]; then
    echo "Error: Config file not found: $CONFIG_FILE"
    exit 1
fi
```

### 10. Use Shellcheck

**Shellcheck finds bugs in scripts:**

```bash
# Install shellcheck
apt install shellcheck

# Check your script
shellcheck myscript.sh

# Example warning:
# Line 10: quote this to prevent word splitting
```

---

## Part 8: Debugging Scripts

### Enable Debug Mode

```bash
# Show commands as they execute
bash -x script.sh

# Or add to script
#!/bin/bash
set -x  # Enable debug mode

# Debug specific section
set -x
# Commands to debug
command1
command2
set +x  # Disable debug mode
```

### Add Debug Output

```bash
#!/bin/bash

DEBUG=true

debug() {
    if [ "$DEBUG" = true ]; then
        echo "[DEBUG] $1"
    fi
}

debug "Starting script..."
debug "User: $USER"
debug "Directory: $(pwd)"

# Your script logic
```

### Common Debugging Techniques

```bash
# Print variable values
echo "DEBUG: DATABASE=$DATABASE"

# Check if command exists
if ! command -v docker &> /dev/null; then
    echo "Docker not installed"
fi

# Verify file exists
if [ ! -f "/etc/nginx/nginx.conf" ]; then
    echo "Nginx config not found"
fi

# Check exit codes
some_command
echo "Exit code: $?"

# Use set -e to stop on errors
set -e  # Exit immediately if any command fails
```

---

## Part 9: Running Scripts Automatically

### Cron Jobs (Scheduled Tasks)

**Cron runs scripts at specified times:**

```bash
# Edit crontab
crontab -e

# Cron syntax:
# * * * * * command
# │ │ │ │ │
# │ │ │ │ └─── Day of week (0-7, Sunday=0 or 7)
# │ │ │ └───── Month (1-12)
# │ │ └─────── Day of month (1-31)
# │ └───────── Hour (0-23)
# └─────────── Minute (0-59)

# Examples:
# Run backup every day at 2 AM
0 2 * * * /root/backup.sh

# Run health check every 5 minutes
*/5 * * * * /root/health-check.sh

# Run cleanup every Sunday at 3 AM
0 3 * * 0 /root/cleanup.sh

# Run on the 1st of every month
0 0 1 * * /root/monthly-report.sh
```

**Helpful cron examples:**

```bash
# Every hour
0 * * * * /path/to/script.sh

# Every day at midnight
0 0 * * * /path/to/script.sh

# Every Monday at 9 AM
0 9 * * 1 /path/to/script.sh

# Every 15 minutes
*/15 * * * * /path/to/script.sh

# Twice a day (6 AM and 6 PM)
0 6,18 * * * /path/to/script.sh
```

**Cron with logging:**

```bash
# Redirect output to log file
0 2 * * * /root/backup.sh >> /var/log/backup.log 2>&1

# Send email on errors only
0 2 * * * /root/backup.sh > /dev/null 2>&1 || mail -s "Backup failed" admin@example.com
```

### Systemd Services

**Run scripts as system services:**

```bash
# Create service file: /etc/systemd/system/myapp.service
[Unit]
Description=My Application
After=network.target

[Service]
Type=simple
User=www-data
WorkingDirectory=/opt/myapp
ExecStart=/opt/myapp/start.sh
Restart=always

[Install]
WantedBy=multi-user.target

# Enable and start service
systemctl daemon-reload
systemctl enable myapp
systemctl start myapp

# Check status
systemctl status myapp

# View logs
journalctl -u myapp -f
```

---

## Part 10: Script Security

### Security Best Practices

**1. Never Hardcode Passwords**

```bash
# Bad
PASSWORD="mysecretpassword123"
mysql -u root -p$PASSWORD

# Good - read from environment
mysql -u root -p"${MYSQL_PASSWORD}"

# Or read from secure file
PASSWORD=$(cat /etc/myapp/db.password)

# Or prompt user
read -sp "Enter password: " PASSWORD
```

**2. Validate All Input**

```bash
# Check user input
read -p "Enter username: " USERNAME

# Validate format
if [[ ! "$USERNAME" =~ ^[a-zA-Z0-9_]+$ ]]; then
    echo "Invalid username"
    exit 1
fi

# Prevent injection attacks
# Bad - user can inject commands
eval "useradd $USERNAME"

# Good - properly quoted
useradd "$USERNAME"
```

**3. Use Absolute Paths**

```bash
# Bad - relies on PATH
nginx -t

# Good - absolute path
/usr/sbin/nginx -t

# Set PATH explicitly
PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
```

**4. Set Proper Permissions**

```bash
# Scripts with sensitive data
chmod 700 script.sh  # Owner only
chown root:root script.sh

# Scripts for everyone
chmod 755 script.sh  # Anyone can execute
```

**5. Check for Root Safely**

```bash
# Check if running as root
if [ "$EUID" -ne 0 ]; then
    echo "This script must be run as root"
    exit 1
fi
```

---

## Part 11: Learning Resources

### Official Documentation

- [Bash Reference Manual](https://www.gnu.org/software/bash/manual/) - Complete Bash documentation
- [Advanced Bash-Scripting Guide](https://tldp.org/LDP/abs/html/) - Comprehensive guide
- [Bash Hackers Wiki](https://wiki.bash-hackers.org/) - Community knowledge

### Interactive Learning

- [ShellCheck](https://www.shellcheck.net/) - Online script validator
- [Explain Shell](https://explainshell.com/) - Breaks down commands
- [Learn Shell](https://www.learnshell.org/) - Interactive tutorials

### Practice Sites

- [HackerRank Shell](https://www.hackerrank.com/domains/shell) - Shell scripting challenges
- [Exercism Bash Track](https://exercism.org/tracks/bash) - Practice exercises
- [OverTheWire Bandit](https://overthewire.org/wargames/bandit/) - Linux/Bash challenges

### Video Tutorials

- [Bash Scripting Tutorial for Beginners](https://www.youtube.com/watch?v=tK9Oc6AEnR4) - Complete course
- [Shell Scripting Crash Course](https://www.youtube.com/watch?v=v-F3YLd6oMw) - Quick intro
- [Advanced Bash Scripting](https://www.youtube.com/watch?v=emhouufDnB4) - Advanced techniques

### Books

- "The Linux Command Line" by William Shotts - Beginner friendly
- "Bash Cookbook" by Carl Albing & JP Vossen - Practical recipes
- "Wicked Cool Shell Scripts" by Dave Taylor - Fun examples

---

## Part 12: Our Week 2 Setup Script Explained

### Why We Created the Setup Script

**Manual process (from Week 2 guides):**
- 5 separate markdown guides
- 200+ individual commands
- 2-3 hours of work
- High chance of typos
- Easy to miss a step

**With setup script:**
- One command: `bash setup-week2-infrastructure.sh`
- 5-10 minutes
- Consistent results every time
- Thoroughly tested
- Well documented

### What Makes Our Script Good

**1. Extensive Comments**
```bash
# Every section explains:
# - What it does
# - Why it's necessary
# - What to expect
```

**2. Error Handling**
```bash
set -e  # Exit on any error
# Won't continue if something fails
```

**3. User Feedback**
```bash
print_success "Docker installed successfully"
print_error "Failed to start service"
# Clear colored output
```

**4. Verification**
```bash
# Tests everything before finishing
if docker ps | grep -q nginx-proxy-manager; then
    print_success "NPM is running"
fi
```

**5. Idempotent Operations**
```bash
# Safe to run multiple times
docker volume create npm-data || print_warning "Volume already exists"
```

### Key Scripting Techniques Used

**Functions for Organization:**
```bash
print_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}
# Reused throughout script
```

**Variables for Configuration:**
```bash
CODE_SERVER_PASSWORD=$(openssl rand -base64 24)
# Generated once, used multiple times
```

**Loops for Cleanup:**
```bash
for pkg in docker.io docker-doc docker-compose; do
    apt remove -y $pkg 2>/dev/null || true
done
```

**Conditionals for Logic:**
```bash
if docker ps | grep -q nginx-proxy-manager; then
    print_success "NPM is running"
else
    print_error "Failed to start NPM"
fi
```

---

## Summary

### Why Bash Scripting Matters

**Automation:**
- Do more with less effort
- Eliminate repetitive tasks
- Scale operations easily

**Consistency:**
- Same result every time
- No human errors
- Reproducible deployments

**Efficiency:**
- Save hours of manual work
- Reduce deployment time
- Focus on important tasks

**Documentation:**
- Scripts serve as documentation
- Show exactly what was done
- Easy to share and maintain

### Skills You've Learned

✅ **What bash scripts are**
- Automated command sequences
- Reusable, testable, shareable

✅ **Why scripting is better**
- Saves time and reduces errors
- Enables automation at scale

✅ **Common use cases**
- Server setup, backups, monitoring
- Deployments, user management

✅ **Essential concepts**
- Variables, loops, conditionals
- Functions, error handling

✅ **Best practices**
- Comments, validation, security
- Idempotency, debugging

✅ **Real-world examples**
- Setup scripts, health checks
- Automated backups, cron jobs

### Next Steps

**Practice:**
1. Start with simple scripts
2. Automate your daily tasks
3. Study existing scripts (like our setup script)
4. Gradually add more complexity

**Common First Scripts:**
- System update automation
- Log file cleanup
- Backup automation
- Service monitoring

**Resources:**
- Read the Week 2 setup script
- Try modifying it for your needs
- Use ShellCheck to validate
- Join scripting communities

---

## Quick Reference

### Script Template

```bash
#!/bin/bash
################################################################################
# Script Name: template.sh
# Description: What this script does
# Author: Your name
# Version: 1.0
################################################################################

set -e  # Exit on error

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'

# Functions
print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Main script logic
main() {
    print_success "Script started"

    # Your code here

    print_success "Script completed"
}

# Run main function
main "$@"
```

### Essential Commands

```bash
# Make script executable
chmod +x script.sh

# Run script
./script.sh
bash script.sh

# Debug script
bash -x script.sh

# Check script syntax
bash -n script.sh

# Validate with shellcheck
shellcheck script.sh
```

### Common Patterns

```bash
# Check if root
[ "$EUID" -ne 0 ] && echo "Run as root" && exit 1

# Check if file exists
[ ! -f file.txt ] && echo "File not found" && exit 1

# Loop through files
for file in *.txt; do
    echo "Processing $file"
done

# Get user input
read -p "Continue? (y/n): " answer
[ "$answer" != "y" ] && exit 0

# Function with arguments
my_function() {
    local arg1=$1
    echo "Argument: $arg1"
}
```

---

**You now understand why bash scripting is essential and how to write effective scripts!**

**Remember:** Start simple, practice often, and gradually build complexity. Every system administrator and DevOps engineer relies on bash scripts daily.

`Mastering bash scripting is one of the most valuable skills in Linux system administration` {{ tip }}
