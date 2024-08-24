#!/bin/sh
RED='\033[1;31m'
GREEN='\033[1;32m'
YELLOW='\033[1;33m'
CYAN='\033[1;36m'
GRAY='\033[1;37m'
WHITE='\033[1;37m'
ns_domain_cloudflare() {
	#delete directory
    rm -rf /etc/xray/dns
    rm dns
	DOMAIN="tepllovpn.eu.org"
	DOMAIN_PATH=$(cat /etc/xray/domain)
	SUB=Free-`</dev/urandom tr -dc X-Z0-9 | head -c4`
	SUB_DOMAIN=${SUB}".tepllovpn.eu.org"
	NS_DOMAIN=ns.${SUB_DOMAIN}
	CF_ID=bangtepllo752@gmail.com
        CF_KEY=d8e5c652e1ddcc6fbfb20b1d7b6364de70c82
	set -euo pipefail
	IP=$(wget -qO- ipinfo.io/ip)
	echo "Actualizando DNS NS para ${NS_DOMAIN}..."
	ZONE=$(
		curl -sLX GET "https://api.cloudflare.com/client/v4/zones?name=${DOMAIN}&status=active" \
		-H "X-Auth-Email: ${CF_ID}" \
		-H "X-Auth-Key: ${CF_KEY}" \
		-H "Content-Type: application/json" | jq -r .result[0].id
	)

	RECORD=$(
		curl -sLX GET "https://api.cloudflare.com/client/v4/zones/${ZONE}/dns_records?name=${NS_DOMAIN}" \
		-H "X-Auth-Email: ${CF_ID}" \
		-H "X-Auth-Key: ${CF_KEY}" \
		-H "Content-Type: application/json" | jq -r .result[0].id
	)

	if [[ "${#RECORD}" -le 10 ]]; then
		RECORD=$(
			curl -sLX POST "https://api.cloudflare.com/client/v4/zones/${ZONE}/dns_records" \
			-H "X-Auth-Email: ${CF_ID}" \
			-H "X-Auth-Key: ${CF_KEY}" \
			-H "Content-Type: application/json" \
			--data '{"type":"NS","name":"'${NS_DOMAIN}'","content":"'${DOMAIN_PATH}'","proxied":false}' | jq -r .result.id
		)
	fi

	RESULT=$(
		curl -sLX PUT "https://api.cloudflare.com/client/v4/zones/${ZONE}/dns_records/${RECORD}" \
		-H "X-Auth-Email: ${CF_ID}" \
		-H "X-Auth-Key: ${CF_KEY}" \
		-H "Content-Type: application/json" \
		--data '{"type":"NS","name":"'${NS_DOMAIN}'","content":"'${DOMAIN_PATH}'","proxied":false}'
	)
	echo $NS_DOMAIN >/etc/xray/dns
}
setup_dnstt() {
clear
nameserver=$(cat /etc/xray/dns)
apt update -y
apt install -y python3 python3-dnslib net-tools
apt install ncurses-utils -y
apt install dnsutils -y
#apt install golang -y
apt install git -y
apt install curl -y
apt install wget -y
apt install ncurses-utils -y
apt install screen -y
apt install cron -y
apt install iptables -y
apt install -y git screen whois dropbear wget
#apt install -y pwgen python php jq curl
apt install -y sudo gnutls-bin
#apt install -y mlocate dh-make libaudit-dev build-essential
apt install -y dos2unix debconf-utils
service cron reload
service cron restart

#Configurar Slowdns
rm -rf /etc/slowdns
mkdir -m 777 /etc/slowdns
wget -q -O /etc/slowdns/server.key "https://raw.githubusercontent.com/JerrySBG/SBG2/main/slowdns/server.key"
wget -q -O /etc/slowdns/server.pub "https://raw.githubusercontent.com/JerrySBG/SBG2/main/slowdns/server.pub"
wget -q -O /etc/slowdns/dnstt-server "https://raw.githubusercontent.com/JerrySBG/SBG2/main/slowdns/dnstt-server"
wget -q -O /etc/slowdns/dnstt-client "https://raw.githubusercontent.com/JerrySBG/SBG2/main/slowdns/dnstt-client"
cd
chmod +x /etc/slowdns/server.key
chmod +x /etc/slowdns/server.pub
chmod +x /etc/slowdns/dnstt-server
chmod +x /etc/slowdns/dnstt-client

cd
#install client.service
cat > /etc/systemd/system/client.service << END
[Unit]
Description=Client SlowDNS By HideSSH
Documentation=https://hidessh.com
After=network.target nss-lookup.target

[Service]
Type=simple
User=root
CapabilityBoundingSet=CAP_NET_ADMIN CAP_NET_BIND_SERVICE
AmbientCapabilities=CAP_NET_ADMIN CAP_NET_BIND_SERVICE
NoNewPrivileges=true
ExecStart=/etc/slowdns/dnstt-client -udp 8.8.8.8:53 --pubkey-file /etc/slowdns/server.pub $nameserver 127.0.0.1:110
Restart=on-failure

[Install]
WantedBy=multi-user.target
END

cd
#install server.service
cat > /etc/systemd/system/server.service << END
[Unit]
Description=Server SlowDNS By HideSSH
Documentation=https://hidessh.com
After=network.target nss-lookup.target

[Service]
Type=simple
User=root
CapabilityBoundingSet=CAP_NET_ADMIN CAP_NET_BIND_SERVICE
AmbientCapabilities=CAP_NET_ADMIN CAP_NET_BIND_SERVICE
NoNewPrivileges=true
ExecStart=/etc/slowdns/dnstt-server -udp :5300 -privkey-file /etc/slowdns/server.key $nameserver 127.0.0.1:69
Restart=on-failure

[Install]
WantedBy=multi-user.target
END

#permission service slowdns
cd
chmod +x /etc/systemd/system/client.service
chmod +x /etc/systemd/system/server.service
pkill dnstt-server
pkill dnstt-client
#ACTIVAR
systemctl daemon-reload
systemctl stop client
systemctl stop server
systemctl enable client
systemctl enable server
systemctl start client
systemctl start server
systemctl restart client
systemctl restart server
clear
}
#install slowdns
sudo apt install squid -y
#configurando Key
echo "\e[1;32m Generando nueva clave"
cd /etc/slowdns
rm server.key server.pub
./dnstt-server -gen-key -privkey-file server.key -pubkey-file server.pub
echo -e "\e[1;32m FINALIZANDO..."
#setting IPtables
iptables -I INPUT -p udp --dport 5300 -j ACCEPT
iptables -t nat -I PREROUTING -p udp --dport 53 -j REDIRECT --to-ports 5300
netfilter-persistent save
netfilter-persistent reload
./startdns

ns_domain_cloudflare
setup_dnstt
clear
read -p "Presione [Enter] para Continuar"
rm -f /root/installsl.sh
rm -f /root/installsl2.sh
menu