#!/bin/bash

#================[ √ ]=================#
# Jubair VPN Manager - Delete Expired v1.0
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

# Delete Expired Accounts
delete_expired() {
    TODAY=$(date +%Y-%m-%d)
    for PROTOCOL in ssh vmess vless trojan shadowsocks noobz; do
        FILE="/root/VPN_MANAGER/${PROTOCOL}_users.txt"
        if [ -f "$FILE" ]; then
            while IFS=: read -r id remarks days expiry; do
                if [[ "$expiry" < "$TODAY" ]]; then
                    if [ "$PROTOCOL" = "ssh" ]; then
                        userdel "$id" 2>/dev/null
                        rm -f "/etc/ssh/welcome_$id.txt"
                    elif [ "$PROTOCOL" = "vmess" ] || [ "$PROTOCOL" = "vless" ]; then
                        CONFIG=$(jq "del(.inbounds[] | select(.protocol==\"$PROTOCOL\") | .settings.clients[] | select(.id==\"$id\"))" /usr/local/etc/xray/${PROTOCOL}_config.json)
                        echo "$CONFIG" > /usr/local/etc/xray/${PROTOCOL}_config.json
                    elif [ "$PROTOCOL" = "trojan" ] || [ "$PROTOCOL" = "shadowsocks" ]; then
                        CONFIG=$(jq "del(.inbounds[] | select(.protocol==\"$PROTOCOL\") | .settings.clients[] | select(.password==\"$id\"))" /usr/local/etc/xray/${PROTOCOL}_config.json)
                        echo "$CONFIG" > /usr/local/etc/xray/${PROTOCOL}_config.json
                    elif [ "$PROTOCOL" = "noobz" ]; then
                        noobzvpn --remove-user "$id"
                    fi
                    sed -i "/$id/d" "$FILE"
                    echo -e "${GREEN}Deleted expired $PROTOCOL account: $remarks${NC}"
                fi
            done < "$FILE"
        fi
    done
    systemctl restart xray
    systemctl restart sshd dropbear
}

# Main
clear
draw_ui "DELETE EXPIRED ACCOUNTS"
delete_expired
draw_ui "All expired accounts deleted!"
