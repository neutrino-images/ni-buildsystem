# makefile to build system tools

$(D)/openvpn: $(D)/lzo $(D)/openssl $(ARCHIVE)/openvpn-$(OPENVPN_VER).tar.xz | $(TARGETPREFIX)
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
	$(MAKE) install DESTDIR=$(TARGETPREFIX)
	$(REMOVE)/openvpn-$(OPENVPN_VER)
	touch $@

$(D)/openssh: $(D)/openssl $(D)/zlib $(ARCHIVE)/openssh-$(OPENSSH_VER).tar.gz | $(TARGETPREFIX)
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
		--with-cppflags="-pipe $(TARGET_O_CFLAGS) $(TARGET_MARCH_CFLAGS) -g -I$(TARGETINCLUDE)" \
		--with-ldflags="-L$(TARGETLIB)" \
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
	$(MAKE) install DESTDIR=$(TARGETPREFIX)
	$(REMOVE)/openssh-$(OPENSSH_VER)
	touch $@

ifeq ($(BOXSERIES), hd2)
  LOC_TIME = var/etc/localtime
else
  LOC_TIME = etc/localtime
endif

$(D)/timezone: $(ARCHIVE)/tzdata$(TZDATA_VER).tar.gz | $(TARGETPREFIX)
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
		install -d -m 0755 $(TARGETPREFIX)/share/ $(TARGETPREFIX)/etc; \
		mv zoneinfo/ $(TARGETPREFIX)/share/
	install -m 0644 $(IMAGEFILES)/timezone/timezone.xml $(TARGETPREFIX)/etc/
	cp $(TARGETPREFIX)/share/zoneinfo/CET $(TARGETPREFIX)/$(LOC_TIME)
	$(REMOVE)/timezone
	touch $@

$(D)/mtd-utils: $(D)/zlib $(D)/lzo $(D)/e2fsprogs $(ARCHIVE)/mtd-utils-$(MTD-UTILS_VER).tar.bz2 | $(TARGETPREFIX)
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
		install -D -m 0755 $(BUILD_TMP)/mtd-utils-$(MTD-UTILS_VER)/nanddump $(TARGETPREFIX)/sbin
		install -D -m 0755 $(BUILD_TMP)/mtd-utils-$(MTD-UTILS_VER)/nandtest $(TARGETPREFIX)/sbin
		install -D -m 0755 $(BUILD_TMP)/mtd-utils-$(MTD-UTILS_VER)/nandwrite $(TARGETPREFIX)/sbin
		install -D -m 0755 $(BUILD_TMP)/mtd-utils-$(MTD-UTILS_VER)/mtd_debug $(TARGETPREFIX)/sbin
		install -D -m 0755 $(BUILD_TMP)/mtd-utils-$(MTD-UTILS_VER)/mkfs.jffs2 $(TARGETPREFIX)/sbin
endif
		install -D -m 0755 $(BUILD_TMP)/mtd-utils-$(MTD-UTILS_VER)/flash_erase $(TARGETPREFIX)/sbin
		$(REMOVE)/mtd-utils-$(MTD-UTILS_VER)
		touch $@

$(D)/iperf: $(ARCHIVE)/iperf-$(IPERF_VER)-source.tar.gz | $(TARGETPREFIX)
	$(UNTAR)/iperf-$(IPERF_VER)-source.tar.gz
	pushd $(BUILD_TMP)/iperf-$(IPERF_VER); \
		$(PATCH)/iperf-disable-profiling.patch && \
		$(CONFIGURE) \
			--target=$(TARGET) \
			--prefix= \
			--mandir=/.remove; \
		$(MAKE); \
		$(MAKE) install DESTDIR=$(TARGETPREFIX)
	$(REMOVE)/iperf-$(IPERF_VER)
	touch $@

$(D)/parted: $(D)/e2fsprogs $(ARCHIVE)/parted-$(PARTED_VER).tar.xz | $(TARGETPREFIX)
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
		$(MAKE) install DESTDIR=$(TARGETPREFIX)
	$(REWRITE_LIBTOOL)/libparted.la
	$(REWRITE_LIBTOOL)/libparted-fs-resize.la
	$(REWRITE_PKGCONF) $(PKG_CONFIG_PATH)/libparted.pc
	$(REMOVE)/parted-$(PARTED_VER)
	touch $@

$(D)/hdparm: $(ARCHIVE)/hdparm-$(HDPARM_VER).tar.gz | $(TARGETPREFIX)
	$(UNTAR)/hdparm-$(HDPARM_VER).tar.gz
	pushd $(BUILD_TMP)/hdparm-$(HDPARM_VER) && \
		$(BUILDENV) \
		$(MAKE) CC=$(TARGET)-gcc STRIP=$(TARGET)-strip && \
		install -m755 hdparm $(TARGETPREFIX)/sbin/hdparm
	$(REMOVE)/hdparm-$(HDPARM_VER)
	touch $@

