# Part 8: Web and Database Servers

## Prerequisites

Before starting this section, you should understand:
- Basic networking concepts (ports, protocols, IP addresses)
- How to manage services with systemctl
- Basic file permissions and ownership
- How to edit configuration files
- Package management with APT

**Learning Resources:**
- [Nginx Documentation](https://nginx.org/en/docs/)
- [Apache Documentation](https://httpd.apache.org/docs/)
- [MySQL Documentation](https://dev.mysql.com/doc/)
- [PostgreSQL Documentation](https://www.postgresql.org/docs/)

---

## Chapter 18: Web Server Administration

### Introduction to Web Servers

A web server is software that serves web content to clients (browsers) over HTTP/HTTPS. The two most popular web servers for Ubuntu are:

1. **Nginx** - High-performance, lightweight, excellent for static content and as a reverse proxy
2. **Apache** - Feature-rich, highly configurable, excellent module ecosystem

We'll focus primarily on Nginx but also cover Apache basics.

### Nginx Installation and Configuration

#### Installing Nginx

```bash
# Update package index
sudo apt update

# Install Nginx
sudo apt install nginx -y

# Check version
nginx -v

# Start and enable Nginx
sudo systemctl start nginx
sudo systemctl enable nginx

# Check status
sudo systemctl status nginx

# Test configuration
sudo nginx -t

# View Nginx processes
ps aux | grep nginx
```

#### Understanding Nginx Architecture

```bash
# Nginx directory structure
ls -la /etc/nginx/

# Key directories and files:
# /etc/nginx/nginx.conf         - Main configuration file
# /etc/nginx/sites-available/   - Available site configurations
# /etc/nginx/sites-enabled/     - Enabled site configurations (symlinks)
# /etc/nginx/conf.d/           - Additional configuration files
# /etc/nginx/snippets/         - Reusable configuration snippets

# Default web root
ls -la /var/www/html/

# Nginx logs
ls -la /var/log/nginx/
# access.log - Request logs
# error.log  - Error logs
```

#### Basic Nginx Configuration

```bash
# Main configuration file
sudo nano /etc/nginx/nginx.conf
```

```nginx
# Main context - global settings
user www-data;
worker_processes auto;  # Number of worker processes
pid /run/nginx.pid;
include /etc/nginx/modules-enabled/*.conf;

# Events context - connection processing
events {
    worker_connections 768;  # Max connections per worker
    multi_accept on;         # Accept multiple connections
    use epoll;              # Connection processing method
}

# HTTP context - HTTP server settings
http {
    ##
    # Basic Settings
    ##
    sendfile on;
    tcp_nopush on;
    tcp_nodelay on;
    keepalive_timeout 65;
    types_hash_max_size 2048;
    server_tokens off;  # Hide Nginx version

    # MIME types
    include /etc/nginx/mime.types;
    default_type application/octet-stream;

    ##
    # SSL Settings
    ##
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers ECDHE-RSA-AES128-GCM-SHA256:ECDHE-RSA-AES256-GCM-SHA384;
    ssl_prefer_server_ciphers off;

    ##
    # Logging Settings
    ##
    access_log /var/log/nginx/access.log;
    error_log /var/log/nginx/error.log;

    ##
    # Gzip Settings
    ##
    gzip on;
    gzip_vary on;
    gzip_proxied any;
    gzip_comp_level 6;
    gzip_types text/plain text/css text/xml text/javascript
               application/json application/javascript application/xml+rss
               application/rss+xml application/atom+xml image/svg+xml
               text/x-js text/x-cross-domain-policy application/x-font-ttf
               application/x-font-opentype application/vnd.ms-fontobject
               image/x-icon;

    ##
    # Virtual Host Configs
    ##
    include /etc/nginx/conf.d/*.conf;
    include /etc/nginx/sites-enabled/*;
}
```

#### Creating Your First Website

```bash
# Create a new site configuration
sudo nano /etc/nginx/sites-available/mywebsite
```

```nginx
server {
    listen 80;
    listen [::]:80;

    # Server name (domain or IP)
    server_name mywebsite.com www.mywebsite.com;

    # Document root
    root /var/www/mywebsite;
    index index.html index.htm index.php;

    # Logging
    access_log /var/log/nginx/mywebsite_access.log;
    error_log /var/log/nginx/mywebsite_error.log;

    # Main location block
    location / {
        try_files $uri $uri/ =404;
    }

    # Deny access to .htaccess files
    location ~ /\.ht {
        deny all;
    }

    # Static file caching
    location ~* \.(jpg|jpeg|png|gif|ico|css|js)$ {
        expires 365d;
        add_header Cache-Control "public, immutable";
    }
}
```

```bash
# Create website directory
sudo mkdir -p /var/www/mywebsite

# Set ownership
sudo chown -R www-data:www-data /var/www/mywebsite

# Create test page
sudo nano /var/www/mywebsite/index.html
```

```html
<!DOCTYPE html>
<html>
<head>
    <title>Welcome to My Website</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            max-width: 800px;
            margin: 50px auto;
            padding: 20px;
        }
        h1 { color: #333; }
    </style>
</head>
<body>
    <h1>Welcome to My Website</h1>
    <p>This is served by Nginx on Ubuntu Server.</p>
    <p>Server time: <span id="time"></span></p>
    <script>
        document.getElementById('time').textContent = new Date().toLocaleString();
    </script>
</body>
</html>
```

```bash
# Enable the site
sudo ln -s /etc/nginx/sites-available/mywebsite /etc/nginx/sites-enabled/

# Test configuration
sudo nginx -t

# Reload Nginx
sudo systemctl reload nginx

# Test the site
curl http://localhost
```

### Virtual Hosts Configuration

Virtual hosts allow you to host multiple websites on a single server.

#### Name-based Virtual Hosts

```bash
# Site 1 configuration
sudo nano /etc/nginx/sites-available/site1.com
```

```nginx
server {
    listen 80;
    server_name site1.com www.site1.com;
    root /var/www/site1.com;
    index index.html;

    location / {
        try_files $uri $uri/ =404;
    }
}
```

```bash
# Site 2 configuration
sudo nano /etc/nginx/sites-available/site2.com
```

```nginx
server {
    listen 80;
    server_name site2.com www.site2.com;
    root /var/www/site2.com;
    index index.html;

    location / {
        try_files $uri $uri/ =404;
    }
}
```

```bash
# Create directories and enable sites
sudo mkdir -p /var/www/{site1.com,site2.com}
sudo chown -R www-data:www-data /var/www/site1.com
sudo chown -R www-data:www-data /var/www/site2.com

# Enable both sites
sudo ln -s /etc/nginx/sites-available/site1.com /etc/nginx/sites-enabled/
sudo ln -s /etc/nginx/sites-available/site2.com /etc/nginx/sites-enabled/

# Reload Nginx
sudo nginx -t && sudo systemctl reload nginx
```

#### Port-based Virtual Hosts

```nginx
# Listen on different ports
server {
    listen 8080;
    server_name _;
    root /var/www/app1;
}

server {
    listen 8081;
    server_name _;
    root /var/www/app2;
}
```

### Local Reverse Proxy

A reverse proxy forwards client requests to backend servers. This is useful for:
- Load balancing
- Hiding backend servers
- Adding SSL/TLS termination
- Caching

#### Basic Reverse Proxy Configuration

```bash
# Configure Nginx as reverse proxy
sudo nano /etc/nginx/sites-available/reverse-proxy
```

```nginx
# Reverse proxy to local application
server {
    listen 80;
    server_name app.example.com;

    location / {
        proxy_pass http://localhost:3000;
        proxy_http_version 1.1;

        # Headers
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;

        # Timeouts
        proxy_connect_timeout 60s;
        proxy_send_timeout 60s;
        proxy_read_timeout 60s;

        # Buffering
        proxy_buffering off;
        proxy_cache_bypass $http_upgrade;
    }
}
```

#### Reverse Proxy with Load Balancing

```nginx
# Define upstream servers
upstream backend {
    least_conn;  # Load balancing method
    server localhost:3001 weight=3;
    server localhost:3002 weight=2;
    server localhost:3003 backup;

    # Health checks
    keepalive 32;
}

server {
    listen 80;
    server_name api.example.com;

    location / {
        proxy_pass http://backend;
        proxy_http_version 1.1;
        proxy_set_header Connection "";
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
    }

    # Health check endpoint
    location /health {
        access_log off;
        return 200 "healthy\n";
        add_header Content-Type text/plain;
    }
}
```

### Static Site Hosting

#### Optimized Static Site Configuration

```bash
sudo nano /etc/nginx/sites-available/static-site
```

```nginx
server {
    listen 80;
    server_name static.example.com;
    root /var/www/static-site;
    index index.html;

    # Security headers
    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header X-XSS-Protection "1; mode=block" always;
    add_header X-Content-Type-Options "nosniff" always;

    # Enable compression
    gzip on;
    gzip_types text/plain text/css application/json application/javascript text/xml application/xml application/xml+rss text/javascript;

    # Cache static assets
    location ~* \.(css|js|jpg|jpeg|png|gif|ico|svg|woff|woff2|ttf|eot)$ {
        expires 1y;
        add_header Cache-Control "public, immutable";
        access_log off;
    }

    # HTML files - shorter cache
    location ~* \.html$ {
        expires 1h;
        add_header Cache-Control "public, must-revalidate";
    }

    # Deny access to hidden files
    location ~ /\. {
        deny all;
        access_log off;
        log_not_found off;
    }

    # Custom error pages
    error_page 404 /404.html;
    error_page 500 502 503 504 /50x.html;

    location = /404.html {
        internal;
    }

    location = /50x.html {
        internal;
    }
}
```

### Apache as Alternative

#### Installing Apache

```bash
# Install Apache
sudo apt install apache2 -y

# Note: If Nginx is running, stop it first
sudo systemctl stop nginx
sudo systemctl disable nginx

# Start Apache
sudo systemctl start apache2
sudo systemctl enable apache2

# Check status
sudo systemctl status apache2
```

#### Basic Apache Configuration

```bash
# Apache directory structure
ls -la /etc/apache2/

# Key directories:
# /etc/apache2/apache2.conf      - Main configuration
# /etc/apache2/sites-available/  - Available sites
# /etc/apache2/sites-enabled/    - Enabled sites
# /etc/apache2/mods-available/   - Available modules
# /etc/apache2/mods-enabled/     - Enabled modules

# Create a virtual host
sudo nano /etc/apache2/sites-available/mysite.conf
```

```apache
<VirtualHost *:80>
    ServerName mysite.com
    ServerAlias www.mysite.com
    ServerAdmin webmaster@mysite.com
    DocumentRoot /var/www/mysite

    <Directory /var/www/mysite>
        Options Indexes FollowSymLinks
        AllowOverride All
        Require all granted
    </Directory>

    ErrorLog ${APACHE_LOG_DIR}/mysite_error.log
    CustomLog ${APACHE_LOG_DIR}/mysite_access.log combined
</VirtualHost>
```

```bash
# Enable site and required modules
sudo a2ensite mysite.conf
sudo a2enmod rewrite
sudo a2enmod headers
sudo a2enmod ssl

# Disable default site
sudo a2dissite 000-default.conf

# Test configuration
sudo apache2ctl configtest

# Reload Apache
sudo systemctl reload apache2
```

### Web Server Security

#### Nginx Security Hardening

```bash
# Security configuration
sudo nano /etc/nginx/snippets/security.conf
```

```nginx
# Security headers
add_header X-Frame-Options "SAMEORIGIN" always;
add_header X-XSS-Protection "1; mode=block" always;
add_header X-Content-Type-Options "nosniff" always;
add_header Referrer-Policy "no-referrer-when-downgrade" always;
add_header Content-Security-Policy "default-src 'self' http: https: data: blob: 'unsafe-inline'" always;
add_header Strict-Transport-Security "max-age=31536000; includeSubDomains" always;

# Disable server tokens
server_tokens off;

# Limit request methods
if ($request_method !~ ^(GET|HEAD|POST)$ ) {
    return 405;
}

# Block common exploits
location ~* "(eval\()" { deny all; }
location ~* "(127\.0\.0\.1)" { deny all; }
location ~* "([a-z0-9]{2000})" { deny all; }
location ~* "(javascript\:)(.*)(\;)" { deny all; }
location ~* "(base64_encode)(.*)(\()" { deny all; }
location ~* "(GLOBALS|REQUEST)(=|\[|%)" { deny all; }
location ~* "(<|%3C).*script.*(>|%3)" { deny all; }

# Deny access to hidden files
location ~ /\. {
    deny all;
    access_log off;
    log_not_found off;
}
```

```bash
# Include security configuration in server blocks
sudo nano /etc/nginx/sites-available/secure-site
```

```nginx
server {
    listen 80;
    server_name secure.example.com;

    # Include security settings
    include /etc/nginx/snippets/security.conf;

    # Rate limiting
    limit_req_zone $binary_remote_addr zone=one:10m rate=1r/s;
    limit_req zone=one burst=5 nodelay;

    # Connection limits
    limit_conn_zone $binary_remote_addr zone=addr:10m;
    limit_conn addr 10;

    location / {
        root /var/www/secure-site;
        index index.html;
    }
}
```

#### SSL/TLS Configuration

```bash
# Generate self-signed certificate for testing
sudo openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
    -keyout /etc/ssl/private/nginx-selfsigned.key \
    -out /etc/ssl/certs/nginx-selfsigned.crt \
    -subj "/C=US/ST=State/L=City/O=Organization/CN=example.com"

# Create strong Diffie-Hellman group
sudo openssl dhparam -out /etc/nginx/dhparam.pem 2048

# SSL configuration
sudo nano /etc/nginx/snippets/ssl-params.conf
```

```nginx
# SSL parameters
ssl_protocols TLSv1.2 TLSv1.3;
ssl_prefer_server_ciphers off;
ssl_ciphers ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-CHACHA20-POLY1305:ECDHE-RSA-CHACHA20-POLY1305:DHE-RSA-AES128-GCM-SHA256:DHE-RSA-AES256-GCM-SHA384;

ssl_session_timeout 1d;
ssl_session_cache shared:SSL:10m;
ssl_session_tickets off;

ssl_dhparam /etc/nginx/dhparam.pem;

# OCSP stapling
ssl_stapling on;
ssl_stapling_verify on;

# Resolver
resolver 8.8.8.8 8.8.4.4 valid=300s;
resolver_timeout 5s;
```

```nginx
# HTTPS server block
server {
    listen 443 ssl http2;
    listen [::]:443 ssl http2;
    server_name secure.example.com;

    ssl_certificate /etc/ssl/certs/nginx-selfsigned.crt;
    ssl_certificate_key /etc/ssl/private/nginx-selfsigned.key;

    include /etc/nginx/snippets/ssl-params.conf;
    include /etc/nginx/snippets/security.conf;

    root /var/www/secure-site;
    index index.html;
}

# Redirect HTTP to HTTPS
server {
    listen 80;
    listen [::]:80;
    server_name secure.example.com;
    return 301 https://$server_name$request_uri;
}
```

### Performance Optimization

#### Nginx Performance Tuning

```bash
# Performance optimized configuration
sudo nano /etc/nginx/nginx.conf
```

```nginx
# Worker processes and connections
worker_processes auto;
worker_rlimit_nofile 65535;

events {
    worker_connections 4096;
    use epoll;
    multi_accept on;
}

http {
    # File handling
    sendfile on;
    tcp_nopush on;
    tcp_nodelay on;

    # Keepalive
    keepalive_timeout 65;
    keepalive_requests 100;

    # Buffers
    client_body_buffer_size 128k;
    client_max_body_size 10m;
    client_header_buffer_size 1k;
    large_client_header_buffers 4 8k;
    output_buffers 32 32k;
    postpone_output 1460;

    # Timeouts
    client_header_timeout 60s;
    client_body_timeout 60s;
    send_timeout 60s;

    # File cache
    open_file_cache max=1000 inactive=20s;
    open_file_cache_valid 30s;
    open_file_cache_min_uses 2;
    open_file_cache_errors on;

    # Gzip compression
    gzip on;
    gzip_vary on;
    gzip_proxied any;
    gzip_comp_level 6;
    gzip_min_length 256;
    gzip_types
        application/atom+xml
        application/geo+json
        application/javascript
        application/x-javascript
        application/json
        application/ld+json
        application/manifest+json
        application/rdf+xml
        application/rss+xml
        application/xhtml+xml
        application/xml
        font/eot
        font/otf
        font/ttf
        image/svg+xml
        text/css
        text/javascript
        text/plain
        text/xml;
}
```

#### Caching Configuration

```nginx
# FastCGI cache for dynamic content
fastcgi_cache_path /var/cache/nginx levels=1:2
                   keys_zone=FASTCGI:100m
                   inactive=60m
                   max_size=1g;

# Proxy cache for reverse proxy
proxy_cache_path /var/cache/nginx/proxy
                 levels=1:2
                 keys_zone=PROXY:100m
                 inactive=60m
                 max_size=1g;

server {
    # FastCGI caching example (PHP)
    location ~ \.php$ {
        fastcgi_pass unix:/var/run/php/php8.1-fpm.sock;
        fastcgi_index index.php;
        include fastcgi_params;

        # Cache configuration
        fastcgi_cache FASTCGI;
        fastcgi_cache_valid 200 60m;
        fastcgi_cache_valid 404 10m;
        fastcgi_cache_bypass $no_cache;
        fastcgi_no_cache $no_cache;

        # Cache key
        fastcgi_cache_key "$scheme$request_method$host$request_uri";

        # Add cache status header
        add_header X-Cache-Status $upstream_cache_status;
    }

    # Set cache bypass conditions
    set $no_cache 0;

    # Don't cache POST requests
    if ($request_method = POST) {
        set $no_cache 1;
    }

    # Don't cache URLs with query string
    if ($query_string != "") {
        set $no_cache 1;
    }

    # Don't cache logged in users (cookie example)
    if ($http_cookie ~* "logged_in") {
        set $no_cache 1;
    }
}
```

---

## Chapter 19: Database Server Management

### Introduction to Database Servers

Database servers store and manage structured data for applications. We'll cover:
1. **MySQL/MariaDB** - Popular relational database
2. **PostgreSQL** - Advanced open-source relational database

### MySQL/MariaDB Setup

#### Installing MySQL

```bash
# Install MySQL Server
sudo apt update
sudo apt install mysql-server -y

# Check version
mysql --version

# Start and enable MySQL
sudo systemctl start mysql
sudo systemctl enable mysql

# Check status
sudo systemctl status mysql
```

#### Securing MySQL Installation

```bash
# Run security script
sudo mysql_secure_installation

# This script will:
# 1. Set root password
# 2. Remove anonymous users
# 3. Disallow root login remotely
# 4. Remove test database
# 5. Reload privilege tables

# Answer the prompts:
# - Set password validation plugin? Y
# - Password validation level? 2 (STRONG)
# - Enter root password: [your-strong-password]
# - Remove anonymous users? Y
# - Disallow root login remotely? Y
# - Remove test database? Y
# - Reload privilege tables? Y
```

#### MySQL Configuration

```bash
# Main configuration file
sudo nano /etc/mysql/mysql.conf.d/mysqld.cnf
```

```ini
[mysqld]
# Basic Settings
user            = mysql
pid-file        = /var/run/mysqld/mysqld.pid
socket          = /var/run/mysqld/mysqld.sock
port            = 3306
datadir         = /var/lib/mysql

# Network
bind-address    = 127.0.0.1  # Only local connections
mysqlx-bind-address = 127.0.0.1

# Character Set
character-set-server = utf8mb4
collation-server = utf8mb4_unicode_ci

# Performance
key_buffer_size         = 16M
max_allowed_packet      = 64M
thread_stack            = 256K
thread_cache_size       = 8
max_connections         = 100

# Query Cache (MySQL 5.7 and earlier)
query_cache_limit       = 1M
query_cache_size        = 16M

# InnoDB
innodb_buffer_pool_size = 256M
innodb_log_file_size    = 64M
innodb_flush_log_at_trx_commit = 1
innodb_file_per_table   = 1

# Logging
log_error = /var/log/mysql/error.log
slow_query_log          = 1
slow_query_log_file     = /var/log/mysql/slow.log
long_query_time         = 2

# Binary logging (for replication/backup)
server-id               = 1
log_bin                 = /var/log/mysql/mysql-bin.log
binlog_expire_logs_seconds = 604800
max_binlog_size         = 100M
```

```bash
# Apply configuration changes
sudo systemctl restart mysql
```

#### Basic MySQL Administration

```bash
# Connect to MySQL as root
sudo mysql

# Or with password
mysql -u root -p
```

```sql
-- Create database
CREATE DATABASE myapp_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- Create user
CREATE USER 'myapp_user'@'localhost' IDENTIFIED BY 'strong_password';

-- Grant privileges
GRANT ALL PRIVILEGES ON myapp_db.* TO 'myapp_user'@'localhost';
GRANT SELECT, INSERT, UPDATE, DELETE ON myapp_db.* TO 'myapp_user'@'localhost';

-- For remote access (be careful!)
CREATE USER 'remote_user'@'%' IDENTIFIED BY 'strong_password';
GRANT ALL PRIVILEGES ON myapp_db.* TO 'remote_user'@'%';

-- View users
SELECT User, Host FROM mysql.user;

-- View privileges
SHOW GRANTS FOR 'myapp_user'@'localhost';

-- Reload privileges
FLUSH PRIVILEGES;

-- Exit MySQL
EXIT;
```

#### Creating and Managing Databases

```sql
-- Connect as user
mysql -u myapp_user -p myapp_db

-- Create table
CREATE TABLE users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(50) UNIQUE NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_email (email),
    INDEX idx_created (created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Insert data
INSERT INTO users (username, email, password_hash)
VALUES ('john_doe', 'john@example.com', 'hashed_password_here');

-- Query data
SELECT * FROM users WHERE email = 'john@example.com';

-- Update data
UPDATE users SET username = 'jane_doe' WHERE id = 1;

-- Delete data
DELETE FROM users WHERE id = 1;

-- Show databases
SHOW DATABASES;

-- Show tables
SHOW TABLES;

-- Describe table structure
DESCRIBE users;

-- Show table creation statement
SHOW CREATE TABLE users\G
```

### PostgreSQL Basics

#### Installing PostgreSQL

```bash
# Install PostgreSQL
sudo apt update
sudo apt install postgresql postgresql-contrib -y

# Check version
psql --version

# Check status
sudo systemctl status postgresql

# PostgreSQL creates a 'postgres' system user
sudo -i -u postgres
```

#### PostgreSQL Configuration

```bash
# Main configuration files
ls /etc/postgresql/*/main/
# postgresql.conf - Main configuration
# pg_hba.conf - Authentication configuration

# Edit main configuration
sudo nano /etc/postgresql/14/main/postgresql.conf
```

```conf
# Connection Settings
listen_addresses = 'localhost'
port = 5432
max_connections = 100

# Memory Settings
shared_buffers = 256MB
effective_cache_size = 1GB
maintenance_work_mem = 64MB
work_mem = 4MB

# Write Ahead Log
wal_level = replica
max_wal_size = 1GB
min_wal_size = 80MB

# Logging
logging_collector = on
log_directory = '/var/log/postgresql'
log_filename = 'postgresql-%Y-%m-%d_%H%M%S.log'
log_rotation_age = 1d
log_rotation_size = 100MB
log_line_prefix = '%m [%p] %q%u@%d '
log_statement = 'all'
log_duration = on

# Statistics
track_activities = on
track_counts = on
track_io_timing = on
```

```bash
# Authentication configuration
sudo nano /etc/postgresql/14/main/pg_hba.conf
```

```conf
# TYPE  DATABASE        USER            ADDRESS                 METHOD
local   all             postgres                                peer
local   all             all                                     peer
host    all             all             127.0.0.1/32            scram-sha-256
host    all             all             ::1/128                 scram-sha-256
```

```bash
# Restart PostgreSQL
sudo systemctl restart postgresql
```

#### Basic PostgreSQL Administration

```bash
# Switch to postgres user
sudo -u postgres psql
```

```sql
-- Create database
CREATE DATABASE myapp_db;

-- Create user
CREATE USER myapp_user WITH PASSWORD 'strong_password';

-- Grant privileges
GRANT ALL PRIVILEGES ON DATABASE myapp_db TO myapp_user;

-- Make user database owner
ALTER DATABASE myapp_db OWNER TO myapp_user;

-- List databases
\l

-- List users
\du

-- Connect to database
\c myapp_db

-- Create table
CREATE TABLE users (
    id SERIAL PRIMARY KEY,
    username VARCHAR(50) UNIQUE NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create index
CREATE INDEX idx_users_email ON users(email);

-- Show tables
\dt

-- Describe table
\d users

-- Quit
\q
```

### Database Security

#### MySQL Security Best Practices

```bash
# Remove remote root access
mysql -u root -p
```

```sql
-- Remove root access from non-localhost
DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1');

-- Ensure no anonymous users
DELETE FROM mysql.user WHERE User='';

-- Remove test database
DROP DATABASE IF EXISTS test;
DELETE FROM mysql.db WHERE Db='test' OR Db='test\\_%';

-- Create application-specific users with minimal privileges
CREATE USER 'readonly'@'localhost' IDENTIFIED BY 'password';
GRANT SELECT ON myapp_db.* TO 'readonly'@'localhost';

CREATE USER 'appuser'@'localhost' IDENTIFIED BY 'password';
GRANT SELECT, INSERT, UPDATE, DELETE ON myapp_db.* TO 'appuser'@'localhost';

-- Enable SSL/TLS
SHOW VARIABLES LIKE '%ssl%';

FLUSH PRIVILEGES;
```

#### PostgreSQL Security

```sql
-- Revoke public schema access
REVOKE CREATE ON SCHEMA public FROM PUBLIC;

-- Create read-only user
CREATE USER readonly WITH PASSWORD 'secure_password';
GRANT CONNECT ON DATABASE myapp_db TO readonly;
GRANT USAGE ON SCHEMA public TO readonly;
GRANT SELECT ON ALL TABLES IN SCHEMA public TO readonly;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT SELECT ON TABLES TO readonly;

-- Create application user with limited privileges
CREATE USER appuser WITH PASSWORD 'secure_password';
GRANT CONNECT ON DATABASE myapp_db TO appuser;
GRANT USAGE, CREATE ON SCHEMA public TO appuser;
GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA public TO appuser;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT SELECT, INSERT, UPDATE, DELETE ON TABLES TO appuser;
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA public TO appuser;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT USAGE, SELECT ON SEQUENCES TO appuser;
```

### Database Backup and Recovery

#### MySQL Backup Strategies

```bash
# Logical backup with mysqldump
# Full database backup
mysqldump -u root -p --all-databases > all_databases_backup.sql

# Single database backup
mysqldump -u root -p myapp_db > myapp_db_backup.sql

# Compressed backup
mysqldump -u root -p myapp_db | gzip > myapp_db_backup.sql.gz

# Backup with stored procedures and triggers
mysqldump -u root -p --routines --triggers myapp_db > myapp_db_full.sql

# Backup specific tables
mysqldump -u root -p myapp_db users posts > tables_backup.sql

# Consistent backup for InnoDB
mysqldump -u root -p --single-transaction myapp_db > myapp_db_consistent.sql

# Create backup script
sudo nano /usr/local/bin/mysql-backup.sh
```

```bash
#!/bin/bash
# MySQL backup script

# Configuration
BACKUP_DIR="/backup/mysql"
MYSQL_USER="root"
MYSQL_PASSWORD="your_password"
DATE=$(date +%Y%m%d_%H%M%S)
RETENTION_DAYS=7

# Create backup directory
mkdir -p "$BACKUP_DIR"

# Backup all databases
mysqldump -u "$MYSQL_USER" -p"$MYSQL_PASSWORD" \
    --all-databases \
    --single-transaction \
    --routines \
    --triggers \
    --events \
    | gzip > "$BACKUP_DIR/all_databases_$DATE.sql.gz"

# Check if backup was successful
if [ $? -eq 0 ]; then
    echo "Backup successful: all_databases_$DATE.sql.gz"

    # Remove old backups
    find "$BACKUP_DIR" -name "*.sql.gz" -mtime +$RETENTION_DAYS -delete
    echo "Old backups removed (older than $RETENTION_DAYS days)"
else
    echo "Backup failed!"
    exit 1
fi
```

#### MySQL Recovery

```bash
# Restore full database
mysql -u root -p < all_databases_backup.sql

# Restore single database
mysql -u root -p myapp_db < myapp_db_backup.sql

# Restore from compressed backup
gunzip < myapp_db_backup.sql.gz | mysql -u root -p myapp_db

# Restore specific tables
mysql -u root -p myapp_db < tables_backup.sql
```

#### PostgreSQL Backup and Recovery

```bash
# Logical backup with pg_dump
# Full database backup
sudo -u postgres pg_dump myapp_db > myapp_db_backup.sql

# Compressed backup
sudo -u postgres pg_dump myapp_db | gzip > myapp_db_backup.sql.gz

# Custom format (allows selective restore)
sudo -u postgres pg_dump -Fc myapp_db > myapp_db_backup.custom

# Backup all databases
sudo -u postgres pg_dumpall > all_databases_backup.sql

# PostgreSQL backup script
sudo nano /usr/local/bin/postgresql-backup.sh
```

```bash
#!/bin/bash
# PostgreSQL backup script

BACKUP_DIR="/backup/postgresql"
DATE=$(date +%Y%m%d_%H%M%S)
RETENTION_DAYS=7

mkdir -p "$BACKUP_DIR"

# Backup all databases
sudo -u postgres pg_dumpall | gzip > "$BACKUP_DIR/all_databases_$DATE.sql.gz"

# Backup individual databases in custom format
for DB in $(sudo -u postgres psql -t -c "SELECT datname FROM pg_database WHERE datistemplate = false;"); do
    sudo -u postgres pg_dump -Fc "$DB" > "$BACKUP_DIR/${DB}_$DATE.custom"
done

# Remove old backups
find "$BACKUP_DIR" -name "*.sql.gz" -o -name "*.custom" -mtime +$RETENTION_DAYS -delete

echo "PostgreSQL backup completed"
```

```bash
# PostgreSQL recovery
# Restore from SQL dump
sudo -u postgres psql myapp_db < myapp_db_backup.sql

# Restore from custom format
sudo -u postgres pg_restore -d myapp_db myapp_db_backup.custom

# Restore specific tables
sudo -u postgres pg_restore -d myapp_db -t users myapp_db_backup.custom
```

### Performance Tuning

#### MySQL Performance Optimization

```bash
# Performance analysis
mysql -u root -p
```

```sql
-- Check slow queries
SHOW VARIABLES LIKE 'slow_query%';
SHOW VARIABLES LIKE 'long_query_time';

-- Enable slow query log
SET GLOBAL slow_query_log = 'ON';
SET GLOBAL long_query_time = 2;

-- Analyze query performance
EXPLAIN SELECT * FROM users WHERE email = 'user@example.com';

-- Show process list
SHOW FULL PROCESSLIST;

-- Kill long-running query
KILL QUERY process_id;

-- Table optimization
ANALYZE TABLE users;
OPTIMIZE TABLE users;

-- Check table status
SHOW TABLE STATUS LIKE 'users'\G

-- InnoDB buffer pool status
SHOW ENGINE INNODB STATUS\G

-- Performance schema
SELECT * FROM performance_schema.events_statements_summary_by_digest
ORDER BY SUM_TIMER_WAIT DESC LIMIT 10;
```

#### PostgreSQL Performance Tuning

```sql
-- Enable query statistics
CREATE EXTENSION IF NOT EXISTS pg_stat_statements;

-- View slow queries
SELECT query, calls, total_exec_time, mean_exec_time
FROM pg_stat_statements
ORDER BY mean_exec_time DESC
LIMIT 10;

-- Analyze query execution
EXPLAIN ANALYZE SELECT * FROM users WHERE email = 'user@example.com';

-- View current activity
SELECT pid, usename, application_name, state, query
FROM pg_stat_activity
WHERE state != 'idle';

-- Kill long-running query
SELECT pg_terminate_backend(pid)
FROM pg_stat_activity
WHERE pid != pg_backend_pid()
AND query_start < now() - interval '5 minutes';

-- Table maintenance
VACUUM ANALYZE users;
REINDEX TABLE users;

-- Check table size
SELECT
    schemaname,
    tablename,
    pg_size_pretty(pg_total_relation_size(schemaname||'.'||tablename)) AS size
FROM pg_tables
ORDER BY pg_total_relation_size(schemaname||'.'||tablename) DESC;
```

### Database Monitoring

#### MySQL Monitoring Script

```bash
sudo nano /usr/local/bin/mysql-monitor.sh
```

```bash
#!/bin/bash
# MySQL monitoring script

MYSQL_USER="monitor"
MYSQL_PASS="password"

echo "=== MySQL Monitoring Report ==="
echo "Date: $(date)"
echo

# Connection statistics
mysql -u "$MYSQL_USER" -p"$MYSQL_PASS" -e "SHOW STATUS LIKE 'Threads_connected';"
mysql -u "$MYSQL_USER" -p"$MYSQL_PASS" -e "SHOW STATUS LIKE 'Max_used_connections';"

# Query statistics
echo -e "\n=== Query Statistics ==="
mysql -u "$MYSQL_USER" -p"$MYSQL_PASS" -e "SHOW GLOBAL STATUS LIKE 'Questions';"
mysql -u "$MYSQL_USER" -p"$MYSQL_PASS" -e "SHOW GLOBAL STATUS LIKE 'Slow_queries';"

# InnoDB statistics
echo -e "\n=== InnoDB Buffer Pool ==="
mysql -u "$MYSQL_USER" -p"$MYSQL_PASS" -e "
SELECT
    (SELECT VARIABLE_VALUE FROM performance_schema.global_status
     WHERE VARIABLE_NAME = 'Innodb_buffer_pool_pages_total') AS total_pages,
    (SELECT VARIABLE_VALUE FROM performance_schema.global_status
     WHERE VARIABLE_NAME = 'Innodb_buffer_pool_pages_free') AS free_pages,
    (SELECT VARIABLE_VALUE FROM performance_schema.global_status
     WHERE VARIABLE_NAME = 'Innodb_buffer_pool_pages_dirty') AS dirty_pages;"

# Table sizes
echo -e "\n=== Top 5 Largest Tables ==="
mysql -u "$MYSQL_USER" -p"$MYSQL_PASS" -e "
SELECT
    table_schema AS 'Database',
    table_name AS 'Table',
    ROUND(((data_length + index_length) / 1024 / 1024), 2) AS 'Size (MB)'
FROM information_schema.TABLES
ORDER BY (data_length + index_length) DESC
LIMIT 5;"
```

### Maintenance Tasks

#### Automated Maintenance

```bash
# Create maintenance script
sudo nano /usr/local/bin/database-maintenance.sh
```

```bash
#!/bin/bash
# Database maintenance script

LOG_FILE="/var/log/database-maintenance.log"

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

# MySQL Maintenance
mysql_maintenance() {
    log "Starting MySQL maintenance"

    # Optimize all tables
    mysqlcheck -u root -p'password' --all-databases --optimize

    # Analyze tables
    mysqlcheck -u root -p'password' --all-databases --analyze

    # Flush logs
    mysql -u root -p'password' -e "FLUSH LOGS;"

    # Purge old binary logs
    mysql -u root -p'password' -e "PURGE BINARY LOGS BEFORE DATE_SUB(NOW(), INTERVAL 7 DAY);"

    log "MySQL maintenance completed"
}

# PostgreSQL Maintenance
postgresql_maintenance() {
    log "Starting PostgreSQL maintenance"

    # VACUUM all databases
    sudo -u postgres vacuumdb --all --analyze

    # Reindex databases
    sudo -u postgres reindexdb --all

    # Update statistics
    sudo -u postgres psql -c "SELECT schemaname, tablename FROM pg_tables WHERE schemaname NOT IN ('pg_catalog', 'information_schema');" | \
    while read schema table; do
        sudo -u postgres psql -c "ANALYZE $schema.$table;"
    done

    log "PostgreSQL maintenance completed"
}

# Main execution
main() {
    mysql_maintenance
    postgresql_maintenance

    # Clean up old logs
    find /var/log -name "*.log" -mtime +30 -delete

    log "Database maintenance completed successfully"
}

main
```

```bash
# Schedule maintenance
sudo crontab -e
# Add: 0 2 * * 0 /usr/local/bin/database-maintenance.sh
```

---

## Practice Exercises

### Exercise 1: Web Server Setup
1. Install and configure Nginx
2. Create three virtual hosts with different content
3. Set up a reverse proxy to a local application
4. Implement SSL/TLS with self-signed certificates
5. Configure caching and compression

### Exercise 2: Database Administration
1. Install both MySQL and PostgreSQL
2. Create databases and users with appropriate privileges
3. Import sample data and run queries
4. Set up automated backups for both databases
5. Monitor and optimize query performance

### Exercise 3: Security Hardening
1. Secure both web server and database installations
2. Configure firewalls to allow only necessary ports
3. Implement rate limiting on the web server
4. Set up SSL/TLS for database connections
5. Create security audit scripts

### Exercise 4: Performance Testing
1. Use Apache Bench (ab) to test web server performance
2. Optimize web server configuration based on results
3. Create load on databases and identify slow queries
4. Implement caching strategies
5. Document performance improvements

---

## Quick Reference

### Nginx Commands
```bash
sudo nginx -t                    # Test configuration
sudo nginx -s reload            # Reload configuration
sudo nginx -s stop              # Stop Nginx
sudo systemctl restart nginx    # Restart service
tail -f /var/log/nginx/access.log  # Monitor access log
tail -f /var/log/nginx/error.log   # Monitor error log
```

### MySQL Commands
```bash
sudo systemctl status mysql     # Check status
mysql -u root -p               # Connect as root
mysqldump db_name > backup.sql # Backup database
mysql db_name < backup.sql     # Restore database
mysqlcheck --all-databases     # Check all databases
```

### PostgreSQL Commands
```bash
sudo -u postgres psql          # Connect as postgres
pg_dump dbname > backup.sql    # Backup database
psql dbname < backup.sql       # Restore database
vacuumdb --all                 # Vacuum all databases
```

### Performance Testing
```bash
ab -n 1000 -c 10 http://localhost/  # Apache Bench
curl -w "@curl-format.txt" -o /dev/null -s http://localhost/  # Measure response time
mysqlslap --auto-generate-sql --number-of-queries=1000  # MySQL benchmark
pgbench -i -s 10 mydb          # PostgreSQL benchmark
```

---

## Additional Resources

### Web Server Resources
- [Nginx Documentation](https://nginx.org/en/docs/)
- [Apache HTTP Server Documentation](https://httpd.apache.org/docs/)
- [Mozilla SSL Configuration Generator](https://ssl-config.mozilla.org/)
- [Web Server Security Guidelines](https://owasp.org/www-project-web-security-testing-guide/)

### Database Resources
- [MySQL Reference Manual](https://dev.mysql.com/doc/refman/8.0/en/)
- [PostgreSQL Documentation](https://www.postgresql.org/docs/)
- [Database Security Best Practices](https://www.cisecurity.org/benchmark/postgresql)
- [SQL Tutorial](https://www.w3schools.com/sql/)

### Performance Tools
- [GTmetrix](https://gtmetrix.com/) - Web performance testing
- [Percona Toolkit](https://www.percona.com/software/database-tools/percona-toolkit) - MySQL tools
- [pgBadger](https://pgbadger.darold.net/) - PostgreSQL log analyzer
- [MySQLTuner](https://github.com/major/MySQLTuner-perl) - MySQL optimization

### Next Steps
After completing this section, you should:
- Be able to set up and configure web servers
- Understand database installation and administration
- Know how to secure web and database servers
- Be able to optimize performance
- Have backup and recovery procedures in place

Continue to Part 9 to learn about hosting and managing applications on your server.