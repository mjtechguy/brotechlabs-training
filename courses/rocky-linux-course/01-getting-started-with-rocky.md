# Part 1: Getting Started with Rocky Linux

## Prerequisites and Learning Resources

Before starting this course, you should have:
- Basic computer literacy (understanding of files, folders, and programs)
- Access to a VM running Rocky Linux 8 or 9 (or AlmaLinux as an alternative)
- A terminal or SSH client on your local computer
- Curiosity and willingness to learn!

**Helpful Resources:**
- Rocky Linux Documentation: https://docs.rockylinux.org/
- Rocky Linux Forums: https://forums.rockylinux.org/
- Linux Command Line Tutorial: https://linuxcommand.org/
- SELinux Project: https://selinuxproject.org/
- Learn Vim Interactive: https://www.openvim.com/

---

## Chapter 1: Understanding Rocky Linux and Enterprise Environments

### Introduction

Welcome to the world of enterprise Linux! In this course, we'll focus on **Rocky Linux**, a powerful, free, and enterprise-ready operating system. You'll learn how to manage servers that power everything from websites to databases to cloud applications.

### What is Rocky Linux?

Imagine you want to run a restaurant. You could:
1. **Buy expensive commercial equipment** (like using commercial enterprise Linux with paid support)
2. **Use professional-grade equipment that's free** (like using Rocky Linux)

Rocky Linux gives you enterprise-quality tools without the enterprise price tag!

**Rocky Linux** is:
- **Free Forever**: No subscriptions, no licenses, no fees
- **Enterprise-Ready**: Used by Fortune 500 companies and small businesses alike
- **Community-Driven**: Supported by thousands of users and contributors worldwide
- **Stable**: Designed to run for years without problems
- **Compatible**: Runs the same software as expensive commercial Linux

```bash
# Let's check what version of Rocky Linux you're running:
cat /etc/rocky-release
# Rocky Linux release 8.9 (Green Obsidian)
# or
# Rocky Linux release 9.3 (Blue Onyx)
#
# Fun fact: Each version has a gemstone codename!
# 8.9 = Green Obsidian
# 9.3 = Blue Onyx
```

### Why Learn Rocky Linux?

1. **It's What Companies Use**: Many businesses run Rocky Linux or similar systems
2. **Job Skills**: Linux administrators are in high demand
3. **Free to Learn**: No expensive licenses while you're learning
4. **Transferable Skills**: What you learn applies to RHEL, AlmaLinux, and other enterprise Linux systems

### Enterprise Linux vs Regular Linux

Think of Linux distributions like different types of vehicles:

**Regular Linux** (like Ubuntu Desktop, Fedora):
- Like a sports car - fast, latest features, exciting
- Updates frequently with new features
- Great for personal use and development
- Things might break with updates

**Enterprise Linux** (like Rocky Linux):
- Like a commercial truck - reliable, stable, predictable
- Updates focus on security and stability
- Designed to run 24/7 for years
- Thoroughly tested before release
- Same software versions for years (stability over novelty)

```bash
# Enterprise Linux keeps software stable for years
# For example, Rocky Linux 8 uses:
python3 --version
# Python 3.6.8  <- Released in 2018, still supported until 2029!

# This stability means:
# ✓ Your applications keep working
# ✓ No surprise breaking changes
# ✓ Security updates without feature changes
# ✗ You don't get the latest features immediately
```

### Key Concepts Explained

#### What is a Virtual Machine (VM)?

A **Virtual Machine** is a computer that exists only in software. Imagine having multiple computers running inside one physical computer, each completely isolated from the others.

**Physical Server** (Traditional):
- One operating system per physical machine
- If it breaks, you need to fix the hardware
- Expensive to buy and maintain
- Takes weeks to purchase and set up

**Virtual Machine** (Modern):
- Multiple VMs on one physical machine
- If it breaks, just create a new one
- Pay only for what you use
- Create a new server in minutes

```bash
# Check if you're running in a VM:
systemd-detect-virt

# Output examples:
# kvm        <- Running in KVM virtualization
# vmware     <- Running in VMware
# none       <- Physical machine
```

#### What is "Ephemeral"?

**Ephemeral** means temporary or short-lived. In cloud computing, your VM could disappear at any time (planned or unplanned), so you must be prepared:

```bash
# Traditional approach (servers are "pets"):
# - Server named "prod-web-01" that you've carefully configured
# - If it dies, you spend hours fixing it
# - Losing it would be a disaster

# Cloud approach (servers are "cattle"):
# - Generic server that can be replaced instantly
# - If it dies, destroy it and create a new one
# - Losing one is no big deal because everything is automated
```

### Virtual Machines vs Physical Servers

#### Understanding Your Virtual Environment

Let's explore the VM you're working with:

```bash
# The systemd-detect-virt command tells you what virtualization platform you're using
systemd-detect-virt

# Understanding the output:
# kvm     <- Kernel Virtual Machine (common in Linux clouds)
# vmware  <- VMware (common in enterprises)
# xen     <- Xen hypervisor (used by AWS)
# none    <- You're on physical hardware

# Let's see more details about your virtual hardware:
lscpu | grep Hypervisor
# Hypervisor vendor: KVM
# This tells you what's managing your VM

# Check your VM's "hardware" specifications:
lscpu
# Architecture:        x86_64          <- 64-bit processor
# CPU(s):              2               <- You have 2 virtual CPUs
# Thread(s) per core:  1               <- Each core runs one thread
# Core(s) per socket:  2               <- 2 cores per processor
# Socket(s):           1               <- 1 processor
# This is all virtual - there's no actual CPU dedicated just to you!
```

#### Why VMs are Great for Learning