$(D)/hd-idle: $(ARCHIVE)/hd-idle-$(HDIDLE_VER).tgz | $(TARGETPREFIX)
	$(UNTAR)/hd-idle-$(HDIDLE_VER).tgz
	pushd $(BUILD_TMP)/hd-idle && \
		$(TARGET)-gcc $(TARGET_CFLAGS) $(TARGET_LDFLAGS) -o hd-idle hd-idle.c && \
	install -m755 hd-idle $(BIN)/
	$(REMOVE)/hd-idle
	touch $@

# only used for "touch"
$(D)/coreutils: $(ARCHIVE)/coreutils-$(COREUTILS_VER).tar.xz | $(TARGETPREFIX)
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

$(D)/less: $(D)/libncurses $(ARCHIVE)/less-$(LESS_VER).tar.gz | $(TARGETPREFIX)
	$(REMOVE)/less-$(LESS_VER)
	$(UNTAR)/less-$(LESS_VER).tar.gz
	cd $(BUILD_TMP)/less-$(LESS_VER) && \
		$(CONFIGURE) \
			--prefix= \
			--target=$(TARGET) \
			--mandir=/.remove \
			&& \
		$(MAKE) && \
		$(MAKE) install DESTDIR=$(TARGETPREFIX)
	$(REMOVE)/less-$(LESS_VER)
	touch $@

$(D)/ntp: $(ARCHIVE)/ntp-$(NTP_VER).tar.gz $(D)/openssl | $(TARGETPREFIX)
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
	mv -v $(BUILD_TMP)/ntp-$(NTP_VER)/ntpdate/ntpdate $(TARGETPREFIX)/sbin/
	$(REMOVE)/ntp-$(NTP_VER)
	touch $@

$(D)/djmount: $(ARCHIVE)/djmount-$(DJMOUNT_VER).tar.gz $(D)/libfuse | $(TARGETPREFIX)
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
		make install DESTDIR=$(TARGETPREFIX)
	install -D -m 755 $(IMAGEFILES)/scripts/djmount.init $(TARGETPREFIX)/etc/init.d/djmount
	ln -sf djmount $(TARGETPREFIX)/etc/init.d/S99djmount
	ln -sf djmount $(TARGETPREFIX)/etc/init.d/K01djmount
	$(REMOVE)/djmount-$(DJMOUNT_VER)
	touch $@

$(D)/ushare: $(ARCHIVE)/ushare-$(USHARE_VER).tar.bz2 $(D)/libupnp | $(TARGETPREFIX)
	$(UNTAR)/ushare-$(USHARE_VER).tar.bz2
	pushd $(BUILD_TMP)/ushare-$(USHARE_VER) && \
		$(PATCH)/ushare.diff && \
		$(BUILDENV) \
		./configure \
			--prefix=$(TARGETPREFIX) \
			--disable-dlna \
			--disable-nls \
			--cross-compile \
			--cross-prefix=$(TARGET)- && \
		sed -i config.h  -e 's@SYSCONFDIR.*@SYSCONFDIR "/etc"@' && \
		sed -i config.h  -e 's@LOCALEDIR.*@LOCALEDIR "/share"@' && \
		ln -sf ../config.h src/ && \
		$(MAKE) && \
		$(MAKE) install && \
		install -D -m 0644 $(IMAGEFILES)/scripts/ushare.conf $(TARGETPREFIX)/etc/ushare.conf
		install -D -m 0755 $(IMAGEFILES)/scripts/ushare.init $(TARGETPREFIX)/etc/init.d/ushare
		ln -sf ushare $(TARGETPREFIX)/etc/init.d/S99ushare
		ln -sf ushare $(TARGETPREFIX)/etc/init.d/K01ushare
	$(REMOVE)/ushare-$(USHARE_VER)
	touch $@

$(D)/smartmontools: $(ARCHIVE)/smartmontools-$(SMARTMON_VER).tar.gz | $(TARGETPREFIX)
	$(UNTAR)/smartmontools-$(SMARTMON_VER).tar.gz
	cd $(BUILD_TMP)/smartmontools-$(SMARTMON_VER) && \
		$(BUILDENV) \
		$(CONFIGURE) \
			--target=$(TARGET) \
			--prefix= && \
		$(MAKE) && \
		install -m755 smartctl $(TARGETPREFIX)/sbin/smartctl
	$(REMOVE)/smartmontools-$(SMARTMON_VER)
	touch $@

