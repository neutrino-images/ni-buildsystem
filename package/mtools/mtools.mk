################################################################################
#
# mtools
#
################################################################################

MTOOLS_VERSION = 4.0.40
MTOOLS_DIR = mtools-$(MTOOLS_VERSION)
MTOOLS_SOURCE = mtools-$(MTOOLS_VERSION).tar.gz
MTOOLS_SITE = $(GNU_MIRROR)/mtools

# ------------------------------------------------------------------------------

HOST_MTOOLS_VERSION = $(MTOOLS_VERSION)
HOST_MTOOLS_DIR = $(MTOOLS_DIR)
HOST_MTOOLS_SOURCE = $(MTOOLS_SOURCE)
HOST_MTOOLS_SITE = $(MTOOLS_SITE)

host-mtools: | $(HOST_DIR)
	$(call host-autotools-package)
