#
# makefile to setup and initialize the final buildsystem
#
# -----------------------------------------------------------------------------

# buildsystem related
BOOTSTRAP  = $(CROSS_DIR)
BOOTSTRAP += $(STATIC_DIR)
BOOTSTRAP += $(DEPS_DIR)
BOOTSTRAP += $(BUILD_DIR)
BOOTSTRAP += $(STAGING_DIR)
BOOTSTRAP += $(IMAGE_DIR)
BOOTSTRAP += $(UPDATE_DIR)
BOOTSTRAP += host-tools

# target related
BOOTSTRAP += target-dir
BOOTSTRAP += libs-static
BOOTSTRAP += libs-cross

ifeq ($(BOXTYPE),$(filter $(BOXTYPE),coolstream))
  BOOTSTRAP += var-update
endif

# -----------------------------------------------------------------------------

bootstrap: $(BOOTSTRAP)
	@touch $(BUILD_DIR)/.$(BOXTYPE)-$(BOXMODEL)
	@$(call draw_line);
	@$(call SUCCESS,"Bootstrapped for $(TARGET_BOX)")
	@$(call draw_line);

# -----------------------------------------------------------------------------

skeleton: | $(TARGET_DIR)
	$(INSTALL_COPY) --remove-destination $(SKEL_ROOT)/. $(TARGET_DIR)/
	$(SED) 's|%(BOOT_PARTITION)|$(BOOT_PARTITION)|' $(TARGET_sysconfdir)/mdev.conf

# -----------------------------------------------------------------------------

target-dir:
	$(INSTALL) -d $(TARGET_DIR)
	$(INSTALL) -d $(TARGET_bindir)
	$(INSTALL) -d $(TARGET_includedir)
	$(INSTALL) -d $(TARGET_libdir)
	$(INSTALL) -d $(TARGET_sbindir)
	$(INSTALL) -d $(TARGET_datadir)
	#$(INSTALL) -d $(TARGET_prefix)/local/{bin,include,lib,sbin,share}
	$(INSTALL) -d $(TARGET_localstatedir)/bin
	$(INSTALL) -d $(TARGET_localstatedir)/etc/init.d
	$(INSTALL) -d $(TARGET_localstatedir)/keys
	$(INSTALL) -d $(TARGET_localstatedir)/root
	$(INSTALL) -d $(TARGET_localstatedir)/run
ifeq ($(BOXSERIES),$(filter $(BOXSERIES),hd5x hd6x vusolo4k vuduo4k vuduo4kse vuultimo4k vuzero4k vuuno4k vuuno4kse))
	$(INSTALL) -d $(TARGET_DIR)/boot
endif
	$(INSTALL) -d $(TARGET_DIR)/dev
	$(INSTALL) -d $(TARGET_DIR)/home
	$(INSTALL) -d $(TARGET_DIR)/media
	$(INSTALL) -d $(TARGET_DIR)/mnt
	$(INSTALL) -d $(TARGET_DIR)/proc
	$(INSTALL) -d $(TARGET_DIR)/srv
	$(INSTALL) -d $(TARGET_DIR)/sys
	$(INSTALL) -d $(TARGET_DIR)/tmp
	$(foreach dir,$(subst :, ,$(PKG_CONFIG_PATH)),$(shell $(INSTALL) -d $(dir)))
	make skeleton
ifeq ($(PERSISTENT_VAR_PARTITION),yes)
  ifeq ($(IMAGE_NEW),yes)
	touch -f $(TARGET_localstatedir)/etc/.newimage
  endif
endif

# -----------------------------------------------------------------------------

$(TARGET_DIR):
	@$(call draw_line);
	@echo "TARGET_DIR does not exist. You probably need to run 'make bootstrap'"
	@$(call draw_line);
	@false

# -----------------------------------------------------------------------------

$(STATIC_DIR) \
$(DEPS_DIR) \
$(BUILD_DIR) \
$(STAGING_DIR) \
$(IMAGE_DIR) \
$(UPDATE_DIR):
	$(INSTALL) -d $(@)

# -----------------------------------------------------------------------------

libs-cross: | $(TARGET_DIR)
	$(INSTALL_COPY) $(CROSS_DIR)/$(TARGET)/sys-root/lib/*so* $(TARGET_base_libdir)
ifeq ($(BOXSERIES),hd2)
	$(CD) $(TARGET_base_libdir); \
		ln -sf libuClibc-$(UCLIBC_NG_VERSION).so libcrypt.so.0; \
		ln -sf libuClibc-$(UCLIBC_NG_VERSION).so libdl.so.0; \
		ln -sf libuClibc-$(UCLIBC_NG_VERSION).so libm.so.0; \
		ln -sf libuClibc-$(UCLIBC_NG_VERSION).so libpthread.so.0; \
		ln -sf libuClibc-$(UCLIBC_NG_VERSION).so librt.so.0
endif
ifeq ($(BOXSERIES),$(filter $(BOXSERIES),hd5x hd6x vusolo4k vuduo4k vuduo4kse vuultimo4k vuzero4k vuuno4k vuuno4kse))
	$(CD) $(TARGET_base_libdir); \
		ln -sf ld-2.27.so ld-linux.so.3
endif
	$(CD) $(TARGET_libdir); \
		ln -sf ../../lib/libgcc_s.so.1 libgcc_s.so.1

# -----------------------------------------------------------------------------

ifeq ($(BOXTYPE),$(filter $(BOXTYPE),coolstream))

var-update: $(TARGET_localstatedir)/update

$(TARGET_localstatedir)/update: | $(TARGET_DIR)
	$(INSTALL) -d $(@)
ifeq ($(BOXSERIES),$(filter $(BOXSERIES),hd2))
	$(INSTALL_DATA) $(SOURCE_DIR)/$(NI_DRIVERS_BIN)/$(DRIVERS_BIN_DIR)/uldr.bin $(@)
  ifeq ($(BOXMODEL),kronos_v2)
	$(INSTALL_DATA) $(SOURCE_DIR)/$(NI_DRIVERS_BIN)/$(DRIVERS_BIN_DIR)/u-boot.bin.kronos_v2 $(@)/u-boot.bin
  else
	$(INSTALL_DATA) $(SOURCE_DIR)/$(NI_DRIVERS_BIN)/$(DRIVERS_BIN_DIR)/u-boot.bin $(@)
  endif
endif

endif

# -----------------------------------------------------------------------------

# hack to make sure they are always copied
PHONY += $(TARGET_localstatedir)/update

# -----------------------------------------------------------------------------

PHONY += bootstrap
PHONY += skeleton
PHONY += target-dir
PHONY += libs-cross
