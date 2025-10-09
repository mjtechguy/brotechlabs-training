# Week 2: Secure Domain-Based Deployment with Docker & Nginx Proxy Manager

## Overview

Week 2 focuses on building a production-ready, secure web infrastructure. You'll learn how to purchase and configure a domain name, set up professional DNS management, deploy containerized applications using Docker, and implement reverse proxy with automatic SSL/TLS certificates.

By the end of this week, you'll have a fully functional, HTTPS-secured development environment accessible via your own domain name.

---

## Learning Objectives

By completing Week 2, you will:

- ✅ Understand domain name registration and management
- ✅ Configure professional DNS using Cloudflare
- ✅ Deploy and manage Docker containers
- ✅ Set up Nginx Proxy Manager for reverse proxying
- ✅ Obtain and auto-renew SSL/TLS certificates from Let's Encrypt
- ✅ Deploy code-server securely behind a reverse proxy
- ✅ Understand the complete web request flow from browser to application
- ✅ Implement security best practices for production deployments

---

## Project Architecture

### What We're Building

```
Domain (namecheap.com)
    ↓
DNS (Cloudflare)
    ↓
Hetzner Server (Public IP)
    ↓
Nginx Proxy Manager (Docker Container)
    ├── Port 80 (HTTP) → Auto-redirect to HTTPS
    ├── Port 443 (HTTPS) → SSL/TLS termination
    └── Reverse Proxy Routes:
        ├── code.yourdomain.com → Code-Server Container
        └── (future subdomains for other apps)
    ↓
Code-Server (Docker Container)
    └── VS Code in browser (accessible only through proxy)
```

### Key Components

1. **Domain Name** (Namecheap)
   - Your custom web address
   - Example: `mydevlab.com`

2. **DNS Management** (Cloudflare)
   - Translates domain to server IP
   - Fast global DNS resolution
   - Free SSL/TLS (not used in our setup, but available)
   - DDoS protection

3. **Cloud Server** (Hetzner)
   - Ubuntu 22.04 LTS
   - Docker host
   - Public IP address

4. **Docker Engine**
   - Container runtime
   - Isolates applications
   - Easy deployment and management

5. **Nginx Proxy Manager** (NPM)
   - Web-based reverse proxy management
   - Automatic Let's Encrypt SSL certificates
   - Traffic routing to containers

6. **Let's Encrypt**
   - Free SSL/TLS certificates
   - Automatic renewal
   - Browser-trusted certificates

7. **Code-Server**
   - VS Code in browser
   - Accessible via HTTPS
   - Secured behind proxy

---

## Topic 1: Domain Names and Registration

### What is a Domain Name?

A **domain name** is a human-readable address that points to an IP address on the internet. Instead of remembering `123.45.67.89`, you can use `mywebsite.com`.

### Domain Name Anatomy

```
https://code.mydevlab.com
  |      |     |       └── Top-Level Domain (TLD)
  |      |     └────────── Second-Level Domain (SLD)
  |      └──────────────── Subdomain
  └─────────────────────── Protocol
```

**Components:**
- **Protocol**: `https://` or `http://` (how to connect)
- **Subdomain**: `code`, `www`, `blog`, `api` (optional prefix)
- **Domain**: `mydevlab` (your unique name)
- **TLD**: `.com`, `.net`, `.io`, `.dev` (extension)

### Common Top-Level Domains (TLDs)

| TLD | Purpose | Cost (Typical) | Best For |
|-----|---------|----------------|----------|
| `.com` | Commercial | $10-15/year | General purpose, most popular |
| `.net` | Network | $12-15/year | Tech, networking companies |
| `.org` | Organization | $12-15/year | Non-profits, open source |
| `.io` | Input/Output | $30-40/year | Tech startups, developers |
| `.dev` | Developer | $12-15/year | Development projects |
| `.xyz` | Generic | $1-10/year | Budget-friendly, modern |
| `.app` | Applications | $15-20/year | Web/mobile apps |
| `.cloud` | Cloud services | $8-20/year | Cloud projects |

### Why Namecheap?

**Namecheap** is a popular domain registrar known for:

**Pros:**
- ✅ Competitive pricing
- ✅ Free WHOIS privacy (hides your personal info)
- ✅ User-friendly interface
- ✅ Good customer support
- ✅ Free dynamic DNS
- ✅ No hidden renewal fees (mostly)

**Cons:**
- ❌ DNS management interface less advanced than Cloudflare
- ❌ Not as fast as some premium DNS services

**Alternatives:**
- **Cloudflare Registrar**: At-cost pricing (no markup), but requires Cloudflare account
- **Google Domains**: Simple, integrated with Google services (being transitioned to Squarespace)
- **Porkbun**: Competitive pricing, good features
- **GoDaddy**: Popular but often more expensive with aggressive upselling

### Domain Pricing Considerations

**Initial Registration vs Renewal:**
- First year: Often discounted (e.g., $0.99, $8.88)
- Renewal: Regular price (e.g., $12.98/year for .com)
- **Always check renewal price before buying!**

**Hidden Costs to Watch For:**
- WHOIS privacy: Free on Namecheap, paid elsewhere (~$5-10/year)
- DNS hosting: Free on most registrars
- Email forwarding: Sometimes paid feature
- SSL certificates: Free with Let's Encrypt (we'll use this)

### WHOIS and Privacy

**WHOIS Database:**
- Public directory of domain ownership
- Shows: Name, email, phone, address of domain owner
- Required by ICANN (internet governing body)

**WHOIS Privacy Protection:**
- Replaces your personal info with registrar's contact info
- Protects against spam and identity theft
- **Free on Namecheap** (paid on many other registrars)
- Highly recommended for personal domains

### Domain Lifecycle

```
Available → Purchase → Active → Renewal → Active
                          ↓
                    Expires (if not renewed)
                          ↓
                    Grace Period (30-45 days)
                          ↓
                    Redemption Period (30 days, higher fee)
                          ↓
                    Deleted (back to available)
```

**Important:**
- Enable **auto-renewal** to prevent losing your domain
- Domains can be expensive to recover after expiration
- Set calendar reminders before renewal dates

### Choosing Your Domain Name

**Best Practices:**
- ✅ Short and memorable
- ✅ Easy to spell and pronounce
- ✅ Avoid numbers and hyphens
- ✅ Use .com if available (most recognized)
- ✅ Check trademark issues
- ✅ Consider brand/project name

**For Learning/Personal Projects:**
- Use your name: `johnsmith.dev`
- Use project name: `mydevlab.com`
- Use creative combinations: `codecrafters.io`

