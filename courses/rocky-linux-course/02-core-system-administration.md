# Part 2: Core System Administration

## Chapter 4: User and Group Management

### Introduction to Linux Users and Groups

In Linux, everything revolves around users and permissions. Think of your Rocky Linux server like an office building:
- **Users** are like employees with ID badges
- **Groups** are like departments (HR, IT, Sales)
- **Permissions** are like keycard access to different rooms
- **root** is like the building owner with the master key

Every file, folder, and process belongs to a user and group. This is how Linux keeps things organized and secure!

### Understanding User Types

#### Types of Users in Rocky Linux

```bash
# Linux has three types of users:

# 1. Root User (UID 0)
# - The superuser with unlimited power
# - User ID (UID) is always 0
# - Home directory: /root
# - Like the CEO who can access everything

# 2. System Users (UID 1-999)
# - Used by services and programs
# - Can't login normally
# - Examples: nginx, mysql, mail
# - Like automated systems (security cameras, HVAC)

# 3. Regular Users (UID 1000+)
# - Real people who use the system
# - Can login and have home directories
# - Examples: john, sarah, admin
# - Like regular employees

# See all users on your system:
cat /etc/passwd
# root:x:0:0:root:/root:/bin/bash
# bin:x:1:1:bin:/bin:/sbin/nologin       <- System user (can't login)
# daemon:x:2:2:daemon:/sbin:/sbin/nologin <- System user
# ...
# admin:x:1000:1000:Administrator:/home/admin:/bin/bash <- Regular user

# Format of /etc/passwd:
# username:password:UID:GID:description:home:shell
# The 'x' means password is stored elsewhere (in /etc/shadow)
```

### Creating and Managing Users

#### Creating Users the Right Way

```bash
# Method 1: useradd (low-level command)
sudo useradd john
# This creates a basic user but doesn't:
# - Set a password
# - Create a home directory (on some systems)
# - Copy default files

# Method 2: adduser (better for interactive use - not available on Rocky by default)
# Rocky Linux doesn't have adduser, but we can use useradd with options

# Method 3: useradd with all the options (recommended)
sudo useradd -m -s /bin/bash -c "John Smith" -G wheel john

# Let's understand each option:
# useradd       = the command
# -m            = create home directory (/home/john)
# -s /bin/bash  = set shell (program that interprets commands)
# -c "John Smith" = comment/full name
# -G wheel      = add to wheel group (for sudo access)
# john          = the username

# Now set a password:
sudo passwd john
# Enter new UNIX password: ********
# Retype new UNIX password: ********
# passwd: password updated successfully

# Verify the user was created:
id john
# uid=1001(john) gid=1001(john) groups=1001(john),10(wheel)

# See user details:
finger john  # May need to install: sudo dnf install finger
# Login: john                           Name: John Smith
# Directory: /home/john                 Shell: /bin/bash
# Never logged in.
```

#### Understanding User Files

```bash
# When you create a user, Linux updates several files:

# 1. /etc/passwd - Basic user information (public)
grep john /etc/passwd
# john:x:1001:1001:John Smith:/home/john:/bin/bash

# 2. /etc/shadow - Encrypted passwords (private)
sudo grep john /etc/shadow
# john:$6$abc...:19700:0:99999:7:::
# This contains the encrypted password and password aging info

# 3. /etc/group - Group memberships
grep john /etc/group
# wheel:x:10:admin,john    <- john is in wheel group
# john:x:1001:              <- john's personal group

# 4. Home directory created
ls -la /home/john
# total 12
# drwx------. 2 john john  62 Dec 10 10:00 .
# drwxr-xr-x. 4 root root  30 Dec 10 10:00 ..
# -rw-r--r--. 1 john john  18 Jul 21  2023 .bash_logout
# -rw-r--r--. 1 john john 141 Jul 21  2023 .bash_profile
# -rw-r--r--. 1 john john 492 Jul 21  2023 .bashrc

# These hidden files (starting with .) are copied from:
ls -la /etc/skel
# This is the "skeleton" directory - template for new users
```

#### Modifying Users

```bash
# Change user's full name:
sudo usermod -c "John P. Smith" john

# Add user to additional groups:
sudo usermod -aG docker,developers john
# -a = append (don't remove from existing groups)
# -G = supplementary groups
# Always use -aG together!

# Change user's shell:
sudo usermod -s /bin/zsh john

# Change username (careful - user must be logged out):
sudo usermod -l johnsmith john
# -l = login name

# Lock a user account (prevent login):
sudo usermod -L john
# or
sudo passwd -l john

# Unlock a user account:
sudo usermod -U john
# or
sudo passwd -u john

# Set account expiration:
sudo usermod -e 2024-12-31 john
# Account expires on Dec 31, 2024

# See account details:
sudo chage -l john
# Last password change                    : Dec 10, 2023
# Password expires                        : Mar 10, 2024
# Password inactive                       : never
# Account expires                         : Dec 31, 2024
# Minimum number of days between password change : 0
# Maximum number of days between password change : 90
# Number of days of warning before password expires : 7
```

