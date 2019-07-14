#
# makefile to build system tools
#
# -----------------------------------------------------------------------------

BUSYBOX_VER    = 1.30.1
BUSYBOX_TMP    = busybox-$(BUSYBOX_VER)
BUSYBOX_SOURCE = busybox-$(BUSYBOX_VER).tar.bz2
BUSYBOX_URL    = https://busybox.net/downloads

$(ARCHIVE)/$(BUSYBOX_SOURCE):
	$(DOWNLOAD) $(BUSYBOX_URL)/$(BUSYBOX_SOURCE)

BUSYBOX_PATCH  = busybox-fix-config-header.diff
BUSYBOX_PATCH += busybox-insmod-hack.patch
BUSYBOX_PATCH += busybox-mount-use-var-etc-fstab.patch
BUSYBOX_PATCH += busybox-fix-partition-size.patch
BUSYBOX_PATCH += busybox-mount_single_uuid.patch

# Link busybox against libtirpc so that we can leverage its RPC support for NFS
# mounting with BusyBox
BUSYBOX_CFLAGS = $(TARGET_CFLAGS)
BUSYBOX_CFLAGS += "`$(PKG_CONFIG) --cflags libtirpc`"
# Don't use LDFLAGS for -ltirpc, because LDFLAGS is used for the non-final link
# of modules as well.
BUSYBOX_CFLAGS_busybox = "`$(PKG_CONFIG) --libs libtirpc`"

# Allows the buildsystem to tweak CFLAGS
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

$(D)/busybox: $(D)/libtirpc $(ARCHIVE)/$(BUSYBOX_SOURCE) | $(TARGET_DIR)
	$(REMOVE)/$(BUSYBOX_TMP)
	$(UNTAR)/$(BUSYBOX_SOURCE)
	$(CHDIR)/$(BUSYBOX_TMP); \
		$(call apply_patches, $(BUSYBOX_PATCH)); \
		cp $(CONFIGS)/busybox-$(BOXTYPE)-$(BOXSERIES).config .config; \
		sed -i -e 's|^CONFIG_PREFIX=.*|CONFIG_PREFIX="$(TARGET_DIR)"|' .config; \
		$(BUSYBOX_MAKE_ENV) $(MAKE) busybox $(BUSYBOX_MAKE_OPTS); \
		$(BUSYBOX_MAKE_ENV) $(MAKE) install $(BUSYBOX_MAKE_OPTS)
	$(REMOVE)/$(BUSYBOX_TMP)
	$(TOUCH)

# -----------------------------------------------------------------------------

OPENVPN_VER    = 2.4.6
OPENVPN_TMP    = openvpn-$(OPENVPN_VER)
OPENVPN_SOURCE = openvpn-$(OPENVPN_VER).tar.xz
OPENVPN_URL    = http://build.openvpn.net/downloads/releases

$(ARCHIVE)/$(OPENVPN_SOURCE):
	$(DOWNLOAD) $(OPENVPN_URL)/$(OPENVPN_SOURCE)

$(D)/openvpn: $(D)/lzo $(D)/openssl $(ARCHIVE)/$(OPENVPN_SOURCE) | $(TARGET_DIR)
	$(REMOVE)/$(OPENVPN_TMP)
	$(UNTAR)/$(OPENVPN_SOURCE)
	$(CHDIR)/$(OPENVPN_TMP); \
		$(CONFIGURE) \
			IFCONFIG="/sbin/ifconfig" \
			NETSTAT="/bin/netstat" \
			ROUTE="/sbin/route" \
			IPROUTE="/sbin/ip" \
			--prefix= \
			--mandir=$(remove-mandir) \
			--docdir=$(remove-docdir) \
			--infodir=$(remove-infodir) \
			--enable-shared \
			--disable-static \
			--enable-small \
			--enable-management \
			--disable-debug \
			--disable-selinux \
			--disable-plugins \
			--disable-pkcs11 \
			; \
		$(MAKE); \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
	$(REMOVE)/$(OPENVPN_TMP)
	$(TOUCH)

# -----------------------------------------------------------------------------

OPENSSH_VER    = 7.9p1
OPENSSH_TMP    = openssh-$(OPENSSH_VER)
OPENSSH_SOURCE = openssh-$(OPENSSH_VER).tar.gz
OPENSSH_URL    = https://artfiles.org/openbsd/OpenSSH/portable

$(ARCHIVE)/$(OPENSSH_SOURCE):
	$(DOWNLOAD) $(OPENSSH_URL)/$(OPENSSH_SOURCE)

$(D)/openssh: $(D)/openssl $(D)/zlib $(ARCHIVE)/$(OPENSSH_SOURCE) | $(TARGET_DIR)
	$(REMOVE)/$(OPENSSH_TMP)
	$(UNTAR)/$(OPENSSH_SOURCE)
	$(CHDIR)/$(OPENSSH_TMP); \
		export ac_cv_search_dlopen=no; \
		./configure \
			$(CONFIGURE_OPTS) \
			--prefix= \
			--mandir=$(remove-mandir) \
			--docdir=$(remove-docdir) \
			--infodir=$(remove-infodir) \
			--with-pid-dir=/tmp \
			--with-privsep-path=/var/empty \
			--with-cppflags="-pipe $(TARGET_OPTIMIZATION) $(TARGET_DEBUGGING) $(TARGET_ABI) -I$(TARGET_INCLUDE_DIR)" \
			--with-ldflags="-L$(TARGET_LIB_DIR)" \
			--libexecdir=/bin \
			--disable-strip \
			--disable-lastlog \
			--disable-utmp \
			--disable-utmpx \
			--disable-wtmp \
			--disable-wtmpx \
			--disable-pututline \
			--disable-pututxline \
			; \
		$(MAKE); \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
	$(REMOVE)/$(OPENSSH_TMP)
	$(TOUCH)

# -----------------------------------------------------------------------------

TZDATA_VER    = 2018e
TZDATA_TMP    = tzdata$(TZDATA_VER)
TZDATA_SOURCE = tzdata$(TZDATA_VER).tar.gz
TZDATA_URL    = ftp://ftp.iana.org/tz/releases

$(ARCHIVE)/$(TZDATA_SOURCE):
	$(DOWNLOAD) $(TZDATA_URL)/$(TZDATA_SOURCE)

ifeq ($(BOXSERIES), hd2)
  LOCALTIME = var/etc/localtime
else
  LOCALTIME = etc/localtime
endif

$(D)/tzdata: $(ARCHIVE)/$(TZDATA_SOURCE) | $(TARGET_DIR)
	$(REMOVE)/$(TZDATA_TMP)
	$(MKDIR)/$(TZDATA_TMP)
	$(CHDIR)/$(TZDATA_TMP); \
		tar -xf $(ARCHIVE)/$(TZDATA_SOURCE); \
		unset ${!LC_*}; LANG=POSIX; LC_ALL=POSIX; export LANG LC_ALL; \
		zic -d zoneinfo.tmp \
			africa antarctica asia australasia \
			europe northamerica southamerica pacificnew \
			etcetera backward; \
		mkdir zoneinfo; \
		sed -n '/zone=/{s/.*zone="\(.*\)".*$$/\1/; p}' $(IMAGEFILES)/timezone/timezone.xml | sort -u | \
		while read x; do \
			find zoneinfo.tmp -type f -name $$x | sort | \
			while read y; do \
				cp -a $$y zoneinfo/$$x; \
			done; \
			test -e zoneinfo/$$x || echo "WARNING: timezone $$x not found."; \
		done; \
		install -d -m 0755 $(TARGET_SHARE_DIR)/ $(TARGET_DIR)/etc; \
		mv zoneinfo/ $(TARGET_SHARE_DIR)/
	install -m 0644 $(IMAGEFILES)/timezone/timezone.xml $(TARGET_DIR)/etc/
	cp $(TARGET_SHARE_DIR)/zoneinfo/CET $(TARGET_DIR)/$(LOCALTIME)
	$(REMOVE)/$(TZDATA_TMP)
	$(TOUCH)

# -----------------------------------------------------------------------------

MTD-UTILS_VER    = 2.0.2
MTD-UTILS_TMP    = mtd-utils-$(MTD-UTILS_VER)
MTD-UTILS_SOURCE = mtd-utils-$(MTD-UTILS_VER).tar.bz2
MTD-UTILS_URL    = ftp://ftp.infradead.org/pub/mtd-utils

$(ARCHIVE)/$(MTD-UTILS_SOURCE):
	$(DOWNLOAD) $(MTD-UTILS_URL)/$(MTD-UTILS_SOURCE)

$(D)/mtd-utils: $(D)/zlib $(D)/lzo $(D)/e2fsprogs $(ARCHIVE)/$(MTD-UTILS_SOURCE) | $(TARGET_DIR)
	$(REMOVE)/$(MTD-UTILS_TMP)
	$(UNTAR)/$(MTD-UTILS_SOURCE)
	$(CHDIR)/$(MTD-UTILS_TMP); \
		$(CONFIGURE) \
			--prefix= \
			--target=$(TARGET) \
			--mandir=$(remove-mandir) \
			--enable-silent-rules \
			--disable-tests \
			--without-xattr \
			; \
		$(MAKE)
ifeq ($(BOXSERIES), hd2)
	install -D -m 0755 $(BUILD_TMP)/$(MTD-UTILS_TMP)/nanddump $(TARGET_DIR)/sbin
	install -D -m 0755 $(BUILD_TMP)/$(MTD-UTILS_TMP)/nandtest $(TARGET_DIR)/sbin
	install -D -m 0755 $(BUILD_TMP)/$(MTD-UTILS_TMP)/nandwrite $(TARGET_DIR)/sbin
	install -D -m 0755 $(BUILD_TMP)/$(MTD-UTILS_TMP)/mtd_debug $(TARGET_DIR)/sbin
	install -D -m 0755 $(BUILD_TMP)/$(MTD-UTILS_TMP)/mkfs.jffs2 $(TARGET_DIR)/sbin
endif
	install -D -m 0755 $(BUILD_TMP)/$(MTD-UTILS_TMP)/flash_erase $(TARGET_DIR)/sbin
	$(REMOVE)/$(MTD-UTILS_TMP)
	$(TOUCH)

# -----------------------------------------------------------------------------

