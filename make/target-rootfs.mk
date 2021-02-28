#
# targets to finish TARGET_DIR and create rootfs
#
# -----------------------------------------------------------------------------

target-finish: .version update.urls symbolic-links
ifeq ($(BOXTYPE),armbox)
	make e2-multiboot
endif

# -----------------------------------------------------------------------------

.version: $(TARGET_DIR)/.version
$(TARGET_DIR)/.version: | $(TARGET_DIR)
	echo "distro=NI"							 > $(@)
	echo "imagename=NI \o/ Neutrino-Image"					>> $(@)
	echo "imagedescription=$(IMAGE_DESC)"					>> $(@)
	echo "imageversion=$(IMAGE_VERSION)"					>> $(@)
	echo "version=$(IMAGE_TYPE)$(IMAGE_VER)$(IMAGE_DATE)"	 		>> $(@)
	echo "describe=$$(git describe --always --long --tags | sed 's/-/./2')"	>> $(@)
	echo "builddate=$$(date)"						>> $(@)
	echo "box_model=$(BOXMODEL)"						>> $(@)
	echo "creator=$(TARGET_VENDOR), $(MAINTAINER)"				>> $(@)
	echo "homepage=www.neutrino-images.de"					>> $(@)
ifeq ($(BOXTYPE),$(filter $(BOXTYPE),armbox mipsbox))
	echo "imagedir=$(IMAGE_SUBDIR)"						>> $(@)
endif

# -----------------------------------------------------------------------------

update.urls: $(TARGET_localstatedir)/etc/update.urls
$(TARGET_localstatedir)/etc/update.urls: | $(TARGET_DIR)
	echo "$(NI_SERVER)/update.php"				 > $(@)
	echo "$(CHANNELLISTS_SITE)/$(CHANNELLISTS_MD5FILE)"	>> $(@)

# -----------------------------------------------------------------------------

# create symbolic links in TARGET_DIR
symbolic-links: | $(TARGET_DIR)
	$(CD) $(TARGET_DIR); \
		rm -rf root; ln -sf /var/root root; \
		rm -rf share; ln -sf /usr/share share
	$(CD) $(TARGET_localstatedir); \
		rm -rf run; ln -sf /tmp run; \
		rm -rf tmp; ln -sf /tmp tmp
	$(CD) $(TARGET_sysconfdir); \
		ln -sf /proc/mounts mtab
ifeq ($(PERSISTENT_VAR_PARTITION),yes)
	$(CD) $(TARGET_sysconfdir); \
		ln -sf /var/etc/exports exports; \
		ln -sf /var/etc/hostname hostname; \
		ln -sf /var/etc/localtime localtime; \
		ln -sf /var/etc/passwd passwd; \
		ln -sf /var/etc/resolv.conf resolv.conf; \
		ln -sf /var/etc/wpa_supplicant.conf wpa_supplicant.conf
	$(CD) $(TARGET_sysconfdir)/network; \
		ln -sf /var/etc/network/interfaces interfaces
endif
	mkdir -p $(TARGET_localstatedir)/tuxbox/config
	$(CD) $(TARGET_localstatedir)/tuxbox/config; \
		ln -sf /var/keys/SoftCam.Key SoftCam.Key

# -----------------------------------------------------------------------------

e2-multiboot: | $(TARGET_DIR)
	mkdir -p $(TARGET_bindir)
	echo -e "#!/bin/sh\necho Nope!" > $(TARGET_bindir)/enigma2
	chmod 0755 $(TARGET_bindir)/enigma2
	#
	echo -e "NI $(IMAGE_VERSION) \\\n \\\l\n" > $(TARGET_sysconfdir)/issue
	#
	mkdir -p $(TARGET_datadir)
	touch $(TARGET_datadir)/bootlogo.mvi
	#
	mkdir -p $(TARGET_localstatedir)/lib/opkg
	touch $(TARGET_localstatedir)/lib/opkg/status
	#
	$(INSTALL_DATA) $(TARGET_DIR)/.version $(TARGET_sysconfdir)/image-version

# -----------------------------------------------------------------------------

