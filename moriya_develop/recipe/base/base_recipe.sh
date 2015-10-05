#!/bin/bash

arch=amd64
packages=netbase,net-tools,iproute
release=jessie

lxcdir=/var/lib/lxc
rootfs=rootfs0

MIRROR=http://http.debian.net/debian

NAME=base-v1-0
PASSWORD=password

if [ -d ${lxcdir}/${NAME} ]
then
    echo "${NAME} already existed"
    return 1
else
    mkdir -p ${lxcdir}/${NAME}
fi

rootdir=${lxcdir}/${NAME}/${rootfs}
[ -d ${rootdir} ] || mkdir ${rootdir}

debootstrap --verbose --variant=minbase --arch=$arch --include=$packages "$release" "$rootdir" $MIRROR

cat <<EOF > ${rootdir}/etc/hostname
${NAME}
EOF

sed 's/^ConditionPathExists=/# ConditionPathExists=/' ${rootdir}/lib/systemd/system/getty\@.service > ${rootdir}/etc/systemd/system/getty\@.service
( cd ${rootdir}/etc/systemd/system/getty.target.wants
   ln -sf ../getty\@.service getty@tty1.service
)

chroot ${rootdir} ln -s /dev/null /etc/systemd/system/systemd-udevd.service

chroot ${rootdir} ln -s /lib/systemd/system/halt.target /etc/systemd/system/sigpwr.target
chroot ${rootdir} ln -s /lib/systemd/system/multi-user.target /etc/systemd/system/default.target
  
echo "root:${PASSWORD}" | chroot ${rootdir} chpasswd

