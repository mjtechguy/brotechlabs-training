# Hetzner Cloud: Zero to Hero

A comprehensive, beginner-friendly course on mastering Hetzner Cloud infrastructure.

---

## Course Overview

This course takes you from complete beginner to confident Hetzner Cloud user. You'll learn everything you need to deploy, manage, secure, and scale infrastructure on Hetzner Cloud.

**Who this course is for:**
- Complete beginners to cloud computing
- Developers wanting to learn infrastructure
- System administrators new to Hetzner
- Anyone wanting affordable, powerful cloud infrastructure

**What you'll learn:**
- Set up and manage Hetzner Cloud accounts
- Deploy and manage virtual servers (VPS)
- Configure networking, storage, and security
- Optimize performance and costs
- Build production-ready infrastructure

**Prerequisites:**
- Basic computer skills
- Ability to use a terminal/command line (we'll teach you!)
- No prior cloud experience needed

**Time commitment:**
- 10 modules
- ~20-30 hours total
- Self-paced

**Cost:**
- Course: Free
- Hetzner Cloud: ~€5-20 (~$5.50-$22) for course exercises (can delete resources after each lab)

---

## What is Hetzner Cloud?

**Hetzner Cloud** is a European cloud infrastructure provider that offers:
- Virtual Private Servers (VPS) - computers you rent in the cloud
- Networking - connect your servers together
- Storage - add extra disk space
- Load Balancers - distribute traffic across multiple servers

**Why Hetzner?**
- **Affordable:** Often 50-70% cheaper than AWS, Google Cloud, or Azure
- **Powerful:** High-performance hardware (AMD EPYC, Intel, Arm64)
- **Simple:** Easy-to-use interface and straightforward pricing
- **European:** Data centers in Germany, Finland (great for GDPR compliance)
- **Reliable:** 99.9% uptime, established since 1997

**Hetzner vs Other Cloud Providers:**

| Feature | Hetzner | AWS | DigitalOcean |
|---------|---------|-----|--------------|
| Entry server | €4.51/mo (~$4.90) | ~€15/mo (~$16) | ~€6/mo (~$6.50) |
| Complexity | Low | Very High | Medium |
| Location | EU + US | Global | Global |
| Best for | Cost-conscious users | Enterprise | Developers |

---

## Course Structure

### Module 0: Orientation & Fundamentals
**Time:** 2 hours

Learn what Hetzner Cloud is, create an account, and understand server types.

- What is Hetzner Cloud?
- Server types explained (CX, CPX, CCX, CAX)
- Account creation and setup
- Hetzner CLI installation

**Lab:** Configure CLI and explore available options

---

### Module 1: Deploying and Managing Servers
**Time:** 3 hours

Deploy your first servers and learn lifecycle management.

- Understanding server types
- Deploy via Console (web interface)
- Deploy via CLI (command line)
- Server lifecycle (start, stop, reboot, etc.)
- Images and snapshots

**Lab:** Deploy servers, compare performance, create snapshots

---

### Module 2: Networking Essentials
**Time:** 3 hours

Build secure, flexible network topologies.

- IPv4 and IPv6 addresses
- Floating IPs for high availability
- Private networks
- Firewall rules
- Load balancers (overview)

**Lab:** Create private network, configure floating IP, test connectivity

---

### Module 3: Storage & Data Management
**Time:** 2 hours

Manage persistent storage and backups.

- Root volumes vs attached volumes
- Creating and managing volumes
- Mounting and formatting storage
- Volume snapshots
- Backup strategies

**Lab:** Create volume, move data between servers

---

### Module 4: Security & Access Control
**Time:** 3 hours

Secure your infrastructure properly.

- SSH key management
- Network isolation
- Server hardening
- API token security
- GDPR considerations

**Lab:** Harden server, apply firewall, validate security

---

### Module 5: Scaling & Resource Optimization
**Time:** 2 hours

Optimize resources and manage costs.

- Upgrading/downgrading servers
- Using snapshots for scaling
- Monitoring and metrics
- Resource organization
- Cost tracking

**Lab:** Rescale servers, monitor costs, organize resources

---

### Module 6: Advanced Server Operations
**Time:** 3 hours

Master operational tools and automation.

- Rescue mode and recovery
- Cloud-init automation
- Console logs and debugging
- API exploration

**Lab:** Deploy server with cloud-init configuration

---

### Module 7: Regional Strategy & Performance Tuning
**Time:** 2 hours

Optimize for latency and performance.

- Data center locations
- Hardware choices (Intel, AMD, Arm64)
- Performance benchmarking
- Multi-region strategies

**Lab:** Compare performance across regions

---

### Module 8: Administration & Real-World Operations
**Time:** 2 hours

Run infrastructure like a professional.

- Project management
- Usage auditing
- Disaster recovery
- Support and incidents

**Lab:** Full restore from snapshot

---

### Module 9: Capstone Project
**Time:** 4 hours

Build production-ready infrastructure.

**Project:** Deploy a complete 2-tier application with:
- Application servers
- Database server
- Private networking
- Floating IP for failover
- Backups and monitoring
- Security hardening

---

## Learning Path

**Recommended order:**
1. Complete modules in sequence (0 → 9)
2. Do all labs - hands-on practice is essential
3. Take notes and experiment
4. Don't rush - understanding is more important than speed

**Alternative paths:**

**Fast Track (experienced users):**
- Modules 0, 1, 2, 4, 9
- Time: ~8 hours

**Security Focus:**
- Modules 0, 1, 2, 4, 6
- Time: ~10 hours

**Operations Focus:**
- Modules 0, 1, 3, 5, 8
- Time: ~10 hours

---

## Course Resources

**Official Documentation:**
- [Hetzner Cloud Docs](https://docs.hetzner.com/cloud/)
- [Hetzner API Docs](https://docs.hetzner.cloud/)
- [Hetzner CLI (hcloud)](https://github.com/hetznercloud/cli)

**Pricing:**
- [Hetzner Cloud Pricing](https://www.hetzner.com/cloud)

**Community:**
- [Hetzner Community Forum](https://community.hetzner.com/)
- [Hetzner Status Page](https://status.hetzner.com/)

**Additional Learning:**
- [Linux Command Line Basics](https://ubuntu.com/tutorials/command-line-for-beginners)
- [SSH Key Guide](https://www.ssh.com/academy/ssh/keygen)

---

## What You'll Need

**Hardware:**
- Computer (Windows, Mac, or Linux)
- Internet connection
- At least 4GB RAM

**Software (free):**
- Terminal/Command line
  - Mac: Built-in Terminal
  - Windows: PowerShell or WSL
  - Linux: Built-in Terminal
- Text editor (VS Code, Sublime, nano, vim)
- SSH client (usually built-in)

**Accounts:**
- Hetzner Cloud account (will create in Module 0)
- Credit/debit card for Hetzner (~€5-20 / $5.50-$22 budget)

**Knowledge:**
- Basic computer skills
- Willingness to learn!

---

## Cost Estimate

**Course exercises:**
- Module 0: €0-1 (~$0-1)
- Module 1: €1-2 (~$1-2)
- Module 2: €2-3 (~$2-3)
- Module 3: €1-2 (~$1-2)
- Module 4: €1 (~$1)
- Module 5: €1-2 (~$1-2)
- Module 6: €1 (~$1)
- Module 7: €2-4 (~$2-4)
- Module 8: €1 (~$1)
- Module 9: €3-5 (~$3-5)

**Total: €15-25 (~$16-27)** (if you delete resources after each module)

**Tips to minimize costs:**
- Delete resources immediately after each lab
- Use smallest server types (CPX11, CAX11)
- Billing is hourly - you only pay for what you use
- Set up billing alerts in Hetzner Console

---

## Glossary

Key terms you'll learn:

- **VPS** - Virtual Private Server (a virtual computer you rent)
- **Instance** - Another name for a server/VPS
- **CLI** - Command Line Interface (text-based commands)
- **Console** - Hetzner's web interface for managing resources
- **API** - Application Programming Interface (programmatic access)
- **SSH** - Secure Shell (encrypted remote access to servers)
- **Snapshot** - Point-in-time backup of a server
- **Volume** - Additional storage you can attach to servers
- **Floating IP** - IP address that can move between servers
- **Private Network** - Isolated network for your servers

*(Full glossary available in each module)*

---

## Getting Help

**During the course:**
- Each module has troubleshooting sections
- Labs include common issues and solutions
- Check Hetzner documentation
- Use Hetzner community forum

**Support:**
- Hetzner Support (email): https://accounts.hetzner.com/support
- Community Forum: https://community.hetzner.com/
- Status Page: https://status.hetzner.com/

---

## Start Learning

Ready to begin? Start with Module 0!

**Next:** [Module 0 - Orientation & Fundamentals](./module-00-orientation.mdcl)

---

Good luck on your journey to Hetzner Cloud mastery! 🚀
