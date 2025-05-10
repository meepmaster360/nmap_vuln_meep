#!/bin/bash
# NmapExplorer - Comprehensive Network Scanning Tool
# Author: YourName
# Version: 2.0

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Banner
echo -e "${BLUE}"
cat << "EOF"
  _   _  __  __                 _____  _                  
 | \ | |/ _|/ _|               |  __ \| |                 
 |  \| | |_| |_ __ _  ___ ___  | |__) | | __ _ _ __   ___ 
 | . ` |  _|  _/ _` |/ __/ _ \ |  ___/| |/ _` | '_ \ / _ \
 | |\  | | | || (_| | (_|  __/ | |    | | (_| | | | |  __/
 |_| \_|_| |_| \__,_|\___\___| |_|    |_|\__,_|_| |_|\___|
EOF
echo -e "${NC}"
echo -e "${YELLOW}        Nmap Network Exploration & Vulnerability Scanner${NC}"
echo -e "${YELLOW}----------------------------------------------------------${NC}"

# Check root
if [ "$(id -u)" != "0" ]; then
    echo -e "${RED}[!] This script must be run as root${NC}" >&2
    exit 1
fi

# Check if nmap is installed
if ! command -v nmap &> /dev/null; then
    echo -e "${YELLOW}[+] Installing Nmap...${NC}"
    apt-get update && apt-get install -y nmap
fi

# Check if vulners.nse script is available
if [ ! -f "/usr/share/nmap/scripts/vulners.nse" ]; then
    echo -e "${YELLOW}[+] Installing Vulners NSE script...${NC}"
    wget -O /usr/share/nmap/scripts/vulners.nse https://svn.nmap.org/nmap/scripts/vulners.nse
    nmap --script-updatedb
fi

# Main menu
echo -e "\n${GREEN}[1] Quick Network Discovery"
echo "[2] Comprehensive Port Scan"
echo "[3] Service Version Detection"
echo "[4] Vulnerability Scan (Vulners)"
echo "[5] Full Audit Scan (Aggressive)"
echo "[6] Custom Nmap Command"
echo "[7] Exit${NC}"

read -p "Select an option [1-7]: " option

case $option in
    1)
        # Quick Network Discovery
        read -p "Enter target IP or range (e.g., 192.168.1.0/24): " target
        echo -e "${YELLOW}[+] Running Ping Sweep...${NC}"
        nmap -sn $target -oN quick_discovery.txt
        echo -e "${GREEN}[+] Results saved to quick_discovery.txt${NC}"
        ;;
    2)
        # Comprehensive Port Scan
        read -p "Enter target IP or range: " target
        echo -e "${YELLOW}[+] Running Comprehensive Port Scan...${NC}"
        nmap -p- --min-rate 1000 -T4 $target -oN full_port_scan.txt
        echo -e "${GREEN}[+] Results saved to full_port_scan.txt${NC}"
        ;;
    3)
        # Service Version Detection
        read -p "Enter target IP or range: " target
        echo -e "${YELLOW}[+] Running Service Detection Scan...${NC}"
        nmap -sV --version-intensity 5 $target -oN service_versions.txt
        echo -e "${GREEN}[+] Results saved to service_versions.txt${NC}"
        ;;
    4)
        # Vulnerability Scan
        read -p "Enter target IP or range: " target
        echo -e "${YELLOW}[+] Running Vulnerability Scan (Vulners)...${NC}"
        nmap -sV --script=vulners.nse $target -oN vulnerability_scan.txt
        echo -e "${GREEN}[+] Results saved to vulnerability_scan.txt${NC}"
        ;;
    5)
        # Full Audit Scan
        read -p "Enter target IP or range: " target
        echo -e "${YELLOW}[+] Running Full Audit Scan (Aggressive)...${NC}"
        nmap -A -T4 -p- --script=vulners.nse $target -oN full_audit_scan.txt
        echo -e "${GREEN}[+] Results saved to full_audit_scan.txt${NC}"
        ;;
    6)
        # Custom Nmap Command
        read -p "Enter your custom Nmap command (without 'nmap'): " custom_cmd
        echo -e "${YELLOW}[+] Running Custom Command...${NC}"
        nmap $custom_cmd
        ;;
    7)
        echo -e "${YELLOW}[+] Exiting...${NC}"
        exit 0
        ;;
    *)
        echo -e "${RED}[!] Invalid option${NC}"
        exit 1
        ;;
esac

# Post-scan options
echo -e "\n${GREEN}Post-scan Options:"
echo "[1] View scan results"
echo "[2] Scan another target"
echo "[3] Exit${NC}"

read -p "Select an option [1-3]: " post_option

case $post_option in
    1)
        case $option in
            1) less quick_discovery.txt ;;
            2) less full_port_scan.txt ;;
            3) less service_versions.txt ;;
            4) less vulnerability_scan.txt ;;
            5) less full_audit_scan.txt ;;
        esac
        ;;
    2)
        exec "$0"
        ;;
    3)
        exit 0
        ;;
    *)
        exit 1
        ;;
esac
