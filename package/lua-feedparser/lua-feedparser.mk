################################################################################
#
# lua-feedparser
#
################################################################################

LUA_FEEDPARSER_VERSION = 0.71
LUA_FEEDPARSER_DIR = lua-feedparser-$(LUA_FEEDPARSER_VERSION)
LUA_FEEDPARSER_SOURCE = lua-feedparser-$(LUA_FEEDPARSER_VERSION).tar.gz
LUA_FEEDPARSER_SITE = $(call github,slact,lua-feedparser,$(LUA_FEEDPARSER_VERSION))

LUA_FEEDPARSER_DEPENDENCIES = luaexpat

LUA_FEEDPARSER_MAKE_OPTS = \
	PREFIX=$(TARGET_prefix)

define LUA_FEEDPARSER_PATCH_MAKEFILE
	$(SED) 's|^PREFIX =|PREFIX ?=|' $(PKG_BUILD_DIR)/Makefile
endef
LUA_FEEDPARSER_POST_PATCH_HOOKS += LUA_FEEDPARSER_PATCH_MAKEFILE

lua-feedparser: | $(TARGET_DIR)
	$(call generic-package)
