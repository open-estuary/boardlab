#!/bin/bash

#############################################################################
# get all boards number
#############################################################################

get_all_boards_no=$(grep -E "^(BOARD)" $OPENLAB_CONF_DIR/$BOARD_INFO_FILE | grep -Po "(?<=BOARD)([^:]*)" | tr '\n' ' ')

#############################################################################
# get_board_type brdNo
#############################################################################
get_board_type()
{
	local board_no=$1
	local board_info=$(grep -P "^(BOARD$board_no:).*" $OPENLAB_CONF_DIR/$BOARD_INFO_FILE)
	local board_type=$(echo $board_info | grep -Po "(?<=type=)([^ ,]*)")
	echo $board_type
}

#############################################################################
# get_board_mac brdNo
#############################################################################
get_board_mac()
{
	local board_no=$1
	local board_info=$(grep -P "^(BOARD$board_no:).*" $OPENLAB_CONF_DIR/$BOARD_INFO_FILE)
	local board_mac=$(echo $board_info | grep -Po "(?<=mac=)([^ ,]*)")
	echo $board_mac
}

#############################################################################
# get_board_info brdNo
#############################################################################
get_board_info()
{
	grep -P "^(BOARD$1:).*" $OPENLAB_CONF_DIR/$BOARD_INFO_FILE
}

#############################################################################
# board_deploy_chk brdNo
#############################################################################
board_deploy_chk()
{
	local board_no=$1
	local board_info=$(grep -P "^(BOARD$board_no:).*" $OPENLAB_CONF_DIR/$BOARD_INFO_FILE)
	local power_info=$(echo $board_info | grep -Po "(?<=power=)([^,]*)")
	local power_type=$(echo "$power_info" | grep -Po "(PDU|BMC)")
	local power_args=($(echo ${power_info#$power_type}))
	local power_index=${power_args[0]}
	local power_control_info=

	if [ x"$power_type" = x"PDU" ]; then
		power_control_info=$(grep -P "^(PDU$power_index:)" $OPENLAB_CONF_DIR/$PDU_INFO_FILE)
	else
		power_control_info=$(grep -P "^(BMC$power_index:)" $OPENLAB_CONF_DIR/$BMC_INFO_FILE)
	fi

	if [ x"$power_control_info" = x"" ]; then
		echo "Power$brdNo is not deployed into Open Lab, please touch the Lab. manager." >&2
		return 1
	fi
	
	return 0
}

#############################################################################
# board_using_chk_ex brdNo op
#############################################################################
board_using_chk_ex()
{
	brdNo=$1
	op=$2

	user=`whoami`
	usr=$(get_board_current_user $brdNo)
	if [ x"$usr" = x"$user" ]; then
		if [ x"$op" = x"connect" ]; then
			echo "You are using another session connected to the board."
			read -n1 -p "Do you want to kill it and try a new session [Y/N]?" answer
			case $answer in
			Y | y)
				echo  -e "\n fine ,continue"
				close_board_connect $brdNo
				local pid=`get_board_connect_pid $brdNo`
				if [ x"$pid" != x"" ]; then
					kill -s 9 $pid
				fi
				return 0
				;;
			N | n)
				echo -e "\n ok,good bye" ; return 1
				;;
			*)
				echo -e  "\n Sorry! Error choice" ; return 1
				;;
			esac
		fi
	elif [ x"$usr" != x"" ]; then
		email=$(get_user_mail $usr)
		echo "$email is using the board on $brdNo"
		echo "if you really want to use it, please contact with him" ; return 1
	fi

	return 0
}

#############################################################################
# board_using_chk brdNo op
#############################################################################
board_using_chk()
{
	if (board_using_chk_ex $1 $2); then
		return 0
	else
		return 1
	fi
}