$(D)/inadyn: $(D)/openssl $(D)/confuse $(D)/libite $(ARCHIVE)/inadyn-$(INADYN_VER).tar.xz | $(TARGETPREFIX)
	$(REMOVE)/inadyn-$(INADYN_VER)
	$(UNTAR)/inadyn-$(INADYN_VER).tar.xz
	cd $(BUILD_TMP)/inadyn-$(INADYN_VER) && \
		autoreconf -fi && \
		$(CONFIGURE) \
			--prefix= \
			--libdir=$(TARGETLIB) \
			--includedir=$(TARGETINCLUDE) \
			--mandir=/.remove \
			--docdir=/.remove \
			--enable-openssl && \
		$(MAKE); \
		$(MAKE) install DESTDIR=$(TARGETPREFIX)
	install -D -m 644 $(IMAGEFILES)/scripts/inadyn.conf $(TARGETPREFIX)/var/etc/inadyn.conf
	ln -sf /var/etc/inadyn.conf $(TARGETPREFIX)/etc/inadyn.conf
	install -D -m 755 $(IMAGEFILES)/scripts/inadyn.init $(TARGETPREFIX)/etc/init.d/inadyn
	ln -sf inadyn $(TARGETPREFIX)/etc/init.d/S80inadyn
	ln -sf inadyn $(TARGETPREFIX)/etc/init.d/K60inadyn
	$(REMOVE)/inadyn-$(INADYN_VER)
	touch $@

$(D)/vsftpd: $(D)/openssl $(ARCHIVE)/vsftpd-$(VSFTPD_VER).tar.gz | $(TARGETPREFIX)
	$(UNTAR)/vsftpd-$(VSFTPD_VER).tar.gz
	cd $(BUILD_TMP)/vsftpd-$(VSFTPD_VER) && \
		$(PATCH)/vsftpd-fix-CVE-2015-1419.patch && \
		$(PATCH)/vsftpd-disable-capabilities.patch && \
		$(PATCH)/vsftpd-musl-compatibility.patch && \
		sed -i -e 's/.*VSF_BUILD_PAM/#undef VSF_BUILD_PAM/' builddefs.h && \
		sed -i -e 's/.*VSF_BUILD_SSL/#define VSF_BUILD_SSL/' builddefs.h && \
		make clean && \
		TARGETPREFIX=$(TARGETPREFIX) make CC=$(TARGET)-gcc LIBS="-lcrypt -lcrypto -lssl" CFLAGS="$(TARGET_CFLAGS)" LDFLAGS="$(TARGET_LDFLAGS)"
	install -d $(TARGETPREFIX)/share/empty
	install -D -m 755 $(BUILD_TMP)/vsftpd-$(VSFTPD_VER)/vsftpd $(TARGETPREFIX)/sbin/vsftpd
	install -D -m 644 $(IMAGEFILES)/scripts/vsftpd.conf $(TARGETPREFIX)/etc/vsftpd.conf
	install -D -m 644 $(IMAGEFILES)/scripts/vsftpd.chroot_list $(TARGETPREFIX)/etc/vsftpd.chroot_list
	install -D -m 755 $(IMAGEFILES)/scripts/vsftpd.init $(TARGETPREFIX)/etc/init.d/vsftpd
	ln -sf vsftpd $(TARGETPREFIX)/etc/init.d/S53vsftpd
	ln -sf vsftpd $(TARGETPREFIX)/etc/init.d/K80vsftpd
	$(REMOVE)/vsftpd-$(VSFTPD_VER)
	touch $@

$(D)/procps-ng: $(D)/libncurses $(ARCHIVE)/procps-ng-$(PROCPS-NG_VER).tar.xz | $(TARGETPREFIX)
	$(UNTAR)/procps-ng-$(PROCPS-NG_VER).tar.xz
	cd $(BUILD_TMP)/procps-ng-$(PROCPS-NG_VER) && \
	export ac_cv_func_malloc_0_nonnull=yes && \
	export ac_cv_func_realloc_0_nonnull=yes && \
		$(CONFIGURE) \
			--target=$(TARGET) \
			--prefix= && \
		$(MAKE) && \
		rm -f $(TARGETPREFIX)/bin/ps $(TARGETPREFIX)/bin/top && \
		install -D -m 755 top/.libs/top $(TARGETPREFIX)/bin/top && \
		install -D -m 755 ps/.libs/pscommand $(TARGETPREFIX)/bin/ps && \
		cp -a proc/.libs/libprocps.so* $(TARGETLIB)
	$(REMOVE)/procps-ng-$(PROCPS-NG_VER)
	touch $@

