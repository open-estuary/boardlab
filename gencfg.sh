#!/bin/bash
USER=`whoami`
DEFCFG=~/grub.conf
echo "set timeout=5
set default=minilinux
menuentry \"minilinux\" --id minilinux {
        set root=(tftp,192.168.1.107)
        linux /$USER/Image rdinit=/init crashkernel=256M@32M console=ttyS0,115200 earlycon=uart8250,mmio32,0x80300000
        initrd /$USER/hulk-hip05.cpio.gz
        devicetree /$USER/hip05-d02.dtb
}
menuentry \"ubuntu\" --id ubuntu {
        set root=(tftp,192.168.1.107)
        linux /$USER/Image rdinit=/init console=ttyS0,115200 earlycon=uart8250,mmio32,0x80300000 root=/dev/nfs rw nfsroot=192.168.1.107:/home/hisilicon/ftp/$USER/ubuntu ip=:::::eth0:dhcp::
       devicetree /$USER/hip05-d02.dtb
}
menuentry \"opensuse\" --id opensuse {
        set root=(tftp,192.168.1.107)
        linux /$USER/Image rdinit=/init console=ttyS0,115200 earlycon=uart8250,mmio32,0x80300000 root=/dev/nfs rw nfsroot=192.168.1.107:/home/hisilicon/ftp/$USER/opensuse ip=:::::eth0:dhcp::
       devicetree /$USER/hip05-d02.dtb
}" >$DEFCFG


