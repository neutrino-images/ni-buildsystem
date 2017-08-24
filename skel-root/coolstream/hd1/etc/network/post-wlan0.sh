#!/bin/sh

echo Stopping wlan0

/sbin/wpa_cli terminate
sleep 2
