# Part 2: Core System Administration

## Prerequisites

Before starting this section, you should understand:
- Basic command line navigation (covered in Part 1)
- How to use a text editor (nano or vim)
- The concept of users and permissions
- How to connect to your server via SSH

**Resources for Review:**
- Linux Users and Groups: https://www.linux.com/training-tutorials/understanding-linux-users-and-groups/
- File Permissions: https://www.linux.com/training-tutorials/understanding-linux-file-permissions/
- Systemd Basics: https://www.freedesktop.org/wiki/Software/systemd/

---

## Chapter 4: User and Group Management

### Understanding Linux Users

Linux is a **multi-user operating system**, meaning multiple people can use the same computer simultaneously, each with their own settings, files, and permissions. Even on a single-user server, the concept of users is crucial for security and service isolation.

#### Why Multiple Users Matter

Think of users like different employees in an office building:
- **The CEO (root)**: Has keys to every room, can change anything
- **Employees (regular users)**: Have keys to their own offices and common areas
- **Service staff (system users)**: Have keys only to specific areas they maintain
- **Visitors (nobody/guest)**: Very limited access

This separation ensures:
1. **Security**: A compromised web server user can't access database files
2. **Accountability**: Actions can be traced to specific users
3. **Isolation**: Users can't accidentally (or maliciously) affect each other

#### Types of Users

```bash
# View all users on the system
cat /etc/passwd

# This file contains user account information
# Format: username:password:UID:GID:comment:home:shell
# Example line:
ubuntu:x:1000:1000:Ubuntu,,,:/home/ubuntu:/bin/bash

# Let's break this down:
# ubuntu        - Username (login name)
# x             - Password placeholder (actual password in /etc/shadow)
# 1000          - User ID (UID) - unique number identifying the user
# 1000          - Primary Group ID (GID)
# Ubuntu,,,     - GECOS field (full name, office, phone, etc.)
# /home/ubuntu  - Home directory
# /bin/bash     - Default shell (command interpreter)
```

**User ID (UID) Ranges:**
- **0**: root user (administrator)
- **1-999**: System users (services like www-data, mysql)
- **1000+**: Regular users (humans)

```bash
# See UIDs in action
id              # Shows current user's IDs
id ubuntu       # Shows specific user's IDs

# Output explanation:
# uid=1000(ubuntu) gid=1000(ubuntu) groups=1000(ubuntu),4(adm),27(sudo)
# uid=1000(ubuntu)     - User ID and name
# gid=1000(ubuntu)     - Primary group ID and name
# groups=...           - All groups this user belongs to
```

### Creating Users: The Complete Guide

There are two main commands for creating users: `adduser` (Ubuntu-friendly) and `useradd` (low-level). Let's understand both:

#### Using adduser (Recommended for Beginners)

```bash
# adduser is interactive and user-friendly
sudo adduser johndoe

# What happens during this command:
# 1. Creates user account
# 2. Creates home directory (/home/johndoe)
# 3. Copies skeleton files from /etc/skel
# 4. Creates a group with same name
# 5. Prompts for password
# 6. Prompts for user information

# The skeleton directory (/etc/skel)
ls -la /etc/skel
# Files here are copied to every new user's home directory
# Typically includes:
# .bashrc     - Bash configuration
# .profile    - Login script
# .bash_logout - Logout script
```

#### Using useradd (Low-Level Command)

```bash
# useradd requires more options but gives more control
sudo useradd -m -s /bin/bash -G sudo,docker -c "John Doe" johndoe

# Let's understand each option:
# -m             : Create home directory
# -s /bin/bash   : Set default shell
# -G sudo,docker : Add to additional groups
# -c "John Doe"  : Comment (full name)
# johndoe        : Username

# useradd doesn't set a password, do it separately:
sudo passwd johndoe

# Other useful useradd options:
# -d /custom/home    : Custom home directory
# -u 1500           : Specific UID
# -g groupname      : Primary group
# -e 2024-12-31     : Account expiry date
# -f 30             : Days until account is disabled after password expires
# -k /custom/skel   : Custom skeleton directory
```

#### System Users vs Regular Users

```bash
# Create a system user (for services, not humans)
sudo useradd -r -s /usr/sbin/nologin -d /var/lib/myapp -m myapp

# Why these options for system users:
# -r                    : System user (UID < 1000)
# -s /usr/sbin/nologin  : Cannot log in interactively
# -d /var/lib/myapp     : Home in /var/lib (not /home)
# -m                    : Create the directory

# System users are for running services securely:
# - Can't log in with password
# - Limited permissions
# - Service-specific home directories

# Example: See existing system users
awk -F: '$3 < 1000 {print $1 " (UID: " $3 ")"}' /etc/passwd | head -10
```

### Understanding Groups

**Groups** are collections of users. They simplify permission management - instead of giving permissions to each user individually, you give permissions to a group.

#### Primary vs Supplementary Groups

