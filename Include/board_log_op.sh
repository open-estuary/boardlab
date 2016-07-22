#!/bin/bash

OPENLAB_TOPDIR=/usr/local/openlab
source $OPENLAB_TOPDIR/Include/common.sh
source $OPENLAB_TOPDIR/Include/userop.sh
source $OPENLAB_TOPDIR/Include/boardop.sh
source $OPENLAB_TOPDIR/Include/telnetop.sh
source $OPENLAB_TOPDIR/Include/bmcop.sh
source $OPENLAB_TOPDIR/Include/board_serial_op.sh
source $OPENLAB_TOPDIR/Include/board_power_op.sh
source $OPENLAB_TOPDIR/Include/pduop.sh

# select log files of a period time specified by user
# select_log_files $1 $2
# $1 for start time and $2 for end time
select_log_files()
{
	#TODO
}

board_used_log_parse()
{
	local LOG_FILE=${OPENLAB_LOG_DIR}/${BOARD_USED_LOG_FILE}
	local LOG_FILE_TEMP=/tmp/$BOARD_USED_LOG_FILE
	:> $LOG_FILE_TEMP

	local time_start=$1
	local time_end=$2
	local log_files=$(select_log_files $time_start $time_end)

	local count=0
	local total_time=0
	for file in $log_files;
	do
	    let "count += 1"
	    cat ${OPENLAB_LOG_DIR}/$file >> $LOG_FILE_TEMP
	done

	let "count -= 1"
	let total_time=24*3600*$count

	if [ $time_start -eq 0 ]; then
		# get current day used time
		local CUR_DAY_START=$(sed -n '1p' $LOG_FILE | cut -d ":" -f2)
		local CUR_DAY_NOW=$(date +%s)
		local CUR_DAY_USED_TIME=$((CUR_DAY_NOW - CUR_DAY_START))
		let "total_time += $CUR_DAY_USED_TIME"
	fi

	############## Check how many boards have been used ###############################
	local all_boards_no=($(get_all_boards_no))
	for boardno in ${all_boards_no[*]}
	do
	    records=$(grep -w "boardno:${boardno}" $LOG_FILE_TEMP)
	    if [ -n "$records" ];then
	        boards_used[n]=$boardno
	        let n=n+1
	    fi
	done

	############## To parse max session time, total using time, total time and rating usage from log file ###############################
	for boardno in ${boards_used[*]}
	do
	    records=$(grep -w "boardno:${boardno}" $LOG_FILE_TEMP)

	    usr=$(echo -e "$records" | grep -Po "(?<=usr:)([^ ]+)" | awk '{a[$0]++} END {for(i in a) printf("over past week, %10s use-->%-3s times\n"), i, a[i]}' | sort)
	    echo "==================================================="
	    echo -e "boardno:$boardno\n${usr}"

	    max_session_time=$(echo -e "$records" | grep -Po "(?<=session_time:)([^ ]+)" |awk 'BEGIN {max = 0} {if ($1+0 > max+0) max=$1} END {print max}')
	    echo "max session time:${max_session_time}s"

	    total_using_time=$(echo -e "$records" | grep -Po "(?<=session_time:)([^ ]+)" |awk 'BEGIN {total_using_time = 0} {total_using_time += $1} END {print total_using_time}')

	    echo "total using time:${total_using_time}s"
	    echo "total time:${total_time}s"
	    echo -n "rating:"
	    echo "$total_using_time $total_time" | awk '{printf ("%.2f\n",$1/$2)}'
	done
}

