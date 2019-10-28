#
# makefile to build system libs
#
# -----------------------------------------------------------------------------

ZLIB_VER    = 1.2.11
ZLIB_TMP    = zlib-$(ZLIB_VER)
ZLIB_SOURCE = zlib-$(ZLIB_VER).tar.xz
ZLIB_URL    = https://sourceforge.net/projects/libpng/files/zlib/$(ZLIB_VER)

$(ARCHIVE)/$(ZLIB_SOURCE):
	$(DOWNLOAD) $(ZLIB_URL)/$(ZLIB_SOURCE)

ZLIB_PATCH  = zlib-ldflags-tests.patch
ZLIB_PATCH += zlib-remove.ldconfig.call.patch

zlib: $(ARCHIVE)/$(ZLIB_SOURCE) | $(TARGET_DIR)
	$(REMOVE)/$(ZLIB_TMP)
	$(UNTAR)/$(ZLIB_SOURCE)
	$(CHDIR)/$(ZLIB_TMP); \
		$(call apply_patches, $(ZLIB_PATCH)); \
		$(BUILD_ENV) \
		mandir=$(remove-mandir) \
		./configure \
			--prefix= \
			--shared \
			--uname=Linux \
			; \
		$(MAKE); \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
	$(REWRITE_PKGCONF)/zlib.pc
	$(REMOVE)/$(ZLIB_TMP)
	$(TOUCH)

# -----------------------------------------------------------------------------

FUSE_VER    = 2.9.8
FUSE_TMP    = fuse-$(FUSE_VER)
FUSE_SOURCE = fuse-$(FUSE_VER).tar.gz
FUSE_URL    = https://github.com/libfuse/libfuse/releases/download/fuse-$(FUSE_VER)

$(ARCHIVE)/$(FUSE_SOURCE):
	$(DOWNLOAD) $(FUSE_URL)/$(FUSE_SOURCE)

libfuse: $(ARCHIVE)/$(FUSE_SOURCE) | $(TARGET_DIR)
	$(REMOVE)/$(FUSE_TMP)
	$(UNTAR)/$(FUSE_SOURCE)
	$(CHDIR)/$(FUSE_TMP); \
		$(CONFIGURE) \
			--prefix= \
			--datarootdir=$(remove-datarootdir) \
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
	$(REMOVE)/$(FUSE_TMP)
	$(TOUCH)

# -----------------------------------------------------------------------------

LIBUPNP_VER    = 1.6.22
LIBUPNP_TMP    = libupnp-$(LIBUPNP_VER)
LIBUPNP_SOURCE = libupnp-$(LIBUPNP_VER).tar.bz2
LIBUPNP_URL    = http://sourceforge.net/projects/pupnp/files/pupnp/libUPnP%20$(LIBUPNP_VER)

$(ARCHIVE)/$(LIBUPNP_SOURCE):
	$(DOWNLOAD) $(LIBUPNP_URL)/$(LIBUPNP_SOURCE)

libupnp: $(ARCHIVE)/$(LIBUPNP_SOURCE) | $(TARGET_DIR)
	$(REMOVE)/$(LIBUPNP_TMP)
	$(UNTAR)/$(LIBUPNP_SOURCE)
	$(CHDIR)/$(LIBUPNP_TMP); \
		$(CONFIGURE) \
			--prefix= \
			--enable-shared \
			--disable-static \
			; \
		$(MAKE); \
		$(MAKE) install DESTDIR=$(TARGET_DIR); \
	$(REWRITE_LIBTOOL)/libixml.la
	$(REWRITE_LIBTOOL)/libthreadutil.la
	$(REWRITE_LIBTOOL)/libupnp.la
	$(REWRITE_PKGCONF)/libupnp.pc
	$(REMOVE)/$(LIBUPNP_TMP)
	$(TOUCH)
	
# -----------------------------------------------------------------------------

LIBDVBSI_VER    = git
LIBDVBSI_TMP    = libdvbsi.$(LIBDVBSI_VER)
LIBDVBSI_SOURCE = libdvbsi.$(LIBDVBSI_VER)
LIBDVBSI_URL    = https://github.com/OpenVisionE2

LIBDVBSI_PATCH  = libdvbsi++-content_identifier_descriptor.patch

libdvbsi: | $(TARGET_DIR)
	$(REMOVE)/$(LIBDVBSI_TMP)
	$(GET-GIT-SOURCE) $(LIBDVBSI_URL)/$(LIBDVBSI_SOURCE) $(ARCHIVE)/$(LIBDVBSI_SOURCE)
	$(CPDIR)/$(LIBDVBSI_SOURCE)
	$(CHDIR)/$(LIBDVBSI_TMP); \
		$(call apply_patches, $(LIBDVBSI_PATCH)); \
		$(CONFIGURE) \
			--prefix= \
			--enable-shared \
			--enable-silent-rules \
			--disable-static \
			; \
		$(MAKE); \
		make install DESTDIR=$(TARGET_DIR); \
	$(REWRITE_LIBTOOL)/libdvbsi++.la
	$(REWRITE_PKGCONF)/libdvbsi++.pc
	$(REMOVE)/$(LIBDVBSI_TMP)
	$(TOUCH)

# -----------------------------------------------------------------------------

GIFLIB_VER    = 5.1.4
GIFLIB_TMP    = giflib-$(GIFLIB_VER)
GIFLIB_SOURCE = giflib-$(GIFLIB_VER).tar.bz2
GIFLIB_URL    = https://sourceforge.net/projects/giflib/files

$(ARCHIVE)/$(GIFLIB_SOURCE):
	$(DOWNLOAD) $(GIFLIB_URL)/$(GIFLIB_SOURCE)

giflib: $(ARCHIVE)/$(GIFLIB_SOURCE) | $(TARGET_DIR)
	$(REMOVE)/$(GIFLIB_TMP)
	$(UNTAR)/$(GIFLIB_SOURCE)
	$(CHDIR)/$(GIFLIB_TMP); \
		export ac_cv_prog_have_xmlto=no; \
		$(CONFIGURE) \
			--prefix= \
			--disable-static \
			--enable-shared \
			--bindir=$(remove-bindir) \
			; \
		$(MAKE) all; \
		make install DESTDIR=$(TARGET_DIR)
	$(REWRITE_LIBTOOL)/libgif.la
	$(REMOVE)/$(GIFLIB_TMP)
	$(TOUCH)

# -----------------------------------------------------------------------------

LIBCURL_VER    = 7.66.0
LIBCURL_TMP    = curl-$(LIBCURL_VER)
LIBCURL_SOURCE = curl-$(LIBCURL_VER).tar.bz2
LIBCURL_URL    = https://curl.haxx.se/download

$(ARCHIVE)/$(LIBCURL_SOURCE):
	$(DOWNLOAD) $(LIBCURL_URL)/$(LIBCURL_SOURCE)

LIBCURL_DEPS   = zlib openssl rtmpdump ca-bundle

LIBCURL_CONF   = $(if $(filter $(BOXSERIES), hd1),--disable-ipv6,--enable-ipv6)

libcurl: $(LIBCURL_DEPS) $(ARCHIVE)/$(LIBCURL_SOURCE) | $(TARGET_DIR)
	$(REMOVE)/$(LIBCURL_TMP)
	$(UNTAR)/$(LIBCURL_SOURCE)
	$(CHDIR)/$(LIBCURL_TMP); \
		$(CONFIGURE) \
			--prefix= \
			--datarootdir=$(remove-datarootdir) \
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
			--enable-optimize \
			$(LIBCURL_CONF) \
			; \
		$(MAKE) all; \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
	mv $(TARGET_BIN_DIR)/curl-config $(HOST_DIR)/bin/
	$(REWRITE_CONFIG) $(HOST_DIR)/bin/curl-config
	rm -f $(TARGET_SHARE_DIR)/zsh
	$(REWRITE_LIBTOOL)/libcurl.la
	$(REWRITE_PKGCONF)/libcurl.pc
	$(REMOVE)/$(LIBCURL_TMP)
	$(TOUCH)