```bash
# Every user has:
# 1. One primary group (used for new files they create)
# 2. Zero or more supplementary groups

# See a user's groups
groups johndoe
# Output: johndoe : johndoe sudo docker

# First group (johndoe) is primary
# Others (sudo, docker) are supplementary

# Why this matters:
# When johndoe creates a file, it's owned by user:johndoe group:johndoe
# But johndoe can also access files owned by groups sudo and docker
```

#### Creating and Managing Groups

```bash
# Create a new group
sudo groupadd developers

# Create group with specific GID
sudo groupadd -g 2000 project-team

# View group information
getent group developers
# Output: developers:x:1001:
# Format: groupname:password:GID:members

# Add user to group (supplementary)
sudo usermod -aG developers johndoe
# IMPORTANT: -a means "append" - without it, you REPLACE all groups!

# Alternative way to add user to group
sudo gpasswd -a johndoe developers

# Remove user from group
sudo gpasswd -d johndoe developers

# Delete a group
sudo groupdel oldgroup
# Note: Can't delete if it's someone's primary group
```

#### Practical Group Example: Web Development Team

```bash
#!/bin/bash
# setup_web_team.sh - Create structure for web development team

# Create groups for different roles
sudo groupadd webdev
sudo groupadd frontend
sudo groupadd backend
sudo groupadd deploy

# Create shared directories
sudo mkdir -p /var/www/{shared,frontend,backend}

# Set group ownership
sudo chgrp webdev /var/www/shared
sudo chgrp frontend /var/www/frontend
sudo chgrp backend /var/www/backend

# Set permissions (group can read/write/enter)
sudo chmod 2775 /var/www/shared    # 2 = SGID bit
sudo chmod 2775 /var/www/frontend
sudo chmod 2775 /var/www/backend

# SGID bit explanation:
# When set on a directory (2xxx or g+s):
# - New files inherit the directory's group
# - Without SGID: files owned by creator's primary group
# - With SGID: files owned by directory's group

# Create users with appropriate groups
sudo useradd -m -G webdev,frontend alice
sudo useradd -m -G webdev,backend bob
sudo useradd -m -G webdev,deploy,frontend,backend charlie

echo "Team structure created!"
echo "Alice can work on: shared, frontend"
echo "Bob can work on: shared, backend"
echo "Charlie can work on: everything and deploy"
```

### Password Management and Policies

Passwords are the first line of defense. Linux provides comprehensive tools for password management.

#### Understanding /etc/shadow

```bash
# Passwords aren't stored in /etc/passwd (despite the name)
# They're in /etc/shadow (readable only by root)

sudo cat /etc/shadow | grep johndoe
# johndoe:$6$rounds=5000$salt$hash:19000:0:99999:7:::

# Let's decode this:
# johndoe                           : Username
# $6$rounds=5000$salt$hash         : Encrypted password
#   $6$ = SHA-512 encryption
#   $rounds=5000$ = Key stretching iterations
#   salt = Random data to prevent rainbow tables
#   hash = The actual encrypted password
# 19000                            : Days since Jan 1, 1970 password was changed
# 0                                : Minimum days before can change again
# 99999                            : Maximum days before must change
# 7                                : Warning days before expiry
# :                                : Inactivity period (empty)
# :                                : Account expiry (empty)
```

#### Setting Password Policies

```bash
# Install password quality tools
sudo apt install libpam-pwquality

# Configure password complexity
sudo nano /etc/security/pwquality.conf

# Add these lines with explanations:
# Minimum password length
minlen = 12

# Require at least 1 digit (-1 = must have, 1 = +1 credit for having)
dcredit = -1

# Require at least 1 uppercase letter
ucredit = -1

# Require at least 1 lowercase letter
lcredit = -1

# Require at least 1 special character
ocredit = -1

# Require at least 3 different character classes
minclass = 3

# Maximum repeated characters (aaaa would fail with 3)
maxrepeat = 3

# Maximum sequence (abcd or 1234 would fail with 3)
maxsequence = 3

# Check if password contains username (1 = yes)
usercheck = 1

# Enforce for root user too (1 = yes)
enforce_for_root = 1

# How it works:
# PAM (Pluggable Authentication Modules) checks these rules
# when users change passwords with passwd command
```

#### Password Aging with chage

```bash
# chage = "change age" - manages password aging

# View password aging info
sudo chage -l johndoe

# Output explanation:
# Last password change                     : Jan 15, 2024
# Password expires                         : Apr 15, 2024
# Password inactive                        : never
# Account expires                          : never
# Minimum number of days between password change : 7
# Maximum number of days between password change : 90
# Number of days of warning before password expires : 14

# Set password aging
sudo chage -M 90 johndoe    # Must change every 90 days
sudo chage -m 7 johndoe     # Can't change for 7 days after changing
sudo chage -W 14 johndoe    # Warn 14 days before expiry
sudo chage -I 30 johndoe    # Disable account 30 days after expiry

# Force password change at next login
sudo passwd -e johndoe
# or
sudo chage -d 0 johndoe

# Set account expiry (different from password expiry)
sudo chage -E 2024-12-31 johndoe    # Account expires on this date
sudo chage -E -1 johndoe            # Never expire (remove expiry)
```

### User Resource Limits

