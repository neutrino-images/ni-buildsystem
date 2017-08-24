#!/bin/sh

CONFIGDIR="/var/tuxbox/config"
nhttpd=${CONFIGDIR}"/nhttpd.conf"

htauth=$(grep "^mod_auth.authenticate"	$nhttpd | cut -d"=" -f2)
htuser=$(grep "^mod_auth.username"	$nhttpd | cut -d"=" -f2)
htpass=$(grep "^mod_auth.password"	$nhttpd | cut -d"=" -f2)
htport=$(grep "^WebsiteMain.port"	$nhttpd | cut -d"=" -f2)
if [ "$htauth" = "true" ]
then
	hturl="http://$htuser:$htpass@127.0.0.1:$htport"
else
	hturl="http://127.0.0.1:$htport"
fi

if [ $(wget -q -O - "$hturl/control/setmode?status" | sed 's/\r$//') = "on" ]
then
	echo "[${0##*/}] record in progress; delay reboot"
	new_alarm=$(($(date +%s)+300))
	wget -q -O - "$hturl//control/timer?action=new&type=8&alarm=${new_alarm}&PluginName=autoreboot"
	exit
fi

if [ $(wget -q -O - "$hturl/control/standby" | sed 's/\r$//') = "off" ]
then
	wget -q -O - "$hturl/control/standby?on"
	echo ""
	sleep 20
fi

echo "[${0##*/}] will reboot now"
(sleep 1; reboot) &
