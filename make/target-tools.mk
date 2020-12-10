#
# makefile to build system tools
#
# -----------------------------------------------------------------------------

BUSYBOX_VER    = 1.31.1
BUSYBOX_DIR    = busybox-$(BUSYBOX_VER)
BUSYBOX_SOURCE = busybox-$(BUSYBOX_VER).tar.bz2
BUSYBOX_SITE   = https://busybox.net/downloads

$(DL_DIR)/$(BUSYBOX_SOURCE):
	$(DOWNLOAD) $(BUSYBOX_SITE)/$(BUSYBOX_SOURCE)

BUSYBOX_PATCH  = busybox-fix-config-header.diff
BUSYBOX_PATCH += busybox-insmod-hack.patch
BUSYBOX_PATCH += busybox-fix-partition-size.patch
BUSYBOX_PATCH += busybox-mount_single_uuid.patch

BUSYBOX_DEPS   = libtirpc

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
	$(MAKE_OPTS) \
	CFLAGS_EXTRA="$(TARGET_CFLAGS)" \
	EXTRA_LDFLAGS="$(TARGET_LDFLAGS)" \
	CONFIG_PREFIX="$(TARGET_DIR)"

BUSYBOX_BUILD_CONFIG = $(BUILD_DIR)/$(BUSYBOX_DIR)/.config

define BUSYBOX_INSTALL_CONFIG
	$(INSTALL_DATA) $(CONFIGS)/busybox-minimal.config $(BUSYBOX_BUILD_CONFIG)
	$(call KCONFIG_SET_OPT,CONFIG_PREFIX,"$(TARGET_DIR)",$(BUSYBOX_BUILD_CONFIG))
endef

ifeq ($(BOXSERIES), $(filter $(BOXSERIES), hd2 hd5x hd6x vusolo4k vuduo4k vuduo4kse vuultimo4k vuzero4k vuuno4k vuuno4kse vuduo))

  define BUSYBOX_SET_BLKDISCARD
	$(call KCONFIG_ENABLE_OPT,CONFIG_BLKDISCARD,$(BUSYBOX_BUILD_CONFIG))
  endef

  define BUSYBOX_SET_IPV6
	$(call KCONFIG_ENABLE_OPT,CONFIG_FEATURE_IPV6,$(BUSYBOX_BUILD_CONFIG))
	$(call KCONFIG_ENABLE_OPT,CONFIG_FEATURE_IFUPDOWN_IPV6,$(BUSYBOX_BUILD_CONFIG))
  endef

  ifeq ($(BOXSERIES), $(filter $(BOXSERIES), hd5x hd6x vusolo4k vuduo4k vuduo4kse vuultimo4k vuzero4k vuuno4k vuuno4kse vuduo))

    define BUSYBOX_SET_SWAP
	$(call KCONFIG_ENABLE_OPT,CONFIG_SWAPON,$(BUSYBOX_BUILD_CONFIG))
	$(call KCONFIG_ENABLE_OPT,CONFIG_SWAPOFF,$(BUSYBOX_BUILD_CONFIG))
    endef

    define BUSYBOX_SET_HEXDUMP
	$(call KCONFIG_ENABLE_OPT,CONFIG_HEXDUMP,$(BUSYBOX_BUILD_CONFIG))
    endef

    define BUSYBOX_SET_PKILL
	$(call KCONFIG_ENABLE_OPT,CONFIG_PKILL,$(BUSYBOX_BUILD_CONFIG))
    endef

    ifeq ($(BOXSERIES), $(filter $(BOXSERIES), vusolo4k vuduo4k vuduo4kse vuultimo4k vuzero4k vuuno4k vuuno4kse vuduo))

      define BUSYBOX_SET_START_STOP_DAEMON
	$(call KCONFIG_ENABLE_OPT,CONFIG_START_STOP_DAEMON,$(BUSYBOX_BUILD_CONFIG))
	$(call KCONFIG_ENABLE_OPT,CONFIG_FEATURE_START_STOP_DAEMON_LONG_OPTIONS,$(BUSYBOX_BUILD_CONFIG))
	$(call KCONFIG_ENABLE_OPT,CONFIG_FEATURE_START_STOP_DAEMON_FANCY,$(BUSYBOX_BUILD_CONFIG))
      endef

    endif

  endif

endif

define BUSYBOX_MODIFY_CONFIG
	$(BUSYBOX_SET_BLKDISCARD)
	$(BUSYBOX_SET_IPV6)
	$(BUSYBOX_SET_SWAP)
	$(BUSYBOX_SET_HEXDUMP)
	$(BUSYBOX_SET_PKILL)
	$(BUSYBOX_SET_START_STOP_DAEMON)
endef

define BUSYBOX_ADD_TO_SHELLS
	if grep -q 'CONFIG_ASH=y' $(BUSYBOX_BUILD_CONFIG); then \
		grep -qsE '^/bin/ash$$' $(TARGET_sysconfdir)/shells \
			|| echo "/bin/ash" >> $(TARGET_sysconfdir)/shells; \
	fi
	if grep -q 'CONFIG_HUSH=y' $(BUSYBOX_BUILD_CONFIG); then \
		grep -qsE '^/bin/hush$$' $(TARGET_sysconfdir)/shells \
			|| echo "/bin/hush" >> $(TARGET_sysconfdir)/shells; \
	fi
	if grep -q 'CONFIG_SH_IS_ASH=y\|CONFIG_SH_IS_HUSH=y' $(BUSYBOX_BUILD_CONFIG); then \
		grep -qsE '^/bin/sh$$' $(TARGET_sysconfdir)/shells \
			|| echo "/bin/sh" >> $(TARGET_sysconfdir)/shells; \
	fi
endef

busybox: $(BUSYBOX_DEPS) $(DL_DIR)/$(BUSYBOX_SOURCE) | $(TARGET_DIR)
	$(REMOVE)/$(BUSYBOX_DIR)
	$(UNTAR)/$(BUSYBOX_SOURCE)
	$(CHDIR)/$(BUSYBOX_DIR); \
		$(call apply_patches, $(BUSYBOX_PATCH))
	$(BUSYBOX_INSTALL_CONFIG)
	$(BUSYBOX_MODIFY_CONFIG)
	$(CHDIR)/$(BUSYBOX_DIR); \
		$(BUSYBOX_MAKE_ENV) $(MAKE) $(BUSYBOX_MAKE_OPTS) busybox; \
		$(BUSYBOX_MAKE_ENV) $(MAKE) $(BUSYBOX_MAKE_OPTS) install-noclobber
	$(BUSYBOX_ADD_TO_SHELLS)
	$(REMOVE)/$(BUSYBOX_DIR)
	$(TOUCH)

# -----------------------------------------------------------------------------

OPENVPN_VER    = 2.5.0
OPENVPN_DIR    = openvpn-$(OPENVPN_VER)
OPENVPN_SOURCE = openvpn-$(OPENVPN_VER).tar.xz
OPENVPN_SITE   = http://build.openvpn.net/downloads/releases

$(DL_DIR)/$(OPENVPN_SOURCE):
	$(DOWNLOAD) $(OPENVPN_SITE)/$(OPENVPN_SOURCE)

OPENVPN_DEPS   = lzo openssl

openvpn: $(OPENVPN_DEPS) $(DL_DIR)/$(OPENVPN_SOURCE) | $(TARGET_DIR)
	$(REMOVE)/$(OPENVPN_DIR)
	$(UNTAR)/$(OPENVPN_SOURCE)
	$(CHDIR)/$(OPENVPN_DIR); \
		$(CONFIGURE) \
			IFCONFIG="/sbin/ifconfig" \
			NETSTAT="/bin/netstat" \
			ROUTE="/sbin/route" \
			IPROUTE="/sbin/ip" \
			--prefix=$(prefix) \
			--mandir=$(REMOVE_mandir) \
			--docdir=$(REMOVE_docdir) \
			--infodir=$(REMOVE_infodir) \
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
	$(REMOVE)/$(OPENVPN_DIR)
	$(TOUCH)

# -----------------------------------------------------------------------------

OPENSSH_VER    = 8.4p1
OPENSSH_DIR    = openssh-$(OPENSSH_VER)
OPENSSH_SOURCE = openssh-$(OPENSSH_VER).tar.gz
OPENSSH_SITE   = https://artfiles.org/openbsd/OpenSSH/portable

$(DL_DIR)/$(OPENSSH_SOURCE):
	$(DOWNLOAD) $(OPENSSH_SITE)/$(OPENSSH_SOURCE)

OPENSSH_DEPS   = openssl zlib

openssh: $(OPENSSH_DEPS) $(DL_DIR)/$(OPENSSH_SOURCE) | $(TARGET_DIR)
	$(REMOVE)/$(OPENSSH_DIR)
	$(UNTAR)/$(OPENSSH_SOURCE)
	$(CHDIR)/$(OPENSSH_DIR); \
		export ac_cv_search_dlopen=no; \
		./configure \
			$(CONFIGURE_OPTS) \
			--prefix=$(prefix) \
			--mandir=$(REMOVE_mandir) \
			--docdir=$(REMOVE_docdir) \
			--infodir=$(REMOVE_infodir) \
			--sysconfdir=$(sysconfdir)/ssh \
			--libexecdir=$(sbindir) \
			--with-pid-dir=/tmp \
			--with-privsep-path=/var/empty \
			--with-cppflags="-pipe $(TARGET_OPTIMIZATION) $(TARGET_DEBUGGING) $(TARGET_ABI) -I$(TARGET_includedir)" \
			--with-ldflags="-L$(TARGET_libdir)" \
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
	$(REMOVE)/$(OPENSSH_DIR)
	$(TOUCH)

# -----------------------------------------------------------------------------

TZDATA_VER    = 2020d
TZDATA_DIR    = tzdata$(TZDATA_VER)
TZDATA_SOURCE = tzdata$(TZDATA_VER).tar.gz
TZDATA_SITE   = ftp://ftp.iana.org/tz/releases

$(DL_DIR)/$(TZDATA_SOURCE):
	$(DOWNLOAD) $(TZDATA_SITE)/$(TZDATA_SOURCE)

TZDATA_DEPS   = host-zic

TZDATA_ZONELIST = \
	africa antarctica asia australasia europe northamerica \
	southamerica etcetera backward

ETC_LOCALTIME = $(if $(filter $(PERSISTENT_VAR_PARTITION), yes),/var/etc/localtime,/etc/localtime)

