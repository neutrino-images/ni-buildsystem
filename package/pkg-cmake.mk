################################################################################
#
# CMake packages
#
################################################################################

define cmake-package
	$(call PREPARE)
	$(call TARGET_CMAKE)
	$(CHDIR)/$($(PKG)_DIR)/$($(PKG)_SUBDIR); \
		$(MAKE); \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
	$(TARGET_RM) $(TARGET_libdir)/cmake
	$(call TARGET_FOLLOWUP)
endef

define host-cmake-package
	$(call PREPARE)
	$(call HOST_CMAKE)
	$(CHDIR)/$($(PKG)_DIR)/$($(PKG)_SUBDIR); \
		$(MAKE); \
		$(MAKE) install
	$(call HOST_FOLLOWUP)
endef
