# alpine-router

Alpine as a Router. Based on Alpine Linux, Alpine Router allows your machine to behave as a router connected to a DHCP available network.

## How to Use

    sudo sh ./initialize-router.sh

After seeing "Done!", reboot and run

    sudo tcpdump -i eth1 dst port 53 or src port 53

then visit some websites to see if there are any DNS queries getting through. dnscrypt-proxy is working if nothing is comming up here. To see DNSCrypt queries, change the port to 443.

## Notes

- The scripts are only intended to be run right after a clean install only once because right now I'm too lazy to make it more user friendly, so it simply overwrites/adds configs to bunch of config files without checking.
- The scripts expect two network interfaces, namely eth0 and eth1, and make eth0 as a LAN interface and eth1 as a WAN/outer-LAN interface.
