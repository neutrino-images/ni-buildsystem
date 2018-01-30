# makefile to build system tools

$(D)/openvpn: $(D)/lzo $(D)/openssl $(ARCHIVE)/openvpn-$(OPENVPN_VER).tar.xz | $(TARGET_DIR)
	$(UNTAR)/openvpn-$(OPENVPN_VER).tar.xz
	cd $(BUILD_TMP)/openvpn-$(OPENVPN_VER) && \
	$(CONFIGURE) \
		IFCONFIG="/sbin/ifconfig" \
		NETSTAT="/bin/netstat" \
		ROUTE="/sbin/route" \
		IPROUTE="/sbin/ip" \
		--prefix= \
		--mandir=/.remove \
		--docdir=/.remove \
		--infodir=/.remove \
		--enable-shared \
		--disable-static \
		--enable-small \
		--enable-management \
		--disable-debug \
		--disable-selinux \
		--disable-plugins \
		--disable-pkcs11 && \
	$(MAKE) && \
	$(MAKE) install DESTDIR=$(TARGET_DIR)
	$(REMOVE)/openvpn-$(OPENVPN_VER)
	touch $@

$(D)/openssh: $(D)/openssl $(D)/zlib $(ARCHIVE)/openssh-$(OPENSSH_VER).tar.gz | $(TARGET_DIR)
	$(UNTAR)/openssh-$(OPENSSH_VER).tar.gz
	cd $(BUILD_TMP)/openssh-$(OPENSSH_VER) && \
	export ac_cv_search_dlopen=no && \
	./configure \
		$(CONFIGURE_OPTS) \
		--prefix= \
		--mandir=/.remove \
		--docdir=/.remove \
		--infodir=/.remove \
		--with-pid-dir=/tmp \
		--with-privsep-path=/var/empty \
		--with-cppflags="-pipe $(TARGET_O_CFLAGS) $(TARGET_MARCH_CFLAGS) -g -I$(TARGET_INCLUDE_DIR)" \
		--with-ldflags="-L$(TARGET_LIB_DIR)" \
		--libexecdir=/bin \
		--disable-strip \
		--disable-lastlog \
		--disable-utmp \
		--disable-utmpx \
		--disable-wtmp \
		--disable-wtmpx \
		--disable-pututline \
		--disable-pututxline && \
	$(MAKE) && \
	$(MAKE) install DESTDIR=$(TARGET_DIR)
	$(REMOVE)/openssh-$(OPENSSH_VER)
	touch $@

ifeq ($(BOXSERIES), hd2)
  LOC_TIME = var/etc/localtime
else
  LOC_TIME = etc/localtime
endif

$(D)/timezone: $(ARCHIVE)/tzdata$(TZDATA_VER).tar.gz | $(TARGET_DIR)
	$(REMOVE)/timezone
	mkdir $(BUILD_TMP)/timezone $(BUILD_TMP)/timezone/zoneinfo
	tar -C $(BUILD_TMP)/timezone -xf $(ARCHIVE)/tzdata$(TZDATA_VER).tar.gz
	set -e; cd $(BUILD_TMP)/timezone; \
		unset ${!LC_*}; LANG=POSIX; LC_ALL=POSIX; export LANG LC_ALL; \
		zic -d zoneinfo.tmp \
			africa antarctica asia australasia \
			europe northamerica southamerica pacificnew \
			etcetera backward; \
		sed -n '/zone=/{s/.*zone="\(.*\)".*$$/\1/; p}' $(IMAGEFILES)/timezone/timezone.xml | sort -u | \
		while read x; do \
			find zoneinfo.tmp -type f -name $$x | sort | \
			while read y; do \
				cp -a $$y zoneinfo/$$x; \
			done; \
			test -e zoneinfo/$$x || echo "WARNING: timezone $$x not found."; \
		done; \
		install -d -m 0755 $(TARGET_DIR)/share/ $(TARGET_DIR)/etc; \
		mv zoneinfo/ $(TARGET_DIR)/share/
	install -m 0644 $(IMAGEFILES)/timezone/timezone.xml $(TARGET_DIR)/etc/
	cp $(TARGET_DIR)/share/zoneinfo/CET $(TARGET_DIR)/$(LOC_TIME)
	$(REMOVE)/timezone
	touch $@

$(D)/mtd-utils: $(D)/zlib $(D)/lzo $(D)/e2fsprogs $(ARCHIVE)/mtd-utils-$(MTD-UTILS_VER).tar.bz2 | $(TARGET_DIR)
	$(UNTAR)/mtd-utils-$(MTD-UTILS_VER).tar.bz2
	pushd $(BUILD_TMP)/mtd-utils-$(MTD-UTILS_VER) && \
		$(CONFIGURE) \
			--prefix= \
			--target=$(TARGET) \
			--mandir=/.remove \
			--enable-silent-rules \
			--disable-tests \
			--without-xattr \
			&& \
		$(MAKE)
ifeq ($(BOXSERIES), hd2)
		install -D -m 0755 $(BUILD_TMP)/mtd-utils-$(MTD-UTILS_VER)/nanddump $(TARGET_DIR)/sbin
		install -D -m 0755 $(BUILD_TMP)/mtd-utils-$(MTD-UTILS_VER)/nandtest $(TARGET_DIR)/sbin
		install -D -m 0755 $(BUILD_TMP)/mtd-utils-$(MTD-UTILS_VER)/nandwrite $(TARGET_DIR)/sbin
		install -D -m 0755 $(BUILD_TMP)/mtd-utils-$(MTD-UTILS_VER)/mtd_debug $(TARGET_DIR)/sbin
		install -D -m 0755 $(BUILD_TMP)/mtd-utils-$(MTD-UTILS_VER)/mkfs.jffs2 $(TARGET_DIR)/sbin
endif
		install -D -m 0755 $(BUILD_TMP)/mtd-utils-$(MTD-UTILS_VER)/flash_erase $(TARGET_DIR)/sbin
		$(REMOVE)/mtd-utils-$(MTD-UTILS_VER)
		touch $@

$(D)/iperf: $(ARCHIVE)/iperf-$(IPERF_VER)-source.tar.gz | $(TARGET_DIR)
	$(UNTAR)/iperf-$(IPERF_VER)-source.tar.gz
	pushd $(BUILD_TMP)/iperf-$(IPERF_VER); \
		$(PATCH)/iperf-disable-profiling.patch && \
		$(CONFIGURE) \
			--target=$(TARGET) \
			--prefix= \
			--mandir=/.remove; \
		$(MAKE); \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
	$(REMOVE)/iperf-$(IPERF_VER)
	touch $@

$(D)/parted: $(D)/e2fsprogs $(ARCHIVE)/parted-$(PARTED_VER).tar.xz | $(TARGET_DIR)
	$(UNTAR)/parted-$(PARTED_VER).tar.xz
	cd $(BUILD_TMP)/parted-$(PARTED_VER) && \
		$(PATCH)/parted-3.2-devmapper-1.patch && \
		$(PATCH)/parted-3.2-sysmacros.patch && \
		$(CONFIGURE) \
			--prefix= \
			--target=$(TARGET) \
			--mandir=/.remove \
			--infodir=/.remove \
			--enable-silent-rules \
			--enable-shared \
			--disable-static \
			--disable-debug \
			--disable-pc98 \
			--disable-nls \
			--disable-device-mapper \
			--without-readline && \
		$(MAKE) && \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
	$(REWRITE_LIBTOOL)/libparted.la
	$(REWRITE_LIBTOOL)/libparted-fs-resize.la
	$(REWRITE_PKGCONF) $(PKG_CONFIG_PATH)/libparted.pc
	$(REMOVE)/parted-$(PARTED_VER)
	touch $@

