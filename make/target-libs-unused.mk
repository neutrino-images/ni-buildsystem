#
# makefile to build system libs (currently unused in ni-image)
#
# -----------------------------------------------------------------------------

LIBID3TAG_VER    = 0.15.1b
LIBID3TAG_TMP    = libid3tag-$(LIBID3TAG_VER)
LIBID3TAG_SOURCE = libid3tag-$(LIBID3TAG_VER).tar.gz
LIBID3TAG_URL    = https://sourceforge.net/projects/mad/files/libid3tag/$(LIBID3TAG_VER)

$(ARCHIVE)/$(LIBID3TAG_SOURCE):
	$(DOWNLOAD) $(LIBID3TAG_URL)/$(LIBID3TAG_SOURCE)

LIBID3TAG_PATCH  = libid3tag-pc.patch

LIBID3TAG_DEPS   = zlib

libid3tag: $(LIBID3TAG_DEPS) $(ARCHIVE)/$(LIBID3TAG_SOURCE) | $(TARGET_DIR)
	$(REMOVE)/$(LIBID3TAG_TMP)
	$(UNTAR)/$(LIBID3TAG_SOURCE)
	$(CHDIR)/$(LIBID3TAG_TMP); \
		$(call apply_patches, $(LIBID3TAG_PATCH)); \
		autoreconf -fi; \
		$(CONFIGURE) \
			--prefix= \
			--enable-shared=yes \
			; \
		$(MAKE) all; \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
	$(REWRITE_PKGCONF)/id3tag.pc
	$(REWRITE_LIBTOOL_LA)
	$(REMOVE)/$(LIBID3TAG_TMP)
	$(TOUCH)

# -----------------------------------------------------------------------------

FLAC_VER    = 1.3.2
FLAC_TMP    = flac-$(FLAC_VER)
FLAC_SOURCE = flac-$(FLAC_VER).tar.xz
FLAC_URL    = https://ftp.osuosl.org/pub/xiph/releases/flac

$(ARCHIVE)/$(FLAC_SOURCE):
	$(DOWNLOAD) $(FLAC_URL)/$(FLAC_SOURCE)

libFLAC: $(ARCHIVE)/$(FLAC_SOURCE) | $(TARGET_DIR)
	$(REMOVE)/$(LIBFLAC_TMP)
	$(UNTAR)/$(LIBFLAC_SOURCE)
	$(CHDIR)/$(LIBFLAC_TMP); \
		autoreconf -fi; \
		$(CONFIGURE) \
			--prefix= \
			--datarootdir=$(remove-datarootdir) \
			--enable-shared \
			--disable-static \
			--disable-cpplibs \
			--disable-xmms-plugin \
			--disable-ogg \
			--disable-altivec \
			; \
		$(MAKE) all; \
		make install DESTDIR=$(TARGET_DIR); \
	$(REWRITE_PKGCONF)/flac.pc
	$(REWRITE_LIBTOOL_LA)
	rm -rf $(TARGET_DIR)/bin/flac
	rm -rf $(TARGET_DIR)/bin/metaflac
	$(REMOVE)/$(LIBFLAC_TMP)
	$(TOUCH)

# -----------------------------------------------------------------------------

BZIP2_VER    = 1.0.8
BZIP2_TMP    = bzip2-$(BZIP2_VER)
BZIP2_SOURCE = bzip2-$(BZIP2_VER).tar.gz
BZIP2_URL    = https://sourceware.org/pub/bzip2

$(ARCHIVE)/$(BZIP2_SOURCE):
	$(DOWNLOAD) $(BZIP2_URL)/$(BZIP2_SOURCE)

BZIP2_PATCH  = bzip2.patch

