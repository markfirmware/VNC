#!/bin/bash
set -e

LPR=VNCTest
CONF=$1
if [[ $CONF == "" ]]
then
    CONF=QEMUVPB
fi
case $CONF in
QEMUVPB)
    PROC=QEMUVPB
    ARCH=ARMV7a
    KERNEL=kernel.bin
    ;;
RPI)
    PROC=RPIB
    ARCH=ARMV6
    KERNEL=kernel.img
    ;;
RPI2)
    PROC=RPI2B
    ARCH=ARMV7a
    KERNEL=kernel7.img
    ;;
RPI3)
    PROC=RPI3B
    ARCH=ARMV7a
    KERNEL=kernel7.img
    ;;
esac

echo build.sh $LPR $CONF

ULTIBO=$HOME/ultibo/core
ULTIBOBIN=$ULTIBO/fpc/bin
REPO=prototype-microbit-as-ultibo-peripheral
export PATH=$ULTIBOBIN:$PATH
#for f in *.lpr *.pas
#do
#    ptop -l 1000 -i 1 -c ptop.cfg $f $f.formatted
#    mv $f.formatted $f
#done

rm -rf lib/ *.o
fpc -dBUILD_$CONF -B -O2 -Tultibo -Parm -Cp$ARCH -Wp$PROC -Fi$ULTIBO/source/rtl/ultibo/extras -Fi$ULTIBO/source/rtl/ultibo/core @$ULTIBOBIN/$CONF.CFG $LPR.lpr >& errors.log

mv $KERNEL $LPR-kernel-$CONF.img