$(D)/nano: $(D)/libncurses $(ARCHIVE)/nano-$(NANO_VER).tar.gz | $(TARGETPREFIX)
	$(UNTAR)/nano-$(NANO_VER).tar.gz
	cd $(BUILD_TMP)/nano-$(NANO_VER) && \
		export ac_cv_prog_NCURSESW_CONFIG=false && \
		$(CONFIGURE) \
			--target=$(TARGET) \
			--prefix= && \
		$(MAKE) CURSES_LIB="-lncurses" && \
		install -m755 src/nano $(TARGETPREFIX)/bin
	$(REMOVE)/nano-$(NANO_VER)
	touch $@

$(D)/minicom: $(D)/libncurses $(ARCHIVE)/minicom-$(MINICOM_VER).tar.gz | $(TARGETPREFIX)
	$(UNTAR)/minicom-$(MINICOM_VER).tar.gz
	cd $(BUILD_TMP)/minicom-$(MINICOM_VER) && \
		$(PATCH)/minicom-fix-h-v-return-value-is-not-0.patch && \
		$(CONFIGURE) \
			--prefix= \
			--target=$(TARGET) \
			--disable-nls && \
		$(MAKE) && \
		install -m755 src/minicom $(TARGETPREFIX)/bin
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
	CONFIG_PREFIX="$(TARGETPREFIX)"

$(D)/busybox: $(D)/libtirpc $(ARCHIVE)/busybox-$(BUSYBOX_VER).tar.bz2 | $(TARGETPREFIX)
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

