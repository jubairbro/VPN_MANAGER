#!/bin/bash

#================[ √ ]=================#
# Jubair VPN Manager - Speedtest v1.0
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

# Run Speedtest
run_speedtest() {
    clear
    draw_ui "RUNNING SPEEDTEST"
    speedtest-cli --simple > /tmp/speedtest.txt
    PING=$(grep "Ping" /tmp/speedtest.txt | awk '{print $2 " " $3}')
    DOWNLOAD=$(grep "Download" /tmp/speedtest.txt | awk '{print $2 " " $3}')
    UPLOAD=$(grep "Upload" /tmp/speedtest.txt | awk '{print $2 " " $3}')
    draw_ui "SPEEDTEST RESULTS" \
            "Ping       : $PING" \
            "Download   : $DOWNLOAD" \
            "Upload     : $UPLOAD"
    rm -f /tmp/speedtest.txt
}

# Main
run_speedtest
read -p "Press Enter to continue..."
