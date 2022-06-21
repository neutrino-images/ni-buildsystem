################################################################################
#
# libzen
#
################################################################################

LIBZEN_VERSION = 0.4.38
LIBZEN_DIR = ZenLib
LIBZEN_SOURCE = libzen_$(LIBZEN_VERSION).tar.bz2
LIBZEN_SITE = https://mediaarea.net/download/source/libzen/$(LIBZEN_VERSION)

LIBZEN_SUBDIR = Project/GNU/Library

LIBZEN_DEPENDENCIES = zlib

LIBZEN_AUTORECONF = YES

libzen: | $(TARGET_DIR)
	$(call autotools-package)