Linux can limit resources per user to prevent one user from consuming everything.

#### Understanding ulimit

```bash
# ulimit controls resource limits for current shell

# View current limits
ulimit -a

# Output with explanations:
# core file size          (blocks, -c) 0        # Core dump size
# data seg size           (kbytes, -d) unlimited # Data segment
# scheduling priority             (-e) 0         # Nice priority
# file size               (blocks, -f) unlimited # File size
# pending signals                 (-i) 7609      # Signal queue
# max locked memory       (kbytes, -l) 64        # Locked RAM
# max memory size         (kbytes, -m) unlimited # RAM usage
# open files                      (-n) 1024      # File descriptors
# pipe size            (512 bytes, -p) 8         # Pipe buffer
# POSIX message queues     (bytes, -q) 819200    # Message queues
# real-time priority              (-r) 0         # RT priority
# stack size              (kbytes, -s) 8192      # Stack size
# cpu time               (seconds, -t) unlimited # CPU time
# max user processes              (-u) 7609      # Process count
# virtual memory          (kbytes, -v) unlimited # Virtual memory
# file locks                      (-x) unlimited # File locks

# Set temporary limits
ulimit -n 4096    # Increase open files limit
ulimit -u 100     # Limit to 100 processes
```

#### Persistent Limits in /etc/security/limits.conf

```bash
# Edit system-wide limits
sudo nano /etc/security/limits.conf

# Format: domain type item value
# domain: username, @groupname, * (everyone)
# type: soft (can be raised up to hard), hard (absolute limit)
# item: resource name
# value: limit value

# Examples with explanations:

# Limit john to 50 processes
john    hard    nproc    50

# Web servers often need many open files
www-data soft    nofile   4096
www-data hard    nofile   8192

# Prevent fork bombs (infinite process creation)
@users   hard    nproc    100

# Limit developers group memory usage
@developers hard memlock 1048576  # 1GB in KB

# Default limits for all users
*        soft    core     0         # No core dumps
*        hard    maxlogins 3        # Max 3 concurrent logins

# Why soft vs hard limits?
# soft: Starting/default limit
# hard: Maximum the user can raise to using ulimit
# User can raise soft up to hard, but not exceed hard
```

### Understanding sudo in Depth

**sudo** (Super User DO) is critical for Linux security. It allows users to run commands with elevated privileges without knowing the root password.

#### How sudo Works

```bash
# The sudo workflow:
# 1. User types: sudo command
# 2. sudo checks /etc/sudoers for permissions
# 3. Asks for USER's password (not root's)
# 4. If allowed, runs command as root
# 5. Logs the action

# Check your sudo privileges
sudo -l

# Output explanation:
# User johndoe may run the following commands on ubuntu-server:
#     (ALL : ALL) ALL

# Format: (run_as_user : run_as_group) commands
# (ALL : ALL) ALL means:
# Can run as any user, any group, any command
```

#### Configuring sudo with visudo

```bash
# ALWAYS use visudo to edit sudoers
sudo visudo

# Why visudo?
# - Checks syntax before saving
# - Prevents lockout from syntax errors
# - Uses file locking to prevent concurrent edits

# Basic sudoers syntax:
# who where = (as_whom) what

# Examples with detailed explanations:

# Give john full sudo access
john ALL=(ALL:ALL) ALL
# john: username
# ALL: from any terminal/host
# (ALL:ALL): as any user:any group
# ALL: any command

# Allow alice to restart web server without password
alice ALL=(ALL) NOPASSWD: /usr/bin/systemctl restart nginx
# NOPASSWD: don't ask for password
# Specific command: more secure than ALL

# Let developers group manage docker
%developers ALL=(ALL) NOPASSWD: /usr/bin/docker
# % prefix means group name

# Allow bob to run as www-data user
bob ALL=(www-data) ALL
# Now bob can: sudo -u www-data command

# Command aliases for organization
# Define command groups
Cmnd_Alias SHUTDOWN = /sbin/halt, /sbin/shutdown, /sbin/reboot
Cmnd_Alias NETWORKING = /sbin/ifconfig, /sbin/ip
Cmnd_Alias SOFTWARE = /usr/bin/apt, /usr/bin/snap

# User aliases
User_Alias ADMINS = john, jane, bob
User_Alias WEBTEAM = alice, charlie

# Now use aliases:
ADMINS ALL=(ALL) ALL
WEBTEAM ALL=(ALL) SOFTWARE, NETWORKING
```

#### sudo Best Practices

```bash
# Create separate sudoers files for organization
# Instead of editing main file, create modular configs:

sudo visudo -f /etc/sudoers.d/developers
# Add developer-specific rules

sudo visudo -f /etc/sudoers.d/webadmins
# Add web admin rules

# These files are automatically included

# Security recommendations:

# 1. Log sudo commands
# Add to sudoers:
Defaults        log_output
Defaults        log_input
Defaults        logfile="/var/log/sudo.log"

# 2. Set timeout (re-ask password after X minutes)
Defaults        timestamp_timeout=15

# 3. Lecture users (show warning)
Defaults        lecture="always"
Defaults        lecture_file="/etc/sudo_lecture.txt"

# 4. Restrict sudo to specific terminals
Defaults        requiretty

# 5. Environment variables to keep
Defaults        env_keep += "EDITOR VISUAL HOME"

# 6. Insults (show funny messages on wrong password - optional fun)
Defaults        insults
```