#### Deleting Users

```bash
# CAREFUL: This is permanent!

# Method 1: Keep home directory (safer)
sudo userdel john
# User deleted but /home/john still exists
# Good for: Terminated employees whose data might be needed

# Method 2: Delete everything (dangerous!)
sudo userdel -r john
# -r = remove home directory and mail spool
# Everything is gone forever!

# Method 3: Best practice - disable first, delete later
# Step 1: Disable the account
sudo usermod -L john
sudo usermod -s /sbin/nologin john
# Step 2: After 30 days, if no issues, delete
sudo userdel -r john

# Before deleting, consider backing up their data:
sudo tar -czf /backup/john-$(date +%Y%m%d).tar.gz /home/john
```

### Group Management

#### Understanding Groups

```bash
# Groups are collections of users. Like departments in a company.
# Every user has:
# - Primary group: Their main group (usually same name as user)
# - Supplementary groups: Additional groups they belong to

# See all groups:
cat /etc/group
# root:x:0:
# wheel:x:10:admin,john
# admin:x:1000:
# john:x:1001:

# Format: groupname:password:GID:members

# See what groups you're in:
groups
# admin wheel

# See what groups another user is in:
groups john
# john : john wheel docker
```

#### Creating and Managing Groups

```bash
# Create a new group:
sudo groupadd developers
# By default, gets next available GID (1002, 1003, etc.)

# Create group with specific GID:
sudo groupadd -g 2000 projectx
# -g = specify GID

# Add users to a group:
sudo usermod -aG developers john
sudo usermod -aG developers sarah
# Remember: always use -aG to append!

# WRONG WAY (removes from other groups):
# sudo usermod -G developers john  # DON'T DO THIS!

# Add multiple users at once:
for user in john sarah mike; do
    sudo usermod -aG developers $user
done

# Remove user from a group (tricky - no direct command):
# Method 1: Edit directly
sudo gpasswd -d john developers
# -d = delete user from group

# Method 2: Set groups explicitly
sudo usermod -G wheel,john mike
# This sets ONLY these groups (removes from others)

# Delete a group:
sudo groupdel projectx
# Can't delete if it's someone's primary group

# Change group name:
sudo groupmod -n newname oldname
```

### Password Policies

#### Setting Password Requirements

```bash
# Rocky Linux uses PAM (Pluggable Authentication Modules) for passwords

# Install password quality tools:
sudo dnf install -y libpwquality

# Edit password requirements:
sudo nano /etc/security/pwquality.conf

# Common settings:
minlen = 12          # Minimum length
dcredit = -1         # Require at least 1 digit
ucredit = -1         # Require at least 1 uppercase
lcredit = -1         # Require at least 1 lowercase
ocredit = -1         # Require at least 1 special character
minclass = 3         # Require at least 3 character classes

# The negative numbers mean "at least this many required"
# Positive numbers mean "credit for up to this many"

# Test password quality:
echo "MyPassword123!" | pwscore
# 100  <- Score out of 100

echo "password" | pwscore
# Password quality check failed:
# The password fails the dictionary check
```

#### Password Aging and Expiration

```bash
# Set password policies for all new users:
sudo nano /etc/login.defs

# Important settings:
PASS_MAX_DAYS   90    # Password expires after 90 days
PASS_MIN_DAYS   7     # Must wait 7 days between changes
PASS_MIN_LEN    12    # Minimum password length
PASS_WARN_AGE   14    # Warn 14 days before expiration

# Set password policies for existing user:
sudo chage -M 90 -m 7 -W 14 john
# -M = max days
# -m = min days
# -W = warning days

# Force password change on next login:
sudo chage -d 0 john
# or
sudo passwd -e john

# See password information:
sudo chage -l john
# Last password change                    : password must be changed
# Password expires                        : password must be changed
# Password inactive                       : password must be changed
# Account expires                         : never

# Never expire password (not recommended):
sudo chage -M 99999 john

# Set account to expire on specific date:
sudo chage -E 2024-12-31 john
# Useful for contractors or temporary employees
```

### User Resource Limits

#### Understanding and Setting Limits

```bash
# Linux can limit resources per user to prevent abuse

# See current limits for your session:
ulimit -a
# core file size          (blocks, -c) 0
# data seg size           (kbytes, -d) unlimited
# file size               (blocks, -f) unlimited
# max locked memory       (kbytes, -l) 64
# max memory size         (kbytes, -m) unlimited
# open files                      (-n) 1024     <- Max files open
# pipe size            (512 bytes, -p) 8
# stack size              (kbytes, -s) 8192
# cpu time               (seconds, -t) unlimited
# max user processes              (-u) 4096     <- Max processes
# virtual memory          (kbytes, -v) unlimited

# Set temporary limit for current session:
ulimit -n 2048  # Increase open files limit

# Set permanent limits for users:
sudo nano /etc/security/limits.conf

# Format: domain type item value
# domain = user, @group, or *
# type = soft (warning) or hard (enforced)
# item = what to limit
# value = the limit

# Examples:
john    soft    nproc    100     # Warn at 100 processes
john    hard    nproc    150     # Block at 150 processes
@developers soft nofile  2048    # 2048 open files for developers group
*       hard    core     0        # No core dumps for anyone

# Common limits:
# nproc = number of processes
# nofile = number of open files
# cpu = CPU time in minutes
# maxlogins = max number of logins
# priority = nice priority
# locks = file locks
# sigpending = pending signals
# msgqueue = message queue size

# After changing, user must logout and login for changes to take effect

# Check limits for another user:
sudo -u john bash -c "ulimit -a"
```

