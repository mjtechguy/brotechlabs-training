# Part 1: Getting Started with Ubuntu in Cloud VMs

## Prerequisites and Learning Resources

Before starting this course, you should have:
- Basic computer literacy (understanding of files, folders, and programs)
- Access to a cloud VM running Ubuntu 24.04 LTS
- A terminal or SSH client on your local computer

**Helpful Resources:**
- Ubuntu Official Documentation: https://ubuntu.com/server/docs
- Linux Command Line Basics: https://linuxcommand.org/
- Cloud-init Documentation: https://cloudinit.readthedocs.io/
- SSH Guide: https://www.ssh.com/academy/ssh

---

## Chapter 1: Understanding Cloud VMs vs Traditional Servers

### Introduction

When you provision an Ubuntu server in a cloud environment, you're working with a **virtual machine (VM)**. But what exactly is a virtual machine?

**Virtual Machine (VM)**: A VM is essentially a computer that runs inside another computer. It's a software-based simulation of a physical computer, complete with its own operating system, applications, and virtual hardware. Think of it like having multiple computers running on one physical machine, each isolated from the others.

**Cloud VM**: A virtual machine that runs in a cloud provider's data center rather than on your own hardware. You rent these VMs by the hour or minute, and can create or destroy them with a few commands.

### Key Concepts Explained

#### What is "Ephemeral"?
**Ephemeral** means temporary or short-lived. In cloud computing, this means your VM can be destroyed at any time (intentionally or due to hardware failure), so you must design your systems to handle this. Unlike a physical server in your office that might run for years, cloud VMs are designed to be disposable.

```bash
# Traditional server approach (treating servers as "pets"):
# - You give it a name like "webserver1"
# - You manually install and configure software
# - You fix it when it breaks
# - Losing it would be catastrophic

# Cloud VM approach (treating servers as "cattle"):
# - Servers have generic identifiers
# - Everything is automated via scripts
# - If one breaks, you destroy it and create a new one
# - Losing one is no big deal
```

#### What is an API?
**API (Application Programming Interface)**: A set of rules and protocols that allows different software programs to communicate with each other. In cloud computing, APIs let you control your VMs programmatically (through code) rather than clicking buttons in a web interface.

```bash
# Example: Instead of clicking "Create VM" in a web console, you might run:
# aws ec2 run-instances --image-id ami-12345 --instance-type t2.micro
# This API call creates a new VM programmatically
```

### Storage Types Explained

In cloud VMs, storage works differently than on your personal computer:

#### Root/Boot Volume
The **root volume** (also called boot volume) is where your operating system is installed. Think of it like your computer's main hard drive with Windows or macOS.

```bash
# The df command shows "disk free" space
# -h means "human readable" (shows MB, GB instead of bytes)
df -h /

# Understanding the output:
# Filesystem      Size  Used Avail Use% Mounted on
# /dev/xvda1       20G  2.5G   17G  13% /

# Let's break this down:
# - /dev/xvda1: The device name (like C: drive in Windows)
# - 20G: Total size is 20 gigabytes
# - 2.5G: Currently using 2.5 gigabytes
# - 17G: 17 gigabytes available
# - 13%: Using 13% of the disk
# - /: Mounted at root (the top of the filesystem tree)
```

#### Data Volumes
**Data volumes** are additional storage you can attach to your VM, like plugging in an external USB drive to your laptop.

```bash
# The lsblk command means "list block devices" (storage devices)
lsblk

# Understanding the output:
# NAME    MAJ:MIN RM  SIZE RO TYPE MOUNTPOINT
# xvda    202:0    0   20G  0 disk             <- Main disk
# └─xvda1 202:1    0   20G  0 part /           <- Root partition
# xvdf    202:80   0  100G  0 disk             <- Additional volume (not mounted yet)

# To use an additional volume, you need to:
# 1. Create a filesystem on it (format it)
# 2. Mount it (make it accessible at a specific location)
# We'll cover this in detail in Part 3: Storage and Filesystems
```

### Cloud-init: Automated Server Setup

**Cloud-init** is a tool that automatically configures your VM when it first boots. Instead of manually logging in and running commands to set up your server, cloud-init does it for you automatically.

#### Understanding Cloud-init

Think of cloud-init like a recipe that runs automatically when you create a new VM:
1. You write instructions (the recipe)
2. You give these instructions to the cloud provider when creating the VM
3. Cloud-init runs your instructions automatically on first boot
4. Your server is ready to use without manual configuration

#### Cloud-init Configuration Languages

Cloud-init can understand instructions in two main formats:

1. **Cloud-config (YAML format)** - Structured configuration
2. **Bash scripts** - Regular shell commands

```yaml
#cloud-config
# This line MUST be the first line to identify this as cloud-config format
# YAML uses indentation (spaces, not tabs) to show structure

# Example explanation:
hostname: webserver-01  # Sets the computer's name
manage_etc_hosts: true  # Updates the hosts file automatically

# The 'users' section creates new user accounts
users:
  - default  # Keep the default 'ubuntu' user
  - name: sysadmin  # Create a new user called 'sysadmin'
    groups: sudo  # Add to sudo group (can run admin commands)
    shell: /bin/bash  # Use bash as their shell (command interpreter)
    sudo: ['ALL=(ALL) NOPASSWD:ALL']  # Can run any command as admin without password
    ssh_authorized_keys:  # SSH public keys that can login as this user
      - ssh-rsa AAAAB3NzaC1... admin@company.com

# Automatically install software packages
package_update: true  # Update package list (like app store refresh)
package_upgrade: true  # Upgrade existing packages to latest versions
packages:  # List of packages to install
  - htop  # Interactive process viewer (we'll explain this later)
  - git   # Version control system
  - vim   # Text editor

# Run shell commands after setup
runcmd:
  - echo "Server provisioned at $(date)" >> /var/log/provision.log
  - systemctl restart ssh  # Restart SSH service to apply any changes
```

