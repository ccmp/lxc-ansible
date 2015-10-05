#!/bin/bash

# setup VLAN1
ip link add link eth1 name eth1.1 type vlan id 1
ip link set eth1.1 up
ip addr add 10.10.1.1/24 dev eth1.1

