################################################################################
#
# pixman
#
################################################################################

PIXMAN_VERSION = 0.34.0
PIXMAN_DIR = pixman-$(PIXMAN_VERSION)
PIXMAN_SOURCE = pixman-$(PIXMAN_VERSION).tar.gz
PIXMAN_SITE = https://www.cairographics.org/releases

PIXMAN_DEPENDENCIES = zlib libpng

PIXMAN_CONF_OPTS = \
	--disable-gtk \
	--disable-arm-simd \
	--disable-loongson-mmi \
	--disable-docs

pixman: | $(TARGET_DIR)
	$(call autotools-package)