IPERF_VER    = 3.1.3
IPERF_TMP    = iperf-$(IPERF_VER)
IPERF_SOURCE = iperf-$(IPERF_VER)-source.tar.gz
IPERF_URL    = https://iperf.fr/download/source

$(ARCHIVE)/$(IPERF_SOURCE):
	$(DOWNLOAD) $(IPERF_URL)/$(IPERF_SOURCE)

IPERF_PATCH  = iperf-disable-profiling.patch

$(D)/iperf: $(ARCHIVE)/$(IPERF_SOURCE) | $(TARGET_DIR)
	$(REMOVE)/$(IPERF_TMP)
	$(UNTAR)/$(IPERF_SOURCE)
	$(CHDIR)/$(IPERF_TMP); \
		$(call apply_patches, $(IPERF_PATCH)); \
		$(CONFIGURE) \
			--target=$(TARGET) \
			--prefix= \
			--mandir=$(remove-mandir) \
			; \
		$(MAKE); \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
	$(REMOVE)/$(IPERF_TMP)
	$(TOUCH)

# -----------------------------------------------------------------------------

PARTED_VER    = 3.2
PARTED_TMP    = parted-$(PARTED_VER)
PARTED_SOURCE = parted-$(PARTED_VER).tar.xz
PARTED_URL    = https://ftp.gnu.org/gnu/parted

$(ARCHIVE)/$(PARTED_SOURCE):
	$(DOWNLOAD) $(PARTED_URL)/$(PARTED_SOURCE)

PARTED_PATCH  = parted-devmapper-1.patch
PARTED_PATCH += parted-sysmacros.patch

$(D)/parted: $(D)/e2fsprogs $(ARCHIVE)/$(PARTED_SOURCE) | $(TARGET_DIR)
	$(REMOVE)/$(PARTED_TMP)
	$(UNTAR)/$(PARTED_SOURCE)
	$(CHDIR)/$(PARTED_TMP); \
		$(call apply_patches, $(PARTED_PATCH)); \
		$(CONFIGURE) \
			--prefix= \
			--target=$(TARGET) \
			--mandir=$(remove-mandir) \
			--infodir=$(remove-infodir) \
			--enable-silent-rules \
			--enable-shared \
			--disable-static \
			--disable-debug \
			--disable-pc98 \
			--disable-nls \
			--disable-device-mapper \
			--without-readline \
			; \
		$(MAKE); \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
	$(REWRITE_LIBTOOL)/libparted.la
	$(REWRITE_LIBTOOL)/libparted-fs-resize.la
	$(REWRITE_PKGCONF)/libparted.pc
	$(REMOVE)/$(PARTED_TMP)
	$(TOUCH)

# -----------------------------------------------------------------------------

HDPARM_VER    = 9.54
HDPARM_TMP    = hdparm-$(HDPARM_VER)
HDPARM_SOURCE = hdparm-$(HDPARM_VER).tar.gz
HDPARM_URL    = https://sourceforge.net/projects/hdparm/files/hdparm

$(ARCHIVE)/$(HDPARM_SOURCE):
	$(DOWNLOAD) $(HDPARM_URL)/$(HDPARM_SOURCE)

$(D)/hdparm: $(ARCHIVE)/$(HDPARM_SOURCE) | $(TARGET_DIR)
	$(REMOVE)/$(HDPARM_TMP)
	$(UNTAR)/$(HDPARM_SOURCE)
	$(CHDIR)/$(HDPARM_TMP); \
		$(BUILDENV) \
		$(MAKE); \
		install -D -m 0755 hdparm $(TARGET_DIR)/sbin/hdparm
	$(REMOVE)/$(HDPARM_TMP)
	$(TOUCH)

# -----------------------------------------------------------------------------

HD-IDLE_VER    = 1.05
HD-IDLE_TMP    = hd-idle
HD-IDLE_SOURCE = hd-idle-$(HD-IDLE_VER).tgz
HD-IDLE_URL    = https://sourceforge.net/projects/hd-idle/files

$(ARCHIVE)/$(HD-IDLE_SOURCE):
	$(DOWNLOAD) $(HD-IDLE_URL)/$(HD-IDLE_SOURCE)

$(D)/hd-idle: $(ARCHIVE)/$(HD-IDLE_SOURCE) | $(TARGET_DIR)
	$(REMOVE)/$(HD-IDLE_TMP)
	$(UNTAR)/$(HD-IDLE_SOURCE)
	$(CHDIR)/$(HD-IDLE_TMP); \
		$(BUILDENV) \
		$(MAKE); \
		install -D -m 0755 hd-idle $(TARGET_DIR)/sbin/hd-idle
	$(REMOVE)/$(HD-IDLE_TMP)
	$(TOUCH)

# -----------------------------------------------------------------------------

COREUTILS_VER    = 8.30
COREUTILS_TMP    = coreutils-$(COREUTILS_VER)
COREUTILS_SOURCE = coreutils-$(COREUTILS_VER).tar.xz
COREUTILS_URL    = https://ftp.gnu.org/gnu/coreutils

$(ARCHIVE)/$(COREUTILS_SOURCE):
	$(DOWNLOAD) $(COREUTILS_URL)/$(COREUTILS_SOURCE)

COREUTILS_PATCH  = coreutils-fix-build.patch

COREUTILS_BIN    = touch

$(D)/coreutils: $(ARCHIVE)/$(COREUTILS_SOURCE) | $(TARGET_DIR)
	$(REMOVE)/$(COREUTILS_TMP)
	$(UNTAR)/$(COREUTILS_SOURCE)
	$(CHDIR)/$(COREUTILS_TMP); \
		$(call apply_patches, $(COREUTILS_PATCH)); \
		autoreconf -fi; \
		$(CONFIGURE) \
			--target=$(TARGET) \
			--prefix= \
			--bindir=/bin.coreutils \
			--libexecdir=$(remove-libexecdir) \
			--datarootdir=$(remove-datarootdir) \
			--enable-silent-rules \
			--disable-xattr \
			--disable-libcap \
			--disable-acl \
			--without-gmp \
			--without-selinux \
			; \
		$(MAKE); \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
	for bin in $(COREUTILS_BIN); do \
		rm -f $(TARGET_DIR)/bin/$$bin; \
		install -m 0755 $(TARGET_DIR)/bin.coreutils/$$bin $(TARGET_DIR)/bin/$$bin; \
	done
	$(REMOVE)/$(COREUTILS_TMP) \
		$(TARGET_DIR)/bin.coreutils
	$(TOUCH)

# -----------------------------------------------------------------------------

LESS_VER    = 530
LESS_TMP    = less-$(LESS_VER)
LESS_SOURCE = less-$(LESS_VER).tar.gz
LESS_URL    = http://www.greenwoodsoftware.com/less

$(ARCHIVE)/$(LESS_SOURCE):
	$(DOWNLOAD) $(LESS_URL)/$(LESS_SOURCE)

$(D)/less: $(D)/ncurses $(ARCHIVE)/$(LESS_SOURCE) | $(TARGET_DIR)
	$(REMOVE)/$(LESS_TMP)
	$(UNTAR)/$(LESS_SOURCE)
	$(CHDIR)/$(LESS_TMP); \
		$(CONFIGURE) \
			--prefix= \
			--target=$(TARGET) \
			--mandir=$(remove-mandir) \
			; \
		$(MAKE); \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
	$(REMOVE)/$(LESS_TMP)
	$(TOUCH)

# -----------------------------------------------------------------------------

NTP_VER    = 4.2.8
NTP_TMP    = ntp-$(NTP_VER)
NTP_SOURCE = ntp-$(NTP_VER).tar.gz
NTP_URL    = https://www.eecis.udel.edu/~ntp/ntp_spool/ntp4/ntp-$(basename $(NTP_VER))

$(ARCHIVE)/$(NTP_SOURCE):
	$(DOWNLOAD) $(NTP_URL)/$(NTP_SOURCE)

NTP_PATCH  = ntp.patch

$(D)/ntp: $(D)/openssl $(ARCHIVE)/$(NTP_SOURCE) | $(TARGET_DIR)
	$(REMOVE)/$(NTP_TMP)
	$(UNTAR)/$(NTP_SOURCE)
	$(CHDIR)/$(NTP_TMP); \
		$(call apply_patches, $(NTP_PATCH)); \
		$(CONFIGURE) \
			--prefix= \
			--target=$(TARGET) \
			--disable-debugging \
			--with-shared \
			--with-crypto \
			--with-yielding-select=yes \
			--without-ntpsnmpd \
			; \
		$(MAKE); \
		install -D -m 0755 ntpdate/ntpdate $(TARGET_DIR)/sbin/ntpdate
	install -D -m 0755 $(IMAGEFILES)/scripts/ntpdate.init $(TARGET_DIR)/etc/init.d/ntpdate
	$(REMOVE)/$(NTP_TMP)
	$(TOUCH)

# -----------------------------------------------------------------------------

DJMOUNT_VER    = 0.71
DJMOUNT_TMP    = djmount-$(DJMOUNT_VER)
DJMOUNT_SOURCE = djmount-$(DJMOUNT_VER).tar.gz
DJMOUNT_URL    = https://sourceforge.net/projects/djmount/files/djmount/$(DJMOUNT_VER)

$(ARCHIVE)/$(DJMOUNT_SOURCE):
	$(DOWNLOAD) $(DJMOUNT_URL)/$(DJMOUNT_SOURCE)

DJMOUNT_PATCH  = djmount-fix-hang-with-asset-upnp.patch
DJMOUNT_PATCH += djmount-fix-incorrect-range-when-retrieving-content-via-HTTP.patch
DJMOUNT_PATCH += djmount-fix-new-autotools.diff
DJMOUNT_PATCH += djmount-fixed-crash-when-using-UTF-8-charset.patch
DJMOUNT_PATCH += djmount-fixed-crash.patch
DJMOUNT_PATCH += djmount-support-fstab-mounting.diff
DJMOUNT_PATCH += djmount-support-seeking-in-large-2gb-files.patch

