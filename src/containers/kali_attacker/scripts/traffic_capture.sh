#!/bin/bash

# Traffic Capture Script
# Captures network traffic for later analysis

echo "=== Traffic Capture Script ==="

# Configuration variables
INTERFACE="${1:-eth0}"
CAPTURE_FILE="/captures/traffic_$(date +%Y%m%d_%H%M%S).pcap"
DURATION="${2:-60}"  # Duration in seconds

echo "Interface: $INTERFACE"
echo "Capture file: $CAPTURE_FILE"
echo "Duration: $DURATION seconds"
echo ""

# Create directory if it doesn't exist
mkdir -p /captures

# Verify that the interface exists
if ! ip link show $INTERFACE > /dev/null 2>&1; then
    echo "Error: Interface $INTERFACE does not exist"
    echo "Available interfaces:"
    ip link show
    exit 1
fi

echo "Starting traffic capture..."
echo "Press Ctrl+C to stop early"
echo ""

# Cleanup function
cleanup() {
    echo ""
    echo "Stopping traffic capture..."
    if [ ! -z "$TCPDUMP_PID" ] && kill -0 $TCPDUMP_PID 2>/dev/null; then
        kill $TCPDUMP_PID
        wait $TCPDUMP_PID 2>/dev/null
    fi
    
    if [ -f "$CAPTURE_FILE" ]; then
        echo "Capture saved to: $CAPTURE_FILE"
        echo "File size: $(ls -lh $CAPTURE_FILE | awk '{print $5}')"
        echo ""
        echo "Capture summary (first 10 lines):"
        tcpdump -r $CAPTURE_FILE -nn -c 10 2>/dev/null || echo "Could not read capture file"
    fi
    exit 0
}

# Configure trap to cleanup on SIGINT (Ctrl+C)
trap cleanup SIGINT

# Capture traffic with tcpdump
echo "Running: tcpdump -i $INTERFACE -w $CAPTURE_FILE"
tcpdump -i $INTERFACE -w $CAPTURE_FILE &
TCPDUMP_PID=$!

# Wait for the specified duration
echo "Capturing traffic for $DURATION seconds..."
sleep $DURATION

# Stop tcpdump
cleanup
