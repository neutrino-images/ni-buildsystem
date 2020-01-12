#
# makefile to build system tools
#
# -----------------------------------------------------------------------------

BUSYBOX_VER    = 1.31.1
BUSYBOX_TMP    = busybox-$(BUSYBOX_VER)
BUSYBOX_SOURCE = busybox-$(BUSYBOX_VER).tar.bz2
BUSYBOX_URL    = https://busybox.net/downloads

$(ARCHIVE)/$(BUSYBOX_SOURCE):
	$(DOWNLOAD) $(BUSYBOX_URL)/$(BUSYBOX_SOURCE)

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

BUSYBOX_BUILD_CONFIG = $(BUILD_TMP)/$(BUSYBOX_TMP)/.config

define BUSYBOX_INSTALL_CONFIG
	$(INSTALL_DATA) $(CONFIGS)/busybox-minimal.config $(BUSYBOX_BUILD_CONFIG)
	$(call KCONFIG_SET_OPT,CONFIG_PREFIX,"$(TARGET_DIR)",$(BUSYBOX_BUILD_CONFIG))
endef

ifeq ($(BOXSERIES), $(filter $(BOXSERIES), hd2 hd51 vusolo4k vuduo4k vuultimo4k vuzero4k vuuno4k vuuno4kse vuduo))

  define BUSYBOX_SET_BLKDISCARD
	$(call KCONFIG_ENABLE_OPT,CONFIG_BLKDISCARD,$(BUSYBOX_BUILD_CONFIG))
  endef

  define BUSYBOX_SET_IPV6
	$(call KCONFIG_ENABLE_OPT,CONFIG_FEATURE_IPV6,$(BUSYBOX_BUILD_CONFIG))
	$(call KCONFIG_ENABLE_OPT,CONFIG_FEATURE_IFUPDOWN_IPV6,$(BUSYBOX_BUILD_CONFIG))
  endef

  ifeq ($(BOXSERIES), $(filter $(BOXSERIES), hd51 vusolo4k vuduo4k vuultimo4k vuzero4k vuuno4k vuuno4kse vuduo))

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

    ifeq ($(BOXSERIES), $(filter $(BOXSERIES), vusolo4k vuduo4k vuultimo4k vuzero4k vuuno4k vuuno4kse vuduo))

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
		grep -qsE '^/bin/ash$$' $(TARGET_DIR)/etc/shells \
			|| echo "/bin/ash" >> $(TARGET_DIR)/etc/shells; \
	fi
	if grep -q 'CONFIG_HUSH=y' $(BUSYBOX_BUILD_CONFIG); then \
		grep -qsE '^/bin/hush$$' $(TARGET_DIR)/etc/shells \
			|| echo "/bin/hush" >> $(TARGET_DIR)/etc/shells; \
	fi
	if grep -q 'CONFIG_SH_IS_ASH=y\|CONFIG_SH_IS_HUSH=y' $(BUSYBOX_BUILD_CONFIG); then \
		grep -qsE '^/bin/sh$$' $(TARGET_DIR)/etc/shells \
			|| echo "/bin/sh" >> $(TARGET_DIR)/etc/shells; \
	fi
endef

busybox: $(BUSYBOX_DEPS) $(ARCHIVE)/$(BUSYBOX_SOURCE) | $(TARGET_DIR)
	$(REMOVE)/$(BUSYBOX_TMP)
	$(UNTAR)/$(BUSYBOX_SOURCE)
	$(CHDIR)/$(BUSYBOX_TMP); \
		$(call apply_patches, $(BUSYBOX_PATCH))
	$(BUSYBOX_INSTALL_CONFIG)
	$(BUSYBOX_MODIFY_CONFIG)
	$(CHDIR)/$(BUSYBOX_TMP); \
		$(BUSYBOX_MAKE_ENV) $(MAKE) $(BUSYBOX_MAKE_OPTS) busybox; \
		$(BUSYBOX_MAKE_ENV) $(MAKE) $(BUSYBOX_MAKE_OPTS) install-noclobber
	$(BUSYBOX_ADD_TO_SHELLS)
	$(REMOVE)/$(BUSYBOX_TMP)
	$(TOUCH)

# -----------------------------------------------------------------------------

OPENVPN_VER    = 2.4.6
OPENVPN_TMP    = openvpn-$(OPENVPN_VER)
OPENVPN_SOURCE = openvpn-$(OPENVPN_VER).tar.xz
OPENVPN_URL    = http://build.openvpn.net/downloads/releases

$(ARCHIVE)/$(OPENVPN_SOURCE):
	$(DOWNLOAD) $(OPENVPN_URL)/$(OPENVPN_SOURCE)

OPENVPN_DEPS   = lzo openssl

openvpn: $(OPENVPN_DEPS) $(ARCHIVE)/$(OPENVPN_SOURCE) | $(TARGET_DIR)
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

OPENSSH_VER    = 8.1p1
OPENSSH_TMP    = openssh-$(OPENSSH_VER)
OPENSSH_SOURCE = openssh-$(OPENSSH_VER).tar.gz
OPENSSH_URL    = https://artfiles.org/openbsd/OpenSSH/portable

$(ARCHIVE)/$(OPENSSH_SOURCE):
	$(DOWNLOAD) $(OPENSSH_URL)/$(OPENSSH_SOURCE)

OPENSSH_DEPS   = openssl zlib

openssh: $(OPENSSH_DEPS) $(ARCHIVE)/$(OPENSSH_SOURCE) | $(TARGET_DIR)
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

TZDATA_VER    = 2019b
TZDATA_TMP    = tzdata$(TZDATA_VER)
TZDATA_SOURCE = tzdata$(TZDATA_VER).tar.gz
TZDATA_URL    = ftp://ftp.iana.org/tz/releases

$(ARCHIVE)/$(TZDATA_SOURCE):
	$(DOWNLOAD) $(TZDATA_URL)/$(TZDATA_SOURCE)

TZDATA_DEPS   = $(HOST_ZIC)

TZDATA_ZONELIST = \
	africa antarctica asia australasia europe northamerica \
	southamerica pacificnew etcetera backward

ETC_LOCALTIME = $(if $(filter $(PERSISTENT_VAR_PARTITION), yes),/var/etc/localtime,/etc/localtime)

tzdata: $(TZDATA_DEPS) $(ARCHIVE)/$(TZDATA_SOURCE) | $(TARGET_DIR)
	$(REMOVE)/$(TZDATA_TMP)
	$(MKDIR)/$(TZDATA_TMP)
	$(CHDIR)/$(TZDATA_TMP); \
		tar -xf $(ARCHIVE)/$(TZDATA_SOURCE); \
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
		mkdir -p $(TARGET_SHARE_DIR); \
		rm -rf $(TARGET_SHARE_DIR)/zoneinfo; \
		mv zoneinfo/ $(TARGET_SHARE_DIR)/
	$(INSTALL_DATA) -D $(TARGET_FILES)/tzdata/timezone.xml $(TARGET_DIR)/etc/timezone.xml
	$(INSTALL_DATA) $(TARGET_SHARE_DIR)/zoneinfo/CET $(TARGET_DIR)$(ETC_LOCALTIME)
	$(REMOVE)/$(TZDATA_TMP)
	$(TOUCH)

