# makefile to build system libs

$(D)/zlib: $(ARCHIVE)/zlib-$(ZLIB_VER).tar.gz | $(TARGET_DIR)
	$(UNTAR)/zlib-$(ZLIB_VER).tar.gz
	cd $(BUILD_TMP)/zlib-$(ZLIB_VER) && \
		$(PATCH)/zlib-ldflags-tests.patch && \
		$(PATCH)/zlib-remove.ldconfig.call.patch && \
		rm -rf config.cache && \
		$(BUILDENV) \
		CC=$(TARGET)-gcc \
		LD=$(TARGET)-ld \
		AR="$(TARGET)-ar" \
		RANLIB=$(TARGET)-ranlib \
		LDFLAGS="$(TARGET_LDFLAGS)" \
		mandir=$(BUILD_TMP)/zlib-$(ZLIB_VER)/.remove \
		./configure \
			--prefix= \
			--shared && \
		$(MAKE) && \
		$(MAKE) install prefix=$(TARGET_DIR)
	$(REWRITE_PKGCONF) $(PKG_CONFIG_PATH)/zlib.pc
	$(REMOVE)/zlib-$(ZLIB_VER)
	touch $@

$(D)/libfuse: $(ARCHIVE)/fuse-$(FUSE_VER).tar.gz | $(TARGET_DIR)
	$(UNTAR)/fuse-$(FUSE_VER).tar.gz
	pushd $(BUILD_TMP)/fuse-$(FUSE_VER) && \
		$(CONFIGURE) \
			--prefix= \
			--datarootdir=/.remove \
			--disable-static \
			--disable-example \
			--disable-mtab \
			--with-gnu-ld \
			--enable-util \
			--enable-lib \
			--enable-silent-rules && \
		$(MAKE) all && \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
	$(REWRITE_LIBTOOL)/libfuse.la
	$(REWRITE_LIBTOOL)/libulockmgr.la
	$(REWRITE_PKGCONF) $(PKG_CONFIG_PATH)/fuse.pc
	rm -rf $(TARGET_DIR)/etc/udev
	rm -rf $(TARGET_DIR)/etc/init.d/fuse
	$(REMOVE)/fuse-$(FUSE_VER)
	touch $@

$(D)/libupnp: $(ARCHIVE)/libupnp-$(LIBUPNP_VER).tar.bz2 | $(TARGET_DIR)
	$(UNTAR)/libupnp-$(LIBUPNP_VER).tar.bz2
	pushd $(BUILD_TMP)/libupnp-$(LIBUPNP_VER) && \
		$(CONFIGURE) \
			--prefix= \
			--enable-shared \
			--disable-static && \
		$(MAKE) && \
		$(MAKE) install DESTDIR=$(TARGET_DIR) && \
	$(REMOVE)/libupnp-$(LIBUPNP_VER)
	$(REWRITE_LIBTOOL)/libixml.la
	$(REWRITE_LIBTOOL)/libthreadutil.la
	$(REWRITE_LIBTOOL)/libupnp.la
	$(REWRITE_PKGCONF) $(PKG_CONFIG_PATH)/libupnp.pc
	touch $@
	
$(D)/libdvbsi: | $(TARGET_DIR)
	$(REMOVE)/libdvbsi++
	git clone git://git.opendreambox.org/git/obi/libdvbsi++.git $(BUILD_TMP)/libdvbsi++
	cd $(BUILD_TMP)/libdvbsi++; \
		$(PATCH)/libdvbsi++-fix-sectionLength-check.patch; \
		$(PATCH)/libdvbsi++-content_identifier_descriptor.patch; \
		$(CONFIGURE) \
			--prefix= \
			--enable-shared \
			--enable-silent-rules \
			--disable-static; \
		$(MAKE); \
		make install DESTDIR=$(TARGET_DIR); \
	$(REMOVE)/libdvbsi++
	$(REWRITE_LIBTOOL)/libdvbsi++.la
	$(REWRITE_PKGCONF) $(PKG_CONFIG_PATH)/libdvbsi++.pc
	touch $@

$(D)/giflib: $(ARCHIVE)/giflib-$(GIFLIB_VER).tar.bz2 | $(TARGET_DIR)
	$(UNTAR)/giflib-$(GIFLIB_VER).tar.bz2
	pushd $(BUILD_TMP)/giflib-$(GIFLIB_VER) && \
		export ac_cv_prog_have_xmlto=no && \
		$(CONFIGURE) \
			--prefix= \
			--disable-static \
			--enable-shared \
			--bindir=/.remove && \
		$(MAKE) all && \
		make install DESTDIR=$(TARGET_DIR)
	$(REWRITE_LIBTOOL)/libgif.la
	$(REMOVE)/giflib-$(GIFLIB_VER)
	touch $@

CURL_IPV6="--enable-ipv6"
ifeq ($(BOXSERIES), hd1)
	CURL_IPV6="--disable-ipv6"
endif

$(D)/libcurl: $(D)/zlib $(D)/openssl $(D)/librtmp $(D)/ca-bundle $(ARCHIVE)/curl-$(LIBCURL_VER).tar.bz2 | $(TARGET_DIR)
	$(UNTAR)/curl-$(LIBCURL_VER).tar.bz2
	pushd $(BUILD_TMP)/curl-$(LIBCURL_VER) && \
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
			--with-ca-bundle=$(CA_BUNDLE_DIR)/$(CA_BUNDLE) \
			--with-random=/dev/urandom \
			--with-ssl=$(TARGET_DIR) \
			--with-librtmp=$(TARGET_DIR)/lib \
			$(CURL_IPV6) \
			--enable-optimize && \
		$(MAKE) all && \
		mkdir -p $(HOST_DIR)/bin && \
		sed -e "s,^prefix=,prefix=$(TARGET_DIR)," < curl-config > $(HOST_DIR)/bin/curl-config && \
		chmod 755 $(HOST_DIR)/bin/curl-config && \
		make install DESTDIR=$(TARGET_DIR)
	rm -rf $(TARGET_DIR)/bin/curl-config $(TARGET_DIR)/share/zsh
	$(REWRITE_LIBTOOL)/libcurl.la
	$(REWRITE_PKGCONF) $(PKG_CONFIG_PATH)/libcurl.pc
	$(REMOVE)/curl-$(LIBCURL_VER)
	touch $@

