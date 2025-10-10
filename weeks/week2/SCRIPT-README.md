# Week 2 Infrastructure Setup Script

This automated setup script handles the complete installation and configuration of the Week 2 infrastructure in a single command.

## What This Script Does

The script automates all manual steps from the Week 2 guides:

### 1. **Docker Installation** (from `02-install-docker.mdcl`)
- Removes any old Docker installations
- Adds Docker's official repository
- Installs Docker Engine and Docker Compose V2
- Configures Docker with best practices (log rotation)
- Enables Docker to start on boot

### 2. **Infrastructure Setup**
- Creates custom Docker network (`nginx-proxy-network`)
- Creates Docker volumes for persistent data
- Sets up organized project directory structure

### 3. **Nginx Proxy Manager Deployment** (from `03-nginx-proxy-manager.mdcl`)
- Creates docker-compose.yml configuration
- Deploys NPM container with proper settings
- Configures ports (80, 443, 81)
- Sets up health checks

### 4. **Code-Server Deployment** (from `04-code-server-docker.mdcl`)
- Generates secure random password
- Creates docker-compose.yml configuration
- Deploys Code-Server container
- Saves password for reference

### 5. **Verification and Helpers**
- Verifies all services are running correctly
- Creates helpful Docker command aliases
- Displays comprehensive access information

## Prerequisites

Before running this script, ensure:

- ✅ Ubuntu 22.04 LTS server
- ✅ Root or sudo privileges
- ✅ Internet connectivity
- ✅ Ports 80, 443, 81, and 8443 open in firewall
- ✅ Domain name purchased (configure DNS separately)

## Usage

### Download and Run

```bash
# Make the script executable
chmod +x setup-week2-infrastructure.sh

# Run the script with sudo
sudo bash setup-week2-infrastructure.sh
```

### What to Expect

The script will:
1. Display colored output showing progress
2. Run for approximately 5-10 minutes (depending on internet speed)
3. Display any errors in red
4. Show a comprehensive summary at the end

### Script Output

The script uses colored output for clarity:
- 🔵 **Blue** = Information messages
- 🟢 **Green** = Success messages
- 🟡 **Yellow** = Warnings
- 🔴 **Red** = Errors

## After Running the Script

### Immediate Access

Once the script completes, you can immediately access:

**Nginx Proxy Manager Admin:**
- URL: `http://YOUR_SERVER_IP:81`
- Email: `admin@example.com`
- Password: `changeme`
- ⚠️ **CHANGE PASSWORD ON FIRST LOGIN!**

**Code-Server (VS Code):**
- URL: `http://YOUR_SERVER_IP:8443`
- Password: Generated and saved to `~/docker/code-server/PASSWORD.txt`

### Next Steps

1. **Change NPM Password**
   - Log into NPM admin panel
   - Change default password immediately

2. **Configure DNS**
   - Point your domain to your server IP
   - Create A records in Cloudflare for:
     - `code.yourdomain.com` → Server IP
     - `npm.yourdomain.com` → Server IP (optional)

3. **Create Proxy Host in NPM**
   - Add proxy host for `code.yourdomain.com`
   - Forward to `code-server:8443`
   - Request SSL certificate from Let's Encrypt

4. **Access via HTTPS**
   - Visit `https://code.yourdomain.com`
   - Enjoy secure access to VS Code in your browser!

## Files Created by Script

```
~/docker/
├── nginx-proxy-manager/
│   └── docker-compose.yml          # NPM configuration
└── code-server/
    ├── docker-compose.yml          # Code-Server configuration
    └── PASSWORD.txt                # Generated password
```

## Docker Resources Created

**Volumes:**
- `npm-data` - NPM database and configurations
- `npm-letsencrypt` - SSL/TLS certificates
- `code-server-data` - VS Code config and projects

**Network:**
- `nginx-proxy-network` - Custom bridge network for container communication

**Containers:**
- `nginx-proxy-manager` - Reverse proxy and SSL management
- `code-server` - VS Code in browser

## Useful Commands (Added as Aliases)

After running the script, these aliases are available (after `source ~/.bashrc`):

```bash
# View containers
dps              # docker ps
dpsa             # docker ps -a

# View images
di               # docker images

# Execute commands in containers
dex              # docker exec -it

# View logs
dl               # docker logs
dlf              # docker logs -f

# Docker Compose shortcuts
dcu              # docker compose up -d
dcd              # docker compose down
dcl              # docker compose logs -f
dcr              # docker compose restart

# Quick directory access
npm-dir          # cd ~/docker/nginx-proxy-manager
code-dir         # cd ~/docker/code-server
```

## Managing Services

### Start All Services
```bash
cd ~/docker/nginx-proxy-manager && docker compose up -d
cd ~/docker/code-server && docker compose up -d
```

