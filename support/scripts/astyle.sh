#!/bin/sh
#
# astyle.sh - Formatting source code using astyle
#
# Copyright (C) 2018 Sven Hoefer <svenhoefer@svenhoefer.com>
# License: WTFPLv2
#

usage() {
	echo "Usage: astyle.sh <source-file.cpp> <source-file.h> ..."
}

test "$1" == "--help"	&& { usage; exit 0; }
test -z "$1"		&& { usage; exit 1; }

type astyle >/dev/null 2>&1 || { echo >&2 "Astyle required, but it's not installed. Aborting."; exit 1; }

for file in $@; do
	astyle \
		--suffix=none \
		--style=allman \
		--formatted -v \
		\
		--indent=force-tab=8 \
		--indent-classes \
		--indent-preproc-define \
		--indent-switches \
		--max-instatement-indent=80 \
		--lineend=linux \
		\
		--unpad-paren \
		\
		--pad-oper \
		--pad-header \
		\
		--align-pointer=name \
		\
		$file
done
