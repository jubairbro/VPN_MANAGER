#!/bin/bash

#================[ √ ]=================#
# Jubair VPN Manager - Setup Script v1.0
# Script by: JubairBro
#================[ √ ]=================#

# Colors for UI
RED='\033[0;31m'
GREEN='\033[0;32m'
CYAN='\033[0;36m'
NC='\033[0m'

# Function to draw UI
draw_ui() {
    clear
    echo -e "${CYAN}┌──────────────────────────────────────────────┐${NC}"
    for text in "$@"; do
        printf "${CYAN}│${NC} %-44s ${CYAN}│${NC}\n" "$text"
    done
    echo -e "${CYAN}└──────────────────────────────────────────────┘${NC}"
}

# Progress Bar
progress_bar() {
    local duration=$1
    local width=20
    local progress=0
    local increment=$((100 / duration))
    echo -e "${CYAN}[--------------------] 0%${NC}"
    for ((i=0; i<duration; i++)); do
        progress=$((progress + increment))
        local filled=$((progress * width / 100))
        local empty=$((width - filled))
        printf "\r${CYAN}["
        printf "%${filled}s" | tr ' ' '█'
        printf "%${empty}s" | tr ' ' '-'
        printf "] %d%%${NC}" $progress
        sleep 1
    done
    echo -e "\n${GREEN}Done!${NC}"
}

# Check Root
check_root() {
    if [ "$EUID" -ne 0 ]; then
        echo -e "${RED}Run as root!${NC}"
        exit 1
    fi
}

