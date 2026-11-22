################################################################################
#
# libwebp
#
################################################################################

LIBWEBP_VERSION = 1.5.0
LIBWEBP_DIR = libwebp-$(LIBWEBP_VERSION)
LIBWEBP_SOURCE = libwebp-$(LIBWEBP_VERSION).tar.gz
LIBWEBP_SITE = https://storage.googleapis.com/downloads.webmproject.org/releases/webp

# the libraries only (webp, webpmux, webpdemux, sharpyuv), no tools
LIBWEBP_CONF_OPTS = \
	--enable-libwebpmux \
	--enable-libwebpdemux \
	--disable-libwebpdecoder \
	--disable-libwebpextras \
	--disable-gl \
	--disable-sdl \
	--disable-png \
	--disable-jpeg \
	--disable-tiff \
	--disable-gif \
	--disable-wic

libwebp: | $(TARGET_DIR)
	$(call autotools-package)