Alternatively, you can use a bash script:

```bash
#!/bin/bash
# This is a bash script format for cloud-init

# Update packages
apt-get update
apt-get upgrade -y

# Install software
apt-get install -y nginx

# Start services
systemctl enable nginx
systemctl start nginx

echo "Setup complete!"
```

**Learn more about cloud-init:**
- Official Tutorial: https://cloudinit.readthedocs.io/en/latest/tutorial/
- Examples: https://cloudinit.readthedocs.io/en/latest/reference/examples.html

### SSH: Secure Shell Explained

**SSH (Secure Shell)** is a protocol that lets you securely connect to and control a remote computer over the internet. Think of it like remote desktop, but for the command line.

#### How SSH Works

SSH uses **cryptographic keys** for security instead of just passwords:

1. **Key Pair**: You generate two mathematically related keys:
   - **Private Key**: Secret key you keep on your computer (like a house key)
   - **Public Key**: Can be shared freely (like a lock that only your key opens)

2. **Authentication Process**:
   - Server has your public key in its "authorized keys" list
   - You connect using your private key
   - Server verifies they match
   - You're granted access

#### Generating SSH Keys

```bash
# ssh-keygen is the command to generate SSH keys
# Let's break down each option:

ssh-keygen -t ed25519 -C "your-email@example.com" -f ~/.ssh/cloud-vm-key

# -t ed25519: Type of encryption (ed25519 is modern and secure)
#            Alternative: -t rsa -b 4096 (older but widely compatible)
# -C "comment": Adds a comment/label to identify the key
# -f filepath: Where to save the key

# This creates two files:
# ~/.ssh/cloud-vm-key       - Private key (NEVER SHARE THIS!)
# ~/.ssh/cloud-vm-key.pub   - Public key (safe to share)

# The ~ symbol means "home directory"
# On Linux/Mac: /home/yourusername/
# On Windows: C:\Users\yourusername\
```

#### SSH Configuration File

The SSH config file lets you create shortcuts for connecting to servers:

```bash
# Edit or create ~/.ssh/config
# This file stores connection shortcuts

Host ubuntu-cloud           # Nickname for this connection
    HostName 203.0.113.10   # The server's IP address or domain
    User ubuntu             # Username to connect as
    IdentityFile ~/.ssh/cloud-vm-key  # Which private key to use
    ServerAliveInterval 60  # Send keepalive every 60 seconds
    ServerAliveCountMax 3   # Disconnect after 3 failed keepalives

# Now instead of typing:
# ssh -i ~/.ssh/cloud-vm-key ubuntu@203.0.113.10

# You can simply type:
# ssh ubuntu-cloud
```

**Learn more about SSH:**
- SSH Academy: https://www.ssh.com/academy/ssh
- OpenSSH Manual: https://www.openssh.com/manual.html

### Instance Metadata Service

The **metadata service** is a special feature of cloud VMs that provides information about the instance from within the instance itself.

#### What is 169.254.169.254?

This is a **link-local address** - a special IP address that only works from within the VM. It's like asking "what's my own phone number?" - the cloud provider answers with information about your VM.

```bash
# curl is a command-line tool for downloading data from URLs
# -s means "silent" (don't show progress bar)

# Get your instance ID (unique identifier)
curl http://169.254.169.254/latest/meta-data/instance-id
# Example output: i-1234567890abcdef0

# Get your public IP address
curl http://169.254.169.254/latest/meta-data/public-ipv4
# Example output: 54.123.45.67

# Get the cloud-init script that was used to set up this VM
curl http://169.254.169.254/latest/user-data

# Why is this useful?
# Your scripts can discover information about themselves
# Example: A web server can find its own IP to configure itself
```

### VM Lifecycle States

Understanding VM states helps you avoid losing data:

```bash
# RUNNING STATE
# - Your VM is turned on and working
# - You're being charged for compute time
# - All your data is accessible
# Think of it: Like your laptop being turned on

# STOPPED STATE
# - VM is turned off but not deleted
# - No compute charges (but still paying for storage)
# - Your data is preserved
# - Public IP might change when you restart
# Think of it: Like closing your laptop lid (sleep mode)

# TERMINATED/DELETED STATE
# - VM is permanently destroyed
# - All data on root volume is lost
# - Cannot be recovered
# Think of it: Like throwing your laptop in the trash

# Best Practice: Always backup important data!
```

---

## Chapter 2: Initial Server Setup

### First Login and Orientation

When you first connect to your Ubuntu cloud VM, you need to understand what you're looking at and what commands help you explore the system.

#### Connecting via SSH

```bash
# SSH (Secure Shell) connects you to your server
# Basic syntax: ssh username@server-address
ssh ubuntu@your-server-ip

# You might see this message first time:
# "The authenticity of host 'x.x.x.x' can't be established.
#  ECDSA key fingerprint is SHA256:...
#  Are you sure you want to continue connecting (yes/no)?"
#
# Type 'yes' - this adds the server to your known_hosts file
# This is like saving a phone number - SSH remembers this server
```

#### Understanding System Information Commands

```bash
# lsb_release shows Linux distribution information
# LSB = Linux Standard Base
# -a means "all information"
lsb_release -a

# Output explanation:
# Distributor ID: Ubuntu          <- The distribution name
# Description: Ubuntu 24.04 LTS   <- Version and type
# Release: 24.04                  <- Version number
# Codename: noble                 <- Version codename

# LTS means "Long Term Support" - supported for 5 years
```