#############################################################################
# get_board_connect_cmd brdNo
#############################################################################
get_board_connect_cmd()
{
	local board_no=$1
	local board_connect_cmd=
	local board_info=$(grep -P "^(BOARD$board_no:).*" $OPENLAB_CONF_DIR/$BOARD_INFO_FILE)

	local serial=$(echo "$board_info" | grep -Po "(?<=serno=)([^ ,]*)")
	local serial_type=$(echo "$serial" | grep -Po "(TELNET|BMC)")
	local serial_no=${serial#$serial_type}

	if [ x"$serial_type" = x"TELNET" ]; then
		board_connect_cmd=$(get_telnet_connect_cmd $serial_no)
	else
		board_connect_cmd=$(get_bmc_connect_cmd $serial_no)
	fi

	echo $board_connect_cmd
}

#############################################################################
# get_board_current_user brdNo
#############################################################################
get_board_current_user()
{
	local board_no=$1
	local board_connect_cmd=$(get_board_connect_cmd $board_no | sed 's/\(-P \)\([^ ]*\)/\1XXXXXXXXXX/')
	local used_info=$(ps -o ruser=userForLongName -e -o pid,cmd | grep "$board_connect_cmd" | grep -v grep)
	local user=$(echo $used_info | awk '{print $1}')
	echo $user
}

#############################################################################
# get_board_connect_pid brdNo
#############################################################################
get_board_connect_pid()
{
	local board_no=$1
	local board_connect_cmd=$(get_board_connect_cmd $board_no | sed 's/\(-P \)\([^ ]*\)/\1XXXXXXXXXX/')
	local used_info=$(ps -e -o pid,cmd | grep "$board_connect_cmd" | grep -v grep)
	local connect_pid=$(echo $used_info | awk '{print $1}')
	echo $connect_pid
}

#############################################################################
# close_board_connect brdNo
#############################################################################
close_board_connect()
{
	board_serial $1 disconnect
}

#############################################################################
# get_board_no_by_ser serial
#############################################################################
get_board_no_by_ser()
{
	local serial=$1
	local board_info=$(grep -P "serno=$serial" $OPENLAB_CONF_DIR/$BOARD_INFO_FILE)
	local board_no=$(echo "$board_info" | grep -Po "(?<=BOARD)(\d+)")
	echo $board_no
}

#############################################################################
# board_deploy_check brdNo
#############################################################################
board_deploy_check()
{
	local brdNo=$1
	local board_info=$(get_board_info $brdNo)
	if [ x"$board_info" = x"" ]; then
		echo "Board$brdNo is not deployed into Open Lab, please touch the Lab. manager."
		return 1
	fi
	local power=$(echo "$board_info" | grep -Po "(?<=power=)([^,]*)")
}

#############################################################################
# board_check brdNo
#############################################################################
board_using_check()
{
	local board_no=$1
	local user="`whoami`"
	if [ x"$usr" = x"" ]; then
		return 0
	elif [ x"$usr" = x"$usr" ]; then
		echo "You are using another session connected to the board" >&2
		return 1
	else
		local mail=$(get_user_mail $usr)
		echo "$mail is using the board on $2" >&2
		return 2
	fi
}

#############################################################################
# board_file_copy_ex brdNo
#############################################################################
board_file_copy_ex()
{
	board_no=$1
	board_type=$(get_board_type $board_no)
	baord_mac=$(get_board_mac $board_no)

	platform=$(echo $board_type | tr "[:upper:]" "[:lower:]")
	grubfile=${GRUB_PREFIX}-${baord_mac}

	bak_path=$FTP_DIR/$FTP_BAK

	eval IMG=\$IMG_$board_type
	eval DTB=\$DTB_$board_type

	CPIO=$mini_rootfs

	if [ ! -f ~/ftp/$IMG ] ;then
		cp $bak_path/$IMG ~/ftp/
	fi 
	if [ ! -f ~/ftp/$DTB ];then
		cp $bak_path/$DTB ~/ftp/
	fi
	if [ ! -f ~/ftp/$MINI_ROOTFS ];then
		cp $bak_path/$MINI_ROOTFS ~/ftp/	
	fi

	if [ ! -f ${DEFCFG} ]; then
		gencfg.sh
	fi

	rm -f $FTP_DIR/${grubfile}
	cp ${DEFCFG} $FTP_DIR/${grubfile}
	chmod a+rw $FTP_DIR/${grubfile}
	rm -f ~/config
	ln -s $FTP_DIR/${grubfile} ~/config
}

#############################################################################
# board_file_copy brdNo
#############################################################################
board_file_copy()
{
	(board_file_copy_ex $1)
}



