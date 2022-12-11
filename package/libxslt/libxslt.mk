################################################################################
#
# libxslt
#
################################################################################

LIBXSLT_VERSION = 1.1.37
LIBXSLT_DIR = libxslt-$(LIBXSLT_VERSION)
LIBXSLT_SOURCE = libxslt-$(LIBXSLT_VERSION).tar.xz
LIBXSLT_SITE = https://download.gnome.org/sources/libxslt/1.1

LIBXSLT_DEPENDENCIES = libxml2

LIBXSLT_CONFIG_SCRIPTS = xslt-config

LIBXSLT_CONF_OPTS = \
	--datarootdir=$(REMOVE_datarootdir) \
	--with-gnu-ld \
	--without-debug \
	--without-python \
	--without-crypto

define LIBXSLT_TARGET_CLEANUP
	$(TARGET_RM) $(addprefix $(TARGET_libdir)/,xsltConf.sh)
endef
LIBXSLT_TARGET_FINALIZE_HOOKS += LIBXSLT_TARGET_CLEANUP

libxslt: | $(TARGET_DIR)
	$(call autotools-package)
