#
# makefile to build system libs
#
# -----------------------------------------------------------------------------

ZLIB_PATCH  = zlib-ldflags-tests.patch
ZLIB_PATCH += zlib-remove.ldconfig.call.patch

$(D)/zlib: $(ARCHIVE)/zlib-$(ZLIB_VER).tar.gz | $(TARGET_DIR)
	$(REMOVE)/zlib-$(ZLIB_VER)
	$(UNTAR)/zlib-$(ZLIB_VER).tar.gz
	$(CHDIR)/zlib-$(ZLIB_VER); \
		$(call apply_patches, $(ZLIB_PATCH)); \
		rm -rf config.cache; \
		$(BUILDENV) \
		CC=$(TARGET)-gcc \
		LD=$(TARGET)-ld \
		AR="$(TARGET)-ar" \
		RANLIB=$(TARGET)-ranlib \
		LDFLAGS="$(TARGET_LDFLAGS)" \
		mandir=$(BUILD_TMP)/zlib-$(ZLIB_VER)/.remove \
		./configure \
			--prefix= \
			--shared \
			; \
		$(MAKE); \
		$(MAKE) install prefix=$(TARGET_DIR)
	$(REWRITE_PKGCONF) $(PKG_CONFIG_PATH)/zlib.pc
	$(REMOVE)/zlib-$(ZLIB_VER)
	$(TOUCH)

# -----------------------------------------------------------------------------

$(D)/libfuse: $(ARCHIVE)/fuse-$(FUSE_VER).tar.gz | $(TARGET_DIR)
	$(REMOVE)/fuse-$(FUSE_VER)
	$(UNTAR)/fuse-$(FUSE_VER).tar.gz
	$(CHDIR)/fuse-$(FUSE_VER); \
		$(CONFIGURE) \
			--prefix= \
			--datarootdir=/.remove \
			--disable-static \
			--disable-example \
			--disable-mtab \
			--with-gnu-ld \
			--enable-util \
			--enable-lib \
			--enable-silent-rules \
			; \
		$(MAKE) all; \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
	$(REWRITE_LIBTOOL)/libfuse.la
	$(REWRITE_LIBTOOL)/libulockmgr.la
	$(REWRITE_PKGCONF) $(PKG_CONFIG_PATH)/fuse.pc
	rm -rf $(TARGET_DIR)/etc/udev
	rm -rf $(TARGET_DIR)/etc/init.d/fuse
	$(REMOVE)/fuse-$(FUSE_VER)
	$(TOUCH)

# -----------------------------------------------------------------------------

$(D)/libupnp: $(ARCHIVE)/libupnp-$(LIBUPNP_VER).tar.bz2 | $(TARGET_DIR)
	$(REMOVE)/libupnp-$(LIBUPNP_VER)
	$(UNTAR)/libupnp-$(LIBUPNP_VER).tar.bz2
	$(CHDIR)/libupnp-$(LIBUPNP_VER); \
		$(CONFIGURE) \
			--prefix= \
			--enable-shared \
			--disable-static \
			; \
		$(MAKE); \
		$(MAKE) install DESTDIR=$(TARGET_DIR); \
	$(REMOVE)/libupnp-$(LIBUPNP_VER)
	$(REWRITE_LIBTOOL)/libixml.la
	$(REWRITE_LIBTOOL)/libthreadutil.la
	$(REWRITE_LIBTOOL)/libupnp.la
	$(REWRITE_PKGCONF) $(PKG_CONFIG_PATH)/libupnp.pc
	$(TOUCH)
	
# -----------------------------------------------------------------------------

$(ARCHIVE)/libdvbsi-.git:
	get-git-source.sh git://github.com/OpenDMM/libdvbsi-.git $@

PHONY += $(ARCHIVE)/libdvbsi-.git

LIBDVBSI_PATCH  = libdvbsi++-content_identifier_descriptor.patch
LIBDVBSI_PATCH += libdvbsi++-fix-descriptorLenghth.patch

$(D)/libdvbsi: $(ARCHIVE)/libdvbsi-.git | $(TARGET_DIR)
	$(REMOVE)/libdvbsi-.git
	$(CPDIR)/libdvbsi-.git
	$(CHDIR)/libdvbsi-.git; \
		$(call apply_patches, $(LIBDVBSI_PATCH)); \
		$(CONFIGURE) \
			--prefix= \
			--enable-shared \
			--enable-silent-rules \
			--disable-static \
			; \
		$(MAKE); \
		make install DESTDIR=$(TARGET_DIR); \
	$(REMOVE)/libdvbsi-.git
	$(REWRITE_LIBTOOL)/libdvbsi++.la
	$(REWRITE_PKGCONF) $(PKG_CONFIG_PATH)/libdvbsi++.pc
	$(TOUCH)

# -----------------------------------------------------------------------------

$(D)/giflib: $(ARCHIVE)/giflib-$(GIFLIB_VER).tar.bz2 | $(TARGET_DIR)
	$(REMOVE)/giflib-$(GIFLIB_VER)
	$(UNTAR)/giflib-$(GIFLIB_VER).tar.bz2
	$(CHDIR)/giflib-$(GIFLIB_VER); \
		export ac_cv_prog_have_xmlto=no; \
		$(CONFIGURE) \
			--prefix= \
			--disable-static \
			--enable-shared \
			--bindir=/.remove \
			; \
		$(MAKE) all; \
		make install DESTDIR=$(TARGET_DIR)
	$(REWRITE_LIBTOOL)/libgif.la
	$(REMOVE)/giflib-$(GIFLIB_VER)
	$(TOUCH)

# -----------------------------------------------------------------------------

CURL_IPV6="--enable-ipv6"
ifeq ($(BOXSERIES), hd1)
	CURL_IPV6="--disable-ipv6"
endif

$(D)/libcurl: $(D)/zlib $(D)/openssl $(D)/librtmp $(D)/ca-bundle $(ARCHIVE)/curl-$(LIBCURL_VER).tar.bz2 | $(TARGET_DIR)
	$(REMOVE)/curl-$(LIBCURL_VER)
	$(UNTAR)/curl-$(LIBCURL_VER).tar.bz2
	$(CHDIR)/curl-$(LIBCURL_VER); \
		$(CONFIGURE) \
			--prefix=  \
			--mandir=/.remove \
			--datarootdir=/.remove \
			--disable-manual \
			--disable-file \
			--disable-rtsp \
			--disable-dict \
			--disable-ldap \
			--disable-curldebug \
			--disable-static \
			--disable-imap \
			--disable-gopher \
			--disable-pop3 \
			--disable-smtp \
			--disable-verbose \
			--disable-manual \
			--disable-ntlm-wb \
			--disable-ares \
			--without-libidn \
			--with-ca-bundle=$(CA-BUNDLE_DIR)/$(CA-BUNDLE) \
			--with-random=/dev/urandom \
			--with-ssl=$(TARGET_DIR) \
			--with-librtmp=$(TARGET_LIB_DIR) \
			$(CURL_IPV6) \
			--enable-optimize \
			; \
		$(MAKE) all; \
		mkdir -p $(HOST_DIR)/bin; \
		sed -e "s,^prefix=,prefix=$(TARGET_DIR)," < curl-config > $(HOST_DIR)/bin/curl-config; \
		chmod 755 $(HOST_DIR)/bin/curl-config; \
		make install DESTDIR=$(TARGET_DIR)
	rm -rf $(TARGET_DIR)/bin/curl-config $(TARGET_DIR)/share/zsh
	$(REWRITE_LIBTOOL)/libcurl.la
	$(REWRITE_PKGCONF) $(PKG_CONFIG_PATH)/libcurl.pc
	$(REMOVE)/curl-$(LIBCURL_VER)
	$(TOUCH)

