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
		$(CMAKE); \
		$(MAKE); \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
	-rm -r $(TARGET_libdir)/cmake
	$(call FOLLOWUP)
endef
