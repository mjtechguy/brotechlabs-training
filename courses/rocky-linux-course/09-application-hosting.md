# Part 9: Application Hosting

## Prerequisites and Learning Resources

Before starting this section, you should have completed:
- Part 1: Getting Started with Rocky Linux
- Part 2: Core System Administration (systemd services)
- Part 4: Networking and Security (firewall and SELinux)
- Part 5: Package and Software Management
- Part 8: Web and Database Servers (for web applications)

**Helpful Resources:**
- Rocky Linux Application Deployment Guide: https://docs.rockylinux.org/guides/
- Software Collections Documentation: https://www.softwarecollections.org/
- Systemd Service Management: https://www.freedesktop.org/software/systemd/man/
- Podman Documentation: https://docs.podman.io/
- Rocky Linux Community Forums: https://forums.rockylinux.org/

---

## Chapter 20: Running Applications

### Introduction

Rocky Linux is like a stage for applications - it provides everything needed for your software to perform. Whether you're running a small Python script or a complex enterprise application, Rocky Linux gives you the tools to host, manage, and monitor your applications effectively.

### Understanding Application Hosting

Think of hosting applications like running a theater:
- **The Stage** (Operating System): Rocky Linux provides the foundation
- **The Actors** (Applications): Your software performs the work
- **The Director** (Systemd): Manages when and how applications run
- **The Stage Manager** (You): Ensures everything runs smoothly
- **The Audience** (Users): Accesses and uses your applications

Applications on Rocky Linux can be:
- **Scripts**: Python, Bash, Perl scripts running tasks
- **Services**: Long-running processes like web apps or APIs
- **Containers**: Isolated applications in their own environments
- **Scheduled Jobs**: Tasks that run at specific times

```bash
# Let's see what's already running
systemctl list-units --type=service --state=running

# Check system resources available for applications
free -h
df -h
nproc
```

### Python Applications on Rocky Linux

Python is incredibly popular for everything from simple scripts to complex web applications. Rocky Linux includes Python, but you might need different versions for different applications.

```bash
# Check current Python version
python3 --version
# Python 3.9.18

# Rocky Linux uses Python 3.9 by default
which python3
# /usr/bin/python3

# Install Python development tools
sudo dnf install python3-devel python3-pip -y

# Create a Python virtual environment (best practice!)
python3 -m venv myapp
source myapp/bin/activate

# Now you're in an isolated Python environment
(myapp) $ python --version
(myapp) $ pip install flask requests
```

**Real-World Example: Simple Flask Application**

Let's create a basic monitoring dashboard:

```python
# /opt/myapp/app.py
from flask import Flask, jsonify
import psutil
import datetime

app = Flask(__name__)

@app.route('/')
def home():
    return '<h1>System Monitor</h1><p>Visit /status for system info</p>'

@app.route('/status')
def status():
    return jsonify({
        'time': datetime.datetime.now().isoformat(),
        'cpu_percent': psutil.cpu_percent(),
        'memory_percent': psutil.virtual_memory().percent,
        'disk_usage': psutil.disk_usage('/').percent
    })

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)
```

```bash
# Install dependencies
sudo dnf install gcc python3-devel -y
pip install flask psutil

# Test run the application
python app.py
# * Running on http://0.0.0.0:5000

# But this stops when you log out! We need systemd...
```

### Creating Systemd Services for Applications

Systemd is like a babysitter for your applications - it starts them, stops them, restarts them if they crash, and ensures they run at boot.

```bash
# Create a systemd service file
sudo vi /etc/systemd/system/myapp.service
```

```ini
[Unit]
Description=My Python Application
After=network.target

[Service]
Type=simple
User=appuser
Group=appuser
WorkingDirectory=/opt/myapp
Environment="PATH=/opt/myapp/venv/bin"
ExecStart=/opt/myapp/venv/bin/python /opt/myapp/app.py
Restart=always
RestartSec=10

# Security settings
PrivateTmp=true
NoNewPrivileges=true
ProtectSystem=strict
ProtectHome=true
ReadWritePaths=/opt/myapp/logs

[Install]
WantedBy=multi-user.target
```