# -----------------------------------------------------------------------------

LIBPNG_PATCH  = libpng-Disable-pngfix-and-png-fix-itxt.patch

LIBPNG_CONF =
ifneq ($(BOXSERIES), hd51)
	LIBPNG_CONF = --disable-arm-neon
endif

$(D)/libpng: $(ARCHIVE)/libpng-$(LIBPNG_VER).tar.xz $(D)/zlib | $(TARGET_DIR)
	$(REMOVE)/libpng-$(LIBPNG_VER)
	$(UNTAR)/libpng-$(LIBPNG_VER).tar.xz
	$(CHDIR)/libpng-$(LIBPNG_VER); \
		$(call apply_patches, $(LIBPNG_PATCH)); \
		$(CONFIGURE) \
			--prefix=$(TARGET_DIR) \
			--bindir=$(HOST_DIR)/bin \
			--mandir=$(BUILD_TMP)/.remove \
			--enable-silent-rules \
			$(LIBPNG_CONF) \
			--disable-static \
			; \
		ECHO=echo $(MAKE) all; \
		make install
	$(REMOVE)/libpng-$(LIBPNG_VER)
	$(TOUCH)

# -----------------------------------------------------------------------------

FREETYPE_PATCH  = freetype2_subpixel.patch

$(D)/freetype: $(D)/zlib $(D)/libpng $(ARCHIVE)/freetype-$(FREETYPE_VER).tar.bz2 | $(TARGET_DIR)
	$(REMOVE)/freetype-$(FREETYPE_VER)
	$(UNTAR)/freetype-$(FREETYPE_VER).tar.bz2
	$(CHDIR)/freetype-$(FREETYPE_VER); \
		$(call apply_patches, $(FREETYPE_PATCH)); \
		sed -i '/^FONT_MODULES += \(type1\|cid\|pfr\|type42\|pcf\|bdf\|winfonts\|cff\)/d' modules.cfg
	$(CHDIR)/freetype-$(FREETYPE_VER)/builds/unix; \
		libtoolize --force --copy; \
		aclocal -I .; \
		autoconf
	$(CHDIR)/freetype-$(FREETYPE_VER); \
		$(CONFIGURE) \
			--prefix=$(TARGET_DIR) \
			--mandir=$(BUILD_TMP)/.remove \
			--enable-shared \
			--disable-static \
			--enable-freetype-config \
			--with-png \
			--with-zlib \
			--without-harfbuzz \
			--without-bzip2 \
			; \
		$(MAKE) all; \
		make install; \
		ln -sf ./freetype2/freetype $(TARGET_INCLUDE_DIR)/freetype; \
	mv $(TARGET_DIR)/bin/freetype-config $(HOST_DIR)/bin/freetype-config
	$(REMOVE)/freetype-$(FREETYPE_VER) $(TARGET_DIR)/share/aclocal
	$(TOUCH)

# -----------------------------------------------------------------------------

ifeq ($(BOXTYPE), armbox)
  LIBJPEG-TURBO = libjpeg-turbo2
else
  LIBJPEG-TURBO = libjpeg-turbo
endif

$(D)/libjpeg: $(LIBJPEG-TURBO)
	$(TOUCH)

# -----------------------------------------------------------------------------

LIBJPEG-TURBO_VER = 1.5.3

$(ARCHIVE)/libjpeg-turbo-$(LIBJPEG-TURBO_VER).tar.gz:
	$(WGET) https://sourceforge.net/projects/libjpeg-turbo/files/$(LIBJPEG-TURBO_VER)/libjpeg-turbo-$(LIBJPEG-TURBO_VER).tar.gz

$(D)/libjpeg-turbo: $(ARCHIVE)/libjpeg-turbo-$(LIBJPEG-TURBO_VER).tar.gz | $(TARGET_DIR)
	$(REMOVE)/libjpeg-turbo-$(LIBJPEG-TURBO_VER)
	$(UNTAR)/libjpeg-turbo-$(LIBJPEG-TURBO_VER).tar.gz
	$(CHDIR)/libjpeg-turbo-$(LIBJPEG-TURBO_VER); \
		export CC=$(TARGET)-gcc; \
		$(CONFIGURE) \
			--prefix= \
			--enable-shared \
			--mandir=/.remove \
			--bindir=/.remove \
			--datadir=/.remove \
			--datarootdir=/.remove \
			--disable-static \
			; \
		$(MAKE) ; \
		make install DESTDIR=$(TARGET_DIR)
	$(REWRITE_LIBTOOL)/libjpeg.la
	rm -f $(TARGET_LIB_DIR)/libturbojpeg* $(TARGET_INCLUDE_DIR)/turbojpeg.h
	$(REMOVE)/libjpeg-turbo-$(LIBJPEG-TURBO_VER)
	$(TOUCH)

# -----------------------------------------------------------------------------

LIBJPEG-TURBO2_VER = 2.0.2
LIBJPEG-TURBO2_SOURCE = libjpeg-turbo-$(LIBJPEG-TURBO2_VER).tar.gz

$(ARCHIVE)/$(LIBJPEG-TURBO2_SOURCE):
	$(WGET) https://sourceforge.net/projects/libjpeg-turbo/files/$(LIBJPEG-TURBO2_VER)/$(LIBJPEG-TURBO2_SOURCE)

LIBJPEG-TURBO2_PATCH = libjpeg-turbo-tiff-ojpeg.patch

$(D)/libjpeg-turbo2: $(ARCHIVE)/$(LIBJPEG-TURBO2_SOURCE) | $(TARGET_DIR)
	$(REMOVE)/libjpeg-turbo-$(LIBJPEG-TURBO2_VER)
	$(UNTAR)/$(LIBJPEG-TURBO2_SOURCE)
	$(CHDIR)/libjpeg-turbo-$(LIBJPEG-TURBO2_VER); \
		$(call apply_patches, $(LIBJPEG-TURBO2_PATCH)); \
		$(CMAKE) \
			-DWITH_SIMD=False \
			-DWITH_JPEG8=80 \
			-DCMAKE_INSTALL_DOCDIR=/.remove \
			-DCMAKE_INSTALL_MANDIR=/.remove \
			; \
		$(MAKE); \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
	$(REWRITE_PKGCONF) $(PKG_CONFIG_PATH)/libturbojpeg.pc
	$(REWRITE_PKGCONF) $(PKG_CONFIG_PATH)/libjpeg.pc
	rm -f $(addprefix $(TARGET_DIR)/bin/,cjpeg djpeg jpegtran rdjpgcom tjbench wrjpgcom)
	$(REMOVE)/libjpeg-turbo-$(LIBJPEG-TURBO2_VER)
	$(TOUCH)

