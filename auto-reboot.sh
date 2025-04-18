#!/bin/bash

#================[ √ ]=================#
# Jubair VPN Manager - Auto Reboot v1.0
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

# Set Auto Reboot
set_auto_reboot() {
    clear
    draw_ui "SET AUTO REBOOT"
    read -p "Enter time for reboot (HH:MM, e.g., 04:00): " REBOOT_TIME
    if [[ ! $REBOOT_TIME =~ ^[0-2][0-9]:[0-5][0-9]$ ]]; then
        draw_ui "Invalid time format! Use HH:MM"
        return 1
    fi
    HOUR=${REBOOT_TIME%:*}
    MINUTE=${REBOOT_TIME#*:}
    echo "$MINUTE $HOUR * * * root /sbin/reboot" > /etc/cron.d/vpn_manager_reboot
    systemctl restart cron
    draw_ui "Auto reboot set to $REBOOT_TIME daily!"
}

# Disable Auto Reboot
disable_auto_reboot() {
    clear
    draw_ui "DISABLE AUTO REBOOT"
    rm -f /etc/cron.d/vpn_manager_reboot
    systemctl restart cron
    draw_ui "Auto reboot disabled!"
}

# Auto Reboot Menu
auto_reboot_menu() {
    while true; do
        clear
        draw_ui "AUTO REBOOT MENU"
        echo -e "${CYAN}┌──────────────────────────────┐${NC}"
        printf "${CYAN}│${NC} %-28s ${CYAN}│${NC}\n" "[1] Set Auto Reboot"
        printf "${CYAN}│${NC} %-28s ${CYAN}│${NC}\n" "[2] Disable Auto Reboot"
        printf "${CYAN}│${NC} %-28s ${CYAN}│${NC}\n" "[0] Back to Main Menu"
        echo -e "${CYAN}└──────────────────────────────┘${NC}"
        read -p "Select an option [0-2]: " option

        case $option in
            1) set_auto_reboot ;;
            2) disable_auto_reboot ;;
            0) exit 0 ;;
            *) echo -e "${RED}Invalid option!${NC}"; sleep 1 ;;
        esac
        read -p "Press Enter to continue..."
    done
}

auto_reboot_menu
