################################################################################
#
# luaposix
#
################################################################################

LUAPOSIX_VERSION = 36.2.1
LUAPOSIX_DIR = luaposix-$(LUAPOSIX_VERSION)
LUAPOSIX_SOURCE = luaposix-$(LUAPOSIX_VERSION).tar.gz
LUAPOSIX_SITE = $(call github,luaposix,luaposix,v$(LUAPOSIX_VERSION))

LUAPOSIX_DEPENDENCIES = lua

LUAPOSIX_BUILD_OPTS = \
	CC="$(TARGET_CC)" \
	CFLAGS="$(TARGET_CFLAGS)" \
	LUA_INCDIR=$(TARGET_includedir)

LUAPOSIX_INSTALL_OPTS = \
	INST_LIBDIR="$(TARGET_libdir)/lua/$(LUA_ABIVERSION)" \
	INST_LUADIR="$(TARGET_datadir)/lua/$(LUA_ABIVERSION)"

luaposix: | $(TARGET_DIR)
	$(call luke-package)
