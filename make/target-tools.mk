#
# makefile to build system tools
#
# -----------------------------------------------------------------------------

#
# $(base_prefix) tools
#
# -----------------------------------------------------------------------------

BUSYBOX_VER    = 1.31.1
BUSYBOX_DIR    = busybox-$(BUSYBOX_VER)
BUSYBOX_SOURCE = busybox-$(BUSYBOX_VER).tar.bz2
BUSYBOX_SITE   = https://busybox.net/downloads

$(DL_DIR)/$(BUSYBOX_SOURCE):
	$(DOWNLOAD) $(BUSYBOX_SITE)/$(BUSYBOX_SOURCE)

BUSYBOX_DEPS = libtirpc

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
	$(TARGET_MAKE_OPTS) \
	CFLAGS_EXTRA="$(TARGET_CFLAGS)" \
	EXTRA_LDFLAGS="$(TARGET_LDFLAGS)" \
	CONFIG_PREFIX="$(TARGET_DIR)"

BUSYBOX_BUILD_CONFIG = $(BUILD_DIR)/$(BUSYBOX_DIR)/.config

define BUSYBOX_INSTALL_CONFIG
	$(INSTALL_DATA) $(PKG_FILES_DIR)/busybox-minimal.config $(BUSYBOX_BUILD_CONFIG)
	$(call KCONFIG_SET_OPT,CONFIG_PREFIX,"$(TARGET_DIR)",$(BUSYBOX_BUILD_CONFIG))
endef

ifeq ($(BOXSERIES),$(filter $(BOXSERIES),hd2 hd5x hd6x vusolo4k vuduo4k vuduo4kse vuultimo4k vuzero4k vuuno4k vuuno4kse vuduo))

  define BUSYBOX_SET_BLKDISCARD
	$(call KCONFIG_ENABLE_OPT,CONFIG_BLKDISCARD,$(BUSYBOX_BUILD_CONFIG))
  endef

  define BUSYBOX_SET_IPV6
	$(call KCONFIG_ENABLE_OPT,CONFIG_FEATURE_IPV6,$(BUSYBOX_BUILD_CONFIG))
	$(call KCONFIG_ENABLE_OPT,CONFIG_FEATURE_IFUPDOWN_IPV6,$(BUSYBOX_BUILD_CONFIG))
  endef

  ifeq ($(BOXSERIES),$(filter $(BOXSERIES),hd5x hd6x vusolo4k vuduo4k vuduo4kse vuultimo4k vuzero4k vuuno4k vuuno4kse vuduo))

    define BUSYBOX_SET_SWAP
	$(call KCONFIG_ENABLE_OPT,CONFIG_SWAPON,$(BUSYBOX_BUILD_CONFIG))
	$(call KCONFIG_ENABLE_OPT,CONFIG_SWAPOFF,$(BUSYBOX_BUILD_CONFIG))
    endef
    define BUSYBOX_INSTALL_SWAP
	$(INSTALL_EXEC) -D $(PKG_FILES_DIR)/swap.init $(TARGET_sysconfdir)/init.d/swap
	$(UPDATE-RC.D) swap stop 98 0 6 .
    endef

    define BUSYBOX_SET_HEXDUMP
	$(call KCONFIG_ENABLE_OPT,CONFIG_HEXDUMP,$(BUSYBOX_BUILD_CONFIG))
    endef

    define BUSYBOX_SET_PKILL
	$(call KCONFIG_ENABLE_OPT,CONFIG_PKILL,$(BUSYBOX_BUILD_CONFIG))
    endef

    define BUSYBOX_SET_FBSET
	$(call KCONFIG_ENABLE_OPT,CONFIG_FBSET,$(BUSYBOX_BUILD_CONFIG))
	$(call KCONFIG_ENABLE_OPT,CONFIG_FEATURE_FBSET_FANCY,$(BUSYBOX_BUILD_CONFIG))
	$(call KCONFIG_ENABLE_OPT,CONFIG_FEATURE_FBSET_READMODE,$(BUSYBOX_BUILD_CONFIG))
    endef
    define BUSYBOX_INSTALL_FBSET
	$(INSTALL_DATA) -D $(PKG_FILES_DIR)/fb.modes $(TARGET_sysconfdir)/fb.modes
    endef

    ifeq ($(BOXSERIES),$(filter $(BOXSERIES),vusolo4k vuduo4k vuduo4kse vuultimo4k vuzero4k vuuno4k vuuno4kse vuduo))

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
	$(BUSYBOX_SET_FBSET)
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

ifeq ($(PERSISTENT_VAR_PARTITION),yes)
  define BUSYBOX_INSTALL_LINK_RESOLV_CONF
	ln -sf /var/etc/resolv.conf $(TARGET_sysconfdir)/resolv.conf
  endef
endif

define BUSYBOX_INSTALL_FILES
	$(BUSYBOX_INSTALL_SWAP)
	$(BUSYBOX_INSTALL_FBSET)
	$(INSTALL_EXEC) -D $(PKG_FILES_DIR)/udhcpc-default.script $(TARGET_datadir)/udhcpc/default.script
	$(BUSYBOX_INSTALL_LINK_RESOLV_CONF)
	$(INSTALL_EXEC) -D $(PKG_FILES_DIR)/crond.init $(TARGET_sysconfdir)/init.d/crond
	$(UPDATE-RC.D) crond defaults 50
	$(INSTALL_EXEC) -D $(PKG_FILES_DIR)/inetd.init $(TARGET_sysconfdir)/init.d/inetd
	$(UPDATE-RC.D) inetd defaults 50
	$(INSTALL_DATA) -D $(PKG_FILES_DIR)/inetd.conf $(TARGET_sysconfdir)/inetd.conf
	$(INSTALL_EXEC) -D $(PKG_FILES_DIR)/mdev.init $(TARGET_sysconfdir)/init.d/mdev
	$(INSTALL_EXEC) -D $(PKG_FILES_DIR)/syslogd.init $(TARGET_sysconfdir)/init.d/syslogd
	$(UPDATE-RC.D) syslogd stop 98 0 6 .
endef

busybox: $(BUSYBOX_DEPS) $(DL_DIR)/$(BUSYBOX_SOURCE) | $(TARGET_DIR)
	$(REMOVE)/$(PKG_DIR)
	$(UNTAR)/$(PKG_SOURCE)
	$(CHDIR)/$(PKG_DIR); \
		$(APPLY_PATCHES); \
	$($(PKG)_INSTALL_CONFIG)
	$($(PKG)_MODIFY_CONFIG)
	$(CHDIR)/$(PKG_DIR); \
		$($(PKG)_MAKE_ENV) $(MAKE) $($(PKG)_MAKE_OPTS) busybox; \
		$($(PKG)_MAKE_ENV) $(MAKE) $($(PKG)_MAKE_OPTS) install-noclobber
	$($(PKG)_ADD_TO_SHELLS)
	$($(PKG)_INSTALL_FILES)
	$(REMOVE)/$(PKG_DIR)
	$(TOUCH)

# -----------------------------------------------------------------------------

BASH_VER    = 5.0
BASH_DIR    = bash-$(BASH_VER)
BASH_SOURCE = bash-$(BASH_VER).tar.gz
BASH_SITE   = $(GNU_MIRROR)/bash

$(DL_DIR)/$(BASH_SOURCE):
	$(DOWNLOAD) $(BASH_SITE)/$(BASH_SOURCE)

BASH_CONF_ENV += \
	bash_cv_getcwd_malloc=yes \
	bash_cv_job_control_missing=present \
	bash_cv_sys_named_pipes=present \
	bash_cv_func_sigsetjmp=present \
	bash_cv_printf_a_format=yes

BASH_CONF_OPTS = \
	--bindir=$(base_bindir) \
	--datarootdir=$(REMOVE_datarootdir) \
	--without-bash-malloc

define BASH_ADD_TO_SHELLS
	grep -qsE '^/bin/bash$$' $(TARGET_sysconfdir)/shells \
		|| echo "/bin/bash" >> $(TARGET_sysconfdir)/shells
endef

bash: $(DL_DIR)/$(BASH_SOURCE) | $(TARGET_DIR)
	$(REMOVE)/$(PKG_DIR)
	$(UNTAR)/$(PKG_SOURCE)
	$(CHDIR)/$(PKG_DIR); \
		$(call apply_patches,$(PKG_PATCHES_DIR),0); \
		$(CONFIGURE); \
		$(MAKE); \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
	-rm $(addprefix $(TARGET_libdir)/bash/, loadables.h Makefile.inc)
	-rm -f $(addprefix $(TARGET_base_bindir)/, bashbug)
	$(BASH_ADD_TO_SHELLS)
	$(REMOVE)/$(PKG_DIR)
	$(TOUCH)

# -----------------------------------------------------------------------------

SYSVINIT_VER    = 2.98
SYSVINIT_DIR    = sysvinit-$(SYSVINIT_VER)
SYSVINIT_SOURCE = sysvinit-$(SYSVINIT_VER).tar.xz
SYSVINIT_SITE   = http://download.savannah.nongnu.org/releases/sysvinit

$(DL_DIR)/$(SYSVINIT_SOURCE):
	$(DOWNLOAD) $(SYSVINIT_SITE)/$(SYSVINIT_SOURCE)

ifeq ($(BOXMODEL),$(filter $(BOXMODEL),vusolo4k vuduo4k vuduo4kse vuultimo4k vuzero4k vuuno4k vuuno4kse))
  define SYSVINIT_INSTALL_RCS
	$(INSTALL_EXEC) -D $(PKG_FILES_DIR)/rcS-vuplus $(TARGET_sysconfdir)/init.d/rcS
  endef
else
  define SYSVINIT_INSTALL_RCS
	$(INSTALL_EXEC) -D $(PKG_FILES_DIR)/rcS-$(BOXSERIES) $(TARGET_sysconfdir)/init.d/rcS
  endef
endif

define SYSVINIT_INSTALL_FILES
	$(INSTALL_DATA) -D $(PKG_FILES_DIR)/inittab $(TARGET_sysconfdir)/inittab
	$(INSTALL_DATA) -D $(PKG_FILES_DIR)/default-rcS $(TARGET_sysconfdir)/default/rcS
	$(INSTALL_EXEC) -D $(PKG_FILES_DIR)/rc $(TARGET_sysconfdir)/init.d/rc
	$(SYSVINIT_INSTALL_RCS)
	$(SED) "s|%(BOXMODEL)|$(BOXMODEL)|g" $(TARGET_sysconfdir)/init.d/rcS
	$(INSTALL_EXEC) -D $(PKG_FILES_DIR)/rcK $(TARGET_sysconfdir)/init.d/rcK
	$(INSTALL_EXEC) -D $(PKG_FILES_DIR)/service $(TARGET_sbindir)/service
	$(INSTALL_EXEC) -D support/scripts/update-rc.d $(TARGET_sbindir)/update-rc.d
endef

sysvinit: $(DL_DIR)/$(SYSVINIT_SOURCE) | $(TARGET_DIR)
	$(REMOVE)/$(PKG_DIR)
	$(UNTAR)/$(PKG_SOURCE)
	$(CHDIR)/$(PKG_DIR); \
		$(APPLY_PATCHES); \
		$(TARGET_CONFIGURE_ENV) \
		$(MAKE) -C src SULOGINLIBS=-lcrypt; \
		$(MAKE) install ROOT=$(TARGET_DIR) MANDIR=$(REMOVE_mandir)
	-rm $(addprefix $(TARGET_base_sbindir)/,bootlogd fstab-decode logsave telinit)
	-rm $(addprefix $(TARGET_bindir)/,last lastb mesg readbootlog utmpdump wall)
	$($(PKG)_INSTALL_FILES)
	$(REMOVE)/$(PKG_DIR)
	$(TOUCH)

# -----------------------------------------------------------------------------

COREUTILS_VER    = 8.30
COREUTILS_DIR    = coreutils-$(COREUTILS_VER)
COREUTILS_SOURCE = coreutils-$(COREUTILS_VER).tar.xz
COREUTILS_SITE   = $(GNU_MIRROR)/coreutils

$(DL_DIR)/$(COREUTILS_SOURCE):
	$(DOWNLOAD) $(COREUTILS_SITE)/$(COREUTILS_SOURCE)

COREUTILS_AUTORECONF = YES

