#
# makefile to build lua libs/tools
#
# -----------------------------------------------------------------------------

LUA_ABIVER = 5.2
LUA_VER    = 5.2.4
LUA_DIR    = lua-$(LUA_VER)
LUA_SOURCE = lua-$(LUA_VER).tar.gz
LUA_SITE   = https://www.lua.org

$(DL_DIR)/$(LUA_SOURCE):
	$(DOWNLOAD) $(LUA_SITE)/ftp/$(LUA_SOURCE)

LUA_PATCH  = lua-01-fix-LUA_ROOT.patch
LUA_PATCH += lua-01-remove-readline.patch
LUA_PATCH += lua-02-shared-libs-for-lua.patch
LUA_PATCH += lua-03-lua-pc.patch
LUA_PATCH += lua-04-crashfix.diff

LUA_DEPS   = ncurses

lua: $(LUA_DEPS) $(DL_DIR)/$(LUA_SOURCE) | $(TARGET_DIR)
	$(REMOVE)/$(LUA_DIR)
	$(UNTAR)/$(LUA_SOURCE)
	$(CHDIR)/$(LUA_DIR); \
		$(call apply_patches,$(LUA_PATCH)); \
		$(MAKE) linux \
			PKG_VERSION=$(LUA_VER) \
			$(MAKE_OPTS) \
			AR="$(TARGET_AR) rcu" \
			LDFLAGS="$(TARGET_LDFLAGS)" \
			; \
		$(MAKE) install INSTALL_TOP=$(TARGET_prefix) INSTALL_MAN=$(TARGET_DIR)$(REMOVE_man1dir); \
		$(MAKE) pc INSTALL_TOP=$(TARGET_prefix) > $(PKG_CONFIG_PATH)/lua.pc
	$(REWRITE_PKGCONF_PC)
	rm -rf $(TARGET_bindir)/luac
	$(REMOVE)/$(LUA_DIR)
	$(TOUCH)

# -----------------------------------------------------------------------------

LUAEXPAT_VER    = 1.3.3
LUAEXPAT_DIR    = luaexpat-$(LUAEXPAT_VER)
LUAEXPAT_SOURCE = luaexpat-$(LUAEXPAT_VER).tar.gz
LUAEXPAT_SITE   = https://github.com/tomasguisasola/luaexpat/archive

$(DL_DIR)/$(LUAEXPAT_SOURCE):
	$(DOWNLOAD) $(LUAEXPAT_SITE)/v$(LUAEXPAT_VER).tar.gz -O $(@)

LUAEXPAT_DEPS   = expat lua

luaexpat: $(LUAEXPAT_DEPS) $(DL_DIR)/$(LUAEXPAT_SOURCE) | $(TARGET_DIR)
	$(REMOVE)/$(LUAEXPAT_DIR)
	$(UNTAR)/$(LUAEXPAT_SOURCE)
	$(CHDIR)/$(LUAEXPAT_DIR); \
		$(SED) 's|^EXPAT_INC=.*|EXPAT_INC= $(TARGET_includedir)|' makefile; \
		$(SED) 's|^CFLAGS =.*|& -L$(TARGET_libdir)|' makefile; \
		$(SED) 's|^CC =.*|CC = $(TARGET_CC)|' makefile; \
		$(MAKE_ENV) \
		$(MAKE) \
			PREFIX=$(TARGET_prefix) \
			LUA_SYS_VER=$(LUA_ABIVER); \
		$(MAKE) install \
			PREFIX=$(TARGET_prefix) \
			LUA_SYS_VER=$(LUA_ABIVER)
	$(REMOVE)/$(LUAEXPAT_DIR)
	$(TOUCH)

# -----------------------------------------------------------------------------

LUA-FEEDPARSER_VER    = 0.71
LUA-FEEDPARSER_DIR    = lua-feedparser-$(LUA-FEEDPARSER_VER)
LUA-FEEDPARSER_SOURCE = lua-feedparser-$(LUA-FEEDPARSER_VER).tar.gz
LUA-FEEDPARSER_SITE   = https://github.com/slact/lua-feedparser/archive

$(DL_DIR)/$(LUA-FEEDPARSER_SOURCE):
	$(DOWNLOAD) $(LUA-FEEDPARSER_SITE)/$(LUA-FEEDPARSER_VER).tar.gz -O $(@)

LUA-FEEDPARSER_PATCH  = lua-feedparser.patch

LUA-DEEDPARSER_DEPS   = luaexpat

lua-feedparser: $(LUA-DEEDPARSER_DEPS) $(DL_DIR)/$(LUA-FEEDPARSER_SOURCE) | $(TARGET_DIR)
	$(REMOVE)/$(LUA-FEEDPARSER_DIR)
	$(UNTAR)/$(LUA-FEEDPARSER_SOURCE)
	$(CHDIR)/$(LUA-FEEDPARSER_DIR); \
		$(SED) 's|^PREFIX =|PREFIX ?=|' Makefile; \
		$(call apply_patches,$(LUA-FEEDPARSER_PATCH)); \
		$(MAKE) install PREFIX=$(TARGET_prefix)
	$(REMOVE)/$(LUA-FEEDPARSER_DIR)
	$(TOUCH)

# -----------------------------------------------------------------------------