$(D)/hdparm: $(ARCHIVE)/hdparm-$(HDPARM_VER).tar.gz | $(TARGET_DIR)
	$(UNTAR)/hdparm-$(HDPARM_VER).tar.gz
	pushd $(BUILD_TMP)/hdparm-$(HDPARM_VER) && \
		$(BUILDENV) \
		$(MAKE) CC=$(TARGET)-gcc STRIP=$(TARGET)-strip && \
		install -m755 hdparm $(TARGET_DIR)/sbin/hdparm
	$(REMOVE)/hdparm-$(HDPARM_VER)
	touch $@

$(D)/hd-idle: $(ARCHIVE)/hd-idle-$(HDIDLE_VER).tgz | $(TARGET_DIR)
	$(UNTAR)/hd-idle-$(HDIDLE_VER).tgz
	pushd $(BUILD_TMP)/hd-idle && \
		$(TARGET)-gcc $(TARGET_CFLAGS) $(TARGET_LDFLAGS) -o hd-idle hd-idle.c && \
	install -m755 hd-idle $(BIN)/
	$(REMOVE)/hd-idle
	touch $@

# only used for "touch"
$(D)/coreutils: $(ARCHIVE)/coreutils-$(COREUTILS_VER).tar.xz | $(TARGET_DIR)
	$(UNTAR)/coreutils-$(COREUTILS_VER).tar.xz
	cd $(BUILD_TMP)/coreutils-$(COREUTILS_VER) && \
		$(PATCH)/coreutils-fix-coolstream-build.patch && \
		autoreconf -fi && \
		$(CONFIGURE) \
			--target=$(TARGET) \
			--prefix= \
			--enable-silent-rules \
			--disable-xattr \
			--disable-libcap \
			--disable-acl \
			--without-gmp \
			--without-selinux && \
		$(MAKE)
	install -m755 $(BUILD_TMP)/coreutils-$(COREUTILS_VER)/src/touch $(BIN)/
	$(REMOVE)/coreutils-$(COREUTILS_VER)
	touch $@

$(D)/less: $(D)/libncurses $(ARCHIVE)/less-$(LESS_VER).tar.gz | $(TARGET_DIR)
	$(REMOVE)/less-$(LESS_VER)
	$(UNTAR)/less-$(LESS_VER).tar.gz
	cd $(BUILD_TMP)/less-$(LESS_VER) && \
		$(CONFIGURE) \
			--prefix= \
			--target=$(TARGET) \
			--mandir=/.remove \
			&& \
		$(MAKE) && \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
	$(REMOVE)/less-$(LESS_VER)
	touch $@

$(D)/ntp: $(ARCHIVE)/ntp-$(NTP_VER).tar.gz $(D)/openssl | $(TARGET_DIR)
	$(UNTAR)/ntp-$(NTP_VER).tar.gz
	pushd $(BUILD_TMP)/ntp-$(NTP_VER) && \
		$(CONFIGURE) \
			--prefix= \
			--target=$(TARGET) \
			--with-shared \
			--with-crypto \
			--with-yielding-select=yes \
			--without-ntpsnmpd && \
		$(MAKE)
	mv -v $(BUILD_TMP)/ntp-$(NTP_VER)/ntpdate/ntpdate $(TARGET_DIR)/sbin/
	$(REMOVE)/ntp-$(NTP_VER)
	touch $@

$(D)/djmount: $(ARCHIVE)/djmount-$(DJMOUNT_VER).tar.gz $(D)/libfuse | $(TARGET_DIR)
	$(UNTAR)/djmount-$(DJMOUNT_VER).tar.gz
	pushd $(BUILD_TMP)/djmount-$(DJMOUNT_VER) && \
		$(PATCH)/djmount-fix-hang-with-asset-upnp.patch && \
		$(PATCH)/djmount-fix-incorrect-range-when-retrieving-content-via-HTTP.patch && \
		$(PATCH)/djmount-fix-new-autotools.diff && \
		$(PATCH)/djmount-fixed-crash-when-using-UTF-8-charset.patch && \
		$(PATCH)/djmount-fixed-crash.patch && \
		$(PATCH)/djmount-support-fstab-mounting.diff && \
		$(PATCH)/djmount-support-seeking-in-large-2gb-files.patch && \
		touch libupnp/config.aux/config.rpath && \
		autoreconf -fi && \
		$(CONFIGURE) -C \
			--prefix= \
			--disable-debug && \
		make && \
		make install DESTDIR=$(TARGET_DIR)
	install -D -m 755 $(IMAGEFILES)/scripts/djmount.init $(TARGET_DIR)/etc/init.d/djmount
	ln -sf djmount $(TARGET_DIR)/etc/init.d/S99djmount
	ln -sf djmount $(TARGET_DIR)/etc/init.d/K01djmount
	$(REMOVE)/djmount-$(DJMOUNT_VER)
	touch $@

$(D)/ushare: $(ARCHIVE)/ushare-$(USHARE_VER).tar.bz2 $(D)/libupnp | $(TARGET_DIR)
	$(UNTAR)/ushare-$(USHARE_VER).tar.bz2
	pushd $(BUILD_TMP)/ushare-$(USHARE_VER) && \
		$(PATCH)/ushare.diff && \
		$(PATCH)/ushare-fix-building-with-gcc-5.x.patch && \
		$(BUILDENV) \
		./configure \
			--prefix=$(TARGET_DIR) \
			--disable-dlna \
			--disable-nls \
			--cross-compile \
			--cross-prefix=$(TARGET)- && \
		sed -i config.h  -e 's@SYSCONFDIR.*@SYSCONFDIR "/etc"@' && \
		sed -i config.h  -e 's@LOCALEDIR.*@LOCALEDIR "/share"@' && \
		ln -sf ../config.h src/ && \
		$(MAKE) && \
		$(MAKE) install && \
		install -D -m 0644 $(IMAGEFILES)/scripts/ushare.conf $(TARGET_DIR)/etc/ushare.conf
		install -D -m 0755 $(IMAGEFILES)/scripts/ushare.init $(TARGET_DIR)/etc/init.d/ushare
		ln -sf ushare $(TARGET_DIR)/etc/init.d/S99ushare
		ln -sf ushare $(TARGET_DIR)/etc/init.d/K01ushare
	$(REMOVE)/ushare-$(USHARE_VER)
	touch $@

$(D)/smartmontools: $(ARCHIVE)/smartmontools-$(SMARTMON_VER).tar.gz | $(TARGET_DIR)
	$(UNTAR)/smartmontools-$(SMARTMON_VER).tar.gz
	cd $(BUILD_TMP)/smartmontools-$(SMARTMON_VER) && \
		$(BUILDENV) \
		$(CONFIGURE) \
			--target=$(TARGET) \
			--prefix= && \
		$(MAKE) && \
		install -m755 smartctl $(TARGET_DIR)/sbin/smartctl
	$(REMOVE)/smartmontools-$(SMARTMON_VER)
	touch $@