# -----------------------------------------------------------------------------

LIBPNG_VER    = 1.6.37
LIBPNG_TMP    = libpng-$(LIBPNG_VER)
LIBPNG_SOURCE = libpng-$(LIBPNG_VER).tar.xz
LIBPNG_URL    = https://sourceforge.net/projects/libpng/files/libpng16/$(LIBPNG_VER)

$(ARCHIVE)/$(LIBPNG_SOURCE):
	$(DOWNLOAD) $(LIBPNG_URL)/$(LIBPNG_SOURCE)

LIBPNG_PATCH  = libpng-Disable-pngfix-and-png-fix-itxt.patch

LIBPNG_DEPS   = zlib

LIBPNG_CONF   = $(if $(filter $(BOXSERIES), hd51 vusolo4k vuduo4k vuultimo4k vuzero4k vuuno4k vuuno4kse),--enable-arm-neon,--disable-arm-neon)

libpng: $(LIBPNG_DEPS) $(ARCHIVE)/$(LIBPNG_SOURCE) | $(TARGET_DIR)
	$(REMOVE)/$(LIBPNG_TMP)
	$(UNTAR)/$(LIBPNG_SOURCE)
	$(CHDIR)/$(LIBPNG_TMP); \
		$(call apply_patches, $(LIBPNG_PATCH)); \
		$(CONFIGURE) \
			--prefix= \
			--mandir=$(remove-mandir) \
			--enable-silent-rules \
			--disable-static \
			$(LIBPNG_CONF) \
			; \
		$(MAKE) all; \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
	mv $(TARGET_BIN_DIR)/libpng*-config $(HOST_DIR)/bin/
	$(REWRITE_CONFIG) $(HOST_DIR)/bin/libpng16-config
	$(REWRITE_PKGCONF)/libpng16.pc
	$(REWRITE_LIBTOOL)/libpng16.la
	$(REMOVE)/$(LIBPNG_TMP)
	$(TOUCH)

# -----------------------------------------------------------------------------

FREETYPE_VER    = 2.10.0
FREETYPE_TMP    = freetype-$(FREETYPE_VER)
FREETYPE_SOURCE = freetype-$(FREETYPE_VER).tar.bz2
FREETYPE_URL    = https://sourceforge.net/projects/freetype/files/freetype2/$(FREETYPE_VER)

$(ARCHIVE)/$(FREETYPE_SOURCE):
	$(DOWNLOAD) $(FREETYPE_URL)/$(FREETYPE_SOURCE)

FREETYPE_PATCH  = freetype2-subpixel.patch
FREETYPE_PATCH += freetype2-config.patch
FREETYPE_PATCH += freetype2-pkgconf.patch

FREETYPE_DEPS   = zlib libpng

freetype: $(FREETYPE_DEPS) $(ARCHIVE)/$(FREETYPE_SOURCE) | $(TARGET_DIR)
	$(REMOVE)/$(FREETYPE_TMP)
	$(UNTAR)/$(FREETYPE_SOURCE)
	$(CHDIR)/$(FREETYPE_TMP); \
		$(call apply_patches, $(FREETYPE_PATCH)); \
		sed -i '/^FONT_MODULES += \(type1\|cid\|pfr\|type42\|pcf\|bdf\|winfonts\|cff\)/d' modules.cfg
	$(CHDIR)/$(FREETYPE_TMP)/builds/unix; \
		libtoolize --force --copy; \
		aclocal -I .; \
		autoconf
	$(CHDIR)/$(FREETYPE_TMP); \
		$(CONFIGURE) \
			--prefix= \
			--mandir=$(remove-mandir) \
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
	mv $(TARGET_BIN_DIR)/freetype-config $(HOST_DIR)/bin
	$(REWRITE_CONFIG) $(HOST_DIR)/bin/freetype-config
	$(REWRITE_PKGCONF)/freetype2.pc
	$(REWRITE_LIBTOOL)/libfreetype.la
	$(REMOVE)/$(FREETYPE_TMP) \
		$(TARGET_SHARE_DIR)/aclocal
	$(TOUCH)

# -----------------------------------------------------------------------------

LIBJPEG-TURBO_VER    = 2.0.2
LIBJPEG-TURBO_TMP    = libjpeg-turbo-$(LIBJPEG-TURBO_VER)
LIBJPEG-TURBO_SOURCE = libjpeg-turbo-$(LIBJPEG-TURBO_VER).tar.gz
LIBJPEG-TURBO_URL    = https://sourceforge.net/projects/libjpeg-turbo/files/$(LIBJPEG-TURBO_VER)

$(ARCHIVE)/$(LIBJPEG-TURBO_SOURCE):
	$(DOWNLOAD) $(LIBJPEG-TURBO_URL)/$(LIBJPEG-TURBO_SOURCE)

LIBJPEG-TURBO_PATCH  = libjpeg-turbo-tiff-ojpeg.patch

libjpeg: $(ARCHIVE)/$(LIBJPEG-TURBO_SOURCE) | $(TARGET_DIR)
	$(REMOVE)/$(LIBJPEG-TURBO_TMP)
	$(UNTAR)/$(LIBJPEG-TURBO_SOURCE)
	$(CHDIR)/$(LIBJPEG-TURBO_TMP); \
		$(call apply_patches, $(LIBJPEG-TURBO_PATCH)); \
		$(CMAKE) \
			-DWITH_SIMD=False \
			-DWITH_JPEG8=80 \
			; \
		$(MAKE); \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
	$(REWRITE_PKGCONF)/libturbojpeg.pc
	$(REWRITE_PKGCONF)/libjpeg.pc
	rm -f $(addprefix $(TARGET_BIN_DIR)/,cjpeg djpeg jpegtran rdjpgcom tjbench wrjpgcom)
	$(REMOVE)/$(LIBJPEG-TURBO_TMP)
	$(TOUCH)

# -----------------------------------------------------------------------------

OPENSSL_VER    = 1.0.2t
OPENSSL_TMP    = openssl-$(OPENSSL_VER)
OPENSSL_SOURCE = openssl-$(OPENSSL_VER).tar.gz
OPENSSL_URL    = https://www.openssl.org/source

$(ARCHIVE)/$(OPENSSL_SOURCE):
	$(DOWNLOAD) $(OPENSSL_URL)/$(OPENSSL_SOURCE)

OPENSSL_PATCH  = 0000-Configure-align-O-flag.patch

ifeq ($(BOXARCH), arm)
  OPENSSL_ARCH = linux-armv4
else ifeq ($(BOXARCH), mips)
  OPENSSL_ARCH = linux-generic32
endif

openssl: $(ARCHIVE)/$(OPENSSL_SOURCE) | $(TARGET_DIR)
	$(REMOVE)/$(OPENSSL_TMP)
	$(UNTAR)/$(OPENSSL_SOURCE)
	$(CHDIR)/$(OPENSSL_TMP); \
		$(call apply_patches, $(addprefix $(@F)/,$(OPENSSL_PATCH))); \
		./Configure \
			$(OPENSSL_ARCH) \
			shared \
			threads \
			no-hw \
			no-engine \
			no-sse2 \
			no-perlasm \
			no-tests \
			no-fuzz-afl \
			no-fuzz-libfuzzer \
			\
			$(TARGET_CFLAGS) \
			-DTERMIOS -fomit-frame-pointer \
			-DOPENSSL_SMALL_FOOTPRINT \
			$(TARGET_LDFLAGS) \
			\
			--cross-compile-prefix=$(TARGET_CROSS) \
			--prefix=/ \
			--openssldir=/etc/ssl \
			; \
		sed -i "s| build_tests||" Makefile; \
		sed -i 's|^MANDIR=.*|MANDIR=$(remove-mandir)|' Makefile; \
		sed -i 's|^HTMLDIR=.*|HTMLDIR=$(remove-htmldir)|' Makefile; \
		make depend; \
		make; \
		make install_sw INSTALL_PREFIX=$(TARGET_DIR)
	$(REWRITE_PKGCONF)/openssl.pc
	$(REWRITE_PKGCONF)/libcrypto.pc
	$(REWRITE_PKGCONF)/libssl.pc
	rm -rf $(TARGET_LIB_DIR)/engines
	rm -f $(TARGET_BIN_DIR)/c_rehash
	rm -f $(TARGET_DIR)/etc/ssl/misc/{CA.pl,tsget}
