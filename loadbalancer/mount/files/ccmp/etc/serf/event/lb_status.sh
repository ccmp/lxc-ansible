#!/bin/bash

if [ "x${SERF_TAG_ROLE}" != "xlb" ]; then
    echo "Not an loadbalancer. Nothing to do in this script."
    exit 0
fi

HOSTNAME=$(hostname)
ADDRESS=$(ip -f inet addr show eth0 | awk '/^ *inet/{print $2;exit}' | cut -d/ -f 1)

if [ "x${SERF_TAG_MASTER}" != "x" ]; then
    MASTER=${SERF_TAG_MASTER}
else
    MASTER=none
fi

echo ${HOSTNAME} ${ADDRESS} ${MASTER}