### Login Restrictions and Access Control

#### Controlling When and Where Users Can Login

```bash
# Method 1: Disable account temporarily
sudo usermod -L username  # Lock
sudo usermod -U username  # Unlock

# Method 2: Set expiration date
sudo usermod -e 2024-12-31 username

# Method 3: Restrict SSH access (edit /etc/ssh/sshd_config)
# AllowUsers john sarah admin
# DenyUsers baduser
# AllowGroups wheel developers
# DenyGroups tempusers

# Method 4: Use /etc/security/access.conf for fine control
sudo nano /etc/security/access.conf

# Format: permission : users : origins
# + : john : 192.168.1.0/24    # john can login from local network
# - : ALL : ALL                 # Deny everyone else

# Method 5: Restrict login times with /etc/security/time.conf
sudo nano /etc/security/time.conf

# Format: services;ttys;users;times
# sshd;*;john;Wk0800-1800      # john can SSH Mon-Fri 8am-6pm
# *;*;contractors;!Wk0800-1800  # contractors can't login during work hours
```

---

## Chapter 5: SELinux and Permissions

### Deep Dive into SELinux

#### Understanding SELinux Concepts

SELinux is like having multiple layers of security. Even if someone breaks through one layer, others stop them. Here's how to think about it:

**Traditional Linux Security** (DAC - Discretionary Access Control):
- Like having locks on doors
- If you have the key (permission), you can open the door
- Once inside, you can do anything the room allows

**SELinux** (MAC - Mandatory Access Control):
- Like having locks on doors AND security cameras AND guards
- Even with a key, guards check if you should be there
- Even inside, you can only do specific approved actions

```bash
# Let's see SELinux in action

# Traditional permissions say the web server (httpd) can read this file:
ls -l /var/www/html/index.html
# -rw-r--r--. 1 root root 100 Dec 10 10:00 /var/www/html/index.html
# The 'r' means httpd can read it (others can read)

# But SELinux adds another layer - the context:
ls -Z /var/www/html/index.html
# -rw-r--r--. root root unconfined_u:object_r:httpd_sys_content_t:s0 /var/www/html/index.html
#                                                ^^^^^^^^^^^^^^^^^^^^
#                                                This is the SELinux type

# The httpd_sys_content_t type means "web server content"
# httpd can ONLY read files with this type, even if regular permissions allow it!
```

#### SELinux Contexts Explained

```bash
# Every file and process has an SELinux context with four parts:
# user:role:type:level

# Let's decode a context:
ls -Z /usr/sbin/httpd
# -rwxr-xr-x. root root system_u:object_r:httpd_exec_t:s0 /usr/sbin/httpd

# Breaking it down:
# system_u  = SELinux user (not the same as Linux user!)
# object_r  = Role (object_r for files, system_r for processes)
# httpd_exec_t = Type (MOST IMPORTANT - this controls access)
# s0        = Security level (used in military systems)

# See process contexts:
ps -eZ | grep httpd
# system_u:system_r:httpd_t:s0   12345 ?   00:00:01 httpd
#                   ^^^^^^^
#          Process is running as httpd_t type

# The MAGIC: SELinux rules say:
# - httpd_t processes can read httpd_sys_content_t files
# - httpd_t processes CANNOT read user_home_t files
# Even if file permissions say yes, SELinux can say no!
```

#### Common SELinux Types You'll See

```bash
# Web server types:
httpd_sys_content_t     # Static web content (HTML, images)
httpd_sys_script_exec_t # CGI scripts that can execute
httpd_sys_rw_content_t  # Content the web server can modify
httpd_log_t            # Web server log files
httpd_cache_t          # Web server cache files

# User and admin types:
user_home_t            # User home directories
admin_home_t           # Admin home directories
ssh_home_t            # SSH keys and config

# System types:
etc_t                 # Configuration files in /etc
bin_t                 # Executable binaries
lib_t                 # Libraries
var_t                 # Variable data

# See all types on your system:
seinfo -t | head -20
# Types: 4932    <- Wow, that's a lot of types!
#   NetworkManager_t
#   NetworkManager_tmp_t
#   abrt_t
#   ...
```

#### Fixing SELinux Problems