```bash
# Create application user (for security)
sudo useradd -r -s /sbin/nologin appuser

# Set ownership
sudo chown -R appuser:appuser /opt/myapp

# Reload systemd and start the service
sudo systemctl daemon-reload
sudo systemctl start myapp
sudo systemctl enable myapp

# Check status
sudo systemctl status myapp

# View logs
sudo journalctl -u myapp -f
```

### Node.js Application Deployment

Node.js powers many modern web applications. Rocky Linux can host Node.js apps efficiently.

```bash
# Install Node.js from AppStream
sudo dnf module list nodejs
sudo dnf module install nodejs:18 -y

# Verify installation
node --version
npm --version

# Create a simple Express app
mkdir /opt/nodeapp
cd /opt/nodeapp
npm init -y
npm install express

# Create app.js
cat > app.js << 'EOF'
const express = require('express');
const app = express();
const port = 3000;

app.get('/', (req, res) => {
  res.json({
    message: 'Hello from Rocky Linux!',
    node: process.version,
    uptime: process.uptime()
  });
});

app.listen(port, () => {
  console.log(`App listening at http://localhost:${port}`);
});
EOF

# Use PM2 for production (process manager for Node.js)
sudo npm install -g pm2

# Start with PM2
pm2 start app.js --name nodeapp
pm2 save
pm2 startup systemd
```

### PHP Applications with Software Collections

PHP powers countless web applications. Rocky Linux supports multiple PHP versions through Software Collections.

```bash
# Install PHP 8.0 from AppStream
sudo dnf module install php:8.0 -y

# Or use Software Collections for more versions
sudo dnf install epel-release -y
sudo dnf install https://rpms.remirepo.net/enterprise/remi-release-9.rpm -y

# Enable PHP 8.2
sudo dnf module reset php
sudo dnf module enable php:remi-8.2 -y
sudo dnf install php php-cli php-fpm php-mysqlnd php-json -y

# Configure PHP-FPM for better performance
sudo systemctl enable --now php-fpm

# Check PHP version
php --version
```

**PHP-FPM Configuration for Applications:**

```bash
# Edit PHP-FPM pool configuration
sudo vi /etc/php-fpm.d/www.conf

# Key settings for applications:
# user = apache
# group = apache
# listen = /run/php-fpm/www.sock
# pm = dynamic
# pm.max_children = 50
# pm.start_servers = 5
# pm.min_spare_servers = 5
# pm.max_spare_servers = 35
```

### Java Application Hosting

Java applications are common in enterprise environments. Rocky Linux handles them well.

```bash
# Install OpenJDK
sudo dnf install java-11-openjdk java-11-openjdk-devel -y

# Or Java 17 for newer applications
sudo dnf install java-17-openjdk java-17-openjdk-devel -y

# Check Java version
java -version

# Set JAVA_HOME
echo 'export JAVA_HOME=/usr/lib/jvm/java-11-openjdk' >> ~/.bashrc
echo 'export PATH=$JAVA_HOME/bin:$PATH' >> ~/.bashrc
source ~/.bashrc

# Running a JAR file as a service
sudo vi /etc/systemd/system/javaapp.service
```

```ini
[Unit]
Description=Java Application
After=syslog.target network.target

[Service]
Type=simple
User=javauser
Group=javauser
ExecStart=/usr/bin/java -jar /opt/javaapp/application.jar
Restart=always
StandardOutput=journal
StandardError=journal
SyslogIdentifier=javaapp

# JVM settings
Environment="JAVA_OPTS=-Xms512m -Xmx2048m"

[Install]
WantedBy=multi-user.target
```

### Process Management and Resource Control

Applications need boundaries - like children need rules. Systemd and cgroups provide resource control.

```bash
# Limit CPU usage for an application
sudo systemctl set-property myapp.service CPUQuota=50%

# Limit memory
sudo systemctl set-property myapp.service MemoryMax=1G

# View current limits
systemctl show myapp.service | grep -E "(CPU|Memory)"

# Monitor resource usage
systemd-cgtop

# View cgroup hierarchy
systemd-cgls

