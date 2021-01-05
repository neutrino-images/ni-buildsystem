#
# makefile to build system libs
#
# -----------------------------------------------------------------------------

ZLIB_VER    = 1.2.11
ZLIB_DIR    = zlib-$(ZLIB_VER)
ZLIB_SOURCE = zlib-$(ZLIB_VER).tar.xz
ZLIB_SITE   = https://sourceforge.net/projects/libpng/files/zlib/$(ZLIB_VER)

$(DL_DIR)/$(ZLIB_SOURCE):
	$(DOWNLOAD) $(ZLIB_SITE)/$(ZLIB_SOURCE)

ZLIB_PATCH  = zlib-ldflags-tests.patch
ZLIB_PATCH += zlib-remove.ldconfig.call.patch

zlib: $(DL_DIR)/$(ZLIB_SOURCE) | $(TARGET_DIR)
	$(REMOVE)/$(ZLIB_DIR)
	$(UNTAR)/$(ZLIB_SOURCE)
	$(CHDIR)/$(ZLIB_DIR); \
		$(call apply_patches,$(ZLIB_PATCH)); \
		$(MAKE_ENV) \
		mandir=$(REMOVE_mandir) \
		./configure \
			--prefix=$(prefix) \
			--shared \
			--uname=Linux \
			; \
		$(MAKE); \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
	$(REMOVE)/$(ZLIB_DIR)
	$(TOUCH)

# -----------------------------------------------------------------------------

LIBFUSE_VER    = 2.9.9
LIBFUSE_DIR    = fuse-$(LIBFUSE_VER)
LIBFUSE_SOURCE = fuse-$(LIBFUSE_VER).tar.gz
LIBFUSE_SITE   = https://github.com/libfuse/libfuse/releases/download/fuse-$(LIBFUSE_VER)

$(DL_DIR)/$(LIBFUSE_SOURCE):
	$(DOWNLOAD) $(LIBFUSE_SITE)/$(LIBFUSE_SOURCE)

libfuse: $(DL_DIR)/$(LIBFUSE_SOURCE) | $(TARGET_DIR)
	$(REMOVE)/$(LIBFUSE_DIR)
	$(UNTAR)/$(LIBFUSE_SOURCE)
	$(CHDIR)/$(LIBFUSE_DIR); \
		$(CONFIGURE) \
			--prefix=$(prefix) \
			--datarootdir=$(REMOVE_datarootdir) \
			--disable-static \
			--disable-example \
			--disable-mtab \
			--with-gnu-ld \
			--enable-util \
			--enable-lib \
			--enable-silent-rules \
			; \
		$(MAKE); \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
	$(REWRITE_LIBTOOL_LA)
	rm -rf $(TARGET_sysconfdir)/udev
	rm -rf $(TARGET_sysconfdir)/init.d/fuse
	$(REMOVE)/$(LIBFUSE_DIR)
	$(TOUCH)

# -----------------------------------------------------------------------------

LIBUPNP_VER    = 1.6.25
LIBUPNP_DIR    = libupnp-$(LIBUPNP_VER)
LIBUPNP_SOURCE = libupnp-$(LIBUPNP_VER).tar.bz2
LIBUPNP_SITE   = http://sourceforge.net/projects/pupnp/files/pupnp/libUPnP%20$(LIBUPNP_VER)

$(DL_DIR)/$(LIBUPNP_SOURCE):
	$(DOWNLOAD) $(LIBUPNP_SITE)/$(LIBUPNP_SOURCE)

libupnp: $(DL_DIR)/$(LIBUPNP_SOURCE) | $(TARGET_DIR)
	$(REMOVE)/$(LIBUPNP_DIR)
	$(UNTAR)/$(LIBUPNP_SOURCE)
	$(CHDIR)/$(LIBUPNP_DIR); \
		$(CONFIGURE) \
			--prefix=$(prefix) \
			--enable-shared \
			--disable-static \
			; \
		$(MAKE); \
		$(MAKE) install DESTDIR=$(TARGET_DIR); \
	$(REWRITE_LIBTOOL_LA)
	$(REMOVE)/$(LIBUPNP_DIR)
	$(TOUCH)
	
# -----------------------------------------------------------------------------

LIBDVBSI_VER    = git
LIBDVBSI_DIR    = libdvbsi.$(LIBDVBSI_VER)
LIBDVBSI_SOURCE = libdvbsi.$(LIBDVBSI_VER)
LIBDVBSI_SITE   = https://github.com/OpenVisionE2

LIBDVBSI_PATCH  = libdvbsi++-content_identifier_descriptor.patch

libdvbsi: | $(TARGET_DIR)
	$(REMOVE)/$(LIBDVBSI_DIR)
	$(GET-GIT-SOURCE) $(LIBDVBSI_SITE)/$(LIBDVBSI_SOURCE) $(DL_DIR)/$(LIBDVBSI_SOURCE)
	$(CPDIR)/$(LIBDVBSI_SOURCE)
	$(CHDIR)/$(LIBDVBSI_DIR); \
		$(call apply_patches,$(LIBDVBSI_PATCH)); \
		$(CONFIGURE) \
			--prefix=$(prefix) \
			--enable-shared \
			--enable-silent-rules \
			--disable-static \
			; \
		$(MAKE); \
		$(MAKE) install DESTDIR=$(TARGET_DIR); \
	$(REWRITE_LIBTOOL_LA)
	$(REMOVE)/$(LIBDVBSI_DIR)
	$(TOUCH)

# -----------------------------------------------------------------------------

GIFLIB_VER    = 5.2.1
GIFLIB_DIR    = giflib-$(GIFLIB_VER)
GIFLIB_SOURCE = giflib-$(GIFLIB_VER).tar.gz
GIFLIB_SITE   = https://sourceforge.net/projects/giflib/files

$(DL_DIR)/$(GIFLIB_SOURCE):
	$(DOWNLOAD) $(GIFLIB_SITE)/$(GIFLIB_SOURCE)

giflib: $(DL_DIR)/$(GIFLIB_SOURCE) | $(TARGET_DIR)
	$(REMOVE)/$(GIFLIB_DIR)
	$(UNTAR)/$(GIFLIB_SOURCE)
	$(CHDIR)/$(GIFLIB_DIR); \
		$(MAKE_ENV) \
		$(MAKE); \
		$(MAKE) install-include install-lib DESTDIR=$(TARGET_DIR) PREFIX=$(prefix)
	$(REMOVE)/$(GIFLIB_DIR)
	$(TOUCH)

# -----------------------------------------------------------------------------

LIBCURL_VER    = 7.74.0
LIBCURL_DIR    = curl-$(LIBCURL_VER)
LIBCURL_SOURCE = curl-$(LIBCURL_VER).tar.bz2
LIBCURL_SITE   = https://curl.haxx.se/download

$(DL_DIR)/$(LIBCURL_SOURCE):
	$(DOWNLOAD) $(LIBCURL_SITE)/$(LIBCURL_SOURCE)

LIBCURL_DEPS   = zlib openssl rtmpdump ca-bundle

LIBCURL_CONF   = $(if $(filter $(BOXSERIES),hd1),--disable-ipv6,--enable-ipv6)

libcurl: $(LIBCURL_DEPS) $(DL_DIR)/$(LIBCURL_SOURCE) | $(TARGET_DIR)
	$(REMOVE)/$(LIBCURL_DIR)
	$(UNTAR)/$(LIBCURL_SOURCE)
	$(CHDIR)/$(LIBCURL_DIR); \
		$(CONFIGURE) \
			--prefix=$(prefix) \
			--datarootdir=$(REMOVE_datarootdir) \
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
			--with-ssl=$(TARGET_prefix) \
			--with-librtmp=$(TARGET_libdir) \
			--enable-optimize \
			$(LIBCURL_CONF) \
			; \
		$(MAKE); \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
	mv $(TARGET_bindir)/curl-config $(HOST_DIR)/bin/
	$(REWRITE_CONFIG) $(HOST_DIR)/bin/curl-config
	rm -f $(TARGET_datadir)/zsh
	$(REWRITE_LIBTOOL_LA)
	$(REMOVE)/$(LIBCURL_DIR)
	$(TOUCH)

