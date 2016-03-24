#!/bin/bash

#############################################################################
# board_power_ex brdNo op
#############################################################################
board_power_ex()
{
	board_no=$1
	power_op=$2
	board_info=$(grep -P "^(BOARD$board_no:).*" $OPENLAB_CONF_DIR/boardinfo.cfg)

	power_info=$(echo "$board_info" | grep -Po "(?<=power=)([^,]*)")
	power_type=$(echo "$power_info" | grep -Po "(PDU|BMC)")
	power_args=($(echo ${power_info#$power_type}))
	power_index=${power_args[0]}

	if [ x"$power_type" = x"PDU" ]; then
		pdu_outlet=${power_args[1]}
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
	(board_power_ex $@)
}

