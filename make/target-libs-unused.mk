#
# makefile to build system libs (currently unused in ni-image)
#
# -----------------------------------------------------------------------------

LIBID3TAG_VER = 0.15.1b

$(ARCHIVE)/libid3tag-$(LIBID3TAG_VER).tar.gz:
	$(DOWNLOAD) http://downloads.sourceforge.net/project/mad/libid3tag/$(LIBID3TAG_VER)/libid3tag-$(LIBID3TAG_VER).tar.gz

LIBID3TAG_PATCH  = libid3tag-pc.patch

$(D)/libid3tag: $(D)/zlib $(ARCHIVE)/libid3tag-$(LIBID3TAG_VER).tar.gz | $(TARGET_DIR)
	$(REMOVE)/libid3tag-$(LIBID3TAG_VER)
	$(UNTAR)/libid3tag-$(LIBID3TAG_VER).tar.gz
	$(CHDIR)/libid3tag-$(LIBID3TAG_VER); \
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
	$(REMOVE)/libid3tag-$(LIBID3TAG_VER)
	$(TOUCH)

# -----------------------------------------------------------------------------

LIBFLAC_VER = 1.3.2

$(ARCHIVE)/flac-$(LIBFLAC_VER).tar.xz:
	$(DOWNLOAD) http://prdownloads.sourceforge.net/sourceforge/flac/flac-$(LIBFLAC_VER).tar.xz

$(D)/libFLAC: $(ARCHIVE)/flac-$(LIBFLAC_VER).tar.xz | $(TARGET_DIR)
	$(REMOVE)/flac-$(LIBFLAC_VER)
	$(UNTAR)/flac-$(LIBFLAC_VER).tar.xz
	$(CHDIR)/flac-$(LIBFLAC_VER); \
		autoreconf -fi; \
		$(CONFIGURE) \
			--prefix= \
			--datarootdir=/.remove \
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
	$(REMOVE)/flac-$(LIBFLAC_VER)
	$(TOUCH)

# -----------------------------------------------------------------------------

LIBROXML_VER = 2.3.0

$(ARCHIVE)/libroxml-$(LIBROXML_VER).tar.gz:
	$(DOWNLOAD) http://download.libroxml.net/pool/v2.x/libroxml-$(LIBROXML_VER).tar.gz

$(D)/libroxml: $(ARCHIVE)/libroxml-$(LIBROXML_VER).tar.gz | $(TARGET_DIR)
	$(REMOVE)/libroxml-$(LIBROXML_VER)
	$(UNTAR)/libroxml-$(LIBROXML_VER).tar.gz
	$(CHDIR)/libroxml-$(LIBROXML_VER); \
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
	$(REMOVE)/libroxml-$(LIBROXML_VER)
	$(TOUCH)

# -----------------------------------------------------------------------------

BZIP2_VER    = 1.0.7
BZIP2        = bzip2-$(BZIP2_VER)
BZIP2_SOURCE = bzip2-$(BZIP2_VER).tar.gz
BZIP2_URL    = https://sourceware.org/pub/bzip2

$(ARCHIVE)/$(BZIP2_SOURCE):
	$(DOWNLOAD) $(BZIP2_URL)/$(BZIP2_SOURCE)

BZIP2_PATCH  = bzip2.patch

$(D)/bzip2: $(ARCHIVE)/$(BZIP2_SOURCE) | $(TARGET_DIR)
	$(REMOVE)/$(BZIP2)
	$(UNTAR)/$(BZIP2_SOURCE)
	$(CHDIR)/$(BZIP2); \
		$(call apply_patches, $(BZIP2_PATCH)); \
		mv Makefile-libbz2_so Makefile; \
		$(BUILDENV) \
		$(MAKE) all; \
		$(MAKE) install PREFIX=$(TARGET_DIR)
	rm -f $(TARGET_DIR)/bin/bzip2
	$(REMOVE)/$(BZIP2)
	$(TOUCH)

# -----------------------------------------------------------------------------

FONTCONFIG_VER = 2.11.93
FONTCONFIG_SOURCE = fontconfig-$(FONTCONFIG_VER).tar.bz2

