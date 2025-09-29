# Part 5: Package and Software Management

## Chapter 12: YUM/DNF Package Management

### Understanding RPM Packages

#### What Are RPM Packages?

Think of package management in Rocky Linux like a smartphone app store:
- **RPM files** = App installers (contain the program)
- **Repositories** = App stores (collections of packages)
- **DNF/YUM** = App store app (finds and installs packages)
- **Dependencies** = Required apps (other packages needed)
- **Package groups** = App bundles (related packages together)

RPM (Red Hat Package Manager) is the foundation - DNF/YUM makes it user-friendly!

```bash
# Understanding package names:
# httpd-2.4.37-43.module+el8.5.0+714+5ec56ee8.x86_64.rpm
#  ↑      ↑                    ↑                ↑      ↑
# name  version            build info        arch   .rpm

# name = Package name (httpd)
# version = Software version (2.4.37-43)
# module info = Module stream details
# arch = Architecture (x86_64, noarch, i686)
# .rpm = File extension

# See installed packages:
rpm -qa | head -5
# kernel-4.18.0-513.9.1.el8_9.x86_64
# NetworkManager-1.40.16-4.el8_9.x86_64
# bash-4.4.20-4.el8_9.x86_64
# systemd-239-74.el8_9.2.x86_64
# glibc-2.28-225.el8.x86_64

# Count installed packages:
rpm -qa | wc -l
# 423

# Find what package owns a file:
rpm -qf /usr/bin/ls
# coreutils-8.30-15.el8.x86_64

# See what files a package installed:
rpm -ql bash | head -10
# /etc/skel/.bash_logout
# /etc/skel/.bash_profile
# /etc/skel/.bashrc
# /usr/bin/alias
# /usr/bin/bash
# /usr/bin/bashbug
# /usr/bin/bg
# /usr/bin/cd
# /usr/bin/command
# /usr/bin/fc

# Get package information:
rpm -qi bash
# Name        : bash
# Version     : 4.4.20
# Release     : 4.el8_9
# Architecture: x86_64
# Install Date: Mon 10 Dec 2023 08:00:00 AM EST
# Group       : System Environment/Shells
# Size        : 6846345
# License     : GPLv3+
# Signature   : RSA/SHA256, Thu 23 Nov 2023 10:00:00 AM EST, Key ID 15af5dac6d745a60
# Source RPM  : bash-4.4.20-4.el8_9.src.rpm
# Build Date  : Wed 22 Nov 2023 03:00:00 PM EST
# Build Host  : x86-02.bld.rocky.lan
# Packager    : infrastructure@rockylinux.org
# Vendor      : Rocky
# URL         : https://www.gnu.org/software/bash
# Summary     : The GNU Bourne Again shell
# Description :
# The GNU Bourne Again shell (Bash) is a shell or command language
# interpreter that is compatible with the Bourne shell...
```

### DNF - The Modern Package Manager

#### DNF Basics

DNF (Dandified YUM) is the next generation of YUM. Rocky Linux uses DNF but keeps 'yum' as an alias for compatibility!

```bash
# DNF and YUM are the same in Rocky Linux:
which yum
# /usr/bin/yum
ls -la /usr/bin/yum
# lrwxrwxrwx. 1 root root 5 Nov 23 10:00 /usr/bin/yum -> dnf-3

# Both commands work identically:
dnf --version
yum --version
# 4.14.0
#   Installed: dnf-0:4.14.0-5.el8_9.noarch at Thu 23 Nov 2023 10:00:00 AM EST
#   Built    : Rocky Linux Build System

# Basic DNF operations:

# Search for packages:
dnf search nginx
# ================================ Name Exactly Matched: nginx ================================
# nginx.x86_64 : A high performance web server and reverse proxy server
# =============================== Name & Summary Matched: nginx ================================
# nginx-filesystem.noarch : The basic directory layout for the Nginx server
# nginx-mod-http-image-filter.x86_64 : Nginx HTTP image filter module
# nginx-mod-http-perl.x86_64 : Nginx HTTP perl module
# nginx-mod-http-xslt-filter.x86_64 : Nginx XSLT module
# nginx-mod-mail.x86_64 : Nginx mail modules
# nginx-mod-stream.x86_64 : Nginx stream modules

# Get package info before installing:
dnf info nginx
# Available Packages
# Name         : nginx
# Epoch        : 1
# Version      : 1.20.1
# Release      : 14.el8_9.1
# Architecture : x86_64
# Size         : 587 k
# Source       : nginx-1.20.1-14.el8_9.1.src.rpm
# Repository   : appstream
# Summary      : A high performance web server and reverse proxy server
# URL          : https://nginx.org
# License      : BSD
# Description  : Nginx is a web server and a reverse proxy server for HTTP, SMTP, POP3 and
#              : IMAP protocols, with a strong focus on high concurrency, performance and low
#              : memory usage.

# See what would be installed (dry run):
dnf install --assumeno nginx
# Dependencies resolved.
# ==================================================================================
#  Package                    Architecture  Version              Repository     Size
# ==================================================================================
# Installing:
#  nginx                      x86_64        1:1.20.1-14.el8_9.1  appstream     587 k
# Installing dependencies:
#  nginx-filesystem           noarch        1:1.20.1-14.el8_9.1  appstream      24 k
#  rocky-logos-httpd          noarch        86.3-1.el8           baseos         24 k
#
# Transaction Summary
# ==================================================================================
# Install  3 Packages
#
# Total download size: 634 k
# Installed size: 1.8 M
# Operation aborted.
```