ifeq ($(BOXSERIES), $(filter $(BOXSERIES), hd1 hd2))
	rm -f $(TARGET_BIN_DIR)/openssl
	rm -f $(TARGET_DIR)/etc/ssl/misc/{CA.*,c_*}
endif
	chmod 0755 $(TARGET_LIB_DIR)/lib{crypto,ssl}.so.*
	for version in 0.9.7 0.9.8 1.0.2; do \
		ln -sf libcrypto.so.1.0.0 $(TARGET_LIB_DIR)/libcrypto.so.$$version; \
		ln -sf libssl.so.1.0.0 $(TARGET_LIB_DIR)/libssl.so.$$version; \
	done
	$(REMOVE)/$(OPENSSL_TMP)
	$(TOUCH)

# -----------------------------------------------------------------------------

NCURSES_VER    = 6.1
NCURSES_TMP    = ncurses-$(NCURSES_VER)
NCURSES_SOURCE = ncurses-$(NCURSES_VER).tar.gz
NCURSES_URL    = https://ftp.gnu.org/pub/gnu/ncurses

$(ARCHIVE)/$(NCURSES_SOURCE):
	$(DOWNLOAD) $(NCURSES_URL)/$(NCURSES_SOURCE)

NCURSES_PATCH  = ncurses-gcc-5.x-MKlib_gen.patch

ncurses: $(ARCHIVE)/$(NCURSES_SOURCE) | $(TARGET_DIR)
	$(REMOVE)/$(NCURSES_TMP)
	$(UNTAR)/$(NCURSES_SOURCE)
	$(CHDIR)/$(NCURSES_TMP); \
		$(call apply_patches, $(NCURSES_PATCH)); \
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
	rm -f $(addprefix $(TARGET_LIB_DIR)/,libform* libmenu* libpanel*)
	rm -f $(addprefix $(PKG_CONFIG_PATH)/,form.pc menu.pc panel.pc)
	rm -f $(HOST_DIR)/bin/ncurses*
	mv $(TARGET_BIN_DIR)/ncurses6-config $(HOST_DIR)/bin
	$(REWRITE_CONFIG) $(HOST_DIR)/bin/ncurses6-config
	$(REWRITE_PKGCONF)/ncurses.pc
	ln -sf ./ncurses/curses.h $(TARGET_INCLUDE_DIR)/curses.h
	ln -sf ./ncurses/curses.h $(TARGET_INCLUDE_DIR)/ncurses.h
	ln -sf ./ncurses/term.h $(TARGET_INCLUDE_DIR)/term.h
	$(REMOVE)/$(NCURSES_TMP)
	$(TOUCH)

# -----------------------------------------------------------------------------

openthreads: $(SOURCE_DIR)/$(NI-OPENTHREADS) | $(TARGET_DIR)
	$(REMOVE)/$(NI-OPENTHREADS)
	tar -C $(SOURCE_DIR) -cp $(NI-OPENTHREADS) --exclude-vcs | tar -C $(BUILD_TMP) -x
	$(CHDIR)/$(NI-OPENTHREADS)/; \
		$(CMAKE) \
			-DCMAKE_SUPPRESS_DEVELOPER_WARNINGS="1" \
			-D_OPENTHREADS_ATOMIC_USE_GCC_BUILTINS_EXITCODE="0" \
			; \
		$(MAKE); \
		make install DESTDIR=$(TARGET_DIR)
	rm -f $(TARGET_LIB_DIR)/cmake
	$(REMOVE)/$(NI-OPENTHREADS)
	$(REWRITE_PKGCONF)/openthreads.pc
	$(TOUCH)

# -----------------------------------------------------------------------------

LIBUSB_VER    = 1.0.23
LIBUSB_TMP    = libusb-$(LIBUSB_VER)
LIBUSB_SOURCE = libusb-$(LIBUSB_VER).tar.bz2
LIBUSB_URL    = https://github.com/libusb/libusb/releases/download/v$(LIBUSB_VER)

$(ARCHIVE)/$(LIBUSB_SOURCE):
	$(DOWNLOAD) $(LIBUSB_URL)/$(LIBUSB_SOURCE)

libusb: $(ARCHIVE)/$(LIBUSB_SOURCE) | $(TARGET_DIR)
	$(REMOVE)/$(LIBUSB_TMP)
	$(UNTAR)/$(LIBUSB_SOURCE)
	$(CHDIR)/$(LIBUSB_TMP); \
		$(CONFIGURE) \
			--prefix= \
			--disable-udev \
			; \
		$(MAKE); \
		make install DESTDIR=$(TARGET_DIR); \
	$(REWRITE_LIBTOOL)/libusb-$(basename $(LIBUSB_VER)).la
	$(REWRITE_PKGCONF)/libusb-$(basename $(LIBUSB_VER)).pc
	$(REMOVE)/$(LIBUSB_TMP)
	$(TOUCH)

# -----------------------------------------------------------------------------

LIBUSB-COMPAT_VER    = 0.1.7
LIBUSB-COMPAT_TMP    = libusb-compat-$(LIBUSB-COMPAT_VER)
LIBUSB-COMPAT_SOURCE = libusb-compat-$(LIBUSB-COMPAT_VER).tar.bz2
LIBUSB-COMPAT_URL    = https://github.com/libusb/libusb-compat-0.1/releases/download/v$(LIBUSB-COMPAT_VER)

$(ARCHIVE)/$(LIBUSB-COMPAT_SOURCE):
	$(DOWNLOAD) $(LIBUSB-COMPAT_URL)/$(LIBUSB-COMPAT_SOURCE)

LUBUSB-COMPAT_DEPS   = libusb

libusb-compat: $(LUBUSB-COMPAT_DEPS) $(ARCHIVE)/$(LIBUSB-COMPAT_SOURCE) | $(TARGET_DIR)
	$(REMOVE)/$(LIBUSB-COMPAT_TMP)
	$(UNTAR)/$(LIBUSB-COMPAT_SOURCE)
	$(CHDIR)/$(LIBUSB-COMPAT_TMP); \
		$(CONFIGURE) \
			--prefix= \
			; \
		$(MAKE); \
		make install DESTDIR=$(TARGET_DIR); \
	mv $(TARGET_BIN_DIR)/libusb-config $(HOST_DIR)/bin
	$(REWRITE_CONFIG) $(HOST_DIR)/bin/libusb-config
	$(REWRITE_LIBTOOL)/libusb.la
	$(REWRITE_PKGCONF)/libusb.pc
	$(REMOVE)/$(LIBUSB-COMPAT_TMP)
	$(TOUCH)

# -----------------------------------------------------------------------------

LIBGD_VER    = 2.2.5
LIBGD_TMP    = libgd-$(LIBGD_VER)
LIBGD_SOURCE = libgd-$(LIBGD_VER).tar.xz
LIBGD_URL    = https://github.com/libgd/libgd/releases/download/gd-$(LIBGD_VER)

$(ARCHIVE)/$(LIBGD_SOURCE):
	$(DOWNLOAD) $(LIBGD_URL)/$(LIBGD_SOURCE)

LIBGD_DEPS   = zlib libpng libjpeg freetype

