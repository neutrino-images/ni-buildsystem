################################################################################
#
# Autotools packages
#
################################################################################

define autotools-package
	$(call PREPARE)
	$(call TARGET_CONFIGURE)
	$(CHDIR)/$($(PKG)_DIR)/$($(PKG)_SUBDIR); \
		$(MAKE); \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
	$(call TARGET_FOLLOWUP)
endef

define host-autotools-package
	$(call PREPARE)
	$(call HOST_CONFIGURE)
	$(CHDIR)/$($(PKG)_DIR)/$($(PKG)_SUBDIR); \
		$(MAKE); \
		$(MAKE) install
	$(call HOST_FOLLOWUP)
endef
