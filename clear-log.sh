#!/bin/bash

#================[ √ ]=================#
# Jubair VPN Manager - Clear Log v1.0
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

# Clear Logs
clear_logs() {
    clear
    draw_ui "CLEARING LOGS"
    truncate -s 0 /var/log/syslog
    truncate -s 0 /var/log/nginx/*.log
    truncate -s 0 /var/log/xray/*.log
    draw_ui "All logs cleared!"
}

# Main
clear_logs
read -p "Press Enter to continue..."
