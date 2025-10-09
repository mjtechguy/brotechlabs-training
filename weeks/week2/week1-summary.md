# Week 1 Summary: IT & DevOps Fundamentals + Hetzner Cloud Server Lab

## Overview

Week 1 covered foundational IT concepts and provided hands-on experience with cloud server setup and management. This week combined theoretical knowledge with practical skills in a real cloud environment.

---

## Key Concepts Covered

### 1. Hardware Fundamentals

**Storage Technologies:**
- **HDD (Hard Disk Drive)**: Traditional spinning disk storage
  - Speed: 80-160 MB/s
  - Best for: Bulk storage, backups
  - Cost-effective but mechanical/fragile

- **SSD (Solid State Drive)**: Flash memory storage
  - Speed: 400-550 MB/s (SATA)
  - Best for: OS drives, applications
  - Fast, silent, shock-resistant

- **NVMe**: High-performance SSD via PCIe
  - Speed: 1,500-7,000+ MB/s
  - Best for: High-performance workloads, gaming, video editing
  - Fastest consumer storage available

**RAM (Random Access Memory):**
- Temporary, volatile memory for active processes
- Types: DDR3 (legacy), DDR4 (current), DDR5 (newest)
- Key point: More RAM = more simultaneous programs
- Recommendations:
  - 8GB: Entry-level
  - 16GB: Sweet spot for most users
  - 32GB+: Professional workloads

**CPU Concepts:**
- **Cores**: Physical processing units
- **Threads**: Virtual cores via hyperthreading
- **Clock Speed**: GHz rating (cycles per second)
- **Architecture**: x86/x64 (Intel/AMD) vs ARM (Apple Silicon, mobile)

**Interfaces:**
- **USB**: Universal Serial Bus (2.0, 3.0, 3.1, 3.2, USB4)
- **USB-C**: Reversible connector supporting multiple protocols
- **Thunderbolt**: High-speed (40 Gbps) using USB-C connector
- **Display**: HDMI, DisplayPort, VGA (legacy), DVI (legacy)

### 2. Operating Systems

**Linux Distributions:**
- Ubuntu, CentOS, Debian, Fedora
- Package managers: apt (Debian/Ubuntu), yum/dnf (RHEL/CentOS)
- Open-source and dominant in server environments

**File System Hierarchy:**
- `/`: Root directory
- `/home`: User directories
- `/etc`: Configuration files
- `/var`: Variable data (logs, databases)
- `/tmp`: Temporary files

### 3. Networking Fundamentals

**Core Concepts:**
- **IP Address**: Device identifier (IPv4: 192.168.1.100, IPv6: longer format)
- **Subnet Mask**: Defines network vs host portion
- **CIDR Notation**: IP range notation (192.168.1.0/24)
- **Gateway/Router**: Connects networks, routes traffic
- **MAC Address**: Hardware identifier for network interfaces

**DNS (Domain Name System):**
- Translates domain names to IP addresses
- Record types: A (IPv4), AAAA (IPv6), CNAME (alias), MX (mail), TXT
- Common DNS servers: 8.8.8.8 (Google), 1.1.1.1 (Cloudflare)
- DNS cache: Stores recent lookups for speed

**DHCP (Dynamic Host Configuration Protocol):**
- Automatically assigns IP addresses and network settings
- DORA process: Discover, Offer, Request, Acknowledge
- Provides: IP, subnet mask, gateway, DNS servers, lease time
- Alternative: Static IP (manually configured)

**Domain Names:**
- Structure: subdomain.domain.tld (blog.example.com)
- TLDs: .com, .org, .net, .io, .dev
- Registration: Purchase from registrars (Namecheap, Cloudflare)
- Nameservers: Tell where to find DNS records

**Network Address Translation (NAT):**
- Allows multiple devices to share one public IP
- Private IP ranges: 10.0.0.0/8, 172.16.0.0/12, 192.168.0.0/16
- Types: SNAT, DNAT, PAT
- Port forwarding: Directs external traffic to internal devices

**VLANs (Virtual LANs):**
- Logical network separation on same physical switch
- Benefits: Security, performance, organization
- Tagged (trunk) vs untagged (access) ports
- Requires Layer 3 routing for inter-VLAN communication

**OSI Model (7 Layers):**
1. Physical: Hardware, cables
2. Data Link: MAC addresses, switches
3. Network: IP addresses, routing
4. Transport: TCP/UDP, ports
5. Session: Session management
6. Presentation: Data formatting
7. Application: HTTP, FTP, SMTP

