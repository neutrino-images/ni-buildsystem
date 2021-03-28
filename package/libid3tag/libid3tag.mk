################################################################################
#
# libid3tag
#
################################################################################

LIBID3TAG_VERSION = 0.15.1b
LIBID3TAG_DIR = libid3tag-$(LIBID3TAG_VERSION)
LIBID3TAG_SOURCE = libid3tag-$(LIBID3TAG_VERSION).tar.gz
LIBID3TAG_SITE = https://sourceforge.net/projects/mad/files/libid3tag/$(LIBID3TAG_VERSION)

LIBID3TAG_DEPENDENCIES = zlib

LIBID3TAG_AUTORECONF = YES

LIBID3TAG_CONF_OPTS = \
	--enable-shared=yes

libid3tag: | $(TARGET_DIR)
	$(call autotools-package)
