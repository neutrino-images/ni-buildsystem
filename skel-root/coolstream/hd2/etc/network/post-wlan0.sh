#!/bin/sh

. /etc/init.d/globals

SHOWINFO "Stopping wlan0"

/sbin/wpa_cli terminate
sleep 2
