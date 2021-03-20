################################################################################
#
# libass
#
################################################################################

LIBASS_VERSION = 0.14.0
LIBASS_DIR = libass-$(LIBASS_VERSION)
LIBASS_SOURCE = libass-$(LIBASS_VERSION).tar.xz
LIBASS_SITE = https://github.com/libass/libass/releases/download/$(LIBASS_VERSION)

LIBASS_DEPENDENCIES = freetype fribidi

LIBASS_CONF_OPTS = \
	--disable-static \
	--disable-test \
	--disable-fontconfig \
	--disable-harfbuzz \
	--disable-require-system-font-provider

libass: | $(TARGET_DIR)
	$(call autotools-package)
