#!/bin/bash

# for lxc 
apt-get -y install git g++ make automake autoconf python python-dev python3 python3-dev python-pip libcap2 libcap-dev pkg-config debootstrap
#
mkdir -p /work/git
cd /work/git
git clone git://github.com/lxc/lxc -b stable-1.0
cd lxc
./autogen.sh
./configure
make
make install
echo "/usr/local/lib/python3/dist-packages" > /usr/lib/python3/dist-packages/custom.pth
ldconfig
mkdir /etc/lxc
cp /vagrant/manager/default.conf /etc/lxc/
#
pip install ansible
pip install lxc-python2
mkdir /etc/ansible
cp /vagrant/manager/hosts_ansible /etc/lxc/hosts
echo lvs1dep 192.168.0.11 >> /etc/hosts
echo lvs2dep 192.168.0.12 >> /etc/hosts
echo web1dep 192.168.0.50 >> /etc/hosts
echo web2dep 192.168.0.51 >> /etc/hosts


#
apt-get install dnsmasq brigde-utils
cp /vagrant/manager/lxc-net.service /etc/systemd/system/
cp /vagrant/manager/lxc-net /usr/local/lib/lxc/
cp /vagrant/manager/dnsmasq_lxc /etc/dnsmasq.d/lxc
systemctl stop dnsmasq
syatemctl disable dnsmasq
systemctl enable lxc-net
systemctl start lxc-net
#


