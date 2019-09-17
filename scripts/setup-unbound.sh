#!/bin/sh

set -ex

apk add unbound

cp /etc/unbound/unbound.conf /etc/unbound/unbound.bak

unbound-anchor -a "/etc/unbound/root.key" || :
chown unbound:unbound /etc/unbound

cat <<EOF > /etc/unbound/unbound.conf
server:
    verbosity: 1
    
    do-udp: yes
    do-tcp: yes
    
    hide-identity: yes
    hide-version: yes
    hide-trustanchor: yes
    
    harden-short-bufsize: yes
    harden-large-queries: yes
    harden-glue: yes
    harden-dnssec-stripped: yes
    harden-below-nxdomain: yes
    harden-algo-downgrade: yes
    
    use-caps-for-id: yes
    
    private-domain: "<HOSTNAME>"
    do-not-query-localhost: no
    
    auto-trust-anchor-file: "/etc/unbound/root.key"
    unblock-lan-zones: no
   
    # IPv4
    do-ip4: yes
    interface: 192.168.0.1
    access-control: 192.168.0.0/24 allow
    
    # IPv6
    do-ip6: no
python:
remote-control:
forward-zone:
    name: "."
    forward-addr: 127.0.0.2@53
    #forward-addr: 1.1.1.1
    #forward-addr: 1.0.0.1
EOF

rc-service unbound restart
rc-update add unbound default
