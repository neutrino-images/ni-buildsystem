# custom ni-makefile - just a collection of targets

ni-init \
init: preqs crosstools bootstrap

# -- wrapper-targets for Neutrino-Updates -------------------------------------

BOXSERIES_UPDATE = hd2 ax
ifneq ($(DEBUG), yes)
	BOXSERIES_UPDATE += hd1
endif

ni-neutrino-update:
	make u-neutrino

ni-neutrino-updates:
	for boxseries in $(BOXSERIES_UPDATE); do \
		$(MAKE) BOXSERIES=$${boxseries} clean ni-neutrino-update || exit; \
	done;
	make clean

ni-neutrino-full-update:
	make u-neutrino-full

ni-neutrino-full-updates:
	for boxseries in $(BOXSERIES_UPDATE); do \
		$(MAKE) BOXSERIES=$${boxseries} clean ni-neutrino-full-update || exit; \
	done;
	make clean

# -----------------------------------------------------------------------------

BOXMODEL_IMAGE = apollo kronos kronos_v2
ifneq ($(DEBUG), yes)
	BOXMODEL_IMAGE += nevis
endif
ni-images:
	for boxmodel in $(BOXMODEL_IMAGE); do \
		$(MAKE) BOXMODEL=$${boxmodel} clean ni-image || exit; \
	done;
	make clean

personalized-image:
	make ni-image PERSONALIZE=yes

ni-image:
	@echo "starting 'make $@' build with "$(NUM_CPUS)" threads!"
	make -j$(NUM_CPUS) neutrino
	make plugins-all
	make plugins-$(BOXSERIES)
	make fbshot
	make -j$(NUM_CPUS) luacurl
	make -j$(NUM_CPUS) timezone
	make -j$(NUM_CPUS) smartmontools
	make -j$(NUM_CPUS) sg3-utils
	make -j$(NUM_CPUS) nfs-utils
	make -j$(NUM_CPUS) procps-ng
	make -j$(NUM_CPUS) nano
	make hd-idle
	make -j$(NUM_CPUS) e2fsprogs
	make -j$(NUM_CPUS) ntfs-3g
	make -j$(NUM_CPUS) exfat-utils
	make -j$(NUM_CPUS) vsftpd
	make -j$(NUM_CPUS) djmount
	make -j$(NUM_CPUS) ushare
	make -j$(NUM_CPUS) xupnpd
	make inadyn
	make -j$(NUM_CPUS) samba
	make dropbear
	make -j$(NUM_CPUS) hdparm
	make -j$(NUM_CPUS) busybox
	make -j$(NUM_CPUS) bc
	make -j$(NUM_CPUS) coreutils
	make -j$(NUM_CPUS) dosfstools
	make -j$(NUM_CPUS) wpa_supplicant
	make -j$(NUM_CPUS) mtd-utils
	make -j$(NUM_CPUS) wget
	make -j$(NUM_CPUS) iconv
	make -j$(NUM_CPUS) streamripper
ifeq ($(BOXSERIES), $(filter $(BOXSERIES), hd2 ax))
	make channellogos
	make -j$(NUM_CPUS) less
	make -j$(NUM_CPUS) parted
	make -j$(NUM_CPUS) openvpn
	make -j$(NUM_CPUS) openssh
  ifneq ($(BOXMODEL), kronos_v2)
	make -j$(NUM_CPUS) bash
	make -j$(NUM_CPUS) iperf
	make -j$(NUM_CPUS) minicom
	make -j$(NUM_CPUS) mc
  endif
  ifeq ($(BOXSERIES), ax)
	make -j$(NUM_CPUS) ofgwrite
	make -j$(NUM_CPUS) aio-grab
	make stb-startup
  endif
  ifeq ($(DEBUG), yes)
	make -j$(NUM_CPUS) strace
	make -j$(NUM_CPUS) valgrind
	make -j$(NUM_CPUS) gdb
  endif
endif
	make -j$(NUM_CPUS) kernel-$(BOXTYPE_SC)-modules
	make autofs5
ifeq ($(PERSONALIZE), yes)
	make personalize
endif
	make rootfs
	make images
	@make done
