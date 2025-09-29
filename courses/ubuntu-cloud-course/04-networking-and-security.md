# Part 4: Networking and Security

## Prerequisites

Before starting this section, you should understand:
- Basic Linux commands and file permissions
- How to use systemctl to manage services
- Basic understanding of IP addresses and ports
- How to edit configuration files with nano or vim

**Learning Resources:**
- Ubuntu Network Configuration: https://ubuntu.com/server/docs/network-configuration
- UFW Guide: https://help.ubuntu.com/community/UFW
- Let's Encrypt Documentation: https://letsencrypt.org/docs/
- SSL/TLS Best Practices: https://wiki.mozilla.org/Security/Server_Side_TLS

---

## Chapter 9: Network Configuration

### Understanding Networking in Cloud VMs

Cloud VM networking is different from traditional server networking. Your VM exists in a virtual network environment with specific characteristics.

#### Key Networking Concepts

**IP Addresses in Cloud VMs:**

```bash
# View your network interfaces
ip addr show

# Typical output:
# 1: lo: <LOOPBACK,UP,LOWER_UP>
#     inet 127.0.0.1/8 scope host lo
# 2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP>
#     inet 172.31.23.145/20 brd 172.31.31.255 scope global eth0
#     inet6 fe80::1234:5678:90ab:cdef/64 scope link

# Understanding the output:
# lo = loopback interface (always 127.0.0.1)
# eth0 = primary network interface
# inet = IPv4 address
# inet6 = IPv6 address
# /20 = subnet mask (CIDR notation)
```

**Types of IP Addresses:**

1. **Private IP**: Internal cloud network address (e.g., 172.31.23.145)
2. **Public IP**: Internet-accessible address (e.g., 54.123.45.67)
3. **Elastic/Floating IP**: Persistent public IP that can move between VMs

```bash
# Get your public IP (from inside the VM)
curl -s ifconfig.me
# or
curl -s ipinfo.io/ip

# See both private and public network info
curl -s ipinfo.io
```

### Netplan Configuration (Ubuntu 18.04+)

Ubuntu uses Netplan for network configuration. It's a YAML-based configuration system that generates the appropriate configuration for your chosen network backend.

#### Understanding Netplan

```bash
# Netplan configuration files location
ls -la /etc/netplan/

# View current configuration
cat /etc/netplan/50-cloud-init.yaml

# Example configuration:
# network:
#   version: 2
#   ethernets:
#     eth0:
#       dhcp4: true
#       dhcp6: false
```

#### Setting a Static IP

```bash
# Create a backup first
sudo cp /etc/netplan/50-cloud-init.yaml /etc/netplan/50-cloud-init.yaml.backup

# Edit the configuration
sudo nano /etc/netplan/01-netcfg.yaml
```

```yaml
# Static IP configuration example
network:
  version: 2
  renderer: networkd
  ethernets:
    eth0:
      dhcp4: no
      addresses:
        - 192.168.1.100/24
      gateway4: 192.168.1.1
      nameservers:
        addresses: [8.8.8.8, 8.8.4.4]
```

```bash
# Test the configuration (dry run)
sudo netplan try

# Apply the configuration
sudo netplan apply

# Verify the changes
ip addr show eth0
```

### DNS Configuration

DNS (Domain Name System) translates domain names to IP addresses.

#### Checking DNS Configuration

```bash
# View current DNS servers
systemd-resolve --status | grep "DNS Servers"

# Alternative method
cat /etc/resolv.conf

# Test DNS resolution
nslookup google.com
dig google.com
host google.com

# See which DNS server answered
dig google.com | grep SERVER
```

#### Configuring DNS

```bash
# Method 1: Using Netplan (preferred for permanent changes)
sudo nano /etc/netplan/01-netcfg.yaml
```

```yaml
network:
  version: 2
  ethernets:
    eth0:
      dhcp4: true
      nameservers:
        addresses:
          - 1.1.1.1  # Cloudflare
          - 1.0.0.1  # Cloudflare backup
          - 8.8.8.8  # Google
        search: [mydomain.com]
```

