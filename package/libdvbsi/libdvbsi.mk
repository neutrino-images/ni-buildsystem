################################################################################
#
# libdvbsi
#
################################################################################

LIBDVBSI_VERSION = 0.3.9
LIBDVBSI_DIR = libdvbsi++-$(LIBDVBSI_VERSION)
LIBDVBSI_SOURCE = libdvbsi++-$(LIBDVBSI_VERSION).tar.bz2
LIBDVBSI_SITE = https://github.com/mtdcr/libdvbsi/releases/download/$(LIBDVBSI_VERSION)

LIBDVBSI_CONV_OPTS = \
	--enable-shared \
	--disable-static

libdvbsi: | $(TARGET_DIR)
	$(call autotools-package)