```bash
# PROBLEM 1: Moved web files and Apache can't read them
# You copied files from your home to web directory:
cp ~/mywebsite/* /var/www/html/

# Apache can't read them! Check context:
ls -Z /var/www/html/
# -rw-rw-r--. john john unconfined_u:object_r:user_home_t:s0 index.html
#                                              ^^^^^^^^^^^
#                                              Wrong type!

# SOLUTION: Restore correct context
sudo restorecon -Rv /var/www/html
# Relabeled /var/www/html/index.html from
#   unconfined_u:object_r:user_home_t:s0 to
#   unconfined_u:object_r:httpd_sys_content_t:s0

# PROBLEM 2: Service can't bind to a port
# You want httpd to listen on port 8080 instead of 80

# Check what ports httpd can use:
sudo semanage port -l | grep http_port_t
# http_port_t    tcp    80, 81, 443, 488, 8008, 8009, 8443, 9000

# 8080 isn't there! Add it:
sudo semanage port -a -t http_port_t -p tcp 8080
# Now httpd can use port 8080

# PROBLEM 3: Service needs network access
# Your web app can't connect to a database

# Check if httpd can make network connections:
sudo getsebool httpd_can_network_connect
# httpd_can_network_connect --> off

# Enable it:
sudo setsebool -P httpd_can_network_connect on
# -P makes it permanent

# PROBLEM 4: Custom file locations
# You want to serve web files from /data/website instead of /var/www

# Tell SELinux this is web content:
sudo semanage fcontext -a -t httpd_sys_content_t "/data/website(/.*)?"
sudo restorecon -Rv /data/website
```

#### SELinux Troubleshooting Tools

```bash
# When something doesn't work, check if SELinux blocked it:

# Method 1: Check for recent denials
sudo ausearch -m AVC -ts recent
# time->Mon Dec 10 10:30:45 2023
# type=AVC msg=audit(1702209045.123:456): avc:  denied  { read } for
#   pid=12345 comm="httpd" name="index.html" dev="sda1" ino=789012
#   scontext=system_u:system_r:httpd_t:s0
#   tcontext=unconfined_u:object_r:user_home_t:s0
#   tclass=file permissive=0

# This says: httpd (running as httpd_t) tried to read a file
# with user_home_t type and was DENIED

# Method 2: Use sealert for human-readable explanations
sudo sealert -a /var/log/audit/audit.log
# SELinux is preventing httpd from read access on the file index.html
#
# ***** Plugin catchall_labels (83.8 confidence) suggests *****
# If you want to allow httpd to have read access on index.html
# Then you need to change the label on index.html
# Do: semanage fcontext -a -t FILE_TYPE 'index.html'
# where FILE_TYPE is one of: httpd_sys_content_t, httpd_cache_t...
# Then execute: restorecon -v 'index.html'

# Method 3: Temporarily disable SELinux to test (NEVER in production!)
sudo setenforce 0  # Set to permissive
# Test if your application works now
sudo setenforce 1  # ALWAYS set back to enforcing!

# If it works with SELinux off, you know SELinux is the issue
```

### Unix File Permissions Deep Dive

#### Understanding Permission Bits

```bash
# Every file has three sets of permissions for three types of users:
ls -l /tmp/example.txt
# -rw-r--r-- 1 john developers 1024 Dec 10 10:00 /tmp/example.txt
#  ↑├─┼─┼─┤
#  │ │ │ └── Others (everyone else): r-- (read only)
#  │ │ └──── Group (developers):     r-- (read only)
#  │ └────── Owner (john):           rw- (read and write)
#  └──────── File type:              - (regular file)

# Permission bits:
# r (read)    = 4
# w (write)   = 2
# x (execute) = 1
# - (none)    = 0

# So rw-r--r-- equals:
# Owner:  rw- = 4+2+0 = 6
# Group:  r-- = 4+0+0 = 4
# Others: r-- = 4+0+0 = 4
# Numeric mode: 644

# Common permission patterns:
# 644 = rw-r--r-- (files - owner writes, others read)
# 755 = rwxr-xr-x (scripts/directories - owner full, others read/execute)
# 600 = rw------- (private files - owner only)
# 700 = rwx------ (private directories - owner only)
# 666 = rw-rw-rw- (shared files - everyone writes) DANGEROUS!
# 777 = rwxrwxrwx (full access to everyone) VERY DANGEROUS!
```

#### Directory Permissions Are Different!

```bash
# For directories, permissions mean different things:
# r = can list files in directory (ls)
# w = can create/delete files in directory
# x = can enter directory (cd)

# Example:
mkdir /tmp/testdir
ls -ld /tmp/testdir
# drwxr-xr-x 2 john john 4096 Dec 10 10:00 /tmp/testdir
# ↑
# d = directory

# Let's experiment:
chmod 744 /tmp/testdir  # rwxr--r--

# Other users can list but not enter:
su - otheruser
ls /tmp/testdir      # Works! (r bit)
cd /tmp/testdir      # Permission denied! (no x bit)

# Important: You need 'x' to access files inside, even with 'r'!
chmod 751 /tmp/testdir  # rwxr-x--x
# Now others can enter but not list:
cd /tmp/testdir      # Works! (x bit)
ls                   # Permission denied! (no r bit)
cat known-file.txt   # Works if you know the name!
```

