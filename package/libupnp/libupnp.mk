################################################################################
#
# libupnp
#
################################################################################

LIBUPNP_VERSION = 1.6.25
LIBUPNP_DIR = libupnp-$(LIBUPNP_VERSION)
LIBUPNP_SOURCE = libupnp-$(LIBUPNP_VERSION).tar.bz2
LIBUPNP_SITE = http://sourceforge.net/projects/pupnp/files/pupnp/libUPnP%20$(LIBUPNP_VERSION)

LIBUPNP_CONV_OPTS = \
	--enable-shared \
	--disable-static

libupnp: | $(TARGET_DIR)
	$(call autotools-package)
