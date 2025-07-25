#!/bin/bash

# Tool Verification Script
# Verifies that all necessary tools are installed and working

echo "=== Tool Verification Script ==="
echo "Verifying tools needed for the laboratory..."
echo ""

# Function to verify a tool
check_tool() {
    local tool=$1
    local show_version=$2
    
    echo -n "Checking $tool... "
    
    if command -v $tool > /dev/null 2>&1; then
        echo "✓ INSTALLED"
        if [ "$show_version" = "true" ]; then
            # Special handling for tools with different flags
            case $tool in
                "ettercap")
                    local version=$(ettercap --version 2>&1 | grep "ettercap" | head -n1)
                    if [ ! -z "$version" ]; then
                        echo "  Version: $version"
                    else
                        echo "  Version: available"
                    fi
                    ;;
                "netdiscover")
                    echo "  Status: available (network discovery tool)"
                    ;;
                "tshark")
                    local version=$(tshark --version 2>&1 | head -n1 | grep -v "Running as")
                    if [ ! -z "$version" ]; then
                        echo "  Version: $version"
                    else
                        echo "  Version: available"
                    fi
                    ;;
                "ip")
                    echo "  Version: $(ip -V 2>&1)"
                    ;;
                "arp"|"nslookup")
                    echo "  Status: available"
                    ;;
                *)
                    # Try different version flags
                    for flag in "--version" "-V" "-v" "version"; do
                        local version_output=$($tool $flag 2>&1 | head -n1)
                        if echo "$version_output" | grep -qi "version\|copyright\|^[a-zA-Z].*[0-9]"; then
                            echo "  Version: $version_output"
                            break
                        fi
                    done
                    ;;
            esac
        fi
    else
        echo "✗ NOT FOUND"
        return 1
    fi
    echo ""
}

# Verify main tools
echo "=== Network Tools ==="
check_tool "ettercap" true
check_tool "tcpdump" true
check_tool "nmap" true
check_tool "arp-scan" true
check_tool "netdiscover" true

echo "=== System Tools ==="
check_tool "ip" true
check_tool "arp" false
check_tool "nslookup" false
check_tool "ping" true

echo "=== Analysis Tools ==="
check_tool "tshark" true
check_tool "curl" true
check_tool "wget" true

echo "=== Scripting Tools ==="
check_tool "python3" true
check_tool "hping3" true

# Verify ettercap plugins
echo "=== Verifying Ettercap Plugins ==="
if command -v ettercap > /dev/null 2>&1; then
    echo "Available plugins:"
    ettercap -P list 2>/dev/null || echo "Could not list plugins"
    echo ""
    
    echo "Checking dns_spoof plugin..."
    if ettercap -P list 2>/dev/null | grep -q dns_spoof; then
        echo "✓ dns_spoof plugin available"
    else
        echo "✗ dns_spoof plugin NOT available"
    fi
else
    echo "ettercap is not installed"
fi

echo ""

# Verify network capabilities
echo "=== Verifying Network Capabilities ==="
echo "Available network interfaces:"
ip link show
echo ""

echo "Current IP configuration:"
ip addr show
echo ""

echo "Routing table:"
ip route show
echo ""

echo "Checking IP forwarding:"
current_forward=$(cat /proc/sys/net/ipv4/ip_forward 2>/dev/null || echo "Not available")
echo "Current IP forwarding: $current_forward"

if [ "$current_forward" = "1" ]; then
    echo "✓ IP forwarding is enabled"
else
    echo "⚠ IP forwarding is disabled"
    echo "  Attempting to enable..."
    if sysctl -w net.ipv4.ip_forward=1 > /dev/null 2>&1; then
        echo "✓ IP forwarding enabled successfully"
    else
        echo "✗ Could not enable IP forwarding"
    fi
fi

echo ""
echo "=== Verification Completed ==="

# Count verified tools
tools_checked=0
tools_failed=0

# Re-verify critical tools for final report
critical_tools=("ettercap" "tcpdump" "nmap" "arp" "nslookup")
echo "Critical tools for the laboratory:"
for tool in "${critical_tools[@]}"; do
    if command -v $tool > /dev/null 2>&1; then
        echo "  ✓ $tool"
        ((tools_checked++))
    else
        echo "  ✗ $tool - NOT AVAILABLE"
        ((tools_failed++))
    fi
done

echo ""
if [ $tools_failed -eq 0 ]; then
    echo "🎉 STATUS: All critical tools are available"
    echo "📋 The container is ready to run the laboratory"
    echo ""
    echo "To start the attacks, run:"
    echo "  /scripts/lab1_menu.sh"
else
    echo "⚠️  STATUS: $tools_failed critical tools are missing"
    echo "📋 Install the missing tools before continuing"
fi
