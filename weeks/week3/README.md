# Week 3: Infrastructure Automation

Welcome to Week 3 of BroTech Labs training! This week, you'll learn how to automate the infrastructure deployment you did manually in Week 2.

## Overview

In Week 2, you manually deployed Nginx Proxy Manager and Code-Server by typing commands, creating configuration files, and clicking through web interfaces. While this hands-on approach taught you what happens under the hood, it's time-consuming and error-prone when repeated.

This week, you'll learn to **automate** that entire process using:
- **Cloud-Init** for server initialization
- **Bash scripting** for application deployment

By the end of Week 3, you'll be able to deploy the same infrastructure in ~15 minutes instead of 2-3 hours!

## What You'll Learn

### Core Concepts
- Infrastructure as Code (IaC) principles
- Two-layer automation strategy (OS + Application)
- Idempotent operations
- Configuration management
- Automated SSL/TLS certificate provisioning

### Technical Skills
- Writing cloud-init configurations in YAML
- Bash scripting for infrastructure automation
- Docker Compose automation
- Error handling and validation
- Debugging automation scripts

### Tools & Technologies
- Cloud-Init (industry-standard server initialization)
- Bash scripting (Linux automation)
- Docker & Docker Compose (containerization)
- Nginx Proxy Manager (reverse proxy with SSL)
- Let's Encrypt (free SSL/TLS certificates)
- UFW (Ubuntu firewall)

## Learning Modules

### [Module 1: Introduction to Automation](./01-intro-to-automation.md)
**Time:** 30 minutes (reading)

Learn why automation matters and what you'll accomplish this week.

**Topics:**
- What is automation and why does it matter?
- Types of automation (cloud-init vs bash scripts)
- Real-world benefits and use cases
- Comparison: Manual vs Automated deployment
- Industry relevance and career skills

**Outcomes:**
- Understand the value proposition of automation
- Recognize when to automate vs when to do manually
- Grasp the two-layer automation strategy

### [Module 2: Cloud-Init Explained](./02-cloud-init-explained.mdcl)
**Time:** 1-2 hours (reading + practice)

Deep dive into cloud-init for automated server initialization.

**Topics:**
- What is cloud-init and how does it work?
- YAML syntax fundamentals
- Cloud-init configuration structure
- Package management and user creation
- Firewall configuration
- Writing files and running commands
- Debugging and troubleshooting

**Outcomes:**
- Write cloud-init configurations from scratch
- Understand YAML syntax and structure
- Configure servers automatically on first boot
- Debug cloud-init issues

**Practice Exercises:**
- 3 hands-on exercises building cloud-init configs
- Solutions provided

### [Module 3: Bash Scripting Deep Dive](./03-bash-scripting-deep-dive.mdcl)
**Time:** 2-3 hours (reading + practice)

Learn bash scripting for infrastructure automation.

**Topics:**
- Bash fundamentals (variables, functions, control flow)
- Script structure and organization
- Error handling and strict mode
- Advanced patterns for automation
- Colored output and user experience
- Waiting for services
- Idempotent operations
- Creating configuration files
- Debugging techniques

**Outcomes:**
- Write bash scripts for infrastructure deployment
- Use functions for reusable code
- Implement proper error handling
- Apply automation best practices
- Debug script issues effectively

**Practice Exercises:**
- 3 progressive exercises building automation skills
- Solutions provided

### [Module 4: Automated Deployment Lab](./04-automated-deployment.mdcl)
**Time:** 2-4 hours (hands-on lab)

Put everything together in a complete automated deployment.

