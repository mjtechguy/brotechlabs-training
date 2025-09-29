# IT Technical Guide for Beginners

A comprehensive guide for those entering IT tech support, cloud computing, and DevOps work.

## Table of Contents

1. [Fundamental Concepts](#fundamental-concepts)
2. [Hardware Fundamentals](#hardware-fundamentals)
3. [Operating Systems](#operating-systems)
4. [Networking Basics](#networking-basics)
5. [Command Line Essentials](#command-line-essentials)
6. [Version Control](#version-control)
7. [Cloud Computing](#cloud-computing)
8. [Virtualization Basics](#virtualization-basics)
9. [Remote Support Tools and VPN](#remote-support-tools-and-vpn)
10. [DevOps Fundamentals](#devops-fundamentals)
11. [Security Basics](#security-basics)
12. [Troubleshooting Methodology](#troubleshooting-methodology)
13. [Common Tools](#common-tools)

---

## Fundamental Concepts

### What is IT?

**Information Technology (IT)** encompasses all aspects of managing and processing information using computers, networks, and software systems.

### Key IT Roles

- **Tech Support**: Assists users with technical issues, troubleshooting software/hardware problems
- **System Administrator**: Manages servers, networks, and infrastructure
- **DevOps Engineer**: Bridges development and operations, automating deployment and infrastructure
- **Cloud Engineer**: Manages cloud-based infrastructure and services

### Basic Computer Architecture

- **CPU (Central Processing Unit)**: The "brain" that executes instructions
- **RAM (Random Access Memory)**: Temporary storage for active processes
- **Storage (HDD/SSD)**: Permanent data storage
- **Motherboard**: Connects all components together
- **Network Interface Card (NIC)**: Enables network connectivity

---

## Hardware Fundamentals

Understanding hardware is essential for IT support, troubleshooting, and making informed purchasing decisions.

### Storage Types

#### HDD (Hard Disk Drive)
**Traditional spinning disk storage**

**How it works:**
- Mechanical spinning platters with magnetic coating
- Read/write head moves across platters to access data
- Similar to a record player

**Characteristics:**
- **Speed**: Slower (80-160 MB/s typical)
- **Capacity**: Large (1TB - 20TB+)
- **Cost**: Cheapest per GB (~$0.02-0.03/GB)
- **Durability**: Fragile, susceptible to physical shock
- **Noise**: Audible spinning and clicking
- **Lifespan**: 3-5 years average

**Best for:**
- Bulk storage (media libraries, backups)
- Budget builds
- Secondary storage
- NAS/file servers where capacity matters more than speed

**Common sizes:**
- Desktop: 3.5-inch
- Laptop: 2.5-inch

#### SSD (Solid State Drive)
**Flash memory storage with no moving parts**

**How it works:**
- Electronic flash memory chips
- No mechanical components
- Data stored in NAND flash cells

**Characteristics:**
- **Speed**: Fast (400-550 MB/s for SATA)
- **Capacity**: Medium (250GB - 4TB common)
- **Cost**: Moderate (~$0.08-0.15/GB)
- **Durability**: Resistant to physical shock
- **Noise**: Silent
- **Lifespan**: 5-7 years, limited write cycles (but high enough for most users)

**Best for:**
- Operating system drive
- Applications
- Gaming
- Laptops (no moving parts = better battery life)
- Any situation where speed matters

**Interfaces:**
- SATA (same connector as HDD)
- M.2 (smaller form factor, faster)

#### NVMe (Non-Volatile Memory Express)
**Newest, fastest SSD technology**

**How it works:**
- SSD that uses PCIe interface instead of SATA
- Direct connection to CPU via PCIe lanes
- Significantly faster than SATA SSDs

**Characteristics:**
- **Speed**: Very fast (1,500-7,000+ MB/s)
- **Capacity**: Medium to large (500GB - 4TB)
- **Cost**: Higher than SATA SSD (~$0.10-0.20/GB)
- **Form factor**: Usually M.2 slot
- **Heat**: Can get hot under heavy load (may need heatsink)

**Best for:**
- High-performance workstations
- Content creation (video editing, 3D rendering)
- Gaming (fastest load times)
- Servers with heavy I/O requirements
- Professional applications

**Generations:**
- NVMe Gen 3: ~3,500 MB/s
- NVMe Gen 4: ~7,000 MB/s
- NVMe Gen 5: ~14,000 MB/s (newest)

#### Storage Comparison Table

| Type | Speed | Capacity | Cost/GB | Durability | Best Use |
|------|-------|----------|---------|------------|----------|
| **HDD** | 80-160 MB/s | 1-20TB | $0.02-0.03 | Fragile | Bulk storage, backups |
| **SATA SSD** | 400-550 MB/s | 250GB-4TB | $0.08-0.15 | Excellent | OS, applications |
| **NVMe SSD** | 1,500-7,000+ MB/s | 500GB-4TB | $0.10-0.20 | Excellent | High performance |

**IT Support Tip:**
- Upgrading from HDD to SSD is the single most impactful performance improvement for older computers
- Always install OS on SSD, use HDD for bulk storage
- Check if motherboard has M.2 slot before buying NVMe

### RAM (Random Access Memory)

**What is RAM?**
Temporary, fast storage that holds data currently being used by CPU and applications.

**How RAM Works:**
- Active programs and data loaded into RAM from storage
- CPU accesses RAM directly (much faster than storage)
- Data lost when power is off (volatile)
- More RAM = more programs can run simultaneously

**RAM Types:**
- **DDR3**: Older (2007), still in older systems
- **DDR4**: Current standard (2014), most common
- **DDR5**: Newest (2021), faster but more expensive

**RAM is NOT interchangeable** - Must match motherboard support

**RAM Specifications:**
- **Capacity**: 4GB, 8GB, 16GB, 32GB, 64GB+ per stick
- **Speed**: Measured in MHz (e.g., 3200MHz, 3600MHz)
- **Channels**: Dual-channel (2 sticks) performs better than single-channel

**How Much RAM Do You Need?**
- **4GB**: Bare minimum (very basic tasks, outdated)
- **8GB**: Entry-level (web browsing, office work, light multitasking)
- **16GB**: Sweet spot (gaming, moderate workloads, multitasking)
- **32GB**: Professional work (video editing, VMs, heavy development)
- **64GB+**: Specialized (3D rendering, large datasets, many VMs)

**RAM vs Storage:**
```
Storage (HDD/SSD) = Long-term memory (your brain's long-term memories)
RAM = Short-term memory (what you're thinking about right now)
```

**Common RAM Issues:**
- System slowdown when RAM is full (uses slower swap/page file on disk)
- Blue screens/crashes (faulty RAM)
- Programs won't open (insufficient RAM)

**Check RAM Usage:**
```bash
# Linux
free -h
htop

# Windows
Task Manager → Performance → Memory

# macOS
Activity Monitor → Memory
```

### CPU (Central Processing Unit)

**What is a CPU?**
The "brain" of the computer that executes instructions and performs calculations.

**Key CPU Concepts:**

#### Cores
- Individual processing units within a CPU
- Each core can handle separate tasks simultaneously
- More cores = better multitasking and parallel processing
- **Dual-core**: 2 cores (basic)
- **Quad-core**: 4 cores (common)
- **Hexa-core**: 6 cores
- **Octa-core**: 8 cores
- **12-core, 16-core, 24-core+**: Workstation/server CPUs

#### Threads
- Virtual cores created by hyperthreading/SMT (Simultaneous Multithreading)
- Allows one physical core to handle two instruction streams
- Example: 6-core CPU with hyperthreading = 12 threads
- Not as powerful as real cores, but improves efficiency

#### Clock Speed (GHz)
- How many cycles per second the CPU can execute
- Measured in GHz (gigahertz)
- Higher = faster, but not the only factor
- Typical range: 2.5 GHz - 5.0 GHz
- **Base clock**: Normal operating speed
- **Boost clock**: Maximum speed under load (turbo boost)

#### CPU Architecture
- **x86/x64 (Intel/AMD)**: Standard for desktops/servers
- **ARM**: Mobile devices, newer Apple Silicon (M1/M2/M3)
- Different architectures can't run same software without emulation

**CPU Comparison:**
```
Gaming: High clock speed (4.5+ GHz) + moderate cores (6-8)
Video Editing: Many cores (12-16+) + good clock speed
Office Work: Moderate everything (4 cores, 3 GHz fine)
Servers: Many cores (16-64+), moderate clock speed
```

**Major CPU Manufacturers:**
- **Intel**: Core i3, i5, i7, i9 (consumer), Xeon (server)
- **AMD**: Ryzen 3, 5, 7, 9 (consumer), EPYC (server)
- **Apple**: M1, M2, M3, M4 (ARM-based)

**Check CPU Info:**
```bash
# Linux
lscpu
cat /proc/cpuinfo

# Windows
Task Manager → Performance → CPU
wmic cpu get name

# macOS
sysctl -n machdep.cpu.brand_string
```

### Peripheral Interfaces

#### USB (Universal Serial Bus)

**USB Versions and Speeds:**
- **USB 2.0**: 480 Mbps (60 MB/s) - Older standard, still common
- **USB 3.0/3.1 Gen 1**: 5 Gbps (625 MB/s) - Blue port
- **USB 3.1 Gen 2**: 10 Gbps (1,250 MB/s)
- **USB 3.2**: 20 Gbps (2,500 MB/s)
- **USB 4**: 40 Gbps (5,000 MB/s) - Newest

**USB Connector Types:**
- **USB-A**: Standard rectangular connector (most common)
- **USB-B**: Square connector (printers, older devices)
- **USB-C**: Reversible, newer devices, supports USB 4
- **Micro-USB**: Small, older Android phones
- **Mini-USB**: Older standard, mostly obsolete

**USB-C vs USB-A:**
- USB-C is the connector shape
- Can carry USB 2.0, 3.0, 3.1, 3.2, or 4 speeds
- Also supports Thunderbolt, DisplayPort, charging
- Reversible (no wrong way to plug in)

#### Thunderbolt
- High-speed interface developed by Intel/Apple
- Uses USB-C connector (looks identical)
- **Thunderbolt 3**: 40 Gbps
- **Thunderbolt 4**: 40 Gbps (more features, better requirements)
- Can daisy-chain up to 6 devices
- Supports external GPUs, high-resolution displays
- More expensive than regular USB-C

#### Display Connections

**HDMI (High-Definition Multimedia Interface)**
- Most common for consumer displays
- Carries both video and audio
- Versions: 1.4, 2.0, 2.1 (support different resolutions/refresh rates)
- **HDMI 2.0**: 4K @ 60Hz
- **HDMI 2.1**: 4K @ 120Hz, 8K @ 60Hz

**DisplayPort**
- Common on monitors and graphics cards
- Often better than HDMI for PC gaming
- Supports daisy-chaining multiple monitors
- **DisplayPort 1.4**: 4K @ 120Hz, 8K @ 60Hz
- **DisplayPort 2.0**: 8K @ 85Hz, 4K @ 240Hz
- Mini DisplayPort: Smaller version (older MacBooks)

**VGA (Video Graphics Array)**
- Legacy analog connection (blue connector)
- Only carries video (no audio)
- Low resolution support
- Still found on older projectors and monitors
- Being phased out

**DVI (Digital Visual Interface)**
- Older digital connection
- Video only (no audio)
- White connector
- Largely replaced by HDMI/DisplayPort

**Connection Priority for Quality:**
DisplayPort > HDMI > DVI > VGA

### Power Supply Efficiency

**80 Plus Ratings:**
- Certification for power supply efficiency
- Higher efficiency = less wasted power as heat
- **80 Plus**: 80% efficient
- **80 Plus Bronze**: 82-85% efficient
- **80 Plus Silver**: 85-88% efficient
- **80 Plus Gold**: 87-90% efficient (sweet spot)
- **80 Plus Platinum**: 89-92% efficient
- **80 Plus Titanium**: 90-94% efficient

**Wattage Calculation:**
- CPU: 65-150W typical (high-end can be 200W+)
- GPU: 150-450W (high-end gaming/AI)
- Other components: ~100W
- **Recommended**: Total wattage × 1.25 (25% headroom)

---

## Operating Systems

### What is an Operating System?

An **Operating System (OS)** is software that manages hardware resources and provides services for applications.

### Major Operating Systems

#### Linux
- **Distribution (Distro)**: A specific version of Linux (Ubuntu, CentOS, Debian, Fedora)
- **Open-source**: Code is publicly available and free
- **Common in servers**: Most web servers and cloud instances run Linux
- **Package Manager**: Tool to install software (apt, yum, dnf)

#### Windows
- **Proprietary**: Owned by Microsoft
- **Common in enterprise**: Dominant in corporate desktop environments
- **Active Directory**: Centralized user/computer management system
- **PowerShell**: Advanced scripting and automation tool

#### macOS
- **Unix-based**: Built on Unix foundations (similar to Linux)
- **Common in development**: Popular among developers and creative professionals

### File System Hierarchy

**Linux/Unix**:
- `/` - Root directory (top level)
- `/home` - User home directories
- `/etc` - Configuration files
- `/var` - Variable data (logs, databases)
- `/tmp` - Temporary files
- `/usr` - User programs and utilities
- `/opt` - Optional third-party software

**Windows**:
- `C:\` - Primary drive
- `C:\Users` - User profiles
- `C:\Program Files` - Installed applications
- `C:\Windows` - OS files

---

## Networking Basics

### Core Concepts

#### IP Address
A unique identifier for devices on a network.
- **IPv4**: 192.168.1.100 (four octets, 0-255)
- **IPv6**: 2001:0db8:85a3:0000:0000:8a2e:0370:7334 (newer, longer format)

#### Subnet Mask
Defines which portion of an IP address is the network vs. host.
- Example: 255.255.255.0 (or /24 in CIDR notation)

#### CIDR (Classless Inter-Domain Routing)
Notation for IP ranges: `192.168.1.0/24` means 256 addresses (192.168.1.0 - 192.168.1.255)

#### Gateway/Router
Device that connects networks and routes traffic between them.
- **Default Gateway**: The IP address of the router that connects your local network to other networks
- Example: If your IP is 192.168.1.100, your gateway might be 192.168.1.1
- All traffic destined for outside your local network goes through the gateway

#### DNS (Domain Name System)
The "phone book" of the internet - translates human-readable domain names to IP addresses.

**How DNS Works:**
1. You type "google.com" in your browser
2. Your computer asks DNS server: "What's the IP for google.com?"
3. DNS server responds: "142.250.185.78"
4. Your computer connects to that IP address

**DNS Components:**
- **Domain Name**: Human-readable address (example.com)
- **DNS Server**: Computer that stores DNS records and answers queries
- **DNS Record Types**:
  - **A Record**: Maps domain to IPv4 address (example.com → 192.0.2.1)
  - **AAAA Record**: Maps domain to IPv6 address
  - **CNAME Record**: Alias pointing to another domain (www.example.com → example.com)
  - **MX Record**: Mail server for domain
  - **TXT Record**: Text information (often for verification)
  - **NS Record**: Nameserver for domain

**DNS Hierarchy:**
```
. (root)
  └── .com (TLD - Top Level Domain)
      └── google.com (Second Level Domain)
          └── mail.google.com (Subdomain)
```

**Common DNS Servers:**
- **8.8.8.8 / 8.8.4.4**: Google Public DNS
- **1.1.1.1 / 1.0.0.1**: Cloudflare DNS (fast and privacy-focused)
- **208.67.222.222 / 208.67.220.220**: OpenDNS

**DNS Propagation:**
- Time it takes for DNS changes to spread across the internet
- Usually 24-48 hours, but often faster
- Affected by TTL (Time To Live) settings

**DNS Cache:**
- Your computer and DNS servers cache (remember) DNS lookups
- Speeds up repeat visits
- Can cause issues when DNS changes - may need to flush cache

**Flush DNS Cache:**
```bash
# Windows
ipconfig /flushdns

# macOS
sudo dscacheutil -flushcache; sudo killall -HUP mDNSResponder

# Linux
sudo systemd-resolve --flush-caches  # systemd-resolved
sudo service nscd restart             # nscd
```

#### DHCP (Dynamic Host Configuration Protocol)
Automatically assigns IP addresses and network configuration to devices.

**Without DHCP (Manual Configuration):**
- You'd manually set IP address, subnet mask, gateway, DNS servers on every device
- Risk of IP conflicts (two devices with same IP)
- Time-consuming and error-prone

**With DHCP (Automatic):**
- Device connects to network
- Sends broadcast: "I need an IP address!"
- DHCP server responds: "Here's 192.168.1.50, use gateway 192.168.1.1, DNS 8.8.8.8"
- Device configured automatically

**DHCP Process (DORA):**
1. **Discover**: Client broadcasts request for IP
2. **Offer**: DHCP server offers an IP address
3. **Request**: Client requests the offered IP
4. **Acknowledge**: Server confirms and assigns the IP

**What DHCP Provides:**
- **IP Address**: Unique address for the device
- **Subnet Mask**: Network configuration
- **Default Gateway**: Router address
- **DNS Servers**: Where to resolve domain names
- **Lease Time**: How long the IP is assigned (e.g., 24 hours)
- **Other options**: NTP servers, domain name, etc.

**DHCP Lease:**
- IP address is "leased" not permanently assigned
- When lease expires, device must renew
- Device typically renews at 50% of lease time
- If device leaves network, IP returns to pool for others to use

**DHCP Scope/Pool:**
- Range of IP addresses DHCP can assign
- Example: 192.168.1.100 - 192.168.1.200 (100 addresses available)

**DHCP Reservation:**
- Assigns same IP to specific device every time (based on MAC address)
- Useful for servers, printers, network devices
- Device still gets IP automatically, but it's always the same one

**Static IP vs DHCP:**
- **Static IP**: Manually configured, never changes (good for servers)
- **Dynamic IP (DHCP)**: Automatically assigned, can change (good for user devices)

**Common DHCP Commands:**
```bash
# Release current IP (Windows)
ipconfig /release

# Request new IP (Windows)
ipconfig /renew

# Release current IP (Linux)
sudo dhclient -r

# Request new IP (Linux)
sudo dhclient

# View DHCP lease info (Windows)
ipconfig /all

# View DHCP lease info (Linux)
cat /var/lib/dhcp/dhclient.leases
```

#### Domain Names and Registration

**What is a Domain Name?**
A domain name is a human-readable address for a website (like google.com instead of 142.250.185.78).

**Domain Name Structure:**
```
https://blog.example.com
  |      |     |      └── TLD (Top-Level Domain)
  |      |     └────────── Second-Level Domain (SLD)
  |      └──────────────── Subdomain
  └─────────────────────── Protocol
```

**Domain Components:**
- **Protocol**: http:// or https:// (how to access)
- **Subdomain**: www, blog, shop, mail (optional prefix)
- **Second-Level Domain**: example (your chosen name)
- **Top-Level Domain**: .com, .org, .net, .io, .dev (the extension)

**Types of Top-Level Domains (TLDs):**
- **Generic TLDs (gTLD)**: .com, .net, .org, .info, .biz
- **Country Code TLDs (ccTLD)**: .us, .uk, .de, .ca, .jp
- **New gTLDs**: .tech, .io, .dev, .app, .cloud (hundreds available)

**Popular TLDs and Their Use:**
- **.com**: Commercial, most popular, suitable for anything
- **.org**: Organizations, non-profits
- **.net**: Networks, tech companies
- **.io**: Tech startups, input/output reference
- **.dev**: Developers, tech projects
- **.co**: Alternative to .com
- **.app**: Mobile/web applications
- **.ai**: AI companies, Armenia country code

**Domain Registration Process:**
1. Choose a domain name
2. Check availability at registrar (like Namecheap, Google Domains, Cloudflare)
3. Purchase domain (yearly fee, usually $10-15 for .com)
4. Configure nameservers (point to DNS provider)
5. Set up DNS records (A, CNAME, MX, etc.)
6. Domain becomes active (can take minutes to hours)

**Domain Registrar vs DNS Provider:**
- **Registrar**: Where you buy the domain (Namecheap, GoDaddy, Cloudflare)
- **DNS Provider**: Where you manage DNS records (can be same or different)
- You can buy domain at one place, use DNS at another

**Important Domain Settings:**
- **Nameservers**: Tell the internet where to find DNS records for your domain
- **Auto-renewal**: Prevent domain from expiring
- **Domain Lock**: Prevents unauthorized transfers
- **WHOIS Privacy**: Hides your personal info from public WHOIS database

**Domain Costs:**
- **Registration**: $10-15/year for .com (varies by TLD)
- **Renewal**: Usually same as registration, sometimes higher
- **Transfer**: Often free or includes 1 year extension
- **Premium domains**: Already owned, resold for higher prices

**Subdomains:**
- Free once you own the domain
- Create as many as you want: blog.example.com, shop.example.com, api.example.com
- Configured through DNS records, no additional registration needed

**Domain Transfer:**
- Moving domain from one registrar to another
- Requires unlock code (EPP/Auth code)
- Usually takes 5-7 days
- Often includes 1-year extension

**Domain Expiration:**
- Domain expires if not renewed
- Grace period: 30-45 days to renew at regular price
- Redemption period: 30 days, can renew at higher price
- After redemption: Domain released, anyone can buy it
- **Always enable auto-renewal for important domains!**

#### MAC Address

**What is a MAC Address?**
A **MAC (Media Access Control) address** is a unique hardware identifier assigned to every network interface.

**Format:**
- 48-bit address: 6 pairs of hexadecimal digits
- Example: `00:1B:44:11:3A:B7` or `00-1B-44-11-3A-B7`
- Also written as: `001b.4411.3ab7`

**Characteristics:**
- **Unique**: Every network card has a different MAC address (supposed to be globally unique)
- **Physical**: Burned into hardware by manufacturer
- **Layer 2**: Operates at Data Link layer (unlike IP which is Layer 3)
- **Local**: Only used within the same network segment

**OUI (Organizationally Unique Identifier):**
- First 3 bytes identify manufacturer
- Example: `00:1B:44` might be Cisco
- Last 3 bytes are device-specific

**Uses of MAC Address:**
- **ARP (Address Resolution Protocol)**: Maps IP address to MAC address
- **DHCP Reservations**: Assign specific IP to specific MAC
- **Network Security**: MAC filtering (allow/deny specific devices)
- **Device Identification**: Tracking devices on network

**View MAC Address:**
```bash
# Linux
ip link show
ifconfig

# Windows
ipconfig /all
getmac

# macOS
ifconfig
networksetup -listallhardwareports
```

**Important Notes:**
- MAC addresses can be spoofed (changed in software)
- MAC filtering is not strong security (easily bypassed)
- Different network interfaces have different MAC addresses (WiFi vs Ethernet)

#### ARP (Address Resolution Protocol)

**What is ARP?**
Protocol that maps IP addresses to MAC addresses on a local network.

**Why ARP is Needed:**
- IP addresses are logical (Layer 3)
- MAC addresses are physical (Layer 2)
- To send data, you need both
- ARP translates: "Who has IP 192.168.1.50? Tell me your MAC address!"

**ARP Process:**
1. Device wants to send data to 192.168.1.50
2. Broadcasts ARP request: "Who has 192.168.1.50?"
3. Device with that IP responds: "I'm 192.168.1.50, my MAC is AA:BB:CC:DD:EE:FF"
4. Original device caches this info in ARP table
5. Data sent directly to MAC address

**ARP Cache/Table:**
- Stores IP-to-MAC mappings
- Prevents repeated ARP requests
- Entries expire after a time (usually minutes)

**View ARP Table:**
```bash
# Linux
arp -a
ip neighbor show

# Windows
arp -a

# macOS
arp -a
```

**Clear ARP Cache:**
```bash
# Linux
sudo ip -s -s neigh flush all

# Windows
arp -d

# macOS
sudo arp -d -a
```

**ARP Spoofing:**
- Attack where malicious device sends fake ARP responses
- Redirects traffic to attacker instead of legitimate device
- Used for man-in-the-middle attacks
- Mitigated by dynamic ARP inspection on managed switches

#### NAT (Network Address Translation)

**What is NAT?**
Allows multiple devices on private network to share one public IP address.

**Why NAT Exists:**
- IPv4 address shortage (only ~4 billion addresses)
- Private networks use internal IP ranges
- NAT translates private IPs to public IP for internet access

**Private IP Ranges (RFC 1918):**
- `10.0.0.0 - 10.255.255.255` (10.0.0.0/8)
- `172.16.0.0 - 172.31.255.255` (172.16.0.0/12)
- `192.168.0.0 - 192.168.255.255` (192.168.0.0/16)

These are NOT routable on internet - only used internally.

**How NAT Works:**
1. Device (192.168.1.100) requests website
2. Router receives packet, notes source IP and port
3. Router replaces source IP with public IP (203.0.113.50)
4. Website responds to public IP
5. Router receives response, looks up mapping
6. Router forwards to original device (192.168.1.100)

**Types of NAT:**
- **SNAT (Source NAT)**: Changes source IP (typical home router)
- **DNAT (Destination NAT)**: Changes destination IP (port forwarding)
- **PAT (Port Address Translation)**: Multiple devices share one public IP using different ports
- **1:1 NAT**: One private IP mapped to one public IP

**Port Forwarding:**
- Type of NAT that directs external traffic to internal device
- Example: Forward external port 80 → internal 192.168.1.10:80
- Used for hosting servers behind NAT
- Also called "port mapping" or "virtual server"

**NAT Traversal:**
- Challenge: External devices can't initiate connection to NATed device
- Solutions: UPnP, STUN, TURN, port forwarding
- Important for gaming, VoIP, P2P applications

#### VLANs (Virtual Local Area Networks)

**What is a VLAN?**
Logical separation of network into multiple broadcast domains, even on same physical switch.

**Why Use VLANs?**
- **Security**: Separate sensitive traffic (finance, HR, guest WiFi)
- **Performance**: Reduce broadcast traffic
- **Organization**: Group devices logically, not physically
- **Flexibility**: Easy to move devices between networks

**Example VLAN Setup:**
- VLAN 10: Management (servers, admin)
- VLAN 20: Employees (workstations)
- VLAN 30: Guests (public WiFi)
- VLAN 40: IoT devices (cameras, sensors)

**VLAN Types:**
- **Data VLAN**: Regular user traffic
- **Voice VLAN**: VoIP traffic (QoS priority)
- **Management VLAN**: Switch/router management
- **Native VLAN**: Untagged traffic (usually VLAN 1)

**VLAN Tagging (802.1Q):**
- Adds VLAN ID to Ethernet frames
- Allows multiple VLANs over single cable
- **Tagged port**: Carries multiple VLANs (trunk)
- **Untagged port**: Single VLAN (access port)

**Trunk vs Access Port:**
- **Access Port**: Connects end device (PC, phone), one VLAN
- **Trunk Port**: Connects switches, carries multiple VLANs

**Inter-VLAN Routing:**
- VLANs are separate networks by default
- To communicate between VLANs, need Layer 3 routing
- Options: Router with multiple interfaces, Layer 3 switch

**Common VLAN Commands (Cisco):**
```
# Create VLAN
vlan 10
name Employees

# Assign port to VLAN
interface GigabitEthernet0/1
switchport mode access
switchport access vlan 10

# Configure trunk
interface GigabitEthernet0/24
switchport mode trunk
switchport trunk allowed vlan 10,20,30
```

#### Additional Networking Concepts

**OSI Model (7 Layers):**
Conceptual framework describing how network communication works:
1. **Physical**: Cables, signals, hardware
2. **Data Link**: MAC addresses, switches, frames
3. **Network**: IP addresses, routing, packets
4. **Transport**: TCP/UDP, ports, end-to-end connections
5. **Session**: Session management, authentication
6. **Presentation**: Data formatting, encryption, compression
7. **Application**: HTTP, FTP, SMTP, user applications

**TCP/IP Model (4 Layers):**
Practical implementation used by internet:
1. **Network Access**: Physical + Data Link (Ethernet, WiFi)
2. **Internet**: Routing, IP addressing
3. **Transport**: TCP, UDP, ports
4. **Application**: HTTP, DNS, SSH, etc.

**Broadcast vs Unicast vs Multicast:**
- **Unicast**: One-to-one (most common)
- **Broadcast**: One-to-all (ARP requests, DHCP discovery)
- **Multicast**: One-to-many (streaming, video conferencing)

**MTU (Maximum Transmission Unit):**
- Largest packet size that can be transmitted
- Default: 1500 bytes for Ethernet
- Too large: Fragmentation needed
- Too small: More overhead
- Jumbo frames: 9000 bytes (specialized networks)

**Latency vs Bandwidth:**
- **Latency**: Time for data to travel (milliseconds)
  - Ping measures latency
  - Affected by distance, routing, network congestion
- **Bandwidth**: Amount of data transferred (Mbps, Gbps)
  - Maximum capacity of connection
  - Like pipe width (bandwidth) vs water pressure (latency)

**Duplex:**
- **Half-Duplex**: One direction at a time (walkie-talkie)
- **Full-Duplex**: Both directions simultaneously (phone call)
- Modern Ethernet is full-duplex

**Quality of Service (QoS):**
- Prioritizes certain types of traffic
- Voice/video get priority over file downloads
- Prevents important traffic from being delayed
- Configured on routers and managed switches

### Network Protocols

- **TCP (Transmission Control Protocol)**: Reliable, connection-oriented communication
- **UDP (User Datagram Protocol)**: Fast, connectionless communication
- **HTTP/HTTPS**: Web traffic (port 80/443)
- **SSH (Secure Shell)**: Secure remote access (port 22)
- **FTP/SFTP**: File transfer (port 21/22)
- **ICMP**: Network diagnostics (ping)

### Common Network Commands

```bash
# Test connectivity
ping google.com

# Show IP configuration
ip addr          # Linux
ipconfig         # Windows

# Trace route to destination
traceroute google.com    # Linux
tracert google.com       # Windows

# Show network connections
netstat -tulpn   # Linux
netstat -ano     # Windows

# DNS lookup
nslookup google.com
dig google.com   # Linux (more detailed)

# Show routing table
ip route         # Linux
route print      # Windows
```

### Ports

**Port**: A virtual endpoint for network connections (0-65535)

**Common Ports**:
- 22: SSH
- 80: HTTP
- 443: HTTPS
- 3306: MySQL
- 5432: PostgreSQL
- 6379: Redis
- 3389: RDP (Remote Desktop)

---

## Command Line Essentials

### Why Command Line?

- **Efficiency**: Faster than GUI for many tasks
- **Automation**: Scripts can execute repetitive tasks
- **Remote Access**: SSH provides command-line access to remote servers
- **Powerful**: More control and options than GUI tools

### Linux/macOS Commands

#### Navigation
```bash
pwd                    # Print working directory
ls                     # List files
ls -la                 # List all files with details
cd /path/to/directory  # Change directory
cd ..                  # Go up one level
cd ~                   # Go to home directory
```

#### File Operations
```bash
mkdir dirname          # Create directory
touch filename         # Create empty file
cp source dest         # Copy file
mv source dest         # Move/rename file
rm filename            # Delete file
rm -rf dirname         # Delete directory recursively
cat filename           # Display file contents
less filename          # View file with pagination
head -n 10 filename    # Show first 10 lines
tail -n 10 filename    # Show last 10 lines
tail -f filename       # Follow file (live updates)
```

#### File Permissions
```bash
chmod 755 file         # Set permissions (rwxr-xr-x)
chown user:group file  # Change owner
```

**Permission Numbers**:
- 4: Read (r)
- 2: Write (w)
- 1: Execute (x)
- 755 = rwxr-xr-x (owner: all, group: read+execute, others: read+execute)

#### Search and Find
```bash
find /path -name "*.txt"      # Find files by name
grep "pattern" filename       # Search within files
grep -r "pattern" /path       # Recursive search
```

#### Process Management
```bash
ps aux                 # Show all processes
top                    # Real-time process monitor
htop                   # Better process monitor (if installed)
kill PID               # Terminate process
kill -9 PID            # Force kill process
killall processname    # Kill by name
```

#### System Information
```bash
df -h                  # Disk space usage
du -sh /path           # Directory size
free -h                # Memory usage
uname -a               # System information
uptime                 # System uptime
```

#### Text Processing
```bash
grep pattern file      # Filter lines
sed 's/old/new/g'      # Replace text
awk '{print $1}'       # Extract columns
sort file              # Sort lines
uniq                   # Remove duplicates
wc -l file             # Count lines
```

#### Piping and Redirection
```bash
command1 | command2    # Pipe output to next command
command > file         # Redirect output to file (overwrite)
command >> file        # Append output to file
command 2>&1           # Redirect stderr to stdout
```

### Windows Commands (CMD/PowerShell)

```powershell
# Navigation
dir                    # List files
cd path                # Change directory

# File operations
copy source dest       # Copy
move source dest       # Move
del filename           # Delete

# System info
ipconfig               # Network configuration
systeminfo             # System details
tasklist               # Running processes
taskkill /PID 1234     # Kill process
```

---

## Version Control

### Git Basics

**Git**: Distributed version control system for tracking code changes.

**Repository (Repo)**: A project folder tracked by Git.

#### Core Concepts

- **Commit**: A snapshot of code at a point in time
- **Branch**: An independent line of development
- **Merge**: Combining changes from different branches
- **Clone**: Copy a repository from remote to local
- **Push**: Send local commits to remote repository
- **Pull**: Fetch and merge remote changes to local
- **Fork**: Create a personal copy of someone else's repository

#### Essential Git Commands

```bash
# Initial setup
git config --global user.name "Your Name"
git config --global user.email "your@email.com"

# Create/clone repository
git init                        # Initialize new repo
git clone https://github.com/user/repo.git

# Basic workflow
git status                      # Check current state
git add filename                # Stage specific file
git add .                       # Stage all changes
git commit -m "message"         # Commit with message
git push origin main            # Push to remote
git pull origin main            # Pull from remote

# Branching
git branch                      # List branches
git branch feature-name         # Create branch
git checkout feature-name       # Switch branch
git checkout -b feature-name    # Create and switch
git merge feature-name          # Merge branch into current

# History and info
git log                         # View commit history
git log --oneline               # Compact history
git diff                        # Show unstaged changes
git diff --staged               # Show staged changes

# Undo changes
git restore filename            # Discard local changes
git reset HEAD~1                # Undo last commit (keep changes)
git reset --hard HEAD~1         # Undo last commit (discard changes)
```

---

## Cloud Computing

### What is Cloud Computing?

Delivery of computing services (servers, storage, databases, networking) over the internet.

### Cloud Service Models

#### IaaS (Infrastructure as a Service)
Raw computing resources: virtual machines, storage, networking.
- **Examples**: AWS EC2, Google Compute Engine, Azure VMs
- **Use case**: Full control over infrastructure

#### PaaS (Platform as a Service)
Platform for building/deploying applications without managing infrastructure.
- **Examples**: AWS Elastic Beanstalk, Google App Engine, Heroku
- **Use case**: Focus on code, not infrastructure

#### SaaS (Software as a Service)
Complete applications delivered over the internet.
- **Examples**: Gmail, Salesforce, Microsoft 365
- **Use case**: End-user applications

### Cloud Deployment Models

- **Public Cloud**: Shared infrastructure (AWS, Azure, GCP)
- **Private Cloud**: Dedicated infrastructure for one organization
- **Hybrid Cloud**: Combination of public and private

### Key Cloud Concepts

#### Virtual Machine (VM) / Instance
A software-based computer running on physical hardware.

#### Container
Lightweight, portable package containing application and dependencies.
- **Docker**: Most popular container platform
- **Kubernetes (K8s)**: Container orchestration platform

#### Storage Types
- **Block Storage**: Like a hard drive (AWS EBS, Azure Disks)
- **Object Storage**: For files and blobs (AWS S3, Azure Blob Storage)
- **File Storage**: Network file systems (AWS EFS, Azure Files)

#### Load Balancer
Distributes traffic across multiple servers for reliability and performance.

#### Auto Scaling
Automatically adjusts resources based on demand.

#### Region and Availability Zone
- **Region**: Geographic location (us-east-1, eu-west-1)
- **Availability Zone (AZ)**: Isolated data center within a region

### AWS Basics

**Common Services**:
- **EC2**: Virtual servers
- **S3**: Object storage
- **RDS**: Managed databases
- **Lambda**: Serverless functions
- **VPC**: Virtual private network
- **IAM**: Identity and access management
- **CloudWatch**: Monitoring and logs
- **Route 53**: DNS service

### Cloud CLI Examples

```bash
# AWS CLI
aws s3 ls                              # List S3 buckets
aws ec2 describe-instances             # List EC2 instances
aws s3 cp file.txt s3://bucket/        # Upload to S3

# DigitalOcean CLI (doctl)
doctl compute droplet list             # List droplets
doctl compute droplet create name      # Create droplet

# Google Cloud CLI (gcloud)
gcloud compute instances list          # List instances
gcloud compute instances create name   # Create instance
```

---

## Virtualization Basics

Virtualization allows you to run multiple operating systems and applications on a single physical machine, maximizing resource utilization and flexibility.

### What is Virtualization?

**Virtualization** creates virtual versions of physical hardware, allowing multiple "virtual machines" to run on one physical computer, each with its own operating system and applications.

**Key Benefits:**
- **Resource Efficiency**: Run multiple servers on one physical machine
- **Cost Savings**: Fewer physical servers needed (power, cooling, space)
- **Isolation**: Problems in one VM don't affect others
- **Testing/Development**: Safely test software in isolated environments
- **Disaster Recovery**: Easy backups and quick recovery (snapshots)
- **Flexibility**: Quick to create, clone, move, or delete VMs

**Common Use Cases:**
- Server consolidation (running many small servers on one physical machine)
- Development and testing environments
- Running legacy applications (old software on old OS)
- Lab environments for learning
- Cloud computing (AWS, Azure, GCP all use virtualization)

### Hypervisors

A **hypervisor** is software that creates and manages virtual machines.

#### Type 1 Hypervisor (Bare Metal)

**Runs directly on hardware without a host OS**

**Examples:**
- **VMware ESXi**: Enterprise standard, powerful features
- **Microsoft Hyper-V**: Built into Windows Server
- **Proxmox VE**: Open-source, KVM-based
- **Citrix XenServer**: Enterprise virtualization
- **KVM (Kernel-based Virtual Machine)**: Linux kernel module

**Characteristics:**
- Better performance (direct hardware access)
- More secure (smaller attack surface)
- Used in data centers and enterprise environments
- Requires dedicated hardware

**Typical Setup:**
```
┌─────────────────────────────────────────┐
│  VM 1    │  VM 2    │  VM 3    │  VM 4  │ ← Virtual Machines
├──────────┴──────────┴──────────┴────────┤
│       Type 1 Hypervisor (ESXi)          │ ← Hypervisor
├─────────────────────────────────────────┤
│         Physical Hardware                │ ← Server Hardware
└─────────────────────────────────────────┘
```

**Best For:**
- Production servers
- Enterprise data centers
- High-performance requirements
- Running many VMs simultaneously

#### Type 2 Hypervisor (Hosted)

**Runs on top of a regular operating system**

**Examples:**
- **VMware Workstation**: Professional desktop virtualization (paid)
- **VMware Fusion**: VMware for macOS (paid)
- **VirtualBox**: Free, cross-platform (Oracle)
- **Parallels Desktop**: Popular for Mac (paid)
- **QEMU**: Open-source emulator and virtualizer

**Characteristics:**
- Easier to set up (runs like normal application)
- Lower performance (goes through host OS)
- Good for desktop use and development
- Can run alongside regular applications

**Typical Setup:**
```
┌─────────────────────────────────────────┐
│  VM 1    │  VM 2    │  VM 3            │ ← Virtual Machines
├──────────┴──────────┴──────────────────┤
│    Type 2 Hypervisor (VirtualBox)       │ ← Hypervisor (Application)
├─────────────────────────────────────────┤
│      Host OS (Windows/macOS/Linux)      │ ← Your Computer's OS
├─────────────────────────────────────────┤
│         Physical Hardware                │ ← Your Computer
└─────────────────────────────────────────┘
```

**Best For:**
- Desktop/laptop use
- Development and testing
- Learning and experimentation
- Running a few VMs occasionally

#### Type 1 vs Type 2 Comparison

| Feature | Type 1 (Bare Metal) | Type 2 (Hosted) |
|---------|---------------------|-----------------|
| **Performance** | Excellent | Good |
| **Ease of Setup** | Complex | Easy |
| **Cost** | Often expensive | Free options available |
| **Use Case** | Enterprise/Production | Desktop/Development |
| **Examples** | ESXi, Hyper-V, Proxmox | VirtualBox, VMware Workstation |

### Virtual Machines vs Containers

Both run isolated applications, but work very differently.

#### Virtual Machines (VMs)

**Full virtualization of entire operating system**

**Characteristics:**
- Each VM includes full OS (guest OS)
- Runs on hypervisor
- Heavy resource usage (each needs RAM, storage for full OS)
- Slower startup (boot entire OS)
- Strong isolation
- Can run different OS types on same host

**Structure:**
```
┌──────────┬──────────┬──────────┐
│  App A   │  App B   │  App C   │
├──────────┼──────────┼──────────┤
│  Guest   │  Guest   │  Guest   │
│   OS     │   OS     │   OS     │
├──────────┴──────────┴──────────┤
│       Hypervisor                │
├─────────────────────────────────┤
│        Host OS                  │
├─────────────────────────────────┤
│      Hardware                   │
└─────────────────────────────────┘
```

**Typical Resource Usage:**
- RAM: 512MB - 8GB+ per VM
- Storage: 10GB - 100GB+ per VM
- Startup time: 30 seconds - 2 minutes

**Best For:**
- Running different operating systems
- Strong security isolation needed
- Legacy applications
- Long-running servers

#### Containers

**Lightweight application isolation sharing host OS kernel**

**Characteristics:**
- Shares host OS kernel
- Only includes application and dependencies
- Lightweight (MB instead of GB)
- Fast startup (seconds)
- Less isolation than VMs
- All containers must be same OS type (Linux containers on Linux host)

**Structure:**
```
┌──────────┬──────────┬──────────┐
│  App A   │  App B   │  App C   │
├──────────┼──────────┼──────────┤
│Container │Container │Container │
│  Engine  │  Engine  │  Engine  │
├──────────┴──────────┴──────────┤
│        Host OS                  │
├─────────────────────────────────┤
│      Hardware                   │
└─────────────────────────────────┘
```

**Popular Container Platforms:**
- **Docker**: Most popular, easy to use
- **Kubernetes**: Container orchestration (managing many containers)
- **Podman**: Docker alternative, daemon-less
- **LXC/LXD**: System containers (more like lightweight VMs)

**Typical Resource Usage:**
- RAM: 50MB - 500MB per container
- Storage: 50MB - 500MB per container
- Startup time: < 1 second

**Best For:**
- Microservices architectures
- CI/CD pipelines
- Rapid deployment and scaling
- Modern cloud-native applications

#### VMs vs Containers Comparison

| Feature | Virtual Machines | Containers |
|---------|------------------|------------|
| **Size** | GBs | MBs |
| **Startup Time** | Minutes | Seconds |
| **Resource Usage** | Heavy | Light |
| **Isolation** | Strong | Moderate |
| **OS Flexibility** | Any OS | Same OS as host |
| **Best For** | Different OSes, strong isolation | Fast deployment, microservices |
| **Examples** | VMware, VirtualBox, Hyper-V | Docker, Kubernetes |

**When to Use What:**
- **Use VMs when**: You need different OS types, strong isolation, or running legacy apps
- **Use Containers when**: Building modern applications, need fast deployment, microservices
- **Use Both**: Many organizations use VMs to run servers, containers to run applications on those VMs

### Snapshots

**Snapshots** capture the complete state of a VM at a specific moment in time.

**What's Captured:**
- Memory state (RAM contents)
- Disk state (all files)
- VM settings and configuration

**Use Cases:**
- **Before updates**: Take snapshot before applying patches
- **Testing**: Revert if something breaks
- **Development**: Try risky changes safely
- **Cloning**: Create identical copies

**Common Operations:**
```bash
# VirtualBox
VBoxManage snapshot "VM Name" take "Snapshot Name"
VBoxManage snapshot "VM Name" restore "Snapshot Name"
VBoxManage snapshot "VM Name" list

# VMware (ESXi)
vim-cmd vmsvc/snapshot.create <vmid> SnapshotName
vim-cmd vmsvc/snapshot.revert <vmid> <snapshotid>

# Proxmox
qm snapshot <vmid> snapshot-name
qm rollback <vmid> snapshot-name
```

**Important Notes:**
- Snapshots are not backups (stored on same disk as VM)
- Multiple snapshots can slow down VM performance
- Delete old snapshots after testing is complete
- Don't rely on snapshots for long-term recovery

### Getting Started with Virtualization

**For Beginners (Desktop/Learning):**

1. **Install VirtualBox** (free, easy):
   - Download from virtualbox.org
   - Install on Windows, Mac, or Linux
   - Download ISO of OS you want to try (e.g., Ubuntu)
   - Create new VM, allocate resources (2GB+ RAM, 20GB+ disk)
   - Install OS in VM

2. **Recommended First Projects:**
   - Install Ubuntu Server and practice Linux commands
   - Set up a web server (nginx/Apache)
   - Test software before installing on main machine
   - Try different Linux distributions

**Resource Allocation Tips:**
- **RAM**: Allocate 25-50% of physical RAM per VM
  - Host has 16GB → Allocate 4-8GB to VM
- **CPU**: Allocate 1-2 cores per VM
- **Storage**: Start with 20-40GB, expandable later
- **Network**: NAT mode for internet access, Bridged for local network access

**Common Virtualization Terms:**
- **Host**: Physical machine running hypervisor
- **Guest**: Virtual machine running on host
- **VM Template**: Pre-configured VM used as starting point for new VMs
- **Clone**: Exact copy of a VM
- **OVF/OVA**: VM export format (portable between platforms)
- **Live Migration**: Moving running VM from one host to another without downtime
- **Resource Pool**: Group of resources shared among VMs

### Performance Considerations

**Factors Affecting VM Performance:**
- **CPU**: More cores = more VMs can run simultaneously
- **RAM**: Most critical - each VM needs its own RAM
- **Storage**: SSDs dramatically improve VM performance vs HDDs
- **Network**: Virtual network adds slight overhead

**Signs Your Host is Overloaded:**
- VMs run very slowly
- Host becomes unresponsive
- High RAM usage (swapping to disk)
- Solution: Reduce number of running VMs or upgrade hardware

---

## Remote Support Tools and VPN

Essential technologies for providing remote IT support and secure network access.

### Remote Desktop Protocol (RDP)

**Microsoft's protocol for remote Windows desktop access**

**Features:**
- Full desktop GUI access
- Sound redirection
- Clipboard sharing (copy/paste between local and remote)
- Drive mapping (access local drives from remote session)
- Printer redirection

**Default Port:** 3389

**Enabling RDP on Windows:**
1. Settings → System → Remote Desktop
2. Enable "Remote Desktop"
3. Note the computer name
4. Configure firewall to allow port 3389

**Connecting to RDP:**
```bash
# Windows (built-in client)
mstsc /v:SERVER_IP

# Or use Remote Desktop Connection app
# Start → Remote Desktop Connection

# Linux
rdesktop SERVER_IP
xfreerdp /v:SERVER_IP /u:USERNAME

# macOS
# Download Microsoft Remote Desktop from App Store
```

**Security Best Practices:**
- Use strong passwords
- Enable Network Level Authentication (NLA)
- Change default port 3389 to non-standard port
- Use VPN for remote access instead of exposing RDP to internet
- Enable MFA if possible
- Use RDP Gateway for added security layer

**Common Issues:**
- "Remote Desktop can't connect": Check firewall, verify RDP is enabled
- Black screen: Graphics driver issue
- Slow performance: Reduce color depth, disable visual effects

### VNC (Virtual Network Computing)

**Cross-platform remote desktop protocol**

**Advantages:**
- Works on Windows, Mac, Linux
- Open standard
- Lightweight

**Popular VNC Software:**
- **TightVNC**: Free, Windows/Linux
- **RealVNC**: Commercial, all platforms
- **TigerVNC**: Open-source, performance-focused
- **UltraVNC**: Windows, file transfer support

**Default Port:** 5900

**Basic VNC Usage:**
```bash
# Install VNC server (Linux)
sudo apt install tightvncserver

# Start VNC server
vncserver :1

# Connect from client
vncviewer SERVER_IP:5901
```

**VNC vs RDP:**
- **RDP**: Better performance, Windows-focused, encrypted by default
- **VNC**: Cross-platform, open standard, less performant

### SSH (Secure Shell)

**Secure command-line remote access for servers**

**Features:**
- Encrypted communication
- Secure file transfer (SCP, SFTP)
- Tunneling (port forwarding)
- Key-based authentication (more secure than passwords)

**Default Port:** 22

**Covered in detail in Security Basics section** (see page above)

### TeamViewer

**Popular commercial remote support solution**

**Features:**
- Easy to use (no configuration needed)
- Works through firewalls/NAT
- Cross-platform (Windows, Mac, Linux, mobile)
- File transfer
- Remote printing
- Unattended access

**Use Cases:**
- Remote support for family/friends
- Quick one-time assistance
- Users behind strict firewalls

**Pricing:**
- Free for personal use
- Paid for commercial use

**How It Works:**
1. Both parties install TeamViewer
2. Remote user provides their ID and password
3. Supporter enters ID to connect
4. Full remote control

**Alternatives:**
- **AnyDesk**: Similar to TeamViewer, lighter weight
- **Chrome Remote Desktop**: Browser-based, free
- **Zoho Assist**: Commercial remote support

### VPN (Virtual Private Network)

**Creates encrypted tunnel for secure communication over internet**

### What is a VPN?

A VPN encrypts your internet traffic and routes it through a secure server, making it appear as if you're accessing the internet from that server's location.

**How VPN Works:**
```
Your Computer → Encrypted Tunnel → VPN Server → Internet
      ↑                                        ↓
   Private                           Appears to come from
   Your IP                            VPN Server's IP
```

### VPN Use Cases

#### 1. Remote Access VPN (Corporate)
**Connect to company network from anywhere**

**Scenario:**
- Employee working from home needs to access company resources
- VPN makes computer act as if it's on office network
- Access internal servers, printers, file shares

**Popular Solutions:**
- OpenVPN
- WireGuard
- Cisco AnyConnect
- Palo Alto GlobalProtect
- Fortinet FortiClient

#### 2. Site-to-Site VPN
**Connect two networks together over internet**

**Scenario:**
- Company has office in New York and California
- Site-to-site VPN connects both office networks
- Employees in either office can access resources in both locations

**Used For:**
- Branch offices
- Connecting on-premises to cloud
- Multi-site organizations

#### 3. Privacy VPN (Consumer)
**Hide your internet activity from ISP and websites**

**Scenario:**
- Hide browsing from ISP
- Access geo-restricted content
- Public WiFi security

**Popular Services:**
- NordVPN
- ExpressVPN
- Mullvad
- ProtonVPN

### VPN Protocols

#### OpenVPN
- **Type**: Open-source
- **Security**: Very secure
- **Speed**: Good
- **Platform**: All platforms
- **Port**: Configurable (often 1194 UDP)
- **Best For**: Corporate use, self-hosted VPN

#### WireGuard
- **Type**: Modern, open-source
- **Security**: Excellent (modern cryptography)
- **Speed**: Fastest VPN protocol
- **Platform**: All platforms
- **Port**: Configurable (51820 UDP default)
- **Best For**: Modern deployments, performance-critical

#### IPSec/IKEv2
- **Type**: Industry standard
- **Security**: Very secure
- **Speed**: Fast
- **Platform**: Built into most devices
- **Best For**: Site-to-site VPNs, mobile devices

#### L2TP/IPSec
- **Type**: Older standard
- **Security**: Good
- **Speed**: Moderate
- **Platform**: Widely supported
- **Best For**: Legacy systems

#### PPTP (Don't Use)
- **Type**: Very old protocol
- **Security**: Weak (easily broken)
- **Speed**: Fast but insecure
- **Status**: Deprecated, avoid

### Setting Up a Basic VPN (OpenVPN)

**Server Side:**
```bash
# Install OpenVPN (Ubuntu)
sudo apt update
sudo apt install openvpn easy-rsa

# Generate keys and certificates
make-cadir ~/openvpn-ca
cd ~/openvpn-ca
./easyrsa init-pki
./easyrsa build-ca
./easyrsa gen-dh
./easyrsa build-server-full server nopass

# Start OpenVPN server
sudo openvpn --config /etc/openvpn/server.conf
```

**Client Side:**
```bash
# Install OpenVPN client
sudo apt install openvpn

# Connect to VPN
sudo openvpn --config client.ovpn
```

**Modern Alternative (WireGuard - Simpler):**
```bash
# Server
sudo apt install wireguard
wg-quick up wg0

# Client
sudo apt install wireguard
wg-quick up wg0
```

### Tailscale (Modern Zero-Config VPN)

**Easiest VPN solution for personal/small business use**

**Features:**
- Zero configuration (just install and login)
- Built on WireGuard
- Mesh network (all devices can talk to each other)
- Free for personal use (up to 3 users, 100 devices)
- Works through firewalls automatically
- No port forwarding needed

**Setup:**
```bash
# Install Tailscale
curl -fsSL https://tailscale.com/install.sh | sh

# Login and connect
sudo tailscale up

# View connected devices
tailscale status
```

**Perfect For:**
- Personal networks (access home server from anywhere)
- Small teams
- Remote access without complexity
- Replacing port forwarding

### VPN Troubleshooting

**Can't Connect to VPN:**
```bash
# Check if VPN service is running
sudo systemctl status openvpn

# Test connectivity to VPN server
ping VPN_SERVER_IP

# Check firewall allows VPN port
sudo ufw allow 1194/udp  # OpenVPN
sudo ufw allow 51820/udp # WireGuard

# View VPN logs
sudo journalctl -u openvpn
tail -f /var/log/syslog | grep vpn
```

**Connected but No Internet:**
- Check DNS configuration
- Verify routing table (`ip route` or `route print`)
- Check if VPN server allows forwarding

**Slow VPN Performance:**
- Try different protocol (WireGuard is fastest)
- Connect to geographically closer server
- Check your internet speed (VPN can't be faster than your connection)
- Reduce encryption level if acceptable for use case

### Remote Support Security

**Best Practices:**
1. **Always verify the person** you're supporting (phone call, ticket system)
2. **Use MFA** for remote access systems
3. **Monitor sessions**: Log who connected when
4. **Least privilege**: Only grant access needed for task
5. **Session timeout**: Auto-disconnect after inactivity
6. **End session properly**: Don't leave connections open
7. **Use VPN first**: Connect to VPN, then use RDP/SSH
8. **Audit trails**: Keep logs of remote access

**Red Flags:**
- Unsolicited remote support requests (scams)
- Requests to install unfamiliar remote software
- Requests for banking/payment information during support

---

## DevOps Fundamentals

### What is DevOps?

**DevOps**: Culture and practices combining Development and Operations to deliver software faster and more reliably.

### Key Principles

1. **Automation**: Automate repetitive tasks
2. **Continuous Integration (CI)**: Frequently merge code changes
3. **Continuous Deployment (CD)**: Automatically deploy code to production
4. **Infrastructure as Code (IaC)**: Manage infrastructure through code
5. **Monitoring and Logging**: Track system health and issues
6. **Collaboration**: Break down silos between teams

### CI/CD Pipeline

**Continuous Integration/Continuous Deployment**: Automated workflow from code to production.

**Typical Pipeline Stages**:
1. **Code**: Developer pushes code
2. **Build**: Compile/package application
3. **Test**: Run automated tests
4. **Deploy**: Deploy to staging/production
5. **Monitor**: Track performance and errors

**Popular CI/CD Tools**:
- GitHub Actions
- GitLab CI/CD
- Jenkins
- CircleCI
- Travis CI

### Infrastructure as Code (IaC)

Managing infrastructure through configuration files instead of manual processes.

**Popular IaC Tools**:
- **Terraform**: Multi-cloud infrastructure provisioning
- **Ansible**: Configuration management and automation
- **CloudFormation**: AWS-specific IaC
- **Pulumi**: IaC using programming languages

**Example Terraform**:
```hcl
resource "aws_instance" "web" {
  ami           = "ami-0c55b159cbfafe1f0"
  instance_type = "t2.micro"

  tags = {
    Name = "WebServer"
  }
}
```

### Containers and Orchestration

#### Docker Basics

```bash
# Images
docker images                          # List images
docker pull nginx                      # Download image
docker build -t myapp .                # Build image from Dockerfile

# Containers
docker ps                              # List running containers
docker ps -a                           # List all containers
docker run -d -p 80:80 nginx           # Run container
docker stop container_id               # Stop container
docker rm container_id                 # Remove container
docker logs container_id               # View logs
docker exec -it container_id bash      # Access container shell

# System
docker system prune                    # Clean up unused resources
```

**Dockerfile Example**:
```dockerfile
FROM ubuntu:22.04
RUN apt-get update && apt-get install -y nginx
COPY . /var/www/html
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
```

#### Kubernetes Basics

**Key Concepts**:
- **Pod**: Smallest deployable unit (one or more containers)
- **Deployment**: Manages replica sets and updates
- **Service**: Network access to pods
- **Namespace**: Virtual cluster within Kubernetes
- **ConfigMap**: Configuration data
- **Secret**: Sensitive data (passwords, keys)

```bash
# kubectl commands
kubectl get pods                       # List pods
kubectl get services                   # List services
kubectl describe pod pod-name          # Pod details
kubectl logs pod-name                  # View logs
kubectl exec -it pod-name -- bash      # Access pod shell
kubectl apply -f config.yaml           # Apply configuration
kubectl delete pod pod-name            # Delete pod
```

### Configuration Management

**Tools**: Ansible, Puppet, Chef, SaltStack

**Ansible Example** (playbook.yml):
```yaml
---
- hosts: webservers
  tasks:
    - name: Install nginx
      apt:
        name: nginx
        state: present
    - name: Start nginx
      service:
        name: nginx
        state: started
```

---

## Security Basics

### Authentication vs Authorization

- **Authentication**: Verifying identity ("Who are you?")
- **Authorization**: Verifying permissions ("What can you do?")

### SSH (Secure Shell)

Secure protocol for remote access to servers.

```bash
# Connect to server
ssh username@hostname

# Connect with specific key
ssh -i ~/.ssh/private_key username@hostname

# Copy files securely
scp file.txt username@hostname:/path/
scp -r folder/ username@hostname:/path/

# Generate SSH key pair
ssh-keygen -t rsa -b 4096 -C "your@email.com"

# Copy public key to server
ssh-copy-id username@hostname
```

### SSL/TLS

Encryption protocols for secure communication (HTTPS).

- **Certificate**: Digital document proving identity
- **Let's Encrypt**: Free SSL certificates
- **Self-signed Certificate**: For testing/internal use

### Firewalls

Controls incoming/outgoing network traffic based on rules.

```bash
# UFW (Ubuntu)
sudo ufw status                        # Check status
sudo ufw allow 22                      # Allow SSH
sudo ufw allow 80/tcp                  # Allow HTTP
sudo ufw enable                        # Enable firewall

# iptables (Linux)
sudo iptables -L                       # List rules
sudo iptables -A INPUT -p tcp --dport 80 -j ACCEPT
```

### Common Security Practices

1. **Use strong passwords**: 12+ characters, mixed case, numbers, symbols
2. **Enable MFA (Multi-Factor Authentication)**: Second verification layer
3. **Principle of Least Privilege**: Grant minimum necessary permissions
4. **Keep systems updated**: Regularly apply security patches
5. **Use SSH keys**: More secure than passwords
6. **Encrypt sensitive data**: Both in transit and at rest
7. **Regular backups**: Protect against data loss
8. **Monitor logs**: Detect suspicious activity

---

## Troubleshooting Methodology

### Systematic Approach

1. **Identify the problem**: What exactly is wrong?
2. **Gather information**: Error messages, logs, recent changes
3. **Establish a theory**: What might be causing it?
4. **Test the theory**: Verify your hypothesis
5. **Plan of action**: Decide on fix and potential impact
6. **Implement solution**: Apply the fix
7. **Verify functionality**: Confirm problem is resolved
8. **Document**: Record issue and solution

### Diagnostic Questions

- When did the problem start?
- What changed recently?
- Can you reproduce the issue?
- Does it affect one user or everyone?
- Are there any error messages?
- What have you tried already?

### Common Diagnostic Commands

```bash
# System resources
top                    # CPU and memory usage
df -h                  # Disk space
free -m                # Memory details
iostat                 # Disk I/O statistics

# Network
ping hostname          # Test connectivity
netstat -tulpn         # Active connections
ss -tulpn              # Socket statistics
tcpdump                # Packet capture

# Logs
tail -f /var/log/syslog              # System log (Debian/Ubuntu)
tail -f /var/log/messages            # System log (RHEL/CentOS)
journalctl -f                        # Systemd journal
grep error /var/log/apache2/error.log

# Services
systemctl status servicename         # Check service status
systemctl restart servicename        # Restart service
systemctl enable servicename         # Enable at boot

# Disk issues
du -sh /*              # Find large directories
lsof | grep deleted    # Find deleted files still open
```

---

## Common Tools

### Text Editors

#### Terminal-based
- **nano**: Beginner-friendly, simple
- **vim**: Powerful, steep learning curve
- **vi**: Minimal version of vim (always available)

```bash
# nano
nano filename          # Edit file
Ctrl+O                 # Save
Ctrl+X                 # Exit

# vim
vim filename           # Edit file
i                      # Insert mode
Esc                    # Command mode
:w                     # Save
:q                     # Quit
:wq                    # Save and quit
:q!                    # Quit without saving
```

#### GUI-based
- VS Code
- Sublime Text
- Atom

### Remote Access

- **SSH**: Command-line access
- **RDP**: Windows remote desktop
- **VNC**: Cross-platform desktop sharing
- **TeamViewer/AnyDesk**: Easy remote support

### Monitoring and Logging

- **Prometheus**: Metrics collection
- **Grafana**: Visualization and dashboards
- **ELK Stack**: Elasticsearch, Logstash, Kibana (log management)
- **Datadog**: Comprehensive monitoring platform
- **New Relic**: Application performance monitoring

### Collaboration

- **Slack**: Team communication
- **Jira**: Issue and project tracking
- **Confluence**: Documentation
- **PagerDuty**: Incident management
- **Zoom/Teams**: Video conferencing

---

## Essential Terminology

### General IT

- **API (Application Programming Interface)**: Way for programs to communicate
- **Bandwidth**: Data transfer capacity
- **Latency**: Time delay in data transmission
- **Throughput**: Actual data transfer rate
- **Uptime**: Time system is operational
- **Downtime**: Time system is unavailable
- **SLA (Service Level Agreement)**: Guaranteed service quality
- **Backup**: Copy of data for recovery
- **Restore**: Recovering data from backup
- **Snapshot**: Point-in-time copy of system/data

### Development

- **Repository**: Storage location for code
- **Dependency**: External code/library required by application
- **Environment**: Specific configuration (dev, staging, production)
- **Deployment**: Process of releasing code to environment
- **Rollback**: Reverting to previous version
- **Hotfix**: Quick fix for critical issue
- **Release**: Specific version deployed to production
- **Artifact**: Build output (compiled code, packages)

### Networking

- **Packet**: Unit of data transmitted over network
- **Protocol**: Rules for data communication
- **Proxy**: Intermediary server between client and destination
- **VPN (Virtual Private Network)**: Encrypted network connection
- **NAT (Network Address Translation)**: Translating private IPs to public
- **CDN (Content Delivery Network)**: Distributed servers for content delivery

### Cloud

- **Provisioning**: Allocating resources
- **Elasticity**: Ability to scale resources dynamically
- **Multi-tenancy**: Multiple customers sharing infrastructure
- **Serverless**: Running code without managing servers
- **Edge Computing**: Processing data near source

### DevOps

- **Pipeline**: Automated workflow
- **Build**: Converting source code to executable
- **Orchestration**: Coordinating multiple automated tasks
- **Provisioning**: Setting up infrastructure
- **Configuration Management**: Maintaining system settings
- **Immutable Infrastructure**: Never modify, only replace

---

## Learning Resources

### Practice Platforms

- **Linux**: Set up Ubuntu VM or use WSL (Windows Subsystem for Linux)
- **Cloud**: Free tiers on AWS, GCP, Azure
- **Containers**: Docker Desktop
- **Labs**: TryHackMe, HackTheBox (security), KodeKloud (DevOps)

### Documentation

- **Man Pages**: `man command` for detailed documentation
- **Official Docs**: Always check official documentation
- **Stack Overflow**: Community Q&A
- **GitHub**: Example projects and code

### Best Practices

1. **Hands-on practice**: Theory is important, but practice is essential
2. **Break things**: Learn by fixing errors (in safe environments)
3. **Read logs**: They contain valuable troubleshooting information
4. **Google effectively**: Use specific error messages and keywords
5. **Document your work**: Keep notes on solutions
6. **Ask questions**: No one knows everything
7. **Stay current**: Technology changes rapidly
8. **Automate**: If you do it twice, automate it

---

## Quick Reference Cheat Sheet

### Most Used Commands

```bash
# Navigation
ls -la, cd, pwd

# Files
cat, less, tail -f, grep, find

# System
top, ps aux, df -h, free -h

# Network
ping, curl, netstat, ss

# Services
systemctl status/start/stop/restart

# Logs
tail -f /var/log/syslog
journalctl -u servicename -f

# Permissions
chmod, chown

# Packages
apt update && apt upgrade      # Debian/Ubuntu
yum update                     # RHEL/CentOS older
dnf update                     # RHEL/CentOS newer
```

### Emergency Commands

```bash
# Disk full
du -sh /* | sort -h                   # Find large dirs
docker system prune -a                # Clean Docker
apt clean                             # Clean package cache

# High CPU/Memory
top                                   # Identify process
kill -9 PID                           # Kill process

# Service issues
systemctl status servicename
journalctl -u servicename -n 50       # Last 50 log lines
systemctl restart servicename

# Network issues
ping 8.8.8.8                          # Test internet
ping gateway_ip                       # Test local network
curl -I https://website.com           # Test web service
```

---

## Conclusion

This guide covers the fundamentals needed to begin working in IT tech support, cloud computing, and DevOps. Remember that learning IT is an ongoing process—technology evolves rapidly, and continuous learning is essential.

**Next Steps**:
1. Set up a Linux environment (VM or WSL)
2. Practice command-line basics daily
3. Create a GitHub account and learn Git
4. Sign up for cloud free tiers and experiment
5. Build small projects to apply knowledge
6. Join IT communities and forums
7. Consider certifications (CompTIA A+, Linux+, AWS Certified Cloud Practitioner)

**Key Takeaway**: Don't try to memorize everything. Focus on understanding concepts and knowing where to find information when needed. Use this guide as a reference to return to as you grow in your IT career.