```bash
# uname shows system information
# uname = "Unix name"
# -a means "all"
uname -a

# Output breakdown:
# Linux hostname 6.8.0-35-generic #35-Ubuntu SMP PREEMPT_DYNAMIC x86_64 GNU/Linux
# Linux           - Operating system
# hostname        - Computer name
# 6.8.0-35        - Kernel version
# generic         - Kernel type
# x86_64          - Architecture (64-bit Intel/AMD)
# GNU/Linux       - OS type
```

```bash
# free shows memory (RAM) usage
# -h means "human readable" (shows MB/GB instead of bytes)
free -h

# Output explanation:
#               total        used        free      shared  buff/cache   available
# Mem:           1.9G        423M        892M        1.0M        647M        1.3G
# Swap:            0B          0B          0B

# Mem = RAM (Random Access Memory - temporary fast storage)
# Swap = Disk space used as overflow when RAM is full
# total = Total RAM installed
# used = Currently being used by programs
# free = Completely unused
# buff/cache = Used for speeding up disk access (can be freed if needed)
# available = Can be used by programs (includes freeable cache)
```

```bash
# df shows disk usage
# df = "disk free"
# -h = human readable
df -h

# Output explanation:
# Filesystem      Size  Used Avail Use% Mounted on
# /dev/xvda1       20G  2.5G   17G  13% /

# Each line is a storage device:
# Filesystem - Device name
# Size - Total space
# Used - Space used
# Avail - Space available
# Use% - Percentage used
# Mounted on - Where it appears in the file system
```

```bash
# nproc shows number of CPU cores
nproc
# Output: 2  (means you have 2 CPU cores)

# CPU core = A processor unit that can execute instructions
# More cores = Can do more things at once
```

### Understanding Users in Linux

Linux is a **multi-user** system - multiple people can use the same computer simultaneously, each with their own files and settings.

#### User Concepts

**User Account**: An identity on the system with:
- Username (like 'john')
- User ID (UID) - a number (like 1000)
- Home directory (personal folder like /home/john)
- Shell (command interpreter, usually /bin/bash)
- Groups (collections of users)

**Special Users**:
- **root**: The administrator account (UID 0) - can do anything
- **System users**: Used by services (like www-data for web servers)

#### Creating Users

```bash
# adduser is the friendly Ubuntu command for creating users
# It asks questions interactively
sudo adduser johnadmin

# sudo means "Super User DO" - run this command as administrator
# Without sudo, you get "Permission denied"

# The command will ask for:
# - Password (type twice for confirmation)
# - Full Name
# - Room Number (optional - just press Enter)
# - Work Phone (optional)
# - Home Phone (optional)
# - Other (optional)

# Behind the scenes, this creates:
# - User entry in /etc/passwd
# - Password in /etc/shadow (encrypted)
# - Home directory at /home/johnadmin
# - Default shell (/bin/bash)
```

```bash
# useradd is the lower-level command (less friendly)
# You must specify everything explicitly

sudo useradd -m -s /bin/bash -G sudo,adm -c "Jane Admin" jane

# Let's break down each option:
# -m: Create home directory
# -s /bin/bash: Set shell to bash
# -G sudo,adm: Add to groups 'sudo' and 'adm'
# -c "Jane Admin": Comment/full name
# jane: The username

# Set password separately:
sudo passwd jane
```

### Understanding sudo

**sudo** stands for "Super User DO". It lets normal users run commands as the administrator (root user).

#### Why use sudo instead of logging in as root?

1. **Security**: Root can do anything - one mistake could destroy the system
2. **Accountability**: sudo logs who did what
3. **Granular control**: Can give specific permissions to specific users

```bash
# Check if you have sudo access
sudo -l

# Output shows what commands you can run:
# User ubuntu may run the following commands:
#     (ALL : ALL) ALL
# This means: you can run ANY command as ANY user

# How sudo works:
# 1. You type: sudo command
# 2. System asks for YOUR password (not root's)
# 3. System checks if you're allowed
# 4. If yes, runs command as root
# 5. Logs the action
```

#### Configuring sudo

```bash
# visudo safely edits the sudo configuration
# It checks for errors before saving (prevents lockout)
sudo visudo

# The file uses this format:
# who where = (as_whom) what

# Examples:
johnadmin ALL=(ALL:ALL) ALL
# johnadmin - username
# ALL - from any terminal
# (ALL:ALL) - as any user:any group
# ALL - can run any command

# Give specific permissions:
webadmin ALL=(ALL) NOPASSWD: /usr/bin/systemctl restart nginx
# webadmin can restart nginx without entering password
```

**WARNING**: Never edit /etc/sudoers directly with a regular text editor! Always use `visudo` - it prevents syntax errors that could lock you out.

### SSH Configuration Explained

#### SSH Hardening

**Hardening** means making something more secure. For SSH, this means changing settings to prevent unauthorized access.

```bash
# First, always backup configuration files before changing them!
sudo cp /etc/ssh/sshd_config /etc/ssh/sshd_config.backup

# sshd_config is the SSH server configuration
# sshd = SSH daemon (the program that accepts connections)
```

Let's understand each security setting:

