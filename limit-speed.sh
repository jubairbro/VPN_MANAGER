#!/bin/bash

#================[ √ ]=================#
# Jubair VPN Manager - Limit Speed v1.0
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

# Set Speed Limit
set_speed_limit() {
    clear
    draw_ui "SET SPEED LIMIT"
    read -p "Enter Username: " username
    read -p "Enter Speed Limit (kbps): " speed
    if id "$username" >/dev/null 2>&1; then
        iptables -A OUTPUT -p tcp -m owner --uid-owner "$username" -m limit --limit $speed/sec -j ACCEPT
        draw_ui "Speed limit set for $username to $speed kbps"
    else
        draw_ui "User $username not found!"
    fi
}

# Remove Speed Limit
remove_speed_limit() {
    clear
    draw_ui "REMOVE SPEED LIMIT"
    read -p "Enter Username: " username
    if id "$username" >/dev/null 2>&1; then
        iptables -D OUTPUT -p tcp -m owner --uid-owner "$username" -m limit --limit $speed/sec -j ACCEPT
        draw_ui "Speed limit removed for $username"
    else
        draw_ui "User $username not found!"
    fi
}

# Speed Limit Menu
speed_limit_menu() {
    while true; do
        clear
        draw_ui "SPEED LIMIT MENU"
        echo -e "${CYAN}┌──────────────────────────────┐${NC}"
        printf "${CYAN}│${NC} %-28s ${CYAN}│${NC}\n" "[1] Set Speed Limit"
        printf "${CYAN}│${NC} %-28s ${CYAN}│${NC}\n" "[2] Remove Speed Limit"
        printf "${CYAN}│${NC} %-28s ${CYAN}│${NC}\n" "[0] Back to Main Menu"
        echo -e "${CYAN}└──────────────────────────────┘${NC}"
        read -p "Select an option [0-2]: " option

        case $option in
            1) set_speed_limit ;;
            2) remove_speed_limit ;;
            0) exit 0 ;;
            *) echo -e "${RED}Invalid option!${NC}"; sleep 1 ;;
        esac
        read -p "Press Enter to continue..."
    done
}

speed_limit_menu
