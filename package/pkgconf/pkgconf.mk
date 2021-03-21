################################################################################
#
# pkgconf
#
################################################################################

PKGCONF_VERSION = 1.7.3
PKGCONF_DIR = pkgconf-$(PKGCONF_VERSION)
PKGCONF_SOURCE = pkgconf-$(PKGCONF_VERSION).tar.gz
PKGCONF_SITE = https://distfiles.dereferenced.org/pkgconf

# -----------------------------------------------------------------------------

HOST_PKGCONF_VERSION = $(PKGCONF_VERSION)
HOST_PKGCONF_DIR = $(PKGCONF_DIR)
HOST_PKGCONF_SOURCE = $(PKGCONF_SOURCE)
HOST_PKGCONF_SITE = $(PKGCONF_SITE)

HOST_PKG_CONFIG = $(HOST_DIR)/bin/pkg-config

define HOST_PKGCONF_INSTALL_PKG_CONFIG
	$(INSTALL_EXEC) $(PKG_FILES_DIR)/pkg-config.in $(HOST_PKG_CONFIG)
endef
HOST_PKGCONF_HOST_FINALIZE_HOOKS += HOST_PKGCONF_INSTALL_PKG_CONFIG

host-pkgconf: | $(HOST_DIR)
	$(call host-autotools-package)
