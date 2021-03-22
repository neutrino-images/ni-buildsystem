#!/bin/bash
#
# move files/dirs from TARGET_DIR to REMOVE_DIR
#
# (C) 2021 vanhofen
# License: WTFPLv2
#
# parameters:
# * TARGET_DIR (absolute path)
# * REMOVE_DIR (subdir inside TARGET_DIR)
# * file(s) or dir(s) to remove (*must* be located inside TARGET_DIR)

TARGET_DIR="$1"
REMOVE_DIR=$(echo $2 | sed -e 's/^\///') # remove leading slash
shift 2

# exit on error
set -e

cd ${TARGET_DIR}
for r in $@; do
	r=${r//${TARGET_DIR}\//}
	mkdir -p $(dirname ${REMOVE_DIR}/${r})
	mv -v ${r} ${REMOVE_DIR}/${r} || true
done
