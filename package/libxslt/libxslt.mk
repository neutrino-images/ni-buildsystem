################################################################################
#
# libxslt
#
################################################################################

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

define LIBXSLT_TARGET_CLEANUP
	-rm -r $(TARGET_libdir)/libxslt-plugins/
	-rm $(addprefix $(TARGET_libdir)/,xsltConf.sh)
endef
LIBXSLT_TARGET_FINALIZE_HOOKS += LIBXSLT_TARGET_CLEANUP

libxslt: | $(TARGET_DIR)
	$(call autotools-package)
