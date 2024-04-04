################################################################################
#
# libpng
#
################################################################################

LIBPNG_VERSION = 1.6.43
LIBPNG_SERIES = 16
LIBPNG_DIR = libpng-$(LIBPNG_VERSION)
LIBPNG_SOURCE = libpng-$(LIBPNG_VERSION).tar.xz
LIBPNG_SITE = https://sourceforge.net/projects/libpng/files/libpng$(LIBPNG_SERIES)/$(LIBPNG_VERSION)

LIBPNG_DEPENDENCIES = zlib

LIBPNG_CONFIG_SCRIPTS = libpng$(LIBPNG_SERIES)-config libpng-config

LIBPNG_CONF_OPTS = \
	--disable-tools \
	--disable-intel-sse \
	--disable-powerpc-vsx

ifeq ($(TARGET_ARCH),arm)
LIBPNG_CONF_OPTS = \
	$(if $(findstring neon,$(TARGET_ABI)),--enable-arm-neon,--disable-arm-neon)
endif

libpng: | $(TARGET_DIR)
	$(call autotools-package)

# -----------------------------------------------------------------------------

HOST_LIBPNG_DEPENDENCIES = host-zlib

host-libpng: | $(HOST_DIR)
	$(call host-autotools-package)
