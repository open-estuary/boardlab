#!/bin/bash
LABCFG="/etc/boardlab/boardlab.cfg"
. $LABCFG

USER=`whoami`
SVRIP=`ifconfig -a|grep -A 2 eth|grep "inet addr"|grep -v 127.0.0.1|grep -v "Bcast:0.0.0.0"|awk '{print $2}'|tr -d "addr:"|sed -n "1p"`

DEFCFG=~/grub.conf

echo "#Description: default grub config file
#author: automated

set timeout=5
set default=minilinux

menuentry \"minilinux\" --id minilinux {
    set root=(tftp,$SVRIP)
    linux /$USER/$img_d02 rdinit=/init crashkernel=256M@32M console=ttyS0,115200 earlycon=uart8250,mmio32,0x80300000
    initrd /$USER/$mini_rootfs
    devicetree /$USER/$dtb_d02
}

menuentry \"Ubuntu D02\" --id ubuntu_d02 {
    set root=(tftp,$SVRIP)
    linux /$USER/$img_d02 rdinit=/init console=ttyS0,115200 earlycon=uart8250,mmio32,0x80300000 root=/dev/nfs rw nfsroot=$SVRIP:$ftp_dir/$USER/ubuntu ip=dhcp
    devicetree /$USER/$dtb_d02
}

menuentry \"Ubuntu D01\" --id ubuntu_d01 {
    set root=(tftp,$SVRIP)
    linux /$USER/$img_d01 rdinit=/init console=ttyS0,115200 earlycon=uart8250,mmio32,0x80300000 root=/dev/nfs rw nfsroot=$SVRIP:$ftp_dir/$USER/ubuntu ip=dhcp
    devicetree /$USER/$dtb_d01
}" >$DEFCFG
