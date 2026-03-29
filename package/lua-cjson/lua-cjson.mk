################################################################################
#
# lua-cjson
#
################################################################################

LUA_CJSON_VERSION = 2.1.0.10-1
LUA_CJSON_DIR = lua-cjson-$(LUA_CJSON_VERSION)
LUA_CJSON_SOURCE = lua-cjson-$(LUA_CJSON_VERSION).src.rock
LUA_CJSON_SITE = $(LUAROCKS_MIRROR)

LUA_CJSON_ROCKSPEC = lua-cjson-$(LUA_CJSON_VERSION).rockspec
LUA_CJSON_SUBDIR = lua-cjson

define LUA_CJSON_TARGET_CLEANUP
	$(TARGET_RM) $(TARGET_libdir)/luarocks
endef
LUA_CJSON_TARGET_FINALIZE_HOOKS += LUA_CJSON_TARGET_CLEANUP

lua-cjson: | $(TARGET_DIR)
	$(call luarocks-package)
