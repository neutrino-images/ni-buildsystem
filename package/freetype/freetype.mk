################################################################################
#
# freetype
#
################################################################################

FREETYPE_VERSION = 2.13.2
FREETYPE_DIR = freetype-$(FREETYPE_VERSION)
FREETYPE_SOURCE = freetype-$(FREETYPE_VERSION).tar.xz
FREETYPE_SITE = https://sourceforge.net/projects/freetype/files/freetype2/$(FREETYPE_VERSION)

FREETYPE_DEPENDENCIES = libpng zlib

FREETYPE_CONFIG_SCRIPTS = freetype-config

FREETYPE_CONF_OPTS = \
	--enable-shared \
	--disable-static \
	--enable-freetype-config \
	--with-png \
	--with-zlib \
	--without-brotli \
	--without-bzip2 \
	--without-harfbuzz

define FREETYPE_PATCH_MODULES_CFG
	$(SED) '/^FONT_MODULES += \(type1\|cid\|pfr\|type42\|pcf\|bdf\|winfonts\|cff\)/d' $(PKG_BUILD_DIR)/modules.cfg
endef
FREETYPE_POST_PATCH_HOOKS += FREETYPE_PATCH_MODULES_CFG

define FREETYPE_LINKING_INCLUDEDIR
	ln -sf freetype2 $(TARGET_includedir)/freetype
endef
FREETYPE_TARGET_FINALIZE_HOOKS += FREETYPE_LINKING_INCLUDEDIR

define FREETYPE_TARGET_CLEANUP
	$(TARGET_RM) $(TARGET_datadir)/aclocal
endef
FREETYPE_TARGET_FINALIZE_HOOKS += FREETYPE_TARGET_CLEANUP

freetype: | $(TARGET_DIR)
	$(call autotools-package)
