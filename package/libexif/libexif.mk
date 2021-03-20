################################################################################
#
# libexif
#
################################################################################

LIBEXIF_VERSION = 0.6.22
LIBEXIF_DIR = libexif-$(LIBEXIF_VERSION)
LIBEXIF_SOURCE = libexif-$(LIBEXIF_VERSION).tar.xz
LIBEXIF_SITE = https://github.com/libexif/libexif/releases/download/libexif-$(subst .,_,$(LIBEXIF_VERSION))-release

LIBEXIF_CONF_OPTS = \
	--datarootdir=$(REMOVE_datarootdir) \
	--with-doc-dir=$(REMOVE_docdir)

libexif: | $(TARGET_DIR)
	$(call autotools-package)
