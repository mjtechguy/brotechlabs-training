# Appendix E: Scripting and Automation Library

## System Administration Scripts

### System Information Collector
```bash
#!/bin/bash
# system-info.sh - Comprehensive system information collector

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored headers
print_header() {
    echo -e "${BLUE}===============================================${NC}"
    echo -e "${GREEN}$1${NC}"
    echo -e "${BLUE}===============================================${NC}"
}

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# System Information
print_header "SYSTEM INFORMATION"
echo "Hostname: $(hostname -f)"
echo "Operating System: $(lsb_release -ds 2>/dev/null || cat /etc/os-release | grep PRETTY_NAME | cut -d'=' -f2 | tr -d '"')"
echo "Kernel: $(uname -r)"
echo "Architecture: $(uname -m)"
echo "Uptime: $(uptime -p)"
echo "Current Date/Time: $(date '+%Y-%m-%d %H:%M:%S %Z')"
echo "Timezone: $(timedatectl | grep "Time zone" | awk '{print $3}')"
echo ""

# Hardware Information
print_header "HARDWARE INFORMATION"
echo "CPU Model: $(lscpu | grep "Model name" | cut -d':' -f2 | xargs)"
echo "CPU Cores: $(nproc)"
echo "CPU MHz: $(lscpu | grep "CPU MHz" | cut -d':' -f2 | xargs)"
echo "Total Memory: $(free -h | awk '/^Mem:/ {print $2}')"
echo "Used Memory: $(free -h | awk '/^Mem:/ {print $3}')"
echo "Free Memory: $(free -h | awk '/^Mem:/ {print $4}')"
echo "Swap Total: $(free -h | awk '/^Swap:/ {print $2}')"
echo "Swap Used: $(free -h | awk '/^Swap:/ {print $3}')"
echo ""

# Disk Information
print_header "DISK USAGE"
df -h | grep -E '^/dev/' | awk '{printf "%-20s %8s %8s %8s %5s %s\n", $1, $2, $3, $4, $5, $6}'
echo ""

# Network Information
print_header "NETWORK INFORMATION"
for interface in $(ip -o link show | awk -F': ' '{print $2}' | grep -v lo); do
    echo "Interface: $interface"
    ip addr show $interface | grep "inet " | awk '{print "  IPv4: " $2}'
    ip addr show $interface | grep "inet6" | awk '{print "  IPv6: " $2}'
    echo "  MAC: $(ip link show $interface | grep ether | awk '{print $2}')"
    echo "  Status: $(ip link show $interface | grep -o "state [A-Z]*" | awk '{print $2}')"
    echo ""
done

echo "Default Gateway: $(ip route | grep default | awk '{print $3}')"
echo "DNS Servers:"
grep nameserver /etc/resolv.conf | awk '{print "  " $2}'
echo ""

# Service Status
print_header "CRITICAL SERVICES STATUS"
services=("ssh" "ufw" "nginx" "apache2" "mysql" "postgresql" "docker" "cron")
for service in "${services[@]}"; do
    if systemctl list-units --all | grep -q "$service.service"; then
        status=$(systemctl is-active $service 2>/dev/null)
        if [ "$status" = "active" ]; then
            echo -e "$service: ${GREEN}$status${NC}"
        else
            echo -e "$service: ${RED}$status${NC}"
        fi
    fi
done
echo ""

# User Information
print_header "USER INFORMATION"
echo "Current User: $(whoami)"
echo "User Groups: $(groups)"
echo "Sudo Privileges: $(sudo -n true 2>/dev/null && echo "Yes" || echo "No")"
echo "Last Login:"
last -5 | head -5
echo ""

# Security Information
print_header "SECURITY STATUS"
echo "Firewall Status: $(ufw status | head -1)"
echo "SELinux Status: $(command_exists getenforce && getenforce || echo "Not installed")"
echo "AppArmor Status: $(command_exists aa-status && aa-status --enabled && echo "Enabled" || echo "Not enabled")"
echo "Failed Login Attempts (last 10):"
grep "authentication failure" /var/log/auth.log 2>/dev/null | tail -10 || echo "  No recent failures"
echo ""

# Package Updates
print_header "PACKAGE UPDATE STATUS"
if command_exists apt; then
    updates=$(apt list --upgradable 2>/dev/null | grep -c upgradable)
    if [ "$updates" -gt 0 ]; then
        echo -e "${YELLOW}$updates packages can be upgraded${NC}"
        echo "Run 'apt list --upgradable' for details"
    else
        echo -e "${GREEN}System is up to date${NC}"
    fi
fi
echo ""

# Top Processes
print_header "TOP 10 PROCESSES BY CPU"
ps aux --sort=-%cpu | head -11
echo ""

print_header "TOP 10 PROCESSES BY MEMORY"
ps aux --sort=-%mem | head -11
```

