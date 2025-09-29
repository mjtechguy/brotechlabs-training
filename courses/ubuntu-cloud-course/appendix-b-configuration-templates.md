# Appendix B: Configuration Templates

## System Configuration Templates

### /etc/sysctl.conf - System Kernel Parameters

```bash
# /etc/sysctl.conf - Production-ready kernel parameters

# Network Security
net.ipv4.tcp_syncookies = 1
net.ipv4.ip_forward = 0
net.ipv6.conf.all.forwarding = 0
net.ipv4.conf.all.rp_filter = 1
net.ipv4.conf.default.rp_filter = 1
net.ipv4.conf.all.accept_source_route = 0
net.ipv6.conf.all.accept_source_route = 0
net.ipv4.conf.all.log_martians = 1
net.ipv4.conf.all.accept_redirects = 0
net.ipv6.conf.all.accept_redirects = 0
net.ipv4.conf.all.send_redirects = 0
net.ipv4.icmp_echo_ignore_broadcasts = 1
net.ipv4.icmp_ignore_bogus_error_responses = 1

# TCP Optimization
net.core.somaxconn = 65535
net.ipv4.tcp_max_syn_backlog = 8192
net.core.netdev_max_backlog = 65536
net.ipv4.tcp_fin_timeout = 15
net.ipv4.tcp_keepalive_time = 300
net.ipv4.tcp_keepalive_probes = 5
net.ipv4.tcp_keepalive_intvl = 15
net.ipv4.tcp_tw_reuse = 1
net.ipv4.ip_local_port_range = 10000 65000

# Memory Management
vm.swappiness = 10
vm.dirty_ratio = 15
vm.dirty_background_ratio = 5
vm.vfs_cache_pressure = 50
vm.overcommit_memory = 1
vm.min_free_kbytes = 65536

# File System
fs.file-max = 2097152
fs.inotify.max_user_watches = 524288
fs.aio-max-nr = 1048576

# Core Dumps
kernel.core_uses_pid = 1
fs.suid_dumpable = 0

# Security
kernel.randomize_va_space = 2
kernel.yama.ptrace_scope = 1
kernel.panic = 60
kernel.panic_on_oops = 1

# Shared Memory
kernel.shmmax = 68719476736
kernel.shmall = 4294967296
kernel.shmmni = 4096
kernel.sem = 250 32000 100 128
```

### /etc/security/limits.conf - User Limits

```bash
# /etc/security/limits.conf - Resource limits configuration

# Default limits for all users
* soft core 0
* hard core 0
* soft nofile 65536
* hard nofile 65536
* soft nproc 32768
* hard nproc 32768
* soft memlock unlimited
* hard memlock unlimited

# Web server user limits
www-data soft nofile 65536
www-data hard nofile 65536
www-data soft nproc 32768
www-data hard nproc 32768

# Database user limits
mysql soft nofile 65536
mysql hard nofile 65536
mysql soft nproc 32768
mysql hard nproc 32768
postgres soft nofile 65536
postgres hard nofile 65536
postgres soft nproc 32768
postgres hard nproc 32768

# Application user limits
app soft nofile 32768
app hard nofile 32768
app soft nproc 16384
app hard nproc 16384
app soft memlock unlimited
app hard memlock unlimited

# Admin user limits
admin soft nofile 65536
admin hard nofile 65536
admin soft nproc 32768
admin hard nproc 32768
admin soft priority -5
admin hard priority -5
```

### /etc/fstab - File System Mount Configuration

```bash
# /etc/fstab - File system mount configuration
# <file system> <mount point> <type> <options> <dump> <pass>

# Root filesystem
UUID=abc12345-6789-def0-1234-567890abcdef / ext4 errors=remount-ro 0 1

# Boot partition
UUID=def12345-6789-abc0-1234-567890defabc /boot ext4 defaults,noatime 0 2

# Swap partition
UUID=789abcde-f012-3456-7890-abcdef012345 none swap sw 0 0

# Data partition with optimizations
UUID=456789ab-cdef-0123-4567-89abcdef0123 /data ext4 defaults,noatime,nodiratime,errors=remount-ro 0 2

# NFS mount
nfs-server:/shared /mnt/nfs nfs4 defaults,_netdev,noatime,rsize=32768,wsize=32768 0 0

# Temporary filesystems
tmpfs /tmp tmpfs defaults,noatime,nosuid,nodev,noexec,mode=1777,size=2G 0 0
tmpfs /var/tmp tmpfs defaults,noatime,nosuid,nodev,noexec,mode=1777,size=1G 0 0
tmpfs /dev/shm tmpfs defaults,noatime,nosuid,nodev,noexec,size=50% 0 0

# Bind mount for chroot
/var/www/html /srv/chroot/var/www/html none bind,ro 0 0

# USB drive auto-mount
UUID=usb12345-6789-def0-1234-567890abcdef /mnt/backup ext4 defaults,noauto,user,noatime 0 0
```

## Network Configuration Templates

### Netplan Configuration - /etc/netplan/01-netcfg.yaml

```yaml
# /etc/netplan/01-netcfg.yaml - Network configuration

network:
  version: 2
  renderer: networkd

  ethernets:
    # Primary interface with static IP
    eth0:
      addresses:
        - 192.168.1.100/24
      gateway4: 192.168.1.1
      nameservers:
        addresses:
          - 8.8.8.8
          - 8.8.4.4
        search:
          - example.com
      routes:
        - to: 10.0.0.0/8
          via: 192.168.1.254
          metric: 100
      optional: false

    # Secondary interface with DHCP
    eth1:
      dhcp4: true
      dhcp4-overrides:
        use-dns: false
        use-routes: false
      optional: true

  # Bond configuration
  bonds:
    bond0:
      dhcp4: no
      interfaces:
        - eth2
        - eth3
      addresses:
        - 10.0.0.10/24
      parameters:
        mode: active-backup
        primary: eth2
        mii-monitor-interval: 100
        up-delay: 200
        down-delay: 200

  # VLAN configuration
  vlans:
    vlan10:
      id: 10
      link: eth0
      addresses:
        - 192.168.10.100/24

    vlan20:
      id: 20
      link: eth0
      addresses:
        - 192.168.20.100/24

  # Bridge configuration
  bridges:
    br0:
      dhcp4: no
      addresses:
        - 172.16.0.1/24
      interfaces:
        - eth4
      parameters:
        stp: true
        forward-delay: 15
```

### UFW Rules Script

