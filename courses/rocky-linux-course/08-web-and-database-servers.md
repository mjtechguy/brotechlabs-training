# Part 8: Web and Database Servers

## Prerequisites and Learning Resources

Before starting this section, you should have completed:
- Part 1: Getting Started with Rocky Linux
- Part 2: Core System Administration (especially SELinux)
- Part 4: Networking and Security (firewall configuration)
- Part 5: Package and Software Management

**Helpful Resources:**
- Apache Documentation: https://httpd.apache.org/docs/
- Nginx Documentation: https://nginx.org/en/docs/
- MariaDB Documentation: https://mariadb.org/documentation/
- PostgreSQL Documentation: https://www.postgresql.org/docs/
- Rocky Linux Web Server Guide: https://docs.rockylinux.org/guides/web/

---

## Chapter 18: Web Server Administration

### Introduction

Web servers are the backbone of the internet - they deliver websites, APIs, and applications to users worldwide. In this chapter, you'll learn how to set up, configure, and secure web servers on Rocky Linux.

### Understanding Web Servers

A web server is like a restaurant waiter:
- **Takes orders** (receives HTTP requests)
- **Goes to the kitchen** (fetches files or runs applications)
- **Delivers the food** (sends web pages back to browsers)
- **Handles multiple tables** (serves many users simultaneously)

Rocky Linux includes two popular web servers:
- **Apache (httpd)**: The traditional choice, incredibly flexible
- **Nginx**: Lightweight and fast, great for high traffic

```bash
# Check if Apache is already installed
rpm -q httpd
# package httpd is not installed

# Check if Nginx is installed
rpm -q nginx
# package nginx is not installed

# We'll install both and learn when to use each!
```

### Installing Apache Web Server

Apache (officially called Apache HTTP Server) is the world's most popular web server. It's been serving websites since 1995!

```bash
# Install Apache
sudo dnf install httpd -y

# Check the version
httpd -v
# Server version: Apache/2.4.57 (Rocky Linux)
# Server built:   Jul 20 2023 00:00:00

# Enable Apache to start automatically
sudo systemctl enable httpd

# Start Apache
sudo systemctl start httpd

# Check if it's running
sudo systemctl status httpd
```

#### Your First Web Page

```bash
# Apache serves files from /var/www/html by default
# Let's create a simple web page
echo "<h1>Welcome to Rocky Linux Web Server!</h1>" | sudo tee /var/www/html/index.html

# Test it locally
curl localhost
# <h1>Welcome to Rocky Linux Web Server!</h1>
```

#### Configuring the Firewall

Web servers need to accept incoming connections:

```bash
# Allow HTTP (port 80) traffic
sudo firewall-cmd --permanent --add-service=http

# Allow HTTPS (port 443) traffic
sudo firewall-cmd --permanent --add-service=https

# Reload firewall rules
sudo firewall-cmd --reload

# Check what's allowed
sudo firewall-cmd --list-services
# cockpit dhcpv6-client http https ssh
```

### SELinux and Web Content

SELinux protects your web server by controlling what it can access. This is like having a security guard who only lets the waiter into certain areas of the restaurant.

```bash
# Check SELinux context for web files
ls -Z /var/www/html/
# -rw-r--r--. root root unconfined_u:object_r:httpd_sys_content_t:s0 index.html

# The httpd_sys_content_t context allows Apache to read these files
```

#### Common SELinux Web Server Contexts

```bash
# Different contexts for different purposes:
# httpd_sys_content_t - Static web content (read-only)
# httpd_sys_rw_content_t - Content Apache can modify
# httpd_sys_script_exec_t - CGI scripts and executables
# httpd_log_t - Log files
# httpd_config_t - Configuration files

# Example: Create a directory for uploads that Apache can write to
sudo mkdir /var/www/html/uploads
sudo chown apache:apache /var/www/html/uploads
sudo semanage fcontext -a -t httpd_sys_rw_content_t "/var/www/html/uploads(/.*)?"
sudo restorecon -Rv /var/www/html/uploads
```

### Virtual Hosts Configuration

Virtual hosts let one web server host multiple websites - like one restaurant serving different cuisines at different tables!

