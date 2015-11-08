#!/bin/bash

SCRIPT="./demo_sub.sh"
#SCRIPT="./test.sh"

apt-get install -y screen 

cat<<EOF>$SCRIPT
#!/bin/bash

START=$(date)

apt-get install python git gcc python-setuptools python-dev -y

easy_install pip 
pip install ansible 

cat /dev/null >  ~/.ssh/known_hosts
ssh-keyscan  github.com >> ~/.ssh/known_hosts

cd ~/
if [ ! -d lxc-ansible ]; then
	git clone git@github.com:ccmp/lxc-ansible.git
fi

cd lxc-ansible/
git checkout develop
git pull
cd kvm_demo/

for hst in mng01 gw1 lvs01 lvs02 web01 web02 ; do
	ssh-keyscan  $hst >> ~/.ssh/known_hosts
	ssh $hst apt-get install -y python > /dev/null &
done

wait

echo "Physical Playbook"
time ansible-playbook -i inventory/development physical/site.yml
echo
echo "Image Playbook"
time ansible-playbook -i inventory/development image/site.yml
echo
echo "Config Playbook"
time ansible-playbook -i inventory/development service1/site_config.yml
echo
echo "Deploy Playbook"
time ansible-playbook -i inventory/development service1/site.yml

echo START=$START
echo END=$(date)
EOF

chmod +x $SCRIPT
screen  -dm bash -c "$SCRIPT ; exec bash"

date 
