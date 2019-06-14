#
# makefile to build lua libs/tools
#
# -----------------------------------------------------------------------------

LUA_ABIVER = 5.2
LUA_VER = $(LUA_ABIVER).4

$(ARCHIVE)/lua-$(LUA_VER).tar.gz:
	$(WGET) http://www.lua.org/ftp/lua-$(LUA_VER).tar.gz

LUA_PATCH  = lua-01-fix-coolstream-build.patch
LUA_PATCH += lua-02-shared-libs-for-lua.patch
LUA_PATCH += lua-03-lua-pc.patch
LUA_PATCH += lua-04-crashfix.diff

$(D)/lua: $(D)/libncurses $(ARCHIVE)/lua-$(LUA_VER).tar.gz | $(TARGET_DIR)
	$(REMOVE)/lua-$(LUA_VER)
	$(UNTAR)/lua-$(LUA_VER).tar.gz
	$(CHDIR)/lua-$(LUA_VER); \
		$(call apply_patches, $(LUA_PATCH)); \
		sed -i 's/^V=.*/V= $(LUA_ABIVER)/' etc/lua.pc; \
		sed -i 's/^R=.*/R= $(LUA_VER)/' etc/lua.pc; \
		$(MAKE) linux PKG_VERSION=$(LUA_VER) CC=$(TARGET)-gcc LD=$(TARGET)-ld AR="$(TARGET)-ar rcu" RANLIB=$(TARGET)-ranlib LDFLAGS="$(TARGET_LDFLAGS)"; \
		$(MAKE) install INSTALL_TOP=$(TARGET_DIR)
	install -D -m 0755 $(BUILD_TMP)/lua-$(LUA_VER)/src/liblua.so.$(LUA_VER) $(TARGET_LIB_DIR)/liblua.so.$(LUA_VER)
	ln -sf liblua.so.$(LUA_VER) $(TARGET_LIB_DIR)/liblua.so
	install -D -m 0644 $(BUILD_TMP)/lua-$(LUA_VER)/etc/lua.pc $(PKG_CONFIG_PATH)/lua.pc
	$(REWRITE_PKGCONF)/lua.pc
	rm -rf $(TARGET_DIR)/bin/luac
	$(REMOVE)/lua-$(LUA_VER)
	$(TOUCH)

# -----------------------------------------------------------------------------

HOST_LUA_PATCH  = lua-01-fix-coolstream-build.patch

# helper for luaposix build
$(HOST_DIR)/bin/lua-$(LUA_VER): $(ARCHIVE)/lua-$(LUA_VER).tar.gz | $(TARGET_DIR)
	$(REMOVE)/lua-$(LUA_VER)
	$(UNTAR)/lua-$(LUA_VER).tar.gz
	$(CHDIR)/lua-$(LUA_VER); \
		$(call apply_patches, $(HOST_LUA_PATCH)); \
		$(MAKE) linux
	install -m 0755 -D $(BUILD_TMP)/lua-$(LUA_VER)/src/lua $@
	$(REMOVE)/lua-$(LUA_VER)

# -----------------------------------------------------------------------------

LUAEXPAT_VER = 1.3.0

$(ARCHIVE)/luaexpat-$(LUAEXPAT_VER).tar.gz:
	$(WGET) http://matthewwild.co.uk/projects/luaexpat/luaexpat-$(LUAEXPAT_VER).tar.gz

LUAEXPAT_PATCH  = luaexpat-makefile.patch

$(D)/luaexpat: $(D)/expat $(D)/lua $(ARCHIVE)/luaexpat-$(LUAEXPAT_VER).tar.gz | $(TARGET_DIR)
	$(REMOVE)/luaexpat-$(LUAEXPAT_VER)
	$(UNTAR)/luaexpat-$(LUAEXPAT_VER).tar.gz
	$(CHDIR)/luaexpat-$(LUAEXPAT_VER); \
		$(call apply_patches, $(LUAEXPAT_PATCH)); \
		$(MAKE) CC=$(TARGET)-gcc LDFLAGS="$(TARGET_LDFLAGS)" PREFIX=$(TARGET_DIR); \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
	$(REMOVE)/luaexpat-$(LUAEXPAT_VER)
	$(TOUCH)

# -----------------------------------------------------------------------------

LUA-FEEDPARSER_VER = 0.71
LUA-FEEDPARSER_SOURCE = lua-feedparser-$(LUA-FEEDPARSER_VER).tar.gz

$(ARCHIVE)/$(LUA-FEEDPARSER_SOURCE):
	$(WGET) https://github.com/slact/lua-feedparser/archive/$(LUA-FEEDPARSER_VER).tar.gz -O $(ARCHIVE)/$(LUA-FEEDPARSER_SOURCE)

LUA-FEEDPARSER_PATCH  = lua-feedparser.patch

$(D)/lua-feedparser: $(D)/luaexpat $(ARCHIVE)/$(LUA-FEEDPARSER_SOURCE) | $(TARGET_DIR)
	$(REMOVE)/lua-feedparser-$(LUA-FEEDPARSER_VER)
	$(UNTAR)/$(LUA-FEEDPARSER_SOURCE)
	$(CHDIR)/lua-feedparser-$(LUA-FEEDPARSER_VER); \
		sed -i 's|^PREFIX =|PREFIX ?=|' Makefile; \
		$(call apply_patches, $(LUA-FEEDPARSER_PATCH)); \
		$(MAKE) install PREFIX=$(TARGET_DIR)
	$(REMOVE)/lua-feedparser-$(LUA-FEEDPARSER_VER)
	$(TOUCH)

