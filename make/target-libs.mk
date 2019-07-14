#
# makefile to build system libs
#
# -----------------------------------------------------------------------------

ZLIB_VER = 1.2.11

$(ARCHIVE)/zlib-$(ZLIB_VER).tar.gz:
	$(DOWNLOAD) http://zlib.net/zlib-$(ZLIB_VER).tar.gz

ZLIB_PATCH  = zlib-ldflags-tests.patch
ZLIB_PATCH += zlib-remove.ldconfig.call.patch

$(D)/zlib: $(ARCHIVE)/zlib-$(ZLIB_VER).tar.gz | $(TARGET_DIR)
	$(REMOVE)/zlib-$(ZLIB_VER)
	$(UNTAR)/zlib-$(ZLIB_VER).tar.gz
	$(CHDIR)/zlib-$(ZLIB_VER); \
		$(call apply_patches, $(ZLIB_PATCH)); \
		$(BUILDENV) \
		mandir=/.remove \
		./configure \
			--prefix= \
			--shared \
			--uname=Linux \
			; \
		$(MAKE); \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
	$(REWRITE_PKGCONF)/zlib.pc
	$(REMOVE)/zlib-$(ZLIB_VER)
	$(TOUCH)

# -----------------------------------------------------------------------------

FUSE_VER = 2.9.8

$(ARCHIVE)/fuse-$(FUSE_VER).tar.gz:
	$(DOWNLOAD) https://github.com/libfuse/libfuse/releases/download/fuse-$(FUSE_VER)/fuse-$(FUSE_VER).tar.gz

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
	$(REWRITE_PKGCONF)/fuse.pc
	rm -rf $(TARGET_DIR)/etc/udev
	rm -rf $(TARGET_DIR)/etc/init.d/fuse
	$(REMOVE)/fuse-$(FUSE_VER)
	$(TOUCH)

# -----------------------------------------------------------------------------

LIBUPNP_VER = 1.6.22

$(ARCHIVE)/libupnp-$(LIBUPNP_VER).tar.bz2:
	$(DOWNLOAD) http://sourceforge.net/projects/pupnp/files/pupnp/libUPnP%20$(LIBUPNP_VER)/libupnp-$(LIBUPNP_VER).tar.bz2

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
	$(REWRITE_PKGCONF)/libupnp.pc
	$(TOUCH)
	
# -----------------------------------------------------------------------------

LIBDVBSI_VER = git
LIBDVBSI_SOURCE = libdvbsi.$(LIBDVBSI_VER)
LIBDVBSI_URL = https://github.com/OpenVisionE2/$(LIBDVBSI_SOURCE)

LIBDVBSI_PATCH  = libdvbsi++-content_identifier_descriptor.patch

$(D)/libdvbsi: | $(TARGET_DIR)
	$(REMOVE)/$(LIBDVBSI_SOURCE)
	get-git-source.sh $(LIBDVBSI_URL) $(ARCHIVE)/$(LIBDVBSI_SOURCE)
	$(CPDIR)/$(LIBDVBSI_SOURCE)
	$(CHDIR)/$(LIBDVBSI_SOURCE); \
		$(call apply_patches, $(LIBDVBSI_PATCH)); \
		$(CONFIGURE) \
			--prefix= \
			--enable-shared \
			--enable-silent-rules \
			--disable-static \
			; \
		$(MAKE); \
		make install DESTDIR=$(TARGET_DIR); \
	$(REMOVE)/$(LIBDVBSI_SOURCE)
	$(REWRITE_LIBTOOL)/libdvbsi++.la
	$(REWRITE_PKGCONF)/libdvbsi++.pc
	$(TOUCH)

# -----------------------------------------------------------------------------

GIFLIB_VER = 5.1.4

$(ARCHIVE)/giflib-$(GIFLIB_VER).tar.bz2:
	$(DOWNLOAD) http://sourceforge.net/projects/giflib/files/giflib-$(GIFLIB_VER).tar.bz2

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

LIBCURL_VER = 7.65.1

$(ARCHIVE)/curl-$(LIBCURL_VER).tar.bz2:
	$(DOWNLOAD) http://curl.haxx.se/download/curl-$(LIBCURL_VER).tar.bz2

LIBCURL_IPV6="--enable-ipv6"
ifeq ($(BOXSERIES), hd1)
  LIBCURL_IPV6="--disable-ipv6"
