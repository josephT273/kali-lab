#!/bin/bash
# ── lab.sh — NovaSpectra Hacking Lab Manager ──────────────────────────────────

RED='\033[0;31m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
NC='\033[0m'

banner() {
  echo -e "${RED}"
  echo "  ╔══════════════════════════════════╗"
  echo "  ║   NovaSpectra Hacking Lab        ║"
  echo "  ╚══════════════════════════════════╝"
  echo -e "${NC}"
}

usage() {
  banner
  echo -e "  ${CYAN}Usage:${NC} ./lab.sh [command]"
  echo ""
  echo -e "  ${YELLOW}Commands:${NC}"
  echo "    up        — Pull (if needed) and start the full lab"
  echo "    down      — Stop the lab"
  echo "    shell     — Drop into Kali shell"
  echo "    status    — Show running containers + IPs"
  echo "    build     — Build Kali image locally (for dev)"
  echo "    dvwa      — Print DVWA access info"
  echo "    metasploit— Print Metasploitable2 access info"
  echo "    juice     — Print Juice Shop access info"
  echo "    clean     — Remove containers (keep volumes)"
  echo "    nuke      — Remove everything including volumes"
  echo ""
}

cmd_up() {
  if [ -z "$(docker images -q ghcr.io/josepht273/kali-lab:latest 2> /dev/null)" ]; then
    echo -e "${YELLOW}[+] Kali image not found. Pulling from GHCR...${NC}"
    docker compose pull kali
  fi

  echo -e "${GREEN}[+] Starting hacking lab...${NC}"
  docker compose up -d
  sleep 2
  cmd_status
}

cmd_down() {
  echo -e "${YELLOW}[*] Stopping lab...${NC}"
  docker compose down
}

cmd_shell() {
  echo -e "${GREEN}[+] Entering Kali lab...${NC}"
  docker exec -it kali-lab /bin/zsh
}

cmd_status() {
  echo -e "${CYAN}[*] Lab status:${NC}"
  echo ""
  docker compose ps
  echo ""
  echo -e "${CYAN}[*] Container IPs on hacknet:${NC}"
  docker network inspect hacknet \
    --format '{{range .Containers}}  {{.Name}}: {{.IPv4Address}}{{"\n"}}{{end}}' 2>/dev/null \
    || echo "  (network not up yet)"
  echo ""
  echo -e "${YELLOW}  Access Info:${NC}"
  echo -e "    Run ${CYAN}./lab.sh dvwa${NC}       for DVWA"
  echo -e "    Run ${CYAN}./lab.sh metasploit${NC} for Metasploitable2"
  echo -e "    Run ${CYAN}./lab.sh juice${NC}      for Juice Shop"
  echo ""
}

cmd_build() {
  echo -e "${YELLOW}[*] Building Kali image locally...${NC}"
  docker compose build kali
}

cmd_rebuild() {
  echo -e "${YELLOW}[*] Pulling latest Kali image from GHCR...${NC}"
  docker compose pull kali
  docker image prune -f
}

cmd_dvwa() {
  DVWA_IP=$(docker inspect dvwa-target \
    --format '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' 2>/dev/null)
  echo ""
  echo -e "${GREEN}  DVWA is accessible from INSIDE Kali at:${NC}"
  echo -e "    ${CYAN}http://dvwa${NC}   (via container hostname)"
  echo -e "    ${CYAN}http://${DVWA_IP}${NC}  (via IP)"
  echo ""
  echo -e "${YELLOW}  Default credentials:${NC} admin / password"
  echo -e "${YELLOW}  First login:${NC} click 'Create / Reset Database'"
  echo ""
}

cmd_metasploit() {
  META_IP=$(docker inspect metasploitable \
    --format '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' 2>/dev/null)
  echo ""
  echo -e "${GREEN}  Metasploitable2 is accessible from INSIDE Kali at:${NC}"
  echo -e "    ${CYAN}${META_IP}${NC}  (via IP)"
  echo -e "    ${CYAN}metasploitable${NC} (via hostname)"
  echo ""
  echo -e "${YELLOW}  Vulnerable Services:${NC}"
  echo "    - FTP (21), SSH (22), Telnet (23), SMTP (25)"
  echo "    - HTTP (80), RPC (111), SMB (139/445)"
  echo "    - MySQL (3306), PostgreSQL (5432), VNC (5900)"
  echo "    - IRC (6667), Apache JServ (8180)"
  echo ""
  echo -e "${YELLOW}  Default credentials:${NC} msfadmin / msfadmin"
  echo ""
}

cmd_juice() {
  JUICE_IP=$(docker inspect juiceshop \
    --format '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' 2>/dev/null)
  echo ""
  echo -e "${GREEN}  OWASP Juice Shop is accessible from INSIDE Kali at:${NC}"
  echo -e "    ${CYAN}http://juiceshop:3000${NC} (via hostname)"
  echo -e "    ${CYAN}http://${JUICE_IP}:3000${NC} (via IP)"
  echo ""
  echo -e "${YELLOW}  Target:${NC} Modern vulnerable web application"
  echo ""
}

cmd_clean() {
  echo -e "${YELLOW}[*] Removing containers (volumes preserved)...${NC}"
  docker compose down --remove-orphans
}

cmd_nuke() {
  echo -e "${RED}[!] This will delete ALL lab data including your workspace volume!${NC}"
  echo -n "    Are you sure? (yes/N): "
  read confirm < /dev/tty
  if [[ "$confirm" == "yes" ]]; then
    docker compose down -v --remove-orphans
    docker rmi ghcr.io/josepht273/kali-lab:latest 2>/dev/null || true
    echo -e "${RED}[!] Lab nuked.${NC}"
  else
    echo "  Cancelled."
  fi
}

# ── Self-Bootstrap Check ─────────────────────────────────────────────────────
# If docker-compose.yml is missing, we are likely running from a standalone download.
if [ ! -f "docker-compose.yml" ]; then
  echo -e "${RED}[!] docker-compose.yml not found!${NC}"
  echo -e "${YELLOW}[?] It looks like you are running the script outside the lab directory.${NC}"
  # Use /dev/tty for input to allow running via curl | bash
  echo -n "    Do you want to clone the full Hacking Lab repository? (Y/n): "
  read confirm < /dev/tty
  if [[ ! "$confirm" =~ ^[Nn]$ ]]; then
    # Default to YES
    echo -e "${GREEN}[+] Cloning repository...${NC}"
    if git clone https://github.com/josepht273/kali-lab.git kali-lab; then
      cd kali-lab
      echo -e "${GREEN}[+] Repository cloned. Starting lab...${NC}"
      chmod +x lab.sh
      exec ./lab.sh "${@:-up}"
    else
      echo -e "${RED}[!] Clone failed. Please check your internet connection.${NC}"
      exit 1
    fi
  else
    echo -e "${RED}[!] Cannot run lab without configuration files. Exiting.${NC}"
    exit 1
  fi
fi

# ── Entry point ───────────────────────────────────────────────────────────────
case "${1}" in
  up)      cmd_up ;;
  down)    cmd_down ;;
  shell)   cmd_shell ;;
  status)  cmd_status ;;
  build)   cmd_build ;;
  rebuild) cmd_rebuild ;;
  dvwa)    cmd_dvwa ;;
  metasploit) cmd_metasploit ;;
  juice)   cmd_juice ;;
  clean)   cmd_clean ;;
  nuke)    cmd_nuke ;;
  *)       usage ;;
esac
