################################################################################
#
# libmediainfo
#
################################################################################

LIBMEDIAINFO_VERSION = 22.03
LIBMEDIAINFO_DIR = MediaInfoLib
LIBMEDIAINFO_SOURCE = libmediainfo_$(LIBMEDIAINFO_VERSION).tar.bz2
LIBMEDIAINFO_SITE = https://mediaarea.net/download/source/libmediainfo/$(LIBMEDIAINFO_VERSION)

LIBMEDIAINFO_SUBDIR = Project/GNU/Library

LIBMEDIAINFO_DEPENDENCIES = libzen

LIBMEDIAINFO_AUTORECONF = YES

libmediainfo: | $(TARGET_DIR)
	$(call autotools-package)
