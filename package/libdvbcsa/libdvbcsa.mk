################################################################################
#
# libdvbcsa
#
################################################################################

LIBDVBCSA_VERSION = master
LIBDVBCSA_DIR = libdvbcsa.git
LIBDVBCSA_SOURCE = libdvbcsa.git
LIBDVBCSA_SITE = $(GITHUB)/oe-mirrors
LIBDVBCSA_SITE_METHOD = git

LIBDVBCSA_AUTORECONF = YES

ifeq ($(TARGET_ARCH),arm)
LIBDVBCSA_CONF_OPTS = \
	$(if $(findstring neon,$(TARGET_ABI)),--enable-neon,--disable-neon)
endif

libdvbcsa: | $(TARGET_DIR)
	$(call autotools-package)
