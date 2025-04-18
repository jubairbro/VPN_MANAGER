#!/bin/bash

#================[ √ ]=================#
# Jubair VPN Manager - Check Bandwidth v1.0
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

# Check Bandwidth
check_bandwidth() {
    clear
    draw_ui "CHECKING BANDWIDTH"
    BANDWIDTH=$(vnstat -s | grep "total" | awk '{print $2 " " $3}')
    draw_ui "BANDWIDTH USAGE" \
            "Total: $BANDWIDTH"
}

# Main
check_bandwidth
read -p "Press Enter to continue..."
