################################################################################
#
# usbutils
#
################################################################################

# usbutils-008 needs udev
USBUTILS_VERSION = 007
USBUTILS_DIR = usbutils-$(USBUTILS_VERSION)
USBUTILS_SOURCE = usbutils-$(USBUTILS_VERSION).tar.xz
USBUTILS_SITE = $(KERNEL_MIRROR)/linux/utils/usb/usbutils

$(DL_DIR)/$(USBUTILS_SOURCE):
	$(download) $(USBUTILS_SITE)/$(USBUTILS_SOURCE)

USBUTILS_DEPENDENCIES = libusb-compat

usbutils: $(USBUTILS_DEPENDENCIES) $(DL_DIR)/$(USBUTILS_SOURCE) | $(TARGET_DIR)
	$(REMOVE)/$(PKG_DIR)
	$(UNTAR)/$(PKG_SOURCE)
	$(call APPLY_PATCHES,$(PKG_PATCHES_DIR))
	$(CHDIR)/$(PKG_DIR); \
		$(CONFIGURE); \
		$(MAKE); \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
	$(TARGET_RM) $(TARGET_bindir)/lsusb.py
	$(TARGET_RM) $(TARGET_bindir)/usbhid-dump
	$(TARGET_RM) $(TARGET_sbindir)/update-usbids.sh
	$(TARGET_RM) $(TARGET_datadir)/pkgconfig
	$(TARGET_RM) $(TARGET_datadir)/usb.ids.gz
	$(REMOVE)/$(PKG_DIR)
	$(TOUCH)
