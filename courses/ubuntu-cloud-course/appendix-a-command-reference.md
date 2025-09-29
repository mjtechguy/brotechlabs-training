# Appendix A: Command Reference

## Essential Command Cheatsheet

### System Information

```bash
# System identification
hostname                      # Display hostname
hostname -f                   # Display FQDN
hostnamectl                   # Display/set hostname and system info
uname -a                      # Display kernel and system information
lsb_release -a               # Display Ubuntu version information
cat /etc/os-release          # Display OS information

# Hardware information
lscpu                        # Display CPU information
lsmem                        # Display memory information
lsblk                        # Display block devices
lspci                        # Display PCI devices
lsusb                        # Display USB devices
dmidecode                    # Display hardware information from BIOS

# System resources
free -h                      # Display memory usage (human-readable)
df -h                        # Display disk usage (human-readable)
du -sh /path                 # Display directory size
uptime                       # Display system uptime and load
w                           # Display who is logged in and what they're doing
```

### File and Directory Operations

```bash
# Navigation
cd /path/to/directory        # Change directory
cd -                         # Go to previous directory
cd ~                         # Go to home directory
pwd                          # Print working directory

# Listing files
ls -la                       # List all files with details
ls -lah                      # List with human-readable sizes
ls -lt                       # List sorted by modification time
ls -lS                       # List sorted by size
tree                         # Display directory tree structure

# File operations
cp -r source dest            # Copy recursively
cp -p source dest            # Copy preserving attributes
mv source dest               # Move/rename files
rm -rf directory             # Remove directory forcefully
mkdir -p /path/to/dir        # Create directory with parents
touch filename               # Create empty file or update timestamp

# File permissions
chmod 755 file               # Set permissions (rwxr-xr-x)
chmod u+x file               # Add execute permission for user
chmod -R 644 directory       # Recursively set permissions
chown user:group file        # Change ownership
chown -R user:group dir      # Recursively change ownership

# Finding files
find / -name "*.log"         # Find files by name
find / -type f -size +100M  # Find files larger than 100MB
find / -mtime -7             # Find files modified in last 7 days
find / -user username        # Find files owned by user
locate filename              # Find files using locate database
which command                # Find command location
whereis command              # Find binary, source, and manual for command
```

### Process Management

```bash
# Process viewing
ps aux                       # Show all processes
ps aux --sort=-%cpu         # Sort processes by CPU usage
ps aux --sort=-%mem         # Sort processes by memory usage
ps -ef                       # Full format listing
ps -p PID                    # Show specific process
pstree                       # Display process tree
top                          # Interactive process viewer
htop                         # Enhanced interactive process viewer

# Process control
kill PID                     # Terminate process
kill -9 PID                  # Force kill process
killall process_name         # Kill all processes by name
pkill pattern                # Kill processes matching pattern
pgrep pattern                # Find PIDs matching pattern
nice -n 10 command           # Run command with lower priority
renice 10 PID                # Change process priority
nohup command &              # Run command immune to hangups

# Background jobs
command &                    # Run command in background
jobs                         # List background jobs
fg %1                        # Bring job 1 to foreground
bg %1                        # Send job 1 to background
disown %1                    # Disown job 1
```

### User and Group Management

```bash
# User management
adduser username             # Add new user (interactive)
useradd username             # Add new user (non-interactive)
userdel username             # Delete user
userdel -r username          # Delete user and home directory
usermod -aG group user       # Add user to group
usermod -l newname oldname   # Rename user
passwd username              # Change user password
passwd -l username           # Lock user account
passwd -u username           # Unlock user account
chage -l username            # Display password aging information

# Group management
groupadd groupname           # Create new group
groupdel groupname           # Delete group
groupmod -n newname oldname  # Rename group
groups username              # Display user's groups
id username                  # Display user and group IDs

# User information
who                          # Display logged in users
whoami                       # Display current username
last                         # Display login history
lastlog                      # Display last login for all users
finger username              # Display user information
su - username                # Switch to user
sudo command                 # Execute command as root
sudo -u user command         # Execute command as another user
```

### Package Management