```bash
# Apply changes
sudo netplan apply

# Method 2: Using systemd-resolved
sudo nano /etc/systemd/resolved.conf

# Add or modify:
# [Resolve]
# DNS=1.1.1.1 8.8.8.8
# FallbackDNS=1.0.0.1 8.8.4.4
# Domains=mydomain.com

# Restart the service
sudo systemctl restart systemd-resolved
```

### Network Troubleshooting

#### Essential Commands

```bash
# Check connectivity
ping -c 4 google.com

# Trace the route to a destination
traceroute google.com
# or
mtr google.com  # Better interactive traceroute

# Check open ports on your system
sudo ss -tulpn
# or
sudo netstat -tulpn

# Understanding the output:
# t = TCP
# u = UDP
# l = Listening
# p = Show process
# n = Numeric (don't resolve names)

# Test specific port connectivity
nc -zv google.com 443
# -z = Zero I/O mode (scanning)
# -v = Verbose
# 443 = HTTPS port

# Check firewall rules
sudo ufw status verbose
sudo iptables -L -n -v
```

#### Common Network Issues and Solutions

```bash
# Issue: Can't reach the internet
# Step 1: Check if you have an IP
ip addr show

# Step 2: Check your default gateway
ip route show
# Look for: default via 192.168.1.1 dev eth0

# Step 3: Test connectivity to gateway
ping -c 4 192.168.1.1

# Step 4: Test DNS
nslookup google.com
# If this fails but ping 8.8.8.8 works, it's a DNS issue

# Issue: Service not accessible from outside
# Check if service is running
sudo systemctl status nginx

# Check if it's listening on the right port/interface
sudo ss -tlnp | grep :80

# Check firewall
sudo ufw status
sudo ufw allow 80/tcp

# Check cloud security groups (provider-specific)
```

### Port Management

Understanding and managing ports is crucial for service accessibility.

```bash
# Well-known ports (0-1023)
# 22  - SSH
# 80  - HTTP
# 443 - HTTPS
# 3306 - MySQL
# 5432 - PostgreSQL
# 6379 - Redis

# View services and their ports
cat /etc/services | grep -E "^(ssh|http|https|mysql|postgres)"

# Change SSH port (security through obscurity)
sudo nano /etc/ssh/sshd_config
# Find and change: Port 22
# To something like: Port 2222

# Restart SSH
sudo systemctl restart sshd

# Update firewall
sudo ufw allow 2222/tcp
sudo ufw delete allow 22/tcp
```

---

## Chapter 10: Security Hardening

### Security Assessment

Before hardening your server, understand its current security posture.

#### Initial Security Scan

```bash
# Check for security updates
sudo apt update
sudo apt list --upgradable

# Check listening services
sudo ss -tulpn

# Check running processes
ps aux

# Check for unnecessary packages
dpkg -l | grep -E '^ii' | wc -l  # Count installed packages

# Check user accounts
cat /etc/passwd | grep -E "/bin/bash|/bin/sh"

# Check sudo permissions
sudo grep -E "^[^#]" /etc/sudoers /etc/sudoers.d/*

# Check for world-writable files
find / -type f -perm -002 2>/dev/null

# Check for SUID/SGID files
find / -type f \( -perm -4000 -o -perm -2000 \) 2>/dev/null
```

### Firewall Configuration with UFW

UFW (Uncomplicated Firewall) is Ubuntu's user-friendly interface to iptables.

#### Basic UFW Setup

```bash
# Check current status
sudo ufw status verbose

# Set default policies
sudo ufw default deny incoming
sudo ufw default allow outgoing

# Allow SSH (critical - do this before enabling!)
sudo ufw allow 22/tcp
# or for custom SSH port
sudo ufw allow 2222/tcp

# Enable the firewall
sudo ufw enable

# Allow common services
sudo ufw allow 80/tcp   # HTTP
sudo ufw allow 443/tcp  # HTTPS
sudo ufw allow 3306/tcp # MySQL (only if needed externally)

# Allow from specific IP
sudo ufw allow from 192.168.1.100 to any port 22

# Allow from subnet
sudo ufw allow from 192.168.1.0/24 to any port 3306

# Rate limiting (protect against brute force)
sudo ufw limit ssh

# Delete a rule
sudo ufw delete allow 3306/tcp
# or by number
sudo ufw status numbered
sudo ufw delete 5
```