COREUTILS_CONF_OPTS = \
	--prefix=$(base_prefix) \
	--exec_prefix=$(base_prefix) \
	--includedir=$(includedir) \
	--libdir=$(libdir) \
	--bindir=$(base_bindir).$(@F) \
	--libexecdir=$(REMOVE_libexecdir) \
	--datarootdir=$(REMOVE_datarootdir) \
	--enable-silent-rules \
	--disable-xattr \
	--disable-libcap \
	--disable-acl \
	--without-gmp \
	--without-selinux

COREUTILS_BINARIES = touch

coreutils: $(DL_DIR)/$(COREUTILS_SOURCE) | $(TARGET_DIR)
	$(REMOVE)/$(PKG_DIR)
	$(UNTAR)/$(PKG_SOURCE)
	$(CHDIR)/$(PKG_DIR); \
		$(APPLY_PATCHES); \
		$(CONFIGURE); \
		$(MAKE); \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
	for bin in $($(PKG)_BINARIES); do \
		rm -f $(TARGET_base_bindir)/$$bin; \
		$(INSTALL_EXEC) -D $(TARGET_base_bindir).$(@F)/$$bin $(TARGET_base_bindir)/$$bin; \
	done
	rm -r $(TARGET_base_bindir).$(@F)
	$(REMOVE)/$(PKG_DIR)
	$(TOUCH)

# -----------------------------------------------------------------------------

PROCPS_NG_VER    = 3.3.16
PROCPS_NG_DIR    = procps-ng-$(PROCPS_NG_VER)
PROCPS_NG_SOURCE = procps-ng-$(PROCPS_NG_VER).tar.xz
PROCPS_NG_SITE   = http://sourceforge.net/projects/procps-ng/files/Production

$(DL_DIR)/$(PROCPS_NG_SOURCE):
	$(DOWNLOAD) $(PROCPS_NG_SITE)/$(PROCPS_NG_SOURCE)

PROCPS_NG_DEPS = ncurses

PROCPS_NG_AUTORECONF = YES

PROCPS_NG_CONF_ENV = \
	ac_cv_func_malloc_0_nonnull=yes \
	ac_cv_func_realloc_0_nonnull=yes

PROCPS_NG_CONF_OPTS = \
	--prefix=$(base_prefix) \
	--exec_prefix=$(base_prefix) \
	--includedir=$(includedir) \
	--libdir=$(libdir) \
	--bindir=$(base_bindir).$(@F) \
	--sbindir=$(base_sbindir).$(@F) \
	--docdir=$(REMOVE_docdir) \
	--without-systemd

PROCPS_NG_BINARIES = ps top

procps-ng: $(PROCPS_NG_DEPS) $(DL_DIR)/$(PROCPS_NG_SOURCE) | $(TARGET_DIR)
	$(REMOVE)/$(PKG_DIR)
	$(UNTAR)/$(PKG_SOURCE)
	$(CHDIR)/$(PKG_DIR); \
		$(APPLY_PATCHES); \
		$(CONFIGURE); \
		$(MAKE); \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
	for bin in $($(PKG)_BINARIES); do \
		rm -f $(TARGET_base_bindir)/$$bin; \
		$(INSTALL_EXEC) -D $(TARGET_base_bindir).$(@F)/$$bin $(TARGET_base_bindir)/$$bin; \
	done
	rm -r $(TARGET_base_bindir).$(@F)
	rm -r $(TARGET_base_sbindir).$(@F)
	$(REWRITE_LIBTOOL)
	$(REMOVE)/$(PKG_DIR)
	$(TOUCH)

# -----------------------------------------------------------------------------

MTD_UTILS_VER    = 2.0.2
MTD_UTILS_DIR    = mtd-utils-$(MTD_UTILS_VER)
MTD_UTILS_SOURCE = mtd-utils-$(MTD_UTILS_VER).tar.bz2
MTD_UTILS_SITE   = ftp://ftp.infradead.org/pub/mtd-utils

$(DL_DIR)/$(MTD_UTILS_SOURCE):
	$(DOWNLOAD) $(MTD_UTILS_SITE)/$(MTD_UTILS_SOURCE)

MTD_UTILS_DEPS =

MTD_UTILS_CONF_OPTS = \
	--prefix=$(base_prefix) \
	--exec_prefix=$(base_prefix) \
	--includedir=$(includedir) \
	--libdir=$(libdir) \
	--sbindir=$(base_sbindir).$(@F) \
	--mandir=$(REMOVE_mandir) \
	--disable-tests \
	--without-zstd \
	--without-ubifs \
	--without-xattr

ifeq ($(BOXSERIES),hd2)
  MTD_UTILS_DEPS += zlib lzo
  MTD_UTILS_CONF_OPTS += --with-jffs
else
  MTD_UTILS_CONF_OPTS += --without-jffs
endif

MTD_UTILS_SBINARIES = flash_erase flash_eraseall
ifeq ($(BOXSERIES),hd2)
  MTD_UTILS_SBINARIES += nanddump nandtest nandwrite mkfs.jffs2
endif

mtd-utils: $(MTD_UTILS_DEPS) $(DL_DIR)/$(MTD_UTILS_SOURCE) | $(TARGET_DIR)
	$(REMOVE)/$(PKG_DIR)
	$(UNTAR)/$(PKG_SOURCE)
	$(CHDIR)/$(PKG_DIR); \
		$(CONFIGURE); \
		$(MAKE); \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
	for sbin in $($(PKG)_SBINARIES); do \
		rm -f $(TARGET_sbindir)/$$sbin; \
		$(INSTALL_EXEC) -D $(TARGET_base_sbindir).$(@F)/$$sbin $(TARGET_base_sbindir)/$$sbin; \
	done
	rm -r $(TARGET_base_sbindir).$(@F)
	$(REMOVE)/$(PKG_DIR)
	$(TOUCH)

# -----------------------------------------------------------------------------

DOSFSTOOLS_VER    = 4.1
DOSFSTOOLS_DIR    = dosfstools-$(DOSFSTOOLS_VER)
DOSFSTOOLS_SOURCE = dosfstools-$(DOSFSTOOLS_VER).tar.xz
DOSFSTOOLS_SITE   = https://github.com/dosfstools/dosfstools/releases/download/v$(DOSFSTOOLS_VER)

$(DL_DIR)/$(DOSFSTOOLS_SOURCE):
	$(DOWNLOAD) $(DOSFSTOOLS_SITE)/$(DOSFSTOOLS_SOURCE)

DOSFSTOOLS_CFLAGS = $(TARGET_CFLAGS) -D_GNU_SOURCE -D_LARGEFILE_SOURCE -D_FILE_OFFSET_BITS=64 -fomit-frame-pointer

DOSFSTOOLS_AUTORECONF = YES

DOSFSTOOLS_CONF_OPTS = \
	--prefix=$(base_prefix) \
	--exec_prefix=$(base_prefix) \
	--docdir=$(REMOVE_docdir) \
	--without-udev \
	--enable-compat-symlinks \
	CFLAGS="$(DOSFSTOOLS_CFLAGS)"

dosfstools: $(DL_DIR)/$(DOSFSTOOLS_SOURCE) | $(TARGET_DIR)
	$(REMOVE)/$(PKG_DIR)
	$(UNTAR)/$(PKG_SOURCE)
	$(CHDIR)/$(PKG_DIR); \
		$(APPLY_PATCHES); \
		$(CONFIGURE); \
		$(MAKE); \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
	$(REMOVE)/$(PKG_DIR)
	$(TOUCH)

# -----------------------------------------------------------------------------

NTFS_3G_VER    = 2017.3.23
NTFS_3G_DIR    = ntfs-3g_ntfsprogs-$(NTFS_3G_VER)
NTFS_3G_SOURCE = ntfs-3g_ntfsprogs-$(NTFS_3G_VER).tgz
NTFS_3G_SITE   = https://tuxera.com/opensource

$(DL_DIR)/$(NTFS_3G_SOURCE):
	$(DOWNLOAD) $(NTFS_3G_SITE)/$(NTFS_3G_SOURCE)

NTFS_3G_DEPS = libfuse

NTFS_3G_CONF_OPTS = \
	--prefix=$(base_prefix) \
	--exec_prefix=$(base_prefix) \
	--includedir=$(includedir) \
	--libdir=$(libdir) \
	--docdir=$(REMOVE_docdir) \
	--disable-ntfsprogs \
	--disable-ldconfig \
	--disable-library \
	--with-fuse=external

ntfs-3g: $(NTFS_3G_DEPS) $(DL_DIR)/$(NTFS_3G_SOURCE) | $(TARGET_DIR)
	$(REMOVE)/$(PKG_DIR)
	$(UNTAR)/$(PKG_SOURCE)
	$(CHDIR)/$(PKG_DIR); \
		$(APPLY_PATCHES); \
		$(CONFIGURE); \
		$(MAKE); \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
	-rm $(addprefix $(TARGET_base_bindir)/,lowntfs-3g ntfs-3g.probe)
	-rm $(addprefix $(TARGET_base_sbindir)/,mount.lowntfs-3g)
	ln -sf $(base_bindir)/ntfs-3g $(TARGET_base_sbindir)/mount.ntfs
	$(REMOVE)/$(PKG_DIR)
	$(TOUCH)

# -----------------------------------------------------------------------------

FUSE_EXFAT_VER    = 1.3.0
FUSE_EXFAT_DIR    = fuse-exfat-$(FUSE_EXFAT_VER)
FUSE_EXFAT_SOURCE = fuse-exfat-$(FUSE_EXFAT_VER).tar.gz
FUSE_EXFAT_SITE   = https://github.com/relan/exfat/releases/download/v$(FUSE_EXFAT_VER)

$(DL_DIR)/$(FUSE_EXFAT_SOURCE):
	$(DOWNLOAD) $(FUSE_EXFAT_SITE)/$(FUSE_EXFAT_SOURCE)

FUSE_EXFAT_DEPS = libfuse

FUSE_EXFAT_AUTORECONF = YES

FUSE_EXFAT_CONF_OPTS = \
	--prefix=$(base_prefix) \
	--exec_prefix=$(base_prefix) \
	--includedir=$(includedir) \
	--libdir=$(libdir) \
	--docdir=$(REMOVE_docdir)

fuse-exfat: $(FUSE_EXFAT_DEPS) $(DL_DIR)/$(FUSE_EXFAT_SOURCE) | $(TARGET_DIR)
	$(REMOVE)/$(PKG_DIR)
	$(UNTAR)/$(PKG_SOURCE)
	$(CHDIR)/$(PKG_DIR); \
		$(CONFIGURE); \
		$(MAKE); \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
	$(REMOVE)/$(PKG_DIR)
	$(TOUCH)

# -----------------------------------------------------------------------------

EXFAT_UTILS_VER    = 1.3.0
EXFAT_UTILS_DIR    = exfat-utils-$(EXFAT_UTILS_VER)
EXFAT_UTILS_SOURCE = exfat-utils-$(EXFAT_UTILS_VER).tar.gz
EXFAT_UTILS_SITE   = https://github.com/relan/exfat/releases/download/v$(EXFAT_UTILS_VER)

$(DL_DIR)/$(EXFAT_UTILS_SOURCE):
	$(DOWNLOAD) $(EXFAT_UTILS_SITE)/$(EXFAT_UTILS_SOURCE)

EXFAT_UTILS_DEPS = fuse-exfat

EXFAT_UTILS_AUTORECONF = YES

EXFAT_UTILS_CONF_OPTS = \
	--prefix=$(base_prefix) \
	--exec_prefix=$(base_prefix) \
	--includedir=$(includedir) \
	--libdir=$(libdir) \
	--docdir=$(REMOVE_docdir)

exfat-utils: $(EXFAT_UTILS_DEPS) $(DL_DIR)/$(EXFAT_UTILS_SOURCE) | $(TARGET_DIR)
	$(REMOVE)/$(PKG_DIR)
	$(UNTAR)/$(PKG_SOURCE)
	$(CHDIR)/$(PKG_DIR); \
		$(CONFIGURE); \
		$(MAKE); \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
	$(REMOVE)/$(PKG_DIR)
	$(TOUCH)

# -----------------------------------------------------------------------------