# -----------------------------------------------------------------------------

LIBPNG_VER    = 1.6.37
LIBPNG_DIR    = libpng-$(LIBPNG_VER)
LIBPNG_SOURCE = libpng-$(LIBPNG_VER).tar.xz
LIBPNG_SITE   = https://sourceforge.net/projects/libpng/files/libpng16/$(LIBPNG_VER)

$(DL_DIR)/$(LIBPNG_SOURCE):
	$(DOWNLOAD) $(LIBPNG_SITE)/$(LIBPNG_SOURCE)

LIBPNG_PATCH  = libpng-Disable-pngfix-and-png-fix-itxt.patch

LIBPNG_DEPS   = zlib

LIBPNG_CONF   = $(if $(filter $(BOXSERIES),hd5x hd6x vusolo4k vuduo4k vuduo4kse vuultimo4k vuzero4k vuuno4k vuuno4kse),--enable-arm-neon,--disable-arm-neon)

libpng: $(LIBPNG_DEPS) $(DL_DIR)/$(LIBPNG_SOURCE) | $(TARGET_DIR)
	$(REMOVE)/$(LIBPNG_DIR)
	$(UNTAR)/$(LIBPNG_SOURCE)
	$(CHDIR)/$(LIBPNG_DIR); \
		$(call apply_patches,$(LIBPNG_PATCH)); \
		$(CONFIGURE) \
			--prefix=$(prefix) \
			--mandir=$(REMOVE_mandir) \
			--enable-silent-rules \
			--disable-static \
			$(LIBPNG_CONF) \
			; \
		$(MAKE); \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
	mv $(TARGET_bindir)/libpng*-config $(HOST_DIR)/bin/
	$(REWRITE_CONFIG) $(HOST_DIR)/bin/libpng16-config
	$(REWRITE_LIBTOOL_LA)
	$(REMOVE)/$(LIBPNG_DIR)
	$(TOUCH)

# -----------------------------------------------------------------------------

FREETYPE_VER    = 2.10.4
FREETYPE_DIR    = freetype-$(FREETYPE_VER)
FREETYPE_SOURCE = freetype-$(FREETYPE_VER).tar.xz
FREETYPE_SITE   = https://sourceforge.net/projects/freetype/files/freetype2/$(FREETYPE_VER)

$(DL_DIR)/$(FREETYPE_SOURCE):
	$(DOWNLOAD) $(FREETYPE_SITE)/$(FREETYPE_SOURCE)

FREETYPE_PATCH  = freetype2-subpixel.patch
FREETYPE_PATCH += freetype2-config.patch
FREETYPE_PATCH += freetype2-pkgconf.patch

FREETYPE_DEPS   = zlib libpng

freetype: $(FREETYPE_DEPS) $(DL_DIR)/$(FREETYPE_SOURCE) | $(TARGET_DIR)
	$(REMOVE)/$(FREETYPE_DIR)
	$(UNTAR)/$(FREETYPE_SOURCE)
	$(CHDIR)/$(FREETYPE_DIR); \
		$(call apply_patches,$(FREETYPE_PATCH)); \
		$(SED) '/^FONT_MODULES += \(type1\|cid\|pfr\|type42\|pcf\|bdf\|winfonts\|cff\)/d' modules.cfg
	$(CHDIR)/$(FREETYPE_DIR)/builds/unix; \
		libtoolize --force --copy; \
		aclocal -I .; \
		autoconf
	$(CHDIR)/$(FREETYPE_DIR); \
		$(CONFIGURE) \
			--prefix=$(prefix) \
			--mandir=$(REMOVE_mandir) \
			--enable-shared \
			--disable-static \
			--enable-freetype-config \
			--with-png \
			--with-zlib \
			--without-harfbuzz \
			--without-bzip2 \
			; \
		$(MAKE); \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
	ln -sf freetype2 $(TARGET_includedir)/freetype
	mv $(TARGET_bindir)/freetype-config $(HOST_DIR)/bin
	$(REWRITE_CONFIG) $(HOST_DIR)/bin/freetype-config
	$(REWRITE_LIBTOOL_LA)
	$(REMOVE)/$(FREETYPE_DIR) \
		$(TARGET_datadir)/aclocal
	$(TOUCH)

# -----------------------------------------------------------------------------

LIBJPEG-TURBO_VER    = 2.0.6
LIBJPEG-TURBO_DIR    = libjpeg-turbo-$(LIBJPEG-TURBO_VER)
LIBJPEG-TURBO_SOURCE = libjpeg-turbo-$(LIBJPEG-TURBO_VER).tar.gz
LIBJPEG-TURBO_SITE   = https://sourceforge.net/projects/libjpeg-turbo/files/$(LIBJPEG-TURBO_VER)

$(DL_DIR)/$(LIBJPEG-TURBO_SOURCE):
	$(DOWNLOAD) $(LIBJPEG-TURBO_SITE)/$(LIBJPEG-TURBO_SOURCE)

LIBJPEG-TURBO_PATCH  = libjpeg-turbo-tiff-ojpeg.patch

libjpeg-turbo: $(DL_DIR)/$(LIBJPEG-TURBO_SOURCE) | $(TARGET_DIR)
	$(REMOVE)/$(LIBJPEG-TURBO_DIR)
	$(UNTAR)/$(LIBJPEG-TURBO_SOURCE)
	$(CHDIR)/$(LIBJPEG-TURBO_DIR); \
		$(call apply_patches,$(LIBJPEG-TURBO_PATCH)); \
		$(CMAKE) \
			-DWITH_SIMD=False \
			-DWITH_JPEG8=80 \
			; \
		$(MAKE); \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
	rm -f $(addprefix $(TARGET_bindir)/,cjpeg djpeg jpegtran rdjpgcom tjbench wrjpgcom)
	$(REMOVE)/$(LIBJPEG-TURBO_DIR)
	$(TOUCH)

# -----------------------------------------------------------------------------

OPENSSL_VER    = 1.0.2t
OPENSSL_DIR    = openssl-$(OPENSSL_VER)
OPENSSL_SOURCE = openssl-$(OPENSSL_VER).tar.gz
OPENSSL_SITE   = https://www.openssl.org/source

$(DL_DIR)/$(OPENSSL_SOURCE):
	$(DOWNLOAD) $(OPENSSL_SITE)/$(OPENSSL_SOURCE)

OPENSSL_PATCH  = 0000-Configure-align-O-flag.patch

ifeq ($(TARGET_ARCH),arm)
  OPENSSL_ARCH = linux-armv4
else ifeq ($(TARGET_ARCH),mips)
  OPENSSL_ARCH = linux-generic32
endif

openssl: $(DL_DIR)/$(OPENSSL_SOURCE) | $(TARGET_DIR)
	$(REMOVE)/$(OPENSSL_DIR)
	$(UNTAR)/$(OPENSSL_SOURCE)
	$(CHDIR)/$(OPENSSL_DIR); \
		$(call apply_patches,$(addprefix $(@F)/,$(OPENSSL_PATCH))); \
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
			--prefix=$(prefix)/ \
			--openssldir=/etc/ssl \
			; \
		$(SED) 's| build_tests||' Makefile; \
		$(SED) 's|^MANDIR=.*|MANDIR=$(REMOVE_mandir)|' Makefile; \
		$(SED) 's|^HTMLDIR=.*|HTMLDIR=$(REMOVE_htmldir)|' Makefile; \
		$(MAKE) depend; \
		$(MAKE); \
		$(MAKE) install_sw INSTALL_PREFIX=$(TARGET_DIR)
	rm -rf $(TARGET_libdir)/engines
	rm -f $(TARGET_bindir)/c_rehash
	rm -f $(TARGET_sysconfdir)/ssl/misc/{CA.pl,tsget}
ifeq ($(BOXSERIES),$(filter $(BOXSERIES),hd1 hd2))
	rm -f $(TARGET_bindir)/openssl
	rm -f $(TARGET_sysconfdir)/ssl/misc/{CA.*,c_*}
