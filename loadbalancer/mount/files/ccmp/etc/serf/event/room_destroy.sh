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
    if [ "x${ROLE}" != "xroom" ];then
	continue
    fi

    if ! ${IPVSADM} -Ln | grep "${VIP}:${PORT}";then
	echo "Service: ${VIP}:${PORT} does not exist."
	continue
    fi

    if ${IPVSADM} -Ln -t ${VIP}:${PORT} | grep "${ADDRESS}:${PORT}" ;then
	${IPVSADM} -d -t ${VIP}:${PORT} -r ${ADDRESS}:${PORT}
    else
	echo "Real: ${ADDRESS}:${PORT} is not add to ${VIP}:${PORT} service"
	continue
    fi
	
    ALIVE_COUNT=$(${IPVSADM} -Ln -t ${VIP}:${PORT} | awk 'BEGIN{c=0}NR>3 && '"${SORRY+\$2 !~ /${SORRY}/ &&}"' $4 == 1{c++}END{print c}')
    if [ ${ALIVE_COUNT} -eq 0 ] ;then
	${IPVSADM} -D -t ${VIP}:${PORT}
    fi
done



    
