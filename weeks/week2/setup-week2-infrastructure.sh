#!/bin/bash

################################################################################
# Week 2 Infrastructure Setup Script
################################################################################
#
# This script automates the complete setup of the Week 2 infrastructure:
# 1. Removes old Docker installations
# 2. Installs Docker Engine and Docker Compose
# 3. Configures Docker with best practices
# 4. Creates necessary directories and networks
# 5. Deploys Nginx Proxy Manager (NPM)
# 6. Deploys Code-Server (VS Code in browser)
#
# Prerequisites:
# - Ubuntu 22.04 LTS server
# - Root or sudo privileges
# - Internet connectivity
# - Domain name purchased (configure DNS separately)
#
# Usage:
#   sudo bash setup-week2-infrastructure.sh
#
# Author: BroTech Labs Training
# Version: 1.0
#
################################################################################

# Exit immediately if a command exits with a non-zero status
set -e

# Enable error tracing - print commands and their arguments as they are executed
set -x

################################################################################
# Color Codes for Output
################################################################################

# These ANSI color codes make output more readable
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

################################################################################
# Helper Functions
################################################################################

# Print info messages in blue
print_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

# Print success messages in green
print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

# Print warning messages in yellow
print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

# Print error messages in red
print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Print section headers
print_section() {
    echo ""
    echo "================================================================================"
    echo "  $1"
    echo "================================================================================"
    echo ""
}

################################################################################
# Part 1: Remove Old Docker Installations
################################################################################

print_section "Part 1: Removing Old Docker Installations"

# Old Docker packages can conflict with new installations
# This loop removes any existing Docker-related packages
print_info "Removing potentially conflicting Docker packages..."

for pkg in docker.io docker-doc docker-compose docker-compose-v2 podman-docker containerd runc; do
    # apt remove with -y flag auto-confirms removal
    # || true ensures the script continues even if package doesn't exist
    apt remove -y $pkg 2>/dev/null || true
done

print_success "Old Docker packages removed (if any existed)"

# Verify Docker is no longer installed
if ! command -v docker &> /dev/null; then
    print_success "Docker successfully removed - ready for fresh installation"
else
    print_warning "Docker command still exists - may be a custom installation"
fi

################################################################################
# Part 2: Set Up Docker's Official Repository
################################################################################

print_section "Part 2: Setting Up Docker's Official Repository"

# Docker uses GPG keys to sign packages for security verification
# This ensures we're installing legitimate Docker packages

print_info "Creating keyrings directory..."
# install command creates directory with specific permissions
# -m 0755 = owner can read/write/execute, others can read/execute
# -d flag indicates we're creating a directory
install -m 0755 -d /etc/apt/keyrings

print_info "Downloading Docker's GPG key..."
# curl flags:
#   -fsSL = fail silently, silent mode, show errors, follow redirects
# GPG key is used to verify package authenticity
curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc

print_info "Setting GPG key permissions..."
# chmod a+r = all users can read the key
chmod a+r /etc/apt/keyrings/docker.asc

print_info "Adding Docker repository to APT sources..."
# This complex command adds Docker's repository to APT
# Breaking it down:
#   - arch=$(dpkg --print-architecture) = gets system architecture (amd64, arm64, etc.)
#   - signed-by=/etc/apt/keyrings/docker.asc = tells APT to verify with GPG key
#   - $(. /etc/os-release && echo "$VERSION_CODENAME") = gets Ubuntu codename (jammy for 22.04)
#   - tee = writes to file and also outputs to terminal
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  tee /etc/apt/sources.list.d/docker.list > /dev/null

print_info "Updating package index..."
# apt update refreshes the package list to include Docker's repository
apt update

print_success "Docker repository configured successfully"

################################################################################
# Part 3: Install Docker Engine and Docker Compose
################################################################################

print_section "Part 3: Installing Docker Engine and Docker Compose"

print_info "Installing Docker packages..."
# Installing all necessary Docker components:
#   - docker-ce: Docker Community Edition (main engine)
#   - docker-ce-cli: Command-line interface for Docker
#   - containerd.io: Container runtime (manages container lifecycle)
#   - docker-buildx-plugin: Enhanced build features (multi-platform builds)
#   - docker-compose-plugin: Docker Compose V2 (multi-container orchestration)
apt install -y \
    docker-ce \
    docker-ce-cli \
    containerd.io \
    docker-buildx-plugin \
    docker-compose-plugin

