#!/bin/sh
LOG="logger -p user.info -t mdev-wlan"
WARN="logger -p user.warn -t mdev-wlan"

case "$ACTION" in
	add|"")
		if [ -s /etc/wpa_supplicant.conf ]; then
			$LOG "trying to bring $MDEV up"
			ifup $MDEV
		else
			$WARN "/etc/wpa_supplicant.conf missing or empty, not trying to bring $MDEV up"
		fi
		;;
	remove)
		$LOG "trying to bring $MDEV down"
		ifdown $MDEV
		;;
esac
