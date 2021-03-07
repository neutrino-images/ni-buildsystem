#
# makefile to build lua libs/tools
#
# -----------------------------------------------------------------------------

LUA_ABIVERSION = 5.2
LUA_VERSION = 5.2.4
LUA_DIR = lua-$(LUA_VERSION)
LUA_SOURCE = lua-$(LUA_VERSION).tar.gz
LUA_SITE = https://www.lua.org

$(DL_DIR)/$(LUA_SOURCE):
	$(DOWNLOAD) $(LUA_SITE)/ftp/$(LUA_SOURCE)

LUA_DEPENDENCIES = ncurses

lua: $(LUA_DEPENDENCIES) $(DL_DIR)/$(LUA_SOURCE) | $(TARGET_DIR)
	$(REMOVE)/$(LUA_DIR)
	$(UNTAR)/$(LUA_SOURCE)
	$(CHDIR)/$(LUA_DIR); \
		$(APPLY_PATCHES); \
		$(MAKE) linux \
			PKG_VERSION=$(LUA_VERSION) \
			$(TARGET_MAKE_OPTS) \
			AR="$(TARGET_AR) rcu" \
			LDFLAGS="$(TARGET_LDFLAGS)" \
			; \
		$(MAKE) install INSTALL_TOP=$(TARGET_prefix) INSTALL_MAN=$(TARGET_DIR)$(REMOVE_man1dir); \
		$(MAKE) pc INSTALL_TOP=$(TARGET_prefix) > $(TARGET_libdir)/pkgconfig/lua.pc
	rm -rf $(TARGET_bindir)/luac
	$(REMOVE)/$(LUA_DIR)
	$(TOUCH)

# -----------------------------------------------------------------------------

LUAEXPAT_VERSION = 1.3.3
LUAEXPAT_DIR = luaexpat-$(LUAEXPAT_VERSION)
LUAEXPAT_SOURCE = luaexpat-$(LUAEXPAT_VERSION).tar.gz
LUAEXPAT_SITE = https://github.com/tomasguisasola/luaexpat/archive

$(DL_DIR)/$(LUAEXPAT_SOURCE):
	$(DOWNLOAD) $(LUAEXPAT_SITE)/v$(LUAEXPAT_VERSION).tar.gz -O $(@)

LUAEXPAT_DEPENDENCIES = expat lua

LUAEXPAT_MAKE_ENV = \
	$(TARGET_CONFIGURE_ENV)

LUAEXPAT_MAKE_OPTS = \
	PREFIX=$(TARGET_prefix) \
	LUA_SYS_VER=$(LUA_ABIVERSION)

luaexpat: $(LUAEXPAT_DEPENDENCIES) $(DL_DIR)/$(LUAEXPAT_SOURCE) | $(TARGET_DIR)
	$(REMOVE)/$(PKG_DIR)
	$(UNTAR)/$(PKG_SOURCE)
	$(CHDIR)/$(PKG_DIR); \
		$(SED) 's|^EXPAT_INC=.*|EXPAT_INC= $(TARGET_includedir)|' makefile; \
		$(SED) 's|^CFLAGS =.*|& -L$(TARGET_libdir)|' makefile; \
		$(SED) 's|^CC =.*|CC = $(TARGET_CC)|' makefile; \
		$($(PKG)_MAKE_ENV) $(MAKE) $($(PKG)_MAKE_OPTS); \
		$($(PKG)_MAKE_ENV) $(MAKE) $($(PKG)_MAKE_OPTS) install
	$(REMOVE)/$(PKG_DIR)
	$(TOUCH)

# -----------------------------------------------------------------------------

LUA_FEEDPARSER_VERSION = 0.71
LUA_FEEDPARSER_DIR = lua-feedparser-$(LUA_FEEDPARSER_VERSION)
LUA_FEEDPARSER_SOURCE = lua-feedparser-$(LUA_FEEDPARSER_VERSION).tar.gz
LUA_FEEDPARSER_SITE = https://github.com/slact/lua-feedparser/archive

$(DL_DIR)/$(LUA_FEEDPARSER_SOURCE):
	$(DOWNLOAD) $(LUA_FEEDPARSER_SITE)/$(LUA_FEEDPARSER_VERSION).tar.gz -O $(@)

LUA_FEEDPARSER_DEPENDENCIES = luaexpat

lua-feedparser: $(LUA-DEEDPARSER_DEPENDENCIES) $(DL_DIR)/$(LUA_FEEDPARSER_SOURCE) | $(TARGET_DIR)
	$(REMOVE)/$(PKG_DIR)
	$(UNTAR)/$(PKG_SOURCE)
	$(CHDIR)/$(PKG_DIR); \
		$(SED) 's|^PREFIX =|PREFIX ?=|' Makefile; \
		$(APPLY_PATCHES); \
		$(MAKE) install PREFIX=$(TARGET_prefix)
	$(REMOVE)/$(PKG_DIR)
	$(TOUCH)

