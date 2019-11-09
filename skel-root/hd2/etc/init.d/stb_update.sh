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
	V_UBOOT="Sun Jan 01 2042  - 00:00:00"
	V_ULDR="Sun Jan 01 2042 00:00:00"
fi

if [ -f /var/update/vmlinux.ub.gz ]; then
	DEV=`grep -i kernel /proc/mtd | cut -f 0 -s -d :`
	grep -q "$V_KERNEL" /proc/version
	if [ $? == 1 ]; then
		SHOWINFO "Updating kernel on device $DEV ..."
		flash_erase /dev/$DEV 0 0 && cat /var/update/vmlinux.ub.gz > /dev/$DEV
		DO_REBOOT=1
	else
		SHOWINFO "Kernel already up-to-date"
	fi
	rm /var/update/vmlinux.ub.gz
fi

if [ -f /var/update/u-boot.bin ]; then
	DEV=`grep -i u-boot /proc/mtd | cut -f 0 -s -d :`
	SHOWINFO "This sucks..."
	SHOWINFO "Updating u-boot on device $DEV ..."
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
	SHOWINFO "This sucks..."
	SHOWINFO "Updating microloader on device $DEV ..."
	flash_erase /dev/$DEV 0 0 && cat /var/update/uldr.bin > /dev/$DEV
	DO_REBOOT=1
	rm /var/update/uldr.bin
fi

if [ $DO_REBOOT == 1 ]; then
	SHOWINFO "Reboot ..."
	sync
	sleep 2
	reboot -f
fi
