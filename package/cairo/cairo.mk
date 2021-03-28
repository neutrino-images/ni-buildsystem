################################################################################
#
# cairo
#
################################################################################

CAIRO_VERSION = 1.16.0
CAIRO_DIR = cairo-$(CAIRO_VERSION)
CAIRO_SOURCE = cairo-$(CAIRO_VERSION).tar.xz
CAIRO_SITE = https://www.cairographics.org/releases

$(DL_DIR)/$(CAIRO_SOURCE):
	$(download) $(CAIRO_SITE)/$(CAIRO_SOURCE)

CAIRO_DEPENDENCIES = fontconfig glib2 libpng pixman zlib

CAIRO_CONF_ENV = \
	ax_cv_c_float_words_bigendian="no"

CAIRO_CONF_OPTS = \
	--with-html-dir=$(REMOVE_htmldir) \
	--with-x=no \
	--disable-xlib \
	--disable-xcb \
	--disable-egl \
	--disable-glesv2 \
	--disable-gl \
	--enable-tee

define CAIRO_TARGET_CLEANUP
	$(TARGET_RM) $(addprefix $(TARGET_bindir)/,cairo-sphinx)
	$(TARGET_RM) $(addprefix $(TARGET_libdir)/cairo/,cairo-fdr* cairo-sphinx*)
	$(TARGET_RM) $(addprefix $(TARGET_libdir)/cairo/.debug/,cairo-fdr* cairo-sphinx*)
endef
CAIRO_TARGET_FINALIZE_HOOKS += CAIRO_TARGET_CLEANUP

cairo: $(CAIRO_DEPENDENCIES) $(DL_DIR)/$(CAIRO_SOURCE) | $(TARGET_DIR)
	$(call autotools-package)
