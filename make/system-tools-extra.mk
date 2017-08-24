# makefile to build extra system tools (mostly unused)

################################# special tools for some addons/scripts

make special-tools:
	make clean BOXSERIES=hd1
	make -j$(NUM_CPUS) xmllint BOXSERIES=hd1
	make -j$(NUM_CPUS) iconv BOXSERIES=hd1
	make -j$(NUM_CPUS) openvpn BOXSERIES=hd1
	find $(TARGETPREFIX)/bin -type f -print0 | xargs -0 $(TARGET)-strip || true
	find $(TARGETPREFIX)/sbin -type f -print0 | xargs -0 $(TARGET)-strip || true
	mv $(TARGETPREFIX)/bin/xmllint $(UPDATE_DIR) && zip -j $(UPDATE_DIR)/xmllint_hd1.zip $(UPDATE_DIR)/xmllint && rm $(UPDATE_DIR)/xmllint
	mv $(TARGETPREFIX)/bin/iconv $(UPDATE_DIR) && zip -j $(UPDATE_DIR)/iconv_hd1.zip $(UPDATE_DIR)/iconv && rm $(UPDATE_DIR)/iconv
	mv $(TARGETPREFIX)/sbin/openvpn $(UPDATE_DIR) && zip -j $(UPDATE_DIR)/openvpn_hd1.zip $(UPDATE_DIR)/openvpn && rm $(UPDATE_DIR)/openvpn
	#
	make clean BOXSERIES=hd2
	make -j$(NUM_CPUS) xmllint BOXSERIES=hd2
	make -j$(NUM_CPUS) iconv BOXSERIES=hd2
	find $(TARGETPREFIX)/bin -type f -print0 | xargs -0 $(TARGET)-strip || true
	mv $(TARGETPREFIX)/bin/xmllint $(UPDATE_DIR) && zip -j $(UPDATE_DIR)/xmllint_hd2.zip $(UPDATE_DIR)/xmllint && rm $(UPDATE_DIR)/xmllint
	mv $(TARGETPREFIX)/bin/iconv $(UPDATE_DIR) && zip -j $(UPDATE_DIR)/iconv_hd2.zip $(UPDATE_DIR)/iconv && rm $(UPDATE_DIR)/iconv
	#
	make clean

$(D)/iconv: $(ARCHIVE)/libiconv-$(LIBICONV_VER).tar.gz | $(TARGETPREFIX)
	$(UNTAR)/libiconv-$(LIBICONV_VER).tar.gz
	pushd $(BUILD_TMP)/libiconv-$(LIBICONV_VER) && \
		$(CONFIGURE) \
			--target=$(TARGET) \
			--prefix= \
			--enable-static \
			--disable-shared \
			--datarootdir=/.remove && \
		$(MAKE) && \
		$(MAKE) install DESTDIR=$(TARGETPREFIX)
	rm -rf $(TARGETLIB)/preloadable_libiconv.so
	rm -rf $(TARGETLIB)/charset.alias
	$(REMOVE)/libiconv-$(LIBICONV_VER)
	$(REWRITE_LIBTOOL)/libiconv.la
	$(REWRITE_LIBTOOL)/libcharset.la
	touch $@

$(D)/xmllint: $(ARCHIVE)/libxml2-$(LIBXML2_VER).tar.gz | $(TARGETPREFIX)
	$(UNTAR)/libxml2-$(LIBXML2_VER).tar.gz
	pushd $(BUILD_TMP)/libxml2-$(LIBXML2_VER) && \
		$(CONFIGURE) \
			--prefix= \
			--enable-static \
			--disable-shared \
			--datarootdir=/.remove \
			--without-python \
			--without-debug \
			--without-sax1 \
			--without-legacy \
			--without-catalog \
			--without-docbook \
			--without-lzma \
			--without-schematron && \
		$(MAKE) && \
		$(MAKE) install DESTDIR=$(TARGETPREFIX)
	mv $(TARGETPREFIX)/bin/xml2-config $(HOSTPREFIX)/bin
	$(REWRITE_LIBTOOL)/libxml2.la
	$(REWRITE_PKGCONF) $(PKG_CONFIG_PATH)/libxml-2.0.pc
	$(REWRITE_PKGCONF) $(HOSTPREFIX)/bin/xml2-config
	rm -rf $(TARGETLIB)/xml2Conf.sh
	$(REMOVE)/libxml2-$(LIBXML2_VER)
	touch $@