$(ARCHIVE)/$(FONTCONFIG_SOURCE):
	$(DOWNLOAD) https://www.freedesktop.org/software/fontconfig/release/$(FONTCONFIG_SOURCE)

$(D)/fontconfig: $(D)/freetype $(D)/expat $(ARCHIVE)/$(FONTCONFIG_SOURCE) | $(TARGET_DIR)
	$(REMOVE)/fontconfig-$(FONTCONFIG_VER)
	$(UNTAR)/$(FONTCONFIG_SOURCE)
	$(CHDIR)/fontconfig-$(FONTCONFIG_VER); \
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
	$(REMOVE)/fontconfig-$(FONTCONFIG_VER)
	$(TOUCH)

# -----------------------------------------------------------------------------

PIXMAN_VER = 0.34.0
PIXMAN_SOURCE = pixman-$(PIXMAN_VER).tar.gz

$(ARCHIVE)/$(PIXMAN_SOURCE):
	$(DOWNLOAD) https://www.cairographics.org/releases/$(PIXMAN_SOURCE)

PIXMAN_PATCH  = pixman-$(PIXMAN_VER)-0001-ARM-qemu-related-workarounds-in-cpu-features-detecti.patch
PIXMAN_PATCH += pixman-$(PIXMAN_VER)-asm_include.patch
PIXMAN_PATCH += pixman-$(PIXMAN_VER)-0001-test-utils-Check-for-FE_INVALID-definition-before-us.patch

$(D)/pixman: $(D)/zlib $(D)/libpng $(ARCHIVE)/$(PIXMAN_SOURCE) | $(TARGET_DIR)
	$(REMOVE)/pixman-$(PIXMAN_VER)
	$(UNTAR)/$(PIXMAN_SOURCE)
	$(CHDIR)/pixman-$(PIXMAN_VER); \
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
	$(REMOVE)/pixman-$(PIXMAN_VER)
	$(TOUCH)

# -----------------------------------------------------------------------------

CAIRO_VER = 1.16.0
CAIRO_SOURCE = cairo-$(CAIRO_VER).tar.xz

$(ARCHIVE)/$(CAIRO_SOURCE):
	$(DOWNLOAD) https://www.cairographics.org/releases/$(CAIRO_SOURCE)

CAIRO_PATCH  = cairo-$(CAIRO_VER)-get_bitmap_surface.diff

$(D)/cairo: $(D)/fontconfig $(D)/glib2 $(D)/libpng $(D)/pixman $(D)/zlib $(ARCHIVE)/$(CAIRO_SOURCE) | $(TARGET_DIR)
	$(REMOVE)/cairo-$(CAIRO_VER)
	$(UNTAR)/$(CAIRO_SOURCE)
	$(CHDIR)/cairo-$(CAIRO_VER); \
		$(call apply_patches, $(CAIRO_PATCH)); \
		$(BUILDENV) \
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
	rm -rf $(TARGET_DIR)/usr/bin/cairo-sphinx
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
	$(REMOVE)/cairo-$(CAIRO_VER)
	$(TOUCH)

# -----------------------------------------------------------------------------

HARFBUZZ_VER = 1.8.8
HARFBUZZ_SOURCE = harfbuzz-$(HARFBUZZ_VER).tar.bz2

$(ARCHIVE)/$(HARFBUZZ_SOURCE):
	$(DOWNLOAD) https://www.freedesktop.org/software/harfbuzz/release/$(HARFBUZZ_SOURCE)

HARFBUZZ_PATCH  = harfbuzz-$(HARFBUZZ_VER)-disable-docs.patch

$(D)/harfbuzz: $(D)/fontconfig $(D)/glib2 $(D)/cairo $(D)/freetype $(ARCHIVE)/$(HARFBUZZ_SOURCE) | $(TARGET_DIR)
	$(REMOVE)/harfbuzz-$(HARFBUZZ_VER)
	$(UNTAR)/$(HARFBUZZ_SOURCE)
	$(CHDIR)/harfbuzz-$(HARFBUZZ_VER); \
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
	$(REMOVE)/harfbuzz-$(HARFBUZZ_VER)
	$(TOUCH)
