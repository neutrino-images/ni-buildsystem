################################################################################
#
# libpng
#
################################################################################

LIBPNG_VERSION = 1.6.37
LIBPNG_DIR = libpng-$(LIBPNG_VERSION)
LIBPNG_SOURCE = libpng-$(LIBPNG_VERSION).tar.xz
LIBPNG_SITE = https://sourceforge.net/projects/libpng/files/libpng16/$(LIBPNG_VERSION)

LIBPNG_DEPENDENCIES = zlib

LIBPNG_CONFIG_SCRIPTS = libpng16-config

LIBPNG_CONF_OPTS = \
	--disable-static \
	$(if $(filter $(BOXSERIES),hd5x hd6x vusolo4k vuduo4k vuduo4kse vuultimo4k vuzero4k vuuno4k vuuno4kse),--enable-arm-neon,--disable-arm-neon)

define LIBPNG_TARGET_CLEANUP
	$(TARGET_RM) $(addprefix $(TARGET_bindir)/,libpng-config)
endef
LIBPNG_TARGET_FINALIZE_HOOKS += LIBPNG_TARGET_CLEANUP

libpng: | $(TARGET_DIR)
	$(call autotools-package)