XFSPROGS_VER    = 5.8.0
XFSPROGS_DIR    = xfsprogs-$(XFSPROGS_VER)
XFSPROGS_SOURCE = xfsprogs-$(XFSPROGS_VER).tar.xz
XFSPROGS_SITE   = $(KERNEL_MIRROR)/linux/utils/fs/xfs/xfsprogs

$(DL_DIR)/$(XFSPROGS_SOURCE):
	$(DOWNLOAD) $(XFSPROGS_SITE)/$(XFSPROGS_SOURCE)

XFSPROGS_DEPS = util-linux

XFSPROGS_CONF_ENV = \
	ac_cv_header_aio_h=yes \
	ac_cv_lib_rt_lio_listio=yes \
	PLATFORM="linux"

XFSPROGS_CONF_OPTS = \
	--datarootdir=$(REMOVE_datarootdir) \
	--enable-lib64=no \
	--enable-gettext=no \
	--disable-libicu \
	INSTALL_USER=root \
	INSTALL_GROUP=root \
	--enable-static

xfsprogs: $(XFSPROGS_DEPS) $(DL_DIR)/$(XFSPROGS_SOURCE) | $(TARGET_DIR)
	$(REMOVE)/$(PKG_DIR)
	$(UNTAR)/$(PKG_SOURCE)
	$(CHDIR)/$(PKG_DIR); \
		$(APPLY_PATCHES); \
		$(CONFIGURE); \
		$(MAKE); \
		$(MAKE) install DIST_ROOT=$(TARGET_DIR)
	-rm -r $(addprefix $(TARGET_libdir)/,xfsprogs)
	$(REMOVE)/$(PKG_DIR)
	$(TOUCH)

# -----------------------------------------------------------------------------

# for coolstream: formatting ext4 failes with newer versions then 1.43.8
E2FSPROGS_VER    = $(if $(filter $(BOXTYPE),coolstream),1.43.8,1.45.6)
E2FSPROGS_DIR    = e2fsprogs-$(E2FSPROGS_VER)
E2FSPROGS_SOURCE = e2fsprogs-$(E2FSPROGS_VER).tar.gz
E2FSPROGS_SITE   = https://sourceforge.net/projects/e2fsprogs/files/e2fsprogs/v$(E2FSPROGS_VER)

$(DL_DIR)/$(E2FSPROGS_SOURCE):
	$(DOWNLOAD) $(E2FSPROGS_SITE)/$(E2FSPROGS_SOURCE)

#E2FSPROGS_DEPS = util-linux

E2FSPROGS_AUTORECONF = YES

#E2FSPROGS_CONF_ENV = \
#	ac_cv_path_LDCONFIG=true

E2FSPROGS_CONF_OPTS = \
	--with-root-prefix="$(base_prefix)" \
	--datarootdir=$(REMOVE_datarootdir) \
	--disable-backtrace \
	--disable-blkid-debug \
	--disable-bmap-stats \
	--disable-debugfs \
	--disable-defrag \
	--disable-e2initrd-helper \
	--disable-fuse2fs \
	--disable-imager \
	--disable-jbd-debug \
	--disable-mmp \
	--disable-nls \
	--disable-profile \
	--disable-rpath \
	--disable-tdb \
	--disable-testio-debug \
	--disable-uuidd \
	--enable-elf-shlibs \
	--enable-fsck \
	--enable-symlink-install \
	--enable-verbose-makecmds \
	--enable-symlink-build \
	--with-gnu-ld \
	--with-crond-dir=no

#	--disable-libblkid \
#	--disable-libuuid \
 
#	--without-libintl-prefix \
#	--without-libiconv-prefix \

e2fsprogs: $(E2FSPROGS_DEPS) $(DL_DIR)/$(E2FSPROGS_SOURCE) | $(TARGET_DIR)
	$(REMOVE)/$(PKG_DIR)
	$(UNTAR)/$(PKG_SOURCE)
	$(CHDIR)/$(PKG_DIR); \
		$(CONFIGURE); \
		$(MAKE); \
		$(MAKE1) install install-libs DESTDIR=$(TARGET_DIR)
	-rm $(addprefix $(TARGET_base_sbindir)/,dumpe2fs e2mmpstatus e2undo logsave)
	-rm $(addprefix $(TARGET_bindir)/,chattr compile_et lsattr mk_cmds uuidgen)
	-rm $(addprefix $(TARGET_sbindir)/,e2freefrag e4crypt filefrag)
	$(REMOVE)/$(PKG_DIR)
	$(TOUCH)

# -----------------------------------------------------------------------------

HDPARM_VER    = 9.60
HDPARM_DIR    = hdparm-$(HDPARM_VER)
HDPARM_SOURCE = hdparm-$(HDPARM_VER).tar.gz
HDPARM_SITE   = https://sourceforge.net/projects/hdparm/files/hdparm

$(DL_DIR)/$(HDPARM_SOURCE):
	$(DOWNLOAD) $(HDPARM_SITE)/$(HDPARM_SOURCE)

hdparm: $(DL_DIR)/$(HDPARM_SOURCE) | $(TARGET_DIR)
	$(REMOVE)/$(PKG_DIR)
	$(UNTAR)/$(PKG_SOURCE)
	$(CHDIR)/$(PKG_DIR); \
		$(APPLY_PATCHES); \
		$(TARGET_CONFIGURE_ENV) \
		$(MAKE); \
		$(MAKE) install DESTDIR=$(TARGET_DIR) mandir=$(REMOVE_mandir)
	$(REMOVE)/$(PKG_DIR)
	$(TOUCH)

# -----------------------------------------------------------------------------

F2FS_TOOLS_VER    = 1.14.0
F2FS_TOOLS_DIR    = f2fs-tools-$(F2FS_TOOLS_VER)
F2FS_TOOLS_SOURCE = f2fs-tools-$(F2FS_TOOLS_VER).tar.gz
F2FS_TOOLS_SITE   = https://git.kernel.org/pub/scm/linux/kernel/git/jaegeuk/f2fs-tools.git/snapshot

$(DL_DIR)/$(F2FS_TOOLS_SOURCE):
	$(DOWNLOAD) $(F2FS_TOOLS_SITE)/$(F2FS_TOOLS_SOURCE)

F2FS_TOOLS_DEPS = util-linux

F2FS_TOOLS_AUTORECONF = YES

F2FS_TOOLS_CONF_ENV = \
	ac_cv_file__git=no

F2FS_TOOLS_CONF_OPTS = \
	--prefix=$(base_prefix) \
	--exec_prefix=$(base_prefix) \
	--includedir=$(includedir) \
	--libdir=$(libdir) \
	--without-selinux

f2fs-tools: $(F2FS_TOOLS_DEPS) $(DL_DIR)/$(F2FS_TOOLS_SOURCE) | $(TARGET_DIR)
	$(REMOVE)/$(PKG_DIR)
	$(UNTAR)/$(PKG_SOURCE)
	$(CHDIR)/$(PKG_DIR); \
		$(CONFIGURE); \
		$(MAKE); \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
	-rm $(addprefix $(TARGET_base_sbindir)/,sg_write_buffer)
	$(REWRITE_LIBTOOL)
	$(REMOVE)/$(PKG_DIR)
	$(TOUCH)

# -----------------------------------------------------------------------------

UTIL_LINUX_VER    = 2.36.2
UTIL_LINUX_DIR    = util-linux-$(UTIL_LINUX_VER)
UTIL_LINUX_SOURCE = util-linux-$(UTIL_LINUX_VER).tar.xz
UTIL_LINUX_SITE   = $(KERNEL_MIRROR)/linux/utils/util-linux/v$(basename $(UTIL_LINUX_VER))

$(DL_DIR)/$(UTIL_LINUX_SOURCE):
	$(DOWNLOAD) $(UTIL_LINUX_SITE)/$(UTIL_LINUX_SOURCE)

UTIL_LINUX_DEPS = ncurses zlib

UTIL_LINUX_AUTORECONF = YES

UTIL_LINUX_CONF_OPTS = \
	--includedir=$(includedir) \
	--libdir=$(libdir) \
	--runstatedir=$(runstatedir) \
	--localedir=$(REMOVE_localedir) \
	--docdir=$(REMOVE_docdir) \
	--disable-gtk-doc \
	\
	--disable-all-programs \
	\
	--enable-libfdisk \
	--enable-libsmartcols \
	--enable-libuuid \
	--enable-libblkid \
	--enable-libmount \
	\
	--disable-makeinstall-chown \
	--disable-makeinstall-setuid \
	--disable-makeinstall-chown \
	\
	--without-audit \
	--without-cap-ng \
	--without-btrfs \
	--without-ncursesw \
	--without-python \
	--without-readline \
	--without-slang \
	--without-smack \
	--without-libmagic \
	--without-systemd \
	--without-systemdsystemunitdir \
	--without-tinfo \
	--without-udev \
	--without-utempter

util-linux: $(UTIL_LINUX_DEPS) $(DL_DIR)/$(UTIL_LINUX_SOURCE) | $(TARGET_DIR)
	$(REMOVE)/$(PKG_DIR)
	$(UNTAR)/$(PKG_SOURCE)
	$(CHDIR)/$(PKG_DIR); \
		$(CONFIGURE); \
		$(MAKE); \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
	$(REWRITE_LIBTOOL)
	$(REMOVE)/$(PKG_DIR)
	$(TOUCH)

# -----------------------------------------------------------------------------

#
# $(prefix) tools
#
# -----------------------------------------------------------------------------

OPENVPN_VER    = 2.5.0
OPENVPN_DIR    = openvpn-$(OPENVPN_VER)
OPENVPN_SOURCE = openvpn-$(OPENVPN_VER).tar.xz
OPENVPN_SITE   = http://build.openvpn.net/downloads/releases

$(DL_DIR)/$(OPENVPN_SOURCE):
	$(DOWNLOAD) $(OPENVPN_SITE)/$(OPENVPN_SOURCE)

OPENVPN_DEPS = lzo openssl

OPENVPN_CONF_ENV = \
	NETSTAT="/bin/netstat" \
	IFCONFIG="/sbin/ifconfig" \
	IPROUTE="/sbin/ip" \
	ROUTE="/sbin/route"

OPENVPN_CONF_OPTS = \
	--docdir=$(REMOVE_docdir) \
	--infodir=$(REMOVE_infodir) \
	--enable-shared \
	--disable-static \
	--enable-small \
	--enable-management \
	--disable-debug \
	--disable-selinux \
	--disable-plugins \
	--disable-pkcs11

openvpn: $(OPENVPN_DEPS) $(DL_DIR)/$(OPENVPN_SOURCE) | $(TARGET_DIR)
	$(REMOVE)/$(PKG_DIR)
	$(UNTAR)/$(PKG_SOURCE)
	$(CHDIR)/$(PKG_DIR); \
		$(CONFIGURE); \
		$(MAKE); \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
	$(REMOVE)/$(PKG_DIR)
	$(TOUCH)

# -----------------------------------------------------------------------------

OPENSSH_VER    = 8.4p1
OPENSSH_DIR    = openssh-$(OPENSSH_VER)
OPENSSH_SOURCE = openssh-$(OPENSSH_VER).tar.gz
OPENSSH_SITE   = https://artfiles.org/openbsd/OpenSSH/portable

$(DL_DIR)/$(OPENSSH_SOURCE):
	$(DOWNLOAD) $(OPENSSH_SITE)/$(OPENSSH_SOURCE)

OPENSSH_DEPS = openssl zlib

OPENSSH_CONF_ENV = \
	ac_cv_search_dlopen=no

OPENSSH_CONF_OPTS = \
	--docdir=$(REMOVE_docdir) \
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
	--disable-pututxline

openssh: $(OPENSSH_DEPS) $(DL_DIR)/$(OPENSSH_SOURCE) | $(TARGET_DIR)
	$(REMOVE)/$(PKG_DIR)
	$(UNTAR)/$(PKG_SOURCE)
	$(CHDIR)/$(PKG_DIR); \
		$($(PKG)_CONF_ENV) ./configure $(TARGET_CONFIGURE_OPTS); \
		$(MAKE); \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
	$(REMOVE)/$(PKG_DIR)
	$(TOUCH)

# -----------------------------------------------------------------------------

TZDATA_VER    = 2020f
TZDATA_DIR    = tzdata$(TZDATA_VER)
TZDATA_SOURCE = tzdata$(TZDATA_VER).tar.gz
TZDATA_SITE   = ftp://ftp.iana.org/tz/releases

