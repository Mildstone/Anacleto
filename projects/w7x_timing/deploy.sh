#!/bin/sh
src=$(realpath $(dirname ${0}))
RedPitayaIP=$1
ssh root@${RedPitayaIP} "rm -rf /usr/local/mdsplus/tdi/w7x_timing;mkdir /usr/local/mdsplus/tdi/w7x_timing"
scp ${src}/tdi/*.fun      root@${RedPitayaIP}:/usr/local/mdsplus/tdi/w7x_timing ; \
scp ${src}/logic/out/red_pitaya.bit ${src}/src/w7x_timing.ko ${src}/src/w7x_timing_test      root@${RedPitayaIP}:/root && \
scp ${src}/src/libw7x_timing_lib.so      root@${RedPitayaIP}:/usr/local/lib && \
if [ -z "$2" ]
then
  ssh root@${RedPitayaIP} "cat /root/red_pitaya.bit > /dev/xdevcfg"
else
  ssh root@${RedPitayaIP} ". /etc/profile;rw&&mount -o remount,rw /boot&&echo ok||echo failed" && \
  scp ${src}/logic/sdk/dts/devicetree.dtb ${src}/../../uImage root@${RedPitayaIP}:/boot && \
  ssh root@${RedPitayaIP} reboot
fi
