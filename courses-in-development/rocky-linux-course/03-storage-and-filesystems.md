# Part 3: Storage and Filesystems

## Chapter 7: Storage Management

### Understanding Storage in Linux

Before we dive into commands, let's understand how Linux sees storage. Imagine your computer's storage like a filing cabinet:
- **Physical Disks** = The actual filing cabinet
- **Partitions** = Drawers in the cabinet
- **Filesystems** = The organizing system inside each drawer
- **Mount Points** = Labels on the drawers so you know what's where

### Block Storage Fundamentals

#### What is Block Storage?

**Block storage** treats storage as chunks (blocks) of data. Think of it like LEGO blocks - you can arrange them however you want. This is different from:
- **File storage**: Already organized into files and folders (like a library)
- **Object storage**: Individual items with metadata (like a warehouse with barcodes)

```bash
# Let's see what storage devices you have:
lsblk
# NAME            MAJ:MIN RM  SIZE RO TYPE MOUNTPOINT
# sda               8:0    0   20G  0 disk
# ├─sda1            8:1    0    1G  0 part /boot
# └─sda2            8:2    0   19G  0 part
#   ├─rl-root     253:0    0   17G  0 lvm  /
#   └─rl-swap     253:1    0    2G  0 lvm  [SWAP]
# sr0              11:0    1 1024M  0 rom

# Let's decode this:
# sda     = First SCSI/SATA disk (a=first, b=second, etc.)
# sda1    = First partition on sda
# sda2    = Second partition on sda
# rl-root = Logical volume named "root" in volume group "rl" (Rocky Linux)
# sr0     = CD/DVD drive (sr = SCSI ROM)

# SIZE = How big it is
# TYPE = disk (physical), part (partition), lvm (logical volume), rom (CD/DVD)
# MOUNTPOINT = Where it's accessible in the filesystem
```

#### Understanding Device Names

```bash
# Linux device naming conventions:
# /dev/sda  = First SATA/SCSI disk
# /dev/sdb  = Second SATA/SCSI disk
# /dev/nvme0n1 = First NVMe SSD
# /dev/vda  = First virtio disk (common in VMs)
# /dev/xvda = First Xen virtual disk (AWS)

# See more details about a disk:
sudo fdisk -l /dev/sda
# Disk /dev/sda: 20 GiB, 21474836480 bytes, 41943040 sectors
# Units: sectors of 1 * 512 = 512 bytes
# Sector size (logical/physical): 512 bytes / 512 bytes
# I/O size (minimum/optimal): 512 bytes / 512 bytes
# Disklabel type: dos
# Disk identifier: 0x1234abcd
#
# Device     Boot   Start      End  Sectors Size Id Type
# /dev/sda1  *       2048  2099199  2097152   1G 83 Linux
# /dev/sda2       2099200 41943039 39843840  19G 8e Linux LVM

# What this tells us:
# - Disk is 20 GB total
# - Uses DOS partition table (MBR)
# - sda1 is 1GB, bootable (*), type 83 (Linux)
# - sda2 is 19GB, type 8e (Linux LVM)
```

### Disk Partitioning

#### Why Partition Disks?

Partitioning is like dividing a house into rooms - each serves a different purpose:
- **Separation**: Keep system files separate from user files
- **Security**: Limit damage if one partition fills up
- **Different filesystems**: Use optimal filesystem for each purpose
- **Dual boot**: Multiple operating systems on one disk

#### Partition Tables: MBR vs GPT

```bash
# Two types of partition tables:

# 1. MBR (Master Boot Record) - Older, limited
#    - Max 4 primary partitions
#    - Max 2TB disk size
#    - Used on older systems

# 2. GPT (GUID Partition Table) - Modern, flexible
#    - 128 partitions (typically)
#    - Huge disk sizes (9.4 ZB theoretical)
#    - Required for UEFI boot

# Check what your disk uses:
sudo parted /dev/sda print
# Model: ATA VBOX HARDDISK (scsi)
# Disk /dev/sda: 21.5GB
# Sector size (logical/physical): 512B/512B
# Partition Table: msdos        <- This is MBR
# Disk Flags:
#
# Number  Start   End     Size    Type     File system  Flags
#  1      1049kB  1075MB  1074MB  primary  xfs          boot
#  2      1075MB  21.5GB  20.4GB  primary               lvm
```

#### Creating Partitions with fdisk (MBR)

