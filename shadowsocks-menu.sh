#!/bin/bash

#================[ √ ]=================#
# Jubair VPN Manager - Shadowsocks Menu v1.0
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

# Create Shadowsocks User
create_shadowsocks_user() {
    clear
    draw_ui "CREATE SHADOWSOCKS USER"
    read -p "Enter Remarks: " remarks
    read -p "Enter Password: " password
    read -p "Enter Expiry Days: " days
    DOMAIN=$(cat /root/VPN_MANAGER/domain.txt 2>/dev/null || echo "Not Set")
    CURRENT_DATE=$(date +%Y-%m-%d)
    EXPIRY_DATE=$(date -d "$days days" +%Y-%m-%d)

    # Update Xray Config
    CONFIG=$(jq ".inbounds[] | select(.protocol==\"shadowsocks\") | .settings.clients += [{\"password\": \"$password\", \"email\": \"$remarks\", \"method\": \"aes-256-gcm\"}]" /usr/local/etc/xray/shadowsocks_config.json)
    echo "$CONFIG" > /usr/local/etc/xray/shadowsocks_config.json
    systemctl restart xray

    echo "$password:$remarks:$days:$EXPIRY_DATE" >> /root/VPN_MANAGER/shadowsocks_users.txt

    SHADOWSOCKS_WS_TLS="ss://$(echo -n "aes-256-gcm:$password@$DOMAIN:443" | base64 -w 0)#${remarks}_TLS"
    SHADOWSOCKS_WS_NOTLS="ss://$(echo -n "aes-256-gcm:$password@$DOMAIN:80" | base64 -w 0)#${remarks}_NoTLS"

    draw_ui "SHADOWSOCKS ACCOUNT CREATED" \
            "Remarks        : $remarks" \
            "Domain         : $DOMAIN" \
            "Created On     : $CURRENT_DATE" \
            "Expires On     : $EXPIRY_DATE" \
            "Port TLS       : 443" \
            "Port none TLS  : 80" \
            "Password       : $password" \
            "Method         : aes-256-gcm" \
            "Network        : ws" \
            "Path           : /shadowsocks" \
            "----------- SHADOWSOCKS WS TLS -----------" \
            "$SHADOWSOCKS_WS_TLS" \
            "--------- SHADOWSOCKS WS NO TLS ----------" \
            "$SHADOWSOCKS_WS_NOTLS"
}

# Create Trial Shadowsocks User
create_trial_shadowsocks_user() {
    clear
    draw_ui "CREATE TRIAL SHADOWSOCKS USER"
    remarks="trial$((RANDOM % 1000))"
    password=$(openssl rand -base64 8)
    days=1
    DOMAIN=$(cat /root/VPN_MANAGER/domain.txt 2>/dev/null || echo "Not Set")
    CURRENT_DATE=$(date +%Y-%m-%d)
    EXPIRY_DATE=$(date -d "$days days" +%Y-%m-%d)

    CONFIG=$(jq ".inbounds[] | select(.protocol==\"shadowsocks\") | .settings.clients += [{\"password\": \"$password\", \"email\": \"$remarks\", \"method\": \"aes-256-gcm\"}]" /usr/local/etc/xray/shadowsocks_config.json)
    echo "$CONFIG" > /usr/local/etc/xray/shadowsocks_config.json
    systemctl restart xray

    echo "$password:$remarks:$days:$EXPIRY_DATE" >> /root/VPN_MANAGER/shadowsocks_users.txt

    SHADOWSOCKS_WS_TLS="ss://$(echo -n "aes-256-gcm:$password@$DOMAIN:443" | base64 -w 0)#${remarks}_TLS"
    SHADOWSOCKS_WS_NOTLS="ss://$(echo -n "aes-256-gcm:$password@$DOMAIN:80" | base64 -w 0)#${remarks}_NoTLS"

    draw_ui "TRIAL SHADOWSOCKS ACCOUNT CREATED" \
            "Remarks        : $remarks" \
            "Domain         : $DOMAIN" \
            "Created On     : $CURRENT_DATE" \
            "Expires On     : $EXPIRY_DATE" \
            "Port TLS       : 443" \
            "Port none TLS  : 80" \
            "Password       : $password" \
            "Method         : aes-256-gcm" \
            "Network        : ws" \
            "Path           : /shadowsocks" \
            "----------- SHADOWSOCKS WS TLS -----------" \
            "$SHADOWSOCKS_WS_TLS" \
            "--------- SHADOWSOCKS WS NO TLS ----------" \
            "$SHADOWSOCKS_WS_NOTLS"
}

