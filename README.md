# Jubair VPN Manager

A fully automated VPN setup script for VPS with support for multiple protocols, Telegram bot management, and a marketing page. This script simplifies the process of setting up a VPN server with SSH, VMess, VLESS, Trojan, Shadowsocks, and NoobzVPN protocols.

## Features
- **Multiple Protocols**: Supports SSH, VMess, VLESS, Trojan, Shadowsocks, and NoobzVPN.
- **WebSocket & TLS**: All protocols support WebSocket (WS) and TLS for secure connections.
- **Automated SSL**: Integrates Let's Encrypt for free SSL certificates.
- **Telegram Bot**: Manage users and server remotely via a Telegram bot.
- **Marketing Page**: Customizable landing page for your VPN service.
- **No Expiry**: Scripts are fully owned by you with no expiry.
- **User-Friendly UI**: Clean and intuitive menu interface.
- **Additional Tools**: Speedtest, bandwidth monitoring, auto-reboot, backup/restore, and more.

## Prerequisites
- A fresh VPS running **Ubuntu 20.04 or 22.04**.
- Root access to the VPS.
- A domain name (optional, for SSL and custom branding).

## Installation
Run the following command to install Jubair VPN Manager on your VPS:

```bash
apt update && apt upgrade -y && update-grub && sleep 2 && apt install wget -y && echo 1 > /proc/sys/net/ipv6/conf/all/disable_ipv6 && wget https://raw.githubusercontent.com/jubairbro/VPN_MANAGER/main/setup.sh && chmod +x setup.sh && ./setup.sh
```

##update comend # First, check and clear any apt locks

```bash
sudo rm -f /var/lib/apt/lists/lock /var/cache/apt/archives/lock /var/lib/dpkg/lock-frontend; sudo dpkg --configure -a; sudo apt clean; sudo apt update && sudo apt upgrade -y && sudo update-grub && sleep 2 && sudo apt install wget -y && echo 1 > /proc/sys/net/ipv6/conf/all/disable_ipv6 && wget https://raw.githubusercontent.com/jubairbro/VPN_MANAGER/main/setup.sh && chmod +x setup.sh && ./setup.sh```


This command:
- Updates the system and installs `wget`.
- Disables IPv6 for compatibility.
- Downloads and executes the `setup.sh` script from this repository.

## Usage
1. After installation, run the main menu:
   ```bash
   menu
   ```
2. Use the menu to create users, manage protocols, set up SSL, or configure the Telegram bot.
3. Access the marketing page at `http://<your-vps-ip>` or `https://<your-domain>` (if SSL is configured).
4. Use the Telegram bot for remote management (configure in `telegram.conf`).

## File Structure
- `setup.sh`: Initial setup script.
- `menu`: Main menu for managing VPN services.
- `<protocol>-menu.sh`: Individual scripts for SSH, VMess, VLESS, etc.
- `telegram-bot.py`: Telegram bot for remote management.
- Other utilities: `speedtest.sh`, `backup-restore.sh`, `auto-reboot.sh`, etc.

## Customization
- **Marketing Page**: Edit `/var/www/html/index.html` to customize the landing page.
- **Telegram Bot**: Update `/root/VPN_MANAGER/telegram.conf` with your bot token and admin IDs.
- **Domain**: Set your domain in `/root/VPN_MANAGER/domain.txt` for SSL and branding.

## Support
For issues or suggestions, join our Telegram group: [Telegram Link](https://t.me/JubairFF)  
Or open an issue on this repository.

## Contributing
Feel free to fork this repository, make improvements, and submit pull requests.


---

**Note**: Always test on a fresh VPS to avoid conflicts with existing configurations.
