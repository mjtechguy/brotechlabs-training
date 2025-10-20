# Appendix C: Troubleshooting Guide

## Common System Issues

### Boot Problems

#### System Won't Boot - Stuck at GRUB

**Symptoms:**
- System stops at GRUB menu
- GRUB rescue mode appears
- "error: no such partition" message

**Diagnosis:**
```bash
# From GRUB rescue mode
grub> ls
grub> ls (hd0,1)/
grub> set root=(hd0,1)
grub> set prefix=(hd0,1)/boot/grub
grub> insmod normal
grub> normal
```

**Solution:**
```bash
# After booting into system
sudo update-grub
sudo grub-install /dev/sda

# Rebuild GRUB configuration
sudo grub-mkconfig -o /boot/grub/grub.cfg

# If boot partition is separate
sudo mount /dev/sda1 /boot
sudo grub-install --root-directory=/boot /dev/sda
```

#### Kernel Panic on Boot

**Symptoms:**
- "Kernel panic - not syncing" message
- System freezes during boot
- Unable to mount root filesystem

**Diagnosis:**
```bash
# Boot with previous kernel from GRUB menu
# Select "Advanced options for Ubuntu"
# Choose an older kernel version

# Check kernel logs
dmesg | grep -i error
journalctl -xb -p err
```

**Solution:**
```bash
# Boot into recovery mode and fix issues
# Select root shell from recovery menu

# Check and repair filesystem
fsck -y /dev/sda1

# Rebuild initramfs
update-initramfs -u -k all

# Remove problematic kernel
apt remove linux-image-[version]
apt autoremove

# Reinstall current kernel
apt install --reinstall linux-image-generic
```

#### System Hangs at "A start job is running"

**Symptoms:**
- Boot process stuck at systemd service
- Timeout messages during boot
- Specific service failing to start

**Diagnosis:**
```bash
# Add to kernel parameters in GRUB
systemd.log_level=debug

# After boot, check failed services
systemctl list-units --failed
systemctl status [service-name]
journalctl -xe
```

**Solution:**
```bash
# Disable problematic service
systemctl disable [service-name]
systemctl mask [service-name]

# Fix systemd timeout
# Edit /etc/systemd/system.conf
DefaultTimeoutStartSec=10s
DefaultTimeoutStopSec=10s

# Reload systemd
systemctl daemon-reload
```

### Network Connectivity Issues

#### No Network Connection

**Symptoms:**
- Cannot ping external hosts
- No IP address assigned
- Network interface down

**Diagnosis:**
```bash
# Check network interfaces
ip link show
ip addr show
ip route show

# Check network service status
systemctl status systemd-networkd
systemctl status NetworkManager

# Check DNS resolution
systemd-resolve --status
cat /etc/resolv.conf

# Test connectivity
ping -c 4 127.0.0.1          # Loopback
ping -c 4 [gateway-ip]        # Gateway
ping -c 4 8.8.8.8            # Internet
nslookup google.com          # DNS
```

**Solution:**
```bash
# Bring interface up
sudo ip link set dev eth0 up

# Restart network services
sudo systemctl restart systemd-networkd
sudo systemctl restart NetworkManager

# Reconfigure netplan
sudo netplan apply

# Manual IP configuration
sudo ip addr add 192.168.1.100/24 dev eth0
sudo ip route add default via 192.168.1.1
echo "nameserver 8.8.8.8" | sudo tee /etc/resolv.conf

# Reset network configuration
sudo rm /etc/netplan/*.yaml
sudo netplan generate
sudo netplan apply
```

#### DNS Resolution Failures

**Symptoms:**
- Can ping IP addresses but not domain names
- "Temporary failure in name resolution"
- Slow DNS lookups

**Diagnosis:**
```bash
# Test DNS servers
dig @8.8.8.8 google.com
dig @1.1.1.1 google.com

# Check systemd-resolved
systemd-resolve --status
resolvectl status

# Check DNS configuration
cat /etc/resolv.conf
ls -la /etc/resolv.conf  # Check if symlink
```

