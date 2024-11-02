#!/bin/bash
user2=$(grep -wE "^#vm $user" "/etc/xray/config.json" | cut -d ' ' -f 2 | sort | uniq)
exp=$(grep -wE "^#vm $user" "/etc/xray/config.json" | cut -d ' ' -f 3 | sort | uniq)

if [ $user2 = $user ]; then
        cd
        sed -i "/^#vm $user $exp/,/^},{/d" /etc/xray/config.json
        sed -i "/^#vmg $user $exp/,/^},{/d" /etc/xray/config.json
        rm -rf /home/vps/public_html/vmess-$user.txt
        rm -rf /etc/vmess/${user}IP
        rm -rf /etc/vmess/${user}login
        rm -rf /etc/cron.d/trialvmess$user
        systemctl restart xray
fi