# Install Packages
install_packages() {
    draw_ui "INSTALLING PACKAGES"
    apt update -y && apt upgrade -y
    progress_bar 5
    apt install -y curl net-tools lsb-release speedtest-cli git nano python3 python3-pip nginx certbot python3-certbot-nginx vnstat iptables dropbear stunnel4 haproxy
    pip3 install python-telegram-bot
    # Install Xray
    bash <(curl -Ls https://raw.githubusercontent.com/XTLS/Xray-install/main/install-release.sh)
    systemctl enable xray
    systemctl start xray
    # Install NoobzVPN
    wget -q https://raw.githubusercontent.com/Noobz-ID/noobzvpn-server/master/install.sh -O noobz-install.sh
    bash noobz-install.sh
    progress_bar 5
}

# Disable IPv6
disable_ipv6() {
    draw_ui "DISABLING IPV6"
    sysctl -w net.ipv6.conf.all.disable_ipv6=1
    sysctl -w net.ipv6.conf.default.disable_ipv6=1
    sysctl -w net.ipv6.conf.lo.disable_ipv6=1
    echo "net.ipv6.conf.all.disable_ipv6 = 1" >> /etc/sysctl.conf
    echo "net.ipv6.conf.default.disable_ipv6 = 1" >> /etc/sysctl.conf
    echo "net.ipv6.conf.lo.disable_ipv6 = 1" >> /etc/sysctl.conf
    progress_bar 2
}

# Setup Domain and SSL
setup_domain_ssl() {
    draw_ui "DOMAIN SETUP"
    read -p "Enter your domain (e.g., vpn.yourdomain.com): " DOMAIN
    echo "$DOMAIN" > /root/VPN_MANAGER/domain.txt

    # Setup nginx
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
    mkdir -p /var/www/html
    cat <<EOF > /var/www/html/index.html
<!DOCTYPE html>
<html>
<head>
    <title>Jubair VPN</title>
    <style>
        body { font-family: Arial, sans-serif; text-align: center; background-color: #f0f0f0; }
        h1 { color: #0066cc; }
        p { font-size: 18px; }
        a { color: #0066cc; text-decoration: none; }
        a:hover { text-decoration: underline; }
    </style>
</head>
<body>
    <h1>Welcome to Jubair VPN</h1>
    <p>Fast, Secure, and Reliable VPN Services by JubairBro</p>
    <p>Join our Telegram: <a href="https://t.me/JubairFF">@JubairFF</a></p>
    <p>Contact us for premium VPN accounts!</p>
</body>
</html>
EOF
    ln -sf /etc/nginx/sites-available/vpn /etc/nginx/sites-enabled/
    systemctl restart nginx

    # Setup SSL
    draw_ui "INSTALLING SSL"
    certbot --nginx -d "$DOMAIN" --non-interactive --agree-tos --email admin@$DOMAIN
    systemctl restart nginx
    progress_bar 3
}

# Setup Telegram Bot
setup_telegram_bot() {
    draw_ui "TELEGRAM BOT SETUP"
    read -p "Enter Telegram Bot Token: " BOT_TOKEN
    read -p "Enter Owner Telegram UID: " OWNER_UID
    cat <<EOF > /root/VPN_MANAGER/telegram.conf
BOT_TOKEN=$BOT_TOKEN
OWNER_UID=$OWNER_UID
ADMINS=$OWNER_UID
EOF
    progress_bar 2
}

# Setup Files
setup_files() {
    draw_ui "SETTING UP FILES"
    mkdir -p /root/VPN_MANAGER
    cd /root/VPN_MANAGER
    curl -Ls https://raw.githubusercontent.com/jubairbro/VPN_MANAGER/main/menu -o menu
    curl -Ls https://raw.githubusercontent.com/jubairbro/VPN_MANAGER/main/ssh-menu.sh -o ssh-menu.sh
    curl -Ls https://raw.githubusercontent.com/jubairbro/VPN_MANAGER/main/vmess-menu.sh -o vmess-menu.sh
    curl -Ls https://raw.githubusercontent.com/jubairbro/VPN_MANAGER/main/vless-menu.sh -o vless-menu.sh
    curl -Ls https://raw.githubusercontent.com/jubairbro/VPN_MANAGER/main/trojan-menu.sh -o trojan-menu.sh
    curl -Ls https://raw.githubusercontent.com/jubairbro/VPN_MANAGER/main/shadowsocks-menu.sh -o shadowsocks-menu.sh
    curl -Ls https://raw.githubusercontent.com/jubairbro/VPN_MANAGER/main/noobz-menu.sh -o noobz-menu.sh
    curl -Ls https://raw.githubusercontent.com/jubairbro/VPN_MANAGER/main/telegram-bot.py -o telegram-bot.py
    curl -Ls https://raw.githubusercontent.com/jubairbro/VPN_MANAGER/main/del-all-exp.sh -o del-all-exp.sh
    curl -Ls https://raw.githubusercontent.com/jubairbro/VPN_MANAGER/main/speedtest.sh -o speedtest.sh
    curl -Ls https://raw.githubusercontent.com/jubairbro/VPN_MANAGER/main/domain-ssl.sh -o domain-ssl.sh
    curl -Ls https://raw.githubusercontent.com/jubairbro/VPN_MANAGER/main/info-port.sh -o info-port.sh
    curl -Ls https://raw.githubusercontent.com/jubairbro/VPN_MANAGER/main/restart.sh -o restart.sh
    curl -Ls https://raw.githubusercontent.com/jubairbro/VPN_MANAGER/main/backup-restore.sh -o backup-restore.sh
    curl -Ls https://raw.githubusercontent.com/jubairbro/VPN_MANAGER/main/clear-cache.sh -o clear-cache.sh
    curl -Ls https://raw.githubusercontent.com/jubairbro/VPN_MANAGER/main/bot-panel.sh -o bot-panel.sh
    curl -Ls https://raw.githubusercontent.com/jubairbro/VPN_MANAGER/main/change-banner.sh -o change-banner.sh
    chmod +x *.sh
    chmod +x *.py
    ln -sf /root/VPN_MANAGER/menu /usr/bin/menu
    progress_bar 3
}

# Setup Auto Tasks
setup_auto_tasks() {
    draw_ui "SETTING UP AUTO TASKS"
    echo "0 0 * * * root /root/VPN_MANAGER/del-all-exp.sh" > /etc/cron.d/vpn_manager_expire
    systemctl restart cron
    progress_bar 2
}

# Main Setup
main_setup() {
    check_root
    disable_ipv6
    install_packages
    setup_domain_ssl
    setup_telegram_bot
    setup_files
    setup_auto_tasks
    draw_ui "SETUP COMPLETED" "Type 'menu' to start!"
}

main_setup