**Solution:**
```bash
# Fix systemd-resolved
sudo systemctl restart systemd-resolved
sudo ln -sf /run/systemd/resolve/resolv.conf /etc/resolv.conf

# Use different DNS servers
# Edit /etc/netplan/01-netcfg.yaml
network:
  ethernets:
    eth0:
      nameservers:
        addresses: [8.8.8.8, 8.8.4.4]

sudo netplan apply

# Disable systemd-resolved and use static DNS
sudo systemctl disable systemd-resolved
sudo systemctl stop systemd-resolved
sudo rm /etc/resolv.conf
echo -e "nameserver 8.8.8.8\nnameserver 1.1.1.1" | sudo tee /etc/resolv.conf
```

#### Network Performance Issues

**Symptoms:**
- Slow network speeds
- High latency
- Packet loss

**Diagnosis:**
```bash
# Check interface statistics
ip -s link show eth0
netstat -i
ifconfig eth0

# Test bandwidth
iperf3 -c server_ip  # Client mode
iperf3 -s            # Server mode

# Check for packet loss
mtr -r google.com
ping -f -c 1000 server_ip

# Monitor network traffic
iftop -i eth0
nethogs
tcpdump -i eth0 -n
```

**Solution:**
```bash
# Optimize network settings
# Edit /etc/sysctl.conf
net.core.rmem_max = 134217728
net.core.wmem_max = 134217728
net.ipv4.tcp_rmem = 4096 87380 134217728
net.ipv4.tcp_wmem = 4096 65536 134217728
net.core.netdev_max_backlog = 5000
net.ipv4.tcp_congestion_control = bbr

sudo sysctl -p

# Check and replace network cable
# Update network drivers
sudo apt update
sudo apt install linux-modules-extra-$(uname -r)

# Disable offloading features if causing issues
sudo ethtool -K eth0 tso off gso off gro off
```

### Disk and Filesystem Issues

#### Disk Full Errors

**Symptoms:**
- "No space left on device" errors
- Cannot create new files
- Services failing due to lack of space

**Diagnosis:**
```bash
# Check disk usage
df -h
df -i  # Check inode usage

# Find large files
find / -type f -size +100M -exec ls -lh {} \; 2>/dev/null
du -h / 2>/dev/null | sort -rh | head -20

# Find large directories
ncdu /
du -sh /* 2>/dev/null | sort -rh

# Check for deleted files still open
lsof | grep deleted
```

**Solution:**
```bash
# Clean package cache
sudo apt clean
sudo apt autoremove

# Clean journal logs
sudo journalctl --vacuum-time=7d
sudo journalctl --vacuum-size=100M

# Clean temporary files
sudo rm -rf /tmp/*
sudo rm -rf /var/tmp/*

# Find and remove old logs
find /var/log -name "*.log.*.gz" -mtime +30 -delete
find /var/log -name "*.log.*" -mtime +30 -delete

# Truncate large log files
truncate -s 0 /var/log/large-file.log

# Clean Docker if installed
docker system prune -a
docker volume prune

# Increase disk space
# Extend LVM volume
sudo lvextend -L +10G /dev/mapper/ubuntu--vg-root
sudo resize2fs /dev/mapper/ubuntu--vg-root
```

#### Filesystem Corruption

**Symptoms:**
- Read-only filesystem
- Input/output errors
- Files disappearing or corrupted

**Diagnosis:**
```bash
# Check filesystem status
mount | grep " / "
dmesg | grep -i error
smartctl -a /dev/sda

# Check for filesystem errors
sudo touch /test-file  # Test if read-only
```

**Solution:**
```bash
# Remount filesystem read-write
sudo mount -o remount,rw /

# Force filesystem check on next boot
sudo touch /forcefsck

# Boot into recovery mode and run fsck
# From recovery menu, select "fsck"
# Or from root shell:
fsck -y /dev/sda1

# For ext4 filesystem
e2fsck -f -y /dev/sda1

# For XFS filesystem
xfs_repair /dev/sda1

# If severe corruption, boot from live USB
# Mount and backup data first
mount /dev/sda1 /mnt
rsync -av /mnt/ /backup/
umount /mnt
fsck -y /dev/sda1
```

#### Slow Disk Performance

