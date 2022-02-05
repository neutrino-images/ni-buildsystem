#!/bin/sh
sleep 3
sync
if [ -e /var/tuxbox/config/zapit/ubouquets.xml.org ]; then
	mv -f /var/tuxbox/config/zapit/ubouquets.xml.org /var/tuxbox/config/zapit/ubouquets.xml
fi
pzapit -c
