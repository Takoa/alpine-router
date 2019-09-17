#!/bin/sh

set -ex

echo "Initializing as a router..."

echo "net.ipv4.ip_forward = 1" >> /etc/sysctl.conf

cat <<EOF > /etc/network/interfaces
auto eth0
iface eth0 inet static
    address 192.168.0.1
    netmask 255.255.255.0
    broadcast 192.168.0.255

allow-hotplug eth1
auto eth1
iface eth1 inet dhcp
    pre-up /sbin/ip link set eth1 up
    post-down /sbin/ip link set eth1 down

auto lo
iface lo inet loopback
        address 127.0.0.1
        netmask 255.0.0.0
EOF

rc-service networking restart

while !(sudo rc-status -a | grep chrony | grep -q started)\
      || !(sudo rc-status -a | grep networking | grep -q started); do
    sleep 2;
done

sed -i "/http:\/\/.*\/alpine\/v.*\/community/s/^#//g" /etc/apk/repositories

apk update

./setup-iptables.sh
./setup-dhcpd.sh
./setup-chrony.sh
./setup-unbound.sh
./setup-dnscrypt-proxy.sh

while !(sudo rc-status -a | grep chrony | grep -q started)\
      || !(sudo rc-status -a | grep networking | grep -q started); do
    sleep 2;
done

rc-service sysctl restart

echo "Done!"