### User Account Management
```bash
#!/bin/bash
# user-management.sh - Comprehensive user account management

set -euo pipefail

# Configuration
LOG_FILE="/var/log/user-management.log"
BACKUP_DIR="/var/backups/user-accounts"
DEFAULT_SHELL="/bin/bash"
PASSWORD_MIN_LENGTH=12
PASSWORD_MAX_AGE=90
PASSWORD_WARN_AGE=14

# Logging function
log_action() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

# Create backup directory if it doesn't exist
mkdir -p "$BACKUP_DIR"

# Function to backup user data
backup_user() {
    local username=$1
    local backup_file="$BACKUP_DIR/${username}_$(date +%Y%m%d_%H%M%S).tar.gz"

    if [ -d "/home/$username" ]; then
        tar -czf "$backup_file" -C /home "$username" 2>/dev/null || true
        log_action "Backed up user $username to $backup_file"
    fi
}

# Function to create user
create_user() {
    local username=$1
    local fullname=$2
    local groups=${3:-""}

    # Check if user exists
    if id "$username" &>/dev/null; then
        echo "User $username already exists"
        return 1
    fi

    # Create user
    useradd -m \
        -s "$DEFAULT_SHELL" \
        -c "$fullname" \
        "$username"

    # Add to additional groups
    if [ -n "$groups" ]; then
        IFS=',' read -ra GROUP_ARRAY <<< "$groups"
        for group in "${GROUP_ARRAY[@]}"; do
            usermod -aG "$group" "$username"
        done
    fi

    # Set password policy
    chage -m 1 -M "$PASSWORD_MAX_AGE" -W "$PASSWORD_WARN_AGE" "$username"

    # Create SSH directory
    mkdir -p "/home/$username/.ssh"
    chmod 700 "/home/$username/.ssh"
    touch "/home/$username/.ssh/authorized_keys"
    chmod 600 "/home/$username/.ssh/authorized_keys"
    chown -R "$username:$username" "/home/$username/.ssh"

    # Generate initial password
    initial_password=$(openssl rand -base64 "$PASSWORD_MIN_LENGTH")
    echo "$username:$initial_password" | chpasswd

    # Force password change on first login
    passwd -e "$username"

    log_action "Created user $username with groups: $groups"
    echo "User $username created successfully"
    echo "Initial password: $initial_password"
    echo "User must change password on first login"
}

# Function to delete user
delete_user() {
    local username=$1
    local remove_home=${2:-false}

    # Check if user exists
    if ! id "$username" &>/dev/null; then
        echo "User $username does not exist"
        return 1
    fi

    # Backup user data first
    backup_user "$username"

    # Kill all processes owned by user
    pkill -u "$username" 2>/dev/null || true

    # Remove user
    if [ "$remove_home" = true ]; then
        userdel -r "$username"
        log_action "Deleted user $username and removed home directory"
    else
        userdel "$username"
        log_action "Deleted user $username (home directory preserved)"
    fi

    echo "User $username deleted successfully"
}

# Function to lock user
lock_user() {
    local username=$1

    # Lock the account
    usermod -L "$username"

    # Expire the account
    chage -E 0 "$username"

    # Kill all processes
    pkill -u "$username" 2>/dev/null || true

    log_action "Locked user account: $username"
    echo "User $username locked successfully"
}

# Function to unlock user
unlock_user() {
    local username=$1

    # Unlock the account
    usermod -U "$username"

    # Remove expiration
    chage -E -1 "$username"

    log_action "Unlocked user account: $username"
    echo "User $username unlocked successfully"
}

# Function to reset password
reset_password() {
    local username=$1

    # Generate new password
    new_password=$(openssl rand -base64 "$PASSWORD_MIN_LENGTH")

    # Set new password
    echo "$username:$new_password" | chpasswd

    # Force password change on next login
    passwd -e "$username"

    log_action "Reset password for user: $username"
    echo "Password reset for $username"
    echo "New password: $new_password"
    echo "User must change password on next login"
}

# Function to add SSH key
add_ssh_key() {
    local username=$1
    local ssh_key=$2

    # Validate SSH key format
    if ! echo "$ssh_key" | ssh-keygen -l -f - &>/dev/null; then
        echo "Invalid SSH key format"
        return 1
    fi

    # Add key to authorized_keys
    echo "$ssh_key" >> "/home/$username/.ssh/authorized_keys"
    chmod 600 "/home/$username/.ssh/authorized_keys"
    chown "$username:$username" "/home/$username/.ssh/authorized_keys"

    log_action "Added SSH key for user: $username"
    echo "SSH key added successfully for $username"
}

# Function to audit users
audit_users() {
    echo "=== User Account Audit ==="
    echo ""

    # Users with UID 0
    echo "Users with UID 0 (root privileges):"
    awk -F: '$3 == 0 {print $1}' /etc/passwd
    echo ""

    # Users with empty passwords
    echo "Users with empty passwords:"
    awk -F: '$2 == "" {print $1}' /etc/shadow
    echo ""

    # Users without password expiry
    echo "Users without password expiry:"
    while IFS=: read -r user pass rest; do
        if [ "$pass" != "*" ] && [ "$pass" != "!" ]; then
            expiry=$(chage -l "$user" 2>/dev/null | grep "Password expires" | cut -d: -f2)
            if [[ $expiry == *"never"* ]]; then
                echo "  $user"
            fi
        fi
    done < /etc/shadow
    echo ""

    # Recently modified user files
    echo "Recently modified user files:"
    find /etc -name passwd -o -name shadow -o -name group -o -name sudoers \
        -mtime -7 -ls 2>/dev/null
    echo ""

    # Users with sudo access
    echo "Users with sudo access:"
    grep -E '^[^#]*ALL=' /etc/sudoers /etc/sudoers.d/* 2>/dev/null | cut -d: -f2
    echo ""
}

# Main menu
case "${1:-}" in
    create)
        create_user "${2:-}" "${3:-}" "${4:-}"
        ;;
    delete)
        delete_user "${2:-}" "${3:-false}"
        ;;
    lock)
        lock_user "${2:-}"
        ;;
    unlock)
        unlock_user "${2:-}"
        ;;
    reset-password)
        reset_password "${2:-}"
        ;;
    add-ssh-key)
        add_ssh_key "${2:-}" "${3:-}"
        ;;
    audit)
        audit_users
        ;;
    *)
        echo "Usage: $0 {create|delete|lock|unlock|reset-password|add-ssh-key|audit} [options]"
        echo ""
        echo "Commands:"
        echo "  create <username> <fullname> [groups]  - Create new user"
        echo "  delete <username> [true|false]         - Delete user (true removes home)"
        echo "  lock <username>                        - Lock user account"
        echo "  unlock <username>                      - Unlock user account"
        echo "  reset-password <username>              - Reset user password"
        echo "  add-ssh-key <username> <key>          - Add SSH public key"
        echo "  audit                                  - Audit user accounts"
        exit 1
        ;;
esac
```

### Service Health Monitor
```bash
#!/bin/bash
# service-monitor.sh - Monitor critical services and restart if needed

# Configuration
SERVICES=("nginx" "mysql" "ssh" "cron" "docker")
MAX_RESTART_ATTEMPTS=3
RESTART_DELAY=30
ALERT_EMAIL="admin@example.com"
LOG_FILE="/var/log/service-monitor.log"
STATE_FILE="/var/run/service-monitor.state"

# Load previous state
declare -A restart_counts
if [ -f "$STATE_FILE" ]; then
    source "$STATE_FILE"
fi

# Logging function
log_message() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

# Alert function
send_alert() {
    local subject=$1
    local message=$2

    # Send email alert
    echo "$message" | mail -s "$subject" "$ALERT_EMAIL"

    # Log alert
    log_message "ALERT: $subject - $message"
}

# Check service function
check_service() {
    local service=$1
    local status

    # Check if service exists
    if ! systemctl list-units --all | grep -q "$service.service"; then
        return 0
    fi

    # Check service status
    if systemctl is-active "$service" >/dev/null 2>&1; then
        # Service is running, reset restart count
        restart_counts[$service]=0
        return 0
    else
        # Service is not running
        return 1
    fi
}

# Restart service function
restart_service() {
    local service=$1
    local attempt=${restart_counts[$service]:-0}

    # Check if we've exceeded max restart attempts
    if [ "$attempt" -ge "$MAX_RESTART_ATTEMPTS" ]; then
        send_alert "Service $service failed" \
            "Service $service has failed $MAX_RESTART_ATTEMPTS times and will not be restarted automatically"
        return 1
    fi

    # Attempt restart
    log_message "Attempting to restart $service (attempt $((attempt + 1)))"
    systemctl restart "$service"

    # Wait for service to start
    sleep "$RESTART_DELAY"

    # Check if restart was successful
    if systemctl is-active "$service" >/dev/null 2>&1; then
        log_message "Successfully restarted $service"
        send_alert "Service $service restarted" \
            "Service $service was down and has been successfully restarted"
        restart_counts[$service]=0
        return 0
    else
        # Increment restart count
        restart_counts[$service]=$((attempt + 1))
        log_message "Failed to restart $service (attempt $((attempt + 1)))"
        return 1
    fi
}

# Health check function
perform_health_check() {
    local service=$1

    case "$service" in
        nginx|apache2)
            # Check web server
            curl -f http://localhost/ >/dev/null 2>&1
            ;;
        mysql)
            # Check MySQL
            mysqladmin ping >/dev/null 2>&1
            ;;
        postgresql)
            # Check PostgreSQL
            sudo -u postgres pg_isready >/dev/null 2>&1
            ;;
        docker)
            # Check Docker
            docker info >/dev/null 2>&1
            ;;
        *)
            # Default check - just verify process is running
            return 0
            ;;
    esac
}

# Main monitoring loop
main() {
    log_message "Starting service monitoring"

    for service in "${SERVICES[@]}"; do
        # Check if service is running
        if ! check_service "$service"; then
            log_message "Service $service is not running"
            restart_service "$service"
        else
            # Service is running, perform health check
            if ! perform_health_check "$service"; then
                log_message "Service $service failed health check"
                restart_service "$service"
            fi
        fi
    done

    # Save state
    declare -p restart_counts > "$STATE_FILE"
}

# Run main function
main
```

