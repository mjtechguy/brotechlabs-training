# Part 4: Networking and Security

## Chapter 9: Network Configuration

### Understanding Linux Networking

#### The Network Stack

Think of your Rocky Linux server's network like a postal system:
- **IP Address** = Your street address (where mail gets delivered)
- **Subnet Mask** = Your neighborhood boundaries
- **Gateway** = The post office (routes mail to other neighborhoods)
- **DNS** = The phone book (converts names to addresses)
- **Ports** = Apartment numbers (which app gets the data)
- **Firewall** = Security guard (checks who can enter)

```bash
# See your network configuration at a glance:
ip a
# 1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN
#     inet 127.0.0.1/8 scope host lo
#        This is the loopback interface (talking to yourself)
#
# 2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel state UP
#     inet 192.168.1.100/24 brd 192.168.1.255 scope global dynamic eth0
#          ↑ Your IP       ↑ Network size    ↑ Broadcast address
#
# The /24 means first 24 bits are network (192.168.1.x)
# Last 8 bits are for hosts (x.x.x.0-255)

# Older command (still works but ip is preferred):
ifconfig
```

### NetworkManager - The Modern Way

#### Understanding NetworkManager

NetworkManager is Rocky Linux's network configuration service. It's like having an intelligent assistant that:
- Automatically configures network connections
- Remembers WiFi passwords
- Switches between networks smoothly
- Handles complex network setups easily

```bash
# Check if NetworkManager is running:
systemctl status NetworkManager
# ● NetworkManager.service - Network Manager
#    Loaded: loaded (/usr/lib/systemd/system/NetworkManager.service; enabled)
#    Active: active (running) since Mon 2023-12-11 08:00:00 EST

# NetworkManager has multiple interfaces:
# 1. nmcli - Command line (what we'll use)
# 2. nmtui - Text user interface (menu-driven)
# 3. GUI - Graphical interface (if desktop installed)

# See NetworkManager's view of your connections:
nmcli device status
# DEVICE  TYPE      STATE      CONNECTION
# eth0    ethernet  connected  Wired connection 1
# lo      loopback  unmanaged  --

nmcli connection show
# NAME                UUID                                  TYPE      DEVICE
# Wired connection 1  12345678-1234-1234-1234-123456789abc  ethernet  eth0
```

#### Configuring Networks with nmcli

```bash
# The nmcli command structure:
# nmcli [object] [action] [parameters]

# Objects: connection, device, general, networking, radio
# Actions: show, add, modify, delete, up, down

# Show detailed connection info:
nmcli connection show "Wired connection 1"
# connection.id:                 Wired connection 1
# connection.uuid:               12345678-1234-1234-1234-123456789abc
# connection.type:               802-3-ethernet
# connection.autoconnect:        yes
# ipv4.method:                   auto  <- DHCP
# ipv4.addresses:                192.168.1.100/24
# ipv4.gateway:                  192.168.1.1
# ipv4.dns:                      8.8.8.8,8.8.4.4
# ...

# Create a new static IP connection:
sudo nmcli connection add \
  con-name "Static-LAN" \
  type ethernet \
  ifname eth0 \
  ipv4.method manual \
  ipv4.addresses 192.168.1.50/24 \
  ipv4.gateway 192.168.1.1 \
  ipv4.dns "8.8.8.8,8.8.4.4"

# Let's break this down:
# con-name = Connection name (for humans)
# type = Connection type (ethernet, wifi, bridge, bond, etc.)
# ifname = Interface name (eth0, ens33, etc.)
# ipv4.method = manual (static) or auto (DHCP)
# ipv4.addresses = IP address with subnet mask in CIDR notation
# ipv4.gateway = Default gateway (router)
# ipv4.dns = DNS servers (comma-separated)

# Activate the new connection:
sudo nmcli connection up "Static-LAN"

# Modify existing connection:
sudo nmcli connection modify "Wired connection 1" \
  ipv4.dns "1.1.1.1,1.0.0.1"  # Change to Cloudflare DNS

# Apply changes (reload connection):
sudo nmcli connection down "Wired connection 1"
sudo nmcli connection up "Wired connection 1"

# Delete a connection:
sudo nmcli connection delete "Old-Connection"
```

#### Network Configuration Files

```bash
# NetworkManager stores configurations in:
ls -la /etc/NetworkManager/system-connections/
# Each connection has its own file

# Legacy network scripts (older Rocky/RHEL way):
ls -la /etc/sysconfig/network-scripts/
# ifcfg-eth0  <- Old-style config file

# Example old-style config:
cat /etc/sysconfig/network-scripts/ifcfg-eth0
# TYPE=Ethernet
# BOOTPROTO=none        # none = static, dhcp = DHCP
# NAME="eth0"
# DEVICE=eth0
# ONBOOT=yes           # Start at boot
# IPADDR=192.168.1.50
# NETMASK=255.255.255.0
# GATEWAY=192.168.1.1
# DNS1=8.8.8.8
# DNS2=8.8.4.4

# NetworkManager can read both formats!
# But nmcli is the modern, preferred method
```

