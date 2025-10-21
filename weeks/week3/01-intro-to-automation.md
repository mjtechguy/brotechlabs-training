# Introduction to Infrastructure Automation

## Welcome to Week 3!

In Week 2, you manually set up your infrastructure step by step. You logged into servers, typed commands, configured services, and clicked through web interfaces. While this hands-on approach is excellent for learning what's happening under the hood, it has some significant limitations when working in the real world.

This week, we're going to learn how to **automate** that same infrastructure deployment, making it faster, more reliable, and easier to repeat.

## What is Automation?

**Automation** means using scripts, tools, or code to perform tasks that you would otherwise do manually. Instead of typing commands one by one, you write down all those commands in a file, and then the computer executes them for you.

Think of it like this:
- **Manual work** = Following a recipe and measuring each ingredient by hand
- **Automation** = Using a bread machine where you add ingredients and press "start"

Both get you bread, but automation is:
- Faster (once set up)
- More consistent (no forgetting steps)
- Repeatable (can make the same bread 100 times)
- Scalable (can make multiple loaves simultaneously)

## Why Automate Infrastructure?

### 1. **Speed**
What took you 2-3 hours in Week 2 can take 10-15 minutes with automation. And if you need to deploy 5 servers? Manual would take 10-15 hours, automated still takes about 15 minutes.

### 2. **Consistency**
When you type commands manually, it's easy to:
- Forget a step
- Make a typo
- Configure things slightly differently each time
- Skip security hardening because you're tired

Automation runs the exact same way every time.

### 3. **Documentation**
Your automation scripts become **living documentation** of how your infrastructure is built. New team members can read the scripts to understand the setup. Six months later, you can remember exactly what you did.

### 4. **Version Control**
Because automation is just files, you can:
- Track changes over time with Git
- Roll back to previous versions
- See who changed what and when
- Collaborate with others

### 5. **Disaster Recovery**
If your server crashes or gets compromised, you can rebuild it in minutes rather than hours or days. Your automation scripts are your backup plan.

### 6. **Reduced Human Error**
Humans make mistakes, especially when doing repetitive tasks. Computers don't get tired, distracted, or bored.

## Real-World Example

Let's say you work for a company that needs to deploy the same web application for 20 different customers, each on their own server.

**Manual Approach:**
- 3 hours per server × 20 servers = 60 hours of work
- High chance of inconsistencies between deployments
- Difficult to track which server has which configuration
- Any mistake needs to be fixed 20 times

**Automated Approach:**
- Write automation once (maybe 4-6 hours)
- Deploy 20 servers in parallel (15-20 minutes each)
- Total time: ~6.5 hours (vs 60 hours)
- All servers identical
- Easy to update all 20 servers when needed
- Mistakes fixed once in the script, then redeploy

**Time saved:** 53.5 hours (89% reduction!)

## Types of Automation We'll Learn

In Week 3, we'll focus on two complementary automation approaches:

### 1. **Cloud-Init** (Server Initialization)
- Runs **once** when a server is first created
- Handles operating system-level setup
- Think: "Setup wizard for servers"

**What Cloud-Init Does:**
- Updates the operating system
- Installs software packages (Docker, Git, etc.)
- Creates users and SSH keys
- Configures firewalls
- Sets up networks
- One-time initialization tasks

**Analogy:** Cloud-init is like the factory setup when you first turn on a new phone - it runs once to get everything ready.

### 2. **Bash Scripts** (Application Deployment)
- Can run **multiple times**
- Handles application and service deployment
- Think: "Recipe for deploying applications"

**What Bash Scripts Do:**
- Deploy Docker containers
- Configure applications
- Set up databases
- Create configuration files
- Tasks you might repeat or update

**Analogy:** Bash scripts are like installing apps on your phone - you can do it as many times as needed.

## The Two-Layer Automation Strategy

We use both tools together for a complete automation solution:

```
┌─────────────────────────────────────────┐
│         CLOUD-INIT (Layer 1)            │
│  Run once at server creation            │
│  • OS updates                           │
│  • Package installation (Docker, etc.)  │
│  • User creation                        │
│  • Firewall setup                       │
│  • SSH configuration                    │
└─────────────────────────────────────────┘
                    ↓
┌─────────────────────────────────────────┐
│      BASH SCRIPT (Layer 2)              │
│  Run when you're ready to deploy        │
│  • Deploy applications                  │
│  • Configure services                   │
│  • Set up databases                     │
│  • Create configurations                │
└─────────────────────────────────────────┘
```

**Why two layers?**

