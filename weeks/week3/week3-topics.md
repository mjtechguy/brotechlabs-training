# Week 3: Automating Your Infrastructure

## Overview

In Week 2, you manually set up everything step-by-step. In Week 3, you'll learn to automate those same steps so a script does the work for you.

**The Big Idea:**
- Week 2: You type every command manually (2-3 hours)
- Week 3: Scripts do it for you (15-20 minutes)

---

## What You'll Learn

- What automation is and why it matters
- Using cloud-init to set up servers automatically
- Writing basic bash scripts
- Deploying the same Week 2 infrastructure, but automated

---

## Why Automate?

**Time Savings:**
- Deploy 1 server manually: 2-3 hours
- Deploy 1 server automated: 15 minutes
- Deploy 10 servers manually: 20-30 hours
- Deploy 10 servers automated: 2-3 hours

**Consistency:**
- Scripts run the same way every time
- No typos or forgotten steps
- Easy to replicate

**Documentation:**
- Your scripts show exactly what you did
- Team members can read and understand
- No guessing about server setup

---

## The Two Tools We'll Use

### 1. Cloud-Init
**What:** A tool that runs ONCE when a server first starts
**Purpose:** Set up the operating system (install Docker, create users, configure firewall)

Think of it as: "Get the server ready for applications"

### 2. Bash Scripts
**What:** A file containing terminal commands
**Purpose:** Deploy and configure your applications (Nginx Proxy Manager, Code-Server)

Think of it as: "Deploy the applications once the server is ready"

---

## Week 3 Labs

### Lab 0: Introduction to Automation (20 min)
Understand why automation matters:
- Compare manual vs automated methods
- See real time savings
- Learn Infrastructure as Code concepts

### Lab 1: Simple Cloud-Init Example (30 min)
Learn cloud-init basics with a simple example that:
- Updates packages
- Installs Docker
- Creates a user

### Lab 2: Simple Bash Script (30 min)
Write your first bash script that:
- Checks if Docker is running
- Deploys a container
- Verifies it worked

### Lab 3: Automated Deployment (60 min)
Combine cloud-init + bash to deploy your full infrastructure automatically with custom website

---

## What You'll Build

The same infrastructure from Week 2:
- Nginx Proxy Manager
- Code-Server
- SSL certificates
- Proper DNS configuration

But this time, automated!

---

## Skills You'll Gain

- Writing cloud-init configurations
- Basic bash scripting
- Infrastructure as Code concepts
- Debugging automation
- Making scripts that can run multiple times safely

---

## Real-World Applications

**DevOps Engineer:**
- Automate deployments
- Save time on repetitive tasks
- Scale infrastructure easily

**Cloud Engineer:**
- Provision servers quickly
- Maintain consistency across environments
- Disaster recovery

**Any IT Role:**
- Automate boring tasks
- Reduce errors
- Document processes in code

---

## Next Steps

Ready to start automating?

**Begin with:** [Lab 0 - Introduction to Automation](./00-intro-to-automation.mdcl)

---

That's it! Keep it simple, learn the basics, and build up from there. 🚀
