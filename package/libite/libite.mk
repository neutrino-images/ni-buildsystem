################################################################################
#
# libite
#
################################################################################

LIBITE_VERSION = 2.5.2
LIBITE_DIR = libite-$(LIBITE_VERSION)
LIBITE_SOURCE = libite-$(LIBITE_VERSION).tar.xz
LIBITE_SITE = https://github.com/troglobit/libite/releases/download/v$(LIBITE_VERSION)

LIBITE_CONF_OPTS = \
	--docdir=$(REMOVE_docdir) \
	--enable-static \
	--disable-shared

libite: | $(TARGET_DIR)
	$(call autotools-package)
