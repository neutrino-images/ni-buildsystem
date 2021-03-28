#
# makefile to build system tools (currently unused in ni-image)
#
# -----------------------------------------------------------------------------

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

# -----------------------------------------------------------------------------

BINUTILS_VERSION = 2.35
BINUTILS_DIR = binutils-$(BINUTILS_VERSION)
BINUTILS_SOURCE = binutils-$(BINUTILS_VERSION).tar.bz2
BINUTILS_SITE = $(GNU_MIRROR)/binutils

$(DL_DIR)/$(BINUTILS_SOURCE):
	$(download) $(BINUTILS_SITE)/$(BINUTILS_SOURCE)

BINUTILS_CONF_OPTS = \
	--disable-multilib \
	--disable-werror \
	--disable-plugins \
	--enable-build-warnings=no \
	--disable-sim \
	--disable-gdb 

BINUTILS_BINARIES = objdump objcopy

binutils: $(DL_DIR)/$(BINUTILS_SOURCE) | $(TARGET_DIR)
	$(REMOVE)/$(PKG_DIR)
	$(UNTAR)/$(PKG_SOURCE)
	$(CHDIR)/$(PKG_DIR); \
		$(CONFIGURE); \
		$(MAKE); \
	for bin in $($(PKG)_BINARIES); do \
		$(INSTALL_EXEC) $(BUILD_DIR)/$(PKG_DIR)/binutils/$$bin $(TARGET_bindir)/; \
	done
	$(REMOVE)/$(PKG_DIR)
	$(TOUCH)

# -----------------------------------------------------------------------------

BZIP2_VERSION = 1.0.8
BZIP2_DIR = bzip2-$(BZIP2_VERSION)
BZIP2_SOURCE = bzip2-$(BZIP2_VERSION).tar.gz
BZIP2_SITE = https://sourceware.org/pub/bzip2

$(DL_DIR)/$(BZIP2_SOURCE):
	$(download) $(BZIP2_SITE)/$(BZIP2_SOURCE)

bzip2: $(DL_DIR)/$(BZIP2_SOURCE) | $(TARGET_DIR)
	$(REMOVE)/$(PKG_DIR)
	$(UNTAR)/$(PKG_SOURCE)
	$(call APPLY_PATCHES,$(PKG_PATCHES_DIR))
	$(CHDIR)/$(PKG_DIR); \
		mv Makefile-libbz2_so Makefile; \
		$(TARGET_CONFIGURE_ENV) \
		$(MAKE); \
		$(MAKE) install PREFIX=$(TARGET_prefix)
	$(TARGET_RM) $(TARGET_bindir)/bzip2
	$(REMOVE)/$(PKG_DIR)
	$(TOUCH)

# -----------------------------------------------------------------------------

IOZONE_VERSION = 3_490
IOZONE_DIR = iozone$(IOZONE_VERSION)
IOZONE_SOURCE = iozone$(IOZONE_VERSION).tar
IOZONE_SITE = http://www.iozone.org/src/current

$(DL_DIR)/$(IOZONE_SOURCE):
	$(download) $(IOZONE_SITE)/$(IOZONE_SOURCE)

iozone: $(DL_DIR)/$(IOZONE_SOURCE) | $(TARGET_DIR)
	$(REMOVE)/$(PKG_DIR)
	$(UNTAR)/$(PKG_SOURCE)
	$(CHDIR)/$(PKG_DIR)/src/current; \
		$(SED) "s/= gcc/= $(TARGET_CC)/" makefile; \
		$(SED) "s/= cc/= $(TARGET_CC)/" makefile; \
		$(TARGET_CONFIGURE_ENV) \
		$(MAKE) linux-arm; \
		$(INSTALL_EXEC) -D iozone $(TARGET_bindir)/iozone
	$(REMOVE)/$(PKG_DIR)
	$(TOUCH)

# -----------------------------------------------------------------------------

LIBZEN_VERSION = 0.4.38
LIBZEN_DIR = ZenLib
LIBZEN_SOURCE = libzen_$(LIBZEN_VERSION).tar.bz2
LIBZEN_SITE = https://mediaarea.net/download/source/libzen/$(LIBZEN_VERSION)

$(DL_DIR)/$(LIBZEN_SOURCE):
	$(download) $(LIBZEN_SITE)/$(LIBZEN_SOURCE)

LIBZEN_DEPENDENCIES = zlib

LIBZEN_AUTORECONF = YES

libzen: $(LIBZEN_DEPENDENCIES) $(DL_DIR)/$(LIBZEN_SOURCE) | $(TARGET_DIR)
	$(REMOVE)/$(PKG_DIR)
	$(UNTAR)/$(PKG_SOURCE)
	$(CHDIR)/$(PKG_DIR)/Project/GNU/Library; \
		$(CONFIGURE); \
		$(MAKE); \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
	$(REWRITE_LIBTOOL)
	$(REMOVE)/$(PKG_DIR)
	$(TOUCH)

# -----------------------------------------------------------------------------

LIBMEDIAINFO_VERSION = 20.08
LIBMEDIAINFO_DIR = MediaInfoLib
LIBMEDIAINFO_SOURCE = libmediainfo_$(LIBMEDIAINFO_VERSION).tar.bz2
LIBMEDIAINFO_SITE = https://mediaarea.net/download/source/libmediainfo/$(LIBMEDIAINFO_VERSION)

$(DL_DIR)/$(LIBMEDIAINFO_SOURCE):
	$(download) $(LIBMEDIAINFO_SITE)/$(LIBMEDIAINFO_SOURCE)

LIBMEDIAINFO_DEPENDENCIES = libzen

LIBMEDIAINFO_AUTORECONF = YES

libmediainfo: $(LIBMEDIAINFO_DEPENDENCIES) $(DL_DIR)/$(LIBMEDIAINFO_SOURCE) | $(TARGET_DIR)
	$(REMOVE)/$(PKG_DIR)
	$(UNTAR)/$(PKG_SOURCE)
	$(CHDIR)/$(PKG_DIR)/Project/GNU/Library; \
		$(CONFIGURE); \
		$(MAKE); \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
	$(REWRITE_LIBTOOL)
	$(REMOVE)/$(PKG_DIR)
	$(TOUCH)

# -----------------------------------------------------------------------------

MEDIAINFO_VERSION = 20.08
MEDIAINFO_DIR = MediaInfo
MEDIAINFO_SOURCE = mediainfo_$(MEDIAINFO_VERSION).tar.bz2
MEDIAINFO_SITE = https://mediaarea.net/download/source/mediainfo/$(MEDIAINFO_VERSION)

$(DL_DIR)/$(MEDIAINFO_SOURCE):
	$(download) $(MEDIAINFO_SITE)/$(MEDIAINFO_SOURCE)

MEDIAINFO_DEPENDENCIES = libmediainfo

MEDIAINFO_AUTORECONF = YES

mediainfo: $(MEDIAINFO_DEPENDENCIES) $(DL_DIR)/$(MEDIAINFO_SOURCE) | $(TARGET_DIR)
	$(REMOVE)/$(MEDIAINFO_DIR)
	$(UNTAR)/$(MEDIAINFO_SOURCE)
	$(CHDIR)/$(MEDIAINFO_DIR)/Project/GNU/CLI; \
		$(CONFIGURE); \
		$(MAKE); \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
	$(REMOVE)/$(MEDIAINFO_DIR)
	$(TOUCH)
