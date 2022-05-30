################################################################################
#
# usbutils
#
################################################################################

USBUTILS_VERSION = 014
USBUTILS_DIR = usbutils-$(USBUTILS_VERSION)
USBUTILS_SOURCE = usbutils-$(USBUTILS_VERSION).tar.xz
USBUTILS_SITE = $(KERNEL_MIRROR)/linux/utils/usb/usbutils

USBUTILS_DEPENDENCIES = libusb-compat libudev-zero

define USBUTILS_TARGET_CLEANUP
	$(TARGET_RM) $(addprefix $(TARGET_bindir)/,lsusb.py usbhid-dump)
endef
USBUTILS_TARGET_FINALIZE_HOOKS += USBUTILS_TARGET_CLEANUP

usbutils: | $(TARGET_DIR)
	$(call autotools-package)
