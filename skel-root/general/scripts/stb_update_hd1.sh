#!/bin/sh

. /etc/init.d/globals

DO_REBOOT=0

if [ -f /var/update/zImage ]; then
	DEV=`grep -i kernel /proc/mtd | cut -f 0 -s -d :`
	test -e /dev/display && dt -t"Kernel Update. Please wait ..."
	SHOWINFO "Updating kernel on device $DEV ..."
	flash_erase /dev/$DEV 0 0 && cat /var/update/zImage > /dev/$DEV
	test -e /dev/display && dt -t"Kernel Update OK."
	SHOWINFO "Kernel update on device $DEV successful."
	DO_REBOOT=1
	rm -f /var/update/zImage
fi

if [ $DO_REBOOT == 1 ]; then
	sync
	sleep 2
	test -e /dev/display && dt -t"Reboot"
	SHOWINFO "Reboot ..."
	reboot -f
fi