**Protocols:**
- **TCP**: Reliable, connection-oriented
- **UDP**: Fast, connectionless
- **HTTP/HTTPS**: Web traffic (port 80/443)
- **SSH**: Secure remote access (port 22)
- **FTP/SFTP**: File transfer (port 21/22)

### 4. Command Line Essentials

**Navigation:**
```bash
pwd                 # Print working directory
ls -la              # List files with details
cd /path            # Change directory
cd ~                # Go to home
```

**File Operations:**
```bash
mkdir dirname       # Create directory
touch filename      # Create file
cp source dest      # Copy
mv source dest      # Move/rename
rm filename         # Delete
cat filename        # Display contents
less filename       # Paginated view
tail -f filename    # Follow file updates
```

**Permissions:**
```bash
chmod 755 file      # Set permissions (rwxr-xr-x)
chown user:group    # Change owner
```

**Process Management:**
```bash
ps aux              # List processes
top/htop            # Monitor processes
kill PID            # Terminate process
```

**System Info:**
```bash
df -h               # Disk space
free -h             # Memory usage
uname -a            # System info
```

### 5. Version Control (Git)

**Core Concepts:**
- **Repository**: Project folder tracked by Git
- **Commit**: Snapshot of code at a point in time
- **Branch**: Independent line of development
- **Merge**: Combining changes from branches
- **Remote**: Remote repository (GitHub, GitLab)

**Essential Commands:**
```bash
git init                    # Initialize repo
git clone URL               # Clone remote repo
git status                  # Check status
git add .                   # Stage all changes
git commit -m "message"     # Commit changes
git push origin main        # Push to remote
git pull origin main        # Pull from remote
git branch                  # List branches
git checkout -b feature     # Create and switch branch
```

### 6. Cloud Computing

**Service Models:**
- **IaaS**: Infrastructure as a Service (AWS EC2, VMs)
- **PaaS**: Platform as a Service (Heroku, App Engine)
- **SaaS**: Software as a Service (Gmail, Salesforce)

**Deployment Models:**
- Public Cloud: Shared infrastructure (AWS, Azure, GCP)
- Private Cloud: Dedicated infrastructure
- Hybrid Cloud: Mix of public and private

**Key Concepts:**
- **VM/Instance**: Virtual machine on physical hardware
- **Container**: Lightweight, portable app package (Docker)
- **Load Balancer**: Distributes traffic across servers
- **Auto Scaling**: Adjusts resources based on demand
- **Region/AZ**: Geographic locations and isolated data centers

### 7. Virtualization

**Hypervisors:**
- **Type 1 (Bare Metal)**: Runs directly on hardware (ESXi, Hyper-V, Proxmox)
  - Better performance, used in production

- **Type 2 (Hosted)**: Runs on OS (VirtualBox, VMware Workstation)
  - Easier setup, good for desktop/development

**VMs vs Containers:**
- **VMs**: Full OS virtualization, heavy, strong isolation
- **Containers**: Share OS kernel, lightweight, fast startup

**Snapshots:**
- Capture VM state at a point in time
- Use for backups before risky changes
- Can revert to previous state quickly

### 8. Remote Access & VPN

**Remote Desktop Protocols:**
- **RDP**: Microsoft's protocol for Windows (port 3389)
- **VNC**: Cross-platform remote desktop (port 5900)
- **SSH**: Secure command-line access (port 22)

**VPN (Virtual Private Network):**
- Creates encrypted tunnel for secure communication
- Use cases:
  - Remote access to corporate network
  - Site-to-site connections
  - Privacy and security on public WiFi

**VPN Protocols:**
- **OpenVPN**: Open-source, very secure, widely supported
- **WireGuard**: Modern, fastest, excellent security
- **IPSec/IKEv2**: Industry standard, built into devices
- **Tailscale**: Zero-config VPN built on WireGuard

### 9. DevOps Fundamentals

**Key Principles:**
1. Automation
2. Continuous Integration (CI)
3. Continuous Deployment (CD)
4. Infrastructure as Code (IaC)
5. Monitoring and Logging
6. Collaboration

**CI/CD Pipeline:**
1. Code
2. Build
3. Test
4. Deploy
5. Monitor