```bash
# Edit with nano (a simple text editor - we'll explain below)
sudo nano /etc/ssh/sshd_config

# Key security settings:

PermitRootLogin no
# Prevents logging in directly as root
# Must login as normal user, then use sudo

PasswordAuthentication no
# Disables password logins
# Only SSH keys allowed (much more secure)

PubkeyAuthentication yes
# Enables SSH key authentication

PermitEmptyPasswords no
# Never allow blank passwords

MaxAuthTries 3
# Only 3 login attempts before disconnection
# Prevents brute-force attacks

ClientAliveInterval 300
# Send keepalive every 300 seconds (5 minutes)
# Detects and closes dead connections

ClientAliveCountMax 2
# Disconnect after 2 failed keepalives

X11Forwarding no
# Disables GUI application forwarding
# Not needed for servers

AllowUsers ubuntu johnadmin
# ONLY these users can SSH in
# Everyone else is blocked
```

After making changes:

```bash
# Test the configuration for errors
sudo sshd -t
# No output = configuration is valid
# Errors will be shown if there are problems

# Restart SSH to apply changes
sudo systemctl restart ssh

# IMPORTANT: Keep your current session open!
# Test login in a new terminal before closing this one
# If you made a mistake, you can fix it from the open session
```

### Text Editors Explained

Linux has many text editors. Here are the most important ones for beginners:

#### nano - The Beginner-Friendly Editor

**nano** is a simple, easy-to-use terminal text editor. If you've used Notepad on Windows, nano is similar.

```bash
# Open a file with nano
nano filename.txt

# The interface shows:
# - Text content in the middle
# - Shortcuts at the bottom (^ means Ctrl key)

# Essential nano shortcuts:
# Ctrl+O : Save file (O for "Output")
# Ctrl+X : Exit nano (X for "eXit")
# Ctrl+W : Search (W for "Where is")
# Ctrl+K : Cut line (K for "Kut")
# Ctrl+U : Paste (U for "Uncut")
# Ctrl+G : Help (G for "Get help")

# The bottom shows: ^X Exit  ^O Write Out
# This means: Press Ctrl+X to exit, Ctrl+O to save
```

**When to use nano**:
- Quick edits
- You're new to Linux
- You want something simple

**Learn more**: https://www.nano-editor.org/dist/latest/nano.html

#### vim - The Power User Editor

**vim** is a powerful but complex editor. It has different "modes" which confuses beginners.

```bash
# Open a file with vim
vim filename.txt

# vim has modes:
# 1. Normal mode (default) - For navigation and commands
# 2. Insert mode - For typing text
# 3. Command mode - For saving, quitting, etc.

# Basic vim workflow:
# 1. Open file: vim file.txt
# 2. Press 'i' to enter Insert mode (now you can type)
# 3. Type your text
# 4. Press ESC to return to Normal mode
# 5. Type :wq and press Enter (w=write/save, q=quit)

# Emergency exit from vim:
# If stuck: Press ESC, then type :q! and Enter
# This quits without saving
```

**When to use vim**:
- You want to become a Linux power user
- You need advanced text manipulation
- You work on many different servers

**Learn vim interactively**: Type `vimtutor` in your terminal for a built-in tutorial

### Understanding the Firewall (UFW)

A **firewall** is like a security guard for your server - it controls what network traffic is allowed in and out.

**UFW** stands for "Uncomplicated Firewall" - Ubuntu's user-friendly firewall tool.

#### How Firewalls Work

Think of your server like a building:
- It has many doors (ports)
- Each door is numbered (port numbers)
- Services use specific doors (SSH uses port 22, web uses port 80)
- The firewall controls which doors are open

```bash
# Install UFW (usually pre-installed)
sudo apt update        # Update package list
sudo apt install ufw   # Install UFW

# Set default policies
# This is like saying: "Lock all doors, but allow people to leave"
sudo ufw default deny incoming   # Block all incoming traffic
sudo ufw default allow outgoing  # Allow all outgoing traffic

# CRITICAL: Allow SSH before enabling!
# If you don't, you'll lock yourself out!
sudo ufw allow 22/tcp
# This opens port 22 for TCP traffic (SSH uses this)

# Alternative if you changed SSH port:
sudo ufw allow 2222/tcp

# Common services and their ports:
sudo ufw allow 80/tcp    # HTTP (web traffic)
sudo ufw allow 443/tcp   # HTTPS (secure web traffic)
sudo ufw allow 3306/tcp  # MySQL database

# Enable the firewall
sudo ufw enable
# It will warn: "This may disrupt existing ssh connections"
# Type 'y' if you allowed SSH above

# Check firewall status
sudo ufw status verbose

# Output explanation:
# Status: active                          <- Firewall is on
# To                         Action      From
# --                         ------      ----
# 22/tcp                     ALLOW IN    Anywhere    <- SSH allowed
# 80/tcp                     ALLOW IN    Anywhere    <- HTTP allowed
```

### System Updates Explained

Keeping your system updated is crucial for security. Updates fix bugs and security vulnerabilities.

#### Understanding Package Management

Ubuntu uses **packages** to install software. Think of packages like apps on a phone:
- **Package**: A bundle of files that make up a program
- **Repository**: Like an app store where packages are stored
- **APT**: Advanced Package Tool - Ubuntu's package manager

```bash
# Update the package list
# This downloads the latest list of available packages
# Like refreshing your app store
sudo apt update

# Output explanation:
# Hit:1 http://archive.ubuntu.com/ubuntu noble InRelease
# Get:2 http://archive.ubuntu.com/ubuntu noble-updates InRelease
# Hit = Already have latest info
# Get = Downloading new info

# View available updates
apt list --upgradable

# Upgrade all packages
sudo apt upgrade -y
# -y means "yes to all prompts"

# Behind the scenes:
# 1. Downloads new versions
# 2. Unpacks them
# 3. Replaces old files
# 4. Restarts affected services
```

