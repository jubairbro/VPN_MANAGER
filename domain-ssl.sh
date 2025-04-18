#!/bin/bash

#================[ √ ]=================#
# Jubair VPN Manager - Domain SSL v1.0
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

# Add New Domain
add_domain() {
    clear
    draw_ui "ADD NEW DOMAIN"
    read -p "Enter new domain (e.g., vpn.yourdomain.com): " DOMAIN
    echo "$DOMAIN" > /root/VPN_MANAGER/domain.txt
    cat <<EOF > /etc/nginx/sites-available/vpn
server {
    listen 80;
    server_name $DOMAIN;
    return 301 https://\$host\$request_uri;
}
server {
    listen 443 ssl;
    server_name $DOMAIN;
    ssl_certificate /etc/letsencrypt/live/$DOMAIN/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/$DOMAIN/privkey.pem;
    root /var/www/html;
    index index.html;
    location /vmess {
        proxy_pass http://127.0.0.1:443;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_set_header Host \$host;
    }
    location /vless {
        proxy_pass http://127.0.0.1:443;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_set_header Host \$host;
    }
    location /trojan {
        proxy_pass http://127.0.0.1:443;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_set_header Host \$host;
    }
    location /shadowsocks {
        proxy_pass http://127.0.0.1:443;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_set_header Host \$host;
    }
}
EOF
    ln -sf /etc/nginx/sites-available/vpn /etc/nginx/sites-enabled/
    certbot --nginx -d "$DOMAIN" --non-interactive --agree-tos --email admin@$DOMAIN
    systemctl restart nginx
    draw_ui "Domain $DOMAIN added and SSL installed!"
}

# Edit Index.html
edit_index_html() {
    clear
    draw_ui "EDIT INDEX.HTML"
    nano /var/www/html/index.html
    draw_ui "Index.html saved!"
}

# Renew SSL
renew_ssl() {
    clear
    draw_ui "RENEW SSL CERTIFICATE"
    certbot renew
    systemctl restart nginx
    draw_ui "SSL certificate renewed!"
}

# Check Domain Status
check_domain_status() {
    clear
    draw_ui "CHECK DOMAIN STATUS"
    DOMAIN=$(cat /root/VPN_MANAGER/domain.txt 2>/dev/null || echo "Not Set")
    if [ "$DOMAIN" != "Not Set" ]; then
        STATUS=$(curl -s -I "https://$DOMAIN" | grep HTTP)
        echo -e "${GREEN}Domain: $DOMAIN\nStatus: $STATUS${NC}"
    else
        echo -e "${RED}No domain set!${NC}"
    fi
}

# Create Trial Account
create_trial_account() {
    clear
    draw_ui "CREATE TRIAL ACCOUNT"
    /root/VPN_MANAGER/ssh-menu.sh
}

# Domain SSL Menu
domain_ssl_menu() {
    while true; do
        clear
        draw_ui "DOMAIN SSL MENU"
        echo -e "${CYAN}┌──────────────────────────────┐${NC}"
        printf "${CYAN}│${NC} %-28s ${CYAN}│${NC}\n" "[1] Add New Domain"
        printf "${CYAN}│${NC} %-28s ${CYAN}│${NC}\n" "[2] Edit Index.html"
        printf "${CYAN}│${NC} %-28s ${CYAN}│${NC}\n" "[3] Renew SSL Certificate"
        printf "${CYAN}│${NC} %-28s ${CYAN}│${NC}\n" "[4] Check Domain Status"
        printf "${CYAN}│${NC} %-28s ${CYAN}│${NC}\n" "[5] Create Trial Account"
        printf "${CYAN}│${NC} %-28s ${CYAN}│${NC}\n" "[0] Back to Main Menu"
        echo -e "${CYAN}└──────────────────────────────┘${NC}"
        read -p "Select an option [0-5]: " option

        case $option in
            1) add_domain ;;
            2) edit_index_html ;;
            3) renew_ssl ;;
            4) check_domain_status ;;
            5) create_trial_account ;;
            0) exit 0 ;;
            *) echo -e "${RED}Invalid option!${NC}"; sleep 1 ;;
        esac
        read -p "Press Enter to continue..."
    done
}

domain_ssl_menu
