#!/bin/bash

#############################################################################
# get all users name
#############################################################################
get_all_users_name()
{
	local all_users_name=$(cut -d ":" -f1 $OPENLAB_CONF_DIR/$USER_INFO_FILE | grep ^[a-zA-Z] | tr '\n' ' ')
	echo ${all_users_name[*]}
}

#############################################################################
# get_user_mail usr
#############################################################################
get_user_mail()
{
	local usr=$1
	local mail=($(grep -P "^($usr:).*" $OPENLAB_CONF_DIR/$USER_INFO_FILE | grep -Po "(?<=email=)([^,]*)"))
	echo $mail
}

#############################################################################
# get_user_boards usr
#############################################################################
get_user_boards()
{
	local usr=$1
	local user_boards=($(grep -P "^($usr:).*" $OPENLAB_CONF_DIR/$USER_INFO_FILE | grep -Po "(?<=boards=)([^,]*)"))
	echo ${user_boards[@]}
}

#############################################################################
# get_user_fullname usr
#############################################################################
get_user_fullname()
{
	local usr=$1
	local usr_fullname=$(grep -P "^($usr:).*" $OPENLAB_CONF_DIR/$USER_INFO_FILE | grep -Po "(?<=fullname=\")([^\"]*)(?=\")")
	echo $usr_fullname
}

#############################################################################
# get_usr_background usr
#############################################################################
get_user_background()
{
	local usr=$1
	local usr_background=$(grep -P "^($usr:).*" $OPENLAB_CONF_DIR/$USER_INFO_FILE | grep -Po "(?<=background=\")([^\"]*)(?=\")")
	echo $usr_background
}

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



