# makefile to setup and initialize the final buildsystem

BOOTSTRAP  = targetprefix
BOOTSTRAP += $(D)
BOOTSTRAP += $(BUILD_TMP)
BOOTSTRAP += $(CROSS_DIR)
BOOTSTRAP += $(STAGING_DIR)
BOOTSTRAP += $(IMAGE_DIR)
BOOTSTRAP += $(UPDATE_DIR)
BOOTSTRAP += $(HOST_DIR)/bin
BOOTSTRAP += includes-and-libs
BOOTSTRAP += modules
BOOTSTRAP += host-preqs
BOOTSTRAP += $(TARGET_LIB_DIR)/libc.so.6

ifeq ($(BOXSERIES), $(filter $(BOXSERIES), hd2 hd51))
  BOOTSTRAP += static-libs
  BOOTSTRAP += blobs
endif

PLAT_INCS = $(TARGET_LIB_DIR)/firmware
PLAT_LIBS = $(TARGET_LIB_DIR) $(STATIC_LIB_DIR)

bootstrap: $(BOOTSTRAP)
	@echo -e "$(TERM_YELLOW)Bootstrapped for $(shell echo $(BOXTYPE) | sed 's/.*/\u&/') $(BOXMODEL)$(TERM_NORMAL)"

skeleton: | $(TARGET_DIR)
	cp --remove-destination -a $(SKEL_ROOT)/* $(TARGET_DIR)/
	if [ -d $(SKEL_ROOT)-$(BOXFAMILY)/ ]; then \
		cp -a $(SKEL_ROOT)-$(BOXFAMILY)/* $(TARGET_DIR)/; \
	fi
	if [ -d $(STATIC_DIR)/ ]; then \
		cp -a $(STATIC_DIR)/* $(TARGET_DIR)/; \
	fi

targetprefix:
	mkdir -p $(TARGET_DIR)
	mkdir -p $(TARGET_DIR)/bin
	mkdir -p $(TARGET_INCLUDE_DIR)
	mkdir -p $(PKG_CONFIG_PATH)
	make skeleton

$(TARGET_DIR):
	@echo "**********************************************************************"
	@echo "TARGET_DIR does not exist. You probably need to run 'make bootstrap'"
	@echo "**********************************************************************"
	@echo ""
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

$(STATIC_LIB_DIR):
	mkdir -p $@

$(TARGET_LIB_DIR)/firmware: | $(TARGET_DIR)
ifeq ($(BOXTYPE), coolstream)
	mkdir -p $@
	cp -a $(SOURCE_DIR)/$(NI_DRIVERS-BIN)/$(DRIVERS_DIR)/firmware/* $@/
endif

$(TARGET_LIB_DIR): | $(TARGET_DIR)
	mkdir -p $@
	cp -a $(SOURCE_DIR)/$(NI_DRIVERS-BIN)/$(DRIVERS_DIR)/libs/* $@
ifeq ($(BOXTYPE), coolstream)
	cp -a $(SOURCE_DIR)/$(NI_DRIVERS-BIN)/$(DRIVERS_DIR)/libcoolstream/$(shell echo -n $(NI_FFMPEG_BRANCH) | sed 's,/,-,g')/* $@
endif

$(TARGET_LIB_DIR)/modules: | $(TARGET_DIR)
	mkdir -p $@
	cp -a $(SOURCE_DIR)/$(NI_DRIVERS-BIN)/$(DRIVERS_DIR)/drivers/$(KERNEL_VERSION_FULL) $@/

$(TARGET_LIB_DIR)/libc.so.6: | $(TARGET_DIR)
	if test -e $(CROSS_DIR)/$(TARGET)/sys-root/lib; then \
		cp -a $(CROSS_DIR)/$(TARGET)/sys-root/lib/*so* $(TARGET_LIB_DIR); \
	else \
		cp -a $(CROSS_DIR)/$(TARGET)/lib/*so* $(TARGET_LIB_DIR); \
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

includes-and-libs: $(PLAT_INCS) $(PLAT_LIBS)

modules: $(TARGET_LIB_DIR)/modules

blobs: $(TARGET_DIR)/var/update

# -----------------------------------------------------------------------------

# hack to make sure they are always copied
PHONY += $(TARGET_LIB_DIR)
PHONY += $(TARGET_LIB_DIR)/firmware
PHONY += $(TARGET_LIB_DIR)/modules
PHONY += $(TARGET_DIR)/var/update

# -----------------------------------------------------------------------------

PHONY += bootstrap
PHONY += skeleton
PHONY += targetprefix
PHONY += includes-and-libs
PHONY += modules
PHONY += blobs