```bash
#!/bin/bash
# ufw-rules.sh - UFW firewall configuration script

# Reset UFW to defaults
ufw --force reset

# Set default policies
ufw default deny incoming
ufw default allow outgoing
ufw default deny routed

# Allow SSH (rate limited)
ufw limit 22/tcp comment 'SSH rate limited'

# Allow alternative SSH port
ufw allow 2222/tcp comment 'Alternative SSH'

# Allow HTTP and HTTPS
ufw allow 80/tcp comment 'HTTP'
ufw allow 443/tcp comment 'HTTPS'

# Allow DNS
ufw allow 53 comment 'DNS'

# Allow NTP
ufw allow 123/udp comment 'NTP'

# Allow SMTP
ufw allow 25/tcp comment 'SMTP'
ufw allow 587/tcp comment 'SMTP Submission'

# Allow IMAP/IMAPS
ufw allow 143/tcp comment 'IMAP'
ufw allow 993/tcp comment 'IMAPS'

# Allow POP3/POP3S
ufw allow 110/tcp comment 'POP3'
ufw allow 995/tcp comment 'POP3S'

# Allow MySQL from specific subnet
ufw allow from 192.168.1.0/24 to any port 3306 comment 'MySQL from local network'

# Allow PostgreSQL from specific IP
ufw allow from 192.168.1.50 to any port 5432 comment 'PostgreSQL from app server'

# Allow Redis from localhost only
ufw allow from 127.0.0.1 to 127.0.0.1 port 6379 comment 'Redis localhost only'

# Allow monitoring ports from monitoring server
ufw allow from 192.168.1.200 to any port 9090 comment 'Prometheus'
ufw allow from 192.168.1.200 to any port 9100 comment 'Node Exporter'
ufw allow from 192.168.1.200 to any port 3000 comment 'Grafana'

# Allow custom application port range
ufw allow 8000:8100/tcp comment 'Application servers'

# Logging
ufw logging on
ufw logging medium

# Enable UFW
ufw --force enable

# Show status
ufw status verbose
```

### IPTables Rules Script

```bash
#!/bin/bash
# iptables-rules.sh - Advanced iptables configuration

# Variables
WAN_IFACE="eth0"
LAN_IFACE="eth1"
LAN_NET="192.168.1.0/24"
ALLOWED_TCP="22,80,443"
ALLOWED_UDP="53,123"

# Flush existing rules
iptables -F
iptables -X
iptables -t nat -F
iptables -t nat -X
iptables -t mangle -F
iptables -t mangle -X

# Default policies
iptables -P INPUT DROP
iptables -P FORWARD DROP
iptables -P OUTPUT ACCEPT

# Loopback
iptables -A INPUT -i lo -j ACCEPT
iptables -A OUTPUT -o lo -j ACCEPT

# Established connections
iptables -A INPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT
iptables -A FORWARD -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT

# Invalid packets
iptables -A INPUT -m conntrack --ctstate INVALID -j DROP

# Rate limiting
iptables -N RATE_LIMIT
iptables -A RATE_LIMIT -m limit --limit 100/sec --limit-burst 200 -j RETURN
iptables -A RATE_LIMIT -j DROP

# SYN flood protection
iptables -N SYN_FLOOD
iptables -A SYN_FLOOD -m limit --limit 10/sec --limit-burst 20 -j RETURN
iptables -A SYN_FLOOD -j DROP
iptables -A INPUT -p tcp --syn -j SYN_FLOOD

# Port scan detection
iptables -N PORT_SCAN
iptables -A PORT_SCAN -m recent --set --name portscan
iptables -A PORT_SCAN -m recent --update --seconds 60 --hitcount 4 --name portscan -j DROP
iptables -A INPUT -p tcp --tcp-flags ALL FIN,URG,PSH -j PORT_SCAN
iptables -A INPUT -p tcp --tcp-flags ALL ALL -j PORT_SCAN
iptables -A INPUT -p tcp --tcp-flags ALL NONE -j PORT_SCAN

# ICMP
iptables -A INPUT -p icmp --icmp-type echo-request -m limit --limit 1/sec -j ACCEPT
iptables -A INPUT -p icmp --icmp-type echo-reply -j ACCEPT
iptables -A INPUT -p icmp --icmp-type destination-unreachable -j ACCEPT
iptables -A INPUT -p icmp --icmp-type time-exceeded -j ACCEPT

# Allowed services
iptables -A INPUT -p tcp -m multiport --dports $ALLOWED_TCP -j ACCEPT
iptables -A INPUT -p udp -m multiport --dports $ALLOWED_UDP -j ACCEPT

# SSH brute force protection
iptables -A INPUT -p tcp --dport 22 -m conntrack --ctstate NEW -m recent --set
iptables -A INPUT -p tcp --dport 22 -m conntrack --ctstate NEW -m recent --update --seconds 60 --hitcount 4 -j DROP

# NAT for LAN
iptables -t nat -A POSTROUTING -s $LAN_NET -o $WAN_IFACE -j MASQUERADE
iptables -A FORWARD -i $LAN_IFACE -o $WAN_IFACE -j ACCEPT
iptables -A FORWARD -i $WAN_IFACE -o $LAN_IFACE -m state --state RELATED,ESTABLISHED -j ACCEPT

# Port forwarding example
# iptables -t nat -A PREROUTING -i $WAN_IFACE -p tcp --dport 8080 -j DNAT --to-destination 192.168.1.100:80
# iptables -A FORWARD -p tcp -d 192.168.1.100 --dport 80 -j ACCEPT

# Logging
iptables -N LOGGING
iptables -A INPUT -j LOGGING
iptables -A LOGGING -m limit --limit 2/min -j LOG --log-prefix "iptables-dropped: " --log-level 4
iptables -A LOGGING -j DROP

# Save rules
iptables-save > /etc/iptables/rules.v4
ip6tables-save > /etc/iptables/rules.v6

echo "Firewall rules applied successfully"
```

## Service Configuration Templates

### Nginx Web Server - /etc/nginx/sites-available/example.com

