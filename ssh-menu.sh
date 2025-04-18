#!/bin/bash

#================[ √ ]=================#
# Jubair VPN Manager - SSH Menu v1.0
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

# Create SSH User
create_ssh_user() {
    clear
    draw_ui "CREATE SSH USER"
    read -p "Enter Username: " username
    read -p "Enter Password: " password
    read -p "Enter Expiry Days: " days
    read -p "Enter IP Limit: " ip_limit
    read -p "Enter Server Message: " server_msg
    DOMAIN=$(cat /root/VPN_MANAGER/domain.txt 2>/dev/null || echo "Not Set")
    CURRENT_DATE=$(date +%Y-%m-%d)
    EXPIRY_DATE=$(date -d "$days days" +%Y-%m-%d)

    if id "$username" >/dev/null 2>&1; then
        echo -e "${RED}Username already exists!${NC}"
        return 1
    fi

    useradd -M -s /bin/false "$username"
    echo "$username:$password" | chpasswd
    usermod -e "$EXPIRY_DATE" "$username"
    echo "$username:$password:$days:$ip_limit:$server_msg:$EXPIRY_DATE" >> /root/VPN_MANAGER/ssh_users.txt
    echo "$server_msg" > /etc/ssh/welcome_$username.txt
    sed -i "/^Banner/d" /etc/ssh/sshd_config
    echo "Banner /etc/ssh/welcome_$username.txt" >> /etc/ssh/sshd_config
    systemctl restart sshd dropbear

    # Setup IP Limit
    iptables -A INPUT -p tcp -m multiport --dports 22,80,443 -m connlimit --connlimit-above $ip_limit -j DROP

    draw_ui "SSH ACCOUNT CREATED" \
            "Username    : $username" \
            "Password    : $password" \
            "Created On  : $CURRENT_DATE" \
            "Expires On  : $EXPIRY_DATE" \
            "IP Limit    : $ip_limit" \
            "Server Msg  : $server_msg" \
            "Port Info   : 22,80,443 (SSH)"
}

# Create Trial SSH User
create_trial_ssh_user() {
    clear
    draw_ui "CREATE TRIAL SSH USER"
    username="trial$((RANDOM % 1000))"
    password=$(openssl rand -base64 8)
    days=1
    ip_limit=1
    server_msg="Trial Account by Jubair VPN"
    DOMAIN=$(cat /root/VPN_MANAGER/domain.txt 2>/dev/null || echo "Not Set")
    CURRENT_DATE=$(date +%Y-%m-%d)
    EXPIRY_DATE=$(date -d "$days days" +%Y-%m-%d)

    useradd -M -s /bin/false "$username"
    echo "$username:$password" | chpasswd
    usermod -e "$EXPIRY_DATE" "$username"
    echo "$username:$password:$days:$ip_limit:$server_msg:$EXPIRY_DATE" >> /root/VPN_MANAGER/ssh_users.txt
    echo "$server_msg" > /etc/ssh/welcome_$username.txt
    sed -i "/^Banner/d" /etc/ssh/sshd_config
    echo "Banner /etc/ssh/welcome_$username.txt" >> /etc/ssh/sshd_config
    systemctl restart sshd dropbear

    iptables -A INPUT -p tcp -m multiport --dports 22,80,443 -m connlimit --connlimit-above $ip_limit -j DROP

    draw_ui "TRIAL SSH ACCOUNT CREATED" \
            "Username    : $username" \
            "Password    : $password" \
            "Created On  : $CURRENT_DATE" \
            "Expires On  : $EXPIRY_DATE" \
            "IP Limit    : $ip_limit" \
            "Server Msg  : $server_msg" \
            "Port Info   : 22,80,443 (SSH)"
}

# Delete SSH User
delete_ssh_user() {
    clear
    draw_ui "DELETE SSH USER"
    read -p "Enter Username to Delete: " username
    if id "$username" >/dev/null 2>&1; then
        userdel "$username"
        sed -i "/^$username:/d" /root/VPN_MANAGER/ssh_users.txt
        rm -f /etc/ssh/welcome_$username.txt
        echo -e "${GREEN}User $username deleted!${NC}"
    else
        echo -e "${RED}User $username not found!${NC}"
    fi
}

# List SSH Users
list_ssh_users() {
    clear
    draw_ui "LIST SSH USERS"
    if [ -f /root/VPN_MANAGER/ssh_users.txt ]; then
        cat /root/VPN_MANAGER/ssh_users.txt | while IFS=: read -r user pass days ip msg expiry; do
            echo -e "${GREEN}User: $user, Expires: $expiry, IP Limit: $ip${NC}"
        done
    else
        echo -e "${RED}No SSH users found!${NC}"
    fi
}

# Renew SSH User
renew_ssh_user() {
    clear
    draw_ui "RENEW SSH USER"
    read -p "Enter Username to Renew: " username
    read -p "Enter New Expiry Days: " days
    if id "$username" >/dev/null 2>&1; then
        EXPIRY_DATE=$(date -d "$days days" +%Y-%m-%d)
        usermod -e "$EXPIRY_DATE" "$username"
        sed -i "/^$username:/s/:[0-9]*:/:$days:/" /root/VPN_MANAGER/ssh_users.txt
        sed -i "/^$username:/s/:[0-9-]*$/:$EXPIRY_DATE/" /root/VPN_MANAGER/ssh_users.txt
        echo -e "${GREEN}User $username renewed until $EXPIRY_DATE!${NC}"
    else
        echo -e "${RED}User $username not found!${NC}"
    fi
}

# SSH Menu
ssh_menu() {
    while true; do
        clear
        draw_ui "SSH MENU"
        echo -e "${CYAN}┌──────────────────────────────┐${NC}"
        printf "${CYAN}│${NC} %-28s ${CYAN}│${NC}\n" "[1] Create SSH User"
        printf "${CYAN}│${NC} %-28s ${CYAN}│${NC}\n" "[2] Create Trial SSH User"
        printf "${CYAN}│${NC} %-28s ${CYAN}│${NC}\n" "[3] Delete SSH User"
        printf "${CYAN}│${NC} %-28s ${CYAN}│${NC}\n" "[4] List SSH Users"
        printf "${CYAN}│${NC} %-28s ${CYAN}│${NC}\n" "[5] Renew SSH User"
        printf "${CYAN}│${NC} %-28s ${CYAN}│${NC}\n" "[0] Back to Main Menu"
        echo -e "${CYAN}└──────────────────────────────┘${NC}"
        read -p "Select an option [0-5]: " option

        case $option in
            1) create_ssh_user ;;
            2) create_trial_ssh_user ;;
            3) delete_ssh_user ;;
            4) list_ssh_users ;;
            5) renew_ssh_user ;;
            0) exit 0 ;;
            *) echo -e "${RED}Invalid option!${NC}"; sleep 1 ;;
        esac
        read -p "Press Enter to continue..."
    done
}

ssh_menu
