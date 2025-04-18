#!/bin/bash

#================[ √ ]=================#
# Jubair VPN Manager - Clear Cache v1.0
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

# Clear Cache
clear_cache() {
    clear
    draw_ui "CLEARING CACHE"
    sync
    echo 3 > /proc/sys/vm/drop_caches
    draw_ui "System cache cleared!"
}

# Main
clear_cache
read -p "Press Enter to continue..."
