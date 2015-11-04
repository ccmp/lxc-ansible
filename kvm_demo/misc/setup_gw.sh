#!/bin/bash

# setup VLAN1
ip link add link eth0 name eth0.1 type vlan id 1
ip link set eth0.1 up
ip addr add 10.10.1.1/24 dev eth0.1
# setup routing
ip route add 10.10.1.110 via 10.10.1.10 dev eth0.1
ip route add 10.10.1.120 via 10.10.1.20 dev eth0.1
# ip forward
echo 1 > /proc/sys/net/ipv4/ip_forward

# Plz set routing at cliant as below.
# ip add route 10.10.1.0/24 via <GATEWAY ADDRESS>

