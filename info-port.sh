#!/bin/bash

#================[ √ ]=================#
# Jubair VPN Manager - Info Port v1.0
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

# Show Port Info
show_port_info() {
    clear
    draw_ui "PORT INFORMATION" \
            "SSH         : 22,80,443" \
            "VMess       : 80,443 (WS)" \
            "VLESS       : 80,443 (WS)" \
            "Trojan      : 80,443 (WS)" \
            "Shadowsocks : 80,443 (WS)" \
            "NoobzVPN    : 80,443" \
            "Dropbear    : 80,443" \
            "HAProxy     : 80,443" \
            "TLS         : 443" \
            "Non-TLS     : 80"
}

# Main
show_port_info
read -p "Press Enter to continue..."