1. **Cloud-Init** handles the foundation that never changes
2. **Bash Scripts** handle applications that might be updated or changed
3. Separating concerns makes troubleshooting easier
4. You can update application deployment without recreating the server

## What You'll Build This Week

By the end of Week 3, you'll have:

1. **A cloud-init configuration** that automatically:
   - Installs Docker and Docker Compose
   - Creates an admin user with your SSH key
   - Configures the firewall (UFW - Uncomplicated Firewall)
   - Sets up Docker networking
   - Prepares directory structure

2. **A bash deployment script** that automatically:
   - Deploys Nginx Proxy Manager
   - Deploys Code-Server (VS Code in browser)
   - Configures health checks
   - Sets up SSL/TLS certificates with Let's Encrypt
   - Verifies everything is working

3. **The same infrastructure as Week 2**, but deployed in a fraction of the time with zero manual configuration steps!

## Automation Mindset

As you learn automation, adopt this mindset:

### "If I do it twice, I automate it"

The first time you do something, do it manually and take notes. The second time, write a script. The third time, just run the script.

### "Make it work, make it better"

Don't try to write perfect automation from the start. Get something working, then improve it:
1. **Make it work** - Basic script that does the job
2. **Make it safe** - Add error checking and validation
3. **Make it maintainable** - Add comments and documentation
4. **Make it reusable** - Use variables and functions

### "Automation is documentation"

Well-written automation scripts are better than documentation because they:
- Can't get out of date (they're what actually runs)
- Show exactly what happens
- Can be tested to verify they work

## Key Terms You'll Learn

**IaC (Infrastructure as Code):** Treating infrastructure configuration like software code - written in files, version controlled, tested, and automated.

**Idempotent:** An operation that produces the same result whether you run it once or multiple times. Example: "Install Docker" is idempotent - running it twice doesn't break anything.

