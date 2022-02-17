################################################################################
#
# lua-feedparser
#
################################################################################

LUA_FEEDPARSER_VERSION = 0.71
LUA_FEEDPARSER_DIR = lua-feedparser-$(LUA_FEEDPARSER_VERSION)
LUA_FEEDPARSER_SOURCE = lua-feedparser-$(LUA_FEEDPARSER_VERSION).tar.gz
LUA_FEEDPARSER_SITE = https://github.com/slact/lua-feedparser/archive

$(DL_DIR)/$(LUA_FEEDPARSER_SOURCE):
	$(download) $(LUA_FEEDPARSER_SITE)/$(LUA_FEEDPARSER_VERSION).tar.gz -O $(@)

LUA_FEEDPARSER_DEPENDENCIES = luaexpat

lua-feedparser: $(LUA_FEEDPARSER_DEPENDENCIES) $(DL_DIR)/$(LUA_FEEDPARSER_SOURCE) | $(TARGET_DIR)
	$(REMOVE)/$(PKG_DIR)
	$(UNTAR)/$(PKG_SOURCE)
	$(call APPLY_PATCHES,$(PKG_PATCHES_DIR))
	$(CHDIR)/$(PKG_DIR); \
		$(SED) 's|^PREFIX =|PREFIX ?=|' Makefile; \
		$(MAKE) install PREFIX=$(TARGET_prefix)
	$(REMOVE)/$(PKG_DIR)
	$(TOUCH)