### Home Directory Management

Each user has a home directory - their personal space for files and settings.

#### Understanding Home Directories

```bash
# Home directory locations:
# Regular users: /home/username
# Root user: /root
# System users: varies (/var/lib/service, /usr/lib/service, etc.)

# See user's home directory
getent passwd johndoe | cut -d: -f6
# or
eval echo ~johndoe

# What's in a home directory?
ls -la /home/johndoe

# Typical contents:
# .bashrc          - Bash configuration
# .profile         - Login configuration
# .ssh/            - SSH keys and config
# .cache/          - Application cache
# .config/         - Application configs
# .local/          - User-specific apps/data
# Documents/       - User documents
# Downloads/       - Downloaded files

# Hidden files (starting with .) contain settings
```

#### Managing Disk Quotas

Disk quotas prevent users from using too much disk space.

```bash
# Install quota tools
sudo apt install quota

# Enable quotas on filesystem
# Edit /etc/fstab
sudo nano /etc/fstab

# Add usrquota,grpquota to mount options:
# UUID=xxx /home ext4 defaults,usrquota,grpquota 0 2

# Remount filesystem
sudo mount -o remount /home

# Initialize quota database
sudo quotacheck -cugm /home

# Turn on quotas
sudo quotaon -v /home

# Set user quota
sudo setquota -u johndoe 1G 1.5G 0 0 /home

# Format: setquota -u username soft_limit hard_limit inode_soft inode_hard filesystem
# 1G soft limit: Warning at 1GB
# 1.5G hard limit: Absolute max
# 0 0: No inode (file count) limits

# View user's quota
sudo quota -u johndoe

# Report all users' disk usage
sudo repquota -a
```

---

## Chapter 5: File System Permissions

### The Linux Permission Model

Linux permissions are like a security system for files and folders. Every file has three types of permissions for three categories of users.

#### Permission Types

```bash
# Three permission types:
# r (read)    - View file contents or list directory
# w (write)   - Modify file or create/delete in directory
# x (execute) - Run file as program or enter directory

# Three user categories:
# u (user)  - The file owner
# g (group) - The file's group
# o (other) - Everyone else

# See permissions:
ls -l myfile.txt
# -rw-r--r-- 1 john developers 1234 Jan 15 10:30 myfile.txt

# Breaking down: -rw-r--r--
# Position 1: - (file type)
#   - = regular file
#   d = directory
#   l = symbolic link
#   b = block device (disk)
#   c = character device (terminal)
#   s = socket
#   p = pipe

# Positions 2-4: rw- (owner permissions)
#   r = can read
#   w = can write
#   - = cannot execute

# Positions 5-7: r-- (group permissions)
#   r = can read
#   - = cannot write
#   - = cannot execute

# Positions 8-10: r-- (others permissions)
```

#### Numeric (Octal) Notation

```bash
# Each permission has a numeric value:
# r (read) = 4
# w (write) = 2
# x (execute) = 1

# Add them up for each category:
# rwx = 4+2+1 = 7 (all permissions)
# rw- = 4+2+0 = 6 (read and write)
# r-x = 4+0+1 = 5 (read and execute)
# r-- = 4+0+0 = 4 (read only)

# Common permission combinations:
# 777 = rwxrwxrwx (everyone can do everything - DANGEROUS!)
# 755 = rwxr-xr-x (owner: all, others: read/execute)
# 644 = rw-r--r-- (owner: read/write, others: read only)
# 600 = rw------- (owner only can read/write)
# 700 = rwx------ (owner only can do everything)

# Why use numbers?
# Faster to type: chmod 755 vs chmod u=rwx,g=rx,o=rx
```

### Special Permissions: SUID, SGID, and Sticky Bit

Beyond basic permissions, Linux has three special permissions for specific security needs.

#### SUID (Set User ID)

```bash
# SUID on executable files makes them run as the file owner
# not as the user running them

# Example: passwd command
ls -l /usr/bin/passwd
# -rwsr-xr-x 1 root root 68208 May 28 2020 /usr/bin/passwd
#     ^
#     s = SUID bit set

# How it works:
# 1. passwd is owned by root
# 2. When john runs passwd, it runs with root privileges
# 3. This allows john to modify /etc/shadow (only root can)
# 4. passwd is carefully written to only change john's password

# Set SUID
chmod u+s program       # Symbolic method
chmod 4755 program      # Numeric method (4xxx)

# Find all SUID programs (potential security risk)
find / -perm -4000 -type f 2>/dev/null

# Why SUID is dangerous:
# If a SUID root program has a bug, attackers can gain root access
# Only use SUID when absolutely necessary
```

#### SGID (Set Group ID)