# -----------------------------------------------------------------------------

OPENSSL_PATCH  = openssl-add-ni-specific-target.patch

OPENSSLFLAGS = CC=$(TARGET)-gcc \
		LD=$(TARGET)-ld \
		AR="$(TARGET)-ar r" \
		RANLIB=$(TARGET)-ranlib \
		MAKEDEPPROG=$(TARGET)-gcc \
		NI_OPTIMIZATION_FLAGS="$(TARGET_CFLAGS)" \
		PROCESSOR=ARM

$(D)/openssl: $(ARCHIVE)/openssl-$(OPENSSL_VER).tar.gz | $(TARGET_DIR)
	$(REMOVE)/openssl-$(OPENSSL_VER)
	$(UNTAR)/openssl-$(OPENSSL_VER).tar.gz
	$(CHDIR)/openssl-$(OPENSSL_VER); \
		$(call apply_patches, $(OPENSSL_PATCH)); \
		./Configure \
			linux-armv4-ni \
			shared \
			threads \
			no-hw \
			no-engine \
			no-sse2 \
			no-perlasm \
			$(TARGET_CPPFLAGS) \
			$(TARGET_LDFLAGS) \
			-DOPENSSL_SMALL_FOOTPRINT \
			--prefix=/ \
			--openssldir=/.remove \
			; \
		make $(OPENSSLFLAGS) depend; \
		sed -i "s# build_tests##" Makefile; \
		make $(OPENSSLFLAGS) all; \
		make install_sw INSTALL_PREFIX=$(TARGET_DIR)
	$(REWRITE_PKGCONF) $(PKG_CONFIG_PATH)/openssl.pc
	$(REWRITE_PKGCONF) $(PKG_CONFIG_PATH)/libcrypto.pc
	$(REWRITE_PKGCONF) $(PKG_CONFIG_PATH)/libssl.pc
	rm -rf $(TARGET_DIR)/bin/c_rehash $(TARGET_LIB_DIR)/engines
ifneq ($(BOXSERIES), hd51)
	rm -rf $(TARGET_DIR)/bin/openssl
endif
	$(REMOVE)/openssl-$(OPENSSL_VER)
	chmod 0755 $(TARGET_LIB_DIR)/libcrypto.so.* $(TARGET_LIB_DIR)/libssl.so.*
	for version in 0.9.7 0.9.8 1.0.2; do \
		ln -sf libcrypto.so.1.0.0 $(TARGET_LIB_DIR)/libcrypto.so.$$version; \
		ln -sf libssl.so.1.0.0 $(TARGET_LIB_DIR)/libssl.so.$$version; \
	done
	$(TOUCH)

# -----------------------------------------------------------------------------

LIBNCURSES_PATCH  = ncurses-gcc-5.x-MKlib_gen.patch

$(D)/libncurses: $(ARCHIVE)/ncurses-$(LIBNCURSES_VER).tar.gz | $(TARGET_DIR)
	$(REMOVE)/ncurses-$(LIBNCURSES_VER)
	$(UNTAR)/ncurses-$(LIBNCURSES_VER).tar.gz; \
	$(CHDIR)/ncurses-$(LIBNCURSES_VER); \
		$(call apply_patches, $(LIBNCURSES_PATCH)); \
		$(CONFIGURE) \
			--target=$(TARGET) \
			--prefix= \
			--enable-pc-files \
			--with-pkg-config \
			--with-pkg-config-libdir=/lib/pkgconfig \
			--with-shared \
			--with-fallbacks='linux vt100 xterm' \
			--disable-big-core \
			--without-manpages \
			--without-progs \
			--without-tests \
			--without-debug \
			--without-ada \
			--without-profile \
			--without-cxx-binding \
			; \
		$(MAKE) libs; \
		$(MAKE) install.libs DESTDIR=$(TARGET_DIR)
	rm -rf $(HOST_DIR)/bin/ncurses*
	rm -rf $(TARGET_LIB_DIR)/libform* $(TARGET_LIB_DIR)/libmenu* $(TARGET_LIB_DIR)/libpanel*
	rm -rf $(PKG_CONFIG_PATH)/form.pc $(PKG_CONFIG_PATH)/menu.pc $(PKG_CONFIG_PATH)/panel.pc
	mv $(TARGET_DIR)/bin/ncurses6-config $(HOST_DIR)/bin
	$(REWRITE_PKGCONF) $(HOST_DIR)/bin/ncurses6-config
	$(REWRITE_PKGCONF) $(PKG_CONFIG_PATH)/ncurses.pc
	ln -sf ./ncurses/curses.h $(TARGET_INCLUDE_DIR)/curses.h
	ln -sf ./ncurses/curses.h $(TARGET_INCLUDE_DIR)/ncurses.h
	ln -sf ./ncurses/term.h $(TARGET_INCLUDE_DIR)/term.h
	$(REMOVE)/ncurses-$(LIBNCURSES_VER)
	$(TOUCH)

# -----------------------------------------------------------------------------

$(D)/openthreads: $(SOURCE_DIR)/$(NI_OPENTHREADS) | $(TARGET_DIR)
	$(REMOVE)/$(NI_OPENTHREADS)
	tar -C $(SOURCE_DIR) -cp $(NI_OPENTHREADS) --exclude-vcs | tar -C $(BUILD_TMP) -x
	$(CHDIR)/$(NI_OPENTHREADS)/; \
		$(CMAKE) \
			-DCMAKE_SUPPRESS_DEVELOPER_WARNINGS="1" \
			-D_OPENTHREADS_ATOMIC_USE_GCC_BUILTINS_EXITCODE="0" \
			; \
		$(MAKE); \
		make install DESTDIR=$(TARGET_DIR)
	rm -f $(TARGET_LIB_DIR)/cmake
	$(REMOVE)/$(NI_OPENTHREADS)
	$(REWRITE_PKGCONF) $(PKG_CONFIG_PATH)/openthreads.pc
	$(TOUCH)

# -----------------------------------------------------------------------------

