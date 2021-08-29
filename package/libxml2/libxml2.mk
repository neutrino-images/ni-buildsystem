################################################################################
#
# libxml2
#
################################################################################

LIBXML2_VERSION = 2.9.12
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

define LIBXML2_TARGET_CLEANUP
	$(TARGET_RM) $(addprefix $(TARGET_libdir)/,cmake xml2Conf.sh)
endef
LIBXML2_TARGET_FINALIZE_HOOKS += LIBXML2_TARGET_CLEANUP

libxml2: | $(TARGET_DIR)
	$(call autotools-package)
