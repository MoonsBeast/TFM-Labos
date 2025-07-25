FROM kalilinux/kali-rolling

# Update system and install pentesting tools
RUN apt-get update && apt-get install -y \
    ettercap-text-only \
    ettercap-common \
    dsniff \
    tcpdump \
    nmap \
    net-tools \
    iputils-ping \
    arp-scan \
    netdiscover \
    wireshark-common \
    tshark \
    curl \
    wget \
    vim \
    nano \
    python3 \
    python3-pip \
    python3-scapy \
    hping3 \
    iproute2 \
    procps \
    dnsutils \
    && rm -rf /var/lib/apt/lists/*

# Configure ettercap for DNS spoofing
RUN mkdir -p /etc/ettercap && \
    echo "# Ettercap DNS spoofing configuration" > /etc/ettercap/etter.dns && \
    echo "# Default entries will be added by scripts" >> /etc/ettercap/etter.dns

# Create directory for scripts and captures
RUN mkdir -p /scripts /captures

# Copy attack scripts
COPY ./containers/kali_attacker/scripts /scripts

# Make scripts executable
RUN chmod +x /scripts/*.sh

# Configure environment
WORKDIR /scripts

# Verify that tools are available (without running commands that require permissions)
RUN echo "Verifying tool availability..." && \
    which ettercap && echo "✓ ettercap available" && \
    which tcpdump && echo "✓ tcpdump available" && \
    which nmap && echo "✓ nmap available" && \
    which arp && echo "✓ arp available" && \
    which nslookup && echo "✓ nslookup available" && \
    echo "All tools are available"

# Keep container active
CMD ["/bin/bash"]
