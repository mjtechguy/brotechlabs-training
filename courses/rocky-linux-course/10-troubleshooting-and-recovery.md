# Part 10: Troubleshooting and Recovery

## Prerequisites and Learning Resources

Before starting this section, you should have completed:
- Part 1: Getting Started with Rocky Linux
- Part 2: Core System Administration (especially systemd and SELinux)
- Part 3: Storage and Filesystems
- Part 4: Networking and Security
- Part 7: Monitoring and Performance

**Helpful Resources:**
- Rocky Linux Troubleshooting Guide: https://docs.rockylinux.org/guides/troubleshooting/
- Red Hat Troubleshooting Guide: https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/9/
- SystemD Debugging: https://www.freedesktop.org/wiki/Software/systemd/Debugging/
- SELinux Troubleshooting: https://wiki.centos.org/HowTos/SELinux
- Rocky Linux Forums: https://forums.rockylinux.org/

---

## Chapter 22: Troubleshooting Methodology

### Introduction

Troubleshooting is like being a detective - you gather clues, form hypotheses, test them, and solve the mystery. The key is having a systematic approach rather than randomly trying things and hoping they work.

### The Rocky Linux Troubleshooting Approach

Think of troubleshooting like diagnosing a car problem:
- **Listen to the symptoms** (What's the user experiencing?)
- **Check the dashboard** (Review logs and monitoring)
- **Look under the hood** (Examine system state)
- **Test components** (Isolate the problem)
- **Apply the fix** (Implement solution)
- **Test drive** (Verify the fix works)
- **Document** (Record what happened for next time)

```bash
# The troubleshooter's first commands
systemctl status
journalctl -xe
dmesg | tail -20
df -h
free -h
top
```

### Understanding the Problem

Before diving into logs, understand what's actually wrong.

```bash
# Create a troubleshooting checklist
cat > /tmp/troubleshoot.txt << 'EOF'
TROUBLESHOOTING CHECKLIST
========================
1. What is the expected behavior?
2. What is the actual behavior?
3. When did it last work correctly?
4. What changed since then?
5. Can the problem be reproduced?
6. What is the business impact?
7. Are there any error messages?
8. Is this affecting all users or just some?
EOF

# Gather system information
cat > /usr/local/bin/sysinfo.sh << 'EOF'
#!/bin/bash
echo "=== System Information ==="
echo "Hostname: $(hostname -f)"
echo "Kernel: $(uname -r)"
echo "Rocky Version: $(cat /etc/rocky-release)"
echo "Uptime: $(uptime)"
echo ""
echo "=== Resource Usage ==="
df -h | grep -v tmpfs
free -h
echo ""
echo "=== Network ==="
ip a show | grep inet
ss -tlnp 2>/dev/null | head -10
echo ""
echo "=== Recent Issues ==="
journalctl -p err -n 10 --no-pager
EOF

chmod +x /usr/local/bin/sysinfo.sh
```

### Log Analysis with Journalctl

Logs are like breadcrumbs - they show you where the system has been and what went wrong.

```bash
# View all logs since boot
journalctl -b

# View logs with priority (0=emerg to 7=debug)
journalctl -p err  # Errors and above
journalctl -p warning  # Warnings and above

# View logs for specific service
journalctl -u sshd
journalctl -u nginx --since "1 hour ago"

# Follow logs in real-time
journalctl -f

# View kernel messages
journalctl -k

# Search for specific patterns
journalctl | grep -i "error\|failed\|critical"

# View logs between timestamps
journalctl --since "2024-01-01 10:00:00" --until "2024-01-01 11:00:00"

# Export logs for analysis
journalctl --since today > /tmp/today_logs.txt

# View boot messages
journalctl -b -1  # Previous boot
journalctl --list-boots  # List all boots
```

**Advanced Log Analysis:**

```bash
# Find what's filling up logs
journalctl --disk-usage

# Identify noisy services
journalctl -n 100000 | awk '{print $5}' | sort | uniq -c | sort -rn | head

# Track specific process
journalctl _PID=1234

# View SELinux denials
journalctl _AUDIT_TYPE=1400

# Custom output format
journalctl -o json-pretty | jq '.MESSAGE'

# Persistent journal configuration
sudo mkdir -p /var/log/journal
sudo systemctl restart systemd-journald
```

### Traditional Log Files

Some services still use traditional log files - knowing where to look is crucial.

```bash
# Important log locations
/var/log/messages     # General system messages
/var/log/secure       # Authentication logs
/var/log/cron         # Cron job logs
/var/log/maillog      # Mail server logs
/var/log/httpd/       # Apache logs
/var/log/nginx/       # Nginx logs
/var/log/audit/       # SELinux audit logs

# Useful log analysis commands
# Find errors in all logs
grep -r "error" /var/log/ 2>/dev/null

# Watch log file in real-time
tail -f /var/log/messages

# View compressed logs
zcat /var/log/messages-20240101.gz

# Count occurrences
grep "Failed password" /var/log/secure | wc -l

# Extract time ranges
sed -n '/Dec 25 10:00/,/Dec 25 11:00/p' /var/log/messages
```

### Network Debugging Tools

Network problems are common - having the right tools makes diagnosis easier.

```bash
# Basic connectivity test
ping -c 4 google.com

# Trace route to destination
traceroute google.com
tracepath google.com  # No root required

# DNS troubleshooting
nslookup google.com
dig google.com
dig +trace google.com  # Full DNS resolution path
host google.com

# Port connectivity
telnet example.com 80
nc -zv example.com 80

# View network connections
ss -tulnp  # TCP/UDP listening ports
ss -ant    # All TCP connections
netstat -tulnp  # Legacy command

# Packet capture
sudo tcpdump -i eth0 -n port 80
sudo tcpdump -i any -w /tmp/capture.pcap

# Network interface statistics
ip -s link show
ifconfig -a  # Legacy
ethtool eth0  # Hardware info

# Firewall debugging
sudo firewall-cmd --list-all
sudo iptables -L -n -v
sudo nft list ruleset  # For nftables
```

**Advanced Network Troubleshooting:**

```bash
# MTU issues
ping -M do -s 1472 google.com

# ARP problems
arp -n
ip neigh show

# Routing issues
ip route show
route -n  # Legacy

# Connection tracking
sudo conntrack -L

# Network namespace debugging
ip netns list
ip netns exec <namespace> ip a

# Performance testing
iperf3 -s  # Server mode
iperf3 -c server_ip  # Client mode
```

### SELinux Troubleshooting

SELinux issues are like locked doors - you need to find the right key.

```bash
# Check SELinux status
getenforce
sestatus

# View recent denials
sudo ausearch -m AVC -ts recent

# Analyze audit log
sudo sealert -a /var/log/audit/audit.log

# Common SELinux fixes
# Wrong context
ls -Z /path/to/file
sudo restorecon -Rv /path/to/directory

# Find correct context
sudo semanage fcontext -l | grep httpd

# Port issues
sudo semanage port -l | grep http
sudo semanage port -a -t http_port_t -p tcp 8080

# Boolean settings
getsebool -a | grep httpd
sudo setsebool -P httpd_can_network_connect on

# Generate policy from denials
sudo audit2allow -M mymodule < /tmp/audit.log
sudo semodule -i mymodule.pp

# Temporarily disable (for testing ONLY)
sudo setenforce 0
# Remember to re-enable!
sudo setenforce 1
```

### Performance Issue Diagnosis

Performance problems are like traffic jams - you need to find the bottleneck.

```bash
# Real-time system monitoring
top
htop
atop

# CPU issues
mpstat 1  # Per-CPU statistics
sar -u 1 10  # CPU usage history
ps aux --sort=-%cpu | head

# Memory issues
free -h
vmstat 1
slabtop
ps aux --sort=-%mem | head

# Disk I/O issues
iostat -x 1
iotop
df -h
du -sh /* | sort -h

# Process investigation
strace -p PID
lsof -p PID
pmap PID

# System call summary
strace -c -p PID

# Check for zombies
ps aux | grep defunct
```

**Creating a Performance Baseline:**

```bash
#!/bin/bash
# performance_baseline.sh
LOG_DIR="/var/log/performance"
mkdir -p $LOG_DIR

while true; do
    DATE=$(date '+%Y%m%d_%H%M%S')

    # CPU baseline
    mpstat 1 1 > $LOG_DIR/cpu_$DATE.log

    # Memory baseline
    free -m > $LOG_DIR/mem_$DATE.log

    # Disk baseline
    iostat -x 1 1 > $LOG_DIR/disk_$DATE.log

    # Network baseline
    ss -s > $LOG_DIR/net_$DATE.log

    sleep 300  # Every 5 minutes
done
```

### Application Debugging

Application issues require specific investigation techniques.

```bash
# Check if application is running
systemctl status myapp
ps aux | grep myapp
pgrep -f myapp

# View application logs
journalctl -u myapp -n 100
tail -f /var/log/myapp/app.log

# Check ports
sudo lsof -i :8080
sudo ss -tlnp | grep 8080

# Trace system calls
sudo strace -f -p $(pgrep myapp)

# Check file handles
ls -l /proc/$(pgrep myapp)/fd/

# Memory usage
pmap $(pgrep myapp)
cat /proc/$(pgrep myapp)/status | grep -i vm

# Environment variables
cat /proc/$(pgrep myapp)/environ | tr '\0' '\n'

# Check limits
cat /proc/$(pgrep myapp)/limits
```

### Common Issues and Solutions

Here's a troubleshooting matrix for common problems:

```bash
# Create a quick reference
cat > /usr/local/bin/quickfix.sh << 'EOF'
#!/bin/bash

case "$1" in
    "disk-full")
        echo "=== Disk Full Solutions ==="
        echo "1. Check disk usage: df -h"
        echo "2. Find large files: find / -size +100M -type f 2>/dev/null"
        echo "3. Clean package cache: dnf clean all"
        echo "4. Check logs: du -sh /var/log/*"
        echo "5. Remove old kernels: package-cleanup --oldkernels --count=2"
        ;;

    "no-network")
        echo "=== No Network Solutions ==="
        echo "1. Check interface: ip link show"
        echo "2. Restart NetworkManager: systemctl restart NetworkManager"
        echo "3. Check DNS: cat /etc/resolv.conf"
        echo "4. Check routes: ip route show"
        echo "5. Check firewall: firewall-cmd --list-all"
        ;;

    "high-load")
        echo "=== High Load Solutions ==="
        echo "1. Check top processes: top"
        echo "2. Check I/O: iotop"
        echo "3. Check CPU: mpstat 1"
        echo "4. Check memory: free -h"
        echo "5. Check swapping: vmstat 1"
        ;;

    "service-failed")
        echo "=== Service Failed Solutions ==="
        echo "1. Check status: systemctl status SERVICE"
        echo "2. View logs: journalctl -u SERVICE -n 50"
        echo "3. Check config: systemctl cat SERVICE"
        echo "4. Reset failed: systemctl reset-failed SERVICE"
        echo "5. Check dependencies: systemctl list-dependencies SERVICE"
        ;;

    *)
        echo "Usage: $0 {disk-full|no-network|high-load|service-failed}"
        ;;
esac
EOF

chmod +x /usr/local/bin/quickfix.sh
```

### Rocky Linux Community Support Resources

When you're stuck, the community can help.

```bash
# Gather information for support request
cat > /tmp/support-info.sh << 'EOF'
#!/bin/bash
echo "=== Rocky Linux Support Information ==="
echo "Date: $(date)"
echo ""
echo "=== System Info ==="
cat /etc/rocky-release
uname -a
echo ""
echo "=== Problem Description ==="
echo "[Describe your issue here]"
echo ""
echo "=== Recent Errors ==="
journalctl -p err -n 20 --no-pager
echo ""
echo "=== System Status ==="
systemctl --failed
df -h
free -h
echo ""
echo "=== Network ==="
ip a | grep inet
echo ""
echo "=== SELinux ==="
getenforce
ausearch -m AVC -ts recent | head -10
EOF

chmod +x /tmp/support-info.sh

# Resources
echo "Rocky Linux Support Resources:
1. Documentation: https://docs.rockylinux.org/
2. Forums: https://forums.rockylinux.org/
3. Chat: https://chat.rockylinux.org/
4. Bug Tracker: https://bugs.rockylinux.org/
5. Reddit: https://www.reddit.com/r/RockyLinux/
6. Mailing Lists: https://lists.resf.org/
"
```

### Creating a Troubleshooting Toolkit

Build your own toolkit for common issues:

```bash
# Create troubleshooting script collection
mkdir -p /usr/local/troubleshoot

# Network test script
cat > /usr/local/troubleshoot/nettest.sh << 'EOF'
#!/bin/bash
echo "=== Network Connectivity Test ==="
interfaces=$(ip -o link show | awk -F': ' '{print $2}')

for iface in $interfaces; do
    if [[ "$iface" != "lo" ]]; then
        echo "Interface: $iface"
        ip addr show $iface | grep inet
        echo ""
    fi
done

echo "=== DNS Resolution ==="
for host in google.com cloudflare.com rocky.linux; do
    echo -n "$host: "
    if host $host > /dev/null 2>&1; then
        echo "OK"
    else
        echo "FAILED"
    fi
done

echo ""
echo "=== Gateway Connectivity ==="
gateway=$(ip route | grep default | awk '{print $3}')
if [ ! -z "$gateway" ]; then
    ping -c 2 $gateway
else
    echo "No default gateway found!"
fi
EOF

chmod +x /usr/local/troubleshoot/nettest.sh
```

### Practical Exercise: Troubleshooting Scenarios

Let's practice with common scenarios:

```bash
# Scenario 1: Service Won't Start
# Simulate a problem
sudo mkdir -p /etc/myapp
echo "invalid config" | sudo tee /etc/myapp/config.conf

# Create a failing service
sudo tee /etc/systemd/system/failapp.service << 'EOF'
[Unit]
Description=Failing Application

[Service]
Type=simple
ExecStart=/usr/bin/python3 /nonexistent/app.py
Restart=always

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
sudo systemctl start failapp

# Now troubleshoot:
systemctl status failapp
journalctl -u failapp -n 20
systemctl cat failapp
# Fix: correct the ExecStart path

# Scenario 2: Disk Space Issues
# Create large file (be careful!)
dd if=/dev/zero of=/tmp/bigfile bs=1M count=100

# Find what's using space
du -sh /* 2>/dev/null | sort -h
find / -size +50M -type f 2>/dev/null
df -i  # Check inodes too!

# Cleanup
rm /tmp/bigfile
```

### Review Questions

1. What's the first step in the troubleshooting methodology?
2. How do you view only error messages in journalctl?
3. What command shows SELinux denials?
4. How do you trace system calls of a running process?
5. What's the difference between tcpdump and ss?
6. How do you find which process is using a specific port?
7. What command helps analyze audit logs?

### Practical Lab

Practice troubleshooting:
1. Create a service that fails to start and diagnose why
2. Simulate high CPU usage and identify the cause
3. Create a network connectivity issue and resolve it
4. Generate SELinux denials and create a policy to fix them
5. Fill up disk space and safely clean it
6. Debug a performance issue using various tools
7. Document your troubleshooting process

---

## Chapter 23: System Recovery

### Introduction

System recovery is like having insurance - you hope you'll never need it, but when disaster strikes, you'll be grateful it's there. Rocky Linux provides multiple recovery methods for different failure scenarios.

### Boot Issues and GRUB2 Recovery

When your system won't boot, it's like your car won't start - you need to diagnose whether it's the battery (GRUB), the engine (kernel), or something else.

```bash
# Understanding GRUB2 configuration
/boot/grub2/grub.cfg         # Main config (don't edit directly!)
/etc/default/grub            # User configuration
/etc/grub.d/                 # Configuration scripts

# Regenerate GRUB configuration
sudo grub2-mkconfig -o /boot/grub2/grub.cfg

# For UEFI systems
sudo grub2-mkconfig -o /boot/efi/EFI/rocky/grub.cfg
```

**Recovering from GRUB Issues:**

```bash
# Boot to rescue mode from installation media
# Select "Troubleshooting" -> "Rescue a Rocky Linux system"

# Once in rescue mode:
# Mount your root filesystem
chroot /mnt/sysroot

# Reinstall GRUB (BIOS)
grub2-install /dev/sda

# Reinstall GRUB (UEFI)
grub2-install --target=x86_64-efi --efi-directory=/boot/efi

# Regenerate configuration
grub2-mkconfig -o /boot/grub2/grub.cfg

# Fix boot order (UEFI)
efibootmgr -v  # View current
efibootmgr -c -d /dev/sda -p 1 -L "Rocky Linux" -l '\EFI\rocky\shimx64.efi'
```

**GRUB Command Line Recovery:**

```grub
# At GRUB prompt (grub>)
# Find your root partition
ls
ls (hd0,msdos1)/
ls (hd0,gpt2)/

# Set root
set root=(hd0,msdos1)

# Load kernel
linux /vmlinuz-5.14.0 root=/dev/sda2 ro

# Load initramfs
initrd /initramfs-5.14.0.img

# Boot
boot
```

### Emergency and Rescue Modes

Rocky Linux provides different recovery modes for different situations.

```bash
# Boot to emergency mode (minimal environment)
# Add to kernel command line:
systemd.unit=emergency.target

# Or from running system:
sudo systemctl isolate emergency.target

# Boot to rescue mode (more services)
systemd.unit=rescue.target

# Or:
sudo systemctl isolate rescue.target

# Single user mode (traditional)
# Add to kernel line:
single

# Or add 's' or '1':
init=/bin/bash
```

**Working in Emergency Mode:**

```bash
# Remount root filesystem as read-write
mount -o remount,rw /

# Check and repair filesystems
fsck /dev/sda1

# Reset failed services
systemctl reset-failed

# Disable problematic service
systemctl mask problematic.service

# View what's preventing normal boot
systemctl list-jobs
systemctl list-dependencies multi-user.target

# Continue to normal mode
systemctl default
```

### Filesystem Recovery with XFS Tools

XFS is Rocky Linux's default filesystem - robust but needs special tools for recovery.

```bash
# Check XFS filesystem
xfs_info /dev/sda2

# Repair XFS filesystem (unmounted)
umount /dev/sda2
xfs_repair /dev/sda2

# Force repair (dangerous!)
xfs_repair -L /dev/sda2  # Zeros log

# Check for corruption
xfs_repair -n /dev/sda2  # Dry run

# Defragment XFS
xfs_fsr /mount/point

# Backup XFS metadata
xfs_metadump /dev/sda2 /tmp/metadata.dump

# Restore from metadata
xfs_mdrestore /tmp/metadata.dump /dev/sda2
```

**EXT4 Recovery (if used):**

```bash
# Check ext4 filesystem
e2fsck /dev/sda1

# Force check
e2fsck -f /dev/sda1

# Automatic repair
e2fsck -y /dev/sda1

# Recover superblock
dumpe2fs /dev/sda1 | grep -i superblock
e2fsck -b 32768 /dev/sda1  # Use backup superblock

# Tune filesystem
tune2fs -l /dev/sda1  # View settings
tune2fs -c 30 /dev/sda1  # Check every 30 mounts
```

### Service Recovery Procedures

When services fail, systematic recovery is key.

```bash
# Service recovery workflow
cat > /usr/local/bin/service-recover.sh << 'EOF'
#!/bin/bash
SERVICE=$1

if [ -z "$SERVICE" ]; then
    echo "Usage: $0 <service-name>"
    exit 1
fi

echo "=== Recovering $SERVICE ==="

# 1. Check status
echo "Current status:"
systemctl status $SERVICE --no-pager

# 2. View recent logs
echo ""
echo "Recent logs:"
journalctl -u $SERVICE -n 20 --no-pager

# 3. Reset if failed
if systemctl is-failed $SERVICE; then
    echo "Resetting failed state..."
    systemctl reset-failed $SERVICE
fi

# 4. Check configuration
echo ""
echo "Validating configuration..."
if command -v nginx &> /dev/null && [ "$SERVICE" = "nginx" ]; then
    nginx -t
elif command -v httpd &> /dev/null && [ "$SERVICE" = "httpd" ]; then
    httpd -t
fi

# 5. Try to start
echo ""
echo "Attempting to start..."
systemctl start $SERVICE

# 6. Check result
sleep 2
if systemctl is-active $SERVICE; then
    echo "SUCCESS: $SERVICE is running"
else
    echo "FAILED: Check logs for details"
    journalctl -u $SERVICE -n 50
fi
EOF

chmod +x /usr/local/bin/service-recover.sh
```

### Data Recovery Techniques

Data recovery is like archaeology - careful excavation can recover treasures.

```bash
# Recover deleted files (if still in use)
lsof | grep deleted
# Copy from /proc/PID/fd/FD

# PhotoRec for file recovery
sudo dnf install testdisk -y
photorec /dev/sda

# Foremost for specific file types
sudo dnf install foremost -y
foremost -t jpg,pdf,doc -i /dev/sda -o /recovery/

# DD rescue for failing drives
sudo dnf install ddrescue -y
ddrescue /dev/failing /dev/backup rescue.log

# Create disk image for recovery
dd if=/dev/sda of=/backup/disk.img bs=4M status=progress

# Mount image
losetup /dev/loop0 /backup/disk.img
mount /dev/loop0 /mnt

# Recover from LVM snapshots
lvconvert --merge /dev/vg/snap
```

**Advanced Data Recovery:**

```bash
# Recover corrupted database
# MySQL/MariaDB
mysqlcheck --all-databases --auto-repair
mysqlcheck --all-databases --repair

# PostgreSQL
postgres --single -D /var/lib/pgsql/data dbname
reindexdb --all

# Recover corrupted RPM database
rpm --rebuilddb
rm -f /var/lib/rpm/__db*
rpm --rebuilddb

# Recover corrupted YUM/DNF cache
dnf clean all
dnf makecache
```

### Root Password Reset

When you're locked out, it's like losing your house keys - you need a way back in.

```bash
# Method 1: Init method
# 1. Boot and edit GRUB entry (press 'e')
# 2. Add to kernel line:
rd.break

# 3. At switch_root prompt:
mount -o remount,rw /sysroot
chroot /sysroot
passwd root
touch /.autorelabel  # Important for SELinux!
exit
exit

# Method 2: Single user mode
# Add to kernel line:
single
# Or:
systemd.unit=rescue.target

# Then:
passwd root
```

**Alternative Password Recovery:**

```bash
# Boot from live media
# Mount system
mkdir /mnt/sysroot
mount /dev/sda2 /mnt/sysroot
mount /dev/sda1 /mnt/sysroot/boot

# Chroot
chroot /mnt/sysroot

# Change password
passwd root

# Or edit directly (not recommended)
# Generate password hash
python3 -c 'import crypt; print(crypt.crypt("newpassword", crypt.mksalt(crypt.METHOD_SHA512)))'

# Edit /etc/shadow
```

### System Rollback Options

Rocky Linux provides several rollback mechanisms.

```bash
# DNF history and rollback
dnf history list
dnf history info 42
dnf history undo 42
dnf history rollback 40

# Snapshot rollback (if using LVM)
# Create snapshot before changes
lvcreate -L 5G -s -n root_snap /dev/vg/root

# Rollback to snapshot
umount /dev/vg/root
lvconvert --merge /dev/vg/root_snap

# Boot snapshot (temporary)
# Add to kernel line:
rd.lvm.snapshot=vg/root_snap

# RPM rollback
rpm -qa --last | head -20  # Recent packages
rpm -e package-name  # Remove package
dnf downgrade package-name  # Downgrade
```

**Creating System Restore Points:**

```bash
#!/bin/bash
# create-restore-point.sh
DATE=$(date +%Y%m%d_%H%M%S)
BACKUP_DIR="/backup/restore_points"

mkdir -p $BACKUP_DIR

# Backup critical configs
tar czf $BACKUP_DIR/configs_$DATE.tar.gz \
    /etc \
    /boot/grub2/grub.cfg \
    /var/lib/rpm \
    2>/dev/null

# Save package list
rpm -qa > $BACKUP_DIR/packages_$DATE.list

# Save service states
systemctl list-unit-files --state=enabled > $BACKUP_DIR/services_$DATE.list

# Create LVM snapshot if available
if lvs | grep -q root; then
    lvcreate -L 2G -s -n snap_$DATE /dev/vg/root
fi

echo "Restore point created: $DATE"
```

### Post-Incident Analysis

After recovery, understand what happened to prevent recurrence.

```bash
# Collect post-incident data
cat > /usr/local/bin/post-incident.sh << 'EOF'
#!/bin/bash
INCIDENT_DIR="/var/log/incidents/$(date +%Y%m%d_%H%M%S)"
mkdir -p $INCIDENT_DIR

echo "=== Post-Incident Report ===" > $INCIDENT_DIR/report.txt
echo "Date: $(date)" >> $INCIDENT_DIR/report.txt
echo "" >> $INCIDENT_DIR/report.txt

# Collect logs
journalctl -b -1 > $INCIDENT_DIR/previous_boot.log
journalctl -b > $INCIDENT_DIR/current_boot.log
dmesg > $INCIDENT_DIR/dmesg.log

# System state
ps aux > $INCIDENT_DIR/processes.txt
systemctl --failed > $INCIDENT_DIR/failed_services.txt
df -h > $INCIDENT_DIR/disk_usage.txt
free -h > $INCIDENT_DIR/memory.txt

# Recent changes
rpm -qa --last | head -50 > $INCIDENT_DIR/recent_packages.txt
last -20 > $INCIDENT_DIR/recent_logins.txt

# Create timeline
echo "=== Timeline ===" >> $INCIDENT_DIR/report.txt
echo "1. Problem first noticed:" >> $INCIDENT_DIR/report.txt
echo "2. Initial symptoms:" >> $INCIDENT_DIR/report.txt
echo "3. Troubleshooting steps:" >> $INCIDENT_DIR/report.txt
echo "4. Root cause:" >> $INCIDENT_DIR/report.txt
echo "5. Resolution:" >> $INCIDENT_DIR/report.txt
echo "6. Preventive measures:" >> $INCIDENT_DIR/report.txt

echo "Post-incident data collected in: $INCIDENT_DIR"
EOF

chmod +x /usr/local/bin/post-incident.sh
```

### Disaster Recovery Planning

Prepare for the worst, hope for the best.

```bash
# Create disaster recovery documentation
cat > /root/disaster-recovery-plan.md << 'EOF'
# Disaster Recovery Plan

## Emergency Contacts
- System Admin: [Name] [Phone]
- Backup Admin: [Name] [Phone]
- Network Admin: [Name] [Phone]

## Critical Systems Priority
1. Database servers
2. Web servers
3. Authentication systems
4. File servers

## Recovery Time Objectives (RTO)
- Critical systems: 2 hours
- Important systems: 4 hours
- Standard systems: 8 hours

## Recovery Point Objectives (RPO)
- Databases: 1 hour
- File systems: 24 hours
- System configs: 1 week

## Backup Locations
- On-site: /backup/
- Off-site: backup.example.com
- Cloud: s3://company-backups/

## Recovery Procedures
1. Boot from recovery media
2. Restore system from backup
3. Verify data integrity
4. Test functionality
5. Document incident

## Testing Schedule
- Monthly: Backup verification
- Quarterly: Partial restore test
- Annually: Full disaster recovery drill
EOF
```

### Practical Exercise: Complete Recovery Scenario

Let's practice a full recovery:

```bash
# SIMULATION - DO NOT RUN ON PRODUCTION!
# This creates problems to practice recovery

# 1. Create backup
mkdir -p /backup/test
tar czf /backup/test/etc_backup.tar.gz /etc

# 2. Simulate filesystem corruption (safe test)
dd if=/dev/zero of=/tmp/testfs bs=1M count=100
mkfs.xfs /tmp/testfs
mkdir /mnt/test
mount -o loop /tmp/testfs /mnt/test
echo "data" > /mnt/test/file.txt

# Corrupt it (safely)
umount /mnt/test
dd if=/dev/urandom of=/tmp/testfs bs=1024 count=1 seek=1000

# 3. Try to mount (will fail)
mount -o loop /tmp/testfs /mnt/test

# 4. Recover
xfs_repair /tmp/testfs
mount -o loop /tmp/testfs /mnt/test

# 5. Verify
ls -la /mnt/test/

# 6. Cleanup
umount /mnt/test
rm /tmp/testfs
```

### Recovery Best Practices

```bash
# Create recovery toolkit USB
# On another system:
dd if=Rocky-9-x86_64-minimal.iso of=/dev/sdX bs=4M status=progress

# Add recovery tools to USB
mount /dev/sdX1 /mnt
mkdir /mnt/tools
cp -r /usr/local/troubleshoot/* /mnt/tools/

# Document system configuration
cat > /root/system-baseline.sh << 'EOF'
#!/bin/bash
# Run monthly to maintain baseline

# Hardware info
lshw -short > /backup/hw-baseline.txt
lsblk > /backup/disk-baseline.txt
lscpu > /backup/cpu-baseline.txt

# Network config
ip a > /backup/network-baseline.txt
ip route > /backup/routes-baseline.txt
firewall-cmd --list-all > /backup/firewall-baseline.txt

# Service config
systemctl list-unit-files > /backup/services-baseline.txt

# Package list
rpm -qa > /backup/packages-baseline.txt

echo "Baseline updated: $(date)"
EOF

chmod +x /root/system-baseline.sh
```

### Review Questions

1. How do you reset the root password in Rocky Linux?
2. What's the difference between emergency and rescue mode?
3. How do you repair an XFS filesystem?
4. What command reinstalls GRUB on a UEFI system?
5. How do you rollback a DNF transaction?
6. What file must be created after resetting root password with rd.break?
7. How do you create and merge LVM snapshots?

### Practical Lab

Practice recovery procedures:
1. Reset the root password using rd.break method
2. Boot into emergency mode and fix a service issue
3. Repair a corrupted filesystem (use test filesystem)
4. Recover GRUB configuration
5. Perform a system rollback using DNF history
6. Create and test a disaster recovery plan
7. Document a complete incident response

### Next Steps

In Part 11, we'll explore production operations - learning how to maintain, monitor, and optimize Rocky Linux systems in enterprise environments. You'll master backup strategies, maintenance procedures, and production best practices to keep your systems running reliably.