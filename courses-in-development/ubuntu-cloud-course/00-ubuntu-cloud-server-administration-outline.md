# Ubuntu Server Administration (Single VM) - Course Outline
## From Zero to Production-Ready Linux Administrator

---

## Part 1: Getting Started with Ubuntu VMs

### Chapter 1: Understanding Virtual Machine Environments
- Virtual machines vs physical servers
- Ephemeral vs persistent storage concepts
- Cloud-init and automated provisioning
- SSH key-based authentication
- VM lifecycle management

### Chapter 2: Initial Server Setup
- First login and orientation
- Creating administrative users
- Configuring sudo access
- SSH hardening and key management
- Setting hostname and timezone
- Basic firewall setup with UFW
- Essential security updates

### Chapter 3: Command Line Mastery
- Navigating the filesystem
- Essential commands and utilities
- Text editors (nano, vim)
- File permissions and ownership
- Process management basics
- Using tmux/screen for persistence
- Command history and aliases

---

## Part 2: Core System Administration

### Chapter 4: User and Group Management
- Creating and managing users
- Group administration
- Password policies
- User resource limits
- Login restrictions
- Home directory management
- User environment configuration

### Chapter 5: File System Permissions
- Unix permission model deep dive
- Special permissions (SUID, SGID, sticky)
- Access Control Lists (ACLs)
- Default permissions with umask
- File attributes
- Auditing file access

### Chapter 6: System Services with Systemd
- Understanding systemd architecture
- Managing services
- Creating custom services
- Systemd timers
- Boot targets and runlevels
- Journald logging
- Service dependencies

---

## Part 3: Storage and Filesystems

### Chapter 7: Storage Management
- Understanding block storage
- Disk partitioning
- Filesystem types and creation
- Mounting and automounting
- Logical Volume Manager (LVM)
- Extending filesystems
- Storage performance tuning

### Chapter 8: File Management and Backups
- Backup strategies (local and remote)
- Using rsync effectively
- LVM snapshot management
- Compression and archiving
- Incremental backups
- Backup automation
- Recovery procedures

---

## Part 4: Networking and Security

### Chapter 9: Network Configuration
- Network interfaces in VMs
- Netplan configuration
- DNS client configuration
- Static vs DHCP
- Network troubleshooting
- Port management
- Local network performance

### Chapter 10: Security Hardening
- Security assessment
- Firewall configuration with UFW/iptables
- Fail2ban setup
- AppArmor configuration
- System auditing with auditd
- File integrity monitoring
- Security updates automation

### Chapter 11: SSL/TLS and Certificates
- Understanding certificates
- Self-signed certificates
- Let's Encrypt for single servers
- Certificate management
- SSL/TLS configuration
- Certificate renewal automation
- Troubleshooting SSL issues

---

## Part 5: Package and Software Management

### Chapter 12: APT Package Management
- Repository management
- Package installation and removal
- Dependency resolution
- Package pinning
- Automatic updates
- Building from source
- Snap packages

### Chapter 13: Software Configuration
- Application installation basics
- Environment variables
- Configuration file management
- Local version control for configs
- Application secrets management
- Service configuration

---

## Part 6: Automation and Scripting

### Chapter 14: Task Automation
- Cron job management
- Systemd timers
- Shell scripting essentials
- Error handling in scripts
- Log rotation with logrotate
- Automated maintenance tasks
- Local monitoring scripts

### Chapter 15: Advanced Scripting
- Bash scripting best practices
- Functions and script libraries
- Cloud-init scripting
- Configuration file templates
- Automated system reports
- Change tracking scripts

---

## Part 7: Monitoring and Performance

### Chapter 16: System Monitoring
- Resource monitoring (CPU, RAM, Disk, Network)
- Process monitoring with top/htop
- Log analysis with journalctl
- Performance baselines
- Local alerting scripts
- System metrics collection
- Custom monitoring scripts

### Chapter 17: Performance Optimization
- Kernel parameters tuning
- Memory management
- I/O optimization
- Network tuning
- Service performance
- Troubleshooting performance issues
- Single-server capacity planning

---

## Part 8: Web and Database Servers

### Chapter 18: Web Server Administration
- Nginx installation and configuration
- Apache as alternative
- Virtual hosts configuration
- Local reverse proxy (to local services)
- Static site hosting
- Web server security
- Performance optimization

### Chapter 19: Database Server Management
- MySQL/MariaDB setup
- PostgreSQL basics
- Database security
- Database backup and recovery
- Performance tuning
- Database monitoring
- Maintenance tasks

---

## Part 9: Application Hosting

### Chapter 20: Running Applications
- Python/Node.js/PHP applications
- Application deployment strategies
- Process management with systemd
- Application logging
- Resource isolation
- Application monitoring
- Troubleshooting applications

### Chapter 21: Local Development Environment
- Setting up development tools
- Version control with Git
- Database development instances
- Testing environments
- Port forwarding for development
- Development vs production configs

---

## Part 10: Troubleshooting and Recovery

### Chapter 22: Troubleshooting Methodology
- Systematic troubleshooting approach
- Common issues and solutions
- Log analysis techniques
- Network debugging
- Performance troubleshooting
- Application debugging
- Getting help effectively

### Chapter 23: System Recovery
- Boot issues resolution
- Filesystem recovery
- Service recovery
- Data recovery techniques
- Root password recovery
- Emergency maintenance mode
- Post-incident analysis

---

## Part 11: Production Operations

### Chapter 24: Backup and Maintenance
- Comprehensive backup strategies
- Testing backup restoration
- System maintenance tasks
- Documentation requirements
- Update and patch management
- Monitoring setup
- Incident response procedures

### Chapter 25: Production Best Practices
- Documentation standards
- Change management process
- Security best practices
- Performance monitoring
- Backup verification
- Maintenance windows
- System hardening checklist

---

## Appendices

### Appendix A: Command Reference
- Essential command cheatsheet
- Useful one-liners
- Troubleshooting commands
- Performance analysis tools

### Appendix B: Configuration Templates
- Service configurations
- Security configurations
- Monitoring setups
- Backup scripts

### Appendix C: Script Library
- System administration scripts
- Monitoring scripts
- Backup and recovery scripts
- Automation examples

### Appendix D: Troubleshooting Guides
- Network issues flowchart
- Boot problems guide
- Service failure diagnosis
- Performance issues checklist

### Appendix E: Resources
- Ubuntu documentation
- Community resources
- Learning paths
- Recommended tools