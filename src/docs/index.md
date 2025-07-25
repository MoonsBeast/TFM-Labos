# Welcome to TFM Cybersecurity Labs

<div class="hero-section">
    <h2>🔐 Interactive Cybersecurity Laboratory Environment</h2>
    <p class="hero-description">
        Master advanced network security concepts through hands-on Docker-based laboratories. 
        Learn ARP spoofing, DNS spoofing, and MITM attacks in a controlled, safe environment.
    </p>
</div>

## 🎯 Laboratory Objectives

<div class="objectives-grid">
    <div class="lab-card">
        <div class="lab-card-header">🌐 Network Security</div>
        <p>Understand fundamental network protocols and their vulnerabilities</p>
        <ul>
            <li>ARP Protocol Analysis</li>
            <li>DNS Resolution Mechanics</li>
            <li>Network Traffic Inspection</li>
        </ul>
    </div>
    
    <div class="lab-card">
        <div class="lab-card-header">⚔️ Attack Techniques</div>
        <p>Learn and execute advanced attack methodologies</p>
        <ul>
            <li>ARP Spoofing/Poisoning</li>
            <li>DNS Spoofing Attacks</li>
            <li>Man-in-the-Middle (MITM)</li>
        </ul>
    </div>
    
    <div class="lab-card">
        <div class="lab-card-header">🛡️ Defense Strategies</div>
        <p>Develop skills to detect and prevent network attacks</p>
        <ul>
            <li>Traffic Analysis</li>
            <li>Attack Detection</li>
            <li>Countermeasures</li>
        </ul>
    </div>
</div>

## 🚀 Getting Started

<div class="getting-started">
    <div class="step-card">
        <div class="step-number">1</div>
        <div class="step-content">
            <h3>Environment Setup</h3>
            <p>Configure your Docker environment for the laboratories</p>
            <a href="docker/" class="step-link">Docker Setup Guide →</a>
        </div>
    </div>
    
    <div class="step-card">
        <div class="step-content">
            <h3>Laboratory Practice</h3>
            <p>Execute hands-on ARP and DNS spoofing attacks</p>
            <a href="lab1/" class="step-link">Laboratory 1: ARP & DNS Spoofing →</a>
        </div>
        <div class="step-number">2</div>
    </div>
</div>

## 🔧 Tools & Technologies

<div class="tools-section">
    <div class="tool-category">
        <h3>🐋 Containerization</h3>
        <div class="tool-badges">
            <span class="tool-badge">Docker</span>
            <span class="tool-badge">Docker Compose</span>
            <span class="tool-badge">Container Networks</span>
        </div>
    </div>
    
    <div class="tool-category">
        <h3>� Security Tools</h3>
        <div class="tool-badges">
            <span class="tool-badge ettercap">Ettercap</span>
            <span class="tool-badge kali">Kali Linux</span>
            <span class="tool-badge parrot">Parrot Security</span>
            <span class="tool-badge">Wireshark</span>
            <span class="tool-badge">tcpdump</span>
        </div>
    </div>
    
    <div class="tool-category">
        <h3>📊 Analysis</h3>
        <div class="tool-badges">
            <span class="tool-badge">Network Monitoring</span>
            <span class="tool-badge">Traffic Analysis</span>
            <span class="tool-badge">Forensics</span>
        </div>
    </div>
</div>

## 📖 Laboratory Structure

!!! info "Learning Path"
    Each laboratory is designed to build upon previous knowledge:
    
    1. **Theory**: Understand the underlying concepts
    2. **Manual Practice**: Execute attacks step-by-step
    3. **Automated Tools**: Use provided scripts
    4. **Analysis**: Analyze captured traffic and results
    5. **Defense**: Learn detection and prevention techniques

## ⚠️ Important Notice

!!! warning "Educational Purpose Only"
    These laboratories are designed **exclusively for educational purposes** in controlled environments. 
    
    - Only use these techniques in authorized testing environments
    - Respect all applicable laws and regulations
    - Obtain proper authorization before testing on any network
    - Use knowledge responsibly for defensive purposes

## 🤝 Prerequisites

Before starting the laboratories, ensure you have:

- [ ] Basic understanding of networking concepts (TCP/IP, DNS, ARP)
- [ ] Docker and Docker Compose installed
- [ ] Administrative/root privileges on your system
- [ ] Familiarity with Linux command line
- [ ] Understanding of cybersecurity ethics

<div class="page-nav">
    <a href="docker/" class="next">
        📚 Start with Docker Setup →
    </a>
</div>

<style>
.hero-section {
    text-align: center;
    background: linear-gradient(135deg, var(--md-primary-fg-color--light), var(--md-primary-fg-color));
    color: white;
    padding: 3rem 2rem;
    border-radius: var(--lab-border-radius);
    margin: 2rem 0;
    box-shadow: var(--lab-shadow-lg);
}

.hero-description {
    font-size: 1.2rem;
    margin: 1rem 0;
    opacity: 0.9;
}

.objectives-grid {
    display: grid;
    grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
    gap: 1.5rem;
    margin: 2rem 0;
}

.getting-started {
    display: flex;
    flex-direction: column;
    gap: 1rem;
    margin: 2rem 0;
}

.step-card {
    display: flex;
    align-items: center;
    background: var(--md-default-bg-color);
    border: 1px solid var(--md-default-fg-color--lightest);
    border-radius: var(--lab-border-radius);
    padding: 1.5rem;
    box-shadow: var(--lab-shadow);
    transition: var(--lab-transition);
}

.step-card:hover {
    transform: translateX(10px);
    box-shadow: var(--lab-shadow-lg);
}

.step-number {
    background: var(--lab-primary);
    color: white;
    width: 3rem;
    height: 3rem;
    border-radius: 50%;
    display: flex;
    align-items: center;
    justify-content: center;
    font-size: 1.5rem;
    font-weight: bold;
    margin-right: 1.5rem;
    flex-shrink: 0;
}

.step-content {
    flex: 1;
}

.step-content h3 {
    margin: 0 0 0.5rem 0;
    color: var(--lab-primary);
}

.step-link {
    color: var(--lab-accent);
    text-decoration: none;
    font-weight: 600;
}

.step-link:hover {
    text-decoration: underline;
}

.tools-section {
    display: grid;
    grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
    gap: 1.5rem;
    margin: 2rem 0;
}

.tool-category {
    background: var(--md-default-bg-color);
    border: 1px solid var(--md-default-fg-color--lightest);
    border-radius: var(--lab-border-radius);
    padding: 1.5rem;
    box-shadow: var(--lab-shadow);
}

.tool-category h3 {
    margin: 0 0 1rem 0;
    color: var(--lab-primary);
}

.tool-badges {
    display: flex;
    flex-wrap: wrap;
    gap: 0.5rem;
}

@media (max-width: 768px) {
    .hero-section {
        padding: 2rem 1rem;
    }
    
    .step-card {
        flex-direction: column;
        text-align: center;
    }
    
    .step-number {
        margin: 0 0 1rem 0;
    }
}
</style>

