#!/bin/bash

apt-get install -y aptitude screen 
aptitude install python git gcc python-setuptools python-dev -y

easy_install pip 
pip install ansible 

ssh-keyscan  github.com >> ~/.ssh/known_hosts
git clone git@github.com:ccmp/lxc-ansible.git
cd lxc-ansible/
git checkout kttest00
cd kvm_demo/

