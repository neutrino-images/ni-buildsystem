################################################################################
#
# libvorbis
#
################################################################################

LIBVORBIS_VERSION = 1.3.7
LIBVORBIS_DIR = libvorbis-$(LIBVORBIS_VERSION)
LIBVORBIS_SOURCE = libvorbis-$(LIBVORBIS_VERSION).tar.xz
LIBVORBIS_SITE = https://downloads.xiph.org/releases/vorbis

LIBVORBIS_DEPENDENCIES = libogg

LIBVORBIS_AUTORECONF = YES

LIBVORBIS_CONF_OPTS = \
	--datarootdir=$(REMOVE_datarootdir) \
	--disable-docs \
	--disable-examples \
	--disable-oggtest

libvorbis: | $(TARGET_DIR)
	$(call autotools-package)
