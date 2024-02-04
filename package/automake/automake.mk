################################################################################
#
# automake
#
################################################################################

AUTOMAKE_VERSION = 1.16.5
AUTOMAKE_DIR = automake-$(AUTOMAKE_VERSION)
AUTOMAKE_SOURCE = automake-$(AUTOMAKE_VERSION).tar.xz
AUTOMAKE_SITE = $(GNU_MIRROR)/automake

# ------------------------------------------------------------------------------

HOST_AUTOMAKE_DEPENDENCIES = host-autoconf

ACLOCAL_HOST_DIR = $(HOST_DIR)/share/aclocal

define HOST_AUTOMAKE_INSTALL_GTK_DOC_M4
	$(INSTALL_DATA) -D $(PKG_FILES_DIR)/gtk-doc.m4 $(ACLOCAL_HOST_DIR)/gtk-doc.m4
endef
HOST_AUTOMAKE_POST_INSTALL_HOOKS += HOST_AUTOMAKE_INSTALL_GTK_DOC_M4

# ensure target aclocal dir exists
define HOST_AUTOMAKE_MAKE_ACLOCAL
	mkdir -p $(ACLOCAL_DIR)
endef
HOST_AUTOMAKE_POST_INSTALL_HOOKS += HOST_AUTOMAKE_MAKE_ACLOCAL

host-automake: | $(HOST_DIR)
	$(call host-autotools-package)

# ------------------------------------------------------------------------------

# variables used by other packages
AUTOMAKE = $(HOST_DIR)/bin/automake
ACLOCAL_DIR = $(TARGET_DIR)/usr/share/aclocal
ACLOCAL = $(HOST_DIR)/bin/aclocal
ACLOCAL_PATH = $(ACLOCAL_DIR):$(ACLOCAL_HOST_DIR)
export ACLOCAL_PATH
