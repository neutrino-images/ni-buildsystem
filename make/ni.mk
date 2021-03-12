#
# makefile to build ni-images; just a collection of targets
#
# -----------------------------------------------------------------------------

BOXMODEL_IMAGE  =
ifneq ($(DEBUG),yes)
  BOXMODEL_IMAGE += nevis
endif
BOXMODEL_IMAGE += apollo kronos kronos_v2
BOXMODEL_IMAGE += hd51 bre2ze4k h7
BOXMODEL_IMAGE += hd60 hd61
BOXMODEL_IMAGE += vusolo4k vuduo4k vuduo4kse vuultimo4k vuzero4k vuuno4k vuuno4kse
#BOXMODEL_IMAGE += vuduo

images \
ni-images:
	for boxmodel in $(BOXMODEL_IMAGE); do \
		$(MAKE) BOXMODEL=$${boxmodel} clean image || exit; \
	done;
	make clean

personalized-image:
	make image PERSONALIZE=yes

image \
ni-image:
	@echo "starting 'make $(@)' build with "$(PARALLEL_JOBS)" threads!"
	$(MAKE) kernel
	$(MAKE) blobs
	$(MAKE) neutrino
	make plugins
	make fbshot
	$(MAKE) tzdata
	$(MAKE) smartmontools
	$(MAKE) sg3_utils
	$(MAKE) nano
	make hd-idle
	$(MAKE) hdparm
	$(MAKE) nfs-utils
	$(MAKE) e2fsprogs
	$(MAKE) ntfs-3g
	$(MAKE) exfat-utils
	$(MAKE) dosfstools
	$(MAKE) mtd-utils
	make djmount
	$(MAKE) ushare
	$(MAKE) xupnpd
	make inadyn
	make samba
	$(MAKE) vsftpd
	make dropbear
	$(MAKE) busybox
	$(MAKE) sysvinit
	$(MAKE) coreutils
	$(MAKE) procps-ng
	$(MAKE) wpa_supplicant
	$(MAKE) wget
	#$(MAKE) streamripper
ifeq ($(BOXSERIES),$(filter $(BOXSERIES),hd2 hd5x hd6x vusolo4k vuduo4k vuduo4kse vuultimo4k vuzero4k vuuno4k vuuno4kse vuduo))
	$(MAKE) less
	$(MAKE) parted
	$(MAKE) openvpn
	$(MAKE) openssh
	$(MAKE) ethtool
	$(MAKE) ifenslave
	$(MAKE) f2fs-tools
  ifneq ($(BOXMODEL),kronos_v2)
	$(MAKE) bash
	$(MAKE) iperf
	$(MAKE) minicom
	$(MAKE) minidlna
	$(MAKE) mc
  endif
  ifeq ($(BOXSERIES),$(filter $(BOXSERIES),hd5x hd6x vusolo4k vuduo4k vuduo4kse vuultimo4k vuzero4k vuuno4k vuuno4kse vuduo))
	$(MAKE) gptfdisk
	$(MAKE) rsync
	$(MAKE) ofgwrite
	$(MAKE) aio-grab
	$(MAKE) dvbsnoop
	$(MAKE) minisatip
	$(MAKE) xfsprogs
	$(MAKE) libxslt
  endif
  ifeq ($(DEBUG),yes)
	$(MAKE) strace
	$(MAKE) valgrind
	$(MAKE) gdb
  endif
endif
	make autofs
	make files-etc
	make files-var-etc
	make init-scripts
ifeq ($(PERSONALIZE),yes)
	make personalize
endif
	make rootfs
	make flash-image
	@make done

# -----------------------------------------------------------------------------

PHONY += images ni-images
PHONY += personalized-image
PHONY += image ni-image
