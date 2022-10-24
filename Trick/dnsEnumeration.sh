#!/bin/bash
# DNS enumeration commands collected from:
# https://book.hacktricks.xyz/network-services-pentesting/pentesting-dns

if [ $# -lt 2 ]; then
    echo '[-] ERROR: No IP address or DNS name given.'
    echo '[*] You must enter command as "./dnsEnumeration.sh TARGETBOX_IP TARGETBOX_DNS".'
    exit 1
fi

ip=$1
dns=$2

log () {
	printf '=%.0s' {1..80}
	echo -e "\n$1"
	printf '=%.0s' {1..80} && echo -e "\n"
}

log "[+] Grabbing DNS 'banner'"
dig version.bind CHAOS TXT @$ip

log "[+] Grabbing DNS 'banner' with Nmap"
nmap -sV -p 53 --script dns-nsid -v $ip

log "[+] ANY record: return all available entries"
dig any $dns @$ip

log "[+] Asynchronous Full Zone Transfer, without domain"
dig axfr @$ip

log "[+] Asynchronous Full Zone Transfer, with domain"
dig axfr @$ip $dns

log "[+] Zone transfer against every authoritative name server"
fierce --domain $dns --dns-servers $ip

log "[+] Any information"
dig ANY @$ip $dns

log "[+] Regular (IPv4) DNS request"
dig A @$ip $dns

log "[+] IPv6 DNS request"
dig AAAA @$ip $dns

log "[+] More information"
dig TXT @$ip $dns

log "[+] Email-related information"
dig MX @$ip $dns

log "[+] DNS nameserver resolution"
dig NS @$ip $dns

log "[+] Network router reverse lookup"
dig -x 192.168.0.2 @$ip

log "[+] IPv6 reverse lookup"
dig -x 2a00:1450:400c:c06::93 @$ip

log "[+] Using nslookup"
nslookup << EOF
SERVER $dns
127.0.0.1
$ip
EOF

log "[+] Enumeration with more Nmap scripts"
nmap -n -v -p 53 --script "(default and *dns*) or fcrdns or dns-srv-enum or dns-random-txid or dns-random-srcport" $ip

log "[+] Brute-force reverse DNS for 127.0.0.0/24"
dnsrecon -r 127.0.0.0/24 -n $ip -d $dns

log "[+] Brute-force reverse DNS for 127.0.1.0/24"
dnsrecon -r 127.0.1.0/24 -n $ip -d $dns

ip_cidr=$(echo $ip | cut -d . -f 1-3).0/24
log "[+] Brute-force reverse DNS for $ip_cidr"
dnsrecon -r $ip_cidr -n $ip -d $dns

log "[+] Zone transfer"
dnsrecon -d $dns -a -n $ip

log "[*] DNS subdomains brute-forcing skipped! Use ffuf or other recommended tools"
sleep 5

log "[+] Active Directory: Global Catalog server query"
dig -t _gc._tcp.lab.$dns

log "[+] Active Directory: LDAP server query"
dig -t _ldap._tcp.lab.$dns

log "[+] Active Directory: Kerberos server query"
dig -t _kerberos._tcp.lab.$dns

log "[+] Active Directory: Kpasswd server query"
dig -t _kpasswd._tcp.lab.$dns

log "[+] DNS server enumeration with Nmap scripts"
nmap -sV -p 53 -v --script dns-srv-enum --script-args "dns-srv-enum.domain=$dns" $ip

log "[+] DNSSec: querying Paypal subdomains"
sudo nmap -sSU -v -p 53 --script dns-nsec-enum --script-args dns-nsec-enum.domains=paypal.com ns3.isc-sns.info $ip

log "[+] Brute-force using 'AAAA' requests to get IPv6 subdomains"
dnsdict6 -s -t $dns

log "[+] Brute-force reverse DNS using IPv6 addresses"
dnsrevenum6 $dns 2001:67c:2e8::/48
