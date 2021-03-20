################################################################################
#
# libmad
#
################################################################################

LIBMAD_VERSION = 0.15.1b
LIBMAD_DIR = libmad-$(LIBMAD_VERSION)
LIBMAD_SOURCE = libmad-$(LIBMAD_VERSION).tar.gz
LIBMAD_SITE = https://sourceforge.net/projects/mad/files/libmad/$(LIBMAD_VERSION)

LIBMAD_AUTORECONF = YES

LIBMAD_CONF_OPTS = \
	--enable-shared=yes \
	--enable-accuracy \
	--enable-fpm=arm \
	--enable-sso

libmad: | $(TARGET_DIR)
	$(call autotools-package)