```bash
# CAREFUL: Partitioning can destroy data! Practice on test systems!

# Let's partition a new disk (example: /dev/sdb)
sudo fdisk /dev/sdb

# You'll enter interactive mode:
# Welcome to fdisk (util-linux 2.32.1).
# Changes will remain in memory only, until you decide to write them.
# Be careful before using the write command.
#
# Command (m for help):

# Common commands:
# m = help menu
# p = print partition table
# n = new partition
# d = delete partition
# t = change partition type
# w = write changes and exit
# q = quit without saving

# Let's create a partition:
Command: n
# Partition type:
#    p   primary (0 primary, 0 extended, 4 free)
#    e   extended
Select: p
# Partition number (1-4, default 1): 1
# First sector (2048-41943039, default 2048): [Enter for default]
# Last sector, +sectors or +size{K,M,G,T,P}: +5G

# This creates a 5GB partition

# View what we did:
Command: p
# Device     Boot Start      End  Sectors Size Id Type
# /dev/sdb1        2048 10487807 10485760   5G 83 Linux

# Save changes:
Command: w
# The partition table has been altered!

# Tell kernel about new partitions:
sudo partprobe /dev/sdb
```

#### Creating Partitions with parted (GPT)

```bash
# parted is more modern and handles GPT better

sudo parted /dev/sdb

# Create GPT partition table:
(parted) mklabel gpt

# Create partitions:
(parted) mkpart primary xfs 1MiB 5GiB
(parted) mkpart primary xfs 5GiB 10GiB

# View partitions:
(parted) print
# Number  Start   End     Size    File system  Name     Flags
#  1      1049kB  5369MB  5368MB               primary
#  2      5369MB  10.7GB  5369MB               primary

# Set names (helpful for identifying):
(parted) name 1 'Data'
(parted) name 2 'Backup'

# Exit:
(parted) quit
```

### Filesystem Types and Creation

#### Understanding Filesystems

A **filesystem** is how data is organized on a disk. Think of it like different ways to organize a library:
- Some are faster to search
- Some pack books more efficiently
- Some handle damage better
- Some work better with certain types of books

#### Rocky Linux Filesystem Options

```bash
# Common filesystems and when to use them:

# XFS (default in Rocky Linux)
# - Great for large files
# - High performance
# - Can grow but not shrink
# - Used for: General purpose, databases

# ext4 (traditional Linux)
# - Very reliable
# - Can grow and shrink
# - Good all-around
# - Used for: General purpose, boot partitions

# ext3 (older)
# - Like ext4 but less features
# - Very stable
# - Used for: Legacy systems

# vfat/FAT32
# - Compatible with Windows
# - No permissions/ownership
# - Used for: USB drives, EFI partitions

# NTFS
# - Windows filesystem
# - Read/write with ntfs-3g
# - Used for: Dual boot with Windows

# Btrfs (advanced)
# - Snapshots, compression
# - Still maturing
# - Used for: Advanced features
```

#### Creating Filesystems

```bash
# Create filesystem on partition (FORMAT - destroys data!)

# XFS filesystem:
sudo mkfs.xfs /dev/sdb1
# meta-data=/dev/sdb1              isize=512    agcount=4, agsize=327680 blks
#          =                       sectsz=512   attr=2, projid32bit=1
# data     =                       bsize=4096   blocks=1310720, imaxpct=25
# naming   =version 2              bsize=4096   ascii-ci=0 ftype=1
# log      =internal log           bsize=4096   blocks=2560, version=2
# realtime =none                   extsz=4096   blocks=0, rtextents=0

# ext4 filesystem:
sudo mkfs.ext4 /dev/sdb2
# mke2fs 1.45.6 (20-Mar-2020)
# Creating filesystem with 1310720 4k blocks and 327680 inodes
# Allocating group tables: done
# Writing inode tables: done
# Creating journal (16384 blocks): done
# Writing superblocks and filesystem accounting information: done

# With labels (helpful for identification):
sudo mkfs.xfs -L "Data" /dev/sdb1
sudo mkfs.ext4 -L "Backup" /dev/sdb2

# Check filesystem type:
sudo file -s /dev/sdb1
# /dev/sdb1: SGI XFS filesystem data (blksz 4096, inosz 512, v2 dirs)

sudo blkid
# /dev/sdb1: LABEL="Data" UUID="123e4567-e89b-12d3-a456-426614174000" TYPE="xfs"
# /dev/sdb2: LABEL="Backup" UUID="987f6543-b21a-98d7-6543-210987654321" TYPE="ext4"
```

