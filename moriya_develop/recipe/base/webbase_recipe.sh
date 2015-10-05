#!/bin/bash

lxcdir=/var/lib/lxc
rootfs=rootfs0

BASEIMAGE=base-v1-0
NAME=webbase-v1-0

[ -d ${lxcdir}/${NAME} ] || mkdir ${lxcdir}/${NAME}
rootdir=${lxcdir}/${NAME}/${rootfs}
[ -d ${rootdir} ] || mkdir ${rootdir}
rsync -Ha ${lxcdir}/${BASEIMAGE}/rootfs0/ ${rootdir}

cat <<EOF > ${rootdir}/etc/hostname
${NAME}
EOF

chroot ${rootdir} /usr/bin/apt-get update
chroot ${rootdir} /usr/bin/apt-get -y install apache2 iptables
chroot ${rootdir} /usr/bin/apt-get clean