LIBPNG_CONF =
ifneq ($(BOXSERIES), hd51)
	LIBPNG_CONF = --disable-arm-neon
endif

$(D)/libpng: $(ARCHIVE)/libpng-$(LIBPNG_VER).tar.xz $(D)/zlib | $(TARGET_DIR)
	$(UNTAR)/libpng-$(LIBPNG_VER).tar.xz
	pushd $(BUILD_TMP)/libpng-$(LIBPNG_VER) && \
		$(PATCH)/libpng-Disable-pngfix-and-png-fix-itxt.patch && \
		$(CONFIGURE) \
			--prefix=$(TARGET_DIR) \
			--bindir=$(HOST_DIR)/bin \
			--mandir=$(BUILD_TMP)/.remove \
			--enable-silent-rules \
			$(LIBPNG_CONF) \
			--disable-static && \
		ECHO=echo $(MAKE) all && \
		make install
	$(REMOVE)/libpng-$(LIBPNG_VER)
	touch $@

$(D)/freetype: $(D)/zlib $(D)/libpng $(ARCHIVE)/freetype-$(FREETYPE_VER).tar.bz2 | $(TARGET_DIR)
	$(UNTAR)/freetype-$(FREETYPE_VER).tar.bz2
	pushd $(BUILD_TMP)/freetype-$(FREETYPE_VER) && \
		$(PATCH)/freetype2_subpixel.patch; \
		sed -i '/^FONT_MODULES += \(type1\|cid\|pfr\|type42\|pcf\|bdf\|winfonts\|cff\)/d' modules.cfg
	pushd $(BUILD_TMP)/freetype-$(FREETYPE_VER)/builds/unix && \
		libtoolize --force --copy && \
		aclocal -I . && \
		autoconf
	pushd $(BUILD_TMP)/freetype-$(FREETYPE_VER) && \
		$(CONFIGURE) \
			--prefix=$(TARGET_DIR) \
			--mandir=$(BUILD_TMP)/.remove \
			--enable-shared \
			--with-png \
			--with-zlib \
			--without-harfbuzz \
			--without-bzip2 \
			--disable-static && \
		$(MAKE) all && \
		make install && \
		ln -sf ./freetype2/freetype $(TARGET_INCLUDE_DIR)/freetype && \
	mv $(TARGET_DIR)/bin/freetype-config $(HOST_DIR)/bin/freetype-config
	$(REMOVE)/freetype-$(FREETYPE_VER) $(TARGET_DIR)/share/aclocal
	touch $@

$(D)/libjpeg: $(ARCHIVE)/libjpeg-turbo-$(LIBJPEG-TURBO_VER).tar.gz | $(TARGET_DIR)
	$(UNTAR)/libjpeg-turbo-$(LIBJPEG-TURBO_VER).tar.gz
	cd $(BUILD_TMP)/libjpeg-turbo-$(LIBJPEG-TURBO_VER) && \
		export CC=$(TARGET)-gcc && \
		$(CONFIGURE) \
			--prefix= \
			--enable-shared \
			--mandir=/.remove \
			--bindir=/.remove \
			--datadir=/.remove \
			--datarootdir=/.remove \
			--disable-static && \
		$(MAKE)  && \
		make install DESTDIR=$(TARGET_DIR)
	$(REWRITE_LIBTOOL)/libjpeg.la
	rm -f $(TARGET_LIB_DIR)/libturbojpeg* $(TARGET_INCLUDE_DIR)/turbojpeg.h
	$(REMOVE)/libjpeg-turbo-$(LIBJPEG-TURBO_VER)
	touch $@

OPENSSLFLAGS = CC=$(TARGET)-gcc \
		LD=$(TARGET)-ld \
		AR="$(TARGET)-ar r" \
		RANLIB=$(TARGET)-ranlib \
		MAKEDEPPROG=$(TARGET)-gcc \
		NI_OPTIMIZATION_FLAGS="$(TARGET_CFLAGS)" \
		PROCESSOR=ARM

$(D)/openssl: $(ARCHIVE)/openssl-$(OPENSSL_VER).tar.gz | $(TARGET_DIR)
	$(UNTAR)/openssl-$(OPENSSL_VER).tar.gz
	pushd $(BUILD_TMP)/openssl-$(OPENSSL_VER) && \
	$(PATCH)/openssl-add-ni-specific-target.patch && \
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
			--openssldir=/.remove && \
		make $(OPENSSLFLAGS) depend && \
		sed -i "s# build_tests##" Makefile && \
		make $(OPENSSLFLAGS) all && \
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
	touch $@

$(D)/libncurses: $(ARCHIVE)/ncurses-$(LIBNCURSES_VER).tar.gz | $(TARGET_DIR)
	$(UNTAR)/ncurses-$(LIBNCURSES_VER).tar.gz && \
	pushd $(BUILD_TMP)/ncurses-$(LIBNCURSES_VER) && \
	$(PATCH)/ncurses-gcc-5.x-MKlib_gen.patch && \
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
			--without-cxx-binding && \
		$(MAKE) libs && \
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
	touch $@