#################################

BINUTILS_VER=2.25
$(ARCHIVE)/binutils-$(BINUTILS_VER).tar.bz2:
	$(WGET) https://ftp.gnu.org/gnu/binutils/binutils-$(BINUTILS_VER).tar.bz2

$(D)/binutils: $(ARCHIVE)/binutils-$(BINUTILS_VER).tar.bz2 | $(TARGETPREFIX)
	$(UNTAR)/binutils-$(BINUTILS_VER).tar.bz2
	cd $(BUILD_TMP)/binutils-$(BINUTILS_VER) && \
		$(CONFIGURE) \
			--target=$(TARGET) \
			--prefix= \
			--disable-multilib \
			--disable-werror \
			--disable-plugins \
			--enable-build-warnings=no \
			--disable-sim \
			--disable-gdb && \
		$(MAKE)
		install -m755 $(BUILD_TMP)/binutils-$(BINUTILS_VER)/binutils/objdump $(BIN)/
		install -m755 $(BUILD_TMP)/binutils-$(BINUTILS_VER)/binutils/objcopy $(BIN)/
	$(REMOVE)/binutils-$(BINUTILS_VER)
	touch $@

UTIL-LINUX_VER=2.29
$(ARCHIVE)/util-linux-$(UTIL-LINUX_VER).tar.xz:
	$(WGET) https://www.kernel.org/pub/linux/utils/util-linux/v$(UTIL-LINUX_VER)/util-linux-$(UTIL-LINUX_VER).tar.xz

$(D)/util-linux: $(D)/libncurses $(ARCHIVE)/util-linux-$(UTIL-LINUX_VER).tar.xz | $(TARGETPREFIX)
	$(UNTAR)/util-linux-$(UTIL-LINUX_VER).tar.xz
	cd $(BUILD_TMP)/util-linux-$(UTIL-LINUX_VER) && \
		$(PATCH)/util-linux-define-mkostemp-for-older-version-of-uClibc.patch && \
		autoreconf -fi && \
		$(CONFIGURE) \
			--prefix= \
			--build=$(BUILD) \
			--host=$(TARGET) \
			--enable-static \
			--disable-shared \
			--mandir=/.remove && \
		$(MAKE) sfdisk && \
		install -m755 sfdisk $(TARGETPREFIX)/sbin/sfdisk
	$(REMOVE)/util-linux-$(UTIL-LINUX_VER)
	touch $@

$(D)/openvpn-hd1: $(D)/kernel-cst-hd1 $(D)/lzo $(D)/openssl $(ARCHIVE)/openvpn-$(OPENVPN_VER).tar.xz | $(TARGETPREFIX)
	$(UNTAR)/openvpn-$(OPENVPN_VER).tar.xz
	cd $(BUILD_TMP)/openvpn-$(OPENVPN_VER) && \
	$(PATCH)/openvpn-fix-tun-device-for-coolstream.patch && \
	$(BUILDENV) ./configure \
		--build=$(BUILD) \
		--host=$(TARGET) \
		--prefix= \
		--mandir=/.remove \
		--docdir=/.remove \
		--infodir=/.remove \
		--enable-shared \
		--disable-static \
		--enable-small \
		--enable-password-save \
		--enable-management \
		--disable-socks \
		--disable-debug \
		--disable-selinux \
		--disable-plugins \
		--disable-pkcs11 && \
	$(MAKE) && \
	$(MAKE) install DESTDIR=$(TARGETPREFIX)
	cp -a $(MODULESDIR)/kernel/drivers/net/tun.ko $(TARGET_MODULE)
	$(TARGET)-strip $(TARGETPREFIX)/sbin/openvpn
	$(REMOVE)/openvpn-$(OPENVPN_VER)
	touch $@

