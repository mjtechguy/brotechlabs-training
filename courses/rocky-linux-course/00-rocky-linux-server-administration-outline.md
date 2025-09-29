# Rocky Linux Server Administration (Single VM) - Course Outline
## From Zero to Production-Ready Enterprise Linux Administrator
### Enterprise Linux Training - 100% RHEL Compatible, 100% Free

---

## Part 1: Getting Started with Rocky Linux

### Chapter 1: Understanding Rocky Linux and Enterprise Environments
- Rocky Linux and the Enterprise ecosystem (100% compatible with RHEL, AlmaLinux, Oracle Linux)
- Virtual machines vs physical servers
- Repository management (no subscriptions needed!)
- Cloud-init and automated provisioning
- SSH key-based authentication
- VM lifecycle management in enterprise environments

### Chapter 2: Initial Server Setup
- First login (no registration required!)
- Creating administrative users
- Configuring sudo access with wheel group
- SSH configuration and key management
- Setting hostname with hostnamectl
- Time synchronization with chrony
- Basic firewall setup with firewalld
- SELinux introduction and basic configuration

### Chapter 3: Command Line Mastery
- Navigating the filesystem
- Essential Rocky/Enterprise Linux commands and utilities
- Text editors (nano, vim, vi)
- File permissions and ownership
- Process management with systemctl
- Using tmux/screen for persistence
- Command history and shell configuration
- Rocky Linux tools and utilities

---

## Part 2: Core System Administration

### Chapter 4: User and Group Management
- Creating and managing users with useradd
- Group administration
- Password policies with PAM
- User resource limits with ulimit
- Login restrictions and access control
- Home directory management
- User environment and shell configuration
- Identity management basics

### Chapter 5: SELinux and Permissions
- SELinux concepts and architecture
- SELinux contexts and labels
- Managing SELinux policies
- Troubleshooting SELinux issues
- Unix permission model
- Special permissions (SUID, SGID, sticky)
- Access Control Lists (ACLs)
- File attributes and extended attributes

### Chapter 6: System Services with Systemd
- Understanding systemd in Rocky Linux
- Managing services and units
- Creating custom systemd services
- Systemd timers and scheduling
- Boot targets and system initialization
- Journald logging and management
- Service dependencies and ordering
- Systemd resource control (cgroups)

---

## Part 3: Storage and Filesystems

### Chapter 7: Storage Management
- Understanding block storage in Rocky Linux
- Disk partitioning with parted and fdisk
- XFS filesystem (Rocky Linux default)
- ext4 and other filesystems
- Mounting and automounting with systemd
- Logical Volume Manager (LVM)
- Stratis storage management
- VDO (Virtual Data Optimizer) for deduplication

### Chapter 8: File Management and Backups
- Backup strategies for enterprise systems
- Using rsync and tar effectively
- LVM and Stratis snapshots
- Compression and archiving
- Incremental backups with rsnapshot
- Backup automation with systemd timers
- Recovery procedures
- Integration with enterprise backup solutions

---

## Part 4: Networking and Security

### Chapter 9: Network Configuration
- Network interfaces in Rocky Linux
- NetworkManager and nmcli
- Network configuration files
- DNS client configuration
- Static vs DHCP configuration
- Network bonding and teaming
- Network troubleshooting tools
- Performance tuning with tuned

### Chapter 10: Security Hardening
- Rocky Linux security baseline
- Firewalld configuration and zones
- SELinux policy management
- System auditing with auditd
- File integrity monitoring with AIDE
- Security updates with yum/dnf
- SCAP security scanning
- CIS benchmark compliance

### Chapter 11: SSL/TLS and Certificates
- Understanding certificates in enterprise
- Managing certificates with certutil
- Self-signed certificates
- Let's Encrypt on Rocky Linux
- Certificate management with mod_ssl
- SSL/TLS configuration
- Certificate renewal automation
- Troubleshooting SSL issues

---

## Part 5: Package and Software Management

### Chapter 12: YUM/DNF Package Management
- Understanding RPM packages
- YUM/DNF repository management in Rocky Linux
- Package installation and removal
- Dependency resolution
- Repository priorities
- Creating local repositories
- EPEL and additional repositories (no subscription needed!)
- Building RPMs from source
- Rocky Linux repository structure

### Chapter 13: Software Configuration
- Application installation patterns
- Environment variables and profiles
- Configuration file management
- Software Collections (SCL)
- Modularity and Application Streams
- Container tools (Podman basics)
- Service configuration
- Application secrets management

---

## Part 6: Automation and Configuration Management