```bash
# APT commands
apt update                   # Update package lists
apt upgrade                  # Upgrade installed packages
apt full-upgrade            # Full system upgrade
apt install package          # Install package
apt remove package           # Remove package
apt purge package            # Remove package and config files
apt autoremove              # Remove unused packages
apt autoclean               # Clean package cache
apt search keyword          # Search for packages
apt show package            # Show package information
apt list --installed        # List installed packages
apt list --upgradeable      # List upgradeable packages

# DPKG commands
dpkg -i package.deb         # Install .deb file
dpkg -r package             # Remove package
dpkg -P package             # Purge package
dpkg -l                     # List installed packages
dpkg -L package             # List files in package
dpkg -S /path/to/file       # Find package owning file
dpkg --configure -a         # Configure unconfigured packages

# Snap commands
snap list                   # List installed snaps
snap find package           # Search for snaps
snap install package        # Install snap
snap remove package         # Remove snap
snap refresh                # Update all snaps
snap refresh package        # Update specific snap
```

### Network Commands

```bash
# Network configuration
ip addr show                # Display IP addresses
ip link show                # Display network interfaces
ip route show               # Display routing table
ip neigh show               # Display ARP table
ifconfig                    # Display network interfaces (legacy)
route -n                    # Display routing table (legacy)

# Network connectivity
ping -c 4 host              # Ping host 4 times
ping6 -c 4 host             # IPv6 ping
traceroute host             # Trace route to host
tracepath host              # Alternative to traceroute
mtr host                    # Interactive traceroute
nc -zv host port            # Test port connectivity
telnet host port            # Connect to port

# DNS
nslookup domain             # Query DNS
dig domain                  # Detailed DNS query
dig +short domain           # Brief DNS query
host domain                 # DNS lookup
systemd-resolve --status    # Display resolver status

# Network monitoring
ss -tulpn                   # Show listening ports
ss -tan                     # Show all TCP connections
netstat -tulpn              # Show listening ports (legacy)
netstat -tan                # Show all TCP connections (legacy)
lsof -i :port               # Show process using port
iftop                       # Real-time bandwidth monitor
nethogs                     # Per-process bandwidth monitor
iptraf-ng                   # Network statistics
vnstat                      # Network traffic monitor

# File transfer
wget URL                    # Download file
wget -c URL                 # Resume download
curl -O URL                 # Download file
curl -L URL                 # Follow redirects
rsync -av source dest       # Sync files
rsync -avz source dest      # Sync with compression
scp file user@host:path     # Secure copy
sftp user@host              # Secure FTP
```

### Service Management

```bash
# Systemctl commands
systemctl status service     # Check service status
systemctl start service      # Start service
systemctl stop service       # Stop service
systemctl restart service    # Restart service
systemctl reload service     # Reload service configuration
systemctl enable service     # Enable service at boot
systemctl disable service    # Disable service at boot
systemctl is-active service  # Check if service is active
systemctl is-enabled service # Check if service is enabled
systemctl list-units        # List all units
systemctl list-units --failed # List failed units
systemctl daemon-reload      # Reload systemd manager
systemctl get-default        # Get default target
systemctl set-default target # Set default target

# Journalctl commands
journalctl                   # View all logs
journalctl -xe              # View recent logs with explanation
journalctl -u service       # View service logs
journalctl -f               # Follow logs (tail -f)
journalctl --since "1 hour ago" # View logs since time
journalctl --until "2024-01-01" # View logs until date
journalctl -p err           # View error messages
journalctl -n 50            # View last 50 entries
journalctl --disk-usage     # Show journal disk usage
journalctl --vacuum-time=7d # Clean logs older than 7 days
```

### File System Operations

