#!/bin/bash

IPTABLES=/sbin/iptables
IP=/sbin/ip

VIP={{ lvscommon.vip }}

# Input
${IPTABLES} -t mangle -A PREROUTING -d ${VIP} -j MARK --set-mark 1
${IPTABLES} -t mangle -A POSTROUTING -d ${VIP} -j TOS --set-tos 2 
# Forward
${IPTABLES} -A FORWARD -p tcp --sport 80 -s ${VIP} -j NFLOG --nflog-prefix "Bad return packet"

#Routing
${IP} rule add table 100 fwmark 1 prio 100
${IP} route add local 0/0 dev lo table 100

#Forward
echo 1 > /proc/sys/net/ipv4/ip_forward