**Domain Availability Check:**
- Search on Namecheap, Cloudflare, or any registrar
- Use tools like `whois` command or websites
- Check social media handle availability too

---

## Topic 2: DNS (Domain Name System) and Cloudflare

### What is DNS?

**DNS (Domain Name System)** is the "phone book" of the internet. It translates human-readable domain names to IP addresses that computers use to communicate.

### How DNS Works

**The DNS Resolution Process:**

```
1. You type: code.mydevlab.com
          ↓
2. Browser checks: Local DNS cache
          ↓ (if not found)
3. Queries: OS DNS cache
          ↓ (if not found)
4. Queries: Recursive DNS server (ISP or Cloudflare 1.1.1.1)
          ↓
5. Recursive server queries: Root nameserver (.)
          ↓
6. Root nameserver returns: .com TLD nameserver
          ↓
7. TLD nameserver returns: mydevlab.com authoritative nameserver
          ↓
8. Authoritative nameserver returns: IP address (123.45.67.89)
          ↓
9. Browser connects to: 123.45.67.89
```

**This process takes milliseconds!**

### DNS Record Types

Understanding DNS record types is essential for configuring your domain:

#### A Record (Address Record)
- **Purpose**: Maps domain name to IPv4 address
- **Example**: `mydevlab.com → 123.45.67.89`
- **Use**: Point domain to server

```
Type: A
Name: @  (represents root domain)
Content: 123.45.67.89
TTL: 3600 (1 hour)
```

#### AAAA Record (IPv6 Address Record)
- **Purpose**: Maps domain name to IPv6 address
- **Example**: `mydevlab.com → 2001:db8::1`
- **Use**: Point domain to IPv6 server

#### CNAME Record (Canonical Name)
- **Purpose**: Creates alias from one domain to another
- **Example**: `www.mydevlab.com → mydevlab.com`
- **Use**: Redirect subdomains, point to CDNs

```
Type: CNAME
Name: www
Content: mydevlab.com
TTL: 3600
```

**Important**:
- Cannot use CNAME on root domain (@)
- CNAME cannot coexist with other records for same name

#### MX Record (Mail Exchange)
- **Purpose**: Specifies mail servers for domain
- **Example**: `mydevlab.com → mail.google.com`
- **Use**: Configure email delivery

```
Type: MX
Name: @
Content: aspmx.l.google.com
Priority: 10
TTL: 3600
```

#### TXT Record (Text Record)
- **Purpose**: Stores text information
- **Example**: Domain verification, SPF, DKIM
- **Use**: Prove domain ownership, email security

```
Type: TXT
Name: @
Content: "v=spf1 include:_spf.google.com ~all"
TTL: 3600
```

#### NS Record (Nameserver)
- **Purpose**: Delegates DNS zone to nameservers
- **Example**: Points to Cloudflare's nameservers
- **Use**: Tell where to find DNS records

```
Type: NS
Name: @
Content: ns1.cloudflare.com
TTL: 86400
```

### TTL (Time To Live)

**TTL** specifies how long DNS records are cached before being refreshed.

**Common TTL Values:**
- **300 seconds (5 minutes)**: When making changes, quick updates
- **3600 seconds (1 hour)**: Good balance
- **86400 seconds (24 hours)**: Stable records, reduces DNS queries
- **Auto**: Let DNS provider optimize

**Strategy:**
- Lower TTL before making changes (e.g., IP change)
- Higher TTL for stable production systems
- Balance between speed and cache efficiency

### What is Cloudflare?

**Cloudflare** is a global network providing:
- DNS management (extremely fast)
- CDN (Content Delivery Network)
- DDoS protection
- SSL/TLS certificates
- Web Application Firewall (WAF)
- Analytics
- And much more...

**Free Tier Includes:**
- ✅ Fast, reliable DNS (1.1.1.1 resolver)
- ✅ DDoS protection
- ✅ SSL/TLS certificates
- ✅ CDN (caching)
- ✅ Analytics
- ✅ Email forwarding (limited)
- ✅ Page rules (3 free)

### Why Use Cloudflare for DNS?

**Advantages over registrar DNS:**

1. **Speed**: Cloudflare has one of the fastest DNS resolution times globally
   - Average global response: <20ms
   - Anycast network (200+ cities worldwide)

2. **Reliability**: 100% uptime SLA on paid plans, excellent on free

3. **Security**:
   - DDoS protection
   - DNSSEC support
   - Protection against DNS attacks

4. **Features**:
   - Advanced DNS management
   - API access for automation
   - CNAME flattening
   - Proxied DNS (orange cloud)

5. **Free**: All basic features at no cost

**Cloudflare DNS vs Namecheap DNS:**

| Feature | Cloudflare | Namecheap |
|---------|------------|-----------|
| **Speed** | Extremely fast (<20ms) | Good (~40ms) |
| **DDoS Protection** | Yes, included | No |
| **SSL/TLS** | Free, automatic | Not provided |
| **CDN** | Yes, free | No |
| **API** | Full API access | Limited |
| **Interface** | Modern, intuitive | Functional |
| **Analytics** | Detailed, real-time | Basic |
| **Price** | Free tier excellent | Free with domain |

### Cloudflare Proxy (Orange Cloud vs Gray Cloud)

**Orange Cloud (Proxied):**
- Traffic routed through Cloudflare's network
- Hides your real server IP
- Enables CDN, caching, firewall
- SSL/TLS termination at Cloudflare
- DDoS protection active

**Gray Cloud (DNS Only):**
- Direct connection to your server
- Real IP visible in DNS
- No CDN or caching
- No Cloudflare firewall
- Faster for non-HTTP traffic

**For Our Project:**
- We'll use **gray cloud (DNS only)**
- Why? We want direct connection to server
- We'll handle SSL at Nginx Proxy Manager
- Simpler troubleshooting for learning

**Production Consideration:**
- Orange cloud recommended for websites
- Gray cloud for SSH, custom protocols
- Can mix: Orange for HTTP(S), gray for mail

### DNS Propagation

**DNS Propagation** is the time it takes for DNS changes to spread across the internet.

**Factors Affecting Propagation:**
- TTL values (cached records)
- ISP DNS caching policies
- Geographic location
- DNS provider infrastructure

**Typical Timeline:**
- Cloudflare: Near-instant (seconds to minutes)
- Global propagation: 24-48 hours (worst case)
- Realistic: 15 minutes to 4 hours for most users

**Check Propagation:**
- Tools: whatsmydns.net, dnschecker.org
- Command: `dig @1.1.1.1 yourdomain.com`
- Wait before troubleshooting (give it time!)