endif

$(D)/libcurl: $(D)/zlib $(D)/openssl $(D)/librtmp $(D)/ca-bundle $(ARCHIVE)/curl-$(LIBCURL_VER).tar.bz2 | $(TARGET_DIR)
	$(REMOVE)/curl-$(LIBCURL_VER)
	$(UNTAR)/curl-$(LIBCURL_VER).tar.bz2
	$(CHDIR)/curl-$(LIBCURL_VER); \
		$(CONFIGURE) \
			--prefix= \
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
			$(LIBCURL_IPV6) \
			--enable-optimize \
			; \
		$(MAKE) all; \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
	mv $(TARGET_DIR)/bin/curl-config $(HOST_DIR)/bin/
	$(REWRITE_CONFIG) $(HOST_DIR)/bin/curl-config
	rm -f $(TARGET_SHARE_DIR)/zsh
	$(REWRITE_LIBTOOL)/libcurl.la
	$(REWRITE_PKGCONF)/libcurl.pc
	$(REMOVE)/curl-$(LIBCURL_VER)
	$(TOUCH)

# -----------------------------------------------------------------------------

LIBPNG_VER = 1.6.37

$(ARCHIVE)/libpng-$(LIBPNG_VER).tar.xz:
	$(DOWNLOAD) http://sourceforge.net/projects/libpng/files/libpng16/$(LIBPNG_VER)/libpng-$(LIBPNG_VER).tar.xz

LIBPNG_PATCH  = libpng-Disable-pngfix-and-png-fix-itxt.patch

LIBPNG_CONF =
ifneq ($(BOXSERIES), $(filter $(BOXSERIES), hd51 bre2ze4k))
  LIBPNG_CONF = --disable-arm-neon
endif

$(D)/libpng: $(ARCHIVE)/libpng-$(LIBPNG_VER).tar.xz $(D)/zlib | $(TARGET_DIR)
	$(REMOVE)/libpng-$(LIBPNG_VER)
	$(UNTAR)/libpng-$(LIBPNG_VER).tar.xz
	$(CHDIR)/libpng-$(LIBPNG_VER); \
		$(call apply_patches, $(LIBPNG_PATCH)); \
		$(CONFIGURE) \
			--prefix= \
			--mandir=/.remove \
			--enable-silent-rules \
			$(LIBPNG_CONF) \
			--disable-static \
			; \
		$(MAKE) all; \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
	mv $(TARGET_DIR)/bin/libpng*-config $(HOST_DIR)/bin/
	$(REWRITE_CONFIG) $(HOST_DIR)/bin/libpng16-config
	$(REWRITE_PKGCONF)/libpng16.pc
	$(REWRITE_LIBTOOL)/libpng16.la
	$(REMOVE)/libpng-$(LIBPNG_VER)
	$(TOUCH)

# -----------------------------------------------------------------------------

FREETYPE_VER = 2.10.0

$(ARCHIVE)/freetype-$(FREETYPE_VER).tar.bz2:
	$(DOWNLOAD) https://sourceforge.net/projects/freetype/files/freetype2/$(FREETYPE_VER)/freetype-$(FREETYPE_VER).tar.bz2

FREETYPE_PATCH  = freetype2-subpixel.patch
FREETYPE_PATCH += freetype2-config.patch
FREETYPE_PATCH += freetype2-pkgconf.patch

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
			--prefix= \
			--mandir=/.remove \
			--enable-shared \
			--disable-static \
			--enable-freetype-config \
			--with-png \
			--with-zlib \
			--without-harfbuzz \
			--without-bzip2 \
			; \
		$(MAKE) all; \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
	ln -sf freetype2 $(TARGET_INCLUDE_DIR)/freetype
	mv $(TARGET_DIR)/bin/freetype-config $(HOST_DIR)/bin
	$(REWRITE_CONFIG) $(HOST_DIR)/bin/freetype-config
	$(REWRITE_PKGCONF)/freetype2.pc
	$(REWRITE_LIBTOOL)/libfreetype.la
	$(REMOVE)/freetype-$(FREETYPE_VER) $(TARGET_SHARE_DIR)/aclocal
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
	$(DOWNLOAD) https://sourceforge.net/projects/libjpeg-turbo/files/$(LIBJPEG-TURBO_VER)/libjpeg-turbo-$(LIBJPEG-TURBO_VER).tar.gz

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
	$(DOWNLOAD) https://sourceforge.net/projects/libjpeg-turbo/files/$(LIBJPEG-TURBO2_VER)/$(LIBJPEG-TURBO2_SOURCE)

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
	$(REWRITE_PKGCONF)/libturbojpeg.pc
	$(REWRITE_PKGCONF)/libjpeg.pc
	rm -f $(addprefix $(TARGET_DIR)/bin/,cjpeg djpeg jpegtran rdjpgcom tjbench wrjpgcom)
	$(REMOVE)/libjpeg-turbo-$(LIBJPEG-TURBO2_VER)
	$(TOUCH)