### Mounting and Automounting

#### Understanding Mount Points

**Mounting** is making a filesystem accessible at a specific location. Think of it like:
- The filesystem is a USB drive
- The mount point is a USB port
- Mounting is plugging it in
- You can only access the drive after plugging it in!

```bash
# The Linux filesystem is a tree starting at root (/)
# Everything else is mounted somewhere in this tree:

tree -L 1 /
# /
# ├── bin -> usr/bin
# ├── boot         <- Separate partition often mounted here
# ├── dev
# ├── etc
# ├── home         <- Could be separate partition
# ├── media        <- Removable media auto-mounts here
# ├── mnt          <- Temporary manual mounts
# ├── opt
# ├── proc
# ├── root
# ├── run
# ├── srv
# ├── sys
# ├── tmp
# ├── usr
# └── var          <- Sometimes separate partition

# See current mounts:
mount
# sysfs on /sys type sysfs (rw,nosuid,nodev,noexec,relatime)
# proc on /proc type proc (rw,nosuid,nodev,noexec,relatime)
# /dev/mapper/rl-root on / type xfs (rw,relatime,attr2,inode64,noquota)
# /dev/sda1 on /boot type xfs (rw,relatime,attr2,inode64,noquota)

# Better view of mounts:
findmnt
# TARGET                       SOURCE           FSTYPE   OPTIONS
# /                            /dev/mapper/rl-root xfs   rw,relatime
# ├─/sys                       sysfs            sysfs    rw,nosuid,nodev
# ├─/proc                      proc             proc     rw,nosuid,nodev
# ├─/dev                       devtmpfs         devtmpfs rw,nosuid
# ├─/boot                      /dev/sda1        xfs      rw,relatime
# └─/home                      /dev/mapper/rl-home xfs   rw,relatime
```

#### Manual Mounting

```bash
# Basic mount syntax:
# mount [options] device mountpoint

# Create mount point (directory):
sudo mkdir /mnt/data
sudo mkdir /mnt/backup

# Mount filesystems:
sudo mount /dev/sdb1 /mnt/data
sudo mount /dev/sdb2 /mnt/backup

# Verify mounts:
df -h
# Filesystem               Size  Used Avail Use% Mounted on
# /dev/sdb1                5.0G   68M  5.0G   2% /mnt/data
# /dev/sdb2                5.0G   20M  4.7G   1% /mnt/backup

# Mount with options:
sudo mount -o ro /dev/sdb1 /mnt/data         # Read-only
sudo mount -o noexec /dev/sdb1 /mnt/data     # No execution
sudo mount -o uid=1000,gid=1000 /dev/sdb1 /mnt/data  # Set ownership (FAT32)

# Mount by label or UUID (more reliable):
sudo mount -L "Data" /mnt/data
sudo mount -U "123e4567-e89b-12d3-a456-426614174000" /mnt/data

# Unmount:
sudo umount /mnt/data
# or
sudo umount /dev/sdb1

# Force unmount if busy:
sudo umount -f /mnt/data    # Force
sudo umount -l /mnt/data    # Lazy unmount

# See what's using a mount:
sudo lsof +D /mnt/data
sudo fuser -vm /mnt/data
```

#### Automatic Mounting with /etc/fstab

```bash
# /etc/fstab configures automatic mounts at boot

# View current fstab:
cat /etc/fstab
#
# /etc/fstab
# Created by anaconda on Mon Dec 10 10:00:00 2023
#
# Accessible filesystems, by reference, are maintained under '/dev/disk'
# See man pages fstab(5), findfs(8), mount(8) and/or blkid(8) for more info
#
# <device>                                <mount point> <type> <options>     <dump> <pass>
/dev/mapper/rl-root                      /            xfs    defaults      0      0
UUID=abc12345-6789-def0-1234-567890abcdef /boot       xfs    defaults      0      0
/dev/mapper/rl-swap                      none         swap   defaults      0      0

# Let's understand each field:
# 1. Device: What to mount (device, UUID, or LABEL)
# 2. Mount point: Where to mount it
# 3. Filesystem type: xfs, ext4, etc.
# 4. Options: Mount options (defaults = rw,suid,dev,exec,auto,nouser,async)
# 5. Dump: Backup with dump command (0 = don't backup)
# 6. Pass: fsck check order (0 = don't check, 1 = check first, 2 = check second)

# Add our new partitions to fstab:
# First, get UUIDs:
blkid /dev/sdb1 /dev/sdb2
# /dev/sdb1: LABEL="Data" UUID="123e4567-e89b-12d3-a456-426614174000" TYPE="xfs"
# /dev/sdb2: LABEL="Backup" UUID="987f6543-b21a-98d7-6543-210987654321" TYPE="ext4"

# Edit fstab:
sudo nano /etc/fstab

# Add these lines:
UUID=123e4567-e89b-12d3-a456-426614174000 /mnt/data   xfs    defaults      0 2
UUID=987f6543-b21a-98d7-6543-210987654321 /mnt/backup ext4   defaults      0 2

# Test without rebooting:
sudo mount -a   # Mount everything in fstab

# If error, fix before rebooting!
# Bad fstab can prevent booting!

# Verify:
findmnt --verify  # Check fstab for errors
```