#### Installing and Removing Packages

```bash
# Install a package:
sudo dnf install nginx
# Dependencies resolved.
# ==================================================================================
#  Package                    Architecture  Version              Repository     Size
# ==================================================================================
# Installing:
#  nginx                      x86_64        1:1.20.1-14.el8_9.1  appstream     587 k
# Installing dependencies:
#  nginx-filesystem           noarch        1:1.20.1-14.el8_9.1  appstream      24 k
#
# Transaction Summary
# ==================================================================================
# Install  2 Packages
#
# Total download size: 611 k
# Installed size: 1.7 M
# Is this ok [y/N]: y
#
# Downloading Packages:
# (1/2): nginx-filesystem-1.20.1-14.el8_9.1.noarch.rpm      24 kB/s |  24 kB     00:01
# (2/2): nginx-1.20.1-14.el8_9.1.x86_64.rpm                587 kB/s | 587 kB     00:01
# ----------------------------------------------------------------------------------
# Total                                                     305 kB/s | 611 kB     00:02
#
# Running transaction check
# Transaction check succeeded.
# Running transaction test
# Transaction test succeeded.
# Running transaction
#   Preparing        :                                                           1/1
#   Installing       : nginx-filesystem-1:1.20.1-14.el8_9.1.noarch              1/2
#   Installing       : nginx-1:1.20.1-14.el8_9.1.x86_64                         2/2
#   Running scriptlet: nginx-1:1.20.1-14.el8_9.1.x86_64                         2/2
#   Verifying        : nginx-1:1.20.1-14.el8_9.1.x86_64                         1/2
#   Verifying        : nginx-filesystem-1:1.20.1-14.el8_9.1.noarch              2/2
#
# Installed:
#   nginx-1:1.20.1-14.el8_9.1.x86_64    nginx-filesystem-1:1.20.1-14.el8_9.1.noarch
#
# Complete!

# Install without prompting:
sudo dnf install -y htop

# Install multiple packages:
sudo dnf install -y vim-enhanced git curl wget

# Install from RPM file:
sudo dnf install ./local-package.rpm

# Install from URL:
sudo dnf install https://example.com/package.rpm

# Remove a package:
sudo dnf remove nginx
# This removes nginx and dependencies ONLY used by nginx

# Remove package and all its dependencies (careful!):
sudo dnf autoremove nginx

# Just remove unneeded dependencies:
sudo dnf autoremove
```

#### Updating Packages

```bash
# Check for updates:
dnf check-update
# kernel.x86_64                    4.18.0-513.11.1.el8_9         baseos
# kernel-headers.x86_64            4.18.0-513.11.1.el8_9         baseos
# systemd.x86_64                   239-74.el8_9.3                baseos
# ...

# Update specific package:
sudo dnf update kernel

# Update everything:
sudo dnf update
# or
sudo dnf upgrade  # Same thing

# Update but exclude certain packages:
sudo dnf update --exclude=kernel*

# Downgrade a package:
sudo dnf downgrade firefox

# See update history:
dnf history
# ID     | Command line              | Date and time    | Action(s)      | Altered
# -------------------------------------------------------------------------------
#     20 | install nginx             | 2023-12-12 10:00 | Install        |    2
#     19 | update                    | 2023-12-11 15:00 | Update         |   10
#     18 | install htop              | 2023-12-11 14:00 | Install        |    1

# See details of a transaction:
dnf history info 20

# Undo a transaction:
sudo dnf history undo 20  # Removes nginx

# Redo a transaction:
sudo dnf history redo 20  # Installs nginx again
```