```bash
# Create directories for two websites
sudo mkdir -p /var/www/site1.example.com
sudo mkdir -p /var/www/site2.example.com

# Create test pages
echo "<h1>This is Site 1</h1>" | sudo tee /var/www/site1.example.com/index.html
echo "<h1>This is Site 2</h1>" | sudo tee /var/www/site2.example.com/index.html

# Create virtual host configuration for Site 1
sudo tee /etc/httpd/conf.d/site1.example.com.conf <<EOF
<VirtualHost *:80>
    ServerName site1.example.com
    DocumentRoot /var/www/site1.example.com
    ErrorLog /var/log/httpd/site1.example.com-error.log
    CustomLog /var/log/httpd/site1.example.com-access.log combined
</VirtualHost>
EOF

# Create virtual host configuration for Site 2
sudo tee /etc/httpd/conf.d/site2.example.com.conf <<EOF
<VirtualHost *:80>
    ServerName site2.example.com
    DocumentRoot /var/www/site2.example.com
    ErrorLog /var/log/httpd/site2.example.com-error.log
    CustomLog /var/log/httpd/site2.example.com-access.log combined
</VirtualHost>
EOF

# Test configuration
sudo httpd -t
# Syntax OK

# Restart Apache to load new configuration
sudo systemctl restart httpd
```

### HTTPS with SSL/TLS

HTTPS encrypts web traffic, like putting your restaurant order in a locked box that only the kitchen can open.

```bash
# Install SSL/TLS module
sudo dnf install mod_ssl -y

# Generate a self-signed certificate for testing
sudo openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
    -keyout /etc/pki/tls/private/server.key \
    -out /etc/pki/tls/certs/server.crt \
    -subj "/C=US/ST=State/L=City/O=Organization/CN=server.example.com"

# Create HTTPS virtual host
sudo tee /etc/httpd/conf.d/ssl-site.conf <<EOF
<VirtualHost *:443>
    ServerName server.example.com
    DocumentRoot /var/www/html
    SSLEngine on
    SSLCertificateFile /etc/pki/tls/certs/server.crt
    SSLCertificateKeyFile /etc/pki/tls/private/server.key
</VirtualHost>
EOF

# Restart Apache
sudo systemctl restart httpd

# Test HTTPS (ignore certificate warning for self-signed cert)
curl -k https://localhost
```

### Reverse Proxy Configuration

A reverse proxy is like a receptionist who directs visitors to the right office. Apache can forward requests to other servers or applications.

```bash
# Install proxy modules
sudo dnf install httpd-devel -y

# Enable proxy modules (they're installed but need to be loaded)
# Add to /etc/httpd/conf.modules.d/00-proxy.conf if not present
echo "LoadModule proxy_module modules/mod_proxy.so" | sudo tee -a /etc/httpd/conf.modules.d/00-proxy.conf
echo "LoadModule proxy_http_module modules/mod_proxy_http.so" | sudo tee -a /etc/httpd/conf.modules.d/00-proxy.conf

# Example: Proxy requests to an application running on port 3000
sudo tee /etc/httpd/conf.d/app-proxy.conf <<EOF
<VirtualHost *:80>
    ServerName app.example.com
    ProxyPreserveHost On
    ProxyPass / http://localhost:3000/
    ProxyPassReverse / http://localhost:3000/
</VirtualHost>
EOF

# SELinux: Allow Apache to make network connections
sudo setsebool -P httpd_can_network_connect on

# Test configuration
sudo httpd -t

# Restart Apache
sudo systemctl restart httpd
```

### Nginx as an Alternative

Nginx (pronounced "engine-x") is known for handling many connections efficiently with low memory usage.

```bash
# Install Nginx
sudo dnf install nginx -y

# Stop Apache first (they both use port 80)
sudo systemctl stop httpd
sudo systemctl disable httpd

# Enable and start Nginx
sudo systemctl enable nginx
sudo systemctl start nginx

# Nginx configuration structure
ls /etc/nginx/
# nginx.conf - Main configuration file
# conf.d/ - Additional configuration files
# sites-available/ - Available site configurations (not used by default in Rocky)
# sites-enabled/ - Enabled site configurations (not used by default in Rocky)

# Create a simple site configuration
sudo tee /etc/nginx/conf.d/mysite.conf <<EOF
server {
    listen 80;
    server_name mysite.example.com;
    root /usr/share/nginx/html;
    index index.html;

    location / {
        try_files \$uri \$uri/ =404;
    }
}
EOF

# Test Nginx configuration
sudo nginx -t

# Reload Nginx
sudo systemctl reload nginx
```

