#!/bin/bash

bp3_find() {
	if ls /dev/mmc* 1> /dev/null 2>&1 && for f in /dev/mmcblk?; do sgdisk -p $f | grep $1; done 1> /dev/null 2>&1 ; then
		export bp3=($(for f in /dev/mmcblk?; do sgdisk -p $f | grep $1; done))
		export part=$(ls /dev/mmcblk*p$bp3)
	elif grep $1 /sys/class/mtd/mtd*/name 1> /dev/null 2>&1 ; then
		export bp3=$(dirname `grep $1 /sys/class/mtd/mtd*/name`)
		export part=/dev/$(ls $bp3 | grep mtd)
	else
		unset bp3
		unset part
		return 1
	fi
	return 0
}

bp3_mkfs() {
	mke2fs $part > /dev/null 2>&1
	tune2fs -m 0 $part > /dev/null 2>&1
	mount $part /mnt/$1
}

bp3_mount() {
	bp3_find $1
	mount | grep /mnt/$1 > /dev/null 2>&1
	if [ "$?" = "0" ]; then
		return 1 # already exists and mounted
	fi
	mkdir -p /mnt/$1
	mount $part /mnt/$1
	if [ "$?" = "0" ]; then
		return 1 # already exists
	fi
	bp3_mkfs $1
	return 0
}

bp3_israw() {
	bp3_find $1
	export ver=$(dd if=$part bs=1 count=4)
	if [ "$ver" = "BP30" ]; then
		export md5=$(dd if=$part bs=1 skip=4 count=32)
		export bp3_size=$(echo `dd if=$part bs=1 skip=36 count=8`)
		export cal=($(dd if=$part bs=1 skip=44 count=$bp3_size | md5sum))
		if [ "$md5" = "$cal" ]; then
			dd if=$part of=bp3.bin bs=1 skip=44 count=$bp3_size
			return 0
		else
			echo "MD5 of bp3.bin in flash $1 doesn't match"
			return 2
		fi
	else
		# check if file system exists
		mount | grep /mnt/$1 > /dev/null 2>&1
		if [ "$?" != "0" ]; then
			mkdir -p /mnt/$1
			mount -r $part /mnt/$1
			if [ "$?" != "0" ]; then
				# old format, no version, 9 bytes size
				export bp3_size=$(echo `dd if=$part bs=9 count=1`)
				dd if=$part of=bp3.bin bs=1 skip=9 count=$bp3_size
			else
				umount $part
			fi
		fi
		return 0
	fi
}

bp3_backup() {
	if [ -e $1 -a ! -h $1 ]; then
		cp $1 /mnt/bp30
		mv $1 /mnt/bp31
		ln -sf /mnt/bp30/$1 $1
		return 0
	fi
	return 1
}

bp3_restore() {
	if [ -e /mnt/bp31/$1 ]; then
		cp /mnt/bp31/$1 /mnt/bp30
		ln -sf /mnt/bp30/$1 $1
	fi
}

bp3_relink() {
	if [ -e /mnt/$1/$2 -a ! -h $2 ]; then
		ln -sf /mnt/$1/$2 $2
	fi
}

bp3_remount() {
	umount /mnt/bp31
}

bp3_main() {
	bp3_find bp30
	if [ "$?" != "0" ]; then
		exit 1
	fi

	# restore bp3.bin from raw partition
	if [ ! -h bp3.bin -a ! -e bp3.bin ]; then
		bp3_israw bp30
		if [ "$?" != "0" ]; then
			bp3_israw bp31
		fi
	fi

	bp3_mount bp30
	local exists=$?
	if [ "$exists" = "1" ]; then
		umount /mnt/bp30
		e2fsck -p $part > /dev/null 2>&1
		if [ "$?" != "0" ]; then
			bp3_mkfs bp30
			exists=0
		else
			bp3_mount bp30
			exists=$?
			if [ -e bp3.bin -a ! -h bp3.bin ] || [ -e pak.bin -a ! -h pak.bin ] || [ -e drm.bin -a ! -h drm.bin ]; then
				# new bin file found
				bp3_find bp31
				mount $part /mnt/bp31
				bp3_backup bp3.bin
				bp3_backup pak.bin
				bp3_backup drm.bin
				bp3_remount
			fi
		fi
	fi

	if [ "$exists" = "0" ]; then
		# bp30 file system is newly created
		bp3_mount bp31
		if [ "$?" = "0" ]; then
			# bp31 also newly created
			bp3_backup bp3.bin
			bp3_backup pak.bin
			bp3_backup drm.bin
		else
			bp3_restore bp3.bin
			bp3_restore pak.bin
			bp3_restore drm.bin
		fi
		bp3_remount
	else
		mount | grep /mnt/bp30 > /dev/null 2>&1
		if [ "$?" = "0" ]; then
			bp3_relink bp30 bp3.bin
			bp3_relink bp30 pak.bin
			bp3_relink bp30 drm.bin
		else
			echo "bp30 partition is bad. Consider replacing flash asap!"
			bp3_mount bp31
			bp3_relink bp31 bp3.bin
			bp3_relink bp31 pak.bin
			bp3_relink bp31 drm.bin
		fi
	fi
}

if [ "$1" != "--" ]; then
	# -- internal mode, used for sourcing in nexus.bp3
	bp3_main
fi