### DNS Configuration

#### Understanding DNS Resolution

```bash
# How Rocky Linux resolves names to IP addresses:

# Step 1: Check /etc/hosts file
cat /etc/hosts
# 127.0.0.1   localhost localhost.localdomain
# ::1         localhost localhost.localdomain
# 192.168.1.10 myserver.local myserver  <- Custom entries

# Step 2: Check DNS servers in /etc/resolv.conf
cat /etc/resolv.conf
# Generated by NetworkManager
# nameserver 8.8.8.8
# nameserver 8.8.4.4
# search local.domain

# Test DNS resolution:
# Method 1: nslookup (simple)
nslookup google.com
# Server:     8.8.8.8
# Address:    8.8.8.8#53
#
# Non-authoritative answer:
# Name:   google.com
# Address: 142.250.80.46

# Method 2: dig (detailed)
dig google.com
# ; <<>> DiG 9.16.23 <<>> google.com
# ;; QUESTION SECTION:
# ;google.com.                    IN      A
#
# ;; ANSWER SECTION:
# google.com.             300     IN      A       142.250.80.46

# Method 3: host (quick)
host google.com
# google.com has address 142.250.80.46
# google.com has IPv6 address 2607:f8b0:4004:c07::71

# Method 4: getent (uses system resolver)
getent hosts google.com
# 142.250.80.46 google.com

# Trace DNS resolution path:
dig +trace google.com
# Shows the full DNS hierarchy from root servers down

# Clear DNS cache (if using systemd-resolved):
sudo systemd-resolve --flush-caches

# Or restart nscd (Name Service Cache Daemon):
sudo systemctl restart nscd
```

#### Configuring DNS

```bash
# Method 1: Via NetworkManager (recommended)
sudo nmcli connection modify "Wired connection 1" \
  ipv4.dns "1.1.1.1,8.8.8.8" \
  ipv4.dns-search "example.com,local.domain"

sudo nmcli connection reload
sudo nmcli connection up "Wired connection 1"

# Method 2: Edit resolv.conf directly (temporary - NetworkManager overwrites!)
sudo nano /etc/resolv.conf
# Add:
# nameserver 1.1.1.1
# nameserver 8.8.8.8
# search example.com local.domain

# Method 3: Prevent NetworkManager from managing resolv.conf
sudo nano /etc/NetworkManager/NetworkManager.conf
# Add under [main]:
# dns=none

# Then manually manage /etc/resolv.conf

# Method 4: Use systemd-resolved (modern alternative)
sudo systemctl enable --now systemd-resolved
sudo ln -sf /run/systemd/resolve/stub-resolv.conf /etc/resolv.conf

# Configure systemd-resolved:
sudo nano /etc/systemd/resolved.conf
# [Resolve]
# DNS=1.1.1.1 8.8.8.8
# FallbackDNS=9.9.9.9
# Domains=example.com
```

### Network Troubleshooting

#### Essential Troubleshooting Tools

```bash
# The troubleshooting toolkit:

# 1. PING - Is the host alive?
ping -c 4 google.com
# PING google.com (142.250.80.46) 56(84) bytes of data.
# 64 bytes from 142.250.80.46: icmp_seq=1 ttl=117 time=15.2 ms
# 64 bytes from 142.250.80.46: icmp_seq=2 ttl=117 time=14.8 ms
# ...
# --- google.com ping statistics ---
# 4 packets transmitted, 4 received, 0% packet loss, time 3004ms
# rtt min/avg/max/mdev = 14.823/15.095/15.456/0.236 ms

# What the output means:
# - 0% packet loss = Good connection
# - time=15.2 ms = Response time (lower is better)
# - ttl=117 = Time To Live (hops remaining)

# If ping fails, try:
ping -c 4 8.8.8.8  # Ping by IP to test if DNS is the issue

# 2. TRACEROUTE - What's the path to the host?
traceroute google.com
# traceroute to google.com (142.250.80.46), 30 hops max, 60 byte packets
#  1  gateway (192.168.1.1)  0.543 ms  0.623 ms  0.702 ms
#  2  10.0.0.1 (10.0.0.1)  10.234 ms  10.456 ms  10.643 ms
#  3  * * *  <- Firewall blocking ICMP
#  4  72.14.234.56 (72.14.234.56)  15.234 ms  15.345 ms  15.567 ms
# ...

# 3. NETSTAT / SS - What's listening and connected?
# netstat is older, ss is modern and faster

ss -tunlp
# -t = TCP
# -u = UDP
# -n = Don't resolve names (faster)
# -l = Listening ports
# -p = Show process (needs sudo)

sudo ss -tunlp
# Netid State  Recv-Q Send-Q  Local Address:Port   Peer Address:Port  Process
# tcp   LISTEN 0      128     0.0.0.0:22           0.0.0.0:*          users:(("sshd",pid=1234))
# tcp   LISTEN 0      100     127.0.0.1:25         0.0.0.0:*          users:(("master",pid=2345))
# tcp   LISTEN 0      128     [::]:22              [::]:*             users:(("sshd",pid=1234))

# See established connections:
ss -tun
# State    Recv-Q Send-Q  Local Address:Port    Peer Address:Port
# ESTAB    0      0       192.168.1.100:22      192.168.1.10:54234

# 4. TCPDUMP - Packet capture (like Wireshark for terminal)
sudo tcpdump -i eth0 -n port 80
# tcpdump: listening on eth0, link-type EN10MB
# 10:15:30.123456 IP 192.168.1.100.54234 > 93.184.216.34.80: Flags [S], seq 12345
# 10:15:30.234567 IP 93.184.216.34.80 > 192.168.1.100.54234: Flags [S.], seq 67890

# Capture to file for analysis:
sudo tcpdump -i eth0 -w capture.pcap
# Later analyze with: tcpdump -r capture.pcap

# 5. NMAP - Port scanning (install first)
sudo dnf install -y nmap

# Scan common ports on a host:
nmap 192.168.1.1
# PORT     STATE SERVICE
# 22/tcp   open  ssh
# 80/tcp   open  http
# 443/tcp  open  https

# Scan specific ports:
nmap -p 22,80,443 192.168.1.1

# Scan entire subnet:
nmap -sn 192.168.1.0/24  # Ping scan only
```