personalize: | $(TARGET_DIR)
	$(call local-script,$(@F),start)
	@LOCAL_ROOT=$(LOCAL_DIR)/root; \
	if [ -n "$$(ls -A $$LOCAL_ROOT)" ]; then \
		$(INSTALL_COPY) -v $$LOCAL_ROOT/* $(TARGET_DIR)/; \
	fi
	$(call local-script,$(@F),stop)

# -----------------------------------------------------------------------------

rootfs: target-finish $(ROOTFS) rootfs-cleanup rootfs-strip

# -----------------------------------------------------------------------------

# create filesystem for our images
$(ROOTFS): | $(TARGET_DIR)
	rm -rf $(ROOTFS)
	mkdir -p $(dir $(ROOTFS))
	$(INSTALL_COPY) $(TARGET_DIR) $(ROOTFS)

# -----------------------------------------------------------------------------

# cleanup root filesystem from useless stuff
rootfs-cleanup: $(ROOTFS)
	rm -rf $(ROOTFS)$(REMOVE_DIR)
	rm -rf $(ROOTFS)$(base_includedir)
	rm -rf $(ROOTFS)$(base_libdir)/pkgconfig
	rm -rf $(ROOTFS)$(includedir)
	rm -rf $(ROOTFS)$(libdir)/pkgconfig
	rm -rf $(ROOTFS)$(libdir)/sigc++*
	rm -rf $(ROOTFS)$(libdir)/glib-2.0
	rm -f  $(ROOTFS)$(libdir)/libvorbisenc*
	find $(ROOTFS) \( -name .gitignore -o -name .gitkeep \) -type f -print0 | xargs --no-run-if-empty -0 rm -f
	find $(ROOTFS) \( -name Makefile.am \) -type f -print0 | xargs --no-run-if-empty -0 rm -f
	find $(ROOTFS)$(base_libdir) \( -name '*.a' -o -name '*.la' \) -print0 | xargs --no-run-if-empty -0 rm -f
	find $(ROOTFS)$(libdir) \( -name '*.a' -o -name '*.la' \) -print0 | xargs --no-run-if-empty -0 rm -f
	@$(call MESSAGE,"After cleanup: $$(du -sh $(ROOTFS))")

# -----------------------------------------------------------------------------

ROOTFS_STRIP_BINS  = $(base_bindir)
ROOTFS_STRIP_BINS += $(base_sbindir)
ROOTFS_STRIP_BINS += $(bindir)
ROOTFS_STRIP_BINS += $(sbindir)
ROOTFS_STRIP_BINS += /usr/share/tuxbox/neutrino/plugins

ROOTFS_STRIP_LIBS  = $(base_libdir)
ROOTFS_STRIP_LIBS += $(libdir)

# strip bins and libs in root filesystem
rootfs-strip: $(ROOTFS)
ifneq ($(DEBUG),yes)
	$(call draw_line);
	@echo "The following warnings from strip are harmless!"
	$(call draw_line);
	for dir in $(ROOTFS_STRIP_BINS); do \
		find $(ROOTFS)$${dir} -type f -print0 | xargs -0 $(TARGET_STRIP) || true; \
	done
	for dir in $(ROOTFS_STRIP_LIBS); do \
		find $(ROOTFS)$${dir} \( \
				-path $(ROOTFS)/lib/libnexus.so -o \
				-path $(ROOTFS)/lib/libnxpl.so -o \
				-path $(ROOTFS)/lib/libv3ddriver.so -o \
				\
				-path $(ROOTFS)/lib/modules \) -prune -o \
		-type f -print0 | xargs -0 $(TARGET_STRIP) || true; \
	done
  ifeq ($(BOXSERIES),hd2)
	find $(ROOTFS)/lib/modules/$(KERNEL_VER)/kernel -type f -name '*.ko' | xargs -n 1 $(TARGET_OBJCOPY) --strip-unneeded
  endif
	@$(call MESSAGE,"After strip: $$(du -sh $(ROOTFS))")
endif

# -----------------------------------------------------------------------------

ifeq ($(BOXTYPE),$(filter $(BOXTYPE),coolstream))

get-update-info: get-update-info-$(BOXSERIES)

get-update-info-hd2:
	$(call draw_line);
	@echo "Get update info for boxmodel $(BOXMODEL)"
	@echo
	@$(CD) $(SOURCE_DIR)/$(NI_DRIVERS_BIN)/$(DRIVERS_BIN_DIR); \
	if [ -e vmlinux.ub.gz ]; then \
		dd status=none if=vmlinux.ub.gz bs=1 skip=$$(LC_ALL=C grep -a -b -o $$'\x1f\x8b\x08\x00\x00\x00\x00\x00' vmlinux.ub.gz \
		| cut -d ':' -f 1) | zcat -q | grep -a "Linux version"; \
	fi; \
	if [ -e u-boot.bin ]; then \
		strings u-boot.bin | grep -m1 "U-Boot "; \
	fi; \
	if [ -e uldr.bin ]; then \
		strings uldr.bin | grep -m1 "Microloader "; \
	fi
	$(call draw_line);

get-update-info-hd1:
	$(call draw_line);
	@echo "Get update info for boxmodel $(BOXMODEL)"
	@echo
	@$(CD) $(SOURCE_DIR)/$(NI_DRIVERS_BIN)/$(DRIVERS_BIN_DIR); \
	if [ -e zImage ]; then \
		dd if=zImage bs=1 skip=$$(LC_ALL=C grep -a -b -o $$'\x1f\x8b\x08\x00\x00\x00\x00\x00' zImage \
		| cut -d ':' -f 1) | zcat -q | grep -a "Linux version"; \
	fi
	$(call draw_line);

endif

# -----------------------------------------------------------------------------

PHONY += target-finish
PHONY += .version $(TARGET_DIR)/.version
PHONY += update.urls $(TARGET_localstatedir)/etc/update.urls
PHONY += symbolic-links
PHONY += e2-multiboot
PHONY += personalize

PHONY += rootfs
PHONY += $(ROOTFS)
PHONY += rootfs-cleanup
PHONY += rootfs-strip