1. **Snapshots**: Save your VM's state and restore if you break something
2. **Cloning**: Make exact copies for testing
3. **Resource Control**: Adjust CPU, memory as needed
4. **Isolation**: Mistakes won't affect other systems
5. **Cost-Effective**: Share hardware with other VMs

### Understanding Software Repositories

#### What are Repositories?

**Repositories** (or "repos") are like app stores for Linux. They contain pre-built software packages that you can install with a single command. Unlike downloading software from random websites, repositories are trusted sources.

#### How Rocky Linux Handles Software (No Subscription Needed!)

Rocky and AlmaLinux come with repositories pre-configured and free:

```bash
# See what repositories are already configured:
ls /etc/yum.repos.d/
# rocky-baseos.repo     <- Core system packages
# rocky-appstream.repo  <- Applications
# rocky-extras.repo     <- Additional packages

# The dnf command manages software packages (we'll learn more in Part 5)
# List enabled repositories:
dnf repolist
# repo id             repo name
# baseos              Rocky Linux 8 - BaseOS
# appstream           Rocky Linux 8 - AppStream
# extras              Rocky Linux 8 - Extras

# EPEL = Extra Packages for Enterprise Linux
# This adds thousands more packages not in the default repos
dnf install -y epel-release
# Now you have access to packages like htop, nginx, and more!

# PowerTools/CRB contains development tools and libraries
# Rocky 8 calls it PowerTools, Rocky 9 calls it CRB
dnf config-manager --set-enabled powertools  # For Rocky 8
# OR
dnf config-manager --set-enabled crb         # For Rocky 9
```

### Cloud-init: Automated Server Setup

#### What is Cloud-init?

**Cloud-init** is like a robot that sets up your server automatically when it first boots. Instead of manually typing commands to create users, install software, and configure settings, cloud-init does it all for you based on instructions you provide.

Think of it like this:
- **Manual setup**: Like following a recipe step-by-step yourself
- **Cloud-init**: Like having a chef who reads the recipe and cooks for you

#### How Cloud-init Works

1. You write instructions (called "user data")
2. You provide these when creating the VM
3. On first boot, cloud-init reads the instructions
4. It automatically configures everything
5. Your server is ready without any manual work!

#### Cloud-init Configuration Example

```yaml
#cloud-config
# This MUST be the first line - it tells cloud-init this is a config file
# YAML format uses indentation (spaces, not tabs!) to show structure

# Set the server's name
hostname: rocky-server
fqdn: rocky-server.example.com  # Fully Qualified Domain Name

# Create user accounts
users:
  - name: admin                    # Username
    groups: wheel                  # 'wheel' group = admin privileges in Rocky Linux
    shell: /bin/bash              # The command interpreter they'll use
    sudo: ALL=(ALL) NOPASSWD:ALL  # Can run any command as root without password
    ssh_authorized_keys:          # SSH public keys that can login
      - ssh-rsa AAAAB3NzaC1... admin@example.com

# Install software automatically
packages:
  - vim      # Advanced text editor
  - tmux     # Terminal multiplexer (multiple shells in one window)
  - wget     # Download files from the internet
  - curl     # Transfer data to/from servers
  - git      # Version control system

# Run commands after initial setup
runcmd:
  # Enable firewall (security)
  - systemctl enable firewalld
  - systemctl start firewalld

  # Allow SSH through firewall
  - firewall-cmd --permanent --add-service=ssh
  - firewall-cmd --reload

  # Create a log entry
  - echo "Server configured by cloud-init at $(date)" >> /var/log/setup.log
```

#### Viewing Cloud-init Status
```bash
# Check cloud-init status
cloud-init status

# View cloud-init logs
journalctl -u cloud-init

# Re-run cloud-init
cloud-init clean
cloud-init init
```

### SSH: Connecting to Your Server Securely

#### What is SSH?

**SSH (Secure Shell)** is how you connect to and control your server remotely. Think of it like a secure remote desktop, but for the command line. Instead of seeing windows and icons, you type commands.

#### Understanding SSH Keys

SSH can use two methods for authentication:
1. **Password**: Type your password each time (less secure)
2. **SSH Keys**: Use cryptographic keys (more secure, more convenient)

SSH keys work like a lock and key:
- **Private Key**: The key you keep secret (stays on your computer)
- **Public Key**: The lock you can share (goes on the server)
- Only your private key can "unlock" your public key

#### Generating Your SSH Keys

```bash
# Generate a modern, secure SSH key pair
# Let's break down this command:
ssh-keygen -t ed25519 -C "your-email@example.com"
# ssh-keygen     = the program that creates keys
# -t ed25519     = type of encryption (ed25519 is modern and secure)
# -C "email"     = comment to identify this key

# What happens when you run this:
# 1. It asks WHERE to save the key:
#    Enter file in which to save the key (/home/user/.ssh/id_ed25519):
#    Just press Enter to use the default location
#
# 2. It asks for a passphrase:
#    Enter passphrase (empty for no passphrase):
#    This is optional extra security - like a password for your key
#    For learning, you can leave it empty (just press Enter)
#
# 3. It creates two files:
#    ~/.ssh/id_ed25519       <- Your PRIVATE key (keep secret!)
#    ~/.ssh/id_ed25519.pub   <- Your PUBLIC key (safe to share)

# For older systems that don't support ed25519:
ssh-keygen -t rsa -b 4096 -C "your-email@example.com"
# -t rsa         = older but widely supported encryption
# -b 4096        = key size in bits (bigger = more secure)
```

#### Copying Your Key to the Server

