#!/bin/bash

IPVSADM=ipvsadm
#VIP=10.254.10.1
#SORRY=10.20.0.50

if [ "x${SERF_TAG_ROLE}" != "xlb" ]; then
    echo "Not an loadbalancer. Nothing to do"
    exit 0
fi

if [ "x${SERF_TAG_STATE}" != "xup" ];then
    exit 0
fi

VIP=${SERF_TAG_IPVSVIP}
SORRY=${SERF_TAG_IPVSSORRY}

while read line; do
    HOSTNAME=$(echo $line | awk '{print $1}')
    ADDRESS=$(echo $line | awk '{print $2}')
    ROLE=$(echo $line | awk '{print $3}')
    PORT=$(echo $line | awk '{print $4}' | sed 's/.*port=\([0-9][0-9]*\) *,*.*$/\1/' )
    STATE=$(echo $line | awk '{print $4}' | sed 's/.*state=\([^, ]*\) *,*.*$/\1/')
    if [ "x${ROLE}" != "xroom" ];then
	continue
    fi
    
    if [ "x${STATE}" != "xup" ];then
	continue
    fi

    echo $line
    
    if ! ${IPVSADM} -Ln | grep "${VIP}:${PORT}";then
	${IPVSADM} -A -t ${VIP}:${PORT} -s lc
	${IPVSADM} -a -t ${VIP}:${PORT} -r ${ADDRESS}:${PORT} -g
    elif ${IPVSADM} -Ln -t ${VIP}:${PORT} | grep "${ADDRESS}:${PORT}" ;then
	${IPVSADM} -e -t ${VIP}:${PORT} -r ${ADDRESS}:${PORT} -w 1
    else
	${IPVSADM} -a -t ${VIP}:${PORT} -r ${ADDRESS}:${PORT} -g
    fi

    if [ "x${SORRY}" != "x" ];then
	if ${IPVSADM} -Ln -t ${VIP}:${PORT} | grep "${SORRY}:${PORT}" ;then
	    ${IPVSADM} -d -t ${VIP}:${PORT} -r ${SORRY}:${PORT} 
	fi
    fi
done



    
