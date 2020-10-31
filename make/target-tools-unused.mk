#
# makefile to build system tools (currently unused in ni-image)
#
# -----------------------------------------------------------------------------

# usbutils-008 needs udev
USBUTILS_VER    = 007
USBUTILS_TMP    = usbutils-$(USBUTILS_VER)
USBUTILS_SOURCE = usbutils-$(USBUTILS_VER).tar.xz
USBUTILS_SITE   = https://www.kernel.org/pub/linux/utils/usb/usbutils

$(DL_DIR)/$(USBUTILS_SOURCE):
	$(DOWNLOAD) $(USBUTILS_SITE)/$(USBUTILS_SOURCE)

USBUTILS_PATCH  = usbutils-avoid-dependency-on-bash.patch
USBUTILS_PATCH += usbutils-fix-null-pointer-crash.patch

USBUTILS_DEPS   = libusb-compat

usbutils: $(USBUTILS_DEPS) $(DL_DIR)/$(USBUTILS_SOURCE) | $(TARGET_DIR)
	$(REMOVE)/$(USBUTILS_TMP)
	$(UNTAR)/$(USBUTILS_SOURCE)
	$(CHDIR)/$(USBUTILS_TMP); \
		$(call apply_patches, $(USBUTILS_PATCH)); \
		$(CONFIGURE) \
			--target=$(TARGET) \
			--prefix= \
			--mandir=$(remove-mandir) \
			--infodir=$(remove-infodir) \
			; \
		$(MAKE); \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
	rm -rf $(TARGET_BIN_DIR)/lsusb.py
	rm -rf $(TARGET_BIN_DIR)/usbhid-dump
	rm -rf $(TARGET_DIR)/sbin/update-usbids.sh
	rm -rf $(TARGET_SHARE_DIR)/pkgconfig
	rm -rf $(TARGET_SHARE_DIR)/usb.ids.gz
	$(REMOVE)/$(USBUTILS_TMP)
	$(TOUCH)

# -----------------------------------------------------------------------------

BINUTILS_VER    = 2.35
BINUTILS_TMP    = binutils-$(BINUTILS_VER)
BINUTILS_SOURCE = binutils-$(BINUTILS_VER).tar.bz2
BINUTILS_SITE   = https://ftp.gnu.org/gnu/binutils

$(DL_DIR)/$(BINUTILS_SOURCE):
	$(DOWNLOAD) $(BINUTILS_SITE)/$(BINUTILS_SOURCE)

BINUTILS_BIN    = objdump objcopy

binutils: $(DL_DIR)/$(BINUTILS_SOURCE) | $(TARGET_DIR)
	$(REMOVE)/$(BINUTILS_TMP)
	$(UNTAR)/$(BINUTILS_SOURCE)
	$(CHDIR)/$(BINUTILS_TMP); \
		$(CONFIGURE) \
			--target=$(TARGET) \
			--prefix= \
			--disable-multilib \
			--disable-werror \
			--disable-plugins \
			--enable-build-warnings=no \
			--disable-sim \
			--disable-gdb \
			; \
		$(MAKE); \
	for bin in $(BINUTILS_BIN); do \
		$(INSTALL_EXEC) $(BUILD_TMP)/$(BINUTILS_TMP)/binutils/$$bin $(TARGET_DIR)/bin/; \
	done
	$(REMOVE)/$(BINUTILS_TMP)
	$(TOUCH)

# -----------------------------------------------------------------------------

UTIL-LINUX_VER    = 2.36
UTIL-LINUX_TMP    = util-linux-$(UTIL-LINUX_VER)
UTIL-LINUX_SOURCE = util-linux-$(UTIL-LINUX_VER).tar.xz
UTIL-LINUX_SITE   = https://www.kernel.org/pub/linux/utils/util-linux/v$(UTIL-LINUX_VER)

$(DL_DIR)/$(UTIL-LINUX_SOURCE):
	$(DOWNLOAD) $(UTIL-LINUX_SITE)/$(UTIL-LINUX_SOURCE)

UTUL-LINUX_DEPS   = ncurses zlib

