# Week 2 Summary: Secure Domain-Based Deployment with Docker & Nginx Proxy Manager

## Overview

Week 2 focused on building a production-ready, secure web infrastructure using modern DevOps practices. Students learned to purchase and configure domain names, deploy containerized applications using Docker, implement reverse proxy with Nginx Proxy Manager, and obtain automatic SSL/TLS certificates from Let's Encrypt.

---

## Key Topics Covered

### 1. Domain Names and Registration

**Core Concepts:**
- Domain name anatomy (protocol, subdomain, domain, TLD)
- Domain registrars and pricing considerations
- WHOIS privacy protection
- Domain lifecycle and renewal

**Practical Skills:**
- Choosing appropriate domain names and TLDs
- Understanding domain pricing (initial vs renewal costs)
- Managing domain ownership and privacy

**Key Takeaway:** Domain names provide human-readable addresses for web services and are the foundation of professional web presence.

---

### 2. DNS (Domain Name System) and Cloudflare

**Core Concepts:**
- DNS resolution process (from browser to server)
- DNS record types (A, AAAA, CNAME, MX, TXT, NS)
- TTL (Time To Live) and DNS propagation
- Nameserver delegation

**Practical Skills:**
- Configuring DNS records in Cloudflare
- Changing nameservers from registrar to DNS provider
- Understanding DNS propagation timelines
- Choosing between proxied (orange cloud) and DNS-only (gray cloud)

**Technologies Used:**
- Cloudflare as DNS provider (fast, reliable, free tier)
- DNS record configuration for subdomains

**Key Takeaway:** DNS translates human-readable domain names to IP addresses, and proper DNS configuration is essential for web service accessibility.

---

### 3. Docker and Containerization

**Core Concepts:**
- Containers vs Virtual Machines
- Docker images, containers, volumes, and networks
- Docker Compose for multi-container orchestration
- Container lifecycle management

**Practical Skills:**
- Installing Docker Engine and Docker Compose
- Running containers with `docker run`
- Managing multi-container applications with Docker Compose
- Understanding Docker networking and volume persistence
- Creating custom Docker networks

**Technologies Used:**
- Docker Engine (Community Edition)
- Docker Compose V2
- Docker Hub for container images

**Architecture Implemented:**
- Custom Docker network (nginx-proxy-network) for container communication
- Named volumes for data persistence
- Container restart policies for high availability

**Key Takeaway:** Docker provides lightweight, portable, and consistent application deployment through containerization, solving "works on my machine" problems.

---

### 4. Nginx Proxy Manager (NPM)

**Core Concepts:**
- Reverse proxy architecture and benefits
- SSL/TLS termination
- Domain-based routing
- Web-based proxy management

**Practical Skills:**
- Deploying NPM using Docker Compose
- Creating proxy host configurations
- Managing SSL certificates through web UI
- Configuring access lists and security settings

**Technologies Used:**
- Nginx Proxy Manager container (jc21/nginx-proxy-manager)
- Web-based management interface (port 81)
- HTTP (80), HTTPS (443) traffic handling

**Architecture Implemented:**
```
Internet → NPM (ports 80/443) → Docker Network → Backend Containers
```

**Key Features:**
- Visual interface for Nginx configuration
- Automatic Let's Encrypt integration
- No manual config file editing required
- Support for multiple proxy hosts

**Key Takeaway:** Reverse proxies provide centralized SSL termination, domain-based routing, and security for multiple backend services on a single server.

---

### 5. SSL/TLS and Let's Encrypt

**Core Concepts:**
- HTTP vs HTTPS and encryption importance
- TLS handshake process
- Certificate types (DV, OV, EV)
- ACME protocol for automated certificate management
- Certificate lifecycle and renewal

**Practical Skills:**
- Requesting SSL certificates from Let's Encrypt via NPM
- Understanding certificate validation (HTTP-01 challenge)
- Configuring automatic certificate renewal
- Verifying SSL certificate validity

**Technologies Used:**
- Let's Encrypt (free, automated CA)
- ACME protocol (HTTP-01 challenge)
- NPM for certificate management

**Security Benefits:**
- All traffic encrypted in transit
- Browser trust indicators (padlock icon)
- Protection against man-in-the-middle attacks
- SEO benefits from HTTPS

**Key Takeaway:** Let's Encrypt democratized SSL/TLS by providing free, automated certificates with 90-day validity and auto-renewal, making HTTPS the web standard.

