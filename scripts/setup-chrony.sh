#!/bin/sh

set -ex

apk add chrony

cat <<EOF > /etc/chrony/chrony.conf
logdir /var/log/chrony
#log measurements statistics tracking

server 0.jp.pool.ntp.org iburst
server 1.jp.pool.ntp.org iburst
server 2.jp.pool.ntp.org iburst
server 3.jp.pool.ntp.org iburst

allow 192.168.0.0/24

broadcast 60 192.168.0.255

initstepslew 10 0.jp.pool.ntp.org

driftfile /var/lib/chrony/chrony.drift
rtcdevice /dev/rtc0
rtcsync
EOF

rc-service chronyd restart