```nginx
# /etc/nginx/sites-available/example.com - Production web server configuration

# Redirect HTTP to HTTPS
server {
    listen 80;
    listen [::]:80;
    server_name example.com www.example.com;

    # ACME challenge for Let's Encrypt
    location /.well-known/acme-challenge/ {
        root /var/www/certbot;
    }

    # Redirect all other requests to HTTPS
    location / {
        return 301 https://$server_name$request_uri;
    }
}

# Main HTTPS server block
server {
    listen 443 ssl http2;
    listen [::]:443 ssl http2;
    server_name example.com www.example.com;

    # Document root
    root /var/www/example.com/public;
    index index.html index.htm index.php;

    # SSL Configuration
    ssl_certificate /etc/letsencrypt/live/example.com/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/example.com/privkey.pem;
    ssl_trusted_certificate /etc/letsencrypt/live/example.com/chain.pem;

    # SSL Security Settings
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-AES256-GCM-SHA384;
    ssl_prefer_server_ciphers off;
    ssl_session_timeout 1d;
    ssl_session_cache shared:SSL:50m;
    ssl_stapling on;
    ssl_stapling_verify on;

    # Security Headers
    add_header Strict-Transport-Security "max-age=31536000; includeSubDomains; preload" always;
    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header X-XSS-Protection "1; mode=block" always;
    add_header Referrer-Policy "strict-origin-when-cross-origin" always;
    add_header Content-Security-Policy "default-src 'self'; script-src 'self' 'unsafe-inline' 'unsafe-eval'; style-src 'self' 'unsafe-inline';" always;

    # Logging
    access_log /var/log/nginx/example.com_access.log combined buffer=32k;
    error_log /var/log/nginx/example.com_error.log error;

    # Gzip Compression
    gzip on;
    gzip_vary on;
    gzip_comp_level 6;
    gzip_types text/plain text/css text/xml text/javascript application/json application/javascript application/xml+rss application/rss+xml application/atom+xml image/svg+xml text/javascript application/vnd.ms-fontobject application/x-font-ttf font/opentype;

    # Cache Control
    location ~* \.(jpg|jpeg|gif|png|svg|webp|ico|woff|woff2|ttf|otf|eot|mp4|webm|ogg|mp3|wav|flac|aac)$ {
        expires 30d;
        add_header Cache-Control "public, immutable";
        access_log off;
    }

    location ~* \.(css|js)$ {
        expires 7d;
        add_header Cache-Control "public";
    }

    # Main location
    location / {
        try_files $uri $uri/ /index.php?$query_string;
    }

    # PHP-FPM Configuration
    location ~ \.php$ {
        try_files $uri =404;
        fastcgi_split_path_info ^(.+\.php)(/.+)$;
        fastcgi_pass unix:/var/run/php/php8.1-fpm.sock;
        fastcgi_index index.php;
        fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
        include fastcgi_params;

        # PHP-FPM Settings
        fastcgi_buffer_size 128k;
        fastcgi_buffers 256 16k;
        fastcgi_busy_buffers_size 256k;
        fastcgi_temp_file_write_size 256k;
        fastcgi_read_timeout 600;
    }

    # Deny access to hidden files
    location ~ /\. {
        deny all;
        access_log off;
        log_not_found off;
    }

    # Deny access to sensitive files
    location ~* \.(engine|inc|info|install|make|module|profile|test|po|sh|.*sql|theme|tpl(\.php)?|xtmpl)$|^(\..*|Entries.*|Repository|Root|Tag|Template)$|\.php_ {
        return 403;
    }

    # Rate limiting
    limit_req_zone $binary_remote_addr zone=one:10m rate=10r/s;
    limit_req zone=one burst=20 nodelay;

    # Client body size limit
    client_max_body_size 100M;
    client_body_buffer_size 128k;

    # Timeouts
    client_body_timeout 60;
    client_header_timeout 60;
    keepalive_timeout 65;
    send_timeout 60;
}
```

### Apache2 Configuration - /etc/apache2/sites-available/example.com.conf

```apache
# /etc/apache2/sites-available/example.com.conf - Apache configuration

<VirtualHost *:80>
    ServerName example.com
    ServerAlias www.example.com

    # Redirect to HTTPS
    RewriteEngine On
    RewriteCond %{SERVER_NAME} =example.com [OR]
    RewriteCond %{SERVER_NAME} =www.example.com
    RewriteRule ^ https://%{SERVER_NAME}%{REQUEST_URI} [END,NE,R=permanent]
</VirtualHost>

<VirtualHost *:443>
    ServerName example.com
    ServerAlias www.example.com
    ServerAdmin webmaster@example.com

    # Document Root
    DocumentRoot /var/www/example.com/public

    # Directory Configuration
    <Directory /var/www/example.com/public>
        Options -Indexes +FollowSymLinks
        AllowOverride All
        Require all granted

        # URL Rewriting
        <IfModule mod_rewrite.c>
            RewriteEngine On
            RewriteCond %{REQUEST_FILENAME} !-f
            RewriteCond %{REQUEST_FILENAME} !-d
            RewriteRule ^(.*)$ index.php/$1 [L]
        </IfModule>
    </Directory>

    # SSL Configuration
    SSLEngine on
    SSLCertificateFile /etc/letsencrypt/live/example.com/fullchain.pem
    SSLCertificateKeyFile /etc/letsencrypt/live/example.com/privkey.pem
    SSLCertificateChainFile /etc/letsencrypt/live/example.com/chain.pem

    # SSL Protocol and Cipher Configuration
    SSLProtocol -all +TLSv1.2 +TLSv1.3
    SSLCipherSuite ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384
    SSLHonorCipherOrder off
    SSLSessionTickets off

    # Security Headers
    Header always set Strict-Transport-Security "max-age=31536000; includeSubDomains; preload"
    Header always set X-Frame-Options "SAMEORIGIN"
    Header always set X-Content-Type-Options "nosniff"
    Header always set X-XSS-Protection "1; mode=block"
    Header always set Referrer-Policy "strict-origin-when-cross-origin"

    # PHP-FPM Proxy Configuration
    <FilesMatch \.php$>
        SetHandler "proxy:unix:/var/run/php/php8.1-fpm.sock|fcgi://localhost"
    </FilesMatch>

    # Compression
    <IfModule mod_deflate.c>
        AddOutputFilterByType DEFLATE text/html text/plain text/xml text/css text/javascript application/javascript application/json
    </IfModule>

    # Caching
    <IfModule mod_expires.c>
        ExpiresActive On
        ExpiresByType image/jpeg "access plus 30 days"
        ExpiresByType image/png "access plus 30 days"
        ExpiresByType image/gif "access plus 30 days"
        ExpiresByType image/webp "access plus 30 days"
        ExpiresByType text/css "access plus 7 days"
        ExpiresByType application/javascript "access plus 7 days"
    </IfModule>

    # Logging
    ErrorLog ${APACHE_LOG_DIR}/example.com_error.log
    CustomLog ${APACHE_LOG_DIR}/example.com_access.log combined

    # Rate Limiting (requires mod_ratelimit)
    <IfModule mod_ratelimit.c>
        <Location />
            SetOutputFilter RATE_LIMIT
            SetEnv rate-limit 1024
        </Location>
    </IfModule>
</VirtualHost>
```

### MySQL Configuration - /etc/mysql/mysql.conf.d/mysqld.cnf

```ini
# /etc/mysql/mysql.conf.d/mysqld.cnf - MySQL production configuration

[mysqld]
# Basic Settings
user = mysql
pid-file = /var/run/mysqld/mysqld.pid
socket = /var/run/mysqld/mysqld.sock
port = 3306
basedir = /usr
datadir = /var/lib/mysql
tmpdir = /tmp
lc-messages-dir = /usr/share/mysql

# Network and Connections
bind-address = 127.0.0.1
skip-external-locking
max_connections = 500
max_user_connections = 50
connect_timeout = 10
wait_timeout = 600
interactive_timeout = 600
max_allowed_packet = 64M

# Character Set
character-set-server = utf8mb4
collation-server = utf8mb4_unicode_ci

# Storage Engine
default-storage-engine = InnoDB
innodb_file_per_table = 1

# InnoDB Settings
innodb_buffer_pool_size = 2G
innodb_log_file_size = 256M
innodb_flush_log_at_trx_commit = 2
innodb_flush_method = O_DIRECT
innodb_lock_wait_timeout = 50
innodb_read_io_threads = 8
innodb_write_io_threads = 8
innodb_io_capacity = 2000
innodb_io_capacity_max = 3000
innodb_thread_concurrency = 0
innodb_autoinc_lock_mode = 2

# Query Cache (deprecated in MySQL 8.0)
# query_cache_type = 1
# query_cache_limit = 2M
# query_cache_size = 64M

# Logging
general_log = 0
general_log_file = /var/log/mysql/general.log
error_log = /var/log/mysql/error.log
log_warnings = 2

# Slow Query Log
slow_query_log = 1
slow_query_log_file = /var/log/mysql/slow.log
long_query_time = 2
log_queries_not_using_indexes = 1

# Binary Logging (for replication and point-in-time recovery)
server-id = 1
log_bin = /var/log/mysql/mysql-bin.log
binlog_format = MIXED
expire_logs_days = 7
max_binlog_size = 100M
sync_binlog = 1

# Performance Schema
performance_schema = ON

# Thread Settings
thread_cache_size = 50
thread_stack = 256K

# Table Settings
table_open_cache = 4000
table_definition_cache = 2000

# Temporary Table Settings
tmp_table_size = 128M
max_heap_table_size = 128M

# Sort and Join Buffers
sort_buffer_size = 2M
join_buffer_size = 2M
read_buffer_size = 2M
read_rnd_buffer_size = 8M

# MyISAM Settings (if still used)
key_buffer_size = 128M
myisam_sort_buffer_size = 64M
myisam_max_sort_file_size = 2G

# Security
local_infile = 0
skip_name_resolve = 1
```