# -----------------------------------------------------------------------------

OPENSSL_VER = 1.0.2s

$(ARCHIVE)/openssl-$(OPENSSL_VER).tar.gz:
	$(DOWNLOAD) http://www.openssl.org/source/openssl-$(OPENSSL_VER).tar.gz

OPENSSL_PATCH  = openssl-add-ni-specific-target.patch

OPENSSL_FLAGS = CC=$(TARGET)-gcc \
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
		make $(OPENSSL_FLAGS) depend; \
		sed -i "s# build_tests##" Makefile; \
		make $(OPENSSL_FLAGS) all; \
		make install_sw INSTALL_PREFIX=$(TARGET_DIR)
	$(REWRITE_PKGCONF)/openssl.pc
	$(REWRITE_PKGCONF)/libcrypto.pc
	$(REWRITE_PKGCONF)/libssl.pc
	rm -rf $(TARGET_DIR)/bin/c_rehash $(TARGET_LIB_DIR)/engines
ifneq ($(BOXSERIES), $(filter $(BOXSERIES), hd51 bre2ze4k))
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

LIBNCURSES_VER = 6.1

$(ARCHIVE)/ncurses-$(LIBNCURSES_VER).tar.gz:
	$(DOWNLOAD) http://ftp.gnu.org/pub/gnu/ncurses/ncurses-$(LIBNCURSES_VER).tar.gz

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
	$(REWRITE_CONFIG) $(HOST_DIR)/bin/ncurses6-config
	$(REWRITE_PKGCONF)/ncurses.pc
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
	$(REWRITE_PKGCONF)/openthreads.pc
	$(TOUCH)

# -----------------------------------------------------------------------------

LIBUSB_MAJOR = 1.0
LIBUSB_VER = $(LIBUSB_MAJOR).21

$(ARCHIVE)/libusb-$(LIBUSB_VER).tar.bz2:
	$(DOWNLOAD) http://sourceforge.net/projects/libusb/files/libusb-$(LIBUSB_MAJOR)/libusb-$(LIBUSB_VER)/libusb-$(LIBUSB_VER).tar.bz2

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
	$(REWRITE_LIBTOOL)/libusb-$(LIBUSB_MAJOR).la
	$(REWRITE_PKGCONF)/libusb-$(LIBUSB_MAJOR).pc
	$(TOUCH)

# -----------------------------------------------------------------------------

LIBUSB-COMPAT_MAJOR = 0.1
LIBUSB-COMPAT_VER = $(LIBUSB-COMPAT_MAJOR).5

$(ARCHIVE)/libusb-compat-$(LIBUSB-COMPAT_VER).tar.bz2:
	$(DOWNLOAD) http://downloads.sourceforge.net/project/libusb/libusb-compat-$(LIBUSB-COMPAT_MAJOR)/libusb-compat-$(LIBUSB-COMPAT_VER)/libusb-compat-$(LIBUSB-COMPAT_VER).tar.bz2

$(D)/libusb-compat: $(ARCHIVE)/libusb-compat-$(LIBUSB-COMPAT_VER).tar.bz2 $(D)/libusb | $(TARGET_DIR)
	$(REMOVE)/libusb-compat-$(LIBUSB-COMPAT_VER)
	$(UNTAR)/libusb-compat-$(LIBUSB-COMPAT_VER).tar.bz2
	$(CHDIR)/libusb-compat-$(LIBUSB-COMPAT_VER); \
		$(CONFIGURE) \
			--prefix= \
			; \
		$(MAKE); \
		make install DESTDIR=$(TARGET_DIR); \
	$(REMOVE)/libusb-compat-$(LIBUSB-COMPAT_VER)
	mv $(TARGET_DIR)/bin/libusb-config $(HOST_DIR)/bin
	$(REWRITE_CONFIG) $(HOST_DIR)/bin/libusb-config
	$(REWRITE_LIBTOOL)/libusb.la
	$(REWRITE_PKGCONF)/libusb.pc
	$(TOUCH)

