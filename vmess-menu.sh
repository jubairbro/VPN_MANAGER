#!/bin/bash

#================[ √ ]=================#
# Jubair VPN Manager - VMess Menu v1.0
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

# Create VMess User
create_vmess_user() {
    clear
    draw_ui "CREATE VMESS USER"
    read -p "Enter Remarks: " remarks
    read -p "Enter Custom UUID (or press Enter for random): " uuid
    read -p "Enter Expiry Days: " days
    uuid=${uuid:-$(cat /proc/sys/kernel/random/uuid)}
    DOMAIN=$(cat /root/VPN_MANAGER/domain.txt 2>/dev/null || echo "Not Set")
    CURRENT_DATE=$(date +%Y-%m-%d)
    EXPIRY_DATE=$(date -d "$days days" +%Y-%m-%d)

    # Update Xray Config
    CONFIG=$(jq ".inbounds[] | select(.protocol==\"vmess\") | .settings.clients += [{\"id\": \"$uuid\", \"email\": \"$remarks\"}]" /usr/local/etc/xray/vmess_config.json)
    echo "$CONFIG" > /usr/local/etc/xray/vmess_config.json
    systemctl restart xray

    echo "$uuid:$remarks:$days:$EXPIRY_DATE" >> /root/VPN_MANAGER/vmess_users.txt

    VMESS_WS_TLS="vmess://$(echo -n "{\"v\": \"2\", \"ps\": \"$remarks\", \"add\": \"$DOMAIN\", \"port\": \"443\", \"id\": \"$uuid\", \"aid\": 0, \"net\": \"ws\", \"path\": \"/vmess\", \"tls\": \"tls\", \"sni\": \"$DOMAIN\"}" | base64 -w 0)"
    VMESS_WS_NOTLS="vmess://$(echo -n "{\"v\": \"2\", \"ps\": \"$remarks\", \"add\": \"$DOMAIN\", \"port\": \"80\", \"id\": \"$uuid\", \"aid\": 0, \"net\": \"ws\", \"path\": \"/vmess\", \"tls\": \"none\"}" | base64 -w 0)"

    draw_ui "VMESS ACCOUNT CREATED" \
            "Remarks        : $remarks" \
            "Domain         : $DOMAIN" \
            "Created On     : $CURRENT_DATE" \
            "Expires On     : $EXPIRY_DATE" \
            "Port TLS       : 443" \
            "Port none TLS  : 80" \
            "ID             : $uuid" \
            "Network        : ws" \
            "Path           : /vmess" \
            "------------- VMESS WS TLS ------------" \
            "$VMESS_WS_TLS" \
            "----------- VMESS WS NO TLS -----------" \
            "$VMESS_WS_NOTLS"
}

# Create Trial VMess User
create_trial_vmess_user() {
    clear
    draw_ui "CREATE TRIAL VMESS USER"
    remarks="trial$((RANDOM % 1000))"
    uuid=$(cat /proc/sys/kernel/random/uuid)
    days=1
    DOMAIN=$(cat /root/VPN_MANAGER/domain.txt 2>/dev/null || echo "Not Set")
    CURRENT_DATE=$(date +%Y-%m-%d)
    EXPIRY_DATE=$(date -d "$days days" +%Y-%m-%d)

    CONFIG=$(jq ".inbounds[] | select(.protocol==\"vmess\") | .settings.clients += [{\"id\": \"$uuid\", \"email\": \"$remarks\"}]" /usr/local/etc/xray/vmess_config.json)
    echo "$CONFIG" > /usr/local/etc/xray/vmess_config.json
    systemctl restart xray

    echo "$uuid:$remarks:$days:$EXPIRY_DATE" >> /root/VPN_MANAGER/vmess_users.txt

    VMESS_WS_TLS="vmess://$(echo -n "{\"v\": \"2\", \"ps\": \"$remarks\", \"add\": \"$DOMAIN\", \"port\": \"443\", \"id\": \"$uuid\", \"aid\": 0, \"net\": \"ws\", \"path\": \"/vmess\", \"tls\": \"tls\", \"sni\": \"$DOMAIN\"}" | base64 -w 0)"
    VMESS_WS_NOTLS="vmess://$(echo -n "{\"v\": \"2\", \"ps\": \"$remarks\", \"add\": \"$DOMAIN\", \"port\": \"80\", \"id\": \"$uuid\", \"aid\": 0, \"net\": \"ws\", \"path\": \"/vmess\", \"tls\": \"none\"}" | base64 -w 0)"

    draw_ui "TRIAL VMESS ACCOUNT CREATED" \
            "Remarks        : $remarks" \
            "Domain         : $DOMAIN" \
            "Created On     : $CURRENT_DATE" \
            "Expires On     : $EXPIRY_DATE" \
            "Port TLS       : 443" \
            "Port none TLS  : 80" \
            "ID             : $uuid" \
            "Network        : ws" \
            "Path           : /vmess" \
            "------------- VMESS WS TLS ------------" \
            "$VMESS_WS_TLS" \
            "----------- VMESS WS NO TLS -----------" \
            "$VMESS_WS_NOTLS"
}

