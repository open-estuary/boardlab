#!/bin/bash

#############################################################################
# get_user_info usr
#############################################################################
get_user_info()
{
	local usr=$1
	local usr_info=$(grep -P "^($usr:).*" $OPENLAB_CONF_DIR/$USER_INFO_FILE)
	echo $usr_info

	if [ x"$usr_info" != x"" ]; then
		return 0
	else
		return 1
	fi
}

#############################################################################
# get_user_mail usr
#############################################################################
get_user_mail()
{
	local usr=$1
	local usr_info=$(get_user_info $usr)
	local mail=$(echo $usr_info | grep -Po "(?<=email=)([^,]*)")
	echo $mail
}

#############################################################################
# get_user_boards usr
#############################################################################
get_user_boards()
{
	local usr=$1
	local usr_info=$(get_user_info $usr)
	local user_boards=($(echo $usr_info | grep -Po "(?<=boards=)([^,]*)"))
	echo ${user_boards[@]}
}

#############################################################################
# get_user_fullname usr
#############################################################################
get_user_fullname()
{
	local usr=$1
	local usr_info=$(get_user_info $usr)
	local usr_fullname=$(echo $usr_info | grep -Po "(?<=fullname=\")([^\"]*)(?=\")")
	echo $usr_fullname
}

#############################################################################
# get_usr_background usr
#############################################################################
get_user_background()
{
	local usr=$1
	local usr_info=$(get_user_info $usr)
	local usr_background=$(echo $usr_info | grep -Po "(?<=background=\")([^\"]*)(?=\")")
	echo $usr_background
}

#############################################################################
# check_user usr
#############################################################################
check_user()
{
	local usr=$1
	if !(get_user_info $usr >/dev/null); then
		echo -e "\033[31mYou are not permited to use the board in OpenLab.\033[0m"
		return 1
	fi

	return 0
}