#### Common Network Problems and Solutions

```bash
# PROBLEM 1: Can't reach the internet
# Diagnostic steps:

# Step 1: Can you ping your gateway?
ip route | grep default
# default via 192.168.1.1 dev eth0
ping -c 2 192.168.1.1

# Step 2: Can you ping external IP?
ping -c 2 8.8.8.8

# Step 3: Can you resolve DNS?
nslookup google.com

# If Step 1 fails: Local network issue
# If Step 2 fails: Gateway/routing issue
# If Step 3 fails: DNS issue

# PROBLEM 2: Service not accessible
# Step 1: Is service running?
sudo systemctl status httpd

# Step 2: Is it listening?
sudo ss -tlnp | grep :80

# Step 3: Is firewall blocking?
sudo firewall-cmd --list-all

# Step 4: Is SELinux blocking?
sudo ausearch -m AVC -ts recent

# PROBLEM 3: Slow network
# Check for packet loss:
ping -c 100 google.com
# Look for packet loss percentage

# Check interface statistics:
ip -s link show eth0
# Look for errors, dropped packets

# Check bandwidth usage:
sudo dnf install -y iftop
sudo iftop -i eth0

# PROBLEM 4: IP conflict
# Check ARP table:
ip neigh
# 192.168.1.1 dev eth0 lladdr 00:11:22:33:44:55 REACHABLE
# If you see FAILED, might be IP conflict

# Use arping to detect conflicts:
sudo dnf install -y iputils
sudo arping -D -I eth0 192.168.1.100
# If you get replies, someone else has this IP!
```

---

## Chapter 10: Security Hardening

### Rocky Linux Security Baseline

#### Understanding Security Layers

Security in Rocky Linux is like a medieval castle:
- **Firewall** = Outer walls (blocks unwanted traffic)
- **SELinux** = Guards at every door (controls what programs can do)
- **File Permissions** = Locks on rooms (controls file access)
- **Audit System** = Security cameras (logs everything)
- **Updates** = Repairs and reinforcements (patches vulnerabilities)

```bash
# Quick security check:
# 1. Is firewall active?
sudo firewall-cmd --state
# running

# 2. Is SELinux enforcing?
getenforce
# Enforcing

# 3. Are updates installed?
sudo dnf check-update
# (empty output means up-to-date)

# 4. Is auditd running?
systemctl status auditd
# ● auditd.service - Security Auditing Service
#    Active: active (running)

# 5. Check for weak passwords:
sudo grep "PASS_MIN_LEN" /etc/login.defs
# PASS_MIN_LEN   12

# 6. Check SSH configuration:
sudo sshd -T | grep -E "permitrootlogin|passwordauthentication"
# permitrootlogin no
# passwordauthentication yes
```

### Firewalld - Your First Line of Defense

#### Understanding Firewalld Concepts

