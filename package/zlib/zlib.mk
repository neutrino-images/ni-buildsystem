################################################################################
#
# zlib
#
################################################################################

ZLIB_VERSION = 1.2.11
ZLIB_DIR = zlib-$(ZLIB_VERSION)
ZLIB_SOURCE = zlib-$(ZLIB_VERSION).tar.xz
ZLIB_SITE = https://sourceforge.net/projects/libpng/files/zlib/$(ZLIB_VERSION)

ZLIB_CONF_ENV = \
	$(TARGET_CONFIGURE_ENV) \
	mandir=$(REMOVE_mandir)

ZLIB_CONF_OPTS = \
	--prefix=$(prefix) \
	--shared \
	--uname=Linux

define ZLIB_CONFIGURE_CMDS
	$(CHDIR)/$($(PKG)_DIR); \
		$($(PKG)_CONF_ENV) ./configure $($(PKG)_CONF_OPTS)
endef

zlib: | $(TARGET_DIR)
	$(call autotools-package)

# -----------------------------------------------------------------------------

HOST_ZLIB_VERSION = $(ZLIB_VERSION)
HOST_ZLIB_DIR = $(ZLIB_DIR)
HOST_ZLIB_SOURCE = $(ZLIB_SOURCE)
HOST_ZLIB_SITE = $(ZLIB_SITE)

HOST_ZLIB_CONF_ENV = \
	$(HOST_CONFIGURE_ENV)

HOST_ZLIB_CONF_OPTS = \
	--prefix="" \
	--shared \
	--uname=Linux

define HOST_ZLIB_CONFIGURE_CMDS
	$(CHDIR)/$($(PKG)_DIR); \
		$($(PKG)_CONF_ENV) ./configure $($(PKG)_CONF_OPTS)
endef

host-zlib: | $(HOST_DIR)
	$(call host-autotools-package)
