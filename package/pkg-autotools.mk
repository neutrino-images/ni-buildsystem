################################################################################
#
# Autotools packages
#
################################################################################

define autotools-package
	$(REMOVE)/$($(PKG)_DIR)
	$(UNTAR)/$($(PKG)_SOURCE)
	$(CHDIR)/$($(PKG)_DIR); \
		$(CONFIGURE); \
		$(MAKE); \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
	$(REWRITE_CONFIG_SCRIPTS)
	$(REWRITE_LIBTOOL)
	$(REMOVE)/$($(PKG)_DIR)
	$(TOUCH)
endef
