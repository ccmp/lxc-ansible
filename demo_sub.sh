#!/bin/bash

apt-get install python git gcc python-setuptools python-dev -y

easy_install pip 
pip install ansible 

cat /dev/null >  ~/.ssh/known_hosts
ssh-keyscan  github.com >> ~/.ssh/known_hosts

git clone git@github.com:ccmp/lxc-ansible.git
cd lxc-ansible/
git checkout kttest00
cd kvm_demo/

for hst in mng01 gw1 lvs01 lvs02 web01 web02 ; do
ssh-keyscan  $hst >> ~/.ssh/known_hosts
done

time ansible-playbook -i inventory/development physical/site.yml
time ansible-playbook -i inventory/development image/site.yml
time ansible-playbook -i inventory/development service1/site_config.yml
time ansible-playbook -i inventory/development service1/site.yml

