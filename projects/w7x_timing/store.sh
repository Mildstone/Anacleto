#!/bin/sh
src=$(realpath $(dirname ${0}))
num=$1
makedest () {
dest=~/rp/${num}$1
mkdir -p ${dest}
}
makedest /usr/local/mdsplus/tdi/w7x_timing
cp ${src}/tdi/*.fun                   $dest ; \
makedest /root
cp ${src}/logic/out/red_pitaya.bit ${src}/src/w7x_timing.ko ${src}/src/w7x_timing_test $dest && \
makedest /usr/local/lib
cp ${src}/src/libw7x_timing_lib.so $dest && \
makedest /boot
cp ${src}/logic/sdk/dts/devicetree.dtb ${src}/../../uImage $dest
