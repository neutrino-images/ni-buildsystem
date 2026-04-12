################################################################################
#
# oscam-archive
#
################################################################################

OSCAM_ARCHIVE_DEPENDENCIES = oscam # oscam requires OSCAM_KEEP_BUILD_DIR = YES

define OSCAM_ARCHIVE_COMPRESS
	v=$$($(BUILD_DIR)/$(OSCAM_DIR)/config.sh --oscam-version); \
	$(INSTALL_EXEC) $(OSCAM_OSCAM_BIN) $(BUILD_DIR)/oscam-$${v}; \
	$(CD) $(BUILD_DIR); \
		rm -f oscam-$${v}.zip; \
		zip -m oscam-$${v}.zip oscam-$${v}
endef
OSCAM_ARCHIVE_INDIVIDUAL_HOOKS += OSCAM_ARCHIVE_COMPRESS

oscam-archive: | $(TARGET_DIR)
	$(call virtual-package,$(PKG_NO_TOUCH))