#### Advanced UFW Rules

```bash
# Allow range of ports
sudo ufw allow 8000:8010/tcp

# Application profiles
sudo ufw app list
sudo ufw app info "Nginx Full"
sudo ufw allow "Nginx Full"

# Logging
sudo ufw logging on
sudo ufw logging medium  # low, medium, high, full

# View logs
sudo tail -f /var/log/ufw.log

# Block specific IP
sudo ufw deny from 192.168.1.50

# Block and log
sudo ufw deny from 192.168.1.50 to any port 80 comment 'Block suspicious IP'
```

### Fail2ban Setup

Fail2ban monitors log files and bans IPs that show malicious behavior.

#### Installing and Configuring Fail2ban

```bash
# Install
sudo apt update
sudo apt install fail2ban -y

# Create local configuration
sudo cp /etc/fail2ban/jail.conf /etc/fail2ban/jail.local
sudo nano /etc/fail2ban/jail.local
```

```ini
# Key settings in jail.local

[DEFAULT]
# Ban time (in seconds)
bantime = 3600  # 1 hour
# Time window for counting failures
findtime = 600  # 10 minutes
# Number of failures before ban
maxretry = 5

# Email notifications
destemail = admin@example.com
action = %(action_mwl)s

[sshd]
enabled = true
port = ssh
filter = sshd
logpath = /var/log/auth.log
maxretry = 3
bantime = 7200

[nginx-http-auth]
enabled = true
filter = nginx-http-auth
port = http,https
logpath = /var/log/nginx/error.log

[nginx-noscript]
enabled = true
port = http,https
filter = nginx-noscript
logpath = /var/log/nginx/access.log
maxretry = 2

[nginx-badbots]
enabled = true
port = http,https
filter = nginx-badbots
logpath = /var/log/nginx/access.log
maxretry = 2

[nginx-noproxy]
enabled = true
port = http,https
filter = nginx-noproxy
logpath = /var/log/nginx/error.log
maxretry = 2
```

```bash
# Restart fail2ban
sudo systemctl restart fail2ban
sudo systemctl enable fail2ban

# Check status
sudo fail2ban-client status
sudo fail2ban-client status sshd

# Unban an IP
sudo fail2ban-client unban 192.168.1.100

# Ban manually
sudo fail2ban-client set sshd banip 192.168.1.100

# Check fail2ban logs
sudo tail -f /var/log/fail2ban.log
```

### AppArmor Configuration

AppArmor provides Mandatory Access Control (MAC) to restrict programs' capabilities.

```bash
# Check AppArmor status
sudo aa-status

# List profiles
ls /etc/apparmor.d/

# Put a profile in enforce mode
sudo aa-enforce /etc/apparmor.d/usr.sbin.nginx

# Put a profile in complain mode (logs but doesn't block)
sudo aa-complain /etc/apparmor.d/usr.sbin.nginx

# Reload profiles
sudo systemctl reload apparmor

# Check AppArmor logs
sudo journalctl -xe | grep apparmor
```

### System Auditing with auditd

Auditd tracks security-relevant events on your system.

```bash
# Install auditd
sudo apt install auditd audispd-plugins -y

# Check status
sudo systemctl status auditd

# Basic audit rules
sudo nano /etc/audit/rules.d/audit.rules
```

```bash
# Example audit rules

# Monitor password file changes
-w /etc/passwd -p wa -k passwd_changes
-w /etc/shadow -p wa -k shadow_changes
-w /etc/group -p wa -k group_changes

# Monitor sudo usage
-w /usr/bin/sudo -p x -k sudo_usage

# Monitor SSH configuration
-w /etc/ssh/sshd_config -p wa -k sshd_config

# Monitor system calls
-a always,exit -F arch=b64 -S execve -F uid=0 -k root_commands

# File deletion by users
-a always,exit -F arch=b64 -S unlink -S unlinkat -S rename -S renameat -F auid>=1000 -F auid!=4294967295 -k delete
```

```bash
# Load rules
sudo augenrules --load

# Search audit logs
sudo ausearch -k passwd_changes
sudo ausearch -k sudo_usage --start today

# Generate reports
sudo aureport --summary
sudo aureport --auth
sudo aureport --failed
```