### Stop All Services
```bash
cd ~/docker/nginx-proxy-manager && docker compose down
cd ~/docker/code-server && docker compose down
```

### Restart a Service
```bash
cd ~/docker/nginx-proxy-manager && docker compose restart
cd ~/docker/code-server && docker compose restart
```

### View Logs
```bash
# NPM logs
cd ~/docker/nginx-proxy-manager && docker compose logs -f

# Code-Server logs
cd ~/docker/code-server && docker compose logs -f
```

### Check Container Status
```bash
docker ps
docker compose ps  # (run from project directory)
```

## Troubleshooting

### Script Fails During Execution

If the script fails:

1. **Check the error message** - Script shows detailed error output
2. **Run with verbose output** - Already enabled with `set -x`
3. **Check logs** - View Docker container logs:
   ```bash
   docker logs nginx-proxy-manager
   docker logs code-server
   ```

### Can't Access Services

**NPM Admin Panel (port 81):**
```bash
# Check if NPM is running
docker ps | grep nginx-proxy-manager

# Check if port is listening
ss -tulpn | grep :81

# Check firewall
ufw status | grep 81
```

**Code-Server (port 8443):**
```bash
# Check if code-server is running
docker ps | grep code-server

# Check if port is listening
ss -tulpn | grep :8443

# Check firewall
ufw status | grep 8443
```

### Services Not Starting

**View container logs:**
```bash
cd ~/docker/nginx-proxy-manager
docker compose logs --tail=50

cd ~/docker/code-server
docker compose logs --tail=50
```

**Restart services:**
```bash
cd ~/docker/nginx-proxy-manager
docker compose restart

cd ~/docker/code-server
docker compose restart
```

### Clean Reinstall

If you need to start over:

```bash
# Stop and remove containers
cd ~/docker/nginx-proxy-manager && docker compose down
cd ~/docker/code-server && docker compose down

# Remove volumes (⚠️ deletes all data!)
docker volume rm npm-data npm-letsencrypt code-server-data

# Remove network
docker network rm nginx-proxy-network

# Run script again
sudo bash setup-week2-infrastructure.sh
```

## What the Script Does NOT Do

The script automates installation but does NOT:

- ❌ Configure DNS (you must do this manually in Cloudflare/Namecheap)
- ❌ Create proxy hosts in NPM (you must do this via web interface)
- ❌ Request SSL certificates (done through NPM web interface)
- ❌ Configure Cloudflare proxy/firewall (optional security step)
- ❌ Set up basic authentication (optional NPM access lists)

These steps require manual configuration through web interfaces.

## Security Considerations

### Immediate Actions Required

1. **Change NPM password** - Default password is publicly known
2. **Save Code-Server password** - Generated randomly, save securely
3. **Configure firewall** - Ensure only necessary ports are open
4. **Set up SSL** - Use Let's Encrypt via NPM for HTTPS

### Optional Security Enhancements

After basic setup:
- Configure Cloudflare IP allowlisting (see `03-nginx-proxy-manager.mdcl` Part 17)
- Enable NPM Access Lists for basic auth (see `03-nginx-proxy-manager.mdcl` Part 18)
- Restrict port 81 access to your IP only
- Use SSH tunnel for NPM admin access

## Script Features

### Error Handling
- `set -e` - Exits immediately on any error
- `set -x` - Shows all commands as they execute
- Detailed error messages with color coding

### Idempotency
- Checks if resources already exist before creating
- Safe to run multiple times (won't duplicate resources)
- Won't fail if Docker is already installed

### Verification
- Tests Docker installation with hello-world
- Verifies all containers are running
- Checks health status of services
- Displays comprehensive summary

### User-Friendly Output
- Color-coded messages (info, success, warning, error)
- Section headers for clarity
- Detailed progress indicators
- Final summary with all access information

## Learning Value

While this script automates the process, it's still valuable to:

1. **Read the script** - Extensively commented to explain each step
2. **Understand the commands** - Learn what each Docker command does
3. **Follow the manual guides** - Understand why each step is necessary
4. **Troubleshoot manually** - Learn to debug when things go wrong

The script is a teaching tool as much as an automation tool.

## Support

If you encounter issues:

1. Check the error message in the script output
2. Review the relevant manual guide in `weeks/week2/`
3. Check Docker logs: `docker logs <container-name>`
4. Verify system requirements are met
5. Ensure internet connectivity is stable

## Version History

- **v1.0** - Initial release
  - Complete Docker installation
  - NPM deployment
  - Code-Server deployment
  - Comprehensive verification
  - User-friendly output

## License

Part of BroTech Labs Training Course - Week 2

---

**Note:** This script is designed for learning environments. For production use, consider additional security hardening and testing.