# Set nice level (priority)
sudo renice -n 10 -p $(pgrep python)
```

**Resource Control in Service Files:**

```ini
[Service]
# CPU limits
CPUQuota=50%
CPUWeight=100

# Memory limits
MemoryMax=2G
MemorySwapMax=0

# IO limits
IOWeight=50
IOReadBandwidthMax=/dev/sda 10M
IOWriteBandwidthMax=/dev/sda 10M

# Task limits
TasksMax=100
```

### Application Logging and Log Rotation

Good logging is like a flight recorder - essential for understanding what happened when things go wrong.

```bash
# Configure application logging directory
sudo mkdir -p /var/log/myapp
sudo chown appuser:appuser /var/log/myapp

# Create logrotate configuration
sudo vi /etc/logrotate.d/myapp
```

```conf
/var/log/myapp/*.log {
    daily
    rotate 14
    compress
    delaycompress
    missingok
    notifempty
    create 0640 appuser appuser
    sharedscripts
    postrotate
        systemctl reload myapp > /dev/null 2>&1 || true
    endscript
}
```

```bash
# Test logrotate configuration
sudo logrotate -d /etc/logrotate.d/myapp

# Force rotation
sudo logrotate -f /etc/logrotate.d/myapp

# View logs with journalctl
journalctl -u myapp --since "1 hour ago"
journalctl -u myapp -p err  # Only errors
journalctl -u myapp -f      # Follow log
```

### Application Monitoring

Monitoring applications is like checking vital signs - you need to know they're healthy.

```bash
# Basic monitoring with systemctl
systemctl status myapp
systemctl is-active myapp
systemctl is-failed myapp

# Create a monitoring script
cat > /usr/local/bin/check_app.sh << 'EOF'
#!/bin/bash
APP_NAME="myapp"
APP_URL="http://localhost:5000/status"

# Check if service is running
if ! systemctl is-active --quiet $APP_NAME; then
    echo "CRITICAL: $APP_NAME is not running"
    systemctl start $APP_NAME
    exit 2
fi

# Check if app responds
if ! curl -s -f $APP_URL > /dev/null; then
    echo "WARNING: $APP_NAME not responding"
    systemctl restart $APP_NAME
    exit 1
fi

echo "OK: $APP_NAME is running and responding"
exit 0
EOF

chmod +x /usr/local/bin/check_app.sh

# Add to cron for regular checks
echo "*/5 * * * * /usr/local/bin/check_app.sh" | sudo crontab -
```

### Container-Based Applications with Podman

Containers are like shipping containers for applications - everything needed is packed inside.

```bash
# Install Podman (Docker alternative, no daemon needed!)
sudo dnf install podman -y

# Run a containerized application
podman run -d --name webapp \
  -p 8080:80 \
  -v /opt/app/data:/data:Z \
  nginx:alpine

# Create systemd service for container
podman generate systemd --name webapp \
  --files --new \
  --restart-policy=always

# Move service file and enable
sudo mv container-webapp.service /etc/systemd/system/
sudo systemctl daemon-reload
sudo systemctl enable --now container-webapp

# View container logs
podman logs -f webapp

# Execute commands in container
podman exec -it webapp sh
```

### SELinux Contexts for Applications

SELinux is like a security guard - it needs to know your application is allowed to do its job.

```bash
# View SELinux context for application files
ls -Z /opt/myapp

# Set correct context for web applications
sudo semanage fcontext -a -t httpd_sys_content_t "/opt/myapp(/.*)?"
sudo restorecon -Rv /opt/myapp

# Allow application to bind to port
sudo semanage port -a -t http_port_t -p tcp 5000

# Check SELinux denials
sudo ausearch -m avc -ts recent

# Troubleshoot with sealert
sudo sealert -a /var/log/audit/audit.log

# Create custom SELinux policy if needed
sudo audit2allow -a -M myapp
sudo semodule -i myapp.pp
```

### Performance Tuning for Applications

```bash
# Use tuned for application profiles
tuned-adm list
sudo tuned-adm profile throughput-performance

