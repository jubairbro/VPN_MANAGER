#!/bin/bash

# Colors for UI
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to draw UI
draw_ui() {
    clear
    echo -e "${GREEN}====================================${NC}"
    echo -e "${YELLOW}      JUBAIR VPN MANAGER SETUP      ${NC}"
    echo -e "${GREEN}====================================${NC}"
    echo -e "${GREEN}Powered by Jubair Bro ${NC}"
    echo ""
}

# Function to check for apt lock
check_apt_lock() {
    draw_ui
    echo -e "${YELLOW}Checking for apt locks...${NC}"
    if [ -f /var/lib/apt/lists/lock ] || [ -f /var/lib/dpkg/lock-frontend ]; then
        echo -e "${RED}Apt lock detected. Attempting to resolve...${NC}"
        sudo rm -f /var/lib/apt/lists/lock /var/cache/apt/archives/lock /var/lib/dpkg/lock-frontend
        sudo dpkg --configure -a
        sudo apt clean
        sleep 2
    fi
    echo -e "${GREEN}Apt lock check completed.${NC}"
}

# Function to check internet connectivity
check_internet() {
    draw_ui
    echo -e "${YELLOW}Checking internet connectivity...${NC}"
    if ! ping -c 1 google.com > /dev/null 2>&1; then
        echo -e "${RED}No internet connection. Please check your network and try again.${NC}"
        exit 1
    fi
    echo -e "${GREEN}Internet connection is active.${NC}"
}

# Function to install dependencies
install_dependencies() {
    draw_ui
    echo -e "${YELLOW}Installing dependencies...${NC}"
    sudo apt update
    sudo apt upgrade -y
    sudo apt install -y nginx certbot python3-pip curl git wget unzip
    sudo systemctl enable nginx
    sudo systemctl start nginx
    echo -e "${GREEN}Dependencies installed successfully.${NC}"
}

# Function to set up directory structure
setup_directories() {
    draw_ui
    echo -e "${YELLOW}Setting up directories...${NC}"
    mkdir -p /root/VPN_MANAGER
    cd /root/VPN_MANAGER || exit 1
    echo -e "${GREEN}Directory setup completed.${NC}"
}

# Function to download additional scripts
download_scripts() {
    draw_ui
    echo -e "${YELLOW}Downloading scripts...${NC}"
    local scripts=(
        "menu"
        "ssh-menu.sh"
        "vmess-menu.sh"
        "vless-menu.sh"
        "trojan-menu.sh"
        "shadowsocks-menu.sh"
        "noobz-menu.sh"
        "telegram-bot.py"
        "del-all-exp.sh"
        "speedtest.sh"
        "domain-ssl.sh"
        "info-port.sh"
        "restart.sh"
        "backup-restore.sh"
        "clear-cache.sh"
        "bot-panel.sh"
        "change-banner.sh"
        "limit-speed.sh"
        "auto-reboot.sh"
        "running.sh"
        "clear-log.sh"
        "check-bandwidth.sh"
        "reboot.sh"
        "cert-ssl.sh"
        "install-udp.sh"
        "bot-notification.sh"
        "update-script.sh"
    )

    for script in "${scripts[@]}"; do
        wget -q "https://raw.githubusercontent.com/jubairbro/VPN_MANAGER/main/$script" -O "$script"
        if [ $? -ne 0 ]; then
            echo -e "${RED}Failed to download $script. Please check your internet or repository.${NC}"
            exit 1
        fi
    done
    chmod +x *.sh
    chmod +x *.py
    echo -e "${GREEN}Scripts downloaded and permissions set.${NC}"
}

# Function to install Xray for VMess, VLESS, etc.
install_xray() {
    draw_ui
    echo -e "${YELLOW}Installing Xray...${NC}"
    wget -q https://github.com/XTLS/Xray-core/releases/latest/download/xray-linux-64.zip -O xray.zip
    unzip xray.zip
    mv xray /usr/local/bin/xray
    chmod +x /usr/local/bin/xray
    mkdir -p /usr/local/etc/xray
    echo -e "${GREEN}Xray installed successfully.${NC}"
}

