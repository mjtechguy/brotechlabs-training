# Week 3: Infrastructure Automation

Learn to automate your infrastructure deployments using cloud-init and bash scripts.

---

## Overview

In Week 2, you manually set up everything step-by-step. In Week 3, you'll automate those same steps so scripts do the work for you.

**Time savings:** Deploy infrastructure in 20 minutes instead of 2-3 hours!

---

## What You'll Learn

- Cloud-init basics (automatic server setup)
- Bash scripting fundamentals
- Automating Docker deployments
- Infrastructure as Code concepts

---

## Labs

Complete these labs in order:

### 0. [Lab 0: Introduction to Automation](./00-intro-to-automation.mdcl)
Understand why automation matters - compare manual vs automated methods.

**Time:** 20 minutes

### 1. [Week 3 Topics](./week3-topics.md)
Quick overview of automation concepts.

**Time:** 10 minutes

### 2. [Lab 1: Simple Cloud-Init](./01-simple-cloud-init.mdcl)
Learn cloud-init with simple examples.

**Time:** 30 minutes

### 3. [Lab 2: Simple Bash Scripts](./02-simple-bash-scripts.mdcl)
Write your first bash scripts.

**Time:** 30 minutes

### 4. [Lab 3: Automated Deployment](./03-automated-deployment.mdcl)
Deploy full infrastructure automatically with custom website.

**Time:** 60 minutes

---

## Prerequisites

- Week 1 & 2 completed
- Hetzner Cloud account
- Domain name
- SSH keys

---

## What You'll Build

The same infrastructure from Week 2, but automated:
- Nginx Proxy Manager
- Code-Server
- SSL certificates
- Firewall configuration

---

## Time Comparison

**Manual (Week 2):**
- Time: 2-3 hours
- Commands: 50+
- Errors: Common

**Automated (Week 3):**
- Time: 20-30 minutes
- Commands: <10
- Errors: Rare

**Savings: 75%+**

---

## Quick Start

1. Start with [Lab 0: Intro to Automation](./00-intro-to-automation.mdcl)
2. Read [week3-topics.md](./week3-topics.md)
3. Do [Lab 1](./01-simple-cloud-init.mdcl)
4. Do [Lab 2](./02-simple-bash-scripts.mdcl)
5. Do [Lab 3](./03-automated-deployment.mdcl)

**Total time:** ~3 hours

---

## Skills You'll Gain

**Technical:**
- Cloud-init configuration
- YAML syntax
- Bash scripting
- Docker automation
- Infrastructure as Code

**Professional:**
- DevOps fundamentals
- Time-saving automation
- Reproducible deployments

---

## Common Issues

**Cloud-init didn't run:**
- Check: `cat /var/log/cloud-init-output.log`

**Docker not installed:**
- Check: `cloud-init status`

**Can't SSH:**
- Verify you added your SSH public key

**SSL fails:**
- Verify DNS points to server

---

## Resources

- [Cloud-Init Docs](https://cloudinit.readthedocs.io/)
- [Bash Guide](https://www.gnu.org/software/bash/manual/)
- [YAML Validator](http://www.yamllint.com/)
- [ShellCheck](https://www.shellcheck.net/) (bash linter)

---

## After Week 3

You'll be ready for:
- Junior DevOps roles
- Cloud engineering positions
- Advanced automation tools (Terraform, Ansible)

---

## Getting Help

**Check logs:**
```bash
# Cloud-init
cat /var/log/cloud-init-output.log

# Docker
docker logs <container-name>

# System
journalctl -xe
```

**Verify status:**
```bash
cloud-init status
docker ps
systemctl status docker
```

---

## Start Here

Begin with: [Lab 0 - Introduction to Automation](./00-intro-to-automation.mdcl)

Good luck! 🚀

---

**Previous:** [Week 2](../week2/)
**Next:** Week 4 - AI Tools
