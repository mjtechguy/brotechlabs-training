# Part 3: Storage and Filesystems

## Prerequisites

Before starting this section, you should understand:
- Basic Linux commands (ls, cd, mkdir)
- File permissions basics
- How to use sudo
- The concept of mounting (we'll explain in detail)

**Learning Resources:**
- Linux Filesystem Hierarchy: https://www.pathname.com/fhs/
- LVM Guide: https://wiki.ubuntu.com/Lvm
- Filesystem Types: https://help.ubuntu.com/community/LinuxFilesystemsExplained
- Storage Concepts: https://www.redhat.com/sysadmin/linux-storage-concepts

---

## Chapter 7: Storage Management in VMs

### Understanding Storage in Cloud VMs

When working with cloud VMs, storage is fundamentally different from your personal computer. Let's understand these differences and key concepts.

#### What is Block Storage?

**Block storage** treats storage as raw blocks of data that can be accessed directly. Think of it like this:

- **Traditional Hard Drive**: Like a filing cabinet with drawers (blocks) that you organize yourself
- **Block Storage in Cloud**: Virtual filing cabinets that can be attached/detached from different VMs

```bash
# View block devices on your system
lsblk

# Understanding the output:
# NAME    MAJ:MIN RM  SIZE RO TYPE MOUNTPOINT
# xvda    202:0    0   20G  0 disk
# └─xvda1 202:1    0   20G  0 part /
# xvdf    202:80   0  100G  0 disk

# Let's decode this:
# NAME: Device name
#   xvda, xvdf = Device names (varies by cloud provider)
#   └─xvda1 = Partition 1 on xvda
# MAJ:MIN: Major and minor device numbers (kernel identifiers)
# RM: Removable (1=yes, 0=no)
# SIZE: Storage size
# RO: Read-only (1=yes, 0=no)
# TYPE: Type of device
#   disk = Whole disk
#   part = Partition
#   lvm = LVM logical volume
# MOUNTPOINT: Where it's accessible in the filesystem
```

#### Types of Storage in Cloud VMs

1. **Root/Boot Volume**
   - Contains the operating system
   - Usually 8-20GB for Ubuntu
   - Deleted when VM is terminated (usually)

2. **Data Volumes**
   - Additional storage you attach
   - Persists independently of VM
   - Can be detached and reattached to different VMs

3. **Ephemeral Storage**
   - Temporary storage that comes with some VM types
   - Lost when VM stops/restarts
   - Good for temporary files, cache

```bash
# Check what storage you have
df -h

# Output explanation:
# Filesystem      Size  Used Avail Use% Mounted on
# /dev/xvda1       20G  5.5G   14G  30% /
# /dev/xvdf       100G   33M  100G   1% /data

# Filesystem: The device or partition
# Size: Total space
# Used: Space used
# Avail: Space available
# Use%: Percentage used
# Mounted on: Where you access it
```

### Understanding Partitions

A **partition** is a logical division of a physical disk. It's like dividing a large room into smaller rooms with walls.

#### Why Use Partitions?

```bash
# Reasons to partition:
# 1. Separate OS from data
# 2. Different filesystems for different uses
# 3. Prevent one area from filling entire disk
# 4. Security and mount options per partition

# See all partitions
sudo fdisk -l

# Output shows:
# Disk /dev/xvda: 20 GiB, 21474836480 bytes
# Disk model:
# Units: sectors of 1 * 512 = 512 bytes
# Sector size (logical/physical): 512 bytes / 512 bytes
#
# Device     Start      End  Sectors Size Type
# /dev/xvda1  2048 41943039 41940992  20G Linux

# Understanding sectors:
# Sectors are the smallest units of storage (usually 512 bytes)
# Start/End show sector numbers where partition begins/ends
```

#### Creating Partitions

```bash
# CAUTION: Partitioning can destroy data! Always backup first!

# For this example, let's partition a new disk /dev/xvdf
# First, check it's really empty
sudo fdisk -l /dev/xvdf

# Interactive partitioning with fdisk
sudo fdisk /dev/xvdf

# Inside fdisk, you'll see:
# Command (m for help):

# Common fdisk commands:
# m - Display help menu
# p - Print partition table
# n - Create new partition
# d - Delete partition
# t - Change partition type
# w - Write changes and exit
# q - Quit without saving

# Let's create a partition:
# Type 'n' for new partition
# Partition type: p (primary)
# Partition number: 1 (or press Enter for default)
# First sector: (press Enter for default)
# Last sector: +50G (creates 50GB partition)
#             or press Enter to use all space

# Type 'w' to write changes

# Refresh partition table
sudo partprobe /dev/xvdf

# Verify new partition
lsblk /dev/xvdf
# xvdf    202:80   0  100G  0 disk
# └─xvdf1 202:81   0  100G  0 part
```

#### GPT vs MBR Partition Tables

```bash
# Two partition table types:

# MBR (Master Boot Record) - Older
# - Max 4 primary partitions
# - Max 2TB disk size
# - Legacy BIOS systems

# GPT (GUID Partition Table) - Modern
# - 128 partitions by default
# - Huge disk sizes (9.4 ZB)
# - UEFI systems
# - Has backup partition table

# Create GPT partition table (recommended)
sudo gdisk /dev/xvdf
# or
sudo parted /dev/xvdf mklabel gpt

# Create MBR partition table (if needed for compatibility)
sudo fdisk /dev/xvdf
# or
sudo parted /dev/xvdf mklabel msdos
```

### Understanding Filesystems

A **filesystem** is how data is organized and stored on a partition. It's like choosing between different filing systems - alphabetical, by date, by category, etc.

#### Common Linux Filesystems

```bash
# ext4 (Fourth Extended Filesystem)
# - Default for Ubuntu
# - Mature, stable, fast
# - Good for general use
# - Supports files up to 16TB

# xfs (XFS Filesystem)
# - High performance
# - Good for large files
# - Used by RHEL/CentOS
# - Cannot shrink (only grow)

# btrfs (B-tree Filesystem)
# - Modern, advanced features
# - Snapshots, compression
# - Still maturing
# - Copy-on-write

# zfs (Z File System)
# - Advanced features
# - Data integrity checking
# - Snapshots, compression
# - Requires more RAM

# Check filesystem type
df -T

# Output:
# Filesystem     Type  Size  Used Avail Use% Mounted on
# /dev/xvda1     ext4   20G  5.5G   14G  30% /
```

#### Creating Filesystems

```bash
# After partitioning, you need to create a filesystem
# This is called "formatting" the partition

# Create ext4 filesystem (most common)
sudo mkfs.ext4 /dev/xvdf1

# What happens:
# Writing inode tables: done
# Creating journal (32768 blocks): done
# Writing superblocks and filesystem accounting information: done

# Let's understand these terms:
# - Inodes: Data structures that store file information
# - Journal: Logs changes for crash recovery
# - Superblocks: Filesystem metadata

# Create with label (recommended)
sudo mkfs.ext4 -L "data-volume" /dev/xvdf1
# Labels help identify volumes

# Other filesystem creation commands:
sudo mkfs.xfs /dev/xvdf1      # XFS
sudo mkfs.btrfs /dev/xvdf1    # Btrfs

# Check filesystem
sudo file -s /dev/xvdf1
# /dev/xvdf1: Linux rev 1.0 ext4 filesystem data
```

### Mounting Filesystems

**Mounting** is making a filesystem accessible at a certain point in your directory tree. It's like connecting a USB drive to your computer - it needs to be "mounted" before you can access the files.

#### Understanding Mount Points

```bash
# A mount point is a directory where a filesystem is attached

# Think of it like this:
# - Your main filesystem is a building (/)
# - A mount point is a door (/mnt/data)
# - Mounting connects another building through that door

# Common mount points:
# /          - Root filesystem
# /home      - User home directories (often separate)
# /var       - Variable data (logs, databases)
# /tmp       - Temporary files
# /mnt       - Temporary mounts
# /media     - Removable media
# /opt       - Optional software
```

#### Mounting and Unmounting

```bash
# Create mount point (directory)
sudo mkdir -p /mnt/data

# Mount filesystem
sudo mount /dev/xvdf1 /mnt/data

# Verify it's mounted
mount | grep xvdf1
# /dev/xvdf1 on /mnt/data type ext4 (rw,relatime)

# Or use:
df -h /mnt/data

# Access the mounted filesystem
cd /mnt/data
ls -la

# Unmount filesystem
cd /  # First, leave the mount point!
sudo umount /mnt/data

# Common mount options
sudo mount -o ro /dev/xvdf1 /mnt/data          # Read-only
sudo mount -o noexec /dev/xvdf1 /mnt/data      # No execution
sudo mount -o uid=1000,gid=1000 /dev/xvdf1 /mnt/data  # Set owner

# If unmount fails: "target is busy"
# Find what's using it:
sudo lsof /mnt/data
# or
sudo fuser -vm /mnt/data

# Force unmount (careful!)
sudo umount -f /mnt/data
# or lazy unmount (unmounts when not busy)
sudo umount -l /mnt/data
```

#### Persistent Mounting with /etc/fstab

The `/etc/fstab` file tells Linux what to mount at boot time.

```bash
# View current fstab
cat /etc/fstab

# Understanding fstab format:
# <device> <mount-point> <filesystem> <options> <dump> <pass>

# Example line:
# /dev/xvdf1 /mnt/data ext4 defaults 0 2

# Let's decode each field:
# 1. Device: What to mount
#    - /dev/xvdf1 - Device name
#    - UUID=xxx - UUID (better, survives device renaming)
#    - LABEL=data - Label

# 2. Mount point: Where to mount it
#    - /mnt/data - Directory path

# 3. Filesystem: Type of filesystem
#    - ext4, xfs, btrfs, etc.

# 4. Options: Mount options (comma-separated)
#    - defaults = rw,suid,dev,exec,auto,nouser,async
#    - ro = read-only
#    - noexec = no program execution
#    - noatime = don't update access times (performance)
#    - errors=remount-ro = remount read-only on errors

# 5. Dump: Backup utility (obsolete)
#    - 0 = don't backup
#    - 1 = backup

# 6. Pass: Filesystem check order at boot
#    - 0 = don't check
#    - 1 = check first (root filesystem)
#    - 2 = check after root

# Get UUID for more reliable mounting
sudo blkid /dev/xvdf1
# /dev/xvdf1: UUID="a1b2c3d4-..." TYPE="ext4" LABEL="data-volume"

# Add to fstab (be careful! Errors can prevent boot!)
echo "UUID=a1b2c3d4-... /mnt/data ext4 defaults,noatime 0 2" | sudo tee -a /etc/fstab

# Test without rebooting
sudo mount -a  # Mounts everything in fstab
# If errors, fix immediately!

# Verify
mount | grep /mnt/data
```

### Logical Volume Manager (LVM)

**LVM** is a flexible way to manage storage. Instead of being limited by physical partitions, LVM lets you create logical volumes that can span multiple disks and be resized on the fly.

#### Understanding LVM Concepts

Think of LVM like managing water storage:

1. **Physical Volumes (PV)** - Water tanks (actual disks/partitions)
2. **Volume Groups (VG)** - Connected tank system (pool of storage)
3. **Logical Volumes (LV)** - Taps/faucets (usable volumes)

```bash
# The LVM stack:
#   Filesystem (ext4, xfs)
#         ↓
#   Logical Volume (LV)
#         ↓
#   Volume Group (VG)
#         ↓
#   Physical Volume (PV)
#         ↓
#   Partition or Disk
```

#### Setting Up LVM

```bash
# Install LVM tools (usually pre-installed)
sudo apt update
sudo apt install lvm2

# 1. Create Physical Volume
sudo pvcreate /dev/xvdf1

# Output:
# Physical volume "/dev/xvdf1" successfully created.

# View physical volumes
sudo pvs
# PV         VG  Fmt  Attr PSize  PFree
# /dev/xvdf1     lvm2 ---  100.00g 100.00g

# Detailed view
sudo pvdisplay /dev/xvdf1

# 2. Create Volume Group
sudo vgcreate data_vg /dev/xvdf1

# Output:
# Volume group "data_vg" successfully created

# View volume groups
sudo vgs
# VG      #PV #LV #SN Attr   VSize  VFree
# data_vg   1   0   0 wz--n- 100.00g 100.00g

# 3. Create Logical Volume
# Create 50GB logical volume
sudo lvcreate -L 50G -n app_lv data_vg

# Or use percentage of VG
sudo lvcreate -l 50%VG -n app_lv data_vg

# View logical volumes
sudo lvs
# LV     VG      Attr       LSize  Pool Origin Data%
# app_lv data_vg -wi-a----- 50.00g

# The LV appears as a device
ls -l /dev/data_vg/app_lv
# or
ls -l /dev/mapper/data_vg-app_lv

# 4. Create filesystem on LV
sudo mkfs.ext4 /dev/data_vg/app_lv

# 5. Mount the LV
sudo mkdir /mnt/app
sudo mount /dev/data_vg/app_lv /mnt/app

# Add to fstab for persistence
echo "/dev/data_vg/app_lv /mnt/app ext4 defaults 0 2" | sudo tee -a /etc/fstab
```

#### LVM Operations

```bash
# Extend Logical Volume (the killer feature!)
# Add 20GB to logical volume
sudo lvextend -L +20G /dev/data_vg/app_lv

# Or extend to specific size
sudo lvextend -L 70G /dev/data_vg/app_lv

# Resize filesystem to use new space
# For ext4:
sudo resize2fs /dev/data_vg/app_lv

# For xfs:
sudo xfs_growfs /mnt/app

# Reduce Logical Volume (ext4 only, not xfs)
# CAREFUL: Can lose data if done wrong!
# 1. Unmount first
sudo umount /mnt/app

# 2. Check filesystem
sudo e2fsck -f /dev/data_vg/app_lv

# 3. Resize filesystem first
sudo resize2fs /dev/data_vg/app_lv 30G

# 4. Then reduce LV
sudo lvreduce -L 30G /dev/data_vg/app_lv

# 5. Remount
sudo mount /dev/data_vg/app_lv /mnt/app

# Add new disk to Volume Group
# If you attach new disk /dev/xvdg
sudo pvcreate /dev/xvdg
sudo vgextend data_vg /dev/xvdg

# Now VG has more space for LVs
sudo vgs

# Create snapshot (backup point)
sudo lvcreate -L 10G -s -n app_snapshot /dev/data_vg/app_lv
# -s = snapshot
# Snapshot only stores changes, not full copy

# Restore from snapshot
sudo umount /mnt/app
sudo lvconvert --merge /dev/data_vg/app_snapshot
# Merges snapshot back to origin

# Remove logical volume
sudo umount /mnt/app
sudo lvremove /dev/data_vg/app_lv
```

### Disk Performance and Optimization

Understanding and optimizing disk performance is crucial for application performance.

#### Measuring Disk Performance

```bash
# Check disk I/O statistics
iostat -x 1

# Key metrics explained:
# r/s, w/s: Reads/writes per second
# rkB/s, wkB/s: KB read/written per second
# await: Average wait time for I/O (milliseconds)
# %util: How busy the disk is (100% = fully busy)

# Monitor specific disk
iostat -x 1 /dev/xvda

# Using iotop to see which processes use disk
sudo apt install iotop
sudo iotop

# Inside iotop:
# Shows processes sorted by disk usage
# O - Only show processes doing I/O
# P - Sort by PID
# A - Accumulated I/O (since iotop started)

# Test disk speed
# Write speed test
dd if=/dev/zero of=/mnt/data/testfile bs=1G count=1 oflag=direct

# Output:
# 1073741824 bytes (1.1 GB, 1.0 GiB) copied, 10.5 s, 102 MB/s

# Read speed test
dd if=/mnt/data/testfile of=/dev/null bs=1G count=1 iflag=direct

# Clean up
rm /mnt/data/testfile
```

#### Filesystem Tuning

```bash
# Check filesystem parameters
sudo tune2fs -l /dev/xvdf1 | grep -E "Block count|Block size|Inode count"

# Reserved blocks (root emergency space)
# By default, ext4 reserves 5% for root
# On large data volumes, this wastes space

# Check reserved blocks
sudo tune2fs -l /dev/xvdf1 | grep "Reserved block count"

# Reduce to 1% (on non-system volumes)
sudo tune2fs -m 1 /dev/xvdf1

# Disable access time updates for performance
# Add noatime to mount options in /etc/fstab
# /dev/xvdf1 /mnt/data ext4 defaults,noatime 0 2

# For databases, consider:
# - noatime: Don't update access times
# - nodiratime: Don't update directory access times
# - nobarrier: Disable write barriers (only with battery-backed RAID)

# Increase read-ahead for sequential workloads
# Current read-ahead (in 512-byte sectors)
sudo blockdev --getra /dev/xvda

# Set to 1024 sectors (512KB)
sudo blockdev --setra 1024 /dev/xvda

# Make persistent
echo 'ACTION=="add|change", KERNEL=="xvda", ATTR{queue/read_ahead_kb}="512"' | \
  sudo tee /etc/udev/rules.d/60-read-ahead.rules
```

---

## Chapter 8: File Management and Backups

### Backup Strategies for Cloud VMs

Backups are your insurance against data loss. In cloud environments, you have multiple backup options.

#### Understanding Backup Types

```bash
# Full Backup
# - Complete copy of all data
# - Slowest but simplest to restore
# - Uses most storage

# Incremental Backup
# - Only changes since last backup (full or incremental)
# - Fastest, least storage
# - Complex restore (need full + all incrementals)

# Differential Backup
# - Changes since last full backup
# - Balance of speed and simplicity
# - Easier restore than incremental

# Snapshot
# - Point-in-time copy of entire disk
# - Very fast (copy-on-write)
# - Cloud provider specific
```

#### The 3-2-1 Backup Rule

```bash
# 3-2-1 Rule:
# 3 - Keep 3 copies of important data
# 2 - Store on 2 different storage types
# 1 - Keep 1 copy offsite

# Example implementation:
# 1. Primary: Live data on VM
# 2. Local backup: Different volume on same VM
# 3. Remote backup: Cloud object storage or different region
```

### Using rsync for Backups

**rsync** is a powerful tool for efficient file copying and synchronization.

#### Understanding rsync

```bash
# rsync only copies what's changed, saving time and bandwidth

# Basic syntax:
rsync [options] source destination

# Local copy
rsync -av /source/dir/ /backup/dir/

# Key options explained:
# -a: Archive mode (preserves permissions, times, etc.)
#     Equals: -rlptgoD
#     -r: recursive
#     -l: copy symlinks as symlinks
#     -p: preserve permissions
#     -t: preserve times
#     -g: preserve group
#     -o: preserve owner
#     -D: preserve devices and special files
# -v: Verbose (show what's being copied)
# -h: Human-readable sizes
# -z: Compress during transfer
# --progress: Show progress bar
# --delete: Delete files in dest that aren't in source

# IMPORTANT: Trailing slash matters!
rsync -av /source/dir/ /dest/    # Copies contents of dir
rsync -av /source/dir /dest/     # Copies dir itself
```

#### Practical rsync Backup Script

```bash
#!/bin/bash
# backup_script.sh - Incremental backup using rsync

# Configuration
SOURCE_DIR="/var/www/html"
BACKUP_DIR="/backup"
DATE=$(date +%Y%m%d_%H%M%S)
BACKUP_PATH="$BACKUP_DIR/$DATE"
LATEST_LINK="$BACKUP_DIR/latest"
LOG_FILE="/var/log/backup.log"

# Function to log messages
log_message() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

log_message "Starting backup of $SOURCE_DIR"

# Create backup directory
mkdir -p "$BACKUP_PATH"

# If previous backup exists, use hard links to save space
if [ -L "$LATEST_LINK" ]; then
    log_message "Using hard links from previous backup"
    # --link-dest creates hard links to unchanged files
    rsync -av --delete \
          --link-dest="$LATEST_LINK" \
          "$SOURCE_DIR/" \
          "$BACKUP_PATH/" \
          2>&1 | tee -a "$LOG_FILE"
else
    log_message "Creating first full backup"
    rsync -av --delete \
          "$SOURCE_DIR/" \
          "$BACKUP_PATH/" \
          2>&1 | tee -a "$LOG_FILE"
fi

# Update latest symlink
rm -f "$LATEST_LINK"
ln -s "$BACKUP_PATH" "$LATEST_LINK"

# Delete old backups (keep last 7 days)
find "$BACKUP_DIR" -maxdepth 1 -type d -name "20*" -mtime +7 -exec rm -rf {} \;

log_message "Backup completed: $BACKUP_PATH"

# Check backup size
BACKUP_SIZE=$(du -sh "$BACKUP_PATH" | cut -f1)
log_message "Backup size: $BACKUP_SIZE"

# Send notification (optional)
# echo "Backup completed: $BACKUP_SIZE" | mail -s "Backup Report" admin@example.com
```

#### Remote Backups with rsync

```bash
# Backup to remote server over SSH
rsync -avz -e ssh /local/dir/ user@remote:/backup/dir/

# With specific SSH port
rsync -avz -e "ssh -p 2222" /local/dir/ user@remote:/backup/dir/

# Using SSH key
rsync -avz -e "ssh -i ~/.ssh/backup_key" /local/dir/ user@remote:/backup/dir/

# Bandwidth limiting (KB/s)
rsync -avz --bwlimit=1000 /local/dir/ user@remote:/backup/dir/

# Exclude files
rsync -av --exclude='*.tmp' --exclude='cache/' /source/ /dest/

# Using exclude file
cat > /tmp/exclude.txt << EOF
*.tmp
*.log
cache/
temp/
.git/
EOF

rsync -av --exclude-from=/tmp/exclude.txt /source/ /dest/

# Dry run (test without actually copying)
rsync -avn /source/ /dest/
```

### Compression and Archives

Understanding how to compress and archive files is essential for backups and file transfers.

#### tar - Tape Archive

```bash
# tar combines multiple files into one archive

# Create archive
tar -cvf archive.tar directory/
# c: Create
# v: Verbose
# f: File (specify filename)

# Create compressed archive
tar -czvf archive.tar.gz directory/
# z: gzip compression

tar -cjvf archive.tar.bz2 directory/
# j: bzip2 compression (better compression, slower)

tar -cJvf archive.tar.xz directory/
# J: xz compression (best compression, slowest)

# Extract archive
tar -xvf archive.tar
# x: Extract

tar -xzvf archive.tar.gz -C /destination/
# -C: Change to directory before extracting

# View contents without extracting
tar -tvf archive.tar.gz

# Extract specific files
tar -xzvf archive.tar.gz path/to/specific/file

# Create archive with date in filename
tar -czvf "backup_$(date +%Y%m%d).tar.gz" /important/data/

# Exclude files from archive
tar -czvf archive.tar.gz --exclude='*.log' --exclude='temp/' directory/

# Create incremental archive
# First, create snapshot file
tar -czvf full_backup.tar.gz --listed-incremental=snapshot.snar directory/

# Later, create incremental (only changed files)
tar -czvf incremental_$(date +%Y%m%d).tar.gz \
    --listed-incremental=snapshot.snar directory/
```

#### Compression Tools

```bash
# gzip - Standard compression
gzip file.txt                # Creates file.txt.gz, removes original
gzip -k file.txt            # Keep original
gzip -d file.txt.gz         # Decompress
gunzip file.txt.gz          # Same as above

# Check compression ratio
gzip -l file.txt.gz

# bzip2 - Better compression, slower
bzip2 file.txt              # Creates file.txt.bz2
bzip2 -k file.txt          # Keep original
bunzip2 file.txt.bz2       # Decompress

# xz - Best compression
xz file.txt                # Creates file.txt.xz
xz -k file.txt            # Keep original
unxz file.txt.xz          # Decompress

# zip - Compatible with Windows
zip archive.zip file1 file2 file3
zip -r archive.zip directory/    # Recursive
unzip archive.zip                 # Extract
unzip -l archive.zip             # List contents
unzip archive.zip -d /destination/  # Extract to specific location

# Compare compression methods
ls -lh file.txt*
# -rw-r--r-- 1 user user 100M file.txt
# -rw-r--r-- 1 user user  30M file.txt.gz
# -rw-r--r-- 1 user user  25M file.txt.bz2
# -rw-r--r-- 1 user user  20M file.txt.xz
```

### Automated Backup Solutions

#### Setting Up Automated Backups with Cron

```bash
# Create backup script
sudo nano /usr/local/bin/daily_backup.sh

#!/bin/bash
# Daily backup script

# Configuration
BACKUP_SOURCES=(
    "/etc"
    "/var/www"
    "/home"
)
BACKUP_DEST="/backup/daily"
RETENTION_DAYS=30
LOG_FILE="/var/log/daily_backup.log"

# Create backup directory with date
BACKUP_DATE=$(date +%Y%m%d)
BACKUP_PATH="$BACKUP_DEST/$BACKUP_DATE"
mkdir -p "$BACKUP_PATH"

# Backup each source
for SOURCE in "${BACKUP_SOURCES[@]}"; do
    # Get source name for archive
    SOURCE_NAME=$(basename "$SOURCE")

    echo "[$(date '+%Y-%m-%d %H:%M:%S')] Backing up $SOURCE" >> "$LOG_FILE"

    tar -czf "$BACKUP_PATH/${SOURCE_NAME}.tar.gz" "$SOURCE" 2>> "$LOG_FILE"

    if [ $? -eq 0 ]; then
        echo "[$(date '+%Y-%m-%d %H:%M:%S')] Success: $SOURCE" >> "$LOG_FILE"
    else
        echo "[$(date '+%Y-%m-%d %H:%M:%S')] Failed: $SOURCE" >> "$LOG_FILE"
    fi
done

# Delete old backups
find "$BACKUP_DEST" -type d -name "20*" -mtime +$RETENTION_DAYS -exec rm -rf {} \; 2>/dev/null

echo "[$(date '+%Y-%m-%d %H:%M:%S')] Backup completed" >> "$LOG_FILE"

# Make executable
sudo chmod +x /usr/local/bin/daily_backup.sh

# Add to cron
sudo crontab -e

# Add this line for daily backup at 2 AM:
0 2 * * * /usr/local/bin/daily_backup.sh

# Or use systemd timer (modern approach)
sudo nano /etc/systemd/system/backup.service

[Unit]
Description=Daily Backup Service
After=network.target

[Service]
Type=oneshot
ExecStart=/usr/local/bin/daily_backup.sh
StandardOutput=journal
StandardError=journal

# Create timer
sudo nano /etc/systemd/system/backup.timer

[Unit]
Description=Daily Backup Timer
Requires=backup.service

[Timer]
OnCalendar=daily
OnCalendar=02:00
Persistent=true

[Install]
WantedBy=timers.target

# Enable timer
sudo systemctl daemon-reload
sudo systemctl enable --now backup.timer

# Check timer status
systemctl list-timers --all | grep backup
```

#### Backup to Cloud Storage

```bash
# Using rclone for cloud storage backups
# rclone supports: S3, Google Drive, Dropbox, OneDrive, etc.

# Install rclone
curl https://rclone.org/install.sh | sudo bash

# Configure rclone (interactive)
rclone config

# Example: Configure S3-compatible storage
# n) New remote
# name> s3-backup
# Storage> s3
# Provider> AWS
# access_key_id> YOUR_KEY
# secret_access_key> YOUR_SECRET
# region> us-east-1
# location_constraint>
# acl> private

# List configured remotes
rclone listremotes

# Backup to cloud
rclone sync /local/backup/ s3-backup:my-bucket/backups/ --progress

# Backup script with rclone
#!/bin/bash
# cloud_backup.sh

LOCAL_BACKUP="/backup/daily"
REMOTE="s3-backup:my-bucket/$(hostname)/backups"
LOG_FILE="/var/log/cloud_backup.log"

echo "[$(date '+%Y-%m-%d %H:%M:%S')] Starting cloud sync" >> "$LOG_FILE"

# Sync to cloud (only upload changes)
rclone sync "$LOCAL_BACKUP" "$REMOTE" \
    --transfers 4 \
    --checkers 8 \
    --contimeout 60s \
    --timeout 300s \
    --retries 3 \
    --low-level-retries 10 \
    --stats 1m \
    --stats-log-level NOTICE \
    --log-file "$LOG_FILE"

if [ $? -eq 0 ]; then
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] Cloud sync completed" >> "$LOG_FILE"

    # Optional: Remove old local backups after successful cloud sync
    find "$LOCAL_BACKUP" -type d -mtime +7 -exec rm -rf {} \; 2>/dev/null
else
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] Cloud sync failed!" >> "$LOG_FILE"
fi
```

### Snapshot Management

Snapshots provide point-in-time copies of your data.

#### LVM Snapshots

```bash
# Create LVM snapshot
# Snapshot only stores changes (Copy-on-Write)

# Create 5GB snapshot of logical volume
sudo lvcreate -L 5G -s -n app_lv_snapshot /dev/data_vg/app_lv

# View snapshots
sudo lvs
# Look for 's' attribute indicating snapshot

# Mount snapshot (read-only recommended)
sudo mkdir /mnt/snapshot
sudo mount -o ro /dev/data_vg/app_lv_snapshot /mnt/snapshot

# Backup from snapshot (consistent backup)
rsync -av /mnt/snapshot/ /backup/consistent_backup/

# Remove snapshot when done
sudo umount /mnt/snapshot
sudo lvremove /dev/data_vg/app_lv_snapshot

# Restore from snapshot (merges back to origin)
# WARNING: This replaces current data with snapshot!
sudo umount /mnt/app  # Unmount origin first
sudo lvconvert --merge /dev/data_vg/app_lv_snapshot
# Reboot or remount to complete merge
```

#### Filesystem Snapshots (Btrfs)

```bash
# If using btrfs filesystem

# Create snapshot
sudo btrfs subvolume snapshot /mnt/data /mnt/data/.snapshots/$(date +%Y%m%d)

# List snapshots
sudo btrfs subvolume list /mnt/data

# Delete old snapshot
sudo btrfs subvolume delete /mnt/data/.snapshots/20240101

# Restore from snapshot
# Method 1: Copy files back
sudo cp -a /mnt/data/.snapshots/20240115/* /mnt/data/

# Method 2: Replace subvolume
sudo mv /mnt/data /mnt/data.old
sudo btrfs subvolume snapshot /mnt/data/.snapshots/20240115 /mnt/data
```

### Disaster Recovery Planning

#### Creating a Recovery Plan

```bash
# Document your recovery procedures

cat > /root/RECOVERY_PLAN.md << 'EOF'
# Disaster Recovery Plan

## Critical Systems
1. Web Server (nginx)
2. Database (MySQL)
3. Application Server

## Backup Locations
- Local: /backup/daily/
- Remote: s3://backup-bucket/
- Snapshots: LVM snapshots every 6 hours

## Recovery Procedures

### 1. System Won't Boot
- Boot from Ubuntu Live USB
- Mount root filesystem
- Check /var/log/syslog for errors
- Run fsck if filesystem errors

### 2. Corrupted Files
- Check most recent backup
- Restore from /backup/daily/latest/
- If not available, check cloud backup

### 3. Database Recovery
- Stop MySQL: systemctl stop mysql
- Backup current data: cp -r /var/lib/mysql /tmp/mysql_broken
- Restore from backup: tar -xzf /backup/daily/latest/mysql.tar.gz -C /
- Start MySQL: systemctl start mysql
- Verify data integrity

### 4. Complete System Restoration
1. Boot fresh Ubuntu installation
2. Install necessary packages
3. Restore /etc from backup
4. Restore application data
5. Restore database
6. Verify services

## Important Contacts
- System Admin: admin@example.com
- Cloud Provider Support: 1-800-xxx-xxxx
- Backup Service: backup@provider.com

## Testing Schedule
- Monthly: Restore single file
- Quarterly: Restore database to test system
- Annually: Complete disaster recovery drill
EOF
```

#### Recovery Testing Script

```bash
#!/bin/bash
# test_recovery.sh - Test backup restoration

TEST_DIR="/tmp/recovery_test_$(date +%Y%m%d)"
BACKUP_SOURCE="/backup/daily/latest"
LOG_FILE="/var/log/recovery_test.log"

echo "[$(date '+%Y-%m-%d %H:%M:%S')] Starting recovery test" | tee -a "$LOG_FILE"

# Create test directory
mkdir -p "$TEST_DIR"

# Test file restoration
echo "Testing file restoration..." | tee -a "$LOG_FILE"
tar -xzf "$BACKUP_SOURCE/etc.tar.gz" -C "$TEST_DIR" etc/hostname 2>/dev/null

if [ -f "$TEST_DIR/etc/hostname" ]; then
    echo "✓ File restoration successful" | tee -a "$LOG_FILE"
else
    echo "✗ File restoration failed!" | tee -a "$LOG_FILE"
    exit 1
fi

# Test database restoration (dry run)
echo "Testing database backup integrity..." | tee -a "$LOG_FILE"
tar -tzf "$BACKUP_SOURCE/mysql.tar.gz" > /dev/null 2>&1

if [ $? -eq 0 ]; then
    echo "✓ Database backup is valid" | tee -a "$LOG_FILE"
else
    echo "✗ Database backup is corrupted!" | tee -a "$LOG_FILE"
    exit 1
fi

# Clean up
rm -rf "$TEST_DIR"

echo "[$(date '+%Y-%m-%d %H:%M:%S')] Recovery test completed" | tee -a "$LOG_FILE"

# Send report
# mail -s "Recovery Test Report" admin@example.com < "$LOG_FILE"
```

### Key Takeaways

1. **Understand storage types** - Root volumes vs data volumes in cloud
2. **Use LVM for flexibility** - Resize volumes without downtime
3. **Always backup before partitioning** - Mistakes can destroy data
4. **Use UUIDs in fstab** - More reliable than device names
5. **Test your backups** - Untested backups are just hopes
6. **Follow 3-2-1 rule** - Multiple copies, different media, offsite
7. **Automate backups** - Manual backups get forgotten
8. **Document recovery procedures** - Stress makes people forget
9. **Use appropriate compression** - Balance speed vs space
10. **Monitor disk usage** - Prevent full disks before they happen

### Learning Resources

- **LVM Guide**: https://wiki.archlinux.org/title/LVM
- **Filesystem Comparison**: https://wiki.archlinux.org/title/File_systems
- **rsync Tutorial**: https://www.digitalocean.com/community/tutorials/how-to-use-rsync-to-sync-local-and-remote-directories
- **Backup Best Practices**: https://www.backblaze.com/blog/the-3-2-1-backup-strategy/
- **Disaster Recovery**: https://www.redhat.com/sysadmin/disaster-recovery-planning

Remember: The best backup is the one you have when you need it. Regular testing ensures your backups actually work when disaster strikes.