#!/bin/sh

. /etc/init.d/globals

SHOWINFO "start update of var-partition"

VARDEV=`grep -i var /proc/mtd | cut -f 0 -s -d :`

if [ -z $VARDEV ]; then
	SHOWINFO "no var-partition found"
else
	if [ ! -d /var_init ]; then
		SHOWINFO "rename /var to /var_init"
		mv /var /var_init
	fi
	if [ ! -d /var ]; then
		SHOWINFO "create /var"
		mkdir /var
	fi
	if [ -f /var_init/etc/.reset ]; then
		SHOWINFO "factory reset."
		SHOWINFO "erase var-partition /dev/$VARDEV"
		rm /var_init/etc/.reset
		flash_erase /dev/$VARDEV 0 0
	fi

	VARBLOCK=`grep -i var /proc/mtd | cut -b 4`
	SHOWINFO "try to mount /dev/mtdblock$VARBLOCK to /var"
	mount -t jffs2 /dev/mtdblock$VARBLOCK /var
	if [ $? != 0 ]; then
		SHOWINFO "erase var-partition /dev/$VARDEV"
		flash_erase /dev/$VARDEV 0 0
		SHOWINFO "try to mount /dev/mtdblock$VARBLOCK to /var"
		mount -t jffs2 /dev/mtdblock$VARBLOCK /var
	fi
	if [ $? != 0 ]; then
		SHOWINFO "failed to mount /var"
		rmdir /var && mv /var_init /var
	else
		if ! grep -q "neutrino-images" /var/etc/update.urls; then
			SHOWINFO "Seems not to be NI. Initializing factory reset..."
			SHOWINFO "unmount var-partition..."
			umount -lf /dev/mtdblock$VARBLOCK
			SHOWINFO "erase var-partition /dev/$VARDEV"
			flash_erase /dev/$VARDEV 0 0
			SHOWINFO "mount /dev/mtdblock$VARBLOCK to /var"
			mount -t jffs2 /dev/mtdblock$VARBLOCK /var
		fi
		if [ ! -d /var/tuxbox ]; then
			rm -f /var_init/etc/.newimage
			cp -a /var_init/* /var/
		fi
		if [ ! -f /var/etc/network/interfaces ]; then
			cp -a /var_init/etc /var/
		fi
		if [ -f /var_init/etc/.newimage ]; then
			rm -f /var_init/etc/.newimage
			cp -f /var_init/tuxbox/config/cables.xml /var/tuxbox/config/cables.xml
			cp -f /var_init/tuxbox/config/satellites.xml /var/tuxbox/config/satellites.xml
			cp -f /var_init/tuxbox/config/terrestrial.xml /var/tuxbox/config/terrestrial.xml
			cp -f /var_init/tuxbox/config/encoding.conf /var/tuxbox/config/encoding.conf
			cp -f /var_init/tuxbox/config/providermap.xml /var/tuxbox/config/providermap.xml
			cp -f /var_init/tuxbox/config/rssreader.conf /var/tuxbox/config/rssreader.conf
			cp -f /var_init/tuxbox/config/shellexec.conf /var/tuxbox/config/shellexec.conf
			cp -f /var_init/etc/passwd /var/etc/passwd
		fi
	fi
fi
