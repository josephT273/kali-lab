# ── NovaSpectra Hacking Lab Shell ─────────────────────────────────────────────
export TERM=xterm-256color
export HISTSIZE=10000
export HISTFILE=/workspace/.zsh_history
export SAVEHIST=10000

setopt SHARE_HISTORY
setopt HIST_IGNORE_DUPS
setopt AUTO_CD

# ── Prompt ─────────────────────────────────────────────────────────────────────
autoload -Uz colors && colors
PROMPT='%F{red}┌[%f%F{cyan}kali-lab%f%F{red}]%f %F{yellow}%~%f
%F{red}└─%f%F{white}$%f '

# ── Aliases ───────────────────────────────────────────────────────────────────
# navigation
alias ws='cd /workspace'
alias web='cd /workspace/web'
alias net='cd /workspace/network'
alias re='cd /workspace/re'
alias ctf='cd /workspace/ctf'
alias loot='cd /workspace/loot'
alias sl='/opt/seclists'

# nmap presets
alias nmap-quick='nmap -T4 -F'
alias nmap-full='nmap -T4 -A -v'
alias nmap-udp='nmap -sU -T4'
alias nmap-vuln='nmap --script vuln'
alias nmap-all='nmap -p- -T4 -A -v'

# web
alias sqli='sqlmap --batch --level=5 --risk=3'
alias fuzz-dir='ffuf -w /opt/seclists/Discovery/Web-Content/common.txt -u'
alias fuzz-sub='ffuf -w /opt/seclists/Discovery/DNS/subdomains-top1million-5000.txt -u'

# RE
alias r2='radare2'
alias r2-analyze='radare2 -A'
alias ghidra-analyze='/opt/ghidra/support/analyzeHeadless'
alias bw='binwalk'
alias bw-extract='binwalk -e'
alias ltrace-full='ltrace -f -S'

# network
alias sniff='tcpdump -i any -n'
alias listen='nc -lvnp'
alias scan-arp='arp-scan -l'

# pwntools shortcut
alias pwn-template='python3 -c "from pwn import *; context.log_level=\"debug\"; print(\"pwntools ready\")"'

# utils
alias hex='xxd'
alias unhex='xxd -r'
alias b64d='base64 -d'
alias b64e='base64 -w0'
alias urld='python3 -c "import sys,urllib.parse; print(urllib.parse.unquote(sys.stdin.read()))"'

# ── Tool paths ────────────────────────────────────────────────────────────────
export PATH="$PATH:/opt/ghidra/support"
export SECLISTS=/opt/seclists

# ── tmux auto-start (if not already in tmux) ─────────────────────────────────
if [ -z "$TMUX" ]; then
  tmux new-session -A -s main
fi

# ── Banner ────────────────────────────────────────────────────────────────────
echo ""
echo "  \033[1;31m╔═══════════════════════════════════╗\033[0m"
echo "  \033[1;31m║  \033[1;37mNovaSpectra Hacking Lab\033[1;31m         ║\033[0m"
echo "  \033[1;31m║  \033[0;36mKali Linux • CLI Only\033[1;31m           ║\033[0m"
echo "  \033[1;31m╚═══════════════════════════════════╝\033[0m"
echo ""
echo "  \033[0;33mWorkspace:\033[0m /workspace/{web,network,re,ctf,loot}"
echo "  \033[0;33mWordlists:\033[0m /opt/seclists"
echo "  \033[0;33mGhidra:\033[0m   ghidra-analyze <project-dir> <project-name> -import <binary>"
echo ""