## Monitoring and Performance Scripts

### Performance Monitor
```bash
#!/bin/bash
# performance-monitor.sh - Real-time performance monitoring

# Configuration
INTERVAL=5
LOG_DIR="/var/log/performance"
ALERT_THRESHOLD_CPU=80
ALERT_THRESHOLD_MEMORY=90
ALERT_THRESHOLD_DISK=90
ALERT_THRESHOLD_LOAD=8

# Create log directory
mkdir -p "$LOG_DIR"

# Function to get CPU usage
get_cpu_usage() {
    top -bn1 | grep "Cpu(s)" | awk '{print 100 - $8}'
}

# Function to get memory usage
get_memory_usage() {
    free | grep Mem | awk '{print ($3/$2) * 100}'
}

# Function to get disk usage
get_disk_usage() {
    df -h / | awk 'NR==2 {print substr($5, 1, length($5)-1)}'
}

# Function to get load average
get_load_average() {
    uptime | awk -F'load average:' '{print $2}' | awk '{print $1}' | tr -d ','
}

# Function to get network statistics
get_network_stats() {
    local interface=${1:-eth0}
    local rx_bytes_before=$(cat /sys/class/net/$interface/statistics/rx_bytes 2>/dev/null || echo 0)
    local tx_bytes_before=$(cat /sys/class/net/$interface/statistics/tx_bytes 2>/dev/null || echo 0)
    sleep 1
    local rx_bytes_after=$(cat /sys/class/net/$interface/statistics/rx_bytes 2>/dev/null || echo 0)
    local tx_bytes_after=$(cat /sys/class/net/$interface/statistics/tx_bytes 2>/dev/null || echo 0)

    local rx_rate=$((rx_bytes_after - rx_bytes_before))
    local tx_rate=$((tx_bytes_after - tx_bytes_before))

    echo "$rx_rate $tx_rate"
}

# Function to check thresholds and alert
check_thresholds() {
    local cpu=$1
    local memory=$2
    local disk=$3
    local load=$4

    local alert_message=""

    if (( $(echo "$cpu > $ALERT_THRESHOLD_CPU" | bc -l) )); then
        alert_message="${alert_message}CPU usage is high: ${cpu}%\n"
    fi

    if (( $(echo "$memory > $ALERT_THRESHOLD_MEMORY" | bc -l) )); then
        alert_message="${alert_message}Memory usage is high: ${memory}%\n"
    fi

    if (( $(echo "$disk > $ALERT_THRESHOLD_DISK" | bc -l) )); then
        alert_message="${alert_message}Disk usage is high: ${disk}%\n"
    fi

    if (( $(echo "$load > $ALERT_THRESHOLD_LOAD" | bc -l) )); then
        alert_message="${alert_message}Load average is high: ${load}\n"
    fi

    if [ -n "$alert_message" ]; then
        echo -e "ALERT: System performance issues detected:\n$alert_message"
        # Send alert (email, slack, etc.)
    fi
}

# Function to format bytes
format_bytes() {
    local bytes=$1
    if [ $bytes -lt 1024 ]; then
        echo "${bytes}B/s"
    elif [ $bytes -lt 1048576 ]; then
        echo "$((bytes / 1024))KB/s"
    else
        echo "$((bytes / 1048576))MB/s"
    fi
}

# Main monitoring loop
monitor() {
    clear
    echo "=== System Performance Monitor ==="
    echo "Press Ctrl+C to exit"
    echo ""

    while true; do
        # Get metrics
        cpu=$(get_cpu_usage)
        memory=$(get_memory_usage)
        disk=$(get_disk_usage)
        load=$(get_load_average)
        network=($(get_network_stats))
        rx_rate=${network[0]}
        tx_rate=${network[1]}

        # Clear screen and display header
        clear
        echo "=== System Performance Monitor ==="
        echo "Time: $(date '+%Y-%m-%d %H:%M:%S')"
        echo "================================="
        echo ""

        # Display metrics
        printf "CPU Usage:      %6.2f%%\n" "$cpu"
        printf "Memory Usage:   %6.2f%%\n" "$memory"
        printf "Disk Usage:     %6d%%\n" "$disk"
        printf "Load Average:   %6s\n" "$load"
        printf "Network RX:     %10s\n" "$(format_bytes $rx_rate)"
        printf "Network TX:     %10s\n" "$(format_bytes $tx_rate)"
        echo ""

        # Top processes by CPU
        echo "Top 5 Processes by CPU:"
        ps aux --sort=-%cpu | head -6 | tail -5 | awk '{printf "  %-20s %5s%%\n", $11, $3}'
        echo ""

        # Top processes by Memory
        echo "Top 5 Processes by Memory:"
        ps aux --sort=-%mem | head -6 | tail -5 | awk '{printf "  %-20s %5s%%\n", $11, $4}'

        # Check thresholds
        check_thresholds "$cpu" "$memory" "$disk" "$load"

        # Log metrics
        echo "$(date '+%Y-%m-%d %H:%M:%S'),${cpu},${memory},${disk},${load},${rx_rate},${tx_rate}" \
            >> "$LOG_DIR/metrics.csv"

        # Wait for next interval
        sleep "$INTERVAL"
    done
}

# Run monitor
monitor
```