#### Systemd Mount Units (Modern Method)

```bash
# Systemd can manage mounts with .mount units

# Create mount unit for /mnt/data:
sudo nano /etc/systemd/system/mnt-data.mount

[Unit]
Description=Data Storage
After=multi-user.target

[Mount]
What=/dev/sdb1
Where=/mnt/data
Type=xfs
Options=defaults

[Install]
WantedBy=multi-user.target

# Enable and start:
sudo systemctl daemon-reload
sudo systemctl enable --now mnt-data.mount

# Check status:
systemctl status mnt-data.mount
```

### Logical Volume Manager (LVM)

#### Understanding LVM

LVM is like having resizable, flexible partitions. Imagine:
- **Physical Volumes (PV)**: Raw disks or partitions (like lumber)
- **Volume Groups (VG)**: Pool of space from PVs (like a warehouse of lumber)
- **Logical Volumes (LV)**: Flexible "partitions" (like building rooms with the lumber)

The magic: You can resize rooms without tearing down the house!

```bash
# See LVM layout:
sudo pvs  # Physical volumes
#   PV         VG Fmt  Attr PSize   PFree
#   /dev/sda2  rl lvm2 a--  <19.00g    0

sudo vgs  # Volume groups
#   VG #PV #LV #SN Attr   VSize   VFree
#   rl   1   2   0 wz--n- <19.00g    0

sudo lvs  # Logical volumes
#   LV   VG Attr       LSize  Pool Origin Data%  Meta%
#   root rl -wi-ao---- 17.00g
#   swap rl -wi-ao----  2.00g

# Detailed view:
sudo pvdisplay
sudo vgdisplay
sudo lvdisplay
```

#### Creating LVM Setup

```bash
# Let's create LVM on a new disk (/dev/sdc)

# Step 1: Create physical volume
sudo pvcreate /dev/sdc
#   Physical volume "/dev/sdc" successfully created.

# Or use partitions:
sudo pvcreate /dev/sdc1 /dev/sdc2

# Verify:
sudo pvs
#   PV         VG Fmt  Attr PSize  PFree
#   /dev/sdc      lvm2 ---  20.00g 20.00g

# Step 2: Create volume group
sudo vgcreate data_vg /dev/sdc
#   Volume group "data_vg" successfully created

# Add more disks later:
sudo vgextend data_vg /dev/sdd

# Step 3: Create logical volumes
sudo lvcreate -n projects -L 5G data_vg
#   Logical volume "projects" created.

sudo lvcreate -n backups -L 8G data_vg
#   Logical volume "backups" created.

# Use percentage of space:
sudo lvcreate -n logs -l 50%FREE data_vg  # 50% of remaining space
sudo lvcreate -n temp -l 100%FREE data_vg # All remaining space

# Step 4: Create filesystems
sudo mkfs.xfs /dev/data_vg/projects
sudo mkfs.ext4 /dev/data_vg/backups

# Step 5: Mount them
sudo mkdir /projects /backups
sudo mount /dev/data_vg/projects /projects
sudo mount /dev/data_vg/backups /backups

# Add to fstab:
echo "/dev/mapper/data_vg-projects /projects xfs defaults 0 2" | sudo tee -a /etc/fstab
echo "/dev/mapper/data_vg-backups /backups ext4 defaults 0 2" | sudo tee -a /etc/fstab
```

#### Resizing LVM Volumes

