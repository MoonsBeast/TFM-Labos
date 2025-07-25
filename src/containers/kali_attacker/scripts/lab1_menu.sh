#!/bin/bash

# Lab1 Menu - Interactive menu for Laboratory 1

echo "======================================"
echo "    LABORATORY 1 - ARP & DNS SPOOFING"
echo "======================================"
echo ""
echo "Select an option:"
echo ""
echo "1) Network reconnaissance"
echo "2) Network monitor (detect changes)"
echo "3) ARP Spoofing"
echo "4) DNS Spoofing"
echo "5) Capture traffic"
echo "6) Verify installed tools"
echo "7) Verify network status"
echo "8) Exit"
echo ""

read -p "Option: " choice

case $choice in
    1)
        echo "Executing network reconnaissance..."
        /scripts/network_recon.sh
        ;;
    2)
        echo "Starting network monitor..."
        /scripts/monitor.sh
        ;;
    3)
        echo "Configuring ARP Spoofing..."
        read -p "Victim IP [192.168.1.30]: " victim_ip
        victim_ip=${victim_ip:-192.168.1.30}
        read -p "Target IP to impersonate [192.168.1.1 for gateway, 192.168.1.4 for DNS]: " target_ip
        target_ip=${target_ip:-192.168.1.1}
        /scripts/arp_spoof.sh $victim_ip $target_ip
        ;;
    4)
        echo "Configuring DNS Spoofing..."
        echo "NOTE: This script executes ARP spoofing against the DNS server"
        read -p "Victim IP [192.168.1.30]: " victim_ip
        victim_ip=${victim_ip:-192.168.1.30}
        read -p "DNS server to impersonate [192.168.1.4]: " dns_server
        dns_server=${dns_server:-192.168.1.4}
        read -p "Malicious server [192.168.1.100]: " evil_server
        evil_server=${evil_server:-192.168.1.100}
        read -p "Target domain [goodserver.com]: " domain
        domain=${domain:-goodserver.com}
        /scripts/dns_spoof.sh $victim_ip $dns_server $evil_server $domain
        ;;
    5)
        echo "Configuring traffic capture..."
        read -p "Duration in seconds [60]: " duration
        duration=${duration:-60}
        /scripts/traffic_capture.sh eth0 $duration
        ;;
    6)
        echo "Verifying installed tools..."
        /scripts/verify_tools.sh
        ;;
    7)
        echo "Current network status:"
        echo ""
        echo "Network interface:"
        ip addr show eth0
        echo ""
        echo "ARP table:"
        arp -a
        echo ""
        echo "Routing table:"
        ip route show
        echo ""
        echo "DNS resolution (goodserver.com):"
        nslookup goodserver.com
        ;;
    8)
        echo "Exiting..."
        exit 0
        ;;
    *)
        echo "Invalid option"
        ;;
esac
