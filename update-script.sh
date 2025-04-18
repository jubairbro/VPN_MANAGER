#!/bin/bash

#================[ √ ]=================#
# Jubair VPN Manager - Update Script v1.0
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

# Update Script
update_script() {
    clear
    draw_ui "UPDATING SCRIPT"
    cd /root/VPN_MANAGER
    git pull origin main
    chmod +x *.sh
    chmod +x *.py
    ln -sf /root/VPN_MANAGER/menu /usr/bin/menu
    draw_ui "Script updated successfully!"
}

# Main
update_script
read -p "Press Enter to continue..."