# Delete VMess User
delete_vmess_user() {
    clear
    draw_ui "DELETE VMESS USER"
    read -p "Enter UUID to Delete: " uuid
    if grep -q "$uuid" /root/VPN_MANAGER/vmess_users.txt; then
        sed -i "/$uuid/d" /root/VPN_MANAGER/vmess_users.txt
        CONFIG=$(jq "del(.inbounds[] | select(.protocol==\"vmess\") | .settings.clients[] | select(.id==\"$uuid\"))" /usr/local/etc/xray/vmess_config.json)
        echo "$CONFIG" > /usr/local/etc/xray/vmess_config.json
        systemctl restart xray
        echo -e "${GREEN}VMess user deleted!${NC}"
    else
        echo -e "${RED}UUID not found!${NC}"
    fi
}

# List VMess Users
list_vmess_users() {
    clear
    draw_ui "LIST VMESS USERS"
    if [ -f /root/VPN_MANAGER/vmess_users.txt ]; then
        cat /root/VPN_MANAGER/vmess_users.txt | while IFS=: read -r uuid remarks days expiry; do
            echo -e "${GREEN}UUID: $uuid, Remarks: $remarks, Expires: $expiry${NC}"
        done
    else
        echo -e "${RED}No VMess users found!${NC}"
    fi
}

# Renew VMess User
renew_vmess_user() {
    clear
    draw_ui "RENEW VMESS USER"
    read -p "Enter UUID to Renew: " uuid
    read -p "Enter New Expiry Days: " days
    if grep -q "$uuid" /root/VPN_MANAGER/vmess_users.txt; then
        EXPIRY_DATE=$(date -d "$days days" +%Y-%m-%d)
        sed -i "/$uuid/s/:[0-9]*:/:$days:/" /root/VPN_MANAGER/vmess_users.txt
        sed -i "/$uuid/s/:[0-9-]*$/:$EXPIRY_DATE/" /root/VPN_MANAGER/vmess_users.txt
        echo -e "${GREEN}VMess user renewed until $EXPIRY_DATE!${NC}"
    else
        echo -e "${RED}UUID not found!${NC}"
    fi
}

# VMess Menu
vmess_menu() {
    while true; do
        clear
        draw_ui "VMESS MENU"
        echo -e "${CYAN}┌──────────────────────────────┐${NC}"
        printf "${CYAN}│${NC} %-28s ${CYAN}│${NC}\n" "[1] Create VMess User"
        printf "${CYAN}│${NC} %-28s ${CYAN}│${NC}\n" "[2] Create Trial VMess User"
        printf "${CYAN}│${NC} %-28s ${CYAN}│${NC}\n" "[3] Delete VMess User"
        printf "${CYAN}│${NC} %-28s ${CYAN}│${NC}\n" "[4] List VMess Users"
        printf "${CYAN}│${NC} %-28s ${CYAN}│${NC}\n" "[5] Renew VMess User"
        printf "${CYAN}│${NC} %-28s ${CYAN}│${NC}\n" "[0] Back to Main Menu"
        echo -e "${CYAN}└──────────────────────────────┘${NC}"
        read -p "Select an option [0-5]: " option

        case $option in
            1) create_vmess_user ;;
            2) create_trial_vmess_user ;;
            3) delete_vmess_user ;;
            4) list_vmess_users ;;
            5) renew_vmess_user ;;
            0) exit 0 ;;
            *) echo -e "${RED}Invalid option!${NC}"; sleep 1 ;;
        esac
        read -p "Press Enter to continue..."
    done
}

vmess_menu
