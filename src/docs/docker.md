# Docker Setup Guide

## Overview

This guide will walk you through the process of setting up Docker in your development environment, with special focus on Windows WSL2 setup and Docker installation.

## Prerequisites

Before starting this guide, make sure you have:

- A Windows system (if following the WSL2 setup)
- Administrative access to your system
- A stable internet connection

## Part 1: WSL2 Setup (Windows Only)

If you're using Windows, it's recommended to set up WSL2 (Windows Subsystem for Linux) first.

### 1.1. Installing WSL2 and Linux Distribution

First, check available Linux distributions:

```powershell
wsl --list --online
```

Install your preferred distribution (WSL2 is installed by default):

```powershell
wsl --install <Distro>
```

### 1.2. Verify WSL Version

Check your WSL version:

```powershell
wsl -l -v
```

If not using version 2, upgrade with:

```powershell
wsl --set-version <Distro> 2
```

### 1.3. Updating WSL2 Distro

1. Update your Linux distribution:

```bash
sudo apt update && sudo apt upgrade -y
```

## Part 2: Docker Installation

### 2.1. Set Up Docker Repository

Install required packages:

```bash
sudo apt install -y ca-certificates curl gnupg
```

Set up Docker's official GPG key:

```bash
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo tee /etc/apt/keyrings/docker.asc > /dev/null
sudo chmod a+r /etc/apt/keyrings/docker.asc
```

Add the repository to APT sources:

```bash
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
```

Update package index:

```shell
sudo apt update
```

### 2.2. Install Docker

Install Docker and related packages:

```bash
sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin docker-compose
```

### 2.3. Verify Installation

Check Docker version and run test container (Optional):

```shell
docker --version
sudo docker run hello-world # Optional
```

### 2.4. Post-Installation Steps

Add your user to the docker group (eliminates need for sudo):

```shell
sudo usermod -aG docker $USER
```

!!! note
    After adding yourself to the docker group, log out and back in for the changes to take effect.

Verify docker works without sudo:

```shell
docker run hello-world
```

### 2.5. Configure Docker Service

Enable Docker to start on boot:

```bash
sudo systemctl enable docker
sudo systemctl start docker
```

Common service commands:

```bash
# Stop Docker service
sudo systemctl stop docker

# Restart Docker service
sudo systemctl restart docker
```

## Troubleshooting

If you encounter any issues:

1. Verify WSL2 is running properly (Windows users)
2. Ensure all installation steps were completed successfully
3. Check system requirements are met
4. Verify network connectivity for docker pulls

!!! tip
    Remember to log out and back in after adding your user to the docker group to apply the changes.

<div class="page-nav">
    <a href="/" class="previous">
        ← Previous: Home
    </a>
    <a href="lab1" class="next">
        Next: Practice 1 →
    </a>
</div>