endif
	chmod 0755 $(TARGET_libdir)/lib{crypto,ssl}.so.*
	for version in 0.9.7 0.9.8 1.0.2; do \
		ln -sf libcrypto.so.1.0.0 $(TARGET_libdir)/libcrypto.so.$$version; \
		ln -sf libssl.so.1.0.0 $(TARGET_libdir)/libssl.so.$$version; \
	done
	$(REMOVE)/$(OPENSSL_DIR)
	$(TOUCH)

# -----------------------------------------------------------------------------

NCURSES_VER    = 6.1
NCURSES_DIR    = ncurses-$(NCURSES_VER)
NCURSES_SOURCE = ncurses-$(NCURSES_VER).tar.gz
NCURSES_SITE   = $(GNU_MIRROR)/ncurses

$(DL_DIR)/$(NCURSES_SOURCE):
	$(DOWNLOAD) $(NCURSES_SITE)/$(NCURSES_SOURCE)

NCURSES_PATCH  = ncurses-gcc-5.x-MKlib_gen.patch

ncurses: $(DL_DIR)/$(NCURSES_SOURCE) | $(TARGET_DIR)
	$(REMOVE)/$(NCURSES_DIR)
	$(UNTAR)/$(NCURSES_SOURCE)
	$(CHDIR)/$(NCURSES_DIR); \
		$(call apply_patches,$(NCURSES_PATCH)); \
		$(CONFIGURE) \
			--target=$(TARGET) \
			--prefix=$(prefix) \
			--enable-pc-files \
			--with-pkg-config \
			--with-pkg-config-libdir=$(libdir)/pkgconfig \
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
	rm -f $(addprefix $(TARGET_libdir)/,libform* libmenu* libpanel*)
	rm -f $(addprefix $(TARGET_libdir)/pkgconfig/,form.pc menu.pc panel.pc)
	rm -f $(HOST_DIR)/bin/ncurses*
	mv $(TARGET_bindir)/ncurses6-config $(HOST_DIR)/bin
	$(REWRITE_CONFIG) $(HOST_DIR)/bin/ncurses6-config
	$(REMOVE)/$(NCURSES_DIR)
	$(TOUCH)

# -----------------------------------------------------------------------------

openthreads: $(SOURCE_DIR)/$(NI-OPENTHREADS) | $(TARGET_DIR)
	$(REMOVE)/$(NI-OPENTHREADS)
	tar -C $(SOURCE_DIR) -cp $(NI-OPENTHREADS) --exclude-vcs | tar -C $(BUILD_DIR) -x
	$(CHDIR)/$(NI-OPENTHREADS)/; \
		$(CMAKE) \
			-DCMAKE_SUPPRESS_DEVELOPER_WARNINGS="1" \
			-D_OPENTHREADS_ATOMIC_USE_GCC_BUILTINS_EXITCODE="0" \
			; \
		$(MAKE); \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
	rm -f $(TARGET_libdir)/cmake
	$(REMOVE)/$(NI-OPENTHREADS)
	$(TOUCH)

# -----------------------------------------------------------------------------

LIBUSB_VER    = 1.0.23
LIBUSB_DIR    = libusb-$(LIBUSB_VER)
LIBUSB_SOURCE = libusb-$(LIBUSB_VER).tar.bz2
LIBUSB_SITE   = https://github.com/libusb/libusb/releases/download/v$(LIBUSB_VER)

$(DL_DIR)/$(LIBUSB_SOURCE):
	$(DOWNLOAD) $(LIBUSB_SITE)/$(LIBUSB_SOURCE)

libusb: $(DL_DIR)/$(LIBUSB_SOURCE) | $(TARGET_DIR)
	$(REMOVE)/$(LIBUSB_DIR)
	$(UNTAR)/$(LIBUSB_SOURCE)
	$(CHDIR)/$(LIBUSB_DIR); \
		$(CONFIGURE) \
			--prefix=$(prefix) \
			--disable-udev \
			; \
		$(MAKE); \
		$(MAKE) install DESTDIR=$(TARGET_DIR); \
	$(REWRITE_LIBTOOL_LA)
	$(REMOVE)/$(LIBUSB_DIR)
	$(TOUCH)

# -----------------------------------------------------------------------------

LIBUSB-COMPAT_VER    = 0.1.7
LIBUSB-COMPAT_DIR    = libusb-compat-$(LIBUSB-COMPAT_VER)
LIBUSB-COMPAT_SOURCE = libusb-compat-$(LIBUSB-COMPAT_VER).tar.bz2
LIBUSB-COMPAT_SITE   = https://github.com/libusb/libusb-compat-0.1/releases/download/v$(LIBUSB-COMPAT_VER)

$(DL_DIR)/$(LIBUSB-COMPAT_SOURCE):
	$(DOWNLOAD) $(LIBUSB-COMPAT_SITE)/$(LIBUSB-COMPAT_SOURCE)

LIBUSB-COMPAT_PATCH  = 0001-fix-a-build-issue-on-linux.patch

LUBUSB-COMPAT_DEPS   = libusb

libusb-compat: $(LUBUSB-COMPAT_DEPS) $(DL_DIR)/$(LIBUSB-COMPAT_SOURCE) | $(TARGET_DIR)
	$(REMOVE)/$(LIBUSB-COMPAT_DIR)
	$(UNTAR)/$(LIBUSB-COMPAT_SOURCE)
	$(CHDIR)/$(LIBUSB-COMPAT_DIR); \
		$(call apply_patches,$(addprefix $(@F)/,$(LIBUSB-COMPAT_PATCH))); \
		$(CONFIGURE) \
			--prefix=$(prefix) \
			; \
		$(MAKE); \
		$(MAKE) install DESTDIR=$(TARGET_DIR); \
	mv $(TARGET_bindir)/libusb-config $(HOST_DIR)/bin
	$(REWRITE_CONFIG) $(HOST_DIR)/bin/libusb-config
	$(REWRITE_LIBTOOL_LA)
	$(REMOVE)/$(LIBUSB-COMPAT_DIR)
	$(TOUCH)

# -----------------------------------------------------------------------------

LIBGD_VER    = 2.2.5
LIBGD_DIR    = libgd-$(LIBGD_VER)
LIBGD_SOURCE = libgd-$(LIBGD_VER).tar.xz
LIBGD_SITE   = https://github.com/libgd/libgd/releases/download/gd-$(LIBGD_VER)

$(DL_DIR)/$(LIBGD_SOURCE):
	$(DOWNLOAD) $(LIBGD_SITE)/$(LIBGD_SOURCE)

LIBGD_DEPS   = zlib libpng libjpeg-turbo freetype

libgd: $(LIBGD_DEPS) $(DL_DIR)/$(LIBGD_SOURCE) | $(TARGET_DIR)
	$(REMOVE)/$(LIBGD_DIR)
	$(UNTAR)/$(LIBGD_SOURCE)
	$(CHDIR)/$(LIBGD_DIR); \
		./bootstrap.sh; \
		$(CONFIGURE) \
			--prefix=$(prefix) \
			--bindir=$(REMOVE_bindir) \
			--without-fontconfig \
			--without-xpm \
			--without-x \
			; \
		$(MAKE); \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
	$(REWRITE_LIBTOOL_LA)
	$(REMOVE)/$(LIBGD_DIR)
	$(TOUCH)

# -----------------------------------------------------------------------------

LIBDPF_VER    = git
LIBDPF_DIR    = dpf-ax.$(LIBDPF_VER)
LIBDPF_SOURCE = dpf-ax.$(LIBDPF_VER)
LIBDPF_SITE   = $(GITHUB)/MaxWiesel

LIBDPF_PATCH  = libdpf-crossbuild.patch

LIBDPF_DEPS   = libusb-compat

libdpf: $(LIBDPF_DEPS) | $(TARGET_DIR)
	$(REMOVE)/$(LIBDPF_DIR)
	$(GET-GIT-SOURCE) $(LIBDPF_SITE)/$(LIBDPF_SOURCE) $(DL_DIR)/$(LIBDPF_SOURCE)
	$(CPDIR)/$(LIBDPF_SOURCE)
	$(CHDIR)/$(LIBDPF_DIR)/dpflib; \
		$(call apply_patches,$(LIBDPF_PATCH)); \
		make libdpf.a CC=$(TARGET_CC) PREFIX=$(TARGET_prefix); \
		mkdir -p $(TARGET_includedir)/libdpf; \
		cp dpf.h $(TARGET_includedir)/libdpf/libdpf.h; \
		cp ../include/spiflash.h $(TARGET_includedir)/libdpf/; \
		cp ../include/usbuser.h $(TARGET_includedir)/libdpf/; \
		cp libdpf.a $(TARGET_libdir)/
	$(REMOVE)/$(LIBDPF_DIR)
	$(TOUCH)