#### Automatic Security Updates

```bash
# Install unattended-upgrades for automatic security updates
sudo apt install unattended-upgrades

# Configure it
sudo dpkg-reconfigure -plow unattended-upgrades
# This opens a dialog asking if you want automatic updates
# Select "Yes"

# What this does:
# - Automatically installs security updates daily
# - Logs what it does
# - Can email you reports
# - Won't break your system (only security updates)
```

### Terminal Multiplexers Explained

A **terminal multiplexer** lets you run multiple terminal sessions in one connection. This is crucial for cloud servers because:
1. Your commands keep running even if you disconnect
2. You can have multiple windows/panes
3. You can return to exactly where you left off

#### tmux - Terminal Multiplexer

**tmux** lets you create persistent terminal sessions that survive disconnections.

```bash
# Install tmux
sudo apt install tmux

# Start a new tmux session
tmux
# Your terminal now runs inside tmux

# Basic concept:
# - Session: A collection of windows (like a workspace)
# - Window: A full-screen terminal (like browser tabs)
# - Pane: Split window into sections

# The control key: Ctrl+b
# Press Ctrl+b, then another key for commands

# Essential tmux commands:
# Ctrl+b, then:
# d     - Detach (leave session running)
# c     - Create new window
# n     - Next window
# p     - Previous window
# %     - Split vertically
# "     - Split horizontally
# arrows - Move between panes
# x     - Kill current pane

# List sessions
tmux ls

# Reattach to session
tmux attach
# or
tmux attach -t session-name

# Why this matters:
# Start a long-running task in tmux
# Disconnect from server
# Come back hours later
# Reattach - your task is still running!
```

**Learn tmux**: https://github.com/tmux/tmux/wiki/Getting-Started

#### screen - Alternative to tmux

**screen** is older but still widely used. Similar concept to tmux but different commands.

```bash
# Install screen
sudo apt install screen

# Start new screen session
screen

# Control key: Ctrl+a
# Press Ctrl+a, then another key

# Essential screen commands:
# Ctrl+a, then:
# d - Detach
# c - Create new window
# n - Next window
# p - Previous window
# k - Kill window

# List sessions
screen -ls

# Reattach
screen -r
```

Choose **tmux** if learning fresh (more modern), or **screen** if that's what your team uses.

### Command History and Aliases

#### Command History

Linux remembers commands you've typed before:

```bash
# See your command history
history

# Output shows numbered list:
# 1  ssh ubuntu@server
# 2  sudo apt update
# 3  sudo apt upgrade

# Rerun command by number
!2  # Runs command #2 (sudo apt update)

# Run last command again
!!

# Run last command starting with 'sudo'
!sudo

# Search history (Ctrl+R)
# Press Ctrl+R, then start typing
# It finds matching commands
# Press Enter to run, or Ctrl+C to cancel
```

#### Aliases - Command Shortcuts

**Aliases** are nicknames for commands. Instead of typing long commands, create short aliases:

```bash
# Create an alias (temporary - only for this session)
alias ll='ls -la'

# Now typing 'll' runs 'ls -la'

# Common aliases to add to ~/.bashrc (permanent):
alias ll='ls -alF'          # List files with details
alias la='ls -A'            # List all including hidden
alias l='ls -CF'            # List in columns
alias ..='cd ..'            # Go up one directory
alias ...='cd ../..'        # Go up two directories
alias update='sudo apt update && sudo apt upgrade'
alias cls='clear'           # Clear screen
alias h='history'           # Show history

# To make permanent, add to ~/.bashrc:
echo "alias ll='ls -alF'" >> ~/.bashrc

# Reload bashrc to apply:
source ~/.bashrc
```

### Key Takeaways

1. **Always secure SSH first** - It's your only way into the server
2. **Use SSH keys instead of passwords** - Much more secure
3. **Enable the firewall but allow SSH first** - Don't lock yourself out
4. **Keep your system updated** - Security patches are critical
5. **Use tmux or screen** - Persistent sessions are essential for cloud servers
6. **Learn one text editor well** - Start with nano, consider vim later
7. **Create aliases for common commands** - Save time and reduce errors
8. **Regular users + sudo is safer than using root** - Prevents accidents

### Recommended Learning Path

1. **Week 1**: Master basic navigation and nano editor
2. **Week 2**: Get comfortable with users, groups, and sudo
3. **Week 3**: Practice with SSH and firewall configuration
4. **Week 4**: Learn tmux and start creating aliases
5. **Ongoing**: Gradually learn vim and advanced commands

### Additional Resources

- **Ubuntu Server Guide**: https://ubuntu.com/server/docs
- **Linux Journey** (free tutorial): https://linuxjourney.com/
- **The Linux Command Line** (free book): https://linuxcommand.org/tlcl.php
- **DigitalOcean Tutorials**: https://www.digitalocean.com/community/tutorials
- **Learn vim**: https://vim-adventures.com/ (gamified learning)
- **tmux Tutorial**: https://leimao.github.io/blog/Tmux-Tutorial/

---

## Chapter 3: Command Line Mastery

### Understanding the Linux Filesystem

Before we dive into commands, let's understand how Linux organizes files. Unlike Windows with drive letters (C:, D:), Linux has a single tree structure starting from root (/).

#### The Directory Tree