$(D)/inadyn: $(D)/openssl $(D)/confuse $(D)/libite $(ARCHIVE)/inadyn-$(INADYN_VER).tar.xz | $(TARGET_DIR)
	$(REMOVE)/inadyn-$(INADYN_VER)
	$(UNTAR)/inadyn-$(INADYN_VER).tar.xz
	cd $(BUILD_TMP)/inadyn-$(INADYN_VER) && \
		autoreconf -fi && \
		$(CONFIGURE) \
			--prefix= \
			--libdir=$(TARGET_LIB_DIR) \
			--includedir=$(TARGET_INCLUDE_DIR) \
			--mandir=/.remove \
			--docdir=/.remove \
			--enable-openssl && \
		$(MAKE); \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
	install -D -m 644 $(IMAGEFILES)/scripts/inadyn.conf $(TARGET_DIR)/var/etc/inadyn.conf
	ln -sf /var/etc/inadyn.conf $(TARGET_DIR)/etc/inadyn.conf
	install -D -m 755 $(IMAGEFILES)/scripts/inadyn.init $(TARGET_DIR)/etc/init.d/inadyn
	ln -sf inadyn $(TARGET_DIR)/etc/init.d/S80inadyn
	ln -sf inadyn $(TARGET_DIR)/etc/init.d/K60inadyn
	$(REMOVE)/inadyn-$(INADYN_VER)
	touch $@

$(D)/vsftpd: $(D)/openssl $(ARCHIVE)/vsftpd-$(VSFTPD_VER).tar.gz | $(TARGET_DIR)
	$(UNTAR)/vsftpd-$(VSFTPD_VER).tar.gz
	cd $(BUILD_TMP)/vsftpd-$(VSFTPD_VER) && \
		$(PATCH)/vsftpd-fix-CVE-2015-1419.patch && \
		$(PATCH)/vsftpd-disable-capabilities.patch && \
		sed -i -e 's/.*VSF_BUILD_PAM/#undef VSF_BUILD_PAM/' builddefs.h && \
		sed -i -e 's/.*VSF_BUILD_SSL/#define VSF_BUILD_SSL/' builddefs.h && \
		make clean && \
		TARGET_DIR=$(TARGET_DIR) make CC=$(TARGET)-gcc LIBS="-lcrypt -lcrypto -lssl" CFLAGS="$(TARGET_CFLAGS)" LDFLAGS="$(TARGET_LDFLAGS)"
	install -d $(TARGET_DIR)/share/empty
	install -D -m 755 $(BUILD_TMP)/vsftpd-$(VSFTPD_VER)/vsftpd $(TARGET_DIR)/sbin/vsftpd
	install -D -m 644 $(IMAGEFILES)/scripts/vsftpd.conf $(TARGET_DIR)/etc/vsftpd.conf
	install -D -m 644 $(IMAGEFILES)/scripts/vsftpd.chroot_list $(TARGET_DIR)/etc/vsftpd.chroot_list
	install -D -m 755 $(IMAGEFILES)/scripts/vsftpd.init $(TARGET_DIR)/etc/init.d/vsftpd
	ln -sf vsftpd $(TARGET_DIR)/etc/init.d/S53vsftpd
	ln -sf vsftpd $(TARGET_DIR)/etc/init.d/K80vsftpd
	$(REMOVE)/vsftpd-$(VSFTPD_VER)
	touch $@

$(D)/procps-ng: $(D)/libncurses $(ARCHIVE)/procps-ng-$(PROCPS-NG_VER).tar.xz | $(TARGET_DIR)
	$(UNTAR)/procps-ng-$(PROCPS-NG_VER).tar.xz
	cd $(BUILD_TMP)/procps-ng-$(PROCPS-NG_VER) && \
	export ac_cv_func_malloc_0_nonnull=yes && \
	export ac_cv_func_realloc_0_nonnull=yes && \
		$(CONFIGURE) \
			--target=$(TARGET) \
			--prefix= && \
		$(MAKE) && \
		rm -f $(TARGET_DIR)/bin/ps $(TARGET_DIR)/bin/top && \
		install -D -m 755 top/.libs/top $(TARGET_DIR)/bin/top && \
		install -D -m 755 ps/.libs/pscommand $(TARGET_DIR)/bin/ps && \
		cp -a proc/.libs/libprocps.so* $(TARGET_LIB_DIR)
	$(REMOVE)/procps-ng-$(PROCPS-NG_VER)
	touch $@

$(D)/nano: $(D)/libncurses $(ARCHIVE)/nano-$(NANO_VER).tar.gz | $(TARGET_DIR)
	$(UNTAR)/nano-$(NANO_VER).tar.gz
	cd $(BUILD_TMP)/nano-$(NANO_VER) && \
		export ac_cv_prog_NCURSESW_CONFIG=false && \
		$(CONFIGURE) \
			--target=$(TARGET) \
			--prefix= && \
		$(MAKE) CURSES_LIB="-lncurses" && \
		install -m755 src/nano $(TARGET_DIR)/bin
	$(REMOVE)/nano-$(NANO_VER)
	touch $@

$(D)/minicom: $(D)/libncurses $(ARCHIVE)/minicom-$(MINICOM_VER).tar.gz | $(TARGET_DIR)
	$(UNTAR)/minicom-$(MINICOM_VER).tar.gz
	cd $(BUILD_TMP)/minicom-$(MINICOM_VER) && \
		$(PATCH)/minicom-fix-h-v-return-value-is-not-0.patch && \
		$(CONFIGURE) \
			--prefix= \
			--target=$(TARGET) \
			--disable-nls && \
		$(MAKE) && \
		install -m755 src/minicom $(TARGET_DIR)/bin
	$(REMOVE)/minicom-$(MINICOM_VER)
	touch $@

# Link against libtirpc so that we can leverage its RPC
# support for NFS mounting with BusyBox
BUSYBOX_CFLAGS = $(TARGET_CFLAGS)
BUSYBOX_CFLAGS += "`$(PKG_CONFIG) --cflags libtirpc`"
# Don't use LDFLAGS for -ltirpc, because LDFLAGS is used for
# the non-final link of modules as well.
BUSYBOX_CFLAGS_busybox = "`$(PKG_CONFIG) --libs libtirpc`"

# Allows the build system to tweak CFLAGS
BUSYBOX_MAKE_ENV = \
	CFLAGS="$(BUSYBOX_CFLAGS)" \
	CFLAGS_busybox="$(BUSYBOX_CFLAGS_busybox)"

BUSYBOX_MAKE_OPTS = \
	CC="$(TARGET)-gcc" \
	LD="$(TARGET)-ld" \
	AR="$(TARGET)-ar" \
	RANLIB="$(TARGET)-ranlib" \
	CROSS_COMPILE="$(TARGET)-" \
	CFLAGS_EXTRA="$(TARGET_CFLAGS)" \
	EXTRA_LDFLAGS="$(TARGET_LDFLAGS)" \
	CONFIG_PREFIX="$(TARGET_DIR)"