### PostgreSQL Configuration - /etc/postgresql/14/main/postgresql.conf

```ini
# /etc/postgresql/14/main/postgresql.conf - PostgreSQL configuration

#------------------------------------------------------------------------------
# CONNECTION AND AUTHENTICATION
#------------------------------------------------------------------------------

listen_addresses = 'localhost'
port = 5432
max_connections = 200
superuser_reserved_connections = 3

#------------------------------------------------------------------------------
# RESOURCE USAGE (MEMORY)
#------------------------------------------------------------------------------

shared_buffers = 2GB
huge_pages = try
work_mem = 10MB
maintenance_work_mem = 512MB
autovacuum_work_mem = -1
max_stack_depth = 2MB
temp_buffers = 16MB
dynamic_shared_memory_type = posix

#------------------------------------------------------------------------------
# DISK
#------------------------------------------------------------------------------

temp_file_limit = -1

#------------------------------------------------------------------------------
# KERNEL RESOURCES
#------------------------------------------------------------------------------

max_files_per_process = 1000
max_worker_processes = 8
max_parallel_workers_per_gather = 2
max_parallel_maintenance_workers = 2
max_parallel_workers = 8

#------------------------------------------------------------------------------
# COST-BASED VACUUM DELAY
#------------------------------------------------------------------------------

vacuum_cost_delay = 0
vacuum_cost_page_hit = 1
vacuum_cost_page_miss = 10
vacuum_cost_page_dirty = 20
vacuum_cost_limit = 200

#------------------------------------------------------------------------------
# BACKGROUND WRITER
#------------------------------------------------------------------------------

bgwriter_delay = 200ms
bgwriter_lru_maxpages = 100
bgwriter_lru_multiplier = 2.0
bgwriter_flush_after = 512kB

#------------------------------------------------------------------------------
# ASYNCHRONOUS BEHAVIOR
#------------------------------------------------------------------------------

effective_io_concurrency = 200
maintenance_io_concurrency = 200
max_worker_processes = 8
max_parallel_workers = 8
max_parallel_maintenance_workers = 2
max_parallel_workers_per_gather = 2

#------------------------------------------------------------------------------
# WRITE-AHEAD LOG
#------------------------------------------------------------------------------

wal_level = replica
fsync = on
synchronous_commit = on
wal_sync_method = fdatasync
full_page_writes = on
wal_compression = on
wal_log_hints = off
wal_buffers = 16MB
wal_writer_delay = 200ms
wal_writer_flush_after = 1MB
checkpoint_timeout = 15min
checkpoint_completion_target = 0.9
checkpoint_flush_after = 256kB
checkpoint_warning = 30s
max_wal_size = 4GB
min_wal_size = 1GB
archive_mode = on
archive_command = 'test ! -f /var/lib/postgresql/14/archive/%f && cp %p /var/lib/postgresql/14/archive/%f'
archive_timeout = 0

#------------------------------------------------------------------------------
# REPLICATION
#------------------------------------------------------------------------------

max_wal_senders = 10
wal_keep_size = 1GB
max_slot_wal_keep_size = -1
wal_sender_timeout = 60s
max_replication_slots = 10

#------------------------------------------------------------------------------
# QUERY TUNING
#------------------------------------------------------------------------------

random_page_cost = 1.1
cpu_tuple_cost = 0.01
cpu_index_tuple_cost = 0.005
cpu_operator_cost = 0.0025
parallel_setup_cost = 1000.0
parallel_tuple_cost = 0.1
min_parallel_table_scan_size = 8MB
min_parallel_index_scan_size = 512kB
effective_cache_size = 6GB

#------------------------------------------------------------------------------
# REPORTING AND LOGGING
#------------------------------------------------------------------------------

log_destination = 'csvlog'
logging_collector = on
log_directory = 'log'
log_filename = 'postgresql-%Y-%m-%d_%H%M%S.log'
log_file_mode = 0640
log_truncate_on_rotation = off
log_rotation_age = 1d
log_rotation_size = 100MB
log_min_duration_statement = 1000
log_checkpoints = on
log_connections = on
log_disconnections = on
log_duration = off
log_error_verbosity = default
log_hostname = off
log_line_prefix = '%t [%p]: user=%u,db=%d,app=%a,client=%h '
log_lock_waits = on
log_statement = 'none'
log_replication_commands = off
log_temp_files = 0
log_timezone = 'UTC'

#------------------------------------------------------------------------------
# STATISTICS
#------------------------------------------------------------------------------

track_activities = on
track_activity_query_size = 1024
track_counts = on
track_io_timing = on
track_functions = all
track_wal_io_timing = on
stats_temp_directory = '/var/run/postgresql/14-main.pg_stat_tmp'

#------------------------------------------------------------------------------
# AUTOVACUUM
#------------------------------------------------------------------------------

autovacuum = on
log_autovacuum_min_duration = 0
autovacuum_max_workers = 3
autovacuum_naptime = 1min
autovacuum_vacuum_threshold = 50
autovacuum_vacuum_insert_threshold = 1000
autovacuum_analyze_threshold = 50
autovacuum_vacuum_scale_factor = 0.1
autovacuum_vacuum_insert_scale_factor = 0.2
autovacuum_analyze_scale_factor = 0.05
autovacuum_freeze_max_age = 200000000
autovacuum_multixact_freeze_max_age = 400000000
autovacuum_vacuum_cost_delay = 2ms
autovacuum_vacuum_cost_limit = -1

#------------------------------------------------------------------------------
# CLIENT CONNECTION DEFAULTS
#------------------------------------------------------------------------------

datestyle = 'iso, mdy'
intervalstyle = 'postgres'
timezone = 'UTC'
lc_messages = 'en_US.UTF-8'
lc_monetary = 'en_US.UTF-8'
lc_numeric = 'en_US.UTF-8'
lc_time = 'en_US.UTF-8'
default_text_search_config = 'pg_catalog.english'

#------------------------------------------------------------------------------
# LOCK MANAGEMENT
#------------------------------------------------------------------------------

deadlock_timeout = 1s
max_locks_per_transaction = 64
max_pred_locks_per_transaction = 64
max_pred_locks_per_relation = -2
max_pred_locks_per_page = 2

#------------------------------------------------------------------------------
# VERSION AND PLATFORM COMPATIBILITY
#------------------------------------------------------------------------------

array_nulls = on
backslash_quote = safe_encoding
escape_string_warning = on
lo_compat_privileges = off
quote_all_identifiers = off
standard_conforming_strings = on
synchronize_seqscans = on

#------------------------------------------------------------------------------
# EXTENSIONS
#------------------------------------------------------------------------------

shared_preload_libraries = 'pg_stat_statements'
pg_stat_statements.max = 10000
pg_stat_statements.track = all
```