```bash
# Disk and partition management
fdisk -l                    # List partitions
fdisk /dev/sda              # Partition disk
parted /dev/sda             # Advanced partitioning
mkfs.ext4 /dev/sda1         # Format as ext4
mkfs.xfs /dev/sda1          # Format as XFS
mount /dev/sda1 /mnt        # Mount filesystem
umount /mnt                 # Unmount filesystem
mount -a                    # Mount all in fstab
findmnt                     # Display mounted filesystems
blkid                       # Display block device attributes

# File system checking
fsck /dev/sda1              # Check filesystem
fsck -y /dev/sda1           # Auto-repair filesystem
e2fsck /dev/sda1            # Check ext2/3/4 filesystem
xfs_repair /dev/sda1        # Repair XFS filesystem

# Disk usage
df -h                       # Display disk usage
df -i                       # Display inode usage
du -sh *                    # Display directory sizes
du -sh * | sort -rh         # Sort by size
ncdu                        # Interactive disk usage

# LVM commands
pvdisplay                   # Display physical volumes
vgdisplay                   # Display volume groups
lvdisplay                   # Display logical volumes
pvcreate /dev/sda1          # Create physical volume
vgcreate vg0 /dev/sda1      # Create volume group
lvcreate -L 10G -n lv0 vg0  # Create logical volume
lvextend -L +5G /dev/vg0/lv0 # Extend logical volume
resize2fs /dev/vg0/lv0      # Resize filesystem
```

## Useful One-liners

### System Administration

```bash
# Find largest files
find / -type f -exec du -h {} + | sort -rh | head -20

# Find largest directories
du -h / 2>/dev/null | sort -rh | head -20

# Delete files older than 30 days
find /path -type f -mtime +30 -delete

# Count files in directory
find /path -type f | wc -l

# Monitor log file in real-time with highlight
tail -f /var/log/syslog | grep --color -E "error|warning|$"

# Show system boot time
who -b | awk '{print $3, $4}'

# List all cron jobs for all users
for user in $(cut -f1 -d: /etc/passwd); do echo "=== $user ==="; crontab -l -u $user 2>/dev/null; done

# Generate random password
openssl rand -base64 32

# Test disk write speed
dd if=/dev/zero of=/tmp/test bs=1M count=1024 conv=fdatasync

# Test disk read speed
dd if=/tmp/test of=/dev/null bs=1M count=1024

# Show top 10 memory consuming processes
ps aux --sort=-%mem | head -11

# Show top 10 CPU consuming processes
ps aux --sort=-%cpu | head -11

# Kill all processes of a user
pkill -u username

# Archive and compress directory
tar czf archive.tar.gz /path/to/directory

# Extract archive
tar xzf archive.tar.gz

# Sync directories excluding certain files
rsync -av --exclude='*.log' --exclude='*.tmp' source/ dest/

# Monitor system calls of a process
strace -p PID -c

# Show all listening ports with process names
ss -tlnp | grep LISTEN

# Watch command output
watch -n 1 'df -h'

# Create multiple directories at once
mkdir -p /path/{dir1,dir2,dir3}/{subdir1,subdir2}

# Batch rename files
for f in *.txt; do mv "$f" "${f%.txt}.bak"; done

# Find and replace in multiple files
find . -type f -name "*.txt" -exec sed -i 's/old/new/g' {} +

# Show directory tree with size
tree -sh /path

# Calculate directory size excluding subdirectories
du -Sh /path | sort -rh | head -20
```

### Network One-liners

```bash
# Show all network connections with process
ss -tupn

# Monitor network traffic by process
nethogs

# Check what process is using a port
lsof -i :80

# Test port from command line
echo > /dev/tcp/host/port && echo "Port open" || echo "Port closed"

# Download file with resume support
wget -c URL

# Download with custom user agent
curl -A "Mozilla/5.0" URL

# Monitor bandwidth usage
iftop -i eth0

# Show network statistics
netstat -s

# List all IP addresses
ip -4 addr | grep -oP '(?<=inet\s)\d+(\.\d+){3}'

# Flush DNS cache
systemd-resolve --flush-caches

# Show DNS statistics
systemd-resolve --statistics

# Block IP with iptables
iptables -A INPUT -s IP_ADDRESS -j DROP

# Allow port through firewall
ufw allow 8080/tcp

# Show established connections
ss -tan state established

# Monitor packet drops
watch -n 1 'netstat -i'

# Test MTU size
ping -M do -s 1472 host

# Show ARP cache
arp -n

# Add static ARP entry
arp -s IP_ADDRESS MAC_ADDRESS

# TCP dump with readable timestamp
tcpdump -tttt -i any port 80

# Monitor HTTP traffic
tcpdump -i any -A -s 0 'tcp port 80'

# Show routing table with metrics
ip route show table all

# Add static route
ip route add 192.168.1.0/24 via 10.0.0.1 dev eth0
```

