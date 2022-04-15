#!/bin/sh

. /etc/init.d/globals

SHOWINFO "force some symlinks from var-partition"

SYMLINKS=" \
	/etc/exports \
	/etc/hostname \
	/etc/passwd \
	/etc/resolv.conf \
	/etc/wpa_supplicant.conf \
	/etc/network/interfaces \
"

for s in $SYMLINKS; do
	ln -sf /var${s} ${s}
done

SHOWINFO "start update of var-partition"

FORCE_FILES=" \
	/var/etc/update.urls \
	/var/tuxbox/config/migration.sh \
"
for f in $FORCE_FILES; do
	cp -a ${f//\/var/\/var_init} ${f}
done

SHOWINFO "add some new dirs and files to var-partition"

NEW_DIRS=" \
	/var/root \
	/var/etc/sysctl.d \
"
mkdir -p $NEW_DIRS

NEW_FILES=" \
	/var/etc/auto.master \
	/var/etc/auto.net \
	/var/etc/inadyn.conf \
	/var/etc/profile.local \
	/var/etc/rc.local \
	/var/tuxbox/config/myservices.xml \
	/var/tuxbox/config/rssreader.conf \
	/var/tuxbox/config/shellexec.conf \
	/var/tuxbox/config/webradio_usr.xml \
	/var/tuxbox/config/webtv_usr.xml \
	/var/xupnpd/xupnpd_cfg.lua \
	/var/xupnpd/xupnpd_feeds.lua \
	/var/xupnpd/xupnpd_playlist.lua \
"
for f in $NEW_FILES; do
	if [ ! -e ${f} ]; then
		mkdir -p $(dirname ${f})
		cp -a ${f//\/var/\/var_init} ${f}
	fi
done

SHOWINFO "done"
mv $0 $0.done