### Nameserver Delegation

**Nameservers** are DNS servers that hold authoritative records for your domain.

**How It Works:**
```
1. Buy domain at Namecheap
   Default nameservers: ns1.namecheap.com

2. Point nameservers to Cloudflare
   Change to: ns1.cloudflare.com, ns2.cloudflare.com

3. Manage DNS at Cloudflare
   All DNS records now controlled by Cloudflare

4. Users query domain
   DNS queries go to Cloudflare nameservers
```

**Namecheap → Cloudflare Flow:**
1. Add domain to Cloudflare account
2. Cloudflare provides nameserver addresses
3. Update nameservers in Namecheap dashboard
4. Wait for propagation (usually 15 minutes to 4 hours)
5. Cloudflare confirms when active
6. Manage all DNS records in Cloudflare

**Important:**
- Once nameservers changed, manage DNS at Cloudflare only
- Changing DNS at Namecheap won't work anymore
- Can switch back anytime (but why would you?)

---

## Topic 3: Docker and Containerization

### What is Docker?

**Docker** is a platform for developing, shipping, and running applications in containers.

**Container** = Lightweight, standalone package containing:
- Application code
- Runtime environment
- System libraries
- Dependencies
- Configuration

**Think of it as:**
- Shipping container for software
- Isolated environment
- Portable across systems
- Consistent behavior everywhere

### Why Docker?

**Problems Docker Solves:**

1. **"Works on my machine" syndrome**
   - Different OS versions
   - Missing dependencies
   - Configuration differences
   - → Docker: Same container runs everywhere

2. **Dependency conflicts**
   - App A needs Python 3.8
   - App B needs Python 3.11
   - → Docker: Each in isolated container

3. **Complex setup**
   - Install database, configure, secure
   - Multiple services with specific versions
   - → Docker: `docker run` and done

4. **Resource efficiency**
   - VMs are heavy (GBs of RAM per instance)
   - Containers share kernel (MBs of RAM)
   - → Docker: Run many containers on one server

5. **Deployment consistency**
   - Different dev/staging/production environments
   - Manual configuration errors
   - → Docker: Same image everywhere

### Containers vs Virtual Machines

**Virtual Machines (VMs):**
```
┌──────────┬──────────┬──────────┐
│  App A   │  App B   │  App C   │
├──────────┼──────────┼──────────┤
│ Guest OS │ Guest OS │ Guest OS │
│  (3 GB)  │  (3 GB)  │  (3 GB)  │
├──────────┴──────────┴──────────┤
│         Hypervisor              │
├─────────────────────────────────┤
│           Host OS               │
├─────────────────────────────────┤
│          Hardware               │
└─────────────────────────────────┘
Total: ~10 GB RAM
Boot time: Minutes
```

**Docker Containers:**
```
┌──────────┬──────────┬──────────┐
│  App A   │  App B   │  App C   │
│ (50 MB)  │ (100 MB) │ (75 MB)  │
├──────────┴──────────┴──────────┤
│        Docker Engine            │
├─────────────────────────────────┤
│           Host OS               │
├─────────────────────────────────┤
│          Hardware               │
└─────────────────────────────────┘
Total: ~500 MB RAM
Boot time: Seconds
```

**Comparison:**

| Feature | Virtual Machines | Containers |
|---------|-----------------|------------|
| **Size** | GBs (full OS) | MBs (app + deps) |
| **Startup** | Minutes | Seconds |
| **Resource Usage** | Heavy | Light |
| **Isolation** | Strong (separate OS) | Good (shared kernel) |
| **Portability** | Lower | High |
| **OS Flexibility** | Any OS | Same as host kernel |
| **Performance** | Some overhead | Near-native |

**When to Use:**
- **VMs**: Different OS types, maximum isolation, legacy apps
- **Containers**: Modern apps, microservices, cloud-native, DevOps

### Docker Core Concepts

#### Images
**Docker Image** = Read-only template for creating containers

**Think of it as:**
- Blueprint for container
- Snapshot of filesystem
- Layered structure (efficient storage)

**Example:**
- `nginx:latest` - Official Nginx image
- `ubuntu:22.04` - Ubuntu 22.04 base image
- `node:18-alpine` - Node.js on Alpine Linux (small)

**Image Layers:**
```
┌─────────────────────────────────┐
│ Application Code (10 MB)        │ ← Your layer
├─────────────────────────────────┤
│ Dependencies (50 MB)            │ ← Node modules
├─────────────────────────────────┤
│ Runtime (Node.js) (100 MB)      │ ← Node.js
├─────────────────────────────────┤
│ Base OS (Ubuntu) (20 MB)        │ ← Base layer
└─────────────────────────────────┘
```

**Benefits of Layers:**
- Shared between images (save disk space)
- Faster downloads (only changed layers)
- Efficient caching

#### Containers
**Docker Container** = Running instance of an image

**Think of it as:**
- Process running in isolated environment
- Ephemeral (can be stopped/started/deleted)
- Created from image
- Can run multiple containers from one image

**Container Lifecycle:**
```
Created → Running → Paused → Stopped → Removed
   ↑_________|         |         |
           Restart     Stop    Delete
```

#### Volumes
**Docker Volume** = Persistent data storage

**Why Volumes?**
- Containers are ephemeral (data lost when removed)
- Volumes persist data outside container
- Shared between containers
- Managed by Docker

**Types:**
1. **Named volumes**: Managed by Docker
   - `docker volume create mydata`
   - `/var/lib/docker/volumes/mydata`

2. **Bind mounts**: Host directory mounted in container
   - Map `/home/user/data` → `/app/data` in container
   - Direct access from host

3. **tmpfs mounts**: In-memory, temporary
   - Fast but volatile
   - Sensitive data

**Example Use Cases:**
- Database data (PostgreSQL, MySQL)
- Application uploads
- Configuration files
- Log files

#### Networks
**Docker Network** = Isolated network for containers

**Default Networks:**
- **bridge**: Default, containers can talk to each other
- **host**: Share host's network (no isolation)
- **none**: No network access

**Custom Networks:**
- Containers on same network can communicate
- DNS resolution by container name
- Isolated from other networks

**Example:**
```
Network: web_network
├── nginx-proxy-manager (port 80, 443)
├── code-server
└── database
```

Containers can reach each other:
- `http://code-server:8080`
- `http://database:5432`

### Docker Registry and Docker Hub

**Docker Registry** = Repository for Docker images

