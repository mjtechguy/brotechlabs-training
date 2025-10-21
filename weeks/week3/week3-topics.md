# Week 3: Infrastructure Automation - From Manual to Automated Deployment

## Overview

Week 3 builds directly on Week 2's manual deployment, teaching you how to automate the entire server setup process. You'll learn about cloud-init, bash scripting, and infrastructure automation - transforming hours of manual work into a single automated deployment.

**The Journey:**
- **Week 2**: You manually ran each command, installed Docker, configured containers
- **Week 3**: You'll automate ALL of those steps into repeatable scripts

By the end of this week, you'll deploy a fully configured server (Docker, Nginx Proxy Manager, Code-Server, SSL certificates) with just a few clicks and one script execution.

---

## Learning Objectives

By completing Week 3, you will:

- ✅ Understand what automation is and why it matters
- ✅ Master cloud-init for server initialization
- ✅ Write bash scripts to automate complex tasks
- ✅ Deploy infrastructure with one command instead of dozens
- ✅ Understand Infrastructure as Code (IaC) principles
- ✅ Debug and troubleshoot automation scripts
- ✅ Implement idempotent operations (can run multiple times safely)
- ✅ Use variables, functions, and error handling in bash
- ✅ Automate Docker installation and configuration
- ✅ Deploy Nginx Proxy Manager and Code-Server automatically
- ✅ Set up SSL/TLS certificates programmatically
- ✅ Create reusable, maintainable deployment scripts

---

## The Automation Journey

### Week 2 (Manual) vs Week 3 (Automated)

**Week 2 Manual Process:**
```
1. Create Hetzner server (manual)
2. SSH into server
3. Update system packages (apt update, apt upgrade)
4. Install prerequisites
5. Add Docker's GPG key
6. Add Docker repository
7. Install Docker
8. Install Docker Compose
9. Create directories
10. Create docker-compose.yml file
11. Start Nginx Proxy Manager
12. Configure NPM through web UI
13. Create DNS records (manual)
14. Deploy Code-Server
15. Configure proxy rules
16. Request SSL certificates
17. Test everything

Total Time: 2-3 hours
Commands Executed: 50+
Files Created: Multiple
Potential for Errors: High
```

**Week 3 Automated Process:**
```
1. Create Hetzner server with cloud-init (manual)
   └─ Cloud-init automatically:
      - Updates system
      - Installs Docker
      - Configures firewall
      - Creates users
      - Sets up monitoring

2. Configure DNS (manual)

3. Run automation script (one command)
   └─ Script automatically:
      - Deploys Nginx Proxy Manager
      - Deploys Code-Server
      - Configures services
      - Sets up SSL
      - Verifies deployment

Total Time: 15-20 minutes
Commands Executed: 1 (plus server creation)
Files Created: Automatically
Potential for Errors: Low (tested, repeatable)
```

---

## Project Architecture

### What We're Building (Same Infrastructure, Automated)

```
┌────────────────────────────────────────────────────────┐
│              AUTOMATED DEPLOYMENT                       │
└────────────────────────────────────────────────────────┘
                         │
         ┌───────────────┴────────────────┐
         │                                │
    CLOUD-INIT                     BASH SCRIPT
   (Server Init)              (Application Deployment)
         │                                │
         ├─ System Updates                ├─ Docker Compose Files
         ├─ Install Docker                ├─ Service Configuration
         ├─ Configure Firewall            ├─ SSL Certificate Setup
         ├─ Create Users                  ├─ Health Checks
         ├─ Set Timezone                  └─ Verification
         └─ Install Base Packages
                         │
         ┌───────────────┴────────────────┐
         │                                │
   NGINX PROXY MANAGER              CODE-SERVER
   (Automated Deploy)              (Automated Deploy)
         │                                │
         └────────────┬───────────────────┘
                      │
                  SAME RESULT
              (But Automated!)
```

### Key Components

1. **Cloud-Init Configuration**
   - YAML file executed at server boot
   - Handles OS-level setup
   - One-time initialization
   - Industry standard (AWS, Google Cloud, Azure, Hetzner)

2. **Bash Automation Script**
   - Deploys applications
   - Configures services
   - Can be re-run safely (idempotent)
   - Version-controlled and reusable

3. **Infrastructure as Code (IaC)**
   - Configuration defined in files
   - Reproducible deployments
   - Version controlled
   - Documented by default

---

## Topic 1: Introduction to Automation

### What is Automation?

**Automation** = Using scripts, tools, and processes to perform tasks without manual intervention

**Simple Definition:**
- **Manual**: You type each command, click each button
- **Automated**: Script does it for you, reliably, every time