# Function to set up Xray config
setup_xray_config() {
    draw_ui
    echo -e "${YELLOW}Setting up Xray configurations...${NC}"
    cat > /usr/local/etc/xray/vmess_config.json <<EOF
{
    "inbounds": [
        {
            "port": 443,
            "protocol": "vmess",
            "settings": {
                "clients": []
            },
            "streamSettings": {
                "network": "ws",
                "wsSettings": {
                    "path": "/vmess"
                },
                "security": "tls",
                "tlsSettings": {
                    "certificates": [
                        {
                            "certificateFile": "/etc/letsencrypt/live/yourdomain.com/fullchain.pem",
                            "keyFile": "/etc/letsencrypt/live/yourdomain.com/privkey.pem"
                        }
                    ]
                }
            }
        }
    ],
    "outbounds": [
        {
            "protocol": "freedom"
        }
    ]
}
EOF
    cat > /usr/local/etc/xray/vless_config.json <<EOF
{
    "inbounds": [
        {
            "port": 8443,
            "protocol": "vless",
            "settings": {
                "clients": [],
                "decryption": "none"
            },
            "streamSettings": {
                "network": "ws",
                "wsSettings": {
                    "path": "/vless"
                },
                "security": "tls",
                "tlsSettings": {
                    "certificates": [
                        {
                            "certificateFile": "/etc/letsencrypt/live/yourdomain.com/fullchain.pem",
                            "keyFile": "/etc/letsencrypt/live/yourdomain.com/privkey.pem"
                        }
                    ]
                }
            }
        }
    ],
    "outbounds": [
        {
            "protocol": "freedom"
        }
    ]
}
EOF
    echo -e "${GREEN}Xray configurations set up successfully.${NC}"
}

# Function to set up Telegram bot dependencies
setup_telegram_bot() {
    draw_ui
    echo -e "${YELLOW}Setting up Telegram bot...${NC}"
    pip3 install python-telegram-bot
    touch /root/VPN_MANAGER/telegram.conf
    echo "BOT_TOKEN=your_bot_token_here" >> /root/VPN_MANAGER/telegram.conf
    echo "CHAT_ID=your_chat_id_here" >> /root/VPN_MANAGER/telegram.conf
    echo -e "${GREEN}Telegram bot setup completed. Edit /root/VPN_MANAGER/telegram.conf with your bot token and chat ID.${NC}"
}

# Function to set up marketing page
setup_marketing_page() {
    draw_ui
    echo -e "${YELLOW}Setting up marketing page...${NC}"
    mkdir -p /var/www/html
    cat > /var/www/html/index.html <<EOF
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Jubair VPN Manager</title>
    <style>
        body { font-family: Arial, sans-serif; text-align: center; background-color: #f0f0f0; }
        h1 { color: #2c3e50; }
        p { color: #7f8c8d; }
    </style>
</head>
<body>
    <h1>Welcome to Jubair VPN Manager</h1>
    <p>Your trusted VPN solution powered by JubairBro Tools.</p>
    <p>Join our Telegram: <a href="https://t.me/JubairFF">@JubairFF</a></p>
</body>
</html>
EOF
    echo -e "${GREEN}Marketing page set up at /var/www/html/index.html${NC}"
}

# Main setup process
draw_ui
echo -e "${YELLOW}Starting Jubair VPN Manager setup...${NC}"

# Step 1: Check internet
check_internet

# Step 2: Check apt locks
check_apt_lock

# Step 3: Install dependencies
install_dependencies

# Step 4: Set up directories
setup_directories

# Step 5: Download scripts
download_scripts

# Step 6: Install Xray
install_xray

# Step 7: Set up Xray config
setup_xray_config

# Step 8: Set up Telegram bot
setup_telegram_bot

# Step 9: Set up marketing page
setup_marketing_page

# Final message
draw_ui
echo -e "${GREEN}Setup completed successfully!${NC}"
echo -e "${YELLOW}Run the following command to access the main menu:${NC}"
echo -e "${GREEN}menu${NC}"
echo -e "${YELLOW}Edit /root/VPN_MANAGER/telegram.conf to set up your Telegram bot.${NC}"
echo -e "${GREEN}Visit http://<your-vps-ip> to see the nagix server page.${NC}"
