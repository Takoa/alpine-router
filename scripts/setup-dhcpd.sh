#!/bin/sh

set -ex

apk add dhcp

sed "s/.*DHCPD_IFACE.*/DHCPD_IFACE=\"eth0\"/" /etc/conf.d/dhcpd

cat <<EOF > /etc/dhcp/dhcpd.conf
option domain-name-servers 192.168.0.1;
option subnet-mask 255.255.255.0;
option routers 192.168.0.1;

subnet 192.168.0.0 netmask 255.255.255.0 {
  range 192.168.0.200 192.168.0.250;
}
EOF

rc-service dhcpd restart
rc-update add dhcpd default
