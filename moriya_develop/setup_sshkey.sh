#!/bin/bash

cd $HOME
[ -d .ssh ] || mkdir .ssh
chmod 700 .ssh
cat << EOF > .ssh/authorized_keys
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDA9F9BNisZjGT8mdA1OvmxHXCTVfIxuzqjZxpiJ1SFZlw561Cv7xc02Wvsy9N05HtwrHpIq97HCSYpr39mpW0aBcg0SqajnlhNmy7dVLlFf15qYjgRg9LrPKOEWktA9e3qSOnAqolIPH1DyBZWAabLFjroLSRSS/86HmX/APeZnpEmwi1PKgBz89NE7+FVpvFomewrd6vImw8/eXFaX0DJABesNmP39b3+TPOOFirWUdBL19UfgL7VKkTyIVIajp9HHXMp4VKNVwuDb+YHfkmgiTMJ90lpcnhHdIcvoQpDPISZBKEEiAWmkyaHSVTyxZRPVo4uGWvCwgRb947RSJ/7 root@manager
EOF
chmod 600 .ssh/authorized_keys