libgd2: $(LIBGD_DEPS) $(ARCHIVE)/$(LIBGD_SOURCE) | $(TARGET_DIR)
	$(REMOVE)/$(LIBGD_TMP)
	$(UNTAR)/$(LIBGD_SOURCE)
	$(CHDIR)/$(LIBGD_TMP); \
		./bootstrap.sh; \
		$(CONFIGURE) \
			--prefix= \
			--bindir=$(remove-bindir) \
			--without-fontconfig \
			--without-xpm \
			--without-x \
			; \
		$(MAKE); \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
	$(REWRITE_LIBTOOL)/libgd.la
	$(REWRITE_PKGCONF)/gdlib.pc
	$(REMOVE)/$(LIBGD_TMP)
	$(TOUCH)

# -----------------------------------------------------------------------------

LIBDPF_VER    = git
LIBDPF_TMP    = dpf-ax.$(LIBDPF_VER)
LIBDPF_SOURCE = dpf-ax.$(LIBDPF_VER)
LIBDPF_URL    = $(GITHUB)/MaxWiesel

LIBDPF_PATCH  = libdpf-crossbuild.patch

LIBDPF_DEPS   = libusb-compat

libdpf: $(LIBDPF_DEPS) | $(TARGET_DIR)
	$(REMOVE)/$(LIBDPF_TMP)
	$(GET-GIT-SOURCE) $(LIBDPF_URL)/$(LIBDPF_SOURCE) $(ARCHIVE)/$(LIBDPF_SOURCE)
	$(CPDIR)/$(LIBDPF_SOURCE)
	$(CHDIR)/$(LIBDPF_TMP)/dpflib; \
		$(call apply_patches, $(LIBDPF_PATCH)); \
		make libdpf.a CC=$(TARGET_CC) PREFIX=$(TARGET_DIR); \
		mkdir -p $(TARGET_INCLUDE_DIR)/libdpf; \
		cp dpf.h $(TARGET_INCLUDE_DIR)/libdpf/libdpf.h; \
		cp ../include/spiflash.h $(TARGET_INCLUDE_DIR)/libdpf/; \
		cp ../include/usbuser.h $(TARGET_INCLUDE_DIR)/libdpf/; \
		cp libdpf.a $(TARGET_LIB_DIR)/
	$(REMOVE)/$(LIBDPF_TMP)
	$(TOUCH)

# -----------------------------------------------------------------------------

LZO_VER    = 2.10
LZO_TMP    = lzo-$(LZO_VER)
LZO_SOURCE = lzo-$(LZO_VER).tar.gz
LZO_URL    = https://www.oberhumer.com/opensource/lzo/download

$(ARCHIVE)/$(LZO_SOURCE):
	$(DOWNLOAD) $(LZO_URL)/$(LZO_SOURCE)

lzo: $(ARCHIVE)/$(LZO_SOURCE) | $(TARGET_DIR)
	$(REMOVE)/$(LZO_TMP)
	$(UNTAR)/$(LZO_SOURCE)
	$(CHDIR)/$(LZO_TMP); \
		$(CONFIGURE) \
			--mandir=$(remove-mandir) \
			--docdir=$(remove-docdir) \
			--prefix= \
			; \
		$(MAKE); \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
	$(REWRITE_LIBTOOL)/liblzo$(basename $(LZO_VER)).la
	$(REMOVE)/$(LZO_TMP)
	$(TOUCH)

# -----------------------------------------------------------------------------

LIBSIGC_VER    = 2.10.2
LIBSIGC_TMP    = libsigc++-$(LIBSIGC_VER)
LIBSIGC_SOURCE = libsigc++-$(LIBSIGC_VER).tar.xz
LIBSIGC_URL    = https://download.gnome.org/sources/libsigc++/$(basename $(LIBSIGC_VER))

$(ARCHIVE)/$(LIBSIGC_SOURCE):
	$(DOWNLOAD) $(LIBSIGC_URL)/$(LIBSIGC_SOURCE)

libsigc++: $(ARCHIVE)/$(LIBSIGC_SOURCE) | $(TARGET_DIR)
	$(REMOVE)/$(LIBSIGC_TMP)
	$(UNTAR)/$(LIBSIGC_SOURCE)
	$(CHDIR)/$(LIBSIGC_TMP); \
		$(CONFIGURE) \
			--prefix= \
			--disable-documentation \
			--enable-silent-rules \
			; \
		$(MAKE); \
		$(MAKE) install DESTDIR=$(TARGET_DIR); \
		cp sigc++config.h $(TARGET_INCLUDE_DIR)
	ln -sf ./sigc++-2.0/sigc++ $(TARGET_INCLUDE_DIR)/sigc++
	$(REWRITE_LIBTOOL)/libsigc-2.0.la
	$(REWRITE_PKGCONF)/sigc++-2.0.pc
	$(REMOVE)/$(LIBSIGC_TMP)
	$(TOUCH)

# -----------------------------------------------------------------------------

EXPAT_VER    = 2.2.9
EXPAT_TMP    = expat-$(EXPAT_VER)
EXPAT_SOURCE = expat-$(EXPAT_VER).tar.bz2
EXPAT_URL    = https://sourceforge.net/projects/expat/files/expat/$(EXPAT_VER)

$(ARCHIVE)/$(EXPAT_SOURCE):
	$(DOWNLOAD) $(EXPAT_URL)/$(EXPAT_SOURCE)

EXPAT_PATCH  = expat-libtool-tag.patch

expat: $(ARCHIVE)/$(EXPAT_SOURCE) | $(TARGET_DIR)
	$(REMOVE)/$(EXPAT_TMP)
	$(UNTAR)/$(EXPAT_SOURCE)
	$(CHDIR)/$(EXPAT_TMP); \
		$(call apply_patches, $(EXPAT_PATCH)); \
		autoreconf -fi; \
		$(CONFIGURE) \
			--prefix= \
			--docdir=$(remove-docdir) \
			--mandir=$(remove-mandir) \
			--enable-shared \
			--disable-static \
			--without-xmlwf \
			; \
		$(MAKE); \
		make install DESTDIR=$(TARGET_DIR)
	$(REWRITE_PKGCONF)/expat.pc
	$(REWRITE_LIBTOOL)/libexpat.la
	$(REMOVE)/$(EXPAT_TMP)
	$(TOUCH)

# -----------------------------------------------------------------------------

LIBBLURAY_VER    = 0.9.3
LIBBLURAY_TMP    = libbluray-$(LIBBLURAY_VER)
LIBBLURAY_SOURCE = libbluray-$(LIBBLURAY_VER).tar.bz2
LIBBLURAY_URL    = ftp.videolan.org/pub/videolan/libbluray/$(LIBBLURAY_VER)

$(ARCHIVE)/$(LIBBLURAY_SOURCE):
	$(DOWNLOAD) $(LIBBLURAY_URL)/$(LIBBLURAY_SOURCE)

LIBBLURAY_PATCH  = libbluray.patch

LIBBLURAY_DEPS   = freetype
ifeq ($(BOXSERIES), hd2)
  LIBBLURAY_DEPS += libaacs libbdplus
endif

libbluray: $(LIBBLURAY_DEPS) $(ARCHIVE)/$(LIBBLURAY_SOURCE) | $(TARGET_DIR)
	$(REMOVE)/$(LIBBLURAY_TMP)
	$(UNTAR)/$(LIBBLURAY_SOURCE)
	$(CHDIR)/$(LIBBLURAY_TMP); \
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
	$(REMOVE)/$(LIBBLURAY_TMP)
	$(TOUCH)

# -----------------------------------------------------------------------------

LIBASS_VER    = 0.14.0
LIBASS_TMP    = libass-$(LIBASS_VER)
LIBASS_SOURCE = libass-$(LIBASS_VER).tar.xz
LIBASS_URL    = https://github.com/libass/libass/releases/download/$(LIBASS_VER)