# Delete Shadowsocks User
delete_shadowsocks_user() {
    clear
    draw_ui "DELETE SHADOWSOCKS USER"
    read -p "Enter Password to Delete: " password
    if grep -q "$password" /root/VPN_MANAGER/shadowsocks_users.txt; then
        sed -i "/$password/d" /root/VPN_MANAGER/shadowsocks_users.txt
        CONFIG=$(jq "del(.inbounds[] | select(.protocol==\"shadowsocks\") | .settings.clients[] | select(.password==\"$password\"))" /usr/local/etc/xray/shadowsocks_config.json)
        echo "$CONFIG" > /usr/local/etc/xray/shadowsocks_config.json
        systemctl restart xray
        echo -e "${GREEN}Shadowsocks user deleted!${NC}"
    else
        echo -e "${RED}Password not found!${NC}"
    fi
}

# List Shadowsocks Users
list_shadowsocks_users() {
    clear
    draw_ui "LIST SHADOWSOCKS USERS"
    if [ -f /root/VPN_MANAGER/shadowsocks_users.txt ]; then
        cat /root/VPN_MANAGER/shadowsocks_users.txt | while IFS=: read -r password remarks days expiry; do
            echo -e "${GREEN}Password: $password, Remarks: $remarks, Expires: $expiry${NC}"
        done
    else
        echo -e "${RED}No Shadowsocks users found!${NC}"
    fi
}

# Renew Shadowsocks User
renew_shadowsocks_user() {
    clear
    draw_ui "RENEW SHADOWSOCKS USER"
    read -p "Enter Password to Renew: " password
    read -p "Enter New Expiry Days: " days
    if grep -q "$password" /root/VPN_MANAGER/shadowsocks_users.txt; then
        EXPIRY_DATE=$(date -d "$days days" +%Y-%m-%d)
        sed -i "/$password/s/:[0-9]*:/:$days:/" /root/VPN_MANAGER/shadowsocks_users.txt
        sed -i "/$password/s/:[0-9-]*$/:$EXPIRY_DATE/" /root/VPN_MANAGER/shadowsocks_users.txt
        echo -e "${GREEN}Shadowsocks user renewed until $EXPIRY_DATE!${NC}"
    else
        echo -e "${RED}Password not found!${NC}"
    fi
}

# Shadowsocks Menu
shadowsocks_menu() {
    while true; do
        clear
        draw_ui "SHADOWSOCKS MENU"
        echo -e "${CYAN}┌──────────────────────────────┐${NC}"
        printf "${CYAN}│${NC} %-28s ${CYAN}│${NC}\n" "[1] Create Shadowsocks User"
        printf "${CYAN}│${NC} %-28s ${CYAN}│${NC}\n" "[2] Create Trial Shadowsocks User"
        printf "${CYAN}│${NC} %-28s ${CYAN}│${NC}\n" "[3] Delete Shadowsocks User"
        printf "${CYAN}│${NC} %-28s ${CYAN}│${NC}\n" "[4] List Shadowsocks Users"
        printf "${CYAN}│${NC} %-28s ${CYAN}│${NC}\n" "[5] Renew Shadowsocks User"
        printf "${CYAN}│${NC} %-28s ${CYAN}│${NC}\n" "[0] Back to Main Menu"
        echo -e "${CYAN}└──────────────────────────────┘${NC}"
        read -p "Select an option [0-5]: " option

        case $option in
            1) create_shadowsocks_user ;;
            2) create_trial_shadowsocks_user ;;
            3) delete_shadowsocks_user ;;
            4) list_shadowsocks_users ;;
            5) renew_shadowsocks_user ;;
            0) exit 0 ;;
            *) echo -e "${RED}Invalid option!${NC}"; sleep 1 ;;
        esac
        read -p "Press Enter to continue..."
    done
}

shadowsocks_menu