# -----------------------------------------------------------------------------

LIBGD_VER = 2.2.5

$(ARCHIVE)/libgd-$(LIBGD_VER).tar.xz:
	$(DOWNLOAD) https://github.com/libgd/libgd/releases/download/gd-$(LIBGD_VER)/libgd-$(LIBGD_VER).tar.xz

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
	$(REWRITE_PKGCONF)/gdlib.pc
	$(TOUCH)

# -----------------------------------------------------------------------------

LIBDPF_VER = 62c8fd0
LIBDPF_SOURCE = dpf-ax-git-$(LIBDPF_VER).tar.bz2

$(ARCHIVE)/$(LIBDPF_SOURCE):
	get-git-archive.sh https://bitbucket.org/max_10/dpf-ax $(LIBDPF_VER) $(notdir $@) $(ARCHIVE)

LIBDPF_PATCH  = libdpf-crossbuild.patch

$(D)/libdpf: $(D)/libusb-compat $(ARCHIVE)/$(LIBDPF_SOURCE) | $(TARGET_DIR)
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

LZO_VER = 2.10

$(ARCHIVE)/lzo-$(LZO_VER).tar.gz:
	$(DOWNLOAD) https://fossies.org/linux/misc/lzo-$(LZO_VER).tar.gz

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

LIBSIGCPP_MAJOR = 2
LIBSIGCPP_MINOR = 4
LIBSIGCPP_MICRO = 1
LIBSIGCPP_VER = $(LIBSIGCPP_MAJOR).$(LIBSIGCPP_MINOR).$(LIBSIGCPP_MICRO)

$(ARCHIVE)/libsigc++-$(LIBSIGCPP_VER).tar.xz:
	$(DOWNLOAD) http://ftp.gnome.org/pub/GNOME/sources/libsigc++/$(LIBSIGCPP_MAJOR).$(LIBSIGCPP_MINOR)/libsigc++-$(LIBSIGCPP_VER).tar.xz

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
	$(REWRITE_PKGCONF)/sigc++-2.0.pc
	$(REMOVE)/libsigc++-$(LIBSIGCPP_VER)
	$(TOUCH)

# -----------------------------------------------------------------------------

EXPAT_VER    = 2.2.7
EXPAT        = expat-$(EXPAT_VER)
EXPAT_SOURCE = expat-$(EXPAT_VER).tar.bz2
EXPAT_URL    = https://sourceforge.net/projects/expat/files/expat/$(EXPAT_VER)

$(ARCHIVE)/$(EXPAT_SOURCE):
	$(DOWNLOAD) $(EXPAT_URL)/$(EXPAT_SOURCE)

EXPAT_PATCH  = expat-libtool-tag.patch

$(D)/expat: $(ARCHIVE)/$(EXPAT_SOURCE) | $(TARGET_DIR)
	$(REMOVE)/$(EXPAT)
	$(UNTAR)/$(EXPAT_SOURCE)
	$(CHDIR)/$(EXPAT); \
		$(call apply_patches, $(EXPAT_PATCH)); \
		autoreconf -fi; \
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
	$(REWRITE_PKGCONF)/expat.pc
	$(REWRITE_LIBTOOL)/libexpat.la
	$(REMOVE)/$(EXPAT)
	$(TOUCH)

# -----------------------------------------------------------------------------

LIBBLURAY_VER = 0.9.2

$(ARCHIVE)/libbluray-$(LIBBLURAY_VER).tar.bz2:
	$(DOWNLOAD) ftp://ftp.videolan.org/pub/videolan/libbluray/$(LIBBLURAY_VER)/libbluray-$(LIBBLURAY_VER).tar.bz2

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
	$(REWRITE_PKGCONF)/libbluray.pc
	$(REMOVE)/libbluray-$(LIBBLURAY_VER)
	$(TOUCH)

# -----------------------------------------------------------------------------

LIBASS_VER = 0.14.0

