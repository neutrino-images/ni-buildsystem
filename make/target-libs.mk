#
# makefile to build system libs
#
# -----------------------------------------------------------------------------

ZLIB_VERSION = 1.2.11
ZLIB_DIR = zlib-$(ZLIB_VERSION)
ZLIB_SOURCE = zlib-$(ZLIB_VERSION).tar.xz
ZLIB_SITE = https://sourceforge.net/projects/libpng/files/zlib/$(ZLIB_VERSION)

$(DL_DIR)/$(ZLIB_SOURCE):
	$(download) $(ZLIB_SITE)/$(ZLIB_SOURCE)

ZLIB_CONF_ENV = \
	mandir=$(REMOVE_mandir)

ZLIB_CONF_OPTS = \
	--prefix=$(prefix) \
	--shared \
	--uname=Linux

zlib: $(DL_DIR)/$(ZLIB_SOURCE) | $(TARGET_DIR)
	$(REMOVE)/$(PKG_DIR)
	$(UNTAR)/$(PKG_SOURCE)
	$(CHDIR)/$(PKG_DIR); \
		$(APPLY_PATCHES); \
		$(TARGET_CONFIGURE_ENV) \
		./configure $($(PKG)_CONF_OPTS); \
		$(MAKE); \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
	$(REMOVE)/$(PKG_DIR)
	$(TOUCH)

# -----------------------------------------------------------------------------

LIBFUSE_VERSION = 2.9.9
LIBFUSE_DIR = fuse-$(LIBFUSE_VERSION)
LIBFUSE_SOURCE = fuse-$(LIBFUSE_VERSION).tar.gz
LIBFUSE_SITE = https://github.com/libfuse/libfuse/releases/download/fuse-$(LIBFUSE_VERSION)

LIBFUSE_CONF_OPTS = \
	--datarootdir=$(REMOVE_datarootdir) \
	--disable-static \
	--disable-example \
	--disable-mtab \
	--with-gnu-ld \
	--enable-util \
	--enable-lib \
	--enable-silent-rules

libfuse: | $(TARGET_DIR)
	$(call autotools-package)
	-rm -r $(TARGET_sysconfdir)/udev
	-rm $(TARGET_sysconfdir)/init.d/fuse

# -----------------------------------------------------------------------------

LIBUPNP_VERSION = 1.6.25
LIBUPNP_DIR = libupnp-$(LIBUPNP_VERSION)
LIBUPNP_SOURCE = libupnp-$(LIBUPNP_VERSION).tar.bz2
LIBUPNP_SITE = http://sourceforge.net/projects/pupnp/files/pupnp/libUPnP%20$(LIBUPNP_VERSION)

LIBUPNP_CONV_OPTS = \
	--enable-shared \
	--disable-static

libupnp: | $(TARGET_DIR)
	$(call autotools-package)
	
# -----------------------------------------------------------------------------

LIBDVBSI_VERSION = 0.3.9
LIBDVBSI_DIR = libdvbsi++-$(LIBDVBSI_VERSION)
LIBDVBSI_SOURCE = libdvbsi++-$(LIBDVBSI_VERSION).tar.bz2
LIBDVBSI_SITE = https://github.com/mtdcr/libdvbsi/releases/download/$(LIBDVBSI_VERSION)

LIBDVBSI_CONV_OPTS = \
	--enable-silent-rules \
	--enable-shared \
	--disable-static

libdvbsi: | $(TARGET_DIR)
	$(call autotools-package)

# -----------------------------------------------------------------------------

LIBDVBCSA_VERSION = git
LIBDVBCSA_DIR = libdvbcsa.$(LIBDVBCSA_VERSION)
LIBDVBCSA_SOURCE = libdvbcsa.$(LIBDVBCSA_VERSION)
LIBDVBCSA_SITE = https://code.videolan.org/videolan

LIBDVBCSA_AUTORECONF = YES

libdvbcsa: | $(TARGET_DIR)
	$(REMOVE)/$(PKG_DIR)
	$(GET_GIT_SOURCE) $(PKG_SITE)/$(PKG_SOURCE) $(DL_DIR)/$(PKG_SOURCE)
	$(CPDIR)/$(PKG_SOURCE)
	$(CHDIR)/$(PKG_DIR); \
		$(CONFIGURE); \
		$(MAKE); \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
	$(REWRITE_LIBTOOL)
	$(REMOVE)/$(PKG_DIR)
	$(TOUCH)

# -----------------------------------------------------------------------------

GIFLIB_VERSION = 5.2.1
GIFLIB_DIR = giflib-$(GIFLIB_VERSION)
GIFLIB_SOURCE = giflib-$(GIFLIB_VERSION).tar.gz
GIFLIB_SITE = https://sourceforge.net/projects/giflib/files

$(DL_DIR)/$(GIFLIB_SOURCE):
	$(download) $(GIFLIB_SITE)/$(GIFLIB_SOURCE)

giflib: $(DL_DIR)/$(GIFLIB_SOURCE) | $(TARGET_DIR)
	$(REMOVE)/$(PKG_DIR)
	$(UNTAR)/$(PKG_SOURCE)
	$(CHDIR)/$(PKG_DIR); \
		$(TARGET_CONFIGURE_ENV) \
		$(MAKE); \
		$(MAKE) install-include install-lib DESTDIR=$(TARGET_DIR) PREFIX=$(prefix)
	$(REMOVE)/$(PKG_DIR)
	$(TOUCH)

# -----------------------------------------------------------------------------

LIBCURL_VERSION = 7.74.0
LIBCURL_DIR = curl-$(LIBCURL_VERSION)
LIBCURL_SOURCE = curl-$(LIBCURL_VERSION).tar.bz2
LIBCURL_SITE = https://curl.haxx.se/download

LIBCURL_DEPENDENCIES = zlib openssl rtmpdump ca-bundle

LIBCURL_CONFIG_SCRIPTS = curl-config