```bash
# The easy way - ssh-copy-id does everything for you:
ssh-copy-id -i ~/.ssh/id_ed25519.pub username@server-ip
# -i ~/.ssh/id_ed25519.pub  = which public key to copy
# username@server-ip         = where to copy it

# Example:
ssh-copy-id -i ~/.ssh/id_ed25519.pub admin@192.168.1.100
# This will:
# 1. Ask for your password (one last time)
# 2. Copy your public key to the server
# 3. Set up everything correctly
# 4. Next time you SSH, no password needed!

# Manual method (if ssh-copy-id isn't available):
cat ~/.ssh/id_ed25519.pub | ssh user@server "mkdir -p ~/.ssh && cat >> ~/.ssh/authorized_keys && chmod 700 ~/.ssh && chmod 600 ~/.ssh/authorized_keys"
# This does the same thing but manually
```

### VM Lifecycle Management

#### Understanding VM States

Virtual machines can be in different states, just like a physical computer:
- **Running**: VM is on and operating
- **Stopped/Shut off**: VM is off but still exists (like shutting down your laptop)
- **Paused**: VM is frozen in time (like hibernation)
- **Destroyed**: VM is gone forever (like throwing away a computer)

#### Managing VMs with virsh (for KVM)

If you're running VMs locally with KVM, you use `virsh` to manage them:

```bash
# List all VMs on this host
virsh list --all
# Id   Name          State
# 1    web-server    running      <- Currently on
# -    db-server     shut off     <- Currently off

# Start a VM (like pressing the power button)
virsh start web-server

# Gracefully shut down a VM (like clicking "Shut Down" in Windows)
virsh shutdown web-server

# Force stop a VM (like holding the power button - use only if stuck!)
virsh destroy web-server  # Don't worry, this doesn't delete the VM!

# Create a snapshot (like a save point in a video game)
virsh snapshot-create-as web-server "before-update" --description "Before system update"
# Now if the update breaks something, you can restore to this point!

# The libvirtd service manages all VMs
systemctl status libvirtd         # Check if VM management service is running
systemctl enable --now libvirtd   # Enable and start it
```

---

## Chapter 2: Initial Server Setup

### Your First Login

When you first connect to your Rocky Linux server, you'll want to explore and understand what you're working with. Let's learn the essential commands to get your bearings.

#### Getting to Know Your System

```bash
# The hostnamectl command shows comprehensive system information
hostnamectl status

# Understanding the output:
#    Static hostname: rocky-server          <- The server's name
#    Icon name: computer-vm                 <- It knows it's a VM!
#    Chassis: vm                           <- Type of system
#    Machine ID: f4b5a2...                 <- Unique identifier
#    Boot ID: 8d3c1f...                    <- Identifies this boot session
#    Virtualization: kvm                   <- Running in KVM
#    Operating System: Rocky Linux 8.9     <- What you're running
#    CPE OS Name: cpe:/o:rocky:rocky:8.9   <- Technical OS identifier
#    Kernel: Linux 4.18.0-513              <- Core system version
#    Architecture: x86-64                  <- 64-bit system

# Check what version of Rocky Linux you're running:
cat /etc/redhat-release
# Rocky Linux release 8.9 (Green Obsidian)
# Each release has a code name - how fun!

# More detailed OS information:
cat /etc/os-release
# NAME="Rocky Linux"                     <- Distribution name
# VERSION="8.9 (Green Obsidian)"         <- Version and codename
# ID="rocky"                            <- Short identifier
# ID_LIKE="rhel centos fedora"          <- Rocky is compatible with these
# VERSION_ID="8.9"                      <- Version number only
# This file is useful for scripts that need to know the OS

# Check the kernel version (the core of Linux):
uname -r
# 4.18.0-513.5.1.el8_9.x86_64
# Let's decode this:
# 4.18.0    = Kernel version
# 513.5.1   = Build number
# el8_9     = Enterprise Linux 8.9
# x86_64    = 64-bit Intel/AMD processor

# See your system's resources:
free -h  # -h means "human readable" (shows MB/GB instead of bytes)
#               total        used        free      shared  buff/cache   available
# Mem:           1.9G        1.2G        148M        9.5M        612M        562M
# Swap:          2.0G        256M        1.8G
#
# What this means:
# Mem = RAM (temporary memory, fast)
# - total: You have 1.9 GB of RAM
# - used: Programs are using 1.2 GB
# - free: 148 MB completely unused
# - buff/cache: 612 MB used for speeding things up (given up if needed)
# - available: 562 MB available for new programs
# Swap = Disk used as emergency RAM (slow)

df -h  # "disk free" - shows disk space
# Filesystem               Size  Used Avail Use% Mounted on
# /dev/mapper/rl-root       17G  4.2G   13G  26% /
# /dev/sda1               1014M  328M  687M  33% /boot
#
# What this means:
# - Your main disk (/) has 17 GB total, using 26%
# - /boot partition (where kernel lives) has 1 GB, using 33%
```

#### No Registration Required!

One of the best things about Rocky Linux is you don't need to register or pay for anything:

```bash
# Rocky Linux is ready to use immediately!
# No registration, no subscription, no activation keys

# Just verify you have working repositories:
dnf repolist
# repo id             repo name                                      status
# baseos              Rocky Linux 8 - BaseOS                        enabled
# appstream           Rocky Linux 8 - AppStream                     enabled
# extras              Rocky Linux 8 - Extras                        enabled

# That's it! You can install any software you need:
dnf search nginx  # Search for web server
dnf info nginx    # Get details about the package
dnf install nginx # Install it (we'll learn more about this later)

# Compare this to commercial enterprise Linux which requires:
# 1. Creating a vendor account
# 2. Getting a subscription (even free developer ones)
# 3. Registering your system
# 4. Attaching subscriptions
# 5. Enabling repositories
# Rocky Linux skips ALL of that!
```

