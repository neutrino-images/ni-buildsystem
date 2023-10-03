################################################################################
#
# zlib
#
################################################################################

ZLIB_VERSION = 1.3
ZLIB_DIR = zlib-$(ZLIB_VERSION)
ZLIB_SOURCE = zlib-$(ZLIB_VERSION).tar.xz
ZLIB_SITE = https://zlib.net

ZLIB_CONF_ENV = \
	$(TARGET_CONFIGURE_ENV) \
	CFLAGS="$(TARGET_CFLAGS) -fPIC" \
	mandir=$(REMOVE_mandir)

ZLIB_CONF_OPTS = \
	--prefix=$(prefix) \
	--shared \
	--uname=Linux

define ZLIB_CONFIGURE_CMDS
	$(CD) $(PKG_BUILD_DIR); \
		$($(PKG)_CONF_ENV) ./configure $($(PKG)_CONF_OPTS)
endef

zlib: | $(TARGET_DIR)
	$(call generic-package)

# -----------------------------------------------------------------------------

HOST_ZLIB_CONF_ENV = \
	$(HOST_CONFIGURE_ENV)

HOST_ZLIB_CONF_OPTS = \
	--prefix=$(HOST_DIR) \
	--shared \
	--uname=Linux

define HOST_ZLIB_CONFIGURE_CMDS
	$(CD) $(PKG_BUILD_DIR); \
		$($(PKG)_CONF_ENV) ./configure $($(PKG)_CONF_OPTS)
endef

host-zlib: | $(HOST_DIR)
	$(call host-generic-package)