### Log Analysis One-liners

```bash
# Count occurrences of IP addresses in log
awk '{print $1}' /var/log/nginx/access.log | sort | uniq -c | sort -rn | head -20

# Find 404 errors
grep " 404 " /var/log/nginx/access.log

# Show most frequent errors
grep ERROR /var/log/syslog | awk '{print $5,$6,$7,$8,$9}' | sort | uniq -c | sort -rn | head -20

# Monitor multiple log files
multitail /var/log/nginx/access.log /var/log/nginx/error.log

# Extract time range from log
awk '/Start_Pattern/,/End_Pattern/' /var/log/syslog

# Count requests per minute
awk '{print $4}' /var/log/nginx/access.log | cut -d: -f1-3 | uniq -c

# Find slow queries in MySQL log
grep -E "Query_time: [0-9]{2,}" /var/log/mysql/slow.log

# Show failed SSH attempts
grep "Failed password" /var/log/auth.log | awk '{print $11}' | sort | uniq -c | sort -rn

# Extract unique user agents
awk -F'"' '/GET/ {print $6}' /var/log/nginx/access.log | sort | uniq

# Calculate average response time
awk '{sum+=$10; count++} END {print sum/count}' /var/log/nginx/access.log

# Show log entries from last hour
journalctl --since "1 hour ago"

# Export logs for specific service
journalctl -u nginx --since today --output json > nginx_logs.json

# Follow multiple journal units
journalctl -f -u nginx -u mysql

# Check boot messages
journalctl -b -p err

# Analyze systemd boot time
systemd-analyze blame
```

## Troubleshooting Commands

### System Troubleshooting

```bash
# System diagnostics
dmesg                       # Display kernel messages
dmesg -T                    # Display with timestamps
dmesg --level=err          # Display only errors
systemctl status            # System status overview
systemctl --failed          # Show failed units
systemd-analyze             # Analyze boot time
systemd-analyze blame       # Show boot time by service
systemd-analyze critical-chain # Show critical chain

# Resource issues
vmstat 1                    # Virtual memory statistics
iostat -x 1                 # I/O statistics
mpstat -P ALL 1            # CPU statistics per core
sar -u 1 10                # System activity (CPU)
sar -r 1 10                # System activity (Memory)
sar -d 1 10                # System activity (Disk)
sar -n DEV 1 10           # System activity (Network)

# Memory debugging
free -h                     # Memory usage
cat /proc/meminfo          # Detailed memory info
slabtop                    # Kernel slab cache
ps aux --sort=-%mem | head # Top memory processes
pmap -x PID                # Memory map of process
valgrind --leak-check=full ./program # Memory leak detection

# Disk troubleshooting
smartctl -a /dev/sda       # SMART disk info
smartctl -t short /dev/sda # Run SMART test
badblocks -sv /dev/sda     # Check for bad blocks
hdparm -tT /dev/sda        # Disk performance test
iotop                      # I/O usage by process
iostat -x 1                # Extended I/O stats

# File system issues
mount -a                    # Mount all filesystems
mount -o remount,rw /      # Remount root as read-write
findmnt --verify           # Verify fstab entries
lsof +D /path              # List open files in path
fuser -vm /mountpoint      # Show processes using mountpoint
```

### Network Troubleshooting

```bash
# Connectivity testing
ping -c 4 8.8.8.8          # Test internet connectivity
ping -c 4 gateway_ip       # Test gateway connectivity
traceroute -n 8.8.8.8      # Trace network path
mtr --report 8.8.8.8       # Combined ping/traceroute
curl -I https://site.com   # Test HTTP/HTTPS
wget --spider https://site.com # Test without downloading

# DNS troubleshooting
nslookup domain.com        # Basic DNS query
dig domain.com +trace      # Trace DNS resolution
dig @8.8.8.8 domain.com    # Query specific DNS server
host -v domain.com         # Verbose DNS lookup
systemd-resolve --flush-caches # Flush DNS cache
resolvectl status          # DNS resolver status

# Port and service testing
nc -zv host 22             # Test SSH port
nmap -sV host              # Service version scan
nmap -p- host              # Scan all ports
telnet host port           # Manual port test
openssl s_client -connect host:443 # Test SSL/TLS

# Firewall debugging
iptables -L -v -n          # List firewall rules
iptables -t nat -L -v -n   # List NAT rules
ufw status verbose         # UFW status
ufw show raw               # Show raw iptables rules
conntrack -L               # Show connection tracking

# Interface troubleshooting
ip link set eth0 up        # Bring interface up
ip link set eth0 down      # Bring interface down
ethtool eth0               # Show interface details
ethtool -S eth0            # Show interface statistics
mii-tool eth0              # Show link status
```

