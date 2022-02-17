################################################################################
#
# freetype
#
################################################################################

FREETYPE_VERSION = 2.11.0
FREETYPE_DIR = freetype-$(FREETYPE_VERSION)
FREETYPE_SOURCE = freetype-$(FREETYPE_VERSION).tar.xz
FREETYPE_SITE = https://sourceforge.net/projects/freetype/files/freetype2/$(FREETYPE_VERSION)

$(DL_DIR)/$(FREETYPE_SOURCE):
	$(download) $(FREETYPE_SITE)/$(FREETYPE_SOURCE)

FREETYPE_DEPENDENCIES = zlib libpng

FREETYPE_CONFIG_SCRIPTS = freetype-config

FREETYPE_CONF_OPTS = \
	--enable-shared \
	--disable-static \
	--enable-freetype-config \
	--with-png \
	--with-zlib \
	--without-harfbuzz \
	--without-bzip2

freetype: $(FREETYPE_DEPENDENCIES) $(DL_DIR)/$(FREETYPE_SOURCE) | $(TARGET_DIR)
	$(REMOVE)/$(PKG_DIR)
	$(UNTAR)/$(PKG_SOURCE)
	$(call APPLY_PATCHES,$(PKG_PATCHES_DIR))
	$(CHDIR)/$(PKG_DIR); \
		$(SED) '/^FONT_MODULES += \(type1\|cid\|pfr\|type42\|pcf\|bdf\|winfonts\|cff\)/d' modules.cfg
	$(CHDIR)/$(PKG_DIR)/builds/unix; \
		libtoolize --force --copy; \
		aclocal -I .; \
		autoconf
	$(CHDIR)/$(PKG_DIR); \
		$(CONFIGURE); \
		$(MAKE); \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
	ln -sf freetype2 $(TARGET_includedir)/freetype
	$(REWRITE_CONFIG_SCRIPTS)
	$(REWRITE_LIBTOOL)
	$(REMOVE)/$(PKG_DIR) \
		$(TARGET_datadir)/aclocal
	$(TOUCH)