# -----------------------------------------------------------------------------

LUAJSON_SOURCE = JSON.lua
LUAJSON_SITE = http://regex.info/code

$(DL_DIR)/$(LUAJSON_SOURCE):
	$(DOWNLOAD) $(LUAJSON_SITE)/$(LUAJSON_SOURCE)

luajson: $(DL_DIR)/$(LUAJSON_SOURCE) | $(TARGET_DIR)
	$(CD) $(DL_DIR); \
		curl --remote-name --time-cond $(PKG_SOURCE) $(PKG_SITE)/$(PKG_SOURCE) || true
	$(INSTALL_DATA) -D $(DL_DIR)/$(PKG_SOURCE) $(TARGET_datadir)/lua/$(LUA_ABIVERSION)
	ln -sf $(PKG_SOURCE) $(TARGET_datadir)/lua/$(LUA_ABIVERSION)/json.lua
	$(TOUCH)

# -----------------------------------------------------------------------------

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
	$(GET-GIT-SOURCE) $(PKG_SITE) $(DL_DIR)/$(PKG_SOURCE)
	$(CPDIR)/$(PKG_SOURCE)
	$(CHDIR)/$(PKG_DIR); \
		$($(PKG)_MAKE_ENV) $(MAKE) $($(PKG)_MAKE_OPTS); \
		$($(PKG)_MAKE_ENV) $(MAKE) $($(PKG)_MAKE_OPTS) install DESTDIR=$(TARGET_DIR)
	$(REMOVE)/$(PKG_DIR)
	$(TOUCH)

# -----------------------------------------------------------------------------

LUAPOSIX_VERSION = 31
LUAPOSIX_DIR = luaposix-$(LUAPOSIX_VERSION)
LUAPOSIX_SOURCE = luaposix-$(LUAPOSIX_VERSION).tar.gz
LUAPOSIX_SITE = https://github.com/luaposix/luaposix/archive

$(DL_DIR)/$(LUAPOSIX_SOURCE):
	$(DOWNLOAD) $(LUAPOSIX_SITE)/v$(LUAPOSIX_VERSION).tar.gz -O $(@)

LUAPOSIX_DEPENDENCIES = $(HOST_LUA) lua luaexpat

LUAPOSIX_AUTORECONF = YES

LUAPOSIX_CONF_ENV = \
	LUA=$(HOST_LUA)

LUAPOSIX_CONF_OPTS = \
	--libdir=$(TARGET_libdir)/lua/$(LUA_ABIVERSION) \
	--datadir=$(TARGET_datadir)/lua/$(LUA_ABIVERSION) \
	--mandir=$(TARGET_DIR)$(REMOVE_mandir) \
	--docdir=$(TARGET_DIR)$(REMOVE_docdir) \
	--enable-silent-rules

GNULIB_VERSION = 20140202
GNULIB_SOURCE = gnulib-$(GNULIB_VERSION)-stable.tar.gz
GNULIB_SITE = http://erislabs.net/ianb/projects/gnulib

$(DL_DIR)/$(GNULIB_SOURCE):
	$(DOWNLOAD) $(GNULIB_SITE)/$(GNULIB_SOURCE)

SLINGSHOT_VERSION = 6
SLINGSHOT_SOURCE = slingshot-$(SLINGSHOT_VERSION).tar.gz
SLINGSHOT_SITE = https://github.com/gvvaughan/slingshot/archive

$(DL_DIR)/$(SLINGSHOT_SOURCE):
	$(DOWNLOAD) $(SLINGSHOT_SITE)/v$(SLINGSHOT_VERSION).tar.gz -O $(@)

luaposix: $(LUAPOSIX_DEPENDENCIES) $(DL_DIR)/$(SLINGSHOT_SOURCE) $(DL_DIR)/$(GNULIB_SOURCE) $(DL_DIR)/$(LUAPOSIX_SOURCE) | $(TARGET_DIR)
	$(REMOVE)/$(PKG_DIR)
	$(UNTAR)/$(PKG_SOURCE)
	$(CHDIR)/$(PKG_DIR); \
		tar -C gnulib --strip=1 -xf $(DL_DIR)/$(GNULIB_SOURCE); \
		tar -C slingshot --strip=1 -xf $(DL_DIR)/$(SLINGSHOT_SOURCE); \
		$(APPLY_PATCHES); \
		./bootstrap; \
		$(CONFIGURE); \
		$(MAKE); \
		$(MAKE) install
	$(REMOVE)/$(PKG_DIR)
	$(TOUCH)
