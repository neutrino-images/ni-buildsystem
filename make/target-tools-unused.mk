#
# makefile to build system tools (currently unused in ni-image)
#
# -----------------------------------------------------------------------------

# usbutils-008 needs udev
USBUTILS_VER    = 007
USBUTILS_DIR    = usbutils-$(USBUTILS_VER)
USBUTILS_SOURCE = usbutils-$(USBUTILS_VER).tar.xz
USBUTILS_SITE   = $(KERNEL_MIRROR)/linux/utils/usb/usbutils

$(DL_DIR)/$(USBUTILS_SOURCE):
	$(DOWNLOAD) $(USBUTILS_SITE)/$(USBUTILS_SOURCE)

USBUTILS_DEPS = libusb-compat

usbutils: $(USBUTILS_DEPS) $(DL_DIR)/$(USBUTILS_SOURCE) | $(TARGET_DIR)
	$(REMOVE)/$(PKG_DIR)
	$(UNTAR)/$(PKG_SOURCE)
	$(CHDIR)/$(PKG_DIR); \
		$(APPLY_PATCHES); \
		$(CONFIGURE); \
		$(MAKE); \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
	rm -rf $(TARGET_bindir)/lsusb.py
	rm -rf $(TARGET_bindir)/usbhid-dump
	rm -rf $(TARGET_sbindir)/update-usbids.sh
	rm -rf $(TARGET_datadir)/pkgconfig
	rm -rf $(TARGET_datadir)/usb.ids.gz
	$(REMOVE)/$(PKG_DIR)
	$(TOUCH)

# -----------------------------------------------------------------------------

BINUTILS_VER    = 2.35
BINUTILS_DIR    = binutils-$(BINUTILS_VER)
BINUTILS_SOURCE = binutils-$(BINUTILS_VER).tar.bz2
BINUTILS_SITE   = $(GNU_MIRROR)/binutils

$(DL_DIR)/$(BINUTILS_SOURCE):
	$(DOWNLOAD) $(BINUTILS_SITE)/$(BINUTILS_SOURCE)

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

BASE_PASSWD_VER    = 3.5.29
BASE_PASSWD_DIR    = base-passwd-$(BASE_PASSWD_VER)
BASE_PASSWD_SOURCE = base-passwd_$(BASE_PASSWD_VER).tar.gz
BASE_PASSWD_SITE   = https://launchpad.net/debian/+archive/primary/+files

$(DL_DIR)/$(BASE_PASSWD_SOURCE):
	$(DOWNLOAD) $(BASE_PASSWD_SITE)/$(BASE_PASSWD_SOURCE)

base-passwd: $(DL_DIR)/$(BASE_PASSWD_SOURCE) | $(TARGET_DIR)
	$(REMOVE)/$(PKG_DIR)
	$(UNTAR)/$(PKG_SOURCE)
	$(CHDIR)/$(PKG_DIR); \
		$(APPLY_PATCHES); \
		$(CONFIGURE); \
		$(MAKE); \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
	$(INSTALL_DATA) -D $(PKG_BUILD_DIR)/group.master $(TARGET_datadir)/base-passwd/group.master
	$(INSTALL_DATA) -D $(PKG_BUILD_DIR)/passwd.master $(TARGET_datadir)/base-passwd/passwd.master
	$(REMOVE)/$(PKG_DIR)
	$(TOUCH)

# -----------------------------------------------------------------------------

SHADOW_VER    = 4.8.1
SHADOW_DIR    = shadow-$(SHADOW_VER)
SHADOW_SOURCE = shadow-$(SHADOW_VER).tar.xz
SHADOW_SITE   = https://github.com/shadow-maint/shadow/releases/download/$(SHADOW_VER)

$(DL_DIR)/$(SHADOW_SOURCE):
	$(DOWNLOAD) $(SHADOW_SITE)/$(SHADOW_SOURCE)

SHADOW_CONF_OPTS = \
	--prefix=$(base_prefix) \
	--datarootdir=$(REMOVE_base_datarootdir)

shadow: $(DL_DIR)/$(SHADOW_SOURCE) | $(TARGET_DIR)
	$(REMOVE)/$(PKG_DIR)
	$(UNTAR)/$(PKG_SOURCE)
	$(CHDIR)/$(PKG_DIR); \
		$(CONFIGURE); \
		$(MAKE); \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
	$(SED) 's|SHELL=.*|SHELL=/bin/sh|' $(TARGET_sysconfdir)/default/useradd
	mkdir -p $(TARGET_sysconfdir)/skel
	$(REMOVE)/$(PKG_DIR)
	$(TOUCH)

# -----------------------------------------------------------------------------

BZIP2_VER    = 1.0.8
BZIP2_DIR    = bzip2-$(BZIP2_VER)
BZIP2_SOURCE = bzip2-$(BZIP2_VER).tar.gz
BZIP2_SITE   = https://sourceware.org/pub/bzip2

$(DL_DIR)/$(BZIP2_SOURCE):
	$(DOWNLOAD) $(BZIP2_SITE)/$(BZIP2_SOURCE)

bzip2: $(DL_DIR)/$(BZIP2_SOURCE) | $(TARGET_DIR)
	$(REMOVE)/$(PKG_DIR)
	$(UNTAR)/$(PKG_SOURCE)
	$(CHDIR)/$(PKG_DIR); \
		$(APPLY_PATCHES); \
		mv Makefile-libbz2_so Makefile; \
		$(TARGET_CONFIGURE_ENV) \
		$(MAKE); \
		$(MAKE) install PREFIX=$(TARGET_prefix)
	rm -f $(TARGET_bindir)/bzip2
	$(REMOVE)/$(PKG_DIR)
	$(TOUCH)

