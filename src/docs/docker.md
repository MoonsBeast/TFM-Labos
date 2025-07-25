# Docker Setup Guide

<div class="hero-section">
    <h2>🐋 Complete Docker Environment Setup</h2>
    <p class="hero-description">
        Step-by-step guide to configure Docker for cybersecurity laboratories. 
        Includes WSL2 setup for Windows users and Docker installation.
    </p>
</div>

## 📋 Overview

This guide will walk you through the process of setting up Docker in your development environment, with special focus on Windows WSL2 setup and Docker installation for cybersecurity laboratories.

## ✅ Prerequisites

Before starting this guide, ensure you have:

<div class="prerequisites-grid">
    <div class="prereq-card">
        <div class="prereq-icon">💻</div>
        <div class="prereq-content">
            <h3>System Requirements</h3>
            <ul>
                <li>Windows 10/11 (WSL2) or Linux</li>
                <li>At least 8GB RAM</li>
                <li>20GB free disk space</li>
            </ul>
        </div>
    </div>
    
    <div class="prereq-card">
        <div class="prereq-icon">👤</div>
        <div class="prereq-content">
            <h3>Access Rights</h3>
            <ul>
                <li>Administrative/sudo privileges</li>
                <li>Ability to modify system settings</li>
                <li>Network connectivity</li>
            </ul>
        </div>
    </div>
</div>

## 🪟 Part 1: WSL2 Setup (Windows Only)

!!! info "Windows Users Only"
    If you're using Linux, skip to [Part 2: Docker Installation](#part-2-docker-installation)

### 1.1. Installing WSL2 and Linux Distribution

First, check available Linux distributions:

=== "PowerShell (Administrator)"
    ```powershell
    wsl --list --online
    ```

Install your preferred distribution (WSL2 is installed by default):

=== "Ubuntu (Recommended)"
    ```powershell
    wsl --install Ubuntu
    ```
    
=== "Other Distributions"
    ```powershell
    wsl --install <Distro-Name>
    # Example: wsl --install Debian
    ```

### 1.2. Verify WSL Version

Check your WSL version:

```powershell
wsl -l -v
```

Expected output:
```
  NAME      STATE           VERSION
* Ubuntu    Running         2
```

If not using version 2, upgrade with:

```powershell
wsl --set-version Ubuntu 2
```

### 1.3. Update Linux Distribution

Access your WSL2 environment and update:

=== "Ubuntu/Debian"
    ```bash
    sudo apt update && sudo apt upgrade -y
    ```
    
=== "CentOS/RHEL"
    ```bash
    sudo dnf update -y
    ```

!!! tip "WSL2 Performance"
    For better performance, store your project files within the WSL2 filesystem rather than the Windows filesystem.

## 🐋 Part 2: Docker Installation

### 2.1. Set Up Docker Repository

Install required packages:

=== "Ubuntu/Debian"
    ```bash
    sudo apt install -y ca-certificates curl gnupg lsb-release
    ```
    
=== "CentOS/RHEL"
    ```bash
    sudo dnf install -y ca-certificates curl gnupg
    ```

Set up Docker's official GPG key:

=== "Ubuntu/Debian"
    ```bash
    # Create keyring directory
    sudo install -m 0755 -d /etc/apt/keyrings
    
    # Add Docker's GPG key
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | \
      sudo tee /etc/apt/keyrings/docker.asc > /dev/null
    
    # Set permissions
    sudo chmod a+r /etc/apt/keyrings/docker.asc
    ```

Add the repository to APT sources:

```bash
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] \
  https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
```

Update package index:

```bash
sudo apt update
```

### 2.2. Install Docker and Docker Compose

Install Docker and all required components:

```bash
sudo apt install -y \
  docker-ce \
  docker-ce-cli \
  containerd.io \
  docker-buildx-plugin \
  docker-compose-plugin \
  docker-compose
```

### 2.3. Verify Installation

Check Docker version:

```bash
docker --version
docker compose version
```

Expected output:
```
Docker version 24.0.x, build xxxxx
Docker Compose version v2.x.x
```

Run test container (optional but recommended):

```bash
sudo docker run hello-world
```

### 2.4. Post-Installation Steps

Add your user to the docker group to run Docker without sudo:

```bash
sudo usermod -aG docker $USER
```

!!! warning "Important"
    After adding yourself to the docker group, you must **log out and back in** (or restart your terminal/WSL2) for the changes to take effect.

Verify Docker works without sudo:

```bash
# After logging back in
docker run hello-world
```

### 2.5. Configure Docker Service

Enable Docker to start on boot:

```bash
sudo systemctl enable docker
sudo systemctl start docker
```

Verify Docker is running:

```bash
sudo systemctl status docker
```

