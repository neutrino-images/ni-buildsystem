#!/bin/bash
#
# get a specified hg version as tarball
#
# (C) 2022 vanhofen
# License: WTFPLv2
#
# parameters:
# * hg URL
# * hg tag/tree-ish to archive
# * archive name (.tar.bz2 will be stripped off)
# * archive/download directory
#
# *** no matter the archive name, it will always be compressed with bzip2 ***
#
HG_URL="$1"
HG_TAG="$2"
TAR_NAME="$3"
ARCHIVE="$4"
test -z "$ARCHIVE" && ARCHIVE="$PWD"

TAR_PATH=${TAR_NAME%.tar*}

DIR=$(mktemp -d $PWD/hg_archive.XXXXXX)
# clean up at exit
trap "rm -rf $DIR" EXIT
# exit on error
set -e
hg clone $HG_URL $DIR
cd $DIR
hg archive -o $TAR_PATH.tar --prefix=$TAR_PATH/ $HG_TAG
bzip2 $TAR_PATH.tar
mv $TAR_PATH.tar.bz2 $ARCHIVE/
# exit trap cleans up...
