#!/bin/sh

. /etc/init.d/globals

SHOWINFO "Starting wlan0"

/sbin/wpa_cli terminate
sleep 2

/sbin/wpa_supplicant -D wext -c /etc/wpa_supplicant.conf -B -i wlan0
sleep 8