**Docker Hub:**
- Official public registry (hub.docker.com)
- Millions of images
- Official images (verified, maintained)
- Community images
- Free for public images

**Common Official Images:**
- `nginx` - Web server
- `mysql` - Database
- `postgres` - Database
- `redis` - Cache
- `node` - Node.js runtime
- `python` - Python runtime
- `ubuntu` - Ubuntu OS

**Image Naming:**
```
registry/username/repository:tag

docker.io/library/nginx:latest
└──┬───┘ └──┬──┘ └─┬─┘ └──┬──┘
Registry  User   Name   Tag
```

**Tags:**
- Version identifiers
- `latest` - Most recent (default)
- `1.21` - Specific version
- `alpine` - Small variant (Alpine Linux)
- `1.21-alpine` - Version + variant

### Docker Compose

**Docker Compose** = Tool for defining multi-container applications

**Why Docker Compose?**
- Managing multiple containers is complex
- Manual `docker run` commands are tedious
- Compose uses YAML file for configuration
- One command to start entire application

**Compose File Example (docker-compose.yml):**
```yaml
version: '3.8'

services:
  nginx-proxy-manager:
    image: jc21/nginx-proxy-manager:latest
    ports:
      - "80:80"
      - "443:443"
      - "81:81"
    volumes:
      - npm-data:/data
      - npm-letsencrypt:/etc/letsencrypt
    restart: unless-stopped

  code-server:
    image: codercom/code-server:latest
    volumes:
      - code-data:/home/coder
    restart: unless-stopped

volumes:
  npm-data:
  npm-letsencrypt:
  code-data:
```

**Commands:**
```bash
docker-compose up -d       # Start all services
docker-compose down        # Stop and remove
docker-compose ps          # List running services
docker-compose logs -f     # View logs
docker-compose restart     # Restart services
```

**Benefits:**
- Declarative configuration
- Easy to version control
- Reproducible environments
- Simple updates

### Docker Commands Overview

**Images:**
```bash
docker images                      # List images
docker pull nginx                  # Download image
docker rmi image_name              # Remove image
docker build -t myapp .            # Build from Dockerfile
```

**Containers:**
```bash
docker ps                          # List running containers
docker ps -a                       # List all containers
docker run -d --name web nginx     # Run container
docker stop container_name         # Stop container
docker start container_name        # Start stopped container
docker restart container_name      # Restart container
docker rm container_name           # Remove container
docker logs container_name         # View logs
docker exec -it container bash     # Access container shell
```

**Volumes:**
```bash
docker volume ls                   # List volumes
docker volume create mydata        # Create volume
docker volume rm mydata            # Remove volume
docker volume inspect mydata       # View volume details
```

**Networks:**
```bash
docker network ls                  # List networks
docker network create mynet        # Create network
docker network rm mynet            # Remove network
docker network inspect mynet       # View network details
```

**System:**
```bash
docker system df                   # Disk usage
docker system prune                # Clean unused resources
docker system prune -a             # Clean everything unused
```

### Docker Security Considerations

**Best Practices:**
1. ✅ Use official images when possible
2. ✅ Specify image tags (not just `latest`)
3. ✅ Keep images updated
4. ✅ Run containers as non-root user
5. ✅ Limit container resources (CPU, memory)
6. ✅ Use secrets for sensitive data
7. ✅ Scan images for vulnerabilities
8. ✅ Minimal base images (Alpine)

**Security Risks:**
- ❌ Running as root in container
- ❌ Using untrusted images
- ❌ Exposing Docker socket
- ❌ Hardcoded secrets in images
- ❌ Running with `--privileged` flag

---

## Topic 4: Nginx Proxy Manager

### What is a Reverse Proxy?

**Reverse Proxy** = Server that sits between clients and backend servers, forwarding requests to the appropriate backend.

**Forward Proxy (Traditional Proxy):**
```
Client → Proxy → Internet
(Hides client's IP)
```

**Reverse Proxy:**
```
Client → Reverse Proxy → Backend Server(s)
(Hides server's details)
```

### How Reverse Proxy Works

**Without Reverse Proxy:**
```
User visits: http://123.45.67.89:8080
Direct connection to application
No SSL, exposed ports, single app
```

**With Reverse Proxy:**
```
User visits: https://code.mydevlab.com
         ↓
Reverse Proxy (Nginx Proxy Manager)
  - Receives request on port 443 (HTTPS)
  - Terminates SSL/TLS
  - Checks routing rules
  - Forwards to code-server:8080
         ↓
Code-Server Container
  - Receives plain HTTP request
  - Returns response
         ↓
Reverse Proxy
  - Encrypts response with SSL
  - Sends to user's browser
```

### Why Use a Reverse Proxy?

**Benefits:**

1. **SSL/TLS Termination**
   - Handle encryption at proxy level
   - Backend apps don't need SSL config
   - Single place to manage certificates

2. **Domain-Based Routing**
   - Multiple apps on one server
   - `code.mydevlab.com` → Code-Server
   - `blog.mydevlab.com` → Blog App
   - `api.mydevlab.com` → API Server

3. **Security**
   - Hide backend server details
   - Single entry point
   - Add authentication layer
   - Rate limiting, DDoS protection

4. **Load Balancing**
   - Distribute traffic across multiple backends
   - High availability
   - Automatic failover

5. **Caching**
   - Cache static content
   - Reduce backend load
   - Faster response times

6. **Centralized Management**
   - One place to configure routing
   - One place for SSL certificates
   - Easier monitoring and logging

### What is Nginx?

**Nginx** (pronounced "engine-x") = High-performance web server and reverse proxy

**Features:**
- Web server (serve static files)
- Reverse proxy
- Load balancer
- HTTP cache
- Mail proxy

**Why Nginx?**
- ✅ Fast and efficient (handles 10,000+ concurrent connections)
- ✅ Low resource usage
- ✅ Highly configurable
- ✅ Battle-tested (powers 30%+ of all websites)
- ✅ Free and open source

**Nginx vs Apache:**
- Nginx: Event-driven, asynchronous (better for many connections)
- Apache: Process-driven (better for dynamic content)
- Nginx: Better reverse proxy performance
- Apache: More modules and .htaccess support

### What is Nginx Proxy Manager?

**Nginx Proxy Manager (NPM)** = Web-based UI for managing Nginx as a reverse proxy

**Traditional Nginx:**
- Edit configuration files manually
- `/etc/nginx/sites-available/mysite.conf`
- Restart nginx after changes
- Complex syntax
- Terminal-based

