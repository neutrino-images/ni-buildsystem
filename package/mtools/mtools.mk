################################################################################
#
# mtools
#
################################################################################

MTOOLS_VERSION = 4.0.40
MTOOLS_DIR = mtools-$(MTOOLS_VERSION)
MTOOLS_SOURCE = mtools-$(MTOOLS_VERSION).tar.gz
MTOOLS_SITE = $(GNU_MIRROR)/mtools

# -----------------------------------------------------------------------------

host-mtools: | $(HOST_DIR)
	$(call host-autotools-package)