### Repository Management in Rocky Linux

#### Understanding Repositories

```bash
# Rocky Linux repositories are FREE! No subscriptions needed!
# This is a major advantage over RHEL

# List enabled repositories:
dnf repolist
# repo id                          repo name
# appstream                        Rocky Linux 8 - AppStream
# baseos                           Rocky Linux 8 - BaseOS
# extras                           Rocky Linux 8 - Extras

# List all repositories (including disabled):
dnf repolist all
# repo id                          repo name                            status
# appstream                        Rocky Linux 8 - AppStream            enabled
# appstream-debug                  Rocky Linux 8 - AppStream Debug      disabled
# appstream-source                 Rocky Linux 8 - AppStream Source     disabled
# baseos                           Rocky Linux 8 - BaseOS               enabled
# baseos-debug                     Rocky Linux 8 - BaseOS Debug         disabled
# baseos-source                    Rocky Linux 8 - BaseOS Source        disabled
# devel                            Rocky Linux 8 - Devel                disabled
# extras                           Rocky Linux 8 - Extras               enabled
# ha                               Rocky Linux 8 - High Availability   disabled
# plus                             Rocky Linux 8 - Plus                 disabled
# powertools                       Rocky Linux 8 - PowerTools           disabled
# resilient-storage                Rocky Linux 8 - Resilient Storage    disabled
# rt                               Rocky Linux 8 - Realtime             disabled

# See repository details:
dnf repoinfo baseos
# Repo-id            : baseos
# Repo-name          : Rocky Linux 8 - BaseOS
# Repo-status        : enabled
# Repo-revision      : 8.9
# Repo-updated       : Mon 11 Dec 2023 10:00:00 AM EST
# Repo-pkgs          : 1,707
# Repo-available-pkgs: 1,707
# Repo-size          : 1.2 G
# Repo-baseurl       : https://download.rockylinux.org/pub/rocky/8/BaseOS/x86_64/os/
# Repo-expire        : 172,800 second(s) (last: Mon 11 Dec 2023 08:00:00 AM EST)
# Repo-filename      : /etc/yum.repos.d/rocky.repo

# Repository configuration files:
ls -la /etc/yum.repos.d/
# -rw-r--r--. 1 root root  713 Nov 23 10:00 rocky-addons.repo
# -rw-r--r--. 1 root root 1161 Nov 23 10:00 rocky-devel.repo
# -rw-r--r--. 1 root root 2335 Nov 23 10:00 rocky-extras.repo
# -rw-r--r--. 1 root root 3825 Nov 23 10:00 rocky.repo

# View repository configuration:
cat /etc/yum.repos.d/rocky.repo
# [baseos]
# name=Rocky Linux $releasever - BaseOS
# mirrorlist=https://mirrors.rockylinux.org/mirrorlist?arch=$basearch&repo=BaseOS-$releasever
# #baseurl=http://dl.rockylinux.org/$contentdir/$releasever/BaseOS/$basearch/os/
# gpgcheck=1
# enabled=1
# countme=1
# gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-rockyofficial
```

#### Managing Repositories

```bash
# Enable a repository:
sudo dnf config-manager --enable powertools
# or
sudo dnf config-manager --set-enabled powertools

# Disable a repository:
sudo dnf config-manager --disable powertools
# or
sudo dnf config-manager --set-disabled powertools

# Add a new repository:
sudo dnf config-manager --add-repo https://example.com/repo.repo

# Or create manually:
sudo nano /etc/yum.repos.d/custom.repo
# [custom]
# name=Custom Repository
# baseurl=https://example.com/repo/el8/$basearch/
# enabled=1
# gpgcheck=1
# gpgkey=https://example.com/repo/RPM-GPG-KEY

# Clean repository cache:
sudo dnf clean all
# 42 files removed

# Make cache:
sudo dnf makecache
# Rocky Linux 8 - BaseOS                           3.5 kB/s | 4.0 kB     00:01
# Rocky Linux 8 - AppStream                        4.2 kB/s | 4.5 kB     00:01
# Rocky Linux 8 - Extras                           2.1 kB/s | 3.5 kB     00:01
# Metadata cache created.

# Install from specific repository:
sudo dnf --enablerepo=powertools install package-name
# or
sudo dnf --disablerepo="*" --enablerepo="baseos" install package-name
```

