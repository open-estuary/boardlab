#!/bin/bash
#author: Justin Zhao
#date: 12/10/2015
#description: to install board management system.

CFGPATH="/etc/boardlab"
BINPATH="/usr/bin"

apt-get install ser2net -y
apt-get install expect-lite -y
apt-get install ipmitool -y

PRJDIR="`dirname $0`"
cd $PRJDIR

# Install config files
mkdir -p $CFGPATH 2>/dev/null

if [ ! -f "$CFGPATH/boards.cfg" ]; then
    cp boards.cfg $CFGPATH/
fi

if [ ! -f "$CFGPATH/users.cfg" ]; then
    cp users.cfg $CFGPATH/
fi

if [ ! -f "$CFGPATH/pdu.cfg" ]; then
    cp pdu.cfg $CFGPATH/
fi

if [ ! -f "$CFGPATH/bmc.cfg" ]; then
    cp bmc.cfg $CFGPATH/
fi

if [ ! -f "$CFGPATH/boardlab.cfg" ]; then
    cp boardlab.cfg $CFGPATH/
fi

# Install binaries
cp ap7921-control $BINPATH
if [ $? != 0 ]; then
    echo "You should do this command with \"sudo\" before it"
    exit
fi
cp check_board $BINPATH
cp board_connect $BINPATH
cp board_list $BINPATH
cp board_reboot $BINPATH
cp cp_rootfs.sh $BINPATH
cp gencfg.sh $BINPATH
cp inituser $BINPATH
cp newuser $BINPATH
cp board_op $BINPATH
. $CFGPATH/boardlab.cfg

mkdir -p $ftp_dir 2>/dev/null
chmod 777 $ftp_dir
mkdir -p $ftp_dir/$ftp_bak 2>/dev/null
cp $img_d01 $ftp_dir/$ftp_bak/
cp $dtb_d01 $ftp_dir/$ftp_bak/
cp $img_d02 $ftp_dir/$ftp_bak/
cp $dtb_d02 $ftp_dir/$ftp_bak/
cp $mini_rootfs $ftp_dir/$ftp_bak/

grep "inituser" /etc/skel/.bashrc >/dev/null
if [ $? = 1 ]; then
    echo "if [ -f /usr/bin/inituser ]; then
    $BINPATH/inituser    
fi" >> /etc/skel/.bashrc
fi

echo "Boardlab installed successfully!"