$(D)/bash: $(ARCHIVE)/bash-$(BASH_VER).tar.gz | $(TARGETPREFIX)
	$(REMOVE)/bash-$(BASH_VER)
	$(UNTAR)/bash-$(BASH_VER).tar.gz
	cd $(BUILD_TMP)/bash-$(BASH_VER); \
		for patch in $(PATCHES)/bash-$(BASH_MAJOR).$(BASH_MINOR)/*; do \
			patch -p0 -i $$patch; \
		done; \
		$(CONFIGURE) && \
		$(MAKE) && \
		install -m 755 bash $(TARGETPREFIX)/bin
	$(REMOVE)/bash-$(BASH_VER)
	touch $@

$(D)/e2fsprogs: $(ARCHIVE)/e2fsprogs-$(E2FSPROGS_VER).tar.gz | $(TARGETPREFIX)
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
		$(MAKE) install DESTDIR=$(TARGETPREFIX) && \
		cd lib/uuid/ && \
		$(MAKE) install DESTDIR=$(TARGETPREFIX)
	$(REWRITE_PKGCONF) $(PKG_CONFIG_PATH)/uuid.pc
	$(REMOVE)/e2fsprogs-$(E2FSPROGS_VER)
	cd $(TARGETPREFIX) && rm sbin/dumpe2fs sbin/logsave sbin/e2undo \
		sbin/filefrag sbin/e2freefrag bin/chattr bin/lsattr bin/uuidgen
	touch $@

$(D)/ntfs-3g: $(ARCHIVE)/ntfs-3g_ntfsprogs-$(NTFS3G_VER).tgz | $(TARGETPREFIX)
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
	install -m 755 $(BUILD_TMP)/ntfs-3g_ntfsprogs-$(NTFS3G_VER)/src/ntfs-3g $(TARGETPREFIX)/sbin/ntfs-3g
	$(REMOVE)/ntfs-3g_ntfsprogs-$(NTFS3G_VER)
	touch $@

# the 'autofs-use-pkg-config' patch for libtirpc link should hopefully be added upstream soon
# see: https://patchwork.ozlabs.org/patch/782714/
$(D)/autofs5: $(D)/libtirpc $(ARCHIVE)/autofs-$(AUTOFS5_VER).tar.gz | $(TARGETPREFIX)
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
		$(MAKE) SUBDIRS="lib daemon modules" install DESTDIR=$(TARGETPREFIX)
	cp -a $(IMAGEFILES)/autofs/* $(TARGETPREFIX)/
	ln -sf autofs $(TARGETPREFIX)/etc/init.d/S60autofs
	ln -sf autofs $(TARGETPREFIX)/etc/init.d/K40autofs
	$(REMOVE)/autofs-$(AUTOFS5_VER)
	touch $@

samba: samba-$(BOXSERIES)

$(D)/samba-hd1: $(D)/zlib $(ARCHIVE)/samba-$(SAMBA33_VER).tar.gz | $(TARGETPREFIX)
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
		$(MAKE) install DESTDIR=$(TARGETPREFIX)
	mkdir -p $(TARGETPREFIX)/var/samba/locks
	install $(IMAGEFILES)/scripts/smb3.conf $(TARGETPREFIX)/etc/samba/smb.conf
	install -m 755 $(IMAGEFILES)/scripts/samba3.init $(TARGETPREFIX)/etc/init.d/samba
	ln -sf samba $(TARGETPREFIX)/etc/init.d/S99samba
	ln -sf samba $(TARGETPREFIX)/etc/init.d/K01samba
	rm -rf $(TARGETPREFIX)/bin/testparm
	rm -rf $(TARGETPREFIX)/bin/findsmb
	rm -rf $(TARGETPREFIX)/bin/smbtar
	rm -rf $(TARGETPREFIX)/bin/smbclient
	rm -rf $(TARGETPREFIX)/bin/smbpasswd
	$(REMOVE)/samba-$(SAMBA33_VER)
	touch $@

$(D)/samba-hd51 \
$(D)/samba-hd2: $(D)/zlib $(ARCHIVE)/samba-$(SAMBA36_VER).tar.gz | $(TARGETPREFIX)
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
		$(MAKE) install DESTDIR=$(TARGETPREFIX)
	mkdir -p $(TARGETPREFIX)/var/samba/locks
	install $(IMAGEFILES)/scripts/smb3.conf $(TARGETPREFIX)/etc/samba/smb.conf
	install -m 755 $(IMAGEFILES)/scripts/samba3.init $(TARGETPREFIX)/etc/init.d/samba
	ln -sf samba $(TARGETPREFIX)/etc/init.d/S99samba
	ln -sf samba $(TARGETPREFIX)/etc/init.d/K01samba
	rm -rf $(TARGETPREFIX)/bin/testparm
	rm -rf $(TARGETPREFIX)/bin/findsmb
	rm -rf $(TARGETPREFIX)/bin/smbtar
	rm -rf $(TARGETPREFIX)/bin/smbclient
	rm -rf $(TARGETPREFIX)/bin/smbpasswd
	$(REMOVE)/samba-$(SAMBA36_VER)
	touch $@

$(D)/dropbear: $(D)/zlib $(ARCHIVE)/dropbear-$(DROPBEAR_VER).tar.bz2 | $(TARGETPREFIX)
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
		$(MAKE) PROGRAMS="dropbear dbclient dropbearkey scp" install DESTDIR=$(TARGETPREFIX)
	install -D -m 0755 $(IMAGEFILES)/scripts/dropbear.init $(TARGETPREFIX)/etc/init.d/dropbear
	install -d -m 0755 $(TARGETPREFIX)/etc/dropbear
	ln -sf dropbear $(TARGETPREFIX)/etc/init.d/S60dropbear
	ln -sf dropbear $(TARGETPREFIX)/etc/init.d/K60dropbear
	$(REMOVE)/dropbear-$(DROPBEAR_VER)
	touch $@

$(D)/sg3-utils: $(ARCHIVE)/sg3_utils-$(SG3-UTILS_VER).tar.xz | $(TARGETPREFIX)
	$(UNTAR)/sg3_utils-$(SG3-UTILS_VER).tar.xz
	cd $(BUILD_TMP)/sg3_utils-$(SG3-UTILS_VER) && \
		$(CONFIGURE) \
			--prefix= \
			--mandir=/.remove && \
		$(MAKE) && \
		cp -a src/.libs/sg_start $(TARGETPREFIX)/bin && \
		cp -a lib/.libs/libsgutils2.so.2.0.0 $(TARGETLIB) && \
		cp -a lib/.libs/libsgutils2.so.2 $(TARGETLIB) && \
		cp -a lib/.libs/libsgutils2.so $(TARGETLIB)
	$(REMOVE)/sg3_utils-$(SG3-UTILS_VER)
	touch $@

fbshot: $(TARGETPREFIX)/bin/fbshot
$(TARGETPREFIX)/bin/fbshot: $(D)/libpng $(ARCHIVE)/fbshot-$(FBSHOT_VER).tar.gz | $(TARGETPREFIX)
	$(REMOVE)/fbshot-$(FBSHOT_VER)
	$(UNTAR)/fbshot-$(FBSHOT_VER).tar.gz
	cd $(BUILD_TMP)/fbshot-$(FBSHOT_VER); \
		$(PATCH)/fbshot-32bit_cs_fb.diff; \
		$(PATCH)/fbshot_cs_hd2.diff; \
		$(TARGET)-gcc $(TARGET_CFLAGS) $(TARGET_LDFLAGS) fbshot.c -lpng -lz -o $@
	$(REMOVE)/fbshot-$(FBSHOT_VER)

$(D)/lcd4linux: $(D)/libncurses $(D)/libgd2 $(D)/libdpf | $(TARGETPREFIX)
	$(REMOVE)/lcd4linux
	git clone https://github.com/TangoCash/lcd4linux.git $(BUILD_TMP)/lcd4linux
	cd $(BUILD_TMP)/lcd4linux && \
		./bootstrap && \
		$(CONFIGURE) \
			--libdir=$(TARGETLIB) \
			--includedir=$(TARGETINCLUDE) \
			--bindir=$(TARGETPREFIX)/bin \
			--prefix= \
			--mandir=/.remove \
			--docdir=/.remove \
			--infodir=/.remove \
			--with-ncurses=$(TARGETLIB) \
			--with-drivers='DPF, SamsungSPF' \
			--with-plugins='all,!dbus,!mpris_dbus,!asterisk,!isdn,!pop3,!ppp,!seti,!huawei,!imon,!kvv,!sample,!w1retap,!wireless,!xmms,!gps,!mpd,!mysql,!qnaplog,!iconv' && \
		$(MAKE) vcs_version && \
		$(MAKE) all && \
		$(MAKE) install
	$(REMOVE)/lcd4linux
	touch $@

$(D)/wpa_supplicant: $(D)/openssl $(ARCHIVE)/wpa_supplicant-$(WPA_SUPP_VER).tar.gz | $(TARGETPREFIX)
	$(UNTAR)/wpa_supplicant-$(WPA_SUPP_VER).tar.gz
	pushd $(BUILD_TMP)/wpa_supplicant-$(WPA_SUPP_VER)/wpa_supplicant && \
		cp $(CONFIGS)/wpa_supplicant.config .config && \
		CC=$(TARGET)-gcc CFLAGS="$(TARGET_CFLAGS)" CXXFLAGS="$(TARGET_CXXFLAGS)" LDFLAGS="$(TARGET_LDFLAGS)" \
		$(MAKE)
	cp -f $(BUILD_TMP)/wpa_supplicant-$(WPA_SUPP_VER)/wpa_supplicant/wpa_cli $(TARGETPREFIX)/sbin/wpa_cli
	cp -f $(BUILD_TMP)/wpa_supplicant-$(WPA_SUPP_VER)/wpa_supplicant/wpa_passphrase $(TARGETPREFIX)/sbin/wpa_passphrase
	cp -f $(BUILD_TMP)/wpa_supplicant-$(WPA_SUPP_VER)/wpa_supplicant/wpa_supplicant $(TARGETPREFIX)/sbin/wpa_supplicant
	$(REMOVE)/wpa_supplicant-$(WPA_SUPP_VER)
	touch $@

$(D)/xupnpd: $(D)/lua $(D)/openssl | $(TARGETPREFIX)
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
		$(MAKE) embedded TARGET=$(TARGET) CC=$(TARGET)-gcc STRIP=$(TARGET)-strip LUAFLAGS="$(TARGET_LDFLAGS) -I$(TARGETINCLUDE)" && \
	install -D -m 0755 xupnpd $(BIN)/ && \
	mkdir -p $(TARGETPREFIX)/share/xupnpd/config && \
	for object in *.lua plugins/ profiles/ ui/ www/; do \
		cp -a $$object $(TARGETPREFIX)/share/xupnpd/; \
	done;
	rm $(TARGETPREFIX)/share/xupnpd/plugins/staff/xupnpd_18plus.lua
	install -D -m 644 $(SOURCE_DIR)/$(NI_NEUTRINO-PLUGINS)/scripts-lua/xupnpd/xupnpd_18plus.lua $(TARGETPREFIX)/share/xupnpd/plugins/
	install -D -m 644 $(SOURCE_DIR)/$(NI_NEUTRINO-PLUGINS)/scripts-lua/xupnpd/xupnpd_youtube.lua $(TARGETPREFIX)/share/xupnpd/plugins/
	install -D -m 644 $(SOURCE_DIR)/$(NI_NEUTRINO-PLUGINS)/scripts-lua/xupnpd/xupnpd_coolstream.lua $(TARGETPREFIX)/share/xupnpd/plugins/
	install -D -m 644 $(SOURCE_DIR)/$(NI_NEUTRINO-PLUGINS)/scripts-lua/xupnpd/xupnpd_cczwei.lua $(TARGETPREFIX)/share/xupnpd/plugins/
	mkdir -p $(TARGETPREFIX)/etc/init.d/
		install -D -m 0755 $(IMAGEFILES)/scripts/xupnpd.init $(TARGETPREFIX)/etc/init.d/xupnpd
		ln -sf xupnpd $(TARGETPREFIX)/etc/init.d/S99xupnpd
		ln -sf xupnpd $(TARGETPREFIX)/etc/init.d/K01xupnpd
	cp -a $(IMAGEFILES)/xupnpd/* $(TARGETPREFIX)/
	$(REMOVE)/xupnpd
	touch $@

$(D)/bc: $(ARCHIVE)/bc-$(BC_VER).tar.gz | $(TARGETPREFIX)
	$(UNTAR)/bc-$(BC_VER).tar.gz
	cd $(BUILD_TMP)/bc-$(BC_VER) && \
		autoreconf -fi && \
		$(CONFIGURE) \
			--target=$(TARGET) \
			--prefix= \
			--mandir=/.remove \
			--infodir=/.remove && \
		$(MAKE) && \
		$(MAKE) install DESTDIR=$(TARGETPREFIX)
	$(REMOVE)/bc-$(BC_VER)
	touch $@

DOSFSTOOLS_CFLAGS = $(TARGET_CFLAGS) -D_GNU_SOURCE -fomit-frame-pointer -D_FILE_OFFSET_BITS=64

$(D)/dosfstools: $(DOSFSTOOLS_DEPS) $(ARCHIVE)/dosfstools-$(DOSFSTOOLS_VER).tar.xz | $(TARGETPREFIX)
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
		$(MAKE) install DESTDIR=$(TARGETPREFIX)
	$(REMOVE)/dosfstools-$(DOSFSTOOLS_VER)
	touch $@

$(D)/nfs-utils: $(D)/rpcbind $(ARCHIVE)/nfs-utils-$(NFS-UTILS_VER).tar.bz2 | $(TARGETPREFIX)
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
			--disable-ipv6 \
			--without-tcp-wrappers \
			--with-statedir=/var/lib/nfs \
			--with-rpcgen=internal \
			--without-systemd \
			; \
		$(MAKE) && \
		$(MAKE) install DESTDIR=$(TARGETPREFIX)
	chmod 755 $(TARGETPREFIX)/sbin/mount.nfs
	rm -rf $(TARGETPREFIX)/sbin/mountstats
	rm -rf $(TARGETPREFIX)/sbin/nfsiostat
	rm -rf $(TARGETPREFIX)/sbin/osd_login
	rm -rf $(TARGETPREFIX)/sbin/start-statd
	rm -rf $(TARGETPREFIX)/sbin/mount.nfs*
	rm -rf $(TARGETPREFIX)/sbin/umount.nfs*
	rm -rf $(TARGETPREFIX)/sbin/showmount
	rm -rf $(TARGETPREFIX)/sbin/rpcdebug
	install -m 755 -D $(IMAGEFILES)/scripts/nfsd.init $(TARGETPREFIX)/etc/init.d/nfsd
	ln -s nfsd $(TARGETPREFIX)/etc/init.d/S60nfsd
	ln -s nfsd $(TARGETPREFIX)/etc/init.d/K01nfsd
	$(REMOVE)/nfs-utils-$(NFS-UTILS_VER)
	touch $@

$(D)/rpcbind: $(D)/libtirpc $(ARCHIVE)/rpcbind-$(RPCBIND_VER).tar.bz2 | $(TARGETPREFIX)
	$(UNTAR)/rpcbind-$(RPCBIND_VER).tar.bz2
	cd $(BUILD_TMP)/rpcbind-$(RPCBIND_VER) && \
	$(PATCH)/rpcbind-0001-Remove-yellow-pages-support.patch && \
	$(PATCH)/rpcbind-0002-handle_reply-Don-t-use-the-xp_auth-pointer-directly.patch && \
	$(PATCH)/rpcbind-0003-src-remove-use-of-the-__P-macro.patch && \
		autoreconf -fi && \
		$(CONFIGURE) \
			--target=$(TARGET) \
			--prefix= \
			--enable-silent-rules \
			--with-rpcuser=root \
			--with-systemdsystemunitdir=no \
			--mandir=/.remove && \
		$(MAKE) && \
		$(MAKE) install DESTDIR=$(TARGETPREFIX)
ifeq ($(BOXSERIES), hd1)
		sed -i -e '/^\(udp\|tcp\)6/ d' $(TARGETPREFIX)/etc/netconfig
endif
	rm -rf $(TARGETPREFIX)/bin/rpcgen
	$(REMOVE)/rpcbind-$(RPCBIND_VER)
	touch $@

$(D)/fuse-exfat: $(ARCHIVE)/fuse-exfat-$(FUSE_EXFAT_VER).tar.gz $(D)/libfuse | $(TARGETPREFIX)
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
		$(MAKE) install DESTDIR=$(TARGETPREFIX)
	$(REMOVE)/fuse-exfat-$(FUSE_EXFAT_VER)
	touch $@

$(D)/exfat-utils: $(ARCHIVE)/exfat-utils-$(EXFAT_UTILS_VER).tar.gz $(D)/fuse-exfat | $(TARGETPREFIX)
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
		$(MAKE) install DESTDIR=$(TARGETPREFIX)
	$(REMOVE)/exfat-utils-$(EXFAT_UTILS_VER)
	touch $@

$(D)/streamripper: $(D)/libvorbisidec $(D)/libmad $(D)/libglib | $(TARGETPREFIX)
	$(REMOVE)/$(NI_STREAMRIPPER)
	tar -C $(SOURCE_DIR) -cp $(NI_STREAMRIPPER) --exclude-vcs | tar -C $(BUILD_TMP) -x
	pushd $(BUILD_TMP)/$(NI_STREAMRIPPER); \
		autoreconf -fi; \
		$(CONFIGURE) \
			--prefix= \
			--includedir=$(TARGETPREFIX)/include \
			--datarootdir=/.remove \
			--with-included-argv=yes \
			--with-included-libmad=no \
			; \
		$(MAKE); \
		$(MAKE) install DESTDIR=$(TARGETPREFIX)
	install -m755 $(IMAGEFILES)/scripts/streamripper.sh $(TARGETPREFIX)/bin/
	$(REMOVE)/$(NI_STREAMRIPPER)
	touch $@

$(D)/gettext: $(ARCHIVE)/gettext-$(GETTEXT_VERSION).tar.xz | $(TARGETPREFIX)
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
		$(MAKE) install DESTDIR=$(TARGETPREFIX)
	rm -rf $(TARGETPREFIX)/bin/envsubst
	rm -rf $(TARGETPREFIX)/bin/gettext
	rm -rf $(TARGETPREFIX)/bin/gettext.sh
	rm -rf $(TARGETPREFIX)/bin/ngettext
	$(REWRITE_LIBTOOL)/libintl.la
	$(REMOVE)/gettext-$(GETTEXT_VERSION)
	touch $@

$(D)/mc: $(ARCHIVE)/mc-$(MC-VER).tar.xz $(D)/libglib $(D)/libncurses | $(TARGETPREFIX)
	$(REMOVE)/mc-$(MC-VER)
	$(UNTAR)/mc-$(MC-VER).tar.xz
	pushd $(BUILD_TMP)/mc-$(MC-VER); \
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
		$(MAKE) install DESTDIR=$(TARGETPREFIX)
	rm -rf $(TARGETPREFIX)/share/mc/examples
	find $(TARGETPREFIX)/share/mc/skins -type f ! -name default.ini | xargs --no-run-if-empty rm
	$(REMOVE)/mc-$(MC-VER)
	touch $@

$(D)/wget: $(D)/openssl $(ARCHIVE)/wget-$(WGET_VER).tar.gz | $(TARGETPREFIX)
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
		$(MAKE) install DESTDIR=$(TARGETPREFIX)
	$(REMOVE)/wget-$(WGET_VER)
	touch $@

# builds only stripped down iconv binary
# used for smarthomeinfo plugin
$(D)/iconv: $(ARCHIVE)/libiconv-$(LIBICONV_VER).tar.gz | $(TARGETPREFIX)
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
	cp -a $(BUILD_TMP)/libiconv-$(LIBICONV_VER)/tmp/bin/iconv $(TARGETPREFIX)/bin
	$(REMOVE)/libiconv-$(LIBICONV_VER)
	touch $@

$(D)/ofgwrite: $(SOURCE_DIR)/$(NI_OFGWRITE) | $(TARGETPREFIX)
	$(REMOVE)/$(NI_OFGWRITE)
	tar -C $(SOURCE_DIR) -cp $(NI_OFGWRITE) --exclude-vcs | tar -C $(BUILD_TMP) -x
	cd $(BUILD_TMP)/$(NI_OFGWRITE); \
		$(BUILDENV) \
		$(MAKE) && \
	install -m 755 $(BUILD_TMP)/$(NI_OFGWRITE)/ofgwrite_bin $(TARGETPREFIX)/bin
	install -m 755 $(BUILD_TMP)/$(NI_OFGWRITE)/ofgwrite_tgz $(TARGETPREFIX)/bin
	install -m 755 $(BUILD_TMP)/$(NI_OFGWRITE)/ofgwrite $(TARGETPREFIX)/bin
	$(REMOVE)/$(NI_OFGWRITE)
	touch $@

$(D)/aio-grab: $(D)/zlib $(D)/libpng $(D)/libjpeg | $(TARGETPREFIX)
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
		$(MAKE) install DESTDIR=$(TARGETPREFIX)
	$(REMOVE)/aio-grab
	touch $@