### Web Server Security Hardening

Protecting your web server is like installing locks, cameras, and alarms in your restaurant.

```bash
# 1. Hide Apache version information
echo "ServerTokens Prod" | sudo tee -a /etc/httpd/conf/httpd.conf
echo "ServerSignature Off" | sudo tee -a /etc/httpd/conf/httpd.conf

# 2. Disable directory listing
sudo tee /etc/httpd/conf.d/security.conf <<EOF
<Directory /var/www/html>
    Options -Indexes
</Directory>
EOF

# 3. Set up rate limiting with mod_ratelimit
echo "LoadModule ratelimit_module modules/mod_ratelimit.so" | sudo tee -a /etc/httpd/conf.modules.d/00-base.conf

# 4. Configure security headers
sudo tee /etc/httpd/conf.d/security-headers.conf <<EOF
Header always set X-Frame-Options "SAMEORIGIN"
Header always set X-Content-Type-Options "nosniff"
Header always set X-XSS-Protection "1; mode=block"
EOF

# 5. Limit request size to prevent DoS
echo "LimitRequestBody 10485760" | sudo tee -a /etc/httpd/conf/httpd.conf
# Limits uploads to 10MB

# Restart Apache to apply security settings
sudo systemctl restart httpd
```

### Performance Optimization

Making your web server fast is like streamlining your restaurant's kitchen operations.

```bash
# 1. Enable compression with mod_deflate
sudo tee /etc/httpd/conf.d/deflate.conf <<EOF
<IfModule mod_deflate.c>
    AddOutputFilterByType DEFLATE text/html text/plain text/xml text/css text/javascript application/javascript
    DeflateCompressionLevel 9
</IfModule>
EOF

# 2. Enable caching for static content
sudo tee /etc/httpd/conf.d/cache.conf <<EOF
<IfModule mod_expires.c>
    ExpiresActive On
    ExpiresByType image/jpg "access plus 1 month"
    ExpiresByType image/jpeg "access plus 1 month"
    ExpiresByType image/png "access plus 1 month"
    ExpiresByType text/css "access plus 1 week"
    ExpiresByType application/javascript "access plus 1 week"
</IfModule>
EOF

# 3. Tune Apache MPM (Multi-Processing Module)
sudo tee /etc/httpd/conf.modules.d/00-mpm.conf <<EOF
LoadModule mpm_event_module modules/mod_mpm_event.so
<IfModule mpm_event_module>
    StartServers             3
    MinSpareThreads         75
    MaxSpareThreads        250
    ThreadsPerChild         25
    MaxRequestWorkers      400
    MaxConnectionsPerChild   0
</IfModule>
EOF

# 4. Monitor Apache status
sudo tee /etc/httpd/conf.d/status.conf <<EOF
<Location "/server-status">
    SetHandler server-status
    Require host localhost
</Location>
EOF

# Restart Apache
sudo systemctl restart httpd

# Check server status
curl http://localhost/server-status?auto
```

### Monitoring and Logging

```bash
# Apache logs are in /var/log/httpd/
ls /var/log/httpd/
# access_log - Who visited your site
# error_log - Problems and errors
# ssl_access_log - HTTPS visits
# ssl_error_log - SSL/TLS errors

# Watch logs in real-time
sudo tail -f /var/log/httpd/access_log

# Analyze top IP addresses
sudo awk '{print $1}' /var/log/httpd/access_log | sort | uniq -c | sort -rn | head -10

# Find 404 errors
sudo grep " 404 " /var/log/httpd/access_log

# Check for potential attacks
sudo grep -E "\.\.\/|union.*select|<script|DROP.*TABLE" /var/log/httpd/access_log

# Rotate logs automatically with logrotate
cat /etc/logrotate.d/httpd
```

---

## Chapter 19: Database Server Management

### Introduction

Databases are like the filing cabinets of the digital world - they store and organize information so applications can quickly find what they need. Rocky Linux supports several database systems, and we'll focus on the most popular ones.

