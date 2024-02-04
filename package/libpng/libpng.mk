################################################################################
#
# libpng
#
################################################################################

LIBPNG_VERSION = 1.6.41
LIBPNG_SERIES = 16
LIBPNG_DIR = libpng-$(LIBPNG_VERSION)
LIBPNG_SOURCE = libpng-$(LIBPNG_VERSION).tar.xz
LIBPNG_SITE = https://sourceforge.net/projects/libpng/files/libpng$(LIBPNG_SERIES)/$(LIBPNG_VERSION)

LIBPNG_DEPENDENCIES = zlib

LIBPNG_CONFIG_SCRIPTS = libpng$(LIBPNG_SERIES)-config libpng-config

LIBPNG_CONF_OPTS = \
	--disable-tools \
	--disable-powerpc-vsx

libpng: | $(TARGET_DIR)
	$(call autotools-package)

# -----------------------------------------------------------------------------

HOST_LIBPNG_DEPENDENCIES = host-zlib

host-libpng: | $(HOST_DIR)
	$(call host-autotools-package)