**YAML (YAML Ain't Markup Language):** A human-readable data format used for configuration files. Cloud-init uses YAML.

**Shell/Bash:** The command-line interface for Linux. Bash (Bourne Again Shell) is the most common shell.

**SSH (Secure Shell):** Encrypted protocol for remote server access. This is how you connect to your server securely.

**UFW (Uncomplicated Firewall):** Ubuntu's user-friendly firewall tool that makes it easy to control network access.

**ACME Protocol:** Automated Certificate Management Environment - the protocol Let's Encrypt uses to issue SSL/TLS certificates automatically.

We'll explain all of these in detail as we encounter them!

## How This Week is Structured

### Module 1: Introduction to Automation (You Are Here!)
Understanding why automation matters and what we'll build.

### Module 2: Cloud-Init Explained
Deep dive into cloud-init: what it is, how it works, and how to write cloud-init configurations.

### Module 3: Bash Scripting Fundamentals
Learn bash scripting from scratch: variables, functions, error handling, and automation patterns.

### Module 4: Automated Deployment Lab
Hands-on lab where you deploy the same Week 2 infrastructure using automation.

## Comparison: Manual vs Automated

Let's preview what you'll experience:

### Week 2 (Manual Deployment)

**Steps:**
1. Create server (5 minutes)
2. SSH in and update packages (10 minutes)
3. Install Docker (15 minutes)
4. Configure firewall manually (10 minutes)
5. Create Docker network manually (5 minutes)
6. Create directories manually (5 minutes)
7. Write NPM docker-compose.yml manually (15 minutes)
8. Deploy NPM (10 minutes)
9. Write Code-Server docker-compose.yml manually (15 minutes)
10. Deploy Code-Server (10 minutes)
11. Configure DNS records (10 minutes)
12. Configure NPM proxy hosts manually (20 minutes)
13. Set up SSL certificates manually (10 minutes)

**Total Time:** ~2.5 hours for one server
**Human Interaction:** Required for all 13 steps

### Week 3 (Automated Deployment)

**Steps:**
1. Customize cloud-init config (5 minutes, one-time)
2. Create server with cloud-init (5 minutes, automatic)
3. Wait for cloud-init to complete (5 minutes, automatic)
4. SSH in and run deployment script (2 minutes)
5. Wait for deployments (8 minutes, automatic)
6. Configure DNS records (10 minutes)
7. Configure NPM proxy hosts and SSL (20 minutes, could be automated later)

**Total Time:** ~55 minutes for one server
**Human Interaction:** Required for steps 1, 4, 6, 7 only
**Time Saved:** 1 hour 35 minutes (63% reduction)

**And for deploying 5 servers?**
- Manual: ~12.5 hours
- Automated: ~2 hours
- Time saved: 10.5 hours (84% reduction!)

## Prerequisites

Before starting Week 3, you should have:

1. **Completed Week 2** - You need to understand what we're automating
2. **Basic Linux familiarity** - Comfortable with command line
3. **Understanding of Docker basics** - What containers and images are
4. **A Hetzner Cloud account** - Where you'll deploy servers
5. **A domain name** - For SSL/TLS configuration (can use brotechlabs.com for learning)

## What You'll Gain

By the end of Week 3, you will be able to:

✅ Explain the benefits of infrastructure automation
✅ Write cloud-init configurations for Ubuntu servers
✅ Understand YAML syntax and structure
✅ Write bash scripts with functions, variables, and error handling
✅ Implement idempotent automation patterns
✅ Automate Docker and Docker Compose deployments
✅ Set up automated SSL/TLS certificate management
✅ Debug and troubleshhooting automation scripts
✅ Apply Infrastructure as Code principles
✅ Deploy identical infrastructure repeatedly and reliably

## Industry Relevance

The skills you'll learn this week are fundamental to modern DevOps and cloud engineering:

- **DevOps Engineers** automate infrastructure daily
- **Cloud Architects** design automated deployment pipelines
- **Site Reliability Engineers (SREs)** use automation for scaling and reliability
- **System Administrators** are transitioning from manual work to automation
- **Software Developers** increasingly need to understand infrastructure automation

Tools like **Terraform**, **Ansible**, **Kubernetes**, and **GitHub Actions** all build on the same concepts you'll learn this week. Master these fundamentals, and you'll be prepared to learn those advanced tools.

## Getting Started

Ready to dive in? Here's your learning path:

1. **Read this introduction** ✅ (You're here!)
2. **Review Week 2 materials** - Refresh your memory on what you built
3. **Study Cloud-Init Explained** - Understand how server initialization works
4. **Learn Bash Scripting Fundamentals** - Build your scripting skills
5. **Complete the Automated Deployment Lab** - Put it all together hands-on

## Common Questions

**Q: Is automation harder to learn than doing things manually?**
A: There's an initial learning curve, but once you understand the patterns, automation is easier and faster. Think of it like learning to ride a bike - hard at first, but then much faster than walking.

**Q: What if my automation breaks?**
A: That's why we test! You'll learn to validate and troubleshoot automation. Plus, you already know how to do everything manually from Week 2, so you can always fall back.

**Q: Do I need to be a programmer?**
A: No! Automation scripting is different from software development. You'll write scripts that are more like "recipes" than complex programs.

**Q: Can I automate absolutely everything?**
A: Almost! Some tasks require human judgment (like choosing domain names or reviewing security settings), but 80-90% of infrastructure deployment can be automated.

**Q: What if I want to make changes later?**
A: That's the beauty of IaC! You update your scripts, test them, and redeploy. Your scripts are your "source of truth."

## Useful Resources

As you work through Week 3, these resources will help:

**Cloud-Init:**
- [Cloud-Init Official Documentation](https://cloudinit.readthedocs.io/)
- [Cloud-Init Examples](https://cloudinit.readthedocs.io/en/latest/reference/examples.html)
- [Hetzner Cloud-Init Guide](https://community.hetzner.com/tutorials/basic-cloud-config)

**Bash Scripting:**
- [Bash Guide for Beginners](https://tldp.org/LDP/Bash-Beginners-Guide/html/)
- [ShellCheck](https://www.shellcheck.net/) - Validates bash scripts
- [Bash Reference Manual](https://www.gnu.org/software/bash/manual/)

**YAML:**
- [YAML Syntax Tutorial](https://docs.ansible.com/ansible/latest/reference_appendices/YAMLSyntax.html)
- [YAML Validator](https://www.yamllint.com/)

**Docker Automation:**
- [Docker Compose Documentation](https://docs.docker.com/compose/)
- [Docker Best Practices](https://docs.docker.com/develop/dev-best-practices/)

**Infrastructure as Code:**
- [What is Infrastructure as Code?](https://www.redhat.com/en/topics/automation/what-is-infrastructure-as-code-iac)
- [IaC Best Practices](https://www.hashicorp.com/resources/what-is-infrastructure-as-code)

## Let's Begin!

You've now got the foundation to understand why automation matters and what you'll accomplish this week.

In the next module, we'll dive deep into **Cloud-Init**, learning how to write configurations that set up servers automatically from the moment they boot.

Remember: automation might seem complex at first, but you're building skills that will save you hundreds of hours in your career. Every professional infrastructure engineer uses these techniques daily.

Let's turn you into an automation expert! 🚀

---

**Next:** [02 - Cloud-Init Explained](./02-cloud-init-explained.mdcl)
