#!/bin/sh
#
# (c) 2014 by zzzZZ for NI

PROG=$(basename $0)
devices="/tmp/devices.txt"
MOUNTBASE=/media

mountedevices() {
	sleep $1
	mdev -s
}

search4devices() {
test -e $devices && rm $devices
echo "$(mount | grep -E "/dev/sd|/dev/sr|/dev/mmcblk" | cut -d" " -f1,2,3)" > $devices.tmp 

while read line
do
	test "${line:0:1}" = "" && continue
	BLKID=$(blkid $(echo $line | cut -d" " -f1))
	eval ${BLKID#*:}
	echo "$line type $TYPE ($LABEL)," >> $devices
done < $devices.tmp
rm $devices.tmp

echo "~GSuche und Mounte neue Devices" >> $devices
}

device="firstrun"
while [ "$device" != "" ]; do
	(msgbox title="Mountpoints verwalten" popup="~cSuche Mountpoints..." cyclic=0) &
	search4devices
	killall msgbox
	device=$(msgbox title="Mountpoints verwalten" msg="~cVerf~ugbare Mountpoints" order=1 select="$(cat $devices)" echo=1)
	if [ "$device" != "" ]; then
		if [ "$(echo $device | cut -d" " -f1)" = "~GSuche" ]; then
			(msgbox popup="~cSuche nach neuen Devices. Bitte warten..." timeout=60 cyclic=0) &
			mountedevices 0
			#msgbox msg="~cSuche beendet." timeout=3
			killall msgbox
		else
			if [ "$(msgbox title="Best~atigung" msg="Mountpoint $(echo $device | cut -d" " -f3) aush~angen?" select="ja,nein" default=2 echo=1)" == "ja" ]; then
				(msgbox popup="~cbitte warten..." cyclic=0) &
				sync; sleep 3
				umount $(echo $device | cut -d" " -f3)
				rc=$?
				killall msgbox
				if [ "$rc" != "0" ]; then
					msgbox msg="Fehler beim umount. RC:$rc" timeout=10
				else
					rmdir $(echo $device | cut -d" " -f3)
					OLDPWD=$PWD
					cd $MOUNTBASE
					for i in *; do
						[ -L "$i" ] || continue
						TARGET=$(readlink "$i")
						if echo $device | cut -d" " -f3 | grep -E $TARGET > /dev/null; then
							rm "$i"
						fi
					done
					cd $OLDPWD
			
					if echo $device | grep -E "/dev/sr"; then
						if [ "$(msgbox title="Best~atigung" msg="Umount erfolgreich. ~nMedium auswerfen?" select="ja,nein" default=1 echo=1)" == "ja" ]; then
							eject -T $(echo $device | cut -d" " -f1)
							if [ "$(msgbox title="Best~atigung" msg="Schublade wieder schlie~zen und remount durchf~uhren?" select="ja,nein" default=1 echo=1)" == "ja" ]; then
								eject -t $(echo $device | cut -d" " -f1)
								mountedevices 10 &	#10 Sekunden sleep vor mdev sollte fuer das Laufwerk wohl reichen
								msgbox msg="~cVersuche $(echo $device | cut -d" " -f3) erneut zu mounten." timeout=3
							fi
						fi
					else
						msgbox msg="~cUmount erfolgreich." timeout=3
					fi
			
				fi
			fi
		fi
	fi
done

test -e $devices && rm $devices