$(D)/djmount: $(D)/libfuse $(ARCHIVE)/$(DJMOUNT_SOURCE) | $(TARGET_DIR)
	$(REMOVE)/$(DJMOUNT_TMP)
	$(UNTAR)/$(DJMOUNT_SOURCE)
	$(CHDIR)/$(DJMOUNT_TMP); \
		$(call apply_patches, $(DJMOUNT_PATCH)); \
		touch libupnp/config.aux/config.rpath; \
		autoreconf -fi; \
		$(CONFIGURE) -C \
			--prefix= \
			--disable-debug \
			; \
		make; \
		make install DESTDIR=$(TARGET_DIR)
	install -D -m 0755 $(IMAGEFILES)/scripts/djmount.init $(TARGET_DIR)/etc/init.d/djmount
	ln -sf djmount $(TARGET_DIR)/etc/init.d/S99djmount
	ln -sf djmount $(TARGET_DIR)/etc/init.d/K01djmount
	$(REMOVE)/$(DJMOUNT_TMP)
	$(TOUCH)

# -----------------------------------------------------------------------------

USHARE_VER    = 1.1a
USHARE_TMP    = ushare-uShare_v$(USHARE_VER)
USHARE_SOURCE = uShare_v$(USHARE_VER).tar.gz
USHARE_URL    = https://github.com/GeeXboX/ushare/archive

$(ARCHIVE)/$(USHARE_SOURCE):
	$(DOWNLOAD) $(USHARE_URL)/$(USHARE_SOURCE)

USHARE_PATCH  = ushare.diff
USHARE_PATCH += ushare-fix-building-with-gcc-5.x.patch

$(D)/ushare: $(D)/libupnp $(ARCHIVE)/$(USHARE_SOURCE)| $(TARGET_DIR)
	$(REMOVE)/$(USHARE_TMP)
	$(UNTAR)/$(USHARE_SOURCE)
	$(CHDIR)/$(USHARE_TMP); \
		$(call apply_patches, $(USHARE_PATCH)); \
		$(BUILDENV) \
		./configure \
			--prefix= \
			--disable-dlna \
			--disable-nls \
			--cross-compile \
			--cross-prefix=$(TARGET)- \
			; \
		sed -i config.h -e 's@SYSCONFDIR.*@SYSCONFDIR "/etc"@'; \
		sed -i config.h -e 's@LOCALEDIR.*@LOCALEDIR "/share"@'; \
		ln -sf ../config.h src/; \
		$(MAKE); \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
	install -D -m 0644 $(IMAGEFILES)/scripts/ushare.conf $(TARGET_DIR)/etc/ushare.conf
	sed -i 's|%(BOXTYPE)|$(BOXTYPE)|; s|%(BOXMODEL)|$(BOXMODEL)|' $(TARGET_DIR)/etc/ushare.conf
	install -D -m 0755 $(IMAGEFILES)/scripts/ushare.init $(TARGET_DIR)/etc/init.d/ushare
	ln -sf ushare $(TARGET_DIR)/etc/init.d/S99ushare
	ln -sf ushare $(TARGET_DIR)/etc/init.d/K01ushare
	$(REMOVE)/$(USHARE_TMP)
	$(TOUCH)

# -----------------------------------------------------------------------------

SMARTMONTOOLS_VER    = 6.6
SMARTMONTOOLS_TMP    = smartmontools-$(SMARTMONTOOLS_VER)
SMARTMONTOOLS_SOURCE = smartmontools-$(SMARTMONTOOLS_VER).tar.gz
SMARTMONTOOLS_URL    = https://sourceforge.net/projects/smartmontools/files/smartmontools/$(SMARTMONTOOLS_VER)

$(ARCHIVE)/$(SMARTMONTOOLS_SOURCE):
	$(DOWNLOAD) $(SMARTMONTOOLS_URL)/$(SMARTMONTOOLS_SOURCE)

$(D)/smartmontools: $(ARCHIVE)/$(SMARTMONTOOLS_SOURCE) | $(TARGET_DIR)
	$(REMOVE)/$(SMARTMONTOOLS_TMP)
	$(UNTAR)/$(SMARTMONTOOLS_SOURCE)
	$(CHDIR)/$(SMARTMONTOOLS_TMP); \
		$(CONFIGURE) \
			--target=$(TARGET) \
			--prefix= \
			; \
		$(MAKE); \
		install -D -m 0755 smartctl $(TARGET_DIR)/sbin/smartctl
	$(REMOVE)/$(SMARTMONTOOLS_TMP)
	$(TOUCH)

# -----------------------------------------------------------------------------

INADYN_VER    = 2.4
INADYN_TMP    = inadyn-$(INADYN_VER)
INADYN_SOURCE = inadyn-$(INADYN_VER).tar.xz
INADYN_URL    = https://github.com/troglobit/inadyn/releases/download/v$(INADYN_VER)

$(ARCHIVE)/$(INADYN_SOURCE):
	$(DOWNLOAD) $(INADYN_URL)/$(INADYN_SOURCE)

$(D)/inadyn: $(D)/openssl $(D)/confuse $(D)/libite $(ARCHIVE)/$(INADYN_SOURCE) | $(TARGET_DIR)
	$(REMOVE)/$(INADYN_TMP)
	$(UNTAR)/$(INADYN_SOURCE)
	$(CHDIR)/$(INADYN_TMP); \
		autoreconf -fi; \
		$(CONFIGURE) \
			--prefix= \
			--libdir=$(TARGET_LIB_DIR) \
			--includedir=$(TARGET_INCLUDE_DIR) \
			--mandir=$(remove-mandir) \
			--docdir=$(remove-docdir) \
			--enable-openssl \
			; \
		$(MAKE); \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
	install -D -m 0644 $(IMAGEFILES)/scripts/inadyn.conf $(TARGET_DIR)/var/etc/inadyn.conf
	ln -sf /var/etc/inadyn.conf $(TARGET_DIR)/etc/inadyn.conf
	install -D -m 0755 $(IMAGEFILES)/scripts/inadyn.init $(TARGET_DIR)/etc/init.d/inadyn
	ln -sf inadyn $(TARGET_DIR)/etc/init.d/S80inadyn
	ln -sf inadyn $(TARGET_DIR)/etc/init.d/K60inadyn
	$(REMOVE)/$(INADYN_TMP)
	$(TOUCH)

# -----------------------------------------------------------------------------

VSFTPD_VER    = 3.0.3
VSFTPD_TMP    = vsftpd-$(VSFTPD_VER)
VSFTPD_SOURCE = vsftpd-$(VSFTPD_VER).tar.gz
VSFTPD_URL    = https://security.appspot.com/downloads

$(ARCHIVE)/$(VSFTPD_SOURCE):
	$(DOWNLOAD) $(VSFTPD_URL)/$(VSFTPD_SOURCE)

VSFTPD_PATCH  = vsftpd-fix-CVE-2015-1419.patch
VSFTPD_PATCH += vsftpd-disable-capabilities.patch
VSFTPD_PATCH += vsftpd-fixchroot.patch
VSFTPD_PATCH += vsftpd-login-blank-password.patch

$(D)/vsftpd: $(D)/openssl $(ARCHIVE)/$(VSFTPD_SOURCE) | $(TARGET_DIR)
	$(REMOVE)/$(VSFTPD_TMP)
	$(UNTAR)/$(VSFTPD_SOURCE)
	$(CHDIR)/$(VSFTPD_TMP); \
		$(call apply_patches, $(VSFTPD_PATCH)); \
		sed -i -e 's/.*VSF_BUILD_PAM/#undef VSF_BUILD_PAM/' builddefs.h; \
		sed -i -e 's/.*VSF_BUILD_SSL/#define VSF_BUILD_SSL/' builddefs.h; \
		$(MAKE) clean; \
		$(MAKE) $(BUILDENV) LIBS="-lcrypt -lcrypto -lssl"; \
		install -D -m 0755 vsftpd $(TARGET_DIR)/sbin/vsftpd
	install -d $(TARGET_SHARE_DIR)/empty
	install -D -m 0644 $(IMAGEFILES)/scripts/vsftpd.conf $(TARGET_DIR)/etc/vsftpd.conf
	install -D -m 0644 $(IMAGEFILES)/scripts/vsftpd.chroot_list $(TARGET_DIR)/etc/vsftpd.chroot_list
	install -D -m 0755 $(IMAGEFILES)/scripts/vsftpd.init $(TARGET_DIR)/etc/init.d/vsftpd
	ln -sf vsftpd $(TARGET_DIR)/etc/init.d/S53vsftpd
	ln -sf vsftpd $(TARGET_DIR)/etc/init.d/K80vsftpd
	$(REMOVE)/$(VSFTPD_TMP)
	$(TOUCH)

# -----------------------------------------------------------------------------

PROCPS-NG_VER    = 3.3.15
PROCPS-NG_TMP    = procps-ng-$(PROCPS-NG_VER)
PROCPS-NG_SOURCE = procps-ng-$(PROCPS-NG_VER).tar.xz
PROCPS-NG_URL    = http://sourceforge.net/projects/procps-ng/files/Production

$(ARCHIVE)/$(PROCPS-NG_SOURCE):
	$(DOWNLOAD) $(PROCPS-NG_URL)/$(PROCPS-NG_SOURCE)

PROCPS-NG_PATCH  = procps_0001-Fix-out-of-tree-builds.patch
PROCPS-NG_PATCH += procps-ng-no-tests-docs.patch

PROCPS-NG_BIN    = ps top

$(D)/procps-ng: $(D)/ncurses $(ARCHIVE)/$(PROCPS-NG_SOURCE) | $(TARGET_DIR)
	$(REMOVE)/$(PROCPS-NG_TMP)
	$(UNTAR)/$(PROCPS-NG_SOURCE)
	$(CHDIR)/$(PROCPS-NG_TMP); \
		$(call apply_patches, $(PROCPS-NG_PATCH)); \
		export ac_cv_func_malloc_0_nonnull=yes; \
		export ac_cv_func_realloc_0_nonnull=yes; \
		autoreconf -fi; \
		$(CONFIGURE) \
			--target=$(TARGET) \
			--prefix= \
			--bindir=/bin.procps \
			--sbindir=/sbin.procps \
			--datarootdir=$(remove-datarootdir) \
			; \
		$(MAKE); \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
	for bin in $(PROCPS-NG_BIN); do \
		rm -f $(TARGET_DIR)/bin/$$bin; \
		install -m 0755 $(TARGET_DIR)/bin.procps/$$bin $(TARGET_DIR)/bin/$$bin; \
	done
	$(REWRITE_PKGCONF)/libprocps.pc
	$(REWRITE_LIBTOOL)/libprocps.la
	$(REMOVE)/$(PROCPS-NG_TMP) \
		$(TARGET_DIR)/bin.procps \
		$(TARGET_DIR)/sbin.procps
	$(TOUCH)

