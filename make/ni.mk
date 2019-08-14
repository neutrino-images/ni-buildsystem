#
# makefile to build ni-images; just a collection of targets
#
# -----------------------------------------------------------------------------

BOXMODEL_IMAGE = apollo kronos kronos_v2 hd51 bre2ze4k
ifneq ($(DEBUG), yes)
  BOXMODEL_IMAGE += nevis
endif

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
	@echo "starting 'make $@' build with "$(PARALLEL_JOBS)" threads!"
	$(MAKE) kernel
	$(MAKE) neutrino
	make plugins
	make fbshot
	$(MAKE) lcd4linux
	$(MAKE) luacurl
	$(MAKE) tzdata
	$(MAKE) smartmontools
	$(MAKE) sg3_utils
	$(MAKE) nfs-utils
	$(MAKE) procps-ng
	$(MAKE) nano
	make hd-idle
	$(MAKE) e2fsprogs
	$(MAKE) ntfs-3g
	$(MAKE) exfat-utils
	$(MAKE) vsftpd
	$(MAKE) djmount
	$(MAKE) ushare
	$(MAKE) xupnpd
	make inadyn
	$(MAKE) samba
	make dropbear
	$(MAKE) hdparm
	$(MAKE) busybox
	$(MAKE) coreutils
	$(MAKE) dosfstools
	$(MAKE) wpa_supplicant
	$(MAKE) mtd-utils
	$(MAKE) wget
	$(MAKE) iconv
	$(MAKE) streamripper
ifeq ($(BOXSERIES), $(filter $(BOXSERIES), hd2 hd51 bre2ze4k))
	$(MAKE) less
	$(MAKE) parted
	$(MAKE) openvpn
	$(MAKE) openssh
	$(MAKE) ethtool
  ifneq ($(BOXMODEL), kronos_v2)
	$(MAKE) bash
	$(MAKE) iperf
	$(MAKE) minicom
	$(MAKE) mc
  endif
  ifeq ($(BOXSERIES), $(filter $(BOXSERIES), hd51 bre2ze4k))
	$(MAKE) rsync
	$(MAKE) ofgwrite
	$(MAKE) aio-grab
	$(MAKE) dvbsnoop
  endif
  ifeq ($(DEBUG), yes)
	$(MAKE) strace
	$(MAKE) valgrind
	$(MAKE) gdb
  endif
endif
	make autofs
	make scripts
	make init-scripts
ifeq ($(PERSONALIZE), yes)
	make personalize
endif
	make rootfs
	make flash-image
	@make done

# -----------------------------------------------------------------------------

# Create reversed changelog using git log --reverse.
# Remove duplicated commits and re-reverse the changelog using awk.
# This keeps the original commit and removes all picked duplicates.
define make-changelog
	git log --reverse --pretty=oneline --no-merges --abbrev-commit | \
	awk '!seen[substr($$0,12)]++' | \
	awk '{a[i++]=$$0} END {for (j=i-1; j>=0;) print a[j--]}'
endef

changelogs:
	$(call make-changelog) > $(STAGING_DIR)/changelog-buildsystem
	$(CD) $(SOURCE_DIR)/$(NI-NEUTRINO); \
		$(call make-changelog) > $(STAGING_DIR)/changelog-neutrino
	$(CD) $(SOURCE_DIR)/$(NI-LIBSTB-HAL); \
		$(call make-changelog) > $(STAGING_DIR)/changelog-libstb-hal

# -----------------------------------------------------------------------------

PHONY += images ni-images
PHONY += personalized-image
PHONY += image ni-image
PHONY += changelogs