### Creating Administrative Users

#### Understanding Linux Users

In Linux, every person who uses the system needs a **user account**. Think of it like having your own locker at school - it's your personal space with your files and settings.

**Important concepts:**
- **root**: The superuser who can do anything (like the school principal)
- **regular users**: Normal accounts with limited permissions (like students)
- **sudo**: Allows regular users to temporarily act as root (like getting a hall pass)

#### Creating Your First Admin User

```bash
# The useradd command creates new user accounts
# Let's break down this command piece by piece:
useradd -m -s /bin/bash -c "System Administrator" admin

# What each part means:
# useradd                    = The command to add users
# -m                        = Create a home directory (/home/admin)
# -s /bin/bash              = Set their shell (command interpreter) to bash
# -c "System Administrator"  = A description/full name for the account
# admin                     = The username they'll use to login

# Now set a password for the new user:
passwd admin
# Enter new password: ********
# Retype new password: ********
# passwd: all authentication tokens updated successfully.

# IMPORTANT: Choose a strong password!
# Good: MyD0g&ILik3B0n3s!  (mix of letters, numbers, symbols)
# Bad:  password123        (too common and weak)

# Give the user admin privileges by adding them to the 'wheel' group:
usermod -aG wheel admin
# usermod = modify user
# -a      = append (add to group, don't replace)
# -G      = supplementary groups
# wheel   = special group that can use sudo
# admin   = which user to modify

# In Rocky Linux, the 'wheel' group is like the VIP list -
# members can use sudo to run commands as root

# Verify the user was created correctly:
id admin
# uid=1001(admin) gid=1001(admin) groups=1001(admin),10(wheel)
# This shows:
# - User ID: 1001 (unique number for this user)
# - Group ID: 1001 (user's primary group)
# - Groups: admin (their personal group), wheel (sudo access)

# See user details:
getent passwd admin
# admin:x:1001:1001:System Administrator:/home/admin:/bin/bash
# Format: username:password:UID:GID:description:home:shell
# The 'x' means password is stored securely elsewhere
```

### Understanding and Configuring Sudo

#### What is Sudo?

**sudo** stands for "superuser do" - it lets regular users run commands as root (the administrator). It's like getting temporary superpowers!

Without sudo: "Sorry, you can't install software"
With sudo: "Sure, just confirm it's really you (password), then go ahead!"

#### How Sudo Works in Rocky Linux

```bash
# Rocky Linux uses the 'wheel' group for sudo access
# Let's look at the sudo configuration file:
sudo cat /etc/sudoers | grep wheel
# %wheel ALL=(ALL) ALL

# What this means:
# %wheel      = Anyone in the wheel group
# ALL=        = From any computer
# (ALL)       = Can run commands as any user
# ALL         = Can run any command

# To edit sudo configuration safely, ALWAYS use visudo:
sudo visudo
# This opens the sudoers file in a safe editor that checks for errors
# NEVER edit /etc/sudoers directly - one typo can lock you out!

# Common sudo configurations:

# 1. Standard (asks for password):
%wheel ALL=(ALL) ALL

# 2. No password required (convenient but less secure):
%wheel ALL=(ALL) NOPASSWD: ALL

# 3. Specific user permissions (more secure):
# Create a file in /etc/sudoers.d/ for custom rules:
echo "admin ALL=(ALL) ALL" | sudo tee /etc/sudoers.d/admin
sudo chmod 440 /etc/sudoers.d/admin
# This gives 'admin' full sudo access

# 4. Limited sudo (best for security):
# Let a user only restart the web server:
webadmin ALL=(ALL) /usr/bin/systemctl restart httpd

# Always validate your sudoers configuration:
sudo visudo -c
# /etc/sudoers: parsed OK        <- Good!
# /etc/sudoers.d/admin: parsed OK

# Test sudo access:
sudo whoami
# root  <- Success! You ran whoami as root

# See what sudo commands you can run:
sudo -l
# User admin may run the following commands on rocky-server:
#     (ALL) ALL  <- You can run anything!
```

### Securing SSH Access

#### Why Secure SSH?

SSH is like the front door to your server. You want a good lock on it! By default, SSH is fairly secure, but we can make it even better.

#### Understanding SSH Configuration

```bash
# The SSH service configuration file controls how SSH works
# Let's look at the current settings:
sudo cat /etc/ssh/sshd_config | grep -E "^[^#]"
# This shows only active settings (not commented lines)

# Make a backup before changing anything (always a good practice!):
sudo cp /etc/ssh/sshd_config /etc/ssh/sshd_config.backup

# Edit the SSH configuration:
sudo vi /etc/ssh/sshd_config
# (We'll learn vi commands in Chapter 3)
# For now, you can use nano instead:
sudo nano /etc/ssh/sshd_config
```

#### Essential SSH Security Settings

```bash
# Here are the important settings to understand:

# 1. Disable root login (critical for security!):
PermitRootLogin no
# Why: If someone guesses the root password, game over!
# Instead: Login as regular user, then use sudo

# 2. Use SSH keys instead of passwords:
PubkeyAuthentication yes     # Allow SSH key login
PasswordAuthentication no    # Disable password login
# Why: SSH keys are nearly impossible to guess
# Passwords can be guessed or stolen

# 3. Prevent empty passwords:
PermitEmptyPasswords no
# Why: Some accounts might have no password by accident

# 4. Limit login attempts:
MaxAuthTries 3
# Why: Stop brute force attacks (trying many passwords)

# 5. Disconnect idle sessions:
ClientAliveInterval 300      # Send keepalive every 5 minutes
ClientAliveCountMax 2        # Disconnect after 2 failed keepalives
# Why: Don't leave sessions open if someone walks away

# 6. Limit who can SSH (optional but recommended):
AllowUsers admin sysadmin
# Why: Even if someone gets another user's password,
# they can't SSH in unless they're on this list

# 7. Use only SSH protocol 2:
Protocol 2
# Why: Protocol 1 is old and insecure
```