# -----------------------------------------------------------------------------

LZO_VER    = 2.10
LZO_DIR    = lzo-$(LZO_VER)
LZO_SOURCE = lzo-$(LZO_VER).tar.gz
LZO_SITE   = https://www.oberhumer.com/opensource/lzo/download

$(DL_DIR)/$(LZO_SOURCE):
	$(DOWNLOAD) $(LZO_SITE)/$(LZO_SOURCE)

lzo: $(DL_DIR)/$(LZO_SOURCE) | $(TARGET_DIR)
	$(REMOVE)/$(LZO_DIR)
	$(UNTAR)/$(LZO_SOURCE)
	$(CHDIR)/$(LZO_DIR); \
		$(CONFIGURE) \
			--mandir=$(REMOVE_mandir) \
			--docdir=$(REMOVE_docdir) \
			--prefix=$(prefix) \
			; \
		$(MAKE); \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
	$(REWRITE_LIBTOOL_LA)
	$(REMOVE)/$(LZO_DIR)
	$(TOUCH)

# -----------------------------------------------------------------------------

LIBSIGC_VER    = 2.10.3
LIBSIGC_DIR    = libsigc++-$(LIBSIGC_VER)
LIBSIGC_SOURCE = libsigc++-$(LIBSIGC_VER).tar.xz
LIBSIGC_SITE   = https://download.gnome.org/sources/libsigc++/$(basename $(LIBSIGC_VER))

$(DL_DIR)/$(LIBSIGC_SOURCE):
	$(DOWNLOAD) $(LIBSIGC_SITE)/$(LIBSIGC_SOURCE)

libsigc: $(DL_DIR)/$(LIBSIGC_SOURCE) | $(TARGET_DIR)
	$(REMOVE)/$(LIBSIGC_DIR)
	$(UNTAR)/$(LIBSIGC_SOURCE)
	$(CHDIR)/$(LIBSIGC_DIR); \
		$(CONFIGURE) \
			--prefix=$(prefix) \
			--disable-documentation \
			--enable-silent-rules \
			; \
		$(MAKE); \
		$(MAKE) install DESTDIR=$(TARGET_DIR); \
		cp sigc++config.h $(TARGET_includedir)
	ln -sf ./sigc++-2.0/sigc++ $(TARGET_includedir)/sigc++
	$(REWRITE_LIBTOOL_LA)
	$(REMOVE)/$(LIBSIGC_DIR)
	$(TOUCH)

# -----------------------------------------------------------------------------

EXPAT_VER    = 2.2.9
EXPAT_DIR    = expat-$(EXPAT_VER)
EXPAT_SOURCE = expat-$(EXPAT_VER).tar.bz2
EXPAT_SITE   = https://sourceforge.net/projects/expat/files/expat/$(EXPAT_VER)

$(DL_DIR)/$(EXPAT_SOURCE):
	$(DOWNLOAD) $(EXPAT_SITE)/$(EXPAT_SOURCE)

EXPAT_PATCH  = expat-libtool-tag.patch

expat: $(DL_DIR)/$(EXPAT_SOURCE) | $(TARGET_DIR)
	$(REMOVE)/$(EXPAT_DIR)
	$(UNTAR)/$(EXPAT_SOURCE)
	$(CHDIR)/$(EXPAT_DIR); \
		$(call apply_patches,$(EXPAT_PATCH)); \
		autoreconf -fi; \
		$(CONFIGURE) \
			--prefix=$(prefix) \
			--docdir=$(REMOVE_docdir) \
			--mandir=$(REMOVE_mandir) \
			--enable-shared \
			--disable-static \
			--without-xmlwf \
			; \
		$(MAKE); \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
	$(REWRITE_LIBTOOL_LA)
	$(REMOVE)/$(EXPAT_DIR)
	$(TOUCH)

# -----------------------------------------------------------------------------

LIBBLURAY_VER    = 0.9.3
LIBBLURAY_DIR    = libbluray-$(LIBBLURAY_VER)
LIBBLURAY_SOURCE = libbluray-$(LIBBLURAY_VER).tar.bz2
LIBBLURAY_SITE   = ftp.videolan.org/pub/videolan/libbluray/$(LIBBLURAY_VER)

$(DL_DIR)/$(LIBBLURAY_SOURCE):
	$(DOWNLOAD) $(LIBBLURAY_SITE)/$(LIBBLURAY_SOURCE)

LIBBLURAY_PATCH  = libbluray.patch

LIBBLURAY_DEPS   = freetype
ifeq ($(BOXSERIES),hd2)
  LIBBLURAY_DEPS += libaacs libbdplus
endif

libbluray: $(LIBBLURAY_DEPS) $(DL_DIR)/$(LIBBLURAY_SOURCE) | $(TARGET_DIR)
	$(REMOVE)/$(LIBBLURAY_DIR)
	$(UNTAR)/$(LIBBLURAY_SOURCE)
	$(CHDIR)/$(LIBBLURAY_DIR); \
		$(call apply_patches,$(LIBBLURAY_PATCH)); \
		./bootstrap; \
		$(CONFIGURE) \
			--prefix=$(prefix) \
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
	$(REWRITE_LIBTOOL_LA)
	$(REMOVE)/$(LIBBLURAY_DIR)
	$(TOUCH)

# -----------------------------------------------------------------------------

LIBASS_VER    = 0.14.0
LIBASS_DIR    = libass-$(LIBASS_VER)
LIBASS_SOURCE = libass-$(LIBASS_VER).tar.xz
LIBASS_SITE   = https://github.com/libass/libass/releases/download/$(LIBASS_VER)

$(DL_DIR)/$(LIBASS_SOURCE):
	$(DOWNLOAD) $(LIBASS_SITE)/$(LIBASS_SOURCE)

LIBASS_PATCH  = libass.patch

LIBASS_DEPS   = freetype fribidi

libass: $(LIBASS_DEPS) $(DL_DIR)/$(LIBASS_SOURCE) | $(TARGET_DIR)
	$(REMOVE)/$(LIBASS_DIR)
	$(UNTAR)/$(LIBASS_SOURCE)
	$(CHDIR)/$(LIBASS_DIR); \
		$(call apply_patches,$(LIBASS_PATCH)); \
		$(CONFIGURE) \
			--target=$(TARGET) \
			--prefix=$(prefix) \
			--disable-static \
			--disable-test \
			--disable-fontconfig \
			--disable-harfbuzz \
			--disable-require-system-font-provider \
			; \
		$(MAKE); \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
	$(REWRITE_LIBTOOL_LA)
	$(REMOVE)/$(LIBASS_DIR)
	$(TOUCH)
	
# -----------------------------------------------------------------------------

LIBGPG-ERROR_VER    = 1.37
LIBGPG-ERROR_DIR    = libgpg-error-$(LIBGPG-ERROR_VER)
LIBGPG-ERROR_SOURCE = libgpg-error-$(LIBGPG-ERROR_VER).tar.bz2
LIBGPG-ERROR_SITE   = ftp://ftp.gnupg.org/gcrypt/libgpg-error

$(DL_DIR)/$(LIBGPG-ERROR_SOURCE):
	$(DOWNLOAD) $(LIBGPG-ERROR_SITE)/$(LIBGPG-ERROR_SOURCE)

libgpg-error: $(DL_DIR)/$(LIBGPG-ERROR_SOURCE) | $(TARGET_DIR)
	$(REMOVE)/$(LIBGPG-ERROR_DIR)
	$(UNTAR)/$(LIBGPG-ERROR_SOURCE)
	$(CHDIR)/$(LIBGPG-ERROR_DIR); \
		pushd src/syscfg; \
			ln -s lock-obj-pub.arm-unknown-linux-gnueabi.h lock-obj-pub.$(TARGET).h; \
			ln -s lock-obj-pub.arm-unknown-linux-gnueabi.h lock-obj-pub.linux-uclibcgnueabi.h; \
		popd; \
		$(CONFIGURE) \
			--prefix=$(prefix) \
			--datarootdir=$(REMOVE_datarootdir) \
			--enable-maintainer-mode \
			--enable-shared \
			--disable-doc \
			--disable-languages \
			--disable-static \
			--disable-tests \
			; \
		$(MAKE); \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
	mv $(TARGET_bindir)/gpg-error-config $(HOST_DIR)/bin
	$(REWRITE_CONFIG) $(HOST_DIR)/bin/gpg-error-config
	$(REWRITE_LIBTOOL_LA)
	rm -f $(addprefix $(TARGET_bindir)/,gpg-error gpgrt-config)
	$(REMOVE)/$(LIBGPG-ERROR_DIR)
	$(TOUCH)

# -----------------------------------------------------------------------------

LIBGCRYPT_VER    = 1.8.5
LIBGCRYPT_DIR    = libgcrypt-$(LIBGCRYPT_VER)
LIBGCRYPT_SOURCE = libgcrypt-$(LIBGCRYPT_VER).tar.gz
LIBGCRYPT_SITE   = ftp://ftp.gnupg.org/gcrypt/libgcrypt

$(DL_DIR)/$(LIBGCRYPT_SOURCE):
	$(DOWNLOAD) $(LIBGCRYPT_SITE)/$(LIBGCRYPT_SOURCE)

LIBGCRYPT_DEPS   = libgpg-error

libgcrypt: $(LIBGCRYPT_DEPS) $(DL_DIR)/$(LIBGCRYPT_SOURCE) | $(TARGET_DIR)
	$(REMOVE)/$(LIBGCRYPT_DIR)
	$(UNTAR)/$(LIBGCRYPT_SOURCE)
	$(CHDIR)/$(LIBGCRYPT_DIR); \
		$(CONFIGURE) \
			--prefix=$(prefix) \
			--datarootdir=$(REMOVE_datarootdir) \
			--enable-maintainer-mode \
			--enable-silent-rules \
			--enable-shared \
			--disable-static \
			--disable-tests \
			; \
		$(MAKE); \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
	mv $(TARGET_bindir)/libgcrypt-config $(HOST_DIR)/bin
	$(REWRITE_CONFIG) $(HOST_DIR)/bin/libgcrypt-config
	$(REWRITE_LIBTOOL_LA)
	rm -rf $(TARGET_bindir)/dumpsexp
	rm -rf $(TARGET_bindir)/hmac256
	rm -rf $(TARGET_bindir)/mpicalc
	$(REMOVE)/$(LIBGCRYPT_DIR)
	$(TOUCH)

# -----------------------------------------------------------------------------

LIBAACS_VER    = 0.9.0
LIBAACS_DIR    = libaacs-$(LIBAACS_VER)
LIBAACS_SOURCE = libaacs-$(LIBAACS_VER).tar.bz2
LIBAACS_SITE   = ftp://ftp.videolan.org/pub/videolan/libaacs/$(LIBAACS_VER)

$(DL_DIR)/$(LIBAACS_SOURCE):
	$(DOWNLOAD) $(LIBAACS_SITE)/$(LIBAACS_SOURCE)

LIBAACS_DEPS   = libgcrypt

libaacs: $(LIBAACS_DEPS) $(DL_DIR)/$(LIBAACS_SOURCE) | $(TARGET_DIR)
	$(REMOVE)/$(LIBAACS_DIR)
	$(UNTAR)/$(LIBAACS_SOURCE)
	$(CHDIR)/$(LIBAACS_DIR); \
		./bootstrap; \
		$(CONFIGURE) \
			--prefix=$(prefix) \
			--enable-maintainer-mode \
			--enable-silent-rules \
			--enable-shared \
			--disable-static \
			; \
		$(MAKE); \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
	$(REWRITE_LIBTOOL_LA)
	$(CD) $(TARGET_DIR); \
		mkdir -p .config/aacs .cache/aacs/vuk
	cp $(TARGET_FILES)/libaacs/KEYDB.cfg $(TARGET_DIR)/.config/aacs
	$(REMOVE)/$(LIBAACS_DIR)
	$(TOUCH)

# -----------------------------------------------------------------------------

LIBBDPLUS_VER    = 0.1.2
LIBBDPLUS_DIR    = libbdplus-$(LIBBDPLUS_VER)
LIBBDPLUS_SOURCE = libbdplus-$(LIBBDPLUS_VER).tar.bz2
LIBBDPLUS_SITE   = ftp://ftp.videolan.org/pub/videolan/libbdplus/$(LIBBDPLUS_VER)

$(DL_DIR)/$(LIBBDPLUS_SOURCE):
	$(DOWNLOAD) $(LIBBDPLUS_SITE)/$(LIBBDPLUS_SOURCE)

LIBBDPLUS_DEPS   = libaacs

libbdplus: $(LIBBDPLUS_DEPS) $(DL_DIR)/$(LIBBDPLUS_SOURCE) | $(TARGET_DIR)
	$(REMOVE)/$(LIBBDPLUS_DIR)
	$(UNTAR)/$(LIBBDPLUS_SOURCE)
	$(CHDIR)/$(LIBBDPLUS_DIR); \
		./bootstrap; \
		$(CONFIGURE) \
			--prefix=$(prefix) \
			--enable-maintainer-mode \
			--enable-silent-rules \
			--enable-shared \
			--disable-static \
			; \
		$(MAKE); \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
	$(REWRITE_LIBTOOL_LA)
	$(CD) $(TARGET_DIR); \
		mkdir -p .config/bdplus/vm0
	cp -f $(TARGET_FILES)/libbdplus/* $(TARGET_DIR)/.config/bdplus/vm0
	$(REMOVE)/$(LIBBDPLUS_DIR)
	$(TOUCH)

# -----------------------------------------------------------------------------

LIBXML2_VER    = 2.9.10
LIBXML2_DIR    = libxml2-$(LIBXML2_VER)
LIBXML2_SOURCE = libxml2-$(LIBXML2_VER).tar.gz
LIBXML2_SITE   = http://xmlsoft.org/sources

$(DL_DIR)/$(LIBXML2_SOURCE):
	$(DOWNLOAD) $(LIBXML2_SITE)/$(LIBXML2_SOURCE)

libxml2: $(DL_DIR)/$(LIBXML2_SOURCE) | $(TARGET_DIR)
	$(REMOVE)/$(LIBXML2_DIR)
	$(UNTAR)/$(LIBXML2_SOURCE)
	$(CHDIR)/$(LIBXML2_DIR); \
		$(APPLY_PATCHES); \
		$(CONFIGURE) \
			--prefix=$(prefix) \
			--enable-shared \
			--disable-static \
			--datarootdir=$(REMOVE_datarootdir) \
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
	mv $(TARGET_bindir)/xml2-config $(HOST_DIR)/bin
	$(REWRITE_CONFIG) $(HOST_DIR)/bin/xml2-config
	$(REWRITE_LIBTOOL_LA)
	rm -rf $(TARGET_libdir)/xml2Conf.sh
	rm -rf $(TARGET_libdir)/cmake
	$(REMOVE)/$(LIBXML2_DIR)
	$(TOUCH)

# -----------------------------------------------------------------------------

PUGIXML_VER    = 1.11.1
PUGIXML_DIR    = pugixml-$(PUGIXML_VER)
PUGIXML_SOURCE = pugixml-$(PUGIXML_VER).tar.gz
PUGIXML_SITE   = https://github.com/zeux/pugixml/releases/download/v$(PUGIXML_VER)

$(DL_DIR)/$(PUGIXML_SOURCE):
	$(DOWNLOAD) $(PUGIXML_SITE)/$(PUGIXML_SOURCE)

PUGIXML_PATCH  = pugixml-config.patch

pugixml: $(DL_DIR)/$(PUGIXML_SOURCE) | $(TARGET_DIR)
	$(REMOVE)/$(PUGIXML_DIR)
	$(UNTAR)/$(PUGIXML_SOURCE)
	$(CHDIR)/$(PUGIXML_DIR); \
		$(call apply_patches,$(PUGIXML_PATCH)); \
		$(CMAKE); \
		$(MAKE); \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
	-rm -r $(TARGET_libdir)/cmake
	$(REMOVE)/$(PUGIXML_DIR)
	$(TOUCH)

# -----------------------------------------------------------------------------

LIBROXML_VER    = 3.0.2
LIBROXML_DIR    = libroxml-$(LIBROXML_VER)
LIBROXML_SOURCE = libroxml-$(LIBROXML_VER).tar.gz
LIBROXML_SITE   = http://download.libroxml.net/pool/v3.x

$(DL_DIR)/$(LIBROXML_SOURCE):
	$(DOWNLOAD) $(LIBROXML_SITE)/$(LIBROXML_SOURCE)

libroxml: $(DL_DIR)/$(LIBROXML_SOURCE) | $(TARGET_DIR)
	$(REMOVE)/$(LIBROXML_DIR)
	$(UNTAR)/$(LIBROXML_SOURCE)
	$(CHDIR)/$(LIBROXML_DIR); \
		$(CONFIGURE) \
			--prefix=$(prefix) \
			--disable-roxml \
			; \
		$(MAKE); \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
	$(REWRITE_LIBTOOL_LA)
	$(REMOVE)/$(LIBROXML_DIR)
	$(TOUCH)

# -----------------------------------------------------------------------------

RTMPDUMP_DEPS   = zlib openssl

RTMPDUMP_MAKE_OPTS = \
	prefix= \
	mandir=$(REMOVE_mandir)

rtmpdump: $(RTMPDUMP_DEPS) $(SOURCE_DIR)/$(NI-RTMPDUMP) | $(TARGET_DIR)
	$(REMOVE)/$(NI-RTMPDUMP)
	tar -C $(SOURCE_DIR) -cp $(NI-RTMPDUMP) --exclude-vcs | tar -C $(BUILD_DIR) -x
	$(CHDIR)/$(NI-RTMPDUMP); \
		$(MAKE) $(RTMPDUMP_MAKE_OPTS) CROSS_COMPILE=$(TARGET_CROSS) XCFLAGS="$(TARGET_CFLAGS)" XLDFLAGS="$(TARGET_LDFLAGS)"; \
		$(MAKE) $(RTMPDUMP_MAKE_OPTS) install prefix=$(prefix) DESTDIR=$(TARGET_DIR)
	rm -rf $(TARGET_DIR)/sbin/rtmpgw
	rm -rf $(TARGET_DIR)/sbin/rtmpsrv
	rm -rf $(TARGET_DIR)/sbin/rtmpsuck
	$(REMOVE)/$(NI-RTMPDUMP)
	$(TOUCH)

# -----------------------------------------------------------------------------

LIBTIRPC_VER    = 1.2.6
LIBTIRPC_DIR    = libtirpc-$(LIBTIRPC_VER)
LIBTIRPC_SOURCE = libtirpc-$(LIBTIRPC_VER).tar.bz2
LIBTIRPC_SITE   = https://sourceforge.net/projects/libtirpc/files/libtirpc/$(LIBTIRPC_VER)

$(DL_DIR)/$(LIBTIRPC_SOURCE):
	$(DOWNLOAD) $(LIBTIRPC_SITE)/$(LIBTIRPC_SOURCE)

LIBTIRP_PATCH  = 0001-Disable-parts-of-TIRPC-requiring-NIS-support.patch
LIBTIRP_PATCH += 0003-Automatically-generate-XDR-header-files-from-.x-sour.patch
LIBTIRP_PATCH += 0004-Add-more-XDR-files-needed-to-build-rpcbind-on-top-of.patch

libtirpc: $(DL_DIR)/$(LIBTIRPC_SOURCE) | $(TARGET_DIR)
	$(REMOVE)/$(LIBTIRPC_DIR)
	$(UNTAR)/$(LIBTIRPC_SOURCE)
	$(CHDIR)/$(LIBTIRPC_DIR); \
		$(call apply_patches,$(addprefix $(@F)/,$(LIBTIRP_PATCH))); \
		autoreconf -fi; \
		$(CONFIGURE) \
			--target=$(TARGET) \
			--prefix=$(prefix) \
			--sysconfdir=$(sysconfdir) \
			--disable-gssapi \
			--enable-silent-rules \
			--mandir=$(REMOVE_mandir) \
			; \
		$(MAKE); \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
	$(REWRITE_LIBTOOL_LA)
ifeq ($(BOXSERIES),hd1)
	$(SED) '/^\(udp\|tcp\)6/ d' $(TARGET_sysconfdir)/netconfig
endif
	$(REMOVE)/$(LIBTIRPC_DIR)
	$(TOUCH)

# -----------------------------------------------------------------------------

CONFUSE_VER    = 3.2.2
CONFUSE_DIR    = confuse-$(CONFUSE_VER)
CONFUSE_SOURCE = confuse-$(CONFUSE_VER).tar.xz
CONFUSE_SITE   = https://github.com/martinh/libconfuse/releases/download/v$(CONFUSE_VER)

$(DL_DIR)/$(CONFUSE_SOURCE):
	$(DOWNLOAD) $(CONFUSE_SITE)/$(CONFUSE_SOURCE)

confuse: $(DL_DIR)/$(CONFUSE_SOURCE) | $(TARGET_DIR)
	$(REMOVE)/$(CONFUSE_DIR)
	$(UNTAR)/$(CONFUSE_SOURCE)
	$(CHDIR)/$(CONFUSE_DIR); \
		$(CONFIGURE) \
			--prefix=$(prefix) \
			--docdir=$(REMOVE_docdir) \
			--mandir=$(REMOVE_mandir) \
			--enable-silent-rules \
			--enable-static \
			--disable-shared \
			; \
		$(MAKE); \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
	$(REMOVE)/$(CONFUSE_DIR)
	$(TOUCH)

# -----------------------------------------------------------------------------

LIBITE_VER    = 2.0.2
LIBITE_DIR    = libite-$(LIBITE_VER)
LIBITE_SOURCE = libite-$(LIBITE_VER).tar.xz
LIBITE_SITE   = https://github.com/troglobit/libite/releases/download/v$(LIBITE_VER)

$(DL_DIR)/$(LIBITE_SOURCE):
	$(DOWNLOAD) $(LIBITE_SITE)/$(LIBITE_SOURCE)

libite: $(DL_DIR)/$(LIBITE_SOURCE) | $(TARGET_DIR)
	$(REMOVE)/$(LIBITE_DIR)
	$(UNTAR)/$(LIBITE_SOURCE)
	$(CHDIR)/$(LIBITE_DIR); \
		$(CONFIGURE) \
			--prefix=$(prefix) \
			--docdir=$(REMOVE_docdir) \
			--mandir=$(REMOVE_docdir) \
			--enable-silent-rules \
			--enable-static \
			--disable-shared \
			; \
		$(MAKE); \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
	$(REMOVE)/$(LIBITE_DIR)
	$(TOUCH)

# -----------------------------------------------------------------------------

LIBMAD_VER    = 0.15.1b
LIBMAD_DIR    = libmad-$(LIBMAD_VER)
LIBMAD_SOURCE = libmad-$(LIBMAD_VER).tar.gz
LIBMAD_SITE   = https://sourceforge.net/projects/mad/files/libmad/$(LIBMAD_VER)

$(DL_DIR)/$(LIBMAD_SOURCE):
	$(DOWNLOAD) $(LIBMAD_SITE)/$(LIBMAD_SOURCE)

LIBMAD_PATCH  = libmad-pc.patch
LIBMAD_PATCH += libmad-frame_length.diff
LIBMAD_PATCH += libmad-mips-h-constraint-removal.patch
LIBMAD_PATCH += libmad-remove-deprecated-cflags.patch
LIBMAD_PATCH += libmad-thumb2-fixed-arm.patch
LIBMAD_PATCH += libmad-thumb2-imdct-arm.patch

libmad: $(DL_DIR)/$(LIBMAD_SOURCE) | $(TARGET_DIR)
	$(REMOVE)/$(LIBMAD_DIR)
	$(UNTAR)/$(LIBMAD_SOURCE)
	$(CHDIR)/$(LIBMAD_DIR); \
		$(call apply_patches,$(LIBMAD_PATCH)); \
		autoreconf -fi; \
		$(CONFIGURE) \
			--prefix=$(prefix) \
			--enable-shared=yes \
			--enable-accuracy \
			--enable-fpm=arm \
			--enable-sso \
			; \
		$(MAKE); \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
	$(REWRITE_LIBTOOL_LA)
	$(REMOVE)/$(LIBMAD_DIR)
	$(TOUCH)

# -----------------------------------------------------------------------------

LIBVORBIS_VER    = 1.3.7
LIBVORBIS_DIR    = libvorbis-$(LIBVORBIS_VER)
LIBVORBIS_SOURCE = libvorbis-$(LIBVORBIS_VER).tar.xz
LIBVORBIS_SITE   = https://downloads.xiph.org/releases/vorbis

$(DL_DIR)/$(LIBVORBIS_SOURCE):
	$(DOWNLOAD) $(LIBVORBIS_SITE)/$(LIBVORBIS_SOURCE)

LIBVORBIS_DEPS   = libogg

libvorbis: $(LIBVORBIS_DEPS) $(DL_DIR)/$(LIBVORBIS_SOURCE) | $(TARGET_DIR)
	$(REMOVE)/$(LIBVORBIS_DIR)
	$(UNTAR)/$(LIBVORBIS_SOURCE)
	$(CHDIR)/$(LIBVORBIS_DIR); \
		$(CONFIGURE) \
			--prefix=$(prefix) \
			--datarootdir=$(REMOVE_datarootdir) \
			; \
		$(MAKE); \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
	$(REWRITE_LIBTOOL_LA)
	$(REMOVE)/$(LIBVORBIS_DIR)
	$(TOUCH)


# -----------------------------------------------------------------------------

LIBVORBISIDEC_VER    = 1.2.1+git20180316
LIBVORBISIDEC_DIR    = libvorbisidec-$(LIBVORBISIDEC_VER)
LIBVORBISIDEC_SOURCE = libvorbisidec_$(LIBVORBISIDEC_VER).orig.tar.gz
LIBVORBISIDEC_SITE   = https://ftp.de.debian.org/debian/pool/main/libv/libvorbisidec

$(DL_DIR)/$(LIBVORBISIDEC_SOURCE):
	$(DOWNLOAD) $(LIBVORBISIDEC_SITE)/$(LIBVORBISIDEC_SOURCE)

LIBVORBISIDEC_DEPS   = libogg

libvorbisidec: $(LIBVORBISIDEC_DEPS) $(DL_DIR)/$(LIBVORBISIDEC_SOURCE) | $(TARGET_DIR)
	$(REMOVE)/$(LIBVORBISIDEC_DIR)
	$(UNTAR)/$(LIBVORBISIDEC_SOURCE)
	$(CHDIR)/$(LIBVORBISIDEC_DIR); \
		$(SED) '122 s/^/#/' configure.in; \
		autoreconf -fi; \
		$(CONFIGURE) \
			--prefix=$(prefix) \
			; \
		$(MAKE); \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
	$(REWRITE_LIBTOOL_LA)
	$(REMOVE)/$(LIBVORBISIDEC_DIR)
	$(TOUCH)

# -----------------------------------------------------------------------------

LIBOGG_VER    = 1.3.4
LIBOGG_DIR    = libogg-$(LIBOGG_VER)
LIBOGG_SOURCE = libogg-$(LIBOGG_VER).tar.gz
LIBOGG_SITE   = http://downloads.xiph.org/releases/ogg

$(DL_DIR)/$(LIBOGG_SOURCE):
	$(DOWNLOAD) $(LIBOGG_SITE)/$(LIBOGG_SOURCE)

libogg: $(DL_DIR)/$(LIBOGG_SOURCE) | $(TARGET_DIR)
	$(REMOVE)/$(LIBOGG_DIR)
	$(UNTAR)/$(LIBOGG_SOURCE)
	$(CHDIR)/$(LIBOGG_DIR); \
		$(CONFIGURE) \
			--prefix=$(prefix) \
			--datarootdir=$(REMOVE_datarootdir) \
			--enable-shared \
			; \
		$(MAKE); \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
	$(REWRITE_LIBTOOL_LA)
	$(REMOVE)/$(LIBOGG_DIR)
	$(TOUCH)

# -----------------------------------------------------------------------------

LIBEXIF_VER    = 0.6.22
LIBEXIF_DIR    = libexif-$(LIBEXIF_VER)
LIBEXIF_SOURCE = libexif-$(LIBEXIF_VER).tar.xz
LIBEXIF_SITE   = https://github.com/libexif/libexif/releases/download/libexif-$(subst .,_,$(LIBEXIF_VER))-release

$(DL_DIR)/$(LIBEXIF_SOURCE):
	$(DOWNLOAD) $(LIBEXIF_SITE)/$(LIBEXIF_SOURCE)

libexif: $(DL_DIR)/$(LIBEXIF_SOURCE) | $(TARGET_DIR)
	$(REMOVE)/$(LIBEXIF_DIR)
	$(UNTAR)/$(LIBEXIF_SOURCE)
	$(CHDIR)/$(LIBEXIF_DIR); \
		$(APPLY_PATCHES); \
		$(CONFIGURE) \
			--prefix=$(prefix) \
			--datarootdir=$(REMOVE_datarootdir) \
			--with-doc-dir=$(REMOVE_docdir) \
			; \
		$(MAKE); \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
	$(REWRITE_LIBTOOL_LA)
	$(REMOVE)/$(LIBEXIF_DIR)
	$(TOUCH)

# -----------------------------------------------------------------------------

FRIBIDI_VER    = 1.0.10
FRIBIDI_DIR    = fribidi-$(FRIBIDI_VER)
FRIBIDI_SOURCE = fribidi-$(FRIBIDI_VER).tar.xz
FRIBIDI_SITE   = https://github.com/fribidi/fribidi/releases/download/v$(FRIBIDI_VER)

$(DL_DIR)/$(FRIBIDI_SOURCE):
	$(DOWNLOAD) $(FRIBIDI_SITE)/$(FRIBIDI_SOURCE)

fribidi: $(DL_DIR)/$(FRIBIDI_SOURCE) | $(TARGET_DIR)
	$(REMOVE)/$(FRIBIDI_DIR)
	$(UNTAR)/$(FRIBIDI_SOURCE)
	$(CHDIR)/$(FRIBIDI_DIR); \
		$(CONFIGURE) \
			--prefix=$(prefix) \
			--mandir=$(REMOVE_mandir) \
			--disable-debug \
			--disable-deprecated \
			; \
		$(MAKE); \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
	$(REWRITE_LIBTOOL_LA)
	$(REMOVE)/$(FRIBIDI_DIR)
	$(TOUCH)

# -----------------------------------------------------------------------------

LIBFFI_VER    = 3.3
LIBFFI_DIR    = libffi-$(LIBFFI_VER)
LIBFFI_SOURCE = libffi-$(LIBFFI_VER).tar.gz
LIBFFI_SITE   = https://github.com/libffi/libffi/releases/download/v$(HOST_LIBFFI_VER)

$(DL_DIR)/$(LIBFFI_SOURCE):
	$(DOWNLOAD) $(LIBFFI_SITE)/$(LIBFFI_SOURCE)

LIBFFI_CONF   = $(if $(filter $(BOXSERIES),hd1),--enable-static --disable-shared)

libffi: $(DL_DIR)/$(LIBFFI_SOURCE) | $(TARGET_DIR)
	$(REMOVE)/$(LIBFFI_DIR)
	$(UNTAR)/$(LIBFFI_SOURCE)
	$(CHDIR)/$(LIBFFI_DIR); \
		$(APPLY_PATCHES); \
		autoreconf -fi; \
		$(CONFIGURE) \
			--prefix=$(prefix) \
			--datarootdir=$(REMOVE_datarootdir) \
			$(LIBFFI_CONF) \
			; \
		$(MAKE); \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
	$(REWRITE_LIBTOOL_LA)
	$(REMOVE)/$(LIBFFI_DIR)
	$(TOUCH)

# -----------------------------------------------------------------------------

GLIB2_VER    = 2.56.3
GLIB2_DIR    = glib-$(GLIB2_VER)
GLIB2_SOURCE = glib-$(GLIB2_VER).tar.xz
GLIB2_SITE   = https://ftp.gnome.org/pub/gnome/sources/glib/$(basename $(GLIB2_VER))

$(DL_DIR)/$(GLIB2_SOURCE):
	$(DOWNLOAD) $(GLIB2_SITE)/$(GLIB2_SOURCE)

GLIB2_PATCH  = glib2-disable-tests.patch
GLIB2_PATCH += glib2-automake.patch

GLIB2_DEPS   = zlib libffi
ifeq ($(BOXSERIES),hd2)
  GLIB2_DEPS += gettext
endif

GLIB2_CONF   = $(if $(filter $(BOXSERIES),hd1),--enable-static --disable-shared)

ifeq ($(BOXTYPE),$(filter $(BOXTYPE),armbox mipsbox))
  GLIB2_DEPS += libiconv
  GLIB2_CONF += --with-libiconv=gnu
endif

glib2: $(GLIB2_DEPS) $(DL_DIR)/$(GLIB2_SOURCE) | $(TARGET_DIR)
	$(REMOVE)/$(GLIB2_DIR)
	$(UNTAR)/$(GLIB2_SOURCE)
	$(CHDIR)/$(GLIB2_DIR); \
		$(call apply_patches,$(GLIB2_PATCH)); \
		echo "ac_cv_type_long_long=yes"		 > arm-linux.cache; \
		echo "glib_cv_stack_grows=no"		>> arm-linux.cache; \
		echo "glib_cv_uscore=no"		>> arm-linux.cache; \
		echo "glib_cv_va_copy=no"		>> arm-linux.cache; \
		echo "glib_cv_va_val_copy=yes"		>> arm-linux.cache; \
		echo "ac_cv_func_posix_getpwuid_r=yes"	>> arm-linux.cache; \
		echo "ac_cv_func_posix_getgrgid_r=yes"	>> arm-linux.cache; \
		autoreconf -fi; \
		$(CONFIGURE) \
			--prefix=$(prefix) \
			--datarootdir=$(REMOVE_datarootdir) \
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
	rm -f $(addprefix $(TARGET_bindir)/,gapplication gdbus* gio* glib* gobject-query gresource gsettings gtester*)
	$(REWRITE_LIBTOOL_LA)
	$(REMOVE)/$(GLIB2_DIR)
	$(TOUCH)

# -----------------------------------------------------------------------------

ALSA-LIB_VER    = 1.2.4
ALSA-LIB_DIR    = alsa-lib-$(ALSA-LIB_VER)
ALSA-LIB_SOURCE = alsa-lib-$(ALSA-LIB_VER).tar.bz2
ALSA-LIB_SITE   = https://www.alsa-project.org/files/pub/lib

$(DL_DIR)/$(ALSA-LIB_SOURCE):
	$(DOWNLOAD) $(ALSA-LIB_SITE)/$(ALSA-LIB_SOURCE)

alsa-lib: $(DL_DIR)/$(ALSA-LIB_SOURCE)
	$(REMOVE)/$(ALSA-LIB_DIR)
	$(UNTAR)/$(ALSA-LIB_SOURCE)
	$(CHDIR)/$(ALSA-LIB_DIR); \
		$(APPLY_PATCHES); \
		autoreconf -fi; \
		$(CONFIGURE) \
			--prefix=$(prefix) \
			--datarootdir=$(REMOVE_datarootdir) \
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
			--disable-topology \
			; \
		$(MAKE); \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
	$(REWRITE_LIBTOOL_LA)
	$(REMOVE)/$(ALSA-LIB_DIR)
	$(TOUCH)

# -----------------------------------------------------------------------------

POPT_VER    = 1.16
POPT_DIR    = popt-$(POPT_VER)
POPT_SOURCE = popt-$(POPT_VER).tar.gz
POPT_SITE   = ftp://anduin.linuxfromscratch.org/BLFS/popt

$(DL_DIR)/$(POPT_SOURCE):
	$(DOWNLOAD) $(POPT_SITE)/$(POPT_SOURCE)

popt: $(DL_DIR)/$(POPT_SOURCE) | $(TARGET_DIR)
	$(REMOVE)/$(POPT_DIR)
	$(UNTAR)/$(POPT_SOURCE)
	$(CHDIR)/$(POPT_DIR); \
		$(CONFIGURE) \
			--prefix=$(prefix) \
			--datarootdir=$(REMOVE_datarootdir) \
			; \
		$(MAKE); \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
	$(REWRITE_LIBTOOL_LA)
	$(REMOVE)/$(POPT_DIR)
	$(TOUCH)

# -----------------------------------------------------------------------------

LIBICONV_VER    = 1.15
LIBICONV_DIR    = libiconv-$(LIBICONV_VER)
LIBICONV_SOURCE = libiconv-$(LIBICONV_VER).tar.gz
LIBICONV_SITE   = $(GNU_MIRROR)/libiconv

$(DL_DIR)/$(LIBICONV_SOURCE):
	$(DOWNLOAD) $(LIBICONV_SITE)/$(LIBICONV_SOURCE)

libiconv: $(DL_DIR)/$(LIBICONV_SOURCE) | $(TARGET_DIR)
	$(REMOVE)/$(LIBICONV_DIR)
	$(UNTAR)/$(LIBICONV_SOURCE)
	$(CHDIR)/$(LIBICONV_DIR); \
		$(SED) '/preload/d' Makefile.in; \
		$(CONFIGURE) CPPFLAGS="$(TARGET_CPPFLAGS) -fPIC" \
			--target=$(TARGET) \
			--prefix=$(prefix) \
			--datarootdir=$(REMOVE_datarootdir) \
			--enable-static \
			--disable-shared \
			--enable-relocatable \
			; \
		$(MAKE); \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
	$(REWRITE_LIBTOOL_LA)
	$(REMOVE)/$(LIBICONV_DIR)
	$(TOUCH)

# -----------------------------------------------------------------------------

GRAPHLCD_BASE_VER    = git
GRAPHLCD_BASE_DIR    = graphlcd-base.$(GRAPHLCD_BASE_VER)
GRAPHLCD_BASE_SOURCE = graphlcd-base.$(GRAPHLCD_BASE_VER)
GRAPHLCD_BASE_SITE   = git://projects.vdr-developer.org

GRAPHLCD_BASE_PATCH  = graphlcd.patch
GRAPHLCD_BASE_PATCH += 0003-strip-graphlcd-conf.patch
GRAPHLCD_BASE_PATCH += 0004-material-colors.patch
ifeq ($(BOXMODEL),$(filter $(BOXMODEL),vuduo4k vuduo4kse vusolo4k vuultimo4k vuuno4kse))
  GRAPHLCD_BASE_PATCH += 0005-add-vuplus-driver.patch
endif

GRAPHLCD_BASE_DEPS   = freetype libiconv libusb

graphlcd-base: $(GRAPHLCD_BASE_DEPS) | $(TARGET_DIR)
	$(REMOVE)/$(GRAPHLCD_BASE_DIR)
	$(GET-GIT-SOURCE) $(GRAPHLCD_BASE_SITE)/$(GRAPHLCD_BASE_SOURCE) $(DL_DIR)/$(GRAPHLCD_BASE_SOURCE)
	$(CPDIR)/$(GRAPHLCD_BASE_DIR)
	$(CHDIR)/$(GRAPHLCD_BASE_DIR); \
		$(call apply_patches,$(addprefix $(@)/,$(GRAPHLCD_BASE_PATCH))); \
		$(MAKE_ENV) \
		$(MAKE); \
		$(MAKE) install DESTDIR=$(TARGET_DIR) PREFIX=$(prefix)
	-rm -r $(TARGET_sysconfdir)/udev
	$(REMOVE)/$(GRAPHLCD_BASE_DIR)
	$(TOUCH)
