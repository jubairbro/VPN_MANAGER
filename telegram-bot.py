#!/usr/bin/env python3

#================[ √ ]=================#
# Jubair VPN Manager - Telegram Bot v1.0
# Script by: JubairBro
#================[ √ ]=================#

import telegram
from telegram.ext import Updater, CommandHandler, MessageHandler, Filters
import subprocess
import os
import random

# Load Config
def load_config():
    config = {}
    with open('/root/VPN_MANAGER/telegram.conf', 'r') as f:
        for line in f:
            key, value = line.strip().split('=')
            config[key] = value
    return config

CONFIG = load_config()
BOT_TOKEN = CONFIG['BOT_TOKEN']
OWNER_UID = int(CONFIG['OWNER_UID'])
ADMINS = [int(uid) for uid in CONFIG['ADMINS'].split(',')]

# Helper Functions
def run_command(command):
    result = subprocess.run(command, shell=True, capture_output=True, text=True)
    return result.stdout or result.stderr

def create_trial_user(protocol):
    if protocol == 'ssh':
        username = f"trial{random.randint(100, 999)}"
        password = run_command("openssl rand -base64 8").strip()
        days = 1
        ip_limit = 1
        server_msg = "Trial Account by Jubair VPN"
        expiry_date = run_command(f"date -d '{days} days' +%Y-%m-%d").strip()
        run_command(f"useradd -M -s /bin/false {username}")
        run_command(f"echo '{username}:{password}' | chpasswd")
        run_command(f"usermod -e '{expiry_date}' {username}")
        run_command(f"echo '{username}:{password}:{days}:{ip_limit}:{server_msg}:{expiry_date}' >> /root/VPN_MANAGER/ssh_users.txt")
        run_command(f"echo '{server_msg}' > /etc/ssh/welcome_{username}.txt")
        run_command(f"sed -i '/^Banner/d' /etc/ssh/sshd_config")
        run_command(f"echo 'Banner /etc/ssh/welcome_{username}.txt' >> /etc/ssh/sshd_config")
        run_command("systemctl restart sshd dropbear")
        run_command(f"iptables -A INPUT -p tcp -m multiport --dports 22,80,443 -m connlimit --connlimit-above {ip_limit} -j DROP")
        return f"Trial SSH Created:\nUsername: {username}\nPassword: {password}\nExpires: {expiry_date}"
    else:
        return f"Trial {protocol} not implemented yet."

# Bot Commands
def start(update, context):
    user_id = update.message.from_user.id
    if user_id not in ADMINS:
        update.message.reply_text("You are not authorized!")
        return
    update.message.reply_text("Welcome to Jubair VPN Manager Bot!\nAvailable commands:\n/ssh_menu\n/vmess_menu\n/vless_menu\n/trojan_menu\n/shadowsocks_menu\n/noobz_menu\n/server_status\n/trial <protocol>")

def ssh_menu(update, context):
    user_id = update.message.from_user.id
    if user_id not in ADMINS:
        update.message.reply_text("You are not authorized!")
        return
    update.message.reply_text("SSH Management:\n1. Create User: /create_ssh <username> <password> <days> <ip_limit>\n2. Delete User: /delete_ssh <username>\n3. List Users: /list_ssh\n4. Renew User: /renew_ssh <username> <days>")

def create_ssh(update, context):
    user_id = update.message.from_user.id
    if user_id not in ADMINS:
        update.message.reply_text("You are not authorized!")
        return
    args = context.args
    if len(args) != 4:
        update.message.reply_text("Usage: /create_ssh <username> <password> <days> <ip_limit>")
        return
    username, password, days, ip_limit = args
    server_msg = "Account by Jubair VPN"
    expiry_date = run_command(f"date -d '{days} days' +%Y-%m-%d").strip()
    run_command(f"useradd -M -s /bin/false {username}")
    run_command(f"echo '{username}:{password}' | chpasswd")
    run_command(f"usermod -e '{expiry_date}' {username}")
    run_command(f"echo '{username}:{password}:{days}:{ip_limit}:{server_msg}:{expiry_date}' >> /root/VPN_MANAGER/ssh_users.txt")
    run_command(f"echo '{server_msg}' > /etc/ssh/welcome_{username}.txt")
    run_command(f"sed -i '/^Banner/d' /etc/ssh/sshd_config")
    run_command(f"echo 'Banner /etc/ssh/welcome_{username}.txt' >> /etc/ssh/sshd_config")
    run_command("systemctl restart sshd dropbear")
    run_command(f"iptables -A INPUT -p tcp -m multiport --dports 22,80,443 -m connlimit --connlimit-above {ip_limit} -j DROP")
    update.message.reply_text(f"SSH User Created:\nUsername: {username}\nPassword: {password}\nExpires: {expiry_date}")