### Understanding Databases

Think of a database like a library:
- **Tables** are like different sections (Fiction, Science, History)
- **Rows** are like individual books
- **Columns** are like book details (Title, Author, ISBN)
- **Queries** are like asking the librarian for specific books

Rocky Linux includes:
- **MariaDB**: Default MySQL-compatible database
- **PostgreSQL**: Advanced open-source database
- **MySQL**: The original, now owned by Oracle

### Installing MariaDB

MariaDB is a community fork of MySQL, created when Oracle bought MySQL. It's 100% compatible with MySQL applications.

```bash
# Install MariaDB server and client
sudo dnf install mariadb-server mariadb -y

# Enable MariaDB to start on boot
sudo systemctl enable mariadb

# Start MariaDB
sudo systemctl start mariadb

# Check status
sudo systemctl status mariadb

# Secure the installation
sudo mysql_secure_installation
# This interactive script will:
# - Set root password
# - Remove anonymous users
# - Disallow root login remotely
# - Remove test database
# - Reload privilege tables

# Answer Y to all questions for maximum security
```

### Basic MariaDB Operations

```bash
# Connect to MariaDB as root
sudo mysql -u root -p
# Enter the password you set during secure installation
```

```sql
-- Once connected to MariaDB:
-- Show all databases
SHOW DATABASES;

-- Create a new database
CREATE DATABASE company_db;

-- Use the database
USE company_db;

-- Create a table
CREATE TABLE employees (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    department VARCHAR(50),
    salary DECIMAL(10,2),
    hire_date DATE
);

-- Insert data
INSERT INTO employees (name, department, salary, hire_date)
VALUES ('John Doe', 'IT', 65000.00, '2023-01-15');

INSERT INTO employees (name, department, salary, hire_date)
VALUES ('Jane Smith', 'HR', 55000.00, '2023-02-01');

-- Query data
SELECT * FROM employees;

-- Update data
UPDATE employees SET salary = 70000.00 WHERE name = 'John Doe';

-- Create a user for an application
CREATE USER 'app_user'@'localhost' IDENTIFIED BY 'SecurePass123!';
GRANT ALL PRIVILEGES ON company_db.* TO 'app_user'@'localhost';
FLUSH PRIVILEGES;

-- Exit MariaDB
EXIT;
```

### SELinux and Databases

SELinux controls how databases interact with the system:

```bash
# Check SELinux context for MariaDB
ls -Z /var/lib/mysql/
# Files have mysqld_db_t context

# Common SELinux booleans for databases
# Allow web server to connect to database
sudo setsebool -P httpd_can_network_connect_db on

# Allow database to send email (for notifications)
sudo setsebool -P mysql_connect_any on

# Check current SELinux settings for MySQL
sudo getsebool -a | grep mysql
```

### Database Backup and Recovery

Backups are your safety net - like keeping copies of important documents in a safe.

```bash
# Method 1: Logical backup with mysqldump
# Backup single database
sudo mysqldump -u root -p company_db > company_db_backup.sql

# Backup all databases
sudo mysqldump -u root -p --all-databases > all_databases_backup.sql

# Backup with compression
sudo mysqldump -u root -p company_db | gzip > company_db_backup.sql.gz

# Method 2: Physical backup (copy files)
# Stop MariaDB first
sudo systemctl stop mariadb

# Copy data directory
sudo cp -R /var/lib/mysql /backup/mysql_physical_backup

# Start MariaDB again
sudo systemctl start mariadb

# Restore from logical backup
sudo mysql -u root -p company_db < company_db_backup.sql

# Restore from compressed backup
gunzip < company_db_backup.sql.gz | sudo mysql -u root -p company_db
```

### Automated Backup Script