# -----------------------------------------------------------------------------

LUAJSON_SOURCE = JSON.lua
LUAJSON_URL = http://regex.info/code/$(LUAJSON_SOURCE)

$(ARCHIVE)/$(LUAJSON_SOURCE):
	$(WGET) $(LUAJSON_URL)

$(D)/luajson: $(ARCHIVE)/$(LUAJSON_SOURCE) | $(TARGET_DIR)
	$(CD) $(ARCHIVE); \
		curl --remote-name --time-cond $(LUAJSON_SOURCE) $(LUAJSON_URL) || true
	install -D -m 0644 $(ARCHIVE)/$(LUAJSON_SOURCE) $(TARGET_DIR)/share/lua/$(LUA_ABIVER)
	$(TOUCH)

# -----------------------------------------------------------------------------

LUACURL_VER = git
LUACURL_SOURCE = lua-curlv3.$(LUACURL_VER)
LUACURL_URL = https://github.com/lua-curl/$(LUACURL_SOURCE)

$(D)/luacurl: $(D)/libcurl $(D)/lua | $(TARGET_DIR)
	$(REMOVE)/$(LUACURL_SOURCE)
	get-git-source.sh $(LUACURL_URL) $(ARCHIVE)/$(LUACURL_SOURCE)
	$(CPDIR)/$(LUACURL_SOURCE)
	$(CHDIR)/$(LUACURL_SOURCE); \
		$(BUILDENV) \
		$(MAKE) CC=$(TARGET)-gcc \
			LDFLAGS="$(TARGET_LDFLAGS)" \
			LIBDIR=$(TARGET_LIB_DIR) \
			LUA_INC=$(TARGET_INCLUDE_DIR); \
		$(MAKE) install DESTDIR=$(TARGET_DIR) \
			LUA_CMOD=/lib/lua/$(LUA_ABIVER) \
			LUA_LMOD=/share/lua/$(LUA_ABIVER)
	$(REMOVE)/$(LUACURL_SOURCE)
	$(TOUCH)

# -----------------------------------------------------------------------------

LUAPOSIX_VER = 31

$(ARCHIVE)/v$(LUAPOSIX_VER).tar.gz:
	$(WGET) https://github.com/luaposix/luaposix/archive/v$(LUAPOSIX_VER).tar.gz

LUAPOSIX_PATCH  = luaposix-fix-build.patch
LUAPOSIX_PATCH += luaposix-fix-docdir-build.patch

SLINGSHOT_VER = 6

$(ARCHIVE)/v$(SLINGSHOT_VER).tar.gz:
	$(WGET) https://github.com/gvvaughan/slingshot/archive/v$(SLINGSHOT_VER).tar.gz

GNULIB_VER = 20140202

$(ARCHIVE)/gnulib-$(GNULIB_VER)-stable.tar.gz:
	$(WGET) http://erislabs.net/ianb/projects/gnulib/gnulib-$(GNULIB_VER)-stable.tar.gz

$(D)/luaposix: $(HOST_DIR)/bin/lua-$(LUA_VER) $(D)/lua $(D)/luaexpat $(ARCHIVE)/v$(LUAPOSIX_VER).tar.gz $(ARCHIVE)/v$(SLINGSHOT_VER).tar.gz $(ARCHIVE)/gnulib-$(GNULIB_VER)-stable.tar.gz | $(TARGET_DIR)
	$(REMOVE)/luaposix-$(LUAPOSIX_VER)
	$(UNTAR)/v$(LUAPOSIX_VER).tar.gz
	tar -C $(BUILD_TMP)/luaposix-$(LUAPOSIX_VER)/slingshot --strip=1 -xf $(ARCHIVE)/v$(SLINGSHOT_VER).tar.gz
	tar -C $(BUILD_TMP)/luaposix-$(LUAPOSIX_VER)/gnulib --strip=1 -xf $(ARCHIVE)/gnulib-$(GNULIB_VER)-stable.tar.gz
	$(CHDIR)/luaposix-$(LUAPOSIX_VER); \
		$(call apply_patches, $(LUAPOSIX_PATCH)); \
		export LUA=$(HOST_DIR)/bin/lua-$(LUA_VER); \
		./bootstrap; \
		autoreconf -fi; \
		$(CONFIGURE) \
			--prefix= \
			--exec-prefix= \
			--libdir=$(TARGET_LIB_DIR)/lua/$(LUA_ABIVER) \
			--datarootdir=$(TARGET_DIR)/share/lua/$(LUA_ABIVER) \
			--mandir=$(TARGET_DIR)/.remove \
			--docdir=$(TARGET_DIR)/.remove \
			--enable-silent-rules \
			; \
		$(MAKE); \
		$(MAKE) all check install
	$(REMOVE)/luaposix-$(LUAPOSIX_VER)
	$(TOUCH)
