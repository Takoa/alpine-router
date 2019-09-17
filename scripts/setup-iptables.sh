#!/bin/sh

set -ex

apk add iptables ip6tables

### Filter Table ###
iptables -t filter -A INPUT -i lo -j ACCEPT
iptables -t filter -A INPUT -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT

# REJECT bad packets
iptables -t filter -A INPUT -m conntrack --ctstate INVALID -j REJECT
iptables -t filter -A INPUT -p tcp --tcp-flags ALL FIN,PSH,URG -j REJECT
iptables -t filter -A INPUT -p tcp --tcp-flags SYN,FIN SYN,FIN -j REJECT
iptables -t filter -A INPUT -p tcp -m conntrack --ctstate NEW ! --tcp-flags FIN,SYN,RST,ACK SYN -j REJECT

# ACCEPT SSH
iptables -t filter -A INPUT -s 192.168.0.0/24 -p tcp --dport 22 -j ACCEPT

# ACCEPT ping request
iptables -t filter -A INPUT -s 192.168.0.0/24 -p icmp --icmp-type echo-request -m conntrack --ctstate NEW,ESTABLISHED,RELATED -j ACCEPT

# ACCEPT DNS queries
iptables -t filter -A INPUT -s 192.168.0.0/24 -p udp --dport 53 -m conntrack --ctstate NEW -j ACCEPT

# ACCEPT NTP
iptables -t filter -A INPUT -s 192.168.0.0/24 -p udp --dport 123 -m conntrack --ctstate NEW,ESTABLISHED -j ACCEPT

iptables -t filter -A INPUT -j REJECT
iptables -t filter -P INPUT DROP

### NAT Table ###
iptables -t nat -A POSTROUTING -s 192.168.0.0/24 -o eth1 -j MASQUERADE

iptables-save > /etc/network/iptables.rules
sed -i "/iface eth0.*/a \    pre-up iptables-restore < /etc/network/iptables.rules" /etc/network/interfaces