**Symptoms:**
- High I/O wait times
- Slow file operations
- System laggy during disk operations

**Diagnosis:**
```bash
# Check I/O statistics
iostat -x 1
iotop -o
dstat -d

# Check disk health
smartctl -H /dev/sda
smartctl -a /dev/sda | grep -E "Reallocated|Pending|Uncorrectable"

# Test disk speed
hdparm -tT /dev/sda
dd if=/dev/zero of=/tmp/test bs=1M count=1024 conv=fdatasync
```

**Solution:**
```bash
# Optimize mount options
# Edit /etc/fstab
/dev/sda1 / ext4 defaults,noatime,nodiratime 0 1

# Optimize I/O scheduler
echo noop | sudo tee /sys/block/sda/queue/scheduler
echo 256 | sudo tee /sys/block/sda/queue/nr_requests

# Enable write caching
hdparm -W1 /dev/sda

# Optimize filesystem
# For ext4
tune2fs -o journal_data_writeback /dev/sda1
tune2fs -O ^has_journal /dev/sda1  # Disable journal (risky)

# Defragment ext4
e4defrag /dev/sda1

# Check and fix bad blocks
badblocks -sv /dev/sda
e2fsck -c /dev/sda1
```

### Service and Process Issues

#### Service Won't Start

**Symptoms:**
- Service fails to start
- Systemd unit in failed state
- Timeout during service start

**Diagnosis:**
```bash
# Check service status
systemctl status service-name
systemctl show service-name

# Check logs
journalctl -u service-name -e
journalctl -u service-name --since "10 minutes ago"
tail -f /var/log/service-name.log

# Verify configuration
systemctl cat service-name
nginx -t  # For nginx
apache2ctl configtest  # For Apache
```

**Solution:**
```bash
# Reset failed state
systemctl reset-failed service-name

# Reload systemd and restart
systemctl daemon-reload
systemctl restart service-name

# Check dependencies
systemctl list-dependencies service-name

# Fix permission issues
chown -R service-user:service-group /path/to/service/files
chmod 755 /path/to/service/binary

# Increase timeout
# Edit service file
systemctl edit service-name

[Service]
TimeoutStartSec=300
TimeoutStopSec=300

# Debug mode
# Add to service file
[Service]
Environment="DEBUG=1"
StandardOutput=journal+console
StandardError=journal+console
```

#### High CPU Usage

**Symptoms:**
- System slow and unresponsive
- Load average very high
- Specific process consuming CPU

**Diagnosis:**
```bash
# Identify high CPU processes
top -b -n 1 | head -20
htop
ps aux --sort=-%cpu | head

# Check system load
uptime
cat /proc/loadavg

# Monitor specific process
pidstat -p PID 1
strace -p PID -c
perf top -p PID
```

**Solution:**
```bash
# Limit process CPU usage
cpulimit -p PID -l 50  # Limit to 50%
nice -n 19 command     # Run with low priority
renice 19 PID         # Change priority of running process

# Kill runaway process
kill -15 PID          # Graceful termination
kill -9 PID           # Force kill

# Investigate and fix
# Check for infinite loops in scripts
# Review application logs
# Update software to latest version
# Optimize database queries
# Add indexes if database-related

# System-wide CPU management
# Set CPU governor
cpupower frequency-set -g powersave
```

#### Memory Leaks / High Memory Usage

**Symptoms:**
- Out of memory errors
- System using swap heavily
- Specific process growing in memory

**Diagnosis:**
```bash
# Check memory usage
free -h
vmstat 1
cat /proc/meminfo

# Identify memory hogs
ps aux --sort=-%mem | head
smem -tk
pmap -x PID

# Monitor memory growth
watch -n 1 'ps aux | grep process-name'

# Check for memory leaks
valgrind --leak-check=full program
```

**Solution:**
```bash
# Clear caches
sync && echo 3 | sudo tee /proc/sys/vm/drop_caches

# Kill memory-intensive process
kill -15 PID

# Limit process memory
# Edit /etc/security/limits.conf
username hard as 2097152  # 2GB limit

# Use systemd to limit memory
systemctl edit service-name

[Service]
MemoryLimit=2G
MemoryMax=2G

# Optimize application
# Fix memory leaks in code
# Implement proper garbage collection
# Use memory profiling tools

# Add swap if needed
sudo fallocate -l 4G /swapfile
sudo chmod 600 /swapfile
sudo mkswap /swapfile
sudo swapon /swapfile

# Adjust swappiness
echo 10 | sudo tee /proc/sys/vm/swappiness
```

