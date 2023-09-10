################################################################################
#
# luarocks
#
################################################################################

LUAROCKS_VERSION = 3.9.0
LUAROCKS_DIR = luarocks-$(LUAROCKS_VERSION)
LUAROCKS_SOURCE = luarocks-$(LUAROCKS_VERSION).tar.gz
LUAROCKS_SITE = https://luarocks.github.io/luarocks/releases

# ------------------------------------------------------------------------------

HOST_LUAROCKS_DEPENDENCIES = host-lua

HOST_LUAROCKS_CONFIG = $(HOST_DIR)/etc/luarocks/config-$(LUA_ABIVERSION).lua

HOST_LUAROCKS_MAKE_ENV = \
	LUA_PATH="$(HOST_DIR)/share/lua/$(LUA_ABIVERSION)/?.lua" \
	TARGET_CC="$(TARGET_CC)" \
	TARGET_LD="$(TARGET_LD)" \
	TARGET_CFLAGS="$(TARGET_CFLAGS) -fPIC" \
	TARGET_LDFLAGS="-L$(TARGET_libdir)" \
	TARGET_DIR="$(TARGET_DIR)" \
	TARGET_includedir="$(TARGET_includedir)" \
	TARGET_libdir="$(TARGET_libdir)"

HOST_LUAROCKS_CONF_OPTS = \
	--with-lua=$(HOST_DIR) \
	--rocks-tree=$(TARGET_DIR)

define HOST_LUAROCKS_REMOVE_CONFIG
	rm -f $(HOST_LUAROCKS_CONFIG)
endef
HOST_LUAROCKS_POST_PATCH_HOOKS += HOST_LUAROCKS_REMOVE_CONFIG

define HOST_LUAROCKS_CREATE_CONFIG
	cat $(PKG_FILES_DIR)/luarocks-config.lua >> $(HOST_LUAROCKS_CONFIG)
endef
HOST_LUAROCKS_HOST_FINALIZE_HOOKS += HOST_LUAROCKS_CREATE_CONFIG

HOST_LUAROCKS_BINARY = $(HOST_DIR)/bin/luarocks

host-luarocks: | $(HOST_DIR)
	$(call host-autotools-package)
