################################################################################
#
# fontconfig
#
################################################################################

FONTCONFIG_VERSION = 2.14.0
FONTCONFIG_DIR = fontconfig-$(FONTCONFIG_VERSION)
FONTCONFIG_SOURCE = fontconfig-$(FONTCONFIG_VERSION).tar.xz
FONTCONFIG_SITE = https://www.freedesktop.org/software/fontconfig/release

FONTCONFIG_DEPENDENCIES = freetype expat

FONTCONFIG_CONF_OPTS = \
	--bindir=$(REMOVE_bindir) \
	--datarootdir=$(REMOVE_datarootdir) \
	--sysconfdir=$(REMOVE_sysconfdir) \
	--with-arch=$(GNU_TARGET_NAME) \
	--with-cache-dir=/var/cache/fontconfig \
	--with-freetype-config=$(HOST_DIR)/bin/freetype-config \
	--with-expat-includes=$(TARGET_includedir) \
	--with-expat-lib=$(TARGET_libdir) \
	--disable-docs

fontconfig: | $(TARGET_DIR)
	$(call autotools-package)