### Log Analyzer
```bash
#!/bin/bash
# log-analyzer.sh - Analyze various log files for issues

# Configuration
LOG_DIRS=("/var/log")
REPORT_FILE="/tmp/log-analysis-$(date +%Y%m%d-%H%M%S).txt"
DAYS_TO_ANALYZE=7

# Patterns to search for
ERROR_PATTERNS=(
    "error"
    "failed"
    "failure"
    "critical"
    "alert"
    "emergency"
    "panic"
    "fatal"
)

WARNING_PATTERNS=(
    "warning"
    "warn"
    "deprecated"
    "notice"
)

SECURITY_PATTERNS=(
    "authentication failure"
    "unauthorized"
    "permission denied"
    "invalid user"
    "POSSIBLE BREAK-IN ATTEMPT"
    "segfault"
)

# Function to analyze log file
analyze_log() {
    local logfile=$1
    local pattern=$2
    local label=$3

    if [ ! -f "$logfile" ]; then
        return
    fi

    local count=$(grep -i "$pattern" "$logfile" 2>/dev/null | wc -l)

    if [ $count -gt 0 ]; then
        echo "  $label: $count occurrences in $(basename $logfile)"

        # Show recent examples
        echo "    Recent examples:"
        grep -i "$pattern" "$logfile" 2>/dev/null | tail -3 | while read -r line; do
            echo "      ${line:0:100}..."
        done
    fi
}

# Function to analyze authentication logs
analyze_auth_logs() {
    echo "=== Authentication Analysis ===" >> "$REPORT_FILE"

    # Failed login attempts
    echo "Failed Login Attempts:" >> "$REPORT_FILE"
    grep "authentication failure" /var/log/auth.log 2>/dev/null | \
        awk '{print $NF}' | sort | uniq -c | sort -rn | head -10 >> "$REPORT_FILE"

    # Successful sudo commands
    echo -e "\nSuccessful Sudo Commands:" >> "$REPORT_FILE"
    grep "sudo.*COMMAND=" /var/log/auth.log 2>/dev/null | \
        tail -20 >> "$REPORT_FILE"

    # SSH connection attempts
    echo -e "\nSSH Connection Summary:" >> "$REPORT_FILE"
    grep "sshd" /var/log/auth.log 2>/dev/null | \
        grep -E "Accepted|Failed" | \
        awk '{print $1, $2, $3, $9, $11}' | \
        tail -20 >> "$REPORT_FILE"

    echo "" >> "$REPORT_FILE"
}

# Function to analyze system logs
analyze_system_logs() {
    echo "=== System Log Analysis ===" >> "$REPORT_FILE"

    # Kernel errors
    echo "Kernel Errors:" >> "$REPORT_FILE"
    dmesg | grep -i error | tail -10 >> "$REPORT_FILE"

    # Service failures
    echo -e "\nService Failures:" >> "$REPORT_FILE"
    journalctl --since="$DAYS_TO_ANALYZE days ago" -p err --no-pager | \
        head -20 >> "$REPORT_FILE"

    # Disk errors
    echo -e "\nDisk Related Errors:" >> "$REPORT_FILE"
    grep -i "I/O error" /var/log/syslog 2>/dev/null | \
        tail -10 >> "$REPORT_FILE"

    echo "" >> "$REPORT_FILE"
}

# Function to analyze web server logs
analyze_web_logs() {
    echo "=== Web Server Analysis ===" >> "$REPORT_FILE"

    # Check for nginx logs
    if [ -f /var/log/nginx/access.log ]; then
        echo "Nginx Access Summary:" >> "$REPORT_FILE"

        # Top IP addresses
        echo "  Top 10 IP Addresses:" >> "$REPORT_FILE"
        awk '{print $1}' /var/log/nginx/access.log | \
            sort | uniq -c | sort -rn | head -10 >> "$REPORT_FILE"

        # HTTP status codes
        echo -e "\n  HTTP Status Codes:" >> "$REPORT_FILE"
        awk '{print $9}' /var/log/nginx/access.log | \
            sort | uniq -c | sort -rn | head -10 >> "$REPORT_FILE"

        # 404 errors
        echo -e "\n  Recent 404 Errors:" >> "$REPORT_FILE"
        grep " 404 " /var/log/nginx/access.log | \
            tail -5 >> "$REPORT_FILE"
    fi

    # Check for Apache logs
    if [ -f /var/log/apache2/access.log ]; then
        echo -e "\nApache Access Summary:" >> "$REPORT_FILE"

        # Similar analysis for Apache
        awk '{print $1}' /var/log/apache2/access.log | \
            sort | uniq -c | sort -rn | head -10 >> "$REPORT_FILE"
    fi

    echo "" >> "$REPORT_FILE"
}

# Function to generate summary
generate_summary() {
    echo "=== Log Analysis Summary ===" >> "$REPORT_FILE"
    echo "Analysis Date: $(date)" >> "$REPORT_FILE"
    echo "Period: Last $DAYS_TO_ANALYZE days" >> "$REPORT_FILE"
    echo "" >> "$REPORT_FILE"

    # Count total errors and warnings
    local total_errors=0
    local total_warnings=0

    for logdir in "${LOG_DIRS[@]}"; do
        if [ -d "$logdir" ]; then
            for pattern in "${ERROR_PATTERNS[@]}"; do
                count=$(find "$logdir" -name "*.log" -mtime -$DAYS_TO_ANALYZE \
                    -exec grep -i "$pattern" {} \; 2>/dev/null | wc -l)
                total_errors=$((total_errors + count))
            done

            for pattern in "${WARNING_PATTERNS[@]}"; do
                count=$(find "$logdir" -name "*.log" -mtime -$DAYS_TO_ANALYZE \
                    -exec grep -i "$pattern" {} \; 2>/dev/null | wc -l)
                total_warnings=$((total_warnings + count))
            done
        fi
    done

    echo "Total Errors Found: $total_errors" >> "$REPORT_FILE"
    echo "Total Warnings Found: $total_warnings" >> "$REPORT_FILE"
    echo "" >> "$REPORT_FILE"
}

# Main execution
main() {
    echo "Starting log analysis..."

    # Generate summary
    generate_summary

    # Analyze different log types
    analyze_auth_logs
    analyze_system_logs
    analyze_web_logs

    # Search for specific patterns
    echo "=== Pattern Analysis ===" >> "$REPORT_FILE"

    for logdir in "${LOG_DIRS[@]}"; do
        if [ -d "$logdir" ]; then
            echo "Analyzing logs in $logdir..." >> "$REPORT_FILE"

            # Find recent log files
            find "$logdir" -name "*.log" -mtime -$DAYS_TO_ANALYZE | while read -r logfile; do
                for pattern in "${ERROR_PATTERNS[@]}"; do
                    analyze_log "$logfile" "$pattern" "ERROR"
                done
            done >> "$REPORT_FILE"
        fi
    done

    echo "" >> "$REPORT_FILE"
    echo "Analysis complete. Report saved to: $REPORT_FILE"

    # Display report
    cat "$REPORT_FILE"
}

# Run main
main
```

## Maintenance Scripts