### Why Automate?

**1. Time Savings**
- Manual deployment: 2-3 hours
- Automated deployment: 15-20 minutes
- Deploy 10 servers manually: 20-30 hours
- Deploy 10 servers automated: 2-3 hours (mostly waiting for cloud-init)

**2. Consistency**
- Humans make typos and forget steps
- Scripts execute the same way every time
- No configuration drift between servers
- Guaranteed identical environments

**3. Documentation**
- Scripts document the deployment process
- New team members can read the script
- No "tribal knowledge" lost when people leave
- Self-documenting infrastructure

**4. Reproducibility**
- Deploy to dev, staging, production identically
- Disaster recovery: spin up new server quickly
- Testing: create temporary environments easily
- Scaling: add capacity rapidly

**5. Error Reduction**
- Scripts handle edge cases
- Error checking built in
- Rollback capabilities
- Tested and refined over time

**6. Scaling**
- Deploy 1 server or 100 servers with same effort
- Parallel deployments
- Consistent at any scale

### Real-World Example

**Manual Process (Prone to Error):**
```bash
# You type this... but maybe you forget one step
apt update
# Oh wait, was it apt-get or apt?
apt upgrade -y
# Did I already add the Docker repository?
apt install docker.io
# Wait, that's the wrong package!
apt remove docker.io
# Let me start over...
```

**Automated Process (Reliable):**
```bash
# Run once, works every time
./deploy-infrastructure.sh
```

The script:
- Checks if steps are already done
- Uses correct package names
- Handles errors gracefully
- Logs everything
- Verifies success

### Automation in the Real World

**Companies Saving Time:**
- Netflix: Deploys 1000+ servers daily (automated)
- Spotify: Infrastructure changes in minutes (Terraform)
- GitHub: Automated deployments 100+ times per day

**Without Automation:**
- Manual deployment of 100 servers: ~200-300 hours
- With automation: ~2-3 hours

**That's 99% time savings!**

### The Automation Mindset

**Before Automation:**
"I need to set up a server. Let me follow the manual steps..."

**After Automation:**
"I need to set up a server. Let me run the script!"

**Key Principle:**
> "If you do it twice, automate it."

---

## Topic 2: Cloud-Init - Automated Server Initialization

### What is Cloud-Init?

**Cloud-Init** = Industry-standard tool for automatic configuration of cloud servers at first boot

**Think of it as:**
- The "setup wizard" for servers
- Runs ONCE when server first boots
- Configured with a YAML file called "user data"
- Supported by ALL major cloud providers

**Who Uses Cloud-Init?**
- Amazon Web Services (AWS)
- Google Cloud Platform (GCP)
- Microsoft Azure
- DigitalOcean
- Hetzner Cloud
- And dozens more...

### How Cloud-Init Works

**The Boot Process:**

```
1. Hetzner creates your server
          ↓
2. Ubuntu starts booting
          ↓
3. Cloud-init starts (very early in boot)
          ↓
4. Cloud-init reads your YAML configuration
          ↓
5. Cloud-init executes your instructions:
   - Update packages
   - Install software
   - Create users
   - Configure SSH
   - Run scripts
   - Set hostname
   - Configure network
   - Whatever you specified!
          ↓
6. System finishes booting
          ↓
7. Your server is ready with everything configured!
```

**Timing:**
- Runs automatically on FIRST BOOT only
- You never manually trigger it
- Completes before you first SSH in
- Server is "ready to go" when you connect

### Cloud-Init Configuration (YAML)

**YAML** = YAML Ain't Markup Language (recursive acronym!)
- Human-readable data format
- Uses indentation (like Python)
- Key-value pairs
- Lists and nested structures

**Basic YAML Syntax:**

```yaml
# Comments start with hash/pound sign
# This is a key-value pair
key: value

# This is a list
fruits:
  - apple
  - banana
  - orange

# This is a nested structure
person:
  name: John
  age: 30
  hobbies:
    - coding
    - hiking
```

**IMPORTANT:** YAML is indentation-sensitive!
- Use spaces, NOT tabs
- 2 spaces per indentation level (standard)
- Wrong indentation = syntax errors

### Cloud-Init Modules (What You Can Do)

Cloud-init has many "modules" for different tasks:

#### 1. Package Management
```yaml
packages:
  - docker.io
  - git
  - htop
  - ufw

package_update: true
package_upgrade: true
```

**What this does:**
- Updates package lists (`apt update`)
- Upgrades all packages (`apt upgrade`)
- Installs specified packages