## Security Configuration Templates

### SSH Configuration - /etc/ssh/sshd_config

```bash
# /etc/ssh/sshd_config - Hardened SSH configuration

# Port and Protocol
Port 22
#Port 2222  # Alternative port
Protocol 2
AddressFamily inet

# Host Keys
HostKey /etc/ssh/ssh_host_rsa_key
HostKey /etc/ssh/ssh_host_ed25519_key

# Ciphers and Algorithms
Ciphers chacha20-poly1305@openssh.com,aes128-ctr,aes192-ctr,aes256-ctr,aes128-gcm@openssh.com,aes256-gcm@openssh.com
MACs umac-64-etm@openssh.com,umac-128-etm@openssh.com,hmac-sha2-256-etm@openssh.com,hmac-sha2-512-etm@openssh.com,hmac-sha1-etm@openssh.com
KexAlgorithms curve25519-sha256,curve25519-sha256@libssh.org,diffie-hellman-group14-sha256,diffie-hellman-group16-sha512,diffie-hellman-group18-sha512

# Authentication
LoginGraceTime 30
PermitRootLogin no
StrictModes yes
MaxAuthTries 3
MaxSessions 10
PubkeyAuthentication yes
AuthorizedKeysFile .ssh/authorized_keys
PasswordAuthentication no
PermitEmptyPasswords no
ChallengeResponseAuthentication no
UsePAM yes

# User/Group Restrictions
AllowUsers admin deploy
#AllowGroups ssh-users
#DenyUsers root
#DenyGroups root

# Security Features
IgnoreRhosts yes
HostbasedAuthentication no
X11Forwarding no
PrintMotd no
PrintLastLog yes
TCPKeepAlive yes
Compression delayed
ClientAliveInterval 300
ClientAliveCountMax 2
UseDNS no
MaxStartups 10:30:100

# Logging
SyslogFacility AUTH
LogLevel VERBOSE

# SFTP Configuration
Subsystem sftp /usr/lib/openssh/sftp-server -f AUTHPRIV -l INFO

# Banner
Banner /etc/ssh/banner.txt

# Allow specific commands only for certain users
#Match User backup
#    ForceCommand /usr/local/bin/backup.sh
#    PasswordAuthentication no
#    PermitTunnel no
#    AllowAgentForwarding no
#    X11Forwarding no

# Chroot jail for SFTP users
#Match Group sftponly
#    ChrootDirectory /srv/sftp/%u
#    ForceCommand internal-sftp
#    AllowTcpForwarding no
#    X11Forwarding no
```

### Fail2ban Configuration - /etc/fail2ban/jail.local

```ini
# /etc/fail2ban/jail.local - Fail2ban configuration

[DEFAULT]
# Ban duration and retry settings
bantime = 3600
findtime = 600
maxretry = 5
destemail = admin@example.com
sender = fail2ban@example.com
action = %(action_mwl)s

# Whitelist
ignoreip = 127.0.0.1/8 ::1 192.168.1.0/24

[sshd]
enabled = true
port = ssh
filter = sshd
logpath = /var/log/auth.log
maxretry = 3
bantime = 7200

[sshd-ddos]
enabled = true
port = ssh
filter = sshd-ddos
logpath = /var/log/auth.log
maxretry = 10
findtime = 60
bantime = 3600

[nginx-http-auth]
enabled = true
filter = nginx-http-auth
port = http,https
logpath = /var/log/nginx/error.log
maxretry = 3
bantime = 3600

[nginx-noscript]
enabled = true
port = http,https
filter = nginx-noscript
logpath = /var/log/nginx/access.log
maxretry = 6
bantime = 86400

[nginx-badbots]
enabled = true
port = http,https
filter = nginx-badbots
logpath = /var/log/nginx/access.log
maxretry = 2
bantime = 86400

[nginx-noproxy]
enabled = true
port = http,https
filter = nginx-noproxy
logpath = /var/log/nginx/error.log
maxretry = 2
bantime = 86400

[nginx-rate-limit]
enabled = true
filter = nginx-limit-req
port = http,https
logpath = /var/log/nginx/error.log
maxretry = 10
findtime = 60
bantime = 3600

[apache-auth]
enabled = false
port = http,https
filter = apache-auth
logpath = /var/log/apache2/*error.log
maxretry = 3
bantime = 3600

[mysqld]
enabled = true
port = 3306
filter = mysqld-auth
logpath = /var/log/mysql/error.log
maxretry = 5
bantime = 3600

[postfix]
enabled = true
port = smtp,465,587
filter = postfix
logpath = /var/log/mail.log
maxretry = 5
bantime = 3600

[dovecot]
enabled = true
port = pop3,pop3s,imap,imaps,submission,465,587
filter = dovecot
logpath = /var/log/mail.log
maxretry = 5
bantime = 3600

[recidive]
enabled = true
filter = recidive
logpath = /var/log/fail2ban.log
action = %(action_mwl)s
bantime = 86400
maxretry = 3
```

### AppArmor Profile - /etc/apparmor.d/usr.sbin.nginx

```bash
# /etc/apparmor.d/usr.sbin.nginx - AppArmor profile for Nginx

#include <tunables/global>

/usr/sbin/nginx {
  #include <abstractions/base>
  #include <abstractions/nameservice>
  #include <abstractions/openssl>

  capability dac_override,
  capability dac_read_search,
  capability net_bind_service,
  capability setgid,
  capability setuid,

  /usr/sbin/nginx mr,

  # Configuration files
  /etc/nginx/ r,
  /etc/nginx/** r,

  # SSL certificates
  /etc/ssl/certs/ r,
  /etc/ssl/certs/** r,
  /etc/letsencrypt/live/*/fullchain.pem r,
  /etc/letsencrypt/live/*/privkey.pem r,
  /etc/letsencrypt/live/*/chain.pem r,

  # Log files
  /var/log/nginx/ w,
  /var/log/nginx/** w,

  # PID file
  /run/nginx.pid rw,

  # Temporary files
  /var/cache/nginx/ w,
  /var/cache/nginx/** w,
  /var/lib/nginx/ w,
  /var/lib/nginx/** w,

  # Web content
  /var/www/ r,
  /var/www/** r,

  # Deny access to sensitive areas
  deny /home/*/,
  deny /root/,
  deny /etc/shadow,
  deny /etc/gshadow,

  # Network access
  network inet tcp,
  network inet6 tcp,
}
```

