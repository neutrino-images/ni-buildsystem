#!/bin/sh

. /etc/init.d/globals

DO_REBOOT=0

if [ -f /var/update/vmlinux.ub.gz ]; then
	DEV=`grep -i kernel /proc/mtd | cut -f 0 -s -d :`
	test -e /dev/display && dt -t"Kernel Update. Please wait ..."
	SHOWINFO "Updating kernel on device $DEV ..."
	flash_erase /dev/$DEV 0 0 && cat /var/update/vmlinux.ub.gz > /dev/$DEV
	test -e /dev/display && dt -t"Kernel Update OK."
	SHOWINFO "Kernel update on device $DEV successful."
	DO_REBOOT=1
	rm /var/update/vmlinux.ub.gz
fi

if [ -f /var/update/u-boot.bin ]; then
	DEV=`grep -i u-boot /proc/mtd | cut -f 0 -s -d :`
	flash_erase /dev/$DEV 0 0 && cat /var/update/u-boot.bin > /dev/$DEV
	DO_REBOOT=1
	rm /var/update/u-boot.bin

	ENVDEV=`grep -i env /proc/mtd | cut -f 0 -s -d :`
	VARDEV=`grep -i var /proc/mtd | cut -f 0 -s -d :`
	if [ -z $VARDEV ]; then
		SHOWINFO "No var partition found, erasing env in /dev/$ENVDEV ..."
		flash_erase /dev/$ENVDEV 0 0
		DO_REBOOT=1
	fi
	KERNEL_VERSION=`cat /proc/version | cut -f 3 -d " "`
	if [ ! -d /lib/modules/$KERNEL_VERSION ]; then
		SHOWINFO "Different kernel version $KERNEL_VERSION found, erasing env in /dev/$ENVDEV ..."
		flash_erase /dev/$ENVDEV 0 0
		DO_REBOOT=1
	fi
fi

if [ -f /var/update/uldr.bin ]; then
	DEV=`grep -i uldr /proc/mtd | cut -f 0 -s -d :`
	flash_erase /dev/$DEV 0 0 && cat /var/update/uldr.bin > /dev/$DEV
	DO_REBOOT=1
	rm /var/update/uldr.bin
fi

if [ $DO_REBOOT == 1 ]; then
	sync
	sleep 2
	test -e /dev/display && dt -t"Reboot"
	SHOWINFO "Reboot ..."
	reboot -f
fi