```bash
# SGID has two uses:
# 1. On files: Run with group's permissions
# 2. On directories: New files inherit directory's group

# SGID on directory (most common use)
mkdir /shared/project
chgrp developers /shared/project
chmod g+s /shared/project    # or chmod 2775

# Now when anyone creates files in /shared/project:
# - Files are owned by group 'developers' (not user's primary group)
# - All team members can collaborate

# Example:
sudo -u alice touch /shared/project/alice-file.txt
sudo -u bob touch /shared/project/bob-file.txt
ls -l /shared/project/
# Both files have group 'developers', not alice/bob's primary groups

# Find SGID directories
find / -perm -2000 -type d 2>/dev/null
```

#### Sticky Bit

```bash
# Sticky bit on directories prevents users from deleting
# files they don't own (even if they have write permission)

# Classic example: /tmp directory
ls -ld /tmp
# drwxrwxrwt 23 root root 4096 Jan 15 12:00 /tmp
#          ^
#          t = sticky bit

# How it works in /tmp:
# - Everyone can create files (rwx for others)
# - Everyone can only delete their own files
# - Prevents users from deleting each other's temp files

# Set sticky bit
chmod +t /shared/uploads    # Symbolic
chmod 1777 /shared/uploads  # Numeric (1xxx)

# Create a shared scratch directory
sudo mkdir /shared/scratch
sudo chmod 1777 /shared/scratch

# Now users can share the directory but can't mess with each other's files
```

### Access Control Lists (ACLs)

Traditional permissions have limitations - you can only set permissions for one user and one group. ACLs provide fine-grained control.

#### Why Use ACLs?

```bash
# Problem: You want to give specific permissions to multiple users
# Traditional permissions can't do this - only one owner, one group

# Solution: ACLs let you set permissions for multiple users/groups

# Install ACL tools
sudo apt install acl

# Check if filesystem supports ACLs
mount | grep acl
# If not shown, enable ACLs:
sudo mount -o remount,acl /
```

#### Using ACLs

```bash
# View ACLs
getfacl filename

# Output explanation:
# # file: filename
# # owner: john
# # group: developers
# user::rw-           # Owner permissions
# user:alice:r--      # Specific user alice can read
# group::r--          # Group permissions
# group:admins:rw-    # Specific group admins can read/write
# mask::rw-           # Maximum permissions for users/groups
# other::r--          # Others permissions

# Set ACL for specific user
setfacl -m u:alice:rw report.txt
# -m = modify
# u:alice:rw = user alice gets read/write

# Set ACL for specific group
setfacl -m g:finance:r report.txt

# Remove specific ACL
setfacl -x u:alice report.txt

# Remove all ACLs
setfacl -b report.txt

# Default ACLs (inherited by new files)
setfacl -d -m u:alice:rw /shared/directory/
# -d = default
# New files in /shared/directory/ will give alice read/write

# Recursive ACLs
setfacl -R -m u:www-data:rx /var/www/
# -R = recursive

# Backup and restore ACLs
getfacl -R /important/ > acl_backup.txt
setfacl --restore=acl_backup.txt
```

#### Practical ACL Example

```bash
#!/bin/bash
# Setup shared project directory with ACLs

PROJECT="/shared/project-alpha"

# Create directory
sudo mkdir -p "$PROJECT"

# Set basic permissions
sudo chown project-lead:developers "$PROJECT"
sudo chmod 770 "$PROJECT"

# Add ACLs for specific access
# Project lead: full access
sudo setfacl -m u:project-lead:rwx "$PROJECT"

# Developers: read/write
sudo setfacl -m g:developers:rwx "$PROJECT"

# QA team: read only
sudo setfacl -m g:qa-team:rx "$PROJECT"

# Specific contractor: read access
sudo setfacl -m u:contractor1:rx "$PROJECT"

# Auditor: read access to everything
sudo setfacl -m u:auditor:rx "$PROJECT"

# Set default ACLs for new files
sudo setfacl -d -m u:project-lead:rwx "$PROJECT"
sudo setfacl -d -m g:developers:rwx "$PROJECT"
sudo setfacl -d -m g:qa-team:rx "$PROJECT"
sudo setfacl -d -m u:contractor1:rx "$PROJECT"

echo "ACLs configured. View with: getfacl $PROJECT"
```

### Understanding umask

**umask** determines default permissions for new files and directories. It's a mask that subtracts from maximum permissions.

```bash
# How umask works:
# Maximum permissions:
#   Files: 666 (rw-rw-rw-)
#   Directories: 777 (rwxrwxrwx)
# umask subtracts from these

# View current umask
umask
# Output: 0022

# Calculate resulting permissions:
# Files: 666 - 022 = 644 (rw-r--r--)
# Directories: 777 - 022 = 755 (rwxr-xr-x)

# Common umask values:
# 022 - Default, secure for most systems
#   Files: 644, Directories: 755
# 027 - More restrictive, good for sensitive systems
#   Files: 640, Directories: 750
# 077 - Private, only owner has access
#   Files: 600, Directories: 700
# 002 - Group-writable, for collaborative environments
#   Files: 664, Directories: 775

# Set umask temporarily
umask 027

# Make permanent for user
echo "umask 027" >> ~/.bashrc

# System-wide default
sudo nano /etc/login.defs
# Find and edit: UMASK 027

# For specific service
# Edit systemd service file:
[Service]
UMask=0027
```