### File Integrity Monitoring

Monitor critical files for unauthorized changes.

```bash
# Install AIDE (Advanced Intrusion Detection Environment)
sudo apt install aide aide-common -y

# Initialize AIDE database
sudo aideinit
# This creates a baseline of your system

# Configure what to monitor
sudo nano /etc/aide/aide.conf

# Run a check
sudo aide --check

# Update database after legitimate changes
sudo aide --update
sudo mv /var/lib/aide/aide.db.new /var/lib/aide/aide.db

# Set up daily checks
sudo nano /etc/cron.daily/aide
```

```bash
#!/bin/bash
# AIDE daily check script
/usr/bin/aide --check | mail -s "AIDE Report $(hostname)" admin@example.com
```

```bash
# Make it executable
sudo chmod +x /etc/cron.daily/aide
```

### Security Updates Automation

Keep your system automatically updated with security patches.

```bash
# Install unattended-upgrades
sudo apt install unattended-upgrades apt-listchanges -y

# Configure
sudo dpkg-reconfigure unattended-upgrades

# Edit configuration
sudo nano /etc/apt/apt.conf.d/50unattended-upgrades
```

```conf
// Automatically upgrade packages from these origins
Unattended-Upgrade::Allowed-Origins {
    "${distro_id}:${distro_codename}-security";
    "${distro_id}ESMApps:${distro_codename}-apps-security";
    "${distro_id}ESM:${distro_codename}-infra-security";
};

// Automatically reboot if required
Unattended-Upgrade::Automatic-Reboot "true";
Unattended-Upgrade::Automatic-Reboot-Time "02:00";

// Send email notifications
Unattended-Upgrade::Mail "admin@example.com";
Unattended-Upgrade::MailReport "on-change";

// Remove unused dependencies
Unattended-Upgrade::Remove-Unused-Dependencies "true";
```

```bash
# Test configuration
sudo unattended-upgrades --dry-run --debug

# Check logs
sudo tail -f /var/log/unattended-upgrades/unattended-upgrades.log
```

---

## Chapter 11: SSL/TLS and Certificates

### Understanding Certificates

SSL/TLS certificates enable encrypted HTTPS connections. Let's understand how they work.

#### Certificate Concepts

**What is SSL/TLS?**
- **SSL**: Secure Sockets Layer (deprecated)
- **TLS**: Transport Layer Security (current standard)
- Provides encryption, authentication, and integrity

**Certificate Components:**
1. **Public Key**: Shared with everyone
2. **Private Key**: Keep secret on your server
3. **Certificate**: Contains public key + identity info
4. **Certificate Authority (CA)**: Trusted entity that signs certificates

```bash
# Generate a self-signed certificate (for testing only!)
sudo openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
  -keyout /etc/ssl/private/test.key \
  -out /etc/ssl/certs/test.crt \
  -subj "/C=US/ST=State/L=City/O=Organization/CN=example.com"

# View certificate details
openssl x509 -in /etc/ssl/certs/test.crt -text -noout

# Check certificate expiration
openssl x509 -in /etc/ssl/certs/test.crt -noout -dates
```

### Let's Encrypt Automation

Let's Encrypt provides free, automated SSL certificates.

#### Installing Certbot

```bash
# Install snapd (if not installed)
sudo apt update
sudo apt install snapd -y

# Install certbot
sudo snap install --classic certbot
sudo ln -s /snap/bin/certbot /usr/bin/certbot

# Alternative: Install from repository
sudo apt update
sudo apt install certbot python3-certbot-nginx -y  # For Nginx
# or
sudo apt install certbot python3-certbot-apache -y  # For Apache
```

#### Obtaining Certificates

```bash
# For Nginx (automatic configuration)
sudo certbot --nginx -d example.com -d www.example.com

# For Apache
sudo certbot --apache -d example.com -d www.example.com

# Standalone (if no web server running)
sudo certbot certonly --standalone -d example.com

# Webroot (place files in web directory)
sudo certbot certonly --webroot -w /var/www/html -d example.com

# DNS challenge (for wildcard certificates)
sudo certbot certonly --manual --preferred-challenges dns -d "*.example.com"
```

#### Interactive Certificate Setup

