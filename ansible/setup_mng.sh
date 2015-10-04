#!/bin/bash

aptitude install python git gcc python-setuptools python-dev -y
easy_install pip 
pip install ansible 

ssh-keyscan  github.com >> ~/.ssh/known_hosts
git clone git@github.com:ccmp/lxc-ansible.git
git checkout develop

cat <<EOF> /etc/hosts
127.0.0.1       localhost mng01
::1             localhost ip6-localhost ip6-loopback
fe00::0         ip6-localnet
ff00::0         ip6-mcastprefix
ff02::1         ip6-allnodes
ff02::2         ip6-allrouters
EOF

ssh-keyscan  mng01 >> ~/.ssh/known_hosts