### File Attributes

Linux supports extended attributes that provide additional file properties beyond permissions.

```bash
# View file attributes
lsattr file.txt

# Common attributes:
# a - Append only (can add but not modify)
# i - Immutable (cannot modify or delete)
# s - Secure deletion (overwrite when deleted)
# u - Undeletable
# c - Compressed
# e - Extent format (for ext4)

# Set immutable attribute (even root cannot modify!)
sudo chattr +i /etc/critical.conf

# Try to modify - will fail
echo "test" >> /etc/critical.conf
# bash: /etc/critical.conf: Operation not permitted

# Remove immutable attribute
sudo chattr -i /etc/critical.conf

# Set append-only (perfect for log files)
sudo chattr +a /var/log/secure.log
# Can append: echo "log entry" >> /var/log/secure.log
# Cannot overwrite: echo "log" > /var/log/secure.log  # Fails

# Recursively set attributes
sudo chattr -R +i /etc/ssl/private/

# Why use attributes?
# - Protect critical files from accidental changes
# - Ensure logs aren't tampered with
# - Comply with security requirements
```

---

## Chapter 6: System Services with Systemd

### What is Systemd?

**Systemd** is the initialization system for Ubuntu and most modern Linux distributions. It's the first process that starts (PID 1) and it manages all other processes.

Think of systemd like the manager of a large building:
- **Starts everything**: Turns on lights, HVAC, elevators (boots the system)
- **Manages services**: Keeps track of what's running (web servers, databases)
- **Handles requests**: Responds to "start the web server" or "stop the database"
- **Logs everything**: Records what happens for troubleshooting
- **Schedules tasks**: Like a building's automated systems

#### Why Systemd Replaced Older Systems

```bash
# Before systemd (SysV init):
# - Sequential startup (slow)
# - Shell scripts for each service
# - Complex dependencies
# - Limited monitoring

# With systemd:
# - Parallel startup (fast)
# - Declarative service files
# - Automatic dependency resolution
# - Built-in monitoring and restart

# See systemd in action
systemctl --version

# View boot time
systemd-analyze

# Output explanation:
# Startup finished in 3.241s (kernel) + 15.234s (userspace) = 18.476s
# kernel: Linux kernel boot time
# userspace: Systemd and services startup time
```

### Understanding Units

Systemd manages "units" - resources it knows how to manage. Think of units as different types of things systemd can control.

```bash
# Types of units:
# .service - Programs that run in background (web servers, databases)
# .socket  - Network or IPC sockets
# .device  - Hardware devices
# .mount   - Mount points for filesystems
# .timer   - Scheduled tasks (like cron)
# .target  - Groups of units (like runlevels)
# .path    - Watches for file/directory changes

# List all units
systemctl list-units

# List specific type
systemctl list-units --type=service

# View unit file
systemctl cat nginx.service
```

### Managing Services

Services are the most common unit type - background programs that provide functionality.

#### Basic Service Management

```bash
# Start a service
sudo systemctl start nginx
# What happens: Systemd runs the ExecStart command in the service file

# Stop a service
sudo systemctl stop nginx
# What happens: Systemd runs ExecStop or sends SIGTERM

# Restart a service
sudo systemctl restart nginx
# What happens: Stops then starts (brief downtime)

# Reload configuration
sudo systemctl reload nginx
# What happens: Sends SIGHUP to reload config (no downtime)

# Check status
systemctl status nginx

# Understanding status output:
# ● nginx.service - A high performance web server
#    Loaded: loaded (/lib/systemd/system/nginx.service; enabled; vendor preset: enabled)
#    Active: active (running) since Mon 2024-01-15 10:00:00 UTC; 1h 30min ago
#      Docs: man:nginx(8)
#  Main PID: 12345 (nginx)
#     Tasks: 2 (limit: 2238)
#    Memory: 8.0M
#    CGroup: /system.slice/nginx.service
#            ├─12345 nginx: master process
#            └─12346 nginx: worker process

# Explanation:
# ● (dot) - State indicator (green=running, red=failed, white=inactive)
# Loaded - Service file found and parsed
# enabled - Starts at boot
# Active - Current state with timestamp
# Main PID - Process ID of main process
# Tasks - Number of tasks/threads
# Memory - Current memory usage
# CGroup - Control group (for resource management)
```

#### Enabling Services at Boot

```bash
# Enable service (start at boot)
sudo systemctl enable nginx

# What this does:
# Creates symbolic link from /etc/systemd/system/multi-user.target.wants/
# to the actual service file

# Disable service (don't start at boot)
sudo systemctl disable nginx

# Enable and start in one command
sudo systemctl enable --now nginx

# Check if enabled
systemctl is-enabled nginx

# Mask service (prevent starting even manually)
sudo systemctl mask nginx
# Creates link to /dev/null

# Unmask service
sudo systemctl unmask nginx
```