```bash
# The power of LVM: resize without unmounting!

# Extend logical volume:
sudo lvextend -L +2G /dev/data_vg/projects
# Size of logical volume data_vg/projects changed from 5.00 GiB to 7.00 GiB

# Or use all free space:
sudo lvextend -l +100%FREE /dev/data_vg/projects

# Resize filesystem to match:
# For XFS:
sudo xfs_growfs /projects

# For ext4:
sudo resize2fs /dev/data_vg/backups

# Shrink volume (ext4 only, not XFS):
# DANGEROUS - backup first!
sudo umount /backups
sudo e2fsck -f /dev/data_vg/backups
sudo resize2fs /dev/data_vg/backups 6G
sudo lvreduce -L 6G /dev/data_vg/backups
sudo mount /backups
```

#### LVM Snapshots

```bash
# Snapshots are point-in-time copies - perfect for backups!

# Create snapshot:
sudo lvcreate -s -n projects_snap -L 1G /dev/data_vg/projects
#   Logical volume "projects_snap" created.

# -s = snapshot
# -n = name
# -L = size (only stores changes, so can be smaller)

# Mount snapshot to access:
sudo mkdir /mnt/snapshot
sudo mount -o ro /dev/data_vg/projects_snap /mnt/snapshot

# Backup from snapshot while system runs normally:
tar -czf /backup/projects-$(date +%Y%m%d).tar.gz /mnt/snapshot

# Remove snapshot when done:
sudo umount /mnt/snapshot
sudo lvremove /dev/data_vg/projects_snap

# Restore from snapshot (DANGEROUS - loses current data):
sudo umount /projects
sudo lvconvert --merge /dev/data_vg/projects_snap
# Reboot to complete merge
```

### Advanced Storage Technologies

#### Stratis - Next-Generation Storage

Stratis is the modern storage management solution available in Rocky Linux - simpler but powerful:

```bash
# Install Stratis:
sudo dnf install -y stratisd stratis-cli

# Start service:
sudo systemctl enable --now stratisd

# Create pool (like volume group):
sudo stratis pool create my_pool /dev/sdd
#                          ^        ^
#                     pool name   disk

# Create filesystem (automatically thin-provisioned):
sudo stratis fs create my_pool projects
#                        ^        ^
#                     pool    filesystem name

# Filesystems appear here:
ls /stratis/my_pool/
# projects

# Mount it:
sudo mkdir /stratis-projects
sudo mount /stratis/my_pool/projects /stratis-projects

# Add to fstab (use UUID):
blkid /stratis/my_pool/projects
# UUID="abc..." TYPE="xfs"

# Snapshots:
sudo stratis fs snapshot my_pool projects projects_snap

# Add cache (SSD for speed):
sudo stratis pool add-cache my_pool /dev/nvme0n1

# See status:
stratis pool list
stratis fs list
```

#### VDO - Virtual Data Optimizer

VDO provides deduplication and compression:

```bash
# Install VDO:
sudo dnf install -y vdo kmod-kvdo

# Create VDO volume:
sudo vdo create --name=vdo_storage \
                --device=/dev/sde \
                --vdoLogicalSize=50G \
                --compression=enabled \
                --deduplication=enabled

# This creates a 50GB logical volume on physical device /dev/sde
# Deduplication removes duplicate data
# Compression shrinks data

# Format and mount:
sudo mkfs.xfs /dev/mapper/vdo_storage
sudo mkdir /vdo-data
sudo mount /dev/mapper/vdo_storage /vdo-data

# Check statistics:
sudo vdostats --human-readable
# Device          Size  Used  Available  Use%  Savings%
# vdo_storage     20.0G 2.1G  17.9G      10%   68%
#                                               ^
#                                        Space saved!

# Great for: Backups, VMs, similar data
```

---

## Chapter 8: File Management and Backups

### Backup Strategies

#### The 3-2-1 Rule

The golden rule of backups:
- **3** copies of important data
- **2** different storage media types
- **1** offsite backup

Think of it like important documents:
- Original on your computer (1)
- Copy on external drive (2)
- Copy in cloud storage (3)

#### Types of Backups

```bash
# Full Backup
# - Complete copy of everything
# - Takes most space and time
# - Easiest to restore
# Like photocopying an entire book

# Incremental Backup
# - Only changes since last backup (any type)
# - Smallest and fastest
# - Need all incrementals to restore
# Like only copying pages that changed

# Differential Backup
# - Changes since last FULL backup
# - Grows over time
# - Need full + latest differential to restore
# Like copying all pages changed since original

# Example backup schedule:
# Sunday: Full backup
# Monday: Incremental (just Monday's changes)
# Tuesday: Incremental (just Tuesday's changes)
# Wednesday: Incremental (just Wednesday's changes)
# Thursday: Incremental (just Thursday's changes)
# Friday: Differential (all changes since Sunday)
# Saturday: Incremental (just Saturday's changes)
```