Common service management commands:

=== "Service Control"
    ```bash
    # Stop Docker service
    sudo systemctl stop docker
    
    # Restart Docker service
    sudo systemctl restart docker
    
    # Check service status
    sudo systemctl status docker
    ```

## 🔧 Laboratory-Specific Configuration

### Privileged Container Support

For cybersecurity laboratories, we need containers with network capabilities:

```bash
# Test privileged container support
docker run --rm --privileged --cap-add=NET_ADMIN alpine ip link show
```

### Network Configuration

Verify Docker can create custom networks:

```bash
# Create test network
docker network create test-lab-network

# List networks
docker network ls

# Remove test network
docker network rm test-lab-network
```

## 🚀 Quick Validation

Test your complete setup:

=== "Complete Test"
    ```bash
    # Clone laboratory repository
    git clone <repository-url>
    cd TFM-Labos/src
    
    # Build and start laboratory environment
    docker-compose up -d
    
    # Check all containers are running
    docker-compose ps
    
    # Clean up
    docker-compose down
    ```

## 🐛 Troubleshooting

<div class="troubleshooting-section">
    <div class="trouble-card">
        <div class="trouble-header">🪟 WSL2 Issues</div>
        <div class="trouble-content">
            <ul>
                <li>Ensure WSL2 is enabled in Windows Features</li>
                <li>Update to latest WSL2 kernel</li>
                <li>Check virtualization is enabled in BIOS</li>
            </ul>
        </div>
    </div>
    
    <div class="trouble-card">
        <div class="trouble-header">🐋 Docker Issues</div>
        <div class="trouble-content">
            <ul>
                <li>Verify all installation steps completed</li>
                <li>Check Docker daemon is running</li>
                <li>Ensure user is in docker group</li>
            </ul>
        </div>
    </div>
    
    <div class="trouble-card">
        <div class="trouble-header">🌐 Network Issues</div>
        <div class="trouble-content">
            <ul>
                <li>Check firewall settings</li>
                <li>Verify network connectivity</li>
                <li>Test DNS resolution</li>
            </ul>
        </div>
    </div>
</div>

### Common Solutions

!!! failure "Docker Permission Denied"
    ```bash
    # If you get permission denied errors
    sudo chmod 666 /var/run/docker.sock
    # Or better: ensure user is in docker group and restart session
    ```

!!! failure "WSL2 Not Starting"
    ```powershell
    # In PowerShell as Administrator
    wsl --shutdown
    wsl --unregister Ubuntu
    wsl --install Ubuntu
    ```

!!! failure "Container Networking Issues"
    ```bash
    # Reset Docker networks
    docker network prune
    
    # Restart Docker service
    sudo systemctl restart docker
    ```

## ✅ Verification Checklist

Before proceeding to the laboratories, verify:

- [ ] Docker is installed and running
- [ ] Docker Compose is available
- [ ] User can run Docker without sudo
- [ ] Privileged containers can be created
- [ ] Custom networks can be created
- [ ] Internet connectivity works from containers

<div class="page-nav">
    <a href="../" class="previous">
        ← Home
    </a>
    <a href="../lab1/" class="next">
        Laboratory 1: ARP & DNS Spoofing →
    </a>
</div>

<style>
.prerequisites-grid {
    display: grid;
    grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
    gap: 1.5rem;
    margin: 2rem 0;
}

.prereq-card {
    display: flex;
    background: var(--md-default-bg-color);
    border: 1px solid var(--md-default-fg-color--lightest);
    border-radius: var(--lab-border-radius);
    padding: 1.5rem;
    box-shadow: var(--lab-shadow);
}

.prereq-icon {
    font-size: 2rem;
    margin-right: 1rem;
    flex-shrink: 0;
}

.prereq-content h3 {
    margin: 0 0 0.5rem 0;
    color: var(--lab-primary);
}

.troubleshooting-section {
    display: grid;
    grid-template-columns: repeat(auto-fit, minmax(280px, 1fr));
    gap: 1rem;
    margin: 2rem 0;
}

.trouble-card {
    background: var(--md-default-bg-color);
    border: 1px solid var(--md-default-fg-color--lightest);
    border-radius: var(--lab-border-radius);
    overflow: hidden;
    box-shadow: var(--lab-shadow);
}

.trouble-header {
    background: var(--lab-warning);
    color: white;
    padding: 1rem;
    font-weight: 600;
}

.trouble-content {
    padding: 1rem;
}

.trouble-content ul {
    margin: 0;
    padding-left: 1.2rem;
}

@media (max-width: 768px) {
    .prereq-card {
        flex-direction: column;
        text-align: center;
    }
    
    .prereq-icon {
        margin: 0 0 1rem 0;
    }
}
</style>