### Special Permissions (SUID, SGID, Sticky Bit)

#### SUID (Set User ID)

```bash
# SUID makes a program run as the file owner, not the user running it
# This is how regular users can change their passwords!

ls -l /usr/bin/passwd
# -rwsr-xr-x 1 root root 33544 Dec  7  2023 /usr/bin/passwd
#     ↑
#     's' means SUID is set

# When you run passwd:
# - You're a regular user (john)
# - passwd runs as root (because of SUID)
# - It can modify /etc/shadow (which only root can write)
# - Changes your password
# - Exits, you're back to being john

# Set SUID (dangerous - use carefully!):
chmod u+s /path/to/program
# or
chmod 4755 /path/to/program  # 4 in front = SUID

# Find all SUID programs (potential security risks):
find / -perm -4000 -type f 2>/dev/null
# /usr/bin/passwd
# /usr/bin/su
# /usr/bin/sudo
# ... these need SUID to work properly
```

#### SGID (Set Group ID)

```bash
# SGID on files: Runs as the group owner
# SGID on directories: New files inherit the directory's group

# Create a shared project directory:
sudo mkdir /shared/project
sudo chgrp developers /shared/project
sudo chmod 2775 /shared/project  # 2 in front = SGID
#          ↑
#     drwxrwsr-x
#            ↑
#            's' in group position = SGID

# Now when anyone creates files here:
cd /shared/project
touch newfile.txt
ls -l newfile.txt
# -rw-rw-r-- 1 john developers 0 Dec 10 10:00 newfile.txt
#                   ↑
#     Inherited developers group, not john's primary group!

# This is perfect for team collaboration!
```

#### Sticky Bit

```bash
# Sticky bit: Only file owner can delete their files
# Even if directory permissions allow deletion

# Classic example: /tmp directory
ls -ld /tmp
# drwxrwxrwt 10 root root 4096 Dec 10 10:00 /tmp
#          ↑
#          't' = sticky bit

# Everyone can create files in /tmp (rwx for others)
# But you can only delete YOUR OWN files

# Test it:
cd /tmp
touch myfile.txt
su - otheruser
rm /tmp/myfile.txt
# rm: cannot remove '/tmp/myfile.txt': Operation not permitted
# Even though /tmp is writable by everyone!

# Set sticky bit:
chmod +t /shared/uploads
# or
chmod 1777 /shared/uploads  # 1 in front = sticky bit

# Perfect for shared upload directories!
```

### Access Control Lists (ACLs)

#### Going Beyond Basic Permissions

```bash
# Traditional permissions have limitations:
# - Only one owner and one group
# - Can't give specific users different permissions
# ACLs solve this!

# Install ACL utilities (usually pre-installed):
sudo dnf install -y acl

# Check if filesystem supports ACLs:
mount | grep acl
# /dev/sda1 on / type ext4 (rw,relatime,seclabel)
# If no 'acl', add it to /etc/fstab mount options

# View ACLs on a file:
getfacl /tmp/example.txt
# # file: tmp/example.txt
# # owner: john
# # group: john
# user::rw-
# group::r--
# other::r--

# Give specific user sarah read-write access:
setfacl -m u:sarah:rw /tmp/example.txt
# -m = modify
# u:sarah:rw = user sarah gets read-write

# Check it worked:
getfacl /tmp/example.txt
# # file: tmp/example.txt
# # owner: john
# # group: john
# user::rw-
# user:sarah:rw-        <- Sarah's special permission!
# group::r--
# mask::rw-
# other::r--

ls -l /tmp/example.txt
# -rw-rw-r--+ 1 john john 1024 Dec 10 10:00 /tmp/example.txt
#           ↑
#           '+' means ACLs are set

# Give a group special permissions:
setfacl -m g:managers:rwx /shared/reports

# Set default ACLs for new files in directory:
setfacl -d -m u:sarah:rw /shared/project
# -d = default (for new files created here)

# Remove ACL:
setfacl -x u:sarah /tmp/example.txt  # Remove sarah's ACL
setfacl -b /tmp/example.txt           # Remove all ACLs

# Copy ACLs from one file to another:
getfacl file1 | setfacl --set-file=- file2

# Recursive ACL setting:
setfacl -R -m u:sarah:rx /shared/documents
```

---

## Chapter 6: System Services with Systemd

### Understanding Systemd

#### What is Systemd?

**Systemd** is the init system - the first process that starts when Rocky Linux boots and the last one to stop when shutting down. It's like the manager of a restaurant:
- Starts all the services (like opening different stations)
- Keeps them running (supervises the staff)
- Restarts them if they crash (replaces sick workers)
- Stops them in the right order (closing procedures)

