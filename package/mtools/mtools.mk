################################################################################
#
# mtools
#
################################################################################

HOST_MTOOLS_VERSION = 4.0.39
HOST_MTOOLS_DIR = mtools-$(HOST_MTOOLS_VERSION)
HOST_MTOOLS_SOURCE = mtools-$(HOST_MTOOLS_VERSION).tar.gz
HOST_MTOOLS_SITE = $(GNU_MIRROR)/mtools

host-mtools: | $(HOST_DIR)
	$(call PREPARE)
	$(CHDIR)/$($(PKG)_DIR); \
		$(HOST_CONFIGURE);\
		$(MAKE1); \
		$(MAKE) install
	$(call HOST_FOLLOWUP)