$(ARCHIVE)/libass-$(LIBASS_VER).tar.xz:
	$(DOWNLOAD) https://github.com/libass/libass/releases/download/$(LIBASS_VER)/libass-$(LIBASS_VER).tar.xz

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
	$(REWRITE_PKGCONF)/libass.pc
	$(TOUCH)
	
# -----------------------------------------------------------------------------

LIBGPG-ERROR_VER = 1.32

$(ARCHIVE)/libgpg-error-$(LIBGPG-ERROR_VER).tar.bz2:
	$(DOWNLOAD) ftp://ftp.gnupg.org/gcrypt/libgpg-error/libgpg-error-$(LIBGPG-ERROR_VER).tar.bz2

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
	$(REWRITE_CONFIG) $(HOST_DIR)/bin/gpg-error-config
	$(REWRITE_LIBTOOL)/libgpg-error.la
	rm -rf $(TARGET_DIR)/bin/gpg-error
	rm -rf $(TARGET_SHARE_DIR)/common-lisp
	$(REMOVE)/libgpg-error-$(LIBGPG-ERROR_VER)
	$(TOUCH)

# -----------------------------------------------------------------------------

LIBGCRYPT_VER = 1.8.3

$(ARCHIVE)/libgcrypt-$(LIBGCRYPT_VER).tar.gz:
	$(DOWNLOAD) ftp://ftp.gnupg.org/gcrypt/libgcrypt/libgcrypt-$(LIBGCRYPT_VER).tar.gz

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
	$(REWRITE_CONFIG) $(HOST_DIR)/bin/libgcrypt-config
	$(REWRITE_LIBTOOL)/libgcrypt.la
	rm -rf $(TARGET_DIR)/bin/dumpsexp
	rm -rf $(TARGET_DIR)/bin/hmac256
	rm -rf $(TARGET_DIR)/bin/mpicalc
	$(REMOVE)/libgcrypt-$(LIBGCRYPT_VER)
	$(TOUCH)

# -----------------------------------------------------------------------------

LIBAACS_VER = 0.9.0

$(ARCHIVE)/libaacs-$(LIBAACS_VER).tar.bz2:
	$(DOWNLOAD) ftp://ftp.videolan.org/pub/videolan/libaacs/$(LIBAACS_VER)/libaacs-$(LIBAACS_VER).tar.bz2

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
	$(REWRITE_PKGCONF)/libaacs.pc
	$(REWRITE_LIBTOOL)/libaacs.la
	$(REMOVE)/libaacs-$(LIBAACS_VER)
	$(CD) $(TARGET_DIR); \
		mkdir -p .config/aacs .cache/aacs/vuk
	cp $(IMAGEFILES)/libaacs/KEYDB.cfg $(TARGET_DIR)/.config/aacs
	$(TOUCH)

# -----------------------------------------------------------------------------

LIBBDPLUS_VER = 0.1.2