```bash
# Create backup script
sudo tee /usr/local/bin/backup_databases.sh <<'EOF'
#!/bin/bash
# Database Backup Script

# Configuration
BACKUP_DIR="/var/backups/mysql"
MYSQL_USER="root"
MYSQL_PASSWORD="YourRootPassword"
DATE=$(date +%Y%m%d_%H%M%S)
RETENTION_DAYS=7

# Create backup directory if it doesn't exist
mkdir -p $BACKUP_DIR

# Backup all databases
mysqldump -u $MYSQL_USER -p$MYSQL_PASSWORD --all-databases | gzip > $BACKUP_DIR/all_databases_$DATE.sql.gz

# Check if backup was successful
if [ $? -eq 0 ]; then
    echo "Backup successful: all_databases_$DATE.sql.gz"

    # Remove old backups
    find $BACKUP_DIR -name "*.sql.gz" -mtime +$RETENTION_DAYS -delete
    echo "Old backups removed (older than $RETENTION_DAYS days)"
else
    echo "Backup failed!" >&2
    exit 1
fi
EOF

# Make script executable
sudo chmod +x /usr/local/bin/backup_databases.sh

# Create systemd timer for automated backups
sudo tee /etc/systemd/system/backup-databases.service <<EOF
[Unit]
Description=Backup MariaDB databases
After=mariadb.service

[Service]
Type=oneshot
ExecStart=/usr/local/bin/backup_databases.sh
User=root
EOF

sudo tee /etc/systemd/system/backup-databases.timer <<EOF
[Unit]
Description=Daily database backup
Requires=backup-databases.service

[Timer]
OnCalendar=daily
OnCalendar=02:00
Persistent=true

[Install]
WantedBy=timers.target
EOF

# Enable and start the timer
sudo systemctl enable backup-databases.timer
sudo systemctl start backup-databases.timer

# Check timer status
sudo systemctl list-timers | grep backup
```

### PostgreSQL Installation and Setup

PostgreSQL is known for its advanced features and standards compliance.

```bash
# Install PostgreSQL
sudo dnf install postgresql-server postgresql -y

# Initialize the database
sudo postgresql-setup --initdb

# Enable and start PostgreSQL
sudo systemctl enable postgresql
sudo systemctl start postgresql

# Switch to postgres user
sudo -u postgres psql
```

```sql
-- In PostgreSQL:
-- Create a database
CREATE DATABASE company_db;

-- Create a user
CREATE USER app_user WITH ENCRYPTED PASSWORD 'SecurePass123!';

-- Grant privileges
GRANT ALL PRIVILEGES ON DATABASE company_db TO app_user;

-- List databases
\l

-- Connect to a database
\c company_db

-- Create a table
CREATE TABLE products (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    price DECIMAL(10,2),
    stock INTEGER DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Exit PostgreSQL
\q
```

### PostgreSQL Configuration

```bash
# PostgreSQL configuration files
ls /var/lib/pgsql/data/
# postgresql.conf - Main configuration
# pg_hba.conf - Client authentication

# Edit pg_hba.conf to allow password authentication
sudo vi /var/lib/pgsql/data/pg_hba.conf
# Change:
# local   all             all                                     peer
# To:
# local   all             all                                     md5

# Allow network connections (if needed)
sudo vi /var/lib/pgsql/data/postgresql.conf
# Uncomment and set:
# listen_addresses = 'localhost'  # or '*' for all interfaces

# Restart PostgreSQL to apply changes
sudo systemctl restart postgresql
```

### Database Performance Tuning

```bash
# MariaDB performance tuning
sudo tee /etc/my.cnf.d/performance.cnf <<EOF
[mysqld]
# Buffer pool size (use 70-80% of available RAM for dedicated DB servers)
innodb_buffer_pool_size = 1G

# Log file size
innodb_log_file_size = 256M

# Query cache
query_cache_type = 1
query_cache_size = 128M

# Connection limits
max_connections = 200
max_allowed_packet = 64M

# Temp table size
tmp_table_size = 64M
max_heap_table_size = 64M

# Thread cache
thread_cache_size = 8

# Table cache
table_open_cache = 2000
EOF

# Restart MariaDB
sudo systemctl restart mariadb

# Check current settings
mysql -u root -p -e "SHOW VARIABLES LIKE 'innodb_buffer_pool_size';"
```

### Database Monitoring

