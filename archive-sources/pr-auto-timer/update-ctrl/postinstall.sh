#!/bin/sh

CP=/bin/cp
WGET=/bin/wget
RM=/bin/rm

if [ ! -e /var/tuxbox/config/pr-auto-timer.conf ]; then
	$CP /var/tuxbox/config/pr-auto-timer.conf.template /var/tuxbox/config/pr-auto-timer.conf
fi

if [ ! -e /var/tuxbox/config/pr-auto-timer.rules ]; then
	$CP /var/tuxbox/config/pr-auto-timer.rules.template /var/tuxbox/config/pr-auto-timer.rules
fi

if [ ! -e /var/tuxbox/config/auto-record-cleaner.conf ]; then
	$CP /var/tuxbox/config/auto-record-cleaner.conf.template /var/tuxbox/config/auto-record-cleaner.conf
fi

if [ ! -e /var/tuxbox/config/auto-record-cleaner.rules ]; then
	$CP /var/tuxbox/config/auto-record-cleaner.rules.template /var/tuxbox/config/auto-record-cleaner.rules
fi

$WGET -q -O - "http://localhost/control/message?popup=Auto-Timer%20installiert."
$WGET -q -O - "http://localhost/control/reloadplugins"

$RM -f /tmp/pr-auto-timer_*.bin
