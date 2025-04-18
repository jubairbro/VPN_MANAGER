#!/bin/bash

#================[ √ ]=================#
# Jubair VPN Manager - Restart v1.0
# Script by: JubairBro
#================[ √ ]=================#

# Colors for UI
RED='\033[0;31m'
GREEN='\033[0;32m'
CYAN='\033[0;36m'
NC='\033[0m'

# Function to draw UI
draw_ui() {
    echo -e "${CYAN}┌──────────────────────────────┐${NC}"
    for text in "$@"; do
        printf "${CYAN}│${NC} %-28s ${CYAN}│${NC}\n" "$text"
    done
    echo -e "${CYAN}└──────────────────────────────┘${NC}"
}

# Restart Services
restart_services() {
    clear
    draw_ui "RESTARTING SERVICES"
    systemctl restart xray
    systemctl restart nginx
    systemctl restart sshd
    systemctl restart dropbear
    systemctl restart haproxy
    draw_ui "All services restarted!"
}

# Main
restart_services
read -p "Press Enter to continue..."