## Monitoring Configuration Templates

### Prometheus Configuration - /etc/prometheus/prometheus.yml

```yaml
# /etc/prometheus/prometheus.yml - Prometheus monitoring configuration

global:
  scrape_interval: 15s
  evaluation_interval: 15s
  scrape_timeout: 10s
  external_labels:
    monitor: 'production'
    datacenter: 'us-east-1'

# Alertmanager configuration
alerting:
  alertmanagers:
    - static_configs:
        - targets:
            - localhost:9093

# Load rules once and periodically evaluate them
rule_files:
  - "alerts/*.yml"
  - "rules/*.yml"

# Scrape configurations
scrape_configs:
  # Prometheus itself
  - job_name: 'prometheus'
    static_configs:
      - targets: ['localhost:9090']
        labels:
          instance: 'prometheus-server'

  # Node Exporter - System metrics
  - job_name: 'node'
    static_configs:
      - targets:
          - 'localhost:9100'
          - 'web-server-1:9100'
          - 'web-server-2:9100'
          - 'db-server-1:9100'
        labels:
          environment: 'production'
    relabel_configs:
      - source_labels: [__address__]
        target_label: instance
        regex: '([^:]+)(?::\d+)?'
        replacement: '${1}'

  # MySQL Exporter
  - job_name: 'mysql'
    static_configs:
      - targets:
          - 'db-server-1:9104'
        labels:
          environment: 'production'
          role: 'master'

  # PostgreSQL Exporter
  - job_name: 'postgres'
    static_configs:
      - targets:
          - 'db-server-2:9187'
        labels:
          environment: 'production'

  # Nginx Exporter
  - job_name: 'nginx'
    static_configs:
      - targets:
          - 'web-server-1:9113'
          - 'web-server-2:9113'
        labels:
          environment: 'production'

  # Blackbox Exporter - Website monitoring
  - job_name: 'blackbox-http'
    metrics_path: /probe
    params:
      module: [http_2xx]
    static_configs:
      - targets:
          - https://example.com
          - https://api.example.com
    relabel_configs:
      - source_labels: [__address__]
        target_label: __param_target
      - source_labels: [__param_target]
        target_label: instance
      - target_label: __address__
        replacement: localhost:9115

  # Service Discovery - Kubernetes
  - job_name: 'kubernetes-pods'
    kubernetes_sd_configs:
      - role: pod
    relabel_configs:
      - source_labels: [__meta_kubernetes_pod_annotation_prometheus_io_scrape]
        action: keep
        regex: true
      - source_labels: [__meta_kubernetes_pod_annotation_prometheus_io_path]
        action: replace
        target_label: __metrics_path__
        regex: (.+)
      - source_labels: [__address__, __meta_kubernetes_pod_annotation_prometheus_io_port]
        action: replace
        regex: ([^:]+)(?::\d+)?;(\d+)
        replacement: $1:$2
        target_label: __address__
```

### Alerting Rules - /etc/prometheus/alerts/system.yml

```yaml
# /etc/prometheus/alerts/system.yml - Prometheus alerting rules

groups:
  - name: system
    interval: 30s
    rules:
      # High CPU usage
      - alert: HighCPUUsage
        expr: 100 - (avg(rate(node_cpu_seconds_total{mode="idle"}[5m])) * 100) > 80
        for: 5m
        labels:
          severity: warning
        annotations:
          summary: "High CPU usage detected on {{ $labels.instance }}"
          description: "CPU usage is above 80% (current value: {{ $value }}%)"

      # High memory usage
      - alert: HighMemoryUsage
        expr: (1 - (node_memory_MemAvailable_bytes / node_memory_MemTotal_bytes)) * 100 > 90
        for: 5m
        labels:
          severity: warning
        annotations:
          summary: "High memory usage on {{ $labels.instance }}"
          description: "Memory usage is above 90% (current value: {{ $value }}%)"

      # Disk space low
      - alert: DiskSpaceLow
        expr: (node_filesystem_avail_bytes{mountpoint="/"} / node_filesystem_size_bytes{mountpoint="/"}) * 100 < 10
        for: 5m
        labels:
          severity: critical
        annotations:
          summary: "Low disk space on {{ $labels.instance }}"
          description: "Disk space is below 10% (current value: {{ $value }}%)"

      # Node down
      - alert: NodeDown
        expr: up == 0
        for: 1m
        labels:
          severity: critical
        annotations:
          summary: "Node {{ $labels.instance }} is down"
          description: "{{ $labels.instance }} has been down for more than 1 minute"

      # High load average
      - alert: HighLoadAverage
        expr: node_load1 / on(instance) count(node_cpu_seconds_total{mode="idle"}) by (instance) > 2
        for: 5m
        labels:
          severity: warning
        annotations:
          summary: "High load average on {{ $labels.instance }}"
          description: "Load average is high (current value: {{ $value }})"

      # Service down
      - alert: ServiceDown
        expr: node_systemd_unit_state{state="active"} == 0
        for: 2m
        labels:
          severity: critical
        annotations:
          summary: "Service {{ $labels.name }} is down on {{ $labels.instance }}"
          description: "Service {{ $labels.name }} has been down for more than 2 minutes"

  - name: network
    interval: 30s
    rules:
      # High network traffic
      - alert: HighNetworkTraffic
        expr: rate(node_network_receive_bytes_total[5m]) > 100000000
        for: 5m
        labels:
          severity: warning
        annotations:
          summary: "High network traffic on {{ $labels.instance }}"
          description: "Network traffic is above 100MB/s (current value: {{ $value }}B/s)"

      # Network errors
      - alert: NetworkErrors
        expr: rate(node_network_receive_errs_total[5m]) > 100
        for: 5m
        labels:
          severity: warning
        annotations:
          summary: "Network errors on {{ $labels.instance }}"
          description: "Network interface {{ $labels.device }} has errors"

  - name: database
    interval: 30s
    rules:
      # MySQL down
      - alert: MySQLDown
        expr: mysql_up == 0
        for: 1m
        labels:
          severity: critical
        annotations:
          summary: "MySQL is down on {{ $labels.instance }}"
          description: "MySQL has been down for more than 1 minute"

      # PostgreSQL down
      - alert: PostgreSQLDown
        expr: pg_up == 0
        for: 1m
        labels:
          severity: critical
        annotations:
          summary: "PostgreSQL is down on {{ $labels.instance }}"
          description: "PostgreSQL has been down for more than 1 minute"

      # Slow queries
      - alert: SlowQueries
        expr: rate(mysql_global_status_slow_queries[5m]) > 10
        for: 5m
        labels:
          severity: warning
        annotations:
          summary: "High number of slow queries on {{ $labels.instance }}"
          description: "More than 10 slow queries per second"
```

