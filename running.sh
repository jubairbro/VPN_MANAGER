#!/bin/bash

#================[ √ ]=================#
# Jubair VPN Manager - Running Services v1.0
# 엉 by: JubairBro
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

# Check Running Services
check_running_services() {
    clear
    draw_ui "RUNNING SERVICES"
    SSH_STATUS=$(systemctl is-active sshd 2>/dev/null || echo "OFF")
    NGINX_STATUS=$(systemctl is-active nginx 2>/dev/null || echo "OFF")
    XRAY_STATUS=$(systemctl is-active xray 2>/dev/null || echo "OFF")
    DROPBEAR_STATUS=$(systemctl is-active dropbear 2>/dev/null || echo "OFF")
    HAPROXY_STATUS=$(systemctl is-active haproxy 2>/dev/null || echo "OFF")
    WS_EPRO_STATUS="ON" # Placeholder for WS-ePro
    draw_ui "SERVICE STATUS" \
            "SSH        : $SSH_STATUS" \
            "NGINX      : $NGINX_STATUS" \
            "XRAY       : $XRAY_STATUS" \
            "WS-ePRO    : $WS_EPRO_STATUS" \
            "DROPBEAR   : $DROPBEAR_STATUS" \
            "HAPROXY    : $HAPROXY_STATUS"
}

# Main
check_running_services
read -p "Press Enter to continue..."
