################################################################################
#
# libusb
#
################################################################################

LIBUSB_VERSION = 1.0.23
LIBUSB_DIR = libusb-$(LIBUSB_VERSION)
LIBUSB_SOURCE = libusb-$(LIBUSB_VERSION).tar.bz2
LIBUSB_SITE = https://github.com/libusb/libusb/releases/download/v$(LIBUSB_VERSION)

LIBUSB_CONF_OPTS = \
	--disable-udev

libusb: | $(TARGET_DIR)
	$(call autotools-package)