$(DL_DIR)/$(TZDATA_SOURCE):
	$(DOWNLOAD) $(TZDATA_SITE)/$(TZDATA_SOURCE)

TZDATA_DEPS = host-zic

TZDATA_ZONELIST = \
	africa antarctica asia australasia europe northamerica \
	southamerica etcetera backward factory

TZDATA_LOCALTIME = CET

ETC_LOCALTIME = $(if $(filter $(PERSISTENT_VAR_PARTITION),yes),/var/etc/localtime,/etc/localtime)

tzdata: $(TZDATA_DEPS) $(DL_DIR)/$(TZDATA_SOURCE) | $(TARGET_DIR)
	$(REMOVE)/$(PKG_DIR)
	$(MKDIR)/$(PKG_DIR)
	$(CHDIR)/$(PKG_DIR); \
		tar -xf $(DL_DIR)/$(PKG_SOURCE); \
		unset ${!LC_*}; LANG=POSIX; LC_ALL=POSIX; export LANG LC_ALL; \
		$(HOST_ZIC) -b fat -d zoneinfo.tmp $(TZDATA_ZONELIST); \
		sed -n '/zone=/{s/.*zone="\(.*\)".*$$/\1/; p}' $(PKG_FILES_DIR)/timezone.xml | sort -u | \
		while read x; do \
			find zoneinfo.tmp -type f -name $$x | sort | \
			while read y; do \
				test -e $$y && $(INSTALL_DATA) -D $$y $(TARGET_datadir)/zoneinfo/$$x; \
			done; \
		done; \
	$(INSTALL_DATA) -D $(PKG_FILES_DIR)/timezone.xml $(TARGET_sysconfdir)/timezone.xml
	ln -sf $(datadir)/zoneinfo/$(TZDATA_LOCALTIME) $(TARGET_DIR)$(ETC_LOCALTIME)
  ifeq ($(PERSISTENT_VAR_PARTITION),yes)
	ln -sf $(ETC_LOCALTIME) $(TARGET_sysconfdir)/localtime
  endif
	echo "$(TZDATA_LOCALTIME)" > $(TARGET_sysconfdir)/timezone
	$(REMOVE)/$(PKG_DIR)
	$(TOUCH)

# -----------------------------------------------------------------------------

IPERF_VER    = 3.1.3
IPERF_DIR    = iperf-$(IPERF_VER)
IPERF_SOURCE = iperf-$(IPERF_VER)-source.tar.gz
IPERF_SITE   = https://iperf.fr/download/source

$(DL_DIR)/$(IPERF_SOURCE):
	$(DOWNLOAD) $(IPERF_SITE)/$(IPERF_SOURCE)

iperf: $(DL_DIR)/$(IPERF_SOURCE) | $(TARGET_DIR)
	$(REMOVE)/$(PKG_DIR)
	$(UNTAR)/$(PKG_SOURCE)
	$(CHDIR)/$(PKG_DIR); \
		$(APPLY_PATCHES); \
		$(CONFIGURE); \
		$(MAKE); \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
	$(REMOVE)/$(PKG_DIR)
	$(TOUCH)

# -----------------------------------------------------------------------------

PARTED_VER    = 3.2
PARTED_DIR    = parted-$(PARTED_VER)
PARTED_SOURCE = parted-$(PARTED_VER).tar.xz
PARTED_SITE   = $(GNU_MIRROR)/parted

$(DL_DIR)/$(PARTED_SOURCE):
	$(DOWNLOAD) $(PARTED_SITE)/$(PARTED_SOURCE)

PARTED_DEPS = util-linux

ifeq ($(BOXTYPE),$(filter $(BOXTYPE),armbox mipsbox))
  PARTED_DEPS += libiconv
endif

PARTED_AUTORECONF = YES

PARTED_CONF_OPTS = \
	--infodir=$(REMOVE_infodir) \
	--enable-shared \
	--disable-static \
	--disable-debug \
	--disable-pc98 \
	--disable-nls \
	--disable-device-mapper \
	--without-readline

parted: $(PARTED_DEPS) $(DL_DIR)/$(PARTED_SOURCE) | $(TARGET_DIR)
	$(REMOVE)/$(PKG_DIR)
	$(UNTAR)/$(PKG_SOURCE)
	$(CHDIR)/$(PKG_DIR); \
		$(APPLY_PATCHES); \
		$(CONFIGURE); \
		$(MAKE); \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
	$(REWRITE_LIBTOOL)
	$(REMOVE)/$(PKG_DIR)
	$(TOUCH)

# -----------------------------------------------------------------------------

HD_IDLE_VER    = 1.05
HD_IDLE_DIR    = hd-idle
HD_IDLE_SOURCE = hd-idle-$(HD_IDLE_VER).tgz
HD_IDLE_SITE   = https://sourceforge.net/projects/hd-idle/files

$(DL_DIR)/$(HD_IDLE_SOURCE):
	$(DOWNLOAD) $(HD_IDLE_SITE)/$(HD_IDLE_SOURCE)

hd-idle: $(DL_DIR)/$(HD_IDLE_SOURCE) | $(TARGET_DIR)
	$(REMOVE)/$(PKG_DIR)
	$(UNTAR)/$(PKG_SOURCE)
	$(CHDIR)/$(PKG_DIR); \
		$(TARGET_CONFIGURE_ENV) \
		$(MAKE); \
		$(INSTALL_EXEC) -D hd-idle $(TARGET_sbindir)/hd-idle
	$(REMOVE)/$(PKG_DIR)
	$(TOUCH)

# -----------------------------------------------------------------------------

LESS_VER    = 563
LESS_DIR    = less-$(LESS_VER)
LESS_SOURCE = less-$(LESS_VER).tar.gz
LESS_SITE   = $(GNU_MIRROR)/less

$(DL_DIR)/$(LESS_SOURCE):
	$(DOWNLOAD) $(LESS_SITE)/$(LESS_SOURCE)

LESS_DEPS = ncurses

less: $(LESS_DEPS) $(DL_DIR)/$(LESS_SOURCE) | $(TARGET_DIR)
	$(REMOVE)/$(PKG_DIR)
	$(UNTAR)/$(PKG_SOURCE)
	$(CHDIR)/$(PKG_DIR); \
		$(CONFIGURE); \
		$(MAKE); \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
	$(REMOVE)/$(PKG_DIR)
	$(TOUCH)

# -----------------------------------------------------------------------------

NTP_VER    = 4.2.8p15
NTP_DIR    = ntp-$(NTP_VER)
NTP_SOURCE = ntp-$(NTP_VER).tar.gz
NTP_SITE   = https://www.eecis.udel.edu/~ntp/ntp_spool/ntp4/ntp-$(basename $(NTP_VER))

$(DL_DIR)/$(NTP_SOURCE):
	$(DOWNLOAD) $(NTP_SITE)/$(NTP_SOURCE)

NTP_DEPS = openssl

NTP_CONF_OPTS = \
	--docdir=$(REMOVE_docdir) \
	--disable-debugging \
	--with-shared \
	--with-crypto \
	--with-yielding-select=yes \
	--without-ntpsnmpd

ntp: $(NTP_DEPS) $(DL_DIR)/$(NTP_SOURCE) | $(TARGET_DIR)
	$(REMOVE)/$(PKG_DIR)
	$(UNTAR)/$(PKG_SOURCE)
	$(CHDIR)/$(PKG_DIR); \
		$(APPLY_PATCHES); \
		$(CONFIGURE); \
		$(MAKE); \
		$(INSTALL_EXEC) -D ntpdate/ntpdate $(TARGET_sbindir)/ntpdate
	$(INSTALL_EXEC) -D $(PKG_FILES_DIR)/ntpdate.init $(TARGET_sysconfdir)/init.d/ntpdate
	$(REMOVE)/$(PKG_DIR)
	$(TOUCH)

# -----------------------------------------------------------------------------

DJMOUNT_VER    = 0.71
DJMOUNT_DIR    = djmount-$(DJMOUNT_VER)
DJMOUNT_SOURCE = djmount-$(DJMOUNT_VER).tar.gz
DJMOUNT_SITE   = https://sourceforge.net/projects/djmount/files/djmount/$(DJMOUNT_VER)

$(DL_DIR)/$(DJMOUNT_SOURCE):
	$(DOWNLOAD) $(DJMOUNT_SITE)/$(DJMOUNT_SOURCE)

DJMOUNT_DEPS = libfuse

DJMOUNT_AUTORECONF = YES

DJMOUNT_CONF_OPTS = \
	--with-fuse-prefix=$(TARGET_prefix) \
	--disable-debug

djmount: $(DJMOUNT_DEPS) $(DL_DIR)/$(DJMOUNT_SOURCE) | $(TARGET_DIR)
	$(REMOVE)/$(PKG_DIR)
	$(UNTAR)/$(PKG_SOURCE)
	$(CHDIR)/$(PKG_DIR); \
		$(APPLY_PATCHES); \
		touch libupnp/config.aux/config.rpath; \
		$(CONFIGURE); \
		$(MAKE1); \
		$(MAKE1) install DESTDIR=$(TARGET_DIR)
	$(INSTALL_EXEC) -D $(PKG_FILES_DIR)/djmount.init $(TARGET_sysconfdir)/init.d/djmount
	$(UPDATE-RC.D) djmount defaults 75 25
	$(REMOVE)/$(PKG_DIR)
	$(TOUCH)

# -----------------------------------------------------------------------------

USHARE_VER    = 1.1a
USHARE_DIR    = ushare-uShare_v$(USHARE_VER)
USHARE_SOURCE = uShare_v$(USHARE_VER).tar.gz
USHARE_SITE   = https://github.com/GeeXboX/ushare/archive

$(DL_DIR)/$(USHARE_SOURCE):
	$(DOWNLOAD) $(USHARE_SITE)/$(USHARE_SOURCE)

USHARE_DEPS = libupnp

USHARE_CONF_OPTS = \
	--prefix=$(prefix) \
	--sysconfdir=$(sysconfdir) \
	--disable-dlna \
	--disable-nls \
	--cross-compile \
	--cross-prefix=$(TARGET_CROSS)

ushare: $(USHARE_DEPS) $(DL_DIR)/$(USHARE_SOURCE) | $(TARGET_DIR)
	$(REMOVE)/$(PKG_DIR)
	$(UNTAR)/$(PKG_SOURCE)
	$(CHDIR)/$(PKG_DIR); \
		$(APPLY_PATCHES); \
		$(TARGET_CONFIGURE_ENV) ./configure $($(PKG)_CONF_OPTS); \
		ln -sf ../config.h src/; \
		$(MAKE); \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
	$(INSTALL_DATA) -D $(PKG_FILES_DIR)/ushare.conf $(TARGET_sysconfdir)/ushare.conf
	$(SED) 's|%(BOXTYPE)|$(BOXTYPE)|; s|%(BOXMODEL)|$(BOXMODEL)|' $(TARGET_sysconfdir)/ushare.conf
	$(INSTALL_EXEC) -D $(PKG_FILES_DIR)/ushare.init $(TARGET_sysconfdir)/init.d/ushare
	$(UPDATE-RC.D) ushare defaults 75 25
	$(REMOVE)/$(PKG_DIR)
	$(TOUCH)

# -----------------------------------------------------------------------------

SQLITE_VER    = 3330000
SQLITE_DIR    = sqlite-autoconf-$(SQLITE_VER)
SQLITE_SOURCE = sqlite-autoconf-$(SQLITE_VER).tar.gz
SQLITE_SITE   = http://www.sqlite.org/2020

$(DL_DIR)/$(SQLITE_SOURCE):
	$(DOWNLOAD) $(SQLITE_SITE)/$(SQLITE_SOURCE)

SQLITE_CONF_OPTS = \
	--bindir=$(REMOVE_bindir)

sqlite: $(DL_DIR)/$(SQLITE_SOURCE) | $(TARGET_DIR)
	$(REMOVE)/$(PKG_DIR)
	$(UNTAR)/$(PKG_SOURCE)
	$(CHDIR)/$(PKG_DIR); \
		$(CONFIGURE); \
		$(MAKE); \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
	$(REWRITE_LIBTOOL)
	$(REMOVE)/$(PKG_DIR)
	$(TOUCH)