# -----------------------------------------------------------------------------

MTD-UTILS_VER    = 2.0.2
MTD-UTILS_TMP    = mtd-utils-$(MTD-UTILS_VER)
MTD-UTILS_SOURCE = mtd-utils-$(MTD-UTILS_VER).tar.bz2
MTD-UTILS_URL    = ftp://ftp.infradead.org/pub/mtd-utils

$(ARCHIVE)/$(MTD-UTILS_SOURCE):
	$(DOWNLOAD) $(MTD-UTILS_URL)/$(MTD-UTILS_SOURCE)

MTD-UTILS_DEPS   = zlib lzo e2fsprogs

mtd-utils: $(MTD-UTILS_DEPS) $(ARCHIVE)/$(MTD-UTILS_SOURCE) | $(TARGET_DIR)
	$(REMOVE)/$(MTD-UTILS_TMP)
	$(UNTAR)/$(MTD-UTILS_SOURCE)
	$(CHDIR)/$(MTD-UTILS_TMP); \
		$(CONFIGURE) \
			--target=$(TARGET) \
			--prefix= \
			--mandir=$(remove-mandir) \
			--enable-silent-rules \
			--disable-tests \
			--without-xattr \
			; \
		$(MAKE)
ifeq ($(BOXSERIES), hd2)
	$(INSTALL_EXEC) -D $(BUILD_TMP)/$(MTD-UTILS_TMP)/nanddump $(TARGET_DIR)/sbin
	$(INSTALL_EXEC) -D $(BUILD_TMP)/$(MTD-UTILS_TMP)/nandtest $(TARGET_DIR)/sbin
	$(INSTALL_EXEC) -D $(BUILD_TMP)/$(MTD-UTILS_TMP)/nandwrite $(TARGET_DIR)/sbin
	$(INSTALL_EXEC) -D $(BUILD_TMP)/$(MTD-UTILS_TMP)/mtd_debug $(TARGET_DIR)/sbin
	$(INSTALL_EXEC) -D $(BUILD_TMP)/$(MTD-UTILS_TMP)/mkfs.jffs2 $(TARGET_DIR)/sbin
endif
	$(INSTALL_EXEC) -D $(BUILD_TMP)/$(MTD-UTILS_TMP)/flash_erase $(TARGET_DIR)/sbin
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

iperf: $(ARCHIVE)/$(IPERF_SOURCE) | $(TARGET_DIR)
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

PARTED_PATCH  = parted-device-mapper.patch
PARTED_PATCH += parted-sysmacros.patch
PARTED_PATCH += parted-iconv.patch

PARTED_DEPS   = e2fsprogs

parted: $(PARTED_DEPS) $(ARCHIVE)/$(PARTED_SOURCE) | $(TARGET_DIR)
	$(REMOVE)/$(PARTED_TMP)
	$(UNTAR)/$(PARTED_SOURCE)
	$(CHDIR)/$(PARTED_TMP); \
		$(call apply_patches, $(PARTED_PATCH)); \
		autoreconf -fi; \
		$(CONFIGURE) \
			--target=$(TARGET) \
			--prefix= \
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

HDPARM_VER    = 9.58
HDPARM_TMP    = hdparm-$(HDPARM_VER)
HDPARM_SOURCE = hdparm-$(HDPARM_VER).tar.gz
HDPARM_URL    = https://sourceforge.net/projects/hdparm/files/hdparm

$(ARCHIVE)/$(HDPARM_SOURCE):
	$(DOWNLOAD) $(HDPARM_URL)/$(HDPARM_SOURCE)

hdparm: $(ARCHIVE)/$(HDPARM_SOURCE) | $(TARGET_DIR)
	$(REMOVE)/$(HDPARM_TMP)
	$(UNTAR)/$(HDPARM_SOURCE)
	$(CHDIR)/$(HDPARM_TMP); \
		$(BUILD_ENV) \
		$(MAKE); \
		$(INSTALL_EXEC) -D hdparm $(TARGET_DIR)/sbin/hdparm
	$(REMOVE)/$(HDPARM_TMP)
	$(TOUCH)

# -----------------------------------------------------------------------------

HD-IDLE_VER    = 1.05
HD-IDLE_TMP    = hd-idle
HD-IDLE_SOURCE = hd-idle-$(HD-IDLE_VER).tgz
HD-IDLE_URL    = https://sourceforge.net/projects/hd-idle/files

$(ARCHIVE)/$(HD-IDLE_SOURCE):
	$(DOWNLOAD) $(HD-IDLE_URL)/$(HD-IDLE_SOURCE)

hd-idle: $(ARCHIVE)/$(HD-IDLE_SOURCE) | $(TARGET_DIR)
	$(REMOVE)/$(HD-IDLE_TMP)
	$(UNTAR)/$(HD-IDLE_SOURCE)
	$(CHDIR)/$(HD-IDLE_TMP); \
		$(BUILD_ENV) \
		$(MAKE); \
		$(INSTALL_EXEC) -D hd-idle $(TARGET_DIR)/sbin/hd-idle
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

coreutils: $(ARCHIVE)/$(COREUTILS_SOURCE) | $(TARGET_DIR)
	$(REMOVE)/$(COREUTILS_TMP)
	$(UNTAR)/$(COREUTILS_SOURCE)
	$(CHDIR)/$(COREUTILS_TMP); \
		$(call apply_patches, $(COREUTILS_PATCH)); \
		autoreconf -fi; \
		$(CONFIGURE) \
			--target=$(TARGET) \
			--prefix= \
			--bindir=/bin.$(@F) \
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
		$(INSTALL_EXEC) $(TARGET_DIR)/bin.$(@F)/$$bin $(TARGET_DIR)/bin/$$bin; \
	done
	$(REMOVE)/$(COREUTILS_TMP) \
		$(TARGET_DIR)/bin.$(@F)
	$(TOUCH)

# -----------------------------------------------------------------------------

LESS_VER    = 530
LESS_TMP    = less-$(LESS_VER)
LESS_SOURCE = less-$(LESS_VER).tar.gz
LESS_URL    = http://www.greenwoodsoftware.com/less

$(ARCHIVE)/$(LESS_SOURCE):
	$(DOWNLOAD) $(LESS_URL)/$(LESS_SOURCE)

LESS_DEPS   = ncurses

less: $(LESS_DEPS) $(ARCHIVE)/$(LESS_SOURCE) | $(TARGET_DIR)
	$(REMOVE)/$(LESS_TMP)
	$(UNTAR)/$(LESS_SOURCE)
	$(CHDIR)/$(LESS_TMP); \
		$(CONFIGURE) \
			--target=$(TARGET) \
			--prefix= \
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

NTP_DEPS   = openssl

