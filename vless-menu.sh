#!/bin/bash

#================[ √ ]=================#
# Jubair VPN Manager - VLESS Menu v1.0
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

# Create VLESS User
create_vless_user() {
    clear
    draw_ui "CREATE VLESS USER"
    read -p "Enter Remarks: " remarks
    read -p "Enter Custom UUID (or press Enter for random): " uuid
    read -p "Enter Expiry Days: " days
    uuid=${uuid:-$(cat /proc/sys/kernel/random/uuid)}
    DOMAIN=$(cat /root/VPN_MANAGER/domain.txt 2>/dev/null || echo "Not Set")
    CURRENT_DATE=$(date +%Y-%m-%d)
    EXPIRY_DATE=$(date -d "$days days" +%Y-%m-%d)

    # Update Xray Config
    CONFIG=$(jq ".inbounds[] | select(.protocol==\"vless\") | .settings.clients += [{\"id\": \"$uuid\", \"email\": \"$remarks\"}]" /usr/local/etc/xray/vless_config.json)
    echo "$CONFIG" > /usr/local/etc/xray/vless_config.json
    systemctl restart xray

    echo "$uuid:$remarks:$days:$EXPIRY_DATE" >> /root/VPN_MANAGER/vless_users.txt

    VLESS_WS_TLS="vless://$uuid@$DOMAIN:443?path=/vless&security=tls&encryption=none&host=$DOMAIN&type=ws&sni=$DOMAIN#$remarks"
    VLESS_WS_NOTLS="vless://$uuid@$DOMAIN:80?path=/vless&security=none&encryption=none&host=$DOMAIN&type=ws#$remarks"

    draw_ui "VLESS ACCOUNT CREATED" \
            "Remarks        : $remarks" \
            "Domain         : $CURRENT_DATE" \
            "Expires On     : $EXPIRY_DATE" \
            "Port TLS       : 443" \
            "Port none TLS  : 80" \
            "ID             : $uuid" \
            "Network        : ws" \
            "Path           : /vless" \
            "------------- VLESS WS TLS ------------" \
            "$VLESS_WS_TLS" \
            "----------- VLESS WS NO TLS -----------" \
            "$VLESS_WS_NOTLS"
}

# Create Trial VLESS User
create_trial_vless_user() {
    clear
    draw_ui "CREATE TRIAL VLESS USER"
    remarks="trial$((RANDOM % 1000))"
    uuid=$(cat /proc/sys/kernel/random/uuid)
    days=1
    DOMAIN=$(cat /root/VPN_MANAGER/domain.txt 2>/dev/null || echo "Not Set")
    CURRENT_DATE=$(date +%Y-%m-%d)
    EXPIRY_DATE=$(date -d "$days days" +%Y-%m-%d)

    CONFIG=$(jq ".inbounds[] | select(.protocol==\"vless\") | .settings.clients += [{\"id\": \"$uuid\", \"email\": \"$remarks\"}]" /usr/local/etc/xray/vless_config.json)
    echo "$CONFIG" > /usr/local/etc/xray/vless_config.json
    systemctl restart xray

    echo "$uuid:$remarks:$days:$EXPIRY_DATE" >> /root/VPN_MANAGER/vless_users.txt

    VLESS_WS_TLS="vless://$uuid@$DOMAIN:443?path=/vless&security=tls&encryption=none&host=$DOMAIN&type=ws&sni=$DOMAIN#$remarks"
    VLESS_WS_NOTLS="vless://$uuid@$DOMAIN:80?path=/vless&security=none&encryption=none&host=$DOMAIN&type=ws#$remarks"

    draw_ui "TRIAL VLESS ACCOUNT CREATED" \
            "Remarks        : $remarks" \
            "Domain         : $DOMAIN" \
            "Created On     : $CURRENT_DATE" \
            "Expires On     : $EXPIRY_DATE" \
            "Port TLS       : 443" \
            "Port none TLS  : 80" \
            "ID             : $uuid" \
            "Network        : ws" \
            "Path           : /vless" \
            "------------- VLESS WS TLS ------------" \
            "$VLESS_WS_TLS" \
            "----------- VLESS WS NO TLS -----------" \
            "$VLESS_WS_NOTLS"
}

