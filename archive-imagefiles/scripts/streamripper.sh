#!/bin/sh

. /etc/init.d/globals

usage() {
	echo "[${BASENAME}] Usage: $0 {start [url]|stop}"
}

case $1 in
	start)
		if [ $# -ne 2 ]; then
			usage
			exit 1
		fi
		streamripper "${2}" -a -s -d "$(get_setting network_nfs_streamripperdir)" &
	;;
	stop)
		killall streamripper
	;;
	*)
		usage
	;;
esac
