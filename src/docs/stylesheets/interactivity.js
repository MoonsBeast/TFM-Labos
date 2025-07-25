// Interactive functionality for TFM-Labos documentation

document.addEventListener('DOMContentLoaded', function() {
    // Add copy functionality to code blocks
    addCopyButtons();
    
    // Add scroll to top functionality
    addScrollToTop();
    
    // Add progress indicator
    addProgressIndicator();
    
    // Add tooltip functionality
    addTooltips();
    
    // Add command execution simulation
    addCommandSimulation();
});

function addCopyButtons() {
    const codeBlocks = document.querySelectorAll('pre code');
    
    codeBlocks.forEach(function(codeBlock) {
        const pre = codeBlock.parentNode;
        const button = document.createElement('button');
        button.className = 'copy-button';
        button.innerHTML = '📋';
        button.title = 'Copy to clipboard';
        
        button.addEventListener('click', function() {
            navigator.clipboard.writeText(codeBlock.textContent).then(function() {
                button.innerHTML = '✅';
                button.style.color = '#4CAF50';
                
                setTimeout(function() {
                    button.innerHTML = '📋';
                    button.style.color = '';
                }, 2000);
            });
        });
        
        pre.style.position = 'relative';
        pre.appendChild(button);
    });
}

function addScrollToTop() {
    const scrollButton = document.createElement('button');
    scrollButton.className = 'scroll-to-top';
    scrollButton.innerHTML = '↑';
    scrollButton.title = 'Scroll to top';
    
    document.body.appendChild(scrollButton);
    
    window.addEventListener('scroll', function() {
        if (window.pageYOffset > 300) {
            scrollButton.classList.add('show');
        } else {
            scrollButton.classList.remove('show');
        }
    });
    
    scrollButton.addEventListener('click', function() {
        window.scrollTo({ top: 0, behavior: 'smooth' });
    });
}

function addProgressIndicator() {
    const progressBar = document.createElement('div');
    progressBar.className = 'progress-bar';
    
    const progress = document.createElement('div');
    progress.className = 'progress';
    progressBar.appendChild(progress);
    
    document.body.appendChild(progressBar);
    
    window.addEventListener('scroll', function() {
        const winScroll = document.body.scrollTop || document.documentElement.scrollTop;
        const height = document.documentElement.scrollHeight - document.documentElement.clientHeight;
        const scrolled = (winScroll / height) * 100;
        progress.style.width = scrolled + '%';
    });
}

function addTooltips() {
    // Add tooltips to important terms
    const terms = {
        'ARP': 'Address Resolution Protocol - Maps IP addresses to MAC addresses',
        'DNS': 'Domain Name System - Translates domain names to IP addresses',
        'MITM': 'Man-in-the-Middle - Attack where attacker intercepts communications',
        'spoofing': 'Technique where attacker impersonates another device or service',
        'ettercap': 'Comprehensive suite for man-in-the-middle attacks',
        'tcpdump': 'Command-line packet analyzer for network troubleshooting'
    };
    
    Object.keys(terms).forEach(term => {
        const regex = new RegExp(`\\b${term}\\b`, 'gi');
        const content = document.querySelector('.md-content');
        
        if (content) {
            content.innerHTML = content.innerHTML.replace(regex, function(match) {
                return `<span class="tooltip" data-tooltip="${terms[term]}">${match}</span>`;
            });
        }
    });
}

function addCommandSimulation() {
    const commandBlocks = document.querySelectorAll('code');
    
    commandBlocks.forEach(function(block) {
        const text = block.textContent.trim();
        
        // Check if it's a shell command
        if (text.startsWith('docker') || text.startsWith('sudo') || text.startsWith('./') || text.startsWith('curl')) {
            block.parentNode.style.cursor = 'pointer';
            block.parentNode.title = 'Click to simulate command execution';
            
            block.parentNode.addEventListener('click', function() {
                simulateCommand(block);
            });
        }
    });
}

function simulateCommand(codeElement) {
    const command = codeElement.textContent.trim();
    const output = getSimulatedOutput(command);
    
    // Create output element
    const outputDiv = document.createElement('div');
    outputDiv.className = 'command-output';
    outputDiv.innerHTML = `
        <div class="output-header">
            <span>💻</span>
            <span>Simulated Output</span>
            <button onclick="this.parentNode.parentNode.remove()" class="close-output">×</button>
        </div>
        <pre><code>${output}</code></pre>
    `;
    
    // Insert after the code block
    codeElement.parentNode.parentNode.insertBefore(outputDiv, codeElement.parentNode.nextSibling);
    
    // Animate the output
    outputDiv.style.maxHeight = '0';
    outputDiv.style.overflow = 'hidden';
    outputDiv.style.transition = 'max-height 0.3s ease-out';
    
    setTimeout(() => {
        outputDiv.style.maxHeight = '300px';
    }, 100);
}

function getSimulatedOutput(command) {
    if (command.includes('docker-compose up')) {
        return `Creating network "src_internal_network" with the default driver
Creating src_dns_1 ... done
Creating src_web_server_1 ... done
Creating src_evil_web_server_1 ... done
Creating src_kali_attacker_1 ... done
Creating src_http_requester_1 ... done
✓ All services started successfully`;
    }
    
    if (command.includes('nmap')) {
        return `Starting Nmap 7.80 ( https://nmap.org )
Nmap scan report for 192.168.1.10
Host is up (0.00021s latency).
PORT     STATE SERVICE
80/tcp   open  http
MAC Address: 02:42:C0:A8:01:0A (Unknown)

Nmap scan report for 192.168.1.100
Host is up (0.00019s latency).
PORT     STATE SERVICE
80/tcp   open  http
MAC Address: 02:42:C0:A8:01:64 (Unknown)

Nmap done: 2 IP addresses (2 hosts up) scanned in 0.58 seconds`;
    }
    
    if (command.includes('ettercap')) {
        return `ettercap 0.8.3 copyright 2001-2019 Ettercap Development Team

Starting Unified sniffing...
Text only Interface activated...
Listening on:
   eth0 -> 02:42:C0:A8:01:14

SSL dissection needs a valid 'redir_command_on' script in the etter.conf file
Ettercap might not work correctly.

Randomizing 255 hosts for scanning...
Scanning the whole netmask for 255 hosts...
* |==================================================>| 100.00 %

2 hosts added to the hosts list...

ARP poisoning victims:
TARGET 1 : 192.168.1.30 02:42:C0:A8:01:1E
TARGET 2 : 192.168.1.1  02:42:C0:A8:01:01

Starting Unified sniffing...

Text only Interface activated...
✓ ARP spoofing attack started successfully`;
    }
    
    if (command.includes('arp -a')) {
        return `gateway (192.168.1.1) at 02:42:c0:a8:01:01 [ether] on eth0
goodserver.com (192.168.1.10) at 02:42:c0:a8:01:0a [ether] on eth0
evilserver.com (192.168.1.100) at 02:42:c0:a8:01:64 [ether] on eth0
victim (192.168.1.30) at 02:42:c0:a8:01:1e [ether] on eth0`;
    }
    
    if (command.includes('nslookup')) {
        return `Server:		192.168.1.4
Address:	192.168.1.4#53

Name:	goodserver.com
Address: 192.168.1.100

** NOTE: DNS spoofing detected! **
Expected: 192.168.1.10, Got: 192.168.1.100`;
    }
    
    return `$ ${command}
Command executed successfully.
Note: This is a simulated output for demonstration purposes.`;
}
