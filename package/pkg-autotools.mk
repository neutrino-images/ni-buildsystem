################################################################################
#
# Autotools packages
#
################################################################################

define autotools-package
	$(call DEPENDENCIES)
	$(call DOWNLOAD,$($(PKG)_SOURCE))
	$(call STARTUP)
	$(call EXTRACT,$(BUILD_DIR))
	$(CHDIR)/$($(PKG)_DIR); \
		$(APPLY_PATCHSET); \
		$(TARGET_CONFIGURE); \
		$(MAKE); \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
	$(call TARGET_FOLLOWUP)
endef

define host-autotools-package
	$(call DEPENDENCIES)
	$(call DOWNLOAD,$($(PKG)_SOURCE))
	$(call STARTUP)
	$(call EXTRACT,$(BUILD_DIR))
	$(CHDIR)/$($(PKG)_DIR); \
		$(APPLY_PATCHSET); \
		$(HOST_CONFIGURE); \
		$(MAKE); \
		$(MAKE) install
	$(call HOST_FOLLOWUP)
endef
