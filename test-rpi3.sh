#!/bin/bash
set -e
set -x

# on raspbian, build the program and reboot to it

LAZDIR="$HOME/ultibo/core"
REPONAME=VNC
LPINAME=VNCTest

rm -rf $REPONAME-kernel7-rpi3.img
WD=$(pwd)
pushd $LAZDIR >& /dev/null
./lazbuild $WD/$LPINAME.lpi
popd >& /dev/null
mv kernel7.img $REPONAME-kernel-rpi3.img

sudo cp arial.ttf /boot
sudo cp $REPONAME-kernel-rpi3.img /boot
sudo cp $REPONAME-config.txt $REPONAME-cmdline.txt /boot
sudo cp /boot/$REPONAME-config.txt /boot/config.txt
sleep 2
sudo reboot
