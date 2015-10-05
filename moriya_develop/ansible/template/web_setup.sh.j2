#!/bin/bash

IPTABLES=/sbin/iptables
IP=/sbin/ip
ARP=/usr/sbin/arp

LVS={{ LVS_SERVER_IP }}
GW={{ GATEWAY_SERVER_IP }}
GWMAC={{ GATEWAY_MACADDR }}

# Input
${IPTABLES} -t nat -A PREROUTING -m tos --tos 2 -j CONNMARK --set-mark 1
${IPTABLES} -t nat -A PREROUTING -m tos --tos 2 -j REDIRECT

#Output
${IPTABLES} -t mangle -A OUTPUT -m connmark --mark 1 -j MARK --set-mark 1

#Routing
${IP} route add default via ${LVS} dev eth0
${IP} route add ${GW} dev eth1
${IP} route add ${GW} dev eth1 table 100
${IP} route add default via ${GW} dev eth1 table 100
${IP} rule add table 100 fwmark 1 prio 100

#Static ARP

${ARP} -s -i eth1 ${GW} ${GWMAC}