```bash
# Systemd is always PID 1 (Process ID 1):
ps -p 1
#     PID TTY          TIME CMD
#       1 ?        00:00:02 systemd

# See the systemd tree - every process descends from it:
pstree -p 1 | head -20
# systemd(1)─┬─NetworkManager(812)─┬─dhclient(1234)
#            │                      └─2*[{NetworkManager}(813,814)]
#            ├─sshd(825)───sshd(2341)───bash(2342)
#            ├─chronyd(830)
#            └─...
```

#### Units: The Building Blocks

```bash
# Systemd manages "units" - different types of resources:

# Types of units:
# .service  = Services (programs that run in background)
# .socket   = Network sockets
# .target   = Groups of units (like runlevels)
# .mount    = Mount points
# .timer    = Scheduled tasks (like cron)
# .path     = Path monitoring
# .device   = Device units

# List all units:
systemctl list-units
# UNIT                           LOAD   ACTIVE SUB       DESCRIPTION
# sshd.service                   loaded active running   OpenSSH server daemon
# firewalld.service              loaded active running   firewalld - dynamic firewall
# multi-user.target              loaded active active    Multi-User System
# ...

# List only services:
systemctl list-units --type=service

# List ALL units (including inactive):
systemctl list-units --all

# List unit files (installed units):
systemctl list-unit-files
# UNIT FILE                      STATE           VENDOR PRESET
# sshd.service                   enabled         enabled
# httpd.service                  disabled        disabled
# ...
```

### Managing Services

#### Basic Service Control

```bash
# The main commands you'll use every day:

# Start a service:
sudo systemctl start httpd
# (No output means success - Unix philosophy!)

# Stop a service:
sudo systemctl stop httpd

# Restart a service (stop then start):
sudo systemctl restart httpd

# Reload configuration without stopping:
sudo systemctl reload httpd
# (Not all services support reload)

# Check service status:
systemctl status httpd
# ● httpd.service - The Apache HTTP Server
#    Loaded: loaded (/usr/lib/systemd/system/httpd.service; disabled; vendor preset: disabled)
#    Active: active (running) since Mon 2023-12-10 10:00:00 EST; 5min ago
#      Docs: man:httpd.service(8)
#  Main PID: 12345 (httpd)
#    Status: "Running, listening on: port 80"
#    CGroup: /system.slice/httpd.service
#            ├─12345 /usr/sbin/httpd -DFOREGROUND
#            ├─12346 /usr/sbin/httpd -DFOREGROUND
#            └─12347 /usr/sbin/httpd -DFOREGROUND

# Understanding the status output:
# Loaded: Is the unit file loaded? enabled/disabled?
# Active: Current state (running/dead/failed)
# Main PID: Process ID of main process
# CGroup: Process tree for this service

# Quick status check:
systemctl is-active httpd   # running or inactive
systemctl is-enabled httpd  # enabled or disabled
systemctl is-failed httpd   # failed or active
```

#### Enabling Services at Boot

```bash
# Enable = start automatically at boot
# Disable = don't start at boot

# Enable a service:
sudo systemctl enable httpd
# Created symlink /etc/systemd/system/multi-user.target.wants/httpd.service
#   → /usr/lib/systemd/system/httpd.service

# What happened? Systemd created a symbolic link
# When multi-user.target starts, it starts everything in its wants/ directory

# Enable AND start now:
sudo systemctl enable --now httpd

# Disable a service:
sudo systemctl disable httpd
# Removed /etc/systemd/system/multi-user.target.wants/httpd.service

# Disable AND stop now:
sudo systemctl disable --now httpd

# Mask a service (prevent it from starting even manually):
sudo systemctl mask httpd
# Created symlink /etc/systemd/system/httpd.service → /dev/null

# Unmask:
sudo systemctl unmask httpd

# See why a service is running:
systemctl status httpd | grep Loaded
# Loaded: loaded (/usr/lib/systemd/system/httpd.service; enabled; vendor preset: disabled)
#                                                         ^^^^^^^^
#                                                    Starts at boot!
```

### Creating Custom Services

#### Writing Your First Service

Let's create a simple service that monitors disk space:

```bash
# Step 1: Create the script
sudo nano /usr/local/bin/disk-monitor.sh

#!/bin/bash
# Simple disk space monitor

while true; do
    usage=$(df -h / | awk 'NR==2 {print $5}' | sed 's/%//')

    if [ "$usage" -gt 80 ]; then
        echo "WARNING: Disk usage is ${usage}% at $(date)" >> /var/log/disk-monitor.log
        # Could also send email alert here
    fi

    sleep 300  # Check every 5 minutes
done

# Make it executable:
sudo chmod +x /usr/local/bin/disk-monitor.sh

# Step 2: Create the service file
sudo nano /etc/systemd/system/disk-monitor.service

[Unit]
Description=Disk Space Monitor
After=multi-user.target

[Service]
Type=simple
ExecStart=/usr/local/bin/disk-monitor.sh
Restart=always
User=root

[Install]
WantedBy=multi-user.target

# Let's understand each section:
# [Unit] = General information
#   Description = What this service does
#   After = Start after this target/service
#
# [Service] = How to run the service
#   Type=simple = Main process stays in foreground
#   ExecStart = Command to run
#   Restart=always = Restart if it crashes
#   User = Run as this user
#
# [Install] = How to enable the service
#   WantedBy = Which target should include this

# Step 3: Load and start the service
sudo systemctl daemon-reload  # Tell systemd about new service
sudo systemctl start disk-monitor
sudo systemctl status disk-monitor
sudo systemctl enable disk-monitor  # Start at boot
```