# -----------------------------------------------------------------------------

NANO_VER    = 4.2
NANO_TMP    = nano-$(NANO_VER)
NANO_SOURCE = nano-$(NANO_VER).tar.gz
NANO_URL    = https://www.nano-editor.org/dist/v$(basename $(NANO_VER))

$(ARCHIVE)/$(NANO_SOURCE):
	$(DOWNLOAD) $(NANO_URL)/$(NANO_SOURCE)

$(D)/nano: $(D)/ncurses $(ARCHIVE)/$(NANO_SOURCE) | $(TARGET_DIR)
	$(REMOVE)/$(NANO_TMP)
	$(UNTAR)/$(NANO_SOURCE)
	$(CHDIR)/$(NANO_TMP); \
		export ac_cv_prog_NCURSESW_CONFIG=false; \
		$(CONFIGURE) \
			--target=$(TARGET) \
			--prefix= \
			--datarootdir=$(remove-datarootdir) \
			--disable-nls \
			--enable-tiny \
			; \
		$(MAKE) CURSES_LIB="-lncurses"; \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
	$(REMOVE)/$(NANO_TMP)
	$(TOUCH)

# -----------------------------------------------------------------------------

MINICOM_VER    = 2.7.1
MINICOM_TMP    = minicom-$(MINICOM_VER)
MINICOM_SOURCE = minicom-$(MINICOM_VER).tar.gz
MINICOM_URL    = http://fossies.org/linux/misc

$(ARCHIVE)/$(MINICOM_SOURCE):
	$(DOWNLOAD) $(MINICOM_URL)/$(MINICOM_SOURCE)

MINICOM_PATCH  = minicom-fix-h-v-return-value-is-not-0.patch

$(D)/minicom: $(D)/ncurses $(ARCHIVE)/$(MINICOM_SOURCE) | $(TARGET_DIR)
	$(REMOVE)/$(MINICOM_TMP)
	$(UNTAR)/$(MINICOM_SOURCE)
	$(CHDIR)/$(MINICOM_TMP); \
		$(call apply_patches, $(MINICOM_PATCH)); \
		$(CONFIGURE) \
			--prefix= \
			--target=$(TARGET) \
			--disable-nls \
			; \
		$(MAKE); \
		install -m 0755 src/minicom $(TARGET_DIR)/bin
	$(REMOVE)/$(MINICOM_TMP)
	$(TOUCH)

# -----------------------------------------------------------------------------

BASH_VER    = 5.0
BASH_TMP    = bash-$(BASH_VER)
BASH_SOURCE = bash-$(BASH_VER).tar.gz
BASH_URL    = http://ftp.gnu.org/gnu/bash

$(ARCHIVE)/$(BASH_SOURCE):
	$(DOWNLOAD) $(BASH_URL)/$(BASH_SOURCE)

BASH_PATCH  = $(PATCHES)/bash

$(D)/bash: $(ARCHIVE)/$(BASH_SOURCE) | $(TARGET_DIR)
	$(REMOVE)/$(BASH_TMP)
	$(UNTAR)/$(BASH_SOURCE)
	$(CHDIR)/$(BASH_TMP); \
		$(call apply_patches, $(BASH_PATCH), 0); \
		$(CONFIGURE) \
			--prefix= \
			--datarootdir=$(remove-datarootdir) \
			; \
		$(MAKE); \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
	$(REWRITE_PKGCONF)/bash.pc
	rm -f $(TARGET_LIB_DIR)/bash/loadables.h
	rm -f $(TARGET_LIB_DIR)/bash/Makefile.inc
	$(REMOVE)/$(BASH_TMP)
	$(TOUCH)


# -----------------------------------------------------------------------------

E2FSPROGS_VER    = 1.44.5
ifeq ($(BOXTYPE), coolstream)
  # formatting ext4 failes with newer versions
  E2FSPROGS_VER  = 1.43.8
endif
E2FSPROGS_TMP    = e2fsprogs-$(E2FSPROGS_VER)
E2FSPROGS_SOURCE = e2fsprogs-$(E2FSPROGS_VER).tar.gz
E2FSPROGS_URL    = https://sourceforge.net/projects/e2fsprogs/files/e2fsprogs/v$(E2FSPROGS_VER)

$(ARCHIVE)/$(E2FSPROGS_SOURCE):
	$(DOWNLOAD) $(E2FSPROGS_URL)/$(E2FSPROGS_SOURCE)

$(D)/e2fsprogs: $(ARCHIVE)/$(E2FSPROGS_SOURCE) | $(TARGET_DIR)
	$(REMOVE)/$(E2FSPROGS_TMP)
	$(UNTAR)/$(E2FSPROGS_SOURCE)
	$(CHDIR)/$(E2FSPROGS_TMP); \
		autoreconf -fi; \
		$(CONFIGURE) \
			--target=$(TARGET) \
			--prefix=/ \
			--datarootdir=$(remove-datarootdir) \
			--disable-nls \
			--disable-profile \
			--disable-e2initrd-helper \
			--disable-backtrace \
			--disable-bmap-stats \
			--disable-debugfs \
			--disable-fuse2fs \
			--disable-imager \
			--disable-mmp \
			--disable-rpath \
			--disable-tdb \
			--disable-uuidd \
			--disable-blkid-debug \
			--disable-jbd-debug \
			--disable-testio-debug \
			--disable-defrag \
			--enable-elf-shlibs \
			--enable-fsck \
			--enable-symlink-install \
			--enable-verbose-makecmds \
			--enable-symlink-build \
			--with-gnu-ld \
			; \
		$(MAKE); \
		$(MAKE) install DESTDIR=$(TARGET_DIR); \
		cd lib/uuid/; \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
	-rm $(addprefix $(TARGET_DIR)/bin/, chattr compile_et lsattr mk_cmds uuidgen)
	-rm $(addprefix $(TARGET_DIR)/sbin/, dumpe2fs e2freefrag e2mmpstatus e2undo e4crypt filefrag logsave)
	$(REWRITE_PKGCONF)/uuid.pc
	$(REMOVE)/$(E2FSPROGS_TMP)
	$(TOUCH)

# -----------------------------------------------------------------------------

NTFS-3G_VER    = 2017.3.23
NTFS-3G_TMP    = ntfs-3g_ntfsprogs-$(NTFS-3G_VER)
NTFS-3G_SOURCE = ntfs-3g_ntfsprogs-$(NTFS-3G_VER).tgz
NTFS-3G_URL    = https://tuxera.com/opensource

$(ARCHIVE)/$(NTFS-3G_SOURCE):
	$(DOWNLOAD) $(NTFS-3G_URL)/$(NTFS-3G_SOURCE)

$(D)/ntfs-3g: $(ARCHIVE)/$(NTFS-3G_SOURCE) | $(TARGET_DIR)
	$(REMOVE)/$(NTFS-3G_TMP)
	$(UNTAR)/$(NTFS-3G_SOURCE)
	$(CHDIR)/$(NTFS-3G_TMP); \
		$(CONFIGURE) \
			--prefix= \
			--mandir=$(remove-mandir) \
			--docdir=$(remove-docdir) \
			--disable-ntfsprogs \
			--disable-ldconfig \
			--disable-library \
			; \
		$(MAKE); \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
	-rm $(addprefix $(TARGET_DIR)/bin/,lowntfs-3g ntfs-3g.probe)
	-rm $(addprefix $(TARGET_DIR)/sbin/,mount.lowntfs-3g)
	$(REMOVE)/$(NTFS-3G_TMP)
	$(TOUCH)

# -----------------------------------------------------------------------------

AUTOFS_VER    = 5.1.5
AUTOFS_TMP    = autofs-$(AUTOFS_VER)
AUTOFS_SOURCE = autofs-$(AUTOFS_VER).tar.xz
AUTOFS_URL    = https://www.kernel.org/pub/linux/daemons/autofs/v5

$(ARCHIVE)/$(AUTOFS_SOURCE):
	$(DOWNLOAD) $(AUTOFS_URL)/$(AUTOFS_SOURCE)

# cd $(PATCHES)\autofs
# wget -N https://mirrors.edge.kernel.org/pub/linux/daemons/autofs/v5/patches-5.1.6/patch_order_5.1.5
# for p in $(cat patch_order_5.1.5); do test -f $p || wget https://mirrors.edge.kernel.org/pub/linux/daemons/autofs/v5/patches-5.1.6/$p; done

AUTOFS_PATCH  = $(addprefix autofs/, $(shell cat $(PATCHES)/autofs/patch_order_$(AUTOFS_VER)))