$(ARCHIVE)/libbdplus-$(LIBBDPLUS_VER).tar.bz2:
	$(DOWNLOAD) ftp://ftp.videolan.org/pub/videolan/libbdplus/$(LIBBDPLUS_VER)/libbdplus-$(LIBBDPLUS_VER).tar.bz2

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
	$(REWRITE_PKGCONF)/libbdplus.pc
	$(REWRITE_LIBTOOL)/libbdplus.la
	$(REMOVE)/libbdplus-$(LIBBDPLUS_VER)
	$(CD) $(TARGET_DIR); \
		mkdir -p .config/bdplus/vm0
	cp -f $(IMAGEFILES)/libbdplus/* $(TARGET_DIR)/.config/bdplus/vm0
	$(TOUCH)

# -----------------------------------------------------------------------------

LIBXML2_VER = 2.9.9

$(ARCHIVE)/libxml2-$(LIBXML2_VER).tar.gz:
	$(DOWNLOAD) ftp://xmlsoft.org/libxml2/libxml2-$(LIBXML2_VER).tar.gz

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
	$(REWRITE_PKGCONF)/libxml-2.0.pc
	$(REWRITE_CONFIG) $(HOST_DIR)/bin/xml2-config
	rm -rf $(TARGET_LIB_DIR)/xml2Conf.sh
	rm -rf $(TARGET_LIB_DIR)/cmake
	$(REMOVE)/libxml2-$(LIBXML2_VER)
	$(TOUCH)

# -----------------------------------------------------------------------------

PUGIXML_VER = 1.9

$(ARCHIVE)/pugixml-$(PUGIXML_VER).tar.gz:
	$(DOWNLOAD) http://github.com/zeux/pugixml/releases/download/v$(PUGIXML_VER)/pugixml-$(PUGIXML_VER).tar.gz

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
	$(REWRITE_PKGCONF)/librtmp.pc
	$(REMOVE)/$(NI_RTMPDUMP)
	$(TOUCH)

# -----------------------------------------------------------------------------

LIBTIRPC_VER = 1.0.2

$(ARCHIVE)/libtirpc-$(LIBTIRPC_VER).tar.bz2:
	$(DOWNLOAD) http://sourceforge.net/projects/libtirpc/files/libtirpc/$(LIBTIRPC_VER)/libtirpc-$(LIBTIRPC_VER).tar.bz2

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
	$(REWRITE_PKGCONF)/libtirpc.pc
	$(REMOVE)/libtirpc-$(LIBTIRPC_VER)
	$(TOUCH)

# -----------------------------------------------------------------------------

CONFUSE_VER = 3.2.2

$(ARCHIVE)/confuse-$(CONFUSE_VER).tar.xz:
	$(DOWNLOAD) https://github.com/martinh/libconfuse/releases/download/v$(CONFUSE_VER)/confuse-$(CONFUSE_VER).tar.xz

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
	$(REWRITE_PKGCONF)/libconfuse.pc
	$(REMOVE)/confuse-$(CONFUSE_VER)
	$(TOUCH)

# -----------------------------------------------------------------------------

LIBITE_VER = 2.0.2

$(ARCHIVE)/libite-$(LIBITE_VER).tar.xz:
	$(DOWNLOAD) https://github.com/troglobit/libite/releases/download/v$(LIBITE_VER)/libite-$(LIBITE_VER).tar.xz

$(D)/libite: $(ARCHIVE)/libite-$(LIBITE_VER).tar.xz | $(TARGET_DIR)
	$(REMOVE)/libite-$(LIBITE_VER)
	$(UNTAR)/libite-$(LIBITE_VER).tar.xz
	$(CHDIR)/libite-$(LIBITE_VER); \
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
	$(REWRITE_PKGCONF)/libite.pc
	$(REMOVE)/libite-$(LIBITE_VER)
	$(TOUCH)

# -----------------------------------------------------------------------------

LIBMAD_VER = 0.15.1b

$(ARCHIVE)/libmad-$(LIBMAD_VER).tar.gz:
	$(DOWNLOAD) http://downloads.sourceforge.net/project/mad/libmad/$(LIBMAD_VER)/libmad-$(LIBMAD_VER).tar.gz

LIBMAD_PATCH  = libmad-pc.patch
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
		autoreconf -fi; \
		$(CONFIGURE) \
			--prefix= \
			--enable-shared=yes \
			--enable-accuracy \
			--enable-fpm=arm \
			--enable-sso \
			; \
		$(MAKE) all; \
		make install DESTDIR=$(TARGET_DIR)
	$(REWRITE_PKGCONF)/mad.pc
	$(REWRITE_LIBTOOL)/libmad.la
	$(REMOVE)/libmad-$(LIBMAD_VER)
	$(TOUCH)

# -----------------------------------------------------------------------------

LIBVORBISIDEC_VER = 1.2.1+git20180316

$(ARCHIVE)/libvorbisidec_$(LIBVORBISIDEC_VER).orig.tar.gz:
	$(DOWNLOAD) http://ftp.de.debian.org/debian/pool/main/libv/libvorbisidec/libvorbisidec_$(LIBVORBISIDEC_VER).orig.tar.gz

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
	$(REWRITE_PKGCONF)/vorbisidec.pc
	$(REWRITE_LIBTOOL)/libvorbisidec.la
	$(TOUCH)

# -----------------------------------------------------------------------------

LIBOGG_VER = 1.3.3

$(ARCHIVE)/libogg-$(LIBOGG_VER).tar.xz:
	$(DOWNLOAD) http://downloads.xiph.org/releases/ogg/libogg-$(LIBOGG_VER).tar.xz

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
	$(REWRITE_PKGCONF)/ogg.pc
	$(REWRITE_LIBTOOL)/libogg.la
	$(REMOVE)/libogg-$(LIBOGG_VER)
	$(TOUCH)

# -----------------------------------------------------------------------------

FRIBIDI_VER = 1.0.4

$(ARCHIVE)/fribidi-$(FRIBIDI_VER).tar.bz2:
	$(DOWNLOAD) https://download.videolan.org/contrib/fribidi/fribidi-$(FRIBIDI_VER).tar.bz2

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
	$(REWRITE_PKGCONF)/fribidi.pc
	$(REWRITE_LIBTOOL)/libfribidi.la
	$(REMOVE)/fribidi-$(FRIBIDI_VER)
	$(TOUCH)

# -----------------------------------------------------------------------------

LIBFFI_VER = 3.2.1

$(ARCHIVE)/libffi-$(LIBFFI_VER).tar.gz:
	$(DOWNLOAD) ftp://sourceware.org/pub/libffi/libffi-$(LIBFFI_VER).tar.gz

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
	$(REWRITE_PKGCONF)/libffi.pc
	$(REWRITE_LIBTOOL)/libffi.la
	$(REMOVE)/libffi-$(LIBFFI_VER)
	$(TOUCH)

# -----------------------------------------------------------------------------

# glibc provides a stub gettext implementation, so we only build it for hd2

GLIB2_MAJOR = 2
GLIB2_MINOR = 56
GLIB2_MICRO = 3
GLIB2_VER = $(GLIB2_MAJOR).$(GLIB2_MINOR).$(GLIB2_MICRO)

$(ARCHIVE)/glib-$(GLIB2_VER).tar.xz:
	$(DOWNLOAD) http://ftp.gnome.org/pub/gnome/sources/glib/$(GLIB2_MAJOR).$(GLIB2_MINOR)/glib-$(GLIB2_VER).tar.xz

GLIB2_PATCH  = glib2-disable-tests.patch

GLIB2_DEPS =
ifeq ($(BOXSERIES), hd2)
  GLIB2_DEPS = $(D)/gettext
endif

GLIB2_CONF =
ifeq ($(BOXSERIES), hd1)
  GLIB2_CONF = --enable-static --disable-shared
endif

$(D)/glib2: $(ARCHIVE)/glib-$(GLIB2_VER).tar.xz $(D)/zlib $(GLIB2_DEPS) $(D)/libffi | $(TARGET_DIR)
	$(REMOVE)/glib-$(GLIB2_VER)
	$(UNTAR)/glib-$(GLIB2_VER).tar.xz
	$(CHDIR)/glib-$(GLIB2_VER); \
		$(call apply_patches, $(GLIB2_PATCH)); \
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
			$(GLIB2_CONF) \
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
	$(REWRITE_PKGCONF)/gio-2.0.pc
	$(REWRITE_PKGCONF)/gio-unix-2.0.pc
	$(REWRITE_PKGCONF)/glib-2.0.pc
	$(REWRITE_PKGCONF)/gmodule-2.0.pc
	$(REWRITE_PKGCONF)/gmodule-export-2.0.pc
	$(REWRITE_PKGCONF)/gmodule-no-export-2.0.pc
	$(REWRITE_PKGCONF)/gobject-2.0.pc
	$(REWRITE_PKGCONF)/gthread-2.0.pc
	$(REWRITE_LIBTOOL)/libgio-2.0.la
	$(REWRITE_LIBTOOL)/libglib-2.0.la
	$(REWRITE_LIBTOOL)/libgmodule-2.0.la
	$(REWRITE_LIBTOOL)/libgobject-2.0.la
	$(REWRITE_LIBTOOL)/libgthread-2.0.la
	$(REMOVE)/glib-$(GLIB2_VER)
	$(TOUCH)

# -----------------------------------------------------------------------------

ALSA-LIB_VER = 1.1.9
ALSA-LIB_SOURCE = alsa-lib-$(ALSA-LIB_VER).tar.bz2

$(ARCHIVE)/$(ALSA-LIB_SOURCE):
	$(DOWNLOAD) ftp://ftp.alsa-project.org/pub/lib/$(ALSA-LIB_SOURCE)

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
	$(REWRITE_PKGCONF)/alsa.pc
	$(REWRITE_LIBTOOL)/libasound.la
	$(REMOVE)/alsa-lib-$(ALSA-LIB_VER)
	$(TOUCH)
