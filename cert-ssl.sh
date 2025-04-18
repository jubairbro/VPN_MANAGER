#!/bin/bash

#================[ √ ]=================#
# Jubair VPN Manager - Cert SSL v1.0
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

# Renew SSL Certificate
renew_ssl() {
    clear
    draw_ui "RENEW SSL CERTIFICATE"
    certbot renew
    systemctl restart nginx
    draw_ui "SSL certificate renewed!"
}

# Check SSL Status
check_ssl_status() {
    clear
    draw_ui "CHECK SSL STATUS"
    DOMAIN=$(cat /root/VPN_MANAGER/domain.txt 2>/dev/null || echo "Not Set")
    if [ "$DOMAIN" != "Not Set" ]; then
        SSL_STATUS=$(openssl s_client -connect "$DOMAIN:443" -servername "$DOMAIN" </dev/null 2>/dev/null | openssl x509 -noout -dates)
        draw_ui "SSL STATUS" "$SSL_STATUS"
    else
        draw_ui "No domain set!"
    fi
}

# SSL Menu
ssl_menu() {
    while true; do
        clear
        draw_ui "SSL CERTIFICATE MENU"
        echo -e "${CYAN}┌──────────────────────────────┐${NC}"
        printf "${CYAN}│${NC} %-28s ${CYAN}│${NC}\n" "[1] Renew SSL Certificate"
        printf "${CYAN}│${NC} %-28s ${CYAN}│${NC}\n" "[2] Check SSL Status"
        printf "${CYAN}│${NC} %-28s ${CYAN}│${NC}\n" "[0] Back to Main Menu"
        echo -e "${CYAN}└──────────────────────────────┘${NC}"
        read -p "Select an option [0-2]: " option

        case $option in
            1) renew_ssl ;;
            2) check_ssl_status ;;
            0) exit 0 ;;
            *) echo -e "${RED}Invalid option!${NC}"; sleep 1 ;;
        esac
        read -p "Press Enter to continue..."
    done
}

ssl_menu