print_success "Docker packages installed successfully"

# Verify installations
print_info "Verifying Docker installation..."
DOCKER_VERSION=$(docker --version)
print_success "Docker installed: $DOCKER_VERSION"

print_info "Verifying Docker Compose installation..."
COMPOSE_VERSION=$(docker compose version)
print_success "Docker Compose installed: $COMPOSE_VERSION"

################################################################################
# Part 4: Configure Docker
################################################################################

print_section "Part 4: Configuring Docker"

# Configure Docker daemon with best practices
print_info "Creating Docker daemon configuration..."

# Create /etc/docker directory if it doesn't exist
mkdir -p /etc/docker

# Create daemon.json configuration file
# This configures:
#   - log-driver: json-file = standard JSON logging
#   - max-size: 10m = maximum 10MB per log file
#   - max-file: 3 = keep maximum 3 log files
# This prevents logs from consuming too much disk space
cat > /etc/docker/daemon.json << 'EOF'
{
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "10m",
    "max-file": "3"
  }
}
EOF

print_success "Docker daemon configuration created"

# Enable Docker to start on boot
print_info "Enabling Docker service to start on boot..."
systemctl enable docker

# Restart Docker to apply configuration
print_info "Restarting Docker to apply configuration..."
systemctl restart docker

# Wait for Docker to be ready
sleep 3

# Verify Docker is running
if systemctl is-active --quiet docker; then
    print_success "Docker service is running"
else
    print_error "Docker service failed to start"
    exit 1
fi

################################################################################
# Part 5: Test Docker Installation
################################################################################

print_section "Part 5: Testing Docker Installation"

print_info "Running Docker hello-world test..."
# hello-world is a minimal Docker image that verifies installation
# It will:
#   1. Pull the hello-world image from Docker Hub
#   2. Create a container
#   3. Run the container (prints a message)
#   4. Exit
docker run --rm hello-world

print_success "Docker is working correctly!"

################################################################################
# Part 6: Create Docker Network
################################################################################

print_section "Part 6: Creating Docker Network"

# Docker networks allow containers to communicate with each other
# Custom bridge networks provide:
#   - DNS resolution (containers can reach each other by name)
#   - Isolation from other containers
#   - Better control over networking

print_info "Creating nginx-proxy-network..."

# Check if network already exists
if docker network ls | grep -q nginx-proxy-network; then
    print_warning "Network nginx-proxy-network already exists"
else
    # docker network create creates a custom bridge network
    docker network create nginx-proxy-network
    print_success "Network nginx-proxy-network created"
fi

# Verify network exists
docker network ls | grep nginx-proxy-network
print_success "Docker network verified"

################################################################################
# Part 7: Create Docker Volumes
################################################################################

print_section "Part 7: Creating Docker Volumes"

# Docker volumes provide persistent storage for containers
# Data in volumes survives container deletion
# This is essential for:
#   - Databases
#   - User files
#   - Configuration
#   - SSL certificates

print_info "Creating Docker volumes for persistent data..."

# Create volumes for Nginx Proxy Manager
# npm-data: stores NPM database, configurations, users
docker volume create npm-data || print_warning "Volume npm-data already exists"

# npm-letsencrypt: stores SSL/TLS certificates from Let's Encrypt
docker volume create npm-letsencrypt || print_warning "Volume npm-letsencrypt already exists"

# Create volume for Code-Server
# code-server-data: stores VS Code settings, extensions, user projects
docker volume create code-server-data || print_warning "Volume code-server-data already exists"

# List all volumes to verify
print_info "Listing all Docker volumes..."
docker volume ls

print_success "Docker volumes created successfully"

################################################################################
# Part 8: Create Project Directories
################################################################################

print_section "Part 8: Creating Project Directories"

# Create organized directory structure for Docker Compose files
# This keeps projects organized and maintainable

print_info "Creating ~/docker directory structure..."

# Create main docker directory
mkdir -p ~/docker

