#!/bin/sh

CERTSCONF=/etc/ca-certificates.conf
CERTSDIR=/share/ca-certificates

rm -f $CERTSCONF

subdirs="$(ls -1 $CERTSDIR)"
for subdir in $subdirs; do
	certs="$(ls -1 $CERTSDIR/$subdir)"
	for cert in $certs; do
		echo "add $subdir/$cert"
		echo "$subdir/$cert" >> $CERTSCONF
	done
done
