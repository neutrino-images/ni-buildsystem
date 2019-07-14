#
# makefile to build lua libs/tools
#
# -----------------------------------------------------------------------------

LUA_ABIVER = 5.2
LUA_VER    = 5.2.4
LUA_TMP    = lua-$(LUA_VER)
LUA_SOURCE = lua-$(LUA_VER).tar.gz
LUA_URL    = https://www.lua.org

$(ARCHIVE)/$(LUA_SOURCE):
	$(DOWNLOAD) $(LUA_URL)/ftp/$(LUA_SOURCE)

LUA_PATCH  = lua-01-fix-LUA_ROOT.patch
LUA_PATCH += lua-01-remove-readline.patch
LUA_PATCH += lua-01-remove-man.patch
LUA_PATCH += lua-02-shared-libs-for-lua.patch
LUA_PATCH += lua-03-lua-pc.patch
LUA_PATCH += lua-04-crashfix.diff

$(D)/lua: $(D)/ncurses $(ARCHIVE)/$(LUA_SOURCE) | $(TARGET_DIR)
	$(REMOVE)/$(LUA_TMP)
	$(UNTAR)/$(LUA_SOURCE)
	$(CHDIR)/$(LUA_TMP); \
		$(call apply_patches, $(LUA_PATCH)); \
		sed -i 's/^V=.*/V= $(LUA_ABIVER)/' etc/lua.pc; \
		sed -i 's/^R=.*/R= $(LUA_VER)/' etc/lua.pc; \
		$(MAKE) linux \
			PKG_VERSION=$(LUA_VER) \
			CC="$(TARGET)-gcc" \
			LD="$(TARGET)-ld" \
			AR="$(TARGET)-ar rcu" \
			RANLIB=$(TARGET)-ranlib \
			LDFLAGS="$(TARGET_LDFLAGS)"; \
		$(MAKE) install INSTALL_TOP=$(TARGET_DIR)
	install -D -m 0755 $(BUILD_TMP)/$(LUA_TMP)/src/liblua.so.$(LUA_VER) $(TARGET_LIB_DIR)/liblua.so.$(LUA_VER)
	ln -sf liblua.so.$(LUA_VER) $(TARGET_LIB_DIR)/liblua.so
	install -D -m 0644 $(BUILD_TMP)/$(LUA_TMP)/etc/lua.pc $(PKG_CONFIG_PATH)/lua.pc
	$(REWRITE_PKGCONF)/lua.pc
	rm -rf $(TARGET_DIR)/bin/luac
	$(REMOVE)/$(LUA_TMP)
	$(TOUCH)

# -----------------------------------------------------------------------------

LUAEXPAT_VER    = 1.3.0
LUAEXPAT_TMP    = luaexpat-$(LUAEXPAT_VER)
LUAEXPAT_SOURCE = luaexpat-$(LUAEXPAT_VER).tar.gz
LUAEXPAT_URL    = https://matthewwild.co.uk/projects/luaexpat

$(ARCHIVE)/$(LUAEXPAT_SOURCE):
	$(DOWNLOAD) $(LUAEXPAT_URL)/$(LUAEXPAT_SOURCE)

LUAEXPAT_PATCH  = luaexpat-makefile.patch

$(D)/luaexpat: $(D)/expat $(D)/lua $(ARCHIVE)/$(LUAEXPAT_SOURCE) | $(TARGET_DIR)
	$(REMOVE)/$(LUAEXPAT_TMP)
	$(UNTAR)/$(LUAEXPAT_SOURCE)
	$(CHDIR)/$(LUAEXPAT_TMP); \
		$(call apply_patches, $(LUAEXPAT_PATCH)); \
		$(BUILDENV) \
		$(MAKE) \
			PREFIX=$(TARGET_DIR); \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
	$(REMOVE)/$(LUAEXPAT_TMP)
	$(TOUCH)

# -----------------------------------------------------------------------------

LUA-FEEDPARSER_VER    = 0.71
LUA-FEEDPARSER_TMP    = lua-feedparser-$(LUA-FEEDPARSER_VER)
LUA-FEEDPARSER_SOURCE = lua-feedparser-$(LUA-FEEDPARSER_VER).tar.gz
LUA-FEEDPARSER_URL    = https://github.com/slact/lua-feedparser/archive

$(ARCHIVE)/$(LUA-FEEDPARSER_SOURCE):
	$(DOWNLOAD) $(LUA-FEEDPARSER_URL)/$(LUA-FEEDPARSER_SOURCE) -O $@

LUA-FEEDPARSER_PATCH  = lua-feedparser.patch

