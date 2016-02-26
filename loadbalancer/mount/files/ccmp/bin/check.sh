#!/bin/bash

SERVER=$1
PORT=$2

HELLO=$(echo HELLO | nc -w 3 ${SERVER} ${PORT})

if [ $? -eq 0 ];then
    echo ${HELLO} | grep "FINE" > /dev/null
    if [ $? -eq 0 ];then
	exit 0
    else
	exit 1
    fi
fi

exit 1

   