### Service Troubleshooting

```bash
# Service debugging
systemctl status service -l # Detailed status
systemctl show service      # All properties
journalctl -u service -e    # Jump to end of logs
journalctl -u service -f    # Follow service logs
journalctl -u service --since "5 min ago"
systemctl cat service       # Show service file
systemctl edit service      # Edit service override
systemctl list-dependencies service # Show dependencies

# Process debugging
strace -p PID              # Trace system calls
strace -e open -p PID      # Trace specific calls
ltrace -p PID              # Trace library calls
lsof -p PID                # List open files
ls -l /proc/PID/fd         # Show file descriptors
cat /proc/PID/status       # Process status
cat /proc/PID/limits       # Process limits
gdb -p PID                 # Attach debugger

# Application logs
tail -f /var/log/app.log   # Follow log file
less +F /var/log/app.log   # Follow in less
grep ERROR /var/log/app.log | tail -50
zgrep ERROR /var/log/app.log.gz # Search compressed logs
```

## Performance Analysis Tools

### CPU Performance

```bash
# CPU monitoring tools
top                        # Interactive process viewer
htop                       # Enhanced top
atop                       # Advanced system monitor
glances                    # Cross-platform monitoring
mpstat -P ALL 1           # Per-CPU statistics
pidstat 1                  # Per-process statistics
perf top                   # Performance counter stats
perf record -g command     # Record performance data
perf report                # Analyze performance data

# CPU frequency
cpupower frequency-info    # CPU frequency information
turbostat                  # CPU turbo state
cpufreq-info              # CPU frequency scaling info
watch -n1 "grep MHz /proc/cpuinfo" # Monitor CPU frequency

# Load testing
stress --cpu 4 --timeout 60s # CPU stress test
stress-ng --cpu 4 --cpu-method all --timeout 60s
sysbench cpu run          # CPU benchmark
```

### Memory Performance

```bash
# Memory monitoring
vmstat 1                   # Virtual memory stats
free -h -s 1              # Memory usage every second
watch -n1 free -h         # Watch memory usage
smem -tk                  # Memory usage by process
ps_mem                    # Memory usage summary

# Memory testing
memtest86+                # Memory test (boot)
memtester 1G 5            # Test 1GB of RAM 5 times
stress --vm 2 --vm-bytes 1G --timeout 60s # Memory stress

# Cache analysis
vmtouch /path/to/file     # Check if file is cached
linux-ftools              # File cache tools
pcstat /path/to/file      # Page cache statistics
```

### Disk I/O Performance

```bash
# I/O monitoring
iostat -x 1               # Extended I/O stats
iotop -o                  # I/O by process (only active)
dstat -d                  # Disk statistics
atop -d                   # Disk activity
sar -d 1                  # Disk activity report

# Disk benchmarking
hdparm -tT /dev/sda       # Simple read test
dd if=/dev/zero of=test bs=1M count=1000 conv=fdatasync # Write test
dd if=test of=/dev/null bs=1M # Read test
fio --name=randread --ioengine=libaio --rw=randread --bs=4k --numjobs=1 --size=1G
bonnie++ -d /tmp -s 2G    # Comprehensive benchmark

# I/O analysis
blktrace -d /dev/sda      # Block I/O tracing
ioping -c 10 /dev/sda     # I/O latency
```

### Network Performance