$(D)/lua-feedparser: $(D)/luaexpat $(ARCHIVE)/$(LUA-FEEDPARSER_SOURCE) | $(TARGET_DIR)
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
LUAJSON_URL    = http://regex.info/code

$(ARCHIVE)/$(LUAJSON_SOURCE):
	$(DOWNLOAD) $(LUAJSON_URL)/$(LUAJSON_SOURCE)

$(D)/luajson: $(ARCHIVE)/$(LUAJSON_SOURCE) | $(TARGET_DIR)
	$(CD) $(ARCHIVE); \
		curl --remote-name --time-cond $(LUAJSON_SOURCE) $(LUAJSON_URL) || true
	install -D -m 0644 $(ARCHIVE)/$(LUAJSON_SOURCE) $(TARGET_SHARE_DIR)/lua/$(LUA_ABIVER)
	ln -sf $(LUAJSON_SOURCE) $(TARGET_SHARE_DIR)/lua/$(LUA_ABIVER)/json.lua
	$(TOUCH)

# -----------------------------------------------------------------------------

LUACURL_VER    = git
LUACURL_TMP    = lua-curlv3.$(LUACURL_VER)
LUACURL_SOURCE = lua-curlv3.$(LUACURL_VER)
LUACURL_URL    = https://github.com/lua-curl/$(LUACURL_SOURCE)

$(D)/luacurl: $(D)/libcurl $(D)/lua | $(TARGET_DIR)
	$(REMOVE)/$(LUACURL_TMP)
	get-git-source.sh $(LUACURL_URL) $(ARCHIVE)/$(LUACURL_SOURCE)
	$(CPDIR)/$(LUACURL_SOURCE)
	$(CHDIR)/$(LUACURL_TMP); \
		$(BUILDENV) \
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
LUAPOSIX_URL    = https://github.com/luaposix/luaposix/archive

$(ARCHIVE)/$(LUAPOSIX_SOURCE):
	$(DOWNLOAD) $(LUAPOSIX_URL)/v$(LUAPOSIX_VER).tar.gz -O $@

LUAPOSIX_PATCH  = luaposix-fix-build.patch
LUAPOSIX_PATCH += luaposix-fix-docdir-build.patch

GNULIB_VER    = 20140202
GNULIB_SOURCE = gnulib-$(GNULIB_VER)-stable.tar.gz
GNULIB_URL    = http://erislabs.net/ianb/projects/gnulib

$(ARCHIVE)/$(GNULIB_SOURCE):
	$(DOWNLOAD) $(GNULIB_URL)/$(GNULIB_SOURCE)

SLINGSHOT_VER    = 6
SLINGSHOT_SOURCE = slingshot-$(SLINGSHOT_VER).tar.gz
SLINGSHOT_URL    = https://github.com/gvvaughan/slingshot/archive

$(ARCHIVE)/$(SLINGSHOT_SOURCE):
	$(DOWNLOAD) $(SLINGSHOT_URL)/v$(SLINGSHOT_VER).tar.gz -O $@

$(D)/luaposix: $(HOST_LUA) $(D)/lua $(D)/luaexpat $(ARCHIVE)/$(SLINGSHOT_SOURCE) $(ARCHIVE)/$(GNULIB_SOURCE) $(ARCHIVE)/$(LUAPOSIX_SOURCE) | $(TARGET_DIR)
	$(REMOVE)/$(LUAPOSIX_TMP)
	$(UNTAR)/$(LUAPOSIX_SOURCE)
	$(CHDIR)/$(LUAPOSIX_TMP); \
		tar -C gnulib --strip=1 -xf $(ARCHIVE)/$(GNULIB_SOURCE); \
		tar -C slingshot --strip=1 -xf $(ARCHIVE)/$(SLINGSHOT_SOURCE); \
		$(call apply_patches, $(LUAPOSIX_PATCH)); \
		export LUA=$(HOST_LUA); \
		./bootstrap; \
		autoreconf -fi; \
		$(CONFIGURE) \
			--prefix= \
			--exec-prefix= \
			--libdir=$(TARGET_LIB_DIR)/lua/$(LUA_ABIVER) \
			--datarootdir=$(TARGET_SHARE_DIR)/lua/$(LUA_ABIVER) \
			--mandir=$(TARGET_DIR)/.remove \
			--docdir=$(TARGET_DIR)/.remove \
			--enable-silent-rules \
			; \
		$(MAKE); \
		$(MAKE) all check install
	$(REMOVE)/$(LUAPOSIX_TMP)
	$(TOUCH)
