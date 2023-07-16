#!/bin/bash
set -e
apt-get update -y && apt-get upgrade -y
apt-get install screen -y
apt-get install lsof -y
wget -O /usr/bin/badvpn-udpgw https://raw.githubusercontent.com/daybreakersx/premscript/master/badvpn-udpgw64 
chmod +x /usr/bin/badvpn-udpgw
touch /etc/rc.local
echo "#! /bin/sh" >> /etc/rc.local
echo "set -e" >> /etc/rc.local
echo "screen -AmdS badvpn nohup badvpn-udpgw --listen-addr 127.0.0.1:37300 &" >> /etc/rc.local
echo "exit 0" >> /etc/rc.local
chmod +x /etc/rc.local