**Nginx Proxy Manager:**
- Web UI (beautiful, modern interface)
- Click to add proxy hosts
- Automatic SSL certificate management
- No manual configuration files
- Beginner-friendly

**Think of it as:**
- cPanel for Nginx
- Simplified reverse proxy management
- Let's Encrypt integration
- All the power, easier to use

### Nginx Proxy Manager Features

**Core Features:**

1. **Proxy Hosts**
   - Create domain-based routing rules
   - Forward requests to backend services
   - Custom locations and paths

2. **SSL Certificates**
   - Automatic Let's Encrypt certificates
   - Click to request certificate
   - Auto-renewal (set and forget)
   - Custom certificates supported

3. **Access Lists**
   - Password protection (HTTP Basic Auth)
   - IP whitelisting/blacklisting
   - Protect specific proxy hosts

4. **Redirection Hosts**
   - Redirect one domain to another
   - Permanent (301) or temporary (302)

5. **Streams**
   - TCP/UDP proxy (not just HTTP)
   - SSH, database, custom protocols

6. **Custom Nginx Config**
   - Advanced users can add custom directives
   - Override specific behaviors

**Dashboard Features:**
- Real-time statistics
- Manage all proxy hosts
- Certificate status
- Access list management
- User management (multi-user support)

### NPM Architecture in Our Setup

**Nginx Proxy Manager as Central Hub:**

```
Internet (Port 80, 443)
         ↓
Nginx Proxy Manager Container
  ├── Port 80 → Redirect to 443
  ├── Port 443 → SSL Termination
  └── Port 81 → NPM Admin Panel
         ↓
Proxy Host Rules:
  ├── code.mydevlab.com → code-server:8080
  ├── npm.mydevlab.com → localhost:81 (self)
  └── (future apps here)
         ↓
Backend Containers
  └── Code-Server (only accessible via NPM)
```

**Network Flow:**
1. User types `https://code.mydevlab.com` in browser
2. DNS resolves to server's public IP
3. Request hits NPM on port 443
4. NPM checks routing rules
5. Matches `code.mydevlab.com` → code-server
6. NPM forwards request to code-server container
7. Code-server responds to NPM
8. NPM sends encrypted response to user

### Why NPM for Our Project?

**Perfect for Learning Because:**
- ✅ Visual, easy to understand
- ✅ See the proxy flow clearly
- ✅ Instant SSL certificate setup
- ✅ No complex Nginx syntax
- ✅ Quick to experiment
- ✅ Industry-relevant skill (reverse proxies are everywhere)

**Production-Ready:**
- Used in real-world deployments
- Active development and updates
- Reliable and stable
- Good community support

**Alternatives:**
- **Traefik**: Auto-discovery, better for Kubernetes
- **Caddy**: Auto HTTPS, simpler config
- **HAProxy**: More advanced load balancing
- **Raw Nginx**: More control, steeper learning curve

### NPM Use Cases

**Typical Scenarios:**

1. **Multiple Web Apps on One Server**
   ```
   blog.example.com → WordPress container
   api.example.com → Node.js API container
   app.example.com → React app container
   ```

2. **Secure Internal Services**
   ```
   portainer.internal.com → Docker management UI
   grafana.internal.com → Monitoring dashboard
   (Add password protection via Access Lists)
   ```

3. **Microservices Architecture**
   ```
   users.api.com → User service
   orders.api.com → Order service
   products.api.com → Product service
   ```

4. **Development Environments**
   ```
   dev.myapp.com → Development container
   staging.myapp.com → Staging container
   prod.myapp.com → Production container
   ```

---

## Topic 5: SSL/TLS and Let's Encrypt

### What is SSL/TLS?

**SSL (Secure Sockets Layer)** and **TLS (Transport Layer Security)** = Protocols for encrypting internet traffic

**Note:** SSL is the old term; TLS is the modern version. People still say "SSL" but mean TLS.

**What It Does:**
- Encrypts data in transit
- Prevents eavesdropping
- Verifies website identity
- Required for HTTPS

### HTTP vs HTTPS

**HTTP (HyperText Transfer Protocol):**
```
Browser → [Plain Text] → Server
         "username: john"
         "password: secret123"
         ↓
Anyone on network can read this!
```

**HTTPS (HTTP Secure):**
```
Browser → [Encrypted] → Server
         "k3#9fJ$mN..."
         ↓
Encrypted, unreadable to eavesdroppers
```

**Visual Indicators:**
- HTTP: No lock, "Not Secure" warning in browser
- HTTPS: Padlock icon, "Secure" or company name

**Why HTTPS Matters:**
- ✅ Protects passwords, credit cards, personal data
- ✅ Prevents man-in-the-middle attacks
- ✅ SEO benefit (Google ranks HTTPS higher)
- ✅ Browser trust (modern browsers warn on HTTP)
- ✅ Required for modern web APIs (geolocation, camera, etc.)
- ✅ Professional appearance

### How SSL/TLS Works

**The TLS Handshake (Simplified):**

```
1. Client Hello
   Browser → "I want to connect securely"

2. Server Hello
   Server → "Here's my SSL certificate"

3. Certificate Verification
   Browser → Checks if certificate is:
              - Issued by trusted authority (CA)
              - Valid (not expired)
              - Matches domain name

4. Key Exchange
   Browser & Server → Generate session keys

5. Encrypted Communication
   Browser ↔ Server → All traffic encrypted
```

**Encryption Types:**
- **Symmetric**: Same key for encryption/decryption (fast, used for data)
- **Asymmetric**: Public/private key pair (slow, used for handshake)

**TLS Handshake Uses Both:**
1. Asymmetric to securely exchange symmetric key
2. Symmetric to encrypt actual data

### SSL Certificates

**SSL Certificate** = Digital document that:
- Proves website identity
- Contains public key for encryption
- Issued by Certificate Authority (CA)

**Certificate Components:**
- Domain name(s) it's valid for
- Public key
- Expiration date
- Issuing Certificate Authority
- Digital signature

**Certificate Types:**

1. **Domain Validated (DV)**
   - Verifies domain ownership only
   - Quick to obtain (minutes)
   - Free from Let's Encrypt
   - Good for: Blogs, personal sites, internal tools

2. **Organization Validated (OV)**
   - Verifies organization identity
   - Manual verification process
   - Costs money ($50-200/year)
   - Good for: Business websites

3. **Extended Validation (EV)**
   - Extensive verification
   - Shows company name in address bar (older browsers)
   - Expensive ($200-1000/year)
   - Good for: Banks, e-commerce, high security

