#!/bin/bash
#
# get a specified git version as tarball
#
# (C) 2013 Stefan Seyfried
# License: WTFPLv2
#
# parameters:
# * git URL
# * git tag/tree-ish to archive
# * archive name (.tar.bz2 will be stripped off)
# * archive/download directory
#
# *** no matter the archive name, it will always be compressed with bzip2 ***
#
GIT_URL="$1"
GIT_TAG="$2"
TAR_NAME="$3"
ARCHIVE="$4"
test -z "$ARCHIVE" && ARCHIVE="$PWD"

TAR_PATH=${TAR_NAME%.tar*}

DIR=$(mktemp -d $PWD/git_archive.XXXXXX)
# clean up at exit
trap "rm -rf $DIR" EXIT
# exit on error
set -e
git clone $GIT_URL $DIR
cd $DIR
git archive -o $TAR_PATH.tar --prefix=$TAR_PATH/ $GIT_TAG
bzip2 $TAR_PATH.tar
mv $TAR_PATH.tar.bz2 $ARCHIVE/
# exit trap cleans up...
