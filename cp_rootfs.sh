#!/bin/bash
#This script is used to copy rootfs to the ftp directory
#It can only be run by root user
USERLIST=/home/htsat/board/userlist
FTP_PATH=/home/hisilicon/ftp
UBUNTU=ubuntu
SUSE=opensuse
BACKUP=$FTP_PATH/backup
UBUN_FILE=ubuntu64.tar.gz
SUSE_FILE=openSUSE-13.1.tbz
while read username email group
	do
	
		echo $username
		if [ -d $FTP_PATH/$username/$UBUNTU ];then
			FILES_UBUN=`ls $FTP_PATH/$username/$UBUNTU` 
		fi
		if [ -d $FTP_PATH/$username/$UBUNTU ];then
			FILES_SUSE=`ls $FTP_PATH/$username/$SUSE`
		fi
		if [ -z "$FILES_UBUN" ];then
			echo "$UBUNTU is empty, Create it ... "
			tar -zxf $BACKUP/$UBUN_FILE -C $FTP_PATH/$username/$UBUNTU
			mv $FTP_PATH/$username/$UBUNTU/rootfs_ubuntu64/* $FTP_PATH/$username/$UBUNTU/
			rm -rf $FTP_PATH/$username/$UBUNTU/rootfs_ubuntu64			
		else
			echo "$UBUNTU is not empty, Skip it!"
		fi	
		if [ -z "$FILES_SUSE" ];then
			echo "$SUSE is empty, Create it ..."
			tar -jxf $BACKUP/$SUSE_FILE -C $FTP_PATH/$username/$SUSE
		else
			echo "$SUSE is not empty, Skip it!"
		fi

	done <$USERLIST
