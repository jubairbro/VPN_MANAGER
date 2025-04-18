#!/bin/bash

#================[ √ ]=================#
# Jubair VPN Manager - Reboot v1.0
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

# Reboot Server
reboot_server() {
    clear
    draw_ui "REBOOTING SERVER"
    sleep 2
    /sbin/reboot
}

# Main
reboot_server
