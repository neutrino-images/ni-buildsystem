################################################################################
#
# flac
#
################################################################################

FLAC_VERSION = 1.3.4
FLAC_DIR = flac-$(FLAC_VERSION)
FLAC_SOURCE = flac-$(FLAC_VERSION).tar.xz
FLAC_SITE = http://downloads.xiph.org/releases/flac

FLAC_AUTORECONF = YES

FLAC_CONF_OPTS = \
	--bindir=$(REMOVE_bindir) \
	--datarootdir=$(REMOVE_datarootdir) \
	--enable-shared \
	--disable-static \
	--disable-cpplibs \
	--disable-xmms-plugin \
	--disable-altivec \
	--disable-ogg \
	--disable-sse

flac: | $(TARGET_DIR)
	$(call autotools-package)
