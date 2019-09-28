#!/bin/sh

. /etc/init.d/globals

grep "Sat Jun 24 19:32:15 CEST 2017" /proc/version > /dev/null
if [ $? == 1 ]; then
	DEV=`grep -i kernel /proc/mtd | cut -f 0 -s -d :`
	test -e /dev/display && dt -t"Kernel Update. Please wait..."
	SHOWINFO "Updating kernel on device $DEV ..."
	flash_erase /dev/$DEV 0 0 && cat /var/update/zImage > /dev/$DEV
	test -e /dev/display && dt -t"Update OK. reboot!"
	SHOWINFO "Kernel update on device $DEV successful. reboot!"
	rm -f /var/update/zImage && rm -f /etc/init.d/stb_update.sh && reboot -f
else
	SHOWINFO "Kernel already up-to-date"
	rm -f /var/update/zImage && rm -f /etc/init.d/stb_update.sh
fi
