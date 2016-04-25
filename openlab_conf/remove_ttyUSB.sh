#!/bin/bash

DEVICE_NAME=$1
NUM1=$(echo $2 | cut -d '/' -f 7)
NUM2=$(echo $2 | cut -d '/' -f 8)
NUM3=$(echo $2 | cut -d '/' -f 9)

HUB_INDEX=$(echo $NUM1 | cut -d '.' -f 2)
NUM_J=$(echo $NUM2 | cut -d '.' -f 3)
NUM_K=$(echo $NUM3 | cut -d '.' -f 4)

let "PORT=($NUM_J-1)*4+$NUM_K"

LINK_NAME=USBHUB${HUB_INDEX}-${PORT}
rm -f /dev/$LINK_NAME