```bash
# Bandwidth testing
iperf3 -s                 # Server mode
iperf3 -c server_ip       # Client mode
nuttcp -S                 # Server mode
nuttcp server_ip          # Client test
speedtest-cli             # Internet speed test

# Latency testing
ping -f -c 1000 host      # Flood ping
hping3 -S -p 80 host      # TCP ping
sockperf ping-pong        # Socket performance

# Traffic analysis
tcpdump -i eth0 -w capture.pcap # Capture packets
tshark -i eth0            # Terminal Wireshark
ngrep -d eth0 port 80     # Network grep
tcpflow -i eth0           # TCP flow recorder

# Connection analysis
ss -s                     # Socket statistics summary
netstat -s                # Network statistics
conntrack -S              # Connection tracking stats
```

### System-wide Performance

```bash
# Comprehensive monitoring
sar -A                    # All system activity
dstat -af                 # All statistics
collectl                  # Detailed system metrics
nmon                      # Performance monitor

# Performance profiling
perf stat command         # Performance statistics
perf record -a -g sleep 10 # System-wide profiling
perf report               # Analyze profile data
systemtap                 # Dynamic tracing
bpftrace                  # eBPF tracing

# Bottleneck identification
USE Method:
# Utilization
sar -u                    # CPU utilization
sar -r                    # Memory utilization
iostat -x                 # Disk utilization
sar -n DEV                # Network utilization

# Saturation
vmstat 1                  # Run queue (r column)
iostat -x                 # await and avgqu-sz
ss -tan | grep -c ESTAB   # Connection count

# Errors
dmesg | grep -i error     # System errors
netstat -s | grep -i error # Network errors
smartctl -a /dev/sda | grep -i error # Disk errors
```

## Quick Debug Commands

```bash
# Quick system health check
echo "=== System Health Check ==="
uptime
free -h
df -h
systemctl --failed
dmesg | tail -20

# Quick network check
echo "=== Network Check ==="
ip -br addr
ip route
ping -c 1 8.8.8.8
ss -tlnp

# Quick service check
echo "=== Service Check ==="
systemctl status nginx
systemctl status mysql
systemctl status ssh

# Quick security check
echo "=== Security Check ==="
last -20
grep "Failed password" /var/log/auth.log | tail -10
ss -tan state established
ufw status

# Quick performance check
echo "=== Performance Check ==="
top -bn1 | head -20
iostat -x 1 3
vmstat 1 3
```

## Emergency Recovery Commands

```bash
# Boot recovery
# At GRUB menu, press 'e' to edit
# Add to linux line:
init=/bin/bash            # Boot to shell
systemd.unit=emergency.target # Emergency mode
systemd.unit=rescue.target # Rescue mode

# Mount root filesystem as read-write
mount -o remount,rw /

# Fix broken packages
dpkg --configure -a
apt-get update
apt-get -f install
apt --fix-broken install

# Reset root password
passwd root

# Rebuild initramfs
update-initramfs -u -k all

# Reinstall GRUB
grub-install /dev/sda
update-grub

# Fix filesystem
fsck -y /dev/sda1

# Restore from backup
tar -xzpf /backup/system.tar.gz -C /

# Network recovery
dhclient eth0             # Get DHCP lease
ip addr add 192.168.1.10/24 dev eth0 # Set static IP
ip route add default via 192.168.1.1 # Add default route
echo "nameserver 8.8.8.8" > /etc/resolv.conf # Set DNS

# Service recovery
systemctl daemon-reload
systemctl reset-failed
systemctl restart service_name

# Clear disk space
journalctl --vacuum-size=100M
apt-get clean
apt-get autoremove
find /tmp -type f -delete
find /var/log -name "*.gz" -delete
```

---

## Command Shortcuts and Aliases

### Useful Bash Aliases

