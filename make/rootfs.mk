# targets to create rootfs

# rootfs targets
rootfs: .version update.urls $(BOX) cleanup strip softlinks

.version: $(TARGETPREFIX)/.version
$(TARGETPREFIX)/.version:
	echo "version="$(IMAGE_TYPE)$(IMAGE_VERSION)$(IMAGE_DATE) > $@
	# determinate last NI-release-tag an use this to git describe
	GITTAG=`cd $(N_HD_SOURCE); git tag -l "NI-*" | tail -n1`; \
	GITDESCRIBE=`cd $(N_HD_SOURCE); git describe --always --dirty --tags --match $$GITTAG`; \
	GITDESCRIBE=$${GITDESCRIBE%-dirty}; \
	echo "describe="$$GITDESCRIBE				>> $@
	# determinate current branch in origin repo
	BRANCH=`cd $(N_HD_SOURCE); git branch --no-color 2>/dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/\1/'`; \
	echo "branch="$$BRANCH					>> $@
	# determinate last commit in origin repo
	COMMIT=`cd $(N_HD_SOURCE); git fetch origin; git show origin/$(NI_NEUTRINO_BRANCH) --stat | grep ^commit | cut -d' ' -f2 | cut -c1-7`; \
	echo "commit="$$COMMIT					>> $@
	echo "builddate="`date`					>> $@
	echo "creator=$(MAINTAINER)"				>> $@
ifeq ($(USE_LIBSTB-HAL), yes)
	echo "imagename=NI-Neutrino-MP"				>> $@
else
	echo "imagename=NI-Neutrino-HD"				>> $@
endif
	echo "homepage=www.neutrino-images.de"			>> $@

update.urls: $(TARGETPREFIX)/var/etc/update.urls
$(TARGETPREFIX)/var/etc/update.urls:
	rm -f $@
	touch $@
	echo "$(NI-SERVER)/update.php"				>> $@
	echo "$(CHANLIST_URL)/$(CHANLIST_MD5FILE)"		>> $@

# create filesystem for our images
$(BOX): | $(TARGETPREFIX)
	rm -rf $(BOX)
	cp -a $(TARGETPREFIX) $(BOX)

# cleanup filesystem from useless stuff
cleanup: $(BOX)
	rm -rf $(BOX)/{include,mymodules}
	rm -rf $(BOX)/share/{aclocal,gdb,locale,man,doc,info,common-lisp}
	rm -rf $(BOX)/lib/pkgconfig
	rm -f $(BOX)/lib/libvorbisenc*
	rm -rf $(BOX)/lib/sigc++*
	rm -rf $(BOX)/lib/glib-2.0
	find $(BOX) \( -name .gitignore -o -name .gitkeep \) -type f -print0 | xargs --no-run-if-empty -0 rm -f
	find $(BOX)/lib \( -name '*.a' -o -name '*.la' \) -print0 | xargs --no-run-if-empty -0 rm -f
	@echo -e "$(TERM_YELLOW)"
	@du -sh $(BOX)
	@echo -e "$(TERM_NORMAL)"

# strip bins and libs in filesystem
strip: $(BOX)
ifeq ($(DEBUG), no)
	@echo "*******************************************************"
	@echo "*** The following warnings from strip are harmless! ***"
	@echo "*******************************************************"
	find $(BOX)/bin -type f -print0 | xargs -0 $(TARGET)-strip || true
	find $(BOX)/sbin -type f -print0 | xargs -0 $(TARGET)-strip || true
	find $(BOX)/lib \( \
			-path $(BOX)/lib/libnexus.so -o \
			-path $(BOX)/lib/libnxpl.so -o \
			-path $(BOX)/lib/libv3ddriver.so -o \
			\
			-path $(BOX)/lib/modules \) -prune -o \
	-type f -print0 | xargs -0 $(TARGET)-strip || true
ifeq ($(BOXSERIES), hd2)
	find $(BOX)/lib/modules/$(KVERSION_FULL)/kernel -type f -name '*.ko' | xargs -n 1 $(TARGET)-objcopy --strip-unneeded
endif
	@echo -e "$(TERM_YELLOW)"
	@du -sh $(BOX)
	@echo -e "$(TERM_NORMAL)"
endif
ifeq ($(DEBUG), yes)
	@echo "*******************************************************"
	@echo "*** The following warnings from strip are harmless! ***"
	@echo "*******************************************************"
	find $(BOX)/bin -path $(BOX)/bin/neutrino -prune -o -type f -print0 | xargs -0 $(TARGET)-strip || true
	find $(BOX)/sbin -type f -print0 | xargs -0 $(TARGET)-strip || true
	find $(BOX)/lib/valgrind -type f -print0 | xargs -0 $(TARGET)-strip || true
	@echo "*******************************************************"
	@echo "***        Strip samba for debug image              ***"
	@echo "*******************************************************"
	$(TARGET)-strip $(TARGETPREFIX)/bin/smbclient
	$(TARGET)-strip $(TARGETPREFIX)/bin/smbpasswd
	$(TARGET)-strip $(TARGETPREFIX)/lib/libsmbsharemodes.so.0
	$(TARGET)-strip $(TARGETPREFIX)/lib/libsmbclient.so.0
	$(TARGET)-strip $(TARGETPREFIX)/lib/libnetapi.so.0
	$(TARGET)-strip $(TARGETPREFIX)/lib/libtdb.so.1
	$(TARGET)-strip $(TARGETPREFIX)/lib/libtalloc.so.1
	$(TARGET)-strip $(TARGETPREFIX)/lib/libwbclient.so.0
	find $(BOX)/lib/samba -type f -print0 | xargs -0 $(TARGET)-strip || true
	@echo -e "$(TERM_YELLOW)"
	@du -sh $(BOX)
	@echo -e "$(TERM_NORMAL)"