**For Our Project:**
- We'll use **Domain Validated (DV)** from Let's Encrypt
- Free, automated, trusted by all browsers
- Perfect for development and most production use

### What is Let's Encrypt?

**Let's Encrypt** = Free, automated, open Certificate Authority

**Founded:** 2016 by Internet Security Research Group (ISRG)

**Mission:** Make HTTPS the default on the web

**Key Facts:**
- ✅ Completely free
- ✅ Automated certificate issuance
- ✅ Automatic renewal
- ✅ Trusted by all major browsers
- ✅ Issues 200+ million certificates
- ✅ Non-profit, community-supported

**How It's Free:**
- Funded by sponsors (Mozilla, Chrome, Cisco, etc.)
- Fully automated (no human labor)
- Open source software (ACME protocol)

### ACME Protocol

**ACME (Automatic Certificate Management Environment)** = Protocol for automating certificate issuance

**How It Works:**

```
1. Your Server → "I want a certificate for code.mydevlab.com"
                ↓
2. Let's Encrypt → "Prove you control that domain"
                ↓
3. Challenge Issued (HTTP-01, DNS-01, or TLS-ALPN-01)
                ↓
4. Your Server → Completes challenge
                ↓
5. Let's Encrypt → Verifies challenge
                ↓
6. Certificate Issued → Valid for 90 days
                ↓
7. Auto-renewal (NPM handles this)
```

**Challenge Types:**

**HTTP-01 (Most Common):**
- Let's Encrypt checks: `http://yourdomain.com/.well-known/acme-challenge/TOKEN`
- Your server must respond with specific token
- Requires port 80 open
- Cannot issue wildcard certificates

**DNS-01:**
- Add TXT record to DNS
- Can issue wildcard certificates (*.mydevlab.com)
- More complex, requires DNS API access

**TLS-ALPN-01:**
- Uses TLS handshake
- Requires port 443
- Less common

**For Our Project:**
- NPM uses **HTTP-01** challenge
- Fully automated, we just click a button!
- NPM handles challenge response automatically

### Certificate Lifecycle

**Issuance:**
```
Request → Challenge → Verification → Issued
```

**Validity:**
- Let's Encrypt: 90 days (shorter = more secure)
- Traditional CAs: 1-2 years

**Renewal:**
- Recommended: Renew at 60 days (30 days before expiry)
- NPM auto-renews for you
- Uses same ACME process

**Revocation:**
- If private key compromised
- Domain ownership lost
- Certificate authority notified

### Why 90-Day Certificates?

**Let's Encrypt Philosophy:**

1. **Security**: Shorter validity = less time for compromise
2. **Automation**: Forces automation (good practice)
3. **Agility**: Easier to change/revoke if needed

**Don't Worry:**
- NPM handles renewal automatically
- Set and forget
- Email notifications if renewal fails

### Certificate Storage

**Where Certificates Live:**
- Private key: Never shared, stays on server
- Public certificate: Sent to browsers
- Chain/Intermediate certificates: Prove trust path to root CA

**In Our Setup:**
- NPM stores certificates in Docker volume
- Persists across container restarts
- Backed up with volume backups

### Browser Trust

**Certificate Trust Chain:**
```
Your Certificate (code.mydevlab.com)
          ↓
Issued by: Let's Encrypt Authority X3
          ↓
Issued by: ISRG Root X1
          ↓
Trusted by: Browser Root Store
```

**Root Store:**
- List of trusted Certificate Authorities
- Built into browsers and operating systems
- Let's Encrypt is in all major root stores
- Your certificate is automatically trusted!

### Common SSL/TLS Errors

**"Certificate Not Trusted":**
- Self-signed certificate
- Expired certificate
- Incomplete certificate chain

**"Certificate Name Mismatch":**
- Certificate issued for different domain
- Accessing via IP instead of domain

**"Certificate Expired":**
- Certificate past expiration date
- Renewal failed

**With NPM:**
- These issues are rare
- Auto-renewal prevents expiration
- Proper configuration prevents mismatches

---

## Topic 6: Secure Code-Server Deployment

### What is Code-Server?

**Code-Server** = Visual Studio Code running in a browser, accessible from anywhere

**Official Description:**
"Run VS Code on any machine anywhere and access it in the browser."

**Created by:** Coder (company formerly known as code-server)

**Why Code-Server?**
- ✅ Access from any device (laptop, tablet, phone)
- ✅ Consistent development environment
- ✅ Cloud-based IDE
- ✅ No local resource usage
- ✅ Collaborate remotely
- ✅ Centralized settings and extensions

### Code-Server vs Desktop VS Code

**Desktop VS Code:**
- Runs on your local machine
- Uses local CPU/RAM
- Local file access
- Extensions installed locally
- Offline capable

**Code-Server:**
- Runs on remote server
- Uses server CPU/RAM
- Server file access
- Extensions installed on server
- Requires internet

**Use Cases:**

**Desktop VS Code:**
- Local development
- Offline work
- Heavy local testing
- Privacy-sensitive projects

**Code-Server:**
- Remote development
- Multiple devices
- Shared team environments
- Powerful server, weak laptop
- Anywhere access

### Security Considerations

**Risks of Exposing Code-Server:**
- Full server access through terminal
- Can read/write any files
- Install packages, modify system
- Execute arbitrary commands

**This Week's Security Layers:**

1. **HTTPS Encryption**
   - All traffic encrypted via TLS
   - Prevents eavesdropping
   - Prevents man-in-the-middle attacks

2. **Domain-Based Access**
   - Not accessible via IP
   - Professional subdomain
   - Easy to remember

3. **Reverse Proxy**
   - Code-server not directly exposed
   - NPM acts as security gateway
   - Additional logging and monitoring

4. **Password Protection**
   - Code-server built-in authentication
   - Strong password required
   - Prevents unauthorized access

**Production Best Practices (Beyond This Week):**
- OAuth2/SSO integration
- IP whitelisting
- VPN access only (Tailscale)
- 2FA authentication
- Audit logging
- Regular security updates

### Code-Server Configuration

**Key Settings:**

**Bind Address:**
```yaml
bind-addr: 0.0.0.0:8080
```
- Listen on all network interfaces
- Port 8080 (internal to container)
- Only accessible via Docker network (not directly from internet)

**Authentication:**
```yaml
auth: password
password: your-strong-password
```
- Built-in password authentication
- Password sent over HTTPS (secure)
- Alternative: `auth: none` (dangerous, only with VPN!)

**Certificate:**
```yaml
cert: false
```
- Don't handle SSL in code-server
- NPM handles SSL termination
- Code-server receives plain HTTP from NPM

