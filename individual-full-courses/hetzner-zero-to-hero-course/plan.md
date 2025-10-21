Module 0 — Orientation & Fundamentals

Goal: Understand Hetzner Cloud’s ecosystem and account setup.
	•	0.1 — What is Hetzner Cloud? (Architecture, data centers, pricing philosophy)
	•	0.2 — Comparing CX, CPX, CCX, and CAX plans (shared vs dedicated vs Arm64)
	•	0.3 — Account creation, projects, API tokens, and console tour
	•	0.4 — Introducing the Hetzner CLI (hcloud): installation and authentication
	•	Lab 0: Configure your CLI and list all server types and regions

⸻

Module 1 — Deploying and Managing Servers

Goal: Provision and manage compute resources efficiently.
	•	1.1 — Understanding server types and hardware options
	•	1.2 — Deploying via the Hetzner Console
	•	1.3 — Deploying via hcloud CLI (server create, rename, rebuild, delete)
	•	1.4 — Server lifecycle: start, stop, reboot, rescue mode, reinstall
	•	1.5 — Images, snapshots, and rebuilds
	•	Lab 1: Deploy two servers (CX & CAX), compare performance, rebuild one from snapshot

⸻

Module 2 — Networking Essentials

Goal: Build secure, flexible networking topologies.
	•	2.1 — Primary IPs (IPv4/IPv6), cost and management
	•	2.2 — Floating IPs for high availability and failover
	•	2.3 — Private networks (Layer-3) and routing between instances
	•	2.4 — Firewall rules: inbound/outbound restrictions
	•	2.5 — Load balancing basics (Hetzner Load Balancer overview)
	•	Lab 2: Create a private network, attach two servers, assign a floating IP, and test connectivity

⸻

Module 3 — Storage & Data Management

Goal: Understand persistent storage and backup strategies.
	•	3.1 — Root volumes vs attached “Volumes”
	•	3.2 — Creating, attaching, formatting, and mounting Volumes (via Console & CLI)
	•	3.3 — Detaching and re-attaching Volumes safely
	•	3.4 — Volume resizing and snapshotting
	•	3.5 — Backup strategies using Hetzner’s snapshot system
	•	Lab 3: Create a 200 GB volume, mount it, move data, detach, and re-attach to another server

⸻

Module 4 — Security & Access Control

Goal: Apply practical cloud security measures.
	•	4.1 — SSH key management (Console & CLI)
	•	4.2 — Network isolation: private networks & firewalls combined
	•	4.3 — Hardening Linux servers (updates, users, SSH config)
	•	4.4 — Restricting access to the Hetzner Console and API tokens
	•	4.5 — Data protection & GDPR awareness for Hetzner regions
	•	Lab 4: Harden a server, apply a firewall template, and validate isolation

⸻

Module 5 — Scaling & Resource Optimization

Goal: Learn how to adjust resources and manage costs.
	•	5.1 — Rescaling servers (upgrade/downgrade) via Console and CLI
	•	5.2 — Using snapshots to duplicate and scale environments
	•	5.3 — Monitoring and metrics (via Console and hcloud info commands)
	•	5.4 — Labeling and organizing resources for efficient management
	•	5.5 — Cost tracking, billing cycles, and cleaning unused resources
	•	Lab 5: Rescale a running instance, monitor cost changes, and tag all resources

⸻

Module 6 — Advanced Server Operations

Goal: Master operational tools for reliability and automation (without pipelines).
	•	6.1 — Rescue and recovery mode: troubleshooting failed servers
	•	6.2 — Cloud-init and user-data customization (boot-time automation)
	•	6.3 — Console logs and serial console access for debugging
	•	6.4 — Using the Hetzner API only for read-only exploration (no coding)
	•	Lab 6: Enable cloud-init to deploy a custom configuration at boot

⸻

Module 7 — Regional Strategy & Performance Tuning

Goal: Optimize for latency, compliance, and hardware performance.
	•	7.1 — Regional architecture: Germany, Finland, USA, Singapore
	•	7.2 — Choosing Intel, AMD, or Arm64 (CAX) for workloads
	•	7.3 — Benchmarking Hetzner plans (CPU, network, disk I/O)
	•	7.4 — Best practices for multi-region setups and data transfer
	•	Lab 7: Deploy identical servers in two regions and measure latency and throughput

⸻

Module 8 — Administration & Real-World Operations

Goal: Run Hetzner Cloud like a professional operator.
	•	8.1 — Project structure & role-based management (multiple users)
	•	8.2 — Auditing usage and tracking changes
	•	8.3 — Backup rotation and disaster recovery strategy
	•	8.4 — Support requests and incident response with Hetzner
	•	Lab 8: Simulate a full restore from snapshot and validate environment integrity

⸻

Module 9 — Capstone Project

Goal: Build a small production-ready environment using everything learned.

Project brief:
Set up a 2-tier architecture on Hetzner Cloud:
	•	2 × App servers in a private network
	•	1 × Database server with attached volume
	•	1 × Floating IP for front-end failover
	•	1 × Snapshot/restore plan
	•	Hardened and labeled infrastructure