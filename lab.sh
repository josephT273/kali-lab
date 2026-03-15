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
  echo "    up        — Build and start the full lab"
  echo "    down      — Stop the lab"
  echo "    shell     — Drop into Kali shell"
  echo "    status    — Show running containers + IPs"
  echo "    rebuild   — Rebuild Kali image from scratch"
  echo "    dvwa      — Print DVWA access info"
  echo "    clean     — Remove containers (keep volumes)"
  echo "    nuke      — Remove everything including volumes"
  echo ""
}

cmd_up() {
  echo -e "${GREEN}[+] Starting hacking lab...${NC}"
  docker compose up -d --build
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
}

cmd_rebuild() {
  echo -e "${YELLOW}[*] Rebuilding Kali image (no cache)...${NC}"
  docker compose build --no-cache kali
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

cmd_clean() {
  echo -e "${YELLOW}[*] Removing containers (volumes preserved)...${NC}"
  docker compose down --remove-orphans
}

cmd_nuke() {
  echo -e "${RED}[!] This will delete ALL lab data including your workspace volume!${NC}"
  read -p "    Are you sure? (yes/N): " confirm
  if [[ "$confirm" == "yes" ]]; then
    docker compose down -v --remove-orphans
    docker rmi hacking-lab-kali 2>/dev/null || true
    echo -e "${RED}[!] Lab nuked.${NC}"
  else
    echo "  Cancelled."
  fi
}

# ── Entry point ───────────────────────────────────────────────────────────────
case "${1}" in
  up)      cmd_up ;;
  down)    cmd_down ;;
  shell)   cmd_shell ;;
  status)  cmd_status ;;
  rebuild) cmd_rebuild ;;
  dvwa)    cmd_dvwa ;;
  clean)   cmd_clean ;;
  nuke)    cmd_nuke ;;
  *)       usage ;;
esac
