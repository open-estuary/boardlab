#!/bin/bash

#############################################################################
#
#############################################################################
OPENLAB_TOPDIR=/usr/local/openlab
OPENLAB_CONF_DIR=$OPENLAB_TOPDIR/openlab_conf
. $OPENLAB_TOPDIR/Include/common.sh

#############################################################################
#
#############################################################################
USER=`whoami`
SVRIP=`ifconfig -a | grep -A 2 eth | grep "inet addr" | grep -v 127.0.0.1 | grep -v "Bcast:0.0.0.0" | awk '{print $2}'| tr -d "addr:" | sed -n "1p"`
DEFCFG=~/grub.cfg

echo "#Description: default grub config file
#author: automated

set timeout=5
set default=minilinux_d02

menuentry \"minilinux_d02\" --id minilinux_d02 {
    set root=(tftp,$SVRIP)
    linux /$USER/$IMG_D02 rdinit=/init crashkernel=256M@32M console=ttyS0,115200 earlycon=uart8250,mmio32,0x80300000
    initrd /$USER/$MINI_ROOTFS
    # devicetree /$USER/$DTB_D02
}

menuentry \"minilinux_d03\" --id minilinux_d03 {
    set root=(tftp,$SVRIP)
    linux /$USER/$IMG_D03 rdinit=/init crashkernel=256M@32M console=ttyS1,115200 earlycon=hisilpcuart,mmio,0xa01b0000,0,0x2f8
    initrd /$USER/$MINI_ROOTFS
    # devicetree /$USER/$DTB_D03
}

menuentry \"Ubuntu D02\" --id ubuntu_d02 {
    set root=(tftp,$SVRIP)
    linux /$USER/$IMG_D02 rdinit=/init console=ttyS0,115200 earlycon=uart8250,mmio32,0x80300000 root=/dev/nfs rw nfsroot=$SVRIP:$FTP_DIR/$USER/ubuntu ip=dhcp
    # devicetree /$USER/$DTB_D02
}

menuentry \"Ubuntu D03\" --id ubuntu_d03 {
    set root=(tftp,$SVRIP)
    linux /$USER/$IMG_D03 rdinit=/init console=ttyS1,115200 earlycon=hisilpcuart,mmio,0xa01b0000,0,0x2f8 root=/dev/nfs rw nfsroot=$SVRIP:$FTP_DIR/$USER/ubuntu ip=dhcp
    # devicetree /$USER/$DTB_D03
}

menuentry \"Ubuntu D01\" --id ubuntu_d01 {
    set root=(tftp,$SVRIP)
    linux /$USER/$IMG_D01 rdinit=/init console=ttyS0,115200 earlycon=uart8250,mmio32,0x80300000 root=/dev/nfs rw nfsroot=$SVRIP:$FTP_DIR/$USER/ubuntu ip=dhcp
    # devicetree /$USER/$DTB_D01
}" >${DEFCFG}