---

### 6. Secure Code-Server Deployment

**Core Concepts:**
- Browser-based IDE (VS Code in browser)
- Security layers for exposed services
- Container networking and isolation
- Password authentication and sudo access

**Practical Skills:**
- Deploying code-server using Docker
- Configuring environment variables (timezone, passwords, domains)
- Setting up persistent volumes for projects and configuration
- Securing code-server behind reverse proxy
- Installing VS Code extensions

**Technologies Used:**
- Code-Server container (codercom/code-server)
- Docker volumes for data persistence
- Internal container networking (no direct internet exposure)

**Security Layers Implemented:**
1. HTTPS encryption (via NPM)
2. Domain-based access (no IP exposure)
3. Reverse proxy protection
4. Password authentication
5. Isolated container environment

**Key Takeaway:** Code-server enables powerful, accessible development environments accessible from any device while maintaining security through multiple protection layers.

---

## Complete Architecture

### System Components

```
┌─────────────────────────────────────────────────────────┐
│                   INTERNET                              │
└────────────────┬────────────────────────────────────────┘
                 │
                 ↓
┌─────────────────────────────────────────────────────────┐
│         NAMECHEAP (Domain Registrar)                    │
│  Domain: mydevlab.com                                   │
│  Nameservers → Cloudflare                               │
└────────────────┬────────────────────────────────────────┘
                 │
                 ↓
┌─────────────────────────────────────────────────────────┐
│            CLOUDFLARE (DNS Provider)                    │
│  A Record: code.mydevlab.com → SERVER_IP               │
│  Fast resolution, DDoS protection                       │
└────────────────┬────────────────────────────────────────┘
                 │
                 ↓
┌─────────────────────────────────────────────────────────┐
│         HETZNER CLOUD SERVER (Ubuntu 22.04)             │
│  Public IP: SERVER_IP                                   │
│  Firewall: Ports 80, 443, 22, 81 open                   │
│                                                         │
│  ┌───────────────────────────────────────────────────┐ │
│  │         DOCKER ENGINE                             │ │
│  │                                                   │ │
│  │  ┌─────────────────────────────────────────────┐ │ │
│  │  │  Nginx Proxy Manager Container            │ │ │
│  │  │  - Ports: 80 (HTTP), 443 (HTTPS)           │ │ │
│  │  │  - Port 81: Admin UI                       │ │ │
│  │  │  - SSL/TLS termination                     │ │ │
│  │  │  - Let's Encrypt certificates              │ │ │
│  │  │  - Proxy routing                           │ │ │
│  │  └────────────┬────────────────────────────────┘ │ │
│  │               │                                   │ │
│  │               │ nginx-proxy-network               │ │
│  │               │ (Internal Docker Network)         │ │
│  │               ↓                                   │ │
│  │  ┌─────────────────────────────────────────────┐ │ │
│  │  │  Code-Server Container                     │ │ │
│  │  │  - Internal Port: 8443                     │ │ │
│  │  │  - VS Code in browser                      │ │ │
│  │  │  - Password protected                      │ │ │
│  │  │  - Volumes: config, projects               │ │ │
│  │  └─────────────────────────────────────────────┘ │ │
│  └───────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────┘
```

### Request Flow

1. **User types:** `https://code.mydevlab.com`
2. **DNS lookup:** Cloudflare resolves to SERVER_IP
3. **Browser connects:** SERVER_IP:443 (HTTPS)
4. **NPM receives request:**
   - Checks domain routing rules
   - Terminates SSL/TLS
   - Decrypts HTTPS traffic
5. **NPM forwards:** HTTP request to code-server:8443 (internal network)
6. **Code-Server processes:**
   - Authenticates user (password)
   - Returns VS Code interface
7. **NPM encrypts:** Response with SSL/TLS
8. **User receives:** Secure, encrypted VS Code in browser

---

## Lab Structure

### Lab 1: Ubuntu Server Preparation
- System updates and security hardening
- UFW firewall configuration
- Time synchronization setup
- Essential tools installation
- Directory structure creation

### Lab 2: Docker Installation
- Docker Engine installation from official repository
- Docker Compose V2 setup
- Docker network creation (nginx-proxy-network)
- Volume creation for services
- Docker configuration and testing

