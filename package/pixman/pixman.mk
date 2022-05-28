################################################################################
#
# pixman
#
################################################################################

PIXMAN_VERSION = 0.40.0
PIXMAN_DIR = pixman-$(PIXMAN_VERSION)
PIXMAN_SOURCE = pixman-$(PIXMAN_VERSION).tar.gz
PIXMAN_SITE = https://www.cairographics.org/releases

PIXMAN_DEPENDENCIES = zlib libpng

# For 0001-Disable-tests.patch
PIXMAN_AUTORECONF = YES

PIXMAN_CONF_OPTS = \
	--disable-gtk \
	--disable-loongson-mmi \
	--disable-arm-simd \
	--disable-arm-iwmmxt \
	--disable-docs

ifeq ($(BOXSERIES),$(filter $(BOXSERIES),hd5x hd6x vusolo4k vuduo4k vuduo4kse vuultimo4k vuzero4k vuuno4k vuuno4kse))
PIXMAN_CONF_OPTS += --enable-arm-neon
else
PIXMAN_CONF_OPTS += --disable-arm-neon
endif

pixman: | $(TARGET_DIR)
	$(call autotools-package)