### Package Management Issues

#### Broken Dependencies

**Symptoms:**
- "Unable to correct problems, you have held broken packages"
- "Unmet dependencies" errors
- Package installation fails

**Diagnosis:**
```bash
# Check package status
dpkg -l | grep -v "^ii"
apt list --upgradable
dpkg --audit

# Check for held packages
apt-mark showhold
dpkg --get-selections | grep hold
```

**Solution:**
```bash
# Fix broken packages
sudo apt --fix-broken install
sudo dpkg --configure -a

# Force package configuration
sudo apt install -f

# Clear package cache and retry
sudo apt clean
sudo apt update

# Remove problematic package
sudo dpkg --remove --force-remove-reinstreq package-name
sudo apt purge package-name

# Manually resolve dependencies
sudo apt install dependency-package
sudo apt satisfy "package-name"

# Reset package database
sudo rm /var/lib/apt/lists/*
sudo apt update

# Use aptitude for complex resolution
sudo aptitude install package-name
```

#### GPG/Repository Key Errors

**Symptoms:**
- "GPG error" when updating
- "NO_PUBKEY" errors
- "Repository is not signed" warnings

**Diagnosis:**
```bash
# Check current keys
apt-key list
gpg --list-keys

# Identify missing key
# Look for key ID in error message
```

**Solution:**
```bash
# Add missing key
sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys KEY_ID

# Alternative keyservers
sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys KEY_ID
sudo apt-key adv --keyserver pgp.mit.edu --recv-keys KEY_ID

# Update from package
sudo apt install ubuntu-keyring
sudo apt update

# For specific repositories
# Docker example
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -

# Modern method (apt 2.4+)
wget -qO- https://example.com/key.asc | sudo tee /usr/share/keyrings/example.asc
```

#### Stuck dpkg Lock

**Symptoms:**
- "Could not get lock /var/lib/dpkg/lock-frontend"
- "Unable to acquire the dpkg frontend lock"
- "Another process is using apt"

**Diagnosis:**
```bash
# Check for running apt processes
ps aux | grep -E "apt|dpkg|unattended"
lsof /var/lib/dpkg/lock-frontend
fuser -v /var/lib/dpkg/lock
```

**Solution:**
```bash
# Wait for process to complete
# Check if unattended-upgrades is running
tail -f /var/log/unattended-upgrades/unattended-upgrades.log

# If safe to interrupt
sudo killall apt apt-get
sudo kill -9 PID

# Remove lock files
sudo rm /var/lib/apt/lists/lock
sudo rm /var/cache/apt/archives/lock
sudo rm /var/lib/dpkg/lock-frontend
sudo rm /var/lib/dpkg/lock

# Reconfigure dpkg
sudo dpkg --configure -a
sudo apt update
```

## Performance Troubleshooting

### System Performance Analysis

#### Identifying Bottlenecks

```bash
# Overall system performance
vmstat 1 10
dstat -tcdnmlpsy
sar -A

# CPU bottleneck indicators
- High %usr or %sys in top/vmstat
- Load average > number of CPUs
- High context switches (cs in vmstat)

# Memory bottleneck indicators
- High swap usage (si/so in vmstat)
- Low free memory with high cache/buffer
- OOM killer messages in dmesg

# Disk I/O bottleneck indicators
- High %iowait in top/iostat
- High await times in iostat -x
- High disk utilization % in iostat

# Network bottleneck indicators
- Packet drops in netstat -i
- High retransmission rates
- Interface errors in ip -s link
```

#### Performance Data Collection

