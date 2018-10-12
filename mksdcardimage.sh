#!/usr/bin/env bash
set -e

SDIMG=qemu-sd-fat12.img
MOUNTFOLDER=qemu-sd-mounted

fallocate -l 1M $SDIMG
mkfs.fat -F 12 $SDIMG
mkdir -p $MOUNTFOLDER
sudo mount $SDIMG $MOUNTFOLDER
cp -a arial.ttf $MOUNTFOLDER
ls -l $MOUNTFOLDER
sudo umount $MOUNTFOLDER
