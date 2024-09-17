#!/bin/bash
# =========================================
MYIP=$(wget -qO- ipinfo.io/ip);
apt install jq curl -y >/dev/null 2>&1
clear
echo -e ""
echo -e  "${BLUE}╭═══════════════════════════════════════════════════╮${NC}"
echo -e  "${BLUE}│  \033[1;37mEjemplo de subdominio XXX.jerrysbg.com Entonces  ${BLUE}│${NC}"
echo -e  "${BLUE}│  \033[1;37mRemplaza solo XXX que sera tu Subdominio         ${BLUE}│${NC}"
echo -e  "${BLUE}╰═══════════════════════════════════════════════════╯${NC}"
echo " "
read -rp "   Ingresa tu Subdominio aquí sin Espacios y en MINUSCULA: " -e sub
echo -e ""
DOMAIN=jerrysbg.com
SUB_DOMAIN=${sub}.jerrysbg.com
CF_ID=pl.ayhackbins@gmail.com
CF_KEY=54235f28506964af3fa4e8c2be734f50b11ed
set -euo pipefail
IP=$(wget -qO- ifconfig.me/ip);
echo "Updating DNS for ${SUB_DOMAIN}..."
ZONE=$(curl -sLX GET "https://api.cloudflare.com/client/v4/zones?name=${DOMAIN}&status=active" \
     -H "X-Auth-Email: ${CF_ID}" \
     -H "X-Auth-Key: ${CF_KEY}" \
     -H "Content-Type: application/json" | jq -r .result[0].id)

RECORD=$(curl -sLX GET "https://api.cloudflare.com/client/v4/zones/${ZONE}/dns_records?name=${SUB_DOMAIN}" \
     -H "X-Auth-Email: ${CF_ID}" \
     -H "X-Auth-Key: ${CF_KEY}" \
     -H "Content-Type: application/json" | jq -r .result[0].id)

if [[ "${#RECORD}" -le 10 ]]; then
     RECORD=$(curl -sLX POST "https://api.cloudflare.com/client/v4/zones/${ZONE}/dns_records" \
     -H "X-Auth-Email: ${CF_ID}" \
     -H "X-Auth-Key: ${CF_KEY}" \
     -H "Content-Type: application/json" \
     --data '{"type":"A","name":"'${SUB_DOMAIN}'","content":"'${IP}'","ttl":120,"proxied":false}' | jq -r .result.id)
fi

RESULT=$(curl -sLX PUT "https://api.cloudflare.com/client/v4/zones/${ZONE}/dns_records/${RECORD}" \
     -H "X-Auth-Email: ${CF_ID}" \
     -H "X-Auth-Key: ${CF_KEY}" \
     -H "Content-Type: application/json" \
     --data '{"type":"A","name":"'${SUB_DOMAIN}'","content":"'${IP}'","ttl":120,"proxied":false}')
echo "Host : $SUB_DOMAIN"
echo "IP=" >> /var/lib/kyt/ipvps.conf
echo $SUB_DOMAIN > /etc/xray/domain
echo $SUB_DOMAIN > /root/domain
cd
rm -f /root/cf.sh