# -----------------------------------------------------------------------------

MINIDLNA_VER    = 1.3.0
MINIDLNA_DIR    = minidlna-$(MINIDLNA_VER)
MINIDLNA_SOURCE = minidlna-$(MINIDLNA_VER).tar.gz
MINIDLNA_SITE   = https://sourceforge.net/projects/minidlna/files/minidlna/$(MINIDLNA_VER)

$(DL_DIR)/$(MINIDLNA_SOURCE):
	$(DOWNLOAD) $(MINIDLNA_SITE)/$(MINIDLNA_SOURCE)

MINIDLNA_DEPS = zlib sqlite libexif libjpeg-turbo libid3tag libogg libvorbis flac ffmpeg

MINIDLNA_AUTORECONF = YES

MINIDLNA_CONF_OPTS = \
	--localedir=$(REMOVE_localedir) \
	--with-log-path=/tmp/minidlna \
	--disable-static

minidlna: $(MINIDLNA_DEPS) $(DL_DIR)/$(MINIDLNA_SOURCE) | $(TARGET_DIR)
	$(REMOVE)/$(PKG_DIR)
	$(UNTAR)/$(PKG_SOURCE)
	$(CHDIR)/$(PKG_DIR); \
		$(CONFIGURE); \
		$(MAKE); \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
	$(INSTALL_DATA) -D $(PKG_BUILD_DIR)/minidlna.conf $(TARGET_sysconfdir)/minidlna.conf
	$(SED) 's|^media_dir=.*|media_dir=A,/media/sda1/music\nmedia_dir=V,/media/sda1/movies\nmedia_dir=P,/media/sda1/pictures|' $(TARGET_sysconfdir)/minidlna.conf
	$(SED) 's|^#user=.*|user=root|' $(TARGET_sysconfdir)/minidlna.conf
	$(SED) 's|^#friendly_name=.*|friendly_name=$(BOXTYPE)-$(BOXMODEL):ReadyMedia|' $(TARGET_sysconfdir)/minidlna.conf
	$(INSTALL_EXEC) -D $(PKG_FILES_DIR)/minidlnad.init $(TARGET_sysconfdir)/init.d/minidlnad
	$(UPDATE-RC.D) minidlnad defaults 75 25
	$(REMOVE)/$(PKG_DIR)
	$(TOUCH)

# -----------------------------------------------------------------------------

SMARTMONTOOLS_VER    = 7.1
SMARTMONTOOLS_DIR    = smartmontools-$(SMARTMONTOOLS_VER)
SMARTMONTOOLS_SOURCE = smartmontools-$(SMARTMONTOOLS_VER).tar.gz
SMARTMONTOOLS_SITE   = https://sourceforge.net/projects/smartmontools/files/smartmontools/$(SMARTMONTOOLS_VER)

$(DL_DIR)/$(SMARTMONTOOLS_SOURCE):
	$(DOWNLOAD) $(SMARTMONTOOLS_SITE)/$(SMARTMONTOOLS_SOURCE)

smartmontools: $(DL_DIR)/$(SMARTMONTOOLS_SOURCE) | $(TARGET_DIR)
	$(REMOVE)/$(PKG_DIR)
	$(UNTAR)/$(PKG_SOURCE)
	$(CHDIR)/$(PKG_DIR); \
		$(CONFIGURE); \
		$(MAKE); \
		$(INSTALL_EXEC) -D smartctl $(TARGET_sbindir)/smartctl
	$(REMOVE)/$(PKG_DIR)
	$(TOUCH)

# -----------------------------------------------------------------------------

INADYN_VER    = 2.6
INADYN_DIR    = inadyn-$(INADYN_VER)
INADYN_SOURCE = inadyn-$(INADYN_VER).tar.xz
INADYN_SITE   = https://github.com/troglobit/inadyn/releases/download/v$(INADYN_VER)

$(DL_DIR)/$(INADYN_SOURCE):
	$(DOWNLOAD) $(INADYN_SITE)/$(INADYN_SOURCE)

INADYN_DEPS = openssl confuse libite

INADYN_AUTORECONF = YES

INADYN_CONF_OPTS = \
	--docdir=$(REMOVE_docdir) \
	--enable-openssl

inadyn: $(INADYN_DEPS) $(DL_DIR)/$(INADYN_SOURCE) | $(TARGET_DIR)
	$(REMOVE)/$(INADYN_DIR)
	$(UNTAR)/$(INADYN_SOURCE)
	$(CHDIR)/$(INADYN_DIR); \
		$(CONFIGURE); \
		$(MAKE); \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
	$(INSTALL_DATA) -D $(PKG_FILES_DIR)/inadyn.conf $(TARGET_localstatedir)/etc/inadyn.conf
	ln -sf /var/etc/inadyn.conf $(TARGET_sysconfdir)/inadyn.conf
	$(INSTALL_EXEC) -D $(PKG_FILES_DIR)/inadyn.init $(TARGET_sysconfdir)/init.d/inadyn
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

VSFTPD_LIBS += -lcrypt $$($(PKG_CONFIG) --libs libssl libcrypto)

VSFTPD_DEPS = openssl

vsftpd: $(VSFTPD_DEPS) $(DL_DIR)/$(VSFTPD_SOURCE) | $(TARGET_DIR)
	$(REMOVE)/$(PKG_DIR)
	$(UNTAR)/$(PKG_SOURCE)
	$(CHDIR)/$(PKG_DIR); \
		$(APPLY_PATCHES); \
		$(SED) 's/.*VSF_BUILD_PAM/#undef VSF_BUILD_PAM/' builddefs.h; \
		$(SED) 's/.*VSF_BUILD_SSL/#define VSF_BUILD_SSL/' builddefs.h; \
		$(MAKE) clean; \
		$(MAKE) $(TARGET_CONFIGURE_ENV) LIBS="$($(PKG)_LIBS)"; \
		$(INSTALL_EXEC) -D vsftpd $(TARGET_sbindir)/vsftpd
	mkdir -p $(TARGET_datadir)/empty
	$(INSTALL_DATA) -D $(PKG_FILES_DIR)/vsftpd.conf $(TARGET_sysconfdir)/vsftpd.conf
	$(INSTALL_DATA) -D $(PKG_FILES_DIR)/vsftpd.chroot_list $(TARGET_sysconfdir)/vsftpd.chroot_list
	$(INSTALL_EXEC) -D $(PKG_FILES_DIR)/vsftpd.init $(TARGET_sysconfdir)/init.d/vsftpd
	$(UPDATE-RC.D) vsftpd defaults 75 25
	$(REMOVE)/$(PKG_DIR)
	$(TOUCH)

# -----------------------------------------------------------------------------

NANO_VER    = 5.4
NANO_DIR    = nano-$(NANO_VER)
NANO_SOURCE = nano-$(NANO_VER).tar.gz
NANO_SITE   = $(GNU_MIRROR)/nano

$(DL_DIR)/$(NANO_SOURCE):
	$(DOWNLOAD) $(NANO_SITE)/$(NANO_SOURCE)

NANO_DEPS = ncurses

NANO_CONF_ENV = \
	ac_cv_prog_NCURSESW_CONFIG=false

NANO_CONF_OPTS = \
	--datarootdir=$(REMOVE_datarootdir) \
	--disable-nls \
	--disable-libmagic \
	--enable-tiny \
	--without-slang \
	--with-wordbounds

nano: $(NANO_DEPS) $(DL_DIR)/$(NANO_SOURCE) | $(TARGET_DIR)
	$(REMOVE)/$(PKG_DIR)
	$(UNTAR)/$(PKG_SOURCE)
	$(CHDIR)/$(PKG_DIR); \
		$(CONFIGURE); \
		$(MAKE) CURSES_LIB="-lncurses"; \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
	$(INSTALL) -d $(TARGET_sysconfdir)/profile.d
	echo "export EDITOR=nano" > $(TARGET_sysconfdir)/profile.d/editor.sh
	$(REMOVE)/$(PKG_DIR)
	$(TOUCH)

# -----------------------------------------------------------------------------

MINICOM_VER    = 2.7.1
MINICOM_DIR    = minicom-$(MINICOM_VER)
MINICOM_SOURCE = minicom-$(MINICOM_VER).tar.gz
MINICOM_SITE   = http://fossies.org/linux/misc

$(DL_DIR)/$(MINICOM_SOURCE):
	$(DOWNLOAD) $(MINICOM_SITE)/$(MINICOM_SOURCE)

MINICOM_DEPS = ncurses

MINICOM_CONF_OPTS = \
	--disable-nls

minicom: $(MINICOM_DEPS) $(DL_DIR)/$(MINICOM_SOURCE) | $(TARGET_DIR)
	$(REMOVE)/$(PKG_DIR)
	$(UNTAR)/$(PKG_SOURCE)
	$(CHDIR)/$(PKG_DIR); \
		$(APPLY_PATCHES); \
		$(CONFIGURE); \
		$(MAKE); \
		$(INSTALL_EXEC) src/minicom $(TARGET_bindir)
	$(REMOVE)/$(PKG_DIR)
	$(TOUCH)

# -----------------------------------------------------------------------------

AUTOFS_VER    = 5.1.6
AUTOFS_DIR    = autofs-$(AUTOFS_VER)
AUTOFS_SOURCE = autofs-$(AUTOFS_VER).tar.xz
AUTOFS_SITE   = $(KERNEL_MIRROR)/linux/daemons/autofs/v5

$(DL_DIR)/$(AUTOFS_SOURCE):
	$(DOWNLOAD) $(AUTOFS_SITE)/$(AUTOFS_SOURCE)

# cd package/autofs/patches
# wget -N https://mirrors.edge.kernel.org/pub/linux/daemons/autofs/v5/patches-5.1.6/patch_order_5.1.5
# for p in $(cat patch_order_5.1.5); do test -f $p || wget https://mirrors.edge.kernel.org/pub/linux/daemons/autofs/v5/patches-5.1.6/$p; done

AUTOFS_DEPS = libtirpc

AUTOFS_AUTORECONF = YES

AUTOFS_CONF_ENV = \
	ac_cv_linux_procfs=yes \
	ac_cv_path_KRB5_CONFIG=no \
	ac_cv_path_MODPROBE=/sbin/modprobe \
	ac_cv_path_RANLIB=$(TARGET_RANLIB) \

AUTOFS_CONF_OPTS = \
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
	--with-flagdir=/var/run

AUTOFS_MAKE_OPTS = \
	SUBDIRS="lib daemon modules"

