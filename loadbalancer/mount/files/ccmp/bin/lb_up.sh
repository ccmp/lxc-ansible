#!/bin/bash

#VR_VIP=10.20.4.10
#VR_MASK=16
#VR_IFACE=eth0

SERF=/usr/ccmp/bin/serf
ARPING=/usr/bin/arping
IPVSADM=ipvsadm

JQ="/usr/bin/jq -r"

if ! SERF_JSON=$(${SERF} info -format json) ;then
    echo 'Serf seem not to be executed'
    exit 1
fi

MY_ROLE=$(echo ${SERF_JSON} | ${JQ} '.tags.role')
if [ "x${MY_ROLE}" != "xlb" ];then
    echo "Not an loadbalancer."
    exit 1
fi

MY_HOSTNAME=$(echo ${SERF_JSON} | ${JQ} '.agent.name')
VR_VIP=$(echo ${SERF_JSON} | ${JQ} '.tags.vrvip')
VR_SUB=$(echo ${SERF_JSON} | ${JQ} '.tags.vrsub')
VR_IFACE=$(echo ${SERF_JSON} | ${JQ} '.tags.vriface')
IPVS_VIP=$(echo ${SERF_JSON} | ${JQ} '.tags.ipvsvip')
SORRY=$(echo ${SERF_JSON} | ${JQ} '.tags.ipvssorry // empty')
MY_MASTER=$(echo ${SERF_JSON} | ${JQ} '.tags.master')
STATE=$(echo ${SERF_JSON} | ${JQ} '.tags.state')

while read line ;do
    HOSTNAME=$(echo $line | ${JQ} '.name' )
    ADDRESS=$(echo $line | ${JQ} '.addr' | cut -d ":" -f 1 )
    PORT=$(echo $line | ${JQ} '.tags.port')

    if ! ${IPVSADM} -Ln | grep "${IPVS_VIP}:${PORT}";then
	${IPVSADM} -A -t ${IPVS_VIP}:${PORT} -s lc
	${IPVSADM} -a -t ${IPVS_VIP}:${PORT} -r ${ADDRESS}:${PORT} -g
    elif ${IPVSADM} -Ln -t ${IPVS_VIP}:${PORT} | grep "${ADDRESS}:${PORT}" ;then
	${IPVSADM} -e -t ${IPVS_VIP}:${PORT} -r ${ADDRESS}:${PORT} -w 1
    else
	${IPVSADM} -a -t ${IPVS_VIP}:${PORT} -r ${ADDRESS}:${PORT} -g
    fi

    if [ "x${SORRY}" != "x" ];then
	if ${IPVSADM} -Ln -t ${IPVS_VIP}:${PORT} | grep "${SORRY}:${PORT}" ;then
	    ${IPVSADM} -d -t ${IPVS_VIP}:${PORT} -r ${SORRY}:${PORT} 
	fi
    fi
done < <(${SERF} members -status alive -tag role=room -tag state=up -format json | ${JQ} -c '.members[]')

if [ "x${MY_MASTER}" = "xmaster" -a "x${STATE}" = "xup" ];then
    exit 0
fi

BE_MASTER=1
while read line ;do
    MASTER=$(echo $line | ${JQ} '.tags.master')
    if [ "x${MASTER}" = "xmaster" ];then
	BE_MASTER=0
	break
    fi
done < <(${SERF} members -status alive -tag role=lb -tag state=up -format json | ${JQ} -c '.members[]')

if  [ ${BE_MASTER} -eq 1  ];then
    ip addr add ${VR_VIP}/${VR_SUB} dev ${VR_IFACE}
    ${ARPING} -A ${VR_VIP} -c 1
    ${SERF} tags -set master=master
else
    ${SERF} tags -set master=slave
fi

${SERF} tags -set state=up




