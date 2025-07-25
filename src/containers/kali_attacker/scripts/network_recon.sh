#!/bin/bash

# Network Reconnaissance Script
# Discovers active hosts on the network and gathers information

echo "=== Network Reconnaissance Script ==="
echo "Discovering local network..."
echo ""

# Get network interface information
INTERFACE=$(ip route | grep default | awk '{print $5}' | head -n1)
# Get local network from routing table
NETWORK=$(ip route | grep $INTERFACE | grep -v default | grep -E '192\.168\.|172\.|10\.' | head -n1 | awk '{print $1}')

# If network is not found, try to get it another way
if [ -z "$NETWORK" ]; then
    # Get interface IP and calculate network
    IP=$(ip addr show $INTERFACE | grep -E 'inet [0-9]' | grep -v 127.0.0.1 | awk '{print $2}' | cut -d'/' -f1)
    CIDR=$(ip addr show $INTERFACE | grep -E 'inet [0-9]' | grep -v 127.0.0.1 | awk '{print $2}' | cut -d'/' -f2)
    
    # For common /24 networks, use the IP base with /24
    if [ "$CIDR" = "24" ]; then
        BASE_IP=$(echo $IP | cut -d'.' -f1-3)
        NETWORK="${BASE_IP}.0/24"
    else
        # For other cases, use the IP with /24 as approximation
        BASE_IP=$(echo $IP | cut -d'.' -f1-3)
        NETWORK="${BASE_IP}.0/24"
    fi
fi

echo "Interface: $INTERFACE"
echo "Network: $NETWORK"
echo ""

# Active host scanning
if [ -z "$NETWORK" ] || [ "$NETWORK" = "default" ]; then
    echo "Error: Could not determine local network."
    echo "Trying to use 192.168.1.0/24 as default network..."
    NETWORK="192.168.1.0/24"
fi

echo "Scanning active hosts in $NETWORK..."
nmap -sn $NETWORK | grep -E "Nmap scan report|MAC Address"
echo ""

# Show current ARP table
echo "Current ARP table:"
arp -a
echo ""

# Port scanning on discovered hosts
echo "Scanning common ports on active hosts..."
for ip in $(nmap -sn $NETWORK | grep "Nmap scan report" | awk '{print $5}'); do
    echo "Scanning $ip..."
    nmap -F $ip | head -n 20
    echo ""
done

echo "Reconnaissance completed."