$(D)/openthreads: $(SOURCE_DIR)/$(NI_OPENTHREADS) | $(TARGET_DIR)
	$(REMOVE)/$(NI_OPENTHREADS)
	tar -C $(SOURCE_DIR) -cp $(NI_OPENTHREADS) --exclude-vcs | tar -C $(BUILD_TMP) -x
	cd $(BUILD_TMP)/$(NI_OPENTHREADS)/ && \
		rm -f CMakeCache.txt && \
			cmake \
			-DCMAKE_BUILD_TYPE="None" \
			-DCMAKE_SYSTEM_NAME="Linux" \
			-DCMAKE_SYSTEM_PROCESSOR="arm" \
			-DCMAKE_CXX_FLAGS="$(TARGET_CFLAGS) -DNDEBUG" \
			-DCMAKE_INSTALL_PREFIX="" \
			-DCMAKE_C_COMPILER="$(TARGET)-gcc" \
			-DCMAKE_CXX_COMPILER="$(TARGET)-g++" \
			-DCMAKE_LINKER="$(CROSS_DIR)/bin/$(TARGET)-ld" \
			-DCMAKE_RANLIB="$(CROSS_DIR)/bin/$(TARGET)-ranlib" \
			-DCMAKE_AR="$(CROSS_DIR)/bin/$(TARGET)-ar" \
			-DCMAKE_NM="$(CROSS_DIR)/bin/$(TARGET)-nm" \
			-DCMAKE_OBJDUMP="$(CROSS_DIR)/bin/$(TARGET)-objdump" \
			-DCMAKE_STRIP="$(CROSS_DIR)/bin/$(TARGET)-strip" \
			-DCMAKE_SUPPRESS_DEVELOPER_WARNINGS="1" \
			-D_OPENTHREADS_ATOMIC_USE_GCC_BUILTINS_EXITCODE="0" && \
		$(MAKE) && \
		make install DESTDIR=$(TARGET_DIR)
		$(REWRITE_PKGCONF) $(PKG_CONFIG_PATH)/openthreads.pc
	$(REMOVE)/$(NI_OPENTHREADS)
	$(REWRITE_PKGCONF) $(PKG_CONFIG_PATH)/openthreads.pc
	touch $@

$(D)/libusb: $(ARCHIVE)/libusb-$(LIBUSB_VER).tar.bz2 | $(TARGET_DIR)
	$(UNTAR)/libusb-$(LIBUSB_VER).tar.bz2
	pushd $(BUILD_TMP)/libusb-$(LIBUSB_VER) && \
		$(CONFIGURE) \
			--prefix= \
			--disable-udev && \
		$(MAKE) && \
		make install DESTDIR=$(TARGET_DIR) && \
	$(REMOVE)/libusb-$(LIBUSB_VER)
	$(REWRITE_LIBTOOL)/libusb-$(LIBUSB_MAJ).la
	$(REWRITE_PKGCONF) $(PKG_CONFIG_PATH)/libusb-$(LIBUSB_MAJ).pc
	touch $@

$(D)/libusb_compat: $(ARCHIVE)/libusb-compat-$(LIBUSB_COMPAT_VER).tar.bz2 $(D)/libusb | $(TARGET_DIR)
	$(UNTAR)/libusb-compat-$(LIBUSB_COMPAT_VER).tar.bz2
	pushd $(BUILD_TMP)/libusb-compat-$(LIBUSB_COMPAT_VER) && \
		$(CONFIGURE) \
			--prefix= && \
		$(MAKE) && \
		make install DESTDIR=$(TARGET_DIR) && \
	$(REMOVE)/libusb-compat-$(LIBUSB_COMPAT_VER)
	mv $(TARGET_DIR)/bin/libusb-config $(HOST_DIR)/bin
	$(REWRITE_PKGCONF) $(HOST_DIR)/bin/libusb-config
	$(REWRITE_LIBTOOL)/libusb.la
	$(REWRITE_PKGCONF) $(PKG_CONFIG_PATH)/libusb.pc
	touch $@

$(D)/libgd2: $(D)/zlib $(D)/libpng $(D)/libjpeg $(D)/freetype $(ARCHIVE)/libgd-$(LIBGD_VER).tar.xz | $(TARGET_DIR)
	$(UNTAR)/libgd-$(LIBGD_VER).tar.xz
	pushd $(BUILD_TMP)/libgd-$(LIBGD_VER) && \
		./bootstrap.sh && \
		$(CONFIGURE) \
			--prefix= \
			--bindir=/.remove \
			--without-fontconfig \
			--without-xpm \
			--without-x && \
		$(MAKE) && \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
	$(REMOVE)/libgd-$(LIBGD_VER)
	$(REWRITE_LIBTOOL)/libgd.la
	$(REWRITE_PKGCONF) $(PKG_CONFIG_PATH)/gdlib.pc
	touch $@

DPF-AX_REV=54
$(ARCHIVE)/dpf-ax_svn$(DPF-AX_REV).tar.gz:
	cd $(BUILD_TMP); \
		svn co -r$(DPF-AX_REV) https://dpf-ax.svn.sourceforge.net/svnroot/dpf-ax/trunk dpf-ax_svn$(DPF-AX_REV); \
		tar cvpzf $@ dpf-ax_svn$(DPF-AX_REV)
	$(REMOVE)/dpf-ax_svn$(DPF-AX_REV)

$(D)/libdpf: $(D)/libusb_compat $(ARCHIVE)/dpf-ax_svn$(DPF-AX_REV).tar.gz | $(TARGET_DIR)
	$(UNTAR)/dpf-ax_svn$(DPF-AX_REV).tar.gz
	cd $(BUILD_TMP)/dpf-ax_svn$(DPF-AX_REV)/dpflib && \
		$(PATCH)/libdpf-crossbuild.diff; \
		make libdpf.a CC=$(TARGET)-gcc PREFIX=$(TARGET_DIR); \
		mkdir -p $(TARGET_INCLUDE_DIR)/libdpf; \
		cp dpf.h $(TARGET_INCLUDE_DIR)/libdpf/libdpf.h; \
		cp ../include/spiflash.h $(TARGET_INCLUDE_DIR)/libdpf/; \
		cp ../include/usbuser.h $(TARGET_INCLUDE_DIR)/libdpf/; \
		cp libdpf.a $(TARGET_LIB_DIR)/
	$(REMOVE)/dpf-ax_svn$(DPF-AX_REV)
	touch $@