ntp: $(NTP_DEPS) $(ARCHIVE)/$(NTP_SOURCE) | $(TARGET_DIR)
	$(REMOVE)/$(NTP_TMP)
	$(UNTAR)/$(NTP_SOURCE)
	$(CHDIR)/$(NTP_TMP); \
		$(call apply_patches, $(NTP_PATCH)); \
		$(CONFIGURE) \
			--target=$(TARGET) \
			--prefix= \
			--disable-debugging \
			--with-shared \
			--with-crypto \
			--with-yielding-select=yes \
			--without-ntpsnmpd \
			; \
		$(MAKE); \
		$(INSTALL_EXEC) -D ntpdate/ntpdate $(TARGET_DIR)/sbin/ntpdate
	$(INSTALL_EXEC) -D $(TARGET_FILES)/scripts/ntpdate.init $(TARGET_DIR)/etc/init.d/ntpdate
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

DJMOUNT_DEPS   = libfuse

djmount: $(DJMOUNT_DEPS) $(ARCHIVE)/$(DJMOUNT_SOURCE) | $(TARGET_DIR)
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
	$(INSTALL_EXEC) -D $(TARGET_FILES)/scripts/djmount.init $(TARGET_DIR)/etc/init.d/djmount
	$(UPDATE-RC.D) djmount defaults 75 25
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
USHARE_PATCH += ushare-disable-iconv-check.patch

USHARE_DEPS   = libupnp

ushare: $(USHARE_DEPS) $(ARCHIVE)/$(USHARE_SOURCE)| $(TARGET_DIR)
	$(REMOVE)/$(USHARE_TMP)
	$(UNTAR)/$(USHARE_SOURCE)
	$(CHDIR)/$(USHARE_TMP); \
		$(call apply_patches, $(USHARE_PATCH)); \
		$(BUILD_ENV) \
		./configure \
			--prefix= \
			--disable-dlna \
			--disable-nls \
			--cross-compile \
			--cross-prefix=$(TARGET_CROSS) \
			; \
		sed -i config.h -e 's@SYSCONFDIR.*@SYSCONFDIR "/etc"@'; \
		sed -i config.h -e 's@LOCALEDIR.*@LOCALEDIR "/share"@'; \
		ln -sf ../config.h src/; \
		$(MAKE); \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
	$(INSTALL_DATA) -D $(TARGET_FILES)/configs/ushare.conf $(TARGET_DIR)/etc/ushare.conf
	sed -i 's|%(BOXTYPE)|$(BOXTYPE)|; s|%(BOXMODEL)|$(BOXMODEL)|' $(TARGET_DIR)/etc/ushare.conf
	$(INSTALL_EXEC) -D $(TARGET_FILES)/scripts/ushare.init $(TARGET_DIR)/etc/init.d/ushare
	$(UPDATE-RC.D) ushare defaults 75 25
	$(REMOVE)/$(USHARE_TMP)
	$(TOUCH)

# -----------------------------------------------------------------------------

SMARTMONTOOLS_VER    = 6.6
SMARTMONTOOLS_TMP    = smartmontools-$(SMARTMONTOOLS_VER)
SMARTMONTOOLS_SOURCE = smartmontools-$(SMARTMONTOOLS_VER).tar.gz
SMARTMONTOOLS_URL    = https://sourceforge.net/projects/smartmontools/files/smartmontools/$(SMARTMONTOOLS_VER)

$(ARCHIVE)/$(SMARTMONTOOLS_SOURCE):
	$(DOWNLOAD) $(SMARTMONTOOLS_URL)/$(SMARTMONTOOLS_SOURCE)

smartmontools: $(ARCHIVE)/$(SMARTMONTOOLS_SOURCE) | $(TARGET_DIR)
	$(REMOVE)/$(SMARTMONTOOLS_TMP)
	$(UNTAR)/$(SMARTMONTOOLS_SOURCE)
	$(CHDIR)/$(SMARTMONTOOLS_TMP); \
		$(CONFIGURE) \
			--target=$(TARGET) \
			--prefix= \
			; \
		$(MAKE); \
		$(INSTALL_EXEC) -D smartctl $(TARGET_DIR)/sbin/smartctl
	$(REMOVE)/$(SMARTMONTOOLS_TMP)
	$(TOUCH)

# -----------------------------------------------------------------------------

INADYN_VER    = 2.4
INADYN_TMP    = inadyn-$(INADYN_VER)
INADYN_SOURCE = inadyn-$(INADYN_VER).tar.xz
INADYN_URL    = https://github.com/troglobit/inadyn/releases/download/v$(INADYN_VER)

$(ARCHIVE)/$(INADYN_SOURCE):
	$(DOWNLOAD) $(INADYN_URL)/$(INADYN_SOURCE)

INADYN_DEPS   = openssl confuse libite

inadyn: $(INADYN_DEPS) $(ARCHIVE)/$(INADYN_SOURCE) | $(TARGET_DIR)
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
	$(INSTALL_DATA) -D $(TARGET_FILES)/configs/inadyn.conf $(TARGET_DIR)/var/etc/inadyn.conf
	ln -sf /var/etc/inadyn.conf $(TARGET_DIR)/etc/inadyn.conf
	$(INSTALL_EXEC) -D $(TARGET_FILES)/scripts/inadyn.init $(TARGET_DIR)/etc/init.d/inadyn
	$(UPDATE-RC.D) inadyn defaults 75 25
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

VSFTPD_DEPS   = openssl

vsftpd: $(VSFTPD_DEPS) $(ARCHIVE)/$(VSFTPD_SOURCE) | $(TARGET_DIR)
	$(REMOVE)/$(VSFTPD_TMP)
	$(UNTAR)/$(VSFTPD_SOURCE)
	$(CHDIR)/$(VSFTPD_TMP); \
		$(call apply_patches, $(VSFTPD_PATCH)); \
		sed -i -e 's/.*VSF_BUILD_PAM/#undef VSF_BUILD_PAM/' builddefs.h; \
		sed -i -e 's/.*VSF_BUILD_SSL/#define VSF_BUILD_SSL/' builddefs.h; \
		$(MAKE) clean; \
		$(MAKE) $(BUILD_ENV) LIBS="-lcrypt -lcrypto -lssl"; \
		$(INSTALL_EXEC) -D vsftpd $(TARGET_DIR)/sbin/vsftpd
	mkdir -p $(TARGET_SHARE_DIR)/empty
	$(INSTALL_DATA) -D $(TARGET_FILES)/configs/vsftpd.conf $(TARGET_DIR)/etc/vsftpd.conf
	$(INSTALL_DATA) -D $(TARGET_FILES)/configs/vsftpd.chroot_list $(TARGET_DIR)/etc/vsftpd.chroot_list
	$(INSTALL_EXEC) -D $(TARGET_FILES)/scripts/vsftpd.init $(TARGET_DIR)/etc/init.d/vsftpd
	$(UPDATE-RC.D) vsftpd defaults 75 25
	$(REMOVE)/$(VSFTPD_TMP)
	$(TOUCH)

# -----------------------------------------------------------------------------

