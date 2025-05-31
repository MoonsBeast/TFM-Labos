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

### 1. Laboratory Environment

<div class="network-diagram secure">
<h4>Lab Network Topology</h4>
<div class="device attacker">Kali Linux<br/>192.168.1.100<br/>Attack Machine</div>
<span class="arrow">↔</span>
<div class="device router">Router/Gateway<br/>192.168.1.1</div>
<span class="arrow">↔</span>
<div class="device client">Target Machine<br/>192.168.1.10<br/>Victim</div>
<br/><br/>
<div class="interactive-demo">
<strong>Network Requirements:</strong><br/>
• Same subnet for all devices<br/>
• No network isolation<br/>
• Basic router configuration
</div>
</div>

**Lab Topology Explanation:**
This diagram shows the network configuration required for the practical laboratory. The components are:

**Network elements:**
- **Attacking machine (left)**: Kali Linux with IP 192.168.1.100, where we'll run the attack tools
- **Router/Gateway (center)**: The network router with IP 192.168.1.1, connecting all devices
- **Target machine (right)**: The attack victim with IP 192.168.1.10

**Important characteristics:**
- **Same subnet**: All devices must be on the same network (192.168.1.x) for ARP to work
- **No isolation**: There should be no network segmentation preventing communication between devices
- **Basic configuration**: Router with standard configuration, no special protections against ARP spoofing

The bidirectional arrows indicate that all devices can communicate directly with each other, which is necessary for the attack to work.

#### 1.1 Required Tools
1. Kali Linux (updated)
2. ettercap
3. dsniff
4. arpspoof
5. Wireshark (optional)
6. Root privileges

#### 1.2 Initial Setup
1. Ensure you're on the target network
2. Enable IP forwarding:
```bash
echo 1 > /proc/sys/net/ipv4/ip_forward
```

<div class="step-animation">
<strong>Verification:</strong> Check if IP forwarding is enabled:<br/>
<code>cat /proc/sys/net/ipv4/ip_forward</code><br/>
Should return: <strong>1</strong>
</div>

**Initial Setup Explanation:**
- **Being on the target network**: Your attacking machine must be physically connected to the same network as the victim. This means using the same WiFi or being connected to the same switch/router.
- **Enable IP forwarding**: This kernel setting allows your Linux machine to act as a router, forwarding packets between the victim and the real gateway. Without this, the victim would lose Internet connectivity when you execute the attack.
- **Verification**: The command `cat /proc/sys/net/ipv4/ip_forward` reads the current value. If it returns "1", it's enabled; if it returns "0", it's disabled.

### 2. Attack Implementation

<div class="timeline">
<div class="timeline-item attack">
<strong>Phase 1:</strong> Network Reconnaissance
</div>
<div class="timeline-item attack">
<strong>Phase 2:</strong> ARP Poisoning
</div>
<div class="timeline-item attack">
<strong>Phase 3:</strong> DNS Interception
</div>
<div class="timeline-item attack">
<strong>Phase 4:</strong> Traffic Redirection
</div>
</div>

**Attack Phases Explanation:**
This timeline shows the four main phases for executing a DNS Spoofing attack:

- **Phase 1 - Network Reconnaissance**: We identify target devices and network topology. We need to know which devices are connected and their IP addresses.
- **Phase 2 - ARP Poisoning**: We position our attacker as an intermediary between the victim and router using ARP poisoning techniques.
- **Phase 3 - DNS Interception**: We capture and modify DNS queries that pass through our device.
- **Phase 4 - Traffic Redirection**: We redirect victims to malicious content controlled by the attacker.

Each phase must be completed successfully before proceeding to the next one.

#### 2.1 Method 1: Using ettercap

<div class="step-animation">
<strong>Step 1:</strong> Configure ettercap for the attack
</div>

1. **Configure ettercap**:
```bash
nano /etc/ettercap/etter.conf
```
Set privileges:
```
[privs]
ec_uid = 0
ec_gid = 0
```

<div class="step-animation">
<strong>Step 2:</strong> Create DNS spoofing rules
</div>

2. **Create DNS rules**:
```bash
nano /etc/ettercap/etter.dns
```
Add entries:
```
*.domain.com A 192.168.1.100
www.domain.com A 192.168.1.100
```

<div class="interactive-demo">
<h4>DNS Rules Syntax</h4>
<div class="code-highlight">
<strong>Wildcard Pattern:</strong> *.example.com A 192.168.1.100<br/>
<strong>Specific Domain:</strong> www.example.com A 192.168.1.100<br/>
<strong>Subdomain:</strong> mail.example.com A 192.168.1.100
</div>
</div>

**DNS Rules Syntax Explanation:**
This diagram shows the syntax for creating DNS spoofing rules in ettercap:

