################################################################################
#
# mtools
#
################################################################################

MTOOLS_VERSION = 4.0.39
MTOOLS_DIR = mtools-$(MTOOLS_VERSION)
MTOOLS_SOURCE = mtools-$(MTOOLS_VERSION).tar.gz
MTOOLS_SITE = $(GNU_MIRROR)/mtools

# ------------------------------------------------------------------------------

HOST_MTOOLS_VERSION = $(MTOOLS_VERSION)
HOST_MTOOLS_DIR = $(MTOOLS_DIR)
HOST_MTOOLS_SOURCE = $(MTOOLS_SOURCE)
HOST_MTOOLS_SITE = $(MTOOLS_SITE)

host-mtools: | $(HOST_DIR)
	$(call PREPARE)
	$(call HOST_CONFIGURE)
	$(CHDIR)/$($(PKG)_DIR); \
		$(MAKE1); \
		$(MAKE) install
	$(call HOST_FOLLOWUP)
