################################################################################
#
# bzip2
#
################################################################################

BZIP2_VERSION = 1.0.8
BZIP2_DIR = bzip2-$(BZIP2_VERSION)
BZIP2_SOURCE = bzip2-$(BZIP2_VERSION).tar.gz
BZIP2_SITE = https://sourceware.org/pub/bzip2

define BZIP2_MAKEFILE_LIBBZ2_SO
	mv $(PKG_BUILD_DIR)/Makefile-libbz2_so $(PKG_BUILD_DIR)/Makefile
endef
BZIP2_POST_PATCH_HOOKS += BZIP2_MAKEFILE_LIBBZ2_SO

define BZIP2_TARGET_CLEANUP
	$(TARGET_RM) $(TARGET_bindir)/bzip2
endef
BZIP2_TARGET_FINALIZE_HOOKS += BZIP2_TARGET_CLEANUP

bzip2: | $(TARGET_DIR)
	$(call PREPARE)
	$(CHDIR)/$($(PKG)_DIR); \
		$(TARGET_CONFIGURE_ENV) \
		$(MAKE); \
		$(MAKE) install PREFIX=$(TARGET_prefix)
	$(call TARGET_FOLLOWUP)
