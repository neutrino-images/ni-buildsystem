#
# makefile to build system tools (currently unused in ni-image)
#
# -----------------------------------------------------------------------------

# usbutils-008 needs udev
USBUTILS_VER = 007

$(ARCHIVE)/usbutils-$(USBUTILS_VER).tar.xz:
	$(DOWNLOAD) https://www.kernel.org/pub/linux/utils/usb/usbutils/usbutils-$(USBUTILS_VER).tar.xz

USBUTILS_PATCH  = usbutils-avoid-dependency-on-bash.patch
USBUTILS_PATCH += usbutils-fix-null-pointer-crash.patch

$(D)/usbutils: $(D)/libusb-compat $(ARCHIVE)/usbutils-$(USBUTILS_VER).tar.xz | $(TARGET_DIR)
	$(REMOVE)/usbutils-$(USBUTILS_VER)
	$(UNTAR)/usbutils-$(USBUTILS_VER).tar.xz
	$(CHDIR)/usbutils-$(USBUTILS_VER); \
		$(call apply_patches, $(USBUTILS_PATCH)); \
		$(CONFIGURE) \
			--target=$(TARGET) \
			--prefix= \
			--mandir=/.remove \
			--infodir=/.remove \
			; \
		$(MAKE); \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
	rm -rf $(TARGET_DIR)/bin/lsusb.py
	rm -rf $(TARGET_DIR)/bin/usbhid-dump
	rm -rf $(TARGET_DIR)/sbin/update-usbids.sh
	rm -rf $(TARGET_SHARE_DIR)/pkgconfig
	rm -rf $(TARGET_SHARE_DIR)/usb.ids.gz
	$(REMOVE)/usbutils-$(USBUTILS_VER)
	$(TOUCH)

# -----------------------------------------------------------------------------

BINUTILS_VER = 2.25

$(ARCHIVE)/binutils-$(BINUTILS_VER).tar.bz2:
	$(DOWNLOAD) https://ftp.gnu.org/gnu/binutils/binutils-$(BINUTILS_VER).tar.bz2

$(D)/binutils: $(ARCHIVE)/binutils-$(BINUTILS_VER).tar.bz2 | $(TARGET_DIR)
	$(REMOVE)/binutils-$(BINUTILS_VER)
	$(UNTAR)/binutils-$(BINUTILS_VER).tar.bz2
	$(CHDIR)/binutils-$(BINUTILS_VER); \
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
		$(MAKE)
		install -m 0755 $(BUILD_TMP)/binutils-$(BINUTILS_VER)/binutils/objdump $(BIN)/
		install -m 0755 $(BUILD_TMP)/binutils-$(BINUTILS_VER)/binutils/objcopy $(BIN)/
	$(REMOVE)/binutils-$(BINUTILS_VER)
	$(TOUCH)

# -----------------------------------------------------------------------------

UTIL-LINUX_VER_MAJOR = 2
UTIL-LINUX_VER_MINOR = 34
UTIL-LINUX_VER_MICRO = 0
ifeq ($(UTIL-LINUX_VER_MICRO), 0)
  UTIL-LINUX_VER = $(UTIL-LINUX_VER_MAJOR).$(UTIL-LINUX_VER_MINOR)
else
  UTIL-LINUX_VER = $(UTIL-LINUX_VER_MAJOR).$(UTIL-LINUX_VER_MINOR).$(UTIL-LINUX_VER_MICRO)
endif

$(ARCHIVE)/util-linux-$(UTIL-LINUX_VER).tar.xz:
	$(DOWNLOAD) https://www.kernel.org/pub/linux/utils/util-linux/v$(UTIL-LINUX_VER_MAJOR).$(UTIL-LINUX_VER_MINOR)/util-linux-$(UTIL-LINUX_VER).tar.xz

$(D)/util-linux: $(D)/libncurses $(D)/zlib $(ARCHIVE)/util-linux-$(UTIL-LINUX_VER).tar.xz | $(TARGET_DIR)
	$(REMOVE)/util-linux-$(UTIL-LINUX_VER)
	$(UNTAR)/util-linux-$(UTIL-LINUX_VER).tar.xz
	$(CHDIR)/util-linux-$(UTIL-LINUX_VER); \
		autoreconf -fi; \
		$(CONFIGURE) \
			--prefix= \
			--datarootdir=/.remove/share \
			--mandir=/.remove/man \
			--localedir=/.remove/locale \
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
	#$(REMOVE)/util-linux-$(UTIL-LINUX_VER)
	$(TOUCH)

# -----------------------------------------------------------------------------

IPTABLES_VER = 1.4.21

$(ARCHIVE)/iptables-$(IPTABLES_VER).tar.bz2:
	$(DOWNLOAD) http://www.netfilter.org/projects/iptables/files/iptables-$(IPTABLES_VER).tar.bz2

$(D)/iptables: $(ARCHIVE)/iptables-$(IPTABLES_VER).tar.bz2 | $(TARGET_DIR)
	$(REMOVE)/iptables-$(IPTABLES_VER)
	$(UNTAR)/iptables-$(IPTABLES_VER).tar.bz2
	$(CHDIR)/iptables-$(IPTABLES_VER); \
		$(CONFIGURE) \
			--prefix= \
			--mandir=/.remove \
			; \
		$(MAKE); \
		make install DESTDIR=$(TARGET_DIR)
	$(REWRITE_LIBTOOL)/libip4tc.la
	$(REWRITE_LIBTOOL)/libip6tc.la
	$(REWRITE_LIBTOOL)/libiptc.la
	$(REWRITE_LIBTOOL)/libxtables.la
	$(REWRITE_PKGCONF)/libip4tc.pc
	$(REWRITE_PKGCONF)/libip6tc.pc
	$(REWRITE_PKGCONF)/libiptc.pc
	$(REWRITE_PKGCONF)/xtables.pc
	$(REMOVE)/iptables-$(IPTABLES_VER)
	$(TOUCH)