```bash
# Monitor MariaDB performance
mysql -u root -p -e "SHOW STATUS LIKE 'Threads_connected';"
mysql -u root -p -e "SHOW STATUS LIKE 'Questions';"
mysql -u root -p -e "SHOW PROCESSLIST;"

# Check slow queries
# First, enable slow query log
sudo tee -a /etc/my.cnf.d/slow_query.cnf <<EOF
[mysqld]
slow_query_log = 1
slow_query_log_file = /var/log/mariadb/slow_queries.log
long_query_time = 2
EOF

sudo systemctl restart mariadb

# Monitor slow query log
sudo tail -f /var/log/mariadb/slow_queries.log

# Create monitoring script
sudo tee /usr/local/bin/monitor_database.sh <<'EOF'
#!/bin/bash
# Database Monitoring Script

echo "=== Database Health Check ==="
echo "Date: $(date)"
echo ""

# Check if MariaDB is running
if systemctl is-active mariadb >/dev/null 2>&1; then
    echo "MariaDB Status: Running"

    # Get connection stats
    mysql -u root -p$1 -e "SHOW STATUS WHERE Variable_name IN ('Threads_connected', 'Max_used_connections', 'Aborted_connects');" 2>/dev/null

    # Check database sizes
    echo -e "\nDatabase Sizes:"
    mysql -u root -p$1 -e "SELECT table_schema AS 'Database', ROUND(SUM(data_length + index_length) / 1024 / 1024, 2) AS 'Size (MB)' FROM information_schema.TABLES GROUP BY table_schema;" 2>/dev/null

else
    echo "MariaDB Status: Not Running!"
fi
EOF

sudo chmod +x /usr/local/bin/monitor_database.sh

# Run monitoring script (provide root password as argument)
sudo /usr/local/bin/monitor_database.sh YourRootPassword
```

### Database Security Best Practices

```bash
# 1. Remove test database and anonymous users (done by mysql_secure_installation)

# 2. Use strong passwords
# Generate a strong password
openssl rand -base64 32

# 3. Limit user privileges
mysql -u root -p <<EOF
-- Create read-only user
CREATE USER 'reader'@'localhost' IDENTIFIED BY 'ReadOnlyPass123!';
GRANT SELECT ON company_db.* TO 'reader'@'localhost';

-- Create application-specific user with limited rights
CREATE USER 'webapp'@'localhost' IDENTIFIED BY 'WebAppPass123!';
GRANT SELECT, INSERT, UPDATE, DELETE ON company_db.* TO 'webapp'@'localhost';
FLUSH PRIVILEGES;
EOF

# 4. Enable SSL/TLS for connections
# Generate SSL certificates
sudo mysql_ssl_rsa_setup

# 5. Configure firewall for database
# MariaDB uses port 3306, PostgreSQL uses 5432
# Only open if you need remote connections
sudo firewall-cmd --permanent --add-port=3306/tcp
sudo firewall-cmd --reload

# 6. Enable audit logging
sudo tee -a /etc/my.cnf.d/audit.cnf <<EOF
[mysqld]
general_log = 1
general_log_file = /var/log/mariadb/general.log
EOF

sudo systemctl restart mariadb
```

### Maintenance Tasks

```bash
# 1. Check and repair tables
mysqlcheck -u root -p --all-databases --check

# Repair if needed
mysqlcheck -u root -p --all-databases --repair

# 2. Optimize tables (reclaim space)
mysqlcheck -u root -p --all-databases --optimize

# 3. Update statistics
mysql -u root -p -e "ANALYZE TABLE company_db.employees;"

# 4. Clean up binary logs
mysql -u root -p -e "PURGE BINARY LOGS BEFORE DATE_SUB(NOW(), INTERVAL 7 DAY);"

# 5. Monitor disk space
df -h /var/lib/mysql

# Create maintenance script
sudo tee /usr/local/bin/database_maintenance.sh <<'EOF'
#!/bin/bash
# Database Maintenance Script

LOG_FILE="/var/log/database_maintenance.log"
MYSQL_USER="root"
MYSQL_PASSWORD="YourRootPassword"

echo "Starting maintenance: $(date)" >> $LOG_FILE

# Check all tables
mysqlcheck -u $MYSQL_USER -p$MYSQL_PASSWORD --all-databases --check >> $LOG_FILE 2>&1

# Optimize tables
mysqlcheck -u $MYSQL_USER -p$MYSQL_PASSWORD --all-databases --optimize >> $LOG_FILE 2>&1

# Update statistics
mysql -u $MYSQL_USER -p$MYSQL_PASSWORD -e "SELECT CONCAT('ANALYZE TABLE ', table_schema, '.', table_name, ';') FROM information_schema.tables WHERE table_schema NOT IN ('information_schema', 'mysql', 'performance_schema');" | mysql -u $MYSQL_USER -p$MYSQL_PASSWORD >> $LOG_FILE 2>&1

# Clean old binary logs
mysql -u $MYSQL_USER -p$MYSQL_PASSWORD -e "PURGE BINARY LOGS BEFORE DATE_SUB(NOW(), INTERVAL 7 DAY);" >> $LOG_FILE 2>&1

echo "Maintenance completed: $(date)" >> $LOG_FILE
EOF

sudo chmod +x /usr/local/bin/database_maintenance.sh

# Schedule weekly maintenance
echo "0 3 * * 0 /usr/local/bin/database_maintenance.sh" | sudo tee -a /etc/crontab
```