- **Wildcard Pattern (*.example.com)**: Captures all DNS queries ending in "example.com", including subdomains like mail.example.com, ftp.example.com, etc.
- **Specific Domain (www.example.com)**: Captures only exact queries for "www.example.com"
- **Subdomain (mail.example.com)**: Captures specific queries for the "mail" subdomain of example.com

All these rules redirect queries to IP 192.168.1.100 (the attacking machine), where a malicious web server can be run to capture credentials or serve fake content.

<div class="step-animation success">
<strong>Step 3:</strong> Execute the attack
</div>

3. **Execute Attack**:
```bash
ettercap -G
```

<div class="network-diagram attack">
<h4>Ettercap Attack Flow</h4>
<div class="device attacker">Kali Linux<br/>ettercap -G</div>
<span class="arrow attack">→</span>
<div class="packet arp">ARP Poisoning</div>
<span class="arrow attack">→</span>
<div class="device client">Victim</div>
<br/><br/>
<div class="device client">Victim DNS Query</div>
<span class="arrow">→</span>
<div class="device attacker">Ettercap<br/>DNS Spoof Plugin</div>
<span class="arrow attack">→</span>
<div class="packet spoofed">Fake DNS Response</div>
</div>

**Ettercap Attack Flow Explanation:**
This diagram shows how Ettercap executes the DNS Spoofing attack in two main phases:

**First row** (ARP Poisoning Phase):
- **Attacker (left)**: Kali Linux machine running ettercap with graphical interface (-G)
- **ARP Packet (center)**: Malicious ARP messages sent to position as man-in-the-middle
- **Victim (right)**: The target device that will be deceived

**Second row** (DNS Spoofing Phase):
- **Victim**: Makes a normal DNS query (e.g., "What's the IP of facebook.com?")
- **Attacker with DNS Plugin**: Ettercap intercepts the query and activates the dns_spoof plugin
- **Fake DNS Response**: Ettercap sends a false response with the attacker's IP

The result is that when the victim tries to access specific websites, they are redirected to the web server controlled by the attacker.

GUI Steps:
- Select network interface
- Scan for hosts
- Select targets
- Start ARP poisoning
- Activate dns_spoof plugin

#### 2.2 Method 2: Using dsniff

1. **Enable packet forwarding**:
```bash
echo 1 > /proc/sys/net/ipv4/ip_forward
```

2. **Start ARP spoofing**:
```bash
arpspoof -i [interface] -t [victim-ip] [gateway-ip]
arpspoof -i [interface] -t [gateway-ip] [victim-ip]
```

3. **Configure DNS spoofing**:
```bash
dnsspoof -i [interface] -f hosts.txt
```

### 3. Monitoring and Verification

#### 3.1 Check Attack Success

<div class="interactive-demo">
<h4>Verification Checklist</h4>
<div class="code-highlight">
✓ ARP tables poisoned (check with <code>arp -a</code>)<br/>
✓ DNS queries intercepted (monitor with Wireshark)<br/>
✓ Target redirections working (test with <code>nslookup</code>)<br/>
✓ Traffic flowing through attacker
</div>
</div>

**Verification Checklist Explanation:**
This checklist helps you confirm that each component of the attack is working correctly:

1. **Poisoned ARP tables**: The `arp -a` command shows the IP-MAC associations that your system knows. If the attack works, you'll see that the attacker's MAC is associated with IPs that don't belong to them (like the router's).

2. **Intercepted DNS queries**: Using Wireshark you can see network traffic in real time. You should observe that the victim's DNS queries are passing through your attacking machine.

3. **Working redirections**: The command `nslookup google.com` from the victim machine should return the attacker's IP (192.168.1.100) instead of Google's real IP.

4. **Traffic flowing through attacker**: You can verify this by monitoring network interfaces or using tools like `tcpdump` to confirm that the victim's traffic passes through your machine.

**Procedimientos de verificación:**
- Monitor network traffic with Wireshark to see intercepted packets
- Verify DNS queries are being modified using network analysis tools
- Confirm target redirections by testing with `nslookup` or `dig` commands
- Check that traffic flows through attacker using network monitoring

<div class="network-diagram">
<h4>Successful Attack Verification</h4>
<div class="device client">Victim<br/>makes DNS query</div>
<span class="arrow attack">→</span>
<div class="device attacker">Attacker<br/>responds with fake IP</div>
<br/><br/>
<div class="packet spoofed">DNS Response: example.com = 192.168.1.100</div>
<br/><br/>
<div class="device client">Victim connects</div>
<span class="arrow attack">→</span>
<div class="device attacker">Malicious Server<br/>192.168.1.100</div>
</div>

**Successful Attack Verification Explanation:**
This diagram shows how to verify that the DNS Spoofing attack is working correctly:

**First row** (Intercepted query):
- **Victim (left)**: Makes a DNS query for www.example.com
- **Attacker (right)**: Responds with a malicious IP controlled by them

