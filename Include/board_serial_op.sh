#!/bin/bash

#############################################################################
# board_serial_ex brdNo op(connect/disconnect)
#############################################################################
board_serial_ex()
{
	local ser_op=$2
	local board_info=$(get_board_info $1)
	local serial=$(echo "$board_info" | grep -Po "(?<=serno=)([^ ,]*)")
	local serial_type=$(echo "$serial" | grep -Po "(TELNET|BMC)")
	local serial_no=${serial#$serial_type}

	if [ x"$serial_type" = x"TELNET" ]; then
		telnet_serial $serial_no $ser_op
	else
		bmc_serial $serial_no $ser_op
	fi
}

#############################################################################
# board_serial brdNo op(connect/disconnect)
#############################################################################
board_serial()
{
	(board_serial_ex $@)
}

