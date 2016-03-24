#!/bin/bash

#############################################################################
# get_telnet_connect_cmd telnetNo
#############################################################################
get_telnet_connect_cmd()
{
	(
		telnet="TELNET$1"
		telnet_info=$(grep -P "^($telnet:).*" $OPENLAB_CONF_DIR/$TELNET_INFO_FILE)
		telnet_ip=$(echo "$telnet_info" | grep -Po "(?<=ip=)([^,]*)")
		telnet_port=$(echo "$telnet_info" | grep -Po "(?<=port=)([^,]*)")
		telnet_op_cmd="telnet $telnet_ip $telnet_port"
		echo $telnet_op_cmd
	)
}

#############################################################################
# telnet_connect telnetNo
#############################################################################
telnet_connect()
{
	(
	 telnet="TELNET$1"
	 telnet_info=$(grep -P "^($telnet:).*" $OPENLAB_CONF_DIR/$TELNET_INFO_FILE)
	 telnet_ip=$(echo "$telnet_info" | grep -Po "(?<=ip=)([^,]*)")
	 telnet_port=$(echo "$telnet_info" | grep -Po "(?<=port=)([^,]*)")
	 exec telnet $telnet_ip $telnet_port
	)
}

#############################################################################
# telnet_disconnect telnetNo
#############################################################################
telnet_disconnect()
{
	(
	telnet="TELNET$1"
	telnet_info=$(grep -P "^($telnet:).*" $OPENLAB_CONF_DIR/$TELNET_INFO_FILE)
	telnet_ip=$(echo "$telnet_info" | grep -Po "(?<=ip=)([^,]*)")
	telnet_port=$(echo "$telnet_info" | grep -Po "(?<=port=)([^,]*)")
	telnet_pid=$(ps -e -o pid,cmd | grep -Po "(.*)(?=telnet  *$telnet_ip  *$telnet_port)" | grep -v grep | awk '{print $1}')
	kill -s 9 $telnet_pid
	)
}

#############################################################################
# telnet_serial_ex telnetNo op(connect/disconnect)
#############################################################################
telnet_serial_ex()
{
	telnet_no=$1
	telnet_op=$2
	case $telnet_op in
	"connect")
		telnet_connect $telnet_no ;;
	"disconnect")
		telnet_disconnect $telnet_no ;;
	esac
}

#############################################################################
# telnet_serial telnetNo op(connect/disconnect)
#############################################################################
telnet_serial()
{
	(telnet_serial_ex $@)
}


