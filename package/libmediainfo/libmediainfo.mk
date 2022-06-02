################################################################################
#
# libmediainfo
#
################################################################################

LIBMEDIAINFO_VERSION = 20.08
LIBMEDIAINFO_DIR = MediaInfoLib
LIBMEDIAINFO_SOURCE = libmediainfo_$(LIBMEDIAINFO_VERSION).tar.bz2
LIBMEDIAINFO_SITE = https://mediaarea.net/download/source/libmediainfo/$(LIBMEDIAINFO_VERSION)

$(DL_DIR)/$(LIBMEDIAINFO_SOURCE):
	$(download) $(LIBMEDIAINFO_SITE)/$(LIBMEDIAINFO_SOURCE)

LIBMEDIAINFO_DEPENDENCIES = libzen

LIBMEDIAINFO_AUTORECONF = YES

libmediainfo: $(LIBMEDIAINFO_DEPENDENCIES) $(DL_DIR)/$(LIBMEDIAINFO_SOURCE) | $(TARGET_DIR)
	$(REMOVE)/$(PKG_DIR)
	$(UNTAR)/$(PKG_SOURCE)
	$(CHDIR)/$(PKG_DIR)/Project/GNU/Library; \
		$(TARGET_CONFIGURE); \
		$(MAKE); \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
	$(REWRITE_LIBTOOL)
	$(REMOVE)/$(PKG_DIR)
	$(TOUCH)
