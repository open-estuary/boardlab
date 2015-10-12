#!/bin/bash
#author: Justin Zhao
#date: 12/10/2015
#description: to install board management system.

CFGPATH="/etc/boardlab"
BINPATH="/usr/bin"

PRJDIR="`dirname $0`"
cd $PRJDIR

# Install config files
sudo mkdir -p $CFGPATH

if [ ! -f "$CFGPATH/boards.cfg" ]; then
    sudo cp boards.cfg $CFGPATH/
fi

if [ ! -f "$CFGPATH/users.cfg" ]; then
    sudo cp users.cfg $CFGPATH/
fi

if [ ! -f "$CFGPATH/boardlab.cfg" ]; then
    sudo cp boardlab.cfg $CFGPATH/
fi

# Install binaries
sudo cp ap7921-control $BINPATH
sudo cp board_connect $BINPATH
sudo cp board_reboot $BINPATH
sudo cp cp_rootfs.sh $BINPATH
sudo cp gencfg.sh $BINPATH
sudo cp newboard $BINPATH
sudo cp newuser $BINPATH

echo "Boardlab installed successfully!"