tzdata: $(TZDATA_DEPS) $(DL_DIR)/$(TZDATA_SOURCE) | $(TARGET_DIR)
	$(REMOVE)/$(TZDATA_DIR)
	$(MKDIR)/$(TZDATA_DIR)
	$(CHDIR)/$(TZDATA_DIR); \
		tar -xf $(DL_DIR)/$(TZDATA_SOURCE); \
		unset ${!LC_*}; LANG=POSIX; LC_ALL=POSIX; export LANG LC_ALL; \
		$(HOST_ZIC) -d zoneinfo.tmp $(TZDATA_ZONELIST); \
		mkdir zoneinfo; \
		sed -n '/zone=/{s/.*zone="\(.*\)".*$$/\1/; p}' $(TARGET_FILES)/tzdata/timezone.xml | sort -u | \
		while read x; do \
			find zoneinfo.tmp -type f -name $$x | sort | \
			while read y; do \
				$(INSTALL_DATA) $$y zoneinfo/$$x; \
			done; \
			test -e zoneinfo/$$x || echo "WARNING: timezone $$x not found."; \
		done; \
		mkdir -p $(TARGET_datadir); \
		rm -rf $(TARGET_datadir)/zoneinfo; \
		mv zoneinfo/ $(TARGET_datadir)/
	$(INSTALL_DATA) -D $(TARGET_FILES)/tzdata/timezone.xml $(TARGET_sysconfdir)/timezone.xml
	$(INSTALL_DATA) $(TARGET_datadir)/zoneinfo/CET $(TARGET_DIR)$(ETC_LOCALTIME)
	$(REMOVE)/$(TZDATA_DIR)
	$(TOUCH)

# -----------------------------------------------------------------------------

MTD-UTILS_VER    = 2.0.2
MTD-UTILS_DIR    = mtd-utils-$(MTD-UTILS_VER)
MTD-UTILS_SOURCE = mtd-utils-$(MTD-UTILS_VER).tar.bz2
MTD-UTILS_SITE   = ftp://ftp.infradead.org/pub/mtd-utils

$(DL_DIR)/$(MTD-UTILS_SOURCE):
	$(DOWNLOAD) $(MTD-UTILS_SITE)/$(MTD-UTILS_SOURCE)

MTD-UTILS_DEPS   = zlib lzo e2fsprogs

mtd-utils: $(MTD-UTILS_DEPS) $(DL_DIR)/$(MTD-UTILS_SOURCE) | $(TARGET_DIR)
	$(REMOVE)/$(MTD-UTILS_DIR)
	$(UNTAR)/$(MTD-UTILS_SOURCE)
	$(CHDIR)/$(MTD-UTILS_DIR); \
		$(CONFIGURE) \
			--target=$(TARGET) \
			--prefix=$(prefix) \
			--mandir=$(REMOVE_mandir) \
			--enable-silent-rules \
			--disable-tests \
			--without-xattr \
			; \
		$(MAKE)
ifeq ($(BOXSERIES), hd2)
	$(INSTALL_EXEC) -D $(BUILD_DIR)/$(MTD-UTILS_DIR)/nanddump $(TARGET_sbindir)
	$(INSTALL_EXEC) -D $(BUILD_DIR)/$(MTD-UTILS_DIR)/nandtest $(TARGET_sbindir)
	$(INSTALL_EXEC) -D $(BUILD_DIR)/$(MTD-UTILS_DIR)/nandwrite $(TARGET_sbindir)
	$(INSTALL_EXEC) -D $(BUILD_DIR)/$(MTD-UTILS_DIR)/mtd_debug $(TARGET_sbindir)
	$(INSTALL_EXEC) -D $(BUILD_DIR)/$(MTD-UTILS_DIR)/mkfs.jffs2 $(TARGET_sbindir)
endif
	$(INSTALL_EXEC) -D $(BUILD_DIR)/$(MTD-UTILS_DIR)/flash_erase $(TARGET_sbindir)
	$(REMOVE)/$(MTD-UTILS_DIR)
	$(TOUCH)

# -----------------------------------------------------------------------------

IPERF_VER    = 3.1.3
IPERF_DIR    = iperf-$(IPERF_VER)
IPERF_SOURCE = iperf-$(IPERF_VER)-source.tar.gz
IPERF_SITE   = https://iperf.fr/download/source

$(DL_DIR)/$(IPERF_SOURCE):
	$(DOWNLOAD) $(IPERF_SITE)/$(IPERF_SOURCE)

IPERF_PATCH  = iperf-disable-profiling.patch

iperf: $(DL_DIR)/$(IPERF_SOURCE) | $(TARGET_DIR)
	$(REMOVE)/$(IPERF_DIR)
	$(UNTAR)/$(IPERF_SOURCE)
	$(CHDIR)/$(IPERF_DIR); \
		$(call apply_patches, $(IPERF_PATCH)); \
		$(CONFIGURE) \
			--target=$(TARGET) \
			--prefix=$(prefix) \
			--mandir=$(REMOVE_mandir) \
			; \
		$(MAKE); \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
	$(REMOVE)/$(IPERF_DIR)
	$(TOUCH)

# -----------------------------------------------------------------------------

PARTED_VER    = 3.2
PARTED_DIR    = parted-$(PARTED_VER)
PARTED_SOURCE = parted-$(PARTED_VER).tar.xz
PARTED_SITE   = $(GNU_MIRROR)/parted

$(DL_DIR)/$(PARTED_SOURCE):
	$(DOWNLOAD) $(PARTED_SITE)/$(PARTED_SOURCE)

PARTED_PATCH  = parted-device-mapper.patch
PARTED_PATCH += parted-sysmacros.patch
PARTED_PATCH += parted-iconv.patch

PARTED_DEPS   = e2fsprogs

parted: $(PARTED_DEPS) $(DL_DIR)/$(PARTED_SOURCE) | $(TARGET_DIR)
	$(REMOVE)/$(PARTED_DIR)
	$(UNTAR)/$(PARTED_SOURCE)
	$(CHDIR)/$(PARTED_DIR); \
		$(call apply_patches, $(PARTED_PATCH)); \
		autoreconf -fi; \
		$(CONFIGURE) \
			--target=$(TARGET) \
			--prefix=$(prefix) \
			--mandir=$(REMOVE_mandir) \
			--infodir=$(REMOVE_infodir) \
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
	$(REWRITE_LIBTOOL_LA)
	$(REWRITE_PKGCONF_PC)
	$(REMOVE)/$(PARTED_DIR)
	$(TOUCH)

# -----------------------------------------------------------------------------

HDPARM_VER    = 9.58
HDPARM_DIR    = hdparm-$(HDPARM_VER)
HDPARM_SOURCE = hdparm-$(HDPARM_VER).tar.gz
HDPARM_SITE   = https://sourceforge.net/projects/hdparm/files/hdparm

$(DL_DIR)/$(HDPARM_SOURCE):
	$(DOWNLOAD) $(HDPARM_SITE)/$(HDPARM_SOURCE)

hdparm: $(DL_DIR)/$(HDPARM_SOURCE) | $(TARGET_DIR)
	$(REMOVE)/$(HDPARM_DIR)
	$(UNTAR)/$(HDPARM_SOURCE)
	$(CHDIR)/$(HDPARM_DIR); \
		$(MAKE_ENV) \
		$(MAKE); \
		$(INSTALL_EXEC) -D hdparm $(TARGET_sbindir)/hdparm
	$(REMOVE)/$(HDPARM_DIR)
	$(TOUCH)

# -----------------------------------------------------------------------------

HD-IDLE_VER    = 1.05
HD-IDLE_DIR    = hd-idle
HD-IDLE_SOURCE = hd-idle-$(HD-IDLE_VER).tgz
HD-IDLE_SITE   = https://sourceforge.net/projects/hd-idle/files

$(DL_DIR)/$(HD-IDLE_SOURCE):
	$(DOWNLOAD) $(HD-IDLE_SITE)/$(HD-IDLE_SOURCE)

hd-idle: $(DL_DIR)/$(HD-IDLE_SOURCE) | $(TARGET_DIR)
	$(REMOVE)/$(HD-IDLE_DIR)
	$(UNTAR)/$(HD-IDLE_SOURCE)
	$(CHDIR)/$(HD-IDLE_DIR); \
		$(MAKE_ENV) \
		$(MAKE); \
		$(INSTALL_EXEC) -D hd-idle $(TARGET_sbindir)/hd-idle
	$(REMOVE)/$(HD-IDLE_DIR)
	$(TOUCH)

# -----------------------------------------------------------------------------

COREUTILS_VER    = 8.30
COREUTILS_DIR    = coreutils-$(COREUTILS_VER)
COREUTILS_SOURCE = coreutils-$(COREUTILS_VER).tar.xz
COREUTILS_SITE   = $(GNU_MIRROR)/coreutils

$(DL_DIR)/$(COREUTILS_SOURCE):
	$(DOWNLOAD) $(COREUTILS_SITE)/$(COREUTILS_SOURCE)

COREUTILS_PATCH  = coreutils-fix-build.patch

COREUTILS_BIN    = touch

coreutils: $(DL_DIR)/$(COREUTILS_SOURCE) | $(TARGET_DIR)
	$(REMOVE)/$(COREUTILS_DIR)
	$(UNTAR)/$(COREUTILS_SOURCE)
	$(CHDIR)/$(COREUTILS_DIR); \
		$(call apply_patches, $(COREUTILS_PATCH)); \
		autoreconf -fi; \
		$(CONFIGURE) \
			--target=$(TARGET) \
			--prefix=$(base_prefix) \
			--bindir=/bin.$(@F) \
			--libexecdir=$(REMOVE_libexecdir) \
			--datarootdir=$(REMOVE_datarootdir) \
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
		rm -f $(TARGET_bindir)/$$bin; \
		$(INSTALL_EXEC) -D $(TARGET_DIR)/bin.$(@F)/$$bin $(TARGET_bindir)/$$bin; \
	done
	$(REMOVE)/$(COREUTILS_DIR) \
		$(TARGET_DIR)/bin.$(@F)
	$(TOUCH)

# -----------------------------------------------------------------------------

LESS_VER    = 563
LESS_DIR    = less-$(LESS_VER)
LESS_SOURCE = less-$(LESS_VER).tar.gz
LESS_SITE   = $(GNU_MIRROR)/less

$(DL_DIR)/$(LESS_SOURCE):
	$(DOWNLOAD) $(LESS_SITE)/$(LESS_SOURCE)

LESS_DEPS   = ncurses

less: $(LESS_DEPS) $(DL_DIR)/$(LESS_SOURCE) | $(TARGET_DIR)
	$(REMOVE)/$(LESS_DIR)
	$(UNTAR)/$(LESS_SOURCE)
	$(CHDIR)/$(LESS_DIR); \
		$(CONFIGURE) \
			--target=$(TARGET) \
			--prefix=$(prefix) \
			--mandir=$(REMOVE_mandir) \
			; \
		$(MAKE); \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
	$(REMOVE)/$(LESS_DIR)
	$(TOUCH)

# -----------------------------------------------------------------------------

NTP_VER    = 4.2.8p15
NTP_DIR    = ntp-$(NTP_VER)
NTP_SOURCE = ntp-$(NTP_VER).tar.gz
NTP_SITE   = https://www.eecis.udel.edu/~ntp/ntp_spool/ntp4/ntp-$(basename $(NTP_VER))

$(DL_DIR)/$(NTP_SOURCE):
	$(DOWNLOAD) $(NTP_SITE)/$(NTP_SOURCE)

NTP_DEPS   = openssl