# Adjust kernel parameters for applications
echo 'net.core.somaxconn = 1024' | sudo tee -a /etc/sysctl.d/99-app.conf
echo 'net.ipv4.tcp_max_syn_backlog = 2048' | sudo tee -a /etc/sysctl.d/99-app.conf
sudo sysctl -p /etc/sysctl.d/99-app.conf

# Monitor application performance
pidstat -p $(pgrep python) 1
iostat -x 1
vmstat 1

# Profile application with perf
sudo perf record -p $(pgrep python) -g -- sleep 30
sudo perf report
```

### Practical Exercise: Deploy a Complete Application

Let's deploy a real application with all the components:

```bash
# 1. Create application structure
sudo mkdir -p /opt/todoapp/{app,logs,data}
sudo useradd -r -s /sbin/nologin todoapp

# 2. Create the application
cat > /opt/todoapp/app/todo.py << 'EOF'
#!/usr/bin/env python3
from flask import Flask, request, jsonify
import json
import os
from datetime import datetime

app = Flask(__name__)
DATA_FILE = '/opt/todoapp/data/todos.json'

def load_todos():
    if os.path.exists(DATA_FILE):
        with open(DATA_FILE, 'r') as f:
            return json.load(f)
    return []

def save_todos(todos):
    with open(DATA_FILE, 'w') as f:
        json.dump(todos, f, indent=2)

@app.route('/todos', methods=['GET'])
def get_todos():
    return jsonify(load_todos())

@app.route('/todos', methods=['POST'])
def add_todo():
    todos = load_todos()
    todo = {
        'id': len(todos) + 1,
        'task': request.json['task'],
        'created': datetime.now().isoformat()
    }
    todos.append(todo)
    save_todos(todos)
    return jsonify(todo), 201

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)
EOF

# 3. Setup Python environment
cd /opt/todoapp/app
python3 -m venv venv
source venv/bin/activate
pip install flask

# 4. Set permissions
sudo chown -R todoapp:todoapp /opt/todoapp
sudo chmod +x /opt/todoapp/app/todo.py

# 5. Create systemd service
sudo tee /etc/systemd/system/todoapp.service << 'EOF'
[Unit]
Description=Todo Application
After=network.target

[Service]
Type=simple
User=todoapp
Group=todoapp
WorkingDirectory=/opt/todoapp/app
ExecStart=/opt/todoapp/app/venv/bin/python /opt/todoapp/app/todo.py
Restart=always
StandardOutput=append:/opt/todoapp/logs/app.log
StandardError=append:/opt/todoapp/logs/error.log

[Install]
WantedBy=multi-user.target
EOF

# 6. Configure SELinux
sudo semanage fcontext -a -t httpd_sys_rw_content_t "/opt/todoapp/data(/.*)?"
sudo restorecon -Rv /opt/todoapp
sudo semanage port -a -t http_port_t -p tcp 5000

# 7. Configure firewall
sudo firewall-cmd --permanent --add-port=5000/tcp
sudo firewall-cmd --reload

# 8. Start and enable service
sudo systemctl daemon-reload
sudo systemctl enable --now todoapp

# 9. Test the application
curl -X POST http://localhost:5000/todos \
  -H "Content-Type: application/json" \
  -d '{"task": "Learn Rocky Linux"}'

curl http://localhost:5000/todos
```

### Troubleshooting Application Issues

Common problems and solutions:

```bash
# Application won't start
sudo journalctl -u myapp -n 50
sudo systemctl status myapp

# Permission denied errors
# Check file ownership
ls -la /opt/myapp
# Check SELinux
getenforce
sudo ausearch -m avc -ts recent

# Port already in use
sudo ss -tlnp | grep :5000
sudo lsof -i :5000

# Application crashes
# Check core dumps
sudo coredumpctl list
sudo coredumpctl info

# Memory issues
dmesg | grep -i "out of memory"
journalctl -u myapp | grep -i memory

