################################################################################
#
# luaexpat
#
################################################################################

LUAEXPAT_VERSION = 1.5.1-1
LUAEXPAT_DIR = luaexpat-$(LUAEXPAT_VERSION)
LUAEXPAT_SOURCE = luaexpat-$(LUAEXPAT_VERSION).src.rock
LUAEXPAT_SITE = $(LUAROCKS_MIRROR)

LUAEXPAT_ROCKSPEC = luaexpat-$(LUAEXPAT_VERSION).rockspec
LUAEXPAT_SUBDIR = luaexpat

LUAEXPAT_DEPENDENCIES = expat

define LUAEXPAT_TARGET_CLEANUP
	$(TARGET_RM) $(TARGET_libdir)/luarocks
endef
LUAEXPAT_TARGET_FINALIZE_HOOKS += LUAEXPAT_TARGET_CLEANUP

luaexpat: | $(TARGET_DIR)
	$(call luarocks-package)