```bash
#!/bin/bash
# performance-collect.sh - Collect performance data

# Create output directory
OUTPUT_DIR="/tmp/perf-$(date +%Y%m%d-%H%M%S)"
mkdir -p $OUTPUT_DIR

# System information
uname -a > $OUTPUT_DIR/uname.txt
lscpu > $OUTPUT_DIR/cpu.txt
free -h > $OUTPUT_DIR/memory.txt
df -h > $OUTPUT_DIR/disk.txt

# Performance snapshots
top -b -n 3 > $OUTPUT_DIR/top.txt
vmstat 1 10 > $OUTPUT_DIR/vmstat.txt
iostat -x 1 10 > $OUTPUT_DIR/iostat.txt
mpstat -P ALL 1 10 > $OUTPUT_DIR/mpstat.txt
pidstat 1 10 > $OUTPUT_DIR/pidstat.txt

# Network statistics
ss -s > $OUTPUT_DIR/sockets.txt
netstat -s > $OUTPUT_DIR/netstat.txt
ip -s link > $OUTPUT_DIR/interfaces.txt

# Process information
ps auxf > $OUTPUT_DIR/processes.txt
lsof > $OUTPUT_DIR/openfiles.txt

# System logs
dmesg > $OUTPUT_DIR/dmesg.txt
journalctl --since "1 hour ago" > $OUTPUT_DIR/journal.txt

# Create archive
tar -czf performance-data.tar.gz -C /tmp $(basename $OUTPUT_DIR)
echo "Performance data collected in: performance-data.tar.gz"
```

### Database Performance Issues

#### MySQL Performance Troubleshooting

```bash
# Check slow queries
mysql -e "SHOW VARIABLES LIKE 'slow_query%';"
tail -f /var/log/mysql/slow.log

# Analyze query performance
mysql -e "SHOW PROCESSLIST;"
mysql -e "SHOW FULL PROCESSLIST;"

# Check table locks
mysql -e "SHOW OPEN TABLES WHERE In_use > 0;"
mysql -e "SHOW ENGINE INNODB STATUS\G"

# Performance metrics
mysql -e "SHOW GLOBAL STATUS LIKE 'Threads%';"
mysql -e "SHOW GLOBAL STATUS LIKE 'Innodb_buffer_pool%';"
mysql -e "SHOW GLOBAL STATUS LIKE 'Created_tmp%';"

# Optimize tables
mysqlcheck -o --all-databases
mysql -e "ANALYZE TABLE database.table;"
mysql -e "OPTIMIZE TABLE database.table;"

# Tune MySQL settings
# Edit /etc/mysql/mysql.conf.d/mysqld.cnf
innodb_buffer_pool_size = 70% of RAM
innodb_log_file_size = 256M
innodb_flush_method = O_DIRECT
innodb_file_per_table = 1

# Monitor with MySQLTuner
perl mysqltuner.pl
```

#### PostgreSQL Performance Troubleshooting

```bash
# Check slow queries
psql -c "SELECT * FROM pg_stat_statements ORDER BY total_time DESC LIMIT 10;"

# Active queries
psql -c "SELECT pid, now() - pg_stat_activity.query_start AS duration, query
         FROM pg_stat_activity
         WHERE (now() - pg_stat_activity.query_start) > interval '5 minutes';"

# Kill long-running query
psql -c "SELECT pg_cancel_backend(PID);"
psql -c "SELECT pg_terminate_backend(PID);"

# Check locks
psql -c "SELECT * FROM pg_locks WHERE granted = false;"

# Vacuum and analyze
vacuumdb -z -v database_name
psql -c "VACUUM ANALYZE;"

# Reindex
reindexdb -d database_name
psql -c "REINDEX DATABASE database_name;"

# Check configuration
psql -c "SHOW shared_buffers;"
psql -c "SHOW effective_cache_size;"
psql -c "SHOW work_mem;"

# Monitor with pg_stat tools
psql -c "SELECT * FROM pg_stat_database;"
psql -c "SELECT * FROM pg_stat_user_tables;"
```

## Error Message Reference

### Common System Error Messages

#### "Cannot allocate memory"
```bash
# Check available memory
free -h
cat /proc/meminfo

# Solutions:
- Add swap space
- Increase ulimits
- Kill memory-intensive processes
- Increase system RAM
```

