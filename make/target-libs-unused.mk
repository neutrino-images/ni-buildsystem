#
# makefile to build system libs (currently unused in ni-image)
#
# -----------------------------------------------------------------------------

LIBID3TAG_VER    = 0.15.1b
LIBID3TAG_DIR    = libid3tag-$(LIBID3TAG_VER)
LIBID3TAG_SOURCE = libid3tag-$(LIBID3TAG_VER).tar.gz
LIBID3TAG_SITE   = https://sourceforge.net/projects/mad/files/libid3tag/$(LIBID3TAG_VER)

$(DL_DIR)/$(LIBID3TAG_SOURCE):
	$(DOWNLOAD) $(LIBID3TAG_SITE)/$(LIBID3TAG_SOURCE)

LIBID3TAG_PATCH  = libid3tag-pc.patch

LIBID3TAG_DEPS   = zlib

libid3tag: $(LIBID3TAG_DEPS) $(DL_DIR)/$(LIBID3TAG_SOURCE) | $(TARGET_DIR)
	$(REMOVE)/$(LIBID3TAG_DIR)
	$(UNTAR)/$(LIBID3TAG_SOURCE)
	$(CHDIR)/$(LIBID3TAG_DIR); \
		$(call apply_patches,$(LIBID3TAG_PATCH)); \
		autoreconf -fi; \
		$(CONFIGURE) \
			--prefix=$(prefix) \
			--enable-shared=yes \
			; \
		$(MAKE); \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
	$(REWRITE_LIBTOOL_LA)
	$(REMOVE)/$(LIBID3TAG_DIR)
	$(TOUCH)

# -----------------------------------------------------------------------------

BZIP2_VER    = 1.0.8
BZIP2_DIR    = bzip2-$(BZIP2_VER)
BZIP2_SOURCE = bzip2-$(BZIP2_VER).tar.gz
BZIP2_SITE   = https://sourceware.org/pub/bzip2

$(DL_DIR)/$(BZIP2_SOURCE):
	$(DOWNLOAD) $(BZIP2_SITE)/$(BZIP2_SOURCE)

BZIP2_PATCH  = bzip2.patch

bzip2: $(DL_DIR)/$(BZIP2_SOURCE) | $(TARGET_DIR)
	$(REMOVE)/$(BZIP2_DIR)
	$(UNTAR)/$(BZIP2_SOURCE)
	$(CHDIR)/$(BZIP2_DIR); \
		$(call apply_patches,$(BZIP2_PATCH)); \
		mv Makefile-libbz2_so Makefile; \
		$(MAKE_ENV) \
		$(MAKE); \
		$(MAKE) install PREFIX=$(TARGET_DIR)
	rm -f $(TARGET_bindir)/bzip2
	$(REMOVE)/$(BZIP2_DIR)
	$(TOUCH)

# -----------------------------------------------------------------------------

FONTCONFIG_VER    = 2.11.93
FONTCONFIG_DIR    = fontconfig-$(FONTCONFIG_VER)
FONTCONFIG_SOURCE = fontconfig-$(FONTCONFIG_VER).tar.bz2
FONTCONFIG_SITE   = https://www.freedesktop.org/software/fontconfig/release

$(DL_DIR)/$(FONTCONFIG_SOURCE):
	$(DOWNLOAD) $(FONTCONFIG_SITE)/$(FONTCONFIG_SOURCE)

FONTCONFIG_DEPS   = freetype expat

fontconfig: $(FONTCONFIG_DEPS) $(DL_DIR)/$(FONTCONFIG_SOURCE) | $(TARGET_DIR)
	$(REMOVE)/$(FONTCONFIG_DIR)
	$(UNTAR)/$(FONTCONFIG_SOURCE)
	$(CHDIR)/$(FONTCONFIG_DIR); \
		$(CONFIGURE) \
			--prefix=$(prefix) \
			--with-freetype-config=$(HOST_DIR)/bin/freetype-config \
			--with-expat-includes=$(TARGET_includedir) \
			--with-expat-lib=$(TARGET_libdir) \
			--sysconfdir=/etc \
			--disable-docs \
			; \
		$(MAKE); \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
	$(REWRITE_LIBTOOL_LA)
	$(REMOVE)/$(FONTCONFIG_DIR)
	$(TOUCH)

# -----------------------------------------------------------------------------

PIXMAN_VER    = 0.34.0
PIXMAN_DIR    = pixman-$(PIXMAN_VER)
PIXMAN_SOURCE = pixman-$(PIXMAN_VER).tar.gz
PIXMAN_SITE   = https://www.cairographics.org/releases

$(DL_DIR)/$(PIXMAN_SOURCE):
	$(DOWNLOAD) $(PIXMAN_SITE)/$(PIXMAN_SOURCE)