PROCPS-NG_VER    = 3.3.15
PROCPS-NG_TMP    = procps-ng-$(PROCPS-NG_VER)
PROCPS-NG_SOURCE = procps-ng-$(PROCPS-NG_VER).tar.xz
PROCPS-NG_URL    = http://sourceforge.net/projects/procps-ng/files/Production

$(ARCHIVE)/$(PROCPS-NG_SOURCE):
	$(DOWNLOAD) $(PROCPS-NG_URL)/$(PROCPS-NG_SOURCE)

PROCPS-NG_PATCH  = procps-ng-0001-Fix-out-of-tree-builds.patch
PROCPS-NG_PATCH += procps-ng-no-tests-docs.patch

PROCPS-NG_DEPS   = ncurses

PROCPS-NG_BIN    = ps top

procps-ng: $(PROCPS-NG_DEPS) $(ARCHIVE)/$(PROCPS-NG_SOURCE) | $(TARGET_DIR)
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
			--bindir=/bin.$(@F) \
			--sbindir=/sbin.$(@F) \
			--datarootdir=$(remove-datarootdir) \
			--without-systemd \
			; \
		$(MAKE); \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
	for bin in $(PROCPS-NG_BIN); do \
		rm -f $(TARGET_DIR)/bin/$$bin; \
		$(INSTALL_EXEC) $(TARGET_DIR)/bin.$(@F)/$$bin $(TARGET_DIR)/bin/$$bin; \
	done
	$(REWRITE_PKGCONF)/libprocps.pc
	$(REWRITE_LIBTOOL)/libprocps.la
	$(REMOVE)/$(PROCPS-NG_TMP) \
		$(TARGET_DIR)/bin.$(@F) \
		$(TARGET_DIR)/sbin.$(@F)
	$(TOUCH)

# -----------------------------------------------------------------------------

NANO_VER    = 4.3
NANO_TMP    = nano-$(NANO_VER)
NANO_SOURCE = nano-$(NANO_VER).tar.gz
NANO_URL    = https://www.nano-editor.org/dist/v$(basename $(NANO_VER))

$(ARCHIVE)/$(NANO_SOURCE):
	$(DOWNLOAD) $(NANO_URL)/$(NANO_SOURCE)

NANO_DEPS   = ncurses

nano: $(NANO_DEPS) $(ARCHIVE)/$(NANO_SOURCE) | $(TARGET_DIR)
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

MINICOM_DEPS   = ncurses

minicom: $(MINICOM_DEPS) $(ARCHIVE)/$(MINICOM_SOURCE) | $(TARGET_DIR)
	$(REMOVE)/$(MINICOM_TMP)
	$(UNTAR)/$(MINICOM_SOURCE)
	$(CHDIR)/$(MINICOM_TMP); \
		$(call apply_patches, $(MINICOM_PATCH)); \
		$(CONFIGURE) \
			--target=$(TARGET) \
			--prefix= \
			--disable-nls \
			; \
		$(MAKE); \
		$(INSTALL_EXEC) src/minicom $(TARGET_DIR)/bin
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

define BASH_ADD_TO_SHELLS
	grep -qsE '^/bin/bash$$' $(TARGET_DIR)/etc/shells \
		|| echo "/bin/bash" >> $(TARGET_DIR)/etc/shells
endef

bash: $(ARCHIVE)/$(BASH_SOURCE) | $(TARGET_DIR)
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
	-rm $(addprefix $(TARGET_LIB_DIR)/bash/, loadables.h Makefile.inc)
	$(BASH_ADD_TO_SHELLS)
	$(REMOVE)/$(BASH_TMP)
	$(TOUCH)


# -----------------------------------------------------------------------------

# for coolstream: formatting ext4 failes with newer versions then 1.43.8
E2FSPROGS_VER    = $(if $(filter $(BOXTYPE), coolstream),1.43.8,1.45.5)
E2FSPROGS_TMP    = e2fsprogs-$(E2FSPROGS_VER)
E2FSPROGS_SOURCE = e2fsprogs-$(E2FSPROGS_VER).tar.gz
E2FSPROGS_URL    = https://sourceforge.net/projects/e2fsprogs/files/e2fsprogs/v$(E2FSPROGS_VER)

$(ARCHIVE)/$(E2FSPROGS_SOURCE):
	$(DOWNLOAD) $(E2FSPROGS_URL)/$(E2FSPROGS_SOURCE)

e2fsprogs: $(ARCHIVE)/$(E2FSPROGS_SOURCE) | $(TARGET_DIR)
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

ntfs-3g: $(ARCHIVE)/$(NTFS-3G_SOURCE) | $(TARGET_DIR)
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
	ln -sf /bin/ntfs-3g $(TARGET_DIR)/sbin/mount.ntfs
	$(REMOVE)/$(NTFS-3G_TMP)
	$(TOUCH)

# -----------------------------------------------------------------------------

AUTOFS_VER    = 5.1.6
AUTOFS_TMP    = autofs-$(AUTOFS_VER)
AUTOFS_SOURCE = autofs-$(AUTOFS_VER).tar.xz
AUTOFS_URL    = https://www.kernel.org/pub/linux/daemons/autofs/v5

$(ARCHIVE)/$(AUTOFS_SOURCE):
	$(DOWNLOAD) $(AUTOFS_URL)/$(AUTOFS_SOURCE)

# cd $(PATCHES)\autofs
# wget -N https://mirrors.edge.kernel.org/pub/linux/daemons/autofs/v5/patches-5.1.6/patch_order_5.1.5
# for p in $(cat patch_order_5.1.5); do test -f $p || wget https://mirrors.edge.kernel.org/pub/linux/daemons/autofs/v5/patches-5.1.6/$p; done

AUTOFS_PATCH  = force-STRIP-to-emtpy.patch
#AUTOFS_PATCH += $(shell cat $(PATCHES)/autofs/patch_order_$(AUTOFS_VER))

AUTOFS_DEPS   = libtirpc

autofs: $(AUTOFS_DEPS) $(ARCHIVE)/$(AUTOFS_SOURCE) | $(TARGET_DIR)
	$(REMOVE)/$(AUTOFS_TMP)
	$(UNTAR)/$(AUTOFS_SOURCE)
	$(CHDIR)/$(AUTOFS_TMP); \
		$(call apply_patches, $(addprefix $(@F)/,$(AUTOFS_PATCH))); \
		sed -i "s|nfs/nfs.h|linux/nfs.h|" include/rpc_subs.h; \
		export ac_cv_linux_procfs=yes; \
		export ac_cv_path_KRB5_CONFIG=no; \
		export ac_cv_path_MODPROBE=/sbin/modprobe; \
		export ac_cv_path_RANLIB=$(TARGET_RANLIB); \
		autoreconf -fi; \
		$(CONFIGURE) \
			--prefix= \
			--datarootdir=$(remove-datarootdir) \
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
	$(REMOVE)/$(AUTOFS_TMP)
	$(TOUCH)

# -----------------------------------------------------------------------------

SAMBA_TARGET = $(if $(filter $(BOXSERIES), hd1), samba33, samba36)

samba: $(SAMBA_TARGET)
	$(TOUCH)

# -----------------------------------------------------------------------------

