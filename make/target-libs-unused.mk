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

$(D)/libid3tag: $(D)/zlib $(ARCHIVE)/$(LIBID3TAG_SOURCE) | $(TARGET_DIR)
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
	$(REWRITE_LIBTOOL)/libid3tag.la
	$(REMOVE)/$(LIBID3TAG_TMP)
	$(TOUCH)

# -----------------------------------------------------------------------------

FLAC_VER    = 1.3.2
FLAC_TMP    = flac-$(FLAC_VER)
FLAC_SOURCE = flac-$(FLAC_VER).tar.xz
FLAC_URL    = https://ftp.osuosl.org/pub/xiph/releases/flac

$(ARCHIVE)/$(FLAC_SOURCE):
	$(DOWNLOAD) $(FLAC_URL)/$(FLAC_SOURCE)

$(D)/libFLAC: $(ARCHIVE)/$(FLAC_SOURCE) | $(TARGET_DIR)
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
	$(REWRITE_LIBTOOL)/libFLAC.la
	rm -rf $(TARGET_DIR)/bin/flac
	rm -rf $(TARGET_DIR)/bin/metaflac
	$(REMOVE)/$(LIBFLAC_TMP)
	$(TOUCH)

# -----------------------------------------------------------------------------

LIBROXML_VER    = 2.3.0
LIBROXML_TMP    = libroxml-$(LIBROXML_VER)
LIBROXML_SOURCE = libroxml-$(LIBROXML_VER).tar.gz
LIBROXML_URL    = http://download.libroxml.net/pool/v2.x

$(ARCHIVE)/$(LIBROXML_SOURCE):
	$(DOWNLOAD) $(LIBROXML_URL)/$(LIBROXML_SOURCE)

$(D)/libroxml: $(ARCHIVE)/$(LIBROXML_SOURCE) | $(TARGET_DIR)
	$(REMOVE)/$(LIBROXML_TMP)
	$(UNTAR)/$(LIBROXML_SOURCE)
	$(CHDIR)/$(LIBROXML_TMP); \
		$(CONFIGURE) \
			--prefix= \
			--disable-xml-read-write \
			--enable-xml-small-input-file \
			--disable-xml-commit-xml-tree \
			--disable-xml-xpath-engine \
			; \
		$(MAKE); \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
	$(REWRITE_PKGCONF)/libroxml.pc
	$(REMOVE)/$(LIBROXML_TMP)
	$(TOUCH)

# -----------------------------------------------------------------------------

BZIP2_VER    = 1.0.7
BZIP2_TMP    = bzip2-$(BZIP2_VER)
BZIP2_SOURCE = bzip2-$(BZIP2_VER).tar.gz
BZIP2_URL    = https://sourceware.org/pub/bzip2

$(ARCHIVE)/$(BZIP2_SOURCE):
	$(DOWNLOAD) $(BZIP2_URL)/$(BZIP2_SOURCE)

BZIP2_PATCH  = bzip2.patch

$(D)/bzip2: $(ARCHIVE)/$(BZIP2_SOURCE) | $(TARGET_DIR)
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

$(D)/fontconfig: $(D)/freetype $(D)/expat $(ARCHIVE)/$(FONTCONFIG_SOURCE) | $(TARGET_DIR)
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
	$(REWRITE_LIBTOOL)/libfontconfig.la
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

$(D)/pixman: $(D)/zlib $(D)/libpng $(ARCHIVE)/$(PIXMAN_SOURCE) | $(TARGET_DIR)
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
	$(REWRITE_LIBTOOL)/libpixman-1.la
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

$(D)/cairo: $(D)/fontconfig $(D)/glib2 $(D)/libpng $(D)/pixman $(D)/zlib $(ARCHIVE)/$(CAIRO_SOURCE) | $(TARGET_DIR)
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
	$(REWRITE_LIBTOOL)/libcairo.la
	$(REWRITE_LIBTOOL)/libcairo-script-interpreter.la
	$(REWRITE_LIBTOOL)/libcairo-gobject.la
	$(REWRITE_LIBTOOL)/cairo/libcairo-trace.la
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

$(D)/harfbuzz: $(D)/fontconfig $(D)/glib2 $(D)/cairo $(D)/freetype $(ARCHIVE)/$(HARFBUZZ_SOURCE) | $(TARGET_DIR)
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
	$(REWRITE_LIBTOOL)/libharfbuzz.la
	$(REWRITE_LIBTOOL)/libharfbuzz-subset.la
	$(REWRITE_PKGCONF)/harfbuzz.pc
	$(REWRITE_PKGCONF)/harfbuzz-subset.pc
	$(REMOVE)/$(HARFBUZZ_TMP)
	$(TOUCH)
