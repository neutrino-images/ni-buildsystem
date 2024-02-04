################################################################################
#
# libtool
#
################################################################################

LIBTOOL_VERSION = 2.4.7
LIBTOOL_DIR = libtool-$(LIBTOOL_VERSION)
LIBTOOL_SOURCE = libtool-$(LIBTOOL_VERSION).tar.xz
LIBTOOL_SITE = $(GNU_MIRROR)/libtool

# ------------------------------------------------------------------------------

HOST_LIBTOOL_DEPENDENCIES = host-m4

HOST_LIBTOOL_CONF_ENV = \
	MAKEINFO=true

# We have a patch that affects libtool.m4, which triggers an autoreconf
# in the build step. Normally we would set AUTORECONF = YES, but this
# doesn't work for host-libtool because that creates a circular
# dependency. Instead, touch the generated files so autoreconf is not
# triggered in the build step. Note that aclocal.m4 has to be touched
# first since the rest depends on it. Note that we don't need the changes
# in libtool.m4 in our configure script, because we're not actually
# running it on the target.
define HOST_LIBTOOL_AVOID_AUTORECONF_HOOK
	find $(PKG_BUILD_DIR) -name aclocal.m4 -exec touch '{}' \;
	find $(PKG_BUILD_DIR) -name config-h.in -exec touch '{}' \;
	find $(PKG_BUILD_DIR) -name configure -exec touch '{}' \;
	find $(PKG_BUILD_DIR) -name Makefile.in -exec touch '{}' \;
endef
HOST_LIBTOOL_PRE_CONFIGURE_HOOKS += HOST_LIBTOOL_AVOID_AUTORECONF_HOOK

host-libtool: | $(HOST_DIR)
	$(call host-autotools-package)

# ------------------------------------------------------------------------------

# variables used by other packages
LIBTOOL = $(HOST_DIR)/bin/libtool
LIBTOOLIZE = $(HOST_DIR)/bin/libtoolize
