# Hetzner Cloud Server Basics

A comprehensive guide to setting up your first cloud server on Hetzner, installing code-server, and learning Linux server fundamentals through hands-on practice.

## What You'll Learn

- Creating and configuring a Hetzner Cloud server
- Setting up Hetzner Cloud Firewall for security
- Installing and accessing code-server (VS Code in the browser)
- Installing the CodeLab extension for interactive learning
- Basic Linux server administration (users, firewall, packages)
- Installing and testing applications like nginx

## Prerequisites

- A Hetzner Cloud account ([hetzner.com](https://www.hetzner.com))
- Payment method added to Hetzner account
- Basic understanding of terminal/command line
- A web browser
- Basic knowledge of SSH (covered in IT Technical Guide)

## Course Structure

1. **Setup Guide** (this document) - Initial server setup and code-server installation
2. **Interactive Lab** (`server-basics-lab.mdcl`) - Hands-on exercises using CodeLab

---

## Part 1: Creating Your Hetzner Cloud Server

### Step 1: Log into Hetzner Cloud Console

1. Go to [https://console.hetzner.cloud](https://console.hetzner.cloud)
2. Log in with your credentials
3. Select your project or create a new one

### Step 2: Create a New Server

1. Click **"Add Server"** button
2. Configure your server with these settings:

#### Location
- Choose a location closest to you for better performance
- Recommended: `Nuremberg` (Europe) or `Ashburn, VA` (US)

#### Image
- **Operating System**: Ubuntu
- **Version**: 22.04 LTS (Long Term Support)
- Why Ubuntu? It's beginner-friendly, widely used, and has excellent documentation

#### Type
- **Type**: Shared vCPU
- **Plan**: CX11 (or CPX11)
  - 1 vCPU
  - 2 GB RAM
  - 20 GB SSD
  - Cost: ~€4.15/month (~$4.50/month)
- This is perfect for learning and development

#### Networking
- **IPv4**: Enabled (leave default)
- **IPv6**: Enabled (optional but recommended)

#### SSH Keys
- **IMPORTANT**: Add your SSH key for secure access
- If you don't have an SSH key:

  **On Linux/Mac:**
  ```bash
  ssh-keygen -t ed25519 -C "your_email@example.com"
  cat ~/.ssh/id_ed25519.pub
  ```

  **On Windows (PowerShell):**
  ```powershell
  ssh-keygen -t ed25519 -C "your_email@example.com"
  type $env:USERPROFILE\.ssh\id_ed25519.pub
  ```

- Copy the entire output and paste it into Hetzner's SSH key field
- Give your SSH key a descriptive name (e.g., "my-laptop")

#### Additional Options
- **Volumes**: None needed
- **Backups**: Optional (costs extra, but recommended for production)
- **Placement Groups**: None needed
- **Labels**: Optional (useful for organizing multiple servers)

#### Name
- Give your server a meaningful name (e.g., "ubuntu-dev-server" or "learning-server")

### Step 3: Create the Server

1. Review your configuration
2. Click **"Create & Buy now"**
3. Wait 30-60 seconds for server creation
4. Note the **IP address** displayed in the server details

---

## Part 2: Setting Up Hetzner Cloud Firewall

Security first! Let's create a firewall before accessing our server.

### Step 1: Create a Firewall

1. In the Hetzner Cloud Console, go to **"Firewalls"** in the left sidebar
2. Click **"Create Firewall"**
3. Name it something descriptive (e.g., "basic-server-firewall")

### Step 2: Configure Inbound Rules

Add the following rules to allow necessary traffic:

#### Rule 1: SSH Access
- **Direction**: Inbound
- **Protocol**: TCP
- **Port**: 22
- **Source**: 0.0.0.0/0, ::/0 (any IP)
- **Description**: SSH access

#### Rule 2: HTTP Access
- **Direction**: Inbound
- **Protocol**: TCP
- **Port**: 80
- **Source**: 0.0.0.0/0, ::/0
- **Description**: HTTP web traffic

#### Rule 3: HTTPS Access
- **Direction**: Inbound
- **Protocol**: TCP
- **Port**: 443
- **Source**: 0.0.0.0/0, ::/0
- **Description**: HTTPS web traffic

#### Rule 4: Code-Server Access
- **Direction**: Inbound
- **Protocol**: TCP
- **Port**: 8080
- **Source**: 0.0.0.0/0, ::/0
- **Description**: Code-server web interface

**Security Note**: For production servers, you should restrict port 22 (SSH) and 8080 (code-server) to your specific IP address instead of `0.0.0.0/0`. For learning purposes, we're allowing all IPs.

### Step 3: Apply Firewall to Server

1. In the firewall details, go to the **"Resources"** tab
2. Click **"Apply to Resources"**
3. Select your server
4. Click **"Apply Firewall"**

**Important**: Outbound traffic is allowed by default, so your server can access the internet for updates and downloads.

---

## Part 3: Connecting to Your Server

### Get Your Connection Details

From the Hetzner Cloud Console, note:
- **IP Address**: (e.g., 123.45.67.89)
- **Username**: `root` (default for new Ubuntu servers)

### Connect via SSH

Open your terminal and connect:

```bash
ssh root@YOUR_SERVER_IP
```

Replace `YOUR_SERVER_IP` with your actual server IP address.

**First Connection:**
- You'll see a message about host authenticity
- Type `yes` to continue
- Your computer will remember this server for future connections

**If you see "Connection refused":**
- Wait a minute (server might still be starting)
- Check your SSH key is correctly added
- Verify the IP address is correct

---

## Part 4: Initial Server Setup

Once connected, you'll see a prompt like: `root@ubuntu-dev-server:~#`

### Step 1: Update System Packages

Always start with system updates:

```bash
apt update && apt upgrade -y
```

**What this does:**
- `apt update`: Downloads package information
- `apt upgrade`: Installs available updates
- `-y`: Automatically answers "yes" to prompts

This may take 2-5 minutes.

### Step 2: Install Essential Tools

```bash
apt install -y curl wget git vim htop ufw
```

**Tools installed:**
- `curl`, `wget`: Download files
- `git`: Version control
- `vim`: Text editor
- `htop`: Better process viewer
- `ufw`: Uncomplicated Firewall (local firewall)

---

## Part 5: Installing Code-Server

Code-server is VS Code running in your browser, accessible from anywhere.

### Step 1: Download and Install Code-Server

Run the official installation script:

```bash
curl -fsSL https://code-server.dev/install.sh | sh
```

This script:
- Detects your system type
- Downloads the latest version
- Installs code-server as a system service

**Installation takes 1-2 minutes.**

### Step 2: Configure Code-Server

Create a configuration directory and file:

```bash
mkdir -p ~/.config/code-server
```

Create the configuration file:

```bash
cat > ~/.config/code-server/config.yaml << 'EOF'
bind-addr: 0.0.0.0:8080
auth: password
password: ChangeThisPassword123!
cert: false
EOF
```

**Configuration explained:**
- `bind-addr: 0.0.0.0:8080`: Listen on all network interfaces, port 8080
- `auth: password`: Use password authentication
- `password`: Your access password (CHANGE THIS!)
- `cert: false`: No HTTPS (we'll use HTTP for learning)

**IMPORTANT**: Change the password to something secure!

Edit the config file to change password:

```bash
nano ~/.config/code-server/config.yaml
```

Change the password line, then:
- Press `Ctrl+O` to save
- Press `Enter` to confirm
- Press `Ctrl+X` to exit

### Step 3: Start Code-Server

Enable and start the code-server service:

```bash
systemctl enable --now code-server@root
```

**What this does:**
- `enable`: Start code-server automatically on boot
- `--now`: Start it immediately
- `@root`: Run as root user (for learning; use dedicated user in production)

### Step 4: Verify Code-Server is Running

Check the service status:

```bash
systemctl status code-server@root
```

You should see:
- `Active: active (running)` in green
- Press `q` to exit the status view

Check if it's listening on port 8080:

```bash
ss -tulpn | grep 8080
```

You should see a line with `LISTEN` and `:8080`

---

## Part 6: Accessing Code-Server

### Open Code-Server in Your Browser

1. Open your web browser
2. Navigate to: `http://YOUR_SERVER_IP:8080`
3. Enter the password you set in the config file
4. You should now see VS Code running in your browser!

**Troubleshooting:**

If you can't connect:

1. **Check firewall allows port 8080:**
   ```bash
   # In your SSH session
   ufw status
   ```

2. **Verify code-server is running:**
   ```bash
   systemctl status code-server@root
   ```

3. **Check the logs:**
   ```bash
   journalctl -u code-server@root -n 50
   ```

4. **Verify Hetzner firewall:**
   - Go to Hetzner Cloud Console
   - Check firewall rules include port 8080

---

## Part 7: Installing the CodeLab Extension

Now that you have code-server running, let's install the CodeLab extension for interactive learning.

### Step 1: Download the CodeLab Extension

In your SSH session (not code-server), download the extension:

```bash
cd ~
wget https://github.com/mjtechguy/codelabv2/releases/download/v1.1.0/codelabv2-1.1.0.vsix
```

**Note**: If this URL doesn't work, you can transfer the `.vsix` file from your local machine using `scp`:

```bash
# On your local machine (not the server)
scp /path/to/codelabv2-1.1.0.vsix root@YOUR_SERVER_IP:/root/
```

### Step 2: Install the Extension in Code-Server

You have two options:

#### Option A: Via Command Line

```bash
code-server --install-extension ~/codelabv2-1.1.0.vsix
```

Then restart code-server:

```bash
systemctl restart code-server@root
```

#### Option B: Via Code-Server UI

1. In your browser, go to code-server
2. Click the Extensions icon (four squares) in the left sidebar
3. Click the three dots (`...`) menu at the top
4. Select **"Install from VSIX..."**
5. Navigate to `/root/codelabv2-1.1.0.vsix`
6. Click **Install**
7. Reload the window when prompted

### Step 3: Verify Installation

1. In code-server, go to Extensions
2. Search for "CodeLab"
3. You should see it installed

---

## Part 8: Setting Up the Interactive Lab

### Step 1: Create a Working Directory

In your SSH session or code-server terminal:

```bash
mkdir -p ~/labs
cd ~/labs
```

### Step 2: Download the Lab File

You'll copy the `server-basics-lab.mdcl` file to your server. You have several options:

#### Option A: Using SCP from Your Local Machine

```bash
# On your local machine
scp server-basics-lab.mdcl root@YOUR_SERVER_IP:/root/labs/
```

#### Option B: Create It Directly on the Server

Open code-server in your browser, then:
1. Click **File → Open Folder**
2. Navigate to `/root/labs`
3. Click **OK**
4. Create a new file: `server-basics-lab.mdcl`
5. Copy and paste the content from the lab file

### Step 3: Open the Lab in Code-Server

1. In code-server, open the file: `/root/labs/server-basics-lab.mdcl`
2. The CodeLab preview should automatically open on the right side
3. If it doesn't, click the CodeLab icon or press `Ctrl+Shift+P` and type "CodeLab: Open Preview"

---

## Next Steps

You now have:
- ✅ A running Ubuntu server on Hetzner
- ✅ Hetzner Cloud Firewall configured
- ✅ Code-server accessible from your browser
- ✅ CodeLab extension installed
- ✅ Ready to start the interactive lab

**Proceed to `server-basics-lab.mdcl` for hands-on learning!**

---

## Useful Commands Reference

### Server Management

```bash
# Reboot server
reboot

# Check system info
uname -a
hostnamectl

# Check disk space
df -h

# Check memory usage
free -h

# View running processes
htop
```

### Code-Server Management

```bash
# Start code-server
systemctl start code-server@root

# Stop code-server
systemctl stop code-server@root

# Restart code-server
systemctl restart code-server@root

# Check status
systemctl status code-server@root

# View logs
journalctl -u code-server@root -f
```

### Firewall Management

```bash
# Check Hetzner firewall status
# (Do this in Hetzner Cloud Console)

# Check local UFW status
ufw status

# Allow a port
ufw allow 8080/tcp

# Enable UFW
ufw enable
```

---

## Troubleshooting

### Can't Connect to Code-Server

1. **Check if code-server is running:**
   ```bash
   systemctl status code-server@root
   ```

2. **Check if port 8080 is listening:**
   ```bash
   ss -tulpn | grep 8080
   ```

3. **Check Hetzner firewall in console:**
   - Verify port 8080 is allowed
   - Verify firewall is applied to your server

4. **Check code-server logs:**
   ```bash
   journalctl -u code-server@root -n 100
   ```

### Code-Server is Slow

- Your server might be too small (upgrade to CX21/CPX21)
- Network latency (choose closer datacenter)
- Too many extensions installed

### SSH Connection Issues

1. **Wrong key:**
   ```bash
   ssh -i ~/.ssh/your_key root@YOUR_SERVER_IP
   ```

2. **Check server is running in Hetzner Console**

3. **Verify IP address is correct**

### Server Running Out of Space

```bash
# Check disk usage
df -h

# Find large directories
du -sh /* | sort -h

# Clean package cache
apt clean
apt autoremove
```

---

## Cost Management

### Server Costs
- CX11: ~€4.15/month (~$4.50/month)
- Charged per hour: ~€0.006/hour
- You can delete the server anytime to stop charges

### How to Stop Charges

**Option 1: Power Off Server**
- Server still exists (keeps IP and data)
- Still charged for reserved resources
- Quick to restart

**Option 2: Delete Server**
- Completely removes server
- Stops all charges immediately
- IP address is released
- **Data is permanently lost**

**Recommendation**: For learning, delete the server when not in use. You can recreate it quickly using this guide.

### How to Delete Your Server

1. Go to Hetzner Cloud Console
2. Select your server
3. Click **"Delete"**
4. Confirm deletion
5. Also delete any unused firewalls and volumes

---

## Security Best Practices

### For Production Servers

1. **Never use root directly:**
   - Create a regular user with sudo access
   - Disable root SSH login

2. **Restrict SSH access:**
   - Use SSH keys only (disable password auth)
   - Change SSH port from 22
   - Limit access to specific IP addresses

3. **Secure code-server:**
   - Use HTTPS with proper SSL certificate
   - Use strong password or disable password auth
   - Restrict access to your IP only
   - Consider using Tailscale VPN

4. **Keep system updated:**
   - Run `apt update && apt upgrade` regularly
   - Enable automatic security updates

5. **Use UFW (local firewall):**
   - Add additional layer besides Hetzner firewall
   - Follow principle of least privilege

6. **Enable backups:**
   - Use Hetzner's backup feature
   - Or set up your own backup solution

### For Learning (This Lab)

The configuration in this guide is intentionally simplified for learning. The security practices above should be implemented for any production server.

---

## Additional Resources

- [Hetzner Cloud Documentation](https://docs.hetzner.com/cloud/)
- [Code-Server Documentation](https://coder.com/docs/code-server)
- [Ubuntu Server Guide](https://ubuntu.com/server/docs)
- [Digital Ocean Tutorials](https://www.digitalocean.com/community/tutorials) (work for most cloud providers)

---

## What's Next?

After completing the interactive lab (`server-basics-lab.mdcl`), you'll be ready to:
- Deploy your own applications
- Set up databases
- Configure web servers
- Implement CI/CD pipelines
- Learn Docker and containers
- Explore Kubernetes

**Now open `server-basics-lab.mdcl` and start learning!**