bzip2: $(ARCHIVE)/$(BZIP2_SOURCE) | $(TARGET_DIR)
	$(REMOVE)/$(BZIP2_TMP)
	$(UNTAR)/$(BZIP2_SOURCE)
	$(CHDIR)/$(BZIP2_TMP); \
		$(call apply_patches, $(BZIP2_PATCH)); \
		mv Makefile-libbz2_so Makefile; \
		$(BUILD_ENV) \
		$(MAKE) all; \
		$(MAKE) install PREFIX=$(TARGET_DIR)
	rm -f $(TARGET_DIR)/bin/bzip2
	$(REMOVE)/$(BZIP2_TMP)
	$(TOUCH)

# -----------------------------------------------------------------------------

FONTCONFIG_VER    = 2.11.93
FONTCONFIG_TMP    = fontconfig-$(FONTCONFIG_VER)
FONTCONFIG_SOURCE = fontconfig-$(FONTCONFIG_VER).tar.bz2
FONTCONFIG_URL    = https://www.freedesktop.org/software/fontconfig/release

$(ARCHIVE)/$(FONTCONFIG_SOURCE):
	$(DOWNLOAD) $(FONTCONFIG_URL)/$(FONTCONFIG_SOURCE)

FONTCONFIG_DEPS   = freetype expat

fontconfig: $(FONTCONFIG_DEPS) $(ARCHIVE)/$(FONTCONFIG_SOURCE) | $(TARGET_DIR)
	$(REMOVE)/$(FONTCONFIG_TMP)
	$(UNTAR)/$(FONTCONFIG_SOURCE)
	$(CHDIR)/$(FONTCONFIG_TMP); \
		$(CONFIGURE) \
			--prefix= \
			--with-freetype-config=$(HOST_DIR)/bin/freetype-config \
			--with-expat-includes=$(TARGET_INCLUDE_DIR) \
			--with-expat-lib=$(TARGET_LIB_DIR) \
			--sysconfdir=/etc \
			--disable-docs \
			; \
		$(MAKE) all; \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
	$(REWRITE_LIBTOOL_LA)
	$(REWRITE_PKGCONF)/fontconfig.pc
	$(REMOVE)/$(FONTCONFIG_TMP)
	$(TOUCH)

# -----------------------------------------------------------------------------

PIXMAN_VER    = 0.34.0
PIXMAN_TMP    = pixman-$(PIXMAN_VER)
PIXMAN_SOURCE = pixman-$(PIXMAN_VER).tar.gz
PIXMAN_URL    = https://www.cairographics.org/releases

$(ARCHIVE)/$(PIXMAN_SOURCE):
	$(DOWNLOAD) $(PIXMAN_URL)/$(PIXMAN_SOURCE)

PIXMAN_PATCH  = pixman-0001-ARM-qemu-related-workarounds-in-cpu-features-detecti.patch
PIXMAN_PATCH += pixman-asm_include.patch
PIXMAN_PATCH += pixman-0001-test-utils-Check-for-FE_INVALID-definition-before-us.patch

PIXMAN_DEPS   = zlib libpng

pixman: $(PIXMAN_DEPS) $(ARCHIVE)/$(PIXMAN_SOURCE) | $(TARGET_DIR)
	$(REMOVE)/$(PIXMAN_TMP)
	$(UNTAR)/$(PIXMAN_SOURCE)
	$(CHDIR)/$(PIXMAN_TMP); \
		$(call apply_patches, $(PIXMAN_PATCH)); \
		$(CONFIGURE) \
			--prefix= \
			--disable-gtk \
			--disable-arm-simd \
			--disable-loongson-mmi \
			--disable-docs \
			; \
		$(MAKE) all; \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
	$(REWRITE_LIBTOOL_LA)
	$(REWRITE_PKGCONF)/pixman-1.pc
	$(REMOVE)/$(PIXMAN_TMP)
	$(TOUCH)

# -----------------------------------------------------------------------------

CAIRO_VER    = 1.16.0
CAIRO_TMP    = cairo-$(CAIRO_VER)
CAIRO_SOURCE = cairo-$(CAIRO_VER).tar.xz
CAIRO_URL    = https://www.cairographics.org/releases

$(ARCHIVE)/$(CAIRO_SOURCE):
	$(DOWNLOAD) $(CAIRO_URL)/$(CAIRO_SOURCE)

