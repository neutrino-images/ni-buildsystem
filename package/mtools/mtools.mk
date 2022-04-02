################################################################################
#
# mtools
#
################################################################################

HOST_MTOOLS_VERSION = 4.0.19
HOST_MTOOLS_DIR = mtools-$(HOST_MTOOLS_VERSION)
HOST_MTOOLS_SOURCE = mtools-$(HOST_MTOOLS_VERSION).tar.gz
HOST_MTOOLS_SITE = $(GNU_MIRROR)/mtools

$(DL_DIR)/$(HOST_MTOOLS_SOURCE):
	$(download) $(HOST_MTOOLS_SITE)/$(HOST_MTOOLS_SOURCE)

host-mtools: $(DL_DIR)/$(HOST_MTOOLS_SOURCE) | $(HOST_DIR)
	$(REMOVE)/$(PKG_DIR)
	$(UNTAR)/$(PKG_SOURCE)
	$(CHDIR)/$(PKG_DIR); \
		$(HOST_CONFIGURE);\
		$(MAKE1); \
		$(MAKE) install
	$(REMOVE)/$(PKG_DIR)
	$(TOUCH)