```bash
# Run certbot interactively
sudo certbot --nginx

# You'll be prompted for:
# 1. Email address (for renewal notifications)
# 2. Terms of service agreement
# 3. Whether to share email with EFF
# 4. Which domains to secure
# 5. Whether to redirect HTTP to HTTPS
```

### Certificate Management

#### Viewing Certificates

```bash
# List certificates managed by certbot
sudo certbot certificates

# Output example:
# Certificate Name: example.com
#   Domains: example.com www.example.com
#   Expiry Date: 2024-06-15 12:34:56+00:00 (VALID: 89 days)
#   Certificate Path: /etc/letsencrypt/live/example.com/fullchain.pem
#   Private Key Path: /etc/letsencrypt/live/example.com/privkey.pem

# Check certificate details
sudo openssl x509 -in /etc/letsencrypt/live/example.com/cert.pem -text -noout

# Verify certificate chain
sudo openssl verify -CAfile /etc/letsencrypt/live/example.com/chain.pem \
  /etc/letsencrypt/live/example.com/cert.pem
```

#### Testing Configuration

```bash
# Test renewal process
sudo certbot renew --dry-run

# Test specific certificate
sudo certbot renew --cert-name example.com --dry-run

# Force renewal (even if not due)
sudo certbot renew --force-renewal

# Check SSL configuration online
# Use: https://www.ssllabs.com/ssltest/
```

### SSL/TLS Configuration

#### Nginx SSL Configuration

```bash
# Create strong Diffie-Hellman parameters
sudo openssl dhparam -out /etc/nginx/dhparam.pem 2048

# Edit Nginx configuration
sudo nano /etc/nginx/sites-available/example.com
```

```nginx
server {
    listen 80;
    listen [::]:80;
    server_name example.com www.example.com;

    # Redirect all HTTP to HTTPS
    return 301 https://$server_name$request_uri;
}

server {
    listen 443 ssl http2;
    listen [::]:443 ssl http2;
    server_name example.com www.example.com;

    # SSL Certificate files
    ssl_certificate /etc/letsencrypt/live/example.com/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/example.com/privkey.pem;

    # SSL Security Settings
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_prefer_server_ciphers off;
    ssl_ciphers ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384;

    # SSL Optimization
    ssl_session_timeout 1d;
    ssl_session_cache shared:SSL:10m;
    ssl_session_tickets off;

    # Diffie-Hellman parameters
    ssl_dhparam /etc/nginx/dhparam.pem;

    # OCSP Stapling
    ssl_stapling on;
    ssl_stapling_verify on;
    ssl_trusted_certificate /etc/letsencrypt/live/example.com/chain.pem;

    # Security Headers
    add_header Strict-Transport-Security "max-age=63072000; includeSubDomains; preload" always;
    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header X-XSS-Protection "1; mode=block" always;

    # Your site configuration
    root /var/www/example.com;
    index index.html index.htm;

    location / {
        try_files $uri $uri/ =404;
    }
}
```

```bash
# Test Nginx configuration
sudo nginx -t

# Reload Nginx
sudo systemctl reload nginx
```

#### Apache SSL Configuration

```bash
# Enable SSL module
sudo a2enmod ssl
sudo a2enmod headers

# Edit Apache configuration
sudo nano /etc/apache2/sites-available/example.com-ssl.conf
```

```apache
<VirtualHost *:80>
    ServerName example.com
    ServerAlias www.example.com
    Redirect permanent / https://example.com/
</VirtualHost>

<VirtualHost *:443>
    ServerName example.com
    ServerAlias www.example.com
    DocumentRoot /var/www/example.com

    # Enable SSL
    SSLEngine on
    SSLCertificateFile /etc/letsencrypt/live/example.com/cert.pem
    SSLCertificateKeyFile /etc/letsencrypt/live/example.com/privkey.pem
    SSLCertificateChainFile /etc/letsencrypt/live/example.com/chain.pem

    # Security Settings
    SSLProtocol -all +TLSv1.2 +TLSv1.3
    SSLCipherSuite ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384
    SSLHonorCipherOrder off

    # Security Headers
    Header always set Strict-Transport-Security "max-age=63072000; includeSubDomains; preload"
    Header always set X-Frame-Options "SAMEORIGIN"
    Header always set X-Content-Type-Options "nosniff"

    # OCSP Stapling
    SSLUseStapling on
    SSLStaplingCache "shmcb:logs/stapling-cache(150000)"

    <Directory /var/www/example.com>
        Options Indexes FollowSymLinks
        AllowOverride All
        Require all granted
    </Directory>
</VirtualHost>
```