### Chapter 14: Task Automation
- Cron job management
- Systemd timers and units
- Shell scripting for Rocky Linux
- Error handling and logging
- Log rotation with logrotate
- Automated maintenance tasks
- System monitoring scripts
- anacron for irregular schedules

### Chapter 15: Configuration Management Basics
- Advanced bash scripting for configuration management
- System configuration with native tools
- Using systemd for automation and configuration
- Configuration file templating with sed/awk
- System state management with native tools
- Bash scripting best practices
- Kickstart for system deployment
- Cloud-init on Rocky Linux
- Configuration file templates
- Change tracking and documentation
- Infrastructure as Code concepts with native tools

---

## Part 7: Monitoring and Performance

### Chapter 16: System Monitoring
- Performance Co-Pilot (PCP) basics
- Resource monitoring tools
- Process monitoring with top/htop
- System Activity Reporter (SAR)
- Log analysis with journalctl
- Performance baselines
- Cockpit web console
- Custom monitoring scripts

### Chapter 17: Performance Optimization
- Kernel parameter tuning
- Tuned profiles for optimization
- Memory management and huge pages
- I/O scheduling and optimization
- Network performance tuning
- CPU scheduling and affinity
- Troubleshooting performance issues
- Capacity planning for single servers

---

## Part 8: Web and Database Servers

### Chapter 18: Web Server Administration
- Apache httpd installation and configuration
- Nginx as alternative web server
- Virtual hosts configuration
- mod_ssl for HTTPS
- mod_proxy for reverse proxy
- SELinux contexts for web content
- Web server security hardening
- Performance optimization

### Chapter 19: Database Server Management
- MariaDB setup (Rocky Linux default)
- PostgreSQL installation and basics
- MySQL alternatives
- Database security with SELinux
- Database backup and recovery
- Performance tuning
- Database monitoring
- Maintenance automation

---

## Part 9: Application Hosting

### Chapter 20: Running Applications
- Python applications with Rocky Linux
- Node.js deployment
- PHP with Software Collections
- Java application hosting
- Process management with systemd
- Application logging and rotation
- Resource control with cgroups
- Application monitoring

### Chapter 21: Development Environment
- Developer tools installation
- Software Collections for developers
- Version control with Git
- Database development instances
- Container development with Podman
- Testing environments
- Development vs production configurations

---

## Part 10: Troubleshooting and Recovery

### Chapter 22: Troubleshooting Methodology
- Rocky Linux troubleshooting approach
- Common issues and solutions
- Log analysis with journalctl and rsyslog
- Network debugging tools
- SELinux troubleshooting
- Performance issue diagnosis
- Application debugging
- Rocky Linux community support resources

### Chapter 23: System Recovery
- Boot issues and GRUB2 recovery
- Filesystem recovery with XFS tools
- Service recovery procedures
- Data recovery techniques
- Root password reset
- Emergency and rescue modes
- System rollback options
- Post-incident analysis

---

## Part 11: Production Operations

### Chapter 24: Backup and Maintenance
- Enterprise backup strategies
- Testing backup restoration
- System maintenance with yum-cron
- Rocky Linux documentation standards
- Update and patch management
- Repository mirroring for offline systems
- Monitoring integration
- Incident response procedures

### Chapter 25: Production Best Practices
- Rocky Linux documentation standards
- Change management process
- Security compliance (PCI, HIPAA)
- Performance monitoring baselines
- Backup verification procedures
- Maintenance windows planning
- System hardening with OpenSCAP
- Enterprise integration patterns (fully RHEL-compatible)

---

## Appendices

### Appendix A: Command Reference
- Rocky Linux essential commands
- SystemD command reference
- SELinux commands
- Firewalld commands
- NetworkManager commands
- DNF/YUM package management commands
- Performance analysis tools

### Appendix B: Configuration Templates
- SELinux policy templates
- Firewalld zone configurations
- SystemD unit files
- Apache/Nginx configurations
- Database configurations
- Backup scripts
- Security configurations

### Appendix C: Script Library
- System administration scripts
- SELinux management scripts
- Monitoring and alerting scripts
- Backup and recovery scripts
- Automation examples
- Performance tuning scripts

### Appendix D: Troubleshooting Guides
- SELinux troubleshooting flowchart
- Network issues diagnosis
- Boot problems guide
- Service failure diagnosis
- Performance bottleneck identification
- Storage issues resolution

### Appendix E: Enterprise Resources
- Rocky Linux documentation
- Rocky Linux community and forums
- Enterprise Linux compatibility guide
- AlmaLinux as alternative
- EPEL repository guide
- Certification paths (RHCSA/RHCE apply to Rocky!)
- Enterprise tools overview
- Migration guides (CentOS/RHEL/Alma to Rocky)