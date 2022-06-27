################################################################################
#
# libarchive
#
################################################################################

LIBARCHIVE_VERSION = 3.6.1
LIBARCHIVE_DIR = libarchive-$(LIBARCHIVE_VERSION)
LIBARCHIVE_SOURCE = libarchive-$(LIBARCHIVE_VERSION).tar.gz
LIBARCHIVE_SITE = https://www.libarchive.org/downloads

LIBARCHIVE_CONF_OPTS = \
	--enable-static=no \
	--disable-bsdtar \
	--disable-bsdcpio \
	--disable-bsdcat \
	--disable-acl \
	--disable-xattr \
	--without-bz2lib \
	--without-expat \
	--without-libiconv-prefix \
	--without-xml2 \
	--without-lz4 \
	--without-lzo2 \
	--without-mbedtls \
	--without-nettle \
	--without-openssl \
	--without-zlib \
	--without-lzma \
	--without-zstd

libarchive: | $(TARGET_DIR)
	$(call autotools-package)
