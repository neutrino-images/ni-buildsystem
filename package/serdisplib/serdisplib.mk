################################################################################
#
# serdisplib
#
################################################################################

SERDISPLIB_VERSION = 2.02
SERDISPLIB_DIR = serdisplib-$(SERDISPLIB_VERSION)
SERDISPLIB_SOURCE = serdisplib-$(SERDISPLIB_VERSION).tar.gz
SERDISPLIB_SITE = https://sourceforge.net/projects/serdisplib/files/serdisplib/$(SERDISPLIB_VERSION)

SERDISPLIB_DEPENDS = libusb-compat

SERDISPLIB_CONF_OPTS = \
	--bindir=$(REMOVE_bindir) \
	--disable-libSDL \
	--disable-libusb \
	--disable-libdlo \
	--with-drivers='framebuffer'

serdisplib: | $(TARGET_DIR)
	$(call autotools-package)