# Create directory for Nginx Proxy Manager
mkdir -p ~/docker/nginx-proxy-manager

# Create directory for Code-Server
mkdir -p ~/docker/code-server

# List directory structure to verify
print_info "Directory structure:"
ls -la ~/docker/

print_success "Project directories created"

################################################################################
# Part 9: Create Nginx Proxy Manager Configuration
################################################################################

print_section "Part 9: Creating Nginx Proxy Manager Configuration"

print_info "Creating docker-compose.yml for Nginx Proxy Manager..."

# Create Docker Compose file for NPM
# This file defines how NPM should run
cat > ~/docker/nginx-proxy-manager/docker-compose.yml << 'EOF'
version: '3.8'

services:
  nginx-proxy-manager:
    # Official NPM image from Docker Hub
    image: jc21/nginx-proxy-manager:latest

    # Container name for easy reference
    container_name: nginx-proxy-manager

    # Restart policy: restart unless manually stopped
    restart: unless-stopped

    # Port mappings (HOST:CONTAINER)
    ports:
      - "80:80"      # HTTP - public web traffic
      - "443:443"    # HTTPS - secure web traffic
      - "81:81"      # Admin panel - NPM web interface

    # Environment variables
    environment:
      # X_FRAME_OPTIONS prevents clickjacking attacks
      X_FRAME_OPTIONS: "sameorigin"

    # Volume mounts for persistent data
    volumes:
      # NPM data: database, configurations, proxy hosts
      - npm-data:/data

      # Let's Encrypt certificates: SSL/TLS certs
      - npm-letsencrypt:/etc/letsencrypt

    # Connect to custom network
    # This allows NPM to communicate with other containers (code-server)
    networks:
      - nginx-proxy-network

    # Health check to monitor container status
    healthcheck:
      # wget checks if admin panel is accessible
      test: ["CMD", "wget", "--quiet", "--tries=1", "--spider", "http://localhost:81"]
      interval: 30s      # Check every 30 seconds
      timeout: 10s       # Timeout after 10 seconds
      retries: 3         # Retry 3 times before marking unhealthy
      start_period: 40s  # Wait 40s before starting health checks

# Use external network created earlier
networks:
  nginx-proxy-network:
    external: true

# Use external volumes created earlier
volumes:
  npm-data:
    external: true
  npm-letsencrypt:
    external: true
EOF

print_success "Nginx Proxy Manager docker-compose.yml created"

# Display the file for verification
print_info "NPM Configuration:"
cat ~/docker/nginx-proxy-manager/docker-compose.yml

################################################################################
# Part 10: Create Code-Server Configuration
################################################################################

print_section "Part 10: Creating Code-Server Configuration"

print_info "Creating docker-compose.yml for Code-Server..."

# Generate a random password for code-server
# This password will be required to access VS Code in browser
CODE_SERVER_PASSWORD=$(openssl rand -base64 24)
print_info "Generated Code-Server password (save this!): $CODE_SERVER_PASSWORD"

# Create Docker Compose file for Code-Server
cat > ~/docker/code-server/docker-compose.yml << EOF
version: '3.8'

services:
  code-server:
    # LinuxServer.io maintains excellent container images
    image: linuxserver/code-server:latest

    # Container name for easy reference
    container_name: code-server

    # Restart policy
    restart: unless-stopped

    # Port mapping
    ports:
      # Code-Server web interface
      # We use 8443 to avoid conflicts and imply it's for HTTPS
      - "8443:8443"

    # Environment variables configure the container
    environment:
      # User/Group IDs (run as root for simplicity)
      - PUID=0
      - PGID=0

      # Timezone (adjust as needed)
      - TZ=America/New_York

      # Code-Server password (required for login)
      - PASSWORD=$CODE_SERVER_PASSWORD

      # Disable sudo password (user is already root in container)
      - SUDO_PASSWORD_HASH=""

      # Port code-server listens on inside container
      - DEFAULT_WORKSPACE=/config/workspace

    # Volume for persistent data
    volumes:
      # Stores VS Code config, extensions, and user projects
      - code-server-data:/config

    # Connect to custom network
    # This allows code-server to be proxied by NPM
    networks:
      - nginx-proxy-network

    # Health check
    healthcheck:
      # Check if code-server web interface is responding
      test: ["CMD", "curl", "-f", "http://localhost:8443"]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 60s

