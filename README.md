# NovaSpectra Hacking Lab

Dockerized Kali Linux lab — CLI only, no GUI. Fully isolated bridge network with a DVWA target.

## Structure

```
hacking-lab/
├── docker-compose.yml      # Orchestrates kali + dvwa + dvwa-db
├── lab.sh                  # Lab manager script
├── scripts/                # Drop helper scripts here (shared with container)
└── kali/
    ├── Dockerfile
    └── config/
        ├── .zshrc          # Shell aliases, prompt, banner
        └── .tmux.conf      # Tmux keybinds (prefix: Ctrl+a)
```

## Quick Start

### 1. One-Line Setup (Recommended)
Use this command to download the manager, clone the repo, and start the lab automatically:

```bash
curl -sL https://raw.githubusercontent.com/josepht273/kali-lab/main/lab.sh | bash
```

### 2. Manual Setup
```bash
# 1. Clone the repo
git clone https://github.com/josepht273/kali-lab.git
cd kali-lab

# 2. Make the manager executable
chmod +x lab.sh

# 3. Build and start the lab
./lab.sh up
```

## Network Layout

```
hacknet (172.20.0.0/24)
├── kali-lab       → your attack box
├── dvwa           → vulnerable web app target
├── dvwa-db        → dvwa's database (internal only)
├── metasploitable → metasploitable2 target (many vuln services)
└── juiceshop      → OWASP Juice Shop (modern web app)
```

From inside Kali, reach targets at:
- **DVWA**: `http://dvwa` (creds: `admin`/`password`)
- **Metasploitable**: `metasploitable` (creds: `msfadmin`/`msfadmin`)
- **Juice Shop**: `http://juiceshop:3000`

## Workspace Layout (persistent)

```
/workspace/
├── web/        # Web app pentesting notes, payloads
├── network/    # Network scan outputs, pcaps
├── re/         # Binaries for reverse engineering
├── ctf/        # CTF challenges
└── loot/       # Credentials, flags, findings
```

## Tools Installed

### Web App Pentesting
| Tool | Usage |
|------|-------|
| `nmap` | Port scanning (`nmap-quick <ip>`, `nmap-full <ip>`, `nmap-vuln <ip>`) |
| `nikto` | Web server scanner |
| `sqlmap` | SQL injection (`sqli -u <url>`) |
| `gobuster` | Directory brute force |
| `ffuf` | Fast fuzzer (`fuzz-dir http://target/FUZZ`) |
| `hydra` | Login brute force |

### Network Pentesting
| Tool | Usage |
|------|-------|
| `tcpdump` | Packet capture (`sniff -w out.pcap`) |
| `tshark` | CLI Wireshark |
| `masscan` | Fast port scanner |
| `hping3` | Packet crafting |
| `netcat` | `listen <port>` to catch reverse shells |
| `socat` | Advanced relay/tunnel |

### Reverse Engineering
| Tool | Usage |
|------|-------|
| `gdb + pwndbg` | `gdb ./binary` — pwndbg loaded automatically |
| `radare2` | `r2 ./binary`, `r2-analyze ./binary` |
| `binwalk` | `bw ./firmware`, `bw-extract ./firmware` |
| `ghidra (headless)` | See Ghidra section below |
| `strace` | `strace ./binary` |
| `ltrace` | `ltrace ./binary` |
| `strings` / `xxd` | `strings ./binary`, `hex ./binary` |

### Python / Exploit Dev
| Tool | Usage |
|------|-------|
| `pwntools` | `from pwn import *` |
| `ropper` | ROP gadget finder |
| `scapy` | Packet crafting in Python |
| `impacket` | SMB/AD attack tooling |

## Ghidra Headless

```bash
# Analyze a binary (creates a project)
ghidra-analyze /workspace/re/myproject MyProject -import /workspace/re/binary -analyzeHeadless

# Run a specific script after analysis
ghidra-analyze /workspace/re/myproject MyProject \
  -process binary \
  -postScript ExportFunctions.java
```

## Tmux Cheatsheet (prefix = Ctrl+a)

| Keys | Action |
|------|--------|
| `prefix + |` | Split vertically |
| `prefix + -` | Split horizontally |
| `prefix + h/j/k/l` | Navigate panes |
| `prefix + c` | New window |
| `prefix + n/p` | Next/prev window |
| `prefix + r` | Reload tmux config |

## Shell Aliases Quick Reference

```bash
# Workspace navigation
ws, web, net, re, ctf, loot

# Nmap
nmap-quick <ip>       # Fast common ports
nmap-full <ip>        # Full with OS/version
nmap-all <ip>         # All 65535 ports
nmap-vuln <ip>        # Vuln scripts

# Fuzzing
fuzz-dir http://dvwa/FUZZ
fuzz-sub http://FUZZ.target.com

# RE
r2 ./binary           # Open in radare2
bw-extract ./file     # Binwalk extract
hex ./file            # xxd hex dump

# Utils
listen 4444           # nc reverse shell listener
b64d / b64e           # base64 decode / encode
```

## Lab Manager Commands

```bash
./lab.sh up        # Start lab
./lab.sh shell     # Enter Kali
./lab.sh status    # Show IPs and containers
./lab.sh dvwa      # DVWA access info
./lab.sh metasploit# Metasploitable access info
./lab.sh juice     # Juice Shop access info
./lab.sh rebuild   # Rebuild Kali image
./lab.sh down      # Stop lab
./lab.sh nuke      # Delete everything (careful!)
```
