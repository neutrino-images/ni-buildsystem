#!/bin/sh
LOG="/bin/logger -p user.info -t mdev-usb"
WARN="/bin/logger -p user.warn -t mdev-usb"

flagLCD=/tmp/.lcd-${MDEV}

# supported dpf-devices
DPF="1908:0102"

# supported spf-devices
SPFstorage="04E8:200A 04E8:200E 04E8:200C 04E8:2012 04E8:2016 04E8:2025 04E8:2033 04E8:201C 04E8:2027 04E8:2035 04E8:204F 04E8:2039"
SPFmonitor="04E8:200B 04E8:200F 04E8:200D 04E8:2013 04E8:2017 04E8:2026 04E8:2034 04E8:201B 04E8:2028 04E8:2036 04E8:2050 04E8:2040"
# SPFmodel: ^SPF-72H  ^SPF-75H  ^SPF-83H  ^SPF-85H  ^SPF-85P  ^SPF-87H  ^SPF-87H  ^SPF-105P ^SPF-107H ^SPF-107H ^SPF-700T ^SPF-1000P
# SPFmodel:           ^SPF-76H            ^SPF-86H  ^SPF-86P   old                                     new
SPF="${SPFstorage} ${SPFmonitor}"

DEVICES="${DPF} ${SPF}"
for DEVICE in ${DEVICES}; do
	V=$(echo ${DEVICE:0:4} | sed 's/^[0]*//' | tr [:upper:] [:lower:]) # lower case vendor  w/o leading zeros
	P=$(echo ${DEVICE:5:4} | sed 's/^[0]*//' | tr [:upper:] [:lower:]) # lower case product w/o leading zeros

	case "$ACTION" in
		add|"")
			#$LOG "trying to process ${DEVICE} (V:{$V} P:{$P}) on ${MDEV}"

			uevent=/sys/class/usb_device/${MDEV}/device/uevent

			test -e $uevent					|| continue
			grep "^PRODUCT=${V}/${P}/*" $uevent >/dev/null	|| continue

			$LOG "supported device (ID ${DEVICE}) on ${MDEV} found"

			# dpf/spf-support
			if $(echo "${DPF} ${SPF}" | grep -q "${DEVICE}"); then
				$LOG "creating flagfile '$flagLCD'"
				echo "${DEVICE}" > $flagLCD

				if $(echo "${DPF} ${SPFstorage}" | grep -q "${DEVICE}"); then
					$LOG "DPF or SPF in storage mode found"
					$LOG "(re)starting lcd4linux"

					service lcd4linux restart
				fi

				if $(echo "${SPFmonitor}" | grep -q "${DEVICE}"); then
					$LOG "SPF in monitor mode found"
					if [ -e /tmp/lcd4linux.pid ]; then
						$LOG "do nothing"
					else
						$LOG "(re)starting lcd4linux"
						service lcd4linux restart
					fi
				fi
			fi
		;;
		remove)
			#$LOG "trying to process ${DEVICE} (V:{$V} P:{$P}) on ${MDEV}"

			# dpf/spf-support
			if [ -e $flagLCD ]; then
				grep "^${DEVICE}" $flagLCD >/dev/null	|| continue

				$LOG "supported DPF/SPF (ID ${DEVICE}) removed from ${MDEV}"

				if $(echo "${DPF} ${SPFmonitor}" | grep -q "${DEVICE}"); then
					$LOG "DPF or SPF in monitor mode removed"
					$LOG "stopping lcd4linux"

					service lcd4linux stop
				fi

				if $(echo "${SPFstorage}" | grep -q "${DEVICE}"); then
					$LOG "SPF in storage mode removed"
					$LOG "do nothing"
				fi

				$LOG "removing flagfile '$flagLCD'"
				rm -f $flagLCD
			fi
		;;
	esac
done
