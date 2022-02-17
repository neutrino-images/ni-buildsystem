################################################################################
#
# bzip2
#
################################################################################

BZIP2_VERSION = 1.0.8
BZIP2_DIR = bzip2-$(BZIP2_VERSION)
BZIP2_SOURCE = bzip2-$(BZIP2_VERSION).tar.gz
BZIP2_SITE = https://sourceware.org/pub/bzip2

$(DL_DIR)/$(BZIP2_SOURCE):
	$(download) $(BZIP2_SITE)/$(BZIP2_SOURCE)

bzip2: $(DL_DIR)/$(BZIP2_SOURCE) | $(TARGET_DIR)
	$(REMOVE)/$(PKG_DIR)
	$(UNTAR)/$(PKG_SOURCE)
	$(call APPLY_PATCHES,$(PKG_PATCHES_DIR))
	$(CHDIR)/$(PKG_DIR); \
		mv Makefile-libbz2_so Makefile; \
		$(TARGET_CONFIGURE_ENV) \
		$(MAKE); \
		$(MAKE) install PREFIX=$(TARGET_prefix)
	$(TARGET_RM) $(TARGET_bindir)/bzip2
	$(REMOVE)/$(PKG_DIR)
	$(TOUCH)
