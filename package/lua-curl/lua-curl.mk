################################################################################
#
# lua-curl
#
################################################################################

LUA_CURL_VERSION = master
LUA_CURL_DIR = lua-curlv3.git
LUA_CURL_SOURCE = lua-curlv3.git
LUA_CURL_SITE = https://github.com/lua-curl
LUA_CURL_SITE_METHOD = git

LUA_CURL_DEPENDENCIES = libcurl lua

LUA_CURL_MAKE_ENV = \
	$(TARGET_CONFIGURE_ENV)

LUA_CURL_MAKE_OPTS = \
	LIBDIR=$(TARGET_libdir) \
	LUA_INC=$(TARGET_includedir) \
	LUA_CMOD=$(libdir)/lua/$(LUA_ABIVERSION) \
	LUA_LMOD=$(datadir)/lua/$(LUA_ABIVERSION)

lua-curl: | $(TARGET_DIR)
	$(call generic-package)
