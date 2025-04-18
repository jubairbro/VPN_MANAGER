#!/bin/bash

#================[ √ ]=================#
# Jubair VPN Manager - Trojan Menu v1.0
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

# Create Trojan User
create_trojan_user() {
    clear
    draw_ui "CREATE TROJAN USER"
    read -p "Enter Remarks: " remarks
    read -p "Enter Password: " password
    read -p "Enter Expiry Days: " days
    DOMAIN=$(cat /root/VPN_MANAGER/domain.txt 2>/dev/null || echo "Not Set")
    CURRENT_DATE=$(date +%Y-%m-%d)
    EXPIRY_DATE=$(date -d "$days days" +%Y-%m-%d)

    # Update Xray Config
    CONFIG=$(jq ".inbounds[] | select(.protocol==\"trojan\") | .settings.clients += [{\"password\": \"$password\", \"email\": \"$remarks\"}]" /usr/local/etc/xray/trojan_config.json)
    echo "$CONFIG" > /usr/local/etc/xray/trojan_config.json
    systemctl restart xray

    echo "$password:$remarks:$days:$EXPIRY_DATE" >> /root/VPN_MANAGER/trojan_users.txt

    TROJAN_WS_TLS="trojan://$password@$DOMAIN:443?path=/trojan&security=tls&sni=$DOMAIN#$remarks"
    TROJAN_WS_NOTLS="trojan://$password@$DOMAIN:80?path=/trojan&security=none#$remarks"

    draw_ui "TROJAN ACCOUNT CREATED" \
            "Remarks        : $remarks" \
            "Domain         : $DOMAIN" \
            "Created On     : $CURRENT_DATE" \
            "Expires On     : $EXPIRY_DATE" \
            "Port TLS       : 443" \
            "Port none TLS  : 80" \
            "Password       : $password" \
            "Network        : ws" \
            "Path           : /trojan" \
            "------------- TROJAN WS TLS ------------" \
            "$TROJAN_WS_TLS" \
            "----------- TROJAN WS NO TLS -----------" \
            "$TROJAN_WS_NOTLS"
}

# Create Trial Trojan User
create_trial_trojan_user() {
    clear
    draw_ui "CREATE TRIAL TROJAN USER"
    remarks="trial$((RANDOM % 1000))"
    password=$(openssl rand -base64 8)
    days=1
    DOMAIN=$(cat /root/VPN_MANAGER/domain.txt 2>/dev/null || echo "Not Set")
    CURRENT_DATE=$(date +%Y-%m-%d)
    EXPIRY_DATE=$(date -d "$days days" +%Y-%m-%d)

    CONFIG=$(jq ".inbounds[] | select(.protocol==\"trojan\") | .settings.clients += [{\"password\": \"$password\", \"email\": \"$remarks\"}]" /usr/local/etc/xray/trojan_config.json)
    echo "$CONFIG" > /usr/local/etc/xray/trojan_config.json
    systemctl restart xray

    echo "$password:$remarks:$days:$EXPIRY_DATE" >> /root/VPN_MANAGER/trojan_users.txt

    TROJAN_WS_TLS="trojan://$password@$DOMAIN:443?path=/trojan&security=tls&sni=$DOMAIN#$remarks"
    TROJAN_WS_NOTLS="trojan://$password@$DOMAIN:80?path=/trojan&security=none#$remarks"

    draw_ui "TRIAL TROJAN ACCOUNT CREATED" \
            "Remarks        : $remarks" \
            "Domain         : $DOMAIN" \
            "Created On     : $CURRENT_DATE" \
            "Expires On     : $EXPIRY_DATE" \
            "Port TLS       : 443" \
            "Port none TLS  : 80" \
            "Password       : $password" \
            "Network        : ws" \
            "Path           : /trojan" \
            "------------- TROJAN WS TLS ------------" \
            "$TROJAN_WS_TLS" \
            "----------- TROJAN WS NO TLS -----------" \
            "$TROJAN_WS_NOTLS"
}

# Delete Trojan User
delete_trojan_user() {
    clear
    draw_ui "DELETE TROJAN USER"
    read -p "Enter Password to Delete: " password
    if grep -q "$password" /root/VPN_MANAGER/trojan_users.txt; then
        sed -i "/$password/d" /root/VPN_MANAGER/trojan_users.txt
        CONFIG=$(jq "del(.inbounds[] | select(.protocol==\"trojan\") | .settings.clients[] | select(.password==\"$password\"))" /usr/local/etc/xray/trojan_config.json)
        echo "$CONFIG" > /usr/local/etc/xray/trojan_config.json
        systemctl restart xray
        echo -e "${GREEN}Trojan user deleted!${NC}"
    else
        echo -e "${RED}Password not found!${NC}"
    fi
}

# List Trojan Users
list_trojan_users() {
    clear
    draw_ui "LIST TROJAN USERS"
    if [ -f /root/VPN_MANAGER/trojan_users.txt ]; then
        cat /root/VPN_MANAGER/trojan_users.txt | while IFS=: read -r password remarks days expiry; do
            echo -e "${GREEN}Password: $password, Remarks: $remarks, Expires: $expiry${NC}"
        done
    else
        echo -e "${RED}No Trojan users found!${NC}"
    fi
}

# Renew Trojan User
renew_trojan_user() {
    clear
    draw_ui "RENEW TROJAN USER"
    read -p "Enter Password to Renew: " password
    read -p "Enter New Expiry Days: " days
    if grep -q "$password" /root/VPN_MANAGER/trojan_users.txt; then
        EXPIRY_DATE=$(date -d "$days days" +%Y-%m-%d)
        sed -i "/$password/s/:[0-9]*:/:$days:/" /root/VPN_MANAGER/trojan_users.txt
        sed -i "/$password/s/:[0-9-]*$/:$EXPIRY_DATE/" /root/VPN_MANAGER/trojan_users.txt
        echo -e "${GREEN}Trojan user renewed until $EXPIRY_DATE!${NC}"
    else
        echo -e "${RED}Password not found!${NC}"
    fi
}

# Trojan Menu
trojan_menu() {
    while true; do
        clear
        draw_ui "TROJAN MENU"
        echo -e "${CYAN}┌──────────────────────────────┐${NC}"
        printf "${CYAN}│${NC} %-28s ${CYAN}│${NC}\n" "[1] Create Trojan User"
        printf "${CYAN}│${NC} %-28s ${CYAN}│${NC}\n" "[2] Create Trial Trojan User"
        printf "${CYAN}│${NC} %-28s ${CYAN}│${NC}\n" "[3] Delete Trojan User"
        printf "${CYAN}│${NC} %-28s ${CYAN}│${NC}\n" "[4] List Trojan Users"
        printf "${CYAN}│${NC} %-28s ${CYAN}│${NC}\n" "[5] Renew Trojan User"
        printf "${CYAN}│${NC} %-28s ${CYAN}│${NC}\n" "[0] Back to Main Menu"
        echo -e "${CYAN}└──────────────────────────────┘${NC}"
        read -p "Select an option [0-5]: " option

        case $option in
            1) create_trojan_user ;;
            2) create_trial_trojan_user ;;
            3) delete_trojan_user ;;
            4) list_trojan_users ;;
            5) renew_trojan_user ;;
            0) exit 0 ;;
            *) echo -e "${RED}Invalid option!${NC}"; sleep 1 ;;
        esac
        read -p "Press Enter to continue..."
    done
}

trojan_menu