$(D)/libusb: $(ARCHIVE)/libusb-$(LIBUSB_VER).tar.bz2 | $(TARGET_DIR)
	$(REMOVE)/libusb-$(LIBUSB_VER)
	$(UNTAR)/libusb-$(LIBUSB_VER).tar.bz2
	$(CHDIR)/libusb-$(LIBUSB_VER); \
		$(CONFIGURE) \
			--prefix= \
			--disable-udev \
			; \
		$(MAKE); \
		make install DESTDIR=$(TARGET_DIR); \
	$(REMOVE)/libusb-$(LIBUSB_VER)
	$(REWRITE_LIBTOOL)/libusb-$(LIBUSB_MAJ).la
	$(REWRITE_PKGCONF) $(PKG_CONFIG_PATH)/libusb-$(LIBUSB_MAJ).pc
	$(TOUCH)

# -----------------------------------------------------------------------------

$(D)/libusb_compat: $(ARCHIVE)/libusb-compat-$(LIBUSB_COMPAT_VER).tar.bz2 $(D)/libusb | $(TARGET_DIR)
	$(REMOVE)/libusb-compat-$(LIBUSB_COMPAT_VER)
	$(UNTAR)/libusb-compat-$(LIBUSB_COMPAT_VER).tar.bz2
	$(CHDIR)/libusb-compat-$(LIBUSB_COMPAT_VER); \
		$(CONFIGURE) \
			--prefix= \
			; \
		$(MAKE); \
		make install DESTDIR=$(TARGET_DIR); \
	$(REMOVE)/libusb-compat-$(LIBUSB_COMPAT_VER)
	mv $(TARGET_DIR)/bin/libusb-config $(HOST_DIR)/bin
	$(REWRITE_PKGCONF) $(HOST_DIR)/bin/libusb-config
	$(REWRITE_LIBTOOL)/libusb.la
	$(REWRITE_PKGCONF) $(PKG_CONFIG_PATH)/libusb.pc
	$(TOUCH)

# -----------------------------------------------------------------------------

$(D)/libgd2: $(D)/zlib $(D)/libpng $(D)/libjpeg $(D)/freetype $(ARCHIVE)/libgd-$(LIBGD_VER).tar.xz | $(TARGET_DIR)
	$(REMOVE)/libgd-$(LIBGD_VER)
	$(UNTAR)/libgd-$(LIBGD_VER).tar.xz
	$(CHDIR)/libgd-$(LIBGD_VER); \
		./bootstrap.sh; \
		$(CONFIGURE) \
			--prefix= \
			--bindir=/.remove \
			--without-fontconfig \
			--without-xpm \
			--without-x \
			; \
		$(MAKE); \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
	$(REMOVE)/libgd-$(LIBGD_VER)
	$(REWRITE_LIBTOOL)/libgd.la
	$(REWRITE_PKGCONF) $(PKG_CONFIG_PATH)/gdlib.pc
	$(TOUCH)

# -----------------------------------------------------------------------------

LIBDPF_VER = 62c8fd0
LIBDPF_SOURCE = dpf-ax-git-$(LIBDPF_VER).tar.bz2

$(ARCHIVE)/$(LIBDPF_SOURCE):
	get-git-archive.sh https://bitbucket.org/max_10/dpf-ax $(LIBDPF_VER) $(notdir $@) $(ARCHIVE)

LIBDPF_PATCH  = libdpf-crossbuild.patch

$(D)/libdpf: $(D)/libusb_compat $(ARCHIVE)/$(LIBDPF_SOURCE) | $(TARGET_DIR)
	$(REMOVE)/dpf-ax-git-$(LIBDPF_VER)
	$(UNTAR)/$(LIBDPF_SOURCE)
	$(CHDIR)/dpf-ax-git-$(LIBDPF_VER)/dpflib; \
		$(call apply_patches, $(LIBDPF_PATCH)); \
		make libdpf.a CC=$(TARGET)-gcc PREFIX=$(TARGET_DIR); \
		mkdir -p $(TARGET_INCLUDE_DIR)/libdpf; \
		cp dpf.h $(TARGET_INCLUDE_DIR)/libdpf/libdpf.h; \
		cp ../include/spiflash.h $(TARGET_INCLUDE_DIR)/libdpf/; \
		cp ../include/usbuser.h $(TARGET_INCLUDE_DIR)/libdpf/; \
		cp libdpf.a $(TARGET_LIB_DIR)/
	$(REMOVE)/dpf-ax-git-$(LIBDPF_VER)
	$(TOUCH)

# -----------------------------------------------------------------------------

$(D)/lzo: $(ARCHIVE)/lzo-$(LZO_VER).tar.gz | $(TARGET_DIR)
	$(REMOVE)/lzo-$(LZO_VER)
	$(UNTAR)/lzo-$(LZO_VER).tar.gz
	$(CHDIR)/lzo-$(LZO_VER); \
		$(CONFIGURE) \
			--mandir=/.remove \
			--docdir=/.remove \
			--prefix= \
			; \
		$(MAKE); \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
	$(REWRITE_LIBTOOL)/liblzo2.la
	$(REMOVE)/lzo-$(LZO_VER)
	$(TOUCH)

# -----------------------------------------------------------------------------

$(D)/libsigc++: $(ARCHIVE)/libsigc++-$(LIBSIGCPP_VER).tar.xz | $(TARGET_DIR)
	$(REMOVE)/libsigc++-$(LIBSIGCPP_VER)
	$(UNTAR)/libsigc++-$(LIBSIGCPP_VER).tar.xz
	$(CHDIR)/libsigc++-$(LIBSIGCPP_VER); \
		$(CONFIGURE) \
			--prefix= \
			--disable-documentation \
			--enable-silent-rules \
			; \
		$(MAKE); \
		make install DESTDIR=$(TARGET_DIR); \
	ln -sf ./sigc++-2.0/sigc++ $(TARGET_INCLUDE_DIR)/sigc++
	cp $(BUILD_TMP)/libsigc++-$(LIBSIGCPP_VER)/sigc++config.h $(TARGET_INCLUDE_DIR)
	$(REWRITE_LIBTOOL)/libsigc-2.0.la
	$(REWRITE_PKGCONF) $(PKG_CONFIG_PATH)/sigc++-2.0.pc
	$(REMOVE)/libsigc++-$(LIBSIGCPP_VER)
	$(TOUCH)

# -----------------------------------------------------------------------------

$(D)/expat: $(ARCHIVE)/expat-$(EXPAT_VER).tar.bz2 | $(TARGET_DIR)
	$(REMOVE)/expat-$(EXPAT_VER)
	$(UNTAR)/expat-$(EXPAT_VER).tar.bz2
	$(CHDIR)/expat-$(EXPAT_VER); \
		$(CONFIGURE) \
			--prefix= \
			--docdir=/.remove \
			--mandir=/.remove \
			--enable-shared \
			--disable-static \
			--without-xmlwf \
			; \
		$(MAKE); \
		make install DESTDIR=$(TARGET_DIR)
	$(REWRITE_PKGCONF) $(PKG_CONFIG_PATH)/expat.pc
	$(REWRITE_LIBTOOL)/libexpat.la
	$(REMOVE)/expat-$(EXPAT_VER)
	$(TOUCH)