### System Cleanup
```bash
#!/bin/bash
# system-cleanup.sh - Comprehensive system cleanup script

# Configuration
DRY_RUN=false
VERBOSE=false
LOG_FILE="/var/log/system-cleanup.log"

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --dry-run)
            DRY_RUN=true
            shift
            ;;
        --verbose)
            VERBOSE=true
            shift
            ;;
        *)
            echo "Unknown option: $1"
            exit 1
            ;;
    esac
done

# Logging function
log_message() {
    local message=$1
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $message" | tee -a "$LOG_FILE"
    if [ "$VERBOSE" = true ]; then
        echo "$message"
    fi
}

# Function to get size of directory/file
get_size() {
    du -sh "$1" 2>/dev/null | cut -f1
}

# Function to clean package cache
clean_package_cache() {
    log_message "Cleaning package cache..."

    local before_size=$(get_size /var/cache/apt)

    if [ "$DRY_RUN" = false ]; then
        apt-get clean
        apt-get autoclean
        apt-get autoremove --purge -y
    fi

    local after_size=$(get_size /var/cache/apt)
    log_message "Package cache cleaned. Size: $before_size -> $after_size"
}

# Function to clean old kernels
clean_old_kernels() {
    log_message "Cleaning old kernels..."

    # Get current kernel
    local current_kernel=$(uname -r)

    # Find old kernels
    local old_kernels=$(dpkg -l 'linux-image-*' | grep '^ii' | \
        awk '{print $2}' | grep -v "$current_kernel" | head -n -1)

    if [ -n "$old_kernels" ]; then
        if [ "$DRY_RUN" = false ]; then
            echo "$old_kernels" | xargs apt-get remove --purge -y
        else
            log_message "Would remove: $old_kernels"
        fi
    fi

    log_message "Old kernels cleaned"
}

# Function to clean log files
clean_logs() {
    log_message "Cleaning log files..."

    # Journal logs
    if [ "$DRY_RUN" = false ]; then
        journalctl --vacuum-time=7d
        journalctl --vacuum-size=100M
    fi

    # Rotate and compress logs
    if [ "$DRY_RUN" = false ]; then
        logrotate -f /etc/logrotate.conf
    fi

    # Clean old archived logs
    find /var/log -name "*.gz" -mtime +30 -delete 2>/dev/null
    find /var/log -name "*.old" -mtime +30 -delete 2>/dev/null
    find /var/log -name "*.1" -mtime +30 -delete 2>/dev/null

    # Truncate large log files
    find /var/log -type f -size +100M | while read -r logfile; do
        if [ "$DRY_RUN" = false ]; then
            truncate -s 0 "$logfile"
            log_message "Truncated large log file: $logfile"
        else
            log_message "Would truncate: $logfile ($(get_size "$logfile"))"
        fi
    done

    log_message "Log files cleaned"
}

# Function to clean temporary files
clean_temp_files() {
    log_message "Cleaning temporary files..."

    # Clean /tmp
    if [ "$DRY_RUN" = false ]; then
        find /tmp -type f -atime +7 -delete 2>/dev/null
        find /tmp -type d -empty -delete 2>/dev/null
    fi

    # Clean /var/tmp
    if [ "$DRY_RUN" = false ]; then
        find /var/tmp -type f -atime +7 -delete 2>/dev/null
        find /var/tmp -type d -empty -delete 2>/dev/null
    fi

    # Clean user cache directories
    for user_home in /home/*; do
        if [ -d "$user_home/.cache" ]; then
            if [ "$DRY_RUN" = false ]; then
                find "$user_home/.cache" -type f -atime +30 -delete 2>/dev/null
            fi
        fi
    done

    log_message "Temporary files cleaned"
}

# Function to clean Docker if installed
clean_docker() {
    if command -v docker >/dev/null 2>&1; then
        log_message "Cleaning Docker..."

        if [ "$DRY_RUN" = false ]; then
            # Remove stopped containers
            docker container prune -f

            # Remove unused images
            docker image prune -a -f

            # Remove unused volumes
            docker volume prune -f

            # Remove unused networks
            docker network prune -f

            # Complete system prune
            docker system prune -a -f --volumes
        fi

        log_message "Docker cleaned"
    fi
}

# Function to clean snap packages
clean_snap() {
    if command -v snap >/dev/null 2>&1; then
        log_message "Cleaning snap packages..."

        # Remove old snap revisions
        snap list --all | awk '/disabled/{print $1, $3}' | while read snapname revision; do
            if [ "$DRY_RUN" = false ]; then
                snap remove "$snapname" --revision="$revision"
            else
                log_message "Would remove snap: $snapname revision $revision"
            fi
        done

        log_message "Snap packages cleaned"
    fi
}

# Function to clean systemd journal
clean_systemd_journal() {
    log_message "Cleaning systemd journal..."

    if [ "$DRY_RUN" = false ]; then
        journalctl --vacuum-time=7d
        journalctl --vacuum-size=500M
    fi

    log_message "Systemd journal cleaned"
}

# Function to optimize databases
optimize_databases() {
    log_message "Optimizing databases..."

    # MySQL/MariaDB
    if command -v mysql >/dev/null 2>&1; then
        if [ "$DRY_RUN" = false ]; then
            mysqlcheck --all-databases --optimize
        fi
    fi

    # PostgreSQL
    if command -v psql >/dev/null 2>&1; then
        if [ "$DRY_RUN" = false ]; then
            sudo -u postgres vacuumdb --all --analyze
        fi
    fi

    log_message "Databases optimized"
}

# Main execution
main() {
    log_message "Starting system cleanup (DRY_RUN=$DRY_RUN)"

    # Record initial disk usage
    local initial_disk=$(df -h / | awk 'NR==2 {print $3}')

    # Run cleanup tasks
    clean_package_cache
    clean_old_kernels
    clean_logs
    clean_temp_files
    clean_docker
    clean_snap
    clean_systemd_journal
    optimize_databases

    # Record final disk usage
    local final_disk=$(df -h / | awk 'NR==2 {print $3}')

    log_message "Cleanup completed. Disk usage: $initial_disk -> $final_disk"

    if [ "$DRY_RUN" = true ]; then
        echo "This was a dry run. No changes were made."
        echo "Run without --dry-run to perform actual cleanup."
    fi
}

# Run main
main
```