```bash
/                   # Root - top of the filesystem tree
├── home           # User home directories
│   ├── ubuntu     # Ubuntu user's personal folder
│   └── john       # John's personal folder
├── etc            # System configuration files
├── var            # Variable data (logs, databases)
│   ├── log        # System and application logs
│   └── www        # Web server files
├── usr            # User programs and utilities
│   ├── bin        # User command binaries
│   └── local      # Locally installed software
├── opt            # Optional/third-party software
├── tmp            # Temporary files (cleared on reboot)
├── dev            # Device files (hard drives, etc.)
├── proc           # Process and kernel information
└── root           # Root user's home directory
```

### Essential Navigation Commands

#### pwd - Print Working Directory

```bash
# pwd shows where you are in the filesystem
pwd

# Output: /home/ubuntu
# This means you're in the ubuntu folder, inside home folder

# Think of it like: "What folder am I in right now?"
```

#### cd - Change Directory

```bash
# cd changes your current location

cd /var/log          # Go to /var/log (absolute path)
cd nginx             # Go into nginx folder (relative path)
cd ..                # Go up one level
cd ../..             # Go up two levels
cd ~                 # Go to your home directory
cd -                 # Go to previous directory

# Absolute vs Relative paths:
# Absolute: Starts with / (from root)
# Example: /home/ubuntu/documents

# Relative: From current location
# Example: documents (if you're in /home/ubuntu)

# Special directories:
# .  = Current directory
# .. = Parent directory
# ~  = Home directory
# -  = Previous directory
```

#### ls - List Directory Contents

```bash
# ls shows files and folders

ls                   # Basic listing
ls -l                # Long format (detailed)
ls -a                # All files (including hidden)
ls -la               # Combine options
ls -lah              # Human-readable sizes
ls -lat              # Sort by time, newest first

# Understanding ls -l output:
# -rw-r--r-- 1 ubuntu ubuntu 4096 Jan 15 10:30 file.txt

# Let's break this down:
# -rw-r--r-- = Permissions (we'll explain this in detail)
# 1          = Number of hard links
# ubuntu     = Owner
# ubuntu     = Group
# 4096       = Size in bytes
# Jan 15 10:30 = Last modified date and time
# file.txt   = Filename

# Hidden files start with a dot (.)
# .bashrc, .ssh, etc.
```

### File Operations

#### cp - Copy Files

```bash
# cp copies files and directories

cp source.txt dest.txt           # Copy file
cp -r sourcedir/ destdir/        # Copy directory recursively
cp -p file.txt file_backup.txt   # Preserve permissions and timestamps
cp -i file.txt newfile.txt       # Interactive (ask before overwrite)

# -r = recursive (needed for directories)
# -p = preserve attributes
# -i = interactive
# -v = verbose (show what's being copied)

# Examples:
cp /etc/nginx/nginx.conf ~/nginx.conf.backup    # Backup config file
cp -r /var/www/html /backup/website-$(date +%Y%m%d)  # Backup with date
```

#### mv - Move/Rename Files

```bash
# mv moves or renames files

mv oldname.txt newname.txt      # Rename file
mv file.txt /tmp/               # Move to different directory
mv file.txt /tmp/newname.txt    # Move and rename

# mv is used for both moving and renaming because
# in Linux, renaming is just moving to a new name

# Safe moving with backup:
mv -b file.txt /tmp/            # Creates backup if destination exists
mv -i file.txt /tmp/            # Asks before overwriting
```

#### rm - Remove Files

```bash
# rm deletes files and directories
# WARNING: No recycle bin! Deleted files are gone!

rm file.txt                     # Delete file
rm -r directory/                # Delete directory and contents
rm -f file.txt                  # Force delete (no confirmation)
rm -rf directory/               # Force delete directory (DANGEROUS!)
rm -i file.txt                  # Interactive (ask confirmation)

# Safety tips:
# 1. Use -i for important files
# 2. Use ls first to see what you're deleting
# 3. Consider using trash-cli instead:
sudo apt install trash-cli
trash file.txt                  # Moves to trash instead of deleting
trash-list                      # Show trashed files
trash-restore                   # Restore files
```

### Viewing File Contents

#### cat - Concatenate and Display

```bash
# cat displays entire file contents

cat file.txt                    # Display file
cat file1.txt file2.txt         # Display multiple files
cat -n file.txt                 # Show line numbers
cat -A file.txt                 # Show all characters (tabs, line endings)

# cat is best for small files
# For large files, use less or head/tail
```

#### less - Page Through Files

```bash
# less lets you scroll through files

less largefile.log

# Commands inside less:
# Space     = Next page
# b         = Previous page
# g         = Go to beginning
# G         = Go to end
# /pattern  = Search forward
# ?pattern  = Search backward
# n         = Next search result
# N         = Previous search result
# q         = Quit

# less is "more" than more (an older pager)
# Remember: "less is more" - less has more features!
```

#### head and tail - View File Parts

```bash
# head shows the beginning of a file
head file.txt                   # First 10 lines (default)
head -n 20 file.txt             # First 20 lines
head -n -5 file.txt             # All except last 5 lines

# tail shows the end of a file
tail file.txt                   # Last 10 lines
tail -n 20 file.txt            # Last 20 lines
tail -f /var/log/syslog        # Follow mode (watch for new lines)
tail -f -n 50 logfile          # Follow, starting with last 50 lines

# tail -f is incredibly useful for watching logs in real-time!
# Press Ctrl+C to stop following
```

### Text Processing Tools

#### grep - Search Text