# -----------------------------------------------------------------------------

ASTRA_SM_VER    = git
ASTRA_SM_DIR    = astra-sm.$(ASTRA_SM_VER)
ASTRA_SM_SOURCE = astra-sm.$(ASTRA_SM_VER)
ASTRA_SM_SITE   = https://gitlab.com/crazycat69

ASTRA_SM_DEPS = openssl

ASTRA_SM_AUTORECONF = YES

ASTRA_SM_CONF_OPTS = \
	--without-lua

astra-sm: $(ASTRA_SM_DEPS) | $(TARGET_DIR)
	$(REMOVE)/$(ASTRA_SM_DIR)
	$(GET-GIT-SOURCE) $(ASTRA_SM_SITE)/$(ASTRA_SM_SOURCE) $(DL_DIR)/$(ASTRA_SM_SOURCE)
	$(CPDIR)/$(ASTRA_SM_SOURCE)
	$(CHDIR)/$(ASTRA_SM_DIR); \
		sed -i 's:(CFLAGS):(CFLAGS_FOR_BUILD):' tools/Makefile.am; \
		$(CONFIGURE); \
		$(MAKE); \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
	$(REMOVE)/$(ASTRA_SM_DIR)
	$(TOUCH)

# -----------------------------------------------------------------------------

IOZONE_VER    = 3_490
IOZONE_DIR    = iozone$(IOZONE_VER)
IOZONE_SOURCE = iozone$(IOZONE_VER).tar
IOZONE_SITE   = http://www.iozone.org/src/current

$(DL_DIR)/$(IOZONE_SOURCE):
	$(DOWNLOAD) $(IOZONE_SITE)/$(IOZONE_SOURCE)

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

READLINE_VER    = 8.1
READLINE_DIR    = readline-$(READLINE_VER)
READLINE_SOURCE = readline-$(READLINE_VER).tar.gz
READLINE_SITE   = $(GNU_MIRROR)/readline

$(DL_DIR)/$(READLINE_SOURCE):
	$(DOWNLOAD) $(READLINE_SITE)/$(READLINE_SOURCE)

READLINE_CONF_OPTS = \
	--datarootdir=$(REMOVE_datarootdir)

readline: $(DL_DIR)/$(READLINE_SOURCE) | $(TARGET_DIR)
	$(REMOVE)/$(PKG_DIR)
	$(UNTAR)/$(PKG_SOURCE)
	$(CHDIR)/$(PKG_DIR); \
		$(CONFIGURE); \
		$(MAKE); \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
	$(REMOVE)/$(PKG_DIR)
	$(TOUCH)

# -----------------------------------------------------------------------------

LIBZEN_VER    = 0.4.38
LIBZEN_DIR    = ZenLib
LIBZEN_SOURCE = libzen_$(LIBZEN_VER).tar.bz2
LIBZEN_SITE   = https://mediaarea.net/download/source/libzen/$(LIBZEN_VER)

$(DL_DIR)/$(LIBZEN_SOURCE):
	$(DOWNLOAD) $(LIBZEN_SITE)/$(LIBZEN_SOURCE)

LIBZEN_DEPS = zlib

LIBZEN_AUTORECONF = YES

libzen: $(LIBZEN_DEPS) $(DL_DIR)/$(LIBZEN_SOURCE) | $(TARGET_DIR)
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

LIBMEDIAINFO_VER    = 20.08
LIBMEDIAINFO_DIR    = MediaInfoLib
LIBMEDIAINFO_SOURCE = libmediainfo_$(LIBMEDIAINFO_VER).tar.bz2
LIBMEDIAINFO_SITE   = https://mediaarea.net/download/source/libmediainfo/$(LIBMEDIAINFO_VER)

$(DL_DIR)/$(LIBMEDIAINFO_SOURCE):
	$(DOWNLOAD) $(LIBMEDIAINFO_SITE)/$(LIBMEDIAINFO_SOURCE)

LIBMEDIAINFO_DEPS = libzen

LIBMEDIAINFO_AUTORECONF = YES

libmediainfo: $(LIBMEDIAINFO_DEPS) $(DL_DIR)/$(LIBMEDIAINFO_SOURCE) | $(TARGET_DIR)
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

MEDIAINFO_VER    = 20.08
MEDIAINFO_DIR    = MediaInfo
MEDIAINFO_SOURCE = mediainfo_$(MEDIAINFO_VER).tar.bz2
MEDIAINFO_SITE   = https://mediaarea.net/download/source/mediainfo/$(MEDIAINFO_VER)

$(DL_DIR)/$(MEDIAINFO_SOURCE):
	$(DOWNLOAD) $(MEDIAINFO_SITE)/$(MEDIAINFO_SOURCE)

MEDIAINFO_DEPS = libmediainfo

MEDIAINFO_AUTORECONF = YES

mediainfo: $(MEDIAINFO_DEPS) $(DL_DIR)/$(MEDIAINFO_SOURCE) | $(TARGET_DIR)
	$(REMOVE)/$(MEDIAINFO_DIR)
	$(UNTAR)/$(MEDIAINFO_SOURCE)
	$(CHDIR)/$(MEDIAINFO_DIR)/Project/GNU/CLI; \
		$(CONFIGURE); \
		$(MAKE); \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
	$(REMOVE)/$(MEDIAINFO_DIR)
	$(TOUCH)
