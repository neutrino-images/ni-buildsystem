#!/bin/sh

. /etc/init.d/globals

SHOWINFO "force some symlinks from var-partition"

ln -sf /var/etc/exports /etc/exports
ln -sf /var/etc/hostname /etc/hostname
ln -sf /var/etc/passwd /etc/passwd
ln -sf /var/etc/resolv.conf /etc/resolv.conf
ln -sf /var/etc/wpa_supplicant.conf /etc/wpa_supplicant.conf
ln -sf /var/etc/network/interfaces /etc/network/interfaces

SHOWINFO "start update of var-partition"

# do always upgrade update.urls
cp -a /var_init/etc/update.urls /var/etc/update.urls
# and migration.sh too
cp -a /var_init/tuxbox/config/migration.sh /var/tuxbox/config/migration.sh

# cleanup (remove me in the future...)
rm -f /var/etc/.cooliptv

# cleanup my mess...
rm -f /var/etc/passwd-
rm -f /var/etc/shadow-
rm -f /var/etc/shadow

# cleanup
rm -f /var/etc/localtime && cp /var_init/etc/localtime /var/etc
rm -f /var/etc/interfaces

SHOWINFO "add some new files to var-partition"

mkdir -p /var/root

# autofs
if [ ! -e /var/etc/auto.master ]; then
	cp -a /var_init/etc/auto.master /var/etc/auto.master
fi
if [ ! -e /var/etc/auto.net ]; then
	cp -a /var_init/etc/auto.net /var/etc/auto.net
fi

if [ ! -e /var/tuxbox/config/rssreader.conf ]; then
	cp -a /var_init/tuxbox/config/rssreader.conf /var/tuxbox/config/rssreader.conf
fi
if [ ! -e /var/tuxbox/config/shellexec.conf ]; then
	cp -a /var_init/tuxbox/config/shellexec.conf /var/tuxbox/config/shellexec.conf
fi
if [ ! -e /var/tuxbox/config/webtv_usr.xml ]; then
	cp -a /var_init/tuxbox/config/webtv_usr.xml /var/tuxbox/config/webtv_usr.xml
fi
if [ ! -e /var/tuxbox/config/webradio_usr.xml ]; then
	cp -a /var_init/tuxbox/config/webradio_usr.xml /var/tuxbox/config/webradio_usr.xml
fi
if [ ! -e /var/tuxbox/config/myservices.xml ]; then
	cp -a /var_init/tuxbox/config/myservices.xml /var/tuxbox/config/myservices.xml
fi
if [ ! -e /var/etc/inadyn.conf ]; then
	cp -a /var_init/etc/inadyn.conf /var/etc/inadyn.conf
fi

mkdir -p /var/xupnpd
for f in cfg feeds playlist; do
	if [ ! -e /var/xupnpd/xupnpd_${f}.lua ]; then
		cp -a /var_init/xupnpd/xupnpd_${f}.lua /var/xupnpd
	fi
done

# force new root default password "ni" as of 29.06.2017
grep "root::0:0::" /var/etc/passwd && cp -af /var_init/etc/passwd /var/etc/passwd

# change shell for root
sed -i '/^root/ s:/bin/bash:/bin/sh:g' /var/etc/passwd
cd /var/root
test -e .bash_history && mv .bash_history .ash_history

SHOWINFO "done"
mv $0 $0.done
