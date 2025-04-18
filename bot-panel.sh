#!/bin/bash

#================[ √ ]=================#
# Jubair VPN Manager - Bot Panel v1.0
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

# Start Bot
start_bot() {
    clear
    draw_ui "STARTING TELEGRAM BOT"
    screen -S telegram-bot -dm python3 /root/VPN_MANAGER/telegram-bot.py
    draw_ui "Telegram bot started in background!"
}

# Stop Bot
stop_bot() {
    clear
    draw_ui "STOPPING TELEGRAM BOT"
    screen -X -S telegram-bot quit
    draw_ui "Telegram bot stopped!"
}

# Restart Bot
restart_bot() {
    clear
    draw_ui "RESTARTING TELEGRAM BOT"
    screen -X -S telegram-bot quit
    screen -S telegram-bot -dm python3 /root/VPN_MANAGER/telegram-bot.py
    draw_ui "Telegram bot restarted!"
}

# Bot Panel Menu
bot_panel_menu() {
    while true; do
        clear
        draw_ui "BOT PANEL MENU"
        echo -e "${CYAN}┌──────────────────────────────┐${NC}"
        printf "${CYAN}│${NC} %-28s ${CYAN}│${NC}\n" "[1] Start Telegram Bot"
        printf "${CYAN}│${NC} %-28s ${CYAN}│${NC}\n" "[2] Stop Telegram Bot"
        printf "${CYAN}│${NC} %-28s ${CYAN}│${NC}\n" "[3] Restart Telegram Bot"
        printf "${CYAN}│${NC} %-28s ${CYAN}│${NC}\n" "[0] Back to Main Menu"
        echo -e "${CYAN}└──────────────────────────────┘${NC}"
        read -p "Select an option [0-3]: " option

        case $option in
            1) start_bot ;;
            2) stop_bot ;;
            3) restart_bot ;;
            0) exit 0 ;;
            *) echo -e "${RED}Invalid option!${NC}"; sleep 1 ;;
        esac
        read -p "Press Enter to continue..."
    done
}

bot_panel_menu