### Code-Server in Docker

**Why Docker for Code-Server?**

1. **Isolation**
   - Separate from host system
   - Easy to remove/recreate
   - Consistent environment

2. **Portability**
   - Same image works everywhere
   - Easy backup (volume snapshots)
   - Simple migration to new server

3. **Resource Limits**
   - Limit CPU/memory usage
   - Prevent runaway processes
   - Better server management

4. **Updates**
   - Pull new image, recreate container
   - Easy rollback if issues
   - Version pinning

**Volume Configuration:**
```yaml
volumes:
  - code-data:/home/coder/project
  - code-config:/home/coder/.config
```

**Persisted Data:**
- Project files
- VS Code settings
- Installed extensions
- Terminal history
- Git configuration

### Accessing Code-Server Securely

**The Complete Flow:**

```
1. User types: https://code.mydevlab.com
          ↓
2. Browser checks: Is this HTTPS? ✓
          ↓
3. DNS lookup: code.mydevlab.com → 123.45.67.89
          ↓
4. Browser connects: 123.45.67.89:443
          ↓
5. TLS Handshake:
   - NPM sends Let's Encrypt certificate
   - Browser verifies certificate
   - Encrypted connection established ✓
          ↓
6. NPM receives: HTTPS request
          ↓
7. NPM checks: Proxy host rules
   - code.mydevlab.com → code-server:8080
          ↓
8. NPM forwards: HTTP request to code-server container
          ↓
9. Code-Server checks: Authentication
   - Password required ✓
          ↓
10. User enters: Password
          ↓
11. Code-Server: Grants access
          ↓
12. User sees: VS Code interface in browser!
```

**Security Checkpoints:**
- ✓ HTTPS encryption
- ✓ Valid SSL certificate
- ✓ Domain-based access
- ✓ Reverse proxy layer
- ✓ Password authentication

### Extension Management

**Installing Extensions:**
1. Open code-server in browser
2. Click Extensions icon (sidebar)
3. Search and install
4. Extensions persist in volume

**Popular Extensions:**
- Python, JavaScript, Go language support
- Docker extension
- GitLens
- Prettier (code formatter)
- ESLint
- Remote - SSH (for nested SSH)

**Extension Storage:**
- Stored in: `/home/coder/.local/share/code-server/extensions`
- Persists across container restarts (via volume)
- Same as desktop VS Code

### Customization

**Settings Sync:**
- Settings stored in volume
- Persist across restarts
- Can sync with GitHub account

**Themes:**
- Install any VS Code theme
- Settings → Color Theme

**Keybindings:**
- Same as desktop VS Code
- Customizable

**Workspace:**
- Multi-root workspaces supported
- Git integration works
- Integrated terminal

### Performance Considerations

**Server Resources:**
- Minimum: 1GB RAM, 1 CPU (basic editing)
- Recommended: 2GB+ RAM, 2+ CPU
- Extensions increase resource usage

**Network:**
- Latency matters (round-trip time)
- Choose server location near you
- Modern browsers handle latency well

**Browser:**
- Chrome/Edge: Best performance
- Firefox: Good performance
- Safari: Works but slight lag
- Mobile: Usable, better on tablet

---

## Project Integration: How Everything Works Together

### The Complete System

```
┌─────────────────────────────────────────────────────────┐
│                     INTERNET                            │
└────────────────┬────────────────────────────────────────┘
                 │
                 │ (User visits: https://code.mydevlab.com)
                 ↓
┌─────────────────────────────────────────────────────────┐
│              NAMECHEAP (Domain Registrar)               │
│  - Domain: mydevlab.com                                 │
│  - Nameservers point to Cloudflare                      │
└────────────────┬────────────────────────────────────────┘
                 │
                 ↓
┌─────────────────────────────────────────────────────────┐
│                 CLOUDFLARE (DNS)                        │
│  - A Record: code.mydevlab.com → 123.45.67.89          │
│  - Fast resolution, DDoS protection                     │
└────────────────┬────────────────────────────────────────┘
                 │
                 ↓
┌─────────────────────────────────────────────────────────┐
│              HETZNER CLOUD SERVER                       │
│  - Ubuntu 22.04 LTS                                     │
│  - Public IP: 123.45.67.89                              │
│  - Firewall: Ports 80, 443, 22 open                     │
│                                                         │
│  ┌───────────────────────────────────────────────────┐ │
│  │              DOCKER ENGINE                        │ │
│  │                                                   │ │
│  │  ┌─────────────────────────────────────────────┐ │ │
│  │  │    Nginx Proxy Manager Container          │ │ │
│  │  │    - Ports: 80, 443 (external)             │ │ │
│  │  │    - Port 81: Admin UI                     │ │ │
│  │  │    - SSL/TLS termination                   │ │ │
│  │  │    - Let's Encrypt certificates            │ │ │
│  │  │                                             │ │ │
│  │  │    Proxy Rules:                            │ │ │
│  │  │    code.mydevlab.com → code-server:8080   │ │ │
│  │  └────────────┬────────────────────────────────┘ │ │
│  │               │                                   │ │
│  │               │ (Internal Docker network)         │ │
│  │               ↓                                   │ │
│  │  ┌─────────────────────────────────────────────┐ │ │
│  │  │    Code-Server Container                   │ │ │
│  │  │    - Port: 8080 (internal only)             │ │ │
│  │  │    - VS Code in browser                     │ │ │
│  │  │    - Password protected                     │ │ │
│  │  │    - Volume: /home/coder/project            │ │ │
│  │  └─────────────────────────────────────────────┘ │ │
│  └───────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────┘
```

### Step-by-Step Request Flow

**When you visit `https://code.mydevlab.com`:**

1. **Browser → DNS Query**
   - "What's the IP for code.mydevlab.com?"

2. **Cloudflare → DNS Response**
   - "It's 123.45.67.89"

3. **Browser → Server (Port 443)**
   - HTTPS connection request

4. **NPM → TLS Handshake**
   - Sends Let's Encrypt certificate
   - Browser verifies and establishes encrypted connection

5. **Browser → NPM (Encrypted)**
   - Sends HTTPS request for code.mydevlab.com

6. **NPM → Check Proxy Rules**
   - Matches: code.mydevlab.com → code-server:8080
   - Decrypts HTTPS request

7. **NPM → Code-Server (Plain HTTP)**
   - Forwards request to code-server container
   - Internal Docker network (secure, not exposed)

8. **Code-Server → Authentication Check**
   - Password required? Yes
   - Password correct? Check credentials

