#!/bin/bash

#############################################################################
# get_bmc_op_cmd bmcNo op ......
#############################################################################
get_bmc_op_cmd()
{
	(
	bmc="BMC$1"
	shift
	bmc_op=$@
	bmc_info=$(grep -P "^($bmc:).*" $OPENLAB_CONF_DIR/$BMC_INFO_FILE)
	bmc_ip=$(echo "$bmc_info" | grep -Po "(?<=ip=)([^,]*)")
	bmc_account=$(echo "$bmc_info" | grep -Po "(?<=account=)([^,]*)")
	bmc_pass=$(echo "$bmc_info" | grep -Po "(?<=pass=)([^,]*)")
	bmc_op_cmd="ipmitool -H $bmc_ip -I lanplus -U $bmc_account -P $bmc_pass $bmc_op"
	echo $bmc_op_cmd
	)
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
	get_bmc_op_cmd $1 sol activate
}

#############################################################################
# bmc_connect bmcNo
#############################################################################
bmc_connect()
{
	send_cmd_to_bmc $1 sol activate
}

#############################################################################
# bmc_disconnect bmcNo
#############################################################################
bmc_disconnect()
{
	(
	send_cmd_to_bmc $1 sol deactivate
	bmc_connect_cmd=$(get_bmc_op_cmd $1 sol activate)
	bmc_pid=$(ps -o pid,cmd | grep "$bmc_connect_cmd" | grep -v grep | awk '{print $1}')
	if [ x"$bmc_pid" != x"" ]; then
		kill -s 9 $bmc_pid
	fi
	)
}

#############################################################################
# bmc_power_on bmcNo
#############################################################################
bmc_power_on()
{
	send_cmd_to_bmc $1 chassis power on
}

#############################################################################
# bmc_power_off bmcNo
#############################################################################
bmc_power_off()
{
	send_cmd_to_bmc $1 chassis power off
}

#############################################################################
# bmc_power_reset bmcNo
#############################################################################
bmc_power_reset()
{
	send_cmd_to_bmc $1 chassis power reset
}

#############################################################################
# bmc_power bmcNo op(on/off/reset)
#############################################################################
bmc_power()
{
	send_cmd_to_bmc $1 chassis power $2
}

#############################################################################
# bmc_serial_ex bmcNo op(connect/disconnect)
#############################################################################
bmc_serial_ex()
{
	bmc_no=$1
	sol_op=$2

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
	(bmc_serial_ex $@)
}