util-linux: $(UTUL-LINUX_DEPS) $(DL_DIR)/$(UTIL-LINUX_SOURCE) | $(TARGET_DIR)
	$(REMOVE)/$(UTIL-LINUX_TMP)
	$(UNTAR)/$(UTIL-LINUX_SOURCE)
	$(CHDIR)/$(UTIL-LINUX_TMP); \
		autoreconf -fi; \
		$(CONFIGURE) \
			--prefix= \
			--datarootdir=$(remove-datarootdir) \
			--enable-static \
			--disable-shared \
			--disable-hardlink \
			--disable-gtk-doc \
			\
			--disable-all-programs \
				--enable-fdisks \
				--enable-libfdisk \
				--enable-libsmartcols \
				--enable-libuuid \
			--disable-bash-completion \
			\
			--disable-makeinstall-chown \
			--disable-makeinstall-setuid \
			--disable-makeinstall-chown \
			\
			--without-ncursesw \
			--without-python \
			--without-slang \
			--without-systemdsystemunitdir \
			--without-tinfo \
			; \
		$(MAKE); \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
	$(REWRITE_LIBTOOL_LA)
	$(REWRITE_PKGCONF_PC)
	$(REMOVE)/$(UTIL-LINUX_TMP)
	$(TOUCH)

# -----------------------------------------------------------------------------

ASTRA-SM_VER    = git
ASTRA-SM_TMP    = astra-sm.$(ASTRA-SM_VER)
ASTRA-SM_SOURCE = astra-sm.$(ASTRA-SM_VER)
ASTRA-SM_SITE   = https://gitlab.com/crazycat69

ASTRA-SM_DEPS   = openssl

# workaround unrecognized command line options
astra-sm: TARGET_ABI=""
astra-sm: $(ASTRA-SM_DEPS) | $(TARGET_DIR)
	$(REMOVE)/$(ASTRA-SM_TMP)
	$(GET-GIT-SOURCE) $(ASTRA-SM_SITE)/$(ASTRA-SM_SOURCE) $(DL_DIR)/$(ASTRA-SM_SOURCE)
	$(CPDIR)/$(ASTRA-SM_SOURCE)
	$(CHDIR)/$(ASTRA-SM_TMP); \
		autoreconf -fi; \
		$(CONFIGURE) \
			--prefix= \
			--without-lua \
			; \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
	$(REMOVE)/$(ASTRA-SM_TMP)
	$(TOUCH)

# -----------------------------------------------------------------------------

IOZONE_VER    = 3_490
IOZONE_TMP    = iozone$(IOZONE_VER)
IOZONE_SOURCE = iozone$(IOZONE_VER).tar
IOZONE_SITE   = http://www.iozone.org/src/current

$(DL_DIR)/$(IOZONE_SOURCE):
	$(DOWNLOAD) $(IOZONE_SITE)/$(IOZONE_SOURCE)

iozone: $(DL_DIR)/$(IOZONE_SOURCE) | $(TARGET_DIR)
	$(REMOVE)/$(IOZONE_TMP)
	$(UNTAR)/$(IOZONE_SOURCE)
	$(CHDIR)/$(IOZONE_TMP)/src/current; \
		sed -i -e "s/= gcc/= $(TARGET_CC)/" makefile; \
		sed -i -e "s/= cc/= $(TARGET_CC)/" makefile; \
		$(MAKE_ENV) \
		$(MAKE) linux-arm; \
		$(INSTALL_EXEC) iozone $(TARGET_BIN_DIR)/
	$(REMOVE)/$(IOZONE_TMP)
	$(TOUCH)

# -----------------------------------------------------------------------------

READLINE_VER    = 8.0
READLINE_TMP    = readline-$(READLINE_VER)
READLINE_SOURCE = readline-$(READLINE_VER).tar.gz
READLINE_SITE   = https://ftp.gnu.org/gnu/readline

$(DL_DIR)/$(READLINE_SOURCE):
	$(DOWNLOAD) $(READLINE_SITE)/$(READLINE_SOURCE)

readline: $(DL_DIR)/$(READLINE_SOURCE) | $(TARGET_DIR)
	$(REMOVE)/$(READLINE_TMP)
	$(UNTAR)/$(READLINE_SOURCE)
	$(CHDIR)/$(READLINE_TMP); \
		$(CONFIGURE) \
			--prefix= \
			--datarootdir=$(remove-datarootdir) \
			; \
		$(MAKE) all; \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
	$(REWRITE_PKGCONF_PC)
	$(REMOVE)/$(READLINE_TMP)
	$(TOUCH)