### Creating Custom Services

Let's create a service for a Python web application:

```bash
# Create service file
sudo nano /etc/systemd/system/myapp.service
```

```ini
[Unit]
# Unit section - metadata and dependencies
Description=My Python Web Application
Documentation=https://myapp.example.com/docs
After=network.target
# After - Start after network is ready
# Before - Start before another service
# Wants - Weak dependency (start if possible)
# Requires - Strong dependency (fail if dependency fails)

[Service]
# Service section - how to run the service
Type=simple
# Type explanations:
# simple - Main process stays in foreground (default)
# forking - Process forks and parent exits (traditional daemons)
# oneshot - Process exits after running (for scripts)
# notify - Service notifies systemd when ready
# idle - Start after all jobs are done

# User and group to run as
User=www-data
Group=www-data

# Working directory
WorkingDirectory=/var/www/myapp

# Environment variables
Environment="FLASK_ENV=production"
Environment="PATH=/var/www/myapp/venv/bin:/usr/bin:/bin"

# Command to start service
ExecStart=/var/www/myapp/venv/bin/python app.py

# Command to reload (optional)
ExecReload=/bin/kill -HUP $MAINPID

# Restart policy
Restart=always
# Restart options:
# always - Always restart if stops
# on-failure - Only if exits with error
# on-abnormal - If crashes or killed
# on-abort - Only on abort
# on-success - Only if exits successfully
# no - Never restart (default)

RestartSec=5
# Wait 5 seconds before restart

# Output to journal
StandardOutput=journal
StandardError=journal

# Security settings
PrivateTmp=true          # Isolated /tmp
NoNewPrivileges=true     # Can't gain privileges
ProtectSystem=strict     # Read-only filesystem
ProtectHome=true         # No access to /home
ReadWritePaths=/var/www/myapp/uploads

[Install]
# Install section - how to enable the service
WantedBy=multi-user.target
# WantedBy - Which target should include this service
# multi-user.target - Normal system startup (no GUI)
# graphical.target - GUI system
```

After creating the service:

```bash
# Reload systemd configuration
sudo systemctl daemon-reload

# Start service
sudo systemctl start myapp

# Check status
systemctl status myapp

# View logs
journalctl -u myapp -n 50
```

### Systemd Timers (Modern Cron)

Timers are systemd's way of scheduling tasks, more powerful than cron.

```bash
# Create timer file
sudo nano /etc/systemd/system/backup.timer
```

```ini
[Unit]
Description=Daily Backup Timer
Documentation=man:backup(1)

[Timer]
# When to run
OnCalendar=daily
# OnCalendar examples:
# daily                    - Once a day at midnight
# weekly                   - Once a week on Monday
# monthly                  - First day of month
# *-*-* 02:00:00          - Every day at 2 AM
# Mon..Fri *-*-* 09:00:00 - Weekdays at 9 AM
# *:0/15                  - Every 15 minutes
# 2024-*-* 00:00:00      - Every day in 2024

# Other timer options:
OnBootSec=10min         # After boot
OnUnitActiveSec=1h      # After last run
OnStartupSec=5min       # After systemd start

# Accuracy (default 1min)
AccuracySec=1s          # How accurate timing should be

# Persistent
Persistent=true         # Run if missed (system was off)

[Install]
WantedBy=timers.target
```

Create the corresponding service:

```bash
sudo nano /etc/systemd/system/backup.service
```

```ini
[Unit]
Description=System Backup
Documentation=man:backup(1)

[Service]
Type=oneshot
ExecStart=/usr/local/bin/backup.sh
StandardOutput=journal
StandardError=journal

# Note: No [Install] section needed for timer-activated services
```

Manage the timer:

```bash
# Enable and start timer
sudo systemctl enable --now backup.timer

# List all timers
systemctl list-timers

# Output shows:
# NEXT - When it will run next
# LEFT - Time until next run
# LAST - When it last ran
# PASSED - Time since last run
# UNIT - Timer name
# ACTIVATES - Service it triggers
```

### Systemd Targets (Boot Stages)

Targets are groups of units that represent system states. They replace traditional runlevels.

```bash
# View current target
systemctl get-default

# Common targets:
# poweroff.target    - System halt (runlevel 0)
# rescue.target      - Single user mode (runlevel 1)
# multi-user.target  - Multi-user, no GUI (runlevel 3)
# graphical.target   - Multi-user with GUI (runlevel 5)
# reboot.target      - System reboot (runlevel 6)

# Change default target
sudo systemctl set-default multi-user.target

# Switch target immediately
sudo systemctl isolate rescue.target
# WARNING: This changes system state immediately!

# View target dependencies
systemctl list-dependencies multi-user.target
```

### Journald - System Logging

Systemd includes journald, a centralized logging system that collects logs from all services.

