# Part 7: Monitoring and Performance

## Chapter 16: System Monitoring

### Understanding System Monitoring

#### The Monitoring Stack

Think of monitoring your Rocky Linux server like monitoring your car:
- **CPU** = Engine (how hard it's working)
- **Memory** = Fuel tank (how much is available)
- **Disk I/O** = Tires (how fast you're moving data)
- **Network** = Radio (communication with outside)
- **Processes** = Passengers (who's using resources)
- **Logs** = Dashboard warnings (what's happening)

Good monitoring helps you spot problems before they become disasters!

```bash
# Quick health check - the 5-minute physical
uptime
# 10:15:32 up 45 days, 23:14,  3 users,  load average: 0.52, 0.58, 0.59
# Shows: current time, uptime, users, and load averages (1min, 5min, 15min)

free -h
# Shows memory usage in human-readable format

df -h
# Shows disk usage for all filesystems

# One command to rule them all:
top
# Press 'q' to quit
# This shows everything: CPU, memory, processes, etc.
```

### Performance Co-Pilot (PCP) Basics

#### Setting Up PCP

Performance Co-Pilot is Rocky Linux's advanced monitoring framework - like having a flight recorder for your server.

```bash
# Install PCP
sudo dnf install -y pcp pcp-system-tools

# Start PCP services
sudo systemctl enable --now pmcd
sudo systemctl enable --now pmlogger

# Check PCP is running
pcp
# Performance Co-Pilot configuration on rocky-server:
#  platform: Linux rocky-server 4.18.0-513.9.1.el8_9.x86_64
#  hardware: 4 cpus, 2 disks, 1 node, 4096MB RAM
#  timezone: EST+5
#      pmcd: Version 5.3.7-17, 12 agents, 6 clients
#  pmlogger: primary logger: /var/log/pcp/pmlogger/rocky-server/20231213.10.15

# Quick performance summary
pcp summary
# Metric                          Value
# kernel.all.cpu.user            0.3%
# kernel.all.cpu.sys              0.2%
# kernel.all.cpu.idle             99.5%
# mem.util.used                   1.2 GB
# mem.util.free                   2.8 GB
# disk.all.read                   0 KB/s
# disk.all.write                  15 KB/s
# network.interface.in.bytes      1.2 KB/s
# network.interface.out.bytes     0.8 KB/s

# Live system metrics
pmstat
# @ Mon Dec 13 10:20:00 2023
#   loadavg                      memory      swap        io    system         cpu
#   1 min   swpd   free   buff  cache   pi   po   bi   bo   in   cs  us  sy  id
#    0.52   0      2.8g   150m  1.2g    0    0    0    15   120  210  1   1   98

# Historical data analysis
pmstat -a /var/log/pcp/pmlogger/$(hostname)/$(date +%Y%m%d)
# Replay metrics from earlier today
```

#### Using PCP Tools

```bash
# CPU monitoring
pmstat -x
# Shows extended CPU metrics including interrupts and context switches

# Memory monitoring
pminfo -f mem.util
# mem.util.used
#     value 1234567890
# mem.util.free
#     value 2345678901
# mem.util.available
#     value 3456789012

# Disk I/O monitoring
pmiostat
# Device       rrqm/s   wrqm/s     r/s     w/s    rkB/s    wkB/s avgrq-sz avgqu-sz   await r_await w_await  %util
# sda            0.00     0.23    0.01    0.18     0.18     5.42    60.91     0.00    2.37    1.23    2.44   0.01

# Network monitoring
pmrep network.interface.in.bytes network.interface.out.bytes
#               n.i.i.bytes  n.i.o.bytes
#                     eth0         eth0
# 10:25:00           1234         5678
# 10:25:01           2345         6789
# 10:25:02           3456         7890

# Process monitoring
pmrep -i proc.nprocs proc.runq.runnable proc.memory.rss
#           p.nprocs  p.r.runnable  p.m.rss
# 10:30:00       245             2   2.1g
# 10:30:01       245             1   2.1g
# 10:30:02       246             3   2.1g

# Custom monitoring script using PCP
cat > /usr/local/bin/pcp-monitor.sh << 'EOF'
#!/bin/bash
echo "System Performance Report - $(date)"
echo "================================"
echo ""
echo "CPU Usage:"
pmval -s 1 kernel.all.cpu.util.all | tail -1
echo ""
echo "Memory Usage:"
pminfo -f mem.util.used mem.util.available | grep value
echo ""
echo "Top 5 CPU Processes:"
pmrep -s 1 -i 5 proc.psinfo.cmd proc.psinfo.cpu.util
echo ""
echo "Disk I/O:"
pmiostat 1 1
EOF

chmod +x /usr/local/bin/pcp-monitor.sh
```

### Resource Monitoring Tools

#### Essential Monitoring Commands

```bash
# TOP - Real-time process viewer
top
# Key commands in top:
# h - help
# 1 - show individual CPU cores
# M - sort by memory usage
# P - sort by CPU usage
# c - show full command path
# k - kill a process
# r - renice a process
# z - toggle colors
# b - bold highlighting
# W - save configuration

# HTOP - Better than top (if installed)
sudo dnf install -y htop
htop
# F1 - Help
# F2 - Setup
# F3 - Search
# F4 - Filter
# F5 - Tree view
# F6 - Sort by
# F9 - Kill process
# F10 - Quit

# VMSTAT - Virtual memory statistics
vmstat 2 5  # Every 2 seconds, 5 times
# procs -----------memory---------- ---swap-- -----io---- -system-- ------cpu-----
#  r  b   swpd   free   buff  cache   si   so    bi    bo   in   cs us sy id wa st
#  1  0      0 2913092 150456 1287656    0    0     0    15  120  210  1  1 98  0  0
#  0  0      0 2913092 150456 1287656    0    0     0     0  115  198  0  1 99  0  0

# Understanding vmstat:
# r = runnable processes (waiting for CPU)
# b = blocked processes (waiting for I/O)
# swpd = swap used
# free = free memory
# buff = buffer memory
# cache = cache memory
# si/so = swap in/out
# bi/bo = blocks in/out (disk I/O)
# in = interrupts per second
# cs = context switches per second
# us = user CPU time
# sy = system CPU time
# id = idle time
# wa = I/O wait time
# st = stolen time (virtualization)

# IOSTAT - I/O statistics
iostat -x 2
# Linux 4.18.0-513.9.1.el8_9.x86_64 (rocky-server) 	12/13/2023 	_x86_64_	(4 CPU)

# avg-cpu:  %user   %nice %system %iowait  %steal   %idle
#            1.23    0.00    0.45    0.12    0.00   98.20

# Device            r/s     w/s     rkB/s     wkB/s   rrqm/s   wrqm/s  %util
# sda              0.15    2.30      6.12    45.60     0.01     0.23   0.45
# sdb              0.00    0.00      0.00     0.00     0.00     0.00   0.00

# MPSTAT - Processor statistics
mpstat -P ALL 2 3  # All CPUs, every 2 seconds, 3 times
# CPU    %usr   %nice    %sys %iowait    %irq   %soft  %steal  %guest  %gnice   %idle
# all    1.25    0.00    0.50    0.12    0.00    0.00    0.00    0.00    0.00   98.13
#   0    2.00    0.00    1.00    0.00    0.00    0.00    0.00    0.00    0.00   97.00
#   1    0.50    0.00    0.50    0.50    0.00    0.00    0.00    0.00    0.00   98.50
#   2    1.50    0.00    0.00    0.00    0.00    0.00    0.00    0.00    0.00   98.50
#   3    1.00    0.00    0.50    0.00    0.00    0.00    0.00    0.00    0.00   98.50
```

#### Memory Monitoring

```bash
# FREE - Memory usage
free -h
#               total        used        free      shared  buff/cache   available
# Mem:          3.8Gi       1.2Gi       1.3Gi        25Mi       1.4Gi       2.4Gi
# Swap:         2.0Gi          0B       2.0Gi

# Continuous monitoring
watch -n 1 free -h
# Updates every second, Ctrl+C to exit

# Detailed memory info
cat /proc/meminfo
# MemTotal:        4045892 kB
# MemFree:         1365432 kB
# MemAvailable:    2523456 kB
# Buffers:          154332 kB
# Cached:          1234568 kB
# SwapCached:            0 kB
# Active:          1567892 kB
# Inactive:         876544 kB
# ...

# Memory usage by process
ps aux --sort=-%mem | head
# USER       PID %CPU %MEM    VSZ   RSS TTY      STAT START   TIME COMMAND
# mysql     2345 0.5 15.2 1843212 623456 ?      Ssl  Dec01  45:23 /usr/sbin/mysqld
# httpd     3456 0.2  5.3  543212 213456 ?      S    09:00   1:23 /usr/sbin/httpd
# ...

# Slab memory (kernel caches)
sudo slabtop
# Active / Total Objects (% used)    : 123456 / 234567 (52.6%)
# Active / Total Slabs (% used)      : 12345 / 12345 (100.0%)
# Active / Total Caches (% used)     : 123 / 187 (65.8%)
# Active / Total Size (% used)       : 123456.00K / 234567.00K (52.6%)

# SMEM - Better memory reporting (install first)
sudo dnf install -y python3-matplotlib python3-pip
sudo pip3 install smem

smem -rs USS
# PID User     Command                         Swap      USS      PSS      RSS
# 2345 mysql    /usr/sbin/mysqld                   0   589.3M   591.2M   623.4M
# 3456 httpd    /usr/sbin/httpd                    0   201.2M   205.3M   213.4M
```

#### Network Monitoring

```bash
# NETSTAT replacement - SS (Socket Statistics)
ss -tulpn
# Netid  State   Recv-Q  Send-Q   Local Address:Port   Peer Address:Port  Process
# tcp    LISTEN  0       128            0.0.0.0:22          0.0.0.0:*      users:(("sshd",pid=1234))
# tcp    LISTEN  0       128               [::]:22             [::]:*      users:(("sshd",pid=1234))
# tcp    LISTEN  0       128            0.0.0.0:80          0.0.0.0:*      users:(("httpd",pid=2345))

# Network connections by state
ss -s
# Total: 186
# TCP:   12 (estab 3, closed 2, orphaned 0, timewait 1)

# IFTOP - Real-time bandwidth usage (install first)
sudo dnf install -y iftop
sudo iftop -i eth0
# Shows bandwidth usage per connection in real-time
# Press 'q' to quit

# NETHOGS - Bandwidth by process
sudo dnf install -y nethogs
sudo nethogs eth0
# Shows which processes are using bandwidth

# NLOAD - Simple bandwidth monitor
sudo dnf install -y nload
nload eth0
# Visual graph of incoming/outgoing traffic

# IP command for interface statistics
ip -s link show eth0
# 2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel state UP
#     link/ether 52:54:00:12:34:56 brd ff:ff:ff:ff:ff:ff
#     RX: bytes  packets  errors  dropped overrun mcast
#     123456789  234567   0       0       0       0
#     TX: bytes  packets  errors  dropped carrier collsns
#     987654321  876543   0       0       0       0

# Monitor network errors
watch -n 1 'ip -s link show eth0 | grep -A1 "RX:\|TX:"'
```

### Process Monitoring

#### Advanced Process Analysis

```bash
# PS - Process snapshot
ps aux
# USER       PID %CPU %MEM    VSZ   RSS TTY      STAT START   TIME COMMAND
# root         1  0.0  0.2 193856  8936 ?        Ss   Nov27   2:15 /usr/lib/systemd/systemd

# Process tree
ps auxf  # Forest view
pstree -p  # Tree with PIDs
pstree -u  # Tree with users

# Find specific processes
pgrep -l nginx
# 2345 nginx
# 2346 nginx

# Process details
ps -fp 2345
# UID        PID  PPID  C STIME TTY          TIME CMD
# nginx     2345     1  0 10:00 ?        00:00:01 nginx: worker process

# PIDSTAT - Process statistics over time
pidstat 2 5  # Every 2 seconds, 5 times
# Linux 4.18.0 (rocky-server)  12/13/2023  _x86_64_  (4 CPU)

# 10:45:00      UID       PID    %usr %system  %guest   %wait    %CPU   CPU  Command
# 10:45:02     1000      2345    0.50    0.00    0.00    0.00    0.50     1  nginx
# 10:45:02        0      3456    1.00    0.50    0.00    0.00    1.50     2  httpd

# Monitor specific process
pidstat -p 2345 2
# Shows CPU, memory, I/O for PID 2345 every 2 seconds

# STRACE - Trace system calls
sudo strace -p 2345
# Attach to process 2345 and show system calls
# Ctrl+C to stop

# Count system calls
sudo strace -c -p 2345
# Let it run, then Ctrl+C
# % time     seconds  usecs/call     calls    errors syscall
# ------ ----------- ----------- --------- --------- ----------------
#  23.45    0.001234         123        10           epoll_wait
#  15.67    0.000823          82        10           read
# ...

# LSOF - List open files
sudo lsof -p 2345
# COMMAND  PID  USER   FD   TYPE DEVICE SIZE/OFF   NODE NAME
# nginx   2345 nginx  cwd    DIR    8,1     4096      2 /
# nginx   2345 nginx  rtd    DIR    8,1     4096      2 /
# nginx   2345 nginx  txt    REG    8,1  1234567 123456 /usr/sbin/nginx

# Files opened by user
sudo lsof -u nginx

# Network connections by process
sudo lsof -i -P -n
# COMMAND   PID USER   FD   TYPE DEVICE SIZE/OFF NODE NAME
# sshd     1234 root    3u  IPv4  12345      0t0  TCP *:22 (LISTEN)
# httpd    2345 root    4u  IPv4  23456      0t0  TCP *:80 (LISTEN)
```

### System Activity Reporter (SAR)

#### Comprehensive System Monitoring with SAR

```bash
# Install sysstat (includes sar)
sudo dnf install -y sysstat

# Enable and start sysstat
sudo systemctl enable --now sysstat

# SAR collects data every 10 minutes by default
cat /etc/cron.d/sysstat
# */10 * * * * root /usr/lib64/sa/sa1 1 1

# View today's CPU usage
sar
# Linux 4.18.0-513.9.1.el8_9.x86_64 (rocky-server) 	12/13/2023 	_x86_64_	(4 CPU)

# 12:00:01 AM     CPU     %user     %nice   %system   %iowait    %steal     %idle
# 12:10:01 AM     all      1.23      0.00      0.45      0.12      0.00     98.20
# 12:20:01 AM     all      1.45      0.00      0.52      0.15      0.00     97.88
# ...

# Memory usage history
sar -r
# 12:00:01 AM kbmemfree kbmemused  %memused kbbuffers  kbcached  kbcommit   %commit
# 12:10:01 AM   1365432   2680460     66.24    154332   1234568   3456789     85.43

# Disk I/O history
sar -d
# 12:00:01 AM       DEV       tps     rkB/s     wkB/s   areq-sz    aqu-sz     await     svctm     %util
# 12:10:01 AM  dev8-0      2.45      6.12     45.60     21.12      0.01      4.08      0.41      0.10

# Network statistics
sar -n DEV
# 12:00:01 AM     IFACE   rxpck/s   txpck/s    rxkB/s    txkB/s   rxcmp/s   txcmp/s  rxmcst/s   %ifutil
# 12:10:01 AM      eth0      5.23      3.45      1.23      0.89      0.00      0.00      0.00      0.01

# Load average history
sar -q
# 12:00:01 AM   runq-sz  plist-sz   ldavg-1   ldavg-5  ldavg-15   blocked
# 12:10:01 AM         1       245      0.52      0.58      0.59         0

# View historical data (yesterday)
sar -f /var/log/sa/sa$(date -d yesterday +%d)

# Generate reports
# CPU report for specific time range
sar -u -s 09:00:00 -e 17:00:00

# Memory report with graphs (requires gnuplot)
sadf -g /var/log/sa/sa$(date +%d) -- -r > memory.svg

# Custom SAR collection
sar -o /tmp/sar.data 2 10  # Collect every 2 seconds, 10 times
sar -f /tmp/sar.data  # Read the collected data
```

### Log Analysis with journalctl

#### Mining the System Journal

```bash
# View all logs
journalctl
# Use arrows to navigate, 'q' to quit

# Follow logs in real-time
journalctl -f
# Like 'tail -f' but for the journal

# Logs since boot
journalctl -b
# Current boot
journalctl -b -1  # Previous boot
journalctl -b -2  # Boot before that

# List boots
journalctl --list-boots
# -2 abc123... Mon 2023-12-11 08:00:00 EST—Mon 2023-12-11 20:00:00 EST
# -1 def456... Tue 2023-12-12 08:00:00 EST—Tue 2023-12-12 20:00:00 EST
#  0 ghi789... Wed 2023-12-13 08:00:00 EST—Wed 2023-12-13 12:00:00 EST

# Time-based filtering
journalctl --since "1 hour ago"
journalctl --since today
journalctl --since yesterday --until "1 hour ago"
journalctl --since "2023-12-13 09:00:00" --until "2023-12-13 10:00:00"

# Priority filtering
journalctl -p err  # Errors and worse
journalctl -p warning..err  # Warnings and errors
# Priorities: emerg, alert, crit, err, warning, notice, info, debug

# Service filtering
journalctl -u sshd
journalctl -u nginx -u httpd  # Multiple services

# Kernel messages
journalctl -k
# Equivalent to dmesg

# User session logs
journalctl _UID=1000

# Executable logs
journalctl _EXE=/usr/bin/bash

# Output formats
journalctl -o json | jq '.'  # JSON format
journalctl -o short-precise  # Microsecond timestamps
journalctl -o cat  # Just messages

# Disk usage
journalctl --disk-usage
# Archived and active journals take up 248.0M in the file system.

# Verify journal integrity
journalctl --verify

# Export logs
journalctl -u nginx --since today -o json > nginx-logs.json

# Pattern matching
journalctl -g "error|failed|critical"  # Grep pattern

# Show fields
journalctl -F _SYSTEMD_UNIT  # List all units with logs

# Complex queries
journalctl _SYSTEMD_UNIT=sshd.service _PID=1234 PRIORITY=3
```

### Cockpit Web Console

#### Web-Based System Management

```bash
# Install Cockpit
sudo dnf install -y cockpit

# Enable and start Cockpit
sudo systemctl enable --now cockpit.socket

# Open firewall port
sudo firewall-cmd --permanent --add-service=cockpit
sudo firewall-cmd --reload

# Access Cockpit
echo "Access Cockpit at: https://$(hostname -I | awk '{print $1}'):9090"
# Login with your system credentials

# Install additional Cockpit modules
sudo dnf install -y cockpit-{dashboard,podman,machines,packagekit,storaged}

# Configure Cockpit
sudo nano /etc/cockpit/cockpit.conf
[WebService]
AllowUnencrypted = false
MaxStartups = 10
LoginTitle = Rocky Linux Server Management
LoginTo = false

[Session]
IdleTimeout = 15
Banner = /etc/cockpit/issue.cockpit

# Create custom banner
sudo nano /etc/cockpit/issue.cockpit
Welcome to Rocky Linux Cockpit
Authorized access only!

# Enable performance metrics collection
sudo systemctl enable --now pmlogger
sudo systemctl enable --now pmcd

# Cockpit features:
# - Real-time performance graphs
# - Service management
# - Log viewer
# - Storage management
# - Network configuration
# - User management
# - Terminal access
# - Container management
# - Virtual machine management
# - Software updates
```

---

## Chapter 17: Performance Optimization

### Kernel Parameter Tuning

#### Understanding and Modifying Kernel Parameters

```bash
# View all kernel parameters
sysctl -a | less
# kern.ostype = Linux
# kern.osrelease = 4.18.0-513.9.1.el8_9.x86_64
# ...thousands more...

# View specific parameter
sysctl net.ipv4.ip_forward
# net.ipv4.ip_forward = 0

# Set parameter temporarily
sudo sysctl net.ipv4.ip_forward=1
# net.ipv4.ip_forward = 1

# Set parameter permanently
echo "net.ipv4.ip_forward = 1" | sudo tee -a /etc/sysctl.d/99-custom.conf
sudo sysctl -p /etc/sysctl.d/99-custom.conf

# Common performance parameters
cat > /etc/sysctl.d/99-performance.conf << 'EOF'
# Network Performance Tuning
# Increase network buffer sizes
net.core.rmem_max = 134217728
net.core.wmem_max = 134217728
net.ipv4.tcp_rmem = 4096 87380 134217728
net.ipv4.tcp_wmem = 4096 65536 134217728

# Increase connection backlog
net.core.somaxconn = 65535
net.ipv4.tcp_max_syn_backlog = 8192

# Enable TCP Fast Open
net.ipv4.tcp_fastopen = 3

# Reduce TCP keepalive time
net.ipv4.tcp_keepalive_time = 300
net.ipv4.tcp_keepalive_probes = 5
net.ipv4.tcp_keepalive_intvl = 15

# Memory Management
# Reduce swappiness (prefer RAM over swap)
vm.swappiness = 10

# Increase max map count (for databases)
vm.max_map_count = 262144

# File System
# Increase file handle limits
fs.file-max = 2097152

# Increase inotify limits
fs.inotify.max_user_watches = 524288
fs.inotify.max_queued_events = 32768
fs.inotify.max_user_instances = 8192
EOF

# Apply settings
sudo sysctl -p /etc/sysctl.d/99-performance.conf

# Monitor kernel performance
# Check dropped packets
netstat -s | grep -i drop

# Check connection states
ss -s

# Check memory pressure
cat /proc/pressure/memory
# some avg10=0.00 avg60=0.00 avg300=0.00 total=0
# full avg10=0.00 avg60=0.00 avg300=0.00 total=0
```

### Tuned Profiles for Optimization

#### Automatic Performance Tuning

```bash
# Install and start tuned
sudo dnf install -y tuned
sudo systemctl enable --now tuned

# List available profiles
tuned-adm list
# Available profiles:
# - balanced                    - General non-specialized tuned profile
# - desktop                     - Optimize for desktop
# - hpc-compute                 - Optimize for HPC compute workloads
# - latency-performance         - Optimize for deterministic performance
# - network-latency            - Optimize for deterministic low latency
# - network-throughput         - Optimize for streaming network throughput
# - powersave                  - Optimize for low power consumption
# - throughput-performance     - Broadly applicable tuning for throughput
# - virtual-guest              - Optimize for running inside a VM
# - virtual-host               - Optimize for running VMs
# Current active profile: balanced

# Show current profile
tuned-adm active
# Current active profile: balanced

# Get profile recommendation
tuned-adm recommend
# virtual-guest  # If running in a VM
# throughput-performance  # If physical server

# Switch profile
sudo tuned-adm profile throughput-performance
# Switching to profile 'throughput-performance'
# Applying processor partitioning: os=0-3
# Applying core affinity: 0-3
# Applying disk tuning...
# Applying network tuning...

# Verify profile is active
tuned-adm verify
# Verification succeeded, current system settings match the preset profile

# Monitor profile effects
tuned-adm profile_info throughput-performance
# Profile name: throughput-performance
# Profile summary: Broadly applicable tuning that provides excellent performance

# Create custom profile
sudo mkdir /etc/tuned/my-app
sudo nano /etc/tuned/my-app/tuned.conf

[main]
summary=Custom profile for my application
include=throughput-performance

[cpu]
governor=performance
energy_perf_bias=performance
min_perf_pct=100

[disk]
elevator=noop

[sysctl]
# Custom kernel parameters
net.core.somaxconn=65535
vm.swappiness=1
vm.dirty_ratio=15
vm.dirty_background_ratio=5

[script]
script=/etc/tuned/my-app/script.sh

# Create profile script
sudo nano /etc/tuned/my-app/script.sh
#!/bin/bash
. /usr/lib/tuned/functions

start() {
    echo "Applying custom tuning..."
    # Disable transparent huge pages
    echo never > /sys/kernel/mm/transparent_hugepage/enabled
    echo never > /sys/kernel/mm/transparent_hugepage/defrag

    # Set CPU frequency to max
    for cpu in /sys/devices/system/cpu/cpu[0-9]*; do
        echo performance > $cpu/cpufreq/scaling_governor
    done

    return 0
}

stop() {
    echo "Removing custom tuning..."
    return 0
}

process $@

sudo chmod +x /etc/tuned/my-app/script.sh

# Apply custom profile
sudo tuned-adm profile my-app
```

### Memory Management and Huge Pages

#### Optimizing Memory Performance

```bash
# Check current memory info
cat /proc/meminfo | grep -i huge
# AnonHugePages:    245760 kB
# ShmemHugePages:        0 kB
# HugePages_Total:       0
# HugePages_Free:        0
# HugePages_Rsvd:        0
# HugePages_Surp:        0
# Hugepagesize:       2048 kB

# Configure huge pages
# Calculate needed pages (e.g., for 4GB)
# 4GB = 4096MB / 2MB per page = 2048 pages

# Set huge pages temporarily
sudo sysctl vm.nr_hugepages=2048

# Set permanently
echo "vm.nr_hugepages = 2048" | sudo tee -a /etc/sysctl.d/99-hugepages.conf

# Monitor huge page usage
watch -n 1 'cat /proc/meminfo | grep -i huge'

# Transparent Huge Pages (THP)
# Check THP status
cat /sys/kernel/mm/transparent_hugepage/enabled
# [always] madvise never

# Disable THP (recommended for databases)
echo never | sudo tee /sys/kernel/mm/transparent_hugepage/enabled
echo never | sudo tee /sys/kernel/mm/transparent_hugepage/defrag

# Make it permanent
cat > /etc/systemd/system/disable-thp.service << 'EOF'
[Unit]
Description=Disable Transparent Huge Pages
DefaultDependencies=no
After=sysinit.target local-fs.target
Before=basic.target

[Service]
Type=oneshot
ExecStart=/bin/sh -c 'echo never > /sys/kernel/mm/transparent_hugepage/enabled && echo never > /sys/kernel/mm/transparent_hugepage/defrag'

[Install]
WantedBy=basic.target
EOF

sudo systemctl daemon-reload
sudo systemctl enable --now disable-thp.service

# NUMA (Non-Uniform Memory Access) optimization
# Check NUMA configuration
numactl --hardware
# available: 2 nodes (0-1)
# node 0 cpus: 0 1 2 3
# node 0 size: 16384 MB
# node 1 cpus: 4 5 6 7
# node 1 size: 16384 MB

# Run process with NUMA binding
numactl --cpunodebind=0 --membind=0 myapp

# Check NUMA statistics
numastat
# node0           node1
# numa_hit        1234567         2345678
# numa_miss       12345           23456
# numa_foreign    23456           12345

# Memory pressure monitoring
cat /proc/pressure/memory
# some avg10=0.00 avg60=0.00 avg300=0.00 total=0
# full avg10=0.00 avg60=0.00 avg300=0.00 total=0

# Enable memory pressure notifications
cat > /usr/local/bin/memory-pressure-monitor.sh << 'EOF'
#!/bin/bash
while true; do
    read -r line < /proc/pressure/memory
    if [[ $line =~ avg10=([0-9.]+) ]]; then
        pressure="${BASH_REMATCH[1]}"
        if (( $(echo "$pressure > 10" | bc -l) )); then
            logger -p warning "High memory pressure: $pressure"
            # Send alert
        fi
    fi
    sleep 10
done
EOF

chmod +x /usr/local/bin/memory-pressure-monitor.sh
```

### I/O Scheduling and Optimization

#### Optimizing Disk Performance

```bash
# Check current I/O scheduler
cat /sys/block/sda/queue/scheduler
# [mq-deadline] kyber bfq none

# I/O Schedulers explained:
# none = No scheduling (good for NVMe)
# mq-deadline = Multiqueue deadline (good for databases)
# kyber = Multiqueue token bucket (good for mixed workloads)
# bfq = Budget Fair Queueing (good for desktop)

# Change I/O scheduler
echo mq-deadline | sudo tee /sys/block/sda/queue/scheduler

# Make it permanent
echo 'ACTION=="add|change", KERNEL=="sd[a-z]", ATTR{queue/scheduler}="mq-deadline"' | \
    sudo tee /etc/udev/rules.d/60-io-scheduler.rules

# I/O tuning parameters
# Read-ahead
cat /sys/block/sda/queue/read_ahead_kb
# 128

# Increase read-ahead for sequential workloads
echo 1024 | sudo tee /sys/block/sda/queue/read_ahead_kb

# Queue depth
cat /sys/block/sda/queue/nr_requests
# 64

# Increase for high I/O workloads
echo 256 | sudo tee /sys/block/sda/queue/nr_requests

# Monitor I/O performance
# Real-time I/O stats
iotop -o  # Only show processes doing I/O

# Detailed I/O statistics
iostat -x 1
# Device            r/s     w/s     rkB/s   wkB/s   rrqm/s  wrqm/s  await  svctm  %util
# sda              15.00   25.00   120.00  200.00    0.00    5.00   2.50   0.50  20.00

# Per-process I/O
pidstat -d 1

# Block device tuning script
cat > /usr/local/bin/io-tune.sh << 'EOF'
#!/bin/bash
# Optimize I/O for all block devices

for disk in /sys/block/sd*; do
    # Set scheduler
    echo mq-deadline > $disk/queue/scheduler

    # Increase read-ahead
    echo 1024 > $disk/queue/read_ahead_kb

    # Increase queue depth
    echo 256 > $disk/queue/nr_requests

    # Disable entropy contribution (for SSDs)
    if [[ $(cat $disk/queue/rotational) == "0" ]]; then
        echo 0 > $disk/queue/add_random
    fi
done

echo "I/O tuning applied"
EOF

sudo chmod +x /usr/local/bin/io-tune.sh

# Create systemd service for I/O tuning
cat > /etc/systemd/system/io-tune.service << 'EOF'
[Unit]
Description=I/O Performance Tuning
After=local-fs.target

[Service]
Type=oneshot
ExecStart=/usr/local/bin/io-tune.sh
RemainAfterExit=yes

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
sudo systemctl enable --now io-tune.service
```

### Network Performance Tuning

#### Optimizing Network Stack

```bash
# Network tuning script
cat > /etc/sysctl.d/99-network-performance.conf << 'EOF'
# TCP Performance Tuning

# TCP Buffer Sizes (min, default, max)
net.ipv4.tcp_rmem = 4096 131072 6291456
net.ipv4.tcp_wmem = 4096 16384 4194304

# Socket Buffer Sizes
net.core.rmem_default = 262144
net.core.rmem_max = 6291456
net.core.wmem_default = 262144
net.core.wmem_max = 4194304

# Connection Queue
net.core.netdev_max_backlog = 30000
net.core.somaxconn = 65535
net.ipv4.tcp_max_syn_backlog = 8192

# TCP Optimization
net.ipv4.tcp_fin_timeout = 10
net.ipv4.tcp_tw_reuse = 1
net.ipv4.ip_local_port_range = 10000 65535

# Congestion Control
net.core.default_qdisc = fq
net.ipv4.tcp_congestion_control = bbr

# Enable TCP Fast Open
net.ipv4.tcp_fastopen = 3

# Disable TCP timestamps (if not needed)
net.ipv4.tcp_timestamps = 0

# Connection Tracking (for high connection count)
net.netfilter.nf_conntrack_max = 524288
net.nf_conntrack_max = 524288
EOF

sudo sysctl -p /etc/sysctl.d/99-network-performance.conf

# NIC tuning
# Check current settings
ethtool -g eth0
# Ring parameters for eth0:
# Pre-set maximums:
# RX:             4096
# TX:             4096
# Current hardware settings:
# RX:             256
# TX:             256

# Increase ring buffers
sudo ethtool -G eth0 rx 4096 tx 4096

# Check offload settings
ethtool -k eth0 | grep -E "tcp|udp|generic"

# Enable offloading
sudo ethtool -K eth0 rx on tx on sg on tso on gso on gro on lro on

# Interrupt coalescing (reduce CPU interrupts)
sudo ethtool -c eth0
# Adaptive RX: off  TX: off

# Set interrupt coalescing
sudo ethtool -C eth0 adaptive-rx on adaptive-tx on

# CPU affinity for network interrupts
# Find network IRQs
grep eth0 /proc/interrupts
#  24:    1234567   PCI-MSI-edge      eth0-rx-0
#  25:    2345678   PCI-MSI-edge      eth0-tx-0

# Set CPU affinity (bind to CPU 0)
echo 1 | sudo tee /proc/irq/24/smp_affinity
echo 1 | sudo tee /proc/irq/25/smp_affinity

# Monitor network performance
# Packet statistics
netstat -s

# Interface errors
ip -s link show eth0

# TCP retransmissions
ss -ti | grep -c retrans

# Network latency test
ping -c 100 8.8.8.8 | tail -1
```

### CPU Scheduling and Affinity

#### Optimizing CPU Performance

```bash
# Check CPU information
lscpu
# Architecture:          x86_64
# CPU(s):                8
# Thread(s) per core:    2
# Core(s) per socket:    4
# Socket(s):             1

# CPU frequency scaling
# Check current governor
cat /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor
# powersave
# powersave
# powersave
# powersave

# Set performance governor
for cpu in /sys/devices/system/cpu/cpu[0-9]*; do
    echo performance | sudo tee $cpu/cpufreq/scaling_governor
done

# Check available frequencies
cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_available_frequencies
# 3600000 3400000 3200000 3000000 2800000 2600000 2400000 2200000

# Set minimum frequency
for cpu in /sys/devices/system/cpu/cpu[0-9]*; do
    echo 3000000 | sudo tee $cpu/cpufreq/scaling_min_freq
done

# Process CPU affinity
# Run process on specific CPUs
taskset -c 0,1 myapp  # Run on CPU 0 and 1
taskset -c 0-3 myapp  # Run on CPU 0 through 3

# Check process affinity
taskset -p 1234
# pid 1234's current affinity mask: ff  # All 8 CPUs

# Change running process affinity
taskset -p -c 0,1 1234

# Isolate CPUs for dedicated use
# Add to kernel boot parameters:
# isolcpus=4,5,6,7 nohz_full=4,5,6,7 rcu_nocbs=4,5,6,7

# Nice and priority
# Run with lower priority
nice -n 10 myapp

# Change running process priority
renice -n 5 -p 1234

# Real-time priority
chrt -f 50 myapp  # FIFO scheduler, priority 50
chrt -r 50 myapp  # Round-robin scheduler

# Check process scheduler
chrt -p 1234
# pid 1234's current scheduling policy: SCHED_OTHER
# pid 1234's current scheduling priority: 0

# CPU sets for process isolation
# Create CPU set
sudo mkdir /sys/fs/cgroup/cpuset/isolated
echo 4-7 | sudo tee /sys/fs/cgroup/cpuset/isolated/cpuset.cpus
echo 0 | sudo tee /sys/fs/cgroup/cpuset/isolated/cpuset.mems

# Assign process to CPU set
echo 1234 | sudo tee /sys/fs/cgroup/cpuset/isolated/tasks
```

### Troubleshooting Performance Issues

#### Performance Problem Diagnosis

```bash
# Performance troubleshooting checklist

# 1. Overall system health
uptime  # Load average
free -h  # Memory
df -h  # Disk space
systemctl status  # Services

# 2. Resource bottleneck identification
# CPU bottleneck
top -b -n 1 | head -20
mpstat 1 5

# Memory bottleneck
vmstat 1 5
slabtop -o

# Disk I/O bottleneck
iostat -x 1 5
iotop -b -n 1

# Network bottleneck
netstat -i
ss -s

# 3. Deep dive tools
# CPU profiling with perf
sudo perf record -g -p 1234 sleep 10
sudo perf report

# System call tracing
sudo strace -c -p 1234

# Block I/O tracing
sudo blktrace -d /dev/sda -o trace
sudo blkparse -i trace

# 4. Create performance report script
cat > /usr/local/bin/performance-report.sh << 'EOF'
#!/bin/bash

REPORT_DIR="/var/log/performance"
TIMESTAMP=$(date +%Y%m%d-%H%M%S)
REPORT_FILE="$REPORT_DIR/report-$TIMESTAMP.txt"

mkdir -p "$REPORT_DIR"

{
    echo "Performance Report - $(date)"
    echo "======================================"
    echo ""

    echo "=== System Information ==="
    uname -a
    uptime
    echo ""

    echo "=== CPU Usage ==="
    mpstat 1 3
    echo ""

    echo "=== Memory Usage ==="
    free -h
    vmstat 1 3
    echo ""

    echo "=== Disk I/O ==="
    iostat -x 1 3
    df -h
    echo ""

    echo "=== Network ==="
    ss -s
    netstat -i
    echo ""

    echo "=== Top Processes ==="
    ps aux --sort=-%cpu | head -10
    echo ""
    ps aux --sort=-%mem | head -10
    echo ""

    echo "=== System Logs (Recent Errors) ==="
    journalctl -p err --since="1 hour ago" | tail -20

} > "$REPORT_FILE"

echo "Performance report saved to: $REPORT_FILE"

# Check for common issues
echo ""
echo "=== Quick Analysis ==="

# High load
load=$(uptime | awk -F'load average:' '{print $2}' | awk '{print $1}' | sed 's/,//')
cores=$(nproc)
if (( $(echo "$load > $cores" | bc -l) )); then
    echo "⚠ WARNING: High load average ($load) for $cores cores"
fi

# Low memory
free_mem=$(free -m | awk 'NR==2{print $7}')
if [ $free_mem -lt 500 ]; then
    echo "⚠ WARNING: Low available memory (${free_mem}MB)"
fi

# Disk space
df -h | awk '$5 > 80 {print "⚠ WARNING: " $6 " is " $5 " full"}'

# Failed services
failed=$(systemctl list-units --failed --no-legend | wc -l)
if [ $failed -gt 0 ]; then
    echo "⚠ WARNING: $failed failed services"
    systemctl list-units --failed --no-legend
fi
EOF

sudo chmod +x /usr/local/bin/performance-report.sh
```

## Practice Exercises

### Exercise 1: Monitoring Setup
1. Configure PCP for comprehensive monitoring
2. Set up SAR with custom collection intervals
3. Create a dashboard using Cockpit
4. Implement custom monitoring scripts
5. Set up alerting for resource thresholds
6. Create automated performance reports

### Exercise 2: Performance Baseline
1. Establish CPU performance baseline
2. Document memory usage patterns
3. Analyze disk I/O characteristics
4. Map network traffic patterns
5. Create performance documentation
6. Set up trend analysis

### Exercise 3: Optimization Project
1. Identify system bottlenecks
2. Apply appropriate tuned profile
3. Optimize kernel parameters
4. Configure huge pages for database
5. Tune network stack for web server
6. Measure performance improvements

### Exercise 4: Troubleshooting Scenarios
1. Diagnose high CPU usage
2. Resolve memory pressure issues
3. Fix disk I/O bottlenecks
4. Troubleshoot network latency
5. Analyze application performance
6. Create troubleshooting runbook

## Summary

In Part 7, we've mastered monitoring and performance optimization in Rocky Linux:

**System Monitoring:**
- Performance Co-Pilot (PCP) for advanced monitoring
- Resource monitoring with traditional tools
- Process analysis and tracking
- System Activity Reporter (SAR) for historical data
- Log analysis with journalctl
- Cockpit web console for GUI management

**Performance Optimization:**
- Kernel parameter tuning for specific workloads
- Tuned profiles for automatic optimization
- Memory management and huge pages
- I/O scheduling and disk optimization
- Network stack performance tuning
- CPU scheduling and affinity management
- Systematic performance troubleshooting

These skills enable you to:
- Monitor systems comprehensively
- Identify performance bottlenecks
- Optimize for specific workloads
- Troubleshoot performance issues
- Maintain optimal system performance
- Create performance baselines and reports

## Additional Resources

- [Rocky Linux Performance Tuning Guide](https://docs.rockylinux.org/guides/system/performance/)
- [Performance Co-Pilot Documentation](https://pcp.io/docs/)
- [Red Hat Performance Tuning Guide](https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/8/html/monitoring_and_managing_system_status_and_performance/index)
- [Tuned Project](https://tuned-project.org/)
- [Linux Performance Analysis](http://www.brendangregg.com/linuxperf.html)
- [Cockpit Project](https://cockpit-project.org/)
- [Kernel Documentation](https://www.kernel.org/doc/Documentation/sysctl/)
- [SAR Command Examples](https://www.thegeekstuff.com/2011/03/sar-examples/)

---

*Continue to Part 8: Web and Database Servers*