# -----------------------------------------------------------------------------

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

LUACURL_PATCH  = lua-curl-Makefile.diff

$(D)/luacurl: $(D)/libcurl $(D)/lua $(ARCHIVE)/Lua-cURL$(LUACURL_VER).tar.xz | $(TARGET_DIR)
	$(REMOVE)/Lua-cURL$(LUACURL_VER)
	$(UNTAR)/Lua-cURL$(LUACURL_VER).tar.xz
	$(CHDIR)/Lua-cURL$(LUACURL_VER); \
		$(call apply_patches, $(LUACURL_PATCH)); \
		$(BUILDENV) \
		CC=$(TARGET)-gcc \
		LUA_CMOD=/lib/lua/$(LUA_ABIVER) \
		LUA_LMOD=/share/lua/$(LUA_ABIVER) \
		LIBDIR=$(TARGET_LIB_DIR) \
		LUA_INC=$(TARGET_INCLUDE_DIR) \
		CURL_LIBS="$(TARGET_LDFLAGS) -lcurl" \
		$(MAKE); \
		LUA_CMOD=/lib/lua/$(LUA_ABIVER) \
		LUA_LMOD=/share/lua/$(LUA_ABIVER) \
		DESTDIR=$(TARGET_DIR) \
		$(MAKE) install
	$(REMOVE)/Lua-cURL$(LUACURL_VER)
	$(TOUCH)

# -----------------------------------------------------------------------------

LUAPOSIX_PATCH  = luaposix-fix-build.patch
LUAPOSIX_PATCH += luaposix-fix-docdir-build.patch

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