### Using rsync for Efficient Backups

#### Understanding rsync

**rsync** is like a smart copy command - it only copies what's changed:

```bash
# Basic rsync syntax:
# rsync [options] source destination

# Simple backup:
rsync -av /home/john/ /backup/john/
# -a = archive mode (preserves everything)
# -v = verbose (show what's happening)

# IMPORTANT: Trailing slashes matter!
rsync -av /source  /dest   # Copies 'source' folder into dest
rsync -av /source/ /dest   # Copies CONTENTS of source into dest

# Common options:
rsync -avh /source/ /dest/        # -h = human-readable sizes
rsync -avhn /source/ /dest/       # -n = dry run (show what would happen)
rsync -avhP /source/ /dest/       # -P = show progress
rsync -avhz /source/ /dest/       # -z = compress during transfer

# Delete files in dest that aren't in source:
rsync -av --delete /source/ /dest/

# Exclude files:
rsync -av --exclude='*.tmp' --exclude='.cache' /source/ /dest/

# Use exclude file:
cat > /tmp/exclude.txt << EOF
*.tmp
*.log
.cache/
node_modules/
EOF

rsync -av --exclude-from=/tmp/exclude.txt /source/ /dest/
```

#### Remote Backups with rsync

```bash
# Backup to remote server:
rsync -avz /local/data/ user@backup-server:/remote/backup/
# -z = compress for network transfer

# Backup from remote server:
rsync -avz user@server:/remote/data/ /local/backup/

# Use SSH with specific port:
rsync -avz -e 'ssh -p 2222' /local/ user@server:/backup/

# Bandwidth limit (don't hog network):
rsync -avz --bwlimit=1000 /local/ user@server:/backup/
# Limit to 1000 KB/s

# Incremental backup script:
#!/bin/bash
BACKUP_DIR="/backup"
DATE=$(date +%Y%m%d_%H%M%S)
LINK_DEST="$BACKUP_DIR/latest"

# Create new backup with hard links to unchanged files
rsync -av --link-dest="$LINK_DEST" /source/ "$BACKUP_DIR/$DATE/"

# Update 'latest' symlink
rm -f "$LINK_DEST"
ln -s "$BACKUP_DIR/$DATE" "$LINK_DEST"

# This creates space-efficient incremental backups!
```

### Archive Creation and Compression

#### Understanding tar Archives

**tar** (Tape Archive) bundles files together, like putting files in a box:

```bash
# Create archive:
tar -cvf archive.tar /path/to/files
# -c = create
# -v = verbose (show files)
# -f = filename follows

# With compression:
tar -czf archive.tar.gz /path/to/files   # gzip compression (.tar.gz or .tgz)
tar -cjf archive.tar.bz2 /path/to/files  # bzip2 (better compression, slower)
tar -cJf archive.tar.xz /path/to/files   # xz (best compression, slowest)

# Extract archive:
tar -xf archive.tar              # Auto-detects compression
tar -xzf archive.tar.gz          # Explicitly for gzip
tar -xvf archive.tar              # Verbose extraction

# Extract to specific directory:
tar -xf archive.tar -C /destination/

# List contents without extracting:
tar -tf archive.tar
tar -tzf archive.tar.gz

# Extract specific files:
tar -xf archive.tar path/to/specific/file

# Create with absolute paths removed (safer):
tar -czf backup.tar.gz -C /home/john .
# -C = change to directory first
# . = archive current directory

# Exclude files:
tar -czf backup.tar.gz --exclude='*.log' --exclude='cache/*' /data/

# Create incremental archive:
tar -czf backup-$(date +%Y%m%d).tar.gz \
    --listed-incremental=/backup/snapshot.snar \
    /data/
# First run creates full backup
# Subsequent runs create incremental
```

#### Compression Tools Comparison

