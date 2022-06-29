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

$(DL_DIR)/$(LUA_SOURCE):
	$(download) $(LUA_SITE)/ftp/$(LUA_SOURCE)

LUA_DEPENDENCIES = ncurses

lua: $(LUA_DEPENDENCIES) $(DL_DIR)/$(LUA_SOURCE) | $(TARGET_DIR)
	$(REMOVE)/$(LUA_DIR)
	$(UNTAR)/$(LUA_SOURCE)
	$(call APPLY_PATCHES,$(PKG_PATCHES_DIR))
	$(CHDIR)/$(LUA_DIR); \
		$(MAKE) linux \
			PKG_VERSION=$(LUA_VERSION) \
			$(TARGET_CONFIGURE_ENVIRONMENT) \
			AR="$(TARGET_AR) rcu" \
			LDFLAGS="$(TARGET_LDFLAGS)" \
			; \
		$(MAKE) install INSTALL_TOP=$(TARGET_prefix) INSTALL_MAN=$(TARGET_DIR)$(REMOVE_man1dir); \
		$(MAKE) pc INSTALL_TOP=$(TARGET_prefix) > $(TARGET_libdir)/pkgconfig/lua.pc
	$(TARGET_RM) $(TARGET_bindir)/luac
	$(REMOVE)/$(LUA_DIR)
	$(call TOUCH)

# -----------------------------------------------------------------------------

HOST_LUA_VERSION = $(LUA_VERSION)
HOST_LUA_DIR = lua-$(HOST_LUA_VERSION)
HOST_LUA_SOURCE = lua-$(HOST_LUA_VERSION).tar.gz
HOST_LUA_SITE = http://www.lua.org/ftp

#$(DL_DIR)/$(HOST_LUA_SOURCE):
#	$(download) $(HOST_LUA_SITE)/$(HOST_LUA_SOURCE)

HOST_LUA_PATCH  = lua-01-fix-LUA_ROOT.patch
HOST_LUA_PATCH += lua-01-remove-readline.patch

HOST_LUA = $(HOST_DIR)/bin/lua

host-lua: $(DL_DIR)/$(HOST_LUA_SOURCE) | $(HOST_DIR)
	$(REMOVE)/$(PKG_DIR)
	$(UNTAR)/$(PKG_SOURCE)
	$(call APPLY_PATCHES,$(PKG_PATCH))
	$(CHDIR)/$(PKG_DIR); \
		$(MAKE) linux; \
		$(MAKE) install INSTALL_TOP=$(HOST_DIR) INSTALL_MAN=$(HOST_DIR)/share/man/man1
	$(REMOVE)/$(PKG_DIR)
	$(call TOUCH)
