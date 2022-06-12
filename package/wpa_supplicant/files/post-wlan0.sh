#!/bin/sh

. /etc/init.d/globals

SHOWINFO "Stopping wlan0"

/usr/sbin/wpa_cli terminate
sleep 2

ifconfig eth0 up
sleep 2