```bash
# Add to ~/.bashrc or ~/.bash_aliases

# System shortcuts
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'
alias cls='clear'
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias h='history'
alias hgrep='history | grep'

# Safety nets
alias rm='rm -i'
alias cp='cp -i'
alias mv='mv -i'
alias mkdir='mkdir -pv'

# System info
alias meminfo='free -h'
alias cpuinfo='lscpu'
alias diskinfo='df -h'
alias myip='curl ifconfig.me'
alias ports='ss -tulpn'

# Service management
alias sysctl='systemctl'
alias sysstatus='systemctl status'
alias sysrestart='systemctl restart'
alias sysstop='systemctl stop'
alias sysstart='systemctl start'

# Package management
alias update='sudo apt update'
alias upgrade='sudo apt upgrade'
alias install='sudo apt install'
alias search='apt search'
alias autoremove='sudo apt autoremove'

# Log viewing
alias syslog='sudo tail -f /var/log/syslog'
alias messages='sudo tail -f /var/log/messages'
alias auth='sudo tail -f /var/log/auth.log'
alias nginx-access='sudo tail -f /var/log/nginx/access.log'
alias nginx-error='sudo tail -f /var/log/nginx/error.log'

# Docker shortcuts (if using Docker)
alias dps='docker ps'
alias dpsa='docker ps -a'
alias di='docker images'
alias dex='docker exec -it'
alias dlog='docker logs -f'
alias dstop='docker stop $(docker ps -q)'
alias drm='docker rm $(docker ps -aq)'

# Git shortcuts
alias gs='git status'
alias ga='git add'
alias gc='git commit'
alias gp='git push'
alias gl='git log --oneline'
alias gd='git diff'

# Process management
alias psg='ps aux | grep'
alias killport='kill -9 $(lsof -t -i:$1)'
alias memhogs='ps aux --sort=-%mem | head'
alias cpuhogs='ps aux --sort=-%cpu | head'

# Network
alias listening='ss -tlnp'
alias established='ss -tan state established'
alias myports='ss -tulpn | grep LISTEN'

# Productivity
alias now='date +"%Y-%m-%d %H:%M:%S"'
alias week='date +%V'
alias path='echo -e ${PATH//:/\\n}'
alias reload='source ~/.bashrc'
```

### Useful Functions

```bash
# Add to ~/.bashrc

# Extract any archive
extract() {
    if [ -f $1 ]; then
        case $1 in
            *.tar.bz2)   tar xjf $1     ;;
            *.tar.gz)    tar xzf $1     ;;
            *.bz2)       bunzip2 $1     ;;
            *.rar)       unrar e $1     ;;
            *.gz)        gunzip $1      ;;
            *.tar)       tar xf $1      ;;
            *.tbz2)      tar xjf $1     ;;
            *.tgz)       tar xzf $1     ;;
            *.zip)       unzip $1       ;;
            *.Z)         uncompress $1  ;;
            *.7z)        7z x $1        ;;
            *)           echo "'$1' cannot be extracted" ;;
        esac
    else
        echo "'$1' is not a valid file"
    fi
}

# Create directory and cd into it
mkcd() {
    mkdir -p "$1" && cd "$1"
}

# Backup file with timestamp
backup() {
    cp "$1" "$1.backup.$(date +%Y%m%d-%H%M%S)"
}

# Find process by name
psgrep() {
    ps aux | grep -v grep | grep -i "$1"
}

# Kill process by name
pskill() {
    ps aux | grep -v grep | grep -i "$1" | awk '{print $2}' | xargs kill -9
}

# Show directory size sorted
dirsize() {
    du -sh ${1:-*} | sort -rh
}

# Quick server info
serverinfo() {
    echo "Hostname: $(hostname -f)"
    echo "IP: $(ip -4 addr | grep -oP '(?<=inet\s)\d+(\.\d+){3}' | grep -v 127.0.0.1 | head -1)"
    echo "OS: $(lsb_release -ds)"
    echo "Kernel: $(uname -r)"
    echo "Uptime:$(uptime -p)"
    echo "Load: $(uptime | awk -F'load average:' '{print $2}')"
    echo "Memory: $(free -h | awk '/^Mem:/ {print $3 " / " $2}')"
    echo "Disk: $(df -h / | awk 'NR==2 {print $3 " / " $2}')"
}

# Monitor log file with highlighting
logwatch() {
    tail -f "$1" | perl -pe 's/(ERROR|WARN|CRITICAL)/\033[31m$1\033[0m/g'
}

# Test port
testport() {
    nc -zv "$1" "$2" 2>&1
}

# Weather (requires curl)
weather() {
    curl "wttr.in/${1:-}"
}
```

---

This comprehensive command reference serves as a quick lookup guide for Ubuntu system administration, covering everything from basic operations to advanced troubleshooting and performance analysis.