#!/bin/bash

BIN=/usr/ccmp/bin
SERF=${BIN}/serf
SERF_ROLE=web
PORT=$1

${SERF} agent \
	-config-file "/usr/ccmp/etc/serf/serf_common.json" \
	-config-file "/usr/ccmp/etc/serf/serf_web.json" \
	-tag port=${PORT} >>/var/log/serf.log 2>&1