### EPEL - Extra Packages for Enterprise Linux

#### Setting Up EPEL

```bash
# EPEL adds thousands of additional packages to Rocky Linux!
# It's community-maintained and free

# Install EPEL:
sudo dnf install -y epel-release

# What happened?
ls -la /etc/yum.repos.d/ | grep epel
# -rw-r--r--. 1 root root 1485 Nov 10 10:00 epel-modular.repo
# -rw-r--r--. 1 root root 1422 Nov 10 10:00 epel-playground.repo
# -rw-r--r--. 1 root root 1314 Nov 10 10:00 epel-testing-modular.repo
# -rw-r--r--. 1 root root 1251 Nov 10 10:00 epel-testing.repo
# -rw-r--r--. 1 root root 1172 Nov 10 10:00 epel.repo

# See new available packages:
dnf repolist
# repo id                 repo name
# appstream               Rocky Linux 8 - AppStream
# baseos                  Rocky Linux 8 - BaseOS
# epel                    Extra Packages for Enterprise Linux 8 - x86_64
# epel-modular           Extra Packages for Enterprise Linux Modular 8 - x86_64
# extras                  Rocky Linux 8 - Extras

# Search EPEL packages:
dnf --disablerepo="*" --enablerepo="epel" list available | head -20

# Popular EPEL packages:
sudo dnf install -y \
  htop \           # Better than top
  ncdu \           # NCurses disk usage
  tmux \           # Terminal multiplexer
  fish \           # Friendly shell
  neofetch \       # System info
  fail2ban \       # Ban IPs with failed logins
  certbot \        # Let's Encrypt client
  rclone           # Cloud storage sync
```

### Package Groups

#### Working with Package Groups

```bash
# Package groups install related packages together

# List available groups:
dnf grouplist
# Available Environment Groups:
#    Server
#    Server with GUI
#    Minimal Install
#    Workstation
#    Custom Operating System
#    Virtualization Host
# Available Groups:
#    Container Management
#    .NET Core Development
#    RPM Development Tools
#    Development Tools
#    Graphical Administration Tools
#    Headless Management
#    Legacy UNIX Compatibility
#    Network Servers
#    Scientific Support
#    Security Tools
#    Smart Card Support
#    System Tools

# See what's in a group:
dnf groupinfo "Development Tools"
# Group: Development Tools
# Description: A basic development environment.
# Mandatory Packages:
#    autoconf
#    automake
#    binutils
#    gcc
#    gcc-c++
#    gdb
#    glibc-devel
#    libtool
#    make
#    pkgconf
#    pkgconf-m4
#    pkgconf-pkg-config
#    redhat-rpm-config
# Optional Packages:
#    asciidoc
#    byacc
#    ctags
#    diffstat
#    git
#    intltool
#    jna
#    ltrace
#    patchutils
#    perl-Fedora-VSP
#    perl-generators
#    pesign
#    source-highlight
#    systemtap
#    valgrind

# Install a group:
sudo dnf groupinstall "Development Tools"
# or
sudo dnf group install "Development Tools"

# Remove a group:
sudo dnf groupremove "Development Tools"

# Update a group:
sudo dnf groupupdate "Development Tools"

# Install environment group (larger collection):
sudo dnf groupinstall "Server with GUI"

# Mark group as installed (without installing):
sudo dnf group mark install "Development Tools"
```

### Building RPMs from Source

#### Creating Your Own RPMs

