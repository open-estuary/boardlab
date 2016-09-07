#!/bin/bash

#############################################################################
# get_bmc_op_cmd bmcNo op ......
#############################################################################
get_bmc_op_cmd()
{
	local board_no=$1
	local bmc="BMC${board_no}"
	shift

	local bmc_op=$@
	local bmc_info=$(grep -P "^($bmc:).*" $OPENLAB_CONF_DIR/$BMC_INFO_FILE)
	local bmc_ip=$(echo "$bmc_info" | grep -Po "(?<=ip=)([^,]*)")
	local bmc_if=$(echo "$bmc_info" | grep -Po "(?<=interface=)([^,]*)")
	local bmc_account=$(echo "$bmc_info" | grep -Po "(?<=account=)([^,]*)")
	local bmc_pass=$(echo "$bmc_info" | grep -Po "(?<=pass=)([^,]*)")
	local bmc_op_cmd="ipmitool -H $bmc_ip -I $bmc_if -U $bmc_account -P $bmc_pass $bmc_op"
	echo $bmc_op_cmd
}

#############################################################################
# send_cmd_to_bmc bmcNo op ......
#############################################################################
send_cmd_to_bmc()
{
	(
	bmc_op_cmd=$(get_bmc_op_cmd $@)
	if [ x"$bmc_op_cmd" != x"" ]; then
		exec $bmc_op_cmd
	fi
	)
}

#############################################################################
# bmc_connect_cmd bmcNo
#############################################################################
get_bmc_connect_cmd()
{
	local bmc_no=$1
	get_bmc_op_cmd $bmc_no sol activate
}

#############################################################################
# bmc_connect bmcNo
#############################################################################
bmc_connect()
{
	local bmc_no=$1
	send_cmd_to_bmc $bmc_no sol activate
}

#############################################################################
# bmc_disconnect bmcNo
#############################################################################
bmc_disconnect()
{
	local bmc_no=$1
	local bmc_connect_cmd=$(get_bmc_connect_cmd $bmc_no)
	local bmc_pid=$(ps -o pid,cmd | grep "$bmc_connect_cmd" | grep -v grep | awk '{print $1}')

	send_cmd_to_bmc $bmc_no sol deactivate

	if [ x"$bmc_pid" != x"" ]; then
		kill -s 9 $bmc_pid
	fi
}

#############################################################################
# bmc_power bmcNo op(on/off/reset)
#############################################################################
bmc_power()
{
	local bmc_no=$1
	local power_op=$2
	send_cmd_to_bmc $bmc_no chassis power $power_op
}

#############################################################################
# bmc_power_on bmcNo
#############################################################################
bmc_power_on()
{
	local bmc_no=$1
	bmc_power $bmc_no on
}

#############################################################################
# bmc_power_off bmcNo
#############################################################################
bmc_power_off()
{
	local bmc_no=$1
	bmc_power $bmc_no off
}

#############################################################################
# bmc_power_reset bmcNo
#############################################################################
bmc_power_reset()
{
	local bmc_no=$1
	bmc_power $bmc_no reset
}

#############################################################################
# bmc_serial_ex bmcNo op(connect/disconnect)
#############################################################################
bmc_serial_ex()
{
	local bmc_no=$1
	local sol_op=$2

	case $sol_op in
	"connect")
		bmc_connect $bmc_no ;;
	"disconnect")
		bmc_disconnect $bmc_no ;;
	esac
}

#############################################################################
# bmc_serial bmcNo op(connect/disconnect)
#############################################################################
bmc_serial()
{
	bmc_serial_ex $@
}