```bash
# grep searches for patterns in files
# Name comes from: Global Regular Expression Print

grep "error" logfile.txt        # Find lines containing "error"
grep -i "error" logfile.txt     # Case-insensitive search
grep -n "error" logfile.txt     # Show line numbers
grep -r "TODO" /home/           # Recursive search in directory
grep -v "debug" logfile.txt     # Invert match (lines NOT containing)
grep -c "error" logfile.txt     # Count matching lines

# Regular expressions (patterns):
grep "^Start" file.txt          # Lines starting with "Start"
grep "end$" file.txt            # Lines ending with "end"
grep "^$" file.txt              # Empty lines
grep "[0-9]" file.txt           # Lines containing numbers

# Useful combinations:
ps aux | grep nginx              # Find nginx processes
history | grep ssh               # Find ssh commands in history
cat /etc/passwd | grep -E ":[0-9]{4}:" # Users with UID >= 1000
```

#### awk - Pattern Processing

```bash
# awk is a powerful text processing tool
# Basic usage: awk 'pattern { action }' file

# Print specific columns (fields)
awk '{print $1}' file.txt       # First column
awk '{print $1, $3}' file.txt   # First and third columns
awk '{print NF}' file.txt       # Number of fields per line
awk '{print NR, $0}' file.txt   # Line number and full line

# Common examples:
# Get usernames from /etc/passwd
awk -F: '{print $1}' /etc/passwd

# Sum numbers in a column
awk '{sum += $1} END {print sum}' numbers.txt

# Print lines longer than 80 characters
awk 'length > 80' file.txt
```

#### sed - Stream Editor

```bash
# sed performs text transformations

# Basic substitution
sed 's/old/new/' file.txt       # Replace first occurrence per line
sed 's/old/new/g' file.txt      # Replace all occurrences
sed 's/old/new/gi' file.txt     # Case-insensitive replacement

# Edit file in-place
sed -i 's/old/new/g' file.txt   # Modifies the actual file
sed -i.bak 's/old/new/g' file.txt # Creates backup first

# Delete lines
sed '/pattern/d' file.txt       # Delete lines matching pattern
sed '5d' file.txt               # Delete line 5
sed '5,10d' file.txt           # Delete lines 5-10

# Practical examples:
# Remove comments from config file
sed '/^#/d' config.txt          # Delete lines starting with #

# Change configuration value
sed -i 's/Port 22/Port 2222/' /etc/ssh/sshd_config
```

### File Permissions Deep Dive

Linux permissions control who can read, write, or execute files. This is fundamental to Linux security.

#### Understanding Permission Notation

```bash
ls -l file.txt
# -rw-r--r-- 1 ubuntu ubuntu 1234 Jan 15 10:30 file.txt

# Breaking down: -rw-r--r--
# Position 1: File type
#   - = regular file
#   d = directory
#   l = symbolic link
#   c = character device
#   b = block device

# Positions 2-4: Owner permissions (u = user)
#   r = read (4)
#   w = write (2)
#   x = execute (1)

# Positions 5-7: Group permissions (g = group)
# Positions 8-10: Others permissions (o = others)

# Numeric notation:
# rwx = 4+2+1 = 7
# rw- = 4+2+0 = 6
# r-- = 4+0+0 = 4

# Common permissions:
# 755 = rwxr-xr-x (programs, directories)
# 644 = rw-r--r-- (regular files)
# 600 = rw------- (private files)
# 777 = rwxrwxrwx (avoid! too permissive)
```

#### chmod - Change Permissions

```bash
# chmod changes file permissions

# Symbolic method:
chmod u+x script.sh              # Add execute for owner
chmod g-w file.txt               # Remove write for group
chmod o=r file.txt               # Set others to read only
chmod a+r file.txt               # Add read for all (a = all)
chmod u=rwx,g=rx,o=r file.txt   # Set specific permissions

# Numeric method:
chmod 755 script.sh              # rwxr-xr-x
chmod 644 file.txt               # rw-r--r--
chmod 600 private.key            # rw-------

# Recursive:
chmod -R 755 /var/www/html/      # Apply to all files/subdirectories

# Special permissions:
chmod u+s program                # SUID - run as owner
chmod g+s directory              # SGID - inherit group
chmod +t /tmp                    # Sticky bit - only owner can delete
```

#### chown - Change Ownership

```bash
# chown changes file owner and group

chown john file.txt              # Change owner to john
chown john:developers file.txt   # Change owner and group
chown :developers file.txt       # Change only group
chown -R john:john /home/john    # Recursive ownership change

# Why ownership matters:
# - Only owner can change permissions
# - Processes run as specific users
# - Security depends on correct ownership
```

### Process Management

A **process** is a running program. Linux can run thousands of processes simultaneously.

#### ps - Process Status

```bash
# ps shows running processes

ps                               # Your processes
ps aux                          # All processes (detailed)
ps aux | grep nginx             # Find specific process

# Understanding ps aux output:
# USER  PID %CPU %MEM    VSZ   RSS TTY  STAT START   TIME COMMAND
# root    1  0.0  0.4 225768  8952 ?    Ss   Jan01   1:23 /sbin/init

# USER = Who's running it
# PID = Process ID (unique number)
# %CPU = CPU usage
# %MEM = Memory usage
# STAT = Status (R=running, S=sleeping, Z=zombie)
# COMMAND = What's running
```

#### top and htop - Interactive Process Viewers

```bash
# top shows processes in real-time
top

# Inside top:
# q = quit
# k = kill process
# r = renice (change priority)
# M = sort by memory
# P = sort by CPU

# htop is more user-friendly (install first)
sudo apt install htop
htop

# htop features:
# - Color coded
# - Mouse support
# - Tree view (F5)
# - Search (F3)
# - Filter (F4)
# - Kill with F9
```

#### Managing Processes