```bash
# Sometimes you need to build your own RPMs

# Install build tools:
sudo dnf groupinstall "Development Tools"
sudo dnf install -y rpm-build rpmdevtools

# Set up build environment:
rpmdev-setuptree
# This creates:
tree ~/rpmbuild/
# /home/user/rpmbuild/
# ├── BUILD      <- Where software is built
# ├── RPMS       <- Built RPMs go here
# ├── SOURCES    <- Source tarballs
# ├── SPECS      <- RPM spec files
# └── SRPMS      <- Source RPMs

# Example: Build a simple "hello world" RPM

# Step 1: Create the program
mkdir ~/hello-1.0
cd ~/hello-1.0

cat > hello.sh << 'EOF'
#!/bin/bash
echo "Hello from Rocky Linux!"
EOF

chmod +x hello.sh

# Step 2: Create tarball
cd ~
tar czf rpmbuild/SOURCES/hello-1.0.tar.gz hello-1.0/

# Step 3: Create spec file
cat > ~/rpmbuild/SPECS/hello.spec << 'EOF'
Name:           hello
Version:        1.0
Release:        1%{?dist}
Summary:        A simple hello world script

License:        GPL
URL:            http://example.com
Source0:        %{name}-%{version}.tar.gz

BuildArch:      noarch

%description
A simple hello world script for Rocky Linux

%prep
%setup -q

%install
rm -rf $RPM_BUILD_ROOT
mkdir -p $RPM_BUILD_ROOT/usr/local/bin
install -m 755 hello.sh $RPM_BUILD_ROOT/usr/local/bin/

%files
/usr/local/bin/hello.sh

%changelog
* Mon Dec 11 2023 Your Name <you@example.com> - 1.0-1
- Initial build
EOF

# Step 4: Build the RPM
cd ~/rpmbuild
rpmbuild -ba SPECS/hello.spec
# Executing(%prep): /bin/sh -e /var/tmp/rpm-tmp.xxxxx
# + cd /home/user/rpmbuild/BUILD
# + cd hello-1.0
# ...
# Wrote: /home/user/rpmbuild/SRPMS/hello-1.0-1.el8.src.rpm
# Wrote: /home/user/rpmbuild/RPMS/noarch/hello-1.0-1.el8.noarch.rpm

# Step 5: Install your RPM
sudo dnf install ~/rpmbuild/RPMS/noarch/hello-1.0-1.el8.noarch.rpm

# Test it:
/usr/local/bin/hello.sh
# Hello from Rocky Linux!

# Build from source RPM:
rpmbuild --rebuild package.src.rpm
```

---

## Chapter 13: Software Configuration

### Application Installation Patterns

#### Understanding Software Installation Methods

```bash
# Rocky Linux offers multiple ways to install software:

# 1. RPM PACKAGES (Traditional)
# - Pre-compiled binaries
# - Managed by DNF/YUM
# - Automatic dependency resolution
sudo dnf install postgresql

# 2. SOFTWARE COLLECTIONS (Multiple versions)
# - Install multiple versions side-by-side
# - Don't interfere with system packages
sudo dnf install gcc-toolset-11

# 3. MODULARITY/APP STREAMS (Version selection)
# - Choose software versions
# - Switch between streams
dnf module list nodejs
sudo dnf module enable nodejs:18

# 4. CONTAINERS (Isolated environments)
# - Podman/Docker containers
# - Complete isolation
podman run -d nginx

# 5. FROM SOURCE (Maximum control)
# - Compile yourself
# - Latest versions
./configure && make && sudo make install

# 6. SNAP/FLATPAK (Universal packages)
# - Distribution-independent
# - Sandboxed applications
sudo dnf install snapd
sudo snap install code --classic
```

### Environment Variables and Profiles

#### System-Wide and User Configuration

```bash
# Understanding the login process and environment setup:

# System-wide configurations (all users):
ls -la /etc/profile.d/
# colorls.sh    <- Adds color to ls
# lang.sh       <- Sets language
# less.sh       <- Less pager settings
# vim.sh        <- Vim defaults
# custom.sh     <- Your custom settings

# Login shell process:
# 1. /etc/profile runs first
# 2. /etc/profile.d/*.sh scripts run
# 3. ~/.bash_profile runs
# 4. ~/.bashrc runs
# 5. /etc/bashrc runs

# Check current environment:
env | sort | head -10
# HOME=/home/john
# HOSTNAME=rocky-server
# LANG=en_US.UTF-8
# LOGNAME=john
# PATH=/usr/local/bin:/usr/bin:/bin
# PWD=/home/john
# SHELL=/bin/bash
# TERM=xterm-256color
# USER=john

# Set environment variable (current session):
export MYAPP_HOME=/opt/myapp
export PATH=$PATH:$MYAPP_HOME/bin

# Make it permanent for your user:
echo 'export MYAPP_HOME=/opt/myapp' >> ~/.bashrc
echo 'export PATH=$PATH:$MYAPP_HOME/bin' >> ~/.bashrc

# Make it permanent for all users:
sudo nano /etc/profile.d/myapp.sh
#!/bin/bash
export MYAPP_HOME=/opt/myapp
export PATH=$PATH:$MYAPP_HOME/bin

sudo chmod +x /etc/profile.d/myapp.sh

# Application-specific environment files:
cat /etc/sysconfig/httpd
# Configuration file for httpd service
# OPTIONS=
# LANG=C

# System-wide defaults:
cat /etc/environment
# System-wide environment variables
# PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
```

