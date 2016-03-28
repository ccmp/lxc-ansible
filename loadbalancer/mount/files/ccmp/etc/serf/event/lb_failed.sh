#!/bin/bash

#NETWORK_VIP=10.20.4.10
#NETWORK_MASK=16
#NETWORK_IFACE=eth0

ARPING=/usr/bin/arping
SERF=/usr/ccmp/bin/serf

if [ "x${SERF_TAG_ROLE}" != "xlb" ]; then
    echo "Not an loadbalancer. Nothing to do in this script."
    exit 0
fi

if [ "x${SERF_TAG_STATE}" != "xup" ];then
    exit 0
fi

if [ "x${SERF_TAG_MASTER}" != "xslave" ];then
    exit 0
fi


VR_VIP=${SERF_TAG_VRVIP}
VR_SUB=${SERF_TAG_VRSUB}
VR_IFACE=${SERF_TAG_VRIFACE}

while read line;do
    HOSTNAME=$(echo $line | awk '{print $1}')
    ADDRESS=$(echo $line | awk '{print $2}')
    ROLE=$(echo $line | awk '{print $3}')
    MASTER=$(echo $line | awk '{print $4}' | sed 's/.*master=\([^, ]*\) *,*.*$/\1/')

    if [ "x${ROLE}" != "xlb" ];then
	continue
    fi

    if [ "x${MASTER}" != "xmaster" ];then
	continue
    fi

    ip addr add ${VR_VIP}/${VR_SUB} dev ${VR_IFACE}
    ${ARPING} -A ${VR_VIP} -c 1
    ${SERF} tags -set master=master
done

    
    
