# makefile to build extra system tools (mostly unused)

# -----------------------------------------------------------------------------

# usbutils-008 needs udev
USBUTILS_VER=007
$(ARCHIVE)/usbutils-$(USBUTILS_VER).tar.xz:
	$(WGET) https://www.kernel.org/pub/linux/utils/usb/usbutils/usbutils-$(USBUTILS_VER).tar.xz

USBUTILS_PATCH  = usbutils-avoid-dependency-on-bash.patch
USBUTILS_PATCH += usbutils-fix-null-pointer-crash.patch

$(D)/usbutils: $(D)/libusb_compat $(ARCHIVE)/usbutils-$(USBUTILS_VER).tar.xz | $(TARGET_DIR)
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
	rm -rf $(TARGET_DIR)/share/pkgconfig
	rm -rf $(TARGET_DIR)/share/usb.ids.gz
	$(REMOVE)/usbutils-$(USBUTILS_VER)
	$(TOUCH)

# -----------------------------------------------------------------------------

BINUTILS_VER=2.25
$(ARCHIVE)/binutils-$(BINUTILS_VER).tar.bz2:
	$(WGET) https://ftp.gnu.org/gnu/binutils/binutils-$(BINUTILS_VER).tar.bz2

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
		install -m755 $(BUILD_TMP)/binutils-$(BINUTILS_VER)/binutils/objdump $(BIN)/
		install -m755 $(BUILD_TMP)/binutils-$(BINUTILS_VER)/binutils/objcopy $(BIN)/
	$(REMOVE)/binutils-$(BINUTILS_VER)
	$(TOUCH)

# -----------------------------------------------------------------------------

UTIL-LINUX_VER=2.29
$(ARCHIVE)/util-linux-$(UTIL-LINUX_VER).tar.xz:
	$(WGET) https://www.kernel.org/pub/linux/utils/util-linux/v$(UTIL-LINUX_VER)/util-linux-$(UTIL-LINUX_VER).tar.xz

$(D)/util-linux: $(D)/libncurses $(ARCHIVE)/util-linux-$(UTIL-LINUX_VER).tar.xz | $(TARGET_DIR)
	$(REMOVE)/util-linux-$(UTIL-LINUX_VER)
	$(UNTAR)/util-linux-$(UTIL-LINUX_VER).tar.xz
	$(CHDIR)/util-linux-$(UTIL-LINUX_VER); \
		autoreconf -fi; \
		$(CONFIGURE) \
			--prefix= \
			--build=$(BUILD) \
			--host=$(TARGET) \
			--enable-static \
			--disable-shared \
			--mandir=/.remove \
			; \
		$(MAKE) sfdisk; \
		install -m755 sfdisk $(TARGET_DIR)/sbin/sfdisk
	$(REMOVE)/util-linux-$(UTIL-LINUX_VER)
	$(TOUCH)

# -----------------------------------------------------------------------------

IPTABLES_VER = 1.4.21
$(ARCHIVE)/iptables-$(IPTABLES_VER).tar.bz2:
	$(WGET) http://www.netfilter.org/projects/iptables/files/iptables-$(IPTABLES_VER).tar.bz2

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
	$(REWRITE_PKGCONF) $(PKG_CONFIG_PATH)/libip4tc.pc
	$(REWRITE_PKGCONF) $(PKG_CONFIG_PATH)/libip6tc.pc
	$(REWRITE_PKGCONF) $(PKG_CONFIG_PATH)/libiptc.pc
	$(REWRITE_PKGCONF) $(PKG_CONFIG_PATH)/xtables.pc
	$(REMOVE)/iptables-$(IPTABLES_VER)
	$(TOUCH)

# -----------------------------------------------------------------------------

LIGHTTPD_VER=1.4.31
$(ARCHIVE)/lighttpd-$(LIGHTTPD_VER).tar.gz:
	$(WGET) http://download.lighttpd.net/lighttpd/releases-1.4.x/lighttpd-$(LIGHTTPD_VER).tar.gz

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

PYTHON_VER=2.7.11
$(ARCHIVE)/Python-$(PYTHON_VER).tgz:
	$(WGET) http://www.python.org/ftp/python/$(PYTHON_VER)/Python-$(PYTHON_VER).tgz

