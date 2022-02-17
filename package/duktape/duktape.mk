################################################################################
#
# duktape
#
################################################################################

DUKTAPE_VERSION = 2.6.0
DUKTAPE_DIR = duktape-$(DUKTAPE_VERSION)
DUKTAPE_SOURCE = duktape-$(DUKTAPE_VERSION).tar.xz
DUKTAPE_SITE = 	https://github.com/svaarala/duktape/releases/download/v$(DUKTAPE_VERSION)

duktape:
	$(call DEPENDENCIES)
	$(call DOWNLOAD,$($(PKG)_SOURCE))
	$(call STARTUP)
	$(call EXTRACT,$(BUILD_DIR))
	$(call APPLY_PATCHES,$(PKG_PATCHES_DIR))
	$(CHDIR)/$($(PKG)_DIR); \
		$(TARGET_CONFIGURE_ENV) \
		$(MAKE) -f Makefile.sharedlibrary; \
		$(MAKE) -f Makefile.sharedlibrary INSTALL_PREFIX=$(TARGET_DIR)/usr install
	$(call TARGET_FOLLOWUP)