IPTABLES_VER = 1.4.21
$(ARCHIVE)/iptables-$(IPTABLES_VER).tar.bz2:
	$(WGET) http://www.netfilter.org/projects/iptables/files/iptables-$(IPTABLES_VER).tar.bz2

$(D)/iptables: $(ARCHIVE)/iptables-$(IPTABLES_VER).tar.bz2 | $(TARGETPREFIX)
	$(UNTAR)/iptables-$(IPTABLES_VER).tar.bz2
	set -e; cd $(BUILD_TMP)/iptables-$(IPTABLES_VER); \
		$(CONFIGURE) \
			--prefix= \
			--mandir=/.remove; \
		$(MAKE); \
		make install DESTDIR=$(TARGETPREFIX)
	$(REWRITE_LIBTOOL)/libip4tc.la
	$(REWRITE_LIBTOOL)/libip6tc.la
	$(REWRITE_LIBTOOL)/libiptc.la
	$(REWRITE_LIBTOOL)/libxtables.la
	$(REWRITE_PKGCONF) $(PKG_CONFIG_PATH)/libip4tc.pc
	$(REWRITE_PKGCONF) $(PKG_CONFIG_PATH)/libip6tc.pc
	$(REWRITE_PKGCONF) $(PKG_CONFIG_PATH)/libiptc.pc
	$(REWRITE_PKGCONF) $(PKG_CONFIG_PATH)/xtables.pc
	$(REMOVE)/iptables-$(IPTABLES_VER)
	touch $@

$(ARCHIVE)/lighttpd-1.4.31.tar.gz:
	$(WGET) http://download.lighttpd.net/lighttpd/releases-1.4.x/lighttpd-1.4.31.tar.gz

$(D)/lighttpd: $(D)/zlib $(ARCHIVE)/lighttpd-1.4.31.tar.gz | $(TARGETPREFIX)
	$(UNTAR)/lighttpd-1.4.31.tar.gz
	cd $(BUILD_TMP)/lighttpd-1.4.31 && \
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
		--without-bzip2 && \
	$(MAKE) && \
	$(MAKE) install DESTDIR=$(TARGETPREFIX)
	$(REMOVE)/lighttpd-1.4.31
	touch $@

PYTHON_VER=2.7.11
$(ARCHIVE)/Python-$(PYTHON_VER).tgz:
	$(WGET) http://www.python.org/ftp/python/$(PYTHON_VER)/Python-$(PYTHON_VER).tgz

$(D)/python: $(ARCHIVE)/Python-$(PYTHON_VER).tgz | $(TARGETPREFIX)
	$(REMOVE)/Python-$(PYTHON_VER)
	$(UNTAR)/Python-$(PYTHON_VER).tgz
	pushd $(BUILD_TMP)/Python-$(PYTHON_VER) && \
		echo "ac_cv_file__dev_ptmx=no" > config.site && \
		echo "ac_cv_file__dev_ptc=no" >> config.site && \
		export CONFIG_SITE=config.site && \
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
		cp -a $(BUILD_TMP)/Python-$(PYTHON_VER)/_install/lib/python* $(TARGETLIB)/
		cp -a $(BUILD_TMP)/Python-$(PYTHON_VER)/_install/lib/libpython* $(TARGETLIB)/
		chmod +w $(TARGETLIB)/libpython*
		install -m755 $(BUILD_TMP)/Python-$(PYTHON_VER)/_install/bin/python $(TARGETPREFIX)/bin/
	$(REMOVE)/Python-$(PYTHON_VER)
