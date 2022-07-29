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
	echo "version=$(IMAGE_VERSION_STRING)"			 		>> $(@)
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
		rm -rf share; ln -sf /usr/share share; \
		rm -rf run; ln -sf /var/run run
	$(CD) $(TARGET_localstatedir); \
		rm -rf run; ln -sf /tmp run; \
		rm -rf tmp; ln -sf /tmp tmp
	$(CD) $(TARGET_sysconfdir); \
		ln -sf /proc/mounts mtab
ifeq ($(PERSISTENT_VAR_PARTITION),yes)
	$(CD) $(TARGET_sysconfdir); \
		ln -sf /var/etc/hostname hostname
endif
	$(INSTALL) -d $(TARGET_localstatedir)/tuxbox/config
	$(CD) $(TARGET_localstatedir)/tuxbox/config; \
		ln -sf /var/keys/SoftCam.Key SoftCam.Key

# -----------------------------------------------------------------------------

e2-multiboot: .version | $(TARGET_DIR)
	$(INSTALL) -d $(TARGET_bindir)
	echo -e "#!/bin/sh\necho Nope!" > $(TARGET_bindir)/enigma2
	chmod 0755 $(TARGET_bindir)/enigma2
	#
	echo -e "NI $(IMAGE_VERSION) \\\n \\\l\n" > $(TARGET_sysconfdir)/issue
	#
	$(INSTALL) -d $(TARGET_datadir)
	touch $(TARGET_datadir)/bootlogo.mvi
	#
	$(INSTALL) -d $(TARGET_localstatedir)/lib/opkg
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
ifeq ($(BOXTYPE),coolstream)
	make rootfs-tarball
endif

# -----------------------------------------------------------------------------

# create filesystem for our images
$(ROOTFS): | $(TARGET_DIR)
	rm -rf $(ROOTFS)
	$(INSTALL) -d $(dir $(ROOTFS))
	$(INSTALL_COPY) $(TARGET_DIR) $(ROOTFS)

# -----------------------------------------------------------------------------

# cleanup root filesystem from useless stuff
rootfs-cleanup: $(ROOTFS)
	rm -rf $(ROOTFS)$(REMOVE_DIR)
	rm -rf $(ROOTFS)$(base_includedir)
	rm -rf $(ROOTFS)$(base_libdir)/pkgconfig
	rm -rf $(ROOTFS)$(includedir)
	rm -rf $(ROOTFS)$(libdir)/pkgconfig
	rm -rf $(ROOTFS)$(libdir)/cmake
	rm -rf $(ROOTFS)$(libdir)/sigc++*
	rm -rf $(ROOTFS)$(libdir)/glib-2.0
	rm -f  $(ROOTFS)$(libdir)/libvorbisenc*
	rm -rf $(ROOTFS)/.git
  ifeq ($(BOXSERIES),hd1)
	rm -rf $(ROOTFS)$(datadir)/bash-completion
  endif
	find $(ROOTFS) -name .gitignore -type f -print0 | xargs --no-run-if-empty -0 rm -f
	find $(ROOTFS) -name Makefile.am -type f -print0 | xargs --no-run-if-empty -0 rm -f
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
	@$(call draw_line);
	@echo "The following warnings from strip are harmless!"
	@$(call draw_line);
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
	find $(ROOTFS)/lib/modules/$(KERNEL_VERSION)/kernel -type f -name '*.ko' | xargs -n 1 $(TARGET_OBJCOPY) --strip-unneeded
  endif
	@$(call MESSAGE,"After strip: $$(du -sh $(ROOTFS))")
endif

# -----------------------------------------------------------------------------

ROOTFS_TARBALL = $(IMAGE_DIR)/$(IMAGE_NAME)-rootfs.tgz

ROOTFS_TARBALL_EXCLUDE = \
	./var/update

rootfs-tarball: $(ROOTFS_TARBALL)
$(ROOTFS_TARBALL):
	tar czf $(@) -C $(ROOTFS) $(foreach exclude,$(ROOTFS_TARBALL_EXCLUDE),--exclude='$(exclude)' ) .
ifeq ($(BOXMODEL),$(filter $(BOXMODEL),apollo shiner))
  ifeq ($(BOXMODEL),apollo)
	# create rootfs tarball for shiner too when building apollo
	$(INSTALL_COPY) $(@) $(subst apollo,shiner,$(@))
  else ifeq ($(BOXMODEL),shiner)
	# create rootfs tarball for apollo too when building shiner
	$(INSTALL_COPY) $(@) $(subst shiner,apollo,$(@))
  endif
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