# Performance problems
top -p $(pgrep python)
strace -p $(pgrep python) -c
```

### Review Questions

1. How do you create a systemd service for a Python application?
2. What's the difference between Type=simple and Type=forking in systemd?
3. How do you limit CPU usage to 50% for an application?
4. What SELinux context should web application files have?
5. How do you configure log rotation for an application?
6. What's the advantage of using Podman over Docker?
7. How do you monitor if an application is responding correctly?

### Practical Lab

Create a complete application deployment:
1. Deploy a Python Flask application
2. Create a systemd service with resource limits
3. Configure proper logging with rotation
4. Set up SELinux contexts
5. Add monitoring and automatic restart on failure
6. Configure firewall rules
7. Test the application under load

---

## Chapter 21: Development Environment

### Introduction

A development environment is like a workshop - it needs the right tools, proper organization, and safety measures. Rocky Linux provides an excellent platform for developers, whether you're working on system scripts, web applications, or enterprise software.

### Setting Up Developer Tools

Every craftsman needs their tools. Let's set up a complete development environment.

```bash
# Install Development Tools group
sudo dnf groupinstall "Development Tools" -y

# This includes:
# - gcc, g++, make
# - git, patch, diffutils
# - autoconf, automake
# - rpm-build tools

# Install additional development packages
sudo dnf install \
  vim-enhanced \
  tmux \
  htop \
  tree \
  jq \
  curl \
  wget \
  strace \
  ltrace \
  gdb \
  valgrind -y

# Install language-specific tools
sudo dnf install \
  python3-devel \
  nodejs \
  golang \
  rust \
  cargo -y
```

### Version Control with Git

Git is like a time machine for your code - it tracks every change and lets you collaborate with others.

```bash
# Configure Git (first time setup)
git config --global user.name "Your Name"
git config --global user.email "your.email@example.com"
git config --global init.defaultBranch main

# Set up useful aliases
git config --global alias.st status
git config --global alias.co checkout
git config --global alias.br branch
git config --global alias.cm "commit -m"
git config --global alias.lg "log --oneline --graph --all"

# Configure editor
git config --global core.editor vim

# Set up SSH key for GitHub/GitLab
ssh-keygen -t ed25519 -C "your.email@example.com"
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/id_ed25519

# Display public key to add to GitHub
cat ~/.ssh/id_ed25519.pub
```

**Git Workflow for Development:**

```bash
# Initialize a new project
mkdir myproject && cd myproject
git init

# Create .gitignore
cat > .gitignore << 'EOF'
# Python
__pycache__/
*.py[cod]
venv/
.env

# Node
node_modules/
npm-debug.log

# IDE
.vscode/
.idea/
*.swp
*.swo

# OS
.DS_Store
Thumbs.db
EOF

# Make initial commit
git add .
git commit -m "Initial commit"

# Create development branch
git checkout -b develop

# Work on feature
git checkout -b feature/new-feature
# ... make changes ...
git add .
git commit -m "Add new feature"

# Merge back
git checkout develop
git merge feature/new-feature
```

### Software Collections for Multiple Versions

Software Collections (SCL) lets you run multiple versions of languages and databases simultaneously - like having different sized wrenches in your toolbox.

```bash
# Install Software Collections
sudo dnf install centos-release-scl -y

# Install different Python versions
sudo dnf install rh-python38 rh-python39 -y

# Use a specific Python version
scl enable rh-python38 bash
python --version  # Python 3.8.x

# Make it permanent for a user
echo 'source scl_source enable rh-python38' >> ~/.bashrc

# Install multiple PHP versions
sudo dnf install rh-php73 rh-php74 -y

# Run commands with specific version
scl enable rh-php74 'php -v'

# Create an alias for convenience
alias php74='scl enable rh-php74 php'
```

### Database Development Instances

Developers need databases to test against - like having a sandbox to build in.

```bash
# Install MariaDB for development
sudo dnf install mariadb-server mariadb-devel -y
sudo systemctl start mariadb

# Secure installation (for development, can be less strict)
sudo mysql_secure_installation

# Create development database
sudo mysql << 'EOF'
CREATE DATABASE devdb;
CREATE USER 'devuser'@'localhost' IDENTIFIED BY 'devpass123';
GRANT ALL PRIVILEGES ON devdb.* TO 'devuser'@'localhost';
FLUSH PRIVILEGES;
EOF

