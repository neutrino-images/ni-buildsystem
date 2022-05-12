################################################################################
#
# libupnp
#
################################################################################

LIBUPNP_VERSION = 1.14.12
LIBUPNP_DIR = libupnp-$(LIBUPNP_VERSION)
LIBUPNP_SOURCE = libupnp-$(LIBUPNP_VERSION).tar.bz2
LIBUPNP_SITE = http://downloads.sourceforge.net/project/pupnp/release-$(LIBUPNP_VERSION)

LIBUPNP_DEPENDENCIES += openssl

LIBUPNP_CONF_ENV = \
	ac_cv_lib_compat_ftime=no

# Bind the internal miniserver socket with reuseaddr to allow clean restarts.
LIBUPNP_CONF_OPTS = \
	--disable-samples \
	--enable-open-ssl \
	--enable-reuseaddr

libupnp: | $(TARGET_DIR)
	$(call autotools-package)