#### Applying SSH Changes

```bash
# Test your configuration for errors BEFORE restarting:
sudo sshd -t
# No output = good!
# Error output = fix it before proceeding!

# If the test passes, restart SSH to apply changes:
sudo systemctl restart sshd

# IMPORTANT: Before disconnecting, open a NEW terminal and test SSH!
# This way, if something's wrong, you still have access

# Check SSH service status:
sudo systemctl status sshd
# ● sshd.service - OpenSSH server daemon
#    Active: active (running)  <- Good!

# View SSH login attempts:
sudo journalctl -u sshd -n 20
# This shows the last 20 SSH log entries
```

#### SSH Key Management
```bash
# Set proper permissions
chmod 700 ~/.ssh
chmod 600 ~/.ssh/authorized_keys
chmod 600 ~/.ssh/id_*
chmod 644 ~/.ssh/*.pub

# Manage SSH keys
ssh-keygen -l -f ~/.ssh/id_ed25519.pub  # View fingerprint
ssh-keygen -R hostname                   # Remove host from known_hosts
```

### Setting Your Server's Identity

#### What is a Hostname?

A **hostname** is your server's name on the network. It's like a person's name - it helps identify the server. Instead of remembering IP addresses like 192.168.1.100, you can use names like "web-server" or "database".

#### Setting the Hostname

```bash
# Rocky Linux uses the hostnamectl command to manage hostnames
# First, let's see the current hostname:
hostnamectl status
# Static hostname: localhost.localdomain    <- Default generic name
# Icon name: computer-vm
# Chassis: vm
# Machine ID: abc123...
# Boot ID: def456...
# Virtualization: kvm
# Operating System: Rocky Linux 8.9 (Green Obsidian)
# Kernel: Linux 4.18.0-513.5.1.el8_9.x86_64
# Architecture: x86-64

# Set a meaningful hostname:
sudo hostnamectl set-hostname rocky-learn.example.com
# Format: name.domain.com
# rocky-learn = the server name you choose
# example.com = your domain (use your actual domain or .local for learning)

# You can also set a "pretty" hostname (with spaces and capitals):
sudo hostnamectl set-hostname "Rocky Learning Server" --pretty
# This is just for display purposes

# Verify the change:
hostnamectl status
# Static hostname: rocky-learn.example.com  <- Your new hostname!
# Pretty hostname: Rocky Learning Server

# The hostname is stored in this file:
cat /etc/hostname
# rocky-learn.example.com
```

#### Understanding /etc/hosts

The `/etc/hosts` file is like a local phone book for your computer. It maps names to IP addresses:

```bash
# View the current hosts file:
cat /etc/hosts
# 127.0.0.1   localhost localhost.localdomain
# ::1         localhost localhost.localdomain

# What these mean:
# 127.0.0.1 = IPv4 loopback (refers to "this computer")
# ::1       = IPv6 loopback (same thing for IPv6)
# localhost = Standard name for "this computer"

# Add your server's actual IP and hostname:
sudo nano /etc/hosts
# Add this line (replace with your actual IP):
192.168.1.100 rocky-learn.example.com rocky-learn

# Now your complete hosts file looks like:
127.0.0.1   localhost localhost.localdomain
::1         localhost localhost.localdomain
192.168.1.100 rocky-learn.example.com rocky-learn

# Why do this?
# - Some software needs to resolve the hostname to an IP
# - It works even if DNS is down
# - Faster than DNS lookups

# Test hostname resolution:
ping -c 1 rocky-learn
# PING rocky-learn (192.168.1.100) 56(84) bytes of data.
# Success! The name resolves to the IP
```

### Time Synchronization with Chrony

#### Configure Chrony
```bash
# Install chrony (usually pre-installed)
dnf install -y chrony

# Edit configuration
vi /etc/chrony.conf

# Add NTP servers
server 0.pool.ntp.org iburst
server 1.pool.ntp.org iburst
server 2.pool.ntp.org iburst

# Enable and start chrony
systemctl enable --now chronyd

# Check synchronization status
chronyc sources
chronyc tracking

# Set timezone
timedatectl set-timezone America/New_York
timedatectl status
```

### Understanding and Configuring the Firewall

#### What is a Firewall?

A **firewall** is like a security guard for your server. It decides what network traffic can come in and go out. Think of it like this:
- Your server is a building
- The firewall is the security desk
- Network packets are visitors
- The firewall checks if each visitor is allowed in

#### Introduction to firewalld

Rocky Linux uses **firewalld** as its firewall. It's different from the simple iptables you might have heard of - firewalld is smarter and easier to use!

```bash
# Check if firewalld is installed:
rpm -q firewalld
# firewalld-0.9.3-13.el8.noarch  <- It's installed!

# If not installed (rare), install it:
sudo dnf install -y firewalld

# Start the firewall and enable it to start at boot:
sudo systemctl enable --now firewalld
# Created symlink /etc/systemd/system/...
# This command does two things:
# enable = start automatically when system boots
# --now  = also start it right now

# Check if the firewall is running:
sudo firewall-cmd --state
# running  <- Good! Your firewall is protecting you

# See the default zone (think of zones as security levels):
sudo firewall-cmd --get-default-zone
# public  <- This is the standard zone for servers
```

#### Understanding Firewall Zones

**Zones** are like different security levels. Each network interface can be in a different zone:

- **public**: For untrusted networks (the internet) - most restrictive
- **internal**: For internal networks you mostly trust
- **trusted**: Everything is allowed (dangerous!)
- **drop**: Drops all incoming connections without reply (stealth mode)

```bash
# See what zone your network interface is using:
sudo firewall-cmd --get-active-zones
# public
#   interfaces: eth0
# This means eth0 (your network card) is using the "public" zone rules

# See what's currently allowed through the firewall:
sudo firewall-cmd --list-all
# public (active)
#   target: default
#   interfaces: eth0
#   services: cockpit dhcpv6-client ssh    <- These services are allowed
#   ports:                                  <- No custom ports open
#   protocols:
#   forward: no
#   masquerade: no
#   source-ports:
#   ...

# What do these default services mean?
# ssh = Secure Shell (port 22) - so you can connect!
# dhcpv6-client = Gets IPv6 addresses automatically
# cockpit = Web-based admin interface (port 9090)
```

#### Opening Ports for Services

```bash
# Let's say you want to run a web server. You need to open ports 80 (HTTP) and 443 (HTTPS):

# Method 1: Add by service name (recommended - easier to understand):
sudo firewall-cmd --permanent --add-service=http
sudo firewall-cmd --permanent --add-service=https
# success
# success

# What does --permanent mean?
# --permanent = Save this rule permanently (survives reboot)
# Without it = Rule is temporary (lost on reboot)

# Method 2: Add by port number (when there's no predefined service):
sudo firewall-cmd --permanent --add-port=8080/tcp
# This opens port 8080 for TCP traffic
# Format: port-number/protocol (tcp or udp)

# IMPORTANT: After adding permanent rules, reload the firewall:
sudo firewall-cmd --reload
# success

# Verify your changes:
sudo firewall-cmd --list-all
# services: cockpit dhcpv6-client http https ssh  <- http and https added!
# ports: 8080/tcp                                  <- Custom port added!

# To remove a service or port:
sudo firewall-cmd --permanent --remove-service=http
sudo firewall-cmd --permanent --remove-port=8080/tcp
sudo firewall-cmd --reload
```

#### Common Firewall Tasks

```bash
# See all available services you can add:
sudo firewall-cmd --get-services
# This shows dozens of predefined services like:
# ftp, mysql, postgresql, smtp, dns, nfs, samba, etc.

# Get details about a service:
sudo firewall-cmd --info-service=http
# http
#   ports: 80/tcp   <- HTTP uses port 80
#   protocols:
#   source-ports:
#   modules:
#   destination:

# Emergency: Block all traffic (panic mode):
sudo firewall-cmd --panic-on
# WARNING: This blocks EVERYTHING including SSH!
# To disable panic mode:
sudo firewall-cmd --panic-off

# Allow traffic from specific IP only:
sudo firewall-cmd --permanent --add-source=192.168.1.50
# Now only 192.168.1.50 can connect to services in this zone

# Check firewall logs (useful for troubleshooting):
sudo journalctl -u firewalld -n 20
# Shows last 20 firewall log entries
```

### SELinux: Your Security Guard

#### What is SELinux?

**SELinux (Security-Enhanced Linux)** is like having a very strict security guard that watches everything happening on your server. Even if someone breaks into your server, SELinux limits what they can do.

Think of it this way:
- **Without SELinux**: If someone breaks into your web server, they can access everything
- **With SELinux**: If someone breaks into your web server, they can only access web files

SELinux can be intimidating at first, but it's your friend!

#### SELinux Modes Explained

```bash
# Check what mode SELinux is in:
getenforce
# Enforcing  <- SELinux is actively protecting your system

# SELinux has three modes:
# 1. Enforcing = Full protection (blocks and logs violations)
# 2. Permissive = Logs violations but doesn't block (testing mode)
# 3. Disabled = SELinux is off (not recommended!)

# See detailed SELinux status:
sestatus
# SELinux status:                 enabled
# SELinuxfs mount:                /sys/fs/selinux
# SELinux root directory:         /etc/selinux
# Loaded policy name:             targeted
# Current mode:                   enforcing  <- Currently protecting you
# Mode from config file:          enforcing  <- Will be enforcing after reboot
# Policy MLS status:              enabled
# Policy deny_unknown status:     allowed
# Memory protection checking:     actual (secure)
# Max kernel policy version:      33
```

#### When SELinux Causes Problems (and How to Fix Them)

Sometimes SELinux blocks legitimate actions. Here's how to troubleshoot:

```bash
# Temporarily switch to permissive mode (for testing):
sudo setenforce 0
# Now SELinux logs violations but doesn't block them
# This helps you determine if SELinux is causing a problem

# Switch back to enforcing mode (always do this!):
sudo setenforce 1

# To permanently change SELinux mode (requires reboot):
sudo nano /etc/selinux/config
# Find this line:
# SELINUX=enforcing
# You can change to:
# SELINUX=permissive  <- For testing
# SELINUX=disabled    <- Never recommended!

# IMPORTANT: Always keep SELinux in enforcing mode for production!
```

#### Understanding SELinux Contexts

SELinux labels everything with a "context" - like a security clearance level:

```bash
# See SELinux context for files:
ls -Z /var/www/
# drwxr-xr-x. root root system_u:object_r:httpd_sys_content_t:s0 html
#                      \_________________________________/
#                                SELinux context

# The context has four parts:
# system_u  = SELinux user
# object_r  = SELinux role
# httpd_sys_content_t = Type (most important!)
# s0        = Security level

# Files in /var/www/ should have httpd_sys_content_t type
# This tells SELinux "the web server can read these files"

# See SELinux context for processes:
ps -eZ | grep sshd
# system_u:system_r:sshd_t:s0-s0:c0.c1023 1234 ? 00:00:00 sshd
#                   \_____/
#                   SSH daemon type
```