#### 2. User Management
```yaml
users:
  - name: deploy
    groups: sudo, docker
    shell: /bin/bash
    sudo: 'ALL=(ALL) NOPASSWD:ALL'
    ssh_authorized_keys:
      - ssh-rsa AAAAB3N... your-public-key
```

**What this does:**
- Creates user "deploy"
- Adds to sudo and docker groups
- Sets bash as shell
- Allows passwordless sudo
- Adds SSH public key (for login)

#### 3. File Creation
```yaml
write_files:
  - path: /etc/docker/daemon.json
    content: |
      {
        "log-driver": "json-file",
        "log-opts": {
          "max-size": "10m",
          "max-file": "3"
        }
      }
    permissions: '0644'
```

**What this does:**
- Creates file at specified path
- Writes content to file
- Sets file permissions

#### 4. Running Commands
```yaml
runcmd:
  - systemctl enable docker
  - systemctl start docker
  - docker network create web_network
  - echo "Setup complete!" > /root/setup.log
```

**What this does:**
- Executes commands in order
- Runs after all other modules
- Uses /bin/sh by default

#### 5. Firewall Configuration
```yaml
runcmd:
  - ufw default deny incoming
  - ufw default allow outgoing
  - ufw allow 22/tcp
  - ufw allow 80/tcp
  - ufw allow 443/tcp
  - ufw --force enable
```

**What this does:**
- Configures UFW (Uncomplicated Firewall)
- Denies all incoming by default
- Allows outgoing
- Opens specific ports (SSH, HTTP, HTTPS)
- Enables firewall

### Complete Cloud-Init Example

```yaml
#cloud-config

# This tells cloud-init the file is in cloud-config format
# MUST be first line

# Update and upgrade packages
package_update: true
package_upgrade: true
package_reboot_if_required: true

# Install packages
packages:
  - apt-transport-https
  - ca-certificates
  - curl
  - gnupg
  - lsb-release
  - docker.io
  - docker-compose
  - git
  - htop
  - ufw
  - fail2ban

# Set timezone
timezone: America/New_York

# Create admin user
users:
  - name: admin
    groups: sudo, docker
    shell: /bin/bash
    sudo: 'ALL=(ALL) NOPASSWD:ALL'
    ssh_authorized_keys:
      - ssh-rsa AAAAB3NzaC1yc2E... your-key-here

# Configure Docker
write_files:
  - path: /etc/docker/daemon.json
    content: |
      {
        "log-driver": "json-file",
        "log-opts": {
          "max-size": "10m",
          "max-file": "3"
        }
      }
    permissions: '0644'

# Run commands after everything else
runcmd:
  # Start and enable Docker
  - systemctl enable docker
  - systemctl start docker

  # Configure firewall
  - ufw default deny incoming
  - ufw default allow outgoing
  - ufw allow 22/tcp
  - ufw allow 80/tcp
  - ufw allow 443/tcp
  - ufw --force enable

  # Create Docker network
  - docker network create web_network || true

  # Log completion
  - echo "Cloud-init completed at $(date)" > /root/cloud-init-complete.log

# Optional: send status email (requires mail setup)
# phone_home:
#   url: https://your-webhook-url.com
#   post: all

# Final message
final_message: "Server initialization complete! Time: $UPTIME"
```

### Using Cloud-Init with Hetzner

