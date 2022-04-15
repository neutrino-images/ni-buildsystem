#!/bin/sh

. /etc/init.d/globals

# install correct yWeb style
cd /usr/share/tuxbox/neutrino/httpd/scripts/ && ./Y_Tools.sh style_set

#rm -f /etc/init.d/sys_update.sh
