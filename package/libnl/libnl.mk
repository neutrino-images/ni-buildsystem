################################################################################
#
# libnl
#
################################################################################

LIBNL_VERSION = 3.7.0
LIBNL_DIR = libnl-$(LIBNL_VERSION)
LIBNL_SOURCE = libnl-$(LIBNL_VERSION).tar.gz
LIBNL_SITE = https://github.com/thom311/libnl/releases/download/libnl$(subst .,_,$(LIBNL_VERSION))

LIBNL_CONF_OPTS = \
	--disable-cli \
	--disable-unit-tests

libnl: | $(TARGET_DIR)
	$(call autotools-package)