$(D)/busybox: $(D)/libtirpc $(ARCHIVE)/busybox-$(BUSYBOX_VER).tar.bz2 | $(TARGET_DIR)
	$(REMOVE)/busybox-$(BUSYBOX_VER)
	$(UNTAR)/busybox-$(BUSYBOX_VER).tar.bz2
	pushd $(BUILD_TMP)/busybox-$(BUSYBOX_VER) && \
		$(PATCH)/busybox-fix-config-header.diff && \
		$(PATCH)/busybox-insmod-hack.patch && \
		$(PATCH)/busybox-mount-use-var-etc-fstab.patch && \
		$(PATCH)/busybox-fix-partition-size.patch && \
		cp $(CONFIGS)/busybox-$(BOXSERIES).config .config && \
		$(BUSYBOX_MAKE_ENV) $(MAKE) busybox $(BUSYBOX_MAKE_OPTS) && \
		$(BUSYBOX_MAKE_ENV) $(MAKE) install $(BUSYBOX_MAKE_OPTS)
	$(REMOVE)/busybox-$(BUSYBOX_VER)
	touch $@

$(D)/bash: $(ARCHIVE)/bash-$(BASH_VER).tar.gz | $(TARGET_DIR)
	$(REMOVE)/bash-$(BASH_VER)
	$(UNTAR)/bash-$(BASH_VER).tar.gz
	cd $(BUILD_TMP)/bash-$(BASH_VER); \
		for patch in $(PATCHES)/bash-$(BASH_MAJOR).$(BASH_MINOR)/*; do \
			patch -p0 -i $$patch; \
		done; \
		$(CONFIGURE) && \
		$(MAKE) && \
		install -m 755 bash $(TARGET_DIR)/bin
	$(REMOVE)/bash-$(BASH_VER)
	touch $@

$(D)/e2fsprogs: $(ARCHIVE)/e2fsprogs-$(E2FSPROGS_VER).tar.gz | $(TARGET_DIR)
	$(UNTAR)/e2fsprogs-$(E2FSPROGS_VER).tar.gz
	cd $(BUILD_TMP)/e2fsprogs-$(E2FSPROGS_VER) && \
		autoreconf -fi && \
		$(CONFIGURE) \
			--target=$(TARGET) \
			--prefix=/ \
			--infodir=/.remove \
			--mandir=/.remove \
			--disable-nls \
			--disable-profile \
			--disable-e2initrd-helper \
			--disable-debugfs \
			--disable-imager \
			--disable-resizer \
			--disable-uuidd \
			--disable-testio-debug \
			--disable-defrag \
			--enable-elf-shlibs \
			--enable-fsck \
			--enable-symlink-install \
			--enable-symlink-build \
			--with-gnu-ld && \
		$(MAKE) && \
		$(MAKE) install DESTDIR=$(TARGET_DIR) && \
		cd lib/uuid/ && \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
	$(REWRITE_PKGCONF) $(PKG_CONFIG_PATH)/uuid.pc
	$(REMOVE)/e2fsprogs-$(E2FSPROGS_VER)
	cd $(TARGET_DIR) && rm sbin/dumpe2fs sbin/logsave sbin/e2undo \
		sbin/filefrag sbin/e2freefrag bin/chattr bin/lsattr bin/uuidgen
	touch $@

$(D)/ntfs-3g: $(ARCHIVE)/ntfs-3g_ntfsprogs-$(NTFS3G_VER).tgz | $(TARGET_DIR)
	$(UNTAR)/ntfs-3g_ntfsprogs-$(NTFS3G_VER).tgz
	cd $(BUILD_TMP)/ntfs-3g_ntfsprogs-$(NTFS3G_VER) && \
		$(CONFIGURE) \
			--prefix= \
			--mandir=/.remove \
			--docdir=/.remove \
			--disable-ntfsprogs \
			--disable-ldconfig \
			--disable-library \
			&& \
		$(MAKE) && \
	install -m 755 $(BUILD_TMP)/ntfs-3g_ntfsprogs-$(NTFS3G_VER)/src/ntfs-3g $(TARGET_DIR)/sbin/ntfs-3g
	$(REMOVE)/ntfs-3g_ntfsprogs-$(NTFS3G_VER)
	touch $@

# the 'autofs-use-pkg-config' patch for libtirpc link should hopefully be added upstream soon
# see: https://patchwork.ozlabs.org/patch/782714/
$(D)/autofs5: $(D)/libtirpc $(ARCHIVE)/autofs-$(AUTOFS5_VER).tar.gz | $(TARGET_DIR)
	$(REMOVE)/autofs-$(AUTOFS5_VER)
	$(UNTAR)/autofs-$(AUTOFS5_VER).tar.gz
	cd $(BUILD_TMP)/autofs-$(AUTOFS5_VER) && \
	$(PATCH)/autofs-use-pkg-config-to-search-for-libtirpc-to-fix-cross-c.patch && \
	$(PATCH)/autofs-include-linux-nfs.h-directly-in-rpc_sub.patch && \
	export ac_cv_linux_procfs=yes && \
	export ac_cv_path_KRB5_CONFIG=no && \
	export ac_cv_path_MODPROBE=/sbin/modprobe && \
	export ac_cv_path_RANLIB=$(TARGET)-ranlib && \
		autoreconf -fi && \
		$(CONFIGURE) \
			--prefix= \
			--datarootdir=/.remove \
			--disable-mount-locking \
			--without-openldap \
			--without-sasl \
			--enable-ignore-busy \
			--with-path=$(PATH) \
			--with-libtirpc \
			--with-hesiod=no \
			--with-confdir=/etc \
			--with-mapdir=/etc \
			--with-fifodir=/var/run \
			--with-flagdir=/var/run \
			&& \
		sed -i "s|nfs/nfs.h|linux/nfs.h|" include/rpc_subs.h && \
		$(MAKE) SUBDIRS="lib daemon modules" DONTSTRIP=1 && \
		$(MAKE) SUBDIRS="lib daemon modules" install DESTDIR=$(TARGET_DIR)
	cp -a $(IMAGEFILES)/autofs/* $(TARGET_DIR)/
	ln -sf autofs $(TARGET_DIR)/etc/init.d/S60autofs
	ln -sf autofs $(TARGET_DIR)/etc/init.d/K40autofs
	$(REMOVE)/autofs-$(AUTOFS5_VER)
	touch $@

samba: samba-$(BOXSERIES)

$(D)/samba-hd1: $(D)/zlib $(ARCHIVE)/samba-$(SAMBA33_VER).tar.gz | $(TARGET_DIR)
	$(UNTAR)/samba-$(SAMBA33_VER).tar.gz
	cd $(BUILD_TMP)/samba-$(SAMBA33_VER) && \
	$(PATCH)/samba33-build-only-what-we-need.patch && \
	$(PATCH)/samba33-configure.in-make-getgrouplist_ok-test-cross-compile.patch
	cd $(BUILD_TMP)/samba-$(SAMBA33_VER)/source && \
		./autogen.sh && \
		export CONFIG_SITE=$(CONFIGS)/samba33-config.site && \
		$(CONFIGURE) \
			--prefix=/ \
			--datadir=/var/samba \
			--datarootdir=/.remove \
			--localstatedir=/var/samba \
			--sysconfdir=/etc/samba \
			--with-configdir=/etc/samba \
			--with-privatedir=/etc/samba \
			--with-modulesdir=/.remove \
			--with-sys-quotas=no \
			--with-piddir=/tmp \
			--enable-static \
			--disable-shared \
			--without-cifsmount \
			--without-acl-support \
			--without-ads \
			--without-cluster-support \
			--without-dnsupdate \
			--without-krb5 \
			--without-ldap \
			--without-libnetapi \
			--without-libtalloc \
			--without-libtdb \
			--without-libsmbsharemodes \
			--without-libsmbclient \
			--without-libaddns \
			--without-pam \
			--without-winbind \
			--disable-shared-libs \
			--disable-avahi \
			--disable-cups \
			--disable-iprint \
			--disable-pie \
			--disable-relro \
			--disable-swat && \
		$(MAKE) all && \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
	mkdir -p $(TARGET_DIR)/var/samba/locks
	install $(IMAGEFILES)/scripts/smb3.conf $(TARGET_DIR)/etc/samba/smb.conf
	install -m 755 $(IMAGEFILES)/scripts/samba3.init $(TARGET_DIR)/etc/init.d/samba
	ln -sf samba $(TARGET_DIR)/etc/init.d/S99samba
	ln -sf samba $(TARGET_DIR)/etc/init.d/K01samba
	rm -rf $(TARGET_DIR)/bin/testparm
	rm -rf $(TARGET_DIR)/bin/findsmb
	rm -rf $(TARGET_DIR)/bin/smbtar
	rm -rf $(TARGET_DIR)/bin/smbclient
	rm -rf $(TARGET_DIR)/bin/smbpasswd
	$(REMOVE)/samba-$(SAMBA33_VER)
	touch $@

$(D)/samba-hd51 \
$(D)/samba-hd2: $(D)/zlib $(ARCHIVE)/samba-$(SAMBA36_VER).tar.gz | $(TARGET_DIR)
	$(UNTAR)/samba-$(SAMBA36_VER).tar.gz
	cd $(BUILD_TMP)/samba-$(SAMBA36_VER) && \
	$(PATCH)/samba36-build-only-what-we-need.patch && \
	$(PATCH)/samba36-remove_printer_support.patch && \
	$(PATCH)/samba36-remove_ad_support.patch && \
	$(PATCH)/samba36-remove_services.patch && \
	$(PATCH)/samba36-remove_winreg_support.patch && \
	$(PATCH)/samba36-remove_registry_backend.patch && \
	$(PATCH)/samba36-strip_srvsvc.patch && \
	patch -p0 -i $(BASE_DIR)/archive-patches/samba36-CVE-2016-2112-v3-6.patch && \
	patch -p0 -i $(BASE_DIR)/archive-patches/samba36-CVE-2016-2115-v3-6.patch && \
	patch -p0 -i $(BASE_DIR)/archive-patches/samba36-CVE-2017-7494-v3-6.patch
	cd $(BUILD_TMP)/samba-$(SAMBA36_VER)/source3 && \
		./autogen.sh && \
		export CONFIG_SITE=$(CONFIGS)/samba36-config.site && \
		$(CONFIGURE) \
			--prefix=/ \
			--datadir=/var/samba \
			--datarootdir=/.remove \
			--localstatedir=/var/samba \
			--sysconfdir=/etc/samba \
			--with-configdir=/etc/samba \
			--with-privatedir=/etc/samba \
			--with-modulesdir=/.remove \
			--with-piddir=/tmp \
			--with-sys-quotas=no \
			--enable-static \
			--disable-shared \
			--without-acl-support \
			--without-ads \
			--without-cluster-support \
			--without-dmapi \
			--without-dnsupdate \
			--without-krb5 \
			--without-ldap \
			--without-libnetapi \
			--without-libsmbsharemodes \
			--without-libsmbclient \
			--without-libaddns \
			--without-pam \
			--without-winbind \
			--disable-shared-libs \
			--disable-avahi \
			--disable-cups \
			--disable-iprint \
			--disable-pie \
			--disable-relro \
			--disable-swat && \
		$(MAKE) all && \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
	mkdir -p $(TARGET_DIR)/var/samba/locks
	install $(IMAGEFILES)/scripts/smb3.conf $(TARGET_DIR)/etc/samba/smb.conf
	install -m 755 $(IMAGEFILES)/scripts/samba3.init $(TARGET_DIR)/etc/init.d/samba
	ln -sf samba $(TARGET_DIR)/etc/init.d/S99samba
	ln -sf samba $(TARGET_DIR)/etc/init.d/K01samba
	rm -rf $(TARGET_DIR)/bin/testparm
	rm -rf $(TARGET_DIR)/bin/findsmb
	rm -rf $(TARGET_DIR)/bin/smbtar
	rm -rf $(TARGET_DIR)/bin/smbclient
	rm -rf $(TARGET_DIR)/bin/smbpasswd
	$(REMOVE)/samba-$(SAMBA36_VER)
	touch $@

$(D)/dropbear: $(D)/zlib $(ARCHIVE)/dropbear-$(DROPBEAR_VER).tar.bz2 | $(TARGET_DIR)
	$(UNTAR)/dropbear-$(DROPBEAR_VER).tar.bz2
	cd $(BUILD_TMP)/dropbear-$(DROPBEAR_VER) && \
		$(PATCH)/dropbear-fix-paths.patch && \
		$(CONFIGURE) \
			--prefix= \
			--mandir=/.remove \
			--disable-pututxline \
			--disable-wtmp \
			--disable-wtmpx \
			--disable-loginfunc \
			--disable-pam \
			&& \
		sed -i 's:.*\(#define NO_FAST_EXPTMOD\).*:\1:' options.h && \
		sed -i 's:^#define DROPBEAR_SMALL_CODE::' options.h && \
		$(MAKE) PROGRAMS="dropbear dbclient dropbearkey scp" SCPPROGRESS=1 && \
		$(MAKE) PROGRAMS="dropbear dbclient dropbearkey scp" install DESTDIR=$(TARGET_DIR)
	install -D -m 0755 $(IMAGEFILES)/scripts/dropbear.init $(TARGET_DIR)/etc/init.d/dropbear
	install -d -m 0755 $(TARGET_DIR)/etc/dropbear
	ln -sf dropbear $(TARGET_DIR)/etc/init.d/S60dropbear
	ln -sf dropbear $(TARGET_DIR)/etc/init.d/K60dropbear
	$(REMOVE)/dropbear-$(DROPBEAR_VER)
	touch $@

$(D)/sg3-utils: $(ARCHIVE)/sg3_utils-$(SG3-UTILS_VER).tar.xz | $(TARGET_DIR)
	$(UNTAR)/sg3_utils-$(SG3-UTILS_VER).tar.xz
	cd $(BUILD_TMP)/sg3_utils-$(SG3-UTILS_VER) && \
		$(CONFIGURE) \
			--prefix= \
			--mandir=/.remove && \
		$(MAKE) && \
		cp -a src/.libs/sg_start $(TARGET_DIR)/bin && \
		cp -a lib/.libs/libsgutils2.so.2.0.0 $(TARGET_LIB_DIR) && \
		cp -a lib/.libs/libsgutils2.so.2 $(TARGET_LIB_DIR) && \
		cp -a lib/.libs/libsgutils2.so $(TARGET_LIB_DIR)
	$(REMOVE)/sg3_utils-$(SG3-UTILS_VER)
	touch $@

fbshot: $(TARGET_DIR)/bin/fbshot
$(TARGET_DIR)/bin/fbshot: $(D)/libpng $(ARCHIVE)/fbshot-$(FBSHOT_VER).tar.gz | $(TARGET_DIR)
	$(REMOVE)/fbshot-$(FBSHOT_VER)
	$(UNTAR)/fbshot-$(FBSHOT_VER).tar.gz
	cd $(BUILD_TMP)/fbshot-$(FBSHOT_VER); \
		$(PATCH)/fbshot-32bit_cs_fb.diff; \
		$(PATCH)/fbshot_cs_hd2.diff; \
		$(TARGET)-gcc $(TARGET_CFLAGS) $(TARGET_LDFLAGS) fbshot.c -lpng -lz -o $@
	$(REMOVE)/fbshot-$(FBSHOT_VER)

$(D)/lcd4linux: $(D)/libncurses $(D)/libgd2 $(D)/libdpf | $(TARGET_DIR)
	$(REMOVE)/lcd4linux
	git clone https://github.com/TangoCash/lcd4linux.git $(BUILD_TMP)/lcd4linux
	cd $(BUILD_TMP)/lcd4linux && \
		./bootstrap && \
		$(CONFIGURE) \
			--libdir=$(TARGET_LIB_DIR) \
			--includedir=$(TARGET_INCLUDE_DIR) \
			--bindir=$(TARGET_DIR)/bin \
			--prefix= \
			--mandir=/.remove \
			--docdir=/.remove \
			--infodir=/.remove \
			--with-ncurses=$(TARGET_LIB_DIR) \
			--with-drivers='DPF, SamsungSPF' \
			--with-plugins='all,!dbus,!mpris_dbus,!asterisk,!isdn,!pop3,!ppp,!seti,!huawei,!imon,!kvv,!sample,!w1retap,!wireless,!xmms,!gps,!mpd,!mysql,!qnaplog,!iconv' && \
		$(MAKE) vcs_version && \
		$(MAKE) all && \
		$(MAKE) install
	$(REMOVE)/lcd4linux
	touch $@

$(D)/wpa_supplicant: $(D)/openssl $(ARCHIVE)/wpa_supplicant-$(WPA_SUPP_VER).tar.gz | $(TARGET_DIR)
	$(UNTAR)/wpa_supplicant-$(WPA_SUPP_VER).tar.gz
	pushd $(BUILD_TMP)/wpa_supplicant-$(WPA_SUPP_VER)/wpa_supplicant && \
		cp $(CONFIGS)/wpa_supplicant.config .config && \
		CC=$(TARGET)-gcc CFLAGS="$(TARGET_CFLAGS)" CXXFLAGS="$(TARGET_CXXFLAGS)" LDFLAGS="$(TARGET_LDFLAGS)" \
		$(MAKE)
	cp -f $(BUILD_TMP)/wpa_supplicant-$(WPA_SUPP_VER)/wpa_supplicant/wpa_cli $(TARGET_DIR)/sbin/wpa_cli
	cp -f $(BUILD_TMP)/wpa_supplicant-$(WPA_SUPP_VER)/wpa_supplicant/wpa_passphrase $(TARGET_DIR)/sbin/wpa_passphrase
	cp -f $(BUILD_TMP)/wpa_supplicant-$(WPA_SUPP_VER)/wpa_supplicant/wpa_supplicant $(TARGET_DIR)/sbin/wpa_supplicant
	$(REMOVE)/wpa_supplicant-$(WPA_SUPP_VER)
	touch $@

$(D)/xupnpd: $(D)/lua $(D)/openssl | $(TARGET_DIR)
	$(REMOVE)/xupnpd
	git clone https://github.com/clark15b/xupnpd.git $(BUILD_TMP)/xupnpd
	pushd $(BUILD_TMP)/xupnpd && \
		$(PATCH)/xupnpd-coolstream-dynamic-lua.patch && \
		$(PATCH)/xupnpd-fix-memleak-on-coolstream-boxes-thanks-ng777.patch && \
		$(PATCH)/xupnpd-fix-webif-backlinks.diff && \
		$(PATCH)/xupnpd-change-XUPNPDROOTDIR.diff && \
		$(PATCH)/xupnpd-add-configuration-files.diff
	pushd $(BUILD_TMP)/xupnpd/src && \
		$(BUILDENV) \
		$(MAKE) embedded TARGET=$(TARGET) CC=$(TARGET)-gcc STRIP=$(TARGET)-strip LUAFLAGS="$(TARGET_LDFLAGS) -I$(TARGET_INCLUDE_DIR)" && \
	install -D -m 0755 xupnpd $(BIN)/ && \
	mkdir -p $(TARGET_DIR)/share/xupnpd/config && \
	for object in *.lua plugins/ profiles/ ui/ www/; do \
		cp -a $$object $(TARGET_DIR)/share/xupnpd/; \
	done;
	rm $(TARGET_DIR)/share/xupnpd/plugins/staff/xupnpd_18plus.lua
	install -D -m 644 $(SOURCE_DIR)/$(NI_NEUTRINO-PLUGINS)/scripts-lua/xupnpd/xupnpd_18plus.lua $(TARGET_DIR)/share/xupnpd/plugins/
	install -D -m 644 $(SOURCE_DIR)/$(NI_NEUTRINO-PLUGINS)/scripts-lua/xupnpd/xupnpd_youtube.lua $(TARGET_DIR)/share/xupnpd/plugins/
	install -D -m 644 $(SOURCE_DIR)/$(NI_NEUTRINO-PLUGINS)/scripts-lua/xupnpd/xupnpd_coolstream.lua $(TARGET_DIR)/share/xupnpd/plugins/
	install -D -m 644 $(SOURCE_DIR)/$(NI_NEUTRINO-PLUGINS)/scripts-lua/xupnpd/xupnpd_cczwei.lua $(TARGET_DIR)/share/xupnpd/plugins/
	mkdir -p $(TARGET_DIR)/etc/init.d/
		install -D -m 0755 $(IMAGEFILES)/scripts/xupnpd.init $(TARGET_DIR)/etc/init.d/xupnpd
		ln -sf xupnpd $(TARGET_DIR)/etc/init.d/S99xupnpd
		ln -sf xupnpd $(TARGET_DIR)/etc/init.d/K01xupnpd
	cp -a $(IMAGEFILES)/xupnpd/* $(TARGET_DIR)/
	$(REMOVE)/xupnpd
	touch $@

DOSFSTOOLS_CFLAGS = $(TARGET_CFLAGS) -D_GNU_SOURCE -fomit-frame-pointer -D_FILE_OFFSET_BITS=64

$(D)/dosfstools: $(DOSFSTOOLS_DEPS) $(ARCHIVE)/dosfstools-$(DOSFSTOOLS_VER).tar.xz | $(TARGET_DIR)
	$(REMOVE)/dosfstools-$(DOSFSTOOLS_VER)
	$(UNTAR)/dosfstools-$(DOSFSTOOLS_VER).tar.xz
	set -e; cd $(BUILD_TMP)/dosfstools-$(DOSFSTOOLS_VER); \
		autoreconf -fi; \
		$(CONFIGURE) \
			--prefix= \
			--mandir=/.remove \
			--docdir=/.remove \
			--without-udev \
			--enable-compat-symlinks \
			CFLAGS="$(DOSFSTOOLS_CFLAGS)" \
		; \
		$(MAKE); \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
	$(REMOVE)/dosfstools-$(DOSFSTOOLS_VER)
	touch $@

NFS-UTILS_IPV6=--enable-ipv6
ifeq ($(BOXSERIES), hd1)
	NFS-UTILS_IPV6=--disable-ipv6
endif

$(D)/nfs-utils: $(D)/rpcbind $(ARCHIVE)/nfs-utils-$(NFS-UTILS_VER).tar.bz2 | $(TARGET_DIR)
	$(UNTAR)/nfs-utils-$(NFS-UTILS_VER).tar.bz2
	pushd $(BUILD_TMP)/nfs-utils-$(NFS-UTILS_VER) && \
	$(PATCH)/nfs-utils_01-Patch-taken-from-Gentoo.patch && \
	$(PATCH)/nfs-utils_02-Switch-legacy-index-in-favour-of-strchr.patch && \
	$(PATCH)/nfs-utils_03-Let-the-configure-script-find-getrpcbynumber-in-libt.patch && \
	$(PATCH)/nfs-utils_04-mountd-Add-check-for-struct-file_handle.patch && \
	$(PATCH)/nfs-utils_05-sm-notify-use-sbin-instead-of-usr-sbin.patch && \
	export knfsd_cv_bsd_signals=no && \
		autoreconf -fi && \
		$(CONFIGURE) \
			--prefix= \
			--target=$(TARGET) \
			--enable-maintainer-mode \
			--docdir=/.remove \
			--mandir=/.remove \
			--disable-nfsv4 \
			--disable-nfsv41 \
			--disable-gss \
			--disable-uuid \
			$(NFS-UTILS_IPV6) \
			--without-tcp-wrappers \
			--with-statedir=/var/lib/nfs \
			--with-rpcgen=internal \
			--without-systemd \
			; \
		$(MAKE) && \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
	chmod 755 $(TARGET_DIR)/sbin/mount.nfs
	rm -rf $(TARGET_DIR)/sbin/mountstats
	rm -rf $(TARGET_DIR)/sbin/nfsiostat
	rm -rf $(TARGET_DIR)/sbin/osd_login
	rm -rf $(TARGET_DIR)/sbin/start-statd
	rm -rf $(TARGET_DIR)/sbin/mount.nfs*
	rm -rf $(TARGET_DIR)/sbin/umount.nfs*
	rm -rf $(TARGET_DIR)/sbin/showmount
	rm -rf $(TARGET_DIR)/sbin/rpcdebug
	install -m 755 -D $(IMAGEFILES)/scripts/nfsd.init $(TARGET_DIR)/etc/init.d/nfsd
	ln -s nfsd $(TARGET_DIR)/etc/init.d/S60nfsd
	ln -s nfsd $(TARGET_DIR)/etc/init.d/K01nfsd
	$(REMOVE)/nfs-utils-$(NFS-UTILS_VER)
	touch $@

$(D)/rpcbind: $(D)/libtirpc $(ARCHIVE)/rpcbind-$(RPCBIND_VER).tar.bz2 | $(TARGET_DIR)
	$(UNTAR)/rpcbind-$(RPCBIND_VER).tar.bz2
	cd $(BUILD_TMP)/rpcbind-$(RPCBIND_VER) && \
	$(PATCH)/rpcbind-0001-Remove-yellow-pages-support.patch && \
		autoreconf -fi && \
		$(CONFIGURE) \
			--target=$(TARGET) \
			--prefix= \
			--enable-silent-rules \
			--with-rpcuser=root \
			--with-systemdsystemunitdir=no \
			--mandir=/.remove && \
		$(MAKE) && \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
ifeq ($(BOXSERIES), hd1)
		sed -i -e '/^\(udp\|tcp\)6/ d' $(TARGET_DIR)/etc/netconfig
endif
	rm -rf $(TARGET_DIR)/bin/rpcgen
	$(REMOVE)/rpcbind-$(RPCBIND_VER)
	touch $@

$(D)/fuse-exfat: $(ARCHIVE)/fuse-exfat-$(FUSE_EXFAT_VER).tar.gz $(D)/libfuse | $(TARGET_DIR)
	$(REMOVE)/fuse-exfat-$(FUSE_EXFAT_VER)
	$(UNTAR)/fuse-exfat-$(FUSE_EXFAT_VER).tar.gz
	pushd $(BUILD_TMP)/fuse-exfat-$(FUSE_EXFAT_VER); \
		autoreconf -fi; \
		$(CONFIGURE) \
			--prefix= \
			--docdir=/.remove \
			--mandir=/.remove \
			; \
		$(MAKE); \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
	$(REMOVE)/fuse-exfat-$(FUSE_EXFAT_VER)
	touch $@

$(D)/exfat-utils: $(ARCHIVE)/exfat-utils-$(EXFAT_UTILS_VER).tar.gz $(D)/fuse-exfat | $(TARGET_DIR)
	$(REMOVE)/exfat-utils-$(EXFAT_UTILS_VER)
	$(UNTAR)/exfat-utils-$(EXFAT_UTILS_VER).tar.gz
	pushd $(BUILD_TMP)/exfat-utils-$(EXFAT_UTILS_VER); \
		autoreconf -fi; \
		$(CONFIGURE) \
			--prefix= \
			--docdir=/.remove \
			--mandir=/.remove \
			; \
		$(MAKE); \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
	$(REMOVE)/exfat-utils-$(EXFAT_UTILS_VER)
	touch $@

$(D)/streamripper: $(D)/libvorbisidec $(D)/libmad $(D)/libglib2 | $(TARGET_DIR)
	$(REMOVE)/$(NI_STREAMRIPPER)
	tar -C $(SOURCE_DIR) -cp $(NI_STREAMRIPPER) --exclude-vcs | tar -C $(BUILD_TMP) -x
	pushd $(BUILD_TMP)/$(NI_STREAMRIPPER); \
		autoreconf -fi; \
		$(CONFIGURE) \
			--prefix= \
			--includedir=$(TARGET_DIR)/include \
			--datarootdir=/.remove \
			--with-included-argv=yes \
			--with-included-libmad=no \
			; \
		$(MAKE); \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
	install -m755 $(IMAGEFILES)/scripts/streamripper.sh $(TARGET_DIR)/bin/
	$(REMOVE)/$(NI_STREAMRIPPER)
	touch $@

$(D)/gettext: $(ARCHIVE)/gettext-$(GETTEXT_VERSION).tar.xz | $(TARGET_DIR)
	$(UNTAR)/gettext-$(GETTEXT_VERSION).tar.xz
	pushd $(BUILD_TMP)/gettext-$(GETTEXT_VERSION)/gettext-runtime; \
		autoreconf -fi; \
		$(CONFIGURE) \
			--prefix= \
			--datarootdir=/.remove \
			--disable-libasprintf \
			--disable-acl \
			--disable-openmp \
			--disable-java \
			--disable-native-java \
			--disable-csharp \
			--disable-relocatable \
			--without-emacs \
			; \
		$(MAKE); \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
	rm -rf $(TARGET_DIR)/bin/envsubst
	rm -rf $(TARGET_DIR)/bin/gettext
	rm -rf $(TARGET_DIR)/bin/gettext.sh
	rm -rf $(TARGET_DIR)/bin/ngettext
	$(REWRITE_LIBTOOL)/libintl.la
	$(REMOVE)/gettext-$(GETTEXT_VERSION)
	touch $@

$(D)/mc: $(ARCHIVE)/mc-$(MC_VER).tar.xz $(D)/libglib2 $(D)/libncurses | $(TARGET_DIR)
	$(REMOVE)/mc-$(MC_VER)
	$(UNTAR)/mc-$(MC_VER).tar.xz
	pushd $(BUILD_TMP)/mc-$(MC_VER); \
		autoreconf -fi; \
		$(CONFIGURE) \
			--prefix= \
			--mandir=/.remove \
			--enable-maintainer-mode \
			--enable-silent-rules \
			\
			--disable-charset \
			--disable-nls \
			--disable-vfs-extfs \
			--disable-vfs-fish \
			--disable-vfs-sfs \
			--disable-vfs-sftp \
			--with-screen=ncurses \
			--without-diff-viewer \
			--without-x \
		; \
		$(MAKE) all; \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
	rm -rf $(TARGET_DIR)/share/mc/examples
	find $(TARGET_DIR)/share/mc/skins -type f ! -name default.ini | xargs --no-run-if-empty rm
	$(REMOVE)/mc-$(MC_VER)
	touch $@

$(D)/wget: $(D)/openssl $(ARCHIVE)/wget-$(WGET_VER).tar.gz | $(TARGET_DIR)
	$(REMOVE)/wget-$(WGET_VER)
	$(UNTAR)/wget-$(WGET_VER).tar.gz
	cd $(BUILD_TMP)/wget-$(WGET_VER) && \
	$(PATCH)/wget-remove-hardcoded-engine-support-for-openss.patch && \
	$(PATCH)/wget-set-check_cert-false-by-default.patch && \
	$(PATCH)/wget-change_DEFAULT_LOGFILE.patch && \
		$(CONFIGURE) \
			--target=$(TARGET) \
			--prefix= \
			--datarootdir=/.remove \
			--docdir=/.remove \
			--sysconfdir=/.remove \
			--mandir=/.remove \
			--with-gnu-ld \
			--with-ssl=openssl \
			--disable-debug \
			&& \
		$(MAKE) && \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
	$(REMOVE)/wget-$(WGET_VER)
	touch $@

# builds only stripped down iconv binary
# used for smarthomeinfo plugin
$(D)/iconv: $(ARCHIVE)/libiconv-$(LIBICONV_VER).tar.gz | $(TARGET_DIR)
	$(UNTAR)/libiconv-$(LIBICONV_VER).tar.gz
	pushd $(BUILD_TMP)/libiconv-$(LIBICONV_VER) && \
	$(PATCH)/iconv-disable_transliterations.patch && \
	$(PATCH)/iconv-strip_charsets.patch && \
		$(CONFIGURE) \
			--target=$(TARGET) \
			--prefix= \
			--enable-static \
			--disable-shared \
			--enable-relocatable \
			--datarootdir=/.remove && \
		$(MAKE) && \
	$(MAKE) install DESTDIR=$(BUILD_TMP)/libiconv-$(LIBICONV_VER)/tmp
	cp -a $(BUILD_TMP)/libiconv-$(LIBICONV_VER)/tmp/bin/iconv $(TARGET_DIR)/bin
	$(REMOVE)/libiconv-$(LIBICONV_VER)
	touch $@

$(D)/ofgwrite: $(SOURCE_DIR)/$(NI_OFGWRITE) | $(TARGET_DIR)
	$(REMOVE)/$(NI_OFGWRITE)
	tar -C $(SOURCE_DIR) -cp $(NI_OFGWRITE) --exclude-vcs | tar -C $(BUILD_TMP) -x
	cd $(BUILD_TMP)/$(NI_OFGWRITE); \
		$(BUILDENV) \
		$(MAKE) && \
	install -m 755 $(BUILD_TMP)/$(NI_OFGWRITE)/ofgwrite_bin $(TARGET_DIR)/bin
	install -m 755 $(BUILD_TMP)/$(NI_OFGWRITE)/ofgwrite_tgz $(TARGET_DIR)/bin
	install -m 755 $(BUILD_TMP)/$(NI_OFGWRITE)/ofgwrite $(TARGET_DIR)/bin
	$(REMOVE)/$(NI_OFGWRITE)
	touch $@

$(D)/aio-grab: $(D)/zlib $(D)/libpng $(D)/libjpeg | $(TARGET_DIR)
	$(REMOVE)/aio-grab
	cd $(BUILD_TMP); \
	git clone git://github.com/oe-alliance/aio-grab.git aio-grab; \
	cd aio-grab; \
		aclocal --force -I m4; \
		libtoolize --copy --ltdl --force; \
		autoconf --force; \
		automake --add-missing --copy --force-missing --foreign; \
		$(CONFIGURE) \
			--target=$(TARGET) \
			--prefix= \
			--enable-silent-rules \
		; \
		$(MAKE) all; \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
	$(REMOVE)/aio-grab
	touch $@

$(D)/dvbsnoop: | $(TARGET_DIR)
	$(REMOVE)/dvbsnoop
	cd $(BUILD_TMP); \
	git clone https://github.com/Duckbox-Developers/dvbsnoop.git dvbsnoop; \
	cd dvbsnoop; \
		$(CONFIGURE) \
			--enable-silent-rules \
			--prefix= \
			--mandir=/.remove \
		; \
		$(MAKE); \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
	$(REMOVE)/dvbsnoop
	touch $@

$(D)/ethtool: $(ARCHIVE)/$(ETHTOOL_SOURCE) | $(TARGET_DIR)
	$(REMOVE)/ethtool-$(ETHTOOL_VER)
	$(UNTAR)/$(ETHTOOL_SOURCE)
	set -e; cd $(BUILD_TMP)/ethtool-$(ETHTOOL_VER); \
		$(CONFIGURE) \
			--prefix= \
			--mandir=/.remove \
			--libdir=$(TARGET_LIB_DIR) \
		; \
		$(MAKE); \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
	$(REMOVE)/ethtool-$(ETHTOOL_VER)
	touch $@

$(D)/ca-bundle: $(ARCHIVE)/cacert.pem | $(TARGET_DIR)
	install -D -m 644 $(ARCHIVE)/cacert.pem $(TARGET_DIR)/$(CA_BUNDLE_DIR)/$(CA_BUNDLE)
	touch $@
