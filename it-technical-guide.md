# IT Technical Guide for Beginners

A comprehensive guide for those entering IT tech support, cloud computing, and DevOps work.

## Table of Contents

1. [Fundamental Concepts](#fundamental-concepts)
2. [Operating Systems](#operating-systems)
3. [Networking Basics](#networking-basics)
4. [Command Line Essentials](#command-line-essentials)
5. [Version Control](#version-control)
6. [Cloud Computing](#cloud-computing)
7. [DevOps Fundamentals](#devops-fundamentals)
8. [Security Basics](#security-basics)
9. [Troubleshooting Methodology](#troubleshooting-methodology)
10. [Common Tools](#common-tools)

---

## Fundamental Concepts

### What is IT?

**Information Technology (IT)** encompasses all aspects of managing and processing information using computers, networks, and software systems.

### Key IT Roles

- **Tech Support**: Assists users with technical issues, troubleshooting software/hardware problems
- **System Administrator**: Manages servers, networks, and infrastructure
- **DevOps Engineer**: Bridges development and operations, automating deployment and infrastructure
- **Cloud Engineer**: Manages cloud-based infrastructure and services

### Basic Computer Architecture

- **CPU (Central Processing Unit)**: The "brain" that executes instructions
- **RAM (Random Access Memory)**: Temporary storage for active processes
- **Storage (HDD/SSD)**: Permanent data storage
- **Motherboard**: Connects all components together
- **Network Interface Card (NIC)**: Enables network connectivity

---

## Operating Systems

### What is an Operating System?

An **Operating System (OS)** is software that manages hardware resources and provides services for applications.

### Major Operating Systems

#### Linux
- **Distribution (Distro)**: A specific version of Linux (Ubuntu, CentOS, Debian, Fedora)
- **Open-source**: Code is publicly available and free
- **Common in servers**: Most web servers and cloud instances run Linux
- **Package Manager**: Tool to install software (apt, yum, dnf)

#### Windows
- **Proprietary**: Owned by Microsoft
- **Common in enterprise**: Dominant in corporate desktop environments
- **Active Directory**: Centralized user/computer management system
- **PowerShell**: Advanced scripting and automation tool

#### macOS
- **Unix-based**: Built on Unix foundations (similar to Linux)
- **Common in development**: Popular among developers and creative professionals

### File System Hierarchy

**Linux/Unix**:
- `/` - Root directory (top level)
- `/home` - User home directories
- `/etc` - Configuration files
- `/var` - Variable data (logs, databases)
- `/tmp` - Temporary files
- `/usr` - User programs and utilities
- `/opt` - Optional third-party software

**Windows**:
- `C:\` - Primary drive
- `C:\Users` - User profiles
- `C:\Program Files` - Installed applications
- `C:\Windows` - OS files

---

## Networking Basics

### Core Concepts

#### IP Address
A unique identifier for devices on a network.
- **IPv4**: 192.168.1.100 (four octets, 0-255)
- **IPv6**: 2001:0db8:85a3:0000:0000:8a2e:0370:7334 (newer, longer format)

#### Subnet Mask
Defines which portion of an IP address is the network vs. host.
- Example: 255.255.255.0 (or /24 in CIDR notation)

#### CIDR (Classless Inter-Domain Routing)
Notation for IP ranges: `192.168.1.0/24` means 256 addresses (192.168.1.0 - 192.168.1.255)

#### Gateway/Router
Device that connects networks and routes traffic between them.

#### DNS (Domain Name System)
Translates domain names (google.com) to IP addresses (142.250.185.78).

#### DHCP (Dynamic Host Configuration Protocol)
Automatically assigns IP addresses to devices on a network.

### Network Protocols

- **TCP (Transmission Control Protocol)**: Reliable, connection-oriented communication
- **UDP (User Datagram Protocol)**: Fast, connectionless communication
- **HTTP/HTTPS**: Web traffic (port 80/443)
- **SSH (Secure Shell)**: Secure remote access (port 22)
- **FTP/SFTP**: File transfer (port 21/22)
- **ICMP**: Network diagnostics (ping)

### Common Network Commands

```bash
# Test connectivity
ping google.com

# Show IP configuration
ip addr          # Linux
ipconfig         # Windows

# Trace route to destination
traceroute google.com    # Linux
tracert google.com       # Windows

# Show network connections
netstat -tulpn   # Linux
netstat -ano     # Windows

# DNS lookup
nslookup google.com
dig google.com   # Linux (more detailed)

# Show routing table
ip route         # Linux
route print      # Windows
```

### Ports

**Port**: A virtual endpoint for network connections (0-65535)

**Common Ports**:
- 22: SSH
- 80: HTTP
- 443: HTTPS
- 3306: MySQL
- 5432: PostgreSQL
- 6379: Redis
- 3389: RDP (Remote Desktop)

---

## Command Line Essentials

### Why Command Line?

- **Efficiency**: Faster than GUI for many tasks
- **Automation**: Scripts can execute repetitive tasks
- **Remote Access**: SSH provides command-line access to remote servers
- **Powerful**: More control and options than GUI tools

### Linux/macOS Commands

#### Navigation
```bash
pwd                    # Print working directory
ls                     # List files
ls -la                 # List all files with details
cd /path/to/directory  # Change directory
cd ..                  # Go up one level
cd ~                   # Go to home directory
```

#### File Operations
```bash
mkdir dirname          # Create directory
touch filename         # Create empty file
cp source dest         # Copy file
mv source dest         # Move/rename file
rm filename            # Delete file
rm -rf dirname         # Delete directory recursively
cat filename           # Display file contents
less filename          # View file with pagination
head -n 10 filename    # Show first 10 lines
tail -n 10 filename    # Show last 10 lines
tail -f filename       # Follow file (live updates)
```

#### File Permissions
```bash
chmod 755 file         # Set permissions (rwxr-xr-x)
chown user:group file  # Change owner
```

**Permission Numbers**:
- 4: Read (r)
- 2: Write (w)
- 1: Execute (x)
- 755 = rwxr-xr-x (owner: all, group: read+execute, others: read+execute)

#### Search and Find
```bash
find /path -name "*.txt"      # Find files by name
grep "pattern" filename       # Search within files
grep -r "pattern" /path       # Recursive search
```

#### Process Management
```bash
ps aux                 # Show all processes
top                    # Real-time process monitor
htop                   # Better process monitor (if installed)
kill PID               # Terminate process
kill -9 PID            # Force kill process
killall processname    # Kill by name
```

#### System Information
```bash
df -h                  # Disk space usage
du -sh /path           # Directory size
free -h                # Memory usage
uname -a               # System information
uptime                 # System uptime
```

#### Text Processing
```bash
grep pattern file      # Filter lines
sed 's/old/new/g'      # Replace text
awk '{print $1}'       # Extract columns
sort file              # Sort lines
uniq                   # Remove duplicates
wc -l file             # Count lines
```

#### Piping and Redirection
```bash
command1 | command2    # Pipe output to next command
command > file         # Redirect output to file (overwrite)
command >> file        # Append output to file
command 2>&1           # Redirect stderr to stdout
```

### Windows Commands (CMD/PowerShell)

```powershell
# Navigation
dir                    # List files
cd path                # Change directory

# File operations
copy source dest       # Copy
move source dest       # Move
del filename           # Delete

# System info
ipconfig               # Network configuration
systeminfo             # System details
tasklist               # Running processes
taskkill /PID 1234     # Kill process
```

---

## Version Control

### Git Basics

**Git**: Distributed version control system for tracking code changes.

**Repository (Repo)**: A project folder tracked by Git.

#### Core Concepts

- **Commit**: A snapshot of code at a point in time
- **Branch**: An independent line of development
- **Merge**: Combining changes from different branches
- **Clone**: Copy a repository from remote to local
- **Push**: Send local commits to remote repository
- **Pull**: Fetch and merge remote changes to local
- **Fork**: Create a personal copy of someone else's repository

#### Essential Git Commands

```bash
# Initial setup
git config --global user.name "Your Name"
git config --global user.email "your@email.com"

# Create/clone repository
git init                        # Initialize new repo
git clone https://github.com/user/repo.git

# Basic workflow
git status                      # Check current state
git add filename                # Stage specific file
git add .                       # Stage all changes
git commit -m "message"         # Commit with message
git push origin main            # Push to remote
git pull origin main            # Pull from remote

# Branching
git branch                      # List branches
git branch feature-name         # Create branch
git checkout feature-name       # Switch branch
git checkout -b feature-name    # Create and switch
git merge feature-name          # Merge branch into current

# History and info
git log                         # View commit history
git log --oneline               # Compact history
git diff                        # Show unstaged changes
git diff --staged               # Show staged changes

# Undo changes
git restore filename            # Discard local changes
git reset HEAD~1                # Undo last commit (keep changes)
git reset --hard HEAD~1         # Undo last commit (discard changes)
```

---

## Cloud Computing

### What is Cloud Computing?

Delivery of computing services (servers, storage, databases, networking) over the internet.

### Cloud Service Models

#### IaaS (Infrastructure as a Service)
Raw computing resources: virtual machines, storage, networking.
- **Examples**: AWS EC2, Google Compute Engine, Azure VMs
- **Use case**: Full control over infrastructure

#### PaaS (Platform as a Service)
Platform for building/deploying applications without managing infrastructure.
- **Examples**: AWS Elastic Beanstalk, Google App Engine, Heroku
- **Use case**: Focus on code, not infrastructure

#### SaaS (Software as a Service)
Complete applications delivered over the internet.
- **Examples**: Gmail, Salesforce, Microsoft 365
- **Use case**: End-user applications

### Cloud Deployment Models

- **Public Cloud**: Shared infrastructure (AWS, Azure, GCP)
- **Private Cloud**: Dedicated infrastructure for one organization
- **Hybrid Cloud**: Combination of public and private

### Key Cloud Concepts

#### Virtual Machine (VM) / Instance
A software-based computer running on physical hardware.

#### Container
Lightweight, portable package containing application and dependencies.
- **Docker**: Most popular container platform
- **Kubernetes (K8s)**: Container orchestration platform

#### Storage Types
- **Block Storage**: Like a hard drive (AWS EBS, Azure Disks)
- **Object Storage**: For files and blobs (AWS S3, Azure Blob Storage)
- **File Storage**: Network file systems (AWS EFS, Azure Files)

#### Load Balancer
Distributes traffic across multiple servers for reliability and performance.

#### Auto Scaling
Automatically adjusts resources based on demand.

#### Region and Availability Zone
- **Region**: Geographic location (us-east-1, eu-west-1)
- **Availability Zone (AZ)**: Isolated data center within a region

### AWS Basics

**Common Services**:
- **EC2**: Virtual servers
- **S3**: Object storage
- **RDS**: Managed databases
- **Lambda**: Serverless functions
- **VPC**: Virtual private network
- **IAM**: Identity and access management
- **CloudWatch**: Monitoring and logs
- **Route 53**: DNS service

### Cloud CLI Examples

```bash
# AWS CLI
aws s3 ls                              # List S3 buckets
aws ec2 describe-instances             # List EC2 instances
aws s3 cp file.txt s3://bucket/        # Upload to S3

# DigitalOcean CLI (doctl)
doctl compute droplet list             # List droplets
doctl compute droplet create name      # Create droplet

# Google Cloud CLI (gcloud)
gcloud compute instances list          # List instances
gcloud compute instances create name   # Create instance
```

---

## DevOps Fundamentals

### What is DevOps?

**DevOps**: Culture and practices combining Development and Operations to deliver software faster and more reliably.

### Key Principles

1. **Automation**: Automate repetitive tasks
2. **Continuous Integration (CI)**: Frequently merge code changes
3. **Continuous Deployment (CD)**: Automatically deploy code to production
4. **Infrastructure as Code (IaC)**: Manage infrastructure through code
5. **Monitoring and Logging**: Track system health and issues
6. **Collaboration**: Break down silos between teams

### CI/CD Pipeline

**Continuous Integration/Continuous Deployment**: Automated workflow from code to production.

**Typical Pipeline Stages**:
1. **Code**: Developer pushes code
2. **Build**: Compile/package application
3. **Test**: Run automated tests
4. **Deploy**: Deploy to staging/production
5. **Monitor**: Track performance and errors

**Popular CI/CD Tools**:
- GitHub Actions
- GitLab CI/CD
- Jenkins
- CircleCI
- Travis CI

### Infrastructure as Code (IaC)

Managing infrastructure through configuration files instead of manual processes.

**Popular IaC Tools**:
- **Terraform**: Multi-cloud infrastructure provisioning
- **Ansible**: Configuration management and automation
- **CloudFormation**: AWS-specific IaC
- **Pulumi**: IaC using programming languages

**Example Terraform**:
```hcl
resource "aws_instance" "web" {
  ami           = "ami-0c55b159cbfafe1f0"
  instance_type = "t2.micro"

  tags = {
    Name = "WebServer"
  }
}
```

### Containers and Orchestration

#### Docker Basics

```bash
# Images
docker images                          # List images
docker pull nginx                      # Download image
docker build -t myapp .                # Build image from Dockerfile

# Containers
docker ps                              # List running containers
docker ps -a                           # List all containers
docker run -d -p 80:80 nginx           # Run container
docker stop container_id               # Stop container
docker rm container_id                 # Remove container
docker logs container_id               # View logs
docker exec -it container_id bash      # Access container shell

# System
docker system prune                    # Clean up unused resources
```

**Dockerfile Example**:
```dockerfile
FROM ubuntu:22.04
RUN apt-get update && apt-get install -y nginx
COPY . /var/www/html
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
```

#### Kubernetes Basics

**Key Concepts**:
- **Pod**: Smallest deployable unit (one or more containers)
- **Deployment**: Manages replica sets and updates
- **Service**: Network access to pods
- **Namespace**: Virtual cluster within Kubernetes
- **ConfigMap**: Configuration data
- **Secret**: Sensitive data (passwords, keys)

```bash
# kubectl commands
kubectl get pods                       # List pods
kubectl get services                   # List services
kubectl describe pod pod-name          # Pod details
kubectl logs pod-name                  # View logs
kubectl exec -it pod-name -- bash      # Access pod shell
kubectl apply -f config.yaml           # Apply configuration
kubectl delete pod pod-name            # Delete pod
```

### Configuration Management

**Tools**: Ansible, Puppet, Chef, SaltStack

**Ansible Example** (playbook.yml):
```yaml
---
- hosts: webservers
  tasks:
    - name: Install nginx
      apt:
        name: nginx
        state: present
    - name: Start nginx
      service:
        name: nginx
        state: started
```

---

## Security Basics

### Authentication vs Authorization

- **Authentication**: Verifying identity ("Who are you?")
- **Authorization**: Verifying permissions ("What can you do?")

### SSH (Secure Shell)

Secure protocol for remote access to servers.

```bash
# Connect to server
ssh username@hostname

# Connect with specific key
ssh -i ~/.ssh/private_key username@hostname

# Copy files securely
scp file.txt username@hostname:/path/
scp -r folder/ username@hostname:/path/

# Generate SSH key pair
ssh-keygen -t rsa -b 4096 -C "your@email.com"

# Copy public key to server
ssh-copy-id username@hostname
```

### SSL/TLS

Encryption protocols for secure communication (HTTPS).

- **Certificate**: Digital document proving identity
- **Let's Encrypt**: Free SSL certificates
- **Self-signed Certificate**: For testing/internal use

### Firewalls

Controls incoming/outgoing network traffic based on rules.

```bash
# UFW (Ubuntu)
sudo ufw status                        # Check status
sudo ufw allow 22                      # Allow SSH
sudo ufw allow 80/tcp                  # Allow HTTP
sudo ufw enable                        # Enable firewall

# iptables (Linux)
sudo iptables -L                       # List rules
sudo iptables -A INPUT -p tcp --dport 80 -j ACCEPT
```

### Common Security Practices

1. **Use strong passwords**: 12+ characters, mixed case, numbers, symbols
2. **Enable MFA (Multi-Factor Authentication)**: Second verification layer
3. **Principle of Least Privilege**: Grant minimum necessary permissions
4. **Keep systems updated**: Regularly apply security patches
5. **Use SSH keys**: More secure than passwords
6. **Encrypt sensitive data**: Both in transit and at rest
7. **Regular backups**: Protect against data loss
8. **Monitor logs**: Detect suspicious activity

---

## Troubleshooting Methodology

### Systematic Approach

1. **Identify the problem**: What exactly is wrong?
2. **Gather information**: Error messages, logs, recent changes
3. **Establish a theory**: What might be causing it?
4. **Test the theory**: Verify your hypothesis
5. **Plan of action**: Decide on fix and potential impact
6. **Implement solution**: Apply the fix
7. **Verify functionality**: Confirm problem is resolved
8. **Document**: Record issue and solution

### Diagnostic Questions

- When did the problem start?
- What changed recently?
- Can you reproduce the issue?
- Does it affect one user or everyone?
- Are there any error messages?
- What have you tried already?

### Common Diagnostic Commands

```bash
# System resources
top                    # CPU and memory usage
df -h                  # Disk space
free -m                # Memory details
iostat                 # Disk I/O statistics

# Network
ping hostname          # Test connectivity
netstat -tulpn         # Active connections
ss -tulpn              # Socket statistics
tcpdump                # Packet capture

# Logs
tail -f /var/log/syslog              # System log (Debian/Ubuntu)
tail -f /var/log/messages            # System log (RHEL/CentOS)
journalctl -f                        # Systemd journal
grep error /var/log/apache2/error.log

# Services
systemctl status servicename         # Check service status
systemctl restart servicename        # Restart service
systemctl enable servicename         # Enable at boot

# Disk issues
du -sh /*              # Find large directories
lsof | grep deleted    # Find deleted files still open
```

---

## Common Tools

### Text Editors

#### Terminal-based
- **nano**: Beginner-friendly, simple
- **vim**: Powerful, steep learning curve
- **vi**: Minimal version of vim (always available)

```bash
# nano
nano filename          # Edit file
Ctrl+O                 # Save
Ctrl+X                 # Exit

# vim
vim filename           # Edit file
i                      # Insert mode
Esc                    # Command mode
:w                     # Save
:q                     # Quit
:wq                    # Save and quit
:q!                    # Quit without saving
```

#### GUI-based
- VS Code
- Sublime Text
- Atom

### Remote Access

- **SSH**: Command-line access
- **RDP**: Windows remote desktop
- **VNC**: Cross-platform desktop sharing
- **TeamViewer/AnyDesk**: Easy remote support

### Monitoring and Logging

- **Prometheus**: Metrics collection
- **Grafana**: Visualization and dashboards
- **ELK Stack**: Elasticsearch, Logstash, Kibana (log management)
- **Datadog**: Comprehensive monitoring platform
- **New Relic**: Application performance monitoring

### Collaboration

- **Slack**: Team communication
- **Jira**: Issue and project tracking
- **Confluence**: Documentation
- **PagerDuty**: Incident management
- **Zoom/Teams**: Video conferencing

---

## Essential Terminology

### General IT

- **API (Application Programming Interface)**: Way for programs to communicate
- **Bandwidth**: Data transfer capacity
- **Latency**: Time delay in data transmission
- **Throughput**: Actual data transfer rate
- **Uptime**: Time system is operational
- **Downtime**: Time system is unavailable
- **SLA (Service Level Agreement)**: Guaranteed service quality
- **Backup**: Copy of data for recovery
- **Restore**: Recovering data from backup
- **Snapshot**: Point-in-time copy of system/data

### Development

- **Repository**: Storage location for code
- **Dependency**: External code/library required by application
- **Environment**: Specific configuration (dev, staging, production)
- **Deployment**: Process of releasing code to environment
- **Rollback**: Reverting to previous version
- **Hotfix**: Quick fix for critical issue
- **Release**: Specific version deployed to production
- **Artifact**: Build output (compiled code, packages)

### Networking

- **Packet**: Unit of data transmitted over network
- **Protocol**: Rules for data communication
- **Proxy**: Intermediary server between client and destination
- **VPN (Virtual Private Network)**: Encrypted network connection
- **NAT (Network Address Translation)**: Translating private IPs to public
- **CDN (Content Delivery Network)**: Distributed servers for content delivery

### Cloud

- **Provisioning**: Allocating resources
- **Elasticity**: Ability to scale resources dynamically
- **Multi-tenancy**: Multiple customers sharing infrastructure
- **Serverless**: Running code without managing servers
- **Edge Computing**: Processing data near source

### DevOps

- **Pipeline**: Automated workflow
- **Build**: Converting source code to executable
- **Orchestration**: Coordinating multiple automated tasks
- **Provisioning**: Setting up infrastructure
- **Configuration Management**: Maintaining system settings
- **Immutable Infrastructure**: Never modify, only replace

---

## Learning Resources

### Practice Platforms

- **Linux**: Set up Ubuntu VM or use WSL (Windows Subsystem for Linux)
- **Cloud**: Free tiers on AWS, GCP, Azure
- **Containers**: Docker Desktop
- **Labs**: TryHackMe, HackTheBox (security), KodeKloud (DevOps)

### Documentation

- **Man Pages**: `man command` for detailed documentation
- **Official Docs**: Always check official documentation
- **Stack Overflow**: Community Q&A
- **GitHub**: Example projects and code

### Best Practices

1. **Hands-on practice**: Theory is important, but practice is essential
2. **Break things**: Learn by fixing errors (in safe environments)
3. **Read logs**: They contain valuable troubleshooting information
4. **Google effectively**: Use specific error messages and keywords
5. **Document your work**: Keep notes on solutions
6. **Ask questions**: No one knows everything
7. **Stay current**: Technology changes rapidly
8. **Automate**: If you do it twice, automate it

---

## Quick Reference Cheat Sheet

### Most Used Commands

```bash
# Navigation
ls -la, cd, pwd

# Files
cat, less, tail -f, grep, find

# System
top, ps aux, df -h, free -h

# Network
ping, curl, netstat, ss

# Services
systemctl status/start/stop/restart

# Logs
tail -f /var/log/syslog
journalctl -u servicename -f

# Permissions
chmod, chown

# Packages
apt update && apt upgrade      # Debian/Ubuntu
yum update                     # RHEL/CentOS older
dnf update                     # RHEL/CentOS newer
```

### Emergency Commands

```bash
# Disk full
du -sh /* | sort -h                   # Find large dirs
docker system prune -a                # Clean Docker
apt clean                             # Clean package cache

# High CPU/Memory
top                                   # Identify process
kill -9 PID                           # Kill process

# Service issues
systemctl status servicename
journalctl -u servicename -n 50       # Last 50 log lines
systemctl restart servicename

# Network issues
ping 8.8.8.8                          # Test internet
ping gateway_ip                       # Test local network
curl -I https://website.com           # Test web service
```

---

## Conclusion

This guide covers the fundamentals needed to begin working in IT tech support, cloud computing, and DevOps. Remember that learning IT is an ongoing process—technology evolves rapidly, and continuous learning is essential.

**Next Steps**:
1. Set up a Linux environment (VM or WSL)
2. Practice command-line basics daily
3. Create a GitHub account and learn Git
4. Sign up for cloud free tiers and experiment
5. Build small projects to apply knowledge
6. Join IT communities and forums
7. Consider certifications (CompTIA A+, Linux+, AWS Certified Cloud Practitioner)

**Key Takeaway**: Don't try to memorize everything. Focus on understanding concepts and knowing where to find information when needed. Use this guide as a reference to return to as you grow in your IT career.