```bash
# Enable the site
sudo a2ensite example.com-ssl

# Test configuration
sudo apache2ctl configtest

# Reload Apache
sudo systemctl reload apache2
```

### Certificate Renewal

#### Automatic Renewal Setup

```bash
# Certbot automatically creates a systemd timer
sudo systemctl status snap.certbot.renew.timer
# or for apt installation
sudo systemctl status certbot.timer

# View the timer
systemctl list-timers | grep certbot

# Manual cron setup (if needed)
sudo crontab -e
# Add this line:
# 0 3 * * * /usr/bin/certbot renew --quiet --post-hook "systemctl reload nginx"
```

#### Renewal Hooks

```bash
# Create renewal hook scripts
sudo mkdir -p /etc/letsencrypt/renewal-hooks/deploy/
sudo nano /etc/letsencrypt/renewal-hooks/deploy/reload-services.sh
```

```bash
#!/bin/bash
# Reload services after successful renewal

# Reload Nginx if it's running
if systemctl is-active --quiet nginx; then
    systemctl reload nginx
    echo "Nginx reloaded"
fi

# Reload Apache if it's running
if systemctl is-active --quiet apache2; then
    systemctl reload apache2
    echo "Apache reloaded"
fi

# Restart other services that use the certificate
# systemctl restart postfix
# systemctl restart dovecot

# Send notification
echo "Certificates renewed on $(hostname)" | mail -s "Certificate Renewal" admin@example.com
```

```bash
# Make executable
sudo chmod +x /etc/letsencrypt/renewal-hooks/deploy/reload-services.sh

# Test renewal with hooks
sudo certbot renew --dry-run
```

### Troubleshooting SSL Issues

#### Common Problems and Solutions

```bash
# Problem: Certificate expired
# Check expiration
echo | openssl s_client -servername example.com -connect example.com:443 2>/dev/null | openssl x509 -noout -dates

# Force renewal
sudo certbot renew --force-renewal

# Problem: Mixed content warnings
# Find HTTP resources in HTTPS pages
grep -r "http://" /var/www/html/

# Problem: SSL handshake failures
# Test SSL connection
openssl s_client -connect example.com:443 -servername example.com

# Debug SSL issues
openssl s_client -debug -connect example.com:443

# Problem: Certificate chain issues
# Verify certificate chain
openssl s_client -connect example.com:443 -servername example.com -showcerts

# Problem: Browser warnings about weak ciphers
# Test SSL configuration
nmap --script ssl-enum-ciphers -p 443 example.com

# Online testing tools:
# https://www.ssllabs.com/ssltest/
# https://www.sslshopper.com/ssl-checker.html
# https://observatory.mozilla.org/
```

#### Certificate Backup

```bash
# Backup Let's Encrypt certificates
sudo tar -czf /backup/letsencrypt-$(date +%Y%m%d).tar.gz /etc/letsencrypt/

# Backup script
sudo nano /usr/local/bin/backup-certificates.sh
```

```bash
#!/bin/bash
# Certificate backup script

BACKUP_DIR="/backup/certificates"
DATE=$(date +%Y%m%d-%H%M%S)

# Create backup directory
mkdir -p "$BACKUP_DIR"

# Backup Let's Encrypt
tar -czf "$BACKUP_DIR/letsencrypt-$DATE.tar.gz" /etc/letsencrypt/

# Backup Nginx SSL configurations
tar -czf "$BACKUP_DIR/nginx-ssl-$DATE.tar.gz" /etc/nginx/sites-available/ /etc/nginx/snippets/

# Keep only last 30 days of backups
find "$BACKUP_DIR" -name "*.tar.gz" -mtime +30 -delete

echo "Certificate backup completed: $DATE"
```

```bash
# Make executable and schedule
sudo chmod +x /usr/local/bin/backup-certificates.sh
sudo crontab -e
# Add: 0 2 * * 0 /usr/local/bin/backup-certificates.sh
```

