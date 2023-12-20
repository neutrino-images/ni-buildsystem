################################################################################
#
# brotli
#
################################################################################

BROTLI_VERSION = 1.1.0
BROTLI_DIR = brotli-$(BROTLI_VERSION)
BROTLI_SOURCE = brotli-$(BROTLI_VERSION).tar.gz
BROTLI_SITE = $(call github,google,brotli,v$(BROTLI_VERSION))

BROTLI_CONF_OPTS = \
	-DBROTLI_DISABLE_TESTS=ON \
	-DBROTLI_BUNDLED_MODE=OFF

brotli: | $(TARGET_DIR)
	$(call cmake-package)