```bash
# Start process in background
command &
sleep 100 &                     # Example background job

# List background jobs
jobs
# [1]+  Running   sleep 100 &

# Bring to foreground
fg %1                           # Bring job 1 to foreground

# Send to background
# First: Ctrl+Z to suspend
# Then:
bg %1                           # Resume in background

# Kill processes
kill PID                        # Graceful termination
kill -9 PID                     # Force kill
killall process_name            # Kill by name

# Process priority (nice value)
# -20 (highest) to 19 (lowest), default is 0
nice -n 10 command              # Start with lower priority
renice -n 5 -p PID              # Change running process priority
```

### Shell Scripting Fundamentals

Shell scripts automate repetitive tasks. They're text files containing commands that run sequentially.

#### Creating Your First Script

```bash
# Create script file
nano myscript.sh

# Add this content:
#!/bin/bash
# The line above is called "shebang" - tells system to use bash

# This is a comment - it's ignored by the computer
echo "Hello, World!"             # echo prints text
echo "Today is $(date)"         # $() runs command and inserts output
echo "You are $(whoami)"        # whoami shows current user

# Variables
NAME="Ubuntu Server"            # No spaces around =
echo "Welcome to $NAME"         # $ accesses variable value

# Save and exit nano (Ctrl+O, Ctrl+X)

# Make it executable
chmod +x myscript.sh

# Run it
./myscript.sh                   # ./ means "in current directory"
```

#### Script Basics

```bash
#!/bin/bash

# Variables
VARIABLE="value"                # Set variable
echo $VARIABLE                  # Use variable
echo "$VARIABLE"                # Safer - handles spaces
echo "${VARIABLE}_suffix"       # Clear variable boundaries

# User input
read -p "Enter your name: " USERNAME
echo "Hello, $USERNAME!"

# Conditionals
if [ -f /etc/nginx/nginx.conf ]; then
    echo "Nginx is installed"
else
    echo "Nginx is not installed"
fi

# Loops
for i in 1 2 3 4 5; do
    echo "Number: $i"
done

# Functions
greet() {
    echo "Hello, $1!"          # $1 is first argument
}

greet "Ubuntu"                  # Call function

# Exit codes
# 0 = success, non-zero = error
exit 0                          # Successful completion
```

### Practical Exercises

#### Exercise 1: System Information Script

```bash
#!/bin/bash
# sysinfo.sh - Display system information

echo "=== System Information ==="
echo "Hostname: $(hostname)"
echo "OS: $(lsb_release -d | cut -f2)"
echo "Kernel: $(uname -r)"
echo "Uptime: $(uptime -p)"
echo "Memory: $(free -h | grep Mem | awk '{print $3 " / " $2}')"
echo "Disk Usage:"
df -h | grep -E '^/dev/' | awk '{print "  " $6 ": " $5 " used"}'
echo "Top 5 CPU processes:"
ps aux --sort=-%cpu | head -6 | tail -5 | awk '{print "  " $11 " (" $3 "%)"}'
```

#### Exercise 2: Backup Script

```bash
#!/bin/bash
# backup.sh - Simple backup script

# Configuration
SOURCE_DIR="/home/ubuntu/important"
BACKUP_DIR="/backup"
DATE=$(date +%Y%m%d_%H%M%S)
BACKUP_NAME="backup_$DATE.tar.gz"

# Create backup directory if it doesn't exist
mkdir -p "$BACKUP_DIR"

# Create backup
echo "Creating backup..."
tar -czf "$BACKUP_DIR/$BACKUP_NAME" "$SOURCE_DIR"

# Check if successful
if [ $? -eq 0 ]; then
    echo "Backup created: $BACKUP_DIR/$BACKUP_NAME"

    # Delete backups older than 7 days
    find "$BACKUP_DIR" -name "backup_*.tar.gz" -mtime +7 -delete
    echo "Old backups cleaned up"
else
    echo "Backup failed!" >&2
    exit 1
fi
```

### Key Command Line Tips

#### Command Chaining

```bash
# && - Run second command only if first succeeds
sudo apt update && sudo apt upgrade

# || - Run second command only if first fails
ping -c 1 google.com || echo "Internet is down"

# ; - Run commands sequentially (regardless of success)
cd /tmp ; ls ; pwd

# | - Pipe output from one command to another
ps aux | grep nginx | wc -l    # Count nginx processes
```

#### Input/Output Redirection

```bash
# > - Redirect output to file (overwrites)
echo "Hello" > file.txt

# >> - Append to file
echo "World" >> file.txt

# < - Read input from file
mysql database < backup.sql

# 2> - Redirect errors
command 2> errors.log

# &> - Redirect both output and errors
command &> combined.log

# 2>&1 - Redirect errors to same place as output
command > output.log 2>&1

# tee - Output to both screen and file
command | tee output.log
command | tee -a output.log    # Append mode
```

### Learning Resources

- **Linux Command Challenge**: https://cmdchallenge.com/
- **Explain Shell** (breaks down commands): https://explainshell.com/
- **Bash Guide**: https://mywiki.wooledge.org/BashGuide
- **Regular Expressions**: https://regex101.com/
- **Shell Scripting Tutorial**: https://www.shellscript.sh/

### Practice Makes Perfect

The command line becomes intuitive with practice. Start with:

1. **Daily Tasks**: Use terminal for file management
2. **Automate One Thing**: Write a simple backup script
3. **Learn Keyboard Shortcuts**: Much faster than typing
4. **Read Man Pages**: `man command` shows documentation
5. **Keep a Cheat Sheet**: Write down useful commands

Remember: Everyone was a beginner once. The terminal seems complex at first, but it becomes second nature with practice. Each command you learn is a tool in your toolbox - the more tools you have, the more problems you can solve efficiently.