autofs: $(AUTOFS_DEPS) $(DL_DIR)/$(AUTOFS_SOURCE) | $(TARGET_DIR)
	$(REMOVE)/$(PKG_DIR)
	$(UNTAR)/$(PKG_SOURCE)
	$(CHDIR)/$(PKG_DIR); \
		$(APPLY_PATCHES); \
		$(SED) "s|nfs/nfs.h|linux/nfs.h|" include/rpc_subs.h; \
		$(CONFIGURE); \
		$(MAKE) $($(PKG)_MAKE_OPTS) DONTSTRIP=1; \
		$(MAKE) $($(PKG)_MAKE_OPTS) install DESTDIR=$(TARGET_DIR)
	$(INSTALL_COPY) $(PKG_FILES_DIR)-skel/* $(TARGET_DIR)/
	$(UPDATE-RC.D) autofs defaults 75 25
	$(REMOVE)/$(PKG_DIR)
	$(TOUCH)

# -----------------------------------------------------------------------------

samba: $(if $(filter $(BOXSERIES),hd1),samba33,samba36)
	$(TOUCH)

# -----------------------------------------------------------------------------

SAMBA33_VER    = 3.3.16
SAMBA33_DIR    = samba-$(SAMBA33_VER)
SAMBA33_SOURCE = samba-$(SAMBA33_VER).tar.gz
SAMBA33_SITE   = https://download.samba.org/pub/samba

$(DL_DIR)/$(SAMBA33_SOURCE):
	$(DOWNLOAD) $(SAMBA33_SITE)/$(SAMBA33_SOURCE)

SAMBA33_DEPS = zlib

SAMBA33_CONF_ENV = \
	CONFIG_SITE=$(PKG_FILES_DIR)/samba33-config.site

SAMBA33_CONF_OPTS = \
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
	--disable-swat

samba33: $(SAMBA33_DEPS) $(DL_DIR)/$(SAMBA33_SOURCE) | $(TARGET_DIR)
	$(REMOVE)/$(PKG_DIR)
	$(UNTAR)/$(PKG_SOURCE)
	$(CHDIR)/$(PKG_DIR); \
		$(APPLY_PATCHES); \
	$(CHDIR)/$(PKG_DIR)/source; \
		./autogen.sh; \
		$(CONFIGURE); \
		$(MAKE1) all; \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
	mkdir -p $(TARGET_localstatedir)/samba/locks
	$(INSTALL_DATA) -D $(PKG_FILES_DIR)/smb3.conf $(TARGET_sysconfdir)/samba/smb.conf
	$(INSTALL_EXEC) -D $(PKG_FILES_DIR)/samba3.init $(TARGET_sysconfdir)/init.d/samba
	$(UPDATE-RC.D) samba defaults 75 25
	rm -rf $(TARGET_bindir)/testparm
	rm -rf $(TARGET_bindir)/findsmb
	rm -rf $(TARGET_bindir)/smbtar
	rm -rf $(TARGET_bindir)/smbclient
	rm -rf $(TARGET_bindir)/smbpasswd
	$(REMOVE)/$(PKG_DIR)
	$(TOUCH)

# -----------------------------------------------------------------------------

SAMBA36_VER    = 3.6.25
SAMBA36_DIR    = samba-$(SAMBA36_VER)
SAMBA36_SOURCE = samba-$(SAMBA36_VER).tar.gz
SAMBA36_SITE   = https://download.samba.org/pub/samba/stable

$(DL_DIR)/$(SAMBA36_SOURCE):
	$(DOWNLOAD) $(SAMBA36_SITE)/$(SAMBA36_SOURCE)

SAMBA36_DEPS = zlib

SAMBA36_CONF_ENV = \
	CONFIG_SITE=$(PKG_FILES_DIR)/samba36-config.site

SAMBA36_CONF_OPTS = \
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

samba36: $(SAMBA36_DEPS) $(DL_DIR)/$(SAMBA36_SOURCE) | $(TARGET_DIR)
	$(REMOVE)/$(PKG_DIR)
	$(UNTAR)/$(PKG_SOURCE)
	$(CHDIR)/$(PKG_DIR); \
		$(APPLY_PATCHES); \
	$(CHDIR)/$(PKG_DIR)/source3; \
		./autogen.sh; \
		$(CONFIGURE); \
		$(MAKE); \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
	mkdir -p $(TARGET_localstatedir)/samba/locks
	$(INSTALL_DATA) -D $(PKG_FILES_DIR)/smb3.conf $(TARGET_sysconfdir)/samba/smb.conf
	$(INSTALL_EXEC) -D $(PKG_FILES_DIR)/samba3.init $(TARGET_sysconfdir)/init.d/samba
	$(UPDATE-RC.D) samba defaults 75 25
	rm -rf $(TARGET_bindir)/testparm
	rm -rf $(TARGET_bindir)/findsmb
	rm -rf $(TARGET_bindir)/smbtar
	rm -rf $(TARGET_bindir)/smbclient
	rm -rf $(TARGET_bindir)/smbpasswd
	$(REMOVE)/$(PKG_DIR)
	$(TOUCH)

# -----------------------------------------------------------------------------

DROPBEAR_VER    = 2019.78
DROPBEAR_DIR    = dropbear-$(DROPBEAR_VER)
DROPBEAR_SOURCE = dropbear-$(DROPBEAR_VER).tar.bz2
DROPBEAR_SITE   = http://matt.ucc.asn.au/dropbear/releases

$(DL_DIR)/$(DROPBEAR_SOURCE):
	$(DOWNLOAD) $(DROPBEAR_SITE)/$(DROPBEAR_SOURCE)

DROPBEAR_DEPS = zlib

DROPBEAR_CONF_OPTS = \
	--disable-lastlog \
	--disable-pututxline \
	--disable-wtmp \
	--disable-wtmpx \
	--disable-loginfunc \
	--disable-pam \
	--disable-harden \
	--enable-bundled-libtom

DROPBEAR_MAKE_OPTS = \
	PROGRAMS="dropbear dbclient dropbearkey scp"

dropbear: $(DROPBEAR_DEPS) $(DL_DIR)/$(DROPBEAR_SOURCE) | $(TARGET_DIR)
	$(REMOVE)/$(PKG_DIR)
	$(UNTAR)/$(PKG_SOURCE)
	$(CHDIR)/$(PKG_DIR); \
		$(CONFIGURE); \
		# Ensure that dropbear doesn't use crypt() when it's not available; \
		echo '#if !HAVE_CRYPT'				>> localoptions.h; \
		echo '#define DROPBEAR_SVR_PASSWORD_AUTH 0'	>> localoptions.h; \
		echo '#endif'					>> localoptions.h; \
		# disable SMALL_CODE define; \
		echo '#define DROPBEAR_SMALL_CODE 0'		>> localoptions.h; \
		# fix PATH define; \
		echo '#define DEFAULT_PATH "/sbin:/bin:/usr/sbin:/usr/bin:/var/bin"' >> localoptions.h; \
		$(MAKE) $($(PKG)_MAKE_OPTS) SCPPROGRESS=1; \
		$(MAKE) $($(PKG)_MAKE_OPTS) install DESTDIR=$(TARGET_DIR)
	mkdir -p $(TARGET_sysconfdir)/dropbear
	$(INSTALL_EXEC) -D $(PKG_FILES_DIR)/dropbear.init $(TARGET_sysconfdir)/init.d/dropbear
	$(UPDATE-RC.D) dropbear defaults 75 25
	$(REMOVE)/$(PKG_DIR)
	$(TOUCH)

# -----------------------------------------------------------------------------

SG3_UTILS_VER    = 1.45
SG3_UTILS_DIR    = sg3_utils-$(SG3_UTILS_VER)
SG3_UTILS_SOURCE = sg3_utils-$(SG3_UTILS_VER).tar.xz
SG3_UTILS_SITE   = http://sg.danny.cz/sg/p

$(DL_DIR)/$(SG3_UTILS_SOURCE):
	$(DOWNLOAD) $(SG3_UTILS_SITE)/$(SG3_UTILS_SOURCE)

SG3_UTILS_CONF_OPTS = \
	--bindir=$(bindir).$(@F)

SG3_UTILS_BINARIES = sg_start

sg3_utils: $(DL_DIR)/$(SG3_UTILS_SOURCE) | $(TARGET_DIR)
	$(REMOVE)/$(PKG_DIR)
	$(UNTAR)/$(PKG_SOURCE)
	$(CHDIR)/$(PKG_DIR); \
		$(CONFIGURE); \
		$(MAKE); \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
	for bin in $($(PKG)_BINARIES); do \
		rm -f $(TARGET_bindir)/$$bin; \
		$(INSTALL_EXEC) -D $(TARGET_bindir).$(@F)/$$bin $(TARGET_bindir)/$$bin; \
	done
	rm -r $(TARGET_bindir).$(@F)
	$(INSTALL_EXEC) -D $(PKG_FILES_DIR)/sdX.init $(TARGET_sysconfdir)/init.d/sdX
	$(UPDATE-RC.D) sdX stop 97 0 6 .
	$(REWRITE_LIBTOOL)
	$(REMOVE)/$(PKG_DIR)
	$(TOUCH)

# -----------------------------------------------------------------------------

FBSHOT_VER    = 0.3
FBSHOT_DIR    = fbshot-$(FBSHOT_VER)
FBSHOT_SOURCE = fbshot-$(FBSHOT_VER).tar.gz
FBSHOT_SITE   = http://distro.ibiblio.org/amigolinux/download/Utils/fbshot

$(DL_DIR)/$(FBSHOT_SOURCE):
	$(DOWNLOAD) $(FBSHOT_SITE)/$(FBSHOT_SOURCE)

FBSHOT_DEPS = libpng

fbshot: $(FBSHOT_DEPS) $(DL_DIR)/$(FBSHOT_SOURCE) | $(TARGET_DIR)
	$(REMOVE)/$(PKG_DIR)
	$(UNTAR)/$(PKG_SOURCE)
	$(CHDIR)/$(PKG_DIR); \
		$(APPLY_PATCHES); \
		$(SED) 's|	gcc |	$(TARGET_CC) $(TARGET_CFLAGS) $(TARGET_LDFLAGS) |' Makefile; \
		$(SED) '/strip fbshot/d' Makefile; \
		$(MAKE); \
		$(INSTALL_EXEC) -D fbshot $(TARGET_bindir)/fbshot
	$(REMOVE)/$(PKG_DIR)
	$(TOUCH)

# -----------------------------------------------------------------------------

LCD4LINUX_VER    = git
LCD4LINUX_DIR    = lcd4linux.$(LCD4LINUX_VER)
LCD4LINUX_SOURCE = lcd4linux.$(LCD4LINUX_VER)
LCD4LINUX_SITE   = https://github.com/TangoCash

LCD4LINUX_DEPS = ncurses libgd libdpf

LCD4LINUX_CONF_OPTS = \
	--libdir=$(TARGET_libdir) \
	--includedir=$(TARGET_includedir) \
	--bindir=$(TARGET_bindir) \
	--docdir=$(REMOVE_docdir) \
	--with-ncurses=$(TARGET_libdir) \
	--with-drivers='DPF, SamsungSPF, PNG' \
	--with-plugins='all,!dbus,!mpris_dbus,!asterisk,!isdn,!pop3,!ppp,!seti,!huawei,!imon,!kvv,!sample,!w1retap,!wireless,!xmms,!gps,!mpd,!mysql,!qnaplog,!iconv' \

lcd4linux: $(LCD4LINUX_DEPS) | $(TARGET_DIR)
	$(REMOVE)/$(PKG_DIR)
	$(GET-GIT-SOURCE) $(PKG_SITE)/$(PKG_SOURCE) $(DL_DIR)/$(PKG_SOURCE)
	$(CPDIR)/$(PKG_SOURCE)
	$(CHDIR)/$(PKG_DIR); \
		./bootstrap; \
		$(CONFIGURE); \
		$(MAKE) vcs_version; \
		$(MAKE); \
		$(MAKE) install
	$(INSTALL_COPY) $(PKG_FILES_DIR)-skel/* $(TARGET_DIR)/
	#$(MAKE) samsunglcd4linux
	$(REMOVE)/$(PKG_DIR)
	$(TOUCH)

# -----------------------------------------------------------------------------

SAMSUNGLCD4LINUX_VER    = git
SAMSUNGLCD4LINUX_DIR    = samsunglcd4linux.$(LCD4LINUX_VER)
SAMSUNGLCD4LINUX_SOURCE = samsunglcd4linux.$(LCD4LINUX_VER)
SAMSUNGLCD4LINUX_SITE   = https://github.com/horsti58

samsunglcd4linux: | $(TARGET_DIR)
	$(REMOVE)/$(PKG_DIR)
	$(GET-GIT-SOURCE) $(PKG_SITE)/$(PKG_SOURCE) $(DL_DIR)/$(PKG_SOURCE)
	$(CPDIR)/$(PKG_SOURCE)
	$(CHDIR)/$(PKG_DIR)/ni; \
		$(INSTALL) -m 0600 etc/lcd4linux.conf $(TARGET_sysconfdir); \
		$(INSTALL_COPY) share/* $(TARGET_datadir)
	$(REMOVE)/$(PKG_DIR)
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
	$(REMOVE)/$(PKG_DIR)
	$(UNTAR)/$(PKG_SOURCE)
	$(CHDIR)/$(PKG_DIR)/wpa_supplicant; \
		$(INSTALL_DATA) $(PKG_FILES_DIR)/wpa_supplicant.config .config; \
		$(TARGET_CONFIGURE_ENV) \
		$(MAKE); \
		$(MAKE) install DESTDIR=$(TARGET_DIR) BINDIR=$(sbindir)
	$(INSTALL_EXEC) -D $(PKG_FILES_DIR)/pre-wlan0.sh $(TARGET_sysconfdir)/network/pre-wlan0.sh
	$(INSTALL_EXEC) -D $(PKG_FILES_DIR)/post-wlan0.sh $(TARGET_sysconfdir)/network/post-wlan0.sh
  ifeq ($(PERSISTENT_VAR_PARTITION),yes)
	ln -sf /var/etc/wpa_supplicant.conf $(TARGET_sysconfdir)/wpa_supplicant.conf
  endif
	$(REMOVE)/$(PKG_DIR)
	$(TOUCH)

# -----------------------------------------------------------------------------

XUPNPD_VER    = git
XUPNPD_DIR    = xupnpd.$(XUPNPD_VER)
XUPNPD_SOURCE = xupnpd.$(XUPNPD_VER)
XUPNPD_SITE   = https://github.com/clark15b

XUPNPD_CHECKOUT = 25d6d44

XUPNPD_DEPS = lua openssl

XUPNPD_MAKE_OPTS = \
	TARGET=$(TARGET) LUAFLAGS="$(TARGET_LDFLAGS) -I$(TARGET_includedir)"

xupnpd: $(XUPNPD_DEPS) | $(TARGET_DIR)
	$(REMOVE)/$(PKG_DIR)
	$(GET-GIT-SOURCE) $(PKG_SITE)/$(PKG_SOURCE) $(DL_DIR)/$(PKG_SOURCE)
	$(CPDIR)/$(PKG_SOURCE)
	$(CHDIR)/$(PKG_DIR); \
		git checkout $($(PKG)_CHECKOUT); \
		$(APPLY_PATCHES); \
		$(TARGET_CONFIGURE_ENV) \
		$(MAKE) -C src $($(PKG)_MAKE_OPTS) embedded ; \
		$(INSTALL_EXEC) -D src/xupnpd $(TARGET_bindir)/xupnpd; \
		mkdir -p $(TARGET_datadir)/xupnpd/config; \
		$(INSTALL_COPY) src/{plugins,profiles,ui,www,*.lua} $(TARGET_datadir)/xupnpd/
	rm $(TARGET_datadir)/xupnpd/plugins/staff/xupnpd_18plus.lua
	$(INSTALL_DATA) -D $(SOURCE_DIR)/$(NI_NEUTRINO_PLUGINS)/scripts-lua/xupnpd/xupnpd_18plus.lua $(TARGET_datadir)/xupnpd/plugins/
	$(INSTALL_DATA) -D $(SOURCE_DIR)/$(NI_NEUTRINO_PLUGINS)/scripts-lua/xupnpd/xupnpd_cczwei.lua $(TARGET_datadir)/xupnpd/plugins/
	$(INSTALL_DATA) -D $(SOURCE_DIR)/$(NI_NEUTRINO_PLUGINS)/scripts-lua/xupnpd/xupnpd_neutrino.lua $(TARGET_datadir)/xupnpd/plugins/
	$(INSTALL_DATA) -D $(SOURCE_DIR)/$(NI_NEUTRINO_PLUGINS)/scripts-lua/xupnpd/xupnpd_vimeo.lua $(TARGET_datadir)/xupnpd/plugins/
	$(INSTALL_DATA) -D $(SOURCE_DIR)/$(NI_NEUTRINO_PLUGINS)/scripts-lua/xupnpd/xupnpd_youtube.lua $(TARGET_datadir)/xupnpd/plugins/
	$(INSTALL_COPY) $(PKG_FILES_DIR)-skel/* $(TARGET_DIR)/
	$(UPDATE-RC.D) xupnpd defaults 75 25
	$(REMOVE)/$(PKG_DIR)
	$(TOUCH)

# -----------------------------------------------------------------------------

NFS_UTILS_VER    = 2.2.1
NFS_UTILS_DIR    = nfs-utils-$(NFS_UTILS_VER)
NFS_UTILS_SOURCE = nfs-utils-$(NFS_UTILS_VER).tar.xz
NFS_UTILS_SITE   = $(KERNEL_MIRROR)/linux/utils/nfs-utils/$(NFS_UTILS_VER)

$(DL_DIR)/$(NFS_UTILS_SOURCE):
	$(DOWNLOAD) $(NFS_UTILS_SITE)/$(NFS_UTILS_SOURCE)

NFS_UTILS_DEPS   = rpcbind

NFS_UTILS_AUTORECONF = YES

NFS_UTILS_CONF_ENV = \
	knfsd_cv_bsd_signals=no

NFS_UTILS_CONF_OPTS = \
	--docdir=$(REMOVE_docdir) \
	--enable-maintainer-mode \
	$(if $(filter $(BOXSERIES),hd1),--disable-ipv6,--enable-ipv6) \
	--disable-nfsv4 \
	--disable-nfsv41 \
	--disable-gss \
	--disable-uuid \
	--without-tcp-wrappers \
	--with-statedir=/var/lib/nfs \
	--with-rpcgen=internal \
	--without-systemd

nfs-utils: $(NFS_UTILS_DEPS) $(DL_DIR)/$(NFS_UTILS_SOURCE) | $(TARGET_DIR)
	$(REMOVE)/$(PKG_DIR)
	$(UNTAR)/$(PKG_SOURCE)
	$(CHDIR)/$(PKG_DIR); \
		$(APPLY_PATCHES); \
		$(CONFIGURE); \
		$(MAKE); \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
	chmod 0755 $(TARGET_base_sbindir)/mount.nfs
	rm -f $(addprefix $(TARGET_base_sbindir)/,mount.nfs4 osd_login umount.nfs umount.nfs4)
	rm -f $(addprefix $(TARGET_sbindir)/,mountstats nfsiostat)
  ifeq ($(PERSISTENT_VAR_PARTITION),yes)
	$(INSTALL_DATA) -D $(PKG_FILES_DIR)/exports-var $(TARGET_localstatedir)/etc/exports
	ln -sf /var/etc/exports $(TARGET_sysconfdir)/exports
  else
	$(INSTALL_DATA) -D $(PKG_FILES_DIR)/exports $(TARGET_sysconfdir)/exports
  endif
	$(INSTALL_EXEC) -D $(PKG_FILES_DIR)/nfsd.init $(TARGET_sysconfdir)/init.d/nfsd
	$(UPDATE-RC.D) nfsd defaults 75 25
	$(REMOVE)/$(PKG_DIR)
	$(TOUCH)

# -----------------------------------------------------------------------------

RPCBIND_VER    = 1.2.5
RPCBIND_DIR    = rpcbind-$(RPCBIND_VER)
RPCBIND_SOURCE = rpcbind-$(RPCBIND_VER).tar.bz2
RPCBIND_SITE   = https://sourceforge.net/projects/rpcbind/files/rpcbind/$(RPCBIND_VER)

$(DL_DIR)/$(RPCBIND_SOURCE):
	$(DOWNLOAD) $(RPCBIND_SITE)/$(RPCBIND_SOURCE)

RPCBIND_DEPS = libtirpc

RPCBIND_AUTORECONF = YES

RPCBIND_CONF_OPTS = \
	--enable-silent-rules \
	--with-rpcuser=root \
	--with-systemdsystemunitdir=no

rpcbind: $(RPCBIND_DEPS) $(DL_DIR)/$(RPCBIND_SOURCE) | $(TARGET_DIR)
	$(REMOVE)/$(PKG_DIR)
	$(UNTAR)/$(PKG_SOURCE)
	$(CHDIR)/$(PKG_DIR); \
		$(APPLY_PATCHES); \
		$(CONFIGURE); \
		$(MAKE); \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
	rm -rf $(TARGET_bindir)/rpcgen
	$(REMOVE)/$(PKG_DIR)
	$(TOUCH)

# -----------------------------------------------------------------------------

STREAMRIPPER_DEPS = libvorbisidec libmad glib2

STREAMRIPPER_AUTORECONF = yes

STREAMRIPPER_CONF_OPTS = \
	--includedir=$(TARGET_includedir) \
	--datarootdir=$(REMOVE_datarootdir) \
	--with-ogg-includes=$(TARGET_includedir) \
	--with-ogg-libraries=$(TARGET_libdir) \
	--with-vorbis-includes=$(TARGET_includedir) \
	--with-vorbis-libraries=$(TARGET_libdir) \
	--with-included-argv=yes \
	--with-included-libmad=no

streamripper: $(STREAMRIPPER_DEPS) | $(TARGET_DIR)
	$(REMOVE)/$(NI_STREAMRIPPER)
	tar -C $(SOURCE_DIR) -cp $(NI_STREAMRIPPER) --exclude-vcs | tar -C $(BUILD_DIR) -x
	$(CHDIR)/$(NI_STREAMRIPPER); \
		$(CONFIGURE); \
		$(MAKE); \
		$(INSTALL_EXEC) -D streamripper $(TARGET_bindir)/streamripper
	$(INSTALL_EXEC) $(PKG_FILES_DIR)/streamripper.sh $(TARGET_bindir)/
	$(REMOVE)/$(NI_STREAMRIPPER)
	$(TOUCH)

# -----------------------------------------------------------------------------

GETTEXT_VER    = 0.19.8.1
GETTEXT_DIR    = gettext-$(GETTEXT_VER)
GETTEXT_SOURCE = gettext-$(GETTEXT_VER).tar.xz
GETTEXT_SITE   = $(GNU_MIRROR)/gettext

$(DL_DIR)/$(GETTEXT_SOURCE):
	$(DOWNLOAD) $(GETTEXT_SITE)/$(GETTEXT_SOURCE)

GETTEXT_AUTORECONF = YES

GETTEXT_CONF_OPTS = \
	--bindir=$(REMOVE_bindir) \
	--datarootdir=$(REMOVE_datarootdir) \
	--disable-libasprintf \
	--disable-acl \
	--disable-openmp \
	--disable-java \
	--disable-native-java \
	--disable-csharp \
	--disable-relocatable \
	--without-emacs

gettext: $(DL_DIR)/$(GETTEXT_SOURCE) | $(TARGET_DIR)
	$(REMOVE)/$(PKG_DIR)
	$(UNTAR)/$(PKG_SOURCE)
	$(CHDIR)/$(PKG_DIR); \
		$(CONFIGURE); \
		$(MAKE) -C gettext-runtime; \
		$(MAKE) -C gettext-runtime install DESTDIR=$(TARGET_DIR)
	$(REWRITE_LIBTOOL)
	$(REMOVE)/$(PKG_DIR)
	$(TOUCH)

# -----------------------------------------------------------------------------

MC_VER    = 4.8.25
MC_DIR    = mc-$(MC_VER)
MC_SOURCE = mc-$(MC_VER).tar.xz
MC_SITE   = ftp.midnight-commander.org

$(DL_DIR)/$(MC_SOURCE):
	$(DOWNLOAD) $(MC_SITE)/$(MC_SOURCE)

MC_DEPS = glib2 ncurses

MC_AUTORECONF = YES

MC_CONF_OPTS = \
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
	--without-x

mc: $(MC_DEPS) $(DL_DIR)/$(MC_SOURCE) | $(TARGET_DIR)
	$(REMOVE)/$(PKG_DIR)
	$(UNTAR)/$(PKG_SOURCE)
	$(CHDIR)/$(PKG_DIR); \
		$(APPLY_PATCHES); \
		$(CONFIGURE); \
		$(MAKE); \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
	rm -rf $(TARGET_datadir)/mc/examples
	find $(TARGET_datadir)/mc/skins -type f ! -name default.ini | xargs --no-run-if-empty rm
	$(REMOVE)/$(PKG_DIR)
	$(TOUCH)

# -----------------------------------------------------------------------------

WGET_VER    = 1.20.3
WGET_DIR    = wget-$(WGET_VER)
WGET_SOURCE = wget-$(WGET_VER).tar.gz
WGET_SITE   = $(GNU_MIRROR)/wget

$(DL_DIR)/$(WGET_SOURCE):
	$(DOWNLOAD) $(WGET_SITE)/$(WGET_SOURCE)

WGET_DEPS = openssl

WGET_CONF_OPTS = \
	--datarootdir=$(REMOVE_datarootdir) \
	--sysconfdir=$(REMOVE_sysconfdir) \
	--with-gnu-ld \
	--with-ssl=openssl \
	--disable-debug \
	CFLAGS="$(TARGET_CFLAGS) -DOPENSSL_NO_ENGINE"

wget: $(WGET_DEPS) $(DL_DIR)/$(WGET_SOURCE) | $(TARGET_DIR)
	$(REMOVE)/$(PKG_DIR)
	$(UNTAR)/$(PKG_SOURCE)
	$(CHDIR)/$(PKG_DIR); \
		$(APPLY_PATCHES); \
		$(CONFIGURE); \
		$(MAKE); \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
	$(REMOVE)/$(PKG_DIR)
	$(TOUCH)

# -----------------------------------------------------------------------------

ofgwrite: $(SOURCE_DIR)/$(NI_OFGWRITE) | $(TARGET_DIR)
	$(REMOVE)/$(NI_OFGWRITE)
	tar -C $(SOURCE_DIR) -cp $(NI_OFGWRITE) --exclude-vcs | tar -C $(BUILD_DIR) -x
	$(CHDIR)/$(NI_OFGWRITE); \
		$(TARGET_CONFIGURE_ENV) \
		$(MAKE)
	$(INSTALL_EXEC) $(BUILD_DIR)/$(NI_OFGWRITE)/ofgwrite_bin $(TARGET_bindir)
	$(INSTALL_EXEC) $(BUILD_DIR)/$(NI_OFGWRITE)/ofgwrite_caller $(TARGET_bindir)
	$(INSTALL_EXEC) $(BUILD_DIR)/$(NI_OFGWRITE)/ofgwrite $(TARGET_bindir)
	$(SED) 's|prefix=.*|prefix=$(prefix)|' $(TARGET_bindir)/ofgwrite
	$(REMOVE)/$(NI_OFGWRITE)
	$(TOUCH)

# -----------------------------------------------------------------------------

AIO_GRAB_VER    = git
AIO_GRAB_DIR    = aio-grab.$(AIO_GRAB_VER)
AIO_GRAB_SOURCE = aio-grab.$(AIO_GRAB_VER)
AIO_GRAB_SITE   = https://github.com/oe-alliance

AIO_GRAB_DEPS   = zlib libpng libjpeg-turbo

AIO_GRAB_AUTORECONF = YES

AIO_GRAB_CONF_OPTS = \
	--enable-silent-rules

aio-grab: $(AIO_GRAB_DEPS) | $(TARGET_DIR)
	$(REMOVE)/$(PKG_DIR)
	$(GET-GIT-SOURCE) $(PKG_SITE)/$(PKG_SOURCE) $(DL_DIR)/$(PKG_SOURCE)
	$(CPDIR)/$(PKG_SOURCE)
	$(CHDIR)/$(PKG_DIR); \
		$(CONFIGURE); \
		$(MAKE); \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
	$(REMOVE)/$(PKG_DIR)
	$(TOUCH)

# -----------------------------------------------------------------------------

DVBSNOOP_VER    = git
DVBSNOOP_DIR    = dvbsnoop.$(DVBSNOOP_VER)
DVBSNOOP_SOURCE = dvbsnoop.$(DVBSNOOP_VER)
DVBSNOOP_SITE   = https://github.com/Duckbox-Developers

DVBSNOOP_CONF-OPTS = \
	--enable-silent-rules

dvbsnoop: | $(TARGET_DIR)
	$(REMOVE)/$(PKG_DIR)
	$(GET-GIT-SOURCE) $(PKG_SITE)/$(PKG_SOURCE) $(DL_DIR)/$(PKG_SOURCE)
	$(CPDIR)/$(PKG_SOURCE)
	$(CHDIR)/$(PKG_DIR); \
		$(CONFIGURE); \
		$(MAKE); \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
	$(REMOVE)/$(PKG_DIR)
	$(TOUCH)

# -----------------------------------------------------------------------------

DVB_APPS_VER    = git
DVB_APPS_DIR    = dvb-apps.$(DVB_APPS_VER)
DVB_APPS_SOURCE = dvb-apps.$(DVB_APPS_VER)
DVB_APPS_SITE   = https://github.com/openpli-arm

DVB_APPS_DEPS = kernel libiconv

DVB_APPS_MAKE_OPTS = \
	KERNEL_HEADERS=$(BUILD_DIR)/$(KERNEL_HEADERS) \
	enable_shared=no \
	PERL5LIB=$(PKG_BUILD_DIR)/util/scan \

dvb-apps: $(DVB_APPS_DEPS) | $(TARGET_DIR)
	$(REMOVE)/$(PKG_DIR)
	$(GET-GIT-SOURCE) $(PKG_SITE)/$(PKG_SOURCE) $(DL_DIR)/$(PKG_SOURCE)
	$(CPDIR)/$(PKG_SOURCE)
	$(CHDIR)/$(PKG_DIR); \
		$(APPLY_PATCHES); \
		$(TARGET_CONFIGURE_ENV) LDLIBS="-liconv" \
		$(MAKE) $($(PKG)_MAKE_OPTS); \
		$(MAKE) $($(PKG)_MAKE_OPTS) install DESTDIR=$(TARGET_DIR)
	$(REMOVE)/$(PKG_DIR)
	$(TOUCH)

# -----------------------------------------------------------------------------

MINISATIP_VER    = git
MINISATIP_DIR    = minisatip.$(MINISATIP_VER)
MINISATIP_SOURCE = minisatip.$(MINISATIP_VER)
MINISATIP_SITE   = https://github.com/catalinii

MINISATIP_DEPS = libdvbcsa openssl dvb-apps

MINISATIP_CONF_OPTS = \
	--enable-static \
	--enable-enigma \
	--disable-netcv

minisatip: $(MINISATIP_DEPS) | $(TARGET_DIR)
	$(REMOVE)/$(PKG_DIR)
	$(GET-GIT-SOURCE) $(PKG_SITE)/$(PKG_SOURCE) $(DL_DIR)/$(PKG_SOURCE)
	$(CPDIR)/$(PKG_SOURCE)
	$(CHDIR)/$(PKG_DIR); \
		$(CONFIGURE); \
		$(TARGET_CONFIGURE_ENV) \
		$(MAKE)
	$(INSTALL_EXEC) -D $(PKG_BUILD_DIR)/minisatip $(TARGET_bindir)/minisatip
	$(INSTALL) -d $(TARGET_datadir)/minisatip
	$(INSTALL_COPY) $(PKG_BUILD_DIR)/html $(TARGET_datadir)/minisatip
	$(INSTALL) -d $(TARGET_sysconfdir)/default
	echo 'MINISATIP_OPTS="-x 9090 -t -o /tmp/camd.socket"' > $(TARGET_sysconfdir)/default/minisatip
	$(INSTALL_EXEC) -D $(PKG_FILES_DIR)/minisatip.init $(TARGET_sysconfdir)/init.d/minisatip
	$(UPDATE-RC.D) minisatip defaults 75 25
	$(REMOVE)/$(PKG_DIR)
	$(TOUCH)

# -----------------------------------------------------------------------------

ETHTOOL_VER    = 5.10
ETHTOOL_DIR    = ethtool-$(ETHTOOL_VER)
ETHTOOL_SOURCE = ethtool-$(ETHTOOL_VER).tar.xz
ETHTOOL_SITE   = $(KERNEL_MIRROR)/software/network/ethtool

$(DL_DIR)/$(ETHTOOL_SOURCE):
	$(DOWNLOAD) $(ETHTOOL_SITE)/$(ETHTOOL_SOURCE)

ETHTOOL_CONF_OPTS = \
	--libdir=$(TARGET_libdir) \
	--disable-pretty-dump \
	--disable-netlink

ethtool: $(DL_DIR)/$(ETHTOOL_SOURCE) | $(TARGET_DIR)
	$(REMOVE)/$(PKG_DIR)
	$(UNTAR)/$(PKG_SOURCE)
	$(CHDIR)/$(PKG_DIR); \
		$(CONFIGURE); \
		$(MAKE); \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
	$(REMOVE)/$(PKG_DIR)
	$(TOUCH)

# -----------------------------------------------------------------------------

GPTFDISK_VER    = 1.0.4
GPTFDISK_DIR    = gptfdisk-$(GPTFDISK_VER)
GPTFDISK_SOURCE = gptfdisk-$(GPTFDISK_VER).tar.gz
GPTFDISK_SITE   = https://sourceforge.net/projects/gptfdisk/files/gptfdisk/$(GPTFDISK_VER)

$(DL_DIR)/$(GPTFDISK_SOURCE):
	$(DOWNLOAD) $(GPTFDISK_SITE)/$(GPTFDISK_SOURCE)

GPTFDISK_DEPS = popt e2fsprogs ncurses

GPTFDISK_SBINARIES = sgdisk

gptfdisk: $(GPTFDISK_DEPS) $(DL_DIR)/$(GPTFDISK_SOURCE) | $(TARGET_DIR)
	$(REMOVE)/$(PKG_DIR)
	$(UNTAR)/$(PKG_SOURCE)
	$(CHDIR)/$(PKG_DIR); \
		$(APPLY_PATCHES); \
		$(TARGET_CONFIGURE_ENV) \
		$(MAKE) $($(PKG)_SBINARIES); \
		for sbin in $($(PKG)_SBINARIES); do \
			$(INSTALL_EXEC) -D $$sbin $(TARGET_sbindir)/$$sbin; \
		done
	$(REMOVE)/$(PKG_DIR)
	$(TOUCH)

# -----------------------------------------------------------------------------

RSYNC_VER    = 3.1.3
RSYNC_DIR    = rsync-$(RSYNC_VER)
RSYNC_SOURCE = rsync-$(RSYNC_VER).tar.gz
RSYNC_SITE   = https://download.samba.org/pub/rsync/src/

$(DL_DIR)/$(RSYNC_SOURCE):
	$(DOWNLOAD) $(RSYNC_SITE)/$(RSYNC_SOURCE)

RSYNC_DEPS = zlib popt

RSYNC_CONF_OPTS = \
	--disable-debug \
	--disable-locale \
	--disable-acl-support \
	--with-included-zlib=no \
	--with-included-popt=no

rsync: $(RSYNC_DEPS) $(DL_DIR)/$(RSYNC_SOURCE) | $(TARGET_DIR)
	$(REMOVE)/$(PKG_DIR)
	$(UNTAR)/$(PKG_SOURCE)
	$(CHDIR)/$(PKG_DIR); \
		$(CONFIGURE); \
		$(MAKE); \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
	$(REMOVE)/$(PKG_DIR)
	$(TOUCH)

# -----------------------------------------------------------------------------

FLAC_VER    = 1.3.3
FLAC_DIR    = flac-$(FLAC_VER)
FLAC_SOURCE = flac-$(FLAC_VER).tar.xz
FLAC_SITE   = http://downloads.xiph.org/releases/flac

$(DL_DIR)/$(FLAC_SOURCE):
	$(DOWNLOAD) $(FLAC_SITE)/$(FLAC_SOURCE)

FLAC_AUTORECONF = YES

FLAC_CONF_OPTS = \
	--bindir=$(REMOVE_bindir) \
	--datarootdir=$(REMOVE_datarootdir) \
	--enable-shared \
	--disable-static \
	--disable-cpplibs \
	--disable-xmms-plugin \
	--disable-altivec \
	--disable-ogg \
	--disable-sse

flac: $(DL_DIR)/$(FLAC_SOURCE) | $(TARGET_DIR)
	$(REMOVE)/$(PKG_DIR)
	$(UNTAR)/$(PKG_SOURCE)
	$(CHDIR)/$(PKG_DIR); \
		$(CONFIGURE); \
		$(MAKE); \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
	$(REWRITE_LIBTOOL)
	$(REMOVE)/$(PKG_DIR)
	$(TOUCH)

# -----------------------------------------------------------------------------

CA_BUNDLE_SOURCE = cacert.pem
CA_BUNDLE_SITE   = https://curl.se/ca

$(DL_DIR)/$(CA_BUNDLE_SOURCE):
	$(DOWNLOAD) $(CA_BUNDLE_SITE)/$(CA_BUNDLE_SOURCE)

CA_BUNDLE_CRT = ca-certificates.crt
CA_BUNDLE_DIR = /etc/ssl/certs

ca-bundle: $(DL_DIR)/$(CA_BUNDLE_SOURCE) | $(TARGET_DIR)
	$(CD) $(DL_DIR); \
		curl --remote-name --remote-time -z $(PKG_SOURCE) $(PKG_SITE)/$(PKG_SOURCE) || true
	$(INSTALL_DATA) -D $(DL_DIR)/$(PKG_SOURCE) $(TARGET_DIR)/$(CA_BUNDLE_DIR)/$(CA_BUNDLE_CRT)
	$(TOUCH)
