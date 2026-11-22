################################################################################
#
# python2
#
################################################################################

# host only: the chromium 87 build scripts of QtWebEngine 5.15 need
# Python 2.7, which current distributions no longer ship

PYTHON2_VERSION = 2.7.18
PYTHON2_DIR = Python-$(PYTHON2_VERSION)
PYTHON2_SOURCE = Python-$(PYTHON2_VERSION).tar.xz
PYTHON2_SITE = https://www.python.org/ftp/python/$(PYTHON2_VERSION)

# the bundled expat clashes with the newer expat.h of host/include
HOST_PYTHON2_DEPENDENCIES = host-expat

HOST_PYTHON2_CONF_OPTS = \
	--without-ensurepip \
	--disable-shared \
	--with-system-expat

HOST_PYTHON2_BINARY = $(HOST_DIR)/bin/python2.7

# altinstall: python2.7 only, host/bin/python and python3 stay as they are
define HOST_PYTHON2_INSTALL_CMDS
	$(CD) $(PKG_BUILD_DIR); \
		$(HOST_MAKE_ENV) $(MAKE) altinstall
endef

host-python2: | $(HOST_DIR)
	$(call host-autotools-package)