### Database Backup
```bash
#!/bin/bash
# database-backup.sh - Automated database backup script

# Configuration
BACKUP_DIR="/backup/databases"
MYSQL_USER="backup"
MYSQL_PASS="backup_password"
PG_USER="postgres"
RETENTION_DAYS=30
COMPRESS=true
ENCRYPT=false
ENCRYPTION_KEY=""
S3_BUCKET=""
S3_PATH="database-backups"

# Create backup directory
mkdir -p "$BACKUP_DIR"

# Logging function
log_message() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1"
}

# Function to backup MySQL databases
backup_mysql() {
    if ! command -v mysql >/dev/null 2>&1; then
        return
    fi

    log_message "Starting MySQL backup..."

    # Get list of databases
    databases=$(mysql -u"$MYSQL_USER" -p"$MYSQL_PASS" -e "SHOW DATABASES;" | \
        grep -v Database | grep -v information_schema | grep -v performance_schema | grep -v mysql | grep -v sys)

    for db in $databases; do
        local backup_file="$BACKUP_DIR/mysql_${db}_$(date +%Y%m%d_%H%M%S).sql"

        log_message "Backing up MySQL database: $db"

        # Dump database
        mysqldump -u"$MYSQL_USER" -p"$MYSQL_PASS" \
            --single-transaction \
            --routines \
            --triggers \
            --events \
            --add-drop-database \
            --databases "$db" > "$backup_file"

        # Compress if enabled
        if [ "$COMPRESS" = true ]; then
            gzip "$backup_file"
            backup_file="${backup_file}.gz"
        fi

        # Encrypt if enabled
        if [ "$ENCRYPT" = true ] && [ -n "$ENCRYPTION_KEY" ]; then
            openssl enc -aes-256-cbc -salt -in "$backup_file" \
                -out "${backup_file}.enc" -pass pass:"$ENCRYPTION_KEY"
            rm "$backup_file"
            backup_file="${backup_file}.enc"
        fi

        log_message "MySQL database $db backed up to $backup_file"
    done
}

# Function to backup PostgreSQL databases
backup_postgresql() {
    if ! command -v psql >/dev/null 2>&1; then
        return
    fi

    log_message "Starting PostgreSQL backup..."

    # Get list of databases
    databases=$(sudo -u "$PG_USER" psql -l -t | cut -d'|' -f1 | \
        sed -e 's/^[[:space:]]*//' -e '/^$/d' | \
        grep -v template0 | grep -v template1)

    for db in $databases; do
        local backup_file="$BACKUP_DIR/postgres_${db}_$(date +%Y%m%d_%H%M%S).sql"

        log_message "Backing up PostgreSQL database: $db"

        # Dump database
        sudo -u "$PG_USER" pg_dump -Fp -C "$db" > "$backup_file"

        # Compress if enabled
        if [ "$COMPRESS" = true ]; then
            gzip "$backup_file"
            backup_file="${backup_file}.gz"
        fi

        # Encrypt if enabled
        if [ "$ENCRYPT" = true ] && [ -n "$ENCRYPTION_KEY" ]; then
            openssl enc -aes-256-cbc -salt -in "$backup_file" \
                -out "${backup_file}.enc" -pass pass:"$ENCRYPTION_KEY"
            rm "$backup_file"
            backup_file="${backup_file}.enc"
        fi

        log_message "PostgreSQL database $db backed up to $backup_file"
    done
}

# Function to backup MongoDB
backup_mongodb() {
    if ! command -v mongodump >/dev/null 2>&1; then
        return
    fi

    log_message "Starting MongoDB backup..."

    local backup_dir="$BACKUP_DIR/mongodb_$(date +%Y%m%d_%H%M%S)"

    # Dump all databases
    mongodump --out "$backup_dir"

    # Compress if enabled
    if [ "$COMPRESS" = true ]; then
        tar -czf "${backup_dir}.tar.gz" -C "$BACKUP_DIR" "$(basename "$backup_dir")"
        rm -rf "$backup_dir"
        backup_dir="${backup_dir}.tar.gz"
    fi

    log_message "MongoDB backed up to $backup_dir"
}

# Function to upload to S3
upload_to_s3() {
    if [ -z "$S3_BUCKET" ]; then
        return
    fi

    log_message "Uploading backups to S3..."

    # Find today's backup files
    find "$BACKUP_DIR" -name "*$(date +%Y%m%d)*" -type f | while read -r file; do
        aws s3 cp "$file" "s3://$S3_BUCKET/$S3_PATH/$(basename "$file")"
        if [ $? -eq 0 ]; then
            log_message "Uploaded $(basename "$file") to S3"
        else
            log_message "Failed to upload $(basename "$file") to S3"
        fi
    done
}

# Function to clean old backups
cleanup_old_backups() {
    log_message "Cleaning old backups..."

    # Remove local backups older than retention period
    find "$BACKUP_DIR" -type f -mtime +$RETENTION_DAYS -delete

    # Clean S3 if configured
    if [ -n "$S3_BUCKET" ]; then
        # List and remove old S3 objects
        aws s3 ls "s3://$S3_BUCKET/$S3_PATH/" | while read -r line; do
            file_date=$(echo "$line" | awk '{print $1}')
            file_name=$(echo "$line" | awk '{print $4}')

            if [ -n "$file_name" ]; then
                file_age=$(( ($(date +%s) - $(date -d "$file_date" +%s)) / 86400 ))
                if [ $file_age -gt $RETENTION_DAYS ]; then
                    aws s3 rm "s3://$S3_BUCKET/$S3_PATH/$file_name"
                    log_message "Removed old S3 backup: $file_name"
                fi
            fi
        done
    fi

    log_message "Cleanup completed"
}

# Main execution
main() {
    log_message "Starting database backup process"

    # Perform backups
    backup_mysql
    backup_postgresql
    backup_mongodb

    # Upload to S3
    upload_to_s3

    # Cleanup old backups
    cleanup_old_backups

    log_message "Database backup process completed"
}

# Run main
main
```

## Security Scripts