def delete_ssh(update, context):
    user_id = update.message.from_user.id
    if user_id not in ADMINS:
        update.message.reply_text("You are not authorized!")
        return
    if not context.args:
        update.message.reply_text("Usage: /delete_ssh <username>")
        return
    username = context.args[0]
    if run_command(f"id {username}") == "":
        update.message.reply_text("User not found!")
        return
    run_command(f"userdel {username}")
    run_command(f"sed -i '/^{username}:/d' /root/VPN_MANAGER/ssh_users.txt")
    run_command(f"rm -f /etc/ssh/welcome_{username}.txt")
    update.message.reply_text(f"User {username} deleted!")

def list_ssh(update, context):
    user_id = update.message.from_user.id
    if user_id not in ADMINS:
        update.message.reply_text("You are not authorized!")
        return
    users = run_command("cat /root/VPN_MANAGER/ssh_users.txt")
    if not users:
        update.message.reply_text("No SSH users found!")
        return
    update.message.reply_text(f"SSH Users:\n{users}")

def renew_ssh(update, context):
    user_id = update.message.from_user.id
    if user_id not in ADMINS:
        update.message.reply_text("You are not authorized!")
        return
    if len(context.args) != 2:
        update.message.reply_text("Usage: /renew_ssh <username> <days>")
        return
    username, days = context.args
    if run_command(f"id {username}") == "":
        update.message.reply_text("User not found!")
        return
    expiry_date = run_command(f"date -d '{days} days' +%Y-%m-%d").strip()
    run_command(f"usermod -e '{expiry_date}' {username}")
    run_command(f"sed -i '/^{username}/s/:[0-9]*:/:{days}:/' /root/VPN_MANAGER/ssh_users.txt")
    run_command(f"sed -i '/^{username}/s/:[0-9-]*$/:${expiry_date}/' /root/VPN_MANAGER/ssh_users.txt")
    update.message.reply_text(f"User {username} renewed until {expiry_date}!")

def server_status(update, context):
    user_id = update.message.from_user.id
    if user_id not in ADMINS:
        update.message.reply_text("You are not authorized!")
        return
    os = run_command("lsb_release -d | awk -F'\t' '{print $2}'").strip()
    cpu = run_command("nproc").strip()
    ram = run_command("free -m | awk '/Mem:/ {print $3\"/\"$2}'").strip()
    ip = run_command("curl -s ifconfig.me").strip()
    isp = run_command("whois $ip | grep -i 'orgname' | awk '{print $2}'").strip() or "Unknown"
    city = run_command("whois $ip | grep -i 'city' | awk '{print $2}'").strip() or "Unknown"
    ssh_status = run_command("systemctl is-active sshd").strip()
    nginx_status = run_command("systemctl is-active nginx").strip()
    xray_status = run_command("systemctl is-active xray").strip()
    update.message.reply_text(f"Server Status:\nOS: {os}\nCPU: {cpu}\nRAM: {ram} MB\nIP: {ip}\nISP: {isp}\nCity: {city}\nSSH: {ssh_status}\nNGINX: {nginx_status}\nXRAY: {xray_status}")

def trial(update, context):
    user_id = update.message.from_user.id
    if user_id not in ADMINS:
        update.message.reply_text("You are not authorized!")
        return
    if not context.args:
        update.message.reply_text("Usage: /trial <ssh|vmess|vless|trojan|shadowsocks|noobz>")
        return
    protocol = context.args[0].lower()
    if protocol not in ['ssh', 'vmess', 'vless', 'trojan', 'shadowsocks', 'noobz']:
        update.message.reply_text("Invalid protocol!")
        return
    result = create_trial_user(protocol)
    update.message.reply_text(result)

def main():
    updater = Updater(BOT_TOKEN, use_context=True)
    dp = updater.dispatcher
    dp.add_handler(CommandHandler("start", start))
    dp.add_handler(CommandHandler("ssh_menu", ssh_menu))
    dp.add_handler(CommandHandler("create_ssh", create_ssh))
    dp.add_handler(CommandHandler("delete_ssh", delete_ssh))
    dp.add_handler(CommandHandler("list_ssh", list_ssh))
    dp.add_handler(CommandHandler("renew_ssh", renew_ssh))
    dp.add_handler(CommandHandler("server_status", server_status))
    dp.add_handler(CommandHandler("trial", trial))
    updater.start_polling()
    updater.idle()

if __name__ == '__main__':
    main()