LIBCURL_CONF_OPTS = \
	--datarootdir=$(REMOVE_datarootdir) \
	$(if $(filter $(BOXSERIES),hd1),--disable-ipv6,--enable-ipv6) \
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
	--with-ca-bundle=$(CA_BUNDLE_DIR)/$(CA_BUNDLE_CRT) \
	--with-random=/dev/urandom \
	--with-ssl=$(TARGET_prefix) \
	--with-librtmp=$(TARGET_libdir) \
	--enable-optimize

libcurl: | $(TARGET_DIR)
	$(call autotools-package)

# -----------------------------------------------------------------------------

LIBPNG_VERSION = 1.6.37
LIBPNG_DIR = libpng-$(LIBPNG_VERSION)
LIBPNG_SOURCE = libpng-$(LIBPNG_VERSION).tar.xz
LIBPNG_SITE = https://sourceforge.net/projects/libpng/files/libpng16/$(LIBPNG_VERSION)

LIBPNG_DEPENDENCIES = zlib

LIBPNG_CONFIG_SCRIPTS = libpng16-config

LIBPNG_CONF_OPTS = \
	--enable-silent-rules \
	--disable-static \
	$(if $(filter $(BOXSERIES),hd5x hd6x vusolo4k vuduo4k vuduo4kse vuultimo4k vuzero4k vuuno4k vuuno4kse),--enable-arm-neon,--disable-arm-neon)

libpng: | $(TARGET_DIR)
	$(call autotools-package)
	-rm $(addprefix $(TARGET_bindir)/,libpng-config)

# -----------------------------------------------------------------------------

FREETYPE_VERSION = 2.10.4
FREETYPE_DIR = freetype-$(FREETYPE_VERSION)
FREETYPE_SOURCE = freetype-$(FREETYPE_VERSION).tar.xz
FREETYPE_SITE = https://sourceforge.net/projects/freetype/files/freetype2/$(FREETYPE_VERSION)

$(DL_DIR)/$(FREETYPE_SOURCE):
	$(download) $(FREETYPE_SITE)/$(FREETYPE_SOURCE)

FREETYPE_DEPENDENCIES = zlib libpng

FREETYPE_CONFIG_SCRIPTS = freetype-config

FREETYPE_CONF_OPTS = \
	--enable-shared \
	--disable-static \
	--enable-freetype-config \
	--with-png \
	--with-zlib \
	--without-harfbuzz \
	--without-bzip2

freetype: $(FREETYPE_DEPENDENCIES) $(DL_DIR)/$(FREETYPE_SOURCE) | $(TARGET_DIR)
	$(REMOVE)/$(PKG_DIR)
	$(UNTAR)/$(PKG_SOURCE)
	$(CHDIR)/$(PKG_DIR); \
		$(APPLY_PATCHES); \
		$(SED) '/^FONT_MODULES += \(type1\|cid\|pfr\|type42\|pcf\|bdf\|winfonts\|cff\)/d' modules.cfg
	$(CHDIR)/$(PKG_DIR)/builds/unix; \
		libtoolize --force --copy; \
		aclocal -I .; \
		autoconf
	$(CHDIR)/$(PKG_DIR); \
		$(CONFIGURE); \
		$(MAKE); \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
	ln -sf freetype2 $(TARGET_includedir)/freetype
	$(REWRITE_CONFIG_SCRIPTS)
	$(REWRITE_LIBTOOL)
	$(REMOVE)/$(PKG_DIR) \
		$(TARGET_datadir)/aclocal
	$(TOUCH)

# -----------------------------------------------------------------------------

LIBJPEG_TURBO_VERSION = 2.0.6
LIBJPEG_TURBO_DIR = libjpeg-turbo-$(LIBJPEG_TURBO_VERSION)
LIBJPEG_TURBO_SOURCE = libjpeg-turbo-$(LIBJPEG_TURBO_VERSION).tar.gz
LIBJPEG_TURBO_SITE = https://sourceforge.net/projects/libjpeg-turbo/files/$(LIBJPEG_TURBO_VERSION)

$(DL_DIR)/$(LIBJPEG_TURBO_SOURCE):
	$(download) $(LIBJPEG_TURBO_SITE)/$(LIBJPEG_TURBO_SOURCE)

LIBJPEG_TURBO_CONF_OPTS = \
	-DWITH_SIMD=False \
	-DWITH_JPEG8=80

libjpeg-turbo: $(DL_DIR)/$(LIBJPEG_TURBO_SOURCE) | $(TARGET_DIR)
	$(call cmake-package)
	-rm $(addprefix $(TARGET_bindir)/,cjpeg djpeg jpegtran rdjpgcom tjbench wrjpgcom)

# -----------------------------------------------------------------------------

OPENSSL_VERSION = 1.0.2t
OPENSSL_DIR = openssl-$(OPENSSL_VERSION)
OPENSSL_SOURCE = openssl-$(OPENSSL_VERSION).tar.gz
OPENSSL_SITE = https://www.openssl.org/source

$(DL_DIR)/$(OPENSSL_SOURCE):
	$(download) $(OPENSSL_SITE)/$(OPENSSL_SOURCE)

ifeq ($(TARGET_ARCH),arm)
  OPENSSL_TARGET_ARCH = linux-armv4
else ifeq ($(TARGET_ARCH),mips)
  OPENSSL_TARGET_ARCH = linux-generic32
endif

OPENSSL_CONV_OPTS = \
	--cross-compile-prefix=$(TARGET_CROSS) \
	--prefix=$(prefix) \
	--openssldir=$(sysconfdir)/ssl

OPENSSL_CONV_OPTS += \
	$(OPENSSL_TARGET_ARCH) \
	shared \
	threads \
	no-hw \
	no-engine \
	no-sse2 \
	no-perlasm \
	no-tests \
	no-fuzz-afl \
	no-fuzz-libfuzzer

OPENSSL_CONV_OPTS += \
	-DTERMIOS -fomit-frame-pointer \
	-DOPENSSL_SMALL_FOOTPRINT \
	$(TARGET_CFLAGS) \
	$(TARGET_LDFLAGS) \

