#!/bin/bash

aptitude install python git gcc python-setuptools python-dev -y
easy_install pip 
pip install ansible 

ssh-keyscan  github.com >> ~/.ssh/known_hosts
git clone git@github.com:ccmp/lxc-ansible.git
cd lxc-ansible/ansible/
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

cat  <<\EOF>>~/.bashrc

agent="$HOME/tmp/ssh-agent-$USER"
if [ -S "$SSH_AUTH_SOCK" ]; then
	case $SSH_AUTH_SOCK in
	/tmp/*/agent.[0-9]*)
		ln -snf "$SSH_AUTH_SOCK" $agent && export SSH_AUTH_SOCK=$agent
	esac
elif [ -S $agent ]; then
	export SSH_AUTH_SOCK=$agent
else
	echo "no ssh-agent"
fi
EOF