#### Managing Application Configuration

```bash
# Configuration file locations:

# 1. System services: /etc/
ls -la /etc/ | grep ".conf"
# -rw-r--r--.  1 root root     1634 Nov 23 10:00 nsswitch.conf
# -rw-r--r--.  1 root root     7265 Nov 23 10:00 man_db.conf
# -rw-------.  1 root root      541 Nov 23 10:00 anacrontab

# 2. User configs: ~/. (hidden files)
ls -la ~/ | grep "^\."
# .bash_history
# .bash_logout
# .bash_profile
# .bashrc
# .config/      <- Modern config directory
# .local/       <- User-specific data

# 3. Application configs: /etc/appname/
ls -la /etc/nginx/
# nginx.conf
# conf.d/
# default.d/
# mime.types

# Best practices for config management:

# Keep original config:
sudo cp /etc/httpd/conf/httpd.conf /etc/httpd/conf/httpd.conf.orig

# Use version control for configs:
cd /etc/nginx
sudo git init
sudo git add .
sudo git commit -m "Initial nginx config"

# Template configuration:
# Create template
sudo cp /etc/myapp/config.conf /etc/myapp/config.conf.template

# Deploy from template:
sudo cp /etc/myapp/config.conf.template /etc/myapp/config.conf
sudo sed -i 's/{{HOSTNAME}}/server1.example.com/g' /etc/myapp/config.conf
sudo sed -i 's/{{PORT}}/8080/g' /etc/myapp/config.conf
```

### Software Collections (SCL)

#### Installing and Using Software Collections

```bash
# Software Collections let you install multiple versions of languages/tools

# Install SCL repository:
sudo dnf install -y scl-utils

# For additional SCLs:
sudo dnf install -y \
  https://www.softwarecollections.org/repos/rhscl/rhscl/epel-8-x86_64/noarch/rhscl-rhscl-epel-8-x86_64-1-2.noarch.rpm

# Search for collections:
dnf search rh-python
# rh-python38.x86_64 : Package that installs rh-python38
# rh-python39.x86_64 : Package that installs rh-python39

# Install Python 3.9 collection:
sudo dnf install -y rh-python39

# Enable collection (temporary):
scl enable rh-python39 bash
# This starts a new shell with Python 3.9 active
python --version
# Python 3.9.7
exit  # Leave SCL shell

# Check system Python (unchanged):
python3 --version
# Python 3.6.8

# Enable collection in script:
#!/bin/bash
source /opt/rh/rh-python39/enable
python --version  # Uses Python 3.9

# Make SCL permanent for user:
echo 'source /opt/rh/rh-python39/enable' >> ~/.bashrc

# Install development tools collection:
sudo dnf install -y gcc-toolset-11

# Use newer GCC:
scl enable gcc-toolset-11 bash
gcc --version
# gcc (GCC) 11.2.1 20210728 (Red Hat 11.2.1-1)

# List installed collections:
scl -l
# gcc-toolset-11
# rh-python39
```

### Modularity and Application Streams

#### Working with DNF Modules