#### Advanced Service Options

```bash
# More service file options:

[Unit]
Description=My Application
After=network.target mysql.service
Requires=mysql.service        # Won't start without mysql
Wants=redis.service           # Try to start redis, but ok if it fails

[Service]
Type=forking                  # Process forks and parent exits
PIDFile=/var/run/myapp.pid   # Where to find the PID
User=appuser                  # Run as this user
Group=appgroup               # Run as this group
WorkingDirectory=/opt/myapp  # cd here before starting

# Environment variables:
Environment="DEBUG=1"
EnvironmentFile=/etc/myapp.conf

# Commands:
ExecStartPre=/usr/bin/check-config.sh  # Run before starting
ExecStart=/usr/bin/myapp
ExecReload=/bin/kill -HUP $MAINPID     # How to reload
ExecStop=/usr/bin/myapp-shutdown       # How to stop

# Restart policy:
Restart=on-failure           # Only restart if it fails
RestartSec=5                 # Wait 5 seconds before restart
StartLimitBurst=3           # Try 3 times
StartLimitIntervalSec=60   # Within 60 seconds

# Resource limits:
LimitNOFILE=65536           # Max open files
LimitNPROC=4096            # Max processes
MemoryLimit=2G             # Max memory
CPUQuota=50%              # Max CPU usage

# Security:
PrivateTmp=true            # Isolated /tmp
ProtectSystem=full        # Read-only /usr, /boot, /etc
ProtectHome=true          # Can't access /home
NoNewPrivileges=true      # Can't gain privileges

[Install]
WantedBy=multi-user.target
```

### Systemd Timers (Modern Cron)

#### Creating Scheduled Tasks

```bash
# Systemd timers are more powerful than cron:
# - Can depend on other services
# - Better logging
# - Can run missed jobs
# - More flexible scheduling

# Example: Daily backup timer

# Step 1: Create the service that does the work
sudo nano /etc/systemd/system/backup.service

[Unit]
Description=Daily Backup
After=multi-user.target

[Service]
Type=oneshot
ExecStart=/usr/local/bin/backup.sh
User=root

# Note: No [Install] section for timer-activated services

# Step 2: Create the timer
sudo nano /etc/systemd/system/backup.timer

[Unit]
Description=Daily Backup Timer
Requires=backup.service

[Timer]
OnCalendar=daily
Persistent=true
RandomizedDelaySec=1h

[Install]
WantedBy=timers.target

# Timer options explained:
# OnCalendar=daily       # Run daily at midnight
# OnCalendar=*-*-* 02:00 # Run at 2 AM every day
# OnCalendar=Mon *-*-* 03:00 # Every Monday at 3 AM
# OnCalendar=*:0/15      # Every 15 minutes
# Persistent=true        # Run if missed (machine was off)
# RandomizedDelaySec=1h  # Random delay up to 1 hour (spread load)

# Step 3: Enable and start the timer
sudo systemctl daemon-reload
sudo systemctl enable --now backup.timer

# Check timer status:
systemctl status backup.timer
systemctl list-timers
# NEXT                        LEFT     LAST  PASSED  UNIT         ACTIVATES
# Tue 2023-12-11 00:00:00 EST 13h left n/a   n/a     backup.timer backup.service

# See when it last ran:
systemctl status backup.service
journalctl -u backup.service
```

### Boot Process and Targets

#### Understanding Systemd Targets

```bash
# Targets are like the old runlevels but more flexible
# They group units together for different system states

# Common targets:
# poweroff.target    = System shutdown (runlevel 0)
# rescue.target      = Single user mode (runlevel 1)
# multi-user.target  = Multi-user, no graphics (runlevel 3)
# graphical.target   = Multi-user with graphics (runlevel 5)
# reboot.target      = System reboot (runlevel 6)

# See current target:
systemctl get-default
# multi-user.target

# List all targets:
systemctl list-units --type=target

# Change default target:
sudo systemctl set-default graphical.target

# Switch to target immediately:
sudo systemctl isolate rescue.target  # Like single-user mode

# See target dependencies:
systemctl list-dependencies multi-user.target
# multi-user.target
# ● ├─basic.target
# ● │ ├─-.mount
# ● │ ├─microcode.service
# ● │ ├─paths.target
# ● │ ├─slices.target
# ● │ ├─sockets.target
# ● │ ├─sysinit.target
# ● │ └─timers.target
# ● ├─getty.target
# ● ├─sshd.service
# ● └─...

# Create custom target for your application stack:
sudo nano /etc/systemd/system/myapp.target

[Unit]
Description=My Application Stack
Requires=multi-user.target
After=multi-user.target
AllowIsolate=yes

# Then make services WantedBy=myapp.target
```