```bash
# Let's compare compression methods:

# Original file:
ls -lh bigfile.txt
# -rw-r--r-- 1 john john 100M Dec 10 10:00 bigfile.txt

# gzip (fast, common):
gzip -k bigfile.txt    # -k = keep original
ls -lh bigfile.txt.gz
# -rw-r--r-- 1 john john 27M Dec 10 10:01 bigfile.txt.gz
# 73% compression, fast

# bzip2 (better compression):
bzip2 -k bigfile.txt
ls -lh bigfile.txt.bz2
# -rw-r--r-- 1 john john 22M Dec 10 10:02 bigfile.txt.bz2
# 78% compression, slower

# xz (best compression):
xz -k bigfile.txt
ls -lh bigfile.txt.xz
# -rw-r--r-- 1 john john 18M Dec 10 10:05 bigfile.txt.xz
# 82% compression, slowest

# Decompress:
gunzip bigfile.txt.gz   # or: gzip -d
bunzip2 bigfile.txt.bz2 # or: bzip2 -d
unxz bigfile.txt.xz     # or: xz -d

# View compressed files without extracting:
zcat file.gz      # View gzip
bzcat file.bz2    # View bzip2
xzcat file.xz     # View xz
zless file.gz     # Page through compressed file
```

### Automated Backup Solutions

#### Creating a Backup Script

```bash
#!/bin/bash
# /usr/local/bin/backup.sh - Comprehensive backup script

# Configuration
BACKUP_SOURCE="/home /etc /var/www"
BACKUP_DEST="/backup"
REMOTE_HOST="backup-server"
REMOTE_PATH="/remote-backup"
RETENTION_DAYS=30
DATE=$(date +%Y%m%d_%H%M%S)
LOG_FILE="/var/log/backup.log"

# Function to log messages
log_message() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

# Start backup
log_message "Starting backup..."

# Create backup directory
BACKUP_DIR="$BACKUP_DEST/$DATE"
mkdir -p "$BACKUP_DIR"

# Backup each source
for SOURCE in $BACKUP_SOURCE; do
    if [ -d "$SOURCE" ]; then
        log_message "Backing up $SOURCE..."
        tar -czf "$BACKUP_DIR/$(basename $SOURCE).tar.gz" \
            --exclude='*.tmp' \
            --exclude='cache/*' \
            "$SOURCE" 2>> "$LOG_FILE"
    fi
done

# Create backup metadata
cat > "$BACKUP_DIR/backup-info.txt" << EOF
Backup Date: $DATE
Source: $BACKUP_SOURCE
Hostname: $(hostname)
Total Size: $(du -sh "$BACKUP_DIR" | awk '{print $1}')
EOF

# Sync to remote server
if ping -c 1 "$REMOTE_HOST" &> /dev/null; then
    log_message "Syncing to remote server..."
    rsync -avz "$BACKUP_DIR" "$REMOTE_HOST:$REMOTE_PATH/" 2>> "$LOG_FILE"
else
    log_message "WARNING: Remote host unreachable"
fi

# Clean old backups
log_message "Cleaning old backups..."
find "$BACKUP_DEST" -maxdepth 1 -type d -mtime +$RETENTION_DAYS -exec rm -rf {} \;

# Create latest symlink
ln -sfn "$BACKUP_DIR" "$BACKUP_DEST/latest"

# Check backup size
BACKUP_SIZE=$(du -sh "$BACKUP_DIR" | awk '{print $1}')
log_message "Backup complete. Size: $BACKUP_SIZE"

# Send notification (optional)
# echo "Backup completed successfully" | mail -s "Backup Report" admin@example.com

# Make executable:
# chmod +x /usr/local/bin/backup.sh
```

#### Scheduling Backups

```bash
# Method 1: Cron
crontab -e

# Daily at 2 AM:
0 2 * * * /usr/local/bin/backup.sh

# Weekly on Sunday at 3 AM:
0 3 * * 0 /usr/local/bin/backup.sh

# Method 2: Systemd timer
# Create service unit:
sudo nano /etc/systemd/system/backup.service

[Unit]
Description=System Backup
After=multi-user.target

[Service]
Type=oneshot
ExecStart=/usr/local/bin/backup.sh
StandardOutput=journal
StandardError=journal

# Create timer unit:
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

# Enable timer:
sudo systemctl daemon-reload
sudo systemctl enable --now backup.timer

# Check timer status:
systemctl list-timers | grep backup
```

### Backup Testing and Recovery

#### Testing Your Backups

