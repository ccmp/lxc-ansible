#!/bin/bash

SCRIPT="./demo_sub.sh"
#SCRIPT="./test.sh"

apt-get install -y screen 

chmod +x $SCRIPT
screen  -dm bash -c "$SCRIPT ; exec bash"

