################################################################################
#
# libbluray
#
################################################################################

LIBBLURAY_VERSION = 0.9.3
LIBBLURAY_DIR = libbluray-$(LIBBLURAY_VERSION)
LIBBLURAY_SOURCE = libbluray-$(LIBBLURAY_VERSION).tar.bz2
LIBBLURAY_SITE = ftp.videolan.org/pub/videolan/libbluray/$(LIBBLURAY_VERSION)

$(DL_DIR)/$(LIBBLURAY_SOURCE):
	$(download) $(LIBBLURAY_SITE)/$(LIBBLURAY_SOURCE)

LIBBLURAY_DEPENDENCIES = freetype
ifeq ($(BOXSERIES),hd2)
  LIBBLURAY_DEPENDENCIES += libaacs libbdplus
endif

LIBBLURAY_CONF_OPTS = \
	--enable-shared \
	--disable-static \
	--disable-extra-warnings \
	--disable-doxygen-doc \
	--disable-doxygen-dot \
	--disable-doxygen-html \
	--disable-doxygen-ps \
	--disable-doxygen-pdf \
	--disable-examples \
	--disable-bdjava \
	--without-libxml2 \
	--without-fontconfig

libbluray: $(LIBBLURAY_DEPENDENCIES) $(DL_DIR)/$(LIBBLURAY_SOURCE) | $(TARGET_DIR)
	$(REMOVE)/$(PKG_DIR)
	$(UNTAR)/$(PKG_SOURCE)
	$(call APPLY_PATCHES,$(PKG_PATCHES_DIR))
	$(CHDIR)/$(PKG_DIR); \
		./bootstrap; \
		$(CONFIGURE); \
		$(MAKE); \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
	$(REWRITE_LIBTOOL)
	$(REMOVE)/$(PKG_DIR)
	$(TOUCH)