```bash
# Modules provide different versions of software
# Application Streams are versions of user-space components

# List all modules:
dnf module list
# Rocky Linux 8 - AppStream
# Name          Stream        Profiles                      Summary
# 389-ds        1.4                                         389 Directory Server
# ant           1.10 [d]      common [d]                   Java build tool
# container-tools rhel8 [d][e] common [d]                  Container tools module
# go-toolset    rhel8 [d]     common [d]                   Go programming language
# httpd         2.4 [d][e]    common [d], devel, minimal  Apache HTTP Server
# idm           DL1           adtrust, client, dns, server The Red Hat Identity Management system
# idm           client [d]    common [d]                   RHEL IdM client
# ...

# [d] = default stream
# [e] = enabled stream

# See available streams for a module:
dnf module list nodejs
# Name      Stream    Profiles                              Summary
# nodejs    10 [d]    common [d], development, minimal, s2i Javascript runtime
# nodejs    12        common [d], development, minimal, s2i Javascript runtime
# nodejs    14        common [d], development, minimal, s2i Javascript runtime
# nodejs    16        common [d], development, minimal, s2i Javascript runtime
# nodejs    18        common [d], development, minimal, s2i Javascript runtime
# nodejs    20        common [d], development, minimal, s2i Javascript runtime

# Enable a module stream:
sudo dnf module enable nodejs:18
# Dependencies resolved.
# ================================================================================
#  Package          Architecture    Version            Repository         Size
# ================================================================================
# Enabling module streams:
#  nodejs                           18
#
# Transaction Summary
# ================================================================================
# Is this ok [y/N]: y

# Install module:
sudo dnf module install nodejs:18
# This installs the nodejs module with stream 18

# Or install specific profile:
sudo dnf module install nodejs:18/development

# Switch streams:
sudo dnf module reset nodejs
sudo dnf module enable nodejs:20
sudo dnf distro-sync

# See enabled modules:
dnf module list --enabled

# Disable module:
sudo dnf module disable nodejs

# Remove module:
sudo dnf module remove nodejs:18
```

### Container Tools (Podman Basics)

#### Introduction to Podman

```bash
# Podman is a daemonless container engine
# Compatible with Docker but doesn't need root!

# Install container tools:
sudo dnf module install container-tools

# Or individual packages:
sudo dnf install -y podman skopeo buildah

# Podman vs Docker:
# - No daemon (each container is a process)
# - Rootless containers (better security)
# - Docker-compatible commands
# - Systemd integration

# Search for images:
podman search nginx
# INDEX       NAME                          DESCRIPTION
# docker.io   docker.io/library/nginx       Official build of Nginx.
# docker.io   docker.io/nginxinc/nginx-unprivileged  Unprivileged NGINX Docker
# quay.io     quay.io/bitnami/nginx         Bitnami nginx Docker Image

# Pull an image:
podman pull docker.io/library/nginx:alpine
# Resolved "nginx" as an alias (/etc/containers/registries.conf.d/000-shortnames.conf)
# Trying to pull docker.io/library/nginx:alpine...
# Getting image source signatures
# Writing manifest to image destination
# Storing signatures
# 8921db27df28...e3b8c6b6e0

# List images:
podman images
# REPOSITORY                TAG         IMAGE ID      CREATED      SIZE
# docker.io/library/nginx   alpine      8921db27df28  2 days ago   42.6 MB

# Run a container:
podman run -d --name mynginx -p 8080:80 nginx:alpine
# 5f4a3b2c8d9e10f123456789abcdef0123456789abcdef0123456789abcd

# List running containers:
podman ps
# CONTAINER ID  IMAGE                          COMMAND               CREATED        STATUS        PORTS                 NAMES
# 5f4a3b2c8d9e  docker.io/library/nginx:alpine  nginx -g daemon o...  5 seconds ago  Up 5 seconds  0.0.0.0:8080->80/tcp  mynginx

# Execute command in container:
podman exec mynginx nginx -v
# nginx version: nginx/1.25.3

# View logs:
podman logs mynginx

# Stop container:
podman stop mynginx

# Remove container:
podman rm mynginx

# Run as systemd service:
podman run -d --name mynginx nginx:alpine
podman generate systemd --new --files --name mynginx
# /home/user/container-mynginx.service

# Install as user service:
mkdir -p ~/.config/systemd/user/
cp container-mynginx.service ~/.config/systemd/user/
systemctl --user daemon-reload
systemctl --user enable --now container-mynginx
```

### Service Configuration Best Practices

#### Application Deployment Patterns