### Journald Logging

#### Working with System Logs

```bash
# Journald collects all system logs in one place
# No more hunting through /var/log/* files!

# View all logs:
journalctl
# (Press space to page, q to quit - like 'less')

# Follow logs in real-time (like tail -f):
journalctl -f

# Show only kernel messages:
journalctl -k

# Show logs from current boot:
journalctl -b

# Show logs from previous boot:
journalctl -b -1

# List all boots:
journalctl --list-boots
# -2 8c3b... Mon 2023-12-08 08:00:01 EST—Mon 2023-12-08 20:00:00 EST
# -1 4d5a... Tue 2023-12-09 08:00:00 EST—Tue 2023-12-09 20:00:00 EST
#  0 1a2b... Wed 2023-12-10 08:00:00 EST—Wed 2023-12-10 12:34:56 EST

# Filter by time:
journalctl --since "1 hour ago"
journalctl --since "2023-12-10" --until "2023-12-11"
journalctl --since 09:00 --until "1 hour ago"

# Filter by priority:
journalctl -p err      # Error and worse
journalctl -p warning  # Warning and worse
# Priorities: emerg, alert, crit, err, warning, notice, info, debug

# Filter by service:
journalctl -u sshd
journalctl -u httpd -u mysql  # Multiple services

# Combine filters:
journalctl -u sshd -p err --since today

# Output formats:
journalctl -o json        # JSON format
journalctl -o short-precise # Microsecond precision
journalctl -o cat         # Just the message

# See disk usage:
journalctl --disk-usage
# Archived and active journals take up 248.0M in the file system.

# Clean up old logs:
sudo journalctl --vacuum-time=7d    # Keep only 7 days
sudo journalctl --vacuum-size=100M  # Keep only 100MB

# Make logs persistent (survive reboot):
sudo mkdir -p /var/log/journal
sudo systemctl restart systemd-journald

# Search logs:
journalctl | grep -i error
journalctl _COMM=sshd  # All logs from sshd command
journalctl _PID=12345  # All logs from specific PID
```

## Practice Exercises

### Exercise 1: User Management Challenge
1. Create three users: alice (admin), bob (developer), charlie (intern)
2. Create groups: admins, developers, interns
3. Set up appropriate group memberships
4. Configure sudo access: admins (full), developers (restart services), interns (none)
5. Set password policies: 90-day expiration, 12 character minimum
6. Create a shared directory /projects where developers collaborate with SGID

### Exercise 2: SELinux Practice
1. Create a custom web directory at /data/website
2. Configure SELinux to allow Apache to serve from there
3. Set up a test page and verify Apache can read it
4. Configure Apache to run on port 8080
5. Update SELinux to allow the new port
6. Test and verify everything works with SELinux enforcing

### Exercise 3: Custom Service Creation
1. Write a script that logs system statistics every minute
2. Create a systemd service for your script
3. Configure it to start at boot
4. Create a timer to restart it daily at 3 AM
5. Monitor its logs with journalctl
6. Add resource limits (max 100MB memory, 10% CPU)

### Exercise 4: Permission Scenarios
1. Create a directory where users can upload but not delete others' files
2. Set up a shared script that any user can execute but only admin can modify
3. Create a log file that a service can write to but users can only read
4. Use ACLs to give sarah read access to john's project directory
5. Set up a directory where new files automatically belong to the projects group

## Summary

In Part 2, we've mastered the core of Rocky Linux system administration:

**User and Group Management:**
- Creating and managing user accounts
- Understanding the user database files
- Setting password policies and resource limits
- Managing groups for collaboration

**SELinux Security:**
- Understanding contexts and types
- Fixing common SELinux issues
- Using troubleshooting tools
- Managing booleans and ports

**File Permissions:**
- Traditional Unix permissions
- Special bits (SUID, SGID, sticky)
- Access Control Lists for fine-grained control
- Directory vs file permissions

**Systemd Services:**
- Managing services and their states
- Creating custom services
- Using timers for scheduling
- Understanding the boot process
- Mining logs with journalctl

These skills form the foundation of Linux administration. You can now:
- Control who accesses your system
- Secure your system with multiple layers
- Manage services professionally
- Create automated solutions
- Troubleshoot effectively with logs

## Additional Resources

- [Rocky Linux Documentation - Managing Users and Groups](https://docs.rockylinux.org/books/admin_guide/06-users/)
- [Red Hat SELinux Guide](https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/8/html/using_selinux/index)
- [Systemd Documentation](https://systemd.io/)
- [The Systemd Book](https://systemd-book.org/)
- [Linux Permissions Calculator](https://chmod-calculator.com/)

---

*Continue to Part 3: Storage and Filesystems*