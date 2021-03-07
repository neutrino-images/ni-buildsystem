################################################################################
#
# CMake packages
#
################################################################################

define cmake-package
	$(REMOVE)/$($(PKG)_DIR)
	$(UNTAR)/$($(PKG)_SOURCE)
	$(CHDIR)/$($(PKG)_DIR); \
		$(APPLY_PATCHES); \
		$(CMAKE); \
		$(MAKE); \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
	-rm -r $(TARGET_libdir)/cmake
	$(REWRITE_CONFIG_SCRIPTS)
	$(REWRITE_LIBTOOL)
	$(REMOVE)/$($(PKG)_DIR)
	$(TOUCH)
endef
