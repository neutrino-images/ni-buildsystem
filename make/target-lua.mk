#
# makefile to build lua libs/tools
#
# -----------------------------------------------------------------------------

LUA_ABIVER = 5.2
LUA_VER    = 5.2.4
LUA_TMP    = lua-$(LUA_VER)
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
	$(REMOVE)/$(LUA_TMP)
	$(UNTAR)/$(LUA_SOURCE)
	$(CHDIR)/$(LUA_TMP); \
		$(call apply_patches, $(LUA_PATCH)); \
		$(MAKE) linux \
			PKG_VERSION=$(LUA_VER) \
			$(MAKE_OPTS) \
			AR="$(TARGET_AR) rcu" \
			LDFLAGS="$(TARGET_LDFLAGS)" \
			; \
		$(MAKE) install INSTALL_TOP=$(TARGET_DIR) INSTALL_MAN=$(TARGET_DIR)$(remove-man1dir); \
		$(MAKE) pc INSTALL_TOP=$(TARGET_DIR) > $(PKG_CONFIG_PATH)/lua.pc
	$(REWRITE_PKGCONF_PC)
	rm -rf $(TARGET_DIR)/bin/luac
	$(REMOVE)/$(LUA_TMP)
	$(TOUCH)

# -----------------------------------------------------------------------------

LUAEXPAT_VER    = 1.3.3
LUAEXPAT_TMP    = luaexpat-$(LUAEXPAT_VER)
LUAEXPAT_SOURCE = luaexpat-$(LUAEXPAT_VER).tar.gz
LUAEXPAT_SITE   = https://github.com/tomasguisasola/luaexpat/archive

$(DL_DIR)/$(LUAEXPAT_SOURCE):
	$(DOWNLOAD) $(LUAEXPAT_SITE)/v$(LUAEXPAT_VER).tar.gz -O $(@)

LUAEXPAT_DEPS   = expat lua

luaexpat: $(LUAEXPAT_DEPS) $(DL_DIR)/$(LUAEXPAT_SOURCE) | $(TARGET_DIR)
	$(REMOVE)/$(LUAEXPAT_TMP)
	$(UNTAR)/$(LUAEXPAT_SOURCE)
	$(CHDIR)/$(LUAEXPAT_TMP); \
		sed -i 's|^EXPAT_INC=.*|EXPAT_INC= $(TARGET_INCLUDE_DIR)|' makefile; \
		sed -i 's|^CFLAGS =.*|& -L$(TARGET_LIB_DIR)|' makefile; \
		sed -i 's|^CC =.*|CC = $(TARGET_CC)|' makefile; \
		$(MAKE_ENV) \
		$(MAKE) \
			PREFIX=$(TARGET_DIR) \
			LUA_SYS_VER=$(LUA_ABIVER); \
		$(MAKE) install \
			PREFIX=$(TARGET_DIR) \
			LUA_SYS_VER=$(LUA_ABIVER)
	$(REMOVE)/$(LUAEXPAT_TMP)
	$(TOUCH)

# -----------------------------------------------------------------------------

LUA-FEEDPARSER_VER    = 0.71
LUA-FEEDPARSER_TMP    = lua-feedparser-$(LUA-FEEDPARSER_VER)
LUA-FEEDPARSER_SOURCE = lua-feedparser-$(LUA-FEEDPARSER_VER).tar.gz
LUA-FEEDPARSER_SITE   = https://github.com/slact/lua-feedparser/archive

$(DL_DIR)/$(LUA-FEEDPARSER_SOURCE):
	$(DOWNLOAD) $(LUA-FEEDPARSER_SITE)/$(LUA-FEEDPARSER_VER).tar.gz -O $(@)

LUA-FEEDPARSER_PATCH  = lua-feedparser.patch

LUA-DEEDPARSER_DEPS   = luaexpat

lua-feedparser: $(LUA-DEEDPARSER_DEPS) $(DL_DIR)/$(LUA-FEEDPARSER_SOURCE) | $(TARGET_DIR)
	$(REMOVE)/$(LUA-FEEDPARSER_TMP)
	$(UNTAR)/$(LUA-FEEDPARSER_SOURCE)
	$(CHDIR)/$(LUA-FEEDPARSER_TMP); \
		sed -i 's|^PREFIX =|PREFIX ?=|' Makefile; \
		$(call apply_patches, $(LUA-FEEDPARSER_PATCH)); \
		$(MAKE) install PREFIX=$(TARGET_DIR)
	$(REMOVE)/$(LUA-FEEDPARSER_TMP)
	$(TOUCH)