ntp: $(NTP_DEPS) $(DL_DIR)/$(NTP_SOURCE) | $(TARGET_DIR)
	$(REMOVE)/$(NTP_DIR)
	$(UNTAR)/$(NTP_SOURCE)
	$(CHDIR)/$(NTP_DIR); \
		$(APPLY_PATCHES); \
		$(CONFIGURE) \
			--target=$(TARGET) \
			--prefix=$(prefix) \
			--disable-debugging \
			--with-shared \
			--with-crypto \
			--with-yielding-select=yes \
			--without-ntpsnmpd \
			; \
		$(MAKE); \
		$(INSTALL_EXEC) -D ntpdate/ntpdate $(TARGET_sbindir)/ntpdate
	$(INSTALL_EXEC) -D $(TARGET_FILES)/scripts/ntpdate.init $(TARGET_sysconfdir)/init.d/ntpdate
	$(REMOVE)/$(NTP_DIR)
	$(TOUCH)

# -----------------------------------------------------------------------------

DJMOUNT_VER    = 0.71
DJMOUNT_DIR    = djmount-$(DJMOUNT_VER)
DJMOUNT_SOURCE = djmount-$(DJMOUNT_VER).tar.gz
DJMOUNT_SITE   = https://sourceforge.net/projects/djmount/files/djmount/$(DJMOUNT_VER)

$(DL_DIR)/$(DJMOUNT_SOURCE):
	$(DOWNLOAD) $(DJMOUNT_SITE)/$(DJMOUNT_SOURCE)

DJMOUNT_PATCH  = djmount-fix-hang-with-asset-upnp.patch
DJMOUNT_PATCH += djmount-fix-incorrect-range-when-retrieving-content-via-HTTP.patch
DJMOUNT_PATCH += djmount-fix-new-autotools.diff
DJMOUNT_PATCH += djmount-fix-newer-gcc.patch
DJMOUNT_PATCH += djmount-fixed-crash-when-using-UTF-8-charset.patch
DJMOUNT_PATCH += djmount-fixed-crash.patch
DJMOUNT_PATCH += djmount-support-fstab-mounting.diff
DJMOUNT_PATCH += djmount-support-seeking-in-large-2gb-files.patch

DJMOUNT_DEPS   = libfuse

djmount: $(DJMOUNT_DEPS) $(DL_DIR)/$(DJMOUNT_SOURCE) | $(TARGET_DIR)
	$(REMOVE)/$(DJMOUNT_DIR)
	$(UNTAR)/$(DJMOUNT_SOURCE)
	$(CHDIR)/$(DJMOUNT_DIR); \
		$(call apply_patches, $(DJMOUNT_PATCH)); \
		touch libupnp/config.aux/config.rpath; \
		autoreconf -fi; \
		$(CONFIGURE) -C \
			--prefix=$(prefix) \
			--disable-debug \
			; \
		make; \
		make install DESTDIR=$(TARGET_DIR)
	$(INSTALL_EXEC) -D $(TARGET_FILES)/scripts/djmount.init $(TARGET_sysconfdir)/init.d/djmount
	$(UPDATE-RC.D) djmount defaults 75 25
	$(REMOVE)/$(DJMOUNT_DIR)
	$(TOUCH)

# -----------------------------------------------------------------------------

USHARE_VER    = 1.1a
USHARE_DIR    = ushare-uShare_v$(USHARE_VER)
USHARE_SOURCE = uShare_v$(USHARE_VER).tar.gz
USHARE_SITE   = https://github.com/GeeXboX/ushare/archive

$(DL_DIR)/$(USHARE_SOURCE):
	$(DOWNLOAD) $(USHARE_SITE)/$(USHARE_SOURCE)

USHARE_PATCH  = ushare.diff
USHARE_PATCH += ushare-fix-building-with-gcc-5.x.patch
USHARE_PATCH += ushare-disable-iconv-check.patch

USHARE_DEPS   = libupnp

ushare: $(USHARE_DEPS) $(DL_DIR)/$(USHARE_SOURCE)| $(TARGET_DIR)
	$(REMOVE)/$(USHARE_DIR)
	$(UNTAR)/$(USHARE_SOURCE)
	$(CHDIR)/$(USHARE_DIR); \
		$(call apply_patches, $(USHARE_PATCH)); \
		$(MAKE_ENV) \
		./configure \
			--prefix=$(prefix) \
			--sysconfdir=$(sysconfdir) \
			--disable-dlna \
			--disable-nls \
			--cross-compile \
			--cross-prefix=$(TARGET_CROSS) \
			; \
		ln -sf ../config.h src/; \
		$(MAKE); \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
	$(INSTALL_DATA) -D $(TARGET_FILES)/configs/ushare.conf $(TARGET_sysconfdir)/ushare.conf
	$(SED) 's|%(BOXTYPE)|$(BOXTYPE)|; s|%(BOXMODEL)|$(BOXMODEL)|' $(TARGET_sysconfdir)/ushare.conf
	$(INSTALL_EXEC) -D $(TARGET_FILES)/scripts/ushare.init $(TARGET_sysconfdir)/init.d/ushare
	$(UPDATE-RC.D) ushare defaults 75 25
	$(REMOVE)/$(USHARE_DIR)
	$(TOUCH)

# -----------------------------------------------------------------------------

SMARTMONTOOLS_VER    = 7.1
SMARTMONTOOLS_DIR    = smartmontools-$(SMARTMONTOOLS_VER)
SMARTMONTOOLS_SOURCE = smartmontools-$(SMARTMONTOOLS_VER).tar.gz
SMARTMONTOOLS_SITE   = https://sourceforge.net/projects/smartmontools/files/smartmontools/$(SMARTMONTOOLS_VER)

$(DL_DIR)/$(SMARTMONTOOLS_SOURCE):
	$(DOWNLOAD) $(SMARTMONTOOLS_SITE)/$(SMARTMONTOOLS_SOURCE)

smartmontools: $(DL_DIR)/$(SMARTMONTOOLS_SOURCE) | $(TARGET_DIR)
	$(REMOVE)/$(SMARTMONTOOLS_DIR)
	$(UNTAR)/$(SMARTMONTOOLS_SOURCE)
	$(CHDIR)/$(SMARTMONTOOLS_DIR); \
		$(CONFIGURE) \
			--target=$(TARGET) \
			--prefix=$(prefix) \
			; \
		$(MAKE); \
		$(INSTALL_EXEC) -D smartctl $(TARGET_sbindir)/smartctl
	$(REMOVE)/$(SMARTMONTOOLS_DIR)
	$(TOUCH)

# -----------------------------------------------------------------------------

INADYN_VER    = 2.6
INADYN_DIR    = inadyn-$(INADYN_VER)
INADYN_SOURCE = inadyn-$(INADYN_VER).tar.xz
INADYN_SITE   = https://github.com/troglobit/inadyn/releases/download/v$(INADYN_VER)

$(DL_DIR)/$(INADYN_SOURCE):
	$(DOWNLOAD) $(INADYN_SITE)/$(INADYN_SOURCE)

INADYN_DEPS   = openssl confuse libite

inadyn: $(INADYN_DEPS) $(DL_DIR)/$(INADYN_SOURCE) | $(TARGET_DIR)
	$(REMOVE)/$(INADYN_DIR)
	$(UNTAR)/$(INADYN_SOURCE)
	$(CHDIR)/$(INADYN_DIR); \
		autoreconf -fi; \
		$(CONFIGURE) \
			--prefix=$(prefix) \
			--libdir=$(TARGET_libdir) \
			--includedir=$(TARGET_includedir) \
			--mandir=$(REMOVE_mandir) \
			--docdir=$(REMOVE_docdir) \
			--enable-openssl \
			; \
		$(MAKE); \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
	$(INSTALL_DATA) -D $(TARGET_FILES)/configs/inadyn.conf $(TARGET_localstatedir)/etc/inadyn.conf
	ln -sf /var/etc/inadyn.conf $(TARGET_sysconfdir)/inadyn.conf
	$(INSTALL_EXEC) -D $(TARGET_FILES)/scripts/inadyn.init $(TARGET_sysconfdir)/init.d/inadyn
	$(UPDATE-RC.D) inadyn defaults 75 25
	$(REMOVE)/$(INADYN_DIR)
	$(TOUCH)

# -----------------------------------------------------------------------------

VSFTPD_VER    = 3.0.3
VSFTPD_DIR    = vsftpd-$(VSFTPD_VER)
VSFTPD_SOURCE = vsftpd-$(VSFTPD_VER).tar.gz
VSFTPD_SITE   = https://security.appspot.com/downloads

$(DL_DIR)/$(VSFTPD_SOURCE):
	$(DOWNLOAD) $(VSFTPD_SITE)/$(VSFTPD_SOURCE)

VSFTPD_PATCH  = vsftpd-fix-CVE-2015-1419.patch
VSFTPD_PATCH += vsftpd-disable-capabilities.patch
VSFTPD_PATCH += vsftpd-fixchroot.patch
VSFTPD_PATCH += vsftpd-login-blank-password.patch

VSFTPD_DEPS   = openssl

vsftpd: $(VSFTPD_DEPS) $(DL_DIR)/$(VSFTPD_SOURCE) | $(TARGET_DIR)
	$(REMOVE)/$(VSFTPD_DIR)
	$(UNTAR)/$(VSFTPD_SOURCE)
	$(CHDIR)/$(VSFTPD_DIR); \
		$(call apply_patches, $(VSFTPD_PATCH)); \
		$(SED) 's/.*VSF_BUILD_PAM/#undef VSF_BUILD_PAM/' builddefs.h; \
		$(SED) 's/.*VSF_BUILD_SSL/#define VSF_BUILD_SSL/' builddefs.h; \
		$(MAKE) clean; \
		$(MAKE) $(MAKE_ENV) LIBS="-lcrypt -lcrypto -lssl"; \
		$(INSTALL_EXEC) -D vsftpd $(TARGET_sbindir)/vsftpd
	mkdir -p $(TARGET_datadir)/empty
	$(INSTALL_DATA) -D $(TARGET_FILES)/configs/vsftpd.conf $(TARGET_sysconfdir)/vsftpd.conf
	$(INSTALL_DATA) -D $(TARGET_FILES)/configs/vsftpd.chroot_list $(TARGET_sysconfdir)/vsftpd.chroot_list
	$(INSTALL_EXEC) -D $(TARGET_FILES)/scripts/vsftpd.init $(TARGET_sysconfdir)/init.d/vsftpd
	$(UPDATE-RC.D) vsftpd defaults 75 25
	$(REMOVE)/$(VSFTPD_DIR)
	$(TOUCH)

# -----------------------------------------------------------------------------

PROCPS-NG_VER    = 3.3.16
PROCPS-NG_DIR    = procps-ng-$(PROCPS-NG_VER)
PROCPS-NG_SOURCE = procps-ng-$(PROCPS-NG_VER).tar.xz
PROCPS-NG_SITE   = http://sourceforge.net/projects/procps-ng/files/Production

