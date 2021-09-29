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
		--style=allman \
		\
		--indent=force-tab=8 \
		\
		--indent-classes \
		--indent-switches \
		--indent-after-parens \
		--indent-preproc-define \
		--max-instatement-indent=80 \
		\
		--pad-oper \
		--pad-comma \
		--pad-header \
		--unpad-paren \
		--align-pointer=name \
		\
		--break-one-line-headers \
		--attach-return-type-decl \
		--keep-one-line-blocks \
		--keep-one-line-statements \
		\
		--pad-param-type \
		\
		--suffix=none \
		--verbose \
		--formatted \
		--lineend=linux \
		\
		$file
done