# Delete VLESS User
delete_vless_user() {
    clear
    draw_ui "DELETE VLESS USER"
    read -p "Enter UUID to Delete: " uuid
    if grep -q "$uuid" /root/VPN_MANAGER/vless_users.txt; then
        sed -i "/$uuid/d" /root/VPN_MANAGER/vless_users.txt
        CONFIG=$(jq "del(.inbounds[] | select(.protocol==\"vless\") | .settings.clients[] | select(.id==\"$uuid\"))" /usr/local/etc/xray/vless_config.json)
        echo "$CONFIG" > /usr/local/etc/xray/vless_config.json
        systemctl restart xray
        echo -e "${GREEN}VLESS user deleted!${NC}"
    else
        echo -e "${RED}UUID not found!${NC}"
    fi
}

# List VLESS Users
list_vless_users() {
    clear
    draw_ui "LIST VLESS USERS"
    if [ -f /root/VPN_MANAGER/vless_users.txt ]; then
        cat /root/VPN_MANAGER/vless_users.txt | while IFS=: read -r uuid remarks days expiry; do
            echo -e "${GREEN}UUID: $uuid, Remarks: $remarks, Expires: $expiry${NC}"
        done
    else
        echo -e "${RED}No VLESS users found!${NC}"
    fi
}

# Renew VLESS User
renew_vless_user() {
    clear
    draw_ui "RENEW VLESS USER"
    read -p "Enter UUID to Renew: " uuid
    read -p "Enter New Expiry Days: " days
    if grep -q "$uuid" /root/VPN_MANAGER/vless_users.txt; then
        EXPIRY_DATE=$(date -d "$days days" +%Y-%m-%d)
        sed -i "/$uuid/s/:[0-9]*:/:$days:/" /root/VPN_MANAGER/vless_users.txt
        sed -i "/$uuid/s/:[0-9-]*$/:$EXPIRY_DATE/" /root/VPN_MANAGER/vless_users.txt
        echo -e "${GREEN}VLESS user renewed until $EXPIRY_DATE!${NC}"
    else
        echo -e "${RED}UUID not found!${NC}"
    fi
}

# VLESS Menu
vless_menu() {
    while true; do
        clear
        draw_ui "VLESS MENU"
        echo -e "${CYAN}┌──────────────────────────────┐${NC}"
        printf "${CYAN}│${NC} %-28s ${CYAN}│${NC}\n" "[1] Create VLESS User"
        printf "${CYAN}│${NC} %-28s ${CYAN}│${NC}\n" "[2] Create Trial VLESS User"
        printf "${CYAN}│${NC} %-28s ${CYAN}│${NC}\n" "[3] Delete VLESS User"
        printf "${CYAN}│${NC} %-28s ${CYAN}│${NC}\n" "[4] List VLESS Users"
        printf "${CYAN}│${NC} %-28s ${CYAN}│${NC}\n" "[5] Renew VLESS User"
        printf "${CYAN}│${NC} %-28s ${CYAN}│${NC}\n" "[0] Back to Main Menu"
        echo -e "${CYAN}└──────────────────────────────┘${NC}"
        read -p "Select an option [0-5]: " option

        case $option in
            1) create_vless_user ;;
            2) create_trial_vless_user ;;
            3) delete_vless_user ;;
            4) list_vless_users ;;
            5) renew_vless_user ;;
            0) exit 0 ;;
            *) echo -e "${RED}Invalid option!${NC}"; sleep 1 ;;
        esac
        read -p "Press Enter to continue..."
    done
}

vless_menu
