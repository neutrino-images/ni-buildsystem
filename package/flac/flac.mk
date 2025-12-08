################################################################################
#
# flac
#
################################################################################

FLAC_VERSION = 1.5.0
FLAC_DIR = flac-$(FLAC_VERSION)
FLAC_SOURCE = flac-$(FLAC_VERSION).tar.xz
FLAC_SITE = https://ftp.osuosl.org/pub/xiph/releases/flac

FLAC_CONF_OPTS = \
	--bindir=$(REMOVE_bindir) \
	--datarootdir=$(REMOVE_datarootdir) \
	--enable-shared \
	--disable-static \
	--disable-cpplibs \
	--disable-debug \
	--disable-asm-optimizations \
	--disable-stack-smash-protection \
	--disable-doxygen-docs \
	--disable-thorough-tests \
	--disable-exhaustive-tests \
	--disable-valgrind-testing \
	--disable-ogg \
	--disable-oggtest \
	--disable-examples \
	--disable-rpath

flac: | $(TARGET_DIR)
	$(call autotools-package)