# Install PostgreSQL for development
sudo dnf install postgresql-server postgresql-devel -y
sudo postgresql-setup --initdb
sudo systemctl start postgresql

# Configure PostgreSQL for development
sudo -u postgres psql << 'EOF'
CREATE USER devuser WITH PASSWORD 'devpass123';
CREATE DATABASE devdb OWNER devuser;
GRANT ALL PRIVILEGES ON DATABASE devdb TO devuser;
EOF

# Install Redis for caching development
sudo dnf install redis -y
sudo systemctl start redis
redis-cli ping  # Should return PONG
```

### Container Development with Podman

Containers are perfect for development - consistent environments without the "it works on my machine" problem.

```bash
# Podman is already installed, let's use it for development
# Create a development container
podman run -it --name devbox \
  -v $HOME/projects:/projects:Z \
  -w /projects \
  rockylinux:9 /bin/bash

# Inside container, install what you need
dnf install python3 nodejs npm -y

# Create a Containerfile (Dockerfile)
cat > Containerfile << 'EOF'
FROM rockylinux:9
RUN dnf install -y python3 python3-pip nodejs npm git
RUN pip3 install flask django pytest
WORKDIR /app
CMD ["/bin/bash"]
EOF

# Build custom development image
podman build -t mydev:latest .

# Run with port forwarding and volume mount
podman run -it --rm \
  -p 8000:8000 \
  -v $(pwd):/app:Z \
  mydev:latest

# Use podman-compose for multi-container development
sudo dnf install podman-compose -y

# Create docker-compose.yml
cat > docker-compose.yml << 'EOF'
version: '3'
services:
  web:
    image: rockylinux:9
    volumes:
      - ./app:/app
    ports:
      - "8000:8000"
    command: python3 /app/main.py

  db:
    image: mariadb:latest
    environment:
      MYSQL_ROOT_PASSWORD: rootpass
      MYSQL_DATABASE: appdb
    volumes:
      - db_data:/var/lib/mysql

volumes:
  db_data:
EOF

podman-compose up
```

### IDE and Editor Configuration

Your editor is your primary tool - configure it well.

```bash
# Vim configuration for development
cat > ~/.vimrc << 'EOF'
" Enable syntax highlighting
syntax on

" Show line numbers
set number

" Enable mouse
set mouse=a

" Tab settings
set tabstop=4
set shiftwidth=4
set expandtab
set autoindent

" Search settings
set hlsearch
set ignorecase
set smartcase

" Show matching brackets
set showmatch

" Enable file type detection
filetype plugin indent on

" Status line
set laststatus=2
set ruler

" Code folding
set foldmethod=indent
set foldlevel=99
EOF

# Install Vim plugins manager
curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

# VS Code Remote Development (if using VS Code)
# Install code-server for web-based VS Code
curl -fsSL https://code-server.dev/install.sh | sh

# Start code-server
code-server --bind-addr 0.0.0.0:8080

# Configure firewall for code-server
sudo firewall-cmd --add-port=8080/tcp --permanent
sudo firewall-cmd --reload
```

### Testing Environments

Testing is like quality control - catch problems before they reach production.

```bash
# Python testing setup
pip install pytest pytest-cov pytest-mock

# Create test structure
mkdir -p tests
cat > tests/test_example.py << 'EOF'
import pytest

def add(a, b):
    return a + b

def test_add():
    assert add(2, 3) == 5
    assert add(-1, 1) == 0

def test_add_strings():
    assert add("hello ", "world") == "hello world"
EOF

# Run tests
pytest tests/ -v
pytest tests/ --cov=. --cov-report=html

# Node.js testing setup
npm install --save-dev jest

# Configure package.json
cat > package.json << 'EOF'
{
  "scripts": {
    "test": "jest",
    "test:watch": "jest --watch"
  },
  "devDependencies": {
    "jest": "^27.0.0"
  }
}
EOF

# Continuous testing with watch
npm run test:watch
```

### Development vs Production Configuration

Different environments need different settings - like wearing different clothes for different occasions.

```bash
# Environment-specific configuration
# Create .env files (never commit these!)
cat > .env.development << 'EOF'
DATABASE_URL=postgresql://devuser:devpass@localhost/devdb
DEBUG=true
LOG_LEVEL=debug
API_KEY=dev-key-not-for-production
EOF