CAIRO_PATCH  = cairo-get_bitmap_surface.diff

CAIRO_DEPS   = fontconfig glib2 libpng pixman zlib

cairo: $(CAIRO_DEPS) $(ARCHIVE)/$(CAIRO_SOURCE) | $(TARGET_DIR)
	$(REMOVE)/$(CAIRO_TMP)
	$(UNTAR)/$(CAIRO_SOURCE)
	$(CHDIR)/$(CAIRO_TMP); \
		$(call apply_patches, $(CAIRO_PATCH)); \
		$(BUILD_ENV) \
		ax_cv_c_float_words_bigendian="no" \
		./configure $(CONFIGURE_OPTS) \
			--prefix= \
			--with-x=no \
			--disable-xlib \
			--disable-xcb \
			--disable-egl \
			--disable-glesv2 \
			--disable-gl \
			--enable-tee \
			; \
		$(MAKE) all; \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
	rm -rf $(TARGET_BIN_DIR)/cairo-sphinx
	rm -rf $(TARGET_LIB_DIR)/cairo/cairo-fdr*
	rm -rf $(TARGET_LIB_DIR)/cairo/cairo-sphinx*
	rm -rf $(TARGET_LIB_DIR)/cairo/.debug/cairo-fdr*
	rm -rf $(TARGET_LIB_DIR)/cairo/.debug/cairo-sphinx*
	$(REWRITE_LIBTOOL_LA)
	$(REWRITE_PKGCONF)/cairo.pc
	$(REWRITE_PKGCONF)/cairo-fc.pc
	$(REWRITE_PKGCONF)/cairo-ft.pc
	$(REWRITE_PKGCONF)/cairo-gobject.pc
	$(REWRITE_PKGCONF)/cairo-pdf.pc
	$(REWRITE_PKGCONF)/cairo-png.pc
	$(REWRITE_PKGCONF)/cairo-ps.pc
	$(REWRITE_PKGCONF)/cairo-script.pc
	$(REWRITE_PKGCONF)/cairo-svg.pc
	$(REWRITE_PKGCONF)/cairo-tee.pc
	$(REMOVE)/$(CAIRO_TMP)
	$(TOUCH)

# -----------------------------------------------------------------------------

HARFBUZZ_VER    = 1.8.8
HARFBUZZ_TMP    = harfbuzz-$(HARFBUZZ_VER)
HARFBUZZ_SOURCE = harfbuzz-$(HARFBUZZ_VER).tar.bz2
HARFBUZZ_URL    = https://www.freedesktop.org/software/harfbuzz/release

$(ARCHIVE)/$(HARFBUZZ_SOURCE):
	$(DOWNLOAD) $(HARFBUZZ_URL)/$(HARFBUZZ_SOURCE)

HARFBUZZ_PATCH  = harfbuzz-disable-docs.patch

HARFBUZZ_DEPS   = fontconfig glib2 cairo freetype

harfbuzz: $(HARFBUZZ_DEPS) $(ARCHIVE)/$(HARFBUZZ_SOURCE) | $(TARGET_DIR)
	$(REMOVE)/$(HARFBUZZ_TMP)
	$(UNTAR)/$(HARFBUZZ_SOURCE)
	$(CHDIR)/$(HARFBUZZ_TMP); \
		$(call apply_patches, $(HARFBUZZ_PATCH)); \
		autoreconf -fi; \
		$(CONFIGURE) \
			--prefix= \
			--with-cairo \
			--with-fontconfig \
			--with-freetype \
			--with-glib \
			--without-graphite2 \
			--without-icu \
			; \
		$(MAKE) all; \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
	$(REWRITE_LIBTOOL_LA)
	$(REWRITE_PKGCONF)/harfbuzz.pc
	$(REWRITE_PKGCONF)/harfbuzz-subset.pc
	$(REMOVE)/$(HARFBUZZ_TMP)
	$(TOUCH)
