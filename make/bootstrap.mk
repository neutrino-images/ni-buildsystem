#
# makefile to setup and initialize the final buildsystem
#
# -----------------------------------------------------------------------------

BOOTSTRAP  = target-dir
BOOTSTRAP += $(D)
BOOTSTRAP += $(BUILD_TMP)
BOOTSTRAP += $(STAGING_DIR)
BOOTSTRAP += $(IMAGE_DIR)
BOOTSTRAP += $(UPDATE_DIR)
BOOTSTRAP += $(HOST_DIR)/bin
BOOTSTRAP += cross-libs
BOOTSTRAP += includes
BOOTSTRAP += libs
BOOTSTRAP += firmware
BOOTSTRAP += modules
BOOTSTRAP += host-preqs

ifeq ($(BOXSERIES), $(filter $(BOXSERIES), hd2 hd51))
  BOOTSTRAP += blobs
endif

bootstrap: $(BOOTSTRAP)
	@touch $(BUILD_TMP)/.$(BOXTYPE)-$(BOXMODEL)
	@make line
	@echo -e "$(TERM_YELLOW)Bootstrapped for $(shell echo $(BOXTYPE) | sed 's/.*/\u&/') $(BOXMODEL)$(TERM_NORMAL)"
	@make line

skeleton: | $(TARGET_DIR)
	cp --remove-destination -a $(SKEL_ROOT)/* $(TARGET_DIR)/
	if [ -d $(SKEL_ROOT)-$(BOXFAMILY)/ ]; then \
		cp -a $(SKEL_ROOT)-$(BOXFAMILY)/* $(TARGET_DIR)/; \
	fi

target-dir:
	mkdir -p $(TARGET_DIR)
	mkdir -p $(TARGET_DIR)/bin
ifeq ($(BOXSERIES), hd51)
	mkdir -p $(TARGET_DIR)/boot
endif
	mkdir -p $(TARGET_DIR)/dev
	mkdir -p $(TARGET_DIR)/etc/network/if-{up,pre-up,post-up,down,pre-down,post-down}.d
	mkdir -p $(TARGET_DIR)/media
	mkdir -p $(TARGET_DIR)/mnt
	mkdir -p $(TARGET_DIR)/proc
	mkdir -p $(TARGET_DIR)/srv
	mkdir -p $(TARGET_DIR)/sys
	mkdir -p $(TARGET_DIR)/tmp
	mkdir -p $(TARGET_DIR)/usr/bin
	mkdir -p $(TARGET_DIR)/var/bin
	mkdir -p $(TARGET_DIR)/var/etc/init.d
	mkdir -p $(TARGET_DIR)/var/keys
	mkdir -p $(TARGET_DIR)/var/root
	mkdir -p $(TARGET_DIR)/var/spool/cron/crontabs
	mkdir -p $(PKG_CONFIG_PATH)
	make skeleton
ifeq ($(BOXSERIES), hd2)
  ifeq ($(IMAGE_NEW), yes)
	touch -f $(TARGET_DIR)/var/etc/.newimage
  endif
endif

$(TARGET_DIR):
	@make line
	@echo "TARGET_DIR does not exist. You probably need to run 'make bootstrap'"
	@make line
	@false

$(D) \
$(BUILD_TMP) \
$(STAGING_DIR) \
$(IMAGE_DIR) \
$(UPDATE_DIR) \
$(HOST_DIR):
	mkdir -p $@

$(HOST_DIR)/bin: $(HOST_DIR)
	mkdir -p $@

$(TARGET_INCLUDE_DIR): | $(TARGET_DIR)
	mkdir -p $@

$(TARGET_LIB_DIR): | $(TARGET_DIR)
	mkdir -p $@
	cp -a $(SOURCE_DIR)/$(NI_DRIVERS-BIN)/$(DRIVERS_DIR)/libs/* $@
ifeq ($(BOXTYPE), coolstream)
	cp -a $(SOURCE_DIR)/$(NI_DRIVERS-BIN)/$(DRIVERS_DIR)/libcoolstream/$(shell echo -n $(NI_FFMPEG_BRANCH) | sed 's,/,-,g')/* $@
  ifeq ($(BOXSERIES), hd1)
	ln -sf libnxp.so $@/libconexant.so
  endif
endif

$(TARGET_LIB_DIR)/firmware: | $(TARGET_DIR)
	mkdir -p $@
	cp -a $(SOURCE_DIR)/$(NI_DRIVERS-BIN)/$(DRIVERS_DIR)/firmware/* $@/

$(TARGET_LIB_DIR)/modules: | $(TARGET_DIR)
	mkdir -p $@
	cp -a $(SOURCE_DIR)/$(NI_DRIVERS-BIN)/$(DRIVERS_DIR)/drivers/$(KERNEL_VERSION_FULL) $@/

$(STATIC_LIB_DIR): | $(TARGET_DIR)
	mkdir -p $@
	if [ -d $(STATIC_DIR)/ ]; then \
		cp -a $(STATIC_DIR)/* $(TARGET_DIR)/; \
	fi

$(TARGET_DIR)/var/update: | $(TARGET_DIR)
	mkdir -p $@
ifeq ($(BOXTYPE), coolstream)
	cp -a $(SOURCE_DIR)/$(NI_DRIVERS-BIN)/$(DRIVERS_DIR)/uldr.bin $@/
  ifeq ($(BOXMODEL), kronos_v2)
	cp -a $(SOURCE_DIR)/$(NI_DRIVERS-BIN)/$(DRIVERS_DIR)/u-boot.bin.link $@/u-boot.bin
  else
	cp -a $(SOURCE_DIR)/$(NI_DRIVERS-BIN)/$(DRIVERS_DIR)/u-boot.bin $@/
  endif
endif

cross-libs: | $(TARGET_DIR)
	if [ -d $(CROSS_DIR)/$(TARGET)/sys-root/lib/ ]; then \
		cp -a $(CROSS_DIR)/$(TARGET)/sys-root/lib/*so* $(TARGET_LIB_DIR); \
	elif [ -d $(CROSS_DIR)/$(TARGET)/lib/ ]; then \
		cp -a $(CROSS_DIR)/$(TARGET)/lib/*so* $(TARGET_LIB_DIR); \
	else \
		false; \
	fi
ifeq ($(BOXSERIES), hd2)
	cd $(TARGET_LIB_DIR) && \
		ln -sf libuClibc-$(UCLIBC_VER).so libcrypt.so.0 && \
		ln -sf libuClibc-$(UCLIBC_VER).so libdl.so.0 && \
		ln -sf libuClibc-$(UCLIBC_VER).so libm.so.0 && \
		ln -sf libuClibc-$(UCLIBC_VER).so libpthread.so.0 && \
		ln -sf libuClibc-$(UCLIBC_VER).so librt.so.0
endif

includes: $(TARGET_INCLUDE_DIR)

libs: $(TARGET_LIB_DIR) static-libs $(STATIC_LIB_DIR)

firmware: $(TARGET_LIB_DIR)/firmware

modules: $(TARGET_LIB_DIR)/modules

blobs: $(TARGET_DIR)/var/update

# -----------------------------------------------------------------------------

# hack to make sure they are always copied
PHONY += $(TARGET_INCLUDE_DIR)
PHONY += $(TARGET_LIB_DIR)
PHONY += $(TARGET_LIB_DIR)/firmware
PHONY += $(TARGET_LIB_DIR)/modules
PHONY += $(TARGET_DIR)/var/update
PHONY += $(STATIC_LIB_DIR)

# -----------------------------------------------------------------------------

PHONY += bootstrap
PHONY += skeleton
PHONY += target-dir
PHONY += cross-libs
PHONY += includes
PHONY += libs
PHONY += firmware
PHONY += modules
PHONY += blobs