### Lab 3: Nginx Proxy Manager Deployment
- Docker Compose configuration for NPM
- Container deployment and verification
- Admin panel access and first-time setup
- Health check monitoring
- Backup strategy implementation

### Lab 4: Code-Server Deployment
- Docker Compose configuration for code-server
- Environment variable configuration (passwords, timezone, domain)
- Volume setup for projects and config
- Security hardening (removing direct port access)
- Extension installation and customization

### Lab 5: DNS Configuration and SSL Setup
- Cloudflare account setup
- Nameserver delegation from Namecheap
- A record creation for subdomains
- NPM proxy host configuration
- Let's Encrypt SSL certificate request
- HTTPS verification and testing

---

## Technical Skills Acquired

### System Administration
- Linux system updates and package management
- Firewall configuration (UFW)
- User and permission management
- Time synchronization (NTP)
- SSH configuration and security

### Docker & Containerization
- Docker installation and configuration
- Docker Compose orchestration
- Container lifecycle management
- Volume management for data persistence
- Network creation and management
- Container logs and troubleshooting

### Networking & DNS
- DNS record types and configuration
- Nameserver delegation
- DNS propagation understanding
- Subdomain configuration
- DNS troubleshooting tools (dig, nslookup)

### Web Infrastructure
- Reverse proxy concepts and implementation
- SSL/TLS certificate management
- ACME protocol and Let's Encrypt
- HTTP to HTTPS redirects
- Domain-based routing
- Port management

### Security
- HTTPS encryption implementation
- Multi-layer security approach
- Password management best practices
- Certificate validation and renewal
- Firewall rule configuration
- Access control and authentication

---

## Key Achievements

### Production-Ready Infrastructure
✅ Fully functional HTTPS-secured web infrastructure
✅ Automatic SSL certificate renewal
✅ Professional domain setup
✅ Scalable architecture for multiple services
✅ Container-based deployment

### Security Best Practices
✅ HTTPS encryption for all traffic
✅ No direct container exposure to internet
✅ Reverse proxy architecture
✅ Password-protected services
✅ Firewall configuration
✅ Automated certificate management

### Professional Development Environment
✅ VS Code accessible from any device
✅ Persistent project storage
✅ Consistent development environment
✅ Secure remote access
✅ Extension support

---

## Common Challenges and Solutions

### Challenge: DNS Propagation Delays
**Solution:** Wait 15 minutes to 4 hours for global propagation. Use `dig` or `nslookup` to verify. Cloudflare typically propagates in minutes.

### Challenge: Let's Encrypt Certificate Request Failures
**Solution:** Ensure port 80 is open, DNS points to correct IP, and domain is fully propagated before requesting certificates.

### Challenge: 502 Bad Gateway Errors
**Solution:** Verify backend container is running, check Docker network connectivity, ensure correct port configuration in proxy host.

### Challenge: Container Data Loss on Restart
**Solution:** Use Docker volumes for all persistent data. Verify volumes are properly mounted in docker-compose.yml.

### Challenge: Port Conflicts
**Solution:** Check for existing services on ports 80, 443, 81, 8080. Stop conflicting services or change port mappings.

---

## Best Practices Implemented

### Infrastructure as Code
- All configurations defined in docker-compose.yml files
- Version-controllable deployment definitions
- Reproducible environments
- Easy disaster recovery

### Data Persistence
- Docker volumes for all critical data
- Separation of code and data
- Regular backup procedures
- Volume inspection and management

### Security Hardening
- Minimal port exposure
- Strong password requirements
- Firewall rules (defense in depth)
- HTTPS-only access
- Regular security updates

### Monitoring and Maintenance
- Container health checks
- Log monitoring
- Resource usage tracking
- Automated certificate renewal
- Documented procedures

---

## Future Enhancements

### Additional Services to Deploy
- **Portainer:** Docker management UI
- **Database containers:** PostgreSQL, MySQL, Redis
- **Monitoring stack:** Prometheus, Grafana, Loki
- **CI/CD:** GitLab, Jenkins, GitHub Actions runners
- **File storage:** Nextcloud
- **Project management:** Jira, GitLab

### Advanced Security
- **2FA/MFA:** Authelia, OAuth2 Proxy
- **VPN access:** Tailscale, WireGuard
- **IP whitelisting:** Restrict access by geography
- **Rate limiting:** DDoS protection
- **Audit logging:** Centralized logging

