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
	$(call APPLY_PATCHES,$(PKG_PATCHES_DIR))
	$(CHDIR)/$(PKG_DIR); \
		$(TARGET_CONFIGURE_ENV) \
		./configure $($(PKG)_CONF_OPTS); \
		$(MAKE); \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
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

FREETYPE_VERSION = 2.11.0
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
	$(call APPLY_PATCHES,$(PKG_PATCHES_DIR))
	$(CHDIR)/$(PKG_DIR); \
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

OPENSSL_VERSION = 1.0.2u
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

OPENSSL_CONF_OPTS = \
	--cross-compile-prefix=$(TARGET_CROSS) \
	--prefix=$(prefix) \
	--openssldir=$(sysconfdir)/ssl

OPENSSL_CONF_OPTS += \
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

OPENSSL_CONF_OPTS += \
	-DTERMIOS -fomit-frame-pointer \
	-DOPENSSL_SMALL_FOOTPRINT \
	$(TARGET_CFLAGS) \
	$(TARGET_LDFLAGS) \

openssl: $(DL_DIR)/$(OPENSSL_SOURCE) | $(TARGET_DIR)
	$(REMOVE)/$(PKG_DIR)
	$(UNTAR)/$(PKG_SOURCE)
	$(call APPLY_PATCHES,$(PKG_PATCHES_DIR))
	$(CHDIR)/$(PKG_DIR); \
		./Configure \
			$($(PKG)_CONF_OPTS); \
		$(SED) 's| build_tests||' Makefile; \
		$(SED) 's|^MANDIR=.*|MANDIR=$(REMOVE_mandir)|' Makefile; \
		$(SED) 's|^HTMLDIR=.*|HTMLDIR=$(REMOVE_htmldir)|' Makefile; \
		$(MAKE) depend; \
		$(MAKE); \
		$(MAKE) install_sw INSTALL_PREFIX=$(TARGET_DIR)
	$(TARGET_RM) $(TARGET_libdir)/engines
	$(TARGET_RM) $(TARGET_bindir)/c_rehash
	$(TARGET_RM) $(TARGET_sysconfdir)/ssl/misc/{CA.pl,tsget}
ifeq ($(BOXSERIES),$(filter $(BOXSERIES),hd1 hd2))
	$(TARGET_RM) $(TARGET_bindir)/openssl
	$(TARGET_RM) $(TARGET_sysconfdir)/ssl/misc/{CA.*,c_*}
endif
	chmod 0755 $(TARGET_libdir)/lib{crypto,ssl}.so.*
	for version in 0.9.7 0.9.8 1.0.2; do \
		ln -sf libcrypto.so.1.0.0 $(TARGET_libdir)/libcrypto.so.$$version; \
		ln -sf libssl.so.1.0.0 $(TARGET_libdir)/libssl.so.$$version; \
	done
	$(REMOVE)/$(PKG_DIR)
	$(TOUCH)

# -----------------------------------------------------------------------------

OPENTHREADS_CONF_OPTS = \
	-DCMAKE_SUPPRESS_DEVELOPER_WARNINGS="1" \
	-D_OPENTHREADS_ATOMIC_USE_GCC_BUILTINS_EXITCODE="0" \
	-D_OPENTHREADS_ATOMIC_USE_GCC_BUILTINS_EXITCODE__TRYRUN_OUTPUT="1"

openthreads: $(SOURCE_DIR)/$(NI_OPENTHREADS) | $(TARGET_DIR)
	$(REMOVE)/$(NI_OPENTHREADS)
	tar -C $(SOURCE_DIR) -cp $(NI_OPENTHREADS) | tar -C $(BUILD_DIR) -x
	$(CHDIR)/$(NI_OPENTHREADS)/; \
		$(CMAKE); \
		$(MAKE); \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
	$(REMOVE)/$(NI_OPENTHREADS)
	$(TOUCH)

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
	$(call APPLY_PATCHES,$(PKG_PATCHES_DIR))
	$(CHDIR)/$(PKG_DIR); \
		$(MAKE1) -C dpflib libdpf.a $($(PKG)_MAKE_OPTS)
	$(INSTALL_DATA) -D $(PKG_BUILD_DIR)/dpflib/libdpf.a $(TARGET_libdir)/libdpf.a
	$(INSTALL_DATA) -D $(PKG_BUILD_DIR)/dpflib/dpf.h $(TARGET_includedir)/libdpf/libdpf.h
	$(INSTALL_DATA) -D $(PKG_BUILD_DIR)/include/spiflash.h $(TARGET_includedir)/libdpf/spiflash.h
	$(INSTALL_DATA) -D $(PKG_BUILD_DIR)/include/usbuser.h $(TARGET_includedir)/libdpf/usbuser.h
	$(REMOVE)/$(PKG_DIR)
	$(TOUCH)

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
	$(call APPLY_PATCHES,$(PKG_PATCHES_DIR))
	$(CHDIR)/$(PKG_DIR); \
		./bootstrap; \
		$(CONFIGURE); \
		$(MAKE); \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
	$(REWRITE_LIBTOOL)
	$(REMOVE)/$(PKG_DIR)
	$(TOUCH)

# -----------------------------------------------------------------------------

LIBAACS_VERSION = 0.9.0
LIBAACS_DIR = libaacs-$(LIBAACS_VERSION)
LIBAACS_SOURCE = libaacs-$(LIBAACS_VERSION).tar.bz2
LIBAACS_SITE = ftp://ftp.videolan.org/pub/videolan/libaacs/$(LIBAACS_VERSION)

$(DL_DIR)/$(LIBAACS_SOURCE):
	$(download) $(LIBAACS_SITE)/$(LIBAACS_SOURCE)

LIBAACS_DEPENDENCIES = libgcrypt

LIBAACS_CONF_OPTS = \
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
	tar -C $(SOURCE_DIR) -cp $(NI_RTMPDUMP) | tar -C $(BUILD_DIR) -x
	$(CHDIR)/$(NI_RTMPDUMP); \
		$($(PKG)_MAKE_ENV) $(MAKE) $($(PKG)_MAKE_OPTS); \
		$($(PKG)_MAKE_ENV) $(MAKE) $($(PKG)_MAKE_OPTS) install DESTDIR=$(TARGET_DIR)
	$(TARGET_RM) $(addprefix $(TARGET_sbindir)/,rtmpgw rtmpsrv rtmpsuck)
	$(REMOVE)/$(NI_RTMPDUMP)
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
	$(call APPLY_PATCHES,$(PKG_PATCH))
	$(CHDIR)/$(PKG_DIR); \
		$(TARGET_CONFIGURE_ENV) \
		$(MAKE); \
		$(MAKE) install DESTDIR=$(TARGET_DIR) PREFIX=$(prefix)
	$(TARGET_RM) $(TARGET_sysconfdir)/udev
	$(REMOVE)/$(PKG_DIR)
	$(TOUCH)
