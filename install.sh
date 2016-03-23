#!/bin/bash
#author: Justin Zhao
#date: 12/10/2015
#description: to install board management system.

BINPATH="/usr/bin"

apt-get install ser2net -y
apt-get install expect-lite -y
apt-get install ipmitool -y
apt-get install telnet -y

PRJDIR="`dirname $0`"
cd $PRJDIR

#############################################################################
# Include
#############################################################################
. ./Include/common.sh

#############################################################################
# Install config files
#############################################################################
mkdir -p $OPENLAB_TOPDIR 2>/dev/null

if [ ! -d "$OPENLAB_CONF_DIR" ]; then
    cp -r openlab_conf $OPENLAB_TOPDIR/
fi

if [ ! -d "$OPENLAB_TOPDIR/Include" ]; then
    cp -r Include $OPENLAB_TOPDIR/
fi

# Install binaries
cp ap7921-control $BINPATH
if [ $? != 0 ]; then
    echo "You should do this command with \"sudo\" before it"
    exit 1
fi

#############################################################################
# Copy board binaries to /usr/bin.
#############################################################################
cp board_connect $BINPATH
cp board_list $BINPATH
cp board_reboot $BINPATH
cp newuser $BINPATH
cp gencfg.sh $BINPATH
cp inituser $BINPATH
cp newuser $BINPATH

#############################################################################
# Create ftp directory and copy base file system
#############################################################################
mkdir -p $FTP_DIR 2>/dev/null
chmod 777 $FTP_DIR
mkdir -p $FTP_DIR/$FTP_BAK 2>/dev/null
cp *Image_D* $FTP_DIR/$FTP_BAK/
cp hip*.dtb $FTP_DIR/$FTP_BAK/
cp mini-rootfs*.cpio.gz $FTP_DIR/$FTP_BAK/

#############################################################################
# Comm user profile
#############################################################################
grep "inituser" /etc/skel/.bashrc >/dev/null
if [ $? = 1 ]; then
    echo "export PATH=\$PATH:/sbin
if [ -f /usr/bin/inituser ]; then
    $BINPATH/inituser    
fi" >> /etc/skel/.bashrc
fi

echo "Boardlab installed successfully!"