### Troubleshooting Common Database Issues

```bash
# Issue 1: Can't connect to database
# Check if service is running
sudo systemctl status mariadb

# Check error log
sudo tail -50 /var/log/mariadb/mariadb.log

# Check if port is listening
sudo ss -tlnp | grep 3306

# Issue 2: Access denied errors
# Reset root password if forgotten
sudo systemctl stop mariadb
sudo mysqld_safe --skip-grant-tables &
mysql -u root
# In MySQL: UPDATE mysql.user SET Password=PASSWORD('NewPassword') WHERE User='root';
# FLUSH PRIVILEGES; EXIT;
sudo systemctl restart mariadb

# Issue 3: Slow queries
# Enable slow query log and analyze
sudo tail -f /var/log/mariadb/slow_queries.log

# Use EXPLAIN to analyze query performance
mysql -u root -p -e "EXPLAIN SELECT * FROM company_db.employees WHERE department = 'IT';"

# Issue 4: Database corruption
# Check table integrity
mysqlcheck -u root -p company_db employees

# Force repair
sudo systemctl stop mariadb
sudo myisamchk -r /var/lib/mysql/company_db/employees.MYI
sudo systemctl start mariadb

# Issue 5: Disk space issues
# Check disk usage
du -sh /var/lib/mysql/*

# Clear binary logs if safe
mysql -u root -p -e "RESET MASTER;"
```

## Practice Exercises

### Exercise 1: Multi-Site Web Server
1. Set up Apache with three virtual hosts
2. Configure one site with HTTPS
3. Set up a reverse proxy for one site
4. Implement basic authentication for admin area

### Exercise 2: Database-Driven Website
1. Create a MariaDB database for a blog
2. Set up proper users with limited privileges
3. Create tables for posts, users, and comments
4. Write a backup script that runs daily

### Exercise 3: Performance Testing
1. Install Apache Bench (ab)
2. Test your web server performance
3. Tune Apache/Nginx settings
4. Monitor and optimize database queries

### Exercise 4: Security Audit
1. Run a security scan on your web server
2. Implement all recommended security headers
3. Set up fail2ban for brute force protection
4. Create database audit logs

## Summary

In this part, you've learned:

**Web Server Administration:**
- Installing and configuring Apache and Nginx
- Setting up virtual hosts for multiple websites
- Implementing HTTPS with SSL/TLS
- Configuring reverse proxies
- SELinux contexts for web content
- Security hardening and performance optimization

**Database Server Management:**
- Installing and securing MariaDB and PostgreSQL
- Creating databases, tables, and users
- Backup and recovery procedures
- Performance tuning and monitoring
- Maintenance automation
- Troubleshooting common issues

These skills form the foundation for hosting web applications and managing data in enterprise environments. Remember:
- Always secure your installations first
- Regular backups are not optional
- Monitor performance before issues arise
- Keep your servers updated and patched

## Additional Resources

- Apache Performance Tuning: https://httpd.apache.org/docs/2.4/misc/perf-tuning.html
- MariaDB Knowledge Base: https://mariadb.com/kb/en/
- PostgreSQL Performance: https://wiki.postgresql.org/wiki/Performance_Optimization
- OWASP Web Security: https://owasp.org/www-project-top-ten/
- Rocky Linux Forums - Web & Database Section: https://forums.rockylinux.org/