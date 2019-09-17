#!/bin/sh

set -ex

apk add dnscrypt-proxy dnscrypt-proxy-openrc

cat <<EOF > /etc/resolv.conf
nameserver 127.0.0.2
options edns0 single-request-reopen
EOF

cp /usr/share/udhcpc/default.script /usr/share/udhcpc/default.script.bak
sed -i "s/\/etc\/resolv.conf/no/" /usr/share/udhcpc/default.script

cat <<EOF >> /etc/network/interfaces
auto lo:1
iface lo:1 inet static
    address 127.0.0.2
    netmask 255.0.0.0
EOF

sed -i "/#DNSCRYPT_OPTS=\"-config \/etc\/dnscrypt-proxy\/dnscrypt-proxy.toml\"/s/^#//g" /etc/conf.d/dnscrypt-proxy
cp /etc/dnscrypt-proxy/dnscrypt-proxy.toml /etc/dnscrypt-proxy/dnscrypt-proxy.toml.bak

cat <<EOF > /etc/dnscrypt-proxy/dnscrypt-proxy.toml
listen_addresses = ['127.0.0.2:53']
max_clients = 250

ipv4_servers = true
ipv6_servers = false
dnscrypt_servers = true
doh_servers = true

require_dnssec = false
require_nolog = true
require_nofilter = true
disabled_server_names = []
force_tcp = false

timeout = 2500
keepalive = 30
refused_code_in_responses = false
cert_refresh_delay = 240

fallback_resolver = '9.9.9.9:53'
ignore_system_dns = false
netprobe_timeout = 60
netprobe_address = "9.9.9.9:53"

log_files_max_size = 10
log_files_max_age = 7
log_files_max_backups = 1

cache = true
cache_size = 512
cache_min_ttl = 600
cache_max_ttl = 86400
cache_neg_min_ttl = 60
cache_neg_max_ttl = 600

[sources]
  [sources.'public-resolvers']
  urls = ['https://raw.githubusercontent.com/DNSCrypt/dnscrypt-resolvers/master/v2/public-resolvers.md', 'https://download.dnscrypt.info/resolvers-list/v2/public-resolvers.md']
  cache_file = '/var/cache/dnscrypt-proxy/public-resolvers.md'
  minisign_key = 'RWQf6LRCGA9i53mlYecO4IzT51TGPpvWucNSCh1CBM0QTaLn73Y7GFO3'
  refresh_delay = 72
  prefix = ''
  
  [sources.quad9-resolvers]
  urls = ["https://www.quad9.net/quad9-resolvers.md"]
  minisign_key = "RWQBphd2+f6eiAqBsvDZEBXBGHQBJfeG6G+wJPPKxCZMoEQYpmoysKUN"
  cache_file = "/var/cache/dnscrypt-proxy/quad9-resolvers.md"
  refresh_delay = 72
  prefix = "quad9-"
EOF

rc-service networking restart
rc-service dnscrypt-proxy restart
rc-update add dnscrypt-proxy default
