################################################################################
#
# autoconf
#
################################################################################

AUTOCONF_VERSION = 2.71
AUTOCONF_DIR = autoconf-$(AUTOCONF_VERSION)
AUTOCONF_SOURCE = autoconf-$(AUTOCONF_VERSION).tar.xz
AUTOCONF_SITE = $(GNU_MIRROR)/autoconf

# ------------------------------------------------------------------------------

HOST_AUTOCONF_DEPENDENCIES = host-m4 host-libtool

HOST_AUTOCONF_CONF_ENV = \
	EMACS="no" \
	ac_cv_path_M4=$(HOST_DIR)/bin/m4 \
	ac_cv_prog_gnu_m4_gnu=no

host-autoconf: | $(HOST_DIR)
	$(call host-autotools-package)

# ------------------------------------------------------------------------------

# variables used by other packages
AUTOCONF = $(HOST_DIR)/bin/autoconf -I "$(ACLOCAL_DIR)" -I "$(ACLOCAL_HOST_DIR)"
AUTOHEADER = $(HOST_DIR)/bin/autoheader -I "$(ACLOCAL_DIR)" -I "$(ACLOCAL_HOST_DIR)"
AUTORECONF = $(HOST_CONFIGURE_ENV) ACLOCAL="$(ACLOCAL)" \
	AUTOCONF="$(AUTOCONF)" AUTOHEADER="$(AUTOHEADER)" \
	AUTOMAKE="$(AUTOMAKE)" GTKDOCIZE=/bin/true \
	$(HOST_DIR)/bin/autoreconf -f -i
