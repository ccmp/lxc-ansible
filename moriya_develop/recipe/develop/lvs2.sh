#!/bin/bash

lxcdir=/var/lib/lxc
rootfs=rootfs0

BASEIMAGE=lvsbase-v1-0
NAME=lvs2

LXCHOST=lvshost
SSHKEY=/root/.ssh/id_rsa
LXCHOSTDIR=/var/lib/lxc

[ -d ${lxcdir}/${NAME} ] || mkdir ${lxcdir}/${NAME}
rootdir=${lxcdir}/${NAME}/${rootfs}
[ -d ${rootdir} ] || mkdir ${rootdir}

rsync -Ha ${lxcdir}/${BASEIMAGE}/rootfs0/ ${rootdir}

cat <<EOF > ${rootdir}/etc/hostname
${NAME}
EOF

cat <<\EOF > ${rootdir}/etc/keepalived.conf
virtual_server_group VIP110 {   
        10.10.1.110 80
}

virtual_server group VIP110 {   
    delay_loop 6
    lvs_sched lc
    lvs_method DR
    protocol TCP

    real_server 192.168.10.50 80 {
        weight 1
        inhibit_on_failure
        HTTP_GET {
            url {
              path /index.html 
              status_code 200  
            }
            connect_timeout 3  
        }
    }

    real_server 192.168.10.51 80 {
        weight 1
        inhibit_on_failure
        HTTP_GET {
            url {
              path /index.html 
              status_code 200  
            }
            connect_timeout 3  
        }
    }
}
EOF

[ -d ${rootdir}/work ] || mkdir ${rootdir}/work
cat <<\EOF > ${rootdir}/work/lvs_setup.sh
#!/bin/bash

IPTABLES=/sbin/iptables
IP=/sbin/ip

VIP="10.10.1.110"

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
EOF

cat <<\EOF > ${rootdir}/etc/systemd/system/lvs-setup.service
[Unit]
Description=LVS network setup
After=network.target

[Service]
ExecStart=/work/lvs_setup.sh

[Install]
WantedBy=multi-user.target 
EOF

cat <<EOF > ./config
# Template used to create this container: /usr/share/lxc/templates/lxc-download
# Parameters passed to the template:
# For additional config options, please look at lxc.container.conf(5)

# Distribution configuration
lxc.include = /usr/share/lxc/config/debian.common.conf
lxc.arch = x86_64

# Container specific configuration
lxc.rootfs = /var/lib/lxc/lvs1_new/rootfs0
lxc.utsname = lvs1_new

# Network configuration
lxc.network.type = veth
lxc.network.flags = up
lxc.network.link = lxcbr1
lxc.network.ipv4 =10.10.1.11/24
#
lxc.network.type = veth
lxc.network.flags = up
lxc.network.link = lxcbr10
lxc.network.ipv4 =192.168.10.11/24
EOF

ssh root@${lvshost} "mkdir -p ${hostlxcdir}/${NAME}/rootfs0"
rsync -i ${SSHKEY} -Ha ${rootdir}/ root@${lvshost}:${hostlxcdir}/${NAME}/rootfs0/
rsync -i ${SSHKEY} -Ha config root@${lvshost}:${hostlxcdir}/${NAME}/