### Security Audit
```bash
#!/bin/bash
# security-audit.sh - Comprehensive security audit script

# Configuration
REPORT_FILE="/tmp/security-audit-$(date +%Y%m%d-%H%M%S).txt"
CRITICAL_ISSUES=0
WARNING_ISSUES=0
INFO_ISSUES=0

# Colors
RED='\033[0;31m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
NC='\033[0m'

# Function to log findings
log_finding() {
    local severity=$1
    local message=$2

    case $severity in
        CRITICAL)
            echo -e "${RED}[CRITICAL]${NC} $message" | tee -a "$REPORT_FILE"
            ((CRITICAL_ISSUES++))
            ;;
        WARNING)
            echo -e "${YELLOW}[WARNING]${NC} $message" | tee -a "$REPORT_FILE"
            ((WARNING_ISSUES++))
            ;;
        INFO)
            echo -e "${GREEN}[INFO]${NC} $message" | tee -a "$REPORT_FILE"
            ((INFO_ISSUES++))
            ;;
        *)
            echo "$message" | tee -a "$REPORT_FILE"
            ;;
    esac
}

# Check system updates
check_updates() {
    log_finding "" "=== System Updates ==="

    if command -v apt >/dev/null 2>&1; then
        updates=$(apt list --upgradable 2>/dev/null | grep -c upgradable)
        if [ "$updates" -gt 0 ]; then
            log_finding "WARNING" "$updates packages need updating"

            # Check for security updates
            security_updates=$(apt list --upgradable 2>/dev/null | grep -c security)
            if [ "$security_updates" -gt 0 ]; then
                log_finding "CRITICAL" "$security_updates security updates available"
            fi
        else
            log_finding "INFO" "System is up to date"
        fi
    fi
    echo "" | tee -a "$REPORT_FILE"
}

# Check user accounts
check_users() {
    log_finding "" "=== User Accounts ==="

    # Check for users with UID 0
    uid0_users=$(awk -F: '$3 == 0 {print $1}' /etc/passwd | grep -v root)
    if [ -n "$uid0_users" ]; then
        log_finding "CRITICAL" "Non-root users with UID 0: $uid0_users"
    fi

    # Check for users with empty passwords
    empty_pass=$(awk -F: '($2 == "" || $2 == "!") {print $1}' /etc/shadow 2>/dev/null)
    if [ -n "$empty_pass" ]; then
        log_finding "CRITICAL" "Users with empty passwords: $empty_pass"
    fi

    # Check for users with no password expiry
    no_expiry=$(chage -l $(awk -F: '{print $1}' /etc/passwd) 2>/dev/null | \
        grep "Password expires" | grep never | wc -l)
    if [ "$no_expiry" -gt 0 ]; then
        log_finding "WARNING" "$no_expiry users have passwords that never expire"
    fi

    echo "" | tee -a "$REPORT_FILE"
}

# Check SSH configuration
check_ssh() {
    log_finding "" "=== SSH Configuration ==="

    if [ -f /etc/ssh/sshd_config ]; then
        # Check root login
        if grep -q "^PermitRootLogin yes" /etc/ssh/sshd_config; then
            log_finding "CRITICAL" "Root login is permitted via SSH"
        fi

        # Check password authentication
        if grep -q "^PasswordAuthentication yes" /etc/ssh/sshd_config; then
            log_finding "WARNING" "Password authentication is enabled"
        fi

        # Check protocol version
        if grep -q "^Protocol 1" /etc/ssh/sshd_config; then
            log_finding "CRITICAL" "SSH Protocol 1 is enabled"
        fi

        # Check empty passwords
        if grep -q "^PermitEmptyPasswords yes" /etc/ssh/sshd_config; then
            log_finding "CRITICAL" "Empty passwords are permitted"
        fi
    else
        log_finding "WARNING" "SSH configuration file not found"
    fi

    echo "" | tee -a "$REPORT_FILE"
}

# Check firewall
check_firewall() {
    log_finding "" "=== Firewall Configuration ==="

    # Check UFW
    if command -v ufw >/dev/null 2>&1; then
        if ufw status | grep -q "Status: inactive"; then
            log_finding "CRITICAL" "UFW firewall is not active"
        else
            log_finding "INFO" "UFW firewall is active"

            # Check for permissive rules
            if ufw status | grep -q "ALLOW.*Anywhere"; then
                log_finding "WARNING" "Firewall has rules allowing connections from anywhere"
            fi
        fi
    fi

    # Check iptables
    if command -v iptables >/dev/null 2>&1; then
        if [ $(iptables -L | wc -l) -le 8 ]; then
            log_finding "WARNING" "iptables has no rules configured"
        fi
    fi

    echo "" | tee -a "$REPORT_FILE"
}

# Check file permissions
check_permissions() {
    log_finding "" "=== File Permissions ==="

    # Check world-writable files
    world_writable=$(find / -type f -perm -002 2>/dev/null | head -20 | wc -l)
    if [ "$world_writable" -gt 0 ]; then
        log_finding "WARNING" "Found $world_writable world-writable files"
    fi

    # Check SUID files
    suid_files=$(find / -perm -4000 -type f 2>/dev/null | wc -l)
    log_finding "INFO" "Found $suid_files SUID files"

    # Check important file permissions
    critical_files=(
        "/etc/passwd:644"
        "/etc/shadow:000"
        "/etc/sudoers:440"
        "/root/.ssh:700"
    )

    for file_perm in "${critical_files[@]}"; do
        file=$(echo "$file_perm" | cut -d: -f1)
        expected_perm=$(echo "$file_perm" | cut -d: -f2)

        if [ -e "$file" ]; then
            actual_perm=$(stat -c %a "$file")
            if [ "$actual_perm" != "$expected_perm" ]; then
                log_finding "WARNING" "$file has permissions $actual_perm (expected $expected_perm)"
            fi
        fi
    done

    echo "" | tee -a "$REPORT_FILE"
}

# Check services
check_services() {
    log_finding "" "=== Running Services ==="

    # Check for unnecessary services
    risky_services=("telnet" "rsh" "rlogin" "vsftpd")

    for service in "${risky_services[@]}"; do
        if systemctl is-active "$service" >/dev/null 2>&1; then
            log_finding "WARNING" "Risky service $service is running"
        fi
    done

    # Check listening ports
    open_ports=$(ss -tlnp 2>/dev/null | grep -c LISTEN)
    log_finding "INFO" "$open_ports ports are listening"

    echo "" | tee -a "$REPORT_FILE"
}

# Check logs for issues
check_logs() {
    log_finding "" "=== Log Analysis ==="

    # Check for authentication failures
    auth_failures=$(grep -c "authentication failure" /var/log/auth.log 2>/dev/null || echo 0)
    if [ "$auth_failures" -gt 100 ]; then
        log_finding "WARNING" "High number of authentication failures: $auth_failures"
    fi

    # Check for sudo violations
    sudo_violations=$(grep -c "NOT in sudoers" /var/log/auth.log 2>/dev/null || echo 0)
    if [ "$sudo_violations" -gt 0 ]; then
        log_finding "WARNING" "Sudo violations detected: $sudo_violations"
    fi

    echo "" | tee -a "$REPORT_FILE"
}

# Generate summary
generate_summary() {
    echo "" | tee -a "$REPORT_FILE"
    echo "=== Security Audit Summary ===" | tee -a "$REPORT_FILE"
    echo "Date: $(date)" | tee -a "$REPORT_FILE"
    echo "Hostname: $(hostname -f)" | tee -a "$REPORT_FILE"
    echo "" | tee -a "$REPORT_FILE"
    echo "Critical Issues: $CRITICAL_ISSUES" | tee -a "$REPORT_FILE"
    echo "Warnings: $WARNING_ISSUES" | tee -a "$REPORT_FILE"
    echo "Info Items: $INFO_ISSUES" | tee -a "$REPORT_FILE"
    echo "" | tee -a "$REPORT_FILE"

    if [ "$CRITICAL_ISSUES" -gt 0 ]; then
        echo -e "${RED}CRITICAL ISSUES FOUND - IMMEDIATE ACTION REQUIRED${NC}" | tee -a "$REPORT_FILE"
    elif [ "$WARNING_ISSUES" -gt 0 ]; then
        echo -e "${YELLOW}Warnings found - review recommended${NC}" | tee -a "$REPORT_FILE"
    else
        echo -e "${GREEN}No major security issues found${NC}" | tee -a "$REPORT_FILE"
    fi
}

# Main execution
main() {
    echo "Starting Security Audit..." | tee "$REPORT_FILE"
    echo "=========================" | tee -a "$REPORT_FILE"
    echo "" | tee -a "$REPORT_FILE"

    check_updates
    check_users
    check_ssh
    check_firewall
    check_permissions
    check_services
    check_logs

    generate_summary

    echo "" | tee -a "$REPORT_FILE"
    echo "Full report saved to: $REPORT_FILE" | tee -a "$REPORT_FILE"
}

# Run main
main
```

