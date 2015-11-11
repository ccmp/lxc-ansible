#!/bin/bash

IPTABLES=/sbin/iptables
IP=/sbin/ip
ARP=/usr/sbin/arp

LVS=192.168.10.10
GW=10.10.10.254
GWMAC=52:54:00:11:00:02

# Input
#${IPTABLES} -t nat -A PREROUTING -m tos --tos 2 -j CONNMARK --set-mark 1
${IPTABLES} -t nat -A PREROUTING -m tos --tos 2 -j REDIRECT

#Output
#${IPTABLES} -t mangle -A OUTPUT -m connmark --mark 1 -j MARK --set-mark 1

#Routing
${IP} route add default via ${LVS} dev eth0
#${IP} route add ${GW} dev eth1
#${IP} route add ${GW} dev eth1 table 100
#${IP} route add default via ${GW} dev eth1 table 100
#${IP} rule add table 100 fwmark 1 prio 100

#Static ARP

#${ARP} -s -i eth1 ${GW} ${GWMAC}