$(ARCHIVE)/$(LIBASS_SOURCE):
	$(DOWNLOAD) $(LIBASS_URL)/$(LIBASS_SOURCE)

LIBASS_PATCH  = libass.patch

LIBASS_DEPS   = freetype fribidi

libass: $(LIBASS_DEPS) $(ARCHIVE)/$(LIBASS_SOURCE) | $(TARGET_DIR)
	$(REMOVE)/$(LIBASS_TMP)
	$(UNTAR)/$(LIBASS_SOURCE)
	$(CHDIR)/$(LIBASS_TMP); \
		$(call apply_patches, $(LIBASS_PATCH)); \
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
	$(REWRITE_LIBTOOL)/libass.la
	$(REWRITE_PKGCONF)/libass.pc
	$(REMOVE)/$(LIBASS_TMP)
	$(TOUCH)
	
# -----------------------------------------------------------------------------

LIBGPG-ERROR_VER    = 1.32
LIBGPG-ERROR_TMP    = libgpg-error-$(LIBGPG-ERROR_VER)
LIBGPG-ERROR_SOURCE = libgpg-error-$(LIBGPG-ERROR_VER).tar.bz2
LIBGPG-ERROR_URL    = ftp://ftp.gnupg.org/gcrypt/libgpg-error

$(ARCHIVE)/$(LIBGPG-ERROR_SOURCE):
	$(DOWNLOAD) $(LIBGPG-ERROR_URL)/$(LIBGPG-ERROR_SOURCE)

libgpg-error: $(ARCHIVE)/$(LIBGPG-ERROR_SOURCE) | $(TARGET_DIR)
	$(REMOVE)/$(LIBGPG-ERROR_TMP)
	$(UNTAR)/$(LIBGPG-ERROR_SOURCE)
	$(CHDIR)/$(LIBGPG-ERROR_TMP); \
		pushd src/syscfg; \
			ln -s lock-obj-pub.arm-unknown-linux-gnueabi.h lock-obj-pub.$(TARGET).h; \
		popd; \
		$(CONFIGURE) \
			--prefix= \
			--datarootdir=$(remove-datarootdir) \
			--enable-maintainer-mode \
			--enable-shared \
			--disable-static \
			; \
		$(MAKE); \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
	mv $(TARGET_BIN_DIR)/gpg-error-config $(HOST_DIR)/bin
	$(REWRITE_CONFIG) $(HOST_DIR)/bin/gpg-error-config
	$(REWRITE_LIBTOOL)/libgpg-error.la
	rm -rf $(TARGET_BIN_DIR)/gpg-error
	rm -rf $(TARGET_SHARE_DIR)/common-lisp
	$(REMOVE)/$(LIBGPG-ERROR_TMP)
	$(TOUCH)

# -----------------------------------------------------------------------------

LIBGCRYPT_VER    = 1.8.3
LIBGCRYPT_TMP    = libgcrypt-$(LIBGCRYPT_VER)
LIBGCRYPT_SOURCE = libgcrypt-$(LIBGCRYPT_VER).tar.gz
LIBGCRYPT_URL    = ftp://ftp.gnupg.org/gcrypt/libgcrypt

$(ARCHIVE)/$(LIBGCRYPT_SOURCE):
	$(DOWNLOAD) $(LIBGCRYPT_URL)/$(LIBGCRYPT_SOURCE)

LIBGCRYPT_DEPS   = libgpg-error

libgcrypt: $(LIBGCRYPT_DEPS) $(ARCHIVE)/$(LIBGCRYPT_SOURCE) | $(TARGET_DIR)
	$(REMOVE)/$(LIBGCRYPT_TMP)
	$(UNTAR)/$(LIBGCRYPT_SOURCE)
	$(CHDIR)/$(LIBGCRYPT_TMP); \
		$(CONFIGURE) \
			--prefix= \
			--datarootdir=$(remove-datarootdir) \
			--enable-maintainer-mode \
			--enable-silent-rules \
			--enable-shared \
			--disable-static \
			; \
		$(MAKE); \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
	mv $(TARGET_BIN_DIR)/libgcrypt-config $(HOST_DIR)/bin
	$(REWRITE_CONFIG) $(HOST_DIR)/bin/libgcrypt-config
	$(REWRITE_LIBTOOL)/libgcrypt.la
	rm -rf $(TARGET_BIN_DIR)/dumpsexp
	rm -rf $(TARGET_BIN_DIR)/hmac256
	rm -rf $(TARGET_BIN_DIR)/mpicalc
	$(REMOVE)/$(LIBGCRYPT_TMP)
	$(TOUCH)

# -----------------------------------------------------------------------------

LIBAACS_VER    = 0.9.0
LIBAACS_TMP    = libaacs-$(LIBAACS_VER)
LIBAACS_SOURCE = libaacs-$(LIBAACS_VER).tar.bz2
LIBAACS_URL    = ftp://ftp.videolan.org/pub/videolan/libaacs/$(LIBAACS_VER)

$(ARCHIVE)/$(LIBAACS_SOURCE):
	$(DOWNLOAD) $(LIBAACS_URL)/$(LIBAACS_SOURCE)

LIBAACS_DEPS   = libgcrypt

libaacs: $(LIBAACS_DEPS) $(ARCHIVE)/$(LIBAACS_SOURCE) | $(TARGET_DIR)
	$(REMOVE)/$(LIBAACS_TMP)
	$(UNTAR)/$(LIBAACS_SOURCE)
	$(CHDIR)/$(LIBAACS_TMP); \
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
	$(CD) $(TARGET_DIR); \
		mkdir -p .config/aacs .cache/aacs/vuk
	cp $(IMAGEFILES)/libaacs/KEYDB.cfg $(TARGET_DIR)/.config/aacs
	$(REMOVE)/$(LIBAACS_TMP)
	$(TOUCH)

# -----------------------------------------------------------------------------

LIBBDPLUS_VER    = 0.1.2
LIBBDPLUS_TMP    = libbdplus-$(LIBBDPLUS_VER)
LIBBDPLUS_SOURCE = libbdplus-$(LIBBDPLUS_VER).tar.bz2
LIBBDPLUS_URL    = ftp://ftp.videolan.org/pub/videolan/libbdplus/$(LIBBDPLUS_VER)

$(ARCHIVE)/$(LIBBDPLUS_SOURCE):
	$(DOWNLOAD) $(LIBBDPLUS_URL)/$(LIBBDPLUS_SOURCE)

LIBBDPLUS_DEPS   = libaacs