### High Availability
- **Load balancing:** Multiple backend instances
- **Backup servers:** Failover configuration
- **Database replication:** Master-slave setup
- **Automated backups:** Scheduled and offsite

### Automation
- **Automated backups:** Cron jobs with rotation
- **Infrastructure monitoring:** Alerting on failures
- **Automated updates:** Security patches
- **Configuration management:** Ansible, Terraform

---

## Technologies and Tools Summary

| Category | Technology | Purpose |
|----------|-----------|---------|
| **Domain Registrar** | Namecheap | Domain name purchase and management |
| **DNS Provider** | Cloudflare | Fast DNS resolution, DDoS protection |
| **Cloud Provider** | Hetzner | Ubuntu server hosting |
| **Operating System** | Ubuntu 22.04 LTS | Server platform |
| **Containerization** | Docker Engine | Application containerization |
| **Orchestration** | Docker Compose | Multi-container management |
| **Reverse Proxy** | Nginx Proxy Manager | SSL termination, routing |
| **Web Server** | Nginx | Underlying proxy server |
| **Certificate Authority** | Let's Encrypt | Free SSL/TLS certificates |
| **IDE** | Code-Server | Browser-based development |
| **Firewall** | UFW | Host-level firewall |
| **Tools** | curl, dig, docker CLI | Testing and troubleshooting |

---

## Learning Resources Used

### Official Documentation
- Docker Documentation
- Nginx Proxy Manager Docs
- Let's Encrypt Documentation
- Cloudflare Learning Center
- Code-Server Documentation

### Key Concepts Mastered
- Domain name system (DNS)
- SSL/TLS encryption and certificates
- Reverse proxy architecture
- Container orchestration
- Network security
- Web infrastructure deployment

---

## Week 2 Deliverables

### Infrastructure
1. ✅ Fully configured domain with DNS
2. ✅ Docker environment with custom network
3. ✅ Nginx Proxy Manager with SSL certificates
4. ✅ Code-Server accessible via HTTPS
5. ✅ Automated certificate renewal

### Documentation
1. ✅ System configuration notes
2. ✅ Backup procedures
3. ✅ Troubleshooting guides
4. ✅ Access credentials (securely stored)
5. ✅ Architecture diagrams

### Skills Demonstrated
1. ✅ Linux system administration
2. ✅ Docker containerization
3. ✅ DNS configuration
4. ✅ SSL/TLS certificate management
5. ✅ Reverse proxy setup
6. ✅ Security best practices
7. ✅ Production deployment workflow

---

## Conclusion

Week 2 successfully established a production-grade, secure web infrastructure from the ground up. Students gained hands-on experience with industry-standard tools and practices including domain management, DNS configuration, Docker containerization, reverse proxy architecture, and SSL/TLS certificate automation.

The resulting infrastructure is:
- **Secure:** HTTPS encryption, multi-layer security, automated certificates
- **Scalable:** Easy to add new services with same pattern
- **Professional:** Custom domain, proper DNS, SSL certificates
- **Maintainable:** Documented, reproducible, automated
- **Practical:** Real-world architecture used in production

This foundation enables students to deploy any web application or service securely and professionally, providing the skills necessary for modern DevOps and cloud infrastructure management.

---

## Quick Command Reference

```bash
# System Management
sudo apt update && sudo apt upgrade -y
sudo ufw status
sudo systemctl status docker

# Docker Commands
docker ps                                    # List running containers
docker ps -a                                 # List all containers
docker compose up -d                         # Start services
docker compose down                          # Stop and remove
docker compose logs -f                       # Follow logs
docker compose restart                       # Restart services

# DNS Testing
dig code.yourdomain.com +short              # Check A record
dig @1.1.1.1 code.yourdomain.com            # Query Cloudflare DNS
nslookup code.yourdomain.com                # Alternative DNS check

# SSL Testing
curl -I https://code.yourdomain.com         # Check HTTPS
openssl s_client -connect domain:443        # Check certificate

# NPM Management
cd ~/docker/nginx-proxy-manager
docker compose restart
docker compose logs --tail=50

# Code-Server Management
cd ~/docker/code-server
docker compose restart
docker compose logs --tail=50

# Backups
docker volume ls                             # List volumes
# Backup volumes with tar (see lab notes)
```

---

**Week 2 Complete! Ready for Week 3! 🚀**