# -----------------------------------------------------------------------------

LIGHTTPD_VER = 1.4.31

$(ARCHIVE)/lighttpd-$(LIGHTTPD_VER).tar.gz:
	$(DOWNLOAD) http://download.lighttpd.net/lighttpd/releases-1.4.x/lighttpd-$(LIGHTTPD_VER).tar.gz

$(D)/lighttpd: $(D)/zlib $(ARCHIVE)/lighttpd-$(LIGHTTPD_VER).tar.gz | $(TARGET_DIR)
	$(REMOVE)/lighttpd-$(LIGHTTPD_VER)
	$(UNTAR)/lighttpd-$(LIGHTTPD_VER).tar.gz
	$(CHDIR)/lighttpd-$(LIGHTTPD_VER); \
		$(BUILDENV) ./configure \
			--build=$(BUILD) \
			--host=$(TARGET) \
			--prefix= \
			--mandir=/.remove \
			--docdir=/.remove \
			--infodir=/.remove \
			--with-zlib \
			--enable-silent-rules \
			--without-pcre \
			--without-bzip2 \
			; \
		$(MAKE); \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
	$(REMOVE)/lighttpd-$(LIGHTTPD_VER)
	$(TOUCH)

# -----------------------------------------------------------------------------

# workaround unrecognized command line options
$(D)/astra-sm: TARGET_ABI=""
$(D)/astra-sm: $(D)/openssl | $(TARGET_DIR)
	$(REMOVE)/astra-sm.git
	get-git-source.sh https://gitlab.com/crazycat69/astra-sm.git $(ARCHIVE)/astra-sm.git
	$(CPDIR)/astra-sm.git
	$(CHDIR)/astra-sm.git; \
		autoreconf -fi; \
		$(CONFIGURE) \
			--prefix= \
			--without-lua \
			; \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
	$(REMOVE)/astra-sm.git
	$(TOUCH)

# -----------------------------------------------------------------------------

IOZONE_VER = 482
IOZONE_SOURCE = iozone3_$(IOZONE_VER).tar

$(ARCHIVE)/$(IOZONE_SOURCE):
	$(DOWNLOAD) http://www.iozone.org/src/current/$(IOZONE_SOURCE)

$(D)/iozone3: $(ARCHIVE)/$(IOZONE_SOURCE) | $(TARGET_DIR)
	$(REMOVE)/iozone3_$(IOZONE_VER)
	$(UNTAR)/$(IOZONE_SOURCE)
	$(CHDIR)/iozone3_$(IOZONE_VER)/src/current; \
		sed -i -e "s/= gcc/= $(TARGET)-gcc/" makefile; \
		sed -i -e "s/= cc/= $(TARGET)-cc/" makefile; \
		$(BUILDENV) \
		$(MAKE) linux-arm; \
		install -m 0755 iozone $(TARGET_DIR)/bin
	$(REMOVE)/iozone3_$(IOZONE_VER)
	$(TOUCH)

# -----------------------------------------------------------------------------

RSYNC_VER = 3.1.3
RSYNC_SOURCE = rsync-$(RSYNC_VER).tar.gz

$(ARCHIVE)/$(RSYNC_SOURCE):
	$(DOWNLOAD) https://ftp.samba.org/pub/rsync/$(RSYNC_SOURCE)

$(D)/rsync: $(ARCHIVE)/$(RSYNC_SOURCE) | $(TARGET_DIR)
	$(REMOVE)/rsync-$(RSYNC_VER)
	$(UNTAR)/$(RSYNC_SOURCE)
	$(CHDIR)/rsync-$(RSYNC_VER); \
		$(CONFIGURE) \
			--prefix= \
			--mandir=/.remove \
			--sysconfdir=/etc \
			--disable-debug \
			--disable-locale \
			; \
		$(MAKE) all; \
		$(MAKE) install-all DESTDIR=$(TARGET_DIR)
	$(REMOVE)/rsync-$(RSYNC_VER)
	$(TOUCH)

# -----------------------------------------------------------------------------

READLINE_VER = 8.0
READLINE_SOURCE = readline-$(READLINE_VER).tar.gz

$(ARCHIVE)/$(READLINE_SOURCE):
	$(DOWNLOAD) https://ftp.gnu.org/gnu/readline/$(READLINE_SOURCE)

$(D)/readline: $(ARCHIVE)/$(READLINE_SOURCE) | $(TARGET_DIR)
	$(REMOVE)/readline-$(READLINE_VER)
	$(UNTAR)/$(READLINE_SOURCE)
	$(CHDIR)/readline-$(READLINE_VER); \
		$(CONFIGURE) \
			--prefix= \
			--datarootdir=/.remove \
			; \
		$(MAKE) all; \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
	$(REWRITE_PKGCONF)/readline.pc
	$(REMOVE)/readline-$(READLINE_VER)
	$(TOUCH)