lua-libs: $(SOURCE_DIR)/$(NI_NEUTRINO-PLUGINS) | $(TARGET_DIR)
	cp -a $(SOURCE_DIR)/$(NI_NEUTRINO-PLUGINS)/scripts-lua/share/lua/5.2/* $(TARGET_DIR)/share/lua/$(LUA_ABIVER)/

# -----------------------------------------------------------------------------

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
	cd $(TARGET_LIB_DIR); ln -sf liblua.so.$(LUA_VER) $(TARGET_LIB_DIR)/liblua.so
	install -D -m 0644 $(BUILD_TMP)/lua-$(LUA_VER)/etc/lua.pc $(PKG_CONFIG_PATH)/lua.pc
	$(REWRITE_PKGCONF) $(PKG_CONFIG_PATH)/lua.pc
	rm -rf $(TARGET_DIR)/bin/luac
	$(REMOVE)/lua-$(LUA_VER)
	make lua-libs
	$(TOUCH)

# -----------------------------------------------------------------------------

LIBBLURAY_PATCH  = libbluray.diff

LIBBLURAY_DEPS = $(D)/freetype
ifeq ($(BOXSERIES), hd2)
  LIBBLURAY_DEPS += $(D)/libaacs $(D)/libbdplus
endif

$(D)/libbluray: $(LIBBLURAY_DEPS) $(ARCHIVE)/libbluray-$(LIBBLURAY_VER).tar.bz2 | $(TARGET_DIR)
	$(REMOVE)/libbluray-$(LIBBLURAY_VER)
	$(UNTAR)/libbluray-$(LIBBLURAY_VER).tar.bz2
	$(CHDIR)/libbluray-$(LIBBLURAY_VER); \
		$(call apply_patches, $(LIBBLURAY_PATCH)); \
		./bootstrap; \
		$(CONFIGURE) \
			--prefix= \
			--enable-shared \
			--disable-static \
			--disable-extra-warnings \
			--disable-doxygen-doc \
			--disable-doxygen-dot \
			--disable-doxygen-html \
			--disable-doxygen-ps \
			--disable-doxygen-pdf \
			--disable-examples \
			--disable-bdjava \
			--without-libxml2 \
			--without-fontconfig \
			$(BLURAY_CONFIGURE) \
			; \
		$(MAKE); \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
	$(REWRITE_LIBTOOL)/libbluray.la
	$(REWRITE_PKGCONF) $(PKG_CONFIG_PATH)/libbluray.pc
	$(REMOVE)/libbluray-$(LIBBLURAY_VER)
	$(TOUCH)

# -----------------------------------------------------------------------------

$(D)/libass: $(D)/freetype $(D)/libfribidi $(ARCHIVE)/libass-$(LIBASS_VER).tar.xz | $(TARGET_DIR)
	$(REMOVE)/libass-$(LIBASS_VER)
	$(UNTAR)/libass-$(LIBASS_VER).tar.xz
	$(CHDIR)/libass-$(LIBASS_VER); \
		$(CONFIGURE) \
			--target=$(TARGET) \
			--prefix= \
			--disable-static \
			--disable-test \
			--disable-fontconfig \
			--disable-harfbuzz \
			--disable-require-system-font-provider \
			; \
		$(MAKE); \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
	$(REMOVE)/libass-$(LIBASS_VER)
	$(REWRITE_LIBTOOL)/libass.la
	$(REWRITE_PKGCONF) $(PKG_CONFIG_PATH)/libass.pc
	$(TOUCH)
	
# -----------------------------------------------------------------------------

$(D)/libgpg-error: $(ARCHIVE)/libgpg-error-$(LIBGPG-ERROR_VER).tar.bz2 | $(TARGET_DIR)
	$(REMOVE)/libgpg-error-$(LIBGPG-ERROR_VER)
	$(UNTAR)/libgpg-error-$(LIBGPG-ERROR_VER).tar.bz2
	$(CHDIR)/libgpg-error-$(LIBGPG-ERROR_VER); \
		pushd src/syscfg; \
			ln -s lock-obj-pub.arm-unknown-linux-gnueabi.h lock-obj-pub.linux-uclibcgnueabi.h; \
		popd; \
		$(CONFIGURE) \
			--prefix= \
			--mandir=/.remove \
			--infodir=/.remove \
			--datarootdir=/.remove \
			--enable-maintainer-mode \
			--enable-shared \
			--disable-static \
			; \
		$(MAKE); \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
	mv $(TARGET_DIR)/bin/gpg-error-config $(HOST_DIR)/bin
	$(REWRITE_PKGCONF) $(HOST_DIR)/bin/gpg-error-config
	$(REWRITE_LIBTOOL)/libgpg-error.la
	rm -rf $(TARGET_DIR)/bin/gpg-error
	rm -rf $(TARGET_DIR)/share/common-lisp
	$(REMOVE)/libgpg-error-$(LIBGPG-ERROR_VER)
	$(TOUCH)

# -----------------------------------------------------------------------------

$(D)/libgcrypt: $(ARCHIVE)/libgcrypt-$(LIBGCRYPT_VER).tar.gz $(D)/libgpg-error | $(TARGET_DIR)
	$(REMOVE)/libgcrypt-$(LIBGCRYPT_VER)
	$(UNTAR)/libgcrypt-$(LIBGCRYPT_VER).tar.gz
	$(CHDIR)/libgcrypt-$(LIBGCRYPT_VER); \
		$(CONFIGURE) \
			--prefix= \
			--mandir=/.remove \
			--infodir=/.remove \
			--datarootdir=/.remove \
			--enable-maintainer-mode \
			--enable-silent-rules \
			--enable-shared \
			--disable-static \
			; \
		$(MAKE); \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
	mv $(TARGET_DIR)/bin/libgcrypt-config $(HOST_DIR)/bin
	$(REWRITE_PKGCONF) $(HOST_DIR)/bin/libgcrypt-config
	$(REWRITE_LIBTOOL)/libgcrypt.la
	rm -rf $(TARGET_DIR)/bin/dumpsexp
	rm -rf $(TARGET_DIR)/bin/hmac256
	rm -rf $(TARGET_DIR)/bin/mpicalc
	$(REMOVE)/libgcrypt-$(LIBGCRYPT_VER)
	$(TOUCH)

# -----------------------------------------------------------------------------

$(D)/libaacs: $(ARCHIVE)/libaacs-$(LIBAACS_VER).tar.bz2 $(D)/libgcrypt | $(TARGET_DIR)
	$(REMOVE)/libaacs-$(LIBAACS_VER)
	$(UNTAR)/libaacs-$(LIBAACS_VER).tar.bz2
	$(CHDIR)/libaacs-$(LIBAACS_VER); \
		./bootstrap; \
		$(CONFIGURE) \
			--prefix= \
			--enable-maintainer-mode \
			--enable-silent-rules \
			--enable-shared \
			--disable-static \
			; \
		$(MAKE); \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
	$(REWRITE_PKGCONF) $(PKG_CONFIG_PATH)/libaacs.pc
	$(REWRITE_LIBTOOL)/libaacs.la
	$(REMOVE)/libaacs-$(LIBAACS_VER)
	cd $(TARGET_DIR); \
		mkdir -p .config/aacs .cache/aacs/vuk
	cp $(IMAGEFILES)/libaacs/KEYDB.cfg $(TARGET_DIR)/.config/aacs
	$(TOUCH)

# -----------------------------------------------------------------------------

$(D)/libbdplus: $(ARCHIVE)/libbdplus-$(LIBBDPLUS_VER).tar.bz2 $(D)/libaacs | $(TARGET_DIR)
	$(REMOVE)/libbdplus-$(LIBBDPLUS_VER)
	$(UNTAR)/libbdplus-$(LIBBDPLUS_VER).tar.bz2
	$(CHDIR)/libbdplus-$(LIBBDPLUS_VER); \
		./bootstrap; \
		$(CONFIGURE) \
			--prefix= \
			--enable-maintainer-mode \
			--enable-silent-rules \
			--enable-shared \
			--disable-static \
			; \
		$(MAKE); \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
	$(REWRITE_PKGCONF) $(PKG_CONFIG_PATH)/libbdplus.pc
	$(REWRITE_LIBTOOL)/libbdplus.la
	$(REMOVE)/libbdplus-$(LIBBDPLUS_VER)
	cd $(TARGET_DIR); \
		mkdir -p .config/bdplus/vm0
	cp -f $(IMAGEFILES)/libbdplus/* $(TARGET_DIR)/.config/bdplus/vm0
	$(TOUCH)

# -----------------------------------------------------------------------------

$(D)/libxml2: $(ARCHIVE)/libxml2-$(LIBXML2_VER).tar.gz | $(TARGET_DIR)
	$(REMOVE)/libxml2-$(LIBXML2_VER)
	$(UNTAR)/libxml2-$(LIBXML2_VER).tar.gz
	$(CHDIR)/libxml2-$(LIBXML2_VER); \
		$(CONFIGURE) \
			--prefix= \
			--enable-shared \
			--disable-static \
			--datarootdir=/.remove \
			--without-python \
			--without-debug \
			--without-c14n \
			--without-legacy \
			--without-catalog \
			--without-docbook \
			--without-mem-debug \
			--without-lzma \
			--without-schematron \
			; \
		$(MAKE); \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
	mv $(TARGET_DIR)/bin/xml2-config $(HOST_DIR)/bin
	$(REWRITE_LIBTOOL)/libxml2.la
	$(REWRITE_PKGCONF) $(PKG_CONFIG_PATH)/libxml-2.0.pc
	$(REWRITE_PKGCONF) $(HOST_DIR)/bin/xml2-config
	rm -rf $(TARGET_LIB_DIR)/xml2Conf.sh
	rm -rf $(TARGET_LIB_DIR)/cmake
	$(REMOVE)/libxml2-$(LIBXML2_VER)
	$(TOUCH)

# -----------------------------------------------------------------------------

PUGIXML_PATCH = pugixml-config.patch

$(D)/pugixml: $(ARCHIVE)/pugixml-$(PUGIXML_VER).tar.gz | $(TARGET_DIR)
	$(REMOVE)/pugixml-$(PUGIXML_VER)
	$(UNTAR)/pugixml-$(PUGIXML_VER).tar.gz
	$(CHDIR)/pugixml-$(PUGIXML_VER); \
		$(call apply_patches, $(PUGIXML_PATCH)); \
		$(CMAKE); \
		$(MAKE); \
		make install DESTDIR=$(TARGET_DIR)
	rm -rf $(TARGET_LIB_DIR)/cmake
	$(REMOVE)/pugixml-$(PUGIXML_VER)
	$(TOUCH)

# -----------------------------------------------------------------------------

$(D)/librtmp: $(D)/zlib $(D)/openssl $(SOURCE_DIR)/$(NI_RTMPDUMP) | $(TARGET_DIR)
	$(REMOVE)/$(NI_RTMPDUMP)
	tar -C $(SOURCE_DIR) -cp $(NI_RTMPDUMP) --exclude-vcs | tar -C $(BUILD_TMP) -x
	$(CHDIR)/$(NI_RTMPDUMP); \
		make CROSS_COMPILE=$(TARGET)- XCFLAGS="-I$(TARGET_INCLUDE_DIR) -L$(TARGET_LIB_DIR)" LDFLAGS="-L$(TARGET_LIB_DIR)" prefix=$(TARGET_DIR);\
		make install DESTDIR=$(TARGET_DIR) prefix="" mandir=/.remove
	rm -rf $(TARGET_DIR)/sbin/rtmpgw
	rm -rf $(TARGET_DIR)/sbin/rtmpsrv
	rm -rf $(TARGET_DIR)/sbin/rtmpsuck
	$(REWRITE_PKGCONF) $(PKG_CONFIG_PATH)/librtmp.pc
	$(REMOVE)/$(NI_RTMPDUMP)
	$(TOUCH)

# -----------------------------------------------------------------------------

LIBTIRP_PATCH  = libtirpc-0001-Disable-parts-of-TIRPC-requiring-NIS-support.patch
LIBTIRP_PATCH += libtirpc-0002-uClibc-without-RPC-support-and-musl-does-not-install-rpcent.h.patch
LIBTIRP_PATCH += libtirpc-0003-Add-rpcgen-program-from-nfs-utils-sources.patch
LIBTIRP_PATCH += libtirpc-0004-Automatically-generate-XDR-header-files-from-.x-sour.patch
LIBTIRP_PATCH += libtirpc-0005-Add-more-XDR-files-needed-to-build-rpcbind-on-top-of.patch
LIBTIRP_PATCH += libtirpc-0006-Disable-DES-authentification-support.patch
LIBTIRP_PATCH += libtirpc-0007-include-stdint.h-for-uintptr_t.patch

$(D)/libtirpc: $(ARCHIVE)/libtirpc-$(LIBTIRPC_VER).tar.bz2 | $(TARGET_DIR)
	$(REMOVE)/libtirpc-$(LIBTIRPC_VER)
	$(UNTAR)/libtirpc-$(LIBTIRPC_VER).tar.bz2
	$(CHDIR)/libtirpc-$(LIBTIRPC_VER); \
		$(call apply_patches, $(LIBTIRP_PATCH)); \
		autoreconf -fi; \
		$(CONFIGURE) \
			--target=$(TARGET) \
			--prefix= \
			--disable-gssapi \
			--enable-silent-rules \
			--mandir=/.remove \
			; \
		$(MAKE); \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
	$(REWRITE_LIBTOOL)/libtirpc.la
	$(REWRITE_PKGCONF) $(PKG_CONFIG_PATH)/libtirpc.pc
	$(REMOVE)/libtirpc-$(LIBTIRPC_VER)
	$(TOUCH)

# -----------------------------------------------------------------------------

$(D)/confuse: $(ARCHIVE)/confuse-$(CONFUSE_VER).tar.xz | $(TARGET_DIR)
	$(REMOVE)/confuse-$(CONFUSE_VER)
	$(UNTAR)/confuse-$(CONFUSE_VER).tar.xz
	$(CHDIR)/confuse-$(CONFUSE_VER); \
		$(CONFIGURE) \
			--prefix= \
			--docdir=/.remove \
			--mandir=/.remove \
			--enable-silent-rules \
			--enable-static \
			--disable-shared \
			; \
		$(MAKE); \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
	$(REWRITE_PKGCONF) $(PKG_CONFIG_PATH)/libconfuse.pc
	$(REMOVE)/confuse-$(CONFUSE_VER)
	$(TOUCH)

# -----------------------------------------------------------------------------

$(D)/libite: $(ARCHIVE)/libite-$(ITE_VER).tar.xz | $(TARGET_DIR)
	$(REMOVE)/libite-$(ITE_VER)
	$(UNTAR)/libite-$(ITE_VER).tar.xz
	$(CHDIR)/libite-$(ITE_VER); \
		$(CONFIGURE) \
			--prefix= \
			--docdir=/.remove \
			--mandir=/.remove \
			--enable-silent-rules \
			--enable-static \
			--disable-shared \
			; \
		$(MAKE); \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
	$(REWRITE_PKGCONF) $(PKG_CONFIG_PATH)/libite.pc
	$(REMOVE)/libite-$(ITE_VER)
	$(TOUCH)

# -----------------------------------------------------------------------------

LIBMAD_PATCH  = libmad-pc-fix.diff
LIBMAD_PATCH += libmad-frame_length.diff
LIBMAD_PATCH += libmad-mips-h-constraint-removal.patch
LIBMAD_PATCH += libmad-remove-deprecated-cflags.patch
LIBMAD_PATCH += libmad-thumb2-fixed-arm.patch
LIBMAD_PATCH += libmad-thumb2-imdct-arm.patch

$(D)/libmad: $(ARCHIVE)/libmad-$(LIBMAD_VER).tar.gz | $(TARGET_DIR)
	$(REMOVE)/libmad-$(LIBMAD_VER)
	$(UNTAR)/libmad-$(LIBMAD_VER).tar.gz
	$(CHDIR)/libmad-$(LIBMAD_VER); \
		$(call apply_patches, $(LIBMAD_PATCH)); \
		touch NEWS AUTHORS ChangeLog; \
		autoreconf -fi; \
		$(CONFIGURE) \
			--prefix= \
			--enable-shared=yes \
			--enable-accuracy \
			--enable-fpm=arm \
			--enable-sso \
			; \
		$(MAKE) all; \
		make install DESTDIR=$(TARGET_DIR); \
		sed "s!^prefix=.*!prefix=$(TARGET_DIR)!;" mad.pc > $(PKG_CONFIG_PATH)/libmad.pc
	$(REWRITE_LIBTOOL)/libmad.la
	$(REMOVE)/libmad-$(LIBMAD_VER)
	$(TOUCH)

# -----------------------------------------------------------------------------

$(D)/libvorbisidec: $(ARCHIVE)/libvorbisidec_$(LIBVORBISIDEC_VER).orig.tar.gz $(D)/libogg | $(TARGET_DIR)
	$(REMOVE)/libvorbisidec-$(LIBVORBISIDEC_VER)
	$(UNTAR)/libvorbisidec_$(LIBVORBISIDEC_VER).orig.tar.gz
	$(CHDIR)/libvorbisidec-$(LIBVORBISIDEC_VER); \
		sed -i '122 s/^/#/' configure.in; \
		autoreconf -fi; \
		$(BUILDENV) \
		$(CONFIGURE) \
			--prefix= \
			; \
		make all; \
		make install DESTDIR=$(TARGET_DIR); \
	$(REMOVE)/libvorbisidec-$(LIBVORBISIDEC_VER)
	$(REWRITE_PKGCONF) $(PKG_CONFIG_PATH)/vorbisidec.pc
	$(REWRITE_LIBTOOL)/libvorbisidec.la
	$(TOUCH)

# -----------------------------------------------------------------------------

$(D)/libogg: $(ARCHIVE)/libogg-$(LIBOGG_VER).tar.xz | $(TARGET_DIR)
	$(REMOVE)/libogg-$(LIBOGG_VER)
	$(UNTAR)/libogg-$(LIBOGG_VER).tar.xz
	$(CHDIR)/libogg-$(LIBOGG_VER); \
		$(CONFIGURE) \
			--prefix= \
			--datarootdir=/.remove \
			--enable-shared \
			; \
		$(MAKE); \
		make install DESTDIR=$(TARGET_DIR)
	$(REWRITE_PKGCONF) $(PKG_CONFIG_PATH)/ogg.pc
	$(REWRITE_LIBTOOL)/libogg.la
	$(REMOVE)/libogg-$(LIBOGG_VER)
	$(TOUCH)

# -----------------------------------------------------------------------------

$(D)/libfribidi: $(ARCHIVE)/fribidi-$(FRIBIDI_VER).tar.bz2 | $(TARGET_DIR)
	$(REMOVE)/fribidi-$(FRIBIDI_VER)
	$(UNTAR)/fribidi-$(FRIBIDI_VER).tar.bz2
	$(CHDIR)/fribidi-$(FRIBIDI_VER); \
		$(CONFIGURE) \
			--prefix= \
			--mandir=/.remove \
			--disable-debug \
			--disable-deprecated \
			--enable-charsets \
			--with-glib=no \
			; \
		$(MAKE); \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
	$(REWRITE_PKGCONF) $(PKG_CONFIG_PATH)/fribidi.pc
	$(REWRITE_LIBTOOL)/libfribidi.la
	$(REMOVE)/fribidi-$(FRIBIDI_VER)
	$(TOUCH)

# -----------------------------------------------------------------------------

LIBFFI_PATCH  = libffi-install_headers.patch

LIBFFI_CONF =
ifeq ($(BOXSERIES), hd1)
	LIBFFI_CONF = --enable-static --disable-shared
endif

$(D)/libffi: $(ARCHIVE)/libffi-$(LIBFFI_VER).tar.gz
	$(REMOVE)/libffi-$(LIBFFI_VER)
	$(UNTAR)/libffi-$(LIBFFI_VER).tar.gz
	$(CHDIR)/libffi-$(LIBFFI_VER); \
		$(call apply_patches, $(LIBFFI_PATCH)); \
		$(CONFIGURE) \
			--prefix= \
			--datarootdir=/.remove \
			$(LIBFFI_CONF) \
			; \
		$(MAKE) all; \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
	$(REWRITE_PKGCONF) $(PKG_CONFIG_PATH)/libffi.pc
	$(REWRITE_LIBTOOL)/libffi.la
	$(REMOVE)/libffi-$(LIBFFI_VER)
	$(TOUCH)

# -----------------------------------------------------------------------------

# glibc provides a stub gettext implementation, so we only build it for hd2

LIBGLIB2_DEPS =
ifeq ($(BOXSERIES), hd2)
	LIBGLIB2_DEPS = $(D)/gettext
endif

LIBGLIB2_CONF =
ifeq ($(BOXSERIES), hd1)
	LIBGLIB2_CONF = --enable-static --disable-shared
endif

LIBGLIB2_PATCH  = libglib2-disable-tests.patch

$(D)/libglib2: $(ARCHIVE)/glib-$(GLIB_VER).tar.xz $(D)/zlib $(LIBGLIB2_DEPS) $(D)/libffi | $(TARGET_DIR)
	$(REMOVE)/glib-$(GLIB_VER)
	$(UNTAR)/glib-$(GLIB_VER).tar.xz
	$(CHDIR)/glib-$(GLIB_VER); \
		$(call apply_patches, $(LIBGLIB2_PATCH)); \
		echo "ac_cv_type_long_long=yes"		 > arm-linux.cache; \
		echo "glib_cv_stack_grows=no"		>> arm-linux.cache; \
		echo "glib_cv_uscore=no"		>> arm-linux.cache; \
		echo "glib_cv_va_copy=no"		>> arm-linux.cache; \
		echo "glib_cv_va_val_copy=yes"		>> arm-linux.cache; \
		echo "ac_cv_func_posix_getpwuid_r=yes"	>> arm-linux.cache; \
		echo "ac_cv_func_posix_getgrgid_r=yes"	>> arm-linux.cache; \
		autoreconf -fi; \
		$(CONFIGURE) \
			--prefix= \
			--datarootdir=/.remove \
			--cache-file=arm-linux.cache \
			--disable-debug \
			--disable-selinux \
			--disable-libmount \
			--disable-fam \
			--disable-gtk-doc \
			--disable-gtk-doc-html \
			--disable-compile-warnings \
			--with-threads="posix" \
			--with-pcre=internal \
			$(LIBGLIB2_CONF) \
			; \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
	rm -rf $(TARGET_DIR)/bin/gapplication
	rm -rf $(TARGET_DIR)/bin/gdbus*
	rm -rf $(TARGET_DIR)/bin/gio*
	rm -rf $(TARGET_DIR)/bin/glib*
	rm -rf $(TARGET_DIR)/bin/gobject-query
	rm -rf $(TARGET_DIR)/bin/gresource
	rm -rf $(TARGET_DIR)/bin/gsettings
	rm -rf $(TARGET_DIR)/bin/gtester*
	$(REWRITE_PKGCONF) $(PKG_CONFIG_PATH)/gio-2.0.pc
	$(REWRITE_PKGCONF) $(PKG_CONFIG_PATH)/gio-unix-2.0.pc
	$(REWRITE_PKGCONF) $(PKG_CONFIG_PATH)/glib-2.0.pc
	$(REWRITE_PKGCONF) $(PKG_CONFIG_PATH)/gmodule-2.0.pc
	$(REWRITE_PKGCONF) $(PKG_CONFIG_PATH)/gmodule-export-2.0.pc
	$(REWRITE_PKGCONF) $(PKG_CONFIG_PATH)/gmodule-no-export-2.0.pc
	$(REWRITE_PKGCONF) $(PKG_CONFIG_PATH)/gobject-2.0.pc
	$(REWRITE_PKGCONF) $(PKG_CONFIG_PATH)/gthread-2.0.pc
	$(REWRITE_LIBTOOL)/libgio-2.0.la
	$(REWRITE_LIBTOOL)/libglib-2.0.la
	$(REWRITE_LIBTOOL)/libgmodule-2.0.la
	$(REWRITE_LIBTOOL)/libgobject-2.0.la
	$(REWRITE_LIBTOOL)/libgthread-2.0.la
	$(REMOVE)/glib-$(GLIB_VER)
	$(TOUCH)

# -----------------------------------------------------------------------------

ALSA-LIB_PATCH  = alsa-lib.patch
ALSA-LIB_PATCH += alsa-lib-link_fix.patch

$(D)/alsa-lib: $(ARCHIVE)/$(ALSA-LIB_SOURCE)
	$(REMOVE)/alsa-lib-$(ALSA-LIB_VER)
	$(UNTAR)/$(ALSA-LIB_SOURCE)
	$(CHDIR)/alsa-lib-$(ALSA-LIB_VER); \
		$(call apply_patches, $(ALSA-LIB_PATCH)); \
		$(CONFIGURE) \
			--prefix= \
			--datarootdir=/.remove \
			--with-alsa-devdir=/dev/snd/ \
			--with-plugindir=/lib/alsa \
			--without-debug \
			--with-debug=no \
			--with-versioned=no \
			--enable-symbolic-functions \
			--disable-aload \
			--disable-rawmidi \
			--disable-resmgr \
			--disable-old-symbols \
			--disable-alisp \
			--disable-hwdep \
			--disable-python \
			; \
		$(MAKE); \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
	$(REWRITE_PKGCONF) $(PKG_CONFIG_PATH)/alsa.pc
	$(REWRITE_LIBTOOL)/libasound.la
	$(REMOVE)/alsa-lib-$(ALSA-LIB_VER)
	$(TOUCH)
