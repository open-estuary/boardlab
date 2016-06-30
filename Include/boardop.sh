#!/bin/bash

#############################################################################
# get_board_info brdNo
#############################################################################
get_board_info()
{
	grep -P "^(BOARD$1:).*" $OPENLAB_CONF_DIR/$BOARD_INFO_FILE
}

#############################################################################
# get_board_type brdNo
#############################################################################
get_board_type()
{
	local board_info=$(get_board_info $1)
	local board_type=$(echo $board_info | grep -Po "(?<=type=)([^ ,]*)")
	echo $board_type
}

#############################################################################
# get_board_mac brdNo
#############################################################################
get_board_mac()
{
	local board_info=$(get_board_info $1)
	local board_mac=$(echo $board_info | grep -Po "(?<=mac=)([^ ,]*)")
	echo $board_mac
}

#############################################################################
# get_board_no usr brdIdx
#############################################################################
get_board_no()
{
	local usr=$1
	local board_index=$2
	local user_boards=($(get_user_boards $usr))
	local board_no=

	if [ x"$board_index" = x"" ]; then
		board_no=${user_boards[0]}
	else
		if [ $board_index -lt 0 ] || [ $board_index -ge ${#user_boards[@]} ]; then
			board_index=0
		fi
		board_no=${user_boards[$board_index]}
	fi

	echo $board_no
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
# get_board_connect_cmd brdNo
#############################################################################
get_board_connect_cmd()
{
	local board_connect_cmd=
	local board_info=$(get_board_info $1)
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
# board_deploy_chk brdNo
#############################################################################
board_deploy_chk()
{
	local brdNo=$1
	local board_info=$(get_board_info $brdNo)
	if [ x"$board_info" = x"" ]; then
		echo -e "\033[31mCan't find board info! Please touch the lab manager to get more help!\033[0m" ;
		return 1
	fi

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
		echo "Power$brdNo is not deployed into Open Lab, please touch the lab manager." >&2
		return 1
	fi

	return 0
}

#############################################################################
# board_file_prepare_ex brdNo
#############################################################################
board_file_prepare_ex()
{
	local board_no=$1
	local board_type=$(get_board_type $board_no)
	local baord_mac=$(get_board_mac $board_no)

	local bak_path=$FTP_DIR/$FTP_BAK
	local grubfile=${GRUB_PREFIX}-${baord_mac}

	eval IMG=\$IMG_$board_type
	eval DTB=\$DTB_$board_type

	if [ ! -f ~/ftp/$IMG ]; then
		cp $bak_path/$IMG ~/ftp/
	fi

	if [ ! -f ~/ftp/$DTB ]; then
		cp $bak_path/$DTB ~/ftp/
	fi

	if [ ! -f ~/ftp/$MINI_ROOTFS ]; then
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
# board_file_prepare brdNo
#############################################################################
board_file_prepare()
{
	(board_file_prepare_ex $1)
}

#############################################################################
# gen_board_lock_file usr brdNo
#############################################################################
gen_board_lock_file()
{
	local user=$1
	local board_no=$2
	local board_mac=$(get_board_mac $board_no)
	local filename=${user}@${board_mac}.LOCK
	touch /tmp/$filename
}

#############################################################################
# get_board_lock_file_user lockfile
#############################################################################
get_board_lock_file_user()
{
	local filename=${1#*/}
	local user=${filename%@*}
	echo $user
}

#############################################################################
# find_board_lock_file brdNo
#############################################################################
find_board_lock_file()
{
	local board_no=$1
	local board_mac=$(get_board_mac $board_no)
	local files=$(cd /tmp; ls *.LOCK 2>/dev/null)

	if !(echo $files |grep "$board_mac"); then
		# there is no board lock file for the board,
		# that is, the board is not locked
		return 1
	fi

	local filename=
	for file in $files; do
		filename=${file%.LOCK}
		if [ x"${filename#*@}" = x"$board_mac" ]; then
			echo /tmp/$file
			break
		fi
	done

	return 0
}

#############################################################################
# board_is_lock brdNo
#############################################################################
board_is_lock()
{
	local board_no=$1
	if (find_board_lock_file $board_no >/dev/null); then
		return 0
	else
		return 1
	fi
}

#############################################################################
# board_using_chk_ex user brdNo
#############################################################################
board_using_chk_ex()
{
	local user=$1
	local brdNo=$2

	local email=
	local curUser=$(get_board_current_user $brdNo)

	if [ x"$curUser" = x"" ]; then
		# the board is currently not using by anyone
		if !(board_is_lock $brdNo); then
			return 0
		fi

		# the board is locked
		local lock_file=$(find_board_lock_file $brdNo)
		local lock_user=$(get_board_lock_file_user $lock_file)
		if [ x"$lock_user" = x"$user" ]; then
			# the board locked by yourself
			return 0
		else
			# the board locked by others
			email=$(get_user_mail $lock_user)
			echo "the board $brdNo was locked by $lock_user($email)"
			echo "if you really want to use it, please contact with him,";
			echo "or use the -f option force to lock/unlock the board with sudo permission."
			return 1
		fi
	elif [ x"$curUser" = x"$user" ]; then
		# the board is currently using by yourself
		return 0
	else
		# the board is currently using by others
		email=$(get_user_mail $curUser)
		echo "$curUser($email) is using the board on $brdNo"
		echo "if you really want to use it, please contact with him" ;
		return 1
	fi
}

#############################################################################
# board_using_chk user brdNo
#############################################################################
board_using_chk()
{
	local user=$1
	local brdNo=$2

	if (board_using_chk_ex $user $brdNo); then
		return 0
	else
		return 1
	fi
}