## Utility Functions Library

### Common Functions Library
```bash
#!/bin/bash
# lib/common-functions.sh - Reusable function library

# Color codes
export RED='\033[0;31m'
export GREEN='\033[0;32m'
export YELLOW='\033[1;33m'
export BLUE='\033[0;34m'
export MAGENTA='\033[0;35m'
export CYAN='\033[0;36m'
export WHITE='\033[1;37m'
export NC='\033[0m' # No Color

# Logging functions
log_info() {
    echo -e "${GREEN}[INFO]${NC} $(date '+%Y-%m-%d %H:%M:%S') - $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $(date '+%Y-%m-%d %H:%M:%S') - $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $(date '+%Y-%m-%d %H:%M:%S') - $1"
}

log_debug() {
    if [ "${DEBUG:-false}" = true ]; then
        echo -e "${BLUE}[DEBUG]${NC} $(date '+%Y-%m-%d %H:%M:%S') - $1"
    fi
}

# Check if running as root
require_root() {
    if [ "$EUID" -ne 0 ]; then
        log_error "This script must be run as root"
        exit 1
    fi
}

# Check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Install package if not exists
ensure_package() {
    local package=$1

    if ! dpkg -l | grep -q "^ii  $package "; then
        log_info "Installing $package..."
        apt-get update && apt-get install -y "$package"
    fi
}

# Create backup of file
backup_file() {
    local file=$1
    local backup_dir=${2:-/var/backups}

    if [ -f "$file" ]; then
        local backup_file="$backup_dir/$(basename "$file").$(date +%Y%m%d-%H%M%S).bak"
        cp -p "$file" "$backup_file"
        log_info "Backed up $file to $backup_file"
        echo "$backup_file"
    fi
}

# Retry command with exponential backoff
retry_with_backoff() {
    local max_attempts=${1:-5}
    local delay=${2:-1}
    local max_delay=${3:-60}
    shift 3
    local command=("$@")
    local attempt=1

    while [ $attempt -le $max_attempts ]; do
        if "${command[@]}"; then
            return 0
        fi

        log_warning "Command failed (attempt $attempt/$max_attempts). Retrying in ${delay}s..."
        sleep $delay

        attempt=$((attempt + 1))
        delay=$((delay * 2))
        if [ $delay -gt $max_delay ]; then
            delay=$max_delay
        fi
    done

    log_error "Command failed after $max_attempts attempts"
    return 1
}

# Get system information
get_system_info() {
    cat <<EOF
Hostname: $(hostname -f)
OS: $(lsb_release -ds 2>/dev/null || cat /etc/os-release | grep PRETTY_NAME | cut -d'=' -f2)
Kernel: $(uname -r)
Architecture: $(uname -m)
CPU: $(lscpu | grep "Model name" | cut -d':' -f2 | xargs)
Memory: $(free -h | awk '/^Mem:/ {print $2}')
Disk: $(df -h / | awk 'NR==2 {print $2}')
IP: $(ip -4 addr show | grep -oP '(?<=inet\s)\d+(\.\d+){3}' | grep -v 127.0.0.1 | head -1)
EOF
}

# Send notification
send_notification() {
    local subject=$1
    local message=$2
    local recipient=${3:-admin@example.com}

    # Email notification
    if command_exists mail; then
        echo "$message" | mail -s "$subject" "$recipient"
    fi

    # Slack notification (if webhook configured)
    if [ -n "${SLACK_WEBHOOK_URL:-}" ]; then
        curl -X POST -H 'Content-type: application/json' \
            --data "{\"text\":\"$subject\n$message\"}" \
            "$SLACK_WEBHOOK_URL"
    fi
}

# Check disk space
check_disk_space() {
    local threshold=${1:-90}
    local critical=false

    while IFS= read -r line; do
        usage=$(echo "$line" | awk '{print $5}' | sed 's/%//')
        mount=$(echo "$line" | awk '{print $6}')

        if [ "$usage" -ge "$threshold" ]; then
            log_warning "Disk usage on $mount is ${usage}%"
            critical=true
        fi
    done < <(df -h | grep -E '^/dev/')

    if [ "$critical" = true ]; then
        return 1
    fi
    return 0
}

# Check memory usage
check_memory_usage() {
    local threshold=${1:-90}

    local usage=$(free | grep Mem | awk '{print int($3/$2 * 100)}')

    if [ "$usage" -ge "$threshold" ]; then
        log_warning "Memory usage is ${usage}%"
        return 1
    fi
    return 0
}

# Create secure temporary file
create_temp_file() {
    local prefix=${1:-temp}
    local temp_file=$(mktemp "/tmp/${prefix}.XXXXXX")

    # Ensure cleanup on exit
    trap "rm -f $temp_file" EXIT

    echo "$temp_file"
}

# Validate IP address
validate_ip() {
    local ip=$1
    local valid_regex='^([0-9]{1,3}\.){3}[0-9]{1,3}$'

    if [[ $ip =~ $valid_regex ]]; then
        for octet in $(echo "$ip" | tr '.' ' '); do
            if [ "$octet" -gt 255 ]; then
                return 1
            fi
        done
        return 0
    fi
    return 1
}

# Validate domain name
validate_domain() {
    local domain=$1
    local valid_regex='^([a-zA-Z0-9]([a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?\.)*[a-zA-Z0-9]([a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?$'

    if [[ $domain =~ $valid_regex ]]; then
        return 0
    fi
    return 1
}

# Generate random password
generate_password() {
    local length=${1:-16}
    local charset=${2:-'A-Za-z0-9!@#$%^&*()'}

    openssl rand -base64 48 | tr -d '\n' | fold -w "$length" | head -1
}

# Lock file handling
acquire_lock() {
    local lockfile=${1:-/var/run/script.lock}
    local timeout=${2:-30}

    local count=0
    while [ $count -lt $timeout ]; do
        if mkdir "$lockfile" 2>/dev/null; then
            trap "release_lock $lockfile" EXIT
            return 0
        fi
        sleep 1
        count=$((count + 1))
    done

    log_error "Failed to acquire lock: $lockfile"
    return 1
}

release_lock() {
    local lockfile=$1
    rm -rf "$lockfile"
}

# Export functions
export -f log_info log_warning log_error log_debug
export -f require_root command_exists ensure_package
export -f backup_file retry_with_backoff get_system_info
export -f send_notification check_disk_space check_memory_usage
export -f create_temp_file validate_ip validate_domain
export -f generate_password acquire_lock release_lock
```

---

This comprehensive scripting and automation library provides ready-to-use scripts for system administration, monitoring, maintenance, security auditing, and common utility functions that can be customized and extended for specific needs.