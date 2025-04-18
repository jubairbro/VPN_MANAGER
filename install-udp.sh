#!/bin/bash

#================[ √ ]=================#
# Jubair VPN Manager - Install UDP v1.0
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

# Install UDP
install_udp() {
    clear
    draw_ui "INSTALLING UDP SUPPORT"
    apt install -y openvpn
    wget -q -O /etc/openvpn/server.conf "https://raw.githubusercontent.com/OpenVPN/openvpn/master/sample-config-files/server.conf"
    sed -i 's/port 1194/port 1194/' /etc/openvpn/server.conf
    sed -i 's/proto tcp/proto udp/' /etc/openvpn/server.conf
    systemctl enable openvpn@server
    systemctl start openvpn@server
    draw_ui "UDP support installed!"
}

# Main
install_udp
read -p "Press Enter to continue..."