$(D)/lzo: $(ARCHIVE)/lzo-$(LZO_VER).tar.gz | $(TARGET_DIR)
	$(UNTAR)/lzo-$(LZO_VER).tar.gz
	cd $(BUILD_TMP)/lzo-$(LZO_VER) && \
		$(CONFIGURE) \
			--mandir=/.remove \
			--docdir=/.remove \
			--prefix= && \
		$(MAKE) && \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
	$(REWRITE_LIBTOOL)/liblzo2.la
	$(REMOVE)/lzo-$(LZO_VER)
	touch $@

$(D)/libsigc++: $(ARCHIVE)/libsigc++-$(LIBSIGCPP_VER).tar.xz | $(TARGET_DIR)
	$(UNTAR)/libsigc++-$(LIBSIGCPP_VER).tar.xz
	set -e; cd $(BUILD_TMP)/libsigc++-$(LIBSIGCPP_VER); \
		$(CONFIGURE) \
			--prefix= \
			--disable-documentation \
			--enable-silent-rules; \
		$(MAKE); \
		make install DESTDIR=$(TARGET_DIR); \
	ln -sf ./sigc++-2.0/sigc++ $(TARGET_INCLUDE_DIR)/sigc++
	cp $(BUILD_TMP)/libsigc++-$(LIBSIGCPP_VER)/sigc++config.h $(TARGET_INCLUDE_DIR)
	$(REWRITE_LIBTOOL)/libsigc-2.0.la
	$(REWRITE_PKGCONF) $(PKG_CONFIG_PATH)/sigc++-2.0.pc
	$(REMOVE)/libsigc++-$(LIBSIGCPP_VER)
	touch $@

$(D)/expat: $(ARCHIVE)/expat-$(EXPAT_VER).tar.gz | $(TARGET_DIR)
	$(UNTAR)/expat-$(EXPAT_VER).tar.gz
	set -e; cd $(BUILD_TMP)/expat-$(EXPAT_VER); \
		$(CONFIGURE) \
			--prefix= \
			--mandir=/.remove \
			--enable-shared \
			--disable-static; \
		$(MAKE); \
		make install DESTDIR=$(TARGET_DIR)
	$(REWRITE_PKGCONF) $(PKG_CONFIG_PATH)/expat.pc
	$(REWRITE_LIBTOOL)/libexpat.la
	$(REMOVE)/expat-$(EXPAT_VER)
	touch $@

$(D)/luaexpat: $(ARCHIVE)/luaexpat-$(LUA_EXPAT_VER).tar.gz $(D)/expat | $(TARGET_DIR)
	$(UNTAR)/luaexpat-$(LUA_EXPAT_VER).tar.gz
	set -e; cd $(BUILD_TMP)/luaexpat-$(LUA_EXPAT_VER); \
		rm makefile*; \
		$(PATCH)/luaexpat-makefile.diff; \
		$(PATCH)/luaexpat-1.3.0-lua-5.2.patch; \
		$(PATCH)/luaexpat-lua-5.2-test-fix.patch; \
		$(MAKE) \
		CC=$(TARGET)-gcc LUA_V=$(LUA_ABIVER) LDFLAGS="$(TARGET_LDFLAGS)" \
		LUA_INC=-I$(TARGET_INCLUDE_DIR) EXPAT_INC=-I$(TARGET_INCLUDE_DIR); \
		$(MAKE) install LUA_LDIR=$(TARGET_DIR)/share/lua/$(LUA_ABIVER) LUA_CDIR=$(TARGET_LIB_DIR)/lua/$(LUA_ABIVER)
	rm -rf $(TARGET_DIR)/share/lua/$(LUA_ABIVER)/lxp/tests
	$(REMOVE)/luaexpat-$(LUA_EXPAT_VER)
	touch $@

$(D)/luacurl: $(D)/libcurl $(D)/lua $(ARCHIVE)/Lua-cURL$(LUACURL_VER).tar.xz | $(TARGET_DIR)
	$(UNTAR)/Lua-cURL$(LUACURL_VER).tar.xz
	set -e; cd $(BUILD_TMP)/Lua-cURL$(LUACURL_VER); \
		$(PATCH)/lua-curl-Makefile.diff; \
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
	touch $@

$(D)/luaposix: $(HOST_DIR)/bin/lua-$(LUA_VER) $(D)/lua $(D)/luaexpat $(ARCHIVE)/v$(LUAPOSIX_VER).tar.gz $(ARCHIVE)/v$(SLINGSHOT_VER).tar.gz $(ARCHIVE)/gnulib-$(GNULIB_VER)-stable.tar.gz | $(TARGET_DIR)
	$(UNTAR)/v$(LUAPOSIX_VER).tar.gz
	tar -C $(BUILD_TMP)/luaposix-$(LUAPOSIX_VER)/slingshot --strip=1 -xf $(ARCHIVE)/v$(SLINGSHOT_VER).tar.gz
	tar -C $(BUILD_TMP)/luaposix-$(LUAPOSIX_VER)/gnulib --strip=1 -xf $(ARCHIVE)/gnulib-$(GNULIB_VER)-stable.tar.gz
	set -e; cd $(BUILD_TMP)/luaposix-$(LUAPOSIX_VER); \
		$(PATCH)/luaposix-fix-build.patch; \
		$(PATCH)/luaposix-fix-docdir-build.patch; \
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
			--enable-silent-rules; \
		$(MAKE); \
		$(MAKE) all check install
	$(REMOVE)/luaposix-$(LUAPOSIX_VER) $(TARGET_DIR)/.remove
	touch $@