**Tools:**
- **CI/CD**: GitHub Actions, GitLab CI, Jenkins
- **IaC**: Terraform, Ansible, CloudFormation
- **Containers**: Docker, Kubernetes
- **Configuration**: Ansible, Puppet, Chef

### 10. Security Basics

**Authentication vs Authorization:**
- **Authentication**: Who are you? (login)
- **Authorization**: What can you do? (permissions)

**SSH (Secure Shell):**
```bash
ssh username@hostname           # Connect
ssh-keygen -t rsa -b 4096       # Generate key pair
ssh-copy-id username@hostname   # Copy public key
scp file.txt user@host:/path/   # Secure copy
```

**Firewalls:**
```bash
# UFW (Ubuntu)
sudo ufw allow 22               # Allow SSH
sudo ufw enable                 # Enable firewall

# iptables (Linux)
sudo iptables -L                # List rules
```

**Best Practices:**
1. Use strong passwords (12+ characters)
2. Enable MFA (Multi-Factor Authentication)
3. Principle of least privilege
4. Keep systems updated
5. Use SSH keys instead of passwords
6. Encrypt sensitive data
7. Regular backups
8. Monitor logs

### 11. Troubleshooting Methodology

**Systematic Approach:**
1. Identify the problem
2. Gather information (logs, error messages)
3. Establish a theory
4. Test the theory
5. Plan of action
6. Implement solution
7. Verify functionality
8. Document

**Diagnostic Questions:**
- When did it start?
- What changed recently?
- Can you reproduce it?
- One user or everyone?
- Any error messages?

---

## Hands-On Lab: Hetzner Cloud Server Setup

### What We Built

A fully functional Ubuntu server on Hetzner Cloud with:
- Code-server (VS Code in browser)
- Nginx web server
- Custom HTML page
- Firewall configuration
- User management
- Package management

### Lab Components

#### 1. Hetzner Server Setup
- **Platform**: Hetzner Cloud
- **OS**: Ubuntu 22.04 LTS
- **Server Type**: CX11 (1 vCPU, 2GB RAM, 20GB SSD)
- **Cost**: ~€4.15/month (~$4.50/month)
- **Region**: Nuremberg (Europe) or Ashburn (US)

#### 2. Security Configuration

**Hetzner Cloud Firewall:**
- Port 22: SSH access
- Port 80: HTTP web traffic
- Port 443: HTTPS web traffic
- Port 8080: Code-server interface

**SSH Key Authentication:**
- Generated SSH key pair (ed25519)
- Uploaded public key to Hetzner
- Secure, password-less authentication

#### 3. Initial Server Setup
```bash
# System updates
apt update && apt upgrade -y

# Essential tools
apt install -y curl wget git vim htop ufw

# Verify installations
curl --version
git --version
htop --version
```

#### 4. Code-Server Installation

**What is Code-Server?**
- VS Code running in browser
- Accessible from anywhere
- Full IDE functionality remotely

**Setup:**
```bash
# Install code-server
curl -fsSL https://code-server.dev/install.sh | sh

# Configure
mkdir -p ~/.config/code-server
cat > ~/.config/code-server/config.yaml << EOF
bind-addr: 0.0.0.0:8080
auth: password
password: YOUR_STRONG_PASSWORD
cert: false
EOF

# Start service
systemctl enable --now code-server@root

# Verify
systemctl status code-server@root
ss -tulpn | grep 8080
```

**Access:**
- URL: `http://YOUR_SERVER_IP:8080`
- Enter password configured above
- VS Code interface in browser

#### 5. CodeLab Extension

**Installation:**
```bash
# Download extension
cd ~
wget https://github.com/mjtechguy/codelabv2/releases/download/v1.1.0/codelabv2-1.1.0.vsix

# Install
code-server --install-extension ~/codelabv2-1.1.0.vsix

# Restart
systemctl restart code-server@root
```

**Benefits:**
- Interactive learning documents
- Executable code blocks
- Built-in quizzes
- Live command execution

#### 6. User Management Lab

**Created Regular User:**
```bash
# Create user
adduser student

# Grant sudo privileges
usermod -aG sudo student

# Verify
groups student

# Test sudo access
su - student
sudo whoami
```

**Key Concepts:**
- Never use root for daily tasks
- Grant sudo only to trusted users
- Regular users provide security isolation

#### 7. Package Management

