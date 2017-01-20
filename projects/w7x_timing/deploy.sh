#!/bin/sh
RedPitayaIP=$1
scp tdi/*.fun root@${RedPitayaIP}:/usr/local/mdsplus/tdi/w7x_timing ; \
scp logic/out/red_pitaya.bit src/w7x_timing.ko src/w7x_timing_test root@${RedPitayaIP}:/root && \
scp src/libw7x_timing_lib.so root@${RedPitayaIP}:/usr/local/lib && \
ssh root@${RedPitayaIP} ". /etc/profile;rw&&mount -o remount,rw /boot&&echo ok||echo failed" && \
scp logic/sdk/dts/devicetree.dtb ../../uImage root@${RedPitayaIP}:/boot && \
ssh root@${RedPitayaIP} reboot