# helper for luaposix build
$(HOST_DIR)/bin/lua-$(LUA_VER): $(ARCHIVE)/lua-$(LUA_VER).tar.gz | $(TARGET_DIR)
	$(UNTAR)/lua-$(LUA_VER).tar.gz
	set -e; cd $(BUILD_TMP)/lua-$(LUA_VER); \
		$(PATCH)/lua-01-fix-coolstream-build.patch; \
		$(MAKE) linux
	install -m 0755 -D $(BUILD_TMP)/lua-$(LUA_VER)/src/lua $@
	$(REMOVE)/lua-$(LUA_VER) $(TARGET_DIR)/.remove

lua-libs: $(SOURCE_DIR)/$(NI_NEUTRINO-PLUGINS) | $(TARGET_DIR)
	cp -a $(SOURCE_DIR)/$(NI_NEUTRINO-PLUGINS)/scripts-lua/share/lua/5.2/* $(TARGET_DIR)/share/lua/$(LUA_ABIVER)/

$(D)/lua: $(D)/libncurses $(ARCHIVE)/lua-$(LUA_VER).tar.gz | $(TARGET_DIR)
	$(UNTAR)/lua-$(LUA_VER).tar.gz
	set -e; cd $(BUILD_TMP)/lua-$(LUA_VER); \
		$(PATCH)/lua-01-fix-coolstream-build.patch; \
		$(PATCH)/lua-02-shared-libs-for-lua.patch; \
		$(PATCH)/lua-03-lua-pc.patch; \
		$(PATCH)/lua-04-crashfix.diff; \
		sed -i 's/^V=.*/V= $(LUA_ABIVER)/' etc/lua.pc; \
		sed -i 's/^R=.*/R= $(LUA_VER)/' etc/lua.pc; \
		$(MAKE) linux PKG_VERSION=$(LUA_VER) CC=$(TARGET)-gcc LD=$(TARGET)-ld AR="$(TARGET)-ar rcu" RANLIB=$(TARGET)-ranlib LDFLAGS="$(TARGET_LDFLAGS)"; \
		$(MAKE) install INSTALL_TOP=$(TARGET_DIR)
	install -m 0755 -D $(BUILD_TMP)/lua-$(LUA_VER)/src/liblua.so.$(LUA_VER) $(TARGET_LIB_DIR)/liblua.so.$(LUA_VER)
	cd $(TARGET_LIB_DIR); ln -sf liblua.so.$(LUA_VER) $(TARGET_LIB_DIR)/liblua.so
	install -m 0644 -D $(BUILD_TMP)/lua-$(LUA_VER)/etc/lua.pc $(PKG_CONFIG_PATH)/lua.pc
	$(REWRITE_PKGCONF) $(PKG_CONFIG_PATH)/lua.pc
	rm -rf $(TARGET_DIR)/bin/luac
	$(REMOVE)/lua-$(LUA_VER) $(TARGET_DIR)/.remove
	make lua-libs
	touch $@

BLURAY_DEPS = $(D)/freetype
ifeq ($(BOXSERIES), hd2)
  BLURAY_DEPS += $(D)/libaacs $(D)/libbdplus
endif
$(D)/libbluray: $(BLURAY_DEPS) $(ARCHIVE)/libbluray-$(LIBBLURAY_VER).tar.bz2 | $(TARGET_DIR)
	$(REMOVE)/libbluray-$(LIBBLURAY_VER)
	$(UNTAR)/libbluray-$(LIBBLURAY_VER).tar.bz2
	cd $(BUILD_TMP)/libbluray-$(LIBBLURAY_VER) && \
		$(PATCH)/libbluray.diff && \
		./bootstrap && \
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
			$(BLURAY_CONFIGURE) && \
		$(MAKE) && \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
		$(REWRITE_LIBTOOL)/libbluray.la
		$(REWRITE_PKGCONF) $(PKG_CONFIG_PATH)/libbluray.pc
	$(REMOVE)/libbluray-$(LIBBLURAY_VER)
	touch $@

$(D)/libass: $(D)/freetype $(D)/libfribidi $(ARCHIVE)/libass-$(LIBASS_VER).tar.xz | $(TARGET_DIR)
	$(UNTAR)/libass-$(LIBASS_VER).tar.xz
	pushd $(BUILD_TMP)/libass-$(LIBASS_VER) && \
		$(CONFIGURE) \
			--target=$(TARGET) \
			--prefix= \
			--disable-static \
			--disable-test \
			--disable-fontconfig \
			--disable-harfbuzz \
			--disable-require-system-font-provider && \
		$(MAKE) && \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
	$(REMOVE)/libass-$(LIBASS_VER)
	$(REWRITE_LIBTOOL)/libass.la
	$(REWRITE_PKGCONF) $(PKG_CONFIG_PATH)/libass.pc
	touch $@
	
$(D)/libgpg-error: $(ARCHIVE)/libgpg-error-$(LIBGPG-ERROR_VER).tar.bz2 | $(TARGET_DIR)
	$(UNTAR)/libgpg-error-$(LIBGPG-ERROR_VER).tar.bz2
	pushd $(BUILD_TMP)/libgpg-error-$(LIBGPG-ERROR_VER) && \
		pushd src/syscfg && \
			ln -s lock-obj-pub.arm-unknown-linux-gnueabi.h lock-obj-pub.linux-uclibcgnueabi.h; \
			popd; \
		$(CONFIGURE) \
			--prefix= \
			--mandir=/.remove \
			--infodir=/.remove \
			--datarootdir=/.remove \
			--enable-maintainer-mode \
			--enable-shared \
			--disable-static && \
		$(MAKE) && \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
	mv $(TARGET_DIR)/bin/gpg-error-config $(HOST_DIR)/bin
	$(REWRITE_PKGCONF) $(HOST_DIR)/bin/gpg-error-config
	$(REWRITE_LIBTOOL)/libgpg-error.la
	rm -rf $(TARGET_DIR)/bin/gpg-error
	rm -rf $(TARGET_DIR)/share/common-lisp
	$(REMOVE)/libgpg-error-$(LIBGPG-ERROR_VER)
	touch $@

