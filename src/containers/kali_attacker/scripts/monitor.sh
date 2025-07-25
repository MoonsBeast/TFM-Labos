#!/bin/bash

# Monitor Script - Monitors changes in ARP and DNS tables
# Useful for detecting spoofing attacks

echo "=== Network Monitor Script ==="
echo "Monitoring ARP and DNS changes..."
echo "Press Ctrl+C to stop"
echo ""

# Temporary files for comparison
ARP_PREV="/tmp/arp_prev.txt"
ARP_CURR="/tmp/arp_curr.txt"

# Get initial ARP table
arp -a > $ARP_PREV
echo "Initial ARP table:"
cat $ARP_PREV
echo ""

# Function to check ARP changes
check_arp_changes() {
    arp -a > $ARP_CURR
    
    # Compare with previous state
    if ! diff -q $ARP_PREV $ARP_CURR > /dev/null 2>&1; then
        echo "[$(date)] ARP TABLE CHANGE DETECTED!"
        echo "Differences:"
        diff $ARP_PREV $ARP_CURR
        echo ""
        
        # Update reference
        cp $ARP_CURR $ARP_PREV
    fi
}

# Function to check DNS resolution
check_dns_resolution() {
    local domain="goodserver.com"
    local current_ip=$(nslookup $domain 2>/dev/null | grep "Address:" | tail -n1 | awk '{print $2}')
    
    if [ ! -z "$current_ip" ]; then
        echo "[$(date)] $domain resolves to: $current_ip"
        
        # Check if it's the expected IP
        if [ "$current_ip" != "192.168.1.10" ]; then
            echo "⚠️  ALERT: DNS possibly compromised for $domain"
        fi
    fi
}

# Main monitoring loop
while true; do
    check_arp_changes
    check_dns_resolution
    sleep 5
done
