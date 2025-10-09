# Training Program - Weekly Overview

This document provides a summary of all weeks in the training program.

---

## Week 1: IT/DevOps Fundamentals & Cloud Server Administration

Week 1 provides foundational IT knowledge combined with hands-on cloud server administration. Students learn essential concepts through comprehensive reference material and interactive labs on Hetzner Cloud, covering everything from hardware basics to deploying a live web server.

**What You'll Learn**: Hardware fundamentals (storage, RAM, CPU) • Operating systems and file systems • Networking (IP, DNS, DHCP, protocols) • Command line essentials • Git version control • Cloud computing models (IaaS/PaaS/SaaS) • Virtualization (VMs vs containers) • Remote access tools (SSH, RDP, VNC, VPN) • DevOps basics (CI/CD, IaC, Docker, Kubernetes) • Security fundamentals • System troubleshooting • Linux server administration • User management • Package management with apt • Web server deployment with nginx • System monitoring and log analysis

**Hands-On Labs**: Create Ubuntu 22.04 server on Hetzner Cloud (CX11: 1 vCPU, 2GB RAM, ~€4/month) • Configure cloud firewall • Install code-server (browser-based VS Code) • Manage users and sudo privileges • Deploy and configure nginx web server • Monitor system resources • Troubleshoot services using logs

**Lab Format**: Interactive CodeLab (.mdcl) files with executable code blocks, built-in quizzes, and step-by-step guidance

**Time Commitment**: 3-5 hours reading + 2-4 hours hands-on labs

**Tools Used**: Hetzner Cloud • Ubuntu 22.04 LTS • Code-server • SSH • Nginx • Git

**Prerequisites**: Computer with internet • Basic computer skills • Credit card for Hetzner (~€4/month, can delete server after)

**Start Here**: Read `week1/week1-it-devops-basics.md` for foundational concepts, then complete hands-on labs in `week1/hetzner-cloud-server-basics/`

---

## Week 2: Secure Domain-Based Deployment with Docker & Nginx Proxy Manager

Week 2 builds on foundational knowledge to create a production-ready, secure web infrastructure. Students learn domain management, DNS configuration, containerization with Docker, reverse proxy setup, and SSL/TLS certificate automation. By the end, you'll have a fully HTTPS-secured development environment accessible via your own domain name.

**What You'll Learn**: Domain name registration and management • DNS fundamentals (A records, nameservers, propagation) • Cloudflare DNS configuration • Docker Engine and containerization concepts • Docker Compose for multi-container orchestration • Docker volumes and networks • Reverse proxy architecture and benefits • Nginx Proxy Manager web interface • SSL/TLS certificates and encryption • Let's Encrypt and ACME protocol • Certificate auto-renewal • Code-server deployment in Docker • Secure remote development setup • Production deployment best practices • Backup strategies for containerized applications

**Hands-On Labs**: Purchase domain name (Namecheap) • Configure Cloudflare as DNS provider • Deploy Hetzner server with Docker • Install Docker Engine and Docker Compose • Deploy Nginx Proxy Manager (ports 80, 443, 81) • Deploy code-server in Docker container • Create DNS A records in Cloudflare • Configure NPM proxy hosts with domain routing • Request and auto-renew Let's Encrypt SSL certificates • Access code-server securely via HTTPS (https://code.yourdomain.com) • Implement backup procedures for Docker volumes

**Lab Format**: 5 interactive CodeLab (.mdcl) files with executable commands, UI-based configuration guides, architecture diagrams, and comprehensive troubleshooting

**Time Commitment**: 4-6 hours reading + 3-5 hours hands-on labs

**Tools Used**: Namecheap (domain) • Cloudflare (DNS) • Hetzner Cloud • Ubuntu 22.04 LTS • Docker & Docker Compose • Nginx Proxy Manager • Let's Encrypt • Code-server

**Prerequisites**: Completed Week 1 or equivalent knowledge • Domain name budget ($1-15/year) • Hetzner account (~€4/month server) • Basic understanding of web architecture

**Start Here**: Read `week2/week2-topics.md` for in-depth concepts, then follow labs: `01-ubuntu-server-prep.mdcl` → `02-install-docker.mdcl` → `03-nginx-proxy-manager.mdcl` → `04-code-server-docker.mdcl` → `05-dns-and-npm-config.mdcl`

**Summary**: Check `week2/week1-summary.md` for Week 1 recap with key concepts and links

---

## Week 3: [Coming Soon]

---

## Week 4: [Coming Soon]

---

_More weeks will be added as content is developed._
