#!/bin/bash
#
# clone or pull an existing git repository
#
# (C) 2019 vanhofen
# License: WTFPLv2
#
# parameters:
# * git URL
# * destination directory
#
GIT_URL="$1"
DEST="$2"

# exit on error
set -e

if [ -d $DEST ]; then
	cd $DEST
		git pull || true
else
	git clone $GIT_URL $DEST
fi