### Grafana Dashboard JSON - Basic System Monitoring

```json
{
  "dashboard": {
    "id": null,
    "title": "System Monitoring",
    "tags": ["system", "linux"],
    "timezone": "browser",
    "panels": [
      {
        "id": 1,
        "gridPos": {"x": 0, "y": 0, "w": 12, "h": 8},
        "type": "graph",
        "title": "CPU Usage",
        "datasource": "Prometheus",
        "targets": [
          {
            "expr": "100 - (avg(irate(node_cpu_seconds_total{mode=\"idle\"}[5m])) by (instance) * 100)",
            "legendFormat": "{{ instance }}",
            "refId": "A"
          }
        ],
        "yaxes": [
          {"format": "percent", "min": 0, "max": 100}
        ]
      },
      {
        "id": 2,
        "gridPos": {"x": 12, "y": 0, "w": 12, "h": 8},
        "type": "graph",
        "title": "Memory Usage",
        "datasource": "Prometheus",
        "targets": [
          {
            "expr": "(1 - (node_memory_MemAvailable_bytes / node_memory_MemTotal_bytes)) * 100",
            "legendFormat": "{{ instance }}",
            "refId": "A"
          }
        ],
        "yaxes": [
          {"format": "percent", "min": 0, "max": 100}
        ]
      },
      {
        "id": 3,
        "gridPos": {"x": 0, "y": 8, "w": 12, "h": 8},
        "type": "graph",
        "title": "Disk Usage",
        "datasource": "Prometheus",
        "targets": [
          {
            "expr": "(1 - (node_filesystem_avail_bytes{mountpoint=\"/\"} / node_filesystem_size_bytes{mountpoint=\"/\"})) * 100",
            "legendFormat": "{{ instance }}",
            "refId": "A"
          }
        ],
        "yaxes": [
          {"format": "percent", "min": 0, "max": 100}
        ]
      },
      {
        "id": 4,
        "gridPos": {"x": 12, "y": 8, "w": 12, "h": 8},
        "type": "graph",
        "title": "Network Traffic",
        "datasource": "Prometheus",
        "targets": [
          {
            "expr": "rate(node_network_receive_bytes_total{device!~\"lo\"}[5m])",
            "legendFormat": "{{ instance }} - RX",
            "refId": "A"
          },
          {
            "expr": "rate(node_network_transmit_bytes_total{device!~\"lo\"}[5m])",
            "legendFormat": "{{ instance }} - TX",
            "refId": "B"
          }
        ],
        "yaxes": [
          {"format": "Bps"}
        ]
      }
    ],
    "schemaVersion": 27,
    "version": 1
  }
}
```

## Automation Templates

### Ansible Playbook - System Setup

```yaml
---
# ansible-playbook.yml - Complete system setup playbook

- name: Ubuntu Server Initial Setup
  hosts: all
  become: yes
  vars:
    admin_users:
      - name: admin
        groups: sudo,adm
        shell: /bin/bash
        ssh_key: "ssh-rsa AAAAB3NzaC1yc2E..."

    packages_to_install:
      - vim
      - htop
      - git
      - curl
      - wget
      - ufw
      - fail2ban
      - unattended-upgrades
      - prometheus-node-exporter

    sysctl_settings:
      net.ipv4.tcp_syncookies: 1
      net.ipv4.ip_forward: 0
      vm.swappiness: 10

  tasks:
    - name: Update package cache
      apt:
        update_cache: yes
        cache_valid_time: 3600

    - name: Upgrade all packages
      apt:
        upgrade: full
        autoremove: yes
        autoclean: yes

    - name: Install essential packages
      apt:
        name: "{{ packages_to_install }}"
        state: present

    - name: Create admin users
      user:
        name: "{{ item.name }}"
        groups: "{{ item.groups }}"
        shell: "{{ item.shell }}"
        create_home: yes
        state: present
      loop: "{{ admin_users }}"

    - name: Add SSH keys for admin users
      authorized_key:
        user: "{{ item.name }}"
        key: "{{ item.ssh_key }}"
        state: present
      loop: "{{ admin_users }}"

    - name: Configure sysctl parameters
      sysctl:
        name: "{{ item.key }}"
        value: "{{ item.value }}"
        state: present
        reload: yes
      loop: "{{ sysctl_settings | dict2items }}"

    - name: Configure UFW defaults
      ufw:
        direction: "{{ item.direction }}"
        policy: "{{ item.policy }}"
      loop:
        - { direction: 'incoming', policy: 'deny' }
        - { direction: 'outgoing', policy: 'allow' }

    - name: Configure UFW rules
      ufw:
        rule: "{{ item.rule }}"
        port: "{{ item.port }}"
        proto: "{{ item.proto }}"
      loop:
        - { rule: 'limit', port: '22', proto: 'tcp' }
        - { rule: 'allow', port: '80', proto: 'tcp' }
        - { rule: 'allow', port: '443', proto: 'tcp' }

    - name: Enable UFW
      ufw:
        state: enabled

    - name: Configure fail2ban
      template:
        src: jail.local.j2
        dest: /etc/fail2ban/jail.local
        backup: yes
      notify: restart fail2ban

    - name: Configure unattended upgrades
      dpkg_reconfigure:
        name: unattended-upgrades

    - name: Set timezone
      timezone:
        name: UTC

    - name: Configure SSH
      lineinfile:
        path: /etc/ssh/sshd_config
        regexp: "{{ item.regexp }}"
        line: "{{ item.line }}"
      loop:
        - { regexp: '^#?PermitRootLogin', line: 'PermitRootLogin no' }
        - { regexp: '^#?PasswordAuthentication', line: 'PasswordAuthentication no' }
        - { regexp: '^#?PubkeyAuthentication', line: 'PubkeyAuthentication yes' }
      notify: restart ssh

    - name: Configure log rotation
      template:
        src: logrotate.conf.j2
        dest: /etc/logrotate.d/custom

    - name: Setup cron jobs
      cron:
        name: "{{ item.name }}"
        minute: "{{ item.minute }}"
        hour: "{{ item.hour }}"
        job: "{{ item.job }}"
      loop:
        - { name: 'backup', minute: '0', hour: '2', job: '/usr/local/bin/backup.sh' }
        - { name: 'update-db', minute: '0', hour: '*/6', job: 'updatedb' }

    - name: Ensure services are running
      systemd:
        name: "{{ item }}"
        state: started
        enabled: yes
      loop:
        - ssh
        - ufw
        - fail2ban
        - prometheus-node-exporter

  handlers:
    - name: restart ssh
      systemd:
        name: ssh
        state: restarted

    - name: restart fail2ban
      systemd:
        name: fail2ban
        state: restarted
```

### Cloud-init Configuration