#### Common SELinux Fixes

```bash
# Problem: You uploaded web files and Apache can't read them
# Solution: Restore the correct SELinux context
sudo restorecon -Rv /var/www/html
# Relabeled /var/www/html/index.html from unconfined_u:object_r:user_tmp_t:s0
#   to system_u:object_r:httpd_sys_content_t:s0
# This fixes the context to what it should be!

# Problem: A service can't connect to the network
# Solution: Check and set SELinux booleans (on/off switches)

# See all booleans:
sudo getsebool -a | grep httpd
# httpd_can_network_connect --> off
# httpd_can_network_connect_db --> off
# ... many more ...

# Allow httpd to make network connections:
sudo setsebool -P httpd_can_network_connect on
# -P = Persistent (survives reboot)

# Verify it changed:
sudo getsebool httpd_can_network_connect
# httpd_can_network_connect --> on
```

#### SELinux Troubleshooting Tools

```bash
# Install helpful SELinux troubleshooting tools:
sudo dnf install -y setroubleshoot-server

# After installation, when SELinux blocks something, you'll see hints:
sudo journalctl -xe | grep sealert
# SELinux is preventing /usr/sbin/httpd from...
# For complete message run: sealert -l abc123def456

# Run the suggested command:
sudo sealert -l abc123def456
# This gives you:
# - What was blocked
# - Why it was blocked
# - How to fix it!

# View recent SELinux denials:
sudo ausearch -m avc -ts recent
# This shows what SELinux blocked recently

# Remember: SELinux errors often appear when:
# - Moving files from home directories to service directories
# - Services try to use non-standard ports
# - Services try to access unusual file locations
# The fix is usually restorecon or setting a boolean!
```

---

## Chapter 3: Command Line Mastery

### Navigating the Filesystem

#### Directory Structure
```bash
# Rocky Linux filesystem hierarchy
/
├── bin -> usr/bin      # Essential user commands
├── boot                 # Boot loader files
├── dev                  # Device files
├── etc                  # System configuration
├── home                 # User home directories
├── lib -> usr/lib      # Essential libraries
├── media               # Mount point for removable media
├── mnt                 # Temporary mount point
├── opt                 # Optional software
├── proc                # Process information
├── root                # Root user home
├── run                 # Runtime data
├── sbin -> usr/sbin    # System binaries
├── srv                 # Service data
├── sys                 # Kernel and system information
├── tmp                 # Temporary files
├── usr                 # User programs
└── var                 # Variable data

# Navigation commands
pwd                     # Print working directory
cd /path/to/directory   # Change directory
cd -                    # Previous directory
cd ~                    # Home directory
cd ..                   # Parent directory

# Listing files
ls -la                  # List all with details
ls -lah                 # Human-readable sizes
ls -lt                  # Sort by modification time
ls -ltr                 # Reverse time order
```

### Essential Rocky Linux Commands and Utilities

#### System Information Commands
```bash
# System identification
hostnamectl             # System and host information
uname -a               # Kernel information
cat /etc/redhat-release # Distribution version

# Resource monitoring
top                    # Process viewer
htop                   # Enhanced process viewer
free -h                # Memory usage
df -h                  # Disk usage
du -sh /path          # Directory size

# Process management
ps aux                 # All processes
pgrep process_name    # Find process ID
pkill process_name    # Kill by name
systemctl status      # SystemD units status
```

#### Package Management
```bash
# DNF/YUM commands (DNF is preferred in Rocky 8+)
dnf search package    # Search for package
dnf info package      # Package information
dnf install package   # Install package
dnf remove package    # Remove package
dnf update           # Update all packages
dnf history          # Transaction history
dnf clean all        # Clean cache
```

#### Network Commands
```bash
# Network configuration
ip addr show         # Show IP addresses
ip route show        # Show routing table
ss -tulpn           # Show listening ports
nmcli device status  # NetworkManager status
nmcli connection show # List connections
```

### Text Editors

#### Vi/Vim Basics
```bash
# Vim modes
# Normal mode: ESC
# Insert mode: i, a, o
# Command mode: :

# Basic commands
vi filename          # Open file
i                   # Insert mode
ESC                 # Exit to normal mode
:w                  # Save
:q                  # Quit
:wq                 # Save and quit
:q!                 # Quit without saving

# Navigation
h,j,k,l            # Left, down, up, right
gg                 # Go to beginning
G                  # Go to end
:n                 # Go to line n

# Editing
dd                 # Delete line
yy                 # Copy line
p                  # Paste
u                  # Undo
Ctrl+r             # Redo
/pattern           # Search forward
?pattern           # Search backward
:%s/old/new/g      # Replace all
```

#### Nano Editor
```bash
# Nano basics
nano filename      # Open file

# Key combinations (^ means Ctrl)
^G    # Get help
^O    # Write out (save)
^X    # Exit
^K    # Cut line
^U    # Paste
^W    # Search
^\    # Replace
^C    # Current position
```

### File Permissions and Ownership

#### Permission Model
```bash
# Permission structure: -rwxrwxrwx
# Type: - (file), d (directory), l (link)
# Owner: rwx (read, write, execute)
# Group: rwx
# Others: rwx

# Numeric representation
# 4 = read, 2 = write, 1 = execute
# 755 = rwxr-xr-x
# 644 = rw-r--r--

# Change permissions
chmod 755 file
chmod u+x file      # Add execute for owner
chmod g-w file      # Remove write for group
chmod o=r file      # Set others to read only

# Change ownership
chown user:group file
chown -R user:group directory
chgrp group file

# Special permissions
chmod u+s file      # SUID
chmod g+s directory # SGID
chmod +t directory  # Sticky bit
```