PIXMAN_PATCH  = pixman-0001-ARM-qemu-related-workarounds-in-cpu-features-detecti.patch
PIXMAN_PATCH += pixman-asm_include.patch
PIXMAN_PATCH += pixman-0001-test-utils-Check-for-FE_INVALID-definition-before-us.patch

PIXMAN_DEPS   = zlib libpng

pixman: $(PIXMAN_DEPS) $(DL_DIR)/$(PIXMAN_SOURCE) | $(TARGET_DIR)
	$(REMOVE)/$(PIXMAN_DIR)
	$(UNTAR)/$(PIXMAN_SOURCE)
	$(CHDIR)/$(PIXMAN_DIR); \
		$(call apply_patches,$(PIXMAN_PATCH)); \
		$(CONFIGURE) \
			--prefix=$(prefix) \
			--disable-gtk \
			--disable-arm-simd \
			--disable-loongson-mmi \
			--disable-docs \
			; \
		$(MAKE); \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
	$(REWRITE_LIBTOOL_LA)
	$(REMOVE)/$(PIXMAN_DIR)
	$(TOUCH)

# -----------------------------------------------------------------------------

CAIRO_VER    = 1.16.0
CAIRO_DIR    = cairo-$(CAIRO_VER)
CAIRO_SOURCE = cairo-$(CAIRO_VER).tar.xz
CAIRO_SITE   = https://www.cairographics.org/releases

$(DL_DIR)/$(CAIRO_SOURCE):
	$(DOWNLOAD) $(CAIRO_SITE)/$(CAIRO_SOURCE)

CAIRO_PATCH  = cairo-get_bitmap_surface.diff

CAIRO_DEPS   = fontconfig glib2 libpng pixman zlib

cairo: $(CAIRO_DEPS) $(DL_DIR)/$(CAIRO_SOURCE) | $(TARGET_DIR)
	$(REMOVE)/$(CAIRO_DIR)
	$(UNTAR)/$(CAIRO_SOURCE)
	$(CHDIR)/$(CAIRO_DIR); \
		$(call apply_patches,$(CAIRO_PATCH)); \
		$(MAKE_ENV) \
		ax_cv_c_float_words_bigendian="no" \
		./configure $(CONFIGURE_OPTS) \
			--prefix=$(prefix) \
			--with-x=no \
			--disable-xlib \
			--disable-xcb \
			--disable-egl \
			--disable-glesv2 \
			--disable-gl \
			--enable-tee \
			; \
		$(MAKE); \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
	rm -rf $(TARGET_bindir)/cairo-sphinx
	rm -rf $(TARGET_libdir)/cairo/cairo-fdr*
	rm -rf $(TARGET_libdir)/cairo/cairo-sphinx*
	rm -rf $(TARGET_libdir)/cairo/.debug/cairo-fdr*
	rm -rf $(TARGET_libdir)/cairo/.debug/cairo-sphinx*
	$(REWRITE_LIBTOOL_LA)
	$(REMOVE)/$(CAIRO_DIR)
	$(TOUCH)

# -----------------------------------------------------------------------------

HARFBUZZ_VER    = 1.8.8
HARFBUZZ_DIR    = harfbuzz-$(HARFBUZZ_VER)
HARFBUZZ_SOURCE = harfbuzz-$(HARFBUZZ_VER).tar.bz2
HARFBUZZ_SITE   = https://www.freedesktop.org/software/harfbuzz/release

$(DL_DIR)/$(HARFBUZZ_SOURCE):
	$(DOWNLOAD) $(HARFBUZZ_SITE)/$(HARFBUZZ_SOURCE)

HARFBUZZ_PATCH  = harfbuzz-disable-docs.patch

HARFBUZZ_DEPS   = fontconfig glib2 cairo freetype

harfbuzz: $(HARFBUZZ_DEPS) $(DL_DIR)/$(HARFBUZZ_SOURCE) | $(TARGET_DIR)
	$(REMOVE)/$(HARFBUZZ_DIR)
	$(UNTAR)/$(HARFBUZZ_SOURCE)
	$(CHDIR)/$(HARFBUZZ_DIR); \
		$(call apply_patches,$(HARFBUZZ_PATCH)); \
		autoreconf -fi; \
		$(CONFIGURE) \
			--prefix=$(prefix) \
			--with-cairo \
			--with-fontconfig \
			--with-freetype \
			--with-glib \
			--without-graphite2 \
			--without-icu \
			; \
		$(MAKE); \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
	$(REWRITE_LIBTOOL_LA)
	$(REMOVE)/$(HARFBUZZ_DIR)
	$(TOUCH)