```bash
# A backup isn't a backup until you've tested restore!

# Test restore script:
#!/bin/bash
# /usr/local/bin/test-restore.sh

BACKUP_FILE="/backup/latest/home.tar.gz"
TEST_DIR="/tmp/restore-test"
ORIGINAL_DIR="/home"

# Create test directory
rm -rf "$TEST_DIR"
mkdir -p "$TEST_DIR"

# Extract backup
echo "Extracting backup..."
tar -xzf "$BACKUP_FILE" -C "$TEST_DIR"

# Compare with original
echo "Comparing with original..."
diff -r "$TEST_DIR/home" "$ORIGINAL_DIR" > /tmp/restore-diff.txt

if [ -s /tmp/restore-diff.txt ]; then
    echo "WARNING: Differences found!"
    head -20 /tmp/restore-diff.txt
else
    echo "SUCCESS: Backup matches original"
fi

# Cleanup
rm -rf "$TEST_DIR"

# Run monthly:
# 0 0 1 * * /usr/local/bin/test-restore.sh
```

#### Recovery Procedures

```bash
# Full System Recovery Process:

# 1. Boot from Rocky Linux installation media
# 2. Choose "Rescue" mode
# 3. Mount your system

# Mount root filesystem:
mkdir /mnt/sysroot
mount /dev/mapper/rl-root /mnt/sysroot
mount /dev/sda1 /mnt/sysroot/boot

# Restore from backup:
cd /mnt/sysroot
tar -xzf /path/to/backup.tar.gz

# Fix permissions if needed:
restorecon -Rv /mnt/sysroot

# Reinstall bootloader if needed:
chroot /mnt/sysroot
grub2-install /dev/sda
grub2-mkconfig -o /boot/grub2/grub.cfg

# Exit and reboot:
exit
reboot

# Selective file recovery:
# List files in archive:
tar -tzf backup.tar.gz | grep important-file

# Extract specific file:
tar -xzf backup.tar.gz path/to/important-file

# Extract to different location:
tar -xzf backup.tar.gz -C /tmp path/to/important-file
```

## Practice Exercises

### Exercise 1: Storage Setup
1. Add a new 10GB disk to your VM
2. Create GPT partition table with 3 partitions (2GB, 3GB, 5GB)
3. Format them as XFS, ext4, and XFS
4. Mount them at /data, /backup, and /archive
5. Configure automatic mounting in /etc/fstab
6. Test with reboot

### Exercise 2: LVM Configuration
1. Add two new 5GB disks
2. Create physical volumes on both
3. Create volume group "app_vg"
4. Create 3 logical volumes: web (3GB), db (4GB), logs (2GB)
5. Format and mount them appropriately
6. Extend web volume by 1GB
7. Create and test a snapshot of db volume

### Exercise 3: Backup Implementation
1. Create a backup script for /etc and /home
2. Implement daily incremental backups using rsync
3. Keep 7 daily, 4 weekly, and 3 monthly backups
4. Set up automatic cleanup of old backups
5. Schedule with systemd timer
6. Test restore procedure

### Exercise 4: Advanced Storage
1. Set up Stratis pool with one disk
2. Create two filesystems in the pool
3. Take a snapshot
4. Add a second disk to expand the pool
5. Monitor usage and performance

## Summary

In Part 3, we've mastered storage and filesystem management in Rocky Linux:

**Storage Fundamentals:**
- Understanding block devices and naming conventions
- Partitioning with MBR and GPT
- Creating and managing filesystems
- Mounting and automounting strategies

**LVM Flexibility:**
- Creating expandable storage pools
- Resizing volumes on the fly
- Taking snapshots for backups
- Managing storage dynamically

**Backup Strategies:**
- Implementing the 3-2-1 rule
- Using rsync for efficient backups
- Creating compressed archives
- Automating backup processes
- Testing recovery procedures

**Advanced Technologies:**
- Stratis for simplified management
- VDO for deduplication and compression
- Modern systemd mount units

These skills enable you to:
- Manage storage professionally
- Implement reliable backup strategies
- Recover from disasters
- Optimize storage usage
- Scale storage as needed

## Additional Resources

- [Rocky Linux Storage Guide](https://docs.rockylinux.org/books/admin_guide/08-filesystems/)
- [Red Hat LVM Administration](https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/8/html/configuring_and_managing_logical_volumes/index)
- [Stratis Documentation](https://stratis-storage.github.io/)
- [VDO Documentation](https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/8/html/deduplicating_and_compressing_storage/index)
- [Rsync Documentation](https://rsync.samba.org/documentation.html)

---

*Continue to Part 4: Networking and Security*