LUAJSON_SOURCE = JSON.lua
LUAJSON_SITE   = http://regex.info/code

$(DL_DIR)/$(LUAJSON_SOURCE):
	$(DOWNLOAD) $(LUAJSON_SITE)/$(LUAJSON_SOURCE)

luajson: $(DL_DIR)/$(LUAJSON_SOURCE) | $(TARGET_DIR)
	$(CD) $(DL_DIR); \
		curl --remote-name --time-cond $(LUAJSON_SOURCE) $(LUAJSON_SITE)/$(LUAJSON_SOURCE) || true
	$(INSTALL_DATA) -D $(DL_DIR)/$(LUAJSON_SOURCE) $(TARGET_datadir)/lua/$(LUA_ABIVER)
	ln -sf $(LUAJSON_SOURCE) $(TARGET_datadir)/lua/$(LUA_ABIVER)/json.lua
	$(TOUCH)

# -----------------------------------------------------------------------------

LUACURL_VER    = git
LUACURL_DIR    = lua-curlv3.$(LUACURL_VER)
LUACURL_SOURCE = lua-curlv3.$(LUACURL_VER)
LUACURL_SITE   = https://github.com/lua-curl/$(LUACURL_SOURCE)

LUACURL_DEPS   = libcurl lua

luacurl: $(LUACURL_DEPS) | $(TARGET_DIR)
	echo $(TARGET_libdir)
	echo $(TARGET_includedir)
	echo $(TARGET_datadir)
	$(REMOVE)/$(LUACURL_DIR)
	$(GET-GIT-SOURCE) $(LUACURL_SITE) $(DL_DIR)/$(LUACURL_SOURCE)
	$(CPDIR)/$(LUACURL_SOURCE)
	$(CHDIR)/$(LUACURL_DIR); \
		$(MAKE_ENV) \
		$(MAKE) \
			LIBDIR=$(TARGET_libdir) \
			LUA_INC=$(TARGET_includedir); \
		$(MAKE) install DESTDIR=$(TARGET_DIR) \
			LUA_CMOD=$(libdir)/lua/$(LUA_ABIVER) \
			LUA_LMOD=$(datadir)/lua/$(LUA_ABIVER)
	$(REMOVE)/$(LUACURL_DIR)
	$(TOUCH)

# -----------------------------------------------------------------------------

LUAPOSIX_VER    = 31
LUAPOSIX_DIR    = luaposix-$(LUAPOSIX_VER)
LUAPOSIX_SOURCE = luaposix-$(LUAPOSIX_VER).tar.gz
LUAPOSIX_SITE   = https://github.com/luaposix/luaposix/archive

$(DL_DIR)/$(LUAPOSIX_SOURCE):
	$(DOWNLOAD) $(LUAPOSIX_SITE)/v$(LUAPOSIX_VER).tar.gz -O $(@)

LUAPOSIX_PATCH  = luaposix-fix-docdir-build.patch

LUAPOSIX_DEPS   = $(HOST_LUA) lua luaexpat

GNULIB_VER    = 20140202
GNULIB_SOURCE = gnulib-$(GNULIB_VER)-stable.tar.gz
GNULIB_SITE   = http://erislabs.net/ianb/projects/gnulib

$(DL_DIR)/$(GNULIB_SOURCE):
	$(DOWNLOAD) $(GNULIB_SITE)/$(GNULIB_SOURCE)

SLINGSHOT_VER    = 6
SLINGSHOT_SOURCE = slingshot-$(SLINGSHOT_VER).tar.gz
SLINGSHOT_SITE   = https://github.com/gvvaughan/slingshot/archive

$(DL_DIR)/$(SLINGSHOT_SOURCE):
	$(DOWNLOAD) $(SLINGSHOT_SITE)/v$(SLINGSHOT_VER).tar.gz -O $(@)

luaposix: $(LUAPOSIX_DEPS) $(DL_DIR)/$(SLINGSHOT_SOURCE) $(DL_DIR)/$(GNULIB_SOURCE) $(DL_DIR)/$(LUAPOSIX_SOURCE) | $(TARGET_DIR)
	$(REMOVE)/$(LUAPOSIX_DIR)
	$(UNTAR)/$(LUAPOSIX_SOURCE)
	$(CHDIR)/$(LUAPOSIX_DIR); \
		tar -C gnulib --strip=1 -xf $(DL_DIR)/$(GNULIB_SOURCE); \
		tar -C slingshot --strip=1 -xf $(DL_DIR)/$(SLINGSHOT_SOURCE); \
		$(call apply_patches,$(LUAPOSIX_PATCH)); \
		export LUA=$(HOST_LUA); \
		./bootstrap; \
		autoreconf -fi; \
		$(CONFIGURE) \
			--prefix=$(prefix) \
			--exec-prefix=$(exec_prefix) \
			--libdir=$(TARGET_libdir)/lua/$(LUA_ABIVER) \
			--datarootdir=$(TARGET_datadir)/lua/$(LUA_ABIVER) \
			--mandir=$(TARGET_DIR)$(REMOVE_mandir) \
			--docdir=$(TARGET_DIR)$(REMOVE_docdir) \
			--enable-silent-rules \
			; \
		$(MAKE); \
		$(MAKE) all check install
	$(REMOVE)/$(LUAPOSIX_DIR)
	$(TOUCH)