$(DL_DIR)/$(PROCPS-NG_SOURCE):
	$(DOWNLOAD) $(PROCPS-NG_SITE)/$(PROCPS-NG_SOURCE)

PROCPS-NG_PATCH  = procps-ng-no-tests-docs.patch

PROCPS-NG_DEPS   = ncurses

PROCPS-NG_BIN    = ps top

procps-ng: $(PROCPS-NG_DEPS) $(DL_DIR)/$(PROCPS-NG_SOURCE) | $(TARGET_DIR)
	$(REMOVE)/$(PROCPS-NG_DIR)
	$(UNTAR)/$(PROCPS-NG_SOURCE)
	$(CHDIR)/$(PROCPS-NG_DIR); \
		$(call apply_patches, $(PROCPS-NG_PATCH)); \
		export ac_cv_func_malloc_0_nonnull=yes; \
		export ac_cv_func_realloc_0_nonnull=yes; \
		autoreconf -fi; \
		$(CONFIGURE) \
			--target=$(TARGET) \
			--prefix=$(base_prefix) \
			--bindir=/bin.$(@F) \
			--sbindir=/sbin.$(@F) \
			--includedir=$(includedir) \
			--libdir=$(libdir) \
			--datarootdir=$(REMOVE_datarootdir) \
			--without-systemd \
			; \
		$(MAKE); \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
	for bin in $(PROCPS-NG_BIN); do \
		rm -f $(TARGET_bindir)/$$bin; \
		$(INSTALL_EXEC) -D $(TARGET_DIR)/bin.$(@F)/$$bin $(TARGET_bindir)/$$bin; \
	done
	$(REWRITE_LIBTOOL_LA)
	$(REWRITE_PKGCONF_PC)
	$(REMOVE)/$(PROCPS-NG_DIR) \
		$(TARGET_DIR)/bin.$(@F) \
		$(TARGET_DIR)/sbin.$(@F)
	$(TOUCH)

# -----------------------------------------------------------------------------

NANO_VER    = 5.4
NANO_DIR    = nano-$(NANO_VER)
NANO_SOURCE = nano-$(NANO_VER).tar.gz
NANO_SITE   = $(GNU_MIRROR)/nano

$(DL_DIR)/$(NANO_SOURCE):
	$(DOWNLOAD) $(NANO_SITE)/$(NANO_SOURCE)

NANO_DEPS   = ncurses

nano: $(NANO_DEPS) $(DL_DIR)/$(NANO_SOURCE) | $(TARGET_DIR)
	$(REMOVE)/$(NANO_DIR)
	$(UNTAR)/$(NANO_SOURCE)
	$(CHDIR)/$(NANO_DIR); \
		export ac_cv_prog_NCURSESW_CONFIG=false; \
		$(CONFIGURE) \
			--target=$(TARGET) \
			--prefix=$(prefix) \
			--datarootdir=$(REMOVE_datarootdir) \
			--disable-nls \
			--disable-libmagic \
			--enable-tiny \
			--without-slang \
			--with-wordbounds \
			; \
		$(MAKE) CURSES_LIB="-lncurses"; \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
	$(REMOVE)/$(NANO_DIR)
	$(TOUCH)

# -----------------------------------------------------------------------------

MINICOM_VER    = 2.7.1
MINICOM_DIR    = minicom-$(MINICOM_VER)
MINICOM_SOURCE = minicom-$(MINICOM_VER).tar.gz
MINICOM_SITE   = http://fossies.org/linux/misc

$(DL_DIR)/$(MINICOM_SOURCE):
	$(DOWNLOAD) $(MINICOM_SITE)/$(MINICOM_SOURCE)

MINICOM_PATCH  = minicom-fix-h-v-return-value-is-not-0.patch

MINICOM_DEPS   = ncurses

minicom: $(MINICOM_DEPS) $(DL_DIR)/$(MINICOM_SOURCE) | $(TARGET_DIR)
	$(REMOVE)/$(MINICOM_DIR)
	$(UNTAR)/$(MINICOM_SOURCE)
	$(CHDIR)/$(MINICOM_DIR); \
		$(call apply_patches, $(MINICOM_PATCH)); \
		$(CONFIGURE) \
			--target=$(TARGET) \
			--prefix=$(prefix) \
			--disable-nls \
			; \
		$(MAKE); \
		$(INSTALL_EXEC) src/minicom $(TARGET_bindir)
	$(REMOVE)/$(MINICOM_DIR)
	$(TOUCH)

# -----------------------------------------------------------------------------

BASH_VER    = 5.0
BASH_DIR    = bash-$(BASH_VER)
BASH_SOURCE = bash-$(BASH_VER).tar.gz
BASH_SITE   = $(GNU_MIRROR)/bash

$(DL_DIR)/$(BASH_SOURCE):
	$(DOWNLOAD) $(BASH_SITE)/$(BASH_SOURCE)

BASH_PATCH  = $(PATCHES)/bash

define BASH_ADD_TO_SHELLS
	grep -qsE '^/bin/bash$$' $(TARGET_sysconfdir)/shells \
		|| echo "/bin/bash" >> $(TARGET_sysconfdir)/shells
endef

bash: $(DL_DIR)/$(BASH_SOURCE) | $(TARGET_DIR)
	$(REMOVE)/$(BASH_DIR)
	$(UNTAR)/$(BASH_SOURCE)
	$(CHDIR)/$(BASH_DIR); \
		$(call apply_patches, $(BASH_PATCH), 0); \
		$(CONFIGURE) \
			--prefix=$(prefix) \
			--datarootdir=$(REMOVE_datarootdir) \
			; \
		$(MAKE); \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
	$(REWRITE_PKGCONF_PC)
	-rm $(addprefix $(TARGET_libdir)/bash/, loadables.h Makefile.inc)
	$(BASH_ADD_TO_SHELLS)
	$(REMOVE)/$(BASH_DIR)
	$(TOUCH)


# -----------------------------------------------------------------------------

# for coolstream: formatting ext4 failes with newer versions then 1.43.8
E2FSPROGS_VER    = $(if $(filter $(BOXTYPE), coolstream),1.43.8,1.45.6)
E2FSPROGS_DIR    = e2fsprogs-$(E2FSPROGS_VER)
E2FSPROGS_SOURCE = e2fsprogs-$(E2FSPROGS_VER).tar.gz
E2FSPROGS_SITE   = https://sourceforge.net/projects/e2fsprogs/files/e2fsprogs/v$(E2FSPROGS_VER)

$(DL_DIR)/$(E2FSPROGS_SOURCE):
	$(DOWNLOAD) $(E2FSPROGS_SITE)/$(E2FSPROGS_SOURCE)

e2fsprogs: $(DL_DIR)/$(E2FSPROGS_SOURCE) | $(TARGET_DIR)
	$(REMOVE)/$(E2FSPROGS_DIR)
	$(UNTAR)/$(E2FSPROGS_SOURCE)
	$(CHDIR)/$(E2FSPROGS_DIR); \
		autoreconf -fi; \
		$(CONFIGURE) \
			--target=$(TARGET) \
			--prefix=$(prefix) \
			--sysconfdir=$(sysconfdir) \
			--datarootdir=$(REMOVE_datarootdir) \
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
	-rm $(addprefix $(TARGET_bin)/, chattr compile_et lsattr mk_cmds uuidgen)
	-rm $(addprefix $(TARGET_sbindir)/, dumpe2fs e2freefrag e2mmpstatus e2undo e4crypt filefrag logsave)
	$(REWRITE_PKGCONF_PC)
	$(REMOVE)/$(E2FSPROGS_DIR)
	$(TOUCH)

# -----------------------------------------------------------------------------

NTFS-3G_VER    = 2017.3.23
NTFS-3G_DIR    = ntfs-3g_ntfsprogs-$(NTFS-3G_VER)
NTFS-3G_SOURCE = ntfs-3g_ntfsprogs-$(NTFS-3G_VER).tgz
NTFS-3G_SITE   = https://tuxera.com/opensource

$(DL_DIR)/$(NTFS-3G_SOURCE):
	$(DOWNLOAD) $(NTFS-3G_SITE)/$(NTFS-3G_SOURCE)

ntfs-3g: $(DL_DIR)/$(NTFS-3G_SOURCE) | $(TARGET_DIR)
	$(REMOVE)/$(NTFS-3G_DIR)
	$(UNTAR)/$(NTFS-3G_SOURCE)
	$(CHDIR)/$(NTFS-3G_DIR); \
		$(CONFIGURE) \
			--prefix=$(prefix) \
			--mandir=$(REMOVE_mandir) \
			--docdir=$(REMOVE_docdir) \
			--disable-ntfsprogs \
			--disable-ldconfig \
			--disable-library \
			; \
		$(MAKE); \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
	-rm $(addprefix $(TARGET_bindir)/,lowntfs-3g ntfs-3g.probe)
	-rm $(addprefix $(TARGET_sbindir)/,mount.lowntfs-3g)
	ln -sf ntfs-3g $(TARGET_sbindir)/mount.ntfs
	$(REMOVE)/$(NTFS-3G_DIR)
	$(TOUCH)

# -----------------------------------------------------------------------------

AUTOFS_VER    = 5.1.6
AUTOFS_DIR    = autofs-$(AUTOFS_VER)
AUTOFS_SOURCE = autofs-$(AUTOFS_VER).tar.xz
AUTOFS_SITE   = $(KERNEL_MIRROR)/linux/daemons/autofs/v5

$(DL_DIR)/$(AUTOFS_SOURCE):
	$(DOWNLOAD) $(AUTOFS_SITE)/$(AUTOFS_SOURCE)

# cd $(PATCHES)\autofs
# wget -N https://mirrors.edge.kernel.org/pub/linux/daemons/autofs/v5/patches-5.1.6/patch_order_5.1.5
# for p in $(cat patch_order_5.1.5); do test -f $p || wget https://mirrors.edge.kernel.org/pub/linux/daemons/autofs/v5/patches-5.1.6/$p; done

AUTOFS_PATCH  = force-STRIP-to-emtpy.patch
#AUTOFS_PATCH += $(shell cat $(PATCHES)/autofs/patch_order_$(AUTOFS_VER))

AUTOFS_DEPS   = libtirpc

