################################################################################
#
# libogg
#
################################################################################

LIBOGG_VERSION = 1.3.5
LIBOGG_DIR = libogg-$(LIBOGG_VERSION)
LIBOGG_SOURCE = libogg-$(LIBOGG_VERSION).tar.gz
LIBOGG_SITE = https://ftp.osuosl.org/pub/xiph/releases/ogg

LIBOGG_CONF_OPTS = \
	--datarootdir=$(REMOVE_datarootdir) \
	--enable-shared

libogg: | $(TARGET_DIR)
	$(call autotools-package)
