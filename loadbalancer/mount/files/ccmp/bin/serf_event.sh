#!/bin/bash

SERF=/usr/ccmp/bin/serf

HOSTNAME=$(hostname)
ADDRESS=$(ip -f inet addr show eth0 | awk '/^ *inet/{print $2;exit}' | cut -d/ -f 1)

if ! ROLE=$(${SERF} members | awk '/^'"${HOSTNAME}"'/{print $4}'| sed 's/.*role=\([^, ]*\) *,*.*$/\1/' );then
    echo 'Serf seem not to be executed'
    exit 1
fi

if ! TAGS=$(${SERF} members | awk '/^'"${HOSTNAME}"'/{print $4}');then
    echo 'Serf seem not to be executed'
    exit 1
fi

EVENT=$1
case ${EVENT} in
    "room-up" )
	${SERF} tags -set state=up
	sleep 3
	${SERF} event ${EVENT} "${HOSTNAME} ${ADDRESS} ${ROLE} ${TAGS}"
	;;
    "room-down" )
	${SERF} tags -set state=down
	sleep 3
	${SERF} event ${EVENT} "${HOSTNAME} ${ADDRESS} ${ROLE} port=${PORT}"
	;;
    "room-destroy" )
	${SERF} tags -set state=destroy
	sleep 3
	${SERF} event ${EVENT} "${HOSTNAME} ${ADDRESS} ${ROLE} port=${PORT}"
	;;
    * )
	${SERF} event ${EVENT} "${HOSTNAME} ${ADDRESS} ${ROLE} port=${PORT}"
	;;
esac


