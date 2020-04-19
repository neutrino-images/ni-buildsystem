#
# makefile to build system tools (currently unused in ni-image)
#
# -----------------------------------------------------------------------------

# usbutils-008 needs udev
USBUTILS_VER    = 007
USBUTILS_TMP    = usbutils-$(USBUTILS_VER)
USBUTILS_SOURCE = usbutils-$(USBUTILS_VER).tar.xz
USBUTILS_URL    = https://www.kernel.org/pub/linux/utils/usb/usbutils

$(ARCHIVE)/$(USBUTILS_SOURCE):
	$(DOWNLOAD) $(USBUTILS_URL)/$(USBUTILS_SOURCE)

USBUTILS_PATCH  = usbutils-avoid-dependency-on-bash.patch
USBUTILS_PATCH += usbutils-fix-null-pointer-crash.patch

USBUTILS_DEPS   = libusb-compat

usbutils: $(USBUTILS_DEPS) $(ARCHIVE)/$(USBUTILS_SOURCE) | $(TARGET_DIR)
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

BINUTILS_VER    = 2.25
BINUTILS_TMP    = binutils-$(BINUTILS_VER)
BINUTILS_SOURCE = binutils-$(BINUTILS_VER).tar.bz2
BINUTILS_URL    = https://ftp.gnu.org/gnu/binutils

$(ARCHIVE)/$(BINUTILS_SOURCE):
	$(DOWNLOAD) $(BINUTILS_URL)/$(BINUTILS_SOURCE)

binutils: $(ARCHIVE)/$(BINUTILS_SOURCE) | $(TARGET_DIR)
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
		$(INSTALL_EXEC) binutils/objdump $(TARGET_BIN_DIR)/
		$(INSTALL_EXEC) binutils/objcopy $(TARGET_BIN_DIR)/
	$(REMOVE)/$(BINUTILS_TMP)
	$(TOUCH)

# -----------------------------------------------------------------------------

UTIL-LINUX_ABIVER = 2.35
UTIL-LINUX_VER    = 2.35
UTIL-LINUX_TMP    = util-linux-$(UTIL-LINUX_VER)
UTIL-LINUX_SOURCE = util-linux-$(UTIL-LINUX_VER).tar.xz
UTIL-LINUX_URL    = https://www.kernel.org/pub/linux/utils/util-linux/v$(UTIL-LINUX_ABIVER)

$(ARCHIVE)/$(UTIL-LINUX_SOURCE):
	$(DOWNLOAD) $(UTIL-LINUX_URL)/$(UTIL-LINUX_SOURCE)

UTUL-LINUX_DEPS   = ncurses zlib

util-linux: $(UTUL-LINUX_DEPS) $(ARCHIVE)/$(UTIL-LINUX_SOURCE) | $(TARGET_DIR)
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
	$(REWRITE_PKGCONF)/fdisk.pc
	$(REWRITE_PKGCONF)/smartcols.pc
	$(REWRITE_PKGCONF)/uuid.pc
	$(REWRITE_LIBTOOL)/libfdisk.la
	$(REWRITE_LIBTOOL)/libsmartcols.la
	$(REWRITE_LIBTOOL)/libuuid.la
	$(REMOVE)/$(UTIL-LINUX_TMP)
	$(TOUCH)

# -----------------------------------------------------------------------------

ASTRA-SM_VER    = git
ASTRA-SM_TMP    = astra-sm.$(ASTRA-SM_VER)
ASTRA-SM_SOURCE = astra-sm.$(ASTRA-SM_VER)
ASTRA-SM_URL    = https://gitlab.com/crazycat69

ASTRA-SM_DEPS   = openssl

# workaround unrecognized command line options
astra-sm: TARGET_ABI=""
astra-sm: $(ASTRA-SM_DEPS) | $(TARGET_DIR)
	$(REMOVE)/$(ASTRA-SM_TMP)
	$(GET-GIT-SOURCE) $(ASTRA-SM_URL)/$(ASTRA-SM_SOURCE) $(ARCHIVE)/$(ASTRA-SM_SOURCE)
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

IOZONE_VER    = 482
IOZONE_TMP    = iozone3_$(IOZONE_VER)
IOZONE_SOURCE = iozone3_$(IOZONE_VER).tar
IOZONE_URL    = http://www.iozone.org/src/current

$(ARCHIVE)/$(IOZONE_SOURCE):
	$(DOWNLOAD) $(IOZONE_URL)/$(IOZONE_SOURCE)

iozone3: $(ARCHIVE)/$(IOZONE_SOURCE) | $(TARGET_DIR)
	$(REMOVE)/$(IOZONE_TMP)
	$(UNTAR)/$(IOZONE_SOURCE)
	$(CHDIR)/$(IOZONE_TMP)/src/current; \
		sed -i -e "s/= gcc/= $(TARGET_CC)/" makefile; \
		sed -i -e "s/= cc/= $(TARGET_CC)/" makefile; \
		$(BUILD_ENV) \
		$(MAKE) linux-arm; \
		$(INSTALL_EXEC) iozone $(TARGET_BIN_DIR)/
	$(REMOVE)/$(IOZONE_TMP)
	$(TOUCH)

# -----------------------------------------------------------------------------

READLINE_VER    = 8.0
READLINE_TMP    = readline-$(READLINE_VER)
READLINE_SOURCE = readline-$(READLINE_VER).tar.gz
READLINE_URL    = https://ftp.gnu.org/gnu/readline

$(ARCHIVE)/$(READLINE_SOURCE):
	$(DOWNLOAD) $(READLINE_URL)/$(READLINE_SOURCE)

readline: $(ARCHIVE)/$(READLINE_SOURCE) | $(TARGET_DIR)
	$(REMOVE)/$(READLINE_TMP)
	$(UNTAR)/$(READLINE_SOURCE)
	$(CHDIR)/$(READLINE_TMP); \
		$(CONFIGURE) \
			--prefix= \
			--datarootdir=$(remove-datarootdir) \
			; \
		$(MAKE) all; \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
	$(REWRITE_PKGCONF)/readline.pc
	$(REMOVE)/$(READLINE_TMP)
	$(TOUCH)