### Process Management with SystemD

#### SystemD Basics
```bash
# Service management
systemctl start service
systemctl stop service
systemctl restart service
systemctl reload service
systemctl status service
systemctl enable service   # Start at boot
systemctl disable service  # Don't start at boot

# List units
systemctl list-units --type=service
systemctl list-units --failed
systemctl list-unit-files

# View logs
journalctl -u service
journalctl -f              # Follow logs
journalctl --since "1 hour ago"
journalctl -b              # Boot logs
```

### Using tmux/screen for Persistence

#### tmux Basics
```bash
# Install tmux
dnf install -y tmux

# Session management
tmux new -s session-name   # New session
tmux ls                     # List sessions
tmux attach -t session-name # Attach to session
tmux detach                 # Detach (Ctrl+b, d)
tmux kill-session -t session-name

# Window management (Ctrl+b, then)
c    # Create window
n    # Next window
p    # Previous window
0-9  # Switch to window number
,    # Rename window
&    # Kill window

# Pane management (Ctrl+b, then)
%    # Split vertically
"    # Split horizontally
o    # Switch pane
x    # Kill pane
z    # Zoom pane
```

#### Screen Alternative
```bash
# Install screen
dnf install -y screen

# Basic usage
screen -S session-name     # New session
screen -ls                 # List sessions
screen -r session-name     # Reattach
Ctrl+a, d                  # Detach
screen -X -S session-name quit # Kill session
```

### Command History and Shell Configuration

#### Bash History
```bash
# History commands
history              # Show command history
history 20           # Last 20 commands
!n                   # Execute command n
!!                   # Execute last command
!string              # Execute last command starting with string
Ctrl+r               # Reverse search history

# History configuration in ~/.bashrc
export HISTSIZE=10000
export HISTFILESIZE=20000
export HISTCONTROL=ignoredups:erasedups
export HISTTIMEFORMAT="%Y-%m-%d %H:%M:%S "
```

#### Shell Configuration
```bash
# Bash configuration files
~/.bashrc           # User shell config
~/.bash_profile     # User login shell
/etc/bashrc         # System shell config
/etc/profile        # System login shell

# Useful aliases in ~/.bashrc
alias ll='ls -lah'
alias la='ls -A'
alias l='ls -CF'
alias grep='grep --color=auto'
alias df='df -h'
alias free='free -h'
alias update='sudo dnf update'
alias search='sudo dnf search'
alias install='sudo dnf install'

# Custom prompt
PS1='[\u@\h \W]\$ '  # Default Rocky Linux prompt
PS1='\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '

# Apply changes
source ~/.bashrc
```

### Rocky Linux Tools and Utilities

#### System Configuration Tools
```bash
# System configuration
system-config-*         # Various GUI tools
nmtui                   # Network configuration TUI
firewall-config         # Firewall GUI
authconfig-tui          # Authentication configuration

# Performance tools
tuned-adm list          # List tuning profiles
tuned-adm active        # Current profile
tuned-adm recommend     # Recommended profile
tuned-adm profile balanced  # Set profile

# Package management tools
dnf needs-restarting    # Services needing restart
dnf history info        # Transaction details
package-cleanup         # Clean package problems

# Security tools
oscap                   # Security compliance scanning
aide                    # File integrity monitoring
audit2allow             # SELinux policy generation
```

#### Cockpit Web Console
```bash
# Install Cockpit
dnf install -y cockpit

# Enable and start
systemctl enable --now cockpit.socket

# Access via browser
# https://server-ip:9090

# Add firewall rule
firewall-cmd --permanent --add-service=cockpit
firewall-cmd --reload
```

## Practice Exercises

### Exercise 1: System Setup
1. Create a new administrative user
2. Configure SSH key authentication
3. Disable root SSH login
4. Set up basic firewall rules
5. Configure time synchronization

### Exercise 2: SELinux Practice
1. Check current SELinux mode
2. View contexts for /var/www/html
3. Set a boolean for httpd
4. Restore default contexts
5. Review audit logs

### Exercise 3: Command Line Skills
1. Navigate to /var/log and find the largest file
2. Create a tmux session with multiple windows
3. Set up useful bash aliases
4. Practice vim by editing configuration files
5. Use systemctl to manage services

### Exercise 4: System Information
1. Gather complete system information
2. Check for available updates
3. List all enabled services
4. Monitor system resources
5. Review system logs for errors

## Summary

In Part 1, we've covered the fundamentals of getting started with Rocky Linux systems:

1. **Understanding the Enterprise Linux ecosystem** - Rocky Linux and its compatibility with RHEL and AlmaLinux
2. **Initial server setup** - From first login to basic security configuration
3. **Command line mastery** - Essential commands, tools, and techniques for effective system administration

Key takeaways:
- Rocky Linux uses SystemD for service management
- SELinux provides mandatory access control
- firewalld manages network security
- dnf/yum handles package management
- NetworkManager controls network configuration

These foundational skills prepare you for more advanced topics in system administration, including user management, storage configuration, and service deployment in enterprise environments.

## Additional Resources

- [Rocky Linux Documentation](https://docs.rockylinux.org/)
- [Rocky Linux Forums](https://forums.rockylinux.org/)
- [Rocky Linux Wiki](https://wiki.rockylinux.org/)
- [AlmaLinux Wiki](https://wiki.almalinux.org/)
- [Enterprise Linux Documentation (RHEL)](https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/)
- [SELinux Project Documentation](https://selinuxproject.org/)

---

*Continue to Part 2: Core System Administration*