#### "Too many open files"
```bash
# Check current limits
ulimit -n
cat /proc/PID/limits

# Solutions:
# System-wide
echo "fs.file-max = 100000" >> /etc/sysctl.conf
sysctl -p

# Per-user
# Edit /etc/security/limits.conf
* soft nofile 65536
* hard nofile 65536
```

#### "Permission denied"
```bash
# Check permissions
ls -la file_or_directory
namei -l /full/path/to/file

# Check SELinux/AppArmor
sestatus  # For SELinux
aa-status # For AppArmor

# Solutions:
chmod appropriate_permissions file
chown user:group file
setfacl -m u:user:rwx file  # ACL
```

#### "Connection refused"
```bash
# Check if service is running
systemctl status service
ss -tlnp | grep port

# Check firewall
ufw status
iptables -L -n

# Solutions:
- Start the service
- Open firewall port
- Check binding address (localhost vs 0.0.0.0)
- Verify correct port number
```

#### "Name or service not known"
```bash
# DNS resolution issue
nslookup hostname
dig hostname
host hostname

# Solutions:
- Check /etc/resolv.conf
- Verify DNS servers are reachable
- Check /etc/hosts file
- Flush DNS cache
```

### Application-Specific Errors

#### Web Server Errors

**502 Bad Gateway**
```bash
# Check upstream service
systemctl status php7.4-fpm  # For PHP-FPM
systemctl status application  # For proxied apps

# Check logs
tail -f /var/log/nginx/error.log
tail -f /var/log/apache2/error.log

# Solutions:
- Restart upstream service
- Increase proxy timeouts
- Check upstream service logs
- Verify proxy_pass configuration
```

**503 Service Unavailable**
```bash
# Check server resources
free -h
df -h
ps aux --sort=-%cpu | head

# Check connection limits
ss -s
netstat -ant | grep -c ESTABLISHED

# Solutions:
- Increase worker processes/connections
- Implement rate limiting
- Add more backend servers
- Enable caching
```

**504 Gateway Timeout**
```bash
# Increase timeout values
# Nginx:
proxy_read_timeout 300;
proxy_connect_timeout 300;
proxy_send_timeout 300;

# Apache:
ProxyTimeout 300
```

## Recovery Procedures

### System Recovery

#### Boot into Recovery Mode

```bash
# At GRUB menu:
1. Select "Advanced options for Ubuntu"
2. Select recovery mode kernel
3. Choose from recovery menu:
   - fsck - Check all file systems
   - network - Enable networking
   - root - Drop to root shell
   - dpkg - Repair broken packages
```

#### Emergency Root Access

```bash
# Method 1: Single User Mode
# Add to kernel parameters in GRUB:
init=/bin/bash

# After boot:
mount -o remount,rw /
passwd  # Reset root password

# Method 2: Recovery Mode
# Select "root" from recovery menu
mount -o remount,rw /
```

#### Restore from Backup

```bash
#!/bin/bash
# restore.sh - System restore script

BACKUP_FILE="/backup/system-backup.tar.gz"
RESTORE_POINT="/"

# Boot from live USB if restoring root
# Mount root partition
mount /dev/sda1 /mnt

# Restore files
tar -xzpf $BACKUP_FILE -C /mnt

# Restore MySQL databases
gunzip < backup_mysql.sql.gz | mysql

# Restore PostgreSQL
pg_restore -d database backup.dump

# Fix permissions
chown -R www-data:www-data /var/www
chmod 755 /var/www

# Update GRUB if needed
grub-install /dev/sda
update-grub

# Reboot
reboot
```

### Data Recovery

#### Recover Deleted Files

```bash
# Stop using the disk immediately!

# Use extundelete for ext3/ext4
sudo apt install extundelete
sudo extundelete /dev/sda1 --restore-all

# Use testdisk for various filesystems
sudo apt install testdisk
sudo testdisk /dev/sda

# Use photorec for media files
sudo photorec /dev/sda

# Grep through raw disk for text
sudo grep -a -B100 -A100 'search string' /dev/sda > recovered.txt
```

#### Repair Corrupted Database