---

## Practice Exercises

### Exercise 1: Network Configuration
1. Display all network interfaces and their IP addresses
2. Set up a static IP address using Netplan
3. Configure custom DNS servers
4. Test connectivity to various services
5. Create a script to monitor network connectivity

### Exercise 2: Firewall Setup
1. Configure UFW with default deny incoming policy
2. Allow only necessary services (SSH, HTTP, HTTPS)
3. Set up rate limiting for SSH
4. Create rules for a database that should only be accessible from specific IPs
5. Monitor and analyze firewall logs

### Exercise 3: Security Hardening
1. Install and configure Fail2ban for SSH and web services
2. Set up auditd to monitor sensitive files
3. Configure automatic security updates
4. Perform a security assessment of your system
5. Create a hardening checklist and implement it

### Exercise 4: SSL Certificate Management
1. Obtain a Let's Encrypt certificate for a domain
2. Configure Nginx/Apache with strong SSL settings
3. Set up automatic renewal
4. Test SSL configuration using online tools
5. Create a monitoring script for certificate expiration

---

## Quick Reference

### Essential Network Commands
```bash
ip addr show                    # Show IP addresses
ip route show                    # Show routing table
ss -tulpn                       # Show listening ports
netstat -tulpn                  # Alternative to ss
nslookup domain.com            # DNS lookup
dig domain.com                 # Detailed DNS query
ping -c 4 google.com           # Test connectivity
traceroute google.com          # Trace network path
mtr google.com                 # Interactive traceroute
nc -zv host port               # Test port connectivity
curl -I https://example.com    # Test HTTP/HTTPS
```

### UFW Commands
```bash
sudo ufw status verbose        # Check status
sudo ufw enable               # Enable firewall
sudo ufw allow 22/tcp         # Allow SSH
sudo ufw allow from IP        # Allow from specific IP
sudo ufw deny from IP         # Block specific IP
sudo ufw limit ssh            # Rate limit SSH
sudo ufw delete allow 80      # Delete rule
sudo ufw reset                # Reset to defaults
```

### Security Commands
```bash
sudo fail2ban-client status    # Fail2ban status
sudo aa-status                 # AppArmor status
sudo ausearch -k keyword       # Search audit logs
sudo aide --check             # File integrity check
sudo certbot renew            # Renew certificates
sudo nginx -t                 # Test Nginx config
sudo apache2ctl configtest    # Test Apache config
```

### SSL/TLS Commands
```bash
sudo certbot --nginx          # Get cert for Nginx
sudo certbot renew --dry-run  # Test renewal
sudo certbot certificates     # List certificates
openssl x509 -in cert.pem -text # View certificate
openssl s_client -connect host:443 # Test SSL connection
```

---

## Additional Resources

### Documentation
- [Ubuntu Server Guide - Networking](https://ubuntu.com/server/docs/network-configuration)
- [UFW Documentation](https://help.ubuntu.com/community/UFW)
- [Let's Encrypt Documentation](https://letsencrypt.org/docs/)
- [OWASP TLS Cheat Sheet](https://cheatsheetseries.owasp.org/cheatsheets/Transport_Layer_Protection_Cheat_Sheet.html)

### Security Resources
- [CIS Ubuntu Benchmarks](https://www.cisecurity.org/cis-benchmarks/)
- [Linux Security Modules](https://www.kernel.org/doc/html/latest/admin-guide/LSM/index.html)
- [Fail2ban Filters](https://github.com/fail2ban/fail2ban)
- [Mozilla SSL Configuration Generator](https://ssl-config.mozilla.org/)

### Tools
- [SSL Labs Server Test](https://www.ssllabs.com/ssltest/)
- [Security Headers Scanner](https://securityheaders.com/)
- [Mozilla Observatory](https://observatory.mozilla.org/)
- [Shodan](https://www.shodan.io/) - Search engine for Internet-connected devices

### Next Steps
After completing this section, you should:
- Have a properly configured network setup
- Understand and implement security best practices
- Be able to obtain and manage SSL certificates
- Know how to monitor and audit system security

Continue to Part 5: Package and Software Management to learn about managing software on your Ubuntu server.