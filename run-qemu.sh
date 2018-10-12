#!/bin/bash
set -e

./build.sh QEMUVPB
./mksdcardimage.sh

CMDLINE="NETWORK0_IP_CONFIG=STATIC NETWORK0_IP_ADDRESS=10.0.2.15"
CMDLINE="$CMDLINE NETWORK0_IP_NETMASK=255.255.255.0 NETWORK0_IP_GATEWAY=10.0.2.2"

echo "port 5790 is qemu's vnc server (websocket, suitable for novnc web browser viewer)"
echo "port 5890 is ultibo's vnc server (classic, suitable for any desktop vnc viewer)"
echo "port 5990 is qemu's vnc server (classic, suitable for any desktop vnc viewer)"

qemu-system-arm                                         \
    -M versatilepb -cpu cortex-a8 -m 256M               \
    -drive file=qemu-sd-fat12.img,if=sd,format=raw      \
    -serial stdio                                       \
    -display none                                       \
    -vnc :90,websocket=5790                             \
    -net nic                                            \
    -net user,hostfwd=tcp::5890-:5900                   \
    -kernel VNCTest-kernel-QEMUVPB.img                  \
    -append "$CMDLINE"                                  \
    |& egrep -v '^(pulseaudio:|alsa:|ALSA lib |audio:)'