# Use external network
networks:
  nginx-proxy-network:
    external: true

# Use external volume
volumes:
  code-server-data:
    external: true
EOF

print_success "Code-Server docker-compose.yml created"

# Display the file for verification
print_info "Code-Server Configuration:"
cat ~/docker/code-server/docker-compose.yml

# Save password to file for reference
echo "Code-Server Password: $CODE_SERVER_PASSWORD" > ~/docker/code-server/PASSWORD.txt
print_info "Password saved to ~/docker/code-server/PASSWORD.txt"

################################################################################
# Part 11: Deploy Nginx Proxy Manager
################################################################################

print_section "Part 11: Deploying Nginx Proxy Manager"

print_info "Starting Nginx Proxy Manager..."

# Navigate to NPM directory
cd ~/docker/nginx-proxy-manager

# Pull latest image
print_info "Pulling latest NPM image..."
docker compose pull

# Start container in detached mode
print_info "Starting NPM container..."
docker compose up -d

# Wait for container to be ready
print_info "Waiting for NPM to be ready..."
sleep 10

# Check if container is running
if docker ps | grep -q nginx-proxy-manager; then
    print_success "Nginx Proxy Manager is running!"
else
    print_error "Failed to start Nginx Proxy Manager"
    docker compose logs
    exit 1
fi

# Show container status
docker compose ps

################################################################################
# Part 12: Deploy Code-Server
################################################################################

print_section "Part 12: Deploying Code-Server"

print_info "Starting Code-Server..."

# Navigate to Code-Server directory
cd ~/docker/code-server

# Pull latest image
print_info "Pulling latest Code-Server image..."
docker compose pull

# Start container in detached mode
print_info "Starting Code-Server container..."
docker compose up -d

# Wait for container to be ready
print_info "Waiting for Code-Server to be ready..."
sleep 15

# Check if container is running
if docker ps | grep -q code-server; then
    print_success "Code-Server is running!"
else
    print_error "Failed to start Code-Server"
    docker compose logs
    exit 1
fi

# Show container status
docker compose ps

################################################################################
# Part 13: Verify Complete Setup
################################################################################

print_section "Part 13: Verifying Complete Setup"

print_info "Running comprehensive verification..."

# Get server IP address
SERVER_IP=$(hostname -I | awk '{print $1}')

echo ""
echo "=== Docker Installation ==="
docker --version
docker compose version
echo ""

echo "=== Docker Service Status ==="
systemctl status docker --no-pager | head -5
echo ""

echo "=== Running Containers ==="
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"
echo ""

echo "=== Docker Networks ==="
docker network ls | grep nginx-proxy-network
echo ""

echo "=== Docker Volumes ==="
docker volume ls | grep -E 'npm|code-server'
echo ""

echo "=== NPM Health Check ==="
if docker inspect nginx-proxy-manager --format='{{.State.Health.Status}}' 2>/dev/null | grep -q healthy; then
    print_success "NPM is healthy"
else
    print_warning "NPM health check not yet passing (may need more time)"
fi
echo ""

echo "=== Code-Server Health Check ==="
if docker inspect code-server --format='{{.State.Health.Status}}' 2>/dev/null | grep -q healthy; then
    print_success "Code-Server is healthy"
else
    print_warning "Code-Server health check not yet passing (may need more time)"
fi
echo ""

################################################################################
# Part 14: Display Access Information
################################################################################

print_section "Part 14: Access Information"

cat << EOF

${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}
${GREEN}                    WEEK 2 INFRASTRUCTURE SETUP COMPLETE!                    ${NC}
${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}

${BLUE}📋 Services Deployed:${NC}
   ✅ Docker Engine
   ✅ Docker Compose
   ✅ Nginx Proxy Manager
   ✅ Code-Server (VS Code in browser)

