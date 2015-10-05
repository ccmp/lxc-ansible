#!/bin/bash

# setup VLAN1
brctl addbr lxcbr1
ip link add link eth1 name eth1.1 type vlan id 1
brctl addif lxcbr1 eth1.1
ip link set lxcbr1 up
ip link set eth1.1 up

# setup VLAN10
brctl addbr lxcbr10
ip link add link eth1 name eth1.10 type vlan id 10
brctl addif lxcbr10 eth1.10
ip link set lxcbr10 up
ip link set eth1.10 up


