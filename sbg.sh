#!/bin/bash
# ===================
export BLUE='\033[1;36m'
export NC='\033[0m'
clear
rm -rf $(pwd)/sbg.sh
rm -rf $(pwd)/sbg.sh.1
rm -rf $(pwd)/sbg.sh.2
rm -rf $(pwd)/sbg.sh.3
echo -e "  ${BLUE}╭══════════════════════════════════════╮${NC}"
echo -e "  ${BLUE}│        ACTUALIZANDO BASE DE DATOS!${NC}"
echo -e "  ${BLUE}╰══════════════════════════════════════╯${NC}"
sleep 3
sysctl -w net.ipv6.conf.all.disable_ipv6=1 && sysctl -w net.ipv6.conf.default.disable_ipv6=1 && apt clean && rm -rf /var/lib/apt/lists/* && apt clean && apt update && apt upgrade -y && apt install git
clear
echo -e "  ${BLUE}╭══════════════════════════════════════╮${NC}"
echo -e "  ${BLUE}│        DESCARGANDO ARCHIVOS!${NC}"
echo -e "  ${BLUE}╰══════════════════════════════════════╯${NC}"
echo -e ""
sleep 3
wget https://raw.githubusercontent.com/JerrySBG/scvps/main/sbg2.sh && chmod +x sbg2.sh && ./sbg2.sh