```bash
# View all logs
journalctl

# Navigation in journalctl:
# Space - Next page
# b - Previous page
# g - Go to beginning
# G - Go to end
# / - Search forward
# ? - Search backward
# q - Quit

# Filter by time
journalctl --since "1 hour ago"
journalctl --since "2024-01-15" --until "2024-01-16"
journalctl --since yesterday

# Filter by service
journalctl -u nginx
journalctl -u nginx -u mysql  # Multiple services

# Filter by priority
journalctl -p err     # Error and above
journalctl -p warning # Warning and above

# Priority levels:
# 0: emerg   - System unusable
# 1: alert   - Action must be taken immediately
# 2: crit    - Critical conditions
# 3: err     - Error conditions
# 4: warning - Warning conditions
# 5: notice  - Normal but significant
# 6: info    - Informational
# 7: debug   - Debug messages

# Follow logs (like tail -f)
journalctl -f
journalctl -u nginx -f

# Output formats
journalctl -o json-pretty  # JSON format
journalctl -o cat          # Message only
journalctl -o short-full   # Full timestamp

# Show kernel messages
journalctl -k

# Show messages from current boot
journalctl -b
journalctl -b -1  # Previous boot

# Disk usage
journalctl --disk-usage

# Clean old logs
sudo journalctl --vacuum-time=2weeks
sudo journalctl --vacuum-size=100M
```

### Resource Management with Systemd

Systemd can limit resources per service using cgroups (control groups).

```bash
# In service file:
[Service]
# Memory limits
MemoryHigh=512M      # Soft limit (throttling starts)
MemoryMax=1G         # Hard limit (OOM killer)
MemorySwapMax=0      # No swap usage

# CPU limits
CPUQuota=50%         # Use max 50% of one CPU
CPUWeight=50         # Relative weight (default 100)

# I/O limits
IOWeight=50          # Relative I/O weight
IOReadBandwidthMax=/dev/sda 10M   # Read limit
IOWriteBandwidthMax=/dev/sda 5M   # Write limit

# Process limits
TasksMax=100         # Max number of tasks/threads

# View resource usage
systemd-cgtop        # Like top but for services

# Check specific service resources
systemctl status nginx
# Shows Memory and Tasks usage
```

### Troubleshooting Services

When services fail, systemd provides tools to diagnose issues:

```bash
# Check failed services
systemctl --failed

# Reset failed status
sudo systemctl reset-failed

# Debug a failing service
# 1. Check status
systemctl status problematic-service

# 2. View recent logs
journalctl -u problematic-service -n 50 --no-pager

# 3. Check configuration
systemd-analyze verify /etc/systemd/system/problematic.service

# 4. Run manually for testing
# Get the ExecStart command from service file
systemctl cat problematic-service | grep ExecStart
# Run it manually to see errors

# Common issues and solutions:

# Issue: Service fails immediately
# Check: Executable exists and has correct permissions
ls -la /path/to/executable

# Issue: Permission denied
# Check: User exists and has necessary permissions
id service-user
ls -la /var/lib/service-directory

# Issue: Service doesn't start at boot
# Check: Is it enabled?
systemctl is-enabled service-name
# Check: Dependencies available?
systemctl list-dependencies service-name

# Issue: Service keeps restarting
# Check: Logs for actual error
journalctl -u service-name -f
# Maybe increase RestartSec to avoid rapid restarts
```

### Advanced Systemd Features

#### Service Templates

Create reusable service definitions:

```bash
# Template service (note @ in filename)
sudo nano /etc/systemd/system/webapp@.service

[Unit]
Description=Web App Instance %i

[Service]
User=www-data
WorkingDirectory=/var/www/webapp-%i
ExecStart=/usr/bin/python3 app.py --port=%i
Restart=always

[Install]
WantedBy=multi-user.target

# Use template:
sudo systemctl start webapp@8001
sudo systemctl start webapp@8002
sudo systemctl enable webapp@8001

# %i is replaced with the instance name (8001, 8002)
```

#### Drop-in Files

Modify existing services without editing original files:

```bash
# Create drop-in directory
sudo mkdir /etc/systemd/system/nginx.service.d

# Create override file
sudo nano /etc/systemd/system/nginx.service.d/override.conf

[Service]
# Only include settings you want to change
MemoryMax=256M
Restart=always

# Apply changes
sudo systemctl daemon-reload
sudo systemctl restart nginx
```

### Key Takeaways

1. **Systemd is more than init** - It manages services, logs, timers, and resources
2. **Service files are declarative** - Describe what you want, not how to do it
3. **Use journalctl for logs** - Centralized, filterable, persistent
4. **Timers are better than cron** - More features, better integration
5. **Always daemon-reload** - After changing service files
6. **Check status and logs** - First steps in troubleshooting
7. **Use resource limits** - Prevent services from consuming everything
8. **Templates save time** - For running multiple instances

### Learning Resources

- **Systemd Documentation**: https://systemd.io/
- **Red Hat Systemd Guide**: https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/7/html/system_administrators_guide/chap-managing_services_with_systemd
- **ArchLinux Systemd Wiki**: https://wiki.archlinux.org/title/Systemd (excellent even for Ubuntu users)
- **Systemd by Example**: https://systemd-by-example.com/

Remember: Systemd might seem complex at first, but it's consistent and logical. Once you understand the basics, you can manage any service on any modern Linux system.