#!/bin/bash

BIN=/usr/ccmp/bin
SERF=${BIN}/serf

${SERF} agent \
	-config-file "/usr/ccmp/etc/serf/serf_common.json" \
	-config-file "/usr/ccmp/etc/serf/serf_lvs.json" \
	>>/var/log/serf.log 2>&1

