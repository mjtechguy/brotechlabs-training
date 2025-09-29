# Part 5: Package and Software Management

## Prerequisites

Before starting this section, you should understand:
- Basic command line navigation
- How to use sudo for administrative tasks
- Basic understanding of software and dependencies
- How to edit text files with nano or vim

**Learning Resources:**
- [Ubuntu Package Management Guide](https://help.ubuntu.com/community/AptGet/Howto)
- [Snap Documentation](https://snapcraft.io/docs)
- [Debian Package Management](https://www.debian.org/doc/manuals/debian-faq/pkg-basics.en.html)
- [Environment Variables Guide](https://help.ubuntu.com/community/EnvironmentVariables)

---

## Chapter 12: APT Package Management

### Understanding Package Management

Package management is how you install, update, and remove software on Ubuntu. APT (Advanced Package Tool) is Ubuntu's primary package management system.

#### What are Packages?

A **package** is a compressed file containing:
- Pre-compiled software
- Configuration files
- Dependencies information
- Installation/removal scripts
- Documentation

Think of packages like smartphone apps - they contain everything needed to run, and the package manager (like an app store) handles installation and updates.

```bash
# View information about a package
apt show nginx

# Output includes:
# Package: nginx
# Version: 1.18.0-0ubuntu1
# Priority: optional
# Section: web
# Origin: Ubuntu
# Depends: nginx-core, nginx-common
# Description: small, powerful, scalable web/proxy server
```

### Repository Management

Repositories are servers that host packages. Ubuntu uses multiple repositories for different types of software.

#### Understanding Repository Types

```bash
# View current repositories
cat /etc/apt/sources.list

# Typical Ubuntu repositories:
# main     - Officially supported free software
# universe - Community-maintained free software
# restricted - Proprietary drivers
# multiverse - Software with copyright/legal restrictions

# Example line from sources.list:
# deb http://archive.ubuntu.com/ubuntu focal main restricted universe multiverse
# deb = binary packages
# http://... = repository URL
# focal = Ubuntu version codename
# main restricted... = components
```

#### Adding Repositories

```bash
# Method 1: Add PPA (Personal Package Archive)
sudo add-apt-repository ppa:ondrej/php
sudo apt update

# Method 2: Add repository manually
# Add Docker repository example
# First, add GPG key
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

# Add repository
echo "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list

# Update package index
sudo apt update

# Method 3: Using sources.list.d
sudo nano /etc/apt/sources.list.d/custom.list
# Add: deb http://repository.example.com/ubuntu focal main

# Remove a PPA
sudo add-apt-repository --remove ppa:ondrej/php
```

#### Managing Repository Priorities

```bash
# Install software-properties-common for repository management
sudo apt install software-properties-common

# List all repositories
apt policy

# Check repository for specific package
apt policy nginx

# Pin repository priority
sudo nano /etc/apt/preferences.d/custom-repo
```

```
# Example pinning configuration
Package: *
Pin: release o=Docker
Pin-Priority: 600

Package: nginx
Pin: version 1.18.*
Pin-Priority: 1000
```

### Package Installation and Removal

#### Installing Packages

```bash
# Update package index first
sudo apt update

# Install a package
sudo apt install nginx

# Install multiple packages
sudo apt install nginx mysql-server php-fpm

# Install specific version
sudo apt install nginx=1.18.0-0ubuntu1

# Install without prompting (-y for yes)
sudo apt install -y htop

# Install and mark as manually installed
sudo apt install --mark-manual package-name

# Simulate installation (dry run)
sudo apt install -s nginx

# Install .deb file directly
sudo dpkg -i package.deb
# Fix dependencies if needed
sudo apt install -f
```

#### Removing Packages

```bash
# Remove package but keep configuration files
sudo apt remove nginx

# Remove package and configuration files
sudo apt purge nginx

# Remove automatically installed dependencies no longer needed
sudo apt autoremove

# Remove package and its dependencies
sudo apt purge --auto-remove nginx

# Clean up package cache
sudo apt clean      # Removes all cached packages
sudo apt autoclean  # Removes only outdated cached packages

# Remove orphaned packages
sudo apt install deborphan
deborphan
sudo apt purge $(deborphan)
```

#### Updating and Upgrading

```bash
# Update package index
sudo apt update

# Show upgradable packages
apt list --upgradable

# Upgrade installed packages
sudo apt upgrade

# Full upgrade (may remove packages)
sudo apt full-upgrade
# or
sudo apt dist-upgrade

# Upgrade specific package
sudo apt install --only-upgrade nginx

# Hold package (prevent upgrades)
sudo apt-mark hold nginx

# Unhold package
sudo apt-mark unhold nginx

# List held packages
apt-mark showhold
```

### Dependency Resolution

Understanding how APT handles dependencies is crucial for troubleshooting.

#### Working with Dependencies

```bash
# Show package dependencies
apt depends nginx

# Show reverse dependencies (what depends on this package)
apt rdepends nginx

# Show why a package is installed
apt why nginx

# Fix broken dependencies
sudo apt install -f
# or
sudo dpkg --configure -a

# Check for broken packages
sudo apt check

# Reconfigure package
sudo dpkg-reconfigure package-name

# Force overwrite files
sudo apt install -o Dpkg::Options::="--force-overwrite" package-name
```

#### Resolving Dependency Conflicts

```bash
# Common dependency issues and solutions

# Issue: Unmet dependencies
# Solution 1: Update and fix
sudo apt update
sudo apt install -f

# Solution 2: Remove problematic package
sudo apt remove problematic-package

# Solution 3: Use aptitude for better resolution
sudo apt install aptitude
sudo aptitude install package-name

# Issue: Held broken packages
# View held packages
dpkg --get-selections | grep hold

# Fix held packages
sudo dpkg --remove --force-remove-reinstreq package-name
sudo apt update
sudo apt install -f
```

### Package Pinning

Package pinning allows you to control which versions of packages are installed from which repositories.

```bash
# Create pinning file
sudo nano /etc/apt/preferences.d/nginx-pinning
```

```
# Pin nginx to specific version
Package: nginx
Pin: version 1.18.*
Pin-Priority: 1001

# Pin all packages from a repository
Package: *
Pin: origin repository.example.com
Pin-Priority: 700

# Priority levels:
# 1000+ : Version will be installed even if it's a downgrade
# 990   : Version from target release
# 500   : Version from default release
# 100   : Version from non-target release
# -1    : Never install this version
```

```bash
# Check package priorities
apt-cache policy nginx

# Test pinning without installing
apt-get install -s nginx
```

### Automatic Updates

Configure automatic security updates to keep your system secure.

#### Configuring Unattended Upgrades

```bash
# Install unattended-upgrades
sudo apt install unattended-upgrades

# Enable automatic updates
sudo dpkg-reconfigure --priority=low unattended-upgrades

# Configure what to update
sudo nano /etc/apt/apt.conf.d/50unattended-upgrades
```

```conf
// Automatically upgrade packages from these origins
Unattended-Upgrade::Allowed-Origins {
    "${distro_id}:${distro_codename}-security";
    "${distro_id}:${distro_codename}-updates";
    // "${distro_id}:${distro_codename}-proposed";
    // "${distro_id}:${distro_codename}-backports";
};

// Auto-remove unused dependencies
Unattended-Upgrade::Remove-Unused-Dependencies "true";

// Automatically reboot if needed
Unattended-Upgrade::Automatic-Reboot "true";
Unattended-Upgrade::Automatic-Reboot-Time "02:00";

// Email notifications
Unattended-Upgrade::Mail "admin@example.com";
```

```bash
# Configure update schedule
sudo nano /etc/apt/apt.conf.d/20auto-upgrades
```

```conf
APT::Periodic::Update-Package-Lists "1";
APT::Periodic::Download-Upgradeable-Packages "1";
APT::Periodic::AutocleanInterval "7";
APT::Periodic::Unattended-Upgrade "1";
```

```bash
# Test configuration
sudo unattended-upgrades --dry-run --debug

# Check logs
sudo tail -f /var/log/unattended-upgrades/unattended-upgrades.log
```

### Building from Source

Sometimes you need to compile software from source code.

#### Prerequisites for Building

```bash
# Install build essentials
sudo apt install build-essential

# Common development packages
sudo apt install \
    automake \
    autoconf \
    libtool \
    pkg-config \
    libssl-dev \
    libcurl4-openssl-dev \
    libxml2-dev \
    libsqlite3-dev \
    cmake \
    git

# Install dependencies for specific package
sudo apt build-dep nginx
```

#### Compilation Process

```bash
# Example: Building nginx from source

# 1. Download source
cd /tmp
wget http://nginx.org/download/nginx-1.21.0.tar.gz
tar -xzvf nginx-1.21.0.tar.gz
cd nginx-1.21.0

# 2. Configure build options
./configure \
    --prefix=/usr/local/nginx \
    --with-http_ssl_module \
    --with-http_v2_module \
    --with-http_realip_module

# 3. Compile
make -j$(nproc)  # Use all CPU cores

# 4. Test (optional)
make test

# 5. Install
sudo make install

# 6. Create systemd service
sudo nano /etc/systemd/system/nginx.service
```

```ini
[Unit]
Description=Nginx Web Server
After=network.target

[Service]
Type=forking
PIDFile=/usr/local/nginx/logs/nginx.pid
ExecStartPre=/usr/local/nginx/sbin/nginx -t
ExecStart=/usr/local/nginx/sbin/nginx
ExecReload=/bin/kill -HUP $MAINPID
ExecStop=/bin/kill -TERM $MAINPID

[Install]
WantedBy=multi-user.target
```

```bash
# Enable and start service
sudo systemctl daemon-reload
sudo systemctl enable nginx
sudo systemctl start nginx
```

#### Using Checkinstall

Checkinstall creates a package from compiled source, making it easier to manage.

```bash
# Install checkinstall
sudo apt install checkinstall

# After compilation, instead of 'make install':
sudo checkinstall

# This creates a .deb package and installs it
# You can now manage it with apt:
apt list --installed | grep nginx
sudo apt remove nginx
```

### Snap Packages

Snap is a universal package format that works across different Linux distributions.

#### Understanding Snaps

Snaps are:
- Self-contained with all dependencies
- Automatically updated
- Sandboxed for security
- Version-controlled with rollback capability

```bash
# Install snapd (usually pre-installed on Ubuntu)
sudo apt install snapd

# Check snap version
snap version

# List installed snaps
snap list

# Search for snaps
snap search vscode

# Get info about a snap
snap info code
```

#### Managing Snaps

```bash
# Install a snap
sudo snap install code --classic

# Install specific channel
sudo snap install node --channel=14/stable --classic

# Update snaps
sudo snap refresh
sudo snap refresh code

# Revert to previous version
sudo snap revert code

# Remove a snap
sudo snap remove code

# List available versions
snap list --all code

# Switch channels
sudo snap switch code --channel=stable

# Hold updates
sudo snap hold code

# Connect interfaces (permissions)
snap connections code
sudo snap connect code:removable-media
```

#### Snap Configuration

```bash
# View snap services
snap services

# Start/stop snap services
sudo snap start service-name
sudo snap stop service-name

# Configure snap
sudo snap set nextcloud ports.http=81

# View configuration
sudo snap get nextcloud

# View snap changes
snap changes

# Abort ongoing change
sudo snap abort 123  # Change ID from 'snap changes'

# Download snap for offline installation
snap download code
# Install offline
sudo snap install ./code_*.snap --dangerous
```

---

## Chapter 13: Software Configuration

### Application Deployment

Deploying applications properly ensures they run reliably and securely.

#### Deployment Best Practices

```bash
# 1. Create dedicated user for application
sudo useradd -r -m -d /var/www/app -s /bin/bash appuser

# 2. Set up application directory structure
sudo mkdir -p /var/www/app/{releases,shared,current}
sudo chown -R appuser:appuser /var/www/app

# 3. Deploy application
sudo -u appuser git clone https://github.com/user/app.git /var/www/app/releases/v1.0.0

# 4. Set up shared resources
sudo -u appuser mkdir -p /var/www/app/shared/{config,log,tmp}

# 5. Create symbolic link to current release
sudo -u appuser ln -sfn /var/www/app/releases/v1.0.0 /var/www/app/current
```

#### Zero-Downtime Deployment

```bash
# Deployment script example
sudo nano /usr/local/bin/deploy-app.sh
```

```bash
#!/bin/bash
# Zero-downtime deployment script

APP_DIR="/var/www/app"
RELEASE_DIR="$APP_DIR/releases/$(date +%Y%m%d%H%M%S)"
REPO="https://github.com/user/app.git"

# Deploy new version
echo "Deploying new version..."
sudo -u appuser git clone $REPO $RELEASE_DIR

# Copy shared configuration
sudo -u appuser ln -sfn $APP_DIR/shared/config $RELEASE_DIR/config
sudo -u appuser ln -sfn $APP_DIR/shared/log $RELEASE_DIR/log

# Install dependencies (example for Node.js)
cd $RELEASE_DIR
sudo -u appuser npm install --production

# Run tests
sudo -u appuser npm test

if [ $? -eq 0 ]; then
    # Update current symlink
    sudo -u appuser ln -sfn $RELEASE_DIR $APP_DIR/current

    # Reload application
    sudo systemctl reload app

    echo "Deployment successful!"

    # Keep only last 5 releases
    cd $APP_DIR/releases
    ls -t | tail -n +6 | xargs rm -rf
else
    echo "Tests failed! Deployment aborted."
    rm -rf $RELEASE_DIR
    exit 1
fi
```

```bash
# Make executable
sudo chmod +x /usr/local/bin/deploy-app.sh
```

### Environment Variables

Environment variables configure application behavior without changing code.

#### System-Wide Environment Variables

```bash
# View all environment variables
env
# or
printenv

# View specific variable
echo $PATH
printenv HOME

# Set system-wide variables
sudo nano /etc/environment
```

```bash
# /etc/environment example
PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
JAVA_HOME="/usr/lib/jvm/java-11-openjdk-amd64"
APP_ENV="production"
```

```bash
# Set in profile (runs for login shells)
sudo nano /etc/profile.d/custom-env.sh
```

```bash
#!/bin/bash
export EDITOR=vim
export HISTSIZE=10000
export HISTFILESIZE=20000
export APP_CONFIG="/etc/app/config.json"
```

#### User-Specific Environment Variables

```bash
# Set in user's bashrc
nano ~/.bashrc
# Add at the end:
export MY_APP_KEY="secret_key_here"
export NODE_ENV="development"

# Apply changes
source ~/.bashrc

# Set in user's profile
nano ~/.profile
# Add:
export PATH="$HOME/.local/bin:$PATH"

# Temporary variable (current session only)
export TEMP_VAR="temporary value"

# Run command with specific environment variable
MY_VAR="value" command

# Example:
NODE_ENV="production" node app.js
```

#### Application-Specific Environment

```bash
# Method 1: Using systemd service
sudo nano /etc/systemd/system/myapp.service
```

```ini
[Unit]
Description=My Application

[Service]
Type=simple
User=appuser
WorkingDirectory=/var/www/app/current
Environment="NODE_ENV=production"
Environment="PORT=3000"
Environment="DB_HOST=localhost"
EnvironmentFile=/etc/myapp/env
ExecStart=/usr/bin/node app.js

[Install]
WantedBy=multi-user.target
```

```bash
# Method 2: Using environment file
sudo nano /etc/myapp/env
```

```bash
# Application environment variables
NODE_ENV=production
PORT=3000
DB_HOST=localhost
DB_USER=appuser
DB_PASS=secretpass
API_KEY=your-api-key-here
LOG_LEVEL=info
```

```bash
# Method 3: Using .env file (with dotenv)
nano /var/www/app/.env
```

```bash
# Development settings
NODE_ENV=development
PORT=3000
DB_CONNECTION=mysql://user:pass@localhost/dbname
REDIS_URL=redis://localhost:6379
SECRET_KEY=your-secret-key
DEBUG=true
```

```bash
# Secure .env file
chmod 600 /var/www/app/.env
chown appuser:appuser /var/www/app/.env
```

### Configuration Management

Managing configuration files effectively is crucial for maintainability.

#### Configuration Structure

```bash
# Organize configuration files
sudo mkdir -p /etc/myapp/{conf.d,ssl,secrets}

# Main configuration
sudo nano /etc/myapp/config.yaml
```

```yaml
# Application configuration
app:
  name: MyApplication
  version: 1.0.0
  port: 3000

database:
  host: localhost
  port: 3306
  name: myapp_db
  pool_size: 10

cache:
  driver: redis
  host: localhost
  port: 6379
  ttl: 3600

logging:
  level: info
  file: /var/log/myapp/app.log
  max_size: 10M
  max_files: 10
```

```bash
# Include additional configs
sudo nano /etc/myapp/conf.d/production.yaml
```

#### Configuration Templates

Using templates allows dynamic configuration generation.

```bash
# Install envsubst (part of gettext)
sudo apt install gettext-base

# Create template
sudo nano /etc/myapp/config.template
```

```bash
# Configuration template
server {
    listen ${PORT};
    server_name ${DOMAIN};

    location / {
        proxy_pass http://${BACKEND_HOST}:${BACKEND_PORT};
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
    }
}
```

```bash
# Generate configuration from template
export PORT=80
export DOMAIN=example.com
export BACKEND_HOST=localhost
export BACKEND_PORT=3000

envsubst < /etc/myapp/config.template > /etc/nginx/sites-available/myapp

# Using with script
sudo nano /usr/local/bin/generate-config.sh
```

```bash
#!/bin/bash
# Generate configuration from environment

# Load environment
source /etc/myapp/env

# Generate configs
envsubst < /etc/myapp/nginx.template > /etc/nginx/sites-available/myapp
envsubst < /etc/myapp/app.template > /etc/myapp/config.json

# Validate configurations
nginx -t
if [ $? -eq 0 ]; then
    systemctl reload nginx
else
    echo "Invalid nginx configuration!"
    exit 1
fi
```

### Version Control for Configs

Track configuration changes using Git.

```bash
# Initialize git repository for configs
cd /etc/myapp
sudo git init

# Configure git
sudo git config user.email "admin@example.com"
sudo git config user.name "System Admin"

# Add .gitignore
sudo nano .gitignore
```

```gitignore
# Ignore sensitive files
secrets/
*.key
*.pem
*.crt
.env
*_password
*_secret
```

```bash
# Initial commit
sudo git add .
sudo git commit -m "Initial configuration"

# Create backup script
sudo nano /usr/local/bin/backup-configs.sh
```

```bash
#!/bin/bash
# Backup configuration with git

cd /etc/myapp

# Check for changes
if [[ -n $(git status -s) ]]; then
    # Add all changes
    git add -A

    # Commit with timestamp
    git commit -m "Configuration backup - $(date '+%Y-%m-%d %H:%M:%S')"

    # Push to remote (if configured)
    # git push origin main

    echo "Configuration backed up successfully"
else
    echo "No configuration changes detected"
fi
```

```bash
# Schedule regular backups
sudo crontab -e
# Add: 0 */6 * * * /usr/local/bin/backup-configs.sh
```

### Application Secrets Management

Properly managing secrets is critical for security.

#### Using Linux Keyrings

```bash
# Install secret management tools
sudo apt install gnupg2 pass

# Initialize password store
gpg --gen-key
pass init your-email@example.com

# Store secrets
pass insert myapp/db_password
pass insert myapp/api_key

# Retrieve secrets in scripts
DB_PASS=$(pass myapp/db_password)
```

#### Using Encrypted Files

```bash
# Encrypt sensitive configuration
# Create secret file
sudo nano /etc/myapp/secrets.conf

# Encrypt with GPG
sudo gpg --symmetric --cipher-algo AES256 /etc/myapp/secrets.conf

# Delete original
sudo shred -u /etc/myapp/secrets.conf

# Decrypt when needed
sudo gpg --decrypt /etc/myapp/secrets.conf.gpg

# In application startup script
sudo nano /usr/local/bin/start-app.sh
```

```bash
#!/bin/bash
# Decrypt secrets and start application

# Decrypt secrets to memory
SECRETS=$(gpg --batch --passphrase-file /etc/myapp/.passphrase --decrypt /etc/myapp/secrets.conf.gpg)

# Export as environment variables
eval "$SECRETS"

# Start application
exec /usr/bin/node /var/www/app/app.js
```

#### Using HashiCorp Vault (Advanced)

```bash
# Install Vault
curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add -
sudo apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main"
sudo apt update && sudo apt install vault

# Basic Vault usage
# Start Vault server (development mode)
vault server -dev

# In another terminal
export VAULT_ADDR='http://127.0.0.1:8200'
export VAULT_TOKEN='your-root-token'

# Store secret
vault kv put secret/myapp/config db_password=secret123 api_key=abc456

# Retrieve secret
vault kv get secret/myapp/config

# In application
sudo nano /usr/local/bin/get-secrets.sh
```

```bash
#!/bin/bash
# Retrieve secrets from Vault

export VAULT_ADDR='http://vault.example.com:8200'

# Authenticate
vault login -method=token token=${VAULT_TOKEN}

# Get secrets and export as environment variables
eval $(vault kv get -format=json secret/myapp/config | \
    jq -r '.data.data | to_entries[] | "export " + .key + "=\"" + .value + "\""')
```

### Service Configuration

Configuring services properly ensures reliability and maintainability.

#### Systemd Service Configuration

```bash
# Create service file
sudo nano /etc/systemd/system/myapp.service
```

```ini
[Unit]
Description=My Application Service
Documentation=https://myapp.example.com/docs
After=network-online.target
Wants=network-online.target
Requires=mysql.service redis.service

[Service]
Type=exec
User=appuser
Group=appuser
WorkingDirectory=/var/www/app/current

# Environment
Environment="NODE_ENV=production"
EnvironmentFile=-/etc/myapp/env

# Security
NoNewPrivileges=true
PrivateTmp=true
ProtectSystem=strict
ProtectHome=true
ReadWritePaths=/var/www/app/shared /var/log/myapp

# Resource limits
LimitNOFILE=65536
LimitNPROC=512
MemoryLimit=1G
CPUQuota=80%

# Restart policy
Restart=always
RestartSec=5
StartLimitBurst=5
StartLimitInterval=60

# Commands
ExecStartPre=/usr/local/bin/check-deps.sh
ExecStart=/usr/bin/node app.js
ExecReload=/bin/kill -USR2 $MAINPID
ExecStop=/bin/kill -TERM $MAINPID

# Logging
StandardOutput=journal
StandardError=journal
SyslogIdentifier=myapp

[Install]
WantedBy=multi-user.target
```

```bash
# Reload systemd configuration
sudo systemctl daemon-reload

# Enable service
sudo systemctl enable myapp

# Start service
sudo systemctl start myapp

# Check status
sudo systemctl status myapp

# View logs
journalctl -u myapp -f
```

#### Service Dependencies

```bash
# Create override directory
sudo mkdir -p /etc/systemd/system/myapp.service.d

# Add dependencies
sudo nano /etc/systemd/system/myapp.service.d/dependencies.conf
```

```ini
[Unit]
# Additional dependencies
After=mysql.service redis.service nginx.service
Requires=mysql.service
Wants=redis.service

[Service]
# Wait for services to be ready
ExecStartPre=/bin/bash -c 'until mysqladmin ping; do sleep 1; done'
ExecStartPre=/bin/bash -c 'until redis-cli ping; do sleep 1; done'
```

#### Service Monitoring

```bash
# Create health check script
sudo nano /usr/local/bin/check-myapp.sh
```

```bash
#!/bin/bash
# Health check for myapp

# Check if service is running
if ! systemctl is-active --quiet myapp; then
    echo "Service is not running"
    systemctl start myapp
    exit 1
fi

# Check HTTP endpoint
if ! curl -f -s http://localhost:3000/health > /dev/null; then
    echo "Health check failed"
    systemctl restart myapp
    exit 1
fi

# Check memory usage
MEM=$(ps aux | grep -E "node.*app.js" | awk '{print $4}' | head -1)
if (( $(echo "$MEM > 80" | bc -l) )); then
    echo "High memory usage: ${MEM}%"
    systemctl restart myapp
fi

echo "Service is healthy"
```

```bash
# Schedule health checks
sudo crontab -e
# Add: */5 * * * * /usr/local/bin/check-myapp.sh
```

---

## Practice Exercises

### Exercise 1: Package Management
1. Add a new repository (e.g., Docker or PostgreSQL)
2. Install a package from the new repository
3. Pin the package to a specific version
4. Configure automatic security updates
5. Create a script to audit installed packages

### Exercise 2: Build from Source
1. Download and compile Redis from source
2. Create a systemd service for your compiled Redis
3. Configure it to start on boot
4. Create a package using checkinstall
5. Document the build process

### Exercise 3: Application Deployment
1. Create a deployment structure for a web application
2. Implement a zero-downtime deployment script
3. Set up environment-specific configurations
4. Configure application secrets management
5. Create health monitoring for your application

### Exercise 4: Configuration Management
1. Set up a Git repository for system configurations
2. Create configuration templates using environment variables
3. Implement automated configuration backups
4. Set up a configuration validation system
5. Document your configuration structure

---

## Quick Reference

### APT Commands
```bash
sudo apt update                # Update package index
sudo apt upgrade               # Upgrade all packages
sudo apt install package       # Install package
sudo apt remove package        # Remove package
sudo apt purge package         # Remove package and config
sudo apt autoremove           # Remove unused dependencies
sudo apt search keyword       # Search for packages
apt show package              # Show package information
apt list --installed          # List installed packages
apt list --upgradable        # List upgradable packages
sudo apt-mark hold package   # Prevent package upgrades
```

### Snap Commands
```bash
snap list                     # List installed snaps
snap search package          # Search for snaps
sudo snap install package    # Install snap
sudo snap remove package     # Remove snap
sudo snap refresh           # Update all snaps
snap info package           # Show snap information
snap connections package    # Show snap permissions
sudo snap revert package    # Rollback snap version
```

### Configuration Commands
```bash
printenv                     # Show environment variables
export VAR=value            # Set environment variable
source file                 # Load environment from file
systemctl edit service      # Edit service configuration
systemctl daemon-reload     # Reload systemd configs
journalctl -u service       # View service logs
git diff                    # Show config changes
envsubst < template > output # Process template
```

### Build Commands
```bash
./configure                  # Configure build
make                        # Compile software
make test                   # Run tests
sudo make install           # Install software
sudo checkinstall          # Create package from source
pkg-config --list-all      # List available packages
ldd binary                 # Show library dependencies
```

---

## Additional Resources

### Documentation
- [Ubuntu Server Guide - Package Management](https://ubuntu.com/server/docs/package-management)
- [Debian Administrator's Handbook](https://debian-handbook.info/browse/stable/packaging-system.html)
- [Snapcraft Documentation](https://snapcraft.io/docs)
- [Systemd Service Management](https://www.freedesktop.org/software/systemd/man/systemd.service.html)

### Package Repositories
- [Ubuntu Packages](https://packages.ubuntu.com/)
- [Launchpad PPAs](https://launchpad.net/ubuntu/+ppas)
- [Snap Store](https://snapcraft.io/store)
- [Docker Hub](https://hub.docker.com/)

### Configuration Management Tools
- [Ansible](https://www.ansible.com/)
- [Puppet](https://puppet.com/)
- [Chef](https://www.chef.io/)
- [SaltStack](https://saltproject.io/)

### Security Resources
- [OWASP Configuration Guide](https://owasp.org/www-project-configuration-security/)
- [Linux Secrets Management](https://www.vaultproject.io/)
- [GPG Encryption Guide](https://www.gnupg.org/documentation/)

### Next Steps
After completing this section, you should:
- Understand how to manage packages with APT
- Be able to compile software from source
- Know how to properly deploy applications
- Understand configuration and secrets management

Continue to Part 6: Service Management and Automation to learn about automating tasks and managing services efficiently.