**Second row** (False DNS response):
- **Spoofed packet**: The modified DNS response containing "example.com = 192.168.1.100"

**Third row** (Redirected connection):
- **Victim**: Connects to what they think is example.com
- **Malicious Server**: Actually connects to the attacker's server at 192.168.1.100

To verify the attack works, you can use commands like `nslookup`, `dig`, or simply open a web browser and try to access the target site. If the DNS response shows the attacker's IP instead of the real site's IP, the attack is working correctly.

#### 3.2 Common Issues and Solutions

<div class="step-animation warning">
<strong>Issue 1:</strong> IP forwarding not enabled
<br/><strong>Solution:</strong> <code>echo 1 > /proc/sys/net/ipv4/ip_forward</code>
<br/><strong>Explanation:</strong> Without IP forwarding, your machine doesn't forward intercepted traffic, causing the victim to lose connectivity. This setting is crucial to maintain connectivity while intercepting traffic.
</div>

<div class="step-animation warning">
<strong>Issue 2:</strong> Wrong network interface
<br/><strong>Solution:</strong> Check with <code>ip addr show</code> and select correct interface
<br/><strong>Explanation:</strong> If you specify the wrong interface (e.g., eth0 instead of wlan0), the tools won't be able to send ARP packets to the correct network. Identify the interface connected to the target network.
</div>

<div class="step-animation warning">
<strong>Issue 3:</strong> ARP poisoning not working
<br/><strong>Solution:</strong> Verify targets are on same subnet and accessible
<br/><strong>Explanation:</strong> ARP only works on the same local network. If the victim is on another subnet or there are VLANs configured, the attack won't work. Confirm connectivity with <code>ping</code> first.
</div>

<div class="step-animation warning">
<strong>Issue 4:</strong> DNS spoofing not taking effect
<br/><strong>Solution:</strong> Clear DNS cache and check etter.dns syntax
<br/><strong>Explanation:</strong> Systems cache DNS responses. The victim may continue using previous cached responses. Additionally, syntax errors in etter.dns prevent rules from being applied correctly.
</div>

### 4. Practice Cleanup

#### 4.1 Restore Normal Operation

<div class="timeline">
<div class="timeline-item">
<strong>Step 1:</strong> Stop all attack tools (Ctrl+C on running processes)
</div>
<div class="timeline-item">
<strong>Step 2:</strong> Clear ARP caches on all machines
</div>
<div class="timeline-item">
<strong>Step 3:</strong> Verify normal DNS resolution is restored
</div>
<div class="timeline-item">
<strong>Step 4:</strong> Document findings and lessons learned
</div>
</div>

**Cleanup Process Explanation:**
This timeline shows the necessary steps to restore normal network operation after the laboratory:

- **Step 1 - Stop tools**: Interrupt all active attack processes using Ctrl+C to prevent them from continuing to affect the network.
- **Step 2 - Clear ARP caches**: Remove all false ARP entries from all device tables to restore correct IP-MAC associations.
- **Step 3 - Verify DNS**: Check that DNS queries work normally again and return real IPs of websites.
- **Step 4 - Document**: Record findings, problems encountered, and lessons learned during the exercise.

This cleanup process is fundamental to ensure the network returns to its normal state and that no residual effects of the attack remain.

<div class="interactive-demo">
<h4>Cleanup Commands</h4>
<div class="code-highlight">
<strong>Clear ARP cache:</strong> <code>sudo ip -s -s neigh flush all</code><br/>
<strong>Check DNS resolution:</strong> <code>nslookup google.com</code><br/>
<strong>Verify connectivity:</strong> <code>ping 8.8.8.8</code>
</div>
</div>

**Cleanup Commands Explanation:**
These commands are essential to restore normal network operation:

1. **Clear ARP cache**: `sudo ip -s -s neigh flush all` removes all malicious ARP entries from the system table. This forces devices to rediscover the real MAC addresses.

2. **Verify DNS resolution**: `nslookup google.com` should return Google's real IPs (like 8.8.8.8) instead of the attacker's IP, confirming that DNS works normally.

3. **Verify connectivity**: `ping 8.8.8.8` sends packets to Google's DNS server to confirm that Internet connectivity is working correctly without passing through the attacker.

These steps ensure that the network completely returns to its normal state after the laboratory.

## References and Additional Resources
- [Kali Linux Documentation](https://www.kali.org/docs/)
- [OWASP DNS Spoofing](https://owasp.org/www-community/attacks/DNS_Spoofing)
- [RFC 4033 - DNS Security](https://tools.ietf.org/html/rfc4033)
- [Ettercap Documentation](https://ettercap.github.io/ettercap/)
- [Wireshark User Guide](https://www.wireshark.org/docs/wsug_html_chunked/)
- [ARP Protocol RFC 826](https://tools.ietf.org/html/rfc826)