cat > .env.production << 'EOF'
DATABASE_URL=postgresql://produser:${DB_PASSWORD}@db.example.com/proddb
DEBUG=false
LOG_LEVEL=error
API_KEY=${PRODUCTION_API_KEY}
EOF

# Python: Load environment-specific config
cat > config.py << 'EOF'
import os
from dotenv import load_dotenv

# Load environment
env = os.getenv('APP_ENV', 'development')
load_dotenv(f'.env.{env}')

class Config:
    DATABASE_URL = os.getenv('DATABASE_URL')
    DEBUG = os.getenv('DEBUG', 'false').lower() == 'true'
    LOG_LEVEL = os.getenv('LOG_LEVEL', 'info')

    @classmethod
    def is_production(cls):
        return not cls.DEBUG
EOF

# Use different systemd environments
# Development service
cat > myapp-dev.service << 'EOF'
[Service]
Environment="APP_ENV=development"
ExecStart=/usr/bin/python app.py
EOF

# Production service
cat > myapp-prod.service << 'EOF'
[Service]
Environment="APP_ENV=production"
ExecStart=/usr/bin/python app.py
User=appuser
PrivateTmp=true
ProtectSystem=strict
EOF
```

### Build Automation

Automation is like having a helpful robot - it does repetitive tasks so you can focus on creative work.

```bash
# Create a Makefile for Python project
cat > Makefile << 'EOF'
.PHONY: help install test clean run

help:
	@echo "Available commands:"
	@echo "  make install  - Install dependencies"
	@echo "  make test     - Run tests"
	@echo "  make clean    - Clean up files"
	@echo "  make run      - Run application"

install:
	pip install -r requirements.txt

test:
	pytest tests/ -v --cov=.

clean:
	find . -type f -name '*.pyc' -delete
	find . -type d -name '__pycache__' -delete
	rm -rf .pytest_cache
	rm -rf htmlcov

run:
	python app.py
EOF

# For Node.js projects, use npm scripts
cat > package.json << 'EOF'
{
  "scripts": {
    "start": "node app.js",
    "dev": "nodemon app.js",
    "test": "jest",
    "lint": "eslint .",
    "build": "webpack --mode production",
    "clean": "rm -rf dist node_modules"
  }
}
EOF
```

### Performance Profiling in Development

Understanding performance during development prevents production problems.

```bash
# Python profiling
pip install memory_profiler line_profiler

# Profile memory usage
cat > memory_test.py << 'EOF'
from memory_profiler import profile

@profile
def memory_heavy_function():
    big_list = [i for i in range(1000000)]
    another_list = [i**2 for i in big_list]
    return sum(another_list)

if __name__ == '__main__':
    result = memory_heavy_function()
EOF

python -m memory_profiler memory_test.py

# Profile execution time
cat > time_test.py << 'EOF'
import cProfile
import pstats

def slow_function():
    total = 0
    for i in range(1000000):
        total += i ** 2
    return total

cProfile.run('slow_function()', 'profile_stats')
stats = pstats.Stats('profile_stats')
stats.strip_dirs()
stats.sort_stats('cumulative')
stats.print_stats(10)
EOF

# System-level profiling
perf record -g python app.py
perf report

# Trace system calls
strace -c python app.py

# Monitor file access
strace -e open,openat python app.py
```

### Development Security Best Practices

Security in development is like wearing safety glasses - essential even when you think you don't need them.

```bash
# Secret management
# Never hardcode secrets!
cat > secrets.py << 'EOF'
import os
from cryptography.fernet import Fernet

# Generate a key (do this once)
def generate_key():
    return Fernet.generate_key()

# Encrypt secrets
def encrypt_secret(secret, key):
    f = Fernet(key)
    return f.encrypt(secret.encode())

# Decrypt secrets
def decrypt_secret(encrypted_secret, key):
    f = Fernet(key)
    return f.decrypt(encrypted_secret).decode()