$(D)/libgcrypt: $(ARCHIVE)/libgcrypt-$(LIBGCRYPT_VER).tar.gz $(D)/libgpg-error | $(TARGET_DIR)
	$(UNTAR)/libgcrypt-$(LIBGCRYPT_VER).tar.gz
	pushd $(BUILD_TMP)/libgcrypt-$(LIBGCRYPT_VER) && \
		$(CONFIGURE) \
			--prefix= \
			--mandir=/.remove \
			--infodir=/.remove \
			--datarootdir=/.remove \
			--enable-maintainer-mode \
			--enable-silent-rules \
			--enable-shared \
			--disable-static && \
		$(MAKE) && \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
	mv $(TARGET_DIR)/bin/libgcrypt-config $(HOST_DIR)/bin
	$(REWRITE_PKGCONF) $(HOST_DIR)/bin/libgcrypt-config
	$(REWRITE_LIBTOOL)/libgcrypt.la
	rm -rf $(TARGET_DIR)/bin/dumpsexp
	rm -rf $(TARGET_DIR)/bin/hmac256
	rm -rf $(TARGET_DIR)/bin/mpicalc
	$(REMOVE)/libgcrypt-$(LIBGCRYPT_VER)
	touch $@

$(D)/libaacs: $(ARCHIVE)/libaacs-$(LIBAACS_VER).tar.bz2 $(D)/libgcrypt | $(TARGET_DIR)
	$(UNTAR)/libaacs-$(LIBAACS_VER).tar.bz2
	pushd $(BUILD_TMP)/libaacs-$(LIBAACS_VER) && \
		./bootstrap && \
		$(CONFIGURE) \
			--prefix= \
			--enable-maintainer-mode \
			--enable-silent-rules \
			--enable-shared \
			--disable-static && \
		$(MAKE) && \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
	$(REWRITE_PKGCONF) $(PKG_CONFIG_PATH)/libaacs.pc
	$(REWRITE_LIBTOOL)/libaacs.la
	$(REMOVE)/libaacs-$(LIBAACS_VER)
	cd $(TARGET_DIR) && \
	mkdir -p .config/aacs .cache/aacs/vuk
	cp $(IMAGEFILES)/libaacs/KEYDB.cfg $(TARGET_DIR)/.config/aacs
	touch $@