endif

# create softlinks in filesystem
softlinks: $(BOX)
	pushd $(BOX) && \
	ln -sf /var/root root && \
	pushd $(BOX)/usr && \
	ln -sf /share share && \
	pushd $(BOX)/usr/bin && \
	ln -sf /bin/env env && \
	pushd $(BOX)/var && \
	ln -sf /tmp run && \
	ln -sf /tmp tmp && \
	pushd $(BOX)/etc/init.d && \
	ln -sf fstab K99fstab && \
	ln -sf fstab S01fstab && \
	ln -sf syslogd K98syslogd && \
	ln -sf sdX K97sdX && \
	ln -sf crond S55crond && \
	ln -sf crond K55crond && \
	ln -sf inetd S53inetd && \
	ln -sf inetd K80inetd && \
	ln -sf emu S99emu && \
	ln -sf emu K01emu
	pushd $(BOX)/lib && \
	ln -sf libcrypto.so.1.0.0 libcrypto.so.0.9.8 && \
	ln -sf libssl.so.1.0.0 libssl.so.0.9.8 && \
	ln -sf libcrypto.so.1.0.0 libcrypto.so.0.9.7 && \
	ln -sf libssl.so.1.0.0 libssl.so.0.9.7
	pushd $(BOX)/bin && \
	ln -sf fbshot dboxshot
	pushd $(BOX)/sbin && \
	ln -sf ntfs-3g mount.ntfs
ifeq ($(BOXSERIES), hd1)
	pushd $(BOX)/lib && \
	ln -sf libnxp.so libconexant.so
	pushd $(BOX)/lib/firmware && \
	ln -sf rt2870.bin rt3070.bin
endif
ifeq ($(BOXSERIES), ax)
	pushd $(BOX)/lib && \
	ln -sf libv3ddriver.so libEGL.so && \
	ln -sf libv3ddriver.so libGLESv2.so
endif
ifeq ($(BOXSERIES), hd2)
	pushd $(BOX)/etc && \
	ln -sf /var/etc/exports exports && \
	ln -sf /var/etc/fstab fstab && \
	ln -sf /var/etc/hostname hostname && \
	ln -sf /var/etc/localtime localtime && \
	ln -sf /var/etc/passwd passwd && \
	ln -sf /var/etc/resolv.conf resolv.conf && \
	ln -sf /var/etc/wpa_supplicant.conf wpa_supplicant.conf
	pushd $(BOX)/etc/network && \
	ln -sf /var/etc/network/interfaces interfaces
	pushd $(BOX)/lib && \
	ln -sf libuClibc-$(UCLIBC_VER).so libcrypt.so.0 && \
	ln -sf libuClibc-$(UCLIBC_VER).so libdl.so.0 && \
	ln -sf libuClibc-$(UCLIBC_VER).so libpthread.so.0 && \
	ln -sf libuClibc-$(UCLIBC_VER).so libm.so.0 && \
	ln -sf libuClibc-$(UCLIBC_VER).so librt.so.0
ifeq ($(NEWIMAGE), yes)
	touch -f $(BOX)/var/etc/.newimage
endif
endif
	mkdir -p $(BOX)/var/tuxbox/config && \
	pushd $(BOX)/var/tuxbox/config && \
	ln -sf /var/keys/SoftCam.Key SoftCam.Key

get-update-info: get-update-info-$(BOXSERIES)

get-update-info-hd2:
	@echo " ============================================================================== "
	@echo "                    Get update info for model $(shell echo $(BOXMODEL) | sed 's/.*/\u&/')"
	@echo ""
	@cd $(SOURCE_DIR)/$(NI_DRIVERS-BIN)/$(DRIVERS_DIR); \
	test -e ./u-boot.bin && ( \
		strings u-boot.bin | grep -m1 "U-Boot "; \
	); \
	test -e ./uldr.bin && ( \
		strings uldr.bin | grep -m1 "Microloader "; \
	); \
	cd $(BASE_DIR)/root/var/update; \
	test -e ./vmlinux.ub.gz	&& ( \
		dd if=./vmlinux.ub.gz bs=1 skip=$$(LC_ALL=C grep -a -b -o $$'\x1f\x8b\x08\x00\x00\x00\x00\x00' ./vmlinux.ub.gz \
		| cut -d ':' -f 1) | zcat | grep -a "Linux version"; \
	);
	@echo " ============================================================================== "

get-update-info-hd1:
	@echo " ============================================================================== "
	@echo "                    Get update info for model $(shell echo $(BOXMODEL) | sed 's/.*/\u&/')"
	@echo ""
	@cd $(BASE_DIR)/root/var/update; \
	test -e ./zImage && ( \
		dd if=./zImage bs=1 skip=$$(LC_ALL=C grep -a -b -o $$'\x1f\x8b\x08\x00\x00\x00\x00\x00' ./zImage \
		| cut -d ':' -f 1) | zcat | grep -a "Linux version"; \
	);
	@echo " ============================================================================== "

personalize: | $(TARGETPREFIX)
	$(call local-script,$(notdir $@),start)
	@LOCAL_ROOT=$(LOCAL_DIR)/root; \
	if [ $$(ls -A $$LOCAL_ROOT) ]; then \
		cp -a -v $$LOCAL_ROOT/* $(TARGETPREFIX)/; \
	fi
	$(call local-script,$(notdir $@),stop)

PHONY += $(TARGETPREFIX)/.version $(TARGETPREFIX)/var/etc/update.urls $(BOX)
