#
# targets to create rootfs
#
# -----------------------------------------------------------------------------

rootfs: .version update.urls $(ROOTFS) rootfs-cleanup rootfs-strip rootfs-softlinks

# -----------------------------------------------------------------------------

.version: $(TARGET_DIR)/.version
$(TARGET_DIR)/.version: | $(TARGET_DIR)
	echo "version="$(IMAGE_TYPE)$(IMAGE_VERSION)$(IMAGE_DATE) > $@
	# determinate last NI-tag an use this to git describe
	GITTAG=`cd $(SOURCE_DIR)/$(NI_NEUTRINO); git tag -l "NI-*" | tail -n1`; \
	GITDESCRIBE=`cd $(SOURCE_DIR)/$(NI_NEUTRINO); git describe --always --dirty --tags --match $$GITTAG`; \
	GITDESCRIBE=$${GITDESCRIBE%-dirty}; \
	GITREVLIST=`git rev-list $$GITTAG.. --count`; \
	echo "describe="$$GITDESCRIBE.$$GITREVLIST		>> $@
	# determinate current branch in origin repo
	BRANCH=`cd $(SOURCE_DIR)/$(NI_NEUTRINO); git branch --no-color 2>/dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/\1/'`; \
	echo "branch="$$BRANCH					>> $@
	# determinate last commit in origin repo
	COMMIT=`cd $(SOURCE_DIR)/$(NI_NEUTRINO); git fetch origin; git show origin/$(NI_NEUTRINO_BRANCH) --stat | grep ^commit | cut -d' ' -f2 | cut -c1-7`; \
	echo "commit="$$COMMIT					>> $@
	echo "builddate="`date`					>> $@
	echo "creator=$(MAINTAINER)"				>> $@
ifeq ($(USE_LIBSTB-HAL), yes)
	echo "imagename=NI-Neutrino-MP"				>> $@
else
	echo "imagename=NI-Neutrino-HD"				>> $@
endif
	echo "homepage=www.neutrino-images.de"			>> $@

# -----------------------------------------------------------------------------

update.urls: $(TARGET_DIR)/var/etc/update.urls
$(TARGET_DIR)/var/etc/update.urls: | $(TARGET_DIR)
	echo "$(NI-SERVER)/update.php"				 > $@
	echo "$(CHANNELLISTS_URL)/$(CHANNELLISTS_MD5FILE)"	>> $@

# -----------------------------------------------------------------------------