9. **Code-Server → NPM (Response)**
   - Returns login page or VS Code interface

10. **NPM → Browser (Encrypted)**
    - Encrypts response with TLS
    - Sends to browser

11. **Browser → User**
    - Displays VS Code interface
    - All subsequent communication encrypted

### Data Persistence

**What Persists (Survives Container Restart/Removal):**

**NPM Data:**
- Proxy host configurations
- SSL certificates
- Access lists
- User accounts
- Stored in: Docker volume `npm-data`

**Code-Server Data:**
- Project files
- VS Code settings
- Installed extensions
- Git configuration
- Stored in: Docker volume `code-data`

**What Doesn't Persist:**
- Running processes in containers
- Container logs (unless configured)
- Temporary files in `/tmp`

### Backup Strategy

**Critical Data to Backup:**
1. Docker volumes (contains all persistent data)
2. Docker Compose file (defines infrastructure)
3. Server SSH keys
4. Domain configuration (documented)

**Backup Methods:**
```bash
# Backup volumes
docker run --rm -v npm-data:/data -v $(pwd):/backup ubuntu tar czf /backup/npm-backup.tar.gz /data

# Backup compose file
cp docker-compose.yml ~/backups/

# Version control
git init && git add docker-compose.yml
git commit -m "Infrastructure as code"
```

### Scaling and Future Expansion

**Easy to Add More Services:**

```yaml
# Add to docker-compose.yml:
services:
  blog:
    image: wordpress:latest
    # ... configuration
```

**Add Proxy Rule in NPM:**
- Domain: `blog.mydevlab.com`
- Forward to: `blog:80`
- SSL certificate: Auto-generate

**Instant New App:**
- Deploy container
- Add DNS record (Cloudflare)
- Add proxy host (NPM)
- Request SSL certificate
- Done!

---

## Week 2 Implementation Plan

### Lab Structure

**Lab 1: Domain and DNS Setup**
- Purchase domain on Namecheap
- Set up Cloudflare account
- Configure nameservers
- Create DNS records
- Verify DNS propagation

**Lab 2: Server and Docker Preparation**
- Deploy Hetzner server (or use existing)
- Install Docker and Docker Compose
- Configure firewall
- Verify Docker installation

**Lab 3: Nginx Proxy Manager Deployment**
- Deploy NPM with Docker Compose
- Access NPM admin panel
- Configure first proxy host
- Request Let's Encrypt certificate
- Test HTTPS access

**Lab 4: Code-Server Deployment**
- Deploy code-server container
- Configure code-server settings
- Add proxy rule in NPM
- Test secure access
- Install extensions

**Lab 5: Testing and Validation**
- Verify HTTPS encryption
- Test password authentication
- Check certificate auto-renewal
- Document configuration
- Troubleshooting common issues

### Prerequisites

**Accounts Needed:**
- Hetzner Cloud account (from Week 1)
- Namecheap account (create free)
- Cloudflare account (create free)

**Cost Estimate:**
- Domain: $1-15/year (one-time for learning)
- Hetzner Server: ~$4.50/month (ongoing)
- Cloudflare: $0 (free tier)
- Total: ~$15 initial + $4.50/month

### Skills You'll Gain

**Technical Skills:**
- ✅ Domain name registration
- ✅ DNS configuration and management
- ✅ Docker installation and management
- ✅ Docker Compose orchestration
- ✅ Reverse proxy configuration
- ✅ SSL/TLS certificate management
- ✅ Container networking
- ✅ Production deployment practices

**Conceptual Understanding:**
- ✅ How the web works (DNS, HTTP, HTTPS)
- ✅ Encryption and security
- ✅ Containerization benefits
- ✅ Reverse proxy patterns
- ✅ Infrastructure as code
- ✅ DevOps workflows

---

## Key Takeaways

### Why This Architecture?

**Production-Ready:**
- Real-world deployment pattern
- Used by startups and enterprises
- Scalable and maintainable
- Industry best practices

**Security First:**
- HTTPS everywhere
- Certificate automation
- Defense in depth
- Professional setup

**Learning Value:**
- Understand complete web stack
- Hands-on with modern tools
- Transferable skills
- Portfolio-worthy project

### Beyond This Week

**What You Can Build:**
- Personal blog (WordPress, Ghost)
- Portfolio website (static or dynamic)
- API servers (Node.js, Python)
- Databases (PostgreSQL, MySQL)
- Monitoring (Grafana, Prometheus)
- File sharing (Nextcloud)
- Media server (Plex, Jellyfin)

**All with:**
- Custom domains
- HTTPS security
- Easy management
- Professional setup

---

## Additional Resources

**Documentation:**
- [Namecheap Knowledgebase](https://www.namecheap.com/support/knowledgebase/)
- [Cloudflare Learning Center](https://www.cloudflare.com/learning/)
- [Docker Documentation](https://docs.docker.com/)
- [Nginx Proxy Manager Docs](https://nginxproxymanager.com/guide/)
- [Let's Encrypt Documentation](https://letsencrypt.org/docs/)
- [Code-Server Documentation](https://coder.com/docs/code-server)

**Learning Resources:**
- [Docker Tutorial for Beginners](https://docker-curriculum.com/)
- [Nginx Handbook](https://www.freecodecamp.org/news/the-nginx-handbook/)
- [How HTTPS Works](https://howhttps.works/) - Comic guide
- [DNS Explained](https://www.cloudflare.com/learning/dns/what-is-dns/)

**Tools:**
- [DNS Propagation Checker](https://www.whatsmydns.net/)
- [SSL Certificate Checker](https://www.sslshopper.com/ssl-checker.html)
- [Docker Hub](https://hub.docker.com/) - Container images
- [Compose File Reference](https://docs.docker.com/compose/compose-file/)

**Communities:**
- [r/docker](https://reddit.com/r/docker) - Docker community
- [r/selfhosted](https://reddit.com/r/selfhosted) - Self-hosting enthusiasts
- [Docker Community Forums](https://forums.docker.com/)
- [Let's Encrypt Community](https://community.letsencrypt.org/)

---

## Next Steps

After understanding these topics, you'll be ready to:

1. **Lab 1**: Purchase domain and configure DNS
2. **Lab 2**: Prepare server with Docker
3. **Lab 3**: Deploy Nginx Proxy Manager
4. **Lab 4**: Deploy and secure Code-Server
5. **Lab 5**: Test, validate, and troubleshoot

Each lab will build on the previous one, creating a complete, secure, production-ready deployment.

---

**Let's build something amazing! 🚀**