$(D)/libbdplus: $(ARCHIVE)/libbdplus-$(LIBBDPLUS_VER).tar.bz2 $(D)/libaacs | $(TARGET_DIR)
	$(UNTAR)/libbdplus-$(LIBBDPLUS_VER).tar.bz2
	pushd $(BUILD_TMP)/libbdplus-$(LIBBDPLUS_VER) && \
		./bootstrap && \
		$(CONFIGURE) \
			--prefix= \
			--enable-maintainer-mode \
			--enable-silent-rules \
			--enable-shared \
			--disable-static && \
		$(MAKE) && \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
	$(REWRITE_PKGCONF) $(PKG_CONFIG_PATH)/libbdplus.pc
	$(REWRITE_LIBTOOL)/libbdplus.la
	$(REMOVE)/libbdplus-$(LIBBDPLUS_VER)
	cd $(TARGET_DIR) && \
	mkdir -p .config/bdplus/vm0
	cp -f $(IMAGEFILES)/libbdplus/* $(TARGET_DIR)/.config/bdplus/vm0
	touch $@

$(D)/libxml2: $(ARCHIVE)/libxml2-$(LIBXML2_VER).tar.gz | $(TARGET_DIR)
	$(UNTAR)/libxml2-$(LIBXML2_VER).tar.gz
	pushd $(BUILD_TMP)/libxml2-$(LIBXML2_VER) && \
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
			--without-schematron && \
		$(MAKE) && \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
	mv $(TARGET_DIR)/bin/xml2-config $(HOST_DIR)/bin
	$(REWRITE_LIBTOOL)/libxml2.la
	$(REWRITE_PKGCONF) $(PKG_CONFIG_PATH)/libxml-2.0.pc
	$(REWRITE_PKGCONF) $(HOST_DIR)/bin/xml2-config
	rm -rf $(TARGET_LIB_DIR)/xml2Conf.sh
	rm -rf $(TARGET_LIB_DIR)/cmake
	$(REMOVE)/libxml2-$(LIBXML2_VER)
	touch $@

$(D)/pugixml: $(ARCHIVE)/pugixml-$(PUGIXML_VER).tar.gz | $(TARGET_DIR)
	$(REMOVE)/pugixml-$(PUGIXML_VER)
	$(UNTAR)/pugixml-$(PUGIXML_VER).tar.gz
	set -e; cd $(BUILD_TMP)/pugixml-$(PUGIXML_VER); \
	rm -f CMakeCache.txt && \
		cmake \
		--no-warn-unused-cli \
		-DBUILD_SHARED_LIBS="ON" \
		-DCMAKE_CXX_FLAGS="$(TARGET_CFLAGS) -DNDEBUG" \
		-DCMAKE_INSTALL_PREFIX="" \
		-DCMAKE_BUILD_TYPE="None" \
		-DCMAKE_SYSTEM_NAME="Linux" \
		-DCMAKE_SYSTEM_PROCESSOR="arm" \
		-DCMAKE_C_COMPILER="$(TARGET)-gcc" \
		-DCMAKE_CXX_COMPILER="$(TARGET)-g++" \
		-DCMAKE_LINKER="$(CROSS_DIR)/bin/$(TARGET)-ld" \
		-DCMAKE_RANLIB="$(CROSS_DIR)/bin/$(TARGET)-ranlib" \
		-DCMAKE_AR="$(CROSS_DIR)/bin/$(TARGET)-ar" \
		-DCMAKE_NM="$(CROSS_DIR)/bin/$(TARGET)-nm" \
		-DCMAKE_OBJDUMP="$(CROSS_DIR)/bin/$(TARGET)-objdump" \
		-DCMAKE_STRIP="$(CROSS_DIR)/bin/$(TARGET)-strip" \
		; \
		$(MAKE); \
		make install DESTDIR=$(TARGET_DIR)
	rm -rf $(TARGET_DIR)/lib/cmake
	$(REMOVE)/pugixml-$(PUGIXML_VER)
	touch $@

$(D)/librtmp: $(D)/zlib $(D)/openssl $(SOURCE_DIR)/$(NI_RTMPDUMP) | $(TARGET_DIR)
	$(REMOVE)/$(NI_RTMPDUMP)
	tar -C $(SOURCE_DIR) -cp $(NI_RTMPDUMP) --exclude-vcs | tar -C $(BUILD_TMP) -x
	set -e; cd $(BUILD_TMP)/$(NI_RTMPDUMP); \
		make CROSS_COMPILE=$(TARGET)- XCFLAGS="-I$(TARGET_DIR)/include -L$(TARGET_DIR)/lib" LDFLAGS="-L$(TARGET_DIR)/lib" prefix=$(TARGET_DIR);\
		make install DESTDIR=$(TARGET_DIR) prefix="" mandir=/.remove ;\
		rm -rf $(TARGET_DIR)/.remove
		rm -rf $(TARGET_DIR)/sbin/rtmpgw
		rm -rf $(TARGET_DIR)/sbin/rtmpsrv
		rm -rf $(TARGET_DIR)/sbin/rtmpsuck
	$(REWRITE_PKGCONF) $(PKG_CONFIG_PATH)/librtmp.pc
	$(REMOVE)/$(NI_RTMPDUMP)
	touch $@

$(D)/libtirpc: $(ARCHIVE)/libtirpc-$(LIBTIRPC_VER).tar.bz2 | $(TARGET_DIR)
	$(UNTAR)/libtirpc-$(LIBTIRPC_VER).tar.bz2
	cd $(BUILD_TMP)/libtirpc-$(LIBTIRPC_VER) && \
	$(PATCH)/libtirpc-0001-Disable-parts-of-TIRPC-requiring-NIS-support.patch && \
	$(PATCH)/libtirpc-0002-uClibc-without-RPC-support-and-musl-does-not-install-rpcent.h.patch && \
	$(PATCH)/libtirpc-0003-Add-rpcgen-program-from-nfs-utils-sources.patch && \
	$(PATCH)/libtirpc-0004-Automatically-generate-XDR-header-files-from-.x-sour.patch && \
	$(PATCH)/libtirpc-0005-Add-more-XDR-files-needed-to-build-rpcbind-on-top-of.patch && \
	$(PATCH)/libtirpc-0006-Disable-DES-authentification-support.patch && \
	$(PATCH)/libtirpc-0007-include-stdint.h-for-uintptr_t.patch && \
		autoreconf -fi && \
		$(CONFIGURE) \
			--target=$(TARGET) \
			--prefix= \
			--disable-gssapi \
			--enable-silent-rules \
			--mandir=/.remove && \
		$(MAKE) && \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
	$(REWRITE_LIBTOOL)/libtirpc.la
	$(REWRITE_PKGCONF) $(PKG_CONFIG_PATH)/libtirpc.pc
	$(REMOVE)/libtirpc-$(LIBTIRPC_VER)
	touch $@

$(D)/confuse: $(ARCHIVE)/confuse-$(CONFUSE_VER).tar.xz | $(TARGET_DIR)
	$(UNTAR)/confuse-$(CONFUSE_VER).tar.xz
	set -e; cd $(BUILD_TMP)/confuse-$(CONFUSE_VER); \
		$(CONFIGURE) \
			--prefix= \
			--docdir=/.remove \
			--mandir=/.remove \
			--enable-silent-rules \
			--enable-static \
			--disable-shared \
		$(MAKE); \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
		$(REWRITE_PKGCONF) $(PKG_CONFIG_PATH)/libconfuse.pc
	$(REMOVE)/confuse-$(CONFUSE_VER)
	touch $@

$(D)/libite: $(ARCHIVE)/libite-$(ITE_VER).tar.xz | $(TARGET_DIR)
	$(UNTAR)/libite-$(ITE_VER).tar.xz
	set -e; cd $(BUILD_TMP)/libite-$(ITE_VER); \
		$(CONFIGURE) \
			--prefix= \
			--docdir=/.remove \
			--mandir=/.remove \
			--enable-silent-rules \
			--enable-static \
			--disable-shared \
		$(MAKE); \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
		$(REWRITE_PKGCONF) $(PKG_CONFIG_PATH)/libite.pc
	$(REMOVE)/libite-$(ITE_VER)
	touch $@

$(D)/libmad: $(ARCHIVE)/libmad-$(LIBMAD_VER).tar.gz | $(TARGET_DIR)
	$(UNTAR)/libmad-$(LIBMAD_VER).tar.gz
	pushd $(BUILD_TMP)/libmad-$(LIBMAD_VER) && \
		$(PATCH)/libmad-pc-fix.diff && \
		$(PATCH)/libmad-frame_length.diff && \
		$(PATCH)/libmad-mips-h-constraint-removal.patch && \
		$(PATCH)/libmad-remove-deprecated-cflags.patch && \
		$(PATCH)/libmad-thumb2-fixed-arm.patch && \
		$(PATCH)/libmad-thumb2-imdct-arm.patch && \
		touch NEWS AUTHORS ChangeLog && \
		autoreconf -fi && \
		$(CONFIGURE) \
			--prefix= \
			--enable-shared=yes \
			--enable-accuracy \
			--enable-fpm=arm \
			--enable-sso && \
		$(MAKE) all && \
		make install DESTDIR=$(TARGET_DIR) && \
		sed "s!^prefix=.*!prefix=$(TARGET_DIR)!;" mad.pc > $(PKG_CONFIG_PATH)/libmad.pc
	$(REWRITE_LIBTOOL)/libmad.la
	$(REMOVE)/libmad-$(LIBMAD_VER)
	touch $@

$(D)/libvorbisidec: $(ARCHIVE)/libvorbisidec_$(LIBVORBISIDEC_VER).orig.tar.gz $(D)/libogg | $(TARGET_DIR)
	$(UNTAR)/libvorbisidec_$(LIBVORBISIDEC_VER).orig.tar.gz
	pushd $(BUILD_TMP)/libvorbisidec-$(LIBVORBISIDEC_VER) && \
		sed -i '122 s/^/#/' configure.in && \
		autoreconf -fi && \
		$(BUILDENV) \
		$(CONFIGURE) \
			--prefix= && \
		make all && \
		make install DESTDIR=$(TARGET_DIR) && \
	$(REMOVE)/libvorbisidec-$(LIBVORBISIDEC_VER)
	$(REWRITE_PKGCONF) $(PKG_CONFIG_PATH)/vorbisidec.pc
	$(REWRITE_LIBTOOL)/libvorbisidec.la
	touch $@

$(D)/libogg: $(ARCHIVE)/libogg-$(LIBOGG_VER).tar.xz | $(TARGET_DIR)
	$(UNTAR)/libogg-$(LIBOGG_VER).tar.xz
	pushd $(BUILD_TMP)/libogg-$(LIBOGG_VER) && \
		$(CONFIGURE) \
			--prefix= \
			--datarootdir=/.remove \
			--enable-shared && \
		$(MAKE) && \
		make install DESTDIR=$(TARGET_DIR)
	$(REWRITE_PKGCONF) $(PKG_CONFIG_PATH)/ogg.pc
	$(REWRITE_LIBTOOL)/libogg.la
	$(REMOVE)/libogg-$(LIBOGG_VER)
	touch $@

$(D)/libfribidi: $(ARCHIVE)/fribidi-$(FRIBIDI_VER).tar.bz2 | $(TARGET_DIR)
	$(REMOVE)/fribidi-$(FRIBIDI_VER)
	$(UNTAR)/fribidi-$(FRIBIDI_VER).tar.bz2
	set -e; cd $(BUILD_TMP)/fribidi-$(FRIBIDI_VER); \
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
	touch $@

LIBFFI_CONF =
ifeq ($(BOXSERIES), hd1)
	LIBFFI_CONF = --enable-static --disable-shared
endif

$(D)/libffi: $(ARCHIVE)/libffi-$(LIBFFI_VER).tar.gz
	$(UNTAR)/libffi-$(LIBFFI_VER).tar.gz
	set -e; cd $(BUILD_TMP)/libffi-$(LIBFFI_VER); \
	$(PATCH)/libffi-install_headers.patch; \
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
	touch $@

# glibc provides a stub
# gettext implementation,
# so we only build it for hd2
LIBGLIB2_DEPS =
ifeq ($(BOXSERIES), hd2)
	LIBGLIB2_DEPS = $(D)/gettext
endif

LIBGLIB2_CONF =
ifeq ($(BOXSERIES), hd1)
	LIBGLIB2_CONF = --enable-static --disable-shared
endif

$(D)/libglib2: $(ARCHIVE)/glib-$(GLIB_VER).tar.xz $(D)/zlib $(LIBGLIB2_DEPS) $(D)/libffi | $(TARGET_DIR)
	$(UNTAR)/glib-$(GLIB_VER).tar.xz
	pushd $(BUILD_TMP)/glib-$(GLIB_VER); \
	$(PATCH)/libglib2-disable-tests.patch; \
		echo "ac_cv_type_long_long=yes"		 > arm-linux.cache; \
		echo "glib_cv_stack_grows=no"		>> arm-linux.cache; \
		echo "glib_cv_uscore=no"		>> arm-linux.cache; \
		echo "ac_cv_func_posix_getpwuid_r=yes"	>> arm-linux.cache; \
		echo "ac_cv_func_posix_getgrgid_r=yes"	>> arm-linux.cache; \
		autoreconf -fi; \
		$(CONFIGURE) \
			--prefix= \
			--datarootdir=/.remove \
			--cache-file=arm-linux.cache \
			--enable-debug=no \
			--disable-selinux \
			--enable-libmount=no \
			--disable-fam \
			--with-pcre=internal \
			$(LIBGLIB2_CONF) \
			; \
		$(MAKE) all; \
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
	$(REWRITE_LIBTOOLDEP)/libgio-2.0.la
	$(REWRITE_LIBTOOLDEP)/libglib-2.0.la
	$(REWRITE_LIBTOOLDEP)/libgmodule-2.0.la
	$(REWRITE_LIBTOOLDEP)/libgobject-2.0.la
	$(REWRITE_LIBTOOLDEP)/libgthread-2.0.la
	$(REMOVE)/glib-$(GLIB_VER)
	touch $@

$(D)/alsa-lib: $(ARCHIVE)/$(ALSA-LIB_SOURCE)
	$(UNTAR)/$(ALSA-LIB_SOURCE)
	set -e; cd $(BUILD_TMP)/alsa-lib-$(ALSA-LIB_VER); \
		$(PATCH)/alsa-lib-$(ALSA-LIB_VER)-link_fix.patch; \
		$(PATCH)/alsa-lib-$(ALSA-LIB_VER).patch; \
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
	touch $@