personalize: | $(TARGET_DIR)
	$(call local-script,$(notdir $@),start)
	@LOCAL_ROOT=$(LOCAL_DIR)/root; \
	if [ -n "$$(ls -A $$LOCAL_ROOT)" ]; then \
		cp -a -v $$LOCAL_ROOT/* $(TARGET_DIR)/; \
	fi
	$(call local-script,$(notdir $@),stop)

# -----------------------------------------------------------------------------

# create filesystem for our images
$(ROOTFS): | $(TARGET_DIR)
	rm -rf $(ROOTFS)
	cp -a $(TARGET_DIR) $(ROOTFS)

# -----------------------------------------------------------------------------

# cleanup root filesystem from useless stuff
rootfs-cleanup: $(ROOTFS)
	rm -rf $(ROOTFS)/{include,mymodules}
	rm -rf $(ROOTFS)/share/{aclocal,gdb,locale,man,doc,info,common-lisp}
	rm -rf $(ROOTFS)/lib/pkgconfig
	rm -f  $(ROOTFS)/lib/libvorbisenc*
	rm -rf $(ROOTFS)/lib/sigc++*
	rm -rf $(ROOTFS)/lib/glib-2.0
	find $(ROOTFS) \( -name .gitignore -o -name .gitkeep \) -type f -print0 | xargs --no-run-if-empty -0 rm -f
	find $(ROOTFS)/lib \( -name '*.a' -o -name '*.la' \) -print0 | xargs --no-run-if-empty -0 rm -f
	@echo -e "$(TERM_YELLOW)"
	@du -sh $(ROOTFS)
	@echo -e "$(TERM_NORMAL)"

# -----------------------------------------------------------------------------

# strip bins and libs in root filesystem
rootfs-strip: $(ROOTFS)
ifneq ($(DEBUG), yes)
	@make line
	@echo "The following warnings from strip are harmless!"
	@make line
	find $(ROOTFS)/bin -type f -print0 | xargs -0 $(TARGET)-strip || true
	find $(ROOTFS)/sbin -type f -print0 | xargs -0 $(TARGET)-strip || true
	find $(ROOTFS)/lib \( \
			-path $(ROOTFS)/lib/libnexus.so -o \
			-path $(ROOTFS)/lib/libnxpl.so -o \
			-path $(ROOTFS)/lib/libv3ddriver.so -o \
			\
			-path $(ROOTFS)/lib/modules \) -prune -o \
	-type f -print0 | xargs -0 $(TARGET)-strip || true
  ifeq ($(BOXSERIES), hd2)
	find $(ROOTFS)/lib/modules/$(KERNEL_VERSION_FULL)/kernel -type f -name '*.ko' | xargs -n 1 $(TARGET)-objcopy --strip-unneeded
  endif
	@echo -e "$(TERM_YELLOW)"
	@du -sh $(ROOTFS)
	@echo -e "$(TERM_NORMAL)"
endif

# -----------------------------------------------------------------------------

# create softlinks in root filesystem
rootfs-softlinks: $(ROOTFS)
	pushd $(ROOTFS) && \
		ln -sf /var/root root
ifeq ($(BOXSERIES), hd51)
	pushd $(ROOTFS) && \
		ln -sf /var/root home
endif
	pushd $(ROOTFS)/usr && \
		ln -sf /share share
	pushd $(ROOTFS)/var && \
		ln -sf /tmp run && \
		ln -sf /tmp tmp
	pushd $(ROOTFS)/etc && \
		ln -sf /proc/mounts mtab
	pushd $(ROOTFS)/etc/init.d && \
		ln -sf fstab K99fstab && \
		ln -sf fstab S01fstab && \
		ln -sf syslogd K98syslogd && \
		ln -sf crond S55crond && \
		ln -sf crond K55crond && \
		ln -sf inetd S53inetd && \
		ln -sf inetd K80inetd
ifeq ($(BOXSERIES), hd2)
	pushd $(ROOTFS)/etc && \
		ln -sf /var/etc/exports exports && \
		ln -sf /var/etc/fstab fstab && \
		ln -sf /var/etc/hostname hostname && \
		ln -sf /var/etc/localtime localtime && \
		ln -sf /var/etc/passwd passwd && \
		ln -sf /var/etc/resolv.conf resolv.conf && \
		ln -sf /var/etc/wpa_supplicant.conf wpa_supplicant.conf
	pushd $(ROOTFS)/etc/network && \
		ln -sf /var/etc/network/interfaces interfaces
  ifeq ($(IMAGE_NEW), yes)
	touch -f $(ROOTFS)/var/etc/.newimage
  endif
endif
	mkdir -p $(ROOTFS)/var/tuxbox/config && \
	pushd $(ROOTFS)/var/tuxbox/config && \
	ln -sf /var/keys/SoftCam.Key SoftCam.Key

# -----------------------------------------------------------------------------

get-update-info: get-update-info-$(BOXSERIES)

get-update-info-hd2:
	@make line
	@echo "Get update info for model $(shell echo $(BOXMODEL) | sed 's/.*/\u&/')"
	@echo
	@cd $(SOURCE_DIR)/$(NI_DRIVERS-BIN)/$(DRIVERS_DIR); \
	test -e ./u-boot.bin && ( \
		strings u-boot.bin | grep -m1 "U-Boot "; \
	); \
	test -e ./uldr.bin && ( \
		strings uldr.bin | grep -m1 "Microloader "; \
	); \
	cd $(TARGET_DIR)/var/update; \
	test -e ./vmlinux.ub.gz	&& ( \
		dd if=./vmlinux.ub.gz bs=1 skip=$$(LC_ALL=C grep -a -b -o $$'\x1f\x8b\x08\x00\x00\x00\x00\x00' ./vmlinux.ub.gz \
		| cut -d ':' -f 1) | zcat | grep -a "Linux version"; \
	);
	@make line

get-update-info-hd1:
	@make line
	@echo "Get update info for model $(shell echo $(BOXMODEL) | sed 's/.*/\u&/')"
	@echo
	@cd $(TARGET_DIR)/var/update; \
	test -e ./zImage && ( \
		dd if=./zImage bs=1 skip=$$(LC_ALL=C grep -a -b -o $$'\x1f\x8b\x08\x00\x00\x00\x00\x00' ./zImage \
		| cut -d ':' -f 1) | zcat | grep -a "Linux version"; \
	);
	@make line

# -----------------------------------------------------------------------------

PHONY += rootfs
PHONY += .version $(TARGET_DIR)/.version
PHONY += update.urls $(TARGET_DIR)/var/etc/update.urls
PHONY += personalize
PHONY += $(ROOTFS)
PHONY += rootfs-cleanup
PHONY += rootfs-strip
PHONY += rootfs-softlinks
