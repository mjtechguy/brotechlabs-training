# Part 7: Monitoring and Performance

## Prerequisites

Before starting this section, you should understand:
- Basic Linux commands and system navigation
- How to read and analyze log files
- Understanding of processes and services
- Basic networking concepts
- How to use systemctl and journalctl

**Learning Resources:**
- [Linux Performance Analysis](http://www.brendangregg.com/linuxperf.html)
- [Prometheus Documentation](https://prometheus.io/docs/introduction/overview/)
- [System Performance Tuning](https://www.kernel.org/doc/html/latest/admin-guide/sysctl/index.html)
- [Ubuntu Performance Guide](https://ubuntu.com/server/docs/performance)

---

## Chapter 16: System Monitoring

### Introduction to System Monitoring

Effective monitoring helps you:
- Detect problems before they become critical
- Understand system behavior and usage patterns
- Plan capacity and resources
- Troubleshoot performance issues
- Ensure service availability

### Resource Monitoring (CPU, RAM, Disk, Network)

#### CPU Monitoring

```bash
# Real-time CPU usage
top
# Press '1' to see all CPU cores
# Press 'h' for help
# Press 'q' to quit

# Better alternative to top
htop
# Install if not available: sudo apt install htop

# CPU information
lscpu

# View CPU details
cat /proc/cpuinfo

# Simple CPU usage
mpstat 1 5  # Report every 1 second, 5 times
# Install: sudo apt install sysstat

# Per-core CPU usage
mpstat -P ALL 1

# CPU usage by process
pidstat 1 5
pidstat -u -p PID 1  # Specific process

# Historical CPU data
sar -u 1 10  # CPU usage every 1 second, 10 times
sar -u -f /var/log/sysstat/sa01  # Historical data

# Load average
uptime
cat /proc/loadavg

# Understanding load average:
# 1.23 4.56 7.89
#  ^    ^    ^
#  |    |    +--- 15-minute average
#  |    +-------- 5-minute average
#  +------------- 1-minute average
# Rule of thumb: Load should be < number of CPU cores
```

#### Memory Monitoring

```bash
# Memory usage overview
free -h

# Detailed memory statistics
vmstat 1 5  # Every 1 second, 5 times

# Memory usage by process
ps aux --sort=-%mem | head -20

# Detailed memory info
cat /proc/meminfo

# Swap usage
swapon --show
cat /proc/swaps

# Cache and buffer details
sudo slabtop  # Real-time kernel slab cache

# Memory usage over time
sar -r 1 10  # Memory stats every 1 second, 10 times

# Per-process memory monitoring
pmap -x PID  # Memory map of a process
smem -tk     # Memory usage with totals
# Install: sudo apt install smem

# Check for memory leaks
sudo cat /proc/PID/status | grep -i vm
```

#### Disk Monitoring

```bash
# Disk usage
df -h  # Human-readable disk usage
df -i  # Inode usage

# Directory sizes
du -sh /var/*
du -sh * | sort -rh | head -20  # Top 20 largest

# Disk I/O statistics
iostat -x 1 5  # Extended stats every 1 second

# Real-time disk activity
iotop
# Install: sudo apt install iotop

# Disk I/O by process
pidstat -d 1 5

# Detailed I/O stats
cat /proc/diskstats

# Historical disk I/O
sar -d 1 10

# Check disk health
sudo smartctl -a /dev/sda
# Install: sudo apt install smartmontools

# File system activity
sudo fatrace  # File access trace
# Install: sudo apt install fatrace

# Find large files
find / -type f -size +100M 2>/dev/null | head -20

# Monitor file system events
inotifywait -m -r /path/to/watch
# Install: sudo apt install inotify-tools
```

#### Network Monitoring

```bash
# Network interfaces
ip -s addr show  # Interface statistics
ifconfig -a      # Traditional command

# Real-time network traffic
iftop
# Install: sudo apt install iftop

# Network connections
ss -tulpn  # TCP/UDP listening ports
ss -tan    # All TCP connections
netstat -tulpn  # Alternative

# Network traffic by process
nethogs
# Install: sudo apt install nethogs

# Bandwidth usage
vnstat
# Install: sudo apt install vnstat
vnstat -l  # Live traffic
vnstat -h  # Hourly stats
vnstat -d  # Daily stats

# Network I/O statistics
sar -n DEV 1 5  # Network device stats
sar -n TCP 1 5  # TCP stats

# Packet monitoring
sudo tcpdump -i eth0 -n
sudo tcpdump -i any port 80

# Connection tracking
sudo conntrack -L
# Install: sudo apt install conntrack

# DNS queries monitoring
sudo tcpdump -i any port 53

# Network latency
mtr google.com  # Combines ping and traceroute
```

### Process Monitoring

```bash
# List all processes
ps aux
ps -ef

# Process tree
pstree
pstree -p  # Show PIDs

# Real-time process monitoring
top
htop

# Monitor specific process
pidstat -p PID 1  # All stats for PID
strace -p PID     # System calls
# Install: sudo apt install strace

# Process resource limits
cat /proc/PID/limits

# Open files by process
lsof -p PID
lsof -u username

# Process CPU affinity
taskset -cp PID

# Monitor process creation
sudo execsnoop  # BPF-based tool
# Install: sudo apt install bpfcc-tools

# Process accounting
sudo accton /var/log/account/pacct
lastcomm  # Show executed commands
sa        # Summarize accounting

# Monitor specific command
/usr/bin/time -v command  # Detailed resource usage
```

### Log Analysis

```bash
# System logs location
ls /var/log/

# View system log
journalctl
journalctl -xe  # Recent entries with explanation
journalctl -u nginx  # Specific service
journalctl --since "1 hour ago"
journalctl --since "2024-01-01" --until "2024-01-02"

# Traditional log files
tail -f /var/log/syslog
tail -f /var/log/auth.log
tail -f /var/log/kern.log

# Multiple logs simultaneously
multitail /var/log/nginx/access.log /var/log/nginx/error.log
# Install: sudo apt install multitail

# Log analysis tools
# Count occurrences
grep "error" /var/log/syslog | wc -l

# Top IP addresses in access log
awk '{print $1}' /var/log/nginx/access.log | sort | uniq -c | sort -rn | head -10

# Log parsing with awk
awk '/error/ {print $0}' /var/log/syslog

# GoAccess for web logs
goaccess /var/log/nginx/access.log
# Install: sudo apt install goaccess

# Log rotation status
sudo logrotate -d /etc/logrotate.conf  # Debug mode

# Centralized logging with rsyslog
sudo nano /etc/rsyslog.conf
# Forward to remote syslog server:
# *.* @@remote-server:514
```

#### Creating Log Analysis Script

```bash
sudo nano /usr/local/bin/analyze-logs.sh
```

```bash
#!/bin/bash
# Comprehensive log analysis script

LOG_DIR="/var/log"
REPORT_FILE="/tmp/log-analysis-$(date +%Y%m%d).txt"

analyze_auth_log() {
    echo "=== Authentication Analysis ===" >> "$REPORT_FILE"

    echo "Failed login attempts:" >> "$REPORT_FILE"
    grep "Failed password" $LOG_DIR/auth.log | \
        awk '{print $11}' | sort | uniq -c | sort -rn | head -10 >> "$REPORT_FILE"

    echo "Successful logins:" >> "$REPORT_FILE"
    grep "Accepted password" $LOG_DIR/auth.log | \
        awk '{print $11}' | sort | uniq -c | sort -rn >> "$REPORT_FILE"

    echo "SSH brute force attempts:" >> "$REPORT_FILE"
    grep "Failed password" $LOG_DIR/auth.log | \
        awk '{print $11}' | sort | uniq -c | \
        awk '$1 > 5 {print "WARNING: " $2 " had " $1 " failed attempts"}' >> "$REPORT_FILE"
}

analyze_system_errors() {
    echo "=== System Errors ===" >> "$REPORT_FILE"

    echo "Critical errors:" >> "$REPORT_FILE"
    grep -i "critical\|emergency\|alert" $LOG_DIR/syslog | tail -20 >> "$REPORT_FILE"

    echo "Out of memory events:" >> "$REPORT_FILE"
    grep -i "out of memory\|oom" $LOG_DIR/syslog | tail -10 >> "$REPORT_FILE"

    echo "Disk errors:" >> "$REPORT_FILE"
    grep -i "I/O error\|disk error" $LOG_DIR/syslog | tail -10 >> "$REPORT_FILE"
}

analyze_service_logs() {
    echo "=== Service Status ===" >> "$REPORT_FILE"

    for service in nginx mysql ssh; do
        echo "Service: $service" >> "$REPORT_FILE"
        journalctl -u $service --since "24 hours ago" | \
            grep -i "error\|failed\|critical" | tail -5 >> "$REPORT_FILE"
    done
}

# Main execution
echo "Log Analysis Report - $(date)" > "$REPORT_FILE"
analyze_auth_log
analyze_system_errors
analyze_service_logs

echo "Analysis complete. Report saved to: $REPORT_FILE"
cat "$REPORT_FILE"
```

### Performance Baselines

Establishing baselines helps identify abnormal behavior.

```bash
# Create baseline collection script
sudo nano /usr/local/bin/collect-baseline.sh
```

```bash
#!/bin/bash
# Collect system performance baseline

BASELINE_DIR="/var/lib/monitoring/baseline"
DATE=$(date +%Y%m%d-%H%M%S)

mkdir -p "$BASELINE_DIR"

# Collect CPU baseline
echo "Collecting CPU baseline..."
mpstat -P ALL 1 60 > "$BASELINE_DIR/cpu-$DATE.txt"

# Collect memory baseline
echo "Collecting memory baseline..."
vmstat 1 60 > "$BASELINE_DIR/memory-$DATE.txt"

# Collect disk I/O baseline
echo "Collecting disk I/O baseline..."
iostat -x 1 60 > "$BASELINE_DIR/disk-$DATE.txt"

# Collect network baseline
echo "Collecting network baseline..."
sar -n DEV 1 60 > "$BASELINE_DIR/network-$DATE.txt"

# Process snapshot
ps aux > "$BASELINE_DIR/processes-$DATE.txt"

# System configuration
sysctl -a > "$BASELINE_DIR/sysctl-$DATE.txt"

echo "Baseline collection complete"
```

#### Analyzing Performance Trends

```bash
sudo nano /usr/local/bin/analyze-trends.sh
```

```bash
#!/bin/bash
# Analyze performance trends

BASELINE_DIR="/var/lib/monitoring/baseline"
CURRENT_DIR="/tmp/current"

mkdir -p "$CURRENT_DIR"

# Collect current metrics
mpstat -P ALL 1 10 | awk '/Average/ {print $3,$12}' > "$CURRENT_DIR/cpu.txt"
free -m | awk '/Mem:/ {print $3/$2*100}' > "$CURRENT_DIR/memory.txt"
iostat -x 1 10 | awk '/avg/ {getline; print $14}' > "$CURRENT_DIR/iowait.txt"

# Compare with baseline
compare_metrics() {
    local metric=$1
    local threshold=$2

    baseline=$(cat "$BASELINE_DIR/$metric-baseline.txt" | awk '{sum+=$1} END {print sum/NR}')
    current=$(cat "$CURRENT_DIR/$metric.txt" | awk '{sum+=$1} END {print sum/NR}')

    variance=$(echo "scale=2; (($current - $baseline) / $baseline) * 100" | bc)

    if (( $(echo "$variance > $threshold" | bc -l) )); then
        echo "WARNING: $metric increased by ${variance}% from baseline"
    fi
}

# Check for deviations
compare_metrics "cpu" 20
compare_metrics "memory" 15
compare_metrics "iowait" 30
```

### Alerting Setup

Configure alerts for critical metrics.

```bash
# Create alerting script
sudo nano /usr/local/bin/system-alerts.sh
```

```bash
#!/bin/bash
# System alerting script

# Configuration
ALERT_EMAIL="admin@example.com"
SLACK_WEBHOOK="https://hooks.slack.com/services/YOUR/WEBHOOK/URL"

# Thresholds
CPU_THRESHOLD=80
MEM_THRESHOLD=90
DISK_THRESHOLD=85
LOAD_THRESHOLD=4

# Alert functions
send_email_alert() {
    local subject=$1
    local message=$2

    echo "$message" | mail -s "$subject - $(hostname)" "$ALERT_EMAIL"
}

send_slack_alert() {
    local message=$1

    curl -X POST -H 'Content-type: application/json' \
        --data "{\"text\":\"$(hostname): $message\"}" \
        "$SLACK_WEBHOOK"
}

# Check CPU usage
check_cpu() {
    cpu_usage=$(top -bn1 | grep "Cpu(s)" | awk '{print 100 - $8}' | cut -d'.' -f1)

    if [ "$cpu_usage" -gt "$CPU_THRESHOLD" ]; then
        message="CPU usage is ${cpu_usage}% (threshold: ${CPU_THRESHOLD}%)"
        send_email_alert "High CPU Alert" "$message"
        send_slack_alert "$message"
    fi
}

# Check memory usage
check_memory() {
    mem_usage=$(free | grep Mem | awk '{printf "%.0f", $3/$2 * 100}')

    if [ "$mem_usage" -gt "$MEM_THRESHOLD" ]; then
        message="Memory usage is ${mem_usage}% (threshold: ${MEM_THRESHOLD}%)"
        send_email_alert "High Memory Alert" "$message"

        # Include top memory consumers
        top_consumers=$(ps aux --sort=-%mem | head -5)
        send_email_alert "Memory Consumers" "$top_consumers"
    fi
}

# Check disk usage
check_disk() {
    while IFS= read -r line; do
        usage=$(echo "$line" | awk '{print $5}' | sed 's/%//')
        partition=$(echo "$line" | awk '{print $6}')

        if [ "$usage" -gt "$DISK_THRESHOLD" ]; then
            message="Disk usage on $partition is ${usage}% (threshold: ${DISK_THRESHOLD}%)"
            send_email_alert "High Disk Usage Alert" "$message"
        fi
    done < <(df -h | grep -E '^/dev/')
}

# Check load average
check_load() {
    cores=$(nproc)
    load_1min=$(uptime | awk -F'load average:' '{print $2}' | awk '{print $1}' | tr -d ',')

    if (( $(echo "$load_1min > $LOAD_THRESHOLD" | bc -l) )); then
        message="Load average is $load_1min (${cores} cores, threshold: ${LOAD_THRESHOLD})"
        send_email_alert "High Load Alert" "$message"
    fi
}

# Check service status
check_services() {
    services=("nginx" "mysql" "ssh")

    for service in "${services[@]}"; do
        if ! systemctl is-active --quiet "$service"; then
            message="Service $service is not running!"
            send_email_alert "Service Down Alert" "$message"

            # Attempt restart
            systemctl restart "$service"
            if systemctl is-active --quiet "$service"; then
                send_email_alert "Service Recovered" "$service has been restarted successfully"
            fi
        fi
    done
}

# Main execution
check_cpu
check_memory
check_disk
check_load
check_services
```

```bash
# Schedule alerts
sudo crontab -e
# Add: */5 * * * * /usr/local/bin/system-alerts.sh
```

### Prometheus Node Exporter

Prometheus is a powerful monitoring system with a time-series database.

#### Installing Node Exporter

```bash
# Download node_exporter
cd /tmp
wget https://github.com/prometheus/node_exporter/releases/download/v1.7.0/node_exporter-1.7.0.linux-amd64.tar.gz

# Extract and install
tar xzf node_exporter-1.7.0.linux-amd64.tar.gz
sudo cp node_exporter-1.7.0.linux-amd64/node_exporter /usr/local/bin/
sudo chmod +x /usr/local/bin/node_exporter

# Create service user
sudo useradd --no-create-home --shell /bin/false node_exporter

# Create systemd service
sudo nano /etc/systemd/system/node_exporter.service
```

```ini
[Unit]
Description=Node Exporter
Wants=network-online.target
After=network-online.target

[Service]
User=node_exporter
Group=node_exporter
Type=simple
ExecStart=/usr/local/bin/node_exporter \
    --collector.filesystem.mount-points-exclude=^/(dev|proc|sys|run)($|/) \
    --collector.filesystem.fs-types-exclude=^(autofs|binfmt_misc|bpf|cgroup2?|configfs|debugfs|devpts|devtmpfs|fusectl|hugetlbfs|iso9660|mqueue|nsfs|overlay|proc|procfs|pstore|rpc_pipefs|securityfs|selinuxfs|squashfs|sysfs|tracefs|tmpfs)$ \
    --collector.netclass.ignored-devices=^(veth|docker).*

Restart=always

[Install]
WantedBy=default.target
```

```bash
# Start node_exporter
sudo systemctl daemon-reload
sudo systemctl enable node_exporter
sudo systemctl start node_exporter

# Verify it's running
curl http://localhost:9100/metrics
```

#### Installing Prometheus

```bash
# Download Prometheus
cd /tmp
wget https://github.com/prometheus/prometheus/releases/download/v2.48.0/prometheus-2.48.0.linux-amd64.tar.gz

# Extract and install
tar xzf prometheus-2.48.0.linux-amd64.tar.gz
sudo cp prometheus-2.48.0.linux-amd64/{prometheus,promtool} /usr/local/bin/
sudo chmod +x /usr/local/bin/{prometheus,promtool}

# Create directories
sudo mkdir -p /etc/prometheus /var/lib/prometheus

# Copy configuration files
sudo cp -r prometheus-2.48.0.linux-amd64/{consoles,console_libraries} /etc/prometheus/

# Create Prometheus configuration
sudo nano /etc/prometheus/prometheus.yml
```

```yaml
global:
  scrape_interval: 15s
  evaluation_interval: 15s

alerting:
  alertmanagers:
    - static_configs:
        - targets: []

rule_files:
  - "/etc/prometheus/rules/*.yml"

scrape_configs:
  - job_name: 'node'
    static_configs:
      - targets: ['localhost:9100']

  - job_name: 'prometheus'
    static_configs:
      - targets: ['localhost:9090']
```

```bash
# Create Prometheus service
sudo nano /etc/systemd/system/prometheus.service
```

```ini
[Unit]
Description=Prometheus
Wants=network-online.target
After=network-online.target

[Service]
User=prometheus
Group=prometheus
Type=simple
ExecStart=/usr/local/bin/prometheus \
    --config.file=/etc/prometheus/prometheus.yml \
    --storage.tsdb.path=/var/lib/prometheus/ \
    --web.console.templates=/etc/prometheus/consoles \
    --web.console.libraries=/etc/prometheus/console_libraries

Restart=always

[Install]
WantedBy=multi-user.target
```

```bash
# Create user and set permissions
sudo useradd --no-create-home --shell /bin/false prometheus
sudo chown -R prometheus:prometheus /etc/prometheus /var/lib/prometheus

# Start Prometheus
sudo systemctl daemon-reload
sudo systemctl enable prometheus
sudo systemctl start prometheus

# Access Prometheus UI at http://your-server:9090
```

### Custom Metrics

Create custom metrics for application monitoring.

#### Custom Metric Exporter

```bash
sudo nano /usr/local/bin/custom_exporter.py
```

```python
#!/usr/bin/env python3
# Custom metrics exporter for Prometheus

from prometheus_client import start_http_server, Gauge, Counter, Histogram
import time
import psutil
import subprocess

# Define metrics
app_requests = Counter('app_requests_total', 'Total requests to application')
app_errors = Counter('app_errors_total', 'Total application errors')
response_time = Histogram('app_response_seconds', 'Response time in seconds')
active_users = Gauge('app_active_users', 'Number of active users')
database_connections = Gauge('database_connections', 'Number of database connections')
custom_metric = Gauge('custom_business_metric', 'Custom business metric')

def collect_metrics():
    """Collect custom metrics"""

    # System metrics
    cpu_percent = psutil.cpu_percent()
    memory = psutil.virtual_memory()
    disk = psutil.disk_usage('/')

    # Application metrics (example)
    try:
        # Count nginx connections
        result = subprocess.run(['ss', '-tan', 'state', 'established'],
                              capture_output=True, text=True)
        connections = len(result.stdout.splitlines()) - 1
        active_users.set(connections)

        # Database connections (example for MySQL)
        result = subprocess.run(['mysql', '-e', 'show processlist'],
                              capture_output=True, text=True)
        db_conn = len(result.stdout.splitlines()) - 1
        database_connections.set(db_conn)

    except Exception as e:
        print(f"Error collecting metrics: {e}")

if __name__ == '__main__':
    # Start metrics server
    start_http_server(9091)

    # Continuously collect metrics
    while True:
        collect_metrics()
        time.sleep(10)
```

```bash
# Make executable and create service
chmod +x /usr/local/bin/custom_exporter.py

# Install Python dependencies
pip3 install prometheus_client psutil

# Create service
sudo nano /etc/systemd/system/custom_exporter.service
```

```ini
[Unit]
Description=Custom Prometheus Exporter
After=network.target

[Service]
Type=simple
User=prometheus
ExecStart=/usr/local/bin/custom_exporter.py
Restart=always

[Install]
WantedBy=multi-user.target
```

---

## Chapter 17: Performance Optimization

### Kernel Parameters

Kernel parameters control system behavior at the lowest level.

#### Viewing and Setting Kernel Parameters

```bash
# View all kernel parameters
sysctl -a

# View specific parameter
sysctl net.ipv4.tcp_keepalive_time

# Set parameter temporarily
sudo sysctl -w net.ipv4.tcp_keepalive_time=600

# Set permanently
sudo nano /etc/sysctl.conf
# or better, create a specific file:
sudo nano /etc/sysctl.d/99-performance.conf
```

#### Network Performance Tuning

```bash
sudo nano /etc/sysctl.d/99-network-performance.conf
```

```bash
# Network Performance Tuning

# Increase TCP buffer sizes
net.core.rmem_max = 134217728
net.core.wmem_max = 134217728
net.ipv4.tcp_rmem = 4096 87380 134217728
net.ipv4.tcp_wmem = 4096 65536 134217728

# Increase netdev budget for packet processing
net.core.netdev_budget = 600
net.core.netdev_max_backlog = 5000

# Enable TCP fast open
net.ipv4.tcp_fastopen = 3

# Optimize TCP keepalive
net.ipv4.tcp_keepalive_time = 600
net.ipv4.tcp_keepalive_intvl = 60
net.ipv4.tcp_keepalive_probes = 10

# Increase connection tracking
net.netfilter.nf_conntrack_max = 524288
net.nf_conntrack_max = 524288

# Enable TCP BBR congestion control
net.core.default_qdisc = fq
net.ipv4.tcp_congestion_control = bbr

# Reuse TIME_WAIT sockets
net.ipv4.tcp_tw_reuse = 1

# Increase port range
net.ipv4.ip_local_port_range = 1024 65535

# Increase syn backlog
net.ipv4.tcp_max_syn_backlog = 8192
net.core.somaxconn = 8192

# Enable SYN cookies
net.ipv4.tcp_syncookies = 1

# Disable source routing
net.ipv4.conf.all.accept_source_route = 0
net.ipv6.conf.all.accept_source_route = 0
```

```bash
# Apply settings
sudo sysctl -p /etc/sysctl.d/99-network-performance.conf
```

### Memory Management

#### Memory Tuning Parameters

```bash
sudo nano /etc/sysctl.d/99-memory-performance.conf
```

```bash
# Memory Performance Tuning

# Swappiness (0-100, lower = less swap usage)
vm.swappiness = 10

# Cache pressure (default 100)
vm.vfs_cache_pressure = 50

# Dirty page handling
vm.dirty_ratio = 15
vm.dirty_background_ratio = 5
vm.dirty_expire_centisecs = 3000
vm.dirty_writeback_centisecs = 500

# Shared memory
kernel.shmmax = 68719476736
kernel.shmall = 4294967296
kernel.shmmni = 4096

# Huge pages (for databases)
vm.nr_hugepages = 512

# Memory overcommit
vm.overcommit_memory = 1
vm.overcommit_ratio = 50

# OOM killer behavior
vm.panic_on_oom = 0
vm.oom_kill_allocating_task = 0

# Minimum free memory
vm.min_free_kbytes = 65536

# NUMA balancing (for multi-socket systems)
kernel.numa_balancing = 1
```

#### Analyzing Memory Usage

```bash
# Create memory analysis script
sudo nano /usr/local/bin/analyze-memory.sh
```

```bash
#!/bin/bash
# Memory usage analysis

echo "=== Memory Analysis Report ==="
echo "Date: $(date)"
echo

# Overall memory status
echo "Memory Overview:"
free -h
echo

# Top memory consumers
echo "Top 10 Memory Consumers:"
ps aux --sort=-%mem | head -11
echo

# Memory by type
echo "Memory Types:"
sudo smem -tw
echo

# Slab cache analysis
echo "Top Slab Consumers:"
sudo slabtop -o -s c | head -20
echo

# Huge pages status
echo "Huge Pages Status:"
grep Huge /proc/meminfo
echo

# Memory zones
echo "Memory Zones:"
cat /proc/zoneinfo | grep -E "Node|zone|pages free|min|low|high"
echo

# Memory pressure
echo "Memory Pressure:"
cat /proc/pressure/memory
```

### I/O Optimization

#### Disk I/O Tuning

```bash
# Check current I/O scheduler
cat /sys/block/sda/queue/scheduler

# Change I/O scheduler (choose based on workload)
# noop - No operation, good for SSDs
# deadline - Good for databases
# cfq - Good for general purpose
# mq-deadline - Multi-queue deadline for NVMe
echo mq-deadline | sudo tee /sys/block/nvme0n1/queue/scheduler

# Make permanent
sudo nano /etc/default/grub
# Add to GRUB_CMDLINE_LINUX: elevator=mq-deadline

# Update grub
sudo update-grub

# Tune read-ahead
sudo blockdev --setra 4096 /dev/sda  # Set read-ahead to 2MB

# Check and set queue depth
cat /sys/block/sda/queue/nr_requests
echo 512 | sudo tee /sys/block/sda/queue/nr_requests
```

#### Filesystem Optimization

```bash
# Mount options for better performance
sudo nano /etc/fstab
```

```bash
# Example optimized mount options
UUID=xxx / ext4 defaults,noatime,nodiratime,commit=60,errors=remount-ro 0 1
UUID=yyy /data xfs defaults,noatime,nodiratime,nobarrier,logbufs=8,logbsize=256k 0 2

# For SSDs add:
# discard - Enable TRIM
# noatime - Don't update access times
# nodiratime - Don't update directory access times
```

```bash
# Optimize ext4 filesystem
sudo tune2fs -o journal_data_writeback /dev/sda1
sudo tune2fs -O ^has_journal /dev/sda1  # Disable journal (risky!)

# XFS optimization
sudo xfs_admin -L mylabel /dev/sdb1
mount -o noatime,nodiratime,nobarrier,logbufs=8 /dev/sdb1 /mnt/data
```

### Network Tuning

#### Interface Tuning

```bash
# Check current settings
ethtool eth0

# Increase ring buffer
sudo ethtool -G eth0 rx 4096 tx 4096

# Enable offloading features
sudo ethtool -K eth0 gso on
sudo ethtool -K eth0 gro on
sudo ethtool -K eth0 tso on

# Set interrupt coalescing
sudo ethtool -C eth0 rx-usecs 100

# CPU affinity for network interrupts
# Find network interrupts
grep eth0 /proc/interrupts

# Set CPU affinity
echo 2 | sudo tee /proc/irq/24/smp_affinity_list
```

#### TCP Optimization Script

```bash
sudo nano /usr/local/bin/optimize-tcp.sh
```

```bash
#!/bin/bash
# TCP optimization script

# Enable BBR congestion control
modprobe tcp_bbr
echo "tcp_bbr" | tee /etc/modules-load.d/tcp_bbr.conf
echo "net.core.default_qdisc=fq" | tee -a /etc/sysctl.conf
echo "net.ipv4.tcp_congestion_control=bbr" | tee -a /etc/sysctl.conf

# Optimize for high-throughput
cat << EOF | sudo tee /etc/sysctl.d/99-tcp-optimization.conf
# TCP Optimization for High Throughput

# Buffer sizes
net.core.rmem_max = 134217728
net.core.wmem_max = 134217728
net.core.rmem_default = 262144
net.core.wmem_default = 262144
net.ipv4.tcp_rmem = 4096 262144 134217728
net.ipv4.tcp_wmem = 4096 262144 134217728

# Connection handling
net.ipv4.tcp_max_syn_backlog = 8192
net.core.somaxconn = 8192
net.ipv4.tcp_tw_reuse = 1
net.ipv4.tcp_fin_timeout = 15

# Performance features
net.ipv4.tcp_fastopen = 3
net.ipv4.tcp_mtu_probing = 1
net.ipv4.tcp_timestamps = 1
net.ipv4.tcp_sack = 1
net.ipv4.tcp_window_scaling = 1

# Congestion control
net.ipv4.tcp_congestion_control = bbr
net.core.default_qdisc = fq
EOF

# Apply settings
sysctl -p /etc/sysctl.d/99-tcp-optimization.conf

echo "TCP optimization complete"
```

### Application Performance

#### Application Profiling

```bash
# CPU profiling with perf
sudo apt install linux-tools-common linux-tools-generic

# Record CPU profile
sudo perf record -g -p PID sleep 30
sudo perf report

# Flame graphs
git clone https://github.com/brendangregg/FlameGraph
sudo perf record -F 99 -ag -- sleep 30
sudo perf script | ./FlameGraph/stackcollapse-perf.pl | ./FlameGraph/flamegraph.pl > perf.svg

# Memory profiling with valgrind
sudo apt install valgrind

# Check for memory leaks
valgrind --leak-check=full --show-leak-kinds=all ./application

# Profile memory usage
valgrind --tool=massif ./application
ms_print massif.out.*
```

#### Application Tuning Examples

```bash
# Nginx optimization
sudo nano /etc/nginx/nginx.conf
```

```nginx
user www-data;
worker_processes auto;
worker_rlimit_nofile 65535;

events {
    worker_connections 4096;
    use epoll;
    multi_accept on;
}

http {
    # Basic settings
    sendfile on;
    tcp_nopush on;
    tcp_nodelay on;
    keepalive_timeout 65;
    keepalive_requests 100;

    # Buffer settings
    client_body_buffer_size 128k;
    client_max_body_size 10m;
    client_header_buffer_size 1k;
    large_client_header_buffers 4 8k;
    output_buffers 32 32k;
    postpone_output 1460;

    # Caching
    open_file_cache max=1000 inactive=20s;
    open_file_cache_valid 30s;
    open_file_cache_min_uses 2;
    open_file_cache_errors on;

    # Gzip
    gzip on;
    gzip_vary on;
    gzip_proxied any;
    gzip_comp_level 6;
    gzip_types text/plain text/css text/xml text/javascript application/json application/javascript application/xml+rss application/rss+xml application/atom+xml image/svg+xml text/x-js text/x-cross-domain-policy application/x-font-ttf application/x-font-opentype application/vnd.ms-fontobject image/x-icon;
}
```

```bash
# MySQL optimization
sudo nano /etc/mysql/mysql.conf.d/optimization.cnf
```

```ini
[mysqld]
# InnoDB settings
innodb_buffer_pool_size = 1G
innodb_log_file_size = 256M
innodb_flush_log_at_trx_commit = 2
innodb_flush_method = O_DIRECT
innodb_file_per_table = 1
innodb_io_capacity = 2000
innodb_io_capacity_max = 3000

# Query cache (MySQL 5.7 and earlier)
query_cache_type = 1
query_cache_size = 128M
query_cache_limit = 2M

# Connection settings
max_connections = 500
max_connect_errors = 1000000
wait_timeout = 28800
interactive_timeout = 28800

# Buffer settings
key_buffer_size = 256M
sort_buffer_size = 2M
read_buffer_size = 2M
read_rnd_buffer_size = 8M
join_buffer_size = 8M

# Temp tables
tmp_table_size = 64M
max_heap_table_size = 64M

# Logging
slow_query_log = 1
slow_query_log_file = /var/log/mysql/slow-query.log
long_query_time = 2
```

### Troubleshooting Performance Issues

#### Performance Troubleshooting Checklist

```bash
# Create troubleshooting script
sudo nano /usr/local/bin/performance-check.sh
```

```bash
#!/bin/bash
# Comprehensive performance troubleshooting

echo "=== Performance Troubleshooting Report ==="
echo "Timestamp: $(date)"
echo "Hostname: $(hostname)"
echo

# CPU Analysis
echo "1. CPU Analysis:"
echo "   Load Average: $(uptime | awk -F'load average:' '{print $2}')"
echo "   CPU Count: $(nproc)"
mpstat 1 3 | tail -2
echo

# Memory Analysis
echo "2. Memory Analysis:"
free -h
echo "   Top Memory Consumers:"
ps aux --sort=-%mem | head -5 | awk '{print "   "$11" - "$4"%"}'
echo

# Disk I/O Analysis
echo "3. Disk I/O Analysis:"
iostat -x 1 3 | grep -A1 avg-cpu | tail -2
echo "   High I/O Wait Processes:"
iotop -b -n 1 | head -10 | tail -5
echo

# Network Analysis
echo "4. Network Analysis:"
echo "   Active Connections: $(ss -tan | wc -l)"
echo "   Listen Ports: $(ss -tln | wc -l)"
echo "   Network Traffic:"
sar -n DEV 1 3 | grep -E "Average.*eth0|Average.*ens"
echo

# Process Analysis
echo "5. Process Analysis:"
echo "   Total Processes: $(ps aux | wc -l)"
echo "   Zombie Processes: $(ps aux | grep -c " Z ")"
echo "   Top CPU Consumers:"
ps aux --sort=-%cpu | head -5 | awk '{print "   "$11" - "$3"%"}'
echo

# System Calls
echo "6. System Call Analysis (top 5):"
timeout 5 strace -c -p 1 2>&1 | grep -A5 "% time"
echo

# Kernel Messages
echo "7. Recent Kernel Messages:"
dmesg -T | tail -10
echo

# Service Status
echo "8. Critical Service Status:"
for service in nginx mysql redis ssh; do
    status=$(systemctl is-active $service 2>/dev/null)
    echo "   $service: $status"
done
```

### Capacity Planning

Plan for future resource needs based on current trends.

#### Capacity Planning Script

```bash
sudo nano /usr/local/bin/capacity-planning.sh
```

```bash
#!/bin/bash
# Capacity planning analysis

DAYS_TO_ANALYZE=30
DATA_DIR="/var/lib/monitoring/metrics"

# Collect historical data
collect_data() {
    echo "Collecting historical data for $DAYS_TO_ANALYZE days..."

    # Use sar data if available
    for i in $(seq 1 $DAYS_TO_ANALYZE); do
        date=$(date -d "$i days ago" +%Y%m%d)

        # CPU utilization
        sar -u -f /var/log/sysstat/sa$date 2>/dev/null | \
            awk '/Average/ {print 100-$8}' >> $DATA_DIR/cpu_history.txt

        # Memory usage
        sar -r -f /var/log/sysstat/sa$date 2>/dev/null | \
            awk '/Average/ {print $4}' >> $DATA_DIR/mem_history.txt

        # Disk usage
        df / | awk 'NR==2 {print $5}' | sed 's/%//' >> $DATA_DIR/disk_history.txt
    done
}

# Calculate growth rate
calculate_growth() {
    local file=$1
    local metric=$2

    if [ ! -f "$file" ]; then
        echo "No data available for $metric"
        return
    fi

    # Calculate average daily growth
    first=$(head -1 "$file")
    last=$(tail -1 "$file")
    days=$(wc -l < "$file")

    growth=$(echo "scale=2; ($last - $first) / $days" | bc)

    echo "$metric daily growth: ${growth}%"

    # Project future usage
    current=$last
    for period in 30 60 90 180 365; do
        projected=$(echo "scale=2; $current + ($growth * $period)" | bc)
        echo "  Projected in $period days: ${projected}%"

        if (( $(echo "$projected > 80" | bc -l) )); then
            echo "  WARNING: Will exceed 80% threshold!"
        fi
    done
}

# Generate recommendations
generate_recommendations() {
    echo
    echo "=== Capacity Planning Recommendations ==="

    # CPU recommendations
    cpu_current=$(mpstat 1 3 | awk '/Average/ {print 100-$12}')
    echo "CPU: Current usage ${cpu_current}%"
    if (( $(echo "$cpu_current > 70" | bc -l) )); then
        echo "  - Consider upgrading CPU or optimizing applications"
        echo "  - Review process CPU usage patterns"
    fi

    # Memory recommendations
    mem_current=$(free | awk '/Mem:/ {printf "%.1f", $3/$2 * 100}')
    echo "Memory: Current usage ${mem_current}%"
    if (( $(echo "$mem_current > 80" | bc -l) )); then
        echo "  - Consider adding more RAM"
        echo "  - Review memory-intensive processes"
        echo "  - Optimize application memory usage"
    fi

    # Disk recommendations
    disk_current=$(df / | awk 'NR==2 {print $5}' | sed 's/%//')
    echo "Disk: Current usage ${disk_current}%"
    if [ "$disk_current" -gt 70 ]; then
        echo "  - Plan for storage expansion"
        echo "  - Implement log rotation and cleanup"
        echo "  - Archive old data"
    fi
}

# Main execution
mkdir -p "$DATA_DIR"
collect_data
echo
echo "=== Growth Analysis ==="
calculate_growth "$DATA_DIR/cpu_history.txt" "CPU"
calculate_growth "$DATA_DIR/mem_history.txt" "Memory"
calculate_growth "$DATA_DIR/disk_history.txt" "Disk"
generate_recommendations
```

---

## Practice Exercises

### Exercise 1: Monitoring Setup
1. Install and configure Prometheus with node_exporter
2. Create custom metrics for your application
3. Set up alerting rules for critical thresholds
4. Create a dashboard to visualize metrics
5. Document your monitoring architecture

### Exercise 2: Performance Baseline
1. Create scripts to collect performance baselines
2. Run baseline collection during different workloads
3. Analyze variations and identify patterns
4. Set up automated drift detection
5. Create performance reports

### Exercise 3: System Optimization
1. Tune kernel parameters for your workload
2. Optimize network settings for throughput
3. Configure memory management for your applications
4. Implement I/O optimization strategies
5. Measure performance improvements

### Exercise 4: Troubleshooting Practice
1. Create a performance issue (high CPU, memory leak, etc.)
2. Use monitoring tools to identify the problem
3. Apply appropriate fixes
4. Verify the resolution
5. Document the troubleshooting process

---

## Quick Reference

### Monitoring Commands
```bash
# CPU
top, htop, mpstat, sar -u
ps aux --sort=-%cpu

# Memory
free -h, vmstat, sar -r
ps aux --sort=-%mem

# Disk
df -h, du -sh, iostat -x
iotop, sar -d

# Network
netstat -tulpn, ss -tulpn
iftop, nethogs, vnstat
sar -n DEV

# Processes
ps aux, pstree, pidstat
strace -p PID, lsof -p PID

# Logs
journalctl -xe, tail -f /var/log/syslog
grep ERROR /var/log/*.log
```

### Performance Tools
```bash
# Profiling
perf record/report
valgrind --leak-check=full
strace -c command

# Analysis
vmstat 1
iostat -x 1
sar -A
dstat -cdnm

# Benchmarking
sysbench
iperf3
fio
ab (Apache Bench)
```

### Optimization Parameters
```bash
# Network
net.core.rmem_max
net.core.wmem_max
net.ipv4.tcp_congestion_control

# Memory
vm.swappiness
vm.dirty_ratio
vm.overcommit_memory

# I/O
/sys/block/*/queue/scheduler
/sys/block/*/queue/nr_requests
blockdev --setra

# Application
worker_processes (nginx)
innodb_buffer_pool_size (MySQL)
maxmemory (Redis)
```

---

## Additional Resources

### Documentation
- [Linux Performance](http://www.brendangregg.com/linuxperf.html)
- [Prometheus Documentation](https://prometheus.io/docs/)
- [Kernel Documentation](https://www.kernel.org/doc/html/latest/)
- [Systems Performance Book](http://www.brendangregg.com/systems-performance.html)

### Tools
- [Grafana](https://grafana.com/) - Visualization platform
- [Netdata](https://www.netdata.cloud/) - Real-time monitoring
- [Glances](https://nicolargo.github.io/glances/) - Cross-platform monitoring
- [BPF Tools](https://github.com/iovisor/bcc) - Advanced tracing

### Performance Resources
- [USE Method](http://www.brendangregg.com/usemethod.html)
- [Linux Performance Tuning](https://www.kernel.org/doc/html/latest/admin-guide/kernel-parameters.html)
- [TCP Tuning Guide](https://www.psc.edu/research/networking/tcptune/)

### Next Steps
After completing this section, you should:
- Understand comprehensive system monitoring
- Be able to identify performance bottlenecks
- Know how to optimize system performance
- Have tools for capacity planning

Continue to Part 8: Backup and Recovery to learn about data protection and disaster recovery strategies.