$(D)/autofs: $(D)/libtirpc $(ARCHIVE)/$(AUTOFS_SOURCE) | $(TARGET_DIR)
	$(REMOVE)/$(AUTOFS_TMP)
	$(UNTAR)/$(AUTOFS_SOURCE)
	$(CHDIR)/$(AUTOFS_TMP); \
		$(call apply_patches, $(AUTOFS_PATCH)); \
		sed -i "s|nfs/nfs.h|linux/nfs.h|" include/rpc_subs.h; \
		export ac_cv_linux_procfs=yes; \
		export ac_cv_path_KRB5_CONFIG=no; \
		export ac_cv_path_MODPROBE=/sbin/modprobe; \
		export ac_cv_path_RANLIB=$(TARGET)-ranlib; \
		autoreconf -fi; \
		$(CONFIGURE) \
			--prefix= \
			--datarootdir=$(remove-datarootdir) \
			--enable-ignore-busy \
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
			; \
		$(MAKE) SUBDIRS="lib daemon modules" DONTSTRIP=1; \
		$(MAKE) SUBDIRS="lib daemon modules" install DESTDIR=$(TARGET_DIR)
	cp -a $(IMAGEFILES)/autofs/* $(TARGET_DIR)/
	ln -sf autofs $(TARGET_DIR)/etc/init.d/S60autofs
	ln -sf autofs $(TARGET_DIR)/etc/init.d/K40autofs
	$(REMOVE)/$(AUTOFS_TMP)
	$(TOUCH)

# -----------------------------------------------------------------------------

samba: samba-$(BOXSERIES)

# -----------------------------------------------------------------------------

SAMBA33_VER    = 3.3.16
SAMBA33_TMP    = samba-$(SAMBA33_VER)
SAMBA33_SOURCE = samba-$(SAMBA33_VER).tar.gz
SAMBA33_URL    = https://download.samba.org/pub/samba

$(ARCHIVE)/$(SAMBA33_SOURCE):
	$(DOWNLOAD) $(SAMBA33_URL)/$(SAMBA33_SOURCE)

SAMBA33_PATCH  = samba33-build-only-what-we-need.patch
SAMBA33_PATCH += samba33-configure.in-make-getgrouplist_ok-test-cross-compile.patch

$(D)/samba-hd1: $(D)/zlib $(ARCHIVE)/$(SAMBA33_SOURCE) | $(TARGET_DIR)
	$(REMOVE)/$(SAMBA33_TMP)
	$(UNTAR)/$(SAMBA33_SOURCE)
	$(CHDIR)/$(SAMBA33_TMP); \
		$(call apply_patches, $(SAMBA33_PATCH)); \
	$(CHDIR)/$(SAMBA33_TMP)/source; \
		./autogen.sh; \
		export CONFIG_SITE=$(CONFIGS)/samba33-config.site; \
		$(CONFIGURE) \
			--prefix=/ \
			--datadir=/var/samba \
			--datarootdir=$(remove-datarootdir) \
			--localstatedir=/var/samba \
			--sysconfdir=/etc/samba \
			--with-configdir=/etc/samba \
			--with-privatedir=/etc/samba \
			--with-modulesdir=$(remove-libdir)/samba \
			--with-sys-quotas=no \
			--with-piddir=/var/run \
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
			--disable-swat \
			; \
		$(MAKE) all; \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
	mkdir -p $(TARGET_DIR)/var/samba/locks
	install -m 0644 $(IMAGEFILES)/scripts/smb3.conf $(TARGET_DIR)/etc/samba/smb.conf
	install -m 0755 $(IMAGEFILES)/scripts/samba3.init $(TARGET_DIR)/etc/init.d/samba
	ln -sf samba $(TARGET_DIR)/etc/init.d/S99samba
	ln -sf samba $(TARGET_DIR)/etc/init.d/K01samba
	rm -rf $(TARGET_DIR)/bin/testparm
	rm -rf $(TARGET_DIR)/bin/findsmb
	rm -rf $(TARGET_DIR)/bin/smbtar
	rm -rf $(TARGET_DIR)/bin/smbclient
	rm -rf $(TARGET_DIR)/bin/smbpasswd
	$(REMOVE)/$(SAMBA33_TMP)
	$(TOUCH)

# -----------------------------------------------------------------------------

SAMBA36_VER    = 3.6.25
SAMBA36_TMP    = samba-$(SAMBA36_VER)
SAMBA36_SOURCE = samba-$(SAMBA36_VER).tar.gz
SAMBA36_URL    = https://download.samba.org/pub/samba/stable

$(ARCHIVE)/$(SAMBA36_SOURCE):
	$(DOWNLOAD) $(SAMBA36_URL)/$(SAMBA36_SOURCE)

SAMBA36_PATCH1  = samba36-build-only-what-we-need.patch
SAMBA36_PATCH1 += samba36-remove_printer_support.patch
SAMBA36_PATCH1 += samba36-remove_ad_support.patch
SAMBA36_PATCH1 += samba36-remove_services.patch
SAMBA36_PATCH1 += samba36-remove_winreg_support.patch
SAMBA36_PATCH1 += samba36-remove_registry_backend.patch
SAMBA36_PATCH1 += samba36-strip_srvsvc.patch

SAMBA36_PATCH0  = samba36-CVE-2016-2112-v3-6.patch
SAMBA36_PATCH0 += samba36-CVE-2016-2115-v3-6.patch
SAMBA36_PATCH0 += samba36-CVE-2017-7494-v3-6.patch

$(D)/samba-bre2ze4k \
$(D)/samba-hd51 \
$(D)/samba-hd2: $(D)/zlib $(ARCHIVE)/$(SAMBA36_SOURCE) | $(TARGET_DIR)
	$(REMOVE)/$(SAMBA36_TMP)
	$(UNTAR)/$(SAMBA36_SOURCE)
	$(CHDIR)/$(SAMBA36_TMP); \
		$(call apply_patches, $(SAMBA36_PATCH1), 1); \
		$(call apply_patches, $(SAMBA36_PATCH0), 0); \
	$(CHDIR)/$(SAMBA36_TMP)/source3; \
		./autogen.sh; \
		export CONFIG_SITE=$(CONFIGS)/samba36-config.site; \
		$(CONFIGURE) \
			--prefix=/ \
			--datadir=/var/samba \
			--datarootdir=$(remove-datarootdir) \
			--localstatedir=/var/samba \
			--sysconfdir=/etc/samba \
			--with-configdir=/etc/samba \
			--with-privatedir=/etc/samba \
			--with-modulesdir=$(remove-libdir)/samba \
			--with-piddir=/var/run \
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
			--disable-swat \
			; \
		$(MAKE) all; \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
	mkdir -p $(TARGET_DIR)/var/samba/locks
	install $(IMAGEFILES)/scripts/smb3.conf $(TARGET_DIR)/etc/samba/smb.conf
	install -m 0755 $(IMAGEFILES)/scripts/samba3.init $(TARGET_DIR)/etc/init.d/samba
	ln -sf samba $(TARGET_DIR)/etc/init.d/S99samba
	ln -sf samba $(TARGET_DIR)/etc/init.d/K01samba
	rm -rf $(TARGET_DIR)/bin/testparm
	rm -rf $(TARGET_DIR)/bin/findsmb
	rm -rf $(TARGET_DIR)/bin/smbtar
	rm -rf $(TARGET_DIR)/bin/smbclient
	rm -rf $(TARGET_DIR)/bin/smbpasswd
	$(REMOVE)/$(SAMBA36_TMP)
	$(TOUCH)

# -----------------------------------------------------------------------------

DROPBEAR_VER    = 2018.76
DROPBEAR_TMP    = dropbear-$(DROPBEAR_VER)
DROPBEAR_SOURCE = dropbear-$(DROPBEAR_VER).tar.bz2
DROPBEAR_URL    = http://matt.ucc.asn.au/dropbear/releases

$(ARCHIVE)/$(DROPBEAR_SOURCE):
	$(DOWNLOAD) $(DROPBEAR_URL)/$(DROPBEAR_SOURCE)

$(D)/dropbear: $(D)/zlib $(ARCHIVE)/$(DROPBEAR_SOURCE) | $(TARGET_DIR)
	$(REMOVE)/$(DROPBEAR_TMP)
	$(UNTAR)/$(DROPBEAR_SOURCE)
	$(CHDIR)/$(DROPBEAR_TMP); \
		$(CONFIGURE) \
			--prefix= \
			--mandir=$(remove-mandir) \
			--disable-pututxline \
			--disable-wtmp \
			--disable-wtmpx \
			--disable-loginfunc \
			--disable-pam \
			--disable-zlib \
			--disable-harden \
			--enable-bundled-libtom \
			; \
		# Ensure that dropbear doesn't use crypt() when it's not available; \
		echo '#if !HAVE_CRYPT'                          >> localoptions.h; \
		echo '#define DROPBEAR_SVR_PASSWORD_AUTH 0'     >> localoptions.h; \
		echo '#endif'                                   >> localoptions.h; \
		# disable SMALL_CODE define; \
		sed -i 's|^\(#define DROPBEAR_SMALL_CODE\).*|\1 0|' default_options.h; \
		# fix PATH define; \
		sed -i 's|^\(#define DEFAULT_PATH\).*|\1 "/sbin:/bin:/var/bin"|' default_options.h; \
		# remove /usr prefix; \
		sed -i 's|/usr/|/|g' default_options.h; \
		$(MAKE) PROGRAMS="dropbear dbclient dropbearkey scp" SCPPROGRESS=1; \
		$(MAKE) PROGRAMS="dropbear dbclient dropbearkey scp" install DESTDIR=$(TARGET_DIR)
	install -d -m 0755 $(TARGET_DIR)/etc/dropbear
	install -D -m 0755 $(IMAGEFILES)/scripts/dropbear.init $(TARGET_DIR)/etc/init.d/dropbear
	ln -sf dropbear $(TARGET_DIR)/etc/init.d/S60dropbear
	ln -sf dropbear $(TARGET_DIR)/etc/init.d/K60dropbear
	$(REMOVE)/$(DROPBEAR_TMP)
	$(TOUCH)

# -----------------------------------------------------------------------------

SG3_UTILS_VER    = 1.42
SG3_UTILS_TMP    = sg3_utils-$(SG3_UTILS_VER)
SG3_UTILS_SOURCE = sg3_utils-$(SG3_UTILS_VER).tar.xz
SG3_UTILS_URL    = http://sg.danny.cz/sg/p

$(ARCHIVE)/$(SG3_UTILS_SOURCE):
	$(DOWNLOAD) $(SG3_UTILS_URL)/$(SG3_UTILS_SOURCE)

SG3_UTILS_BIN    = sg_start

$(D)/sg3_utils: $(ARCHIVE)/$(SG3_UTILS_SOURCE) | $(TARGET_DIR)
	$(REMOVE)/$(SG3_UTILS_TMP)
	$(UNTAR)/$(SG3_UTILS_SOURCE)
	$(CHDIR)/$(SG3_UTILS_TMP); \
		$(CONFIGURE) \
			--prefix= \
			--bindir=/bin.sg3_utils \
			--mandir=$(remove-mandir) \
			; \
		$(MAKE); \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
	for bin in $(SG3_UTILS_BIN); do \
		rm -f $(TARGET_DIR)/bin/$$bin; \
		install -m 0755 $(TARGET_DIR)/bin.sg3_utils/$$bin $(TARGET_DIR)/bin/$$bin; \
	done
	$(REWRITE_LIBTOOL)/libsgutils2.la
	install -D -m 0755 $(IMAGEFILES)/scripts/sdX.init $(TARGET_DIR)/etc/init.d/sdX
	ln -sf sdX $(TARGET_DIR)/etc/init.d/K97sdX
	$(REMOVE)/$(SG3_UTILS_TMP) \
		$(TARGET_DIR)/bin.sg3_utils
	$(TOUCH)

# -----------------------------------------------------------------------------

FBSHOT_VER    = 0.3
FBSHOT_TMP    = fbshot-$(FBSHOT_VER)
FBSHOT_SOURCE = fbshot-$(FBSHOT_VER).tar.gz
FBSHOT_URL    = http://distro.ibiblio.org/amigolinux/download/Utils/fbshot

$(ARCHIVE)/$(FBSHOT_SOURCE):
	$(DOWNLOAD) $(FBSHOT_URL)/$(FBSHOT_SOURCE)

FBSHOT_PATCH  = fbshot-32bit_cs_fb.diff
FBSHOT_PATCH += fbshot_cs_hd2.diff

$(D)/fbshot: $(D)/libpng $(ARCHIVE)/$(FBSHOT_SOURCE) | $(TARGET_DIR)
	$(REMOVE)/$(FBSHOT_TMP)
	$(UNTAR)/$(FBSHOT_SOURCE)
	$(CHDIR)/$(FBSHOT_TMP); \
		$(call apply_patches, $(FBSHOT_PATCH)); \
		sed -i 's|	gcc |	$(TARGET)-gcc $(TARGET_CFLAGS) $(TARGET_LDFLAGS) |' Makefile; \
		sed -i '/strip fbshot/d' Makefile; \
		$(MAKE) all; \
		install -D -m 0755 fbshot $(TARGET_DIR)/bin/fbshot
	$(REMOVE)/$(FBSHOT_TMP)
	$(TOUCH)

# -----------------------------------------------------------------------------

LCD4LINUX_VER    = git
LCD4LINUX_TMP    = lcd4linux.$(LCD4LINUX_VER)
LCD4LINUX_SOURCE = lcd4linux.$(LCD4LINUX_VER)
LCD4LINUX_URL    = https://github.com/TangoCash

$(D)/lcd4linux: $(D)/ncurses $(D)/libgd2 $(D)/libdpf | $(TARGET_DIR)
	$(REMOVE)/$(LCD4LINUX_TMP)
	get-git-source.sh $(LCD4LINUX_URL)/$(LCD4LINUX_SOURCE) $(ARCHIVE)/$(LCD4LINUX_SOURCE)
	$(CPDIR)/$(LCD4LINUX_SOURCE)
	$(CHDIR)/$(LCD4LINUX_TMP); \
		./bootstrap; \
		$(CONFIGURE) \
			--libdir=$(TARGET_LIB_DIR) \
			--includedir=$(TARGET_INCLUDE_DIR) \
			--bindir=$(TARGET_DIR)/bin \
			--prefix= \
			--mandir=$(remove-mandir) \
			--docdir=$(remove-docdir) \
			--infodir=$(remove-infodir) \
			--with-ncurses=$(TARGET_LIB_DIR) \
			--with-drivers='DPF, SamsungSPF, PNG' \
			--with-plugins='all,!dbus,!mpris_dbus,!asterisk,!isdn,!pop3,!ppp,!seti,!huawei,!imon,!kvv,!sample,!w1retap,!wireless,!xmms,!gps,!mpd,!mysql,!qnaplog,!iconv' \
			; \
		$(MAKE) vcs_version; \
		$(MAKE) all; \
		$(MAKE) install
	cp -a $(IMAGEFILES)/lcd4linux/* $(TARGET_DIR)/
	#make samsunglcd4linux
	$(REMOVE)/$(LCD4LINUX_TMP)
	$(TOUCH)

# -----------------------------------------------------------------------------

SAMSUNGLCD4LINUX_VER    = git
SAMSUNGLCD4LINUX_TMP    = samsunglcd4linux.$(LCD4LINUX_VER)
SAMSUNGLCD4LINUX_SOURCE = samsunglcd4linux.$(LCD4LINUX_VER)
SAMSUNGLCD4LINUX_URL    = https://github.com/horsti58

$(D)/samsunglcd4linux: | $(TARGET_DIR)
	$(REMOVE)/$(SAMSUNGLCD4LINUX_TMP)
	get-git-source.sh $(SAMSUNGLCD4LINUX_URL)/$(SAMSUNGLCD4LINUX_SOURCE) $(ARCHIVE)/$(SAMSUNGLCD4LINUX_SOURCE)
	$(CPDIR)/$(SAMSUNGLCD4LINUX_SOURCE)
	$(CHDIR)/$(SAMSUNGLCD4LINUX_TMP)/ni; \
		install -m 0600 etc/lcd4linux.conf $(TARGET_DIR)/etc; \
		cp -a share/* $(TARGET_SHARE_DIR)
	$(REMOVE)/$(SAMSUNGLCD4LINUX_TMP)
	$(TOUCH)

# -----------------------------------------------------------------------------

WPA_SUPPLICANT_VER    = 0.7.3
WPA_SUPPLICANT_TMP    = wpa_supplicant-$(WPA_SUPPLICANT_VER)
WPA_SUPPLICANT_SOURCE = wpa_supplicant-$(WPA_SUPPLICANT_VER).tar.gz
WPA_SUPPLICANT_URL    = https://w1.fi/releases

$(ARCHIVE)/$(WPA_SUPPLICANT_SOURCE):
	$(DOWNLOAD) $(WPA_SUPPLICANT_URL)/$(WPA_SUPPLICANT_SOURCE)

$(D)/wpa_supplicant: $(D)/openssl $(ARCHIVE)/$(WPA_SUPPLICANT_SOURCE) | $(TARGET_DIR)
	$(REMOVE)/$(WPA_SUPPLICANT_TMP)
	$(UNTAR)/$(WPA_SUPPLICANT_SOURCE)
	$(CHDIR)/$(WPA_SUPPLICANT_TMP)/wpa_supplicant; \
		cp $(CONFIGS)/wpa_supplicant.config .config; \
		$(BUILDENV) \
		$(MAKE); \
		$(MAKE) install DESTDIR=$(TARGET_DIR) BINDIR=/sbin
	install -D -m 0755 $(IMAGEFILES)/scripts/pre-wlan0.sh $(TARGET_DIR)/etc/network/pre-wlan0.sh
	install -D -m 0755 $(IMAGEFILES)/scripts/post-wlan0.sh $(TARGET_DIR)/etc/network/post-wlan0.sh
	$(REMOVE)/$(WPA_SUPPLICANT_TMP)
	$(TOUCH)

# -----------------------------------------------------------------------------

XUPNPD_VER    = git
XUPNPD_TMP    = xupnpd.$(XUPNPD_VER)
XUPNPD_SOURCE = xupnpd.$(XUPNPD_VER)
XUPNPD_URL    = https://github.com/clark15b

XUPNPD_PATCH  = xupnpd-dynamic-lua.patch
XUPNPD_PATCH += xupnpd-fix-memleak.patch
XUPNPD_PATCH += xupnpd-fix-webif-backlinks.diff
XUPNPD_PATCH += xupnpd-change-XUPNPDROOTDIR.diff
XUPNPD_PATCH += xupnpd-add-configuration-files.diff

$(D)/xupnpd: $(D)/lua $(D)/openssl | $(TARGET_DIR)
	$(REMOVE)/$(XUPNPD_TMP)
	get-git-source.sh $(XUPNPD_URL)/$(XUPNPD_SOURCE) $(ARCHIVE)/$(XUPNPD_SOURCE)
	$(CPDIR)/$(XUPNPD_SOURCE)
	$(CHDIR)/$(XUPNPD_TMP); \
		$(call apply_patches, $(XUPNPD_PATCH))
	$(CHDIR)/$(XUPNPD_TMP)/src; \
		$(BUILDENV) \
		$(MAKE) embedded TARGET=$(TARGET) CC=$(TARGET)-gcc STRIP=$(TARGET)-strip LUAFLAGS="$(TARGET_LDFLAGS) -I$(TARGET_INCLUDE_DIR)"; \
		install -D -m 0755 xupnpd $(TARGET_BIN_DIR)/; \
		install -d $(TARGET_SHARE_DIR)/xupnpd/config; \
		cp -a plugins profiles ui www *.lua $(TARGET_SHARE_DIR)/xupnpd/
	rm $(TARGET_SHARE_DIR)/xupnpd/plugins/staff/xupnpd_18plus.lua
	install -D -m 0644 $(SOURCE_DIR)/$(NI-NEUTRINO-PLUGINS)/scripts-lua/xupnpd/xupnpd_18plus.lua $(TARGET_SHARE_DIR)/xupnpd/plugins/
	install -D -m 0644 $(SOURCE_DIR)/$(NI-NEUTRINO-PLUGINS)/scripts-lua/xupnpd/xupnpd_youtube.lua $(TARGET_SHARE_DIR)/xupnpd/plugins/
	install -D -m 0644 $(SOURCE_DIR)/$(NI-NEUTRINO-PLUGINS)/scripts-lua/xupnpd/xupnpd_coolstream.lua $(TARGET_SHARE_DIR)/xupnpd/plugins/
	install -D -m 0644 $(SOURCE_DIR)/$(NI-NEUTRINO-PLUGINS)/scripts-lua/xupnpd/xupnpd_cczwei.lua $(TARGET_SHARE_DIR)/xupnpd/plugins/
	install -D -m 0755 $(IMAGEFILES)/scripts/xupnpd.init $(TARGET_DIR)/etc/init.d/xupnpd
	ln -sf xupnpd $(TARGET_DIR)/etc/init.d/S99xupnpd
	ln -sf xupnpd $(TARGET_DIR)/etc/init.d/K01xupnpd
	cp -a $(IMAGEFILES)/xupnpd/* $(TARGET_DIR)/
	$(REMOVE)/$(XUPNPD_TMP)
	$(TOUCH)

# -----------------------------------------------------------------------------

DOSFSTOOLS_VER    = 4.1
DOSFSTOOLS_TMP    = dosfstools-$(DOSFSTOOLS_VER)
DOSFSTOOLS_SOURCE = dosfstools-$(DOSFSTOOLS_VER).tar.xz
DOSFSTOOLS_URL    = https://github.com/dosfstools/dosfstools/releases/download/v$(DOSFSTOOLS_VER)

$(ARCHIVE)/$(DOSFSTOOLS_SOURCE):
	$(DOWNLOAD) $(DOSFSTOOLS_URL)/$(DOSFSTOOLS_SOURCE)

DOSFSTOOLS_CFLAGS = $(TARGET_CFLAGS) -D_GNU_SOURCE -fomit-frame-pointer -D_FILE_OFFSET_BITS=64

$(D)/dosfstools: $(ARCHIVE)/$(DOSFSTOOLS_SOURCE) | $(TARGET_DIR)
	$(REMOVE)/$(DOSFSTOOLS_TMP)
	$(UNTAR)/$(DOSFSTOOLS_SOURCE)
	$(CHDIR)/$(DOSFSTOOLS_TMP); \
		autoreconf -fi; \
		$(CONFIGURE) \
			--prefix= \
			--mandir=$(remove-mandir) \
			--docdir=$(remove-docdir) \
			--without-udev \
			--enable-compat-symlinks \
			CFLAGS="$(DOSFSTOOLS_CFLAGS)" \
			; \
		$(MAKE); \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
	$(REMOVE)/$(DOSFSTOOLS_TMP)
	$(TOUCH)

# -----------------------------------------------------------------------------

NFS-UTILS_VER    = 2.2.1
NFS-UTILS_TMP    = nfs-utils-$(NFS-UTILS_VER)
NFS-UTILS_SOURCE = nfs-utils-$(NFS-UTILS_VER).tar.bz2
NFS-UTILS_URL    = https://sourceforge.net/projects/nfs/files/nfs-utils/$(NFS-UTILS_VER)

$(ARCHIVE)/$(NFS-UTILS_SOURCE):
	$(DOWNLOAD) $(NFS-UTILS_URL)/$(NFS-UTILS_SOURCE)

NFS-UTILS_PATCH  = nfs-utils_01-Patch-taken-from-Gentoo.patch
NFS-UTILS_PATCH += nfs-utils_02-Switch-legacy-index-in-favour-of-strchr.patch
NFS-UTILS_PATCH += nfs-utils_03-Let-the-configure-script-find-getrpcbynumber-in-libt.patch
NFS-UTILS_PATCH += nfs-utils_04-mountd-Add-check-for-struct-file_handle.patch
NFS-UTILS_PATCH += nfs-utils_05-sm-notify-use-sbin-instead-of-usr-sbin.patch

NFS-UTILS_IPV6   = --enable-ipv6
ifeq ($(BOXSERIES), hd1)
  NFS-UTILS_IPV6 = --disable-ipv6
endif

$(D)/nfs-utils: $(D)/rpcbind $(ARCHIVE)/$(NFS-UTILS_SOURCE) | $(TARGET_DIR)
	$(REMOVE)/$(NFS-UTILS_TMP)
	$(UNTAR)/$(NFS-UTILS_SOURCE)
	$(CHDIR)/$(NFS-UTILS_TMP); \
		$(call apply_patches, $(NFS-UTILS_PATCH)); \
		export knfsd_cv_bsd_signals=no; \
		autoreconf -fi; \
		$(CONFIGURE) \
			--prefix= \
			--target=$(TARGET) \
			--enable-maintainer-mode \
			--docdir=$(remove-docdir) \
			--mandir=$(remove-mandir) \
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
		$(MAKE); \
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
	install -D -m 0755 $(IMAGEFILES)/scripts/nfsd.init $(TARGET_DIR)/etc/init.d/nfsd
	ln -s nfsd $(TARGET_DIR)/etc/init.d/S60nfsd
	ln -s nfsd $(TARGET_DIR)/etc/init.d/K01nfsd
	$(REMOVE)/$(NFS-UTILS_TMP)
	$(TOUCH)

# -----------------------------------------------------------------------------

RPCBIND_VER    = 1.2.5
RPCBIND_TMP    = rpcbind-$(RPCBIND_VER)
RPCBIND_SOURCE = rpcbind-$(RPCBIND_VER).tar.bz2
RPCBIND_URL    = https://sourceforge.net/projects/rpcbind/files/rpcbind/$(RPCBIND_VER)

$(ARCHIVE)/$(RPCBIND_SOURCE):
	$(DOWNLOAD) $(RPCBIND_URL)/$(RPCBIND_SOURCE)

RPCBIND_PATCH  = rpcbind-0001-Remove-yellow-pages-support.patch
RPCBIND_PATCH += rpcbind-0002-add_option_to_fix_port_number.patch

$(D)/rpcbind: $(D)/libtirpc $(ARCHIVE)/$(RPCBIND_SOURCE) | $(TARGET_DIR)
	$(REMOVE)/$(RPCBIND_TMP)
	$(UNTAR)/$(RPCBIND_SOURCE)
	$(CHDIR)/$(RPCBIND_TMP); \
		$(call apply_patches, $(RPCBIND_PATCH)); \
		autoreconf -fi; \
		$(CONFIGURE) \
			--target=$(TARGET) \
			--prefix= \
			--enable-silent-rules \
			--with-rpcuser=root \
			--with-systemdsystemunitdir=no \
			--mandir=$(remove-mandir) \
			; \
		$(MAKE); \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
ifeq ($(BOXSERIES), hd1)
	sed -i -e '/^\(udp\|tcp\)6/ d' $(TARGET_DIR)/etc/netconfig
endif
	rm -rf $(TARGET_DIR)/bin/rpcgen
	$(REMOVE)/$(RPCBIND_TMP)
	$(TOUCH)

# -----------------------------------------------------------------------------

FUSE-EXFAT_VER    = 1.2.8
FUSE-EXFAT_TMP    = fuse-exfat-$(FUSE-EXFAT_VER)
FUSE-EXFAT_SOURCE = fuse-exfat-$(FUSE-EXFAT_VER).tar.gz
FUSE-EXFAT_URL    = https://github.com/relan/exfat/releases/download/v$(FUSE-EXFAT_VER)

$(ARCHIVE)/$(FUSE-EXFAT_SOURCE):
	$(DOWNLOAD) $(FUSE-EXFAT_URL)/$(FUSE-EXFAT_SOURCE)

$(D)/fuse-exfat: $(D)/libfuse $(ARCHIVE)/$(FUSE-EXFAT_SOURCE) | $(TARGET_DIR)
	$(REMOVE)/$(FUSE-EXFAT_TMP)
	$(UNTAR)/$(FUSE-EXFAT_SOURCE)
	$(CHDIR)/$(FUSE-EXFAT_TMP); \
		autoreconf -fi; \
		$(CONFIGURE) \
			--prefix= \
			--docdir=$(remove-docdir) \
			--mandir=$(remove-mandir) \
			; \
		$(MAKE); \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
	$(REMOVE)/$(FUSE-EXFAT_TMP)
	$(TOUCH)

# -----------------------------------------------------------------------------

EXFAT-UTILS_VER    = 1.2.8
EXFAT-UTILS_TMP    = exfat-utils-$(EXFAT-UTILS_VER)
EXFAT-UTILS_SOURCE = exfat-utils-$(EXFAT-UTILS_VER).tar.gz
EXFAT-UTILS_URL    = https://github.com/relan/exfat/releases/download/v$(EXFAT-UTILS_VER)

$(ARCHIVE)/$(EXFAT-UTILS_SOURCE):
	$(DOWNLOAD) $(EXFAT-UTILS_URL)/$(EXFAT-UTILS_SOURCE)

$(D)/exfat-utils: $(D)/fuse-exfat $(ARCHIVE)/$(EXFAT-UTILS_SOURCE) | $(TARGET_DIR)
	$(REMOVE)/$(EXFAT-UTILS_TMP)
	$(UNTAR)/$(EXFAT-UTILS_SOURCE)
	$(CHDIR)/$(EXFAT-UTILS_TMP); \
		autoreconf -fi; \
		$(CONFIGURE) \
			--prefix= \
			--docdir=$(remove-docdir) \
			--mandir=$(remove-mandir) \
			; \
		$(MAKE); \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
	$(REMOVE)/$(EXFAT-UTILS_TMP)
	$(TOUCH)

# -----------------------------------------------------------------------------

$(D)/streamripper: $(D)/libvorbisidec $(D)/libmad $(D)/glib2 | $(TARGET_DIR)
	$(REMOVE)/$(NI-STREAMRIPPER)
	tar -C $(SOURCE_DIR) -cp $(NI-STREAMRIPPER) --exclude-vcs | tar -C $(BUILD_TMP) -x
	$(CHDIR)/$(NI-STREAMRIPPER); \
		autoreconf -fi; \
		$(CONFIGURE) \
			--prefix= \
			--includedir=$(TARGET_INCLUDE_DIR) \
			--datarootdir=$(remove-datarootdir) \
			--with-included-argv=yes \
			--with-included-libmad=no \
			; \
		$(MAKE); \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
	install -m 0755 $(IMAGEFILES)/scripts/streamripper.sh $(TARGET_DIR)/bin/
	$(REMOVE)/$(NI-STREAMRIPPER)
	$(TOUCH)

# -----------------------------------------------------------------------------

GETTEXT_VER    = 0.19.8.1
GETTEXT_TMP    = gettext-$(GETTEXT_VER)
GETTEXT_SOURCE = gettext-$(GETTEXT_VER).tar.xz
GETTEXT_URL    = ftp://ftp.gnu.org/gnu/gettext

$(ARCHIVE)/$(GETTEXT_SOURCE):
	$(DOWNLOAD) $(GETTEXT_URL)/$(GETTEXT_SOURCE)

$(D)/gettext: $(ARCHIVE)/$(GETTEXT_SOURCE) | $(TARGET_DIR)
	$(REMOVE)/$(GETTEXT_TMP)
	$(UNTAR)/$(GETTEXT_SOURCE)
	$(CHDIR)/$(GETTEXT_TMP)/gettext-runtime; \
		autoreconf -fi; \
		$(CONFIGURE) \
			--prefix= \
			--bindir=$(remove-bindir) \
			--datarootdir=$(remove-datarootdir) \
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
	$(REWRITE_LIBTOOL)/libintl.la
	$(REMOVE)/$(GETTEXT_TMP)
	$(TOUCH)

# -----------------------------------------------------------------------------

MC_VER    = 4.8.23
MC_TMP    = mc-$(MC_VER)
MC_SOURCE = mc-$(MC_VER).tar.xz
MC_URL    = ftp.midnight-commander.org

$(ARCHIVE)/$(MC_SOURCE):
	$(DOWNLOAD) $(MC_URL)/$(MC_SOURCE)

$(D)/mc: $(D)/glib2 $(D)/ncurses $(ARCHIVE)/$(MC_SOURCE) | $(TARGET_DIR)
	$(REMOVE)/$(MC_TMP)
	$(UNTAR)/$(MC_SOURCE)
	$(CHDIR)/$(MC_TMP); \
		autoreconf -fi; \
		$(CONFIGURE) \
			--prefix= \
			--mandir=$(remove-mandir) \
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
			--without-gpm-mouse \
			--without-x \
			; \
		$(MAKE) all; \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
	rm -rf $(TARGET_SHARE_DIR)/mc/examples
	find $(TARGET_SHARE_DIR)/mc/skins -type f ! -name default.ini | xargs --no-run-if-empty rm
	$(REMOVE)/$(MC_TMP)
	$(TOUCH)

# -----------------------------------------------------------------------------

WGET_VER    = 1.19.2
WGET_TMP    = wget-$(WGET_VER)
WGET_SOURCE = wget-$(WGET_VER).tar.gz
WGET_URL    = https://ftp.gnu.org/gnu/wget

$(ARCHIVE)/$(WGET_SOURCE):
	$(DOWNLOAD) $(WGET_URL)/$(WGET_SOURCE)

WGET_PATCH  = wget-remove-hardcoded-engine-support-for-openssl.patch
WGET_PATCH += wget-set-check_cert-false-by-default.patch
WGET_PATCH += wget-change_DEFAULT_LOGFILE.patch

$(D)/wget: $(D)/openssl $(ARCHIVE)/$(WGET_SOURCE) | $(TARGET_DIR)
	$(REMOVE)/$(WGET_TMP)
	$(UNTAR)/$(WGET_SOURCE)
	$(CHDIR)/$(WGET_TMP); \
		$(call apply_patches, $(WGET_PATCH)); \
		$(CONFIGURE) \
			--target=$(TARGET) \
			--prefix= \
			--datarootdir=$(remove-datarootdir) \
			--sysconfdir=$(remove-sysconfdir) \
			--with-gnu-ld \
			--with-ssl=openssl \
			--disable-debug \
			; \
		$(MAKE); \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
	$(REMOVE)/$(WGET_TMP)
	$(TOUCH)

# -----------------------------------------------------------------------------

LIBICONV_VER    = 1.13.1
LIBICONV_TMP    = libiconv-$(LIBICONV_VER)
LIBICONV_SOURCE = libiconv-$(LIBICONV_VER).tar.gz
LIBICONV_URL    = https://ftp.gnu.org/gnu/libiconv

$(ARCHIVE)/$(LIBICONV_SOURCE):
	$(DOWNLOAD) $(LIBICONV_URL)/$(LIBICONV_SOURCE)

LIBICONV_PATCH  = iconv-disable_transliterations.patch
LIBICONV_PATCH += iconv-strip_charsets.patch

# builds only stripped down iconv binary used for smarthomeinfo plugin
$(D)/iconv: $(ARCHIVE)/$(LIBICONV_SOURCE) | $(TARGET_DIR)
	$(REMOVE)/$(LIBICONV_TMP)
	$(UNTAR)/$(LIBICONV_SOURCE)
	$(CHDIR)/$(LIBICONV_TMP); \
		$(call apply_patches, $(LIBICONV_PATCH)); \
		$(CONFIGURE) \
			--target=$(TARGET) \
			--prefix= \
			--datarootdir=$(remove-datarootdir) \
			--includedir=$(remove-includedir) \
			--libdir=$(remove-libdir) \
			--enable-static \
			--disable-shared \
			--enable-relocatable \
			; \
		$(MAKE); \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
	$(REMOVE)/$(LIBICONV_TMP)
	$(TOUCH)

# -----------------------------------------------------------------------------

$(D)/ofgwrite: $(SOURCE_DIR)/$(NI-OFGWRITE) | $(TARGET_DIR)
	$(REMOVE)/$(NI-OFGWRITE)
	tar -C $(SOURCE_DIR) -cp $(NI-OFGWRITE) --exclude-vcs | tar -C $(BUILD_TMP) -x
	$(CHDIR)/$(NI-OFGWRITE); \
		$(BUILDENV) \
		$(MAKE)
	install -m 0755 $(BUILD_TMP)/$(NI-OFGWRITE)/ofgwrite_bin $(TARGET_DIR)/bin
	install -m 0755 $(BUILD_TMP)/$(NI-OFGWRITE)/ofgwrite_caller $(TARGET_DIR)/bin
	install -m 0755 $(BUILD_TMP)/$(NI-OFGWRITE)/ofgwrite $(TARGET_DIR)/bin
	$(REMOVE)/$(NI-OFGWRITE)
	$(TOUCH)

# -----------------------------------------------------------------------------

AIO-GRAB_VER    = git
AIO-GRAB_TMP    = aio-grab.$(AIO-GRAB_VER)
AIO-GRAB_SOURCE = aio-grab.$(AIO-GRAB_VER)
AIO-GRAB_URL    = https://github.com/oe-alliance

$(D)/aio-grab: $(D)/zlib $(D)/libpng $(D)/libjpeg | $(TARGET_DIR)
	$(REMOVE)/$(AIO-GRAB_TMP)
	get-git-source.sh $(AIO-GRAB_URL)/$(AIO-GRAB_SOURCE) $(ARCHIVE)/$(AIO-GRAB_SOURCE)
	$(CPDIR)/$(AIO-GRAB_SOURCE)
	$(CHDIR)/$(AIO-GRAB_TMP); \
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
	$(REMOVE)/$(AIO-GRAB_TMP)
	$(TOUCH)

# -----------------------------------------------------------------------------

DVBSNOOP_VER    = git
DVBSNOOP_TMP    = dvbsnoop.$(DVBSNOOP_VER)
DVBSNOOP_SOURCE = dvbsnoop.$(DVBSNOOP_VER)
DVBSNOOP_URL    = https://github.com/Duckbox-Developers

$(D)/dvbsnoop: | $(TARGET_DIR)
	$(REMOVE)/$(DVBSNOOP_TMP)
	get-git-source.sh $(DVBSNOOP_URL)/$(DVBSNOOP_SOURCE) $(ARCHIVE)/$(DVBSNOOP_SOURCE)
	$(CPDIR)/$(DVBSNOOP_SOURCE)
	$(CHDIR)/$(DVBSNOOP_TMP); \
		$(CONFIGURE) \
			--enable-silent-rules \
			--prefix= \
			--mandir=$(remove-mandir) \
			; \
		$(MAKE); \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
	$(REMOVE)/$(DVBSNOOP_TMP)
	$(TOUCH)

# -----------------------------------------------------------------------------

ETHTOOL_VER    = 4.19
ETHTOOL_TMP    = ethtool-$(ETHTOOL_VER)
ETHTOOL_SOURCE = ethtool-$(ETHTOOL_VER).tar.xz
ETHTOOL_URL    = https://www.kernel.org/pub/software/network/ethtool

$(ARCHIVE)/$(ETHTOOL_SOURCE):
	$(DOWNLOAD) $(ETHTOOL_URL)/$(ETHTOOL_SOURCE)

$(D)/ethtool: $(ARCHIVE)/$(ETHTOOL_SOURCE) | $(TARGET_DIR)
	$(REMOVE)/$(ETHTOOL_TMP)
	$(UNTAR)/$(ETHTOOL_SOURCE)
	$(CHDIR)/$(ETHTOOL_TMP); \
		$(CONFIGURE) \
			--prefix= \
			--mandir=$(remove-mandir) \
			--libdir=$(TARGET_LIB_DIR) \
			--disable-pretty-dump \
			; \
		$(MAKE); \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
	$(REMOVE)/$(ETHTOOL_TMP)
	$(TOUCH)

# -----------------------------------------------------------------------------

GPTFDISK_VER    = 1.0.4
GPTFDISK_TMP    = gptfdisk-$(GPTFDISK_VER)
GPTFDISK_SOURCE = gptfdisk-$(GPTFDISK_VER).tar.gz
GPTFDISK_URL    = https://sourceforge.net/projects/gptfdisk/files/gptfdisk/$(GPTFDISK_VER)

$(ARCHIVE)/$(GPTFDISK_SOURCE):
	$(DOWNLOAD) $(GPTFDISK_URL)/$(GPTFDISK_SOURCE)

GPTFDISK_PATCH  = gptfdisk-ldlibs.patch

$(D)/gptfdisk: $(D)/popt $(D)/e2fsprogs $(ARCHIVE)/$(GPTFDISK_SOURCE) | $(TARGET_DIR)
	$(REMOVE)/$(GPTFDISK_TMP)
	$(UNTAR)/$(GPTFDISK_SOURCE)
	$(CHDIR)/$(GPTFDISK_TMP); \
		$(call apply_patches, $(GPTFDISK_PATCH)); \
		sed -i 's|^CC=.*|CC=$(TARGET)-gcc|' Makefile; \
		sed -i 's|^CXX=.*|CXX=$(TARGET)-g++|' Makefile; \
		$(BUILDENV) \
		$(MAKE) sgdisk; \
		install -D -m 0755 sgdisk $(TARGET_DIR)/sbin/sgdisk
	$(REMOVE)/$(GPTFDISK_TMP)
	$(TOUCH)

# -----------------------------------------------------------------------------

CA-BUNDLE_SOURCE = cacert.pem
CA-BUNDLE_URL    = https://curl.haxx.se/ca

$(ARCHIVE)/$(CA-BUNDLE_SOURCE):
	$(DOWNLOAD) $(CA-BUNDLE_URL)/$(CA-BUNDLE_SOURCE)

$(D)/ca-bundle: $(ARCHIVE)/$(CA-BUNDLE_SOURCE) | $(TARGET_DIR)
	$(CD) $(ARCHIVE); \
		curl --remote-name --time-cond $(CA-BUNDLE_SOURCE) $(CA-BUNDLE_URL)/$(CA-BUNDLE_SOURCE) || true
	install -D -m 0644 $(ARCHIVE)/$(CA-BUNDLE_SOURCE) $(TARGET_DIR)/$(CA-BUNDLE_DIR)/$(CA-BUNDLE)
	$(TOUCH)