```bash
# 1. SYSTEMD SERVICE PATTERN
# For applications that should always run

# Create application directory:
sudo mkdir -p /opt/myapp
sudo mkdir -p /etc/myapp
sudo mkdir -p /var/log/myapp
sudo mkdir -p /var/lib/myapp

# Create dedicated user:
sudo useradd -r -s /bin/false -d /var/lib/myapp myapp

# Set permissions:
sudo chown -R myapp:myapp /opt/myapp
sudo chown -R myapp:myapp /var/log/myapp
sudo chown -R myapp:myapp /var/lib/myapp

# Create service file:
sudo nano /etc/systemd/system/myapp.service
[Unit]
Description=My Application
After=network.target

[Service]
Type=simple
User=myapp
Group=myapp
WorkingDirectory=/opt/myapp
ExecStart=/opt/myapp/bin/myapp
Restart=on-failure
RestartSec=10

# Logging
StandardOutput=journal
StandardError=journal

# Security
NoNewPrivileges=true
PrivateTmp=true

[Install]
WantedBy=multi-user.target

# 2. ENVIRONMENT CONFIGURATION PATTERN

# Create environment file:
sudo nano /etc/sysconfig/myapp
# Production settings
MYAPP_ENV=production
MYAPP_PORT=8080
MYAPP_DB_HOST=localhost
MYAPP_DB_NAME=myapp_prod
MYAPP_LOG_LEVEL=info

# Reference in service:
[Service]
EnvironmentFile=/etc/sysconfig/myapp

# 3. LOG ROTATION PATTERN

sudo nano /etc/logrotate.d/myapp
/var/log/myapp/*.log {
    daily
    rotate 7
    compress
    delaycompress
    missingok
    notifempty
    create 0640 myapp myapp
    sharedscripts
    postrotate
        systemctl reload myapp >/dev/null 2>&1 || true
    endscript
}

# 4. SECRETS MANAGEMENT PATTERN

# Never put secrets in:
# - Environment variables (visible in ps)
# - Command line arguments (visible in ps)
# - Version control

# Instead use:
# - Dedicated secrets file with restricted permissions
sudo nano /etc/myapp/secrets.conf
sudo chmod 600 /etc/myapp/secrets.conf
sudo chown myapp:myapp /etc/myapp/secrets.conf

# Or use systemd credentials:
sudo systemd-creds encrypt - myapp.password <<< "secret123"
# In service file:
LoadCredentialEncrypted=password:/path/to/encrypted/cred
```

## Practice Exercises

### Exercise 1: Repository Management
1. Set up EPEL repository
2. Create a local repository from mounted ISO
3. Configure repository priorities
4. Mirror a repository for offline use
5. Create custom repository for your packages
6. Set up repository caching proxy

### Exercise 2: Package Building
1. Build a simple "hello world" RPM
2. Create an RPM that installs configuration files
3. Package a Python application as RPM
4. Build from source RPM with modifications
5. Sign your RPM packages
6. Create a package that depends on other packages

### Exercise 3: Software Collections Setup
1. Install multiple Python versions using SCL
2. Set up development environment with gcc-toolset
3. Configure per-user SCL activation
4. Create wrapper scripts for SCL applications
5. Run web app with specific Python version
6. Compare performance between SCL versions

### Exercise 4: Container Deployment
1. Deploy a web application using Podman
2. Create a multi-container application (web + database)
3. Build custom container image
4. Set up container as systemd service
5. Configure container networking
6. Implement container health checks

## Summary

In Part 5, we've mastered package and software management in Rocky Linux:

**Package Management:**
- Understanding RPM packages and their structure
- Using DNF/YUM for package installation and updates
- Managing repositories without subscriptions (Rocky Linux advantage!)
- EPEL repository for additional software
- Building custom RPMs from source

**Software Configuration:**
- Multiple installation methods and patterns
- Environment variables and profiles
- Software Collections for multiple versions
- DNF modules and application streams
- Podman containers as Docker alternative

**Best Practices:**
- Service configuration patterns
- Application deployment strategies
- Secrets management
- Log rotation setup
- Security considerations

These skills enable you to:
- Install and manage any software on Rocky Linux
- Maintain multiple software versions simultaneously
- Build and distribute custom packages
- Deploy containerized applications
- Configure applications professionally

## Additional Resources

- [Rocky Linux Package Management Documentation](https://docs.rockylinux.org/books/admin_guide/07-package-management/)
- [RPM Packaging Guide](https://rpm-packaging-guide.github.io/)
- [EPEL Documentation](https://docs.fedoraproject.org/en-US/epel/)
- [Software Collections Guide](https://www.softwarecollections.org/en/)
- [Podman Documentation](https://podman.io/docs)
- [DNF Documentation](https://dnf.readthedocs.io/)
- [Rocky Linux Repository Structure](https://wiki.rockylinux.org/rocky/repo/)
- [Creating RPM Packages](https://docs.fedoraproject.org/en-US/quick-docs/creating-rpm-packages/)

---

*Continue to Part 6: Automation and Configuration Management*