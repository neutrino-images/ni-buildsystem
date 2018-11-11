#
# makefile to setup and initialize the final buildsystem
#
# -----------------------------------------------------------------------------

BOOTSTRAP  = targetprefix
BOOTSTRAP += $(D)
BOOTSTRAP += $(BUILD_TMP)
BOOTSTRAP += $(CROSS_DIR)
BOOTSTRAP += $(STAGING_DIR)
BOOTSTRAP += $(IMAGE_DIR)
BOOTSTRAP += $(UPDATE_DIR)
BOOTSTRAP += $(HOST_DIR)/bin
BOOTSTRAP += includes
BOOTSTRAP += libs
BOOTSTRAP += firmware
BOOTSTRAP += modules
BOOTSTRAP += host-preqs
BOOTSTRAP += $(TARGET_LIB_DIR)/libc.so.6

ifeq ($(BOXSERIES), $(filter $(BOXSERIES), hd2 hd51))
  BOOTSTRAP += blobs
endif

bootstrap: $(BOOTSTRAP)
	@make line
	@echo -e "$(TERM_YELLOW)Bootstrapped for $(shell echo $(BOXTYPE) | sed 's/.*/\u&/') $(BOXMODEL)$(TERM_NORMAL)"
	@make line

skeleton: | $(TARGET_DIR)
	cp --remove-destination -a $(SKEL_ROOT)/* $(TARGET_DIR)/
	if [ -d $(SKEL_ROOT)-$(BOXFAMILY)/ ]; then \
		cp -a $(SKEL_ROOT)-$(BOXFAMILY)/* $(TARGET_DIR)/; \
	fi

targetprefix:
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

$(TARGET_DIR):
	@make line
	@echo "TARGET_DIR does not exist. You probably need to run 'make bootstrap'"
	@make line
	@false

$(D) \
$(BUILD_TMP) \
$(CROSS_DIR) \
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

$(TARGET_LIB_DIR)/libc.so.6: | $(TARGET_DIR)
	if test -e $(CROSS_DIR)/$(TARGET)/sys-root/lib; then \
		cp -a $(CROSS_DIR)/$(TARGET)/sys-root/lib/*so* $(TARGET_LIB_DIR); \
	else \
		cp -a $(CROSS_DIR)/$(TARGET)/lib/*so* $(TARGET_LIB_DIR); \
	fi

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
PHONY += targetprefix
PHONY += includes
PHONY += libs
PHONY += firmware
PHONY += modules
PHONY += blobs
