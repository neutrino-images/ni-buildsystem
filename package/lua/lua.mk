################################################################################
#
# lua
#
################################################################################

LUA_ABIVERSION = 5.2
LUA_VERSION = 5.2.4
LUA_DIR = lua-$(LUA_VERSION)
LUA_SOURCE = lua-$(LUA_VERSION).tar.gz
LUA_SITE = https://www.lua.org

LUA_DEPENDENCIES = ncurses

LUA_MAKE_ARGS = \
	linux

LUA_MAKE_OPTS = \
	PKG_VERSION=$(LUA_VERSION) \
	$(TARGET_CONFIGURE_ENVIRONMENT) \
	AR="$(TARGET_AR) rcu" \
	LDFLAGS="$(TARGET_LDFLAGS)"

LUA_MAKE_INSTALL_OPTS = \
	INSTALL_TOP=$(TARGET_prefix) \
	INSTALL_MAN=$(TARGET_DIR)$(REMOVE_man1dir)

define LUA_MAKE_PC
	$(CHDIR)/$($(PKG)_DIR); \
		$($(PKG)_MAKE) pc INSTALL_TOP=$(TARGET_prefix) > $(TARGET_libdir)/pkgconfig/lua.pc
endef
LUA_POST_COMPILE_HOOKS += LUA_MAKE_PC

define LUA_TARGET_CLEANUP
	$(TARGET_RM) $(TARGET_bindir)/luac
endef
LUA_TARGET_FINALIZE_HOOKS += LUA_TARGET_CLEANUP

lua: | $(TARGET_DIR)
	$(call generic-package)

# -----------------------------------------------------------------------------

HOST_LUA_VERSION = $(LUA_VERSION)
HOST_LUA_DIR = lua-$(HOST_LUA_VERSION)
HOST_LUA_SOURCE = lua-$(HOST_LUA_VERSION).tar.gz
HOST_LUA_SITE = http://www.lua.org/ftp

HOST_LUA_PATCH  = lua-01-fix-LUA_ROOT.patch
HOST_LUA_PATCH += lua-01-remove-readline.patch

HOST_LUA_MAKE_ARGS = \
	linux

HOST_LUA_MAKE_INSTALL_OPTS = \
	INSTALL_TOP=$(HOST_DIR) \
	INSTALL_MAN=$(HOST_DIR)/share/man/man1

HOST_LUA = $(HOST_DIR)/bin/lua

host-lua: | $(HOST_DIR)
	$(call host-generic-package)