SAMBA33_VER    = 3.3.16
SAMBA33_TMP    = samba-$(SAMBA33_VER)
SAMBA33_SOURCE = samba-$(SAMBA33_VER).tar.gz
SAMBA33_URL    = https://download.samba.org/pub/samba

$(ARCHIVE)/$(SAMBA33_SOURCE):
	$(DOWNLOAD) $(SAMBA33_URL)/$(SAMBA33_SOURCE)

SAMBA33_PATCH  = samba33-build-only-what-we-need.patch
SAMBA33_PATCH += samba33-configure.in-make-getgrouplist_ok-test-cross-compile.patch

SAMBA33_DEPS   = zlib

samba33: $(SAMBA33_DEPS) $(ARCHIVE)/$(SAMBA33_SOURCE) | $(TARGET_DIR)
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
	$(INSTALL_DATA) $(TARGET_FILES)/configs/smb3.conf $(TARGET_DIR)/etc/samba/smb.conf
	$(INSTALL_EXEC) $(TARGET_FILES)/scripts/samba3.init $(TARGET_DIR)/etc/init.d/samba
	$(UPDATE-RC.D) samba defaults 75 25
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

SAMBA36_DEPS   = zlib

samba36: $(SAMBA36_DEPS) $(ARCHIVE)/$(SAMBA36_SOURCE) | $(TARGET_DIR)
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
	$(INSTALL_DATA) $(TARGET_FILES)/configs/smb3.conf $(TARGET_DIR)/etc/samba/smb.conf
	$(INSTALL_EXEC) $(TARGET_FILES)/scripts/samba3.init $(TARGET_DIR)/etc/init.d/samba
	$(UPDATE-RC.D) samba defaults 75 25
	rm -rf $(TARGET_DIR)/bin/testparm
	rm -rf $(TARGET_DIR)/bin/findsmb
	rm -rf $(TARGET_DIR)/bin/smbtar
	rm -rf $(TARGET_DIR)/bin/smbclient
	rm -rf $(TARGET_DIR)/bin/smbpasswd
	$(REMOVE)/$(SAMBA36_TMP)
	$(TOUCH)

# -----------------------------------------------------------------------------

DROPBEAR_VER    = 2019.78
DROPBEAR_TMP    = dropbear-$(DROPBEAR_VER)
DROPBEAR_SOURCE = dropbear-$(DROPBEAR_VER).tar.bz2
DROPBEAR_URL    = http://matt.ucc.asn.au/dropbear/releases

$(ARCHIVE)/$(DROPBEAR_SOURCE):
	$(DOWNLOAD) $(DROPBEAR_URL)/$(DROPBEAR_SOURCE)

DROPBEAR_DEPS   = zlib

dropbear: $(DROPBEAR_DEPS) $(ARCHIVE)/$(DROPBEAR_SOURCE) | $(TARGET_DIR)
	$(REMOVE)/$(DROPBEAR_TMP)
	$(UNTAR)/$(DROPBEAR_SOURCE)
	$(CHDIR)/$(DROPBEAR_TMP); \
		$(CONFIGURE) \
			--prefix= \
			--mandir=$(remove-mandir) \
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
		echo '#define DEFAULT_PATH "/sbin:/bin:/var/bin"' >> localoptions.h; \
		# remove /usr prefix; \
		sed -i 's|/usr/|/|g' default_options.h; \
		$(MAKE) PROGRAMS="dropbear dbclient dropbearkey scp" SCPPROGRESS=1; \
		$(MAKE) PROGRAMS="dropbear dbclient dropbearkey scp" install DESTDIR=$(TARGET_DIR)
	mkdir -p $(TARGET_DIR)/etc/dropbear
	$(INSTALL_EXEC) -D $(TARGET_FILES)/scripts/dropbear.init $(TARGET_DIR)/etc/init.d/dropbear
	$(UPDATE-RC.D) dropbear defaults 75 25
	$(REMOVE)/$(DROPBEAR_TMP)
	$(TOUCH)

# -----------------------------------------------------------------------------

SG3_UTILS_VER    = 1.44
SG3_UTILS_TMP    = sg3_utils-$(SG3_UTILS_VER)
SG3_UTILS_SOURCE = sg3_utils-$(SG3_UTILS_VER).tar.xz
SG3_UTILS_URL    = http://sg.danny.cz/sg/p

$(ARCHIVE)/$(SG3_UTILS_SOURCE):
	$(DOWNLOAD) $(SG3_UTILS_URL)/$(SG3_UTILS_SOURCE)

SG3_UTILS_BIN    = sg_start

sg3_utils: $(ARCHIVE)/$(SG3_UTILS_SOURCE) | $(TARGET_DIR)
	$(REMOVE)/$(SG3_UTILS_TMP)
	$(UNTAR)/$(SG3_UTILS_SOURCE)
	$(CHDIR)/$(SG3_UTILS_TMP); \
		$(CONFIGURE) \
			--prefix= \
			--bindir=/bin.$(@F) \
			--mandir=$(remove-mandir) \
			; \
		$(MAKE); \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
	for bin in $(SG3_UTILS_BIN); do \
		rm -f $(TARGET_DIR)/bin/$$bin; \
		$(INSTALL_EXEC) $(TARGET_DIR)/bin.$(@F)/$$bin $(TARGET_DIR)/bin/$$bin; \
	done
	$(REWRITE_LIBTOOL)/libsgutils2.la
	$(INSTALL_EXEC) -D $(TARGET_FILES)/scripts/sdX.init $(TARGET_DIR)/etc/init.d/sdX
	$(UPDATE-RC.D) sdX stop 97 0 6 .
	$(REMOVE)/$(SG3_UTILS_TMP) \
		$(TARGET_DIR)/bin.$(@F)
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

FBSHOT_DEPS   = libpng

fbshot: $(FBSHOT_DEPS) $(ARCHIVE)/$(FBSHOT_SOURCE) | $(TARGET_DIR)
	$(REMOVE)/$(FBSHOT_TMP)
	$(UNTAR)/$(FBSHOT_SOURCE)
	$(CHDIR)/$(FBSHOT_TMP); \
		$(call apply_patches, $(FBSHOT_PATCH)); \
		sed -i 's|	gcc |	$(TARGET_CC) $(TARGET_CFLAGS) $(TARGET_LDFLAGS) |' Makefile; \
		sed -i '/strip fbshot/d' Makefile; \
		$(MAKE) all; \
		$(INSTALL_EXEC) -D fbshot $(TARGET_DIR)/bin/fbshot
	$(REMOVE)/$(FBSHOT_TMP)
	$(TOUCH)

# -----------------------------------------------------------------------------

LCD4LINUX_VER    = git
LCD4LINUX_TMP    = lcd4linux.$(LCD4LINUX_VER)
LCD4LINUX_SOURCE = lcd4linux.$(LCD4LINUX_VER)
LCD4LINUX_URL    = https://github.com/TangoCash

LCD4LINUX_DEPS   = ncurses libgd2 libdpf

