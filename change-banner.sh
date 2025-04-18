#!/bin/bash

#================[ √ ]=================#
# Jubair VPN Manager - Change Banner v1.0
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

# Change Banner
change_banner() {
    clear
    draw_ui "CHANGE SSH BANNER"
    read -p "Enter Username (or leave blank for default): " username
    if [ -z "$username" ]; then
        nano /etc/ssh/welcome_default.txt
        sed -i "/^Banner/d" /etc/ssh/sshd_config
        echo "Banner /etc/ssh/welcome_default.txt" >> /etc/ssh/sshd_config
    else
        nano "/etc/ssh/welcome_$username.txt"
        sed -i "/^Banner/d" /etc/ssh/sshd_config
        echo "Banner /etc/ssh/welcome_$username.txt" >> /etc/ssh/sshd_config
    fi
    systemctl restart sshd dropbear
    draw_ui "SSH banner updated!"
}

# Main
change_banner
read -p "Press Enter to continue..."