**APT (Advanced Package Tool):**
```bash
# Update package lists
apt update

# List upgradable packages
apt list --upgradable

# Upgrade all packages
apt upgrade -y

# Search for packages
apt search nginx

# Show package info
apt show nginx

# Install package
apt install nginx -y

# Remove package
apt remove nginx
```

#### 8. Nginx Web Server

**Installation and Configuration:**
```bash
# Install
apt install nginx -y

# Verify
nginx -v
systemctl status nginx

# Test locally
curl localhost

# Test externally
# Browser: http://YOUR_SERVER_IP
```

**Key Directories:**
- `/etc/nginx/`: Configuration directory
- `/etc/nginx/nginx.conf`: Main config file
- `/etc/nginx/sites-available/`: Available site configs
- `/etc/nginx/sites-enabled/`: Enabled site configs
- `/var/www/html/`: Default web root
- `/var/log/nginx/`: Log files

**Custom HTML Page:**
```bash
cat > /var/www/html/index.html << 'EOF'
<!DOCTYPE html>
<html>
<head>
    <title>My First Server</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
        }
    </style>
</head>
<body>
    <h1>Server Running Successfully!</h1>
</body>
</html>
EOF
```

**Service Management:**
```bash
# Start/stop/restart
systemctl start nginx
systemctl stop nginx
systemctl restart nginx

# Enable/disable on boot
systemctl enable nginx
systemctl disable nginx

# Check status
systemctl status nginx
systemctl is-enabled nginx
```

**Monitoring:**
```bash
# Access logs
tail -20 /var/log/nginx/access.log
tail -f /var/log/nginx/access.log  # Live

# Error logs
tail -20 /var/log/nginx/error.log
```

#### 9. System Monitoring

**Resource Monitoring:**
```bash
# CPU and memory
top
htop

# Disk space
df -h
du -sh /* | sort -h

# Memory
free -h

# Processes
ps aux
ps aux | grep nginx

# Network connections
ss -tulpn
ss -tulpn | grep :80
```

**Logs:**
```bash
# System logs
journalctl -n 50
tail -f /var/log/syslog

# Service logs
journalctl -u nginx
journalctl -u code-server@root -f
```

**System Information:**
```bash
# Hostname and OS
hostnamectl

# Kernel and architecture
uname -a

# Uptime
uptime
```

---

## Skills Acquired

### Technical Skills
- ✅ Cloud server provisioning (Hetzner)
- ✅ SSH key generation and authentication
- ✅ Firewall configuration (cloud-level)
- ✅ Linux user management
- ✅ Package management with APT
- ✅ Web server installation and configuration (Nginx)
- ✅ Service management with systemd
- ✅ System monitoring and log analysis
- ✅ Basic HTML and web hosting
- ✅ Remote development with code-server

### Conceptual Understanding
- ✅ Hardware components and their roles
- ✅ Networking fundamentals (IP, DNS, DHCP, NAT)
- ✅ Operating system architecture
- ✅ Command line proficiency
- ✅ Version control concepts (Git)
- ✅ Cloud computing models
- ✅ Virtualization technologies
- ✅ Security best practices
- ✅ DevOps principles
- ✅ Troubleshooting methodology

---

## Key Commands Reference

### System Management
```bash
# Updates
apt update && apt upgrade -y

# System info
uname -a
hostnamectl
uptime

# Resources
df -h               # Disk
free -h             # Memory
top / htop          # CPU/processes
```

### Service Management
```bash
systemctl status servicename
systemctl start servicename
systemctl stop servicename
systemctl restart servicename
systemctl enable servicename
systemctl disable servicename
```

### File Operations
```bash
ls -la              # List files
cd /path            # Change directory
pwd                 # Current directory
cat file            # Display file
less file           # Paginated view
tail -f file        # Follow file
nano file           # Edit file
```

### Network
```bash
ip addr             # Network interfaces
ping host           # Test connectivity
curl URL            # Fetch URL
ss -tulpn           # Listening ports
```

### Logs
```bash
journalctl -n 50                    # System logs
journalctl -u servicename           # Service logs
tail -f /var/log/syslog             # System log (live)
tail -f /var/log/nginx/access.log   # Nginx access log
```

---

## Important Links

### Week 1 Materials
- [IT Technical Guide for Beginners](../week1/week1-it-devops-basics.md) - Comprehensive theory
- [Hetzner Cloud Server Basics - README](../week1/hetzner-cloud-server-basics/README.md) - Setup overview
- [Hetzner Setup Guide](../week1/hetzner-cloud-server-basics/01-hetzner-setup.mdcl) - Interactive setup
- [Server Basics Lab](../week1/hetzner-cloud-server-basics/02-server-basics-lab.mdcl) - Hands-on exercises

