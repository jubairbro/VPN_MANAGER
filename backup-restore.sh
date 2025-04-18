#!/bin/bash

#================[ √ ]=================#
# Jubair VPN Manager - Backup/Restore v1.0
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

# Backup
backup() {
    clear
    draw_ui "CREATING BACKUP"
    BACKUP_DIR="/root/VPN_MANAGER/backup"
    mkdir -p "$BACKUP_DIR"
    tar -czf "$BACKUP_DIR/vpn_manager_$(date +%Y%m%d).tar.gz" /root/VPN_MANAGER /etc/nginx /usr/local/etc/xray /var/www/html
    draw_ui "Backup created at $BACKUP_DIR/vpn_manager_$(date +%Y%m%d).tar.gz"
}

# Restore
restore() {
    clear
    draw_ui "RESTORING BACKUP"
    read -p "Enter backup file path: " BACKUP_FILE
    if [ -f "$BACKUP_FILE" ]; then
        tar -xzf "$BACKUP_FILE" -C /
        systemctl restart xray nginx sshd dropbear haproxy
        draw_ui "Backup restored!"
    else
        draw_ui "Backup file not found!"
    fi
}

# Backup/Restore Menu
backup_restore_menu() {
    while true; do
        clear
        draw_ui "BACKUP/RESTORE MENU"
        echo -e "${CYAN}┌──────────────────────────────┐${NC}"
        printf "${CYAN}│${NC} %-28s ${CYAN}│${NC}\n" "[1] Create Backup"
        printf "${CYAN}│${NC} %-28s ${CYAN}│${NC}\n" "[2] Restore Backup"
        printf "${CYAN}│${NC} %-28s ${CYAN}│${NC}\n" "[0] Back to Main Menu"
        echo -e "${CYAN}└──────────────────────────────┘${NC}"
        read -p "Select an option [0-2]: " option

        case $option in
            1) backup ;;
            2) restore ;;
            0) exit 0 ;;
            *) echo -e "${RED}Invalid option!${NC}"; sleep 1 ;;
        esac
        read -p "Press Enter to continue..."
    done
}

backup_restore_menu