# Use environment variables
DATABASE_PASSWORD = os.environ.get('DB_PASSWORD')
if not DATABASE_PASSWORD:
    raise ValueError("DB_PASSWORD environment variable not set!")
EOF

# Dependency scanning
pip install safety
safety check

# For Node.js
npm audit
npm audit fix

# Code scanning with bandit (Python)
pip install bandit
bandit -r . -f json -o bandit_report.json

# Static analysis with pylint
pip install pylint
pylint app.py
```

### Debugging Tools and Techniques

Debugging is like being a detective - you need the right tools to solve the mystery.

```bash
# GDB for compiled languages
cat > buggy.c << 'EOF'
#include <stdio.h>
int main() {
    int *p = NULL;
    *p = 42;  // This will crash
    return 0;
}
EOF

gcc -g buggy.c -o buggy
gdb ./buggy
# (gdb) run
# (gdb) bt  # backtrace
# (gdb) quit

# Python debugging with pdb
cat > debug_me.py << 'EOF'
import pdb

def problematic_function(x, y):
    pdb.set_trace()  # Breakpoint
    result = x / y
    return result * 2

print(problematic_function(10, 0))
EOF

python debug_me.py
# (Pdb) l  # list code
# (Pdb) n  # next line
# (Pdb) p x  # print variable
# (Pdb) c  # continue

# Remote debugging with debugpy
pip install debugpy
python -m debugpy --listen 5678 --wait-for-client app.py
```

### Practical Exercise: Complete Development Workflow

Let's create a full development workflow:

```bash
# 1. Set up project structure
mkdir ~/myproject && cd ~/myproject
git init

# 2. Create virtual environment
python3 -m venv venv
source venv/bin/activate

# 3. Create application
cat > app.py << 'EOF'
from flask import Flask, jsonify
import os

app = Flask(__name__)
app.config['DEBUG'] = os.getenv('DEBUG', 'false').lower() == 'true'

@app.route('/')
def home():
    return jsonify({
        'message': 'Hello from development!',
        'debug': app.config['DEBUG']
    })

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=app.config['DEBUG'])
EOF

# 4. Create requirements
cat > requirements.txt << 'EOF'
flask==2.0.1
pytest==6.2.4
pytest-cov==2.12.1
black==21.6b0
flake8==3.9.2
EOF

pip install -r requirements.txt

# 5. Create tests
mkdir tests
cat > tests/test_app.py << 'EOF'
import pytest
from app import app

@pytest.fixture
def client():
    app.config['TESTING'] = True
    with app.test_client() as client:
        yield client

def test_home(client):
    rv = client.get('/')
    json_data = rv.get_json()
    assert json_data['message'] == 'Hello from development!'
EOF

# 6. Create Makefile
cat > Makefile << 'EOF'
.PHONY: install test lint format run clean

install:
	pip install -r requirements.txt

test:
	pytest tests/ -v --cov=. --cov-report=term-missing

lint:
	flake8 app.py tests/

format:
	black app.py tests/

run:
	DEBUG=true python app.py

clean:
	find . -name "*.pyc" -delete
	find . -name "__pycache__" -delete
	rm -rf .pytest_cache htmlcov .coverage
EOF

# 7. Run the workflow
make install
make test
make lint
make format
make run
```

### Review Questions

1. What's the difference between development and production configurations?
2. How do you manage multiple versions of Python using Software Collections?
3. What are the benefits of using containers for development?
4. How do you securely manage secrets in development?
5. What tools can you use for profiling Python applications?
6. How do you set up a CI/CD pipeline locally?
7. What's the purpose of a Makefile in development?

### Practical Lab

Set up a complete development environment:
1. Install development tools and configure Git
2. Set up multiple Python versions using Software Collections
3. Create a development database instance
4. Build a containerized development environment
5. Implement automated testing with coverage
6. Configure different settings for dev/prod
7. Set up debugging and profiling tools
8. Create a build automation system

### Next Steps

In Part 10, we'll explore troubleshooting and recovery - learning how to diagnose and fix problems when things go wrong. You'll learn systematic approaches to solving issues, from boot problems to application crashes, ensuring you can keep your systems running smoothly.