Firewalld uses **zones** - think of them as different security levels for different network locations:
- **trusted** = Your home (everything allowed)
- **home** = Home network (mostly trusted)
- **internal** = Office network (somewhat trusted)
- **work** = Work network (limited trust)
- **public** = Coffee shop WiFi (don't trust anyone!)
- **external** = Internet-facing (very restricted)
- **dmz** = DMZ servers (isolated)
- **block** = Block everything
- **drop** = Silently drop everything

```bash
# See current zone:
sudo firewall-cmd --get-default-zone
# public

# See what zones are active:
sudo firewall-cmd --get-active-zones
# public
#   interfaces: eth0

# See what's allowed in current zone:
sudo firewall-cmd --list-all
# public (active)
#   target: default
#   icmp-block-inversion: no
#   interfaces: eth0
#   sources:
#   services: cockpit dhcpv6-client ssh
#   ports:
#   protocols:
#   forward: no
#   masquerade: no
#   forward-ports:
#   source-ports:
#   icmp-blocks:
#   rich rules:

# What do these services mean?
# ssh = SSH access (port 22)
# cockpit = Web console (port 9090)
# dhcpv6-client = IPv6 DHCP

# See all available zones:
sudo firewall-cmd --get-zones
# block dmz drop external home internal public trusted work

# See zone details:
sudo firewall-cmd --zone=public --list-all
sudo firewall-cmd --zone=home --list-all
```

#### Managing Firewall Rules

```bash
# SERVICES - Pre-defined rule sets

# See available services:
sudo firewall-cmd --get-services
# RH-Satellite-6 amanda-client apache bacula ssh telnet tftp ...

# Add a service (temporary):
sudo firewall-cmd --add-service=http
# success

# Add a service (permanent):
sudo firewall-cmd --permanent --add-service=http
sudo firewall-cmd --reload  # Apply permanent changes

# Remove a service:
sudo firewall-cmd --permanent --remove-service=telnet
sudo firewall-cmd --reload

# PORTS - When no service definition exists

# Open a specific port:
sudo firewall-cmd --permanent --add-port=8080/tcp
sudo firewall-cmd --permanent --add-port=161/udp
sudo firewall-cmd --reload

# Open a port range:
sudo firewall-cmd --permanent --add-port=5000-5010/tcp
sudo firewall-cmd --reload

# Remove a port:
sudo firewall-cmd --permanent --remove-port=8080/tcp
sudo firewall-cmd --reload

# RICH RULES - Complex rules with conditions

# Allow specific IP:
sudo firewall-cmd --permanent --add-rich-rule='
  rule family="ipv4"
  source address="192.168.1.100"
  port port="3306" protocol="tcp"
  accept'

# Rate limiting:
sudo firewall-cmd --permanent --add-rich-rule='
  rule family="ipv4"
  source address="0.0.0.0/0"
  service name="ssh"
  log prefix="SSH-Attempt" level="info"
  limit value="4/m"
  accept'

# Block specific IP:
sudo firewall-cmd --permanent --add-rich-rule='
  rule family="ipv4"
  source address="10.0.0.50"
  drop'

# Log and drop:
sudo firewall-cmd --permanent --add-rich-rule='
  rule family="ipv4"
  source address="192.168.1.0/24"
  port port="23" protocol="tcp"
  log prefix="TELNET-ATTEMPT" level="warning"
  drop'

sudo firewall-cmd --reload
```

#### Zone Management

```bash
# Change interface zone:
sudo firewall-cmd --zone=internal --change-interface=eth0
# Making it permanent:
sudo firewall-cmd --permanent --zone=internal --change-interface=eth0

# Create custom zone:
sudo firewall-cmd --permanent --new-zone=webservers
sudo firewall-cmd --reload

# Configure custom zone:
sudo firewall-cmd --permanent --zone=webservers --add-service=http
sudo firewall-cmd --permanent --zone=webservers --add-service=https
sudo firewall-cmd --permanent --zone=webservers --add-port=8080/tcp
sudo firewall-cmd --reload

# Set default zone:
sudo firewall-cmd --set-default-zone=internal

# Panic mode (block everything):
sudo firewall-cmd --panic-on
# WARNING: This blocks ALL network traffic!
sudo firewall-cmd --panic-off

# Direct rules (iptables-style):
sudo firewall-cmd --direct --add-rule ipv4 filter INPUT 0 \
  -s 192.168.1.0/24 -j ACCEPT
```

### System Auditing with auditd

#### Understanding the Audit System

The audit system is like a security camera that records:
- Who logged in and when
- What files were accessed
- What commands were run
- System calls and security events

```bash
# Check audit service:
systemctl status auditd
# ● auditd.service - Security Auditing Service
#    Active: active (running)

# View audit configuration:
sudo cat /etc/audit/auditd.conf
# log_file = /var/log/audit/audit.log
# max_log_file = 8         # Max size in MB
# num_logs = 5             # Number of logs to keep
# space_left = 75          # MB left warning
# space_left_action = SYSLOG
# disk_full_action = SUSPEND

# See current audit rules:
sudo auditctl -l
# -w /etc/passwd -p wa -k passwd_changes
# -w /etc/shadow -p wa -k shadow_changes
# -a always,exit -F arch=b64 -S execve -F uid=0 -k root_commands
```

#### Creating Audit Rules

```bash
# Watch file access:
# -w = watch
# -p = permissions (r=read, w=write, x=execute, a=attribute)
# -k = key (for searching)

# Monitor password file changes:
sudo auditctl -w /etc/passwd -p wa -k passwd_changes

# Monitor SSH configuration:
sudo auditctl -w /etc/ssh/sshd_config -p wa -k sshd_config

# Monitor all commands by specific user:
sudo auditctl -a always,exit -F arch=b64 -S execve -F uid=1000 -k user_commands

# Monitor failed login attempts:
sudo auditctl -w /var/log/btmp -p wa -k failed_logins

# Make rules permanent:
sudo nano /etc/audit/rules.d/custom.rules
# Add your rules:
-w /etc/passwd -p wa -k passwd_changes
-w /etc/shadow -p wa -k shadow_changes
-w /etc/group -p wa -k group_changes
-w /etc/sudoers -p wa -k sudoers_changes
-w /etc/ssh/sshd_config -p wa -k sshd_config
-w /var/log/btmp -p wa -k failed_logins

# Reload rules:
sudo augenrules --load
```

#### Searching Audit Logs

```bash
# Search audit logs with ausearch:

# Find all password file changes:
sudo ausearch -k passwd_changes
# time->Mon Dec 11 10:15:30 2023
# type=CONFIG_CHANGE msg=audit(1702303030.123:456): auid=1000 uid=0 ...
# type=PATH msg=audit(1702303030.123:456): item=0 name="/etc/passwd" ...

# Find events by user:
sudo ausearch -ua john  # By account name
sudo ausearch -ui 1000  # By UID

# Find events by time:
sudo ausearch -ts today
sudo ausearch -ts 10:00 -te 11:00
sudo ausearch -ts 12/10/2023 -te 12/11/2023

# Find failed operations:
sudo ausearch -sv no  # Success = no

# Find by message type:
sudo ausearch -m LOGIN
sudo ausearch -m USER_CMD  # sudo commands

# Generate reports with aureport:
sudo aureport
# Summary Report
# ======================
# Range of time: 12/01/2023 00:00:01 - 12/11/2023 15:30:45
# Number of changes in configuration: 15
# Number of changes to accounts, groups, or roles: 23
# Number of logins: 145
# Number of failed logins: 12
# ...

# Specific reports:
sudo aureport -l   # Login report
sudo aureport -u   # User report
sudo aureport -f   # File report
sudo aureport -x   # Executable report
sudo aureport --failed  # Failed events
```

### File Integrity Monitoring with AIDE

#### Setting Up AIDE

AIDE (Advanced Intrusion Detection Environment) monitors files for unauthorized changes - like a guard checking if anything moved.

```bash
# Install AIDE:
sudo dnf install -y aide

# Initialize AIDE database:
sudo aide --init
# Running aide --init...
# Start timestamp: 2023-12-11 10:00:00
# AIDE initialized database at /var/lib/aide/aide.db.new.gz

# Move the new database to production:
sudo mv /var/lib/aide/aide.db.new.gz /var/lib/aide/aide.db.gz

# Check configuration:
sudo cat /etc/aide.conf
# database_in=file:/var/lib/aide/aide.db.gz
# database_out=file:/var/lib/aide/aide.db.new.gz
#
# # What to check:
# # p=permissions, u=user, g=group, s=size, m=mtime
# # a=atime, c=ctime, S=check for growing size
# # md5/sha256=checksums, l=link, i=inode
#
# NORMAL = p+i+u+g+s+m+c+md5+sha256
# DIR = p+i+u+g
# LOG = p+u+g+i+S
#
# # What to monitor:
# /boot   NORMAL
# /bin    NORMAL
# /sbin   NORMAL
# /usr/bin NORMAL
# /usr/sbin NORMAL
# /etc    NORMAL
# !/etc/mtab
# /var/log LOG
```

#### Running AIDE Checks

```bash
# Run a check:
sudo aide --check
# Start timestamp: 2023-12-11 15:00:00
# AIDE found differences between database and filesystem!
#
# Summary:
#   Total number of entries:      45231
#   Added entries:                3
#   Removed entries:              1
#   Changed entries:              7
#
# Added entries:
# f+++++++++++++: /etc/new-config-file
#
# Changed entries:
# f   p.g.......: /etc/passwd
# f   ...mc.....: /etc/shadow

# Update database after legitimate changes:
sudo aide --update
sudo mv /var/lib/aide/aide.db.new.gz /var/lib/aide/aide.db.gz

# Automate daily checks:
sudo crontab -e
# Add:
0 3 * * * /usr/sbin/aide --check | mail -s "AIDE Report $(hostname)" admin@example.com
```

### Security Updates and Patch Management

#### Managing Updates with DNF

```bash
# Check for security updates:
sudo dnf check-update --security
# Rocky Linux 8.9 Security Update
# kernel.x86_64                    4.18.0-513.9.1.el8_9
# openssl.x86_64                   1:1.1.1k-10.el8_9
# ...

# Install only security updates:
sudo dnf update --security

# See update history:
sudo dnf history
# ID     | Command line              | Date and time    | Action(s)      | Altered
# -------+---------------------------+------------------+----------------+---------
#     15 | update --security         | 2023-12-11 10:00 | Update         |    5
#     14 | install nginx             | 2023-12-10 15:00 | Install        |    2

# See what changed in a transaction:
sudo dnf history info 15

# Configure automatic updates:
sudo dnf install -y dnf-automatic

# Configure update policy:
sudo nano /etc/dnf/automatic.conf
# [commands]
# upgrade_type = security     # Only security updates
# random_sleep = 300          # Random delay (seconds)
# download_updates = yes
# apply_updates = yes         # Automatically apply
#
# [emitters]
# emit_via = email           # Send notifications
#
# [email]
# email_from = root@localhost
# email_to = admin@example.com

# Enable automatic updates:
sudo systemctl enable --now dnf-automatic.timer

# Check timer:
systemctl list-timers dnf-automatic
```

---

## Chapter 11: SSL/TLS and Certificates

### Understanding Certificates

#### Certificate Concepts

Think of SSL/TLS certificates like a driver's license:
- **Certificate** = The license itself (proves identity)
- **Private Key** = Your signature (only you have it)
- **Public Key** = Your photo (everyone can see it)
- **Certificate Authority (CA)** = The DMV (trusted issuer)
- **Certificate Chain** = Chain of trust (DMV → State → Federal)

```bash
# Generate a private key (your secret):
openssl genrsa -out private.key 2048
# Generating RSA private key, 2048 bit long modulus
# ..........+++
# ..........+++

# See what's in the key:
openssl rsa -in private.key -text -noout | head -20
# RSA Private-Key: (2048 bit, 2 primes)
# modulus:
#     00:c3:45:67:89:ab:cd:ef...
# publicExponent: 65537 (0x10001)
# privateExponent:
#     00:a1:b2:c3:d4:e5:f6...

# Create a certificate signing request (CSR):
openssl req -new -key private.key -out request.csr
# Country Name (2 letter code) [XX]:US
# State or Province Name (full name) []:Colorado
# Locality Name (eg, city) [Default City]:Denver
# Organization Name (eg, company) []:Example Corp
# Organizational Unit Name (eg, section) []:IT
# Common Name (eg, your name or server's hostname) []:www.example.com
# Email Address []:admin@example.com

# View the CSR:
openssl req -in request.csr -text -noout
# Certificate Request:
#     Data:
#         Version: 1 (0x0)
#         Subject: C=US, ST=Colorado, L=Denver, O=Example Corp, OU=IT, CN=www.example.com
#         Subject Public Key Info:
#             Public Key Algorithm: rsaEncryption
#                 RSA Public-Key: (2048 bit)
```

### Self-Signed Certificates

#### Creating Self-Signed Certificates

```bash
# Quick method - One command for everything:
openssl req -x509 \
  -newkey rsa:2048 \
  -keyout server.key \
  -out server.crt \
  -days 365 \
  -nodes \
  -subj "/C=US/ST=State/L=City/O=Company/CN=server.local"

# Let's break this down:
# -x509 = Create a certificate, not a CSR
# -newkey rsa:2048 = Create new 2048-bit RSA key
# -keyout = Where to save private key
# -out = Where to save certificate
# -days = How long certificate is valid
# -nodes = No DES (don't encrypt the key)
# -subj = Subject info (skip interactive prompts)

# Detailed method - More control:

# Step 1: Generate private key
openssl genrsa -out server.key 2048

# Step 2: Create certificate
openssl req -new -x509 \
  -key server.key \
  -out server.crt \
  -days 3650 \
  -subj "/C=US/ST=State/L=City/O=Company/CN=*.example.local"

# Step 3: Verify certificate
openssl x509 -in server.crt -text -noout
# Certificate:
#     Data:
#         Version: 3 (0x2)
#         Serial Number: ...
#         Signature Algorithm: sha256WithRSAEncryption
#         Issuer: C=US, ST=State, L=City, O=Company, CN=*.example.local
#         Validity
#             Not Before: Dec 11 10:00:00 2023 GMT
#             Not After : Dec  8 10:00:00 2033 GMT
#         Subject: C=US, ST=State, L=City, O=Company, CN=*.example.local

# Create certificate with multiple domains (SAN):
cat > san.conf << EOF
[req]
distinguished_name = req_distinguished_name
req_extensions = v3_req

[req_distinguished_name]
countryName = US
stateOrProvinceName = State
localityName = City
organizationName = Company
commonName = server.local

[v3_req]
subjectAltName = @alt_names

[alt_names]
DNS.1 = server.local
DNS.2 = *.server.local
DNS.3 = localhost
IP.1 = 192.168.1.100
IP.2 = 127.0.0.1
EOF

openssl req -new -x509 \
  -key server.key \
  -out server-san.crt \
  -days 365 \
  -config san.conf \
  -extensions v3_req
```

### Let's Encrypt on Rocky Linux

#### Setting Up Let's Encrypt

```bash
# Let's Encrypt gives you FREE trusted certificates!
# Requirements:
# - Domain name you control
# - Server accessible from internet on port 80/443

# Install certbot and plugin:
sudo dnf install -y epel-release
sudo dnf install -y certbot

# For Apache:
sudo dnf install -y python3-certbot-apache

# For Nginx:
sudo dnf install -y python3-certbot-nginx

# Method 1: Apache integration
sudo certbot --apache -d example.com -d www.example.com
# Saving debug log to /var/log/letsencrypt/letsencrypt.log
# Enter email address: admin@example.com
# Agree to terms: A
# Share email with EFF: N
#
# Congratulations! Your certificate and chain have been saved at:
# /etc/letsencrypt/live/example.com/fullchain.pem
# Key: /etc/letsencrypt/live/example.com/privkey.pem
# Certificate will expire on 2024-03-10

# Method 2: Nginx integration
sudo certbot --nginx -d example.com -d www.example.com

# Method 3: Standalone (no web server)
sudo certbot certonly --standalone -d example.com
# This temporarily runs its own web server on port 80

# Method 4: Webroot (existing web server)
sudo certbot certonly --webroot \
  -w /var/www/html \
  -d example.com \
  -d www.example.com

# Method 5: DNS challenge (for wildcards)
sudo certbot certonly --manual \
  --preferred-challenges dns \
  -d "*.example.com" \
  -d example.com
# You'll need to add TXT records to DNS
```

#### Managing Let's Encrypt Certificates

```bash
# List certificates:
sudo certbot certificates
# Found the following certs:
#   Certificate Name: example.com
#     Serial Number: 3a1b2c3d4e5f6789...
#     Domains: example.com www.example.com
#     Expiry Date: 2024-03-10 10:00:00+00:00 (VALID: 89 days)
#     Certificate Path: /etc/letsencrypt/live/example.com/fullchain.pem
#     Private Key Path: /etc/letsencrypt/live/example.com/privkey.pem

# Test renewal:
sudo certbot renew --dry-run
# Processing /etc/renewal/example.com.conf
# Simulating renewal of an existing certificate for example.com
# Congratulations, all simulated renewals succeeded!

# Force renewal:
sudo certbot renew --force-renewal

# Set up automatic renewal:
sudo systemctl enable --now certbot-renew.timer

# Check timer:
systemctl status certbot-renew.timer
systemctl list-timers certbot-renew

# Or use cron:
sudo crontab -e
# Add:
0 3 * * * /usr/bin/certbot renew --quiet --post-hook "systemctl reload nginx"

# Certificate files explained:
ls -la /etc/letsencrypt/live/example.com/
# cert.pem       -> Certificate only
# chain.pem      -> Intermediate certificates
# fullchain.pem  -> cert.pem + chain.pem (use this!)
# privkey.pem    -> Private key
```

### Certificate Management

#### Working with Certificates

```bash
# View certificate details:
openssl x509 -in /path/to/cert.crt -text -noout

# Check certificate dates:
openssl x509 -in cert.crt -noout -dates
# notBefore=Dec 11 10:00:00 2023 GMT
# notAfter=Mar 10 10:00:00 2024 GMT

# Check who issued certificate:
openssl x509 -in cert.crt -noout -issuer
# issuer=C=US, O=Let's Encrypt, CN=R3

# Check certificate fingerprint:
openssl x509 -in cert.crt -noout -fingerprint -sha256
# SHA256 Fingerprint=AB:CD:EF:12:34:56...

# Verify certificate matches private key:
openssl x509 -in cert.crt -noout -modulus | md5sum
openssl rsa -in private.key -noout -modulus | md5sum
# These should match!

# Check certificate chain:
openssl verify -CAfile chain.pem cert.crt
# cert.crt: OK

# Convert certificate formats:
# PEM to DER:
openssl x509 -in cert.pem -outform DER -out cert.der

# DER to PEM:
openssl x509 -in cert.der -inform DER -out cert.pem

# PEM to PKCS12 (for Windows):
openssl pkcs12 -export \
  -out certificate.pfx \
  -inkey private.key \
  -in cert.crt \
  -certfile chain.crt

# Extract from PKCS12:
openssl pkcs12 -in certificate.pfx -out cert.pem -nodes
```

#### Certificate Store Management

```bash
# Rocky Linux certificate store:
ls -la /etc/pki/
# ca-trust/     <- Trusted CAs
# tls/          <- TLS certificates
# rpm-gpg/      <- RPM signing keys

# View trusted CAs:
trust list
# pkcs11:id=%12%34%56...
#     type: certificate
#     label: DigiCert Global Root CA
#     trust: anchor
#     category: authority

# Add custom CA:
sudo cp myCA.crt /etc/pki/ca-trust/source/anchors/
sudo update-ca-trust

# Remove CA:
sudo rm /etc/pki/ca-trust/source/anchors/myCA.crt
sudo update-ca-trust

# Java certificate store (if Java installed):
keytool -list -cacerts
# Enter keystore password: changeit

# Add to Java store:
sudo keytool -import \
  -trustcacerts \
  -alias myCA \
  -file myCA.crt \
  -keystore /etc/pki/java/cacerts

# Test HTTPS connection:
curl -v https://example.com
# * SSL certificate verify ok.

# Ignore certificate errors (testing only!):
curl -k https://self-signed.local
wget --no-check-certificate https://self-signed.local
```

### SSL/TLS Configuration Best Practices

```bash
# Strong Apache SSL configuration:
sudo nano /etc/httpd/conf.d/ssl.conf

# Modern configuration (requires newer clients):
SSLEngine on
SSLProtocol -all +TLSv1.3 +TLSv1.2
SSLCipherSuite ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256
SSLHonorCipherOrder off
SSLSessionTickets off

# Add security headers:
Header always set Strict-Transport-Security "max-age=63072000"
Header always set X-Frame-Options "DENY"
Header always set X-Content-Type-Options "nosniff"

# Strong Nginx SSL configuration:
sudo nano /etc/nginx/conf.d/ssl.conf

ssl_protocols TLSv1.2 TLSv1.3;
ssl_ciphers ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256;
ssl_prefer_server_ciphers off;
ssl_session_cache shared:SSL:10m;
ssl_session_timeout 10m;
ssl_stapling on;
ssl_stapling_verify on;

# Test SSL configuration:
# Online:
# https://www.ssllabs.com/ssltest/

# Command line:
openssl s_client -connect example.com:443 -tls1_2
openssl s_client -connect example.com:443 -tls1_3

# Test cipher support:
nmap --script ssl-enum-ciphers -p 443 example.com

# Generate DH parameters for perfect forward secrecy:
openssl dhparam -out /etc/pki/tls/dhparam.pem 2048

# Then in Apache:
SSLOpenSSLConfCmd DHParameters "/etc/pki/tls/dhparam.pem"

# Or in Nginx:
ssl_dhparam /etc/pki/tls/dhparam.pem;
```

## Practice Exercises

### Exercise 1: Network Configuration Challenge
1. Configure a static IP address using nmcli
2. Set up a secondary IP address on the same interface
3. Configure custom DNS servers
4. Create a network bridge for virtualization
5. Set up network bonding for redundancy
6. Test connectivity and troubleshoot any issues

### Exercise 2: Firewall Hardening
1. Create a custom firewall zone for web servers
2. Allow HTTP/HTTPS only from specific subnets
3. Implement rate limiting for SSH connections
4. Block all outgoing connections except DNS and HTTP/HTTPS
5. Log all dropped packets to a specific file
6. Create a rich rule for port knocking

### Exercise 3: Security Audit Setup
1. Configure auditd to monitor all sudo commands
2. Watch for changes to system configuration files
3. Monitor all network connections by a specific user
4. Set up AIDE to monitor /etc and /usr/bin
5. Create daily reports of security events
6. Alert on any unauthorized file changes

### Exercise 4: SSL/TLS Implementation
1. Create a self-signed wildcard certificate
2. Set up Apache with strong SSL configuration
3. Implement Let's Encrypt for a test domain
4. Configure certificate auto-renewal
5. Test SSL configuration with various tools
6. Set up client certificate authentication

## Summary

In Part 4, we've mastered networking and security in Rocky Linux:

**Network Configuration:**
- NetworkManager and nmcli for modern network management
- DNS configuration and troubleshooting
- Network debugging with ping, traceroute, ss, and tcpdump
- Understanding and fixing common network problems

**Security Hardening:**
- Firewalld zones and rules for network security
- Rich rules for complex firewall configurations
- System auditing with auditd for compliance
- File integrity monitoring with AIDE

**SSL/TLS and Certificates:**
- Understanding certificate concepts and chains
- Creating self-signed certificates
- Implementing Let's Encrypt for free trusted certificates
- Certificate management and troubleshooting
- Strong SSL/TLS configuration

These skills enable you to:
- Configure complex network setups
- Secure your Rocky Linux servers properly
- Monitor and audit system security
- Implement encrypted communications
- Troubleshoot network and security issues

## Additional Resources

- [Rocky Linux Security Guide](https://docs.rockylinux.org/guides/security/)
- [NetworkManager Documentation](https://networkmanager.dev/docs/)
- [Firewalld Documentation](https://firewalld.org/documentation/)
- [Let's Encrypt Documentation](https://letsencrypt.org/docs/)
- [OpenSSL Cookbook](https://www.feistyduck.com/library/openssl-cookbook/online/)
- [Mozilla SSL Configuration Generator](https://ssl-config.mozilla.org/)
- [AIDE Documentation](https://aide.github.io/)
- [Red Hat Audit System Guide](https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/8/html/security_hardening/auditing-the-system_security-hardening)

---

*Continue to Part 5: Package and Software Management*