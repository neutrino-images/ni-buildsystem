#!/bin/bash
#
# clone or pull an existing hg repository
#
# (C) 2022 vanhofen
# License: WTFPLv2
#
# parameters:
# * hg URL
# * destination directory
#
HG_URL="$1"
DEST="$2"

# exit on error
set -e

if [ -d $DEST ]; then
	cd $DEST
		hg pull || true
else
	hg clone $HG_URL $DEST
fi