**Step 1: Prepare Cloud-Init File**
- Create file named `cloud-config.yaml`
- Write your configuration
- Test syntax (we'll show you how)

**Step 2: Create Server with Cloud-Init**

**Via Hetzner Web Console:**
1. Click "Add Server"
2. Choose location, type, image (Ubuntu 22.04)
3. Scroll to "Cloud config"
4. Paste your cloud-init YAML
5. Create server

**Via Hetzner CLI:**
```bash
hcloud server create \
  --name my-server \
  --type cx11 \
  --image ubuntu-22.04 \
  --user-data-from-file cloud-config.yaml
```

**Step 3: Wait for Initialization**
- Server boots (30-60 seconds)
- Cloud-init runs (1-5 minutes depending on tasks)
- You can SSH in once it's done

**Step 4: Verify Cloud-Init Completed**

```bash
# Check cloud-init status
cloud-init status

# Output should be: "status: done"

# View cloud-init log
cat /var/log/cloud-init-output.log

# Check if your user was created
id admin

# Check if Docker is running
systemctl status docker
```

### Cloud-Init Best Practices

**1. Start Simple, Add Gradually**
```yaml
# First attempt: just update packages
#cloud-config
package_update: true
package_upgrade: true

# Works? Add more:
packages:
  - docker.io

# Works? Add more:
users:
  - name: admin
    # ... configuration
```

**2. Test Locally First**

You can test cloud-init without deploying:

```bash
# Install cloud-init locally
sudo apt install cloud-init

# Validate YAML syntax
cloud-init schema --config-file cloud-config.yaml

# Run in "dry-run" mode (simulate)
sudo cloud-init clean --logs --seed
sudo cloud-init init --local
```

**3. Use Comments Liberally**

```yaml
#cloud-config

# System Updates (runs first)
package_update: true  # apt update
package_upgrade: true  # apt upgrade -y

# Install Docker and tools
packages:
  - docker.io       # Container runtime
  - docker-compose  # Multi-container management
  - htop            # System monitor (nice to have)
```

**4. Handle Errors Gracefully**

```yaml
runcmd:
  # || true means "don't fail if this fails"
  - docker network create web_network || true

  # Check if directory exists before creating
  - '[ -d /opt/apps ] || mkdir -p /opt/apps'
```

**5. Log Everything**

```yaml
runcmd:
  # Redirect output to log file
  - docker network create web_network 2>&1 | tee -a /root/setup.log

  # Final timestamp
  - echo "Setup completed at $(date)" >> /root/setup.log
```

**6. Security Considerations**

**WARNING:** Cloud-init files can contain sensitive data!

```yaml
# BAD: Don't put passwords in cloud-init
users:
  - name: admin
    password: MyPassword123  # ❌ EVERYONE can see this!

# GOOD: Use SSH keys instead
users:
  - name: admin
    ssh_authorized_keys:
      - ssh-rsa AAAAB3...  # ✅ Public key is safe
```

**Remember:**
- Cloud-init config is visible to all users on the system
- Don't include passwords, API keys, or secrets
- Use SSH keys for authentication
- Use secret management tools for sensitive data

### Common Cloud-Init Pitfalls

**1. YAML Indentation Errors**

```yaml
# WRONG (tabs used)
packages:
	- docker.io  # ❌ Tab character

# RIGHT (spaces used)
packages:
  - docker.io  # ✅ 2 spaces
```

**2. Missing #cloud-config Header**

```yaml
# WRONG
package_update: true

# RIGHT
#cloud-config
package_update: true
```

**3. Wrong Module Order**

Cloud-init runs modules in a specific order:
1. bootcmd (very early)
2. write_files
3. users
4. packages
5. runcmd (very late)

```yaml
# This works because order is correct
#cloud-config
write_files:  # Runs first
  - path: /etc/file
packages:    # Runs second
  - docker.io
runcmd:      # Runs last
  - docker --version  # Docker is already installed
```

**4. Not Checking Status**

Always verify cloud-init completed:

```bash
# After SSH'ing in
cloud-init status --wait

# If you see "status: done" you're good!
# If you see "status: running" wait a bit more
# If you see "status: error" check logs:
cat /var/log/cloud-init-output.log
```

---

## Topic 3: Bash Scripting for Automation

### What is Bash?

**Bash** = Bourne Again Shell
- Command interpreter for Linux/Unix
- Both interactive (terminal) and scripting language
- Default shell on most Linux systems
- Incredibly powerful for automation

**You've already been using Bash!**
```bash
ls -la                    # Bash command
cd /home/user            # Bash command
sudo apt update          # Bash command
```

**Bash Script** = Text file containing Bash commands
- Extension: `.sh` (convention, not required)
- Executable with `chmod +x script.sh`
- Run with `./script.sh` or `bash script.sh`

### Your First Bash Script

**Create file:** `hello.sh`

```bash
#!/bin/bash

# This is a comment
echo "Hello, World!"
echo "Today is $(date)"
echo "I am running on $(hostname)"
```

**Breaking it down:**

**Line 1:** `#!/bin/bash`
- Called a "shebang" or "hashbang"
- Tells the system: "use bash to run this file"
- MUST be the first line
- `#!` = shebang
- `/bin/bash` = path to bash interpreter

**Line 3:** `# This is a comment`
- Lines starting with `#` (except shebang) are comments
- Ignored by bash
- Used for documentation

**Line 4-6:** `echo` commands
- `echo` prints text to terminal
- `$(command)` runs command and inserts output
- `$(date)` gets current date/time
- `$(hostname)` gets server name

**Make executable and run:**

```bash
# Make script executable
chmod +x hello.sh

# Run it
./hello.sh

# Output:
# Hello, World!
# Today is Sun Oct 20 15:30:00 EDT 2025
# I am running on my-server
```

### Bash Script Variables

Variables store data you can reuse:

```bash
#!/bin/bash

# Define variables (no spaces around =!)
NAME="John"
AGE=30
SERVER_IP="192.168.1.100"

# Use variables with $ prefix
echo "Name: $NAME"
echo "Age: $AGE"
echo "Server: $SERVER_IP"

# Variables in strings
echo "Hello, my name is $NAME and I am $AGE years old"

# Math with variables
NEXT_YEAR=$((AGE + 1))
echo "Next year I'll be $NEXT_YEAR"
```

**Variable Naming Rules:**
- Start with letter or underscore
- Can contain letters, numbers, underscores
- NO spaces around `=`
- Convention: UPPERCASE for constants, lowercase for local

**Examples:**
```bash
# CORRECT
SERVER_NAME="web-01"
port=8080
_temp_file="/tmp/data"

# WRONG
SERVER NAME="web-01"    # Space in name (error!)
server-name="web-01"    # Hyphen not allowed (error!)
port = 8080             # Spaces around = (error!)
```

### Bash Script Functions

Functions are reusable blocks of code:

```bash
#!/bin/bash

# Define a function
print_header() {
    echo "================================"
    echo "  $1"
    echo "================================"
}

install_package() {
    local package_name=$1
    echo "Installing $package_name..."
    apt install -y $package_name
}

# Call functions
print_header "System Setup"
install_package "docker.io"
install_package "git"

print_header "Setup Complete"
```

**Breaking it down:**

**Define function:**
```bash
function_name() {
    # code here
}
```

**Function parameters:**
- `$1` = first parameter
- `$2` = second parameter
- `$@` = all parameters
- `$#` = number of parameters

**Local variables:**
```bash
local variable_name=value
```
- Only exists inside function
- Doesn't affect outside variables

### Conditional Statements (if/else)

Make decisions in your scripts:

```bash
#!/bin/bash

# Check if Docker is installed
if command -v docker &> /dev/null; then
    echo "Docker is installed"
    docker --version
else
    echo "Docker is NOT installed"
    echo "Installing Docker..."
    apt install -y docker.io
fi
```

**If statement syntax:**

```bash
if [ condition ]; then
    # code if condition is true
elif [ other_condition ]; then
    # code if other_condition is true
else
    # code if all conditions are false
fi
```

**Common conditions:**

```bash
# File checks
if [ -f /path/to/file ]; then     # File exists
if [ -d /path/to/dir ]; then      # Directory exists
if [ -x /path/to/file ]; then     # File is executable

# String checks
if [ "$VAR" = "value" ]; then     # Strings are equal
if [ -z "$VAR" ]; then            # String is empty
if [ -n "$VAR" ]; then            # String is not empty

# Number checks
if [ $NUM -eq 5 ]; then           # Equal to
if [ $NUM -ne 5 ]; then           # Not equal to
if [ $NUM -gt 5 ]; then           # Greater than
if [ $NUM -lt 5 ]; then           # Less than

# Command success
if command; then                   # Command succeeded
if ! command; then                 # Command failed
```

**Real example:**

```bash
#!/bin/bash

# Check if running as root
if [ "$EUID" -ne 0 ]; then
    echo "ERROR: This script must be run as root"
    echo "Please run: sudo $0"
    exit 1
fi

# Check if Docker is already installed
if command -v docker &> /dev/null; then
    echo "Docker is already installed: $(docker --version)"
else
    echo "Installing Docker..."
    apt update
    apt install -y docker.io
fi
```

### Loops

Repeat actions:

**For loop (iterate over list):**

```bash
#!/bin/bash

# Loop over list of items
for package in docker.io git htop curl; do
    echo "Installing $package..."
    apt install -y $package
done

# Loop over files
for file in /etc/*.conf; do
    echo "Found config: $file"
done

# Loop over numbers
for i in {1..5}; do
    echo "Iteration $i"
done
```

**While loop (repeat while condition true):**

```bash
#!/bin/bash

# Wait for Docker to be ready
while ! docker info &> /dev/null; do
    echo "Waiting for Docker to start..."
    sleep 2
done

echo "Docker is ready!"
```

### Error Handling

**Exit codes:**
- Every command returns an exit code
- `0` = success
- Non-zero (1, 2, etc.) = error
- Check with `$?` variable

```bash
#!/bin/bash

# Try to install package
apt install -y docker.io

# Check if it succeeded
if [ $? -eq 0 ]; then
    echo "Installation successful!"
else
    echo "Installation failed!"
    exit 1
fi
```

**Better way - use set -e:**

```bash
#!/bin/bash

# Exit immediately if any command fails
set -e

# If this fails, script stops
apt update

# If this fails, script stops
apt install -y docker.io

# If this fails, script stops
systemctl start docker

echo "Everything succeeded!"
```

**Print commands as they execute:**

```bash
#!/bin/bash

# Print each command before executing
set -x

# Exit on errors
set -e

# Now you'll see every command
apt update
apt install -y docker.io
```

**Combine them:**

```bash
#!/bin/bash

# Both at once
set -ex

# Or separately
set -e  # Exit on error
set -x  # Print commands
```

### Input and Output

**Read user input:**

```bash
#!/bin/bash

# Prompt for input
read -p "Enter your name: " NAME
read -p "Enter server IP: " SERVER_IP

echo "Hello $NAME! Connecting to $SERVER_IP..."
```

**Redirect output:**

```bash
#!/bin/bash

# Save output to file
echo "Log entry" > logfile.txt          # Overwrites file

# Append to file
echo "Another entry" >> logfile.txt     # Adds to end

# Save both stdout and stderr
command > output.log 2>&1               # All output to file

# Discard output
command > /dev/null 2>&1                # Silent (no output)
```

### Practical Automation Script Example

```bash
#!/bin/bash

################################################################################
# Docker Installation Script
# Automates the installation of Docker and Docker Compose
################################################################################

set -e  # Exit on any error

# Color codes for pretty output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored messages
print_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

# Check if running as root
if [ "$EUID" -ne 0 ]; then
    print_error "This script must be run as root"
    exit 1
fi

print_info "Starting Docker installation..."

# Remove old versions
print_info "Removing old Docker versions if any..."
for pkg in docker.io docker-doc docker-compose podman-docker containerd runc; do
    apt remove -y $pkg 2>/dev/null || true
done

# Update package index
print_info "Updating package index..."
apt update

# Install prerequisites
print_info "Installing prerequisites..."
apt install -y \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg \
    lsb-release

# Add Docker's official GPG key
print_info "Adding Docker GPG key..."
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | \
    gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

# Add Docker repository
print_info "Adding Docker repository..."
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] \
  https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | \
  tee /etc/apt/sources.list.d/docker.list > /dev/null

# Install Docker
print_info "Installing Docker Engine..."
apt update
apt install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin

# Start and enable Docker
print_info "Starting Docker service..."
systemctl enable docker
systemctl start docker

# Verify installation
if docker --version &> /dev/null; then
    print_info "Docker installed successfully: $(docker --version)"
else
    print_error "Docker installation failed"
    exit 1
fi

# Create Docker network
print_info "Creating Docker network..."
docker network create web_network 2>/dev/null || print_warning "Network already exists"

print_info "Docker installation complete!"
```

---

## Topic 4: Combining Cloud-Init and Bash Scripts

### The Perfect Partnership

**Cloud-Init** = OS-level setup (runs once at boot)
**Bash Script** = Application deployment (can run multiple times)

**Why Both?**

**Cloud-Init is for:**
- System updates
- User creation
- Package installation
- Firewall setup
- SSH configuration
- One-time initialization

**Bash Scripts are for:**
- Deploying applications
- Configuring services
- Tasks that might be repeated
- Complex logic
- Re-running after changes

**Example Strategy:**

**Cloud-Init (user-data.yaml):**
```yaml
#cloud-config
package_update: true
package_upgrade: true

packages:
  - docker.io
  - docker-compose
  - git
  - curl

users:
  - name: deploy
    groups: sudo, docker
    shell: /bin/bash
    sudo: 'ALL=(ALL) NOPASSWD:ALL'

runcmd:
  - systemctl enable docker
  - systemctl start docker
  - docker network create web_network || true
```

**Bash Script (deploy-apps.sh):**
```bash
#!/bin/bash

# Deploy Nginx Proxy Manager
docker compose -f /opt/npm/docker-compose.yml up -d

# Deploy Code-Server
docker compose -f /opt/code-server/docker-compose.yml up -d

# Wait for services
sleep 10

# Verify everything is running
docker ps
```

**Workflow:**
1. Create server with cloud-init → OS ready
2. SSH in (system already configured!)
3. Run bash script → Applications deployed
4. Done!

---

## Week 3 Lab Structure

### Lab 1: Introduction to Automation Concepts
**File:** `01-intro-to-automation.md`
- Understanding automation vs manual
- When to automate
- Automation best practices
- Reading existing scripts

**Duration:** 30 minutes (reading/discussion)

### Lab 2: Cloud-Init Deep Dive
**File:** `02-cloud-init-explained.mdcl`
- YAML syntax tutorial
- Cloud-init modules
- Writing your first cloud-config
- Testing cloud-init locally
- Deploying server with cloud-init
- Troubleshooting cloud-init

**Duration:** 90 minutes (hands-on)

**Hands-On:**
- Write simple cloud-config (update + packages)
- Deploy test server
- Verify cloud-init ran
- Iterate and improve

### Lab 3: Bash Scripting Fundamentals
**File:** `03-bash-scripting-deep-dive.mdcl`
- Bash syntax and structure
- Variables and functions
- Conditionals and loops
- Error handling
- Input/output
- Writing reusable functions
- Debugging techniques

**Duration:** 120 minutes (hands-on)

**Hands-On:**
- Write hello world script
- Create system info script
- Build Docker installer script
- Add error handling and logging

### Lab 4: Complete Automated Deployment
**File:** `04-automated-deployment.mdcl`
- Combining cloud-init + bash
- Deploy full Week 2 infrastructure automated
- Cloud-init: system setup
- Bash: application deployment
- One-command deployment
- Verification and testing

**Duration:** 120 minutes (hands-on)

**Hands-On:**
- Create comprehensive cloud-init config
- Write deployment automation script
- Deploy new server with both
- Verify NPM and Code-Server running
- Configure SSL certificates
- Access via HTTPS

---

## Prerequisites

### Knowledge Prerequisites
- Week 1: Basic Linux commands, SSH
- Week 2: Docker, Nginx Proxy Manager, Code-Server
- Understanding of manual deployment process

### Accounts Needed
- Hetzner Cloud account (from Week 1)
- Domain configured in Cloudflare (from Week 2)
- SSH key pair

### Tools Needed
- Text editor (VS Code, nano, vim)
- SSH client
- Web browser

### Cost Estimate
- Hetzner Server: ~$4.50/month (can use existing)
- Domain: Already purchased in Week 2
- **Total Additional Cost: $0**

---

## Skills You'll Gain

### Technical Skills
- ✅ Writing cloud-init configurations
- ✅ YAML syntax and structure
- ✅ Bash scripting fundamentals
- ✅ Variables, functions, loops in bash
- ✅ Error handling and logging
- ✅ Debugging automation scripts
- ✅ Infrastructure as Code (IaC)
- ✅ Idempotent operations
- ✅ Automated deployment workflows
- ✅ Server provisioning

### Conceptual Understanding
- ✅ When and why to automate
- ✅ Trade-offs of automation
- ✅ Cloud-init vs configuration management
- ✅ Declarative vs imperative automation
- ✅ State management
- ✅ Reproducible infrastructure
- ✅ DevOps principles
- ✅ CI/CD foundations

### Practical Applications
- ✅ Deploy servers in minutes not hours
- ✅ Replicate environments exactly
- ✅ Disaster recovery preparation
- ✅ Testing environment creation
- ✅ Scaling infrastructure
- ✅ Documentation through code
- ✅ Team collaboration
- ✅ Reducing human error

---

## Key Takeaways

### Automation Principles

**1. Automation = Time Investment**
- Upfront time to write scripts
- Massive time savings over time
- Break-even after 2-3 uses typically

**2. Start Simple, Iterate**
- Don't try to automate everything at once
- Test each piece
- Add features gradually
- Refine based on failures

**3. Make it Idempotent**
- Safe to run multiple times
- Check current state before acting
- Don't fail if already done

**Example:**
```bash
# BAD (fails if network exists)
docker network create web_network

# GOOD (safe to run multiple times)
docker network create web_network || true

# BETTER (checks first)
if ! docker network ls | grep -q web_network; then
    docker network create web_network
fi
```

**4. Documentation Matters**
- Scripts are self-documenting
- Add comments for complex logic
- Explain WHY not just WHAT

**5. Version Control Everything**
- Keep scripts in git
- Track changes over time
- Collaborate with team
- Rollback if needed

### Cloud-Init Best Practices

**1. Keep it Simple**
- Basic system setup only
- Don't deploy applications
- Use for foundation

**2. Test Before Production**
- Validate YAML syntax
- Test on throwaway servers
- Have backups

**3. Security First**
- No passwords in configs
- Use SSH keys
- Minimal permissions
- Principle of least privilege

**4. Log Everything**
- Cloud-init logs to `/var/log/cloud-init-output.log`
- Check status with `cloud-init status`
- Debug failures systematically

### Bash Scripting Best Practices

**1. Always use shebang**
```bash
#!/bin/bash
```

**2. Enable strict mode**
```bash
set -euo pipefail
# -e: exit on error
# -u: error on undefined variable
# -o pipefail: pipeline fails if any command fails
```

**3. Use functions**
- Break down complex scripts
- Reusable code
- Easier to test

**4. Color your output**
```bash
echo -e "${GREEN}[SUCCESS]${NC} Task completed"
```

**5. Check prerequisites**
```bash
if [ "$EUID" -ne 0 ]; then
    echo "Run as root"
    exit 1
fi
```

---

## Real-World Impact

### Before Automation (Week 2)
```
Time to deploy server: 2-3 hours
Commands to type: 50+
Potential for typos: High
Consistency: Depends on person
Documentation: Manual notes
Scaling: Linear (1x time per server)
Disaster recovery: Slow, manual
Team onboarding: Hours of training
```

### After Automation (Week 3)
```
Time to deploy server: 15-20 minutes
Commands to type: 1-2
Potential for typos: Very low
Consistency: Perfect (same every time)
Documentation: Scripts ARE documentation
Scaling: Sub-linear (same script for any number)
Disaster recovery: Fast, automated
Team onboarding: Read the scripts
```

### By the Numbers

**Time Savings Example:**
- Manual deployment: 3 hours
- Automated deployment: 20 minutes
- Time saved per deployment: 2 hours 40 minutes

**If you deploy:**
- 5 servers: 13 hours saved
- 10 servers: 26 hours saved
- 50 servers: 133 hours saved (3+ weeks!)

**Error Reduction:**
- Manual: ~10-15% chance of configuration error
- Automated: <1% chance (only script bugs, which get fixed once)

---

## Beyond Week 3

### What You Can Build Next

**Week 4 and Beyond:**
- Monitoring stack (Prometheus, Grafana)
- Database clusters (automated)
- Load balancers (automated)
- CI/CD pipelines
- Multi-region deployments
- Kubernetes clusters

### Advanced Automation Tools

Once you master bash and cloud-init:

**Configuration Management:**
- Ansible (our next topic!)
- Puppet
- Chef
- SaltStack

**Infrastructure as Code:**
- Terraform (create servers programmatically)
- Pulumi
- CloudFormation (AWS)

**Container Orchestration:**
- Docker Swarm
- Kubernetes
- Nomad

### Career Applications

**DevOps Engineer:**
- Automation is core skill
- CI/CD pipelines
- Infrastructure management

**Site Reliability Engineer (SRE):**
- Automated incident response
- Self-healing systems
- Capacity planning

**Cloud Architect:**
- Multi-cloud deployments
- Cost optimization
- Scalability

**All IT Roles:**
- Save time on repetitive tasks
- Improve reliability
- Document processes

---

## Additional Resources

### Cloud-Init Resources
- [Official Cloud-Init Documentation](https://cloudinit.readthedocs.io/)
- [Canonical Cloud-Init Tutorial](https://documentation.ubuntu.com/server/explanation/intro-to/cloud-init/)
- [Hetzner Cloud-Init Guide](https://community.hetzner.com/tutorials/basic-cloud-config/)
- [Cloud-Init Examples](https://cloudinit.readthedocs.io/en/latest/topics/examples.html)
- [YAML Syntax Tutorial](https://www.cloudbees.com/blog/yaml-tutorial-everything-you-need-get-started)

### Bash Scripting Resources
- [Bash Guide for Beginners](https://tldp.org/LDP/Bash-Beginners-Guide/html/)
- [Advanced Bash-Scripting Guide](https://tldp.org/LDP/abs/html/)
- [ShellCheck](https://www.shellcheck.net/) - Script validation tool
- [Bash Scripting Tutorial](https://linuxconfig.org/bash-scripting-tutorial-for-beginners)
- [Linux Handbook Bash Tutorial](https://linuxhandbook.com/bash-automation/)

### Automation Best Practices
- [The Art of Automation](https://www.hashicorp.com/resources/automation-best-practices)
- [Infrastructure as Code Principles](https://infrastructure-as-code.com/book/)
- [The Phoenix Project](https://www.goodreads.com/book/show/17255186-the-phoenix-project) - DevOps novel

### Testing and Validation
- [ShellCheck Online](https://www.shellcheck.net/) - Lint your bash scripts
- [YAML Lint](http://www.yamllint.com/) - Validate YAML syntax
- [Bats](https://github.com/bats-core/bats-core) - Bash testing framework

---

## Let's Get Started!

Ready to transform your manual deployment into automated infrastructure?

**Next:** [Lab 1 - Introduction to Automation](./01-intro-to-automation.md)

---

**The power of automation awaits! Let's build something amazing! 🚀**