### External Resources

**Cloud Platforms:**
- [Hetzner Cloud](https://www.hetzner.com/) - Cloud hosting provider
- [Hetzner Cloud Documentation](https://docs.hetzner.com/cloud/)
- [AWS Free Tier](https://aws.amazon.com/free/)
- [Google Cloud Free Tier](https://cloud.google.com/free)
- [Azure Free Account](https://azure.microsoft.com/en-us/free/)

**Tools:**
- [Code-Server](https://coder.com/docs/code-server) - VS Code in browser
- [CodeLab Extension](https://github.com/mjtechguy/codelabv2) - Interactive learning
- [Nginx Documentation](https://nginx.org/en/docs/)
- [Ubuntu Server Guide](https://ubuntu.com/server/docs)

**Learning Resources:**
- [Linux Journey](https://linuxjourney.com/) - Interactive Linux tutorials
- [DigitalOcean Tutorials](https://www.digitalocean.com/community/tutorials) - Excellent guides
- [ExplainShell](https://explainshell.com/) - Understand any command
- [DevOps Roadmap](https://roadmap.sh/devops) - Learning path

**Communities:**
- [r/linuxadmin](https://reddit.com/r/linuxadmin) - Linux administration
- [r/homelab](https://reddit.com/r/homelab) - Home server enthusiasts
- [r/devops](https://reddit.com/r/devops) - DevOps community
- [Stack Overflow](https://stackoverflow.com/) - Programming Q&A

**Documentation:**
- [Ubuntu Man Pages](https://manpages.ubuntu.com/) - Command documentation
- [Linux Man Pages](https://linux.die.net/man/) - Alternative reference
- [Git Documentation](https://git-scm.com/doc)
- [Docker Documentation](https://docs.docker.com/)

---

## Next Steps (Week 2 Preview)

### Suggested Topics to Explore:

1. **SSL/TLS Certificates**
   - Secure your website with HTTPS
   - Use Let's Encrypt for free certificates
   - Configure nginx for SSL

2. **Docker & Containers**
   - Introduction to containerization
   - Docker basics and Dockerfile
   - Docker Compose for multi-container apps
   - Container orchestration concepts

3. **Databases**
   - Install MySQL or PostgreSQL
   - Basic database administration
   - Backup and restore procedures
   - Connecting applications to databases

4. **Reverse Proxy & Load Balancing**
   - Use nginx as reverse proxy
   - Host multiple applications
   - SSL termination
   - Load balancing strategies

5. **CI/CD Pipelines**
   - Introduction to automation
   - GitHub Actions basics
   - Automated testing
   - Continuous deployment

6. **Monitoring & Logging**
   - System monitoring with Prometheus
   - Visualization with Grafana
   - Centralized logging
   - Alerting and notifications

7. **Application Deployment**
   - Deploy Node.js/Python applications
   - Environment variable management
   - Process managers (PM2, systemd)
   - Application security

---

## Cost Management Reminder

**Hetzner Server Costs:**
- CX11: ~€0.006/hour or ~€4.15/month
- Charged while server exists (even if powered off)
- **To stop charges**: DELETE the server (not just power off)

**Deleting Your Server:**
1. Go to Hetzner Cloud Console
2. Select your server
3. Click "Delete"
4. Confirm deletion
5. Also delete unused firewalls and volumes

**Note**: You can always recreate the server using the lab guides!

---

## Reflection Questions

1. What was the most challenging concept to understand?
2. Which hands-on exercise was most valuable?
3. What would you like to explore more deeply?
4. How can you apply these skills to personal projects?
5. What real-world problems can you solve with these tools?

---

## Conclusion

Week 1 provided a solid foundation in IT fundamentals and hands-on cloud server experience. You've learned both the theory behind modern IT infrastructure and practical skills for managing real servers.

The combination of comprehensive technical documentation and interactive labs gave you both breadth and depth of knowledge. Continue building on these foundations as you progress through more advanced topics.

**Key Takeaway**: IT and DevOps skills build on each other. Master the fundamentals before moving to advanced topics, but don't be afraid to experiment and break things (in safe environments)!

---

**Created**: 2025-10-09
**Last Updated**: 2025-10-09
**Author**: BroTech Labs Training Program