```yaml
#cloud-config
# cloud-init.yml - Cloud instance initialization

hostname: web-server-01
fqdn: web-server-01.example.com
manage_etc_hosts: true

users:
  - name: admin
    groups: sudo, adm
    shell: /bin/bash
    sudo: ALL=(ALL) NOPASSWD:ALL
    ssh_authorized_keys:
      - ssh-rsa AAAAB3NzaC1yc2E... admin@example.com

packages:
  - nginx
  - mysql-client
  - python3-pip
  - git
  - vim
  - htop
  - ufw
  - fail2ban

write_files:
  - path: /etc/sysctl.d/99-custom.conf
    content: |
      net.ipv4.tcp_syncookies = 1
      net.ipv4.ip_forward = 0
      vm.swappiness = 10

  - path: /etc/nginx/sites-available/default
    content: |
      server {
          listen 80 default_server;
          listen [::]:80 default_server;
          root /var/www/html;
          index index.html index.htm index.nginx-debian.html;
          server_name _;
          location / {
              try_files $uri $uri/ =404;
          }
      }

  - path: /usr/local/bin/setup.sh
    permissions: '0755'
    content: |
      #!/bin/bash
      ufw --force enable
      ufw default deny incoming
      ufw default allow outgoing
      ufw allow 22/tcp
      ufw allow 80/tcp
      ufw allow 443/tcp
      systemctl restart ufw

runcmd:
  - systemctl restart nginx
  - /usr/local/bin/setup.sh
  - apt-get update
  - apt-get upgrade -y
  - reboot

final_message: "The system is ready after $UPTIME seconds"
```

### Backup Script Template

```bash
#!/bin/bash
# backup.sh - Comprehensive backup script

# Configuration
BACKUP_DIR="/backup"
BACKUP_DATE=$(date +%Y%m%d_%H%M%S)
BACKUP_NAME="backup_${BACKUP_DATE}"
RETENTION_DAYS=30
LOG_FILE="/var/log/backup.log"
EMAIL="admin@example.com"

# Directories to backup
BACKUP_SOURCES=(
    "/etc"
    "/var/www"
    "/home"
    "/opt"
)

# MySQL backup settings
MYSQL_USER="backup"
MYSQL_PASS="backup_password"
MYSQL_HOST="localhost"

# PostgreSQL backup settings
PG_USER="postgres"

# Functions
log_message() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

send_notification() {
    local subject="$1"
    local message="$2"
    echo "$message" | mail -s "$subject" "$EMAIL"
}

check_space() {
    local required_space=$1
    local available_space=$(df "$BACKUP_DIR" | awk 'NR==2 {print $4}')

    if [ "$available_space" -lt "$required_space" ]; then
        log_message "ERROR: Insufficient space in $BACKUP_DIR"
        send_notification "Backup Failed" "Insufficient disk space for backup"
        exit 1
    fi
}

backup_files() {
    log_message "Starting file backup..."

    for source in "${BACKUP_SOURCES[@]}"; do
        if [ -d "$source" ]; then
            log_message "Backing up $source..."
            tar -czf "${BACKUP_DIR}/${BACKUP_NAME}_$(basename $source).tar.gz" \
                --exclude='*.log' \
                --exclude='*.tmp' \
                --exclude='cache/*' \
                "$source" 2>/dev/null

            if [ $? -eq 0 ]; then
                log_message "Successfully backed up $source"
            else
                log_message "WARNING: Error backing up $source"
            fi
        fi
    done
}

backup_mysql() {
    log_message "Starting MySQL backup..."

    # Get all databases
    databases=$(mysql -u"$MYSQL_USER" -p"$MYSQL_PASS" -h"$MYSQL_HOST" \
                -e "SHOW DATABASES;" | grep -v Database | grep -v mysql \
                | grep -v information_schema | grep -v performance_schema)

    for db in $databases; do
        log_message "Backing up database: $db"
        mysqldump -u"$MYSQL_USER" -p"$MYSQL_PASS" -h"$MYSQL_HOST" \
                  --single-transaction --routines --triggers \
                  "$db" | gzip > "${BACKUP_DIR}/${BACKUP_NAME}_mysql_${db}.sql.gz"

        if [ $? -eq 0 ]; then
            log_message "Successfully backed up database: $db"
        else
            log_message "ERROR: Failed to backup database: $db"
        fi
    done
}

backup_postgresql() {
    log_message "Starting PostgreSQL backup..."

    # Get all databases
    databases=$(su - postgres -c "psql -l -t" | cut -d'|' -f1 | sed -e 's/^[[:space:]]*//' -e '/^$/d' | grep -v template)

    for db in $databases; do
        log_message "Backing up PostgreSQL database: $db"
        su - postgres -c "pg_dump -Fc $db" > "${BACKUP_DIR}/${BACKUP_NAME}_postgres_${db}.dump"

        if [ $? -eq 0 ]; then
            log_message "Successfully backed up PostgreSQL database: $db"
        else
            log_message "ERROR: Failed to backup PostgreSQL database: $db"
        fi
    done
}

cleanup_old_backups() {
    log_message "Cleaning up old backups..."
    find "$BACKUP_DIR" -name "backup_*" -mtime +$RETENTION_DAYS -delete
    log_message "Cleanup completed"
}

verify_backup() {
    log_message "Verifying backup integrity..."

    for file in "${BACKUP_DIR}/${BACKUP_NAME}"*; do
        if [ -f "$file" ]; then
            case "$file" in
                *.tar.gz)
                    tar -tzf "$file" > /dev/null 2>&1
                    ;;
                *.sql.gz)
                    gunzip -t "$file" > /dev/null 2>&1
                    ;;
                *.dump)
                    # PostgreSQL dump verification
                    pg_restore -l "$file" > /dev/null 2>&1
                    ;;
            esac

            if [ $? -eq 0 ]; then
                log_message "Verified: $(basename $file)"
            else
                log_message "ERROR: Verification failed for $(basename $file)"
                VERIFICATION_FAILED=1
            fi
        fi
    done
}

sync_to_remote() {
    local remote_host="backup.example.com"
    local remote_path="/remote/backup/"

    log_message "Syncing backup to remote server..."
    rsync -avz "${BACKUP_DIR}/${BACKUP_NAME}"* "${remote_host}:${remote_path}"

    if [ $? -eq 0 ]; then
        log_message "Successfully synced to remote server"
    else
        log_message "ERROR: Failed to sync to remote server"
    fi
}

# Main execution
main() {
    log_message "=== Backup started ==="

    # Check available space (require at least 10GB)
    check_space 10485760

    # Create backup directory if it doesn't exist
    mkdir -p "$BACKUP_DIR"

    # Perform backups
    backup_files
    backup_mysql
    backup_postgresql

    # Verify backups
    verify_backup

    # Sync to remote if configured
    sync_to_remote

    # Cleanup old backups
    cleanup_old_backups

    # Send notification
    if [ -z "$VERIFICATION_FAILED" ]; then
        log_message "=== Backup completed successfully ==="
        send_notification "Backup Successful" "Backup completed at $(date)"
    else
        log_message "=== Backup completed with errors ==="
        send_notification "Backup Completed with Errors" "Check log file: $LOG_FILE"
    fi
}

# Run main function
main
```

---

This comprehensive configuration template appendix provides ready-to-use configurations for various system components, services, security tools, and automation scripts that can be customized for specific deployment needs.