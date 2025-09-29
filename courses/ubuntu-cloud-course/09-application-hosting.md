# Part 9: Application Hosting

## Prerequisites

Before starting this section, you should understand:
- Basic web server configuration (Nginx/Apache)
- Process management with systemctl
- Environment variables and configuration files
- Basic networking concepts (ports, firewall)
- Package management with APT

**Learning Resources:**
- [Node.js Documentation](https://nodejs.org/en/docs/)
- [Python Web Deployment](https://docs.python.org/3/howto/webservers.html)
- [PHP Documentation](https://www.php.net/docs.php)
- [Git Documentation](https://git-scm.com/doc)

---

## Chapter 20: Running Applications

### Introduction to Application Hosting

Running applications on Ubuntu Server involves:
- Installing runtime environments (Python, Node.js, PHP)
- Configuring applications for production
- Managing application processes
- Handling logs and monitoring
- Ensuring security and resource isolation

### Python Applications

#### Setting Up Python Environment

```bash
# Check Python version (Ubuntu 22.04 comes with Python 3.10+)
python3 --version

# Install Python essentials
sudo apt update
sudo apt install python3-pip python3-venv python3-dev build-essential -y

# Install additional Python packages
sudo apt install python3-setuptools python3-wheel -y

# Upgrade pip
python3 -m pip install --upgrade pip
```

#### Virtual Environments

Virtual environments isolate Python dependencies per application.

```bash
# Create application directory
sudo mkdir -p /var/www/python-app
sudo chown $USER:$USER /var/www/python-app
cd /var/www/python-app

# Create virtual environment
python3 -m venv venv

# Activate virtual environment
source venv/bin/activate

# Your prompt changes to show (venv)
# Install packages in virtual environment
pip install flask gunicorn requests

# Create requirements file
pip freeze > requirements.txt

# Deactivate when done
deactivate
```

#### Flask Application Example

```bash
# Create a Flask application
nano /var/www/python-app/app.py
```

```python
from flask import Flask, jsonify, request
import os
import logging
from datetime import datetime

# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s'
)
logger = logging.getLogger(__name__)

# Create Flask app
app = Flask(__name__)

# Configuration from environment
app.config['DEBUG'] = os.environ.get('FLASK_DEBUG', 'False').lower() == 'true'
app.config['SECRET_KEY'] = os.environ.get('SECRET_KEY', 'dev-secret-key')

@app.route('/')
def index():
    logger.info('Index page accessed')
    return jsonify({
        'message': 'Hello from Flask!',
        'timestamp': datetime.now().isoformat(),
        'environment': os.environ.get('FLASK_ENV', 'production')
    })

@app.route('/health')
def health():
    return jsonify({'status': 'healthy'}), 200

@app.route('/api/echo', methods=['POST'])
def echo():
    data = request.get_json()
    logger.info(f'Echo endpoint called with: {data}')
    return jsonify({'echo': data}), 200

@app.errorhandler(404)
def not_found(error):
    return jsonify({'error': 'Not found'}), 404

@app.errorhandler(500)
def internal_error(error):
    logger.error(f'Internal error: {error}')
    return jsonify({'error': 'Internal server error'}), 500

if __name__ == '__main__':
    # Development server (not for production!)
    app.run(host='0.0.0.0', port=5000)
```

#### WSGI Configuration with Gunicorn

```bash
# Install Gunicorn
cd /var/www/python-app
source venv/bin/activate
pip install gunicorn

# Create Gunicorn configuration
nano /var/www/python-app/gunicorn_config.py
```

```python
import multiprocessing
import os

# Server socket
bind = "127.0.0.1:5000"
backlog = 2048

# Worker processes
workers = multiprocessing.cpu_count() * 2 + 1
worker_class = 'sync'
worker_connections = 1000
timeout = 30
keepalive = 2

# Restart workers after this many requests
max_requests = 1000
max_requests_jitter = 50

# Logging
accesslog = '/var/log/python-app/access.log'
errorlog = '/var/log/python-app/error.log'
loglevel = 'info'
access_log_format = '%(h)s %(l)s %(u)s %(t)s "%(r)s" %(s)s %(b)s "%(f)s" "%(a)s" %(D)s'

# Process naming
proc_name = 'python-app'

# Server mechanics
daemon = False
pidfile = '/var/run/python-app.pid'
user = 'www-data'
group = 'www-data'
tmp_upload_dir = None

# SSL (if needed)
# keyfile = '/path/to/keyfile'
# certfile = '/path/to/certfile'
```

```bash
# Create log directory
sudo mkdir -p /var/log/python-app
sudo chown www-data:www-data /var/log/python-app

# Test Gunicorn
gunicorn --config gunicorn_config.py app:app
```

#### Django Application Setup

```bash
# Install Django
cd /var/www
django-admin startproject django_app
cd django_app

# Install dependencies
pip install django gunicorn psycopg2-binary python-decouple

# Configure Django settings
nano django_app/settings.py
```

```python
# Production settings
from decouple import config

DEBUG = config('DEBUG', default=False, cast=bool)
SECRET_KEY = config('SECRET_KEY')
ALLOWED_HOSTS = config('ALLOWED_HOSTS', cast=lambda v: [s.strip() for s in v.split(',')])

# Database configuration
DATABASES = {
    'default': {
        'ENGINE': 'django.db.backends.postgresql',
        'NAME': config('DB_NAME'),
        'USER': config('DB_USER'),
        'PASSWORD': config('DB_PASSWORD'),
        'HOST': config('DB_HOST', default='localhost'),
        'PORT': config('DB_PORT', default='5432'),
    }
}

# Static files
STATIC_URL = '/static/'
STATIC_ROOT = '/var/www/django_app/static/'
MEDIA_URL = '/media/'
MEDIA_ROOT = '/var/www/django_app/media/'
```

```bash
# Create .env file
nano /var/www/django_app/.env
```

```env
SECRET_KEY=your-secret-key-here
DEBUG=False
ALLOWED_HOSTS=example.com,www.example.com
DB_NAME=django_db
DB_USER=django_user
DB_PASSWORD=secure_password
DB_HOST=localhost
DB_PORT=5432
```

```bash
# Run migrations
python manage.py migrate
python manage.py collectstatic --noinput

# Create superuser
python manage.py createsuperuser
```

### Node.js Applications

#### Installing Node.js

```bash
# Install Node.js via NodeSource repository (for latest version)
curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash -
sudo apt install nodejs -y

# Or install via snap
sudo snap install node --classic

# Verify installation
node --version
npm --version

# Install build tools for native modules
sudo apt install build-essential -y

# Install PM2 globally for process management
sudo npm install -g pm2
```

#### Express.js Application

```bash
# Create application directory
sudo mkdir -p /var/www/node-app
sudo chown $USER:$USER /var/www/node-app
cd /var/www/node-app

# Initialize npm project
npm init -y

# Install Express and dependencies
npm install express helmet cors dotenv winston express-rate-limit

# Create application
nano app.js
```

```javascript
const express = require('express');
const helmet = require('helmet');
const cors = require('cors');
const rateLimit = require('express-rate-limit');
const winston = require('winston');
require('dotenv').config();

// Configure logger
const logger = winston.createLogger({
    level: process.env.LOG_LEVEL || 'info',
    format: winston.format.json(),
    transports: [
        new winston.transports.File({ filename: '/var/log/node-app/error.log', level: 'error' }),
        new winston.transports.File({ filename: '/var/log/node-app/combined.log' }),
        new winston.transports.Console({
            format: winston.format.simple()
        })
    ]
});

// Create Express app
const app = express();
const PORT = process.env.PORT || 3000;

// Security middleware
app.use(helmet());
app.use(cors());

// Rate limiting
const limiter = rateLimit({
    windowMs: 15 * 60 * 1000, // 15 minutes
    max: 100 // limit each IP to 100 requests per windowMs
});
app.use('/api/', limiter);

// Body parsing
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Request logging
app.use((req, res, next) => {
    logger.info(`${req.method} ${req.path} - ${req.ip}`);
    next();
});

// Routes
app.get('/', (req, res) => {
    res.json({
        message: 'Node.js app running!',
        timestamp: new Date().toISOString(),
        environment: process.env.NODE_ENV || 'production'
    });
});

app.get('/health', (req, res) => {
    res.status(200).json({ status: 'healthy' });
});

app.get('/api/info', (req, res) => {
    res.json({
        node_version: process.version,
        memory: process.memoryUsage(),
        uptime: process.uptime()
    });
});

// Error handling
app.use((err, req, res, next) => {
    logger.error(err.stack);
    res.status(500).json({ error: 'Something went wrong!' });
});

// 404 handler
app.use((req, res) => {
    res.status(404).json({ error: 'Not found' });
});

// Start server
app.listen(PORT, () => {
    logger.info(`Server running on port ${PORT}`);
});

// Graceful shutdown
process.on('SIGTERM', () => {
    logger.info('SIGTERM received, closing server...');
    server.close(() => {
        logger.info('Server closed');
        process.exit(0);
    });
});
```

```bash
# Create environment file
nano .env
```

```env
NODE_ENV=production
PORT=3000
LOG_LEVEL=info
```

```bash
# Create log directory
sudo mkdir -p /var/log/node-app
sudo chown $USER:$USER /var/log/node-app
```

#### PM2 Process Management

```bash
# Start application with PM2
pm2 start app.js --name node-app

# Start with configuration file
nano ecosystem.config.js
```

```javascript
module.exports = {
    apps: [{
        name: 'node-app',
        script: './app.js',
        instances: 'max',
        exec_mode: 'cluster',
        env: {
            NODE_ENV: 'production',
            PORT: 3000
        },
        error_file: '/var/log/node-app/pm2-error.log',
        out_file: '/var/log/node-app/pm2-out.log',
        log_file: '/var/log/node-app/pm2-combined.log',
        time: true,
        max_memory_restart: '1G',
        max_restarts: 10,
        min_uptime: '10s',
        watch: false,
        ignore_watch: ['node_modules', 'logs'],
        wait_ready: true,
        listen_timeout: 3000,
        kill_timeout: 5000
    }]
};
```

```bash
# Start with ecosystem file
pm2 start ecosystem.config.js

# PM2 commands
pm2 list              # List all processes
pm2 show node-app    # Show details
pm2 logs node-app    # View logs
pm2 monit            # Monitor resources
pm2 restart node-app # Restart app
pm2 reload node-app  # Zero-downtime reload
pm2 stop node-app    # Stop app
pm2 delete node-app  # Remove from PM2

# Save PM2 configuration
pm2 save

# Setup PM2 to start on boot
pm2 startup systemd
# Follow the command it outputs
```

### PHP Applications

#### PHP Installation and Configuration

```bash
# Install PHP and common extensions
sudo apt update
sudo apt install php8.1 php8.1-fpm php8.1-mysql php8.1-xml php8.1-mbstring \
    php8.1-curl php8.1-gd php8.1-zip php8.1-bcmath php8.1-intl \
    php8.1-opcache php8.1-readline php8.1-cli -y

# Check PHP version
php -v

# Configure PHP-FPM
sudo nano /etc/php/8.1/fpm/php.ini
```

```ini
; Important production settings
expose_php = Off
max_execution_time = 30
max_input_time = 60
memory_limit = 256M
error_reporting = E_ALL & ~E_DEPRECATED & ~E_STRICT
display_errors = Off
display_startup_errors = Off
log_errors = On
error_log = /var/log/php/error.log
post_max_size = 20M
upload_max_filesize = 20M
max_file_uploads = 20
date.timezone = America/New_York

; OPcache settings
opcache.enable=1
opcache.memory_consumption=128
opcache.interned_strings_buffer=8
opcache.max_accelerated_files=4000
opcache.revalidate_freq=2
opcache.fast_shutdown=1
```

```bash
# Configure PHP-FPM pool
sudo nano /etc/php/8.1/fpm/pool.d/www.conf
```

```ini
[www]
user = www-data
group = www-data
listen = /run/php/php8.1-fpm.sock
listen.owner = www-data
listen.group = www-data
listen.mode = 0660

; Process management
pm = dynamic
pm.max_children = 50
pm.start_servers = 5
pm.min_spare_servers = 5
pm.max_spare_servers = 35
pm.process_idle_timeout = 10s
pm.max_requests = 500

; Logging
access.log = /var/log/php/access.log
slowlog = /var/log/php/slow.log
request_slowlog_timeout = 5s

; Environment variables
env[HOSTNAME] = $HOSTNAME
env[PATH] = /usr/local/bin:/usr/bin:/bin
env[TMP] = /tmp
env[TEMP] = /tmp
```

```bash
# Create log directory
sudo mkdir -p /var/log/php
sudo chown www-data:www-data /var/log/php

# Restart PHP-FPM
sudo systemctl restart php8.1-fpm
sudo systemctl enable php8.1-fpm
```

#### Laravel Application

```bash
# Install Composer
curl -sS https://getcomposer.org/installer | php
sudo mv composer.phar /usr/local/bin/composer
sudo chmod +x /usr/local/bin/composer

# Create Laravel project
cd /var/www
composer create-project laravel/laravel laravel-app

# Set permissions
cd laravel-app
sudo chown -R www-data:www-data storage bootstrap/cache
sudo chmod -R 775 storage bootstrap/cache

# Configure environment
cp .env.example .env
nano .env
```

```env
APP_NAME="Laravel App"
APP_ENV=production
APP_KEY=base64:your-generated-key
APP_DEBUG=false
APP_URL=https://example.com

LOG_CHANNEL=daily
LOG_LEVEL=error

DB_CONNECTION=mysql
DB_HOST=127.0.0.1
DB_PORT=3306
DB_DATABASE=laravel_db
DB_USERNAME=laravel_user
DB_PASSWORD=secure_password

CACHE_DRIVER=redis
SESSION_DRIVER=redis
QUEUE_CONNECTION=redis

REDIS_HOST=127.0.0.1
REDIS_PASSWORD=null
REDIS_PORT=6379
```

```bash
# Generate application key
php artisan key:generate

# Run migrations
php artisan migrate

# Optimize for production
php artisan config:cache
php artisan route:cache
php artisan view:cache
php artisan optimize
```

### Application Deployment Strategies

#### Zero-Downtime Deployment

```bash
# Create deployment script
nano /usr/local/bin/deploy-app.sh
```

```bash
#!/bin/bash
# Zero-downtime deployment script

APP_DIR="/var/www/app"
DEPLOY_DIR="/var/www/deployments"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
NEW_RELEASE="$DEPLOY_DIR/$TIMESTAMP"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

log() {
    echo -e "${GREEN}[$(date '+%Y-%m-%d %H:%M:%S')]${NC} $1"
}

error() {
    echo -e "${RED}[ERROR]${NC} $1" >&2
    exit 1
}

# Create new release directory
log "Creating release directory: $NEW_RELEASE"
mkdir -p "$NEW_RELEASE" || error "Failed to create release directory"

# Clone/copy application code
log "Deploying application code..."
git clone https://github.com/user/app.git "$NEW_RELEASE" || error "Failed to clone repository"

# Install dependencies
cd "$NEW_RELEASE"

if [ -f "package.json" ]; then
    log "Installing Node.js dependencies..."
    npm ci --production || error "Failed to install npm dependencies"
fi

if [ -f "requirements.txt" ]; then
    log "Installing Python dependencies..."
    python3 -m venv venv
    source venv/bin/activate
    pip install -r requirements.txt || error "Failed to install Python dependencies"
fi

if [ -f "composer.json" ]; then
    log "Installing PHP dependencies..."
    composer install --no-dev --optimize-autoloader || error "Failed to install Composer dependencies"
fi

# Copy shared files (uploads, configs, etc.)
log "Linking shared resources..."
ln -nfs /var/www/shared/uploads "$NEW_RELEASE/uploads"
ln -nfs /var/www/shared/.env "$NEW_RELEASE/.env"

# Run tests
log "Running tests..."
if [ -f "test.sh" ]; then
    ./test.sh || error "Tests failed"
fi

# Build assets
if [ -f "webpack.config.js" ]; then
    log "Building assets..."
    npm run build || error "Failed to build assets"
fi

# Update symlink (atomic operation)
log "Switching to new release..."
ln -nfs "$NEW_RELEASE" "$APP_DIR.new"
mv -Tf "$APP_DIR.new" "$APP_DIR"

# Reload application
log "Reloading application..."
if [ -f "$APP_DIR/ecosystem.config.js" ]; then
    pm2 reload ecosystem.config.js
elif [ -f "/etc/systemd/system/app.service" ]; then
    sudo systemctl reload app
else
    sudo systemctl reload php8.1-fpm
    sudo systemctl reload nginx
fi

# Clean up old releases (keep last 5)
log "Cleaning up old releases..."
cd "$DEPLOY_DIR"
ls -t | tail -n +6 | xargs rm -rf

log "Deployment completed successfully!"
```

### Process Management with Systemd

#### Creating Systemd Service for Python App

```bash
sudo nano /etc/systemd/system/python-app.service
```

```ini
[Unit]
Description=Python Flask Application
After=network.target mysql.service
Wants=mysql.service

[Service]
Type=notify
User=www-data
Group=www-data
RuntimeDirectory=python-app
WorkingDirectory=/var/www/python-app
Environment="PATH=/var/www/python-app/venv/bin"
Environment="FLASK_ENV=production"
ExecStart=/var/www/python-app/venv/bin/gunicorn \
    --workers 3 \
    --bind unix:/run/python-app/app.sock \
    --access-logfile /var/log/python-app/access.log \
    --error-logfile /var/log/python-app/error.log \
    app:app
ExecReload=/bin/kill -s HUP $MAINPID
KillMode=mixed
KillSignal=SIGQUIT
TimeoutStopSec=5
Restart=always
RestartSec=10

# Security
NoNewPrivileges=true
PrivateTmp=true
ProtectHome=true
ProtectSystem=strict
ReadWritePaths=/var/www/python-app /var/log/python-app

[Install]
WantedBy=multi-user.target
```

#### Node.js Systemd Service

```bash
sudo nano /etc/systemd/system/node-app.service
```

```ini
[Unit]
Description=Node.js Express Application
After=network.target
Wants=redis.service mysql.service

[Service]
Type=simple
User=nodejs
Group=nodejs
WorkingDirectory=/var/www/node-app
Environment=NODE_ENV=production
Environment=PORT=3000
ExecStart=/usr/bin/node app.js
Restart=always
RestartSec=10

# Output to journal
StandardOutput=journal
StandardError=journal
SyslogIdentifier=node-app

# Resource limits
LimitNOFILE=65536
MemoryLimit=512M
CPUQuota=80%

# Security
NoNewPrivileges=true
PrivateTmp=true
ProtectHome=true
ProtectSystem=full

[Install]
WantedBy=multi-user.target
```

```bash
# Enable and start services
sudo systemctl daemon-reload
sudo systemctl enable python-app
sudo systemctl start python-app
sudo systemctl enable node-app
sudo systemctl start node-app

# Check status
sudo systemctl status python-app
sudo systemctl status node-app

# View logs
journalctl -u python-app -f
journalctl -u node-app -f
```

### Application Logging

#### Centralized Logging Setup

```bash
# Create logging configuration
sudo nano /etc/rsyslog.d/apps.conf
```

```conf
# Python application logs
:programname, isequal, "python-app" /var/log/apps/python-app.log
& stop

# Node.js application logs
:programname, isequal, "node-app" /var/log/apps/node-app.log
& stop

# PHP application logs
:programname, isequal, "php-app" /var/log/apps/php-app.log
& stop
```

```bash
# Create log directory
sudo mkdir -p /var/log/apps
sudo chmod 755 /var/log/apps

# Restart rsyslog
sudo systemctl restart rsyslog
```

#### Log Rotation Configuration

```bash
sudo nano /etc/logrotate.d/applications
```

```conf
/var/log/apps/*.log {
    daily
    missingok
    rotate 30
    compress
    delaycompress
    notifempty
    create 0644 www-data www-data
    sharedscripts
    postrotate
        systemctl reload rsyslog > /dev/null 2>&1 || true
    endscript
}

/var/log/python-app/*.log {
    daily
    missingok
    rotate 14
    compress
    delaycompress
    notifempty
    create 0644 www-data www-data
    sharedscripts
    postrotate
        systemctl reload python-app > /dev/null 2>&1 || true
    endscript
}

/var/log/node-app/*.log {
    daily
    missingok
    rotate 14
    compress
    delaycompress
    notifempty
    create 0644 nodejs nodejs
    sharedscripts
    postrotate
        pm2 reloadLogs > /dev/null 2>&1 || true
    endscript
}
```

### Resource Isolation

#### Using Cgroups for Resource Limits

```bash
# Configure systemd resource limits
sudo nano /etc/systemd/system/app-limited.service
```

```ini
[Unit]
Description=Resource-Limited Application

[Service]
Type=simple
User=appuser
Group=appuser

# CPU limits
CPUQuota=50%
CPUWeight=50

# Memory limits
MemoryMax=512M
MemorySwapMax=0

# I/O limits
IOWeight=50
IOReadBandwidthMax=/dev/sda 10M
IOWriteBandwidthMax=/dev/sda 10M

# Task limits
TasksMax=100

ExecStart=/usr/bin/node /var/www/app/app.js

[Install]
WantedBy=multi-user.target
```

#### Using systemd-run for Temporary Limits

```bash
# Run command with resource limits
systemd-run --uid=www-data --gid=www-data \
    --property=MemoryMax=256M \
    --property=CPUQuota=25% \
    --property=IOWeight=10 \
    /usr/bin/python3 /var/www/scripts/intensive-task.py

# Run with time limit
systemd-run --on-active=30s --timer-property=AccuracySec=1s \
    /usr/local/bin/cleanup-script.sh
```

### Application Monitoring

#### Health Check Scripts

```bash
# Create health check script
sudo nano /usr/local/bin/check-apps.sh
```

```bash
#!/bin/bash
# Application health check script

ALERT_EMAIL="admin@example.com"
LOG_FILE="/var/log/app-health.log"

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

check_http_endpoint() {
    local app_name=$1
    local url=$2
    local expected_status=${3:-200}

    status=$(curl -s -o /dev/null -w "%{http_code}" "$url")

    if [ "$status" -eq "$expected_status" ]; then
        log "✓ $app_name is healthy (HTTP $status)"
        return 0
    else
        log "✗ $app_name is unhealthy (HTTP $status, expected $expected_status)"
        echo "$app_name health check failed" | mail -s "App Alert: $app_name" "$ALERT_EMAIL"
        return 1
    fi
}

check_process() {
    local app_name=$1
    local process_name=$2

    if pgrep -f "$process_name" > /dev/null; then
        log "✓ $app_name process is running"
        return 0
    else
        log "✗ $app_name process is not running"

        # Attempt restart
        systemctl restart "$app_name"
        sleep 5

        if pgrep -f "$process_name" > /dev/null; then
            log "✓ $app_name restarted successfully"
        else
            log "✗ Failed to restart $app_name"
            echo "$app_name failed to restart" | mail -s "Critical: $app_name Down" "$ALERT_EMAIL"
        fi
        return 1
    fi
}

check_port() {
    local app_name=$1
    local port=$2

    if nc -z localhost "$port"; then
        log "✓ $app_name port $port is open"
        return 0
    else
        log "✗ $app_name port $port is closed"
        return 1
    fi
}

# Main checks
log "Starting application health checks"

# Check Python app
check_http_endpoint "Python Flask" "http://localhost:5000/health" 200
check_process "python-app" "gunicorn"

# Check Node.js app
check_http_endpoint "Node Express" "http://localhost:3000/health" 200
check_port "Node.js" 3000

# Check PHP app
check_http_endpoint "PHP App" "http://localhost/health.php" 200
check_process "php-fpm" "php-fpm8.1"

log "Health checks completed"
```

```bash
# Make executable and schedule
sudo chmod +x /usr/local/bin/check-apps.sh
sudo crontab -e
# Add: */5 * * * * /usr/local/bin/check-apps.sh
```

### Troubleshooting Applications

#### Common Issues and Solutions

```bash
# Debug script for applications
sudo nano /usr/local/bin/debug-app.sh
```

```bash
#!/bin/bash
# Application debugging script

APP_TYPE=$1
APP_NAME=$2

debug_python() {
    echo "=== Python App Debug ==="

    # Check Python version
    python3 --version

    # Check virtual environment
    if [ -d "/var/www/$APP_NAME/venv" ]; then
        source "/var/www/$APP_NAME/venv/bin/activate"
        pip list
        deactivate
    fi

    # Check service status
    systemctl status "$APP_NAME"

    # Check recent logs
    journalctl -u "$APP_NAME" -n 50

    # Check port binding
    sudo ss -tlnp | grep python

    # Memory usage
    ps aux | grep -E "python|gunicorn" | grep -v grep
}

debug_nodejs() {
    echo "=== Node.js App Debug ==="

    # Check Node version
    node --version
    npm --version

    # Check PM2 status
    pm2 list
    pm2 show "$APP_NAME"

    # Check logs
    pm2 logs "$APP_NAME" --lines 50

    # Check port binding
    sudo ss -tlnp | grep node

    # Memory usage
    ps aux | grep node | grep -v grep
}

debug_php() {
    echo "=== PHP App Debug ==="

    # Check PHP version
    php -v

    # Check PHP-FPM status
    systemctl status php8.1-fpm

    # Check PHP-FPM pool
    sudo php-fpm8.1 -tt

    # Check error logs
    tail -50 /var/log/php/error.log

    # Check OPcache status
    php -r "var_dump(opcache_get_status());"

    # Check loaded extensions
    php -m
}

case "$APP_TYPE" in
    python)
        debug_python
        ;;
    node)
        debug_nodejs
        ;;
    php)
        debug_php
        ;;
    *)
        echo "Usage: $0 {python|node|php} app_name"
        exit 1
        ;;
esac
```

---

## Chapter 21: Local Development Environment

### Setting Up Development Tools

#### Essential Development Packages

```bash
# Install development essentials
sudo apt update
sudo apt install -y \
    build-essential \
    curl \
    wget \
    git \
    vim \
    nano \
    htop \
    tree \
    jq \
    unzip \
    software-properties-common \
    apt-transport-https \
    ca-certificates \
    gnupg \
    lsb-release

# Install development libraries
sudo apt install -y \
    libssl-dev \
    libffi-dev \
    libxml2-dev \
    libxslt1-dev \
    libpq-dev \
    libmysqlclient-dev \
    libsqlite3-dev \
    libcurl4-openssl-dev \
    libjpeg-dev \
    libpng-dev \
    libfreetype6-dev
```

#### Code Editors Setup

```bash
# Install VS Code Server (for remote development)
curl -fsSL https://code-server.dev/install.sh | sh

# Configure code-server
sudo nano ~/.config/code-server/config.yaml
```

```yaml
bind-addr: 127.0.0.1:8080
auth: password
password: your-secure-password
cert: false
```

```bash
# Start code-server
systemctl --user enable --now code-server

# Or install micro editor
curl https://getmic.ro | bash
sudo mv micro /usr/local/bin/

# Or install neovim
sudo apt install neovim -y
```

### Version Control with Git

#### Git Installation and Configuration

```bash
# Install Git
sudo apt install git -y

# Configure Git globally
git config --global user.name "Your Name"
git config --global user.email "your.email@example.com"
git config --global core.editor "nano"
git config --global init.defaultBranch main

# Useful Git aliases
git config --global alias.co checkout
git config --global alias.br branch
git config --global alias.ci commit
git config --global alias.st status
git config --global alias.unstage 'reset HEAD --'
git config --global alias.last 'log -1 HEAD'
git config --global alias.visual '!gitk'

# View configuration
git config --list
```

#### Git Workflow for Projects

```bash
# Initialize new repository
cd /var/www/myproject
git init

# Create .gitignore
nano .gitignore
```

```gitignore
# Dependencies
node_modules/
vendor/
venv/
__pycache__/
*.pyc

# Environment files
.env
.env.local
.env.*.local

# Logs
logs/
*.log
npm-debug.log*
yarn-debug.log*
yarn-error.log*

# IDE
.idea/
.vscode/
*.swp
*.swo
.DS_Store

# Build outputs
dist/
build/
*.egg-info/
public/hot
public/storage
storage/*.key

# Testing
coverage/
.nyc_output/
.pytest_cache/
htmlcov/

# Database
*.sqlite
*.db
```

```bash
# Add and commit files
git add .
git commit -m "Initial commit"

# Create development branch
git checkout -b develop

# Create feature branch
git checkout -b feature/new-feature

# Work on feature...
git add .
git commit -m "Add new feature"

# Merge back to develop
git checkout develop
git merge feature/new-feature

# Delete feature branch
git branch -d feature/new-feature
```

#### Git Hooks for Development

```bash
# Create pre-commit hook
nano .git/hooks/pre-commit
```

```bash
#!/bin/bash
# Pre-commit hook for code quality

echo "Running pre-commit checks..."

# Check for debugging statements
if git diff --cached --name-only | xargs grep -E "console\.log|print\(|var_dump" > /dev/null 2>&1; then
    echo "Error: Found debugging statements"
    echo "Please remove them before committing"
    exit 1
fi

# Run linters based on file types
for file in $(git diff --cached --name-only); do
    if [[ "$file" =~ \.py$ ]]; then
        # Python linting
        if command -v pylint > /dev/null; then
            pylint "$file"
            if [ $? -ne 0 ]; then
                echo "Python linting failed for $file"
                exit 1
            fi
        fi
    elif [[ "$file" =~ \.js$ ]]; then
        # JavaScript linting
        if command -v eslint > /dev/null; then
            eslint "$file"
            if [ $? -ne 0 ]; then
                echo "JavaScript linting failed for $file"
                exit 1
            fi
        fi
    elif [[ "$file" =~ \.php$ ]]; then
        # PHP linting
        php -l "$file"
        if [ $? -ne 0 ]; then
            echo "PHP syntax error in $file"
            exit 1
        fi
    fi
done

echo "Pre-commit checks passed!"
```

```bash
# Make hook executable
chmod +x .git/hooks/pre-commit
```

### Database Development Instances

#### MySQL Development Setup

```bash
# Create development database
mysql -u root -p
```

```sql
-- Create development database
CREATE DATABASE dev_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- Create development user
CREATE USER 'dev_user'@'localhost' IDENTIFIED BY 'dev_password';
GRANT ALL PRIVILEGES ON dev_db.* TO 'dev_user'@'localhost';
GRANT CREATE, DROP ON *.* TO 'dev_user'@'localhost';  -- For testing

-- Create test database
CREATE DATABASE test_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
GRANT ALL PRIVILEGES ON test_db.* TO 'dev_user'@'localhost';

FLUSH PRIVILEGES;
```

```bash
# Create database backup/restore scripts
nano /usr/local/bin/dev-db-backup.sh
```

```bash
#!/bin/bash
# Development database backup

DB_NAME="dev_db"
BACKUP_DIR="/var/backups/dev-db"
DATE=$(date +%Y%m%d_%H%M%S)

mkdir -p "$BACKUP_DIR"

# Backup structure and data separately
mysqldump -u dev_user -pdev_password --no-data "$DB_NAME" > "$BACKUP_DIR/schema_$DATE.sql"
mysqldump -u dev_user -pdev_password --no-create-info "$DB_NAME" > "$BACKUP_DIR/data_$DATE.sql"

# Create combined backup
mysqldump -u dev_user -pdev_password "$DB_NAME" > "$BACKUP_DIR/full_$DATE.sql"

echo "Backup created: $BACKUP_DIR/full_$DATE.sql"

# Keep only last 10 backups
cd "$BACKUP_DIR"
ls -t full_*.sql | tail -n +11 | xargs rm -f
```

#### PostgreSQL Development Setup

```bash
# Create development cluster
sudo pg_createcluster 14 dev -p 5433
sudo systemctl start postgresql@14-dev

# Connect to dev instance
sudo -u postgres psql -p 5433
```

```sql
-- Create development database
CREATE DATABASE dev_db;
CREATE USER dev_user WITH PASSWORD 'dev_password';
GRANT ALL PRIVILEGES ON DATABASE dev_db TO dev_user;
ALTER DATABASE dev_db OWNER TO dev_user;

-- Enable extensions
\c dev_db
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";
```

#### Redis Development Instance

```bash
# Install Redis
sudo apt install redis-server -y

# Create development configuration
sudo cp /etc/redis/redis.conf /etc/redis/redis-dev.conf
sudo nano /etc/redis/redis-dev.conf
```

```conf
# Development Redis configuration
port 6380
pidfile /var/run/redis/redis-server-dev.pid
logfile /var/log/redis/redis-server-dev.log
dir /var/lib/redis-dev
dbfilename dump-dev.rdb

# Development settings
protected-mode no
maxmemory 256mb
maxmemory-policy allkeys-lru

# Enable keyspace notifications
notify-keyspace-events KEA

# Persistence
save 900 1
save 300 10
save 60 10000
```

```bash
# Create systemd service for dev Redis
sudo nano /etc/systemd/system/redis-dev.service
```

```ini
[Unit]
Description=Redis Development Instance
After=network.target

[Service]
Type=notify
ExecStart=/usr/bin/redis-server /etc/redis/redis-dev.conf --supervised systemd
ExecStop=/usr/bin/redis-cli -p 6380 shutdown
TimeoutStopSec=0
Restart=always
User=redis
Group=redis

RuntimeDirectory=redis
RuntimeDirectoryMode=0755

[Install]
WantedBy=multi-user.target
```

```bash
# Start development Redis
sudo systemctl daemon-reload
sudo systemctl enable redis-dev
sudo systemctl start redis-dev

# Test connection
redis-cli -p 6380 ping
```

### Testing Environments

#### Setting Up Testing Framework

```bash
# Python testing with pytest
pip install pytest pytest-cov pytest-env

# Create test configuration
nano pytest.ini
```

```ini
[tool:pytest]
testpaths = tests
python_files = test_*.py
python_classes = Test*
python_functions = test_*
addopts = -v --tb=short --strict-markers --cov=app --cov-report=html
env_files = .env.test
```

```bash
# Node.js testing with Jest
npm install --save-dev jest supertest @types/jest

# Configure Jest
nano jest.config.js
```

```javascript
module.exports = {
    testEnvironment: 'node',
    coverageDirectory: 'coverage',
    collectCoverageFrom: [
        'src/**/*.js',
        '!src/index.js',
        '!src/**/*.test.js'
    ],
    testMatch: [
        '**/__tests__/**/*.js',
        '**/?(*.)+(spec|test).js'
    ],
    verbose: true,
    testTimeout: 10000
};
```

```bash
# PHP testing with PHPUnit
composer require --dev phpunit/phpunit

# Create PHPUnit configuration
nano phpunit.xml
```

```xml
<?xml version="1.0" encoding="UTF-8"?>
<phpunit bootstrap="vendor/autoload.php"
         colors="true"
         verbose="true"
         stopOnFailure="false">
    <testsuites>
        <testsuite name="Application Test Suite">
            <directory>tests</directory>
        </testsuite>
    </testsuites>
    <coverage>
        <include>
            <directory suffix=".php">src</directory>
        </include>
    </coverage>
    <php>
        <env name="APP_ENV" value="testing"/>
        <env name="DB_CONNECTION" value="sqlite"/>
        <env name="DB_DATABASE" value=":memory:"/>
    </php>
</phpunit>
```

#### Automated Testing Scripts

```bash
# Create test runner script
nano /usr/local/bin/run-tests.sh
```

```bash
#!/bin/bash
# Automated testing script

PROJECT_DIR="/var/www/app"
RESULTS_DIR="/var/www/test-results"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)

mkdir -p "$RESULTS_DIR"

run_python_tests() {
    echo "Running Python tests..."
    cd "$PROJECT_DIR"
    source venv/bin/activate
    pytest --cov-report=html:"$RESULTS_DIR/python-coverage-$TIMESTAMP" \
           --junit-xml="$RESULTS_DIR/python-results-$TIMESTAMP.xml"
    deactivate
}

run_node_tests() {
    echo "Running Node.js tests..."
    cd "$PROJECT_DIR"
    npm test -- --coverage --coverageDirectory="$RESULTS_DIR/node-coverage-$TIMESTAMP" \
                --reporters=default --reporters=jest-junit \
                --outputFile="$RESULTS_DIR/node-results-$TIMESTAMP.xml"
}

run_php_tests() {
    echo "Running PHP tests..."
    cd "$PROJECT_DIR"
    vendor/bin/phpunit --coverage-html "$RESULTS_DIR/php-coverage-$TIMESTAMP" \
                       --log-junit "$RESULTS_DIR/php-results-$TIMESTAMP.xml"
}

# Detect and run appropriate tests
if [ -f "$PROJECT_DIR/pytest.ini" ]; then
    run_python_tests
elif [ -f "$PROJECT_DIR/jest.config.js" ]; then
    run_node_tests
elif [ -f "$PROJECT_DIR/phpunit.xml" ]; then
    run_php_tests
else
    echo "No test configuration found"
    exit 1
fi

echo "Tests completed. Results in $RESULTS_DIR"
```

### Port Forwarding for Development

#### SSH Port Forwarding

```bash
# Local port forwarding (access remote service locally)
# Forward local port 8080 to remote server's port 3000
ssh -L 8080:localhost:3000 user@remote-server

# Remote port forwarding (expose local service to remote)
# Forward remote port 8080 to local port 3000
ssh -R 8080:localhost:3000 user@remote-server

# Dynamic port forwarding (SOCKS proxy)
ssh -D 9090 user@remote-server

# Multiple port forwarding
ssh -L 8080:localhost:80 \
    -L 3306:localhost:3306 \
    -L 6379:localhost:6379 \
    user@remote-server

# Create SSH config for easy access
nano ~/.ssh/config
```

```
Host dev-server
    HostName server.example.com
    User developer
    Port 22
    LocalForward 8080 localhost:80
    LocalForward 3306 localhost:3306
    LocalForward 5432 localhost:5432
    LocalForward 6379 localhost:6379
    ServerAliveInterval 60
    ServerAliveCountMax 3
```

```bash
# Connect with configured forwarding
ssh dev-server
```

#### Nginx Reverse Proxy for Development

```bash
# Configure Nginx for development proxy
sudo nano /etc/nginx/sites-available/dev-proxy
```

```nginx
# Development proxy configuration
upstream app_backend {
    server localhost:3000;  # Node.js app
    server localhost:3001 backup;
}

upstream api_backend {
    server localhost:5000;  # Python API
}

server {
    listen 80;
    server_name dev.local;

    # Main application
    location / {
        proxy_pass http://app_backend;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_cache_bypass $http_upgrade;

        # Development headers
        add_header X-Dev-Server $upstream_addr;
        add_header X-Response-Time $upstream_response_time;
    }

    # API proxy
    location /api/ {
        proxy_pass http://api_backend/;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
    }

    # WebSocket support
    location /ws {
        proxy_pass http://app_backend;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
    }

    # Static files (skip proxy)
    location /static/ {
        alias /var/www/static/;
        expires 1h;
    }
}
```

```bash
# Enable development proxy
sudo ln -s /etc/nginx/sites-available/dev-proxy /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl reload nginx

# Add to /etc/hosts for local development
echo "127.0.0.1 dev.local" | sudo tee -a /etc/hosts
```

### Development vs Production Configs

#### Environment-based Configuration

```bash
# Create environment management script
nano /usr/local/bin/switch-env.sh
```

```bash
#!/bin/bash
# Switch between development and production environments

ENV=${1:-dev}
APP_DIR="/var/www/app"

switch_python() {
    cd "$APP_DIR"

    if [ "$ENV" = "prod" ]; then
        cp .env.production .env
        export FLASK_ENV=production
        export FLASK_DEBUG=False
    else
        cp .env.development .env
        export FLASK_ENV=development
        export FLASK_DEBUG=True
    fi

    # Restart application
    systemctl restart python-app
}

switch_node() {
    cd "$APP_DIR"

    if [ "$ENV" = "prod" ]; then
        cp .env.production .env
        export NODE_ENV=production
        npm run build
        pm2 restart app --env production
    else
        cp .env.development .env
        export NODE_ENV=development
        pm2 restart app --env development --watch
    fi
}

switch_php() {
    cd "$APP_DIR"

    if [ "$ENV" = "prod" ]; then
        cp .env.production .env
        php artisan config:cache
        php artisan route:cache
        php artisan view:cache
        php artisan optimize
    else
        cp .env.development .env
        php artisan config:clear
        php artisan route:clear
        php artisan view:clear
        php artisan cache:clear
    fi

    systemctl restart php8.1-fpm
}

echo "Switching to $ENV environment..."

# Detect application type and switch
if [ -f "$APP_DIR/requirements.txt" ]; then
    switch_python
elif [ -f "$APP_DIR/package.json" ]; then
    switch_node
elif [ -f "$APP_DIR/composer.json" ]; then
    switch_php
fi

echo "Environment switched to $ENV"
```

#### Development Tools Configuration

```bash
# Create development utilities
nano /usr/local/bin/dev-utils.sh
```

```bash
#!/bin/bash
# Development utility functions

# Database refresh from production
refresh_db() {
    echo "Refreshing development database from production..."

    # Backup current dev database
    mysqldump -u dev_user -pdev_password dev_db > /tmp/dev_db_backup.sql

    # Get production dump (sanitized)
    ssh prod-server "mysqldump -u user -p prod_db | sed 's/user@prod.com/user@dev.local/g'" > /tmp/prod_dump.sql

    # Import to dev
    mysql -u dev_user -pdev_password dev_db < /tmp/prod_dump.sql

    echo "Database refreshed"
}

# Start all development services
start_dev() {
    echo "Starting development environment..."

    # Start databases
    systemctl start mysql
    systemctl start postgresql
    systemctl start redis-dev

    # Start applications in development mode
    cd /var/www/app
    if [ -f "package.json" ]; then
        npm run dev &
    elif [ -f "requirements.txt" ]; then
        source venv/bin/activate
        python app.py --debug &
    elif [ -f "composer.json" ]; then
        php artisan serve --host=0.0.0.0 --port=8000 &
    fi

    echo "Development environment started"
}

# Stop all development services
stop_dev() {
    echo "Stopping development environment..."

    # Kill development processes
    pkill -f "npm run dev"
    pkill -f "python app.py"
    pkill -f "artisan serve"

    echo "Development environment stopped"
}

# Show development URLs
show_urls() {
    echo "Development URLs:"
    echo "  Main App: http://localhost:3000"
    echo "  API: http://localhost:5000"
    echo "  Database Admin: http://localhost:8080"
    echo "  Mail Catcher: http://localhost:1080"
    echo "  Redis Commander: http://localhost:8081"
}

# Main menu
case "$1" in
    refresh-db)
        refresh_db
        ;;
    start)
        start_dev
        ;;
    stop)
        stop_dev
        ;;
    urls)
        show_urls
        ;;
    *)
        echo "Usage: $0 {refresh-db|start|stop|urls}"
        exit 1
        ;;
esac
```

---

## Practice Exercises

### Exercise 1: Deploy Multi-Language Application
1. Set up a Python Flask API
2. Create a Node.js frontend application
3. Configure PHP admin panel
4. Set up Nginx to route to all three applications
5. Implement proper logging and monitoring

### Exercise 2: Development Environment Setup
1. Configure Git with hooks for code quality
2. Set up development and test databases
3. Implement automated testing for an application
4. Configure port forwarding for remote development
5. Create scripts to switch between dev/prod environments

### Exercise 3: Process Management
1. Create systemd services for different applications
2. Implement resource limits using cgroups
3. Set up PM2 for Node.js application
4. Configure automatic restarts on failure
5. Implement health checks and alerts

### Exercise 4: Performance Optimization
1. Configure application caching
2. Optimize application startup time
3. Implement connection pooling for databases
4. Set up load testing with Apache Bench
5. Monitor and optimize resource usage

---

## Quick Reference

### Application Commands
```bash
# Python
python3 -m venv venv          # Create virtual environment
source venv/bin/activate      # Activate venv
pip install -r requirements.txt # Install dependencies
gunicorn app:app              # Start WSGI server

# Node.js
npm install                    # Install dependencies
npm run dev                    # Development mode
npm run build                  # Build for production
pm2 start app.js              # Start with PM2

# PHP
composer install              # Install dependencies
php artisan serve            # Development server
php-fpm                      # Start PHP-FPM
```

### Process Management
```bash
# Systemd
systemctl start app           # Start service
systemctl stop app            # Stop service
systemctl restart app         # Restart service
systemctl status app          # Check status
journalctl -u app -f          # View logs

# PM2
pm2 start app.js             # Start application
pm2 list                     # List processes
pm2 logs app                 # View logs
pm2 restart app              # Restart
pm2 save                     # Save configuration
```

### Development Tools
```bash
# Git
git status                    # Check status
git add .                     # Stage changes
git commit -m "message"       # Commit
git push origin branch        # Push to remote
git pull                      # Pull changes

# Testing
pytest                        # Run Python tests
npm test                      # Run Node tests
phpunit                       # Run PHP tests

# Database
mysql -u user -p              # Connect to MySQL
psql -U user -d database      # Connect to PostgreSQL
redis-cli                     # Connect to Redis
```

---

## Additional Resources

### Language-Specific Resources
- [Python Deployment Guide](https://docs.python-guide.org/shipping/deployment/)
- [Node.js Best Practices](https://github.com/goldbergyoni/nodebestpractices)
- [PHP: The Right Way](https://phptherightway.com/)
- [12 Factor App](https://12factor.net/)

### Process Management
- [Systemd Documentation](https://www.freedesktop.org/software/systemd/man/)
- [PM2 Documentation](https://pm2.keymetrics.io/docs/)
- [Supervisor Documentation](http://supervisord.org/)

### Development Tools
- [Git Documentation](https://git-scm.com/doc)
- [Docker for Development](https://docs.docker.com/develop/)
- [VS Code Remote Development](https://code.visualstudio.com/docs/remote/remote-overview)

### Performance and Monitoring
- [Application Performance Monitoring](https://www.datadoghq.com/knowledge-center/apm/)
- [New Relic Documentation](https://docs.newrelic.com/)
- [Prometheus Application Monitoring](https://prometheus.io/docs/guides/go-application/)

### Next Steps
After completing this section, you should:
- Be able to deploy applications in Python, Node.js, and PHP
- Understand process management and resource isolation
- Know how to set up development environments
- Be able to implement monitoring and health checks
- Have a complete development workflow configured

Continue to Part 10 to learn about troubleshooting and recovery procedures.