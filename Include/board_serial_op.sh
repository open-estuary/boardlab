#!/bin/bash

#############################################################################
# board_serial_ex brdNo op(connect/disconnect)
#############################################################################
board_serial_ex()
{
	board_no=$1
	ser_op=$2
	
	board_info=$(grep -P "^(BOARD$board_no:).*" $OPENLAB_CONF_DIR/boardinfo.cfg)

	serial=$(echo "$board_info" | grep -Po "(?<=serno=)([^ ,]*)")
	serial_type=$(echo "$serial" | grep -Po "(TELNET|BMC)")
	serial_no=${serial#$serial_type}

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

