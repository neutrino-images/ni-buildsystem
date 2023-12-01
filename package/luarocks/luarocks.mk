################################################################################
#
# luarocks
#
################################################################################

LUAROCKS_VERSION = 3.9.2
LUAROCKS_DIR = luarocks-$(LUAROCKS_VERSION)
LUAROCKS_SOURCE = luarocks-$(LUAROCKS_VERSION).tar.gz
LUAROCKS_SITE = https://luarocks.org/releases

# ------------------------------------------------------------------------------

HOST_LUAROCKS_DEPENDENCIES = host-lua

HOST_LUAROCKS_CONFIG_DIR = $(HOST_DIR)/etc
HOST_LUAROCKS_CONFIG_DEFAULT = $(HOST_LUAROCKS_CONFIG_DIR)/luarocks/config-$(LUA_ABIVERSION).lua
HOST_LUAROCKS_CONFIG_HOST = $(HOST_LUAROCKS_CONFIG_DIR)/luarocks/config-host.lua
HOST_LUAROCKS_CONFIG_TARGET = $(HOST_LUAROCKS_CONFIG_DIR)/luarocks/config-target.lua

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
	--prefix=$(HOST_DIR) \
	--sysconfdir=$(HOST_LUAROCKS_CONFIG_DIR) \
	--with-lua=$(HOST_DIR)

define HOST_LUAROCKS_CONFIGURE_CMDS
	$(CD) $(PKG_BUILD_DIR); \
		./configure $(HOST_LUAROCKS_CONF_OPTS)
endef

define HOST_LUAROCKS_CONFIG_REMOVE
	rm -f $(HOST_LUAROCKS_CONFIG)
endef
HOST_LUAROCKS_PRE_BUILD_HOOKS += HOST_LUAROCKS_CONFIG_REMOVE

define HOST_LUAROCKS_CREATE_CONFIGS
	$(INSTALL_DATA) $(HOST_LUAROCKS_CONFIG_DEFAULT) $(HOST_LUAROCKS_CONFIG_HOST)
	$(INSTALL_DATA) $(HOST_LUAROCKS_CONFIG_DEFAULT) $(HOST_LUAROCKS_CONFIG_TARGET)
	$(SED) 's|root = "$(HOST_DIR)"|root = "$(TARGET_DIR)"|' $(HOST_LUAROCKS_CONFIG_TARGET)
	cat $(PKG_FILES_DIR)/config-target.lua >> $(HOST_LUAROCKS_CONFIG_TARGET)
endef
HOST_LUAROCKS_HOST_FINALIZE_HOOKS += HOST_LUAROCKS_CREATE_CONFIGS

HOST_LUAROCKS_BINARY = $(HOST_DIR)/bin/luarocks

host-luarocks: | $(HOST_DIR)
	$(call host-generic-package)
