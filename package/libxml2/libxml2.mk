################################################################################
#
# libxml2
#
################################################################################

LIBXML2_VERSION = 2.11.5
LIBXML2_DIR = libxml2-$(LIBXML2_VERSION)
LIBXML2_SOURCE = libxml2-$(LIBXML2_VERSION).tar.xz
LIBXML2_SITE = https://download.gnome.org/sources/libxml2/$(basename $(LIBXML2_VERSION))

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

define LIBXML2_TARGET_CLEANUP
	$(TARGET_RM) $(addprefix $(TARGET_libdir)/,cmake)
endef
LIBXML2_TARGET_FINALIZE_HOOKS += LIBXML2_TARGET_CLEANUP

libxml2: | $(TARGET_DIR)
	$(call autotools-package)