# -----------------------------------------------------------------------------

LUAJSON_SOURCE = JSON.lua
LUAJSON_SITE   = http://regex.info/code

$(DL_DIR)/$(LUAJSON_SOURCE):
	$(DOWNLOAD) $(LUAJSON_SITE)/$(LUAJSON_SOURCE)

luajson: $(DL_DIR)/$(LUAJSON_SOURCE) | $(TARGET_DIR)
	$(CD) $(DL_DIR); \
		curl --remote-name --time-cond $(LUAJSON_SOURCE) $(LUAJSON_SITE)/$(LUAJSON_SOURCE) || true
	$(INSTALL_DATA) -D $(DL_DIR)/$(LUAJSON_SOURCE) $(TARGET_SHARE_DIR)/lua/$(LUA_ABIVER)
	ln -sf $(LUAJSON_SOURCE) $(TARGET_SHARE_DIR)/lua/$(LUA_ABIVER)/json.lua
	$(TOUCH)

# -----------------------------------------------------------------------------

LUACURL_VER    = git
LUACURL_TMP    = lua-curlv3.$(LUACURL_VER)
LUACURL_SOURCE = lua-curlv3.$(LUACURL_VER)
LUACURL_SITE   = https://github.com/lua-curl/$(LUACURL_SOURCE)

LUACURL_DEPS   = libcurl lua

luacurl: $(LUACURL_DEPS) | $(TARGET_DIR)
	$(REMOVE)/$(LUACURL_TMP)
	$(GET-GIT-SOURCE) $(LUACURL_SITE) $(DL_DIR)/$(LUACURL_SOURCE)
	$(CPDIR)/$(LUACURL_SOURCE)
	$(CHDIR)/$(LUACURL_TMP); \
		$(MAKE_ENV) \
		$(MAKE) \
			LIBDIR=$(TARGET_LIB_DIR) \
			LUA_INC=$(TARGET_INCLUDE_DIR); \
		$(MAKE) install DESTDIR=$(TARGET_DIR) \
			LUA_CMOD=/lib/lua/$(LUA_ABIVER) \
			LUA_LMOD=/share/lua/$(LUA_ABIVER)
	$(REMOVE)/$(LUACURL_TMP)
	$(TOUCH)

# -----------------------------------------------------------------------------

LUAPOSIX_VER    = 31
LUAPOSIX_TMP    = luaposix-$(LUAPOSIX_VER)
LUAPOSIX_SOURCE = luaposix-$(LUAPOSIX_VER).tar.gz
LUAPOSIX_SITE   = https://github.com/luaposix/luaposix/archive

$(DL_DIR)/$(LUAPOSIX_SOURCE):
	$(DOWNLOAD) $(LUAPOSIX_SITE)/v$(LUAPOSIX_VER).tar.gz -O $(@)

LUAPOSIX_PATCH  = luaposix-fix-build.patch
LUAPOSIX_PATCH += luaposix-fix-docdir-build.patch

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
	$(REMOVE)/$(LUAPOSIX_TMP)
	$(UNTAR)/$(LUAPOSIX_SOURCE)
	$(CHDIR)/$(LUAPOSIX_TMP); \
		tar -C gnulib --strip=1 -xf $(DL_DIR)/$(GNULIB_SOURCE); \
		tar -C slingshot --strip=1 -xf $(DL_DIR)/$(SLINGSHOT_SOURCE); \
		$(call apply_patches, $(LUAPOSIX_PATCH)); \
		export LUA=$(HOST_LUA); \
		./bootstrap; \
		autoreconf -fi; \
		$(CONFIGURE) \
			--prefix= \
			--exec-prefix= \
			--libdir=$(TARGET_LIB_DIR)/lua/$(LUA_ABIVER) \
			--datarootdir=$(TARGET_SHARE_DIR)/lua/$(LUA_ABIVER) \
			--mandir=$(TARGET_DIR)$(remove-mandir) \
			--docdir=$(TARGET_DIR)$(remove-docdir) \
			--enable-silent-rules \
			; \
		$(MAKE); \
		$(MAKE) all check install
	$(REMOVE)/$(LUAPOSIX_TMP)
	$(TOUCH)
