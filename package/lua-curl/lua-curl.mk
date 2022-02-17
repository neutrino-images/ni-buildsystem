################################################################################
#
# lua-curl
#
################################################################################

LUA_CURL_VERSION = git
LUA_CURL_DIR = lua-curlv3.$(LUA_CURL_VERSION)
LUA_CURL_SOURCE = lua-curlv3.$(LUA_CURL_VERSION)
LUA_CURL_SITE = https://github.com/lua-curl/$(LUA_CURL_SOURCE)

LUA_CURL_DEPENDENCIES = libcurl lua

LUA_CURL_MAKE_ENV = \
	$(TARGET_CONFIGURE_ENV)

LUA_CURL_MAKE_OPTS = \
	LIBDIR=$(TARGET_libdir) \
	LUA_INC=$(TARGET_includedir) \
	LUA_CMOD=$(libdir)/lua/$(LUA_ABIVERSION) \
	LUA_LMOD=$(datadir)/lua/$(LUA_ABIVERSION)

lua-curl: $(LUA_CURL_DEPENDENCIES) | $(TARGET_DIR)
	$(REMOVE)/$(PKG_DIR)
	$(GET_GIT_SOURCE) $(PKG_SITE) $(DL_DIR)/$(PKG_SOURCE)
	$(CPDIR)/$(PKG_SOURCE)
	$(CHDIR)/$(PKG_DIR); \
		$($(PKG)_MAKE_ENV) $(MAKE) $($(PKG)_MAKE_OPTS); \
		$($(PKG)_MAKE_ENV) $(MAKE) $($(PKG)_MAKE_OPTS) install DESTDIR=$(TARGET_DIR)
	$(REMOVE)/$(PKG_DIR)
	$(TOUCH)