autofs: $(AUTOFS_DEPS) $(DL_DIR)/$(AUTOFS_SOURCE) | $(TARGET_DIR)
	$(REMOVE)/$(AUTOFS_DIR)
	$(UNTAR)/$(AUTOFS_SOURCE)
	$(CHDIR)/$(AUTOFS_DIR); \
		$(call apply_patches, $(addprefix $(@F)/,$(AUTOFS_PATCH))); \
		$(SED) "s|nfs/nfs.h|linux/nfs.h|" include/rpc_subs.h; \
		export ac_cv_linux_procfs=yes; \
		export ac_cv_path_KRB5_CONFIG=no; \
		export ac_cv_path_MODPROBE=/sbin/modprobe; \
		export ac_cv_path_RANLIB=$(TARGET_RANLIB); \
		autoreconf -fi; \
		$(CONFIGURE) \
			--prefix=$(prefix) \
			--datarootdir=$(REMOVE_datarootdir) \
			--enable-ignore-busy \
			--disable-mount-locking \
			--without-openldap \
			--without-sasl \
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
	$(INSTALL_COPY) $(TARGET_FILES)/autofs/* $(TARGET_DIR)/
	$(UPDATE-RC.D) autofs defaults 75 25
	$(REMOVE)/$(AUTOFS_DIR)
	$(TOUCH)

# -----------------------------------------------------------------------------

SAMBA_TARGET = $(if $(filter $(BOXSERIES), hd1), samba33, samba36)

samba: $(SAMBA_TARGET)
	$(TOUCH)

# -----------------------------------------------------------------------------

SAMBA33_VER    = 3.3.16
SAMBA33_DIR    = samba-$(SAMBA33_VER)
SAMBA33_SOURCE = samba-$(SAMBA33_VER).tar.gz
SAMBA33_SITE   = https://download.samba.org/pub/samba

$(DL_DIR)/$(SAMBA33_SOURCE):
	$(DOWNLOAD) $(SAMBA33_SITE)/$(SAMBA33_SOURCE)

SAMBA33_PATCH  = samba33-build-only-what-we-need.patch
SAMBA33_PATCH += samba33-configure.in-make-getgrouplist_ok-test-cross-compile.patch

SAMBA33_DEPS   = zlib

samba33: $(SAMBA33_DEPS) $(DL_DIR)/$(SAMBA33_SOURCE) | $(TARGET_DIR)
	$(REMOVE)/$(SAMBA33_DIR)
	$(UNTAR)/$(SAMBA33_SOURCE)
	$(CHDIR)/$(SAMBA33_DIR); \
		$(call apply_patches, $(SAMBA33_PATCH)); \
	$(CHDIR)/$(SAMBA33_DIR)/source; \
		./autogen.sh; \
		export CONFIG_SITE=$(CONFIGS)/samba33-config.site; \
		$(CONFIGURE) \
			--prefix=$(prefix)/ \
			--datadir=/var/samba \
			--datarootdir=$(REMOVE_datarootdir) \
			--localstatedir=/var/samba \
			--sysconfdir=/etc/samba \
			--with-configdir=/etc/samba \
			--with-privatedir=/etc/samba \
			--with-modulesdir=$(REMOVE_libdir)/samba \
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
		$(MAKE1) all; \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
	mkdir -p $(TARGET_localstatedir)/samba/locks
	$(INSTALL_DATA) $(TARGET_FILES)/configs/smb3.conf $(TARGET_sysconfdir)/samba/smb.conf
	$(INSTALL_EXEC) $(TARGET_FILES)/scripts/samba3.init $(TARGET_sysconfdir)/init.d/samba
	$(UPDATE-RC.D) samba defaults 75 25
	rm -rf $(TARGET_bindir)/testparm
	rm -rf $(TARGET_bindir)/findsmb
	rm -rf $(TARGET_bindir)/smbtar
	rm -rf $(TARGET_bindir)/smbclient
	rm -rf $(TARGET_bindir)/smbpasswd
	$(REMOVE)/$(SAMBA33_DIR)
	$(TOUCH)

# -----------------------------------------------------------------------------

SAMBA36_VER    = 3.6.25
SAMBA36_DIR    = samba-$(SAMBA36_VER)
SAMBA36_SOURCE = samba-$(SAMBA36_VER).tar.gz
SAMBA36_SITE   = https://download.samba.org/pub/samba/stable

$(DL_DIR)/$(SAMBA36_SOURCE):
	$(DOWNLOAD) $(SAMBA36_SITE)/$(SAMBA36_SOURCE)

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

SAMBA36_DEPS   = zlib

samba36: $(SAMBA36_DEPS) $(DL_DIR)/$(SAMBA36_SOURCE) | $(TARGET_DIR)
	$(REMOVE)/$(SAMBA36_DIR)
	$(UNTAR)/$(SAMBA36_SOURCE)
	$(CHDIR)/$(SAMBA36_DIR); \
		$(call apply_patches, $(SAMBA36_PATCH1), 1); \
		$(call apply_patches, $(SAMBA36_PATCH0), 0); \
	$(CHDIR)/$(SAMBA36_DIR)/source3; \
		./autogen.sh; \
		export CONFIG_SITE=$(CONFIGS)/samba36-config.site; \
		$(CONFIGURE) \
			--prefix=$(prefix)/ \
			--datadir=/var/samba \
			--datarootdir=$(REMOVE_datarootdir) \
			--localstatedir=/var/samba \
			--sysconfdir=/etc/samba \
			--with-configdir=/etc/samba \
			--with-privatedir=/etc/samba \
			--with-modulesdir=$(REMOVE_libdir)/samba \
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
	mkdir -p $(TARGET_localstatedir)/samba/locks
	$(INSTALL_DATA) $(TARGET_FILES)/configs/smb3.conf $(TARGET_sysconfdir)/samba/smb.conf
	$(INSTALL_EXEC) $(TARGET_FILES)/scripts/samba3.init $(TARGET_sysconfdir)/init.d/samba
	$(UPDATE-RC.D) samba defaults 75 25
	rm -rf $(TARGET_bindir)/testparm
	rm -rf $(TARGET_bindir)/findsmb
	rm -rf $(TARGET_bindir)/smbtar
	rm -rf $(TARGET_bindir)/smbclient
	rm -rf $(TARGET_bindir)/smbpasswd
	$(REMOVE)/$(SAMBA36_DIR)
	$(TOUCH)

# -----------------------------------------------------------------------------

DROPBEAR_VER    = 2019.78
DROPBEAR_DIR    = dropbear-$(DROPBEAR_VER)
DROPBEAR_SOURCE = dropbear-$(DROPBEAR_VER).tar.bz2
DROPBEAR_SITE   = http://matt.ucc.asn.au/dropbear/releases

$(DL_DIR)/$(DROPBEAR_SOURCE):
	$(DOWNLOAD) $(DROPBEAR_SITE)/$(DROPBEAR_SOURCE)

DROPBEAR_DEPS   = zlib

dropbear: $(DROPBEAR_DEPS) $(DL_DIR)/$(DROPBEAR_SOURCE) | $(TARGET_DIR)
	$(REMOVE)/$(DROPBEAR_DIR)
	$(UNTAR)/$(DROPBEAR_SOURCE)
	$(CHDIR)/$(DROPBEAR_DIR); \
		$(CONFIGURE) \
			--prefix=$(prefix) \
			--mandir=$(REMOVE_mandir) \
			--disable-lastlog \
			--disable-pututxline \
			--disable-wtmp \
			--disable-wtmpx \
			--disable-loginfunc \
			--disable-pam \
			--disable-harden \
			--enable-bundled-libtom \
			; \
		# Ensure that dropbear doesn't use crypt() when it's not available; \
		echo '#if !HAVE_CRYPT'				>> localoptions.h; \
		echo '#define DROPBEAR_SVR_PASSWORD_AUTH 0'	>> localoptions.h; \
		echo '#endif'					>> localoptions.h; \
		# disable SMALL_CODE define; \
		echo '#define DROPBEAR_SMALL_CODE 0'		>> localoptions.h; \
		# fix PATH define; \
		echo '#define DEFAULT_PATH "/usr/sbin:/usr/bin:/var/bin"' >> localoptions.h; \
		$(MAKE) PROGRAMS="dropbear dbclient dropbearkey scp" SCPPROGRESS=1; \
		$(MAKE) PROGRAMS="dropbear dbclient dropbearkey scp" install DESTDIR=$(TARGET_DIR)
	mkdir -p $(TARGET_sysconfdir)/dropbear
	$(INSTALL_EXEC) -D $(TARGET_FILES)/scripts/dropbear.init $(TARGET_sysconfdir)/init.d/dropbear
	$(UPDATE-RC.D) dropbear defaults 75 25
	$(REMOVE)/$(DROPBEAR_DIR)
	$(TOUCH)

# -----------------------------------------------------------------------------

SG3_UTILS_VER    = 1.45
SG3_UTILS_DIR    = sg3_utils-$(SG3_UTILS_VER)
SG3_UTILS_SOURCE = sg3_utils-$(SG3_UTILS_VER).tar.xz
SG3_UTILS_SITE   = http://sg.danny.cz/sg/p

$(DL_DIR)/$(SG3_UTILS_SOURCE):
	$(DOWNLOAD) $(SG3_UTILS_SITE)/$(SG3_UTILS_SOURCE)

SG3_UTILS_BIN    = sg_start

sg3_utils: $(DL_DIR)/$(SG3_UTILS_SOURCE) | $(TARGET_DIR)
	$(REMOVE)/$(SG3_UTILS_DIR)
	$(UNTAR)/$(SG3_UTILS_SOURCE)
	$(CHDIR)/$(SG3_UTILS_DIR); \
		$(CONFIGURE) \
			--prefix=$(prefix) \
			--bindir=/bin.$(@F) \
			--mandir=$(REMOVE_mandir) \
			; \
		$(MAKE); \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
	for bin in $(SG3_UTILS_BIN); do \
		rm -f $(TARGET_bindir)/$$bin; \
		$(INSTALL_EXEC) -D $(TARGET_DIR)/bin.$(@F)/$$bin $(TARGET_bindir)/$$bin; \
	done
	$(REWRITE_LIBTOOL_LA)
	$(INSTALL_EXEC) -D $(TARGET_FILES)/scripts/sdX.init $(TARGET_sysconfdir)/init.d/sdX
	$(UPDATE-RC.D) sdX stop 97 0 6 .
	$(REMOVE)/$(SG3_UTILS_DIR) \
		$(TARGET_DIR)/bin.$(@F)
	$(TOUCH)

# -----------------------------------------------------------------------------

FBSHOT_VER    = 0.3
FBSHOT_DIR    = fbshot-$(FBSHOT_VER)
FBSHOT_SOURCE = fbshot-$(FBSHOT_VER).tar.gz
FBSHOT_SITE   = http://distro.ibiblio.org/amigolinux/download/Utils/fbshot

$(DL_DIR)/$(FBSHOT_SOURCE):
	$(DOWNLOAD) $(FBSHOT_SITE)/$(FBSHOT_SOURCE)

FBSHOT_PATCH  = fbshot-32bit_cs_fb.diff
FBSHOT_PATCH += fbshot_cs_hd2.diff

FBSHOT_DEPS   = libpng

fbshot: $(FBSHOT_DEPS) $(DL_DIR)/$(FBSHOT_SOURCE) | $(TARGET_DIR)
	$(REMOVE)/$(FBSHOT_DIR)
	$(UNTAR)/$(FBSHOT_SOURCE)
	$(CHDIR)/$(FBSHOT_DIR); \
		$(call apply_patches, $(FBSHOT_PATCH)); \
		$(SED) 's|	gcc |	$(TARGET_CC) $(TARGET_CFLAGS) $(TARGET_LDFLAGS) |' Makefile; \
		$(SED) '/strip fbshot/d' Makefile; \
		$(MAKE) all; \
		$(INSTALL_EXEC) -D fbshot $(TARGET_bindir)/fbshot
	$(REMOVE)/$(FBSHOT_DIR)
	$(TOUCH)

# -----------------------------------------------------------------------------

LCD4LINUX_VER    = git
LCD4LINUX_DIR    = lcd4linux.$(LCD4LINUX_VER)
LCD4LINUX_SOURCE = lcd4linux.$(LCD4LINUX_VER)
LCD4LINUX_SITE   = https://github.com/TangoCash

LCD4LINUX_DEPS   = ncurses libgd libdpf

lcd4linux: $(LCD4LINUX_DEPS) | $(TARGET_DIR)
	$(REMOVE)/$(LCD4LINUX_DIR)
	$(GET-GIT-SOURCE) $(LCD4LINUX_SITE)/$(LCD4LINUX_SOURCE) $(DL_DIR)/$(LCD4LINUX_SOURCE)
	$(CPDIR)/$(LCD4LINUX_SOURCE)
	$(CHDIR)/$(LCD4LINUX_DIR); \
		./bootstrap; \
		$(CONFIGURE) \
			--libdir=$(TARGET_libdir) \
			--includedir=$(TARGET_includedir) \
			--bindir=$(TARGET_bindir) \
			--prefix=$(prefix) \
			--mandir=$(REMOVE_mandir) \
			--docdir=$(REMOVE_docdir) \
			--infodir=$(REMOVE_infodir) \
			--with-ncurses=$(TARGET_libdir) \
			--with-drivers='DPF, SamsungSPF, PNG' \
			--with-plugins='all,!dbus,!mpris_dbus,!asterisk,!isdn,!pop3,!ppp,!seti,!huawei,!imon,!kvv,!sample,!w1retap,!wireless,!xmms,!gps,!mpd,!mysql,!qnaplog,!iconv' \
			; \
		$(MAKE) vcs_version; \
		$(MAKE) all; \
		$(MAKE) install
	$(INSTALL_COPY) $(TARGET_FILES)/lcd4linux/* $(TARGET_DIR)/
	#$(MAKE) samsunglcd4linux
	$(REMOVE)/$(LCD4LINUX_DIR)
	$(TOUCH)

# -----------------------------------------------------------------------------

SAMSUNGLCD4LINUX_VER    = git
SAMSUNGLCD4LINUX_DIR    = samsunglcd4linux.$(LCD4LINUX_VER)
SAMSUNGLCD4LINUX_SOURCE = samsunglcd4linux.$(LCD4LINUX_VER)
SAMSUNGLCD4LINUX_SITE   = https://github.com/horsti58

samsunglcd4linux: | $(TARGET_DIR)
	$(REMOVE)/$(SAMSUNGLCD4LINUX_DIR)
	$(GET-GIT-SOURCE) $(SAMSUNGLCD4LINUX_SITE)/$(SAMSUNGLCD4LINUX_SOURCE) $(DL_DIR)/$(SAMSUNGLCD4LINUX_SOURCE)
	$(CPDIR)/$(SAMSUNGLCD4LINUX_SOURCE)
	$(CHDIR)/$(SAMSUNGLCD4LINUX_DIR)/ni; \
		$(INSTALL) -m 0600 etc/lcd4linux.conf $(TARGET_sysconfdir); \
		$(INSTALL_COPY) share/* $(TARGET_datadir)
	$(REMOVE)/$(SAMSUNGLCD4LINUX_DIR)
	$(TOUCH)

# -----------------------------------------------------------------------------

WPA_SUPPLICANT_VER    = 0.7.3
WPA_SUPPLICANT_DIR    = wpa_supplicant-$(WPA_SUPPLICANT_VER)
WPA_SUPPLICANT_SOURCE = wpa_supplicant-$(WPA_SUPPLICANT_VER).tar.gz
WPA_SUPPLICANT_SITE   = https://w1.fi/releases

$(DL_DIR)/$(WPA_SUPPLICANT_SOURCE):
	$(DOWNLOAD) $(WPA_SUPPLICANT_SITE)/$(WPA_SUPPLICANT_SOURCE)

WPA_SUPPLICANT_DEPS   = openssl

wpa_supplicant: $(WPA_SUPPLICANT_DEPS) $(DL_DIR)/$(WPA_SUPPLICANT_SOURCE) | $(TARGET_DIR)
	$(REMOVE)/$(WPA_SUPPLICANT_DIR)
	$(UNTAR)/$(WPA_SUPPLICANT_SOURCE)
	$(CHDIR)/$(WPA_SUPPLICANT_DIR)/wpa_supplicant; \
		$(INSTALL_DATA) $(CONFIGS)/wpa_supplicant.config .config; \
		$(MAKE_ENV) \
		$(MAKE); \
		$(MAKE) install DESTDIR=$(TARGET_DIR) BINDIR=$(sbindir)
	$(INSTALL_EXEC) -D $(TARGET_FILES)/scripts/pre-wlan0.sh $(TARGET_sysconfdir)/network/pre-wlan0.sh
	$(INSTALL_EXEC) -D $(TARGET_FILES)/scripts/post-wlan0.sh $(TARGET_sysconfdir)/network/post-wlan0.sh
	$(REMOVE)/$(WPA_SUPPLICANT_DIR)
	$(TOUCH)

# -----------------------------------------------------------------------------

XUPNPD_VER    = git
XUPNPD_DIR    = xupnpd.$(XUPNPD_VER)
XUPNPD_SOURCE = xupnpd.$(XUPNPD_VER)
XUPNPD_SITE   = https://github.com/clark15b

XUPNPD_PATCH  = xupnpd-dynamic-lua.patch
XUPNPD_PATCH += xupnpd-fix-memleak.patch
XUPNPD_PATCH += xupnpd-fix-webif-backlinks.diff
XUPNPD_PATCH += xupnpd-add-configuration-files.diff

XUPNPD_DEPS   = lua openssl

xupnpd: $(XUPNPD_DEPS) | $(TARGET_DIR)
	$(REMOVE)/$(XUPNPD_DIR)
	$(GET-GIT-SOURCE) $(XUPNPD_SITE)/$(XUPNPD_SOURCE) $(DL_DIR)/$(XUPNPD_SOURCE)
	$(CPDIR)/$(XUPNPD_SOURCE)
	$(CHDIR)/$(XUPNPD_DIR); \
		git checkout 25d6d44; \
		$(call apply_patches, $(XUPNPD_PATCH))
	$(CHDIR)/$(XUPNPD_DIR)/src; \
		$(MAKE_ENV) \
		$(MAKE) embedded TARGET=$(TARGET) CC=$(TARGET_CC) STRIP=$(TARGET_STRIP) LUAFLAGS="$(TARGET_LDFLAGS) -I$(TARGET_includedir)"; \
		$(INSTALL_EXEC) -D xupnpd $(TARGET_bindir)/; \
		mkdir -p $(TARGET_datadir)/xupnpd/config; \
		$(INSTALL_COPY) plugins profiles ui www *.lua $(TARGET_datadir)/xupnpd/
	rm $(TARGET_datadir)/xupnpd/plugins/staff/xupnpd_18plus.lua
	$(INSTALL_DATA) -D $(SOURCE_DIR)/$(NI-NEUTRINO-PLUGINS)/scripts-lua/xupnpd/xupnpd_18plus.lua $(TARGET_datadir)/xupnpd/plugins/
	$(INSTALL_DATA) -D $(SOURCE_DIR)/$(NI-NEUTRINO-PLUGINS)/scripts-lua/xupnpd/xupnpd_cczwei.lua $(TARGET_datadir)/xupnpd/plugins/
	$(INSTALL_DATA) -D $(SOURCE_DIR)/$(NI-NEUTRINO-PLUGINS)/scripts-lua/xupnpd/xupnpd_neutrino.lua $(TARGET_datadir)/xupnpd/plugins/
	$(INSTALL_DATA) -D $(SOURCE_DIR)/$(NI-NEUTRINO-PLUGINS)/scripts-lua/xupnpd/xupnpd_vimeo.lua $(TARGET_datadir)/xupnpd/plugins/
	$(INSTALL_DATA) -D $(SOURCE_DIR)/$(NI-NEUTRINO-PLUGINS)/scripts-lua/xupnpd/xupnpd_youtube.lua $(TARGET_datadir)/xupnpd/plugins/
	$(INSTALL_EXEC) -D $(TARGET_FILES)/scripts/xupnpd.init $(TARGET_sysconfdir)/init.d/xupnpd
	$(UPDATE-RC.D) xupnpd defaults 75 25
	$(INSTALL_COPY) $(TARGET_FILES)/xupnpd/* $(TARGET_DIR)/
	$(REMOVE)/$(XUPNPD_DIR)
	$(TOUCH)

# -----------------------------------------------------------------------------

DOSFSTOOLS_VER    = 4.1
DOSFSTOOLS_DIR    = dosfstools-$(DOSFSTOOLS_VER)
DOSFSTOOLS_SOURCE = dosfstools-$(DOSFSTOOLS_VER).tar.xz
DOSFSTOOLS_SITE   = https://github.com/dosfstools/dosfstools/releases/download/v$(DOSFSTOOLS_VER)

$(DL_DIR)/$(DOSFSTOOLS_SOURCE):
	$(DOWNLOAD) $(DOSFSTOOLS_SITE)/$(DOSFSTOOLS_SOURCE)

DOSFSTOOLS_PATCH  = switch-to-AC_CHECK_LIB-for-iconv-library-linking.patch

DOSFSTOOLS_CFLAGS = $(TARGET_CFLAGS) -D_GNU_SOURCE -D_LARGEFILE_SOURCE -D_FILE_OFFSET_BITS=64 -fomit-frame-pointer

dosfstools: $(DL_DIR)/$(DOSFSTOOLS_SOURCE) | $(TARGET_DIR)
	$(REMOVE)/$(DOSFSTOOLS_DIR)
	$(UNTAR)/$(DOSFSTOOLS_SOURCE)
	$(CHDIR)/$(DOSFSTOOLS_DIR); \
		$(call apply_patches, $(addprefix $(@F)/,$(DOSFSTOOLS_PATCH))); \
		autoreconf -fi; \
		$(CONFIGURE) \
			--prefix=$(prefix) \
			--mandir=$(REMOVE_mandir) \
			--docdir=$(REMOVE_docdir) \
			--without-udev \
			--enable-compat-symlinks \
			CFLAGS="$(DOSFSTOOLS_CFLAGS)" \
			; \
		$(MAKE); \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
	$(REMOVE)/$(DOSFSTOOLS_DIR)
	$(TOUCH)

# -----------------------------------------------------------------------------

NFS-UTILS_VER    = 2.2.1
NFS-UTILS_DIR    = nfs-utils-$(NFS-UTILS_VER)
NFS-UTILS_SOURCE = nfs-utils-$(NFS-UTILS_VER).tar.xz
NFS-UTILS_SITE   = $(KERNEL_MIRROR)/linux/utils/nfs-utils/$(NFS-UTILS_VER)

$(DL_DIR)/$(NFS-UTILS_SOURCE):
	$(DOWNLOAD) $(NFS-UTILS_SITE)/$(NFS-UTILS_SOURCE)

NFS-UTILS_PATCH  = nfs-utils_01-Patch-taken-from-Gentoo.patch
NFS-UTILS_PATCH += nfs-utils_02-Switch-legacy-index-in-favour-of-strchr.patch
NFS-UTILS_PATCH += nfs-utils_03-Let-the-configure-script-find-getrpcbynumber-in-libt.patch
NFS-UTILS_PATCH += nfs-utils_04-mountd-Add-check-for-struct-file_handle.patch

NFS-UTILS_DEPS   = rpcbind

NFS-UTILS_CONF   = $(if $(filter $(BOXSERIES), hd1),--disable-ipv6,--enable-ipv6)

nfs-utils: $(NFS-UTILS_DEPS) $(DL_DIR)/$(NFS-UTILS_SOURCE) | $(TARGET_DIR)
	$(REMOVE)/$(NFS-UTILS_DIR)
	$(UNTAR)/$(NFS-UTILS_SOURCE)
	$(CHDIR)/$(NFS-UTILS_DIR); \
		$(call apply_patches, $(NFS-UTILS_PATCH)); \
		export knfsd_cv_bsd_signals=no; \
		autoreconf -fi; \
		$(CONFIGURE) \
			--target=$(TARGET) \
			--prefix=$(prefix) \
			--docdir=$(REMOVE_docdir) \
			--mandir=$(REMOVE_mandir) \
			--enable-maintainer-mode \
			--disable-nfsv4 \
			--disable-nfsv41 \
			--disable-gss \
			--disable-uuid \
			$(NFS-UTILS_CONF) \
			--without-tcp-wrappers \
			--with-statedir=/var/lib/nfs \
			--with-rpcgen=internal \
			--without-systemd \
			; \
		$(MAKE); \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
	chmod 0755 $(TARGET_base_sbindir)/mount.nfs
	rm -f $(addprefix $(TARGET_base_sbindir)/,mount.nfs4 osd_login umount.nfs umount.nfs4)
	rm -f $(addprefix $(TARGET_sbindir)/,mountstats nfsiostat)
	$(INSTALL_EXEC) -D $(TARGET_FILES)/scripts/nfsd.init $(TARGET_sysconfdir)/init.d/nfsd
	$(UPDATE-RC.D) nfsd defaults 75 25
	$(REMOVE)/$(NFS-UTILS_DIR)
	$(TOUCH)

# -----------------------------------------------------------------------------

RPCBIND_VER    = 1.2.5
RPCBIND_DIR    = rpcbind-$(RPCBIND_VER)
RPCBIND_SOURCE = rpcbind-$(RPCBIND_VER).tar.bz2
RPCBIND_SITE   = https://sourceforge.net/projects/rpcbind/files/rpcbind/$(RPCBIND_VER)

$(DL_DIR)/$(RPCBIND_SOURCE):
	$(DOWNLOAD) $(RPCBIND_SITE)/$(RPCBIND_SOURCE)

RPCBIND_PATCH  = rpcbind-0001-Remove-yellow-pages-support.patch
RPCBIND_PATCH += rpcbind-0002-add_option_to_fix_port_number.patch

RPCBIND_DEPS   = libtirpc

rpcbind: $(RPCBIND_DEPS) $(DL_DIR)/$(RPCBIND_SOURCE) | $(TARGET_DIR)
	$(REMOVE)/$(RPCBIND_DIR)
	$(UNTAR)/$(RPCBIND_SOURCE)
	$(CHDIR)/$(RPCBIND_DIR); \
		$(call apply_patches, $(RPCBIND_PATCH)); \
		autoreconf -fi; \
		$(CONFIGURE) \
			--target=$(TARGET) \
			--prefix=$(prefix) \
			--enable-silent-rules \
			--with-rpcuser=root \
			--with-systemdsystemunitdir=no \
			--mandir=$(REMOVE_mandir) \
			; \
		$(MAKE); \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
	rm -rf $(TARGET_bindir)/rpcgen
	$(REMOVE)/$(RPCBIND_DIR)
	$(TOUCH)

# -----------------------------------------------------------------------------

FUSE-EXFAT_VER    = 1.3.0
FUSE-EXFAT_DIR    = fuse-exfat-$(FUSE-EXFAT_VER)
FUSE-EXFAT_SOURCE = fuse-exfat-$(FUSE-EXFAT_VER).tar.gz
FUSE-EXFAT_SITE   = https://github.com/relan/exfat/releases/download/v$(FUSE-EXFAT_VER)

$(DL_DIR)/$(FUSE-EXFAT_SOURCE):
	$(DOWNLOAD) $(FUSE-EXFAT_SITE)/$(FUSE-EXFAT_SOURCE)

FUSE-EXFAT_DEPS   = libfuse

fuse-exfat: $(FUSE-EXFAT_DEPS) $(DL_DIR)/$(FUSE-EXFAT_SOURCE) | $(TARGET_DIR)
	$(REMOVE)/$(FUSE-EXFAT_DIR)
	$(UNTAR)/$(FUSE-EXFAT_SOURCE)
	$(CHDIR)/$(FUSE-EXFAT_DIR); \
		autoreconf -fi; \
		$(CONFIGURE) \
			--prefix=$(prefix) \
			--docdir=$(REMOVE_docdir) \
			--mandir=$(REMOVE_mandir) \
			; \
		$(MAKE); \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
	$(REMOVE)/$(FUSE-EXFAT_DIR)
	$(TOUCH)

# -----------------------------------------------------------------------------

EXFAT-UTILS_VER    = 1.3.0
EXFAT-UTILS_DIR    = exfat-utils-$(EXFAT-UTILS_VER)
EXFAT-UTILS_SOURCE = exfat-utils-$(EXFAT-UTILS_VER).tar.gz
EXFAT-UTILS_SITE   = https://github.com/relan/exfat/releases/download/v$(EXFAT-UTILS_VER)

$(DL_DIR)/$(EXFAT-UTILS_SOURCE):
	$(DOWNLOAD) $(EXFAT-UTILS_SITE)/$(EXFAT-UTILS_SOURCE)

EXFAT-UTILS_DEPS   = fuse-exfat

exfat-utils: $(EXFAT-UTILS_DEPS) $(DL_DIR)/$(EXFAT-UTILS_SOURCE) | $(TARGET_DIR)
	$(REMOVE)/$(EXFAT-UTILS_DIR)
	$(UNTAR)/$(EXFAT-UTILS_SOURCE)
	$(CHDIR)/$(EXFAT-UTILS_DIR); \
		autoreconf -fi; \
		$(CONFIGURE) \
			--prefix=$(prefix) \
			--docdir=$(REMOVE_docdir) \
			--mandir=$(REMOVE_mandir) \
			; \
		$(MAKE); \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
	$(REMOVE)/$(EXFAT-UTILS_DIR)
	$(TOUCH)

# -----------------------------------------------------------------------------

STREAMRIPPER_DEPS   = libvorbisidec libmad glib2

streamripper: $(STREAMRIPPER_DEPS) | $(TARGET_DIR)
	$(REMOVE)/$(NI-STREAMRIPPER)
	tar -C $(SOURCE_DIR) -cp $(NI-STREAMRIPPER) --exclude-vcs | tar -C $(BUILD_DIR) -x
	$(CHDIR)/$(NI-STREAMRIPPER); \
		autoreconf -fi; \
		$(CONFIGURE) \
			--prefix= \
			--includedir=$(TARGET_includedir) \
			--datarootdir=$(REMOVE_datarootdir) \
			--with-included-argv=yes \
			--with-included-libmad=no \
			; \
		$(MAKE); \
		$(INSTALL_EXEC) -D streamripper $(TARGET_bindir)/streamripper
	$(INSTALL_EXEC) $(TARGET_FILES)/scripts/streamripper.sh $(TARGET_bindir)/
	$(TOUCH)

# -----------------------------------------------------------------------------

GETTEXT_VER    = 0.19.8.1
GETTEXT_DIR    = gettext-$(GETTEXT_VER)
GETTEXT_SOURCE = gettext-$(GETTEXT_VER).tar.xz
GETTEXT_SITE   = $(GNU_MIRROR)/gettext

$(DL_DIR)/$(GETTEXT_SOURCE):
	$(DOWNLOAD) $(GETTEXT_SITE)/$(GETTEXT_SOURCE)

gettext: $(DL_DIR)/$(GETTEXT_SOURCE) | $(TARGET_DIR)
	$(REMOVE)/$(GETTEXT_DIR)
	$(UNTAR)/$(GETTEXT_SOURCE)
	$(CHDIR)/$(GETTEXT_DIR)/gettext-runtime; \
		autoreconf -fi; \
		$(CONFIGURE) \
			--prefix=$(prefix) \
			--bindir=$(REMOVE_bindir) \
			--datarootdir=$(REMOVE_datarootdir) \
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
	$(REWRITE_LIBTOOL_LA)
	$(REMOVE)/$(GETTEXT_DIR)
	$(TOUCH)

# -----------------------------------------------------------------------------

MC_VER    = 4.8.25
MC_DIR    = mc-$(MC_VER)
MC_SOURCE = mc-$(MC_VER).tar.xz
MC_SITE   = ftp.midnight-commander.org

$(DL_DIR)/$(MC_SOURCE):
	$(DOWNLOAD) $(MC_SITE)/$(MC_SOURCE)

MC_DEPS   = glib2 ncurses

mc: $(MC_DEPS) $(DL_DIR)/$(MC_SOURCE) | $(TARGET_DIR)
	$(REMOVE)/$(MC_DIR)
	$(UNTAR)/$(MC_SOURCE)
	$(CHDIR)/$(MC_DIR); \
		$(APPLY_PATCHES); \
		autoreconf -fi; \
		$(CONFIGURE) \
			--prefix=$(prefix) \
			--sysconfdir=$(sysconfdir) \
			--mandir=$(REMOVE_mandir) \
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
	rm -rf $(TARGET_datadir)/mc/examples
	find $(TARGET_datadir)/mc/skins -type f ! -name default.ini | xargs --no-run-if-empty rm
	$(REMOVE)/$(MC_DIR)
	$(TOUCH)

# -----------------------------------------------------------------------------

WGET_VER    = 1.20.3
WGET_DIR    = wget-$(WGET_VER)
WGET_SOURCE = wget-$(WGET_VER).tar.gz
WGET_SITE   = $(GNU_MIRROR)/wget

$(DL_DIR)/$(WGET_SOURCE):
	$(DOWNLOAD) $(WGET_SITE)/$(WGET_SOURCE)

WGET_PATCH  = set-check_cert-false-by-default.patch
WGET_PATCH += change_DEFAULT_LOGFILE.patch

WGET_DEPS   = openssl

WGET_CFLAGS = $(TARGET_CFLAGS) -DOPENSSL_NO_ENGINE

wget: $(WGET_DEPS) $(DL_DIR)/$(WGET_SOURCE) | $(TARGET_DIR)
	$(REMOVE)/$(WGET_DIR)
	$(UNTAR)/$(WGET_SOURCE)
	$(CHDIR)/$(WGET_DIR); \
		$(call apply_patches, $(addprefix $(@F)/,$(WGET_PATCH))); \
		$(CONFIGURE) \
			--target=$(TARGET) \
			--prefix=$(prefix) \
			--datarootdir=$(REMOVE_datarootdir) \
			--sysconfdir=$(REMOVE_sysconfdir) \
			--with-gnu-ld \
			--with-ssl=openssl \
			--disable-debug \
			CFLAGS="$(WGET_CFLAGS)" \
			; \
		$(MAKE); \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
	$(REMOVE)/$(WGET_DIR)
	$(TOUCH)

# -----------------------------------------------------------------------------

ofgwrite: $(SOURCE_DIR)/$(NI-OFGWRITE) | $(TARGET_DIR)
	$(REMOVE)/$(NI-OFGWRITE)
	tar -C $(SOURCE_DIR) -cp $(NI-OFGWRITE) --exclude-vcs | tar -C $(BUILD_DIR) -x
	$(CHDIR)/$(NI-OFGWRITE); \
		$(MAKE_ENV) \
		$(MAKE)
	$(INSTALL_EXEC) $(BUILD_DIR)/$(NI-OFGWRITE)/ofgwrite_bin $(TARGET_bindir)
	$(INSTALL_EXEC) $(BUILD_DIR)/$(NI-OFGWRITE)/ofgwrite_caller $(TARGET_bindir)
	$(INSTALL_EXEC) $(BUILD_DIR)/$(NI-OFGWRITE)/ofgwrite $(TARGET_bindir)
	$(SED) 's|prefix=.*|prefix=$(prefix)|' $(TARGET_bindir)/ofgwrite
	$(REMOVE)/$(NI-OFGWRITE)
	$(TOUCH)

# -----------------------------------------------------------------------------

AIO-GRAB_VER    = git
AIO-GRAB_DIR    = aio-grab.$(AIO-GRAB_VER)
AIO-GRAB_SOURCE = aio-grab.$(AIO-GRAB_VER)
AIO-GRAB_SITE   = https://github.com/oe-alliance

AIO-GRAB_DEPS   = zlib libpng libjpeg-turbo

aio-grab: $(AIO-GRAB_DEPS) | $(TARGET_DIR)
	$(REMOVE)/$(AIO-GRAB_DIR)
	$(GET-GIT-SOURCE) $(AIO-GRAB_SITE)/$(AIO-GRAB_SOURCE) $(DL_DIR)/$(AIO-GRAB_SOURCE)
	$(CPDIR)/$(AIO-GRAB_SOURCE)
	$(CHDIR)/$(AIO-GRAB_DIR); \
		aclocal --force -I m4; \
		libtoolize --copy --ltdl --force; \
		autoconf --force; \
		automake --add-missing --copy --force-missing --foreign; \
		$(CONFIGURE) \
			--target=$(TARGET) \
			--prefix=$(prefix) \
			--enable-silent-rules \
			; \
		$(MAKE) all; \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
	$(REMOVE)/$(AIO-GRAB_DIR)
	$(TOUCH)

# -----------------------------------------------------------------------------

DVBSNOOP_VER    = git
DVBSNOOP_DIR    = dvbsnoop.$(DVBSNOOP_VER)
DVBSNOOP_SOURCE = dvbsnoop.$(DVBSNOOP_VER)
DVBSNOOP_SITE   = https://github.com/Duckbox-Developers

dvbsnoop: | $(TARGET_DIR)
	$(REMOVE)/$(DVBSNOOP_DIR)
	$(GET-GIT-SOURCE) $(DVBSNOOP_SITE)/$(DVBSNOOP_SOURCE) $(DL_DIR)/$(DVBSNOOP_SOURCE)
	$(CPDIR)/$(DVBSNOOP_SOURCE)
	$(CHDIR)/$(DVBSNOOP_DIR); \
		$(CONFIGURE) \
			--enable-silent-rules \
			--prefix=$(prefix) \
			--mandir=$(REMOVE_mandir) \
			; \
		$(MAKE); \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
	$(REMOVE)/$(DVBSNOOP_DIR)
	$(TOUCH)

# -----------------------------------------------------------------------------

ETHTOOL_VER    = 5.9
ETHTOOL_DIR    = ethtool-$(ETHTOOL_VER)
ETHTOOL_SOURCE = ethtool-$(ETHTOOL_VER).tar.xz
ETHTOOL_SITE   = $(KERNEL_MIRROR)/software/network/ethtool

$(DL_DIR)/$(ETHTOOL_SOURCE):
	$(DOWNLOAD) $(ETHTOOL_SITE)/$(ETHTOOL_SOURCE)

ethtool: $(DL_DIR)/$(ETHTOOL_SOURCE) | $(TARGET_DIR)
	$(REMOVE)/$(ETHTOOL_DIR)
	$(UNTAR)/$(ETHTOOL_SOURCE)
	$(CHDIR)/$(ETHTOOL_DIR); \
		$(CONFIGURE) \
			--prefix=$(prefix) \
			--mandir=$(REMOVE_mandir) \
			--libdir=$(TARGET_libdir) \
			--disable-pretty-dump \
			--disable-netlink \
			; \
		$(MAKE); \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
	$(REMOVE)/$(ETHTOOL_DIR)
	$(TOUCH)

# -----------------------------------------------------------------------------

GPTFDISK_VER    = 1.0.4
GPTFDISK_DIR    = gptfdisk-$(GPTFDISK_VER)
GPTFDISK_SOURCE = gptfdisk-$(GPTFDISK_VER).tar.gz
GPTFDISK_SITE   = https://sourceforge.net/projects/gptfdisk/files/gptfdisk/$(GPTFDISK_VER)

$(DL_DIR)/$(GPTFDISK_SOURCE):
	$(DOWNLOAD) $(GPTFDISK_SITE)/$(GPTFDISK_SOURCE)

GPTFDISK_PATCH  = gptfdisk-ldlibs.patch

GPTFDISK_DEPS   = popt e2fsprogs

gptfdisk: $(GPTFDISK_DEPS) $(DL_DIR)/$(GPTFDISK_SOURCE) | $(TARGET_DIR)
	$(REMOVE)/$(GPTFDISK_DIR)
	$(UNTAR)/$(GPTFDISK_SOURCE)
	$(CHDIR)/$(GPTFDISK_DIR); \
		$(call apply_patches, $(GPTFDISK_PATCH)); \
		$(SED) 's|^CC=.*|CC=$(TARGET_CC)|' Makefile; \
		$(SED) 's|^CXX=.*|CXX=$(TARGET_CXX)|' Makefile; \
		$(MAKE_ENV) \
		$(MAKE) sgdisk; \
		$(INSTALL_EXEC) -D sgdisk $(TARGET_sbindir)/sgdisk
	$(REMOVE)/$(GPTFDISK_DIR)
	$(TOUCH)

# -----------------------------------------------------------------------------

RSYNC_VER    = 3.1.3
RSYNC_DIR    = rsync-$(RSYNC_VER)
RSYNC_SOURCE = rsync-$(RSYNC_VER).tar.gz
RSYNC_SITE   = https://download.samba.org/pub/rsync/src/

$(DL_DIR)/$(RSYNC_SOURCE):
	$(DOWNLOAD) $(RSYNC_SITE)/$(RSYNC_SOURCE)

RSYNC_DEPS   = zlib popt

rsync: $(RSYNC_DEPS) $(DL_DIR)/$(RSYNC_SOURCE) | $(TARGET_DIR)
	$(REMOVE)/$(RSYNC_DIR)
	$(UNTAR)/$(RSYNC_SOURCE)
	$(CHDIR)/$(RSYNC_DIR); \
		$(CONFIGURE) \
			--prefix=$(prefix) \
			--mandir=$(REMOVE_mandir) \
			--disable-debug \
			--disable-locale \
			--disable-acl-support \
			--with-included-zlib=no \
			--with-included-popt=no \
			; \
		$(MAKE); \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
	$(REMOVE)/$(RSYNC_DIR)
	$(TOUCH)

# -----------------------------------------------------------------------------

SYSVINIT_VER    = 2.98
SYSVINIT_DIR    = sysvinit-$(SYSVINIT_VER)
SYSVINIT_SOURCE = sysvinit-$(SYSVINIT_VER).tar.xz
SYSVINIT_SITE   = http://download.savannah.nongnu.org/releases/sysvinit

$(DL_DIR)/$(SYSVINIT_SOURCE):
	$(DOWNLOAD) $(SYSVINIT_SITE)/$(SYSVINIT_SOURCE)

define SYSVINIT_INSTALL
	for sbin in halt init shutdown killall5 runlevel; do \
		$(INSTALL_EXEC) -D $(BUILD_DIR)/$(SYSVINIT_DIR)/src/$$sbin $(TARGET_base_sbindir)/$$sbin || exit 1; \
	done
	ln -sf /sbin/halt $(TARGET_base_sbindir)/reboot
	ln -sf /sbin/halt $(TARGET_base_sbindir)/poweroff
	ln -sf /sbin/killall5 $(TARGET_base_sbindir)/pidof
endef

sysvinit: $(DL_DIR)/$(SYSVINIT_SOURCE) | $(TARGET_DIR)
	$(REMOVE)/$(SYSVINIT_DIR)
	$(UNTAR)/$(SYSVINIT_SOURCE)
	$(CHDIR)/$(SYSVINIT_DIR); \
		$(APPLY_PATCHES); \
		$(MAKE_ENV) \
		$(MAKE) -C src SULOGINLIBS=-lcrypt
	$(SYSVINIT_INSTALL)
	$(REMOVE)/$(SYSVINIT_DIR)
	$(TOUCH)

# -----------------------------------------------------------------------------

CA-BUNDLE_SOURCE = cacert.pem
CA-BUNDLE_SITE   = https://curl.haxx.se/ca

$(DL_DIR)/$(CA-BUNDLE_SOURCE):
	$(DOWNLOAD) $(CA-BUNDLE_SITE)/$(CA-BUNDLE_SOURCE)

CA-BUNDLE        = ca-certificates.crt
CA-BUNDLE_DIR    = /etc/ssl/certs

ca-bundle: $(DL_DIR)/$(CA-BUNDLE_SOURCE) | $(TARGET_DIR)
	$(CD) $(DL_DIR); \
		curl --remote-name --time-cond $(CA-BUNDLE_SOURCE) $(CA-BUNDLE_SITE)/$(CA-BUNDLE_SOURCE) || true
	$(INSTALL_DATA) -D $(DL_DIR)/$(CA-BUNDLE_SOURCE) $(TARGET_DIR)/$(CA-BUNDLE_DIR)/$(CA-BUNDLE)
	$(TOUCH)
