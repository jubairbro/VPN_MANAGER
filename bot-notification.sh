#!/bin/bash

#================[ √ ]=================#
# Jubair VPN Manager - Bot Notification v1.0
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

# Enable Notification
enable_notification() {
    clear
    draw_ui "ENABLE BOT NOTIFICATION"
    read -p "Enter Telegram Chat ID: " CHAT_ID
    read -p "Enter Notification Message: " MESSAGE
    BOT_TOKEN=$(grep BOT_TOKEN /root/VPN_MANAGER/telegram.conf | cut -d= -f2)
    curl -s -X POST "https://api.telegram.org/bot$BOT_TOKEN/sendMessage" -d chat_id="$CHAT_ID" -d text="$MESSAGE"
    echo "NOTIFICATION_CHAT_ID=$CHAT_ID" >> /root/VPN_MANAGER/telegram.conf
    draw_ui "Notification sent and enabled!"
}

# Disable Notification
disable_notification() {
    clear
    draw_ui "DISABLE BOT NOTIFICATION"
    sed -i '/NOTIFICATION_CHAT_ID/d' /root/VPN_MANAGER/telegram.conf
    draw_ui "Notification disabled!"
}

# Notification Menu
notification_menu() {
    while true; do
        clear
        draw_ui "BOT NOTIFICATION MENU"
        echo -e "${CYAN}┌──────────────────────────────┐${NC}"
        printf "${CYAN}│${NC} %-28s ${CYAN}│${NC}\n" "[1] Enable Notification"
        printf "${CYAN}│${NC} %-28s ${CYAN}│${NC}\n" "[2] Disable Notification"
        printf "${CYAN}│${NC} %-28s ${CYAN}│${NC}\n" "[0] Back to Main Menu"
        echo -e "${CYAN}└──────────────────────────────┘${NC}"
        read -p "Select an option [0-2]: " option

        case $option in
            1) enable_notification ;;
            2) disable_notification ;;
            0) exit 0 ;;
            *) echo -e "${RED}Invalid option!${NC}"; sleep 1 ;;
        esac
        read -p "Press Enter to continue..."
    done
}

notification_menu
