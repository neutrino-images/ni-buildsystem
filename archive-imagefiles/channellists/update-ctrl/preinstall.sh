#!/bin/sh
if [ -e /var/tuxbox/config/zapit/ubouquets.xml ]; then
	/bin/msgbox title="Kanallisten-Update" msg="~s~n~c~YEigene ubouquets.xml ~uberschreiben?" select="Ja,Nein" default=2
	if [ ${?} == 2 ]; then
		mv /var/tuxbox/config/zapit/ubouquets.xml /var/tuxbox/config/zapit/ubouquets.xml.org
		echo "### move ubouquets.xml ###"
	fi
fi
