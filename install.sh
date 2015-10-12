#!/bin/bash
#author: Justin Zhao
#date: 12/10/2015
#description: to install board management system.

CFGPATH="/etc/boardlab"
BINPATH="/usr/bin"

PRJDIR="`dirname $0`"
cd $PRJDIR

# Install config files
sudo mkdir -p $CFGPATH 2>/dev/null

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
sudo cp board_check $BINPATH
sudo cp board_connect $BINPATH
sudo cp board_reboot $BINPATH
sudo cp cp_rootfs.sh $BINPATH
sudo cp gencfg.sh $BINPATH
sudo cp newboard $BINPATH
sudo cp newuser $BINPATH

. $CFGPATH/boardlab.cfg

mkdir -p $ftp_dir/backup 2>/dev/null
cp Image_D02 $ftp_dir/backup/
cp hip05-d02.dtb $ftp_dir/backup/
cp zImage_D01 $ftp_dir/backup/
cp hip04-d01.dtb $ftp_dir/backup/
cp mini-rootfs.cpio.gz $ftp_dir/backup/

echo "Boardlab installed successfully!"
