#!/bin/bash

lxcdir=/var/lib/lxc
rootfs=rootfs0

BASEIMAGE=webbase-v1-0
NAME=web1

LXCHOST=webhost1
SSHKEY=/root/.ssh/id_rsa
LXCHOSTDIR=/var/lib/lxc

[ -d ${lxcdir}/${NAME} ] || mkdir ${lxcdir}/${NAME}
rootdir=${lxcdir}/${NAME}/${rootfs}
[ -d ${rootdir} ] || mkdir ${rootdir}

rsync -Ha ${lxcdir}/${BASEIMAGE}/rootfs0/ ${rootdir}

cat <<EOF > ${rootdir}/etc/hostname
${NAME}
EOF

[ -d ${rootdir}/work ] || mkdir ${rootdir}/work
cat <<\EOF > ${rootdir}/work/web_setup.sh
#!/bin/bash

IPTABLES=/sbin/iptables
IP=/sbin/ip
ARP=/usr/sbin/arp

LVS="192.168.10.11"
GW="10.10.1.1"
GWMAC="08:00:27:d7:0f:2f"

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

EOF

cat <<\EOF > ${rootdir}/etc/systemd/system/web-setup.service
[Unit]
Description=Webserver network setup
After=network.target

[Service]
ExecStart=/work/web_setup.sh

[Install]
WantedBy=multi-user.target 
EOF

cat <<\EOF > ./config
# Template used to create this container: /usr/share/lxc/templates/lxc-download
# Parameters passed to the template:
# For additional config options, please look at lxc.container.conf(5)

# Distribution configuration
lxc.include = /usr/share/lxc/config/debian.common.conf
lxc.include = /usr/share/lxc/config/debian.userns.conf
lxc.arch = x86_64

# Container specific configuration
lxc.rootfs = /lxc/web10a/rootfs
lxc.utsname = web10a

# Network configuration
lxc.network.type = veth
lxc.network.link = lxcbr10
lxc.network.flags = up
#lxc.network.hwaddr = 00:16:3e:xx:xx:xx
lxc.network.ipv4 = 192.168.10.50/24
#
lxc.network.type = veth
lxc.network.link = lxcbr1
lxc.network.flags = up
#lxc.network.hwaddr = 00:16:3e:xx:xx:xx
#lxc.network.ipv4 = 192.168.10.50/24
#
lxc.mount.entry = /home/user10/.local/share/lxc/web10a/work work none bind,optional 0 0
EOF


