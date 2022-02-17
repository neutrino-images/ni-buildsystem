################################################################################
#
# libzen
#
################################################################################

LIBZEN_VERSION = 0.4.38
LIBZEN_DIR = ZenLib
LIBZEN_SOURCE = libzen_$(LIBZEN_VERSION).tar.bz2
LIBZEN_SITE = https://mediaarea.net/download/source/libzen/$(LIBZEN_VERSION)

$(DL_DIR)/$(LIBZEN_SOURCE):
	$(download) $(LIBZEN_SITE)/$(LIBZEN_SOURCE)

LIBZEN_DEPENDENCIES = zlib

LIBZEN_AUTORECONF = YES

libzen: $(LIBZEN_DEPENDENCIES) $(DL_DIR)/$(LIBZEN_SOURCE) | $(TARGET_DIR)
	$(REMOVE)/$(PKG_DIR)
	$(UNTAR)/$(PKG_SOURCE)
	$(CHDIR)/$(PKG_DIR)/Project/GNU/Library; \
		$(CONFIGURE); \
		$(MAKE); \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
	$(REWRITE_LIBTOOL)
	$(REMOVE)/$(PKG_DIR)
	$(TOUCH)
