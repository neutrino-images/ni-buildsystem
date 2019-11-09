#!/bin/sh

. /etc/init.d/globals

DO_REBOOT=0

if [ -e /etc/init.d/stb_update.data ]; then
	. /etc/init.d/stb_update.data 2> /dev/null
fi

if [ -e /var/etc/.stb_update ]; then
	rm /var/etc/.stb_update
	# force an update with a bogus date
	V_KERNEL="Sun Jan 1 00:00:00 CET 2042"
fi

if [ -f /var/update/zImage ]; then
	DEV=`grep -i kernel /proc/mtd | cut -f 0 -s -d :`
	grep -q "$V_KERNEL" /proc/version
	if [ $? == 1 ]; then
		test -e /dev/display && dt -t"Kernel Update. Please wait..."
		SHOWINFO "Updating kernel on device $DEV ..."
		flash_erase /dev/$DEV 0 0 && cat /var/update/zImage > /dev/$DEV
		test -e /dev/display && dt -t"Update OK. Reboot!"
		SHOWINFO "Kernel update on device $DEV successful. reboot!"
		DO_REBOOT=1
	else
		SHOWINFO "Kernel already up-to-date"
	fi
	rm -f /var/update/zImage
fi

if [ $DO_REBOOT == 1 ]; then
	SHOWINFO "Reboot ..."
	sync
	sleep 2
	reboot -f
fi
