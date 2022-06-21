#!/bin/bash

version=5.1.8
url=https://mirrors.edge.kernel.org/pub/linux/daemons/autofs/v5/patches-5.1.9

cd patches
wget -N $url/patch_order_$version
i=0
cat patch_order_$version | while read p; do 
	case "$p" in 
		*.patch)
			i=$((i+1))
			t=$(printf "%04d\n" $i)-$p
			if [ ! -f $t ]; then
				wget -O $t $url/$p
			fi
		;;
	esac
done
