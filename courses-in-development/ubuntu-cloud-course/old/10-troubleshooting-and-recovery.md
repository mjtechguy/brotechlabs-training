# Part 10: Troubleshooting and Recovery

## Prerequisites

Before starting this section, you should understand:
- Linux system architecture and boot process
- How to work with systemd and services
- Basic networking concepts
- File system structure and permissions
- How to read and analyze log files

**Learning Resources:**
- [Linux Troubleshooting Guide](https://www.tecmint.com/linux-troubleshooting-guide/)
- [Ubuntu Recovery Documentation](https://help.ubuntu.com/community/RecoveryMode)
- [System Recovery Techniques](https://www.kernel.org/doc/html/latest/admin-guide/sysrq.html)
- [Debugging Linux Systems](https://www.brendangregg.com/linuxperf.html)

---

## Chapter 22: Troubleshooting Methodology

### Systematic Troubleshooting Approach

Effective troubleshooting follows a systematic approach to identify and resolve issues efficiently.

#### The Troubleshooting Process

1. **Define the Problem**: What exactly is not working?
2. **Gather Information**: Collect logs, error messages, system state
3. **Develop Hypotheses**: What could cause this problem?
4. **Test Hypotheses**: Systematically test each possibility
5. **Implement Solution**: Apply the fix
6. **Verify Resolution**: Confirm the problem is solved
7. **Document**: Record the issue and solution for future reference

#### Initial System Assessment

```bash
# Create comprehensive troubleshooting script
sudo nano /usr/local/bin/system-diagnose.sh
```

```bash
#!/bin/bash
# Comprehensive system diagnosis script

LOG_FILE="/tmp/system-diagnosis-$(date +%Y%m%d-%H%M%S).log"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo "System Diagnosis Report" | tee "$LOG_FILE"
echo "========================" | tee -a "$LOG_FILE"
echo "Date: $(date)" | tee -a "$LOG_FILE"
echo "Hostname: $(hostname -f)" | tee -a "$LOG_FILE"
echo "" | tee -a "$LOG_FILE"

# System Information
check_system_info() {
    echo -e "${BLUE}=== System Information ===${NC}" | tee -a "$LOG_FILE"

    # OS Version
    echo "OS Version:" | tee -a "$LOG_FILE"
    lsb_release -a 2>/dev/null | tee -a "$LOG_FILE"

    # Kernel
    echo -e "\nKernel:" | tee -a "$LOG_FILE"
    uname -r | tee -a "$LOG_FILE"

    # Uptime
    echo -e "\nUptime:" | tee -a "$LOG_FILE"
    uptime | tee -a "$LOG_FILE"

    # Last reboot
    echo -e "\nLast reboot:" | tee -a "$LOG_FILE"
    who -b | tee -a "$LOG_FILE"
    echo "" | tee -a "$LOG_FILE"
}

# Resource Usage
check_resources() {
    echo -e "${BLUE}=== Resource Usage ===${NC}" | tee -a "$LOG_FILE"

    # CPU
    echo "CPU Usage:" | tee -a "$LOG_FILE"
    top -bn1 | head -5 | tee -a "$LOG_FILE"

    # Memory
    echo -e "\nMemory Usage:" | tee -a "$LOG_FILE"
    free -h | tee -a "$LOG_FILE"

    # Swap
    echo -e "\nSwap Usage:" | tee -a "$LOG_FILE"
    swapon --show | tee -a "$LOG_FILE"

    # Disk
    echo -e "\nDisk Usage:" | tee -a "$LOG_FILE"
    df -h | tee -a "$LOG_FILE"

    # Disk I/O
    echo -e "\nDisk I/O Statistics:" | tee -a "$LOG_FILE"
    iostat -x 1 3 | tail -n 20 | tee -a "$LOG_FILE"
    echo "" | tee -a "$LOG_FILE"
}

# Network Status
check_network() {
    echo -e "${BLUE}=== Network Status ===${NC}" | tee -a "$LOG_FILE"

    # Interfaces
    echo "Network Interfaces:" | tee -a "$LOG_FILE"
    ip addr show | tee -a "$LOG_FILE"

    # Routes
    echo -e "\nRouting Table:" | tee -a "$LOG_FILE"
    ip route show | tee -a "$LOG_FILE"

    # DNS
    echo -e "\nDNS Servers:" | tee -a "$LOG_FILE"
    systemd-resolve --status | grep "DNS Servers" | tee -a "$LOG_FILE"

    # Connections
    echo -e "\nActive Connections:" | tee -a "$LOG_FILE"
    ss -tuln | head -20 | tee -a "$LOG_FILE"

    # Firewall
    echo -e "\nFirewall Status:" | tee -a "$LOG_FILE"
    sudo ufw status verbose | head -20 | tee -a "$LOG_FILE"
    echo "" | tee -a "$LOG_FILE"
}

# Service Status
check_services() {
    echo -e "${BLUE}=== Service Status ===${NC}" | tee -a "$LOG_FILE"

    # Failed services
    echo "Failed Services:" | tee -a "$LOG_FILE"
    systemctl list-units --failed | tee -a "$LOG_FILE"

    # Critical services
    echo -e "\nCritical Services Status:" | tee -a "$LOG_FILE"
    for service in ssh nginx mysql postgresql redis-server; do
        if systemctl is-enabled "$service" &>/dev/null; then
            status=$(systemctl is-active "$service")
            if [ "$status" = "active" ]; then
                echo -e "${GREEN}✓${NC} $service: $status" | tee -a "$LOG_FILE"
            else
                echo -e "${RED}✗${NC} $service: $status" | tee -a "$LOG_FILE"
            fi
        fi
    done
    echo "" | tee -a "$LOG_FILE"
}

# Recent Logs
check_logs() {
    echo -e "${BLUE}=== Recent System Logs ===${NC}" | tee -a "$LOG_FILE"

    # System errors
    echo "Recent Errors (last 20):" | tee -a "$LOG_FILE"
    journalctl -p err -n 20 --no-pager | tee -a "$LOG_FILE"

    # Kernel messages
    echo -e "\nRecent Kernel Messages:" | tee -a "$LOG_FILE"
    dmesg | tail -20 | tee -a "$LOG_FILE"

    # Authentication
    echo -e "\nRecent Authentication:" | tee -a "$LOG_FILE"
    grep -i "authentication\|failed\|error" /var/log/auth.log | tail -10 | tee -a "$LOG_FILE"
    echo "" | tee -a "$LOG_FILE"
}

# Process Information
check_processes() {
    echo -e "${BLUE}=== Process Information ===${NC}" | tee -a "$LOG_FILE"

    # Top CPU consumers
    echo "Top CPU Processes:" | tee -a "$LOG_FILE"
    ps aux --sort=-%cpu | head -10 | tee -a "$LOG_FILE"

    # Top Memory consumers
    echo -e "\nTop Memory Processes:" | tee -a "$LOG_FILE"
    ps aux --sort=-%mem | head -10 | tee -a "$LOG_FILE"

    # Zombie processes
    echo -e "\nZombie Processes:" | tee -a "$LOG_FILE"
    ps aux | grep " Z " | tee -a "$LOG_FILE"
    echo "" | tee -a "$LOG_FILE"
}

# Performance Issues
check_performance() {
    echo -e "${BLUE}=== Performance Indicators ===${NC}" | tee -a "$LOG_FILE"

    # Load average
    echo "Load Average:" | tee -a "$LOG_FILE"
    cat /proc/loadavg | tee -a "$LOG_FILE"

    # CPU cores
    echo -e "\nCPU Cores: $(nproc)" | tee -a "$LOG_FILE"

    # I/O wait
    echo -e "\nI/O Wait:" | tee -a "$LOG_FILE"
    iostat -c 1 3 | grep -A1 avg-cpu | tail -2 | tee -a "$LOG_FILE"

    # Memory pressure
    echo -e "\nMemory Pressure:" | tee -a "$LOG_FILE"
    if [ -f /proc/pressure/memory ]; then
        cat /proc/pressure/memory | tee -a "$LOG_FILE"
    fi
    echo "" | tee -a "$LOG_FILE"
}

# Security Check
check_security() {
    echo -e "${BLUE}=== Security Quick Check ===${NC}" | tee -a "$LOG_FILE"

    # Login attempts
    echo "Recent Failed Logins:" | tee -a "$LOG_FILE"
    grep "Failed password" /var/log/auth.log | tail -5 | tee -a "$LOG_FILE"

    # Sudo usage
    echo -e "\nRecent Sudo Usage:" | tee -a "$LOG_FILE"
    grep "sudo" /var/log/auth.log | tail -5 | tee -a "$LOG_FILE"

    # Open ports
    echo -e "\nListening Ports:" | tee -a "$LOG_FILE"
    sudo ss -tlnp | tee -a "$LOG_FILE"
    echo "" | tee -a "$LOG_FILE"
}

# Main execution
main() {
    check_system_info
    check_resources
    check_network
    check_services
    check_logs
    check_processes
    check_performance
    check_security

    echo -e "${GREEN}Diagnosis complete. Report saved to: $LOG_FILE${NC}"
}

main
```

```bash
# Make executable
sudo chmod +x /usr/local/bin/system-diagnose.sh

# Run diagnosis
sudo system-diagnose.sh
```

### Common Issues and Solutions

#### System Won't Boot

```bash
# Boot troubleshooting checklist

# 1. Check GRUB menu (hold Shift during boot)
# 2. Boot to recovery mode
# 3. From recovery menu, select:
#    - fsck (Check filesystem)
#    - remount (Remount filesystem read/write)
#    - root (Drop to root shell)

# In recovery root shell:

# Check filesystem
fsck -y /dev/sda1

# Check and fix package issues
dpkg --configure -a
apt-get update
apt-get -f install

# Check kernel issues
# List installed kernels
dpkg --list | grep linux-image

# Remove problematic kernel
apt-get remove linux-image-[version]

# Reinstall current kernel
apt-get install --reinstall linux-image-$(uname -r)

# Update GRUB
update-grub

# Check disk space
df -h

# Clean up if needed
apt-get autoremove
apt-get clean
journalctl --vacuum-size=100M
```

#### Service Won't Start

```bash
# Service troubleshooting script
sudo nano /usr/local/bin/debug-service.sh
```

```bash
#!/bin/bash
# Service debugging script

SERVICE=$1

if [ -z "$SERVICE" ]; then
    echo "Usage: $0 <service-name>"
    exit 1
fi

echo "=== Debugging $SERVICE ==="

# Check if service exists
if ! systemctl list-unit-files | grep -q "^$SERVICE"; then
    echo "Service $SERVICE does not exist"
    exit 1
fi

# Service status
echo "1. Service Status:"
systemctl status "$SERVICE" --no-pager

# Service dependencies
echo -e "\n2. Dependencies:"
systemctl list-dependencies "$SERVICE"

# Configuration test (if applicable)
echo -e "\n3. Configuration Test:"
case "$SERVICE" in
    nginx*)
        nginx -t
        ;;
    apache2*)
        apache2ctl configtest
        ;;
    mysql*)
        mysqld --verbose --help 2>/dev/null | head -20
        ;;
    ssh*)
        sshd -t
        ;;
esac

# Recent logs
echo -e "\n4. Recent Logs:"
journalctl -u "$SERVICE" -n 50 --no-pager

# Process check
echo -e "\n5. Process Check:"
ps aux | grep -i "$SERVICE" | grep -v grep

# Port check
echo -e "\n6. Port Check:"
case "$SERVICE" in
    nginx*)
        ss -tlnp | grep :80
        ss -tlnp | grep :443
        ;;
    ssh*)
        ss -tlnp | grep :22
        ;;
    mysql*)
        ss -tlnp | grep :3306
        ;;
    postgresql*)
        ss -tlnp | grep :5432
        ;;
esac

# File permissions
echo -e "\n7. Configuration File Permissions:"
case "$SERVICE" in
    nginx*)
        ls -la /etc/nginx/nginx.conf
        ls -la /etc/nginx/sites-enabled/
        ;;
    apache2*)
        ls -la /etc/apache2/apache2.conf
        ls -la /etc/apache2/sites-enabled/
        ;;
    ssh*)
        ls -la /etc/ssh/sshd_config
        ;;
esac

# Resource limits
echo -e "\n8. Resource Limits:"
systemctl show "$SERVICE" | grep -E "Limit|Memory|CPU|Tasks"

# Try to start with verbose output
echo -e "\n9. Attempting to start service:"
systemctl start "$SERVICE" -l

# Final status
echo -e "\n10. Final Status:"
systemctl status "$SERVICE" --no-pager
```

#### High CPU Usage

```bash
# CPU troubleshooting script
sudo nano /usr/local/bin/debug-cpu.sh
```

```bash
#!/bin/bash
# Debug high CPU usage

echo "=== CPU Usage Analysis ==="

# Overall CPU usage
echo "1. Current CPU Usage:"
top -bn1 | head -10

# Top CPU processes over time
echo -e "\n2. Top CPU Consumers (30 seconds):"
for i in {1..6}; do
    echo "Sample $i:"
    ps aux --sort=-%cpu | head -5 | awk '{print $2, $3, $11}'
    sleep 5
done

# Check for CPU-intensive services
echo -e "\n3. Service CPU Usage:"
systemd-cgtop -n 1 -b --cpu=percentage

# Check CPU frequency scaling
echo -e "\n4. CPU Frequency:"
grep "cpu MHz" /proc/cpuinfo

# Check for thermal throttling
echo -e "\n5. CPU Temperature:"
if command -v sensors &> /dev/null; then
    sensors | grep -E "Core|CPU"
fi

# Check scheduler statistics
echo -e "\n6. Scheduler Statistics:"
cat /proc/schedstat | head -20

# Interrupt statistics
echo -e "\n7. Interrupts:"
cat /proc/interrupts | head -20

# Process tree of high CPU process
echo -e "\n8. Process Tree of Top Consumer:"
TOP_PID=$(ps aux --sort=-%cpu | head -2 | tail -1 | awk '{print $2}')
pstree -p "$TOP_PID"

# Trace system calls (5 seconds)
echo -e "\n9. System Calls of Top Consumer (5 seconds):"
timeout 5 strace -c -p "$TOP_PID" 2>&1
```

### Log Analysis Techniques

#### Advanced Log Analysis

```bash
# Log analysis toolkit
sudo nano /usr/local/bin/log-analyze.sh
```

```bash
#!/bin/bash
# Advanced log analysis script

analyze_auth_logs() {
    echo "=== Authentication Analysis ==="

    # Failed login attempts by IP
    echo "Failed Login Attempts by IP:"
    grep "Failed password" /var/log/auth.log | \
        awk '{print $(NF-3)}' | sort | uniq -c | sort -rn | head -10

    # Successful logins
    echo -e "\nSuccessful Logins:"
    grep "Accepted password\|Accepted publickey" /var/log/auth.log | \
        awk '{print $1, $2, $3, $11}' | tail -10

    # Sudo usage
    echo -e "\nSudo Commands:"
    grep "sudo.*COMMAND" /var/log/auth.log | tail -10

    # Account changes
    echo -e "\nAccount Modifications:"
    grep -E "useradd|usermod|userdel|passwd" /var/log/auth.log | tail -5
}

analyze_system_logs() {
    echo -e "\n=== System Log Analysis ==="

    # Error frequency
    echo "Error Frequency (last 24 hours):"
    journalctl --since="24 hours ago" -p err --no-pager | \
        awk '{print $5}' | sort | uniq -c | sort -rn | head -10

    # Out of memory events
    echo -e "\nOOM (Out of Memory) Events:"
    grep -i "out of memory\|oom-killer" /var/log/syslog | tail -5

    # Disk errors
    echo -e "\nDisk Errors:"
    grep -iE "I/O error|disk error|read error|write error" /var/log/syslog | tail -5

    # Network errors
    echo -e "\nNetwork Errors:"
    grep -iE "link down|link is not ready|connection refused" /var/log/syslog | tail -5
}

analyze_application_logs() {
    echo -e "\n=== Application Log Analysis ==="

    # Nginx errors
    if [ -f /var/log/nginx/error.log ]; then
        echo "Nginx Errors:"
        awk '{print $6, $7, $8, $9, $10}' /var/log/nginx/error.log | \
            sort | uniq -c | sort -rn | head -10
    fi

    # MySQL slow queries
    if [ -f /var/log/mysql/slow.log ]; then
        echo -e "\nMySQL Slow Queries:"
        grep "Query_time" /var/log/mysql/slow.log | tail -5
    fi

    # PHP errors
    if [ -f /var/log/php/error.log ]; then
        echo -e "\nPHP Errors:"
        grep -E "Fatal error|Warning|Notice" /var/log/php/error.log | \
            awk '{print $3, $4, $5}' | sort | uniq -c | sort -rn | head -10
    fi
}

analyze_performance_logs() {
    echo -e "\n=== Performance Analysis ==="

    # High load periods
    echo "High Load Periods:"
    sar -q | awk '$4 > 2 {print $1, $2, "Load:", $4}' | tail -10

    # Memory usage peaks
    echo -e "\nMemory Usage Peaks:"
    sar -r | awk '$4 > 80 {print $1, $2, "Used:", $4"%"}' | tail -10

    # Disk I/O peaks
    echo -e "\nDisk I/O Peaks:"
    sar -d | awk '$10 > 80 {print $1, $2, $3, "Util:", $10"%"}' | tail -10
}

# Pattern search function
search_pattern() {
    local pattern=$1
    local logfile=$2
    local context=${3:-2}

    echo -e "\nSearching for pattern: $pattern in $logfile"
    grep -C "$context" "$pattern" "$logfile" | tail -20
}

# Time-based analysis
analyze_by_time() {
    local hour=$1
    echo -e "\nLog entries for hour $hour:00:"
    journalctl --since="$(date +%Y-%m-%d) $hour:00" --until="$(date +%Y-%m-%d) $hour:59" | \
        head -50
}

# Main menu
case "$1" in
    auth)
        analyze_auth_logs
        ;;
    system)
        analyze_system_logs
        ;;
    app)
        analyze_application_logs
        ;;
    perf)
        analyze_performance_logs
        ;;
    search)
        search_pattern "$2" "$3" "$4"
        ;;
    time)
        analyze_by_time "$2"
        ;;
    all)
        analyze_auth_logs
        analyze_system_logs
        analyze_application_logs
        analyze_performance_logs
        ;;
    *)
        echo "Usage: $0 {auth|system|app|perf|search <pattern> <file>|time <hour>|all}"
        exit 1
        ;;
esac
```

### Network Debugging

#### Network Troubleshooting Tools

```bash
# Network debugging script
sudo nano /usr/local/bin/debug-network.sh
```

```bash
#!/bin/bash
# Comprehensive network debugging

TARGET=${1:-"8.8.8.8"}

echo "=== Network Debugging ==="
echo "Target: $TARGET"
echo

# Basic connectivity
echo "1. Basic Connectivity Test:"
ping -c 4 "$TARGET"

# DNS resolution
echo -e "\n2. DNS Resolution:"
nslookup "$TARGET"
dig "$TARGET" +short

# Traceroute
echo -e "\n3. Network Path:"
traceroute -m 15 "$TARGET"

# MTU discovery
echo -e "\n4. MTU Discovery:"
ping -M do -s 1472 -c 4 "$TARGET"

# Port connectivity (if hostname)
if [[ "$TARGET" =~ ^[a-zA-Z] ]]; then
    echo -e "\n5. Port Scan (common ports):"
    for port in 22 80 443 3306 5432; do
        timeout 1 bash -c "echo >/dev/tcp/$TARGET/$port" 2>/dev/null && \
            echo "Port $port: OPEN" || echo "Port $port: CLOSED"
    done
fi

# Local network configuration
echo -e "\n6. Local Network Configuration:"
ip addr show
ip route show
cat /etc/resolv.conf

# Network statistics
echo -e "\n7. Network Statistics:"
ss -s
netstat -i

# Firewall rules
echo -e "\n8. Firewall Rules:"
sudo iptables -L -n -v | head -30
sudo ufw status numbered

# Network performance
echo -e "\n9. Network Performance Test:"
if command -v iperf3 &> /dev/null; then
    echo "Run 'iperf3 -s' on target and 'iperf3 -c $TARGET' here"
fi

# TCP dump (5 seconds)
echo -e "\n10. Packet Capture (5 seconds):"
sudo timeout 5 tcpdump -i any host "$TARGET" -c 20
```

### Performance Troubleshooting

#### Performance Analysis Script

```bash
# Performance troubleshooting
sudo nano /usr/local/bin/debug-performance.sh
```

```bash
#!/bin/bash
# Performance bottleneck identification

echo "=== Performance Analysis ==="
echo "Collecting data for 30 seconds..."

# Create temporary directory for results
TMPDIR=$(mktemp -d)
trap "rm -rf $TMPDIR" EXIT

# Background monitoring processes
vmstat 1 30 > "$TMPDIR/vmstat.log" &
iostat -x 1 30 > "$TMPDIR/iostat.log" &
mpstat -P ALL 1 30 > "$TMPDIR/mpstat.log" &

# Collect initial state
echo "Initial State:" > "$TMPDIR/initial.log"
ps aux --sort=-%cpu | head -20 >> "$TMPDIR/initial.log"
ps aux --sort=-%mem | head -20 >> "$TMPDIR/initial.log"

# Wait for collection
sleep 31

# Analyze results
echo -e "\n=== Analysis Results ==="

# CPU bottleneck
echo "1. CPU Analysis:"
awk '/^Average:/ {if (NR>1) print}' "$TMPDIR/mpstat.log"

CPU_IDLE=$(awk '/^Average:/ && /all/ {print $NF}' "$TMPDIR/mpstat.log")
if (( $(echo "$CPU_IDLE < 20" | bc -l) )); then
    echo "WARNING: CPU bottleneck detected (idle < 20%)"
fi

# Memory bottleneck
echo -e "\n2. Memory Analysis:"
tail -5 "$TMPDIR/vmstat.log" | awk '{print "Free:", $4, "Buffer:", $5, "Cache:", $6, "Swap In:", $7, "Swap Out:", $8}'

SWAP_ACTIVITY=$(tail -10 "$TMPDIR/vmstat.log" | awk '{sum+=$7+$8} END {print sum}')
if [ "$SWAP_ACTIVITY" -gt 100 ]; then
    echo "WARNING: High swap activity detected"
fi

# I/O bottleneck
echo -e "\n3. I/O Analysis:"
grep "avg-cpu" "$TMPDIR/iostat.log" -A1 | tail -2

IO_WAIT=$(grep "avg-cpu" "$TMPDIR/iostat.log" -A1 | tail -1 | awk '{print $4}')
if (( $(echo "$IO_WAIT > 30" | bc -l) )); then
    echo "WARNING: I/O bottleneck detected (iowait > 30%)"
fi

# Top resource consumers
echo -e "\n4. Top Resource Consumers:"
echo "CPU:"
ps aux --sort=-%cpu | head -5 | awk '{print $2, $3, $11}'
echo -e "\nMemory:"
ps aux --sort=-%mem | head -5 | awk '{print $2, $4, $11}'

# System calls analysis
echo -e "\n5. System Call Analysis (top process):"
TOP_PID=$(ps aux --sort=-%cpu | head -2 | tail -1 | awk '{print $2}')
timeout 5 strace -c -p "$TOP_PID" 2>&1 | head -20

echo -e "\nAnalysis complete."
```

### Application Debugging

#### Application Debug Framework

```bash
# Application debugging framework
sudo nano /usr/local/bin/debug-app.sh
```

```bash
#!/bin/bash
# Application debugging framework

APP_NAME=$1
APP_TYPE=$2  # python|node|php|java

if [ -z "$APP_NAME" ]; then
    echo "Usage: $0 <app-name> [app-type]"
    exit 1
fi

echo "=== Debugging Application: $APP_NAME ==="

# Find application process
find_app_process() {
    echo "1. Finding Application Process:"

    # Try different methods
    PIDS=$(pgrep -f "$APP_NAME" | tr '\n' ' ')

    if [ -z "$PIDS" ]; then
        PIDS=$(ps aux | grep -i "$APP_NAME" | grep -v grep | awk '{print $2}' | tr '\n' ' ')
    fi

    if [ -z "$PIDS" ]; then
        echo "No process found for $APP_NAME"
        return 1
    fi

    echo "Found PIDs: $PIDS"

    for PID in $PIDS; do
        echo -e "\nProcess $PID:"
        ps -p "$PID" -o pid,ppid,user,cmd,state,%cpu,%mem,etime
    done
}

# Check application logs
check_app_logs() {
    echo -e "\n2. Application Logs:"

    # Standard locations
    LOG_PATHS=(
        "/var/log/$APP_NAME"
        "/var/log/${APP_NAME}.log"
        "/var/log/${APP_NAME}/*.log"
        "/var/www/$APP_NAME/logs"
        "/home/*/logs/${APP_NAME}*.log"
    )

    for path in "${LOG_PATHS[@]}"; do
        if ls $path 2>/dev/null; then
            echo "Found logs at: $path"
            tail -20 $path 2>/dev/null
            break
        fi
    done

    # Check journald
    echo -e "\nSystemd Journal:"
    journalctl -u "$APP_NAME" -n 20 --no-pager
}

# Check resources
check_resources() {
    echo -e "\n3. Resource Usage:"

    if [ -n "$PIDS" ]; then
        for PID in $PIDS; do
            echo -e "\nProcess $PID Resources:"

            # Memory map
            echo "Memory:"
            pmap -x "$PID" 2>/dev/null | tail -5

            # Open files
            echo -e "\nOpen Files:"
            lsof -p "$PID" 2>/dev/null | wc -l

            # Network connections
            echo -e "Network Connections:"
            lsof -p "$PID" -i 2>/dev/null | tail -10

            # Threads
            echo -e "\nThreads:"
            ps -L -p "$PID" | wc -l
        done
    fi
}

# Language-specific debugging
debug_by_language() {
    echo -e "\n4. Language-Specific Debugging:"

    case "$APP_TYPE" in
        python)
            echo "Python Application:"
            # Check Python version
            python3 --version

            # Check installed packages
            if [ -d "venv" ]; then
                source venv/bin/activate
                pip list | grep -E "(error|warning)" || echo "No package issues"
                deactivate
            fi

            # Check for syntax errors
            find . -name "*.py" -exec python3 -m py_compile {} \; 2>&1 | head -10
            ;;

        node)
            echo "Node.js Application:"
            # Check Node version
            node --version
            npm --version

            # Check for missing dependencies
            if [ -f "package.json" ]; then
                npm ls 2>&1 | grep -E "(missing|error)" | head -10
            fi

            # PM2 status
            pm2 describe "$APP_NAME" 2>/dev/null
            ;;

        php)
            echo "PHP Application:"
            # Check PHP version
            php --version

            # Check PHP errors
            php -l index.php 2>&1

            # Check composer dependencies
            if [ -f "composer.json" ]; then
                composer validate
            fi
            ;;

        java)
            echo "Java Application:"
            # Check Java version
            java -version

            # JVM stats
            if [ -n "$PIDS" ]; then
                jstat -gc "$PIDS" 2>/dev/null
                jmap -heap "$PIDS" 2>/dev/null | head -20
            fi
            ;;
    esac
}

# Check dependencies
check_dependencies() {
    echo -e "\n5. Dependency Check:"

    # Database connectivity
    echo "Database Connectivity:"
    nc -zv localhost 3306 2>&1 | grep -E "(succeeded|refused)"
    nc -zv localhost 5432 2>&1 | grep -E "(succeeded|refused)"

    # Redis connectivity
    echo -e "\nRedis Connectivity:"
    redis-cli ping 2>/dev/null || echo "Redis not responding"

    # External APIs (example)
    echo -e "\nExternal API Check:"
    curl -s -o /dev/null -w "API Response: %{http_code}\n" http://api.example.com/health
}

# Performance profiling
profile_application() {
    echo -e "\n6. Performance Profile (10 seconds):"

    if [ -n "$PIDS" ]; then
        PID=$(echo $PIDS | awk '{print $1}')

        # CPU sampling
        echo "CPU Sampling:"
        top -b -p "$PID" -n 10 -d 1 | grep "$PID" | \
            awk '{sum+=$9; count++} END {print "Average CPU:", sum/count"%"}'

        # System calls
        echo -e "\nSystem Calls:"
        timeout 10 strace -c -p "$PID" 2>&1 | head -20
    fi
}

# Main execution
find_app_process
check_app_logs
check_resources
debug_by_language
check_dependencies
profile_application

echo -e "\n=== Debugging Complete ==="
```

### Getting Help Effectively

#### Information Gathering for Support

```bash
# Create support information script
sudo nano /usr/local/bin/gather-support-info.sh
```

```bash
#!/bin/bash
# Gather information for support requests

OUTPUT_DIR="/tmp/support-$(date +%Y%m%d-%H%M%S)"
mkdir -p "$OUTPUT_DIR"

echo "Gathering system information for support..."

# System information
echo "System Information" > "$OUTPUT_DIR/system.txt"
uname -a >> "$OUTPUT_DIR/system.txt"
lsb_release -a >> "$OUTPUT_DIR/system.txt" 2>&1
uptime >> "$OUTPUT_DIR/system.txt"

# Hardware information
echo -e "\nHardware Information" >> "$OUTPUT_DIR/system.txt"
lscpu >> "$OUTPUT_DIR/system.txt"
free -h >> "$OUTPUT_DIR/system.txt"
df -h >> "$OUTPUT_DIR/system.txt"
lsblk >> "$OUTPUT_DIR/system.txt"

# Package information
dpkg -l > "$OUTPUT_DIR/packages.txt"
snap list > "$OUTPUT_DIR/snaps.txt" 2>&1

# Service status
systemctl list-units --failed > "$OUTPUT_DIR/failed-services.txt"
systemctl status > "$OUTPUT_DIR/system-status.txt"

# Network configuration
ip addr show > "$OUTPUT_DIR/network.txt"
ip route show >> "$OUTPUT_DIR/network.txt"
ss -tuln >> "$OUTPUT_DIR/network.txt"

# Recent logs
journalctl -xe -n 1000 > "$OUTPUT_DIR/journal.log"
dmesg > "$OUTPUT_DIR/dmesg.log"

# Configuration files (sanitized)
for conf in /etc/nginx/nginx.conf /etc/apache2/apache2.conf /etc/ssh/sshd_config; do
    if [ -f "$conf" ]; then
        grep -v "^\s*#\|^\s*$" "$conf" > "$OUTPUT_DIR/$(basename $conf).txt"
    fi
done

# Create archive
tar -czf "$OUTPUT_DIR.tar.gz" -C /tmp "$(basename $OUTPUT_DIR)"

echo "Support information collected: $OUTPUT_DIR.tar.gz"
echo ""
echo "When asking for help, include:"
echo "1. Description of the problem"
echo "2. What you expected to happen"
echo "3. What actually happened"
echo "4. Steps to reproduce the issue"
echo "5. Error messages (exact text)"
echo "6. Recent changes to the system"
echo "7. The support archive: $OUTPUT_DIR.tar.gz"
```

---

## Chapter 23: System Recovery

### Boot Issues Resolution

#### GRUB Recovery

```bash
# GRUB recovery procedures

# 1. Access GRUB menu
# Hold Shift or Esc during boot

# 2. From GRUB menu, press 'e' to edit

# 3. Common fixes in GRUB:

# Fix root partition
# Change: root=UUID=xxx
# To: root=/dev/sda1

# Single user mode
# Add to linux line: single
# Or: init=/bin/bash

# Disable problematic services
# Add to linux line: systemd.unit=rescue.target

# 4. Press Ctrl+X or F10 to boot

# After booting to recovery:

# Remount root as read-write
mount -o remount,rw /

# Fix GRUB installation
grub-install /dev/sda
update-grub

# Rebuild initramfs
update-initramfs -u -k all

# Fix package issues
dpkg --configure -a
apt-get update
apt-get -f install
```

#### Boot Repair Script

```bash
# Boot repair automation
sudo nano /usr/local/bin/boot-repair.sh
```

```bash
#!/bin/bash
# Automated boot repair script

echo "=== Boot Repair Script ==="
echo "WARNING: Run only from recovery mode or live USB"
echo ""

# Check if running as root
if [ "$EUID" -ne 0 ]; then
    echo "Please run as root"
    exit 1
fi

# Mount filesystems
repair_mounts() {
    echo "1. Checking and mounting filesystems..."

    # Remount root as read-write
    mount -o remount,rw /

    # Mount necessary filesystems
    mount -t proc proc /proc
    mount -t sysfs sys /sys
    mount -t devtmpfs udev /dev
    mount -t devpts devpts /dev/pts

    # Mount boot partition if separate
    if [ -b /dev/sda1 ]; then
        mount /dev/sda1 /boot
    fi

    echo "Filesystems mounted"
}

# Fix filesystem errors
fix_filesystem() {
    echo -e "\n2. Checking filesystems..."

    # Get root device
    ROOT_DEV=$(mount | grep "on / " | awk '{print $1}')

    # Check and fix filesystem
    fsck -y "$ROOT_DEV"

    # Check other filesystems
    fsck -A -y

    echo "Filesystem check complete"
}

# Repair package system
repair_packages() {
    echo -e "\n3. Repairing package system..."

    # Fix dpkg database
    dpkg --configure -a

    # Fix broken dependencies
    apt-get update
    apt-get -f install -y

    # Remove problematic packages if needed
    apt-get autoremove -y

    # Clean package cache
    apt-get clean

    echo "Package system repaired"
}

# Repair GRUB
repair_grub() {
    echo -e "\n4. Repairing GRUB bootloader..."

    # Detect boot disk
    BOOT_DISK=$(lsblk -no pkname $(mount | grep "on / " | awk '{print $1}') | head -1)

    if [ -z "$BOOT_DISK" ]; then
        echo "Could not detect boot disk"
        return 1
    fi

    # Install GRUB
    grub-install /dev/"$BOOT_DISK"

    # Update GRUB configuration
    update-grub

    echo "GRUB repaired"
}

# Fix kernel issues
repair_kernel() {
    echo -e "\n5. Checking kernel..."

    # Get current kernel
    CURRENT_KERNEL=$(uname -r)

    # Reinstall current kernel
    apt-get install --reinstall linux-image-"$CURRENT_KERNEL" -y

    # Update initramfs
    update-initramfs -u -k all

    echo "Kernel repaired"
}

# Fix networking
repair_network() {
    echo -e "\n6. Resetting network configuration..."

    # Reset network configuration
    rm -f /etc/netplan/*.yaml

    # Create default configuration
    cat > /etc/netplan/01-netcfg.yaml << EOF
network:
  version: 2
  ethernets:
    eth0:
      dhcp4: true
EOF

    # Apply configuration
    netplan generate
    netplan apply

    echo "Network configuration reset"
}

# Main repair process
main() {
    repair_mounts
    fix_filesystem
    repair_packages
    repair_grub
    repair_kernel
    repair_network

    echo -e "\n=== Repair Complete ==="
    echo "Please reboot the system: shutdown -r now"
}

# Confirm before proceeding
read -p "This will attempt to repair the system. Continue? (y/n): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    main
else
    echo "Repair cancelled"
fi
```

### Filesystem Recovery

#### Filesystem Recovery Procedures

```bash
# Filesystem recovery script
sudo nano /usr/local/bin/fs-recovery.sh
```

```bash
#!/bin/bash
# Filesystem recovery procedures

echo "=== Filesystem Recovery ==="

# Check all filesystems
check_filesystems() {
    echo "1. Filesystem Status:"

    # List all filesystems
    lsblk -f

    # Check mount status
    echo -e "\nMounted filesystems:"
    mount | column -t

    # Check for errors in system log
    echo -e "\nRecent filesystem errors:"
    dmesg | grep -iE "ext4|xfs|btrfs|error|corrupt" | tail -20
}

# Repair ext4 filesystem
repair_ext4() {
    local device=$1
    echo "Repairing ext4 filesystem on $device"

    # Unmount if mounted
    umount "$device" 2>/dev/null

    # Run filesystem check
    e2fsck -p "$device"  # Automatic repair

    if [ $? -ne 0 ]; then
        echo "Automatic repair failed, trying forced repair..."
        e2fsck -fy "$device"  # Force repair
    fi

    # Check for bad blocks
    echo "Checking for bad blocks..."
    badblocks -sv "$device"

    # Optimize filesystem
    echo "Optimizing filesystem..."
    e2fsck -D "$device"  # Optimize directories
    tune2fs -O has_journal "$device"  # Ensure journal is enabled
}

# Repair XFS filesystem
repair_xfs() {
    local device=$1
    echo "Repairing XFS filesystem on $device"

    # Unmount if mounted
    umount "$device" 2>/dev/null

    # Run XFS repair
    xfs_repair "$device"

    if [ $? -ne 0 ]; then
        echo "Standard repair failed, trying forced repair..."
        xfs_repair -L "$device"  # Zero log, may lose recent changes
    fi
}

# Recover deleted files
recover_deleted() {
    local device=$1
    local output_dir=$2

    echo "Attempting to recover deleted files from $device"
    echo "Output directory: $output_dir"

    mkdir -p "$output_dir"

    # Using extundelete for ext4
    if command -v extundelete &> /dev/null; then
        extundelete "$device" --restore-all --output-dir "$output_dir"
    else
        echo "extundelete not installed. Install with: apt install extundelete"
    fi

    # Using photorec for general recovery
    if command -v photorec &> /dev/null; then
        photorec /d "$output_dir" "$device"
    else
        echo "photorec not installed. Install with: apt install testdisk"
    fi
}

# Mount recovery
mount_recovery() {
    local device=$1
    local mount_point=$2

    echo "Attempting to mount $device at $mount_point"

    mkdir -p "$mount_point"

    # Try normal mount
    if mount "$device" "$mount_point"; then
        echo "Successfully mounted"
        return 0
    fi

    # Try read-only mount
    echo "Normal mount failed, trying read-only..."
    if mount -o ro "$device" "$mount_point"; then
        echo "Mounted read-only"
        return 0
    fi

    # Try recovery mount options
    echo "Trying recovery mount options..."

    # For ext4
    mount -o ro,noload "$device" "$mount_point" 2>/dev/null && \
        echo "Mounted with noload option" && return 0

    # For XFS
    mount -o ro,norecovery "$device" "$mount_point" 2>/dev/null && \
        echo "Mounted with norecovery option" && return 0

    echo "Failed to mount device"
    return 1
}

# LVM recovery
lvm_recovery() {
    echo "LVM Recovery:"

    # Scan for LVM devices
    echo "Scanning for LVM devices..."
    pvscan
    vgscan
    lvscan

    # Activate volume groups
    echo "Activating volume groups..."
    vgchange -ay

    # Display LVM information
    echo -e "\nLVM Status:"
    pvdisplay
    vgdisplay
    lvdisplay
}

# RAID recovery
raid_recovery() {
    echo "RAID Recovery:"

    # Scan for RAID arrays
    echo "Scanning for RAID arrays..."
    mdadm --assemble --scan

    # Display RAID status
    cat /proc/mdstat

    # Detailed RAID information
    for array in /dev/md*; do
        if [ -b "$array" ]; then
            echo -e "\nArray $array:"
            mdadm --detail "$array"
        fi
    done
}

# Main menu
case "$1" in
    check)
        check_filesystems
        ;;
    repair-ext4)
        repair_ext4 "$2"
        ;;
    repair-xfs)
        repair_xfs "$2"
        ;;
    recover)
        recover_deleted "$2" "$3"
        ;;
    mount)
        mount_recovery "$2" "$3"
        ;;
    lvm)
        lvm_recovery
        ;;
    raid)
        raid_recovery
        ;;
    *)
        echo "Usage: $0 {check|repair-ext4 <device>|repair-xfs <device>|recover <device> <output_dir>|mount <device> <mount_point>|lvm|raid}"
        exit 1
        ;;
esac
```

### Service Recovery

#### Service Recovery Automation

```bash
# Service recovery script
sudo nano /usr/local/bin/service-recovery.sh
```

```bash
#!/bin/bash
# Automated service recovery

CRITICAL_SERVICES="ssh nginx mysql postgresql redis-server"
LOG_FILE="/var/log/service-recovery.log"

log_message() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

# Recover individual service
recover_service() {
    local service=$1
    log_message "Attempting to recover $service"

    # Stop the service completely
    systemctl stop "$service"
    sleep 2

    # Kill any remaining processes
    pkill -f "$service"

    # Clear failed state
    systemctl reset-failed "$service"

    # Check and fix permissions
    case "$service" in
        ssh)
            chmod 600 /etc/ssh/ssh_host_*_key
            chmod 644 /etc/ssh/ssh_host_*_key.pub
            ;;
        nginx)
            nginx -t || return 1
            chown -R www-data:www-data /var/log/nginx
            ;;
        mysql)
            chown -R mysql:mysql /var/lib/mysql
            chown -R mysql:mysql /var/log/mysql
            ;;
        postgresql)
            chown -R postgres:postgres /var/lib/postgresql
            chown -R postgres:postgres /var/log/postgresql
            ;;
    esac

    # Start the service
    if systemctl start "$service"; then
        log_message "Successfully recovered $service"
        return 0
    else
        log_message "Failed to recover $service"
        return 1
    fi
}

# Dependency resolution
resolve_dependencies() {
    local service=$1
    log_message "Resolving dependencies for $service"

    # Get service dependencies
    deps=$(systemctl list-dependencies "$service" | grep -E "●|○" | awk '{print $2}')

    for dep in $deps; do
        if ! systemctl is-active "$dep" &>/dev/null; then
            log_message "Starting dependency: $dep"
            systemctl start "$dep"
        fi
    done
}

# Port conflict resolution
resolve_port_conflicts() {
    local service=$1
    local port=$2

    log_message "Checking port $port for $service"

    # Find process using the port
    pid=$(ss -tlnp | grep ":$port" | grep -oP 'pid=\K[0-9]+')

    if [ -n "$pid" ]; then
        process=$(ps -p "$pid" -o comm=)
        log_message "Port $port is used by $process (PID: $pid)"

        # Kill conflicting process if it's not a critical service
        if [[ ! "$CRITICAL_SERVICES" =~ $process ]]; then
            kill "$pid"
            sleep 2
            kill -9 "$pid" 2>/dev/null
            log_message "Killed conflicting process $process"
        fi
    fi
}

# Configuration recovery
recover_config() {
    local service=$1

    log_message "Recovering configuration for $service"

    # Backup current config
    cp -r /etc/"$service" /etc/"$service".backup.$(date +%Y%m%d)

    # Check for config backup
    if [ -d /etc/"$service".backup ]; then
        log_message "Restoring from backup"
        cp -r /etc/"$service".backup/* /etc/"$service"/
    fi

    # Validate configuration
    case "$service" in
        nginx)
            nginx -t || return 1
            ;;
        apache2)
            apache2ctl configtest || return 1
            ;;
        ssh)
            sshd -t || return 1
            ;;
    esac

    return 0
}

# Main recovery process
main() {
    log_message "Starting service recovery"

    for service in $CRITICAL_SERVICES; do
        if ! systemctl is-active "$service" &>/dev/null; then
            log_message "Service $service is not running"

            # Resolve dependencies
            resolve_dependencies "$service"

            # Resolve port conflicts
            case "$service" in
                ssh)
                    resolve_port_conflicts "$service" 22
                    ;;
                nginx)
                    resolve_port_conflicts "$service" 80
                    resolve_port_conflicts "$service" 443
                    ;;
                mysql)
                    resolve_port_conflicts "$service" 3306
                    ;;
                postgresql)
                    resolve_port_conflicts "$service" 5432
                    ;;
                redis-server)
                    resolve_port_conflicts "$service" 6379
                    ;;
            esac

            # Recover configuration
            recover_config "$service"

            # Attempt recovery
            recover_service "$service"
        else
            log_message "Service $service is running"
        fi
    done

    log_message "Service recovery complete"
}

main
```

### Data Recovery Techniques

#### Data Recovery Toolkit

```bash
# Data recovery toolkit
sudo nano /usr/local/bin/data-recovery.sh
```

```bash
#!/bin/bash
# Comprehensive data recovery toolkit

RECOVERY_DIR="/recovery"
mkdir -p "$RECOVERY_DIR"

# Database recovery
recover_mysql_database() {
    local database=$1
    echo "Recovering MySQL database: $database"

    # Try to repair tables
    mysqlcheck --repair --all-databases

    # Force InnoDB recovery
    echo "Forcing InnoDB recovery mode..."
    echo "[mysqld]" > /tmp/recovery.cnf
    echo "innodb_force_recovery = 1" >> /tmp/recovery.cnf

    # Start MySQL in recovery mode
    mysqld --defaults-file=/tmp/recovery.cnf &
    sleep 10

    # Dump database
    mysqldump --all-databases > "$RECOVERY_DIR/mysql_recovery.sql"

    # Stop recovery mode MySQL
    mysqladmin shutdown

    echo "Database dumped to $RECOVERY_DIR/mysql_recovery.sql"
}

recover_postgresql_database() {
    echo "Recovering PostgreSQL database"

    # Reset transaction log
    sudo -u postgres pg_resetwal /var/lib/postgresql/14/main

    # Start in single-user mode
    sudo -u postgres postgres --single -D /var/lib/postgresql/14/main postgres

    # Dump all databases
    sudo -u postgres pg_dumpall > "$RECOVERY_DIR/postgresql_recovery.sql"

    echo "Database dumped to $RECOVERY_DIR/postgresql_recovery.sql"
}

# File recovery
recover_deleted_files() {
    local partition=$1
    echo "Scanning for deleted files on $partition"

    # Install recovery tools if not present
    which testdisk || apt-get install -y testdisk
    which extundelete || apt-get install -y extundelete

    # Create recovery directory
    mkdir -p "$RECOVERY_DIR/files"

    # Use extundelete for ext4
    if file -sL "$partition" | grep -q ext4; then
        extundelete "$partition" --restore-all -o "$RECOVERY_DIR/files"
    fi

    # Use testdisk for general recovery
    testdisk /log /cmd "$partition" undelete

    echo "Recovered files saved to $RECOVERY_DIR/files"
}

# Log recovery
recover_logs() {
    echo "Recovering system logs"

    # Recover journald logs
    mkdir -p "$RECOVERY_DIR/logs"

    # Copy corrupted journal files
    cp -r /var/log/journal "$RECOVERY_DIR/logs/"

    # Try to export readable entries
    journalctl --file=/var/log/journal/*/*.journal \
        --output=export > "$RECOVERY_DIR/logs/journal_export.txt" 2>/dev/null

    # Recover text logs
    for log in /var/log/*.log; do
        if [ -f "$log" ]; then
            strings "$log" > "$RECOVERY_DIR/logs/$(basename $log).recovered"
        fi
    done

    echo "Logs recovered to $RECOVERY_DIR/logs"
}

# Configuration recovery
recover_configs() {
    echo "Recovering configuration files"

    mkdir -p "$RECOVERY_DIR/configs"

    # System configurations
    configs=(
        "/etc/nginx"
        "/etc/apache2"
        "/etc/mysql"
        "/etc/postgresql"
        "/etc/ssh"
        "/etc/netplan"
        "/etc/systemd"
    )

    for config in "${configs[@]}"; do
        if [ -e "$config" ]; then
            cp -r "$config" "$RECOVERY_DIR/configs/"
        fi
    done

    # Package list
    dpkg -l > "$RECOVERY_DIR/configs/installed_packages.txt"

    echo "Configurations backed up to $RECOVERY_DIR/configs"
}

# User data recovery
recover_user_data() {
    echo "Recovering user data"

    mkdir -p "$RECOVERY_DIR/users"

    # Home directories
    for user_home in /home/*; do
        if [ -d "$user_home" ]; then
            username=$(basename "$user_home")
            echo "Recovering data for user: $username"

            # Important directories
            dirs=(".ssh" ".config" "Documents" "scripts")

            for dir in "${dirs[@]}"; do
                if [ -d "$user_home/$dir" ]; then
                    mkdir -p "$RECOVERY_DIR/users/$username"
                    cp -r "$user_home/$dir" "$RECOVERY_DIR/users/$username/"
                fi
            done
        fi
    done

    echo "User data recovered to $RECOVERY_DIR/users"
}

# Main menu
echo "=== Data Recovery Toolkit ==="
echo "1. Recover MySQL Database"
echo "2. Recover PostgreSQL Database"
echo "3. Recover Deleted Files"
echo "4. Recover Logs"
echo "5. Recover Configurations"
echo "6. Recover User Data"
echo "7. Full Recovery (All)"
echo ""
read -p "Select option: " option

case $option in
    1) recover_mysql_database ;;
    2) recover_postgresql_database ;;
    3) read -p "Enter partition (e.g., /dev/sda1): " part
       recover_deleted_files "$part" ;;
    4) recover_logs ;;
    5) recover_configs ;;
    6) recover_user_data ;;
    7) recover_mysql_database
       recover_postgresql_database
       recover_logs
       recover_configs
       recover_user_data ;;
    *) echo "Invalid option" ;;
esac
```

### Root Password Recovery

#### Password Recovery Procedures

```bash
# Root password recovery script
# This must be run from recovery mode or live USB

# Method 1: Using recovery mode
# 1. Boot to GRUB menu
# 2. Select Advanced options
# 3. Select recovery mode
# 4. Select "root - Drop to root shell prompt"

# Method 2: Using init=/bin/bash
# 1. In GRUB, press 'e' to edit
# 2. Find line starting with "linux"
# 3. Replace "ro quiet splash" with "rw init=/bin/bash"
# 4. Press Ctrl+X to boot

# Once in recovery shell:

# Remount root filesystem as read-write
mount -o remount,rw /

# Reset root password
passwd root

# Or reset specific user password
passwd username

# Update authentication
touch /etc/shadow

# If using systemd, you may need to:
# 1. Boot with "systemd.unit=rescue.target" instead
# 2. Then run:
mount -o remount,rw /
passwd root

# Sync and reboot
sync
reboot -f
```

### Emergency Maintenance Mode

#### Emergency Mode Procedures

```bash
# Emergency maintenance script
sudo nano /usr/local/bin/emergency-maint.sh
```

```bash
#!/bin/bash
# Emergency maintenance mode procedures

echo "=== Emergency Maintenance Mode ==="
echo "WARNING: System is in emergency state"
echo ""

# Basic system check
emergency_check() {
    echo "1. Basic System Check:"

    # Check root filesystem
    echo "Root filesystem:"
    mount | grep "on / "

    # Check available memory
    echo -e "\nMemory status:"
    free -h

    # Check disk space
    echo -e "\nDisk space:"
    df -h /

    # Check network
    echo -e "\nNetwork status:"
    ip link show
}

# Emergency network setup
emergency_network() {
    echo -e "\n2. Emergency Network Setup:"

    # Bring up loopback
    ip link set lo up

    # Find first ethernet interface
    ETH=$(ip link show | grep -E "^[0-9]+: e" | head -1 | cut -d: -f2 | tr -d ' ')

    if [ -n "$ETH" ]; then
        echo "Configuring $ETH with DHCP..."
        ip link set "$ETH" up
        dhclient "$ETH"
    fi

    # Show IP
    ip addr show
}

# Emergency package fix
emergency_packages() {
    echo -e "\n3. Emergency Package Repair:"

    # Fix dpkg interruptions
    dpkg --configure -a

    # Force remove problematic package
    if [ -n "$1" ]; then
        dpkg --remove --force-remove-reinstreq "$1"
    fi

    # Clean package cache
    apt-get clean

    # Update package list
    apt-get update

    # Fix dependencies
    apt-get -f install
}

# Emergency service disable
emergency_disable_services() {
    echo -e "\n4. Disabling Non-Essential Services:"

    # Services to disable in emergency
    services=(
        "apache2"
        "nginx"
        "mysql"
        "postgresql"
        "docker"
        "snapd"
    )

    for service in "${services[@]}"; do
        if systemctl is-enabled "$service" &>/dev/null; then
            systemctl disable "$service"
            echo "Disabled $service"
        fi
    done
}

# Emergency backup
emergency_backup() {
    echo -e "\n5. Emergency Backup:"

    BACKUP_DIR="/emergency-backup"
    mkdir -p "$BACKUP_DIR"

    # Backup critical files
    tar -czf "$BACKUP_DIR/etc-backup.tar.gz" /etc 2>/dev/null
    tar -czf "$BACKUP_DIR/home-backup.tar.gz" /home 2>/dev/null

    # Backup package list
    dpkg -l > "$BACKUP_DIR/packages.txt"

    # Backup system info
    uname -a > "$BACKUP_DIR/system.txt"
    lsblk >> "$BACKUP_DIR/system.txt"

    echo "Backup created in $BACKUP_DIR"
}

# Recovery checklist
recovery_checklist() {
    echo -e "\n=== Recovery Checklist ==="
    echo "[ ] Filesystem checked and mounted"
    echo "[ ] Network connectivity restored"
    echo "[ ] Package system repaired"
    echo "[ ] Critical services running"
    echo "[ ] System logs checked"
    echo "[ ] Backup created"
    echo "[ ] Root cause identified"
    echo "[ ] Documentation updated"
}

# Main menu
PS3="Select emergency action: "
options=(
    "System Check"
    "Setup Network"
    "Fix Packages"
    "Disable Services"
    "Emergency Backup"
    "Show Checklist"
    "Exit"
)

select opt in "${options[@]}"; do
    case $REPLY in
        1) emergency_check ;;
        2) emergency_network ;;
        3) emergency_packages ;;
        4) emergency_disable_services ;;
        5) emergency_backup ;;
        6) recovery_checklist ;;
        7) break ;;
        *) echo "Invalid option" ;;
    esac
done
```

### Post-Incident Analysis

#### Incident Analysis Framework

```bash
# Post-incident analysis script
sudo nano /usr/local/bin/post-incident.sh
```

```bash
#!/bin/bash
# Post-incident analysis and reporting

INCIDENT_DIR="/var/log/incidents/$(date +%Y%m%d-%H%M%S)"
mkdir -p "$INCIDENT_DIR"

echo "=== Post-Incident Analysis ==="
echo "Incident Time: $(date)"
echo ""

# Collect incident data
collect_incident_data() {
    echo "Collecting incident data..."

    # Timeline of events
    echo "=== Timeline ===" > "$INCIDENT_DIR/timeline.txt"

    # Last 100 system events
    journalctl -n 100 > "$INCIDENT_DIR/journal_recent.log"

    # System state at incident
    ps aux > "$INCIDENT_DIR/processes.txt"
    netstat -tulpn > "$INCIDENT_DIR/network.txt" 2>&1
    df -h > "$INCIDENT_DIR/disk.txt"
    free -h > "$INCIDENT_DIR/memory.txt"

    # Service status
    systemctl status > "$INCIDENT_DIR/services.txt"

    # Recent changes
    echo "=== Recent Package Changes ===" > "$INCIDENT_DIR/changes.txt"
    grep -E "install|remove|upgrade" /var/log/dpkg.log | tail -50 >> "$INCIDENT_DIR/changes.txt"

    # User activity
    echo "=== User Activity ===" > "$INCIDENT_DIR/user_activity.txt"
    last -50 >> "$INCIDENT_DIR/user_activity.txt"

    echo "Data collected in $INCIDENT_DIR"
}

# Analyze root cause
analyze_root_cause() {
    echo -e "\nAnalyzing potential root causes..."

    ANALYSIS="$INCIDENT_DIR/analysis.txt"

    echo "=== Root Cause Analysis ===" > "$ANALYSIS"
    echo "Date: $(date)" >> "$ANALYSIS"
    echo "" >> "$ANALYSIS"

    # Check for OOM killer
    if dmesg | grep -q "Out of memory"; then
        echo "FINDING: Out of Memory killer was triggered" >> "$ANALYSIS"
        dmesg | grep "Out of memory" | tail -5 >> "$ANALYSIS"
    fi

    # Check for disk space issues
    if [ $(df / | tail -1 | awk '{print $5}' | sed 's/%//') -gt 90 ]; then
        echo "FINDING: Disk space critical (>90%)" >> "$ANALYSIS"
        df -h >> "$ANALYSIS"
    fi

    # Check for failed services
    failed_services=$(systemctl list-units --failed --no-legend | wc -l)
    if [ "$failed_services" -gt 0 ]; then
        echo "FINDING: $failed_services failed services detected" >> "$ANALYSIS"
        systemctl list-units --failed >> "$ANALYSIS"
    fi

    # Check for security breaches
    if grep -q "Failed password\|BREAK-IN" /var/log/auth.log; then
        echo "FINDING: Potential security breach detected" >> "$ANALYSIS"
        grep "Failed password\|BREAK-IN" /var/log/auth.log | tail -10 >> "$ANALYSIS"
    fi

    # Check for hardware errors
    if dmesg | grep -qiE "error|fail|fault"; then
        echo "FINDING: Hardware errors detected" >> "$ANALYSIS"
        dmesg | grep -iE "error|fail|fault" | tail -10 >> "$ANALYSIS"
    fi

    echo -e "\nAnalysis saved to $ANALYSIS"
}

# Generate report
generate_report() {
    echo -e "\nGenerating incident report..."

    REPORT="$INCIDENT_DIR/incident_report.md"

    cat > "$REPORT" << EOF
# Incident Report

## Incident Details
- **Date/Time**: $(date)
- **System**: $(hostname -f)
- **Severity**: [TO BE FILLED]
- **Duration**: [TO BE FILLED]

## Description
[Brief description of the incident]

## Impact
- Services affected:
- Users affected:
- Data loss:

## Timeline
$(tail -20 "$INCIDENT_DIR/timeline.txt" 2>/dev/null)

## Root Cause
$(cat "$INCIDENT_DIR/analysis.txt" 2>/dev/null | grep "FINDING")

## Resolution Steps
1. [Step taken to resolve]
2. [Step taken to resolve]
3. [Step taken to resolve]

## Lessons Learned
- What went well:
- What could be improved:

## Action Items
- [ ] Update documentation
- [ ] Implement monitoring for [specific metric]
- [ ] Create automation for [recovery process]
- [ ] Train team on [specific procedure]

## Prevention Measures
- [Measure to prevent recurrence]
- [Measure to prevent recurrence]

---
Generated: $(date)
EOF

    echo "Report template created: $REPORT"
    echo "Please edit the report to add specific details"
}

# Create recovery documentation
create_documentation() {
    echo -e "\nCreating recovery documentation..."

    DOC="$INCIDENT_DIR/recovery_steps.md"

    cat > "$DOC" << EOF
# Recovery Documentation

## Issue: [Issue Title]

### Symptoms
- [Symptom 1]
- [Symptom 2]

### Root Cause
[Identified root cause]

### Solution

\`\`\`bash
# Step 1: [Description]
[commands]

# Step 2: [Description]
[commands]

# Step 3: [Description]
[commands]
\`\`\`

### Verification
\`\`\`bash
# Verify the fix
[verification commands]
\`\`\`

### Prevention
To prevent this issue in the future:
1. [Prevention step]
2. [Prevention step]

### Related Issues
- [Link to similar issues]

### References
- [Documentation links]
EOF

    echo "Documentation template created: $DOC"
}

# Main execution
collect_incident_data
analyze_root_cause
generate_report
create_documentation

echo -e "\n=== Post-Incident Analysis Complete ==="
echo "All data saved to: $INCIDENT_DIR"
echo ""
echo "Next steps:"
echo "1. Complete the incident report"
echo "2. Review with team"
echo "3. Implement preventive measures"
echo "4. Update monitoring and alerts"
```

---

## Practice Exercises

### Exercise 1: Troubleshooting Practice
1. Create a script that diagnoses common system issues
2. Simulate various failures (disk full, service crash, network issue)
3. Use troubleshooting tools to identify root causes
4. Document the resolution process
5. Create automated recovery procedures

### Exercise 2: Recovery Scenarios
1. Practice booting into recovery mode
2. Repair a corrupted filesystem
3. Recover a failed service with dependencies
4. Restore data from backups
5. Reset forgotten passwords

### Exercise 3: Emergency Response
1. Create an emergency response checklist
2. Set up emergency maintenance procedures
3. Practice data recovery techniques
4. Implement automated recovery scripts
5. Create incident response documentation

### Exercise 4: Post-Incident Process
1. Simulate a system failure
2. Collect forensic data
3. Perform root cause analysis
4. Generate an incident report
5. Create prevention measures

---

## Quick Reference

### Troubleshooting Commands
```bash
# System diagnosis
systemctl status           # Service status
journalctl -xe             # Recent logs
dmesg | tail              # Kernel messages
top                       # Process activity
df -h                     # Disk usage
free -h                   # Memory usage

# Network troubleshooting
ip addr show              # Network interfaces
ss -tulpn                 # Open ports
ping -c 4 host           # Connectivity test
traceroute host          # Network path
nslookup domain          # DNS resolution

# Process debugging
strace -p PID            # System calls
lsof -p PID              # Open files
ps aux | grep process    # Find processes
```

### Recovery Commands
```bash
# Boot recovery
grub-install /dev/sda     # Reinstall GRUB
update-grub              # Update GRUB config
update-initramfs -u      # Update initramfs

# Filesystem recovery
fsck -y /dev/sda1        # Check filesystem
mount -o remount,rw /    # Remount read-write
badblocks -sv /dev/sda   # Check for bad blocks

# Service recovery
systemctl reset-failed    # Clear failed state
systemctl daemon-reload   # Reload configs
dpkg --configure -a      # Fix package issues

# Password recovery
passwd username          # Reset password
passwd -l username       # Lock account
passwd -u username       # Unlock account
```

---

## Additional Resources

### Documentation
- [Ubuntu Server Guide - Troubleshooting](https://ubuntu.com/server/docs/troubleshooting)
- [Linux System Recovery](https://www.tldp.org/LDP/sag/html/system-recovery.html)
- [SystemD Debugging](https://www.freedesktop.org/software/systemd/man/systemd-analyze.html)
- [Kernel Debugging](https://www.kernel.org/doc/html/latest/admin-guide/bug-hunting.html)

### Tools
- [SystemRescue](https://www.system-rescue.org/) - Recovery live system
- [TestDisk](https://www.cgsecurity.org/wiki/TestDisk) - Data recovery
- [GParted Live](https://gparted.org/livecd.php) - Partition management
- [Trinity Rescue Kit](http://trinityhome.org/) - Recovery and repair

### Best Practices
- [Incident Response Guide](https://www.sans.org/reading-room/whitepapers/incident/)
- [Linux Performance Analysis](http://www.brendangregg.com/usemethod.html)
- [Post-Mortem Template](https://github.com/dastergon/postmortem-templates)

### Next Steps
After completing this section, you should:
- Have systematic troubleshooting methodology
- Be able to recover from various system failures
- Know how to perform root cause analysis
- Have emergency procedures documented
- Be prepared for incident response

Continue to Part 11 to learn about production operations and best practices.