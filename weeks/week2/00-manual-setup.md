# Manual Setup Steps

This document outlines the manual steps that need to be completed before proceeding with the Week 2 infrastructure setup.

## Prerequisites

The following tasks must be completed manually:

### 1. Domain Name Registration

- **Platform**: Namecheap
- **Task**: Purchase a domain name for the project
- **Notes**: Choose a domain that will be used for all services and applications in this training

### 2. DNS Configuration

- **Platform**: Cloudflare
- **Task**: Configure DNS for the purchased domain
- **Steps**:
  - Add the domain to Cloudflare
  - Update nameservers on Namecheap to point to Cloudflare
  - Configure initial DNS records as needed

### 3. Server Infrastructure

- **Platform**: Hetzner
- **Task**: Create server instances
- **Notes**: Create the necessary cloud server instances that will host the infrastructure
- **Considerations**:
  - Choose appropriate instance sizes based on requirements
  - Select the correct datacenter region
  - Configure networking and firewall rules as needed

## After Manual Setup

Once these manual steps are completed, you can proceed with the automated configuration steps outlined in the subsequent guides:

1. Ubuntu Server Preparation
2. Docker Installation
3. Nginx Proxy Manager Setup
4. Code Server Docker Deployment
5. DNS and NPM Configuration

---

**Note**: Keep track of all credentials, IP addresses, and configuration details from these manual steps as they will be needed in the subsequent setup guides.
