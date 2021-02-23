#!/bin/bash
#
# checkout or update an existing svn repository
#
# (C) 2019 vanhofen
# License: WTFPLv2
#
# parameters:
# * svn URL
# * destination directory
#
SVN_URL="$1"
DEST="$2"

# exit on error
set -e

if [ -d $DEST ]; then
	cd $DEST
		svn update || true
else
	svn checkout $SVN_URL $DEST
fi
