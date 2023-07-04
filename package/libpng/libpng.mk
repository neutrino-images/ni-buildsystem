################################################################################
#
# libpng
#
################################################################################

LIBPNG_VERSION = 1.6.40
LIBPNG_DIR = libpng-$(LIBPNG_VERSION)
LIBPNG_SOURCE = libpng-$(LIBPNG_VERSION).tar.xz
LIBPNG_SITE = https://sourceforge.net/projects/libpng/files/libpng16/$(LIBPNG_VERSION)

LIBPNG_DEPENDENCIES = zlib

LIBPNG_CONFIG_SCRIPTS = libpng16-config libpng-config

libpng: | $(TARGET_DIR)
	$(call autotools-package)

# -----------------------------------------------------------------------------

HOST_LIBPNG_DEPENDENCIES = host-zlib

host-libpng: | $(HOST_DIR)
	$(call host-autotools-package)