```bash
# MySQL repair
mysqlcheck --repair --all-databases
mysql -e "REPAIR TABLE database.table;"

# Force InnoDB recovery
# Add to my.cnf:
innodb_force_recovery = 1
# Levels 1-6, start with 1

# PostgreSQL repair
postgres --single -D /var/lib/postgresql/14/main database_name
REINDEX DATABASE database_name;
VACUUM FULL;

# Export and reimport if severe
mysqldump database > backup.sql
mysql database < backup.sql
```

### Emergency Procedures

#### Out of Disk Space - Can't Login

```bash
# Boot from live USB
mount /dev/sda1 /mnt

# Clean up space
rm -rf /mnt/var/log/*.log.*
rm -rf /mnt/tmp/*
rm -rf /mnt/var/cache/apt/archives/*.deb

# Truncate large files
truncate -s 0 /mnt/var/log/syslog

# If using LVM, extend volume
lvextend -L +5G /dev/vg/root
resize2fs /dev/vg/root
```

#### Network Emergency Access

```bash
# Console access via serial/KVM
# Configure serial console
# Edit /etc/default/grub
GRUB_CMDLINE_LINUX="console=tty0 console=ttyS0,115200"
update-grub

# Emergency network configuration
# Create minimal network config
cat > /etc/netplan/emergency.yaml << EOF
network:
  version: 2
  ethernets:
    eth0:
      dhcp4: yes
EOF

netplan apply

# Or use ip commands
ip link set eth0 up
ip addr add 192.168.1.100/24 dev eth0
ip route add default via 192.168.1.1
```

#### Security Breach Recovery

```bash
#!/bin/bash
# security-incident-response.sh

# 1. Isolate system
iptables -P INPUT DROP
iptables -P OUTPUT DROP
iptables -A OUTPUT -p tcp --dport 22 -j ACCEPT  # Keep SSH

# 2. Preserve evidence
dd if=/dev/sda of=/external/disk.img bs=4M
tar -czf /external/logs.tar.gz /var/log

# 3. Check for compromises
find / -mtime -7 -type f  # Recently modified files
find / -perm -4000 2>/dev/null  # SUID files
last -100  # Login history
ps auxf  # Running processes
netstat -tulpn  # Network connections

# 4. Check for rootkits
apt install rkhunter chkrootkit
rkhunter --check
chkrootkit

# 5. Reset all passwords
passwd root
for user in $(ls /home); do passwd $user; done

# 6. Review and restore
# Check all configuration files
# Restore from known good backup
# Patch vulnerabilities
# Monitor closely
```

## Quick Reference Decision Tree

### System Won't Start?
```
Is GRUB loading?
├─ No → Reinstall GRUB from live USB
└─ Yes → Can you boot to recovery mode?
    ├─ No → Boot live USB, check filesystem
    └─ Yes → Is it a service issue?
        ├─ Yes → Disable problematic service
        └─ No → Check kernel/initramfs issues
```

### Network Not Working?
```
Can you ping localhost?
├─ No → Network stack issue, check kernel modules
└─ Yes → Can you ping gateway?
    ├─ No → Check IP configuration and routes
    └─ Yes → Can you ping 8.8.8.8?
        ├─ No → Gateway/firewall issue
        └─ Yes → Can you ping google.com?
            ├─ No → DNS issue
            └─ Yes → Application-specific issue
```

### Service Won't Start?
```
Does systemctl status show errors?
├─ No → Check if actually running (ps aux)
└─ Yes → Are there dependency failures?
    ├─ Yes → Fix dependent services first
    └─ No → Check logs for specific errors
        ├─ Permission denied → Fix ownership/permissions
        ├─ Port in use → Find conflicting service
        ├─ Configuration error → Validate config file
        └─ Missing files → Reinstall or restore
```

### Performance Issue?
```
Is CPU usage high?
├─ Yes → Identify process (top), optimize or limit
└─ No → Is memory usage high?
    ├─ Yes → Check for leaks, add swap
    └─ No → Is I/O wait high?
        ├─ Yes → Check disk health, optimize I/O
        └─ No → Check network latency/bandwidth
```

---

This comprehensive troubleshooting guide provides systematic approaches to diagnosing and resolving common Ubuntu server issues, complete with commands, solutions, and recovery procedures.