libbdplus: $(LIBBDPLUS_DEPS) $(ARCHIVE)/$(LIBBDPLUS_SOURCE) | $(TARGET_DIR)
	$(REMOVE)/$(LIBBDPLUS_TMP)
	$(UNTAR)/$(LIBBDPLUS_SOURCE)
	$(CHDIR)/$(LIBBDPLUS_TMP); \
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
	$(CD) $(TARGET_DIR); \
		mkdir -p .config/bdplus/vm0
	cp -f $(IMAGEFILES)/libbdplus/* $(TARGET_DIR)/.config/bdplus/vm0
	$(REMOVE)/$(LIBBDPLUS_TMP)
	$(TOUCH)

# -----------------------------------------------------------------------------

LIBXML2_VER    = 2.9.9
LIBXML2_TMP    = libxml2-$(LIBXML2_VER)
LIBXML2_SOURCE = libxml2-$(LIBXML2_VER).tar.gz
LIBXML2_URL    = http://xmlsoft.org/sources

$(ARCHIVE)/$(LIBXML2_SOURCE):
	$(DOWNLOAD) $(LIBXML2_URL)/$(LIBXML2_SOURCE)

libxml2: $(ARCHIVE)/$(LIBXML2_SOURCE) | $(TARGET_DIR)
	$(REMOVE)/$(LIBXML2_TMP)
	$(UNTAR)/$(LIBXML2_SOURCE)
	$(CHDIR)/$(LIBXML2_TMP); \
		$(CONFIGURE) \
			--prefix= \
			--enable-shared \
			--disable-static \
			--datarootdir=$(remove-datarootdir) \
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
	mv $(TARGET_BIN_DIR)/xml2-config $(HOST_DIR)/bin
	$(REWRITE_LIBTOOL)/libxml2.la
	$(REWRITE_PKGCONF)/libxml-2.0.pc
	$(REWRITE_CONFIG) $(HOST_DIR)/bin/xml2-config
	rm -rf $(TARGET_LIB_DIR)/xml2Conf.sh
	rm -rf $(TARGET_LIB_DIR)/cmake
	$(REMOVE)/$(LIBXML2_TMP)
	$(TOUCH)

# -----------------------------------------------------------------------------

PUGIXML_VER    = 1.9
PUGIXML_TMP    = pugixml-$(PUGIXML_VER)
PUGIXML_SOURCE = pugixml-$(PUGIXML_VER).tar.gz
PUGIXML_URL    = https://github.com/zeux/pugixml/releases/download/v$(PUGIXML_VER)

$(ARCHIVE)/$(PUGIXML_SOURCE):
	$(DOWNLOAD) $(PUGIXML_URL)/$(PUGIXML_SOURCE)

PUGIXML_PATCH  = pugixml-config.patch

pugixml: $(ARCHIVE)/$(PUGIXML_SOURCE) | $(TARGET_DIR)
	$(REMOVE)/$(PUGIXML_TMP)
	$(UNTAR)/$(PUGIXML_SOURCE)
	$(CHDIR)/$(PUGIXML_TMP); \
		$(call apply_patches, $(PUGIXML_PATCH)); \
		$(CMAKE); \
		$(MAKE); \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
	rm -rf $(TARGET_LIB_DIR)/cmake
	$(REMOVE)/$(PUGIXML_TMP)
	$(TOUCH)

# -----------------------------------------------------------------------------

RTMPDUMP_DEPS   = zlib openssl

RTMPDUMP_MAKE_OPTS = \
	prefix= \
	mandir=$(remove-mandir)

rtmpdump: $(RTMPDUMP_DEPS) $(SOURCE_DIR)/$(NI-RTMPDUMP) | $(TARGET_DIR)
	$(REMOVE)/$(NI-RTMPDUMP)
	tar -C $(SOURCE_DIR) -cp $(NI-RTMPDUMP) --exclude-vcs | tar -C $(BUILD_TMP) -x
	$(CHDIR)/$(NI-RTMPDUMP); \
		make $(RTMPDUMP_MAKE_OPTS) CROSS_COMPILE=$(TARGET_CROSS) XCFLAGS="$(TARGET_CFLAGS)" XLDFLAGS="$(TARGET_LDFLAGS)"; \
		make $(RTMPDUMP_MAKE_OPTS) install DESTDIR=$(TARGET_DIR)
	rm -rf $(TARGET_DIR)/sbin/rtmpgw
	rm -rf $(TARGET_DIR)/sbin/rtmpsrv
	rm -rf $(TARGET_DIR)/sbin/rtmpsuck
	$(REWRITE_PKGCONF)/librtmp.pc
	$(REMOVE)/$(NI-RTMPDUMP)
	$(TOUCH)

# -----------------------------------------------------------------------------

LIBTIRPC_VER    = 1.1.4
LIBTIRPC_TMP    = libtirpc-$(LIBTIRPC_VER)
LIBTIRPC_SOURCE = libtirpc-$(LIBTIRPC_VER).tar.bz2
LIBTIRPC_URL    = https://sourceforge.net/projects/libtirpc/files/libtirpc/$(LIBTIRPC_VER)

$(ARCHIVE)/$(LIBTIRPC_SOURCE):
	$(DOWNLOAD) $(LIBTIRPC_URL)/$(LIBTIRPC_SOURCE)

LIBTIRP_PATCH  = 0001-Disable-parts-of-TIRPC-requiring-NIS-support.patch
LIBTIRP_PATCH += 0002-uClibc-without-RPC-support-and-musl-does-not-install-rpcent.h.patch
LIBTIRP_PATCH += 0003-Automatically-generate-XDR-header-files-from-.x-sour.patch
LIBTIRP_PATCH += 0004-Add-more-XDR-files-needed-to-build-rpcbind-on-top-of.patch
LIBTIRP_PATCH += 0005-Disable-DES-authentification-support.patch
LIBTIRP_PATCH += 0006-rpc-types.h-fix-musl-build.patch

libtirpc: $(ARCHIVE)/$(LIBTIRPC_SOURCE) | $(TARGET_DIR)
	$(REMOVE)/$(LIBTIRPC_TMP)
	$(UNTAR)/$(LIBTIRPC_SOURCE)
	$(CHDIR)/$(LIBTIRPC_TMP); \
		$(call apply_patches, $(addprefix $(@F)/,$(LIBTIRP_PATCH))); \
		autoreconf -fi; \
		$(CONFIGURE) \
			--target=$(TARGET) \
			--prefix= \
			--disable-gssapi \
			--enable-silent-rules \
			--mandir=$(remove-mandir) \
			; \
		$(MAKE); \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
	$(REWRITE_LIBTOOL)/libtirpc.la
	$(REWRITE_PKGCONF)/libtirpc.pc
	$(REMOVE)/$(LIBTIRPC_TMP)
	$(TOUCH)

# -----------------------------------------------------------------------------

CONFUSE_VER    = 3.2.2
CONFUSE_TMP    = confuse-$(CONFUSE_VER)
CONFUSE_SOURCE = confuse-$(CONFUSE_VER).tar.xz
CONFUSE_URL    = https://github.com/martinh/libconfuse/releases/download/v$(CONFUSE_VER)

$(ARCHIVE)/$(CONFUSE_SOURCE):
	$(DOWNLOAD) $(CONFUSE_URL)/$(CONFUSE_SOURCE)

confuse: $(ARCHIVE)/$(CONFUSE_SOURCE) | $(TARGET_DIR)
	$(REMOVE)/$(CONFUSE_TMP)
	$(UNTAR)/$(CONFUSE_SOURCE)
	$(CHDIR)/$(CONFUSE_TMP); \
		$(CONFIGURE) \
			--prefix= \
			--docdir=$(remove-docdir) \
			--mandir=$(remove-mandir) \
			--enable-silent-rules \
			--enable-static \
			--disable-shared \
			; \
		$(MAKE); \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
	$(REWRITE_PKGCONF)/libconfuse.pc
	$(REMOVE)/$(CONFUSE_TMP)
	$(TOUCH)

# -----------------------------------------------------------------------------

LIBITE_VER    = 2.0.2
LIBITE_TMP    = libite-$(LIBITE_VER)
LIBITE_SOURCE = libite-$(LIBITE_VER).tar.xz
LIBITE_URL    = https://github.com/troglobit/libite/releases/download/v$(LIBITE_VER)

$(ARCHIVE)/$(LIBITE_SOURCE):
	$(DOWNLOAD) $(LIBITE_URL)/$(LIBITE_SOURCE)

libite: $(ARCHIVE)/$(LIBITE_SOURCE) | $(TARGET_DIR)
	$(REMOVE)/$(LIBITE_TMP)
	$(UNTAR)/$(LIBITE_SOURCE)
	$(CHDIR)/$(LIBITE_TMP); \
		$(CONFIGURE) \
			--prefix= \
			--docdir=$(remove-docdir) \
			--mandir=$(remove-docdir) \
			--enable-silent-rules \
			--enable-static \
			--disable-shared \
			; \
		$(MAKE); \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
	$(REWRITE_PKGCONF)/libite.pc
	$(REMOVE)/$(LIBITE_TMP)
	$(TOUCH)

# -----------------------------------------------------------------------------

LIBMAD_VER    = 0.15.1b
LIBMAD_TMP    = libmad-$(LIBMAD_VER)
LIBMAD_SOURCE = libmad-$(LIBMAD_VER).tar.gz
LIBMAD_URL    = https://sourceforge.net/projects/mad/files/libmad/$(LIBMAD_VER)

$(ARCHIVE)/$(LIBMAD_SOURCE):
	$(DOWNLOAD) $(LIBMAD_URL)/$(LIBMAD_SOURCE)

LIBMAD_PATCH  = libmad-pc.patch
LIBMAD_PATCH += libmad-frame_length.diff
LIBMAD_PATCH += libmad-mips-h-constraint-removal.patch
LIBMAD_PATCH += libmad-remove-deprecated-cflags.patch
LIBMAD_PATCH += libmad-thumb2-fixed-arm.patch
LIBMAD_PATCH += libmad-thumb2-imdct-arm.patch

libmad: $(ARCHIVE)/$(LIBMAD_SOURCE) | $(TARGET_DIR)
	$(REMOVE)/$(LIBMAD_TMP)
	$(UNTAR)/$(LIBMAD_SOURCE)
	$(CHDIR)/$(LIBMAD_TMP); \
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
	$(REMOVE)/$(LIBMAD_TMP)
	$(TOUCH)

# -----------------------------------------------------------------------------

LIBVORBISIDEC_VER    = 1.2.1+git20180316
LIBVORBISIDEC_TMP    = libvorbisidec-$(LIBVORBISIDEC_VER)
LIBVORBISIDEC_SOURCE = libvorbisidec_$(LIBVORBISIDEC_VER).orig.tar.gz
LIBVORBISIDEC_URL    = https://ftp.de.debian.org/debian/pool/main/libv/libvorbisidec

$(ARCHIVE)/$(LIBVORBISIDEC_SOURCE):
	$(DOWNLOAD) $(LIBVORBISIDEC_URL)/$(LIBVORBISIDEC_SOURCE)

LIBVORBISIDEC_DEPS   = libogg

libvorbisidec: $(LIBVORBISIDEC_DEPS) $(ARCHIVE)/$(LIBVORBISIDEC_SOURCE) | $(TARGET_DIR)
	$(REMOVE)/$(LIBVORBISIDEC_TMP)
	$(UNTAR)/$(LIBVORBISIDEC_SOURCE)
	$(CHDIR)/$(LIBVORBISIDEC_TMP); \
		sed -i '122 s/^/#/' configure.in; \
		autoreconf -fi; \
		$(CONFIGURE) \
			--prefix= \
			; \
		make all; \
		make install DESTDIR=$(TARGET_DIR); \
	$(REWRITE_PKGCONF)/vorbisidec.pc
	$(REWRITE_LIBTOOL)/libvorbisidec.la
	$(REMOVE)/$(LIBVORBISIDEC_TMP)
	$(TOUCH)

# -----------------------------------------------------------------------------

LIBOGG_VER    = 1.3.4
LIBOGG_TMP    = libogg-$(LIBOGG_VER)
LIBOGG_SOURCE = libogg-$(LIBOGG_VER).tar.gz
LIBOGG_URL    = https://ftp.osuosl.org/pub/xiph/releases/ogg

$(ARCHIVE)/$(LIBOGG_SOURCE):
	$(DOWNLOAD) $(LIBOGG_URL)/$(LIBOGG_SOURCE)

libogg: $(ARCHIVE)/$(LIBOGG_SOURCE) | $(TARGET_DIR)
	$(REMOVE)/$(LIBOGG_TMP)
	$(UNTAR)/$(LIBOGG_SOURCE)
	$(CHDIR)/$(LIBOGG_TMP); \
		$(CONFIGURE) \
			--prefix= \
			--datarootdir=$(remove-datarootdir) \
			--enable-shared \
			; \
		$(MAKE); \
		make install DESTDIR=$(TARGET_DIR)
	$(REWRITE_PKGCONF)/ogg.pc
	$(REWRITE_LIBTOOL)/libogg.la
	$(REMOVE)/$(LIBOGG_TMP)
	$(TOUCH)

# -----------------------------------------------------------------------------

FRIBIDI_VER    = 1.0.7
FRIBIDI_TMP    = fribidi-$(FRIBIDI_VER)
FRIBIDI_SOURCE = fribidi-$(FRIBIDI_VER).tar.bz2
FRIBIDI_URL    = https://github.com/fribidi/fribidi/releases/download/v$(FRIBIDI_VER)

$(ARCHIVE)/$(FRIBIDI_SOURCE):
	$(DOWNLOAD) $(FRIBIDI_URL)/$(FRIBIDI_SOURCE)

fribidi: $(ARCHIVE)/$(FRIBIDI_SOURCE) | $(TARGET_DIR)
	$(REMOVE)/$(FRIBIDI_TMP)
	$(UNTAR)/$(FRIBIDI_SOURCE)
	$(CHDIR)/$(FRIBIDI_TMP); \
		$(CONFIGURE) \
			--prefix= \
			--mandir=$(remove-mandir) \
			--disable-debug \
			--disable-deprecated \
			; \
		$(MAKE); \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
	$(REWRITE_PKGCONF)/fribidi.pc
	$(REWRITE_LIBTOOL)/libfribidi.la
	$(REMOVE)/$(FRIBIDI_TMP)
	$(TOUCH)

# -----------------------------------------------------------------------------

LIBFFI_VER    = 3.2.1
LIBFFI_TMP    = libffi-$(LIBFFI_VER)
LIBFFI_SOURCE = libffi-$(LIBFFI_VER).tar.gz
LIBFFI_URL    = ftp://sourceware.org/pub/libffi

$(ARCHIVE)/$(LIBFFI_SOURCE):
	$(DOWNLOAD) $(LIBFFI_URL)/$(LIBFFI_SOURCE)

LIBFFI_PATCH  = libffi-install_headers.patch

LIBFFI_CONF   = $(if $(filter $(BOXSERIES), hd1),--enable-static --disable-shared)

libffi: $(ARCHIVE)/$(LIBFFI_SOURCE) | $(TARGET_DIR)
	$(REMOVE)/$(LIBFFI_TMP)
	$(UNTAR)/$(LIBFFI_SOURCE)
	$(CHDIR)/$(LIBFFI_TMP); \
		$(call apply_patches, $(LIBFFI_PATCH)); \
		$(CONFIGURE) \
			--prefix= \
			--datarootdir=$(remove-datarootdir) \
			$(LIBFFI_CONF) \
			; \
		$(MAKE) all; \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
	$(REWRITE_PKGCONF)/libffi.pc
	$(REWRITE_LIBTOOL)/libffi.la
	$(REMOVE)/$(LIBFFI_TMP)
	$(TOUCH)

# -----------------------------------------------------------------------------

GLIB2_VER    = 2.56.3
GLIB2_TMP    = glib-$(GLIB2_VER)
GLIB2_SOURCE = glib-$(GLIB2_VER).tar.xz
GLIB2_URL    = https://ftp.gnome.org/pub/gnome/sources/glib/$(basename $(GLIB2_VER))

$(ARCHIVE)/$(GLIB2_SOURCE):
	$(DOWNLOAD) $(GLIB2_URL)/$(GLIB2_SOURCE)

GLIB2_PATCH  = glib2-disable-tests.patch
GLIB2_PATCH += glib2-automake.patch

GLIB2_DEPS   = zlib libffi
ifeq ($(BOXSERIES), hd2)
  GLIB2_DEPS += gettext
endif

GLIB2_CONF   = $(if $(filter $(BOXSERIES), hd1),--enable-static --disable-shared)
GLIB2_CONF  += $(if $(filter $(BOXSERIES), vusolo4k vuduo4k vuultimo4k vuuno4kse),--with-libiconv=gnu)

glib2: $(GLIB2_DEPS) $(ARCHIVE)/$(GLIB2_SOURCE) | $(TARGET_DIR)
	$(REMOVE)/$(GLIB2_TMP)
	$(UNTAR)/$(GLIB2_SOURCE)
	$(CHDIR)/$(GLIB2_TMP); \
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
			--datarootdir=$(remove-datarootdir) \
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
	rm -f $(addprefix $(TARGET_BIN_DIR)/,gapplication gdbus* gio* glib* gobject-query gresource gsettings gtester*)
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
	$(REMOVE)/$(GLIB2_TMP)
	$(TOUCH)

# -----------------------------------------------------------------------------

ALSA-LIB_VER    = 1.1.9
ALSA-LIB_TMP    = alsa-lib-$(ALSA-LIB_VER)
ALSA-LIB_SOURCE = alsa-lib-$(ALSA-LIB_VER).tar.bz2
ALSA-LIB_URL    = https://www.alsa-project.org/files/pub/lib

$(ARCHIVE)/$(ALSA-LIB_SOURCE):
	$(DOWNLOAD) $(ALSA-LIB_URL)/$(ALSA-LIB_SOURCE)

ALSA-LIB_PATCH  = alsa-lib.patch
ALSA-LIB_PATCH += alsa-lib-link_fix.patch

alsa-lib: $(ARCHIVE)/$(ALSA-LIB_SOURCE)
	$(REMOVE)/$(ALSA-LIB_TMP)
	$(UNTAR)/$(ALSA-LIB_SOURCE)
	$(CHDIR)/$(ALSA-LIB_TMP); \
		$(call apply_patches, $(ALSA-LIB_PATCH)); \
		$(CONFIGURE) \
			--prefix= \
			--datarootdir=$(remove-datarootdir) \
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
	$(REMOVE)/$(ALSA-LIB_TMP)
	$(TOUCH)

# -----------------------------------------------------------------------------

POPT_VER    = 1.16
POPT_TMP    = popt-$(POPT_VER)
POPT_SOURCE = popt-$(POPT_VER).tar.gz
POPT_URL    = ftp://anduin.linuxfromscratch.org/BLFS/popt

$(ARCHIVE)/$(POPT_SOURCE):
	$(DOWNLOAD) $(POPT_URL)/$(POPT_SOURCE)

popt: $(ARCHIVE)/$(POPT_SOURCE) | $(TARGET_DIR)
	$(REMOVE)/$(POPT_TMP)
	$(UNTAR)/$(POPT_SOURCE)
	$(CHDIR)/$(POPT_TMP); \
		$(CONFIGURE) \
			--prefix= \
			--datarootdir=$(remove-datarootdir) \
			; \
		$(MAKE); \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
	$(REWRITE_PKGCONF)/popt.pc
	$(REWRITE_LIBTOOL)/libpopt.la
	$(REMOVE)/$(POPT_TMP)
	$(TOUCH)

# -----------------------------------------------------------------------------

LIBICONV_VER    = 1.15
LIBICONV_TMP    = libiconv-$(LIBICONV_VER)
LIBICONV_SOURCE = libiconv-$(LIBICONV_VER).tar.gz
LIBICONV_URL    = https://ftp.gnu.org/gnu/libiconv

$(ARCHIVE)/$(LIBICONV_SOURCE):
	$(DOWNLOAD) $(LIBICONV_URL)/$(LIBICONV_SOURCE)

libiconv: $(ARCHIVE)/$(LIBICONV_SOURCE) | $(TARGET_DIR)
	$(REMOVE)/$(LIBICONV_TMP)
	$(UNTAR)/$(LIBICONV_SOURCE)
	$(CHDIR)/$(LIBICONV_TMP); \
		sed -i -e '/preload/d' Makefile.in; \
		$(CONFIGURE) CPPFLAGS="$(TARGET_CPPFLAGS) -fPIC" \
			--target=$(TARGET) \
			--prefix= \
			--datarootdir=$(remove-datarootdir) \
			--enable-static \
			--disable-shared \
			--enable-relocatable \
			; \
		$(MAKE); \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
	$(REWRITE_LIBTOOL)/libcharset.la
	$(REWRITE_LIBTOOL)/libiconv.la
	$(REMOVE)/$(LIBICONV_TMP)
	$(TOUCH)

# -----------------------------------------------------------------------------

LIBICONV-STRIPPED_VER    = 1.13.1
LIBICONV-STRIPPED_TMP    = libiconv-$(LIBICONV-STRIPPED_VER)
LIBICONV-STRIPPED_SOURCE = libiconv-$(LIBICONV-STRIPPED_VER).tar.gz
LIBICONV-STRIPPED_URL    = https://ftp.gnu.org/gnu/libiconv

$(ARCHIVE)/$(LIBICONV-STRIPPED_SOURCE):
	$(DOWNLOAD) $(LIBICONV-STRIPPED_URL)/$(LIBICONV-STRIPPED_SOURCE)

LIBICONV-STRIPPED_PATCH  = disable_transliterations.patch
LIBICONV-STRIPPED_PATCH += strip_charsets.patch

# builds only stripped down iconv binary used by smarthomeinfo plugin
iconv-bin: $(ARCHIVE)/$(LIBICONV-STRIPPED_SOURCE) | $(TARGET_DIR)
	$(REMOVE)/$(LIBICONV-STRIPPED_TMP)
	$(UNTAR)/$(LIBICONV-STRIPPED_SOURCE)
	$(CHDIR)/$(LIBICONV-STRIPPED_TMP); \
		$(call apply_patches, $(addprefix libiconv/,$(LIBICONV-STRIPPED_PATCH))); \
		sed -i -e '/preload/d' Makefile.in; \
		$(CONFIGURE) \
			--target=$(TARGET) \
			--prefix= \
			--datarootdir=$(remove-datarootdir) \
			--includedir=$(remove-includedir) \
			--libdir=$(remove-libdir) \
			--enable-static \
			--disable-shared \
			--enable-relocatable \
			; \
		$(MAKE); \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
	$(REMOVE)/$(LIBICONV-STRIPPED_TMP)
	$(TOUCH)

# -----------------------------------------------------------------------------

GRAPHLCD_VER    = git
GRAPHLCD_TMP    = graphlcd-base.$(GRAPHLCD_VER)
GRAPHLCD_SOURCE = graphlcd-base.$(GRAPHLCD_VER)
GRAPHLCD_URL    = git://projects.vdr-developer.org

GRAPHLCD_PATCH  = graphlcd.patch
ifeq ($(BOXMODEL), $(filter $(BOXMODEL), vuduo4k vusolo4k vuultimo4k vuuno4kse))
  GRAPHLCD_PATCH += graphlcd-vuplus.patch
endif

GRAPHLCD_DEPS   = freetype libiconv libusb

graphlcd: $(GRAPHLCD_DEPS) | $(TARGET_DIR)
	$(REMOVE)/$(GRAPHLCD_TMP)
	$(GET-GIT-SOURCE) $(GRAPHLCD_URL)/$(GRAPHLCD_SOURCE) $(ARCHIVE)/$(GRAPHLCD_SOURCE)
	$(CPDIR)/$(GRAPHLCD_TMP)
	$(CHDIR)/$(GRAPHLCD_TMP); \
		$(call apply_patches, $(addprefix $(@)/,$(GRAPHLCD_PATCH))); \
		$(MAKE) -C glcdgraphics all TARGET=$(TARGET_CROSS) PREFIX= DESTDIR=$(TARGET_DIR); \
		$(MAKE) -C glcddrivers all TARGET=$(TARGET_CROSS) PREFIX= DESTDIR=$(TARGET_DIR); \
		$(MAKE) -C glcdgraphics install PREFIX= DESTDIR=$(TARGET_DIR); \
		$(MAKE) -C glcddrivers install PREFIX= DESTDIR=$(TARGET_DIR); \
		cp -a graphlcd.conf $(TARGET_DIR)/etc
	$(REMOVE)/$(GRAPHLCD_TMP)
	$(TOUCH)