lcd4linux: $(LCD4LINUX_DEPS) | $(TARGET_DIR)
	$(REMOVE)/$(LCD4LINUX_TMP)
	$(GET-GIT-SOURCE) $(LCD4LINUX_URL)/$(LCD4LINUX_SOURCE) $(ARCHIVE)/$(LCD4LINUX_SOURCE)
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
	$(INSTALL_COPY) $(TARGET_FILES)/lcd4linux/* $(TARGET_DIR)/
	#make samsunglcd4linux
	$(REMOVE)/$(LCD4LINUX_TMP)
	$(TOUCH)

# -----------------------------------------------------------------------------

SAMSUNGLCD4LINUX_VER    = git
SAMSUNGLCD4LINUX_TMP    = samsunglcd4linux.$(LCD4LINUX_VER)
SAMSUNGLCD4LINUX_SOURCE = samsunglcd4linux.$(LCD4LINUX_VER)
SAMSUNGLCD4LINUX_URL    = https://github.com/horsti58

samsunglcd4linux: | $(TARGET_DIR)
	$(REMOVE)/$(SAMSUNGLCD4LINUX_TMP)
	$(GET-GIT-SOURCE) $(SAMSUNGLCD4LINUX_URL)/$(SAMSUNGLCD4LINUX_SOURCE) $(ARCHIVE)/$(SAMSUNGLCD4LINUX_SOURCE)
	$(CPDIR)/$(SAMSUNGLCD4LINUX_SOURCE)
	$(CHDIR)/$(SAMSUNGLCD4LINUX_TMP)/ni; \
		$(INSTALL) -m 0600 etc/lcd4linux.conf $(TARGET_DIR)/etc; \
		$(INSTALL_COPY) share/* $(TARGET_SHARE_DIR)
	$(REMOVE)/$(SAMSUNGLCD4LINUX_TMP)
	$(TOUCH)

# -----------------------------------------------------------------------------

WPA_SUPPLICANT_VER    = 0.7.3
WPA_SUPPLICANT_TMP    = wpa_supplicant-$(WPA_SUPPLICANT_VER)
WPA_SUPPLICANT_SOURCE = wpa_supplicant-$(WPA_SUPPLICANT_VER).tar.gz
WPA_SUPPLICANT_URL    = https://w1.fi/releases

$(ARCHIVE)/$(WPA_SUPPLICANT_SOURCE):
	$(DOWNLOAD) $(WPA_SUPPLICANT_URL)/$(WPA_SUPPLICANT_SOURCE)

WPA_SUPPLICANT_DEPS   = openssl

wpa_supplicant: $(WPA_SUPPLICANT_DEPS) $(ARCHIVE)/$(WPA_SUPPLICANT_SOURCE) | $(TARGET_DIR)
	$(REMOVE)/$(WPA_SUPPLICANT_TMP)
	$(UNTAR)/$(WPA_SUPPLICANT_SOURCE)
	$(CHDIR)/$(WPA_SUPPLICANT_TMP)/wpa_supplicant; \
		$(INSTALL_DATA) $(CONFIGS)/wpa_supplicant.config .config; \
		$(BUILD_ENV) \
		$(MAKE); \
		$(MAKE) install DESTDIR=$(TARGET_DIR) BINDIR=/sbin
	$(INSTALL_EXEC) -D $(TARGET_FILES)/scripts/pre-wlan0.sh $(TARGET_DIR)/etc/network/pre-wlan0.sh
	$(INSTALL_EXEC) -D $(TARGET_FILES)/scripts/post-wlan0.sh $(TARGET_DIR)/etc/network/post-wlan0.sh
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

XUPNPD_DEPS   = lua openssl

xupnpd: $(XUPNPD_DEPS) | $(TARGET_DIR)
	$(REMOVE)/$(XUPNPD_TMP)
	$(GET-GIT-SOURCE) $(XUPNPD_URL)/$(XUPNPD_SOURCE) $(ARCHIVE)/$(XUPNPD_SOURCE)
	$(CPDIR)/$(XUPNPD_SOURCE)
	$(CHDIR)/$(XUPNPD_TMP); \
		$(call apply_patches, $(XUPNPD_PATCH))
	$(CHDIR)/$(XUPNPD_TMP)/src; \
		$(BUILD_ENV) \
		$(MAKE) embedded TARGET=$(TARGET) CC=$(TARGET_CC) STRIP=$(TARGET_STRIP) LUAFLAGS="$(TARGET_LDFLAGS) -I$(TARGET_INCLUDE_DIR)"; \
		$(INSTALL_EXEC) -D xupnpd $(TARGET_BIN_DIR)/; \
		mkdir -p $(TARGET_SHARE_DIR)/xupnpd/config; \
		$(INSTALL_COPY) plugins profiles ui www *.lua $(TARGET_SHARE_DIR)/xupnpd/
	rm $(TARGET_SHARE_DIR)/xupnpd/plugins/staff/xupnpd_18plus.lua
	$(INSTALL_DATA) -D $(SOURCE_DIR)/$(NI-NEUTRINO-PLUGINS)/scripts-lua/xupnpd/xupnpd_18plus.lua $(TARGET_SHARE_DIR)/xupnpd/plugins/
	$(INSTALL_DATA) -D $(SOURCE_DIR)/$(NI-NEUTRINO-PLUGINS)/scripts-lua/xupnpd/xupnpd_youtube.lua $(TARGET_SHARE_DIR)/xupnpd/plugins/
	$(INSTALL_DATA) -D $(SOURCE_DIR)/$(NI-NEUTRINO-PLUGINS)/scripts-lua/xupnpd/xupnpd_coolstream.lua $(TARGET_SHARE_DIR)/xupnpd/plugins/
	$(INSTALL_DATA) -D $(SOURCE_DIR)/$(NI-NEUTRINO-PLUGINS)/scripts-lua/xupnpd/xupnpd_cczwei.lua $(TARGET_SHARE_DIR)/xupnpd/plugins/
	$(INSTALL_EXEC) -D $(TARGET_FILES)/scripts/xupnpd.init $(TARGET_DIR)/etc/init.d/xupnpd
	$(UPDATE-RC.D) xupnpd defaults 75 25
	$(INSTALL_COPY) $(TARGET_FILES)/xupnpd/* $(TARGET_DIR)/
	$(REMOVE)/$(XUPNPD_TMP)
	$(TOUCH)

# -----------------------------------------------------------------------------

DOSFSTOOLS_VER    = 4.1
DOSFSTOOLS_TMP    = dosfstools-$(DOSFSTOOLS_VER)
DOSFSTOOLS_SOURCE = dosfstools-$(DOSFSTOOLS_VER).tar.xz
DOSFSTOOLS_URL    = https://github.com/dosfstools/dosfstools/releases/download/v$(DOSFSTOOLS_VER)

$(ARCHIVE)/$(DOSFSTOOLS_SOURCE):
	$(DOWNLOAD) $(DOSFSTOOLS_URL)/$(DOSFSTOOLS_SOURCE)

DOSFSTOOLS_PATCH  = switch-to-AC_CHECK_LIB-for-iconv-library-linking.patch

DOSFSTOOLS_CFLAGS = $(TARGET_CFLAGS) -D_GNU_SOURCE -D_LARGEFILE_SOURCE -D_FILE_OFFSET_BITS=64 -fomit-frame-pointer

dosfstools: $(ARCHIVE)/$(DOSFSTOOLS_SOURCE) | $(TARGET_DIR)
	$(REMOVE)/$(DOSFSTOOLS_TMP)
	$(UNTAR)/$(DOSFSTOOLS_SOURCE)
	$(CHDIR)/$(DOSFSTOOLS_TMP); \
		$(call apply_patches, $(addprefix $(@F)/,$(DOSFSTOOLS_PATCH))); \
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

NFS-UTILS_DEPS   = rpcbind

NFS-UTILS_CONF   = $(if $(filter $(BOXSERIES), hd1),--disable-ipv6,--enable-ipv6)

nfs-utils: $(NFS-UTILS_DEPS) $(ARCHIVE)/$(NFS-UTILS_SOURCE) | $(TARGET_DIR)
	$(REMOVE)/$(NFS-UTILS_TMP)
	$(UNTAR)/$(NFS-UTILS_SOURCE)
	$(CHDIR)/$(NFS-UTILS_TMP); \
		$(call apply_patches, $(NFS-UTILS_PATCH)); \
		export knfsd_cv_bsd_signals=no; \
		autoreconf -fi; \
		$(CONFIGURE) \
			--target=$(TARGET) \
			--prefix= \
			--docdir=$(remove-docdir) \
			--mandir=$(remove-mandir) \
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
	chmod 0755 $(TARGET_DIR)/sbin/mount.nfs
	rm -rf $(TARGET_DIR)/sbin/mountstats
	rm -rf $(TARGET_DIR)/sbin/nfsiostat
	rm -rf $(TARGET_DIR)/sbin/osd_login
	rm -rf $(TARGET_DIR)/sbin/start-statd
	rm -rf $(TARGET_DIR)/sbin/mount.nfs*
	rm -rf $(TARGET_DIR)/sbin/umount.nfs*
	rm -rf $(TARGET_DIR)/sbin/showmount
	rm -rf $(TARGET_DIR)/sbin/rpcdebug
	$(INSTALL_EXEC) -D $(TARGET_FILES)/scripts/nfsd.init $(TARGET_DIR)/etc/init.d/nfsd
	$(UPDATE-RC.D) nfsd defaults 75 25
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

RPCBIND_DEPS   = libtirpc

rpcbind: $(RPCBIND_DEPS) $(ARCHIVE)/$(RPCBIND_SOURCE) | $(TARGET_DIR)
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

FUSE-EXFAT_VER    = 1.3.0
FUSE-EXFAT_TMP    = fuse-exfat-$(FUSE-EXFAT_VER)
FUSE-EXFAT_SOURCE = fuse-exfat-$(FUSE-EXFAT_VER).tar.gz
FUSE-EXFAT_URL    = https://github.com/relan/exfat/releases/download/v$(FUSE-EXFAT_VER)

$(ARCHIVE)/$(FUSE-EXFAT_SOURCE):
	$(DOWNLOAD) $(FUSE-EXFAT_URL)/$(FUSE-EXFAT_SOURCE)

FUSE-EXFAT_DEPS   = libfuse

fuse-exfat: $(FUSE-EXFAT_DEPS) $(ARCHIVE)/$(FUSE-EXFAT_SOURCE) | $(TARGET_DIR)
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

EXFAT-UTILS_VER    = 1.3.0
EXFAT-UTILS_TMP    = exfat-utils-$(EXFAT-UTILS_VER)
EXFAT-UTILS_SOURCE = exfat-utils-$(EXFAT-UTILS_VER).tar.gz
EXFAT-UTILS_URL    = https://github.com/relan/exfat/releases/download/v$(EXFAT-UTILS_VER)

$(ARCHIVE)/$(EXFAT-UTILS_SOURCE):
	$(DOWNLOAD) $(EXFAT-UTILS_URL)/$(EXFAT-UTILS_SOURCE)

EXFAT-UTILS_DEPS   = fuse-exfat

exfat-utils: $(EXFAT-UTILS_DEPS) $(ARCHIVE)/$(EXFAT-UTILS_SOURCE) | $(TARGET_DIR)
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

STREAMRIPPER_DEPS   = libvorbisidec libmad glib2

streamripper: $(STREAMRIPPER_DEPS) | $(TARGET_DIR)
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
	$(INSTALL_EXEC) $(TARGET_FILES)/scripts/streamripper.sh $(TARGET_DIR)/bin/
	$(REMOVE)/$(NI-STREAMRIPPER)
	$(TOUCH)

# -----------------------------------------------------------------------------

GETTEXT_VER    = 0.19.8.1
GETTEXT_TMP    = gettext-$(GETTEXT_VER)
GETTEXT_SOURCE = gettext-$(GETTEXT_VER).tar.xz
GETTEXT_URL    = ftp://ftp.gnu.org/gnu/gettext

$(ARCHIVE)/$(GETTEXT_SOURCE):
	$(DOWNLOAD) $(GETTEXT_URL)/$(GETTEXT_SOURCE)

gettext: $(ARCHIVE)/$(GETTEXT_SOURCE) | $(TARGET_DIR)
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

MC_DEPS   = glib2 ncurses

mc: $(MC_DEPS) $(ARCHIVE)/$(MC_SOURCE) | $(TARGET_DIR)
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

WGET_VER    = 1.20.3
WGET_TMP    = wget-$(WGET_VER)
WGET_SOURCE = wget-$(WGET_VER).tar.gz
WGET_URL    = https://ftp.gnu.org/gnu/wget

$(ARCHIVE)/$(WGET_SOURCE):
	$(DOWNLOAD) $(WGET_URL)/$(WGET_SOURCE)

WGET_PATCH  = set-check_cert-false-by-default.patch
WGET_PATCH += change_DEFAULT_LOGFILE.patch

WGET_DEPS   = openssl

WGET_CFLAGS = $(TARGET_CFLAGS) -DOPENSSL_NO_ENGINE

wget: $(WGET_DEPS) $(ARCHIVE)/$(WGET_SOURCE) | $(TARGET_DIR)
	$(REMOVE)/$(WGET_TMP)
	$(UNTAR)/$(WGET_SOURCE)
	$(CHDIR)/$(WGET_TMP); \
		$(call apply_patches, $(addprefix $(@F)/,$(WGET_PATCH))); \
		$(CONFIGURE) \
			--target=$(TARGET) \
			--prefix= \
			--datarootdir=$(remove-datarootdir) \
			--sysconfdir=$(remove-sysconfdir) \
			--with-gnu-ld \
			--with-ssl=openssl \
			--disable-debug \
			CFLAGS="$(WGET_CFLAGS)" \
			; \
		$(MAKE); \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
	$(REMOVE)/$(WGET_TMP)
	$(TOUCH)

# -----------------------------------------------------------------------------

ofgwrite: $(SOURCE_DIR)/$(NI-OFGWRITE) | $(TARGET_DIR)
	$(REMOVE)/$(NI-OFGWRITE)
	tar -C $(SOURCE_DIR) -cp $(NI-OFGWRITE) --exclude-vcs | tar -C $(BUILD_TMP) -x
	$(CHDIR)/$(NI-OFGWRITE); \
		$(BUILD_ENV) \
		$(MAKE)
	$(INSTALL_EXEC) $(BUILD_TMP)/$(NI-OFGWRITE)/ofgwrite_bin $(TARGET_DIR)/bin
	$(INSTALL_EXEC) $(BUILD_TMP)/$(NI-OFGWRITE)/ofgwrite_caller $(TARGET_DIR)/bin
	$(INSTALL_EXEC) $(BUILD_TMP)/$(NI-OFGWRITE)/ofgwrite $(TARGET_DIR)/bin
	$(REMOVE)/$(NI-OFGWRITE)
	$(TOUCH)

# -----------------------------------------------------------------------------

AIO-GRAB_VER    = git
AIO-GRAB_TMP    = aio-grab.$(AIO-GRAB_VER)
AIO-GRAB_SOURCE = aio-grab.$(AIO-GRAB_VER)
AIO-GRAB_URL    = https://github.com/oe-alliance

AIO-GRAB_DEPS   = zlib libpng libjpeg

aio-grab: $(AIO-GRAB_DEPS) | $(TARGET_DIR)
	$(REMOVE)/$(AIO-GRAB_TMP)
	$(GET-GIT-SOURCE) $(AIO-GRAB_URL)/$(AIO-GRAB_SOURCE) $(ARCHIVE)/$(AIO-GRAB_SOURCE)
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

dvbsnoop: | $(TARGET_DIR)
	$(REMOVE)/$(DVBSNOOP_TMP)
	$(GET-GIT-SOURCE) $(DVBSNOOP_URL)/$(DVBSNOOP_SOURCE) $(ARCHIVE)/$(DVBSNOOP_SOURCE)
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

ETHTOOL_VER    = 5.3
ETHTOOL_TMP    = ethtool-$(ETHTOOL_VER)
ETHTOOL_SOURCE = ethtool-$(ETHTOOL_VER).tar.xz
ETHTOOL_URL    = https://www.kernel.org/pub/software/network/ethtool

$(ARCHIVE)/$(ETHTOOL_SOURCE):
	$(DOWNLOAD) $(ETHTOOL_URL)/$(ETHTOOL_SOURCE)

ethtool: $(ARCHIVE)/$(ETHTOOL_SOURCE) | $(TARGET_DIR)
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

GPTFDISK_DEPS   = popt e2fsprogs

gptfdisk: $(GPTFDISK_DEPS) $(ARCHIVE)/$(GPTFDISK_SOURCE) | $(TARGET_DIR)
	$(REMOVE)/$(GPTFDISK_TMP)
	$(UNTAR)/$(GPTFDISK_SOURCE)
	$(CHDIR)/$(GPTFDISK_TMP); \
		$(call apply_patches, $(GPTFDISK_PATCH)); \
		sed -i 's|^CC=.*|CC=$(TARGET_CC)|' Makefile; \
		sed -i 's|^CXX=.*|CXX=$(TARGET_CXX)|' Makefile; \
		$(BUILD_ENV) \
		$(MAKE) sgdisk; \
		$(INSTALL_EXEC) -D sgdisk $(TARGET_DIR)/sbin/sgdisk
	$(REMOVE)/$(GPTFDISK_TMP)
	$(TOUCH)

# -----------------------------------------------------------------------------

RSYNC_VER    = 3.1.3
RSYNC_TMP    = rsync-$(RSYNC_VER)
RSYNC_SOURCE = rsync-$(RSYNC_VER).tar.gz
RSYNC_URL    = https://ftp.samba.org/pub/rsync

$(ARCHIVE)/$(RSYNC_SOURCE):
	$(DOWNLOAD) $(RSYNC_URL)/$(RSYNC_SOURCE)

RSYNC_DEPS   = zlib popt

rsync: $(RSYNC_DEPS) $(ARCHIVE)/$(RSYNC_SOURCE) | $(TARGET_DIR)
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

SYSVINIT_VER    = 2.96
SYSVINIT_TMP    = sysvinit-$(SYSVINIT_VER)
SYSVINIT_SOURCE = sysvinit-$(SYSVINIT_VER).tar.xz
SYSVINIT_URL    = http://download.savannah.nongnu.org/releases/sysvinit

$(ARCHIVE)/$(SYSVINIT_SOURCE):
	$(DOWNLOAD) $(SYSVINIT_URL)/$(SYSVINIT_SOURCE)

SYSVINIT_PATCH  = crypt-lib.patch
SYSVINIT_PATCH += change-INIT_FIFO.patch
ifeq ($(BOXSERIES), hd2)
  SYSVINIT_PATCH += remove-fstack-protector-strong.patch
endif

define SYSVINIT_INSTALL
	for sbin in halt init shutdown killall5; do \
		$(INSTALL_EXEC) -D $(BUILD_TMP)/$(SYSVINIT_TMP)/src/$$sbin $(TARGET_DIR)/sbin/$$sbin || exit 1; \
	done
	ln -sf /sbin/halt $(TARGET_DIR)/sbin/reboot
	ln -sf /sbin/halt $(TARGET_DIR)/sbin/poweroff
	ln -sf /sbin/killall5 $(TARGET_DIR)/sbin/pidof
endef

sysvinit: $(ARCHIVE)/$(SYSVINIT_SOURCE) | $(TARGET_DIR)
	$(REMOVE)/$(SYSVINIT_TMP)
	$(UNTAR)/$(SYSVINIT_SOURCE)
	$(CHDIR)/$(SYSVINIT_TMP); \
		$(call apply_patches, $(addprefix $(@F)/,$(SYSVINIT_PATCH))); \
		$(BUILD_ENV) \
		$(MAKE) -C src SULOGINLIBS=-lcrypt
	$(SYSVINIT_INSTALL)
	$(REMOVE)/$(SYSVINIT_TMP)
	$(TOUCH)

# -----------------------------------------------------------------------------

CA-BUNDLE_SOURCE = cacert.pem
CA-BUNDLE_URL    = https://curl.haxx.se/ca

$(ARCHIVE)/$(CA-BUNDLE_SOURCE):
	$(DOWNLOAD) $(CA-BUNDLE_URL)/$(CA-BUNDLE_SOURCE)

ca-bundle: $(ARCHIVE)/$(CA-BUNDLE_SOURCE) | $(TARGET_DIR)
	$(CD) $(ARCHIVE); \
		curl --remote-name --time-cond $(CA-BUNDLE_SOURCE) $(CA-BUNDLE_URL)/$(CA-BUNDLE_SOURCE) || true
	$(INSTALL_DATA) -D $(ARCHIVE)/$(CA-BUNDLE_SOURCE) $(TARGET_DIR)/$(CA-BUNDLE_DIR)/$(CA-BUNDLE)
	$(TOUCH)
