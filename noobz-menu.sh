#!/bin/bash

#================[ √ ]=================#
# Jubair VPN Manager - NoobzVPN Menu v1.0
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

# Create NoobzVPN User
create_noobz_user() {
    clear
    draw_ui "CREATE NOOBZVPN USER"
    read -p "Enter Username: " username
    read -p "Enter Password: " password
    read -p "Enter Expiry Days: " days
    DOMAIN=$(cat /root/VPN_MANAGER/domain.txt 2>/dev/null || echo "Not Set")
    CURRENT_DATE=$(date +%Y-%m-%d)
    EXPIRY_DATE=$(date -d "$days days" +%Y-%m-%d)

    # Add NoobzVPN User
    noobzvpn --add-user "$username" "$password"
    echo "$username:$password:$days:$EXPIRY_DATE" >> /root/VPN_MANAGER/noobz_users.txt

    # Generate NoobzVPN Config
    NOOBZ_CONFIG="Username: $username\nPassword: $password\nServer: $DOMAIN\nPort: 80,443"

    draw_ui "NOOBZVPN ACCOUNT CREATED" \
            "Username       : $username" \
            "Password       : $password" \
            "Domain         : $DOMAIN" \
            "Created On     : $CURRENT_DATE" \
            "Expires On     : $EXPIRY_DATE" \
            "Port           : 80,443" \
            "------------- NOOBZVPN CONFIG -------------" \
            "$NOOBZ_CONFIG"
}

# Create Trial NoobzVPN User
create_trial_noobz_user() {
    clear
    draw_ui "CREATE TRIAL NOOBZVPN USER"
    username="trial$((RANDOM % 1000))"
    password=$(openssl rand -base64 8)
    days=1
    DOMAIN=$(cat /root/VPN_MANAGER/domain.txt 2>/dev/null || echo "Not Set")
    CURRENT_DATE=$(date +%Y-%m-%d)
    EXPIRY_DATE=$(date -d "$days days" +%Y-%m-%d)

    noobzvpn --add-user "$username" "$password"
    echo "$username:$password:$days:$EXPIRY_DATE" >> /root/VPN_MANAGER/noobz_users.txt

    NOOBZ_CONFIG="Username: $username\nPassword: $password\nServer: $DOMAIN\nPort: 80,443"

    draw_ui "TRIAL NOOBZVPN ACCOUNT CREATED" \
            "Username       : $username" \
            "Password       : $password" \
            "Domain         : $DOMAIN" \
            "Created On     : $CURRENT_DATE" \
            "Expires On     : $EXPIRY_DATE" \
            "Port           : 80,443" \
            "------------- NOOBZVPN CONFIG -------------" \
            "$NOOBZ_CONFIG"
}

# Delete NoobzVPN User
delete_noobz_user() {
    clear
    draw_ui "DELETE NOOBZVPN USER"
    read -p "Enter Username to Delete: " username
    if grep -q "$username" /root/VPN_MANAGER/noobz_users.txt; then
        noobzvpn --remove-user "$username"
        sed -i "/$username/d" /root/VPN_MANAGER/noobz_users.txt
        echo -e "${GREEN}NoobzVPN user deleted!${NC}"
    else
        echo -e "${RED}Username not found!${NC}"
    fi
}

# List NoobzVPN Users
list_noobz_users() {
    clear
    draw_ui "LIST NOOBZVPN USERS"
    if [ -f /root/VPN_MANAGER/noobz_users.txt ]; then
        cat /root/VPN_MANAGER/noobz_users.txt | while IFS=: read -r username password days expiry; do
            echo -e "${GREEN}Username: $username, Expires: $expiry${NC}"
        done
    else
        echo -e "${RED}No NoobzVPN users found!${NC}"
    fi
}

# Renew NoobzVPN User
renew_noobz_user() {
    clear
    draw_ui "RENEW NOOBZVPN USER"
    read -p "Enter Username to Renew: " username
    read -p "Enter New Expiry Days: " days
    if grep -q "$username" /root/VPN_MANAGER/noobz_users.txt; then
        EXPIRY_DATE=$(date -d "$days days" +%Y-%m-%d)
        sed -i "/$username/s/:[0-9]*:/:$days:/" /root/VPN_MANAGER/noobz_users.txt
        sed -i "/$username/s/:[0-9-]*$/:$EXPIRY_DATE/" /root/VPN_MANAGER/noobz_users.txt
        echo -e "${GREEN}NoobzVPN user renewed until $EXPIRY_DATE!${NC}"
    else
        echo -e "${RED}Username not found!${NC}"
    fi
}

# NoobzVPN Menu
noobz_menu() {
    while true; do
        clear
        draw_ui "NOOBZVPN MENU"
        echo -e "${CYAN}┌──────────────────────────────┐${NC}"
        printf "${CYAN}│${NC} %-28s ${CYAN}│${NC}\n" "[1] Create NoobzVPN User"
        printf "${CYAN}│${NC} %-28s ${CYAN}│${NC}\n" "[2] Create Trial NoobzVPN User"
        printf "${CYAN}│${NC} %-28s ${CYAN}│${NC}\n" "[3] Delete NoobzVPN User"
        printf "${CYAN}│${NC} %-28s ${CYAN}│${NC}\n" "[4] List NoobzVPN Users"
        printf "${CYAN}│${NC} %-28s ${CYAN}│${NC}\n" "[5] Renew NoobzVPN User"
        printf "${CYAN}│${NC} %-28s ${CYAN}│${NC}\n" "[0] Back to Main Menu"
        echo -e "${CYAN}└──────────────────────────────┘${NC}"
        read -p "Select an option [0-5]: " option

        case $option in
            1) create_noobz_user ;;
            2) create_trial_noobz_user ;;
            3) delete_noobz_user ;;
            4) list_noobz_users ;;
            5) renew_noobz_user ;;
            0) exit 0 ;;
            *) echo -e "${RED}Invalid option!${NC}"; sleep 1 ;;
        esac
        read -p "Press Enter to continue..."
    done
}

noobz_menu