$(D)/python: $(ARCHIVE)/Python-$(PYTHON_VER).tgz | $(TARGET_DIR)
	$(REMOVE)/Python-$(PYTHON_VER)
	$(UNTAR)/Python-$(PYTHON_VER).tgz
	$(CHDIR)/Python-$(PYTHON_VER); \
		echo "ac_cv_file__dev_ptmx=no" > config.site; \
		echo "ac_cv_file__dev_ptc=no" >> config.site; \
		export CONFIG_SITE=config.site; \
		./configure; \
		make python Parser/pgen; \
		mv python hostpython; \
		mv Parser/pgen Parser/hostpgen; \
		make distclean; \
		$(PATCH)/Python-xcompile.patch; \
		CC=$(TARGET)-gcc \
		CXX=$(TARGET)-g++ \
		AR=$(TARGET)-ar \
		RANLIB=$(TARGET)-ranlib \
		./configure \
			--build=$(BUILD) \
			--host=$(TARGET) \
			--prefix= \
			--enable-shared \
			--disable-ipv6 \
			; \
		make \
			HOSTPYTHON=./hostpython \
			HOSTPGEN=./Parser/hostpgen \
			BLDSHARED="$(TARGET)-gcc -shared" \
			CROSS_COMPILE=$(TARGET)- \
			CROSS_COMPILE_TARGET=yes \
			HOSTARCH=$(TARGET) \
			BUILDARCH=$(BUILD) \
			; \
		make install \
			HOSTPYTHON=./hostpython \
			HOSTPGEN=./Parser/hostpgen \
			BLDSHARED="$(TARGET)-gcc -shared" \
			CROSS_COMPILE=$(TARGET)- \
			CROSS_COMPILE_TARGET=yes \
			prefix=$(BUILD_TMP)/Python-$(PYTHON_VER)/_install \
			; \
		cp -a $(BUILD_TMP)/Python-$(PYTHON_VER)/_install/lib/python* $(TARGET_LIB_DIR)/
		cp -a $(BUILD_TMP)/Python-$(PYTHON_VER)/_install/lib/libpython* $(TARGET_LIB_DIR)/
		chmod +w $(TARGET_LIB_DIR)/libpython*
		install -m755 $(BUILD_TMP)/Python-$(PYTHON_VER)/_install/bin/python $(TARGET_DIR)/bin/
	$(REMOVE)/Python-$(PYTHON_VER)
	$(TOUCH)

# -----------------------------------------------------------------------------

$(D)/astra-sm: $(D)/openssl | $(TARGET_DIR)
	# workaround unrecognized command line options
	make astra-sm-no-march-cflags TARGET_MARCH_CFLAGS=""

$(D)/astra-sm-no-march-cflags:
	$(REMOVE)/astra-sm
	git clone https://gitlab.com/crazycat69/astra-sm.git $(BUILD_TMP)/astra-sm; \
	$(CHDIR)/astra-sm; \
		autoreconf -fi; \
		$(CONFIGURE) \
			--prefix= \
			--without-lua-compiler \
			; \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
	$(REMOVE)/astra-sm
	$(TOUCH)

# -----------------------------------------------------------------------------

IOZONE_VER = 482
IOZONE_SOURCE = iozone3_$(IOZONE_VER).tar

$(ARCHIVE)/$(IOZONE_SOURCE):
	$(WGET) http://www.iozone.org/src/current/$(IOZONE_SOURCE)

$(D)/iozone3: $(ARCHIVE)/$(IOZONE_SOURCE) | $(TARGET_DIR)
	$(REMOVE)/iozone3_$(IOZONE_VER)
	$(UNTAR)/$(IOZONE_SOURCE)
	$(CHDIR)/iozone3_$(IOZONE_VER)/src/current; \
		sed -i -e "s/= gcc/= $(TARGET)-gcc/" makefile; \
		sed -i -e "s/= cc/= $(TARGET)-cc/" makefile; \
		$(BUILDENV) \
		$(MAKE) linux-arm; \
		install -m 755 iozone $(TARGET_DIR)/bin
	$(REMOVE)/iozone3_$(IOZONE_VER)
	$(TOUCH)
