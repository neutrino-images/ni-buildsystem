################################################################################
#
# fontconfig
#
################################################################################

FONTCONFIG_VERSION = 2.11.93
FONTCONFIG_DIR = fontconfig-$(FONTCONFIG_VERSION)
FONTCONFIG_SOURCE = fontconfig-$(FONTCONFIG_VERSION).tar.bz2
FONTCONFIG_SITE = https://www.freedesktop.org/software/fontconfig/release

FONTCONFIG_DEPENDENCIES = freetype expat

FONTCONFIG_CONF_OPTS = \
	--with-freetype-config=$(HOST_DIR)/bin/freetype-config \
	--with-expat-includes=$(TARGET_includedir) \
	--with-expat-lib=$(TARGET_libdir) \
	--disable-docs

fontconfig: | $(TARGET_DIR)
	$(call autotools-package)
