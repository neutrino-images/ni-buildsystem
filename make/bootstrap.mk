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
BOOTSTRAP += libs-static
BOOTSTRAP += target-dir
BOOTSTRAP += libs-cross

ifeq ($(BOXTYPE), $(filter $(BOXTYPE), coolstream))
  BOOTSTRAP += var-update
endif

# -----------------------------------------------------------------------------

bootstrap: $(BOOTSTRAP)
	@touch $(BUILD_DIR)/.$(BOXTYPE)-$(BOXMODEL)
	$(call draw_line);
	@echo -e "$(TERM_YELLOW)Bootstrapped for $(shell echo $(BOXTYPE) | sed 's/.*/\u&/') $(BOXNAME) ($(BOXMODEL))$(TERM_NORMAL)"
	$(call draw_line);

# -----------------------------------------------------------------------------

skeleton: | $(TARGET_DIR)
	$(INSTALL_COPY) --remove-destination $(SKEL-ROOT)/. $(TARGET_DIR)/
	$(SED) 's|%(BOOT_PARTITION)|$(BOOT_PARTITION)|' $(TARGET_sysconfdir)/mdev.conf
	$(INSTALL_COPY) $(STATIC_DIR)/. $(TARGET_DIR)/

# -----------------------------------------------------------------------------

target-dir:
	mkdir -p $(TARGET_DIR)
	mkdir -p $(TARGET_bindir)
	mkdir -p $(TARGET_includedir)
	mkdir -p $(TARGET_libdir)
	mkdir -p $(TARGET_sbindir)
	mkdir -p $(TARGET_datadir)
	#mkdir -p $(TARGET_prefix)/local/{bin,include,lib,sbin,share}
	mkdir -p $(TARGET_sysconfdir)/network/if-{up,pre-up,post-up,down,pre-down,post-down}.d
	mkdir -p $(TARGET_localstatedir)/bin
	mkdir -p $(TARGET_localstatedir)/etc/init.d
	mkdir -p $(TARGET_localstatedir)/keys
	mkdir -p $(TARGET_localstatedir)/root
	mkdir -p $(TARGET_localstatedir)/spool/cron/crontabs
ifeq ($(BOXSERIES), $(filter $(BOXSERIES), hd5x hd6x vusolo4k vuduo4k vuduo4kse vuultimo4k vuzero4k vuuno4k vuuno4kse))
	mkdir -p $(TARGET_DIR)/boot
endif
	mkdir -p $(TARGET_DIR)/dev
	mkdir -p $(TARGET_DIR)/media
	mkdir -p $(TARGET_DIR)/mnt
	mkdir -p $(TARGET_DIR)/proc
	mkdir -p $(TARGET_DIR)/srv
	mkdir -p $(TARGET_DIR)/sys
	mkdir -p $(TARGET_DIR)/tmp
	mkdir -p $(PKG_CONFIG_PATH)
	make skeleton
ifeq ($(PERSISTENT_VAR_PARTITION), yes)
  ifeq ($(IMAGE_NEW), yes)
	touch -f $(TARGET_localstatedir)/etc/.newimage
  endif
endif

# -----------------------------------------------------------------------------

$(TARGET_DIR):
	$(call draw_line);
	@echo "TARGET_DIR does not exist. You probably need to run 'make bootstrap'"
	$(call draw_line);
	@false

# -----------------------------------------------------------------------------

$(STATIC_DIR) \
$(DEPS_DIR) \
$(BUILD_DIR) \
$(STAGING_DIR) \
$(IMAGE_DIR) \
$(UPDATE_DIR):
	mkdir -p $(@)

# -----------------------------------------------------------------------------

libs-cross: | $(TARGET_DIR)
	if [ -d $(CROSS_DIR)/$(TARGET)/sys-root/lib/ ]; then \
		$(INSTALL_COPY) $(CROSS_DIR)/$(TARGET)/sys-root/lib/*so* $(TARGET_base_libdir); \
	elif [ -d $(CROSS_DIR)/$(TARGET)/lib/ ]; then \
		$(INSTALL_COPY) $(CROSS_DIR)/$(TARGET)/lib/*so* $(TARGET_base_libdir); \
	else \
		false; \
	fi
ifeq ($(BOXSERIES), hd2)
	$(CD) $(TARGET_base_libdir); \
		ln -sf libuClibc-$(UCLIBC_VER).so libcrypt.so.0; \
		ln -sf libuClibc-$(UCLIBC_VER).so libdl.so.0; \
		ln -sf libuClibc-$(UCLIBC_VER).so libm.so.0; \
		ln -sf libuClibc-$(UCLIBC_VER).so libpthread.so.0; \
		ln -sf libuClibc-$(UCLIBC_VER).so librt.so.0
endif
ifeq ($(BOXSERIES), $(filter $(BOXSERIES), hd5x hd6x vusolo4k vuduo4k vuduo4kse vuultimo4k vuzero4k vuuno4k vuuno4kse))
	$(CD) $(TARGET_base_libdir); \
		ln -sf ld-2.23.so ld-linux.so.3
endif

# -----------------------------------------------------------------------------

ifeq ($(BOXTYPE), $(filter $(BOXTYPE), coolstream))

var-update: $(TARGET_localstatedir)/update

$(TARGET_localstatedir)/update: | $(TARGET_DIR)
	mkdir -p $(@)
ifeq ($(BOXSERIES), $(filter $(BOXSERIES), hd1))
	$(INSTALL_DATA) $(SOURCE_DIR)/$(NI-DRIVERS-BIN)/$(DRIVERS-BIN_DIR)/zImage $(@)
else ifeq ($(BOXSERIES), $(filter $(BOXSERIES), hd2))
	$(INSTALL_DATA) $(SOURCE_DIR)/$(NI-DRIVERS-BIN)/$(DRIVERS-BIN_DIR)/vmlinux.ub.gz $(@)
	$(INSTALL_DATA) $(SOURCE_DIR)/$(NI-DRIVERS-BIN)/$(DRIVERS-BIN_DIR)/uldr.bin $(@)
  ifeq ($(BOXMODEL), kronos_v2)
	$(INSTALL_DATA) $(SOURCE_DIR)/$(NI-DRIVERS-BIN)/$(DRIVERS-BIN_DIR)/u-boot.bin.kronos_v2 $(@)/u-boot.bin
  else
	$(INSTALL_DATA) $(SOURCE_DIR)/$(NI-DRIVERS-BIN)/$(DRIVERS-BIN_DIR)/u-boot.bin $(@)
  endif
endif
	$(INSTALL_DATA) $(SOURCE_DIR)/$(NI-DRIVERS-BIN)/$(DRIVERS-BIN_DIR)/stb_update.data $(@)

endif

# -----------------------------------------------------------------------------

# hack to make sure they are always copied
PHONY += $(TARGET_localstatedir)/update

# -----------------------------------------------------------------------------

PHONY += bootstrap
PHONY += skeleton
PHONY += target-dir
PHONY += libs-cross