${BLUE}🌐 Access URLs:${NC}

   ${YELLOW}Nginx Proxy Manager Admin:${NC}
   📍 http://$SERVER_IP:81

   ${YELLOW}Default NPM Login:${NC}
   📧 Email:    admin@example.com
   🔑 Password: changeme

   ${RED}⚠️  IMPORTANT: Change NPM password on first login!${NC}

   ${YELLOW}Code-Server (VS Code):${NC}
   📍 http://$SERVER_IP:8443
   🔑 Password: $CODE_SERVER_PASSWORD

   ${RED}⚠️  Password also saved to: ~/docker/code-server/PASSWORD.txt${NC}

${BLUE}📁 Project Structure:${NC}
   ~/docker/
   ├── nginx-proxy-manager/
   │   └── docker-compose.yml
   └── code-server/
       ├── docker-compose.yml
       └── PASSWORD.txt

${BLUE}🔧 Useful Commands:${NC}

   ${YELLOW}View running containers:${NC}
   docker ps

   ${YELLOW}View all containers:${NC}
   docker ps -a

   ${YELLOW}View NPM logs:${NC}
   cd ~/docker/nginx-proxy-manager && docker compose logs -f

   ${YELLOW}View Code-Server logs:${NC}
   cd ~/docker/code-server && docker compose logs -f

   ${YELLOW}Restart NPM:${NC}
   cd ~/docker/nginx-proxy-manager && docker compose restart

   ${YELLOW}Restart Code-Server:${NC}
   cd ~/docker/code-server && docker compose restart

   ${YELLOW}Stop all services:${NC}
   cd ~/docker/nginx-proxy-manager && docker compose down
   cd ~/docker/code-server && docker compose down

   ${YELLOW}Start all services:${NC}
   cd ~/docker/nginx-proxy-manager && docker compose up -d
   cd ~/docker/code-server && docker compose up -d

${BLUE}📝 Next Steps:${NC}

   1. ${YELLOW}Configure DNS:${NC}
      - Point your domain to server IP: $SERVER_IP
      - Create A records in Cloudflare

   2. ${YELLOW}Access NPM Admin:${NC}
      - Go to http://$SERVER_IP:81
      - Login and change password immediately

   3. ${YELLOW}Create Proxy Host in NPM:${NC}
      - Add proxy host for code-server
      - Request SSL certificate from Let's Encrypt

   4. ${YELLOW}Access Code-Server via HTTPS:${NC}
      - Use your domain (e.g., https://code.yourdomain.com)

   5. ${YELLOW}Configure Cloudflare (Optional):${NC}
      - Enable orange cloud (proxied)
      - Set up IP allowlisting for security

${BLUE}📚 Documentation:${NC}
   - Week 2 Guide: ~/brotechlabs-training/weeks/week2/
   - Docker Docs: https://docs.docker.com
   - NPM Docs: https://nginxproxymanager.com

${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}

${GREEN}🎉 Installation complete! Your infrastructure is ready to use!${NC}

${YELLOW}⚠️  Remember to:${NC}
   - Change NPM admin password
   - Save Code-Server password securely
   - Configure firewall rules if needed
   - Set up DNS for your domain

${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}

EOF

################################################################################
# Part 15: Create Helpful Aliases (Optional)
################################################################################

print_section "Part 15: Creating Helpful Docker Aliases (Optional)"

print_info "Adding Docker aliases to .bashrc..."

# Add aliases to .bashrc if they don't already exist
if ! grep -q "# Docker Aliases" ~/.bashrc; then
    cat >> ~/.bashrc << 'EOF'

# Docker Aliases - Added by Week 2 Setup Script
alias dps='docker ps'
alias dpsa='docker ps -a'
alias di='docker images'
alias dex='docker exec -it'
alias dl='docker logs'
alias dlf='docker logs -f'
alias dcu='docker compose up -d'
alias dcd='docker compose down'
alias dcl='docker compose logs -f'
alias dcr='docker compose restart'

# Quick access to project directories
alias npm-dir='cd ~/docker/nginx-proxy-manager'
alias code-dir='cd ~/docker/code-server'
EOF

    print_success "Docker aliases added to ~/.bashrc"
    print_info "Run 'source ~/.bashrc' to use aliases immediately"
else
    print_warning "Docker aliases already exist in ~/.bashrc"
fi

################################################################################
# Script Complete
################################################################################

print_section "Setup Script Complete!"

print_success "All tasks completed successfully! 🚀"

# Return to home directory
cd ~

exit 0
