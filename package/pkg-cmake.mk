################################################################################
#
# CMake packages
#
################################################################################

define cmake-package
	$(call DEPENDENCIES)
	$(call DOWNLOAD,$($(PKG)_SOURCE))
	$(call STARTUP)
	$(call EXTRACT,$(BUILD_DIR))
	$(CHDIR)/$($(PKG)_DIR); \
		$(APPLY_PATCHES); \
		$(TARGET_CMAKE); \
		$(MAKE); \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
	@rm -rf $(TARGET_libdir)/cmake
	$(call TARGET_FOLLOWUP)
endef

define host-cmake-package
	$(call DEPENDENCIES)
	$(call DOWNLOAD,$($(PKG)_SOURCE))
	$(call STARTUP)
	$(call EXTRACT,$(BUILD_DIR))
	$(CHDIR)/$($(PKG)_DIR); \
		$(APPLY_PATCHES); \
		$(HOST_CMAKE); \
		$(MAKE); \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
	$(call HOST_FOLLOWUP)
endef
