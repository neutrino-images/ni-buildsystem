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

$(D)/usbutils: $(D)/libusb-compat $(ARCHIVE)/$(USBUTILS_SOURCE) | $(TARGET_DIR)
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

$(D)/binutils: $(ARCHIVE)/$(BINUTILS_SOURCE) | $(TARGET_DIR)
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

UTIL_LINUX_ABIVER = 2.34
UTIL_LINUX_VER    = 2.34
UTIL_LINUX_TMP    = util-linux-$(UTIL_LINUX_VER)
UTIL_LINUX_SOURCE = util-linux-$(UTIL_LINUX_VER).tar.xz
UTIL_LINUX_URL    = https://www.kernel.org/pub/linux/utils/util-linux/v$(UTIL_LINUX_ABIVER)

$(ARCHIVE)/$(UTIL_LINUX_SOURCE):
	$(DOWNLOAD) $(UTIL_LINUX_URL)/$(UTIL_LINUX_SOURCE)

$(D)/util-linux: $(D)/ncurses $(D)/zlib $(ARCHIVE)/$(UTIL_LINUX_SOURCE) | $(TARGET_DIR)
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

# workaround unrecognized command line options
$(D)/astra-sm: TARGET_ABI=""
$(D)/astra-sm: $(D)/openssl | $(TARGET_DIR)
	$(REMOVE)/$(ASTRA-SM_TMP)
	get-git-source.sh $(ASTRA-SM_URL)/$(ASTRA-SM_SOURCE) $(ARCHIVE)/$(ASTRA-SM_SOURCE)
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

$(D)/iozone3: $(ARCHIVE)/$(IOZONE_SOURCE) | $(TARGET_DIR)
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

RSYNC_VER    = 3.1.3
RSYNC_TMP    = rsync-$(RSYNC_VER)
RSYNC_SOURCE = rsync-$(RSYNC_VER).tar.gz
RSYNC_URL    = https://ftp.samba.org/pub/rsync

$(ARCHIVE)/$(RSYNC_SOURCE):
	$(DOWNLOAD) $(RSYNC_URL)/$(RSYNC_SOURCE)

$(D)/rsync: $(D)/zlib $(D)/popt $(ARCHIVE)/$(RSYNC_SOURCE) | $(TARGET_DIR)
	$(REMOVE)/$(RSYNC_TMP)
	$(UNTAR)/$(RSYNC_SOURCE)
	$(CHDIR)/$(RSYNC_TMP); \
		$(CONFIGURE) \
			--prefix= \
			--mandir=$(remove-mandir) \
			--disable-debug \
			--disable-locale \
			--disable-acl-support \
			--with-included-zlib=no \
			--with-included-popt=no \
			; \
		$(MAKE); \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
	$(REMOVE)/$(RSYNC_TMP)
	$(TOUCH)

# -----------------------------------------------------------------------------

READLINE_VER    = 8.0
READLINE_TMP    = readline-$(READLINE_VER)
READLINE_SOURCE = readline-$(READLINE_VER).tar.gz
READLINE_URL    = https://ftp.gnu.org/gnu/readline

$(ARCHIVE)/$(READLINE_SOURCE):
	$(DOWNLOAD) $(READLINE_URL)/$(READLINE_SOURCE)

$(D)/readline: $(ARCHIVE)/$(READLINE_SOURCE) | $(TARGET_DIR)
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
