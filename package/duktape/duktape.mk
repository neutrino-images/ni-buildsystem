################################################################################
#
# duktape
#
################################################################################

DUKTAPE_VERSION = 2.7.0
DUKTAPE_DIR = duktape-$(DUKTAPE_VERSION)
DUKTAPE_SOURCE = duktape-$(DUKTAPE_VERSION).tar.xz
DUKTAPE_SITE = 	https://github.com/svaarala/duktape/releases/download/v$(DUKTAPE_VERSION)

duktape:
	$(call PREPARE)
	$(CHDIR)/$($(PKG)_DIR); \
		$(TARGET_CONFIGURE_ENV) \
		$(MAKE) -f Makefile.sharedlibrary; \
		$(MAKE) -f Makefile.sharedlibrary INSTALL_PREFIX=$(TARGET_DIR)$(prefix) install
	$(call TARGET_FOLLOWUP)
