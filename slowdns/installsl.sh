#!/bin/sh
colornow=$(cat /etc/rmbl/theme/color.conf)
export NC="\e[0m"
export COLOR1="$(cat /etc/rmbl/theme/$colornow | grep -w "TEXT" | cut -d: -f2|sed 's/ //g')"
export COLBG1="$(cat /etc/rmbl/theme/$colornow | grep -w "BG" | cut -d: -f2|sed 's/ //g')"
WH='\033[1;37m'
REPO="https://raw.githubusercontent.com/JerrySBG/SBG2/main/"
cd
clear
slowsbg() {
clear  
echo -e "$COLOR1╭═══════════════════════════════════════════╮${NC}"
echo -e "$COLOR1│$NC         \e[1;32mConfigurar Dominio SlowDNS        $COLOR1│${NC}"  
echo -e "$COLOR1╰═══════════════════════════════════════════╯${NC}"
echo -e "$COLOR1╭═══════════════════════════════════════════╮${NC}" 
echo -e "$COLOR1│  [ 1 ]  \e[1;32mPropio Dominio SlowDNS                ${NC}"  
echo -e "$COLOR1│  [ 2 ]  \e[1;32mDominio Aletorio Free                 ${NC}" 
#echo -e "$COLOR1│  [ 3 ]  \e[1;32mDominio Aletorio By JERRY-SBG             ${NC}"                                
echo -e "$COLOR1╰═══════════════════════════════════════════╯${NC}"
until [[ $slow =~ ^[1-2]+$ ]]; do 
read -p "   Por Favor Selecciona del 1 al 2 : " slow
done

if [[ $slow == "1" ]]; then
#install slowdns
sudo apt install squid -y
#setting IPtables
iptables -I INPUT -p udp --dport 5300 -j ACCEPT
iptables -t nat -I PREROUTING -p udp --dport 53 -j REDIRECT --to-ports 5300
netfilter-persistent save
netfilter-persistent reload

#delete directory
rm -rf /etc/xray/dns
rm dns

#input nameserver manual to cloudflare
clear
echo -e "$COLOR1╭═══════════════════════════════════════════╮${NC}"
echo -e "$COLOR1│$NC               \e[1;32mDOMINIO SLOWDNS             $COLOR1│${NC}"  
echo -e "$COLOR1╰═══════════════════════════════════════════╯${NC}"
echo -e "$COLOR1╭═══════════════════════════════════════════╮${NC}"
echo -e "$COLOR1│$NC  \e[1;32mDebes de tener Ya Configurado tu Dominio $COLOR1│${NC}"  
echo -e "$COLOR1╰═══════════════════════════════════════════╯${NC}"
read -rp "Introduce Tu Dominio NS : " -e sub
SUB_DOMAIN=${sub}
NS_DOMAIN=${SUB_DOMAIN}
echo $NS_DOMAIN > /etc/xray/dns

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

#konfigurasi slowdns
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

clear
echo "\e[1;32m Generando nueva clave"
cd /etc/slowdns
rm server.key server.pub
./dnstt-server -gen-key -privkey-file server.key -pubkey-file server.pub
echo -e " \e[1;32mFINALIZANDO..."
./startdns

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
fi
if [[ $slow == "2" ]]; then
#install slowdns
wget ${REPO}slowdns/installsl2.sh && chmod +x installsl2.sh && bash ./installsl2.sh
rm -f /root/installsl2.sh
clear
fi
if [[ $slow == "3" ]]; then
#install slowdns
wget ${REPO}slowdns/slowdns.sh && chmod +x slowdns.sh && bash ./slowdns.sh
rm -f /root/slowdns.sh
clear
fi
}
slowsbg
exit
