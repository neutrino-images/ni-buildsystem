################################################################################
#
# luaposix
#
################################################################################

LUAPOSIX_VERSION = 31
LUAPOSIX_DIR = luaposix-$(LUAPOSIX_VERSION)
LUAPOSIX_SOURCE = luaposix-$(LUAPOSIX_VERSION).tar.gz
LUAPOSIX_SITE = https://github.com/luaposix/luaposix/archive

LUAPOSIX_DEPENDENCIES = $(HOST_LUA) lua luaexpat gnulib slingshot

LUAPOSIX_AUTORECONF = YES

LUAPOSIX_CONF_ENV = \
	LUA=$(HOST_LUA)

LUAPOSIX_CONF_OPTS = \
	--libdir=$(libdir)/lua/$(LUA_ABIVERSION) \
	--datadir=$(datadir)/lua/$(LUA_ABIVERSION) \
	--mandir=$(REMOVE_mandir) \
	--docdir=$(REMOVE_docdir)

define LUAPOSIX_UNPACK_GNULIB
	tar -C $(PKG_BUILD_DIR)/gnulib --strip=1 -xf $(DL_DIR)/$(GNULIB_SOURCE)
endef
LUAPOSIX_POST_PATCH_HOOKS += LUAPOSIX_UNPACK_GNULIB

define LUAPOSIX_UNPACK_SLINGSHOT
	tar -C $(PKG_BUILD_DIR)/slingshot --strip=1 -xf $(DL_DIR)/$(SLINGSHOT_SOURCE)
endef
LUAPOSIX_POST_PATCH_HOOKS += LUAPOSIX_UNPACK_SLINGSHOT

define LUAPOSIX_BOOTSTRAP
	$(CHDIR)/$($(PKG)_DIR); \
		./bootstrap
endef
LUAPOSIX_PRE_CONFIGURE_HOOKS += LUAPOSIX_BOOTSTRAP

luaposix: | $(TARGET_DIR)
	$(call autotools-package)
