#!/bin/bash

GITHUB_CMD="https://raw.githubusercontent.com/JerrySBG/scvps/main/"

apt install python3 -y

systemctl stop ws
systemctl disable ws
rm -f /etc/systemd/system/ws.service
systemctl daemon-reload

wget -q -O /usr/bin/ws.py "${GITHUB_CMD}ws.py"
chmod +x ws.py

cat > /etc/systemd/system/ws.service <<-FDLY
[Unit]
Description=WebSocket
Documentation=https://github.com/JerrySBG
After=syslog.target network-online.target
[Service]
User=root
NoNewPrivileges=true
ExecStart=python3 /usr/bin/ws.py
Restart=on-failure
RestartPreventExitStatus=23
LimitNPROC=10000
LimitNOFILE=1000000
[Install]
WantedBy=multi-user.target

FDLY

systemctl enable ws
systemctl start ws
systemctl restart ws