openssl: $(DL_DIR)/$(OPENSSL_SOURCE) | $(TARGET_DIR)
	$(REMOVE)/$(PKG_DIR)
	$(UNTAR)/$(PKG_SOURCE)
	$(CHDIR)/$(PKG_DIR); \
		$(APPLY_PATCHES); \
		./Configure \
			$($(PKG)_CONV_OPTS); \
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
	$(REMOVE)/$(PKG_DIR)
	$(TOUCH)

# -----------------------------------------------------------------------------

NCURSES_VERSION = 6.1
NCURSES_DIR = ncurses-$(NCURSES_VERSION)
NCURSES_SOURCE = ncurses-$(NCURSES_VERSION).tar.gz
NCURSES_SITE = $(GNU_MIRROR)/ncurses

$(DL_DIR)/$(NCURSES_SOURCE):
	$(download) $(NCURSES_SITE)/$(NCURSES_SOURCE)

NCURSES_CONFIG_SCRIPTS = ncurses6-config

NCURSES_CONF_OPTS = \
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
	--without-cxx-binding

ncurses: $(DL_DIR)/$(NCURSES_SOURCE) | $(TARGET_DIR)
	$(REMOVE)/$(PKG_DIR)
	$(UNTAR)/$(PKG_SOURCE)
	$(CHDIR)/$(PKG_DIR); \
		$(APPLY_PATCHES); \
		$(CONFIGURE); \
		$(MAKE) libs; \
		$(MAKE) install.libs DESTDIR=$(TARGET_DIR)
	-rm $(addprefix $(TARGET_libdir)/,libform* libmenu* libpanel*)
	-rm $(addprefix $(TARGET_libdir)/pkgconfig/,form.pc menu.pc panel.pc)
	$(REWRITE_CONFIG_SCRIPTS)
	$(REMOVE)/$(PKG_DIR)
	$(TOUCH)

# -----------------------------------------------------------------------------

OPENTHREADS_CONF_OPTS = \
	-DCMAKE_SUPPRESS_DEVELOPER_WARNINGS="1" \
	-D_OPENTHREADS_ATOMIC_USE_GCC_BUILTINS_EXITCODE="0" \
	-D_OPENTHREADS_ATOMIC_USE_GCC_BUILTINS_EXITCODE__TRYRUN_OUTPUT="1"

openthreads: $(SOURCE_DIR)/$(NI_OPENTHREADS) | $(TARGET_DIR)
	$(REMOVE)/$(NI_OPENTHREADS)
	tar -C $(SOURCE_DIR) -cp $(NI_OPENTHREADS) --exclude-vcs | tar -C $(BUILD_DIR) -x
	$(CHDIR)/$(NI_OPENTHREADS)/; \
		$(CMAKE); \
		$(MAKE); \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
	$(REMOVE)/$(NI_OPENTHREADS)
	$(TOUCH)

# -----------------------------------------------------------------------------

LIBUSB_VERSION = 1.0.23
LIBUSB_DIR = libusb-$(LIBUSB_VERSION)
LIBUSB_SOURCE = libusb-$(LIBUSB_VERSION).tar.bz2
LIBUSB_SITE = https://github.com/libusb/libusb/releases/download/v$(LIBUSB_VERSION)

LIBUSB_CONF_OPTS = \
	--disable-udev

libusb: | $(TARGET_DIR)
	$(call autotools-package)

# -----------------------------------------------------------------------------

LIBUSB_COMPAT_VERSION = 0.1.7
LIBUSB_COMPAT_DIR = libusb-compat-$(LIBUSB_COMPAT_VERSION)
LIBUSB_COMPAT_SOURCE = libusb-compat-$(LIBUSB_COMPAT_VERSION).tar.bz2
LIBUSB_COMPAT_SITE = https://github.com/libusb/libusb-compat-0.1/releases/download/v$(LIBUSB_COMPAT_VERSION)

LIBUSB_COMPAT_CONFIG_SCRIPTS = libusb-config

LIBUSB_COMPAT_DEPENDENCIES = libusb

libusb-compat: | $(TARGET_DIR)
	$(call autotools-package)

# -----------------------------------------------------------------------------

LIBGD_VERSION = 2.2.5
LIBGD_DIR = libgd-$(LIBGD_VERSION)
LIBGD_SOURCE = libgd-$(LIBGD_VERSION).tar.xz
LIBGD_SITE = https://github.com/libgd/libgd/releases/download/gd-$(LIBGD_VERSION)

LIBGD_DEPENDENCIES = zlib libpng libjpeg-turbo freetype

LIBGD_CONF_OPTS = \
	--bindir=$(REMOVE_bindir) \
	--without-fontconfig \
	--without-xpm \
	--without-x

libgd: | $(TARGET_DIR)
	$(call autotools-package)

# -----------------------------------------------------------------------------

LIBDPF_VERSION = git
LIBDPF_DIR = dpf-ax.$(LIBDPF_VERSION)
LIBDPF_SOURCE = dpf-ax.$(LIBDPF_VERSION)
LIBDPF_SITE = $(GITHUB)/MaxWiesel

LIBDPF_DEPENDENCIES = libusb-compat

LIBDPF_MAKE_OPTS = \
	CC=$(TARGET_CC) PREFIX=$(TARGET_prefix)

libdpf: $(LIBDPF_DEPENDENCIES) | $(TARGET_DIR)
	$(REMOVE)/$(PKG_DIR)
	$(GET_GIT_SOURCE) $(PKG_SITE)/$(PKG_SOURCE) $(DL_DIR)/$(PKG_SOURCE)
	$(CPDIR)/$(PKG_SOURCE)
	$(CHDIR)/$(PKG_DIR); \
		$(APPLY_PATCHES); \
		$(MAKE1) -C dpflib libdpf.a $($(PKG)_MAKE_OPTS)
	$(INSTALL_DATA) -D $(PKG_BUILD_DIR)/dpflib/libdpf.a $(TARGET_libdir)/libdpf.a
	$(INSTALL_DATA) -D $(PKG_BUILD_DIR)/dpflib/dpf.h $(TARGET_includedir)/libdpf/libdpf.h
	$(INSTALL_DATA) -D $(PKG_BUILD_DIR)/include/spiflash.h $(TARGET_includedir)/libdpf/spiflash.h
	$(INSTALL_DATA) -D $(PKG_BUILD_DIR)/include/usbuser.h $(TARGET_includedir)/libdpf/usbuser.h
	$(REMOVE)/$(PKG_DIR)
	$(TOUCH)

# -----------------------------------------------------------------------------

LZO_VERSION = 2.10
LZO_DIR = lzo-$(LZO_VERSION)
LZO_SOURCE = lzo-$(LZO_VERSION).tar.gz
LZO_SITE = https://www.oberhumer.com/opensource/lzo/download

LZO_CONF_OPTS = \
	--docdir=$(REMOVE_docdir)

lzo: | $(TARGET_DIR)
	$(call autotools-package)

# -----------------------------------------------------------------------------

LIBSIGC_VERSION = 2.10.3
LIBSIGC_DIR = libsigc++-$(LIBSIGC_VERSION)
LIBSIGC_SOURCE = libsigc++-$(LIBSIGC_VERSION).tar.xz
LIBSIGC_SITE = https://download.gnome.org/sources/libsigc++/$(basename $(LIBSIGC_VERSION))

$(DL_DIR)/$(LIBSIGC_SOURCE):
	$(download) $(LIBSIGC_SITE)/$(LIBSIGC_SOURCE)

LIBSIGC_CONF_OPTS = \
	--disable-benchmark \
	--disable-documentation \
	--disable-warnings \
	--without-boost

libsigc: $(DL_DIR)/$(LIBSIGC_SOURCE) | $(TARGET_DIR)
	$(REMOVE)/$(PKG_DIR)
	$(UNTAR)/$(PKG_SOURCE)
	$(CHDIR)/$(PKG_DIR); \
		$(CONFIGURE); \
		$(MAKE); \
		$(MAKE) install DESTDIR=$(TARGET_DIR); \
		cp sigc++config.h $(TARGET_includedir)
	ln -sf ./sigc++-2.0/sigc++ $(TARGET_includedir)/sigc++
	$(REWRITE_LIBTOOL)
	$(REMOVE)/$(PKG_DIR)
	$(TOUCH)

# -----------------------------------------------------------------------------

EXPAT_VERSION = 2.2.9
EXPAT_DIR = expat-$(EXPAT_VERSION)
EXPAT_SOURCE = expat-$(EXPAT_VERSION).tar.bz2
EXPAT_SITE = https://sourceforge.net/projects/expat/files/expat/$(EXPAT_VERSION)

EXPAT_AUTORECONF = YES

EXPAT_CONF_OPTS = \
	--docdir=$(REMOVE_docdir) \
	--without-xmlwf \
	--without-docbook

expat: | $(TARGET_DIR)
	$(call autotools-package)

# -----------------------------------------------------------------------------

LIBBLURAY_VERSION = 0.9.3
LIBBLURAY_DIR = libbluray-$(LIBBLURAY_VERSION)
LIBBLURAY_SOURCE = libbluray-$(LIBBLURAY_VERSION).tar.bz2
LIBBLURAY_SITE = ftp.videolan.org/pub/videolan/libbluray/$(LIBBLURAY_VERSION)

$(DL_DIR)/$(LIBBLURAY_SOURCE):
	$(download) $(LIBBLURAY_SITE)/$(LIBBLURAY_SOURCE)

LIBBLURAY_DEPENDENCIES = freetype
ifeq ($(BOXSERIES),hd2)
  LIBBLURAY_DEPENDENCIES += libaacs libbdplus
endif

LIBBLURAY_CONF_OPTS = \
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
	--without-fontconfig

libbluray: $(LIBBLURAY_DEPENDENCIES) $(DL_DIR)/$(LIBBLURAY_SOURCE) | $(TARGET_DIR)
	$(REMOVE)/$(PKG_DIR)
	$(UNTAR)/$(PKG_SOURCE)
	$(CHDIR)/$(PKG_DIR); \
		$(APPLY_PATCHES); \
		./bootstrap; \
		$(CONFIGURE); \
		$(MAKE); \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
	$(REWRITE_LIBTOOL)
	$(REMOVE)/$(PKG_DIR)
	$(TOUCH)

# -----------------------------------------------------------------------------

LIBASS_VERSION = 0.14.0
LIBASS_DIR = libass-$(LIBASS_VERSION)
LIBASS_SOURCE = libass-$(LIBASS_VERSION).tar.xz
LIBASS_SITE = https://github.com/libass/libass/releases/download/$(LIBASS_VERSION)

LIBASS_DEPENDENCIES = freetype fribidi

LIBASS_CONF_OPTS = \
	--disable-static \
	--disable-test \
	--disable-fontconfig \
	--disable-harfbuzz \
	--disable-require-system-font-provider

libass: | $(TARGET_DIR)
	$(call autotools-package)
	
# -----------------------------------------------------------------------------

LIBGPG_ERROR_VERSION = 1.37
LIBGPG_ERROR_DIR = libgpg-error-$(LIBGPG_ERROR_VERSION)
LIBGPG_ERROR_SOURCE = libgpg-error-$(LIBGPG_ERROR_VERSION).tar.bz2
LIBGPG_ERROR_SITE = ftp://ftp.gnupg.org/gcrypt/libgpg-error

$(DL_DIR)/$(LIBGPG_ERROR_SOURCE):
	$(download) $(LIBGPG_ERROR_SITE)/$(LIBGPG_ERROR_SOURCE)

LIBGPG_ERROR_AUTORECONF = YES

LIBGPG_ERROR_CONFIG_SCRIPTS = gpg-error-config

LIBGPG_ERROR_CONF_OPTS = \
	--datarootdir=$(REMOVE_datarootdir) \
	--enable-maintainer-mode \
	--enable-shared \
	--disable-doc \
	--disable-languages \
	--disable-static \
	--disable-tests

libgpg-error: $(DL_DIR)/$(LIBGPG_ERROR_SOURCE) | $(TARGET_DIR)
	$(REMOVE)/$(PKG_DIR)
	$(UNTAR)/$(PKG_SOURCE)
	$(CHDIR)/$(PKG_DIR); \
		pushd src/syscfg; \
			ln -s lock-obj-pub.arm-unknown-linux-gnueabi.h lock-obj-pub.$(TARGET).h; \
			ln -s lock-obj-pub.arm-unknown-linux-gnueabi.h lock-obj-pub.linux-uclibcgnueabi.h; \
		popd; \
		$(CONFIGURE); \
		$(MAKE); \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
	-rm $(addprefix $(TARGET_bindir)/,gpg-error gpgrt-config)
	$(REWRITE_CONFIG_SCRIPTS)
	$(REWRITE_LIBTOOL)
	$(REMOVE)/$(PKG_DIR)
	$(TOUCH)

# -----------------------------------------------------------------------------

LIBGCRYPT_VERSION = 1.8.5
LIBGCRYPT_DIR = libgcrypt-$(LIBGCRYPT_VERSION)
LIBGCRYPT_SOURCE = libgcrypt-$(LIBGCRYPT_VERSION).tar.gz
LIBGCRYPT_SITE = ftp://ftp.gnupg.org/gcrypt/libgcrypt

LIBGCRYPT_DEPENDENCIES = libgpg-error

LIBGCRYPT_CONFIG_SCRIPTS = libgcrypt-config

LIBGCRYPT_CONF_OPTS = \
	--datarootdir=$(REMOVE_datarootdir) \
	--enable-maintainer-mode \
	--enable-silent-rules \
	--enable-shared \
	--disable-static \
	--disable-tests

libgcrypt: | $(TARGET_DIR)
	$(call autotools-package)
	-rm $(addprefix $(TARGET_bindir)/,dumpsexp hmac256 mpicalc)

# -----------------------------------------------------------------------------

LIBAACS_VERSION = 0.9.0
LIBAACS_DIR = libaacs-$(LIBAACS_VERSION)
LIBAACS_SOURCE = libaacs-$(LIBAACS_VERSION).tar.bz2
LIBAACS_SITE = ftp://ftp.videolan.org/pub/videolan/libaacs/$(LIBAACS_VERSION)

$(DL_DIR)/$(LIBAACS_SOURCE):
	$(download) $(LIBAACS_SITE)/$(LIBAACS_SOURCE)

LIBAACS_DEPENDENCIES = libgcrypt

LIBAACS_CONF_OPTS = \
	--enable-maintainer-mode \
	--enable-silent-rules \
	--enable-shared \
	--disable-static

libaacs: $(LIBAACS_DEPENDENCIES) $(DL_DIR)/$(LIBAACS_SOURCE) | $(TARGET_DIR)
	$(REMOVE)/$(PKG_DIR)
	$(UNTAR)/$(PKG_SOURCE)
	$(CHDIR)/$(PKG_DIR); \
		./bootstrap; \
		$(CONFIGURE); \
		$(MAKE); \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
	$(REWRITE_LIBTOOL)
	$(INSTALL) -d $(TARGET_DIR)/.cache/aacs/vuk
	$(INSTALL_DATA) -D $(PKG_FILES_DIR)/KEYDB.cfg $(TARGET_DIR)/.config/aacs/KEYDB.cfg
	$(REMOVE)/$(PKG_DIR)
	$(TOUCH)

# -----------------------------------------------------------------------------

LIBBDPLUS_VERSION = 0.1.2
LIBBDPLUS_DIR = libbdplus-$(LIBBDPLUS_VERSION)
LIBBDPLUS_SOURCE = libbdplus-$(LIBBDPLUS_VERSION).tar.bz2
LIBBDPLUS_SITE = ftp://ftp.videolan.org/pub/videolan/libbdplus/$(LIBBDPLUS_VERSION)

$(DL_DIR)/$(LIBBDPLUS_SOURCE):
	$(download) $(LIBBDPLUS_SITE)/$(LIBBDPLUS_SOURCE)

LIBBDPLUS_DEPENDENCIES = libaacs

LIBBDPLUS_CONF_OPTS = \
	--enable-maintainer-mode \
	--enable-silent-rules \
	--enable-shared \
	--disable-static

libbdplus: $(LIBBDPLUS_DEPENDENCIES) $(DL_DIR)/$(LIBBDPLUS_SOURCE) | $(TARGET_DIR)
	$(REMOVE)/$(PKG_DIR)
	$(UNTAR)/$(PKG_SOURCE)
	$(CHDIR)/$(PKG_DIR); \
		./bootstrap; \
		$(CONFIGURE); \
		$(MAKE); \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
	$(REWRITE_LIBTOOL)
	$(INSTALL) -d $(TARGET_DIR)/.config/bdplus/vm0
	$(INSTALL_COPY) $(PKG_FILES_DIR)/* $(TARGET_DIR)/.config/bdplus/vm0
	$(REMOVE)/$(PKG_DIR)
	$(TOUCH)

# -----------------------------------------------------------------------------

LIBXML2_VERSION = 2.9.10
LIBXML2_DIR = libxml2-$(LIBXML2_VERSION)
LIBXML2_SOURCE = libxml2-$(LIBXML2_VERSION).tar.gz
LIBXML2_SITE = http://xmlsoft.org/sources

LIBXML2_CONFIG_SCRIPTS = xml2-config

LIBXML2_CONF_OPTS = \
	--datarootdir=$(REMOVE_datarootdir) \
	--enable-shared \
	--disable-static \
	--without-python \
	--without-debug \
	--without-c14n \
	--without-legacy \
	--without-catalog \
	--without-docbook \
	--without-mem-debug \
	--without-lzma \
	--without-schematron

libxml2: | $(TARGET_DIR)
	$(call autotools-package)
	-rm -r $(TARGET_libdir)/cmake
	-rm $(addprefix $(TARGET_libdir)/,xml2Conf.sh)

# -----------------------------------------------------------------------------

PUGIXML_VERSION = 1.11.1
PUGIXML_DIR = pugixml-$(PUGIXML_VERSION)
PUGIXML_SOURCE = pugixml-$(PUGIXML_VERSION).tar.gz
PUGIXML_SITE = https://github.com/zeux/pugixml/releases/download/v$(PUGIXML_VERSION)

$(DL_DIR)/$(PUGIXML_SOURCE):
	$(download) $(PUGIXML_SITE)/$(PUGIXML_SOURCE)

pugixml: $(DL_DIR)/$(PUGIXML_SOURCE) | $(TARGET_DIR)
	$(call cmake-package)

# -----------------------------------------------------------------------------

LIBROXML_VERSION = 3.0.2
LIBROXML_DIR = libroxml-$(LIBROXML_VERSION)
LIBROXML_SOURCE = libroxml-$(LIBROXML_VERSION).tar.gz
LIBROXML_SITE = http://download.libroxml.net/pool/v3.x

LIBROXML_CONF_OPTS = \
	--disable-roxml

libroxml: | $(TARGET_DIR)
	$(call autotools-package)

# -----------------------------------------------------------------------------

LIBXSLT_VERSION = 1.1.34
LIBXSLT_DIR = libxslt-$(LIBXSLT_VERSION)
LIBXSLT_SOURCE = libxslt-$(LIBXSLT_VERSION).tar.gz
LIBXSLT_SITE = ftp://xmlsoft.org/libxml2

LIBXSLT_DEPENDENCIES = libxml2

LIBXSLT_CONFIG_SCRIPTS = xslt-config

LIBXSLT_CONF_OPTS = \
	--datarootdir=$(REMOVE_datarootdir) \
	--enable-shared \
	--disable-static \
	--without-python \
	--without-crypto \
	--without-debug \
	--without-mem-debug

libxslt: | $(TARGET_DIR)
	$(call autotools-package)
	-rm -r $(TARGET_libdir)/libxslt-plugins/
	-rm $(addprefix $(TARGET_libdir)/,xsltConf.sh)

# -----------------------------------------------------------------------------

RTMPDUMP_DEPENDENCIES = zlib openssl

RTMPDUMP_MAKE_ENV = \
	CROSS_COMPILE=$(TARGET_CROSS) \
	XCFLAGS="$(TARGET_CFLAGS)" \
	XLDFLAGS="$(TARGET_LDFLAGS)"

RTMPDUMP_MAKE_OPTS = \
	prefix=$(prefix) \
	mandir=$(REMOVE_mandir)

rtmpdump: $(RTMPDUMP_DEPENDENCIES) $(SOURCE_DIR)/$(NI_RTMPDUMP) | $(TARGET_DIR)
	$(REMOVE)/$(NI_RTMPDUMP)
	tar -C $(SOURCE_DIR) -cp $(NI_RTMPDUMP) --exclude-vcs | tar -C $(BUILD_DIR) -x
	$(CHDIR)/$(NI_RTMPDUMP); \
		$($(PKG)_MAKE_ENV) $(MAKE) $($(PKG)_MAKE_OPTS); \
		$($(PKG)_MAKE_ENV) $(MAKE) $($(PKG)_MAKE_OPTS) install DESTDIR=$(TARGET_DIR)
	-rm $(addprefix $(TARGET_sbindir)/,rtmpgw rtmpsrv rtmpsuck)
	$(REMOVE)/$(NI_RTMPDUMP)
	$(TOUCH)

# -----------------------------------------------------------------------------

LIBTIRPC_VERSION = 1.2.6
LIBTIRPC_DIR = libtirpc-$(LIBTIRPC_VERSION)
LIBTIRPC_SOURCE = libtirpc-$(LIBTIRPC_VERSION).tar.bz2
LIBTIRPC_SITE = https://sourceforge.net/projects/libtirpc/files/libtirpc/$(LIBTIRPC_VERSION)

LIBTIRPC_AUTORECONF = YES

LIBTIRPC_CONF_OPTS = \
	--disable-gssapi \
	--enable-silent-rules

libtirpc: | $(TARGET_DIR)
	$(call autotools-package)
ifeq ($(BOXSERIES),hd1)
	$(SED) '/^\(udp\|tcp\)6/ d' $(TARGET_sysconfdir)/netconfig
endif

# -----------------------------------------------------------------------------

CONFUSE_VERSION = 3.2.2
CONFUSE_DIR = confuse-$(CONFUSE_VERSION)
CONFUSE_SOURCE = confuse-$(CONFUSE_VERSION).tar.xz
CONFUSE_SITE = https://github.com/martinh/libconfuse/releases/download/v$(CONFUSE_VERSION)

CONFUSE_CONF_OPTS = \
	--docdir=$(REMOVE_docdir) \
	--enable-silent-rules \
	--enable-static \
	--disable-shared

confuse: | $(TARGET_DIR)
	$(call autotools-package)

# -----------------------------------------------------------------------------

LIBITE_VERSION = 2.0.2
LIBITE_DIR = libite-$(LIBITE_VERSION)
LIBITE_SOURCE = libite-$(LIBITE_VERSION).tar.xz
LIBITE_SITE = https://github.com/troglobit/libite/releases/download/v$(LIBITE_VERSION)

LIBITE_CONF_OPTS = \
	--docdir=$(REMOVE_docdir) \
	--enable-silent-rules \
	--enable-static \
	--disable-shared

libite: | $(TARGET_DIR)
	$(call autotools-package)

# -----------------------------------------------------------------------------

LIBMAD_VERSION = 0.15.1b
LIBMAD_DIR = libmad-$(LIBMAD_VERSION)
LIBMAD_SOURCE = libmad-$(LIBMAD_VERSION).tar.gz
LIBMAD_SITE = https://sourceforge.net/projects/mad/files/libmad/$(LIBMAD_VERSION)

LIBMAD_AUTORECONF = YES

LIBMAD_CONF_OPTS = \
	--enable-shared=yes \
	--enable-accuracy \
	--enable-fpm=arm \
	--enable-sso

libmad: | $(TARGET_DIR)
	$(call autotools-package)

# -----------------------------------------------------------------------------

LIBVORBIS_VERSION = 1.3.7
LIBVORBIS_DIR = libvorbis-$(LIBVORBIS_VERSION)
LIBVORBIS_SOURCE = libvorbis-$(LIBVORBIS_VERSION).tar.xz
LIBVORBIS_SITE = https://downloads.xiph.org/releases/vorbis

LIBVORBIS_DEPENDENCIES = libogg

LIBVORBIS_AUTORECONF = YES

LIBVORBIS_CONF_OPTS = \
	--datarootdir=$(REMOVE_datarootdir) \
	--disable-docs \
	--disable-examples \
	--disable-oggtest

libvorbis: | $(TARGET_DIR)
	$(call autotools-package)

# -----------------------------------------------------------------------------

LIBVORBISIDEC_VERSION = 1.2.1+git20180316
LIBVORBISIDEC_DIR = libvorbisidec-$(LIBVORBISIDEC_VERSION)
LIBVORBISIDEC_SOURCE = libvorbisidec_$(LIBVORBISIDEC_VERSION).orig.tar.gz
LIBVORBISIDEC_SITE = https://ftp.de.debian.org/debian/pool/main/libv/libvorbisidec

$(DL_DIR)/$(LIBVORBISIDEC_SOURCE):
	$(download) $(LIBVORBISIDEC_SITE)/$(LIBVORBISIDEC_SOURCE)

LIBVORBISIDEC_DEPENDENCIES = libogg

LIBVORBISIDEC_AUTORECONF = YES

libvorbisidec: $(LIBVORBISIDEC_DEPENDENCIES) $(DL_DIR)/$(LIBVORBISIDEC_SOURCE) | $(TARGET_DIR)
	$(REMOVE)/$(PKG_DIR)
	$(UNTAR)/$(PKG_SOURCE)
	$(CHDIR)/$(PKG_DIR); \
		$(SED) '122 s/^/#/' configure.in; \
		$(CONFIGURE); \
		$(MAKE); \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
	$(REWRITE_LIBTOOL)
	$(REMOVE)/$(PKG_DIR)
	$(TOUCH)

# -----------------------------------------------------------------------------

LIBOGG_VERSION = 1.3.4
LIBOGG_DIR = libogg-$(LIBOGG_VERSION)
LIBOGG_SOURCE = libogg-$(LIBOGG_VERSION).tar.gz
LIBOGG_SITE = http://downloads.xiph.org/releases/ogg

LIBOGG_CONF_OPTS = \
	--datarootdir=$(REMOVE_datarootdir) \
	--enable-shared

libogg: | $(TARGET_DIR)
	$(call autotools-package)

# -----------------------------------------------------------------------------

LIBEXIF_VERSION = 0.6.22
LIBEXIF_DIR = libexif-$(LIBEXIF_VERSION)
LIBEXIF_SOURCE = libexif-$(LIBEXIF_VERSION).tar.xz
LIBEXIF_SITE = https://github.com/libexif/libexif/releases/download/libexif-$(subst .,_,$(LIBEXIF_VERSION))-release

LIBEXIF_CONF_OPTS = \
	--datarootdir=$(REMOVE_datarootdir) \
	--with-doc-dir=$(REMOVE_docdir)

libexif: | $(TARGET_DIR)
	$(call autotools-package)

# -----------------------------------------------------------------------------

FRIBIDI_VERSION = 1.0.10
FRIBIDI_DIR = fribidi-$(FRIBIDI_VERSION)
FRIBIDI_SOURCE = fribidi-$(FRIBIDI_VERSION).tar.xz
FRIBIDI_SITE = https://github.com/fribidi/fribidi/releases/download/v$(FRIBIDI_VERSION)

FRIBIDI_CONF_OPTS = \
	--disable-debug \
	--disable-deprecated

fribidi: | $(TARGET_DIR)
	$(call autotools-package)

# -----------------------------------------------------------------------------

LIBFFI_VERSION = 3.3
LIBFFI_DIR = libffi-$(LIBFFI_VERSION)
LIBFFI_SOURCE = libffi-$(LIBFFI_VERSION).tar.gz
LIBFFI_SITE = https://github.com/libffi/libffi/releases/download/v$(HOST_LIBFFI_VERSION)

LIBFFI_AUTORECONF = YES

LIBFFI_CONF_OPTS = \
	--datarootdir=$(REMOVE_datarootdir) \
	$(if $(filter $(BOXSERIES),hd1),--enable-static --disable-shared)

libffi: | $(TARGET_DIR)
	$(call autotools-package)

# -----------------------------------------------------------------------------

GLIB2_VERSION = 2.56.3
GLIB2_DIR = glib-$(GLIB2_VERSION)
GLIB2_SOURCE = glib-$(GLIB2_VERSION).tar.xz
GLIB2_SITE = https://ftp.gnome.org/pub/gnome/sources/glib/$(basename $(GLIB2_VERSION))

$(DL_DIR)/$(GLIB2_SOURCE):
	$(download) $(GLIB2_SITE)/$(GLIB2_SOURCE)

GLIB2_DEPENDENCIES = zlib libffi
ifeq ($(BOXSERIES),hd2)
  GLIB2_DEPENDENCIES += gettext
endif

GLIB2_AUTORECONF = YES

GLIB2_CONF_OPTS = \
	--bindir=$(REMOVE_bindir) \
	--datadir=$(REMOVE_datadir) \
	$(if $(filter $(BOXSERIES),hd1),--enable-static --disable-shared) \
	--cache-file=arm-linux.cache \
	--disable-debug \
	--disable-selinux \
	--disable-libmount \
	--disable-fam \
	--disable-gtk-doc \
	--disable-gtk-doc-html \
	--disable-compile-warnings \
	--with-threads="posix" \
	--with-pcre=internal

ifeq ($(BOXTYPE),$(filter $(BOXTYPE),armbox mipsbox))
  GLIB2_DEPENDENCIES += libiconv
  GLIB2_CONF_OPTS += --with-libiconv=gnu
endif

glib2: $(GLIB2_DEPENDENCIES) $(DL_DIR)/$(GLIB2_SOURCE) | $(TARGET_DIR)
	$(REMOVE)/$(PKG_DIR)
	$(UNTAR)/$(PKG_SOURCE)
	$(CHDIR)/$(PKG_DIR); \
		$(APPLY_PATCHES); \
		echo "ac_cv_type_long_long=yes"		 > arm-linux.cache; \
		echo "glib_cv_stack_grows=no"		>> arm-linux.cache; \
		echo "glib_cv_uscore=no"		>> arm-linux.cache; \
		echo "glib_cv_va_copy=no"		>> arm-linux.cache; \
		echo "glib_cv_va_val_copy=yes"		>> arm-linux.cache; \
		echo "ac_cv_func_posix_getpwuid_r=yes"	>> arm-linux.cache; \
		echo "ac_cv_func_posix_getgrgid_r=yes"	>> arm-linux.cache; \
		$(CONFIGURE); \
		$(MAKE); \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
	$(REWRITE_LIBTOOL)
	$(REMOVE)/$(PKG_DIR)
	$(TOUCH)

# -----------------------------------------------------------------------------

ALSA_LIB_VERSION = 1.2.4
ALSA_LIB_DIR = alsa-lib-$(ALSA_LIB_VERSION)
ALSA_LIB_SOURCE = alsa-lib-$(ALSA_LIB_VERSION).tar.bz2
ALSA_LIB_SITE = https://www.alsa-project.org/files/pub/lib

ALSA_LIB_AUTORECONF = YES

ALSA_LIB_CONF_OPTS = \
	--with-alsa-devdir=/dev/snd/ \
	--with-plugindir=$(libdir)/alsa \
	--without-debug \
	--with-debug=no \
	--with-versioned=no \
	--enable-symbolic-functions \
	--disable-aload \
	--disable-rawmidi \
	--disable-resmgr \
	--disable-old-symbols \
	--disable-alisp \
	--disable-ucm \
	--disable-hwdep \
	--disable-python \
	--disable-topology

alsa-lib: | $(TARGET_DIR)
	$(call autotools-package)
	find $(TARGET_datadir)/alsa/cards/ -name '*.conf' ! -name 'aliases.conf' | xargs --no-run-if-empty rm
	find $(TARGET_datadir)/alsa/pcm/ -name '*.conf' ! -name 'default.conf' ! -name 'dmix.conf' ! -name 'dsnoop.conf' | xargs --no-run-if-empty rm
	-rm -r $(TARGET_datadir)/aclocal

# -----------------------------------------------------------------------------

POPT_VERSION = 1.16
POPT_DIR = popt-$(POPT_VERSION)
POPT_SOURCE = popt-$(POPT_VERSION).tar.gz
POPT_SITE = ftp://anduin.linuxfromscratch.org/BLFS/popt

POPT_CONF_OPTS = \
	--datarootdir=$(REMOVE_datarootdir)

popt: | $(TARGET_DIR)
	$(call autotools-package)

# -----------------------------------------------------------------------------

LIBICONV_VERSION = 1.15
LIBICONV_DIR = libiconv-$(LIBICONV_VERSION)
LIBICONV_SOURCE = libiconv-$(LIBICONV_VERSION).tar.gz
LIBICONV_SITE = $(GNU_MIRROR)/libiconv

$(DL_DIR)/$(LIBICONV_SOURCE):
	$(download) $(LIBICONV_SITE)/$(LIBICONV_SOURCE)

LIBICONV_CONF_ENV = \
	CPPFLAGS="$(TARGET_CPPFLAGS) -fPIC"

LIBICONV_CONF_OPTS = \
	--datarootdir=$(REMOVE_datarootdir) \
	--enable-static \
	--disable-shared \
	--enable-relocatable

libiconv: $(DL_DIR)/$(LIBICONV_SOURCE) | $(TARGET_DIR)
	$(REMOVE)/$(PKG_DIR)
	$(UNTAR)/$(PKG_SOURCE)
	$(CHDIR)/$(PKG_DIR); \
		$(SED) '/preload/d' Makefile.in; \
		$(CONFIGURE); \
		$(MAKE); \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
	$(REWRITE_LIBTOOL)
	$(REMOVE)/$(PKG_DIR)
	$(TOUCH)

# -----------------------------------------------------------------------------

GRAPHLCD_BASE_VERSION = git
GRAPHLCD_BASE_DIR = graphlcd-base.$(GRAPHLCD_BASE_VERSION)
GRAPHLCD_BASE_SOURCE = graphlcd-base.$(GRAPHLCD_BASE_VERSION)
GRAPHLCD_BASE_SITE = git://projects.vdr-developer.org

GRAPHLCD_BASE_PATCH  = graphlcd.patch
GRAPHLCD_BASE_PATCH += 0003-strip-graphlcd-conf.patch
GRAPHLCD_BASE_PATCH += 0004-material-colors.patch
ifeq ($(BOXMODEL),$(filter $(BOXMODEL),vuduo4k vuduo4kse vusolo4k vuultimo4k vuuno4kse))
  GRAPHLCD_BASE_PATCH += 0005-add-vuplus-driver.patch
endif

GRAPHLCD_BASE_DEPENDENCIES = freetype libiconv libusb

graphlcd-base: $(GRAPHLCD_BASE_DEPENDENCIES) | $(TARGET_DIR)
	$(REMOVE)/$(PKG_DIR)
	$(GET_GIT_SOURCE) $(PKG_SITE)/$(PKG_SOURCE) $(DL_DIR)/$(PKG_SOURCE)
	$(CPDIR)/$(PKG_SOURCE)
	$(CHDIR)/$(PKG_DIR); \
		$(call apply_patches,$(addprefix $(PKG_PATCHES_DIR)/,$(PKG_PATCH))); \
		$(TARGET_CONFIGURE_ENV) \
		$(MAKE); \
		$(MAKE) install DESTDIR=$(TARGET_DIR) PREFIX=$(prefix)
	-rm -r $(TARGET_sysconfdir)/udev
	$(REMOVE)/$(PKG_DIR)
	$(TOUCH)