**What You'll Deploy:**
- Ubuntu 22.04 server (automated setup with cloud-init)
- Docker and Docker Compose (automated installation)
- Nginx Proxy Manager (automated deployment)
- Code-Server (automated deployment)
- SSL/TLS certificates (automated with Let's Encrypt)
- Firewall (automated configuration)

**Lab Structure:**
1. Understanding the automation stack
2. Preparing cloud-init configuration
3. Creating server with cloud-init
4. Configuring DNS records
5. Running deployment script
6. Verifying deployment
7. Configuring NPM with SSL
8. Accessing Code-Server
9. Understanding the automation
10. Troubleshooting guide
11. Manual vs automated comparison
12. Cleanup

**Outcomes:**
- Deploy complete infrastructure automatically
- Troubleshoot automation issues
- Understand time savings and consistency benefits
- Build confidence in automation skills

## Prerequisites

Before starting Week 3, you should:

✅ **Have completed Week 2** - Understanding what we're automating
✅ **Be comfortable with Linux command line** - Basic file operations, navigation
✅ **Understand Docker basics** - Containers, images, volumes, networks
✅ **Have a Hetzner Cloud account** - For server deployment
✅ **Have a domain name** - For SSL/TLS configuration (can use brotechlabs.com for learning)
✅ **Have SSH keys generated** - For secure server access

## Repository Structure

```
week3/
├── README.md                          # This file
├── week3-topics.md                    # Comprehensive overview
├── 01-intro-to-automation.md          # Introduction to automation
├── 02-cloud-init-explained.mdcl       # Cloud-Init tutorial
├── 03-bash-scripting-deep-dive.mdcl   # Bash scripting guide
├── 04-automated-deployment.mdcl       # Hands-on lab (main project)
├── cloud-init-template.yaml           # Production-ready cloud-init config
└── deploy-infrastructure.sh           # Complete deployment automation script
```

## How to Use This Material

### Recommended Learning Path

**Day 1: Foundations (2-3 hours)**
1. Read [01-intro-to-automation.md](./01-intro-to-automation.md)
2. Review Week 2 materials (refresh what you'll automate)
3. Read [week3-topics.md](./week3-topics.md) for comprehensive overview

**Day 2: Cloud-Init (2-3 hours)**
1. Work through [02-cloud-init-explained.mdcl](./02-cloud-init-explained.mdcl)
2. Complete the 3 practice exercises
3. Review [cloud-init-template.yaml](./cloud-init-template.yaml)
4. Customize the template with your details

**Day 3: Bash Scripting (3-4 hours)**
1. Work through [03-bash-scripting-deep-dive.mdcl](./03-bash-scripting-deep-dive.mdcl)
2. Complete the 3 practice exercises
3. Review [deploy-infrastructure.sh](./deploy-infrastructure.sh)
4. Understand each section of the script

**Day 4-5: Hands-On Lab (4-6 hours)**
1. Complete [04-automated-deployment.mdcl](./04-automated-deployment.mdcl)
2. Deploy infrastructure using automation
3. Troubleshoot any issues
4. Experiment with modifications
5. Clean up resources

**Total Time Investment:** 11-16 hours

### Alternative: Fast Track (6-8 hours)

If you're comfortable with scripting:
1. Skim intro materials (30 min)
2. Review cloud-init template and script (1 hour)
3. Complete automated deployment lab (4-6 hours)
4. Reference other materials as needed

## Key Files Explained

### cloud-init-template.yaml
Production-ready cloud-init configuration that:
- Updates and upgrades Ubuntu packages
- Installs Docker, Docker Compose, and utilities
- Creates admin user with SSH key authentication
- Configures firewall (UFW)
- Sets up Docker networking
- Creates directory structure
- Configures fail2ban for security

**Usage:** Customize variables (SSH key, timezone, domain) and paste into Hetzner's "Cloud config" field when creating a server.

### deploy-infrastructure.sh
Comprehensive bash script that:
- Validates prerequisites (Docker, sudo, etc.)
- Creates Docker networks
- Deploys Nginx Proxy Manager with Docker Compose
- Deploys Code-Server with Docker Compose
- Waits for services to be healthy
- Provides colored, user-friendly output
- Displays final configuration instructions

**Usage:** SSH into your server and run:
```bash
sudo bash deploy-infrastructure.sh
```

## Time Comparison: Manual vs Automated

### Week 2 (Manual) - One Server
| Step | Time |
|------|------|
| Create server | 5 min |
| Update packages | 10 min |
| Install Docker | 15 min |
| Configure firewall | 10 min |
| Set up Docker network | 5 min |
| Create directories | 5 min |
| Write NPM docker-compose.yml | 15 min |
| Deploy NPM | 10 min |
| Write Code-Server docker-compose.yml | 15 min |
| Deploy Code-Server | 10 min |
| Configure DNS | 10 min |
| Configure NPM proxy hosts | 20 min |
| Set up SSL | 10 min |
| **Total** | **~2.5 hours** |

### Week 3 (Automated) - One Server
| Step | Time | Automated? |
|------|------|------------|
| Customize cloud-init (one-time) | 5 min | No |
| Create server with cloud-init | 5 min | Partially |
| Cloud-init runs (wait) | 5 min | Yes |
| SSH in and run script | 2 min | No |
| Script deploys everything (wait) | 8 min | Yes |
| Configure DNS | 10 min | No |
| Configure NPM and SSL | 20 min | No |
| **Total** | **~55 min** | **~13 min automated** |

**Time Saved:** 1 hour 35 minutes (63% reduction)

### For Five Servers
- **Manual:** ~12.5 hours
- **Automated:** ~2 hours (servers deployed in parallel)
- **Time Saved:** 10.5 hours (84% reduction!)

## What Makes This Training Unique

1. **Beginner-Friendly:** Assumes no prior automation experience
2. **Explains Everything:** Every term, acronym, and concept defined
3. **Relates to Manual Work:** Compares to Week 2's manual steps
4. **Production-Ready:** Code you can actually use in real projects
5. **Heavily Commented:** Every line of code explained
6. **Troubleshooting Included:** Common issues and solutions
7. **Practice Exercises:** Hands-on learning with solutions
8. **Industry-Standard Tools:** Skills transfer to all major clouds

## Skills You'll Gain

By completing Week 3, you'll be able to:

✅ Write cloud-init configurations for Ubuntu servers
✅ Automate server initialization with YAML
✅ Write bash scripts for infrastructure deployment
✅ Use Docker Compose for multi-container applications
✅ Implement error handling in automation
✅ Create idempotent operations (safe to run multiple times)
✅ Configure automated SSL/TLS with Let's Encrypt
✅ Debug automation issues effectively
✅ Apply Infrastructure as Code (IaC) principles
✅ Deploy identical infrastructure repeatedly and reliably

## Real-World Applications

These skills apply directly to:

**DevOps Engineering**
- Automated deployment pipelines
- Infrastructure provisioning
- Configuration management
- CI/CD automation

**Cloud Architecture**
- Multi-region deployments
- Disaster recovery
- Auto-scaling configurations
- Infrastructure templates

**Site Reliability Engineering (SRE)**
- Incident response automation
- Service deployment
- System configuration
- Monitoring setup

**System Administration**
- Server fleet management
- Consistent configurations
- Rapid deployment
- Disaster recovery

## Career Relevance

The automation concepts you learn this week are foundational to modern infrastructure roles:

**Entry-Level Roles:**
- Junior DevOps Engineer: $70k-90k
- Cloud Support Engineer: $60k-80k
- Systems Administrator: $55k-75k

**Mid-Level Roles:**
- DevOps Engineer: $90k-130k
- Cloud Engineer: $95k-125k
- Site Reliability Engineer: $100k-140k

**Senior Roles:**
- Senior DevOps Engineer: $130k-180k
- Cloud Architect: $140k-200k
- Principal SRE: $150k-220k

*Salary ranges vary by location, company, and experience.*

## Next Steps After Week 3

Once you've mastered automation fundamentals, you can explore:

**Advanced Automation Tools:**
- **Terraform** - Infrastructure as Code for cloud resources
- **Ansible** - Configuration management and orchestration
- **Packer** - Automated machine image creation
- **GitHub Actions** - CI/CD automation

**Container Orchestration:**
- **Kubernetes** - Container orchestration at scale
- **Docker Swarm** - Docker-native orchestration
- **Nomad** - HashiCorp's orchestrator

**Cloud Platforms:**
- **AWS CloudFormation** - AWS infrastructure automation
- **Google Cloud Deployment Manager** - GCP automation
- **Azure Resource Manager** - Azure automation

## Getting Help

If you get stuck:

1. **Check the troubleshooting sections** in each module
2. **Review the commented code** in template files
3. **Read error messages carefully** - they often explain the issue
4. **Check logs:**
   - Cloud-init: `/var/log/cloud-init-output.log`
   - Docker: `docker logs container-name`
   - System: `journalctl -xe`
5. **Test incrementally** - Don't write everything at once

## Useful Resources

**Cloud-Init:**
- [Official Documentation](https://cloudinit.readthedocs.io/)
- [Cloud-Init Examples](https://cloudinit.readthedocs.io/en/latest/reference/examples.html)
- [Hetzner Cloud-Init Guide](https://community.hetzner.com/tutorials/basic-cloud-config)
- [YAML Validator](https://www.yamllint.com/)

**Bash Scripting:**
- [Bash Guide for Beginners](https://tldp.org/LDP/Bash-Beginners-Guide/html/)
- [ShellCheck](https://www.shellcheck.net/) - Script validator
- [Bash Reference Manual](https://www.gnu.org/software/bash/manual/)
- [Advanced Bash Scripting Guide](https://tldp.org/LDP/abs/html/)

**Docker Automation:**
- [Docker Compose Documentation](https://docs.docker.com/compose/)
- [Docker Best Practices](https://docs.docker.com/develop/dev-best-practices/)
- [Dockerfile Reference](https://docs.docker.com/engine/reference/builder/)

**Infrastructure as Code:**
- [What is IaC?](https://www.redhat.com/en/topics/automation/what-is-infrastructure-as-code-iac)
- [IaC Best Practices](https://www.hashicorp.com/resources/what-is-infrastructure-as-code)
- [The Twelve-Factor App](https://12factor.net/)

**SSL/TLS:**
- [Let's Encrypt Documentation](https://letsencrypt.org/docs/)
- [ACME Protocol](https://tools.ietf.org/html/rfc8555)
- [SSL/TLS Best Practices](https://www.ssl.com/guide/ssl-best-practices/)

## Common Questions

**Q: Do I need to be a programmer?**
A: No! Automation scripting is different from software development. If you can follow recipes and understand logic, you can learn automation.

**Q: What if my automation breaks?**
A: You already know how to do everything manually from Week 2, so you can always fall back. Plus, you'll learn debugging techniques.

**Q: Can I use these skills with other cloud providers?**
A: Absolutely! Cloud-init works with AWS, Google Cloud, Azure, DigitalOcean, and more. Bash scripts work on all Linux systems.

**Q: How long until I'm job-ready?**
A: After Week 3, you'll have foundational automation skills. Add some advanced tools (Terraform, Kubernetes) and build a portfolio of projects, and you could be job-ready in 3-6 months.

**Q: Should I memorize all the bash commands?**
A: No! Focus on understanding concepts and patterns. You can always look up syntax. The automation scripts themselves serve as documentation.

**Q: What's the best way to practice?**
A: Complete the labs, then try to automate other tasks you do regularly. Build your own projects. Break things and fix them - that's how you learn!

## Success Criteria

You'll know you've mastered Week 3 when you can:

✅ Explain the difference between cloud-init and bash scripts
✅ Write a cloud-init config that sets up a server from scratch
✅ Write a bash script that deploys a Docker application
✅ Customize the provided templates for your own use case
✅ Deploy infrastructure in <1 hour that previously took 2-3 hours
✅ Debug automation issues by reading logs
✅ Explain Infrastructure as Code to a beginner
✅ Confidently modify automation scripts
✅ Make your scripts idempotent and error-resistant
✅ Deploy the same infrastructure multiple times consistently

## Ready to Begin?

Start your automation journey:

1. **Read:** [01-intro-to-automation.md](./01-intro-to-automation.md)
2. **Then:** [02-cloud-init-explained.mdcl](./02-cloud-init-explained.mdcl)
3. **Next:** [03-bash-scripting-deep-dive.mdcl](./03-bash-scripting-deep-dive.mdcl)
4. **Finally:** [04-automated-deployment.mdcl](./04-automated-deployment.mdcl)

Remember: automation might seem complex at first, but you're building skills that will save you hundreds of hours throughout your career. Every professional infrastructure engineer uses these techniques daily.

**Let's turn you into an automation expert! 🚀**

---

**Previous Week:** [Week 2 - Manual Infrastructure Deployment](../week2/)
**Next Week:** Week 4 - AI and Modern Development Tools

---

*BroTech Labs Training - Infrastructure Automation*
*Version 2.0 - 2025*
