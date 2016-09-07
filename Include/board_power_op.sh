#!/bin/bash

#############################################################################
# board_power_ex brdNo op
#############################################################################
board_power_ex()
{
	local board_no=$1
	local power_op=$2
	local board_info=$(get_board_info $board_no)
	local power_info=$(echo "$board_info" | grep -Po "(?<=power=)([^,]*)")
	local power_type=$(echo "$power_info" | grep -Po "(PDU|BMC)")
	local power_args=($(echo ${power_info#$power_type}))
	local power_index=${power_args[0]}

	if [ x"$power_type" = x"PDU" ]; then
		local pdu_outlet=${power_args[1]}
		pdu_power $power_index $pdu_outlet $power_op
	else
		bmc_power $power_index $power_op
	fi
}

#############################################################################
# board_power brdNo op
#############################################################################
board_power()
{
	board_power_ex $@
}

