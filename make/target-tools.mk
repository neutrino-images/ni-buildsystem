#
# makefile to build system tools
#
# -----------------------------------------------------------------------------

#
# $(base_prefix) tools
#
# -----------------------------------------------------------------------------

BUSYBOX_VERSION = 1.31.1
BUSYBOX_DIR = busybox-$(BUSYBOX_VERSION)
BUSYBOX_SOURCE = busybox-$(BUSYBOX_VERSION).tar.bz2
BUSYBOX_SITE = https://busybox.net/downloads

$(DL_DIR)/$(BUSYBOX_SOURCE):
	$(download) $(BUSYBOX_SITE)/$(BUSYBOX_SOURCE)

BUSYBOX_DEPENDENCIES = libtirpc

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
	$(MAKE) ifupdown-scripts
	$(INSTALL_EXEC) -D $(PKG_FILES_DIR)/udhcpc-default.script $(TARGET_datadir)/udhcpc/default.script
	$(BUSYBOX_INSTALL_LINK_RESOLV_CONF)
	$(INSTALL_EXEC) -D $(PKG_FILES_DIR)/crond.init $(TARGET_sysconfdir)/init.d/crond
	$(UPDATE-RC.D) crond defaults 50
	$(INSTALL) -d $(TARGET_localstatedir)/spool/cron/crontabs \
		$(TARGET_sysconfdir)/cron.{daily,hourly,monthly,weekly}
	$(INSTALL_EXEC) -D $(PKG_FILES_DIR)/inetd.init $(TARGET_sysconfdir)/init.d/inetd
	$(UPDATE-RC.D) inetd defaults 50
	$(INSTALL_DATA) -D $(PKG_FILES_DIR)/inetd.conf $(TARGET_sysconfdir)/inetd.conf
	$(INSTALL_EXEC) -D $(PKG_FILES_DIR)/mdev.init $(TARGET_sysconfdir)/init.d/mdev
	$(INSTALL_EXEC) -D $(PKG_FILES_DIR)/syslogd.init $(TARGET_sysconfdir)/init.d/syslogd
	$(UPDATE-RC.D) syslogd stop 98 0 6 .
endef

busybox: $(BUSYBOX_DEPENDENCIES) $(DL_DIR)/$(BUSYBOX_SOURCE) | $(TARGET_DIR)
	$(REMOVE)/$(PKG_DIR)
	$(UNTAR)/$(PKG_SOURCE)
	$(call APPLY_PATCHES,$(PKG_PATCHES_DIR))
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

SYSVINIT_VERSION = 3.00
SYSVINIT_DIR = sysvinit-$(SYSVINIT_VERSION)
SYSVINIT_SOURCE = sysvinit-$(SYSVINIT_VERSION).tar.xz
SYSVINIT_SITE = http://download.savannah.nongnu.org/releases/sysvinit

$(DL_DIR)/$(SYSVINIT_SOURCE):
	$(download) $(SYSVINIT_SITE)/$(SYSVINIT_SOURCE)

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
	$(call APPLY_PATCHES,$(PKG_PATCHES_DIR))
	$(CHDIR)/$(PKG_DIR); \
		$(TARGET_CONFIGURE_ENV) \
		$(MAKE) -C src SULOGINLIBS=-lcrypt; \
		$(MAKE) install ROOT=$(TARGET_DIR) MANDIR=$(REMOVE_mandir)
	$(TARGET_RM) $(addprefix $(TARGET_base_sbindir)/,bootlogd fstab-decode logsave telinit)
	$(TARGET_RM) $(addprefix $(TARGET_bindir)/,last lastb mesg readbootlog utmpdump wall)
	$($(PKG)_INSTALL_FILES)
	$(REMOVE)/$(PKG_DIR)
	$(TOUCH)

# -----------------------------------------------------------------------------

# for coolstream: formatting ext4 failes with newer versions then 1.43.8
E2FSPROGS_VERSION = $(if $(filter $(BOXTYPE),coolstream),1.43.8,1.46.4)
E2FSPROGS_DIR = e2fsprogs-$(E2FSPROGS_VERSION)
E2FSPROGS_SOURCE = e2fsprogs-$(E2FSPROGS_VERSION).tar.gz
E2FSPROGS_SITE = https://sourceforge.net/projects/e2fsprogs/files/e2fsprogs/v$(E2FSPROGS_VERSION)

$(DL_DIR)/$(E2FSPROGS_SOURCE):
	$(download) $(E2FSPROGS_SITE)/$(E2FSPROGS_SOURCE)

# Use libblkid and libuuid from util-linux
E2FSPROGS_DEPENDENCIES = util-linux

#E2FSPROGS_AUTORECONF = YES

E2FSPROGS_CONF_ENV = \
	ac_cv_path_LDCONFIG=true

E2FSPROGS_CONF_OPTS = \
	--with-root-prefix="$(base_prefix)" \
	--libdir=$(libdir) \
	--includedir=$(includedir) \
	--datarootdir=$(REMOVE_datarootdir) \
	--disable-backtrace \
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
	--disable-libblkid \
	--disable-libuuid \
	--disable-uuidd \
	--enable-elf-shlibs \
	--enable-fsck \
	--enable-symlink-build \
	--enable-symlink-install \
	--enable-verbose-makecmds \
	--without-libintl-prefix \
	--without-libiconv-prefix \
	--with-gnu-ld \
	--with-crond-dir=no

e2fsprogs: $(E2FSPROGS_DEPENDENCIES) $(DL_DIR)/$(E2FSPROGS_SOURCE) | $(TARGET_DIR)
	$(REMOVE)/$(PKG_DIR)
	$(UNTAR)/$(PKG_SOURCE)
	$(CHDIR)/$(PKG_DIR); \
		$(CONFIGURE); \
		$(MAKE); \
		$(MAKE1) install install-libs DESTDIR=$(TARGET_DIR)
	$(TARGET_RM) $(addprefix $(TARGET_base_sbindir)/,dumpe2fs e2mmpstatus e2undo logsave)
	$(TARGET_RM) $(addprefix $(TARGET_bindir)/,chattr compile_et lsattr mk_cmds uuidgen)
	$(TARGET_RM) $(addprefix $(TARGET_sbindir)/,e2freefrag e4crypt filefrag)
	$(REMOVE)/$(PKG_DIR)
	$(TOUCH)

# -----------------------------------------------------------------------------

HDPARM_VERSION = 9.60
HDPARM_DIR = hdparm-$(HDPARM_VERSION)
HDPARM_SOURCE = hdparm-$(HDPARM_VERSION).tar.gz
HDPARM_SITE = https://sourceforge.net/projects/hdparm/files/hdparm

$(DL_DIR)/$(HDPARM_SOURCE):
	$(download) $(HDPARM_SITE)/$(HDPARM_SOURCE)

hdparm: $(DL_DIR)/$(HDPARM_SOURCE) | $(TARGET_DIR)
	$(REMOVE)/$(PKG_DIR)
	$(UNTAR)/$(PKG_SOURCE)
	$(call APPLY_PATCHES,$(PKG_PATCHES_DIR))
	$(CHDIR)/$(PKG_DIR); \
		$(TARGET_CONFIGURE_ENV) \
		$(MAKE); \
		$(MAKE) install DESTDIR=$(TARGET_DIR) mandir=$(REMOVE_mandir)
	$(REMOVE)/$(PKG_DIR)
	$(TOUCH)

# -----------------------------------------------------------------------------

#
# $(prefix) tools
#
# -----------------------------------------------------------------------------

OPENSSH_VERSION = 8.6p1
OPENSSH_DIR = openssh-$(OPENSSH_VERSION)
OPENSSH_SOURCE = openssh-$(OPENSSH_VERSION).tar.gz
OPENSSH_SITE = https://artfiles.org/openbsd/OpenSSH/portable

$(DL_DIR)/$(OPENSSH_SOURCE):
	$(download) $(OPENSSH_SITE)/$(OPENSSH_SOURCE)

OPENSSH_DEPENDENCIES = openssl zlib

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

openssh: $(OPENSSH_DEPENDENCIES) $(DL_DIR)/$(OPENSSH_SOURCE) | $(TARGET_DIR)
	$(REMOVE)/$(PKG_DIR)
	$(UNTAR)/$(PKG_SOURCE)
	$(CHDIR)/$(PKG_DIR); \
		$($(PKG)_CONF_ENV) ./configure $(TARGET_CONFIGURE_OPTS); \
		$(MAKE); \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
	$(REMOVE)/$(PKG_DIR)
	$(TOUCH)

# -----------------------------------------------------------------------------

TZDATA_VERSION = 2020f
TZDATA_DIR = tzdata$(TZDATA_VERSION)
TZDATA_SOURCE = tzdata$(TZDATA_VERSION).tar.gz
TZDATA_SITE = ftp://ftp.iana.org/tz/releases

$(DL_DIR)/$(TZDATA_SOURCE):
	$(download) $(TZDATA_SITE)/$(TZDATA_SOURCE)

TZDATA_DEPENDENCIES = host-zic

TZDATA_ZONELIST = \
	africa antarctica asia australasia europe northamerica \
	southamerica etcetera backward factory

TZDATA_LOCALTIME = CET

ETC_LOCALTIME = $(if $(filter $(PERSISTENT_VAR_PARTITION),yes),/var/etc/localtime,/etc/localtime)

tzdata: $(TZDATA_DEPENDENCIES) $(DL_DIR)/$(TZDATA_SOURCE) | $(TARGET_DIR)
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

HD_IDLE_VERSION = 1.05
HD_IDLE_DIR = hd-idle
HD_IDLE_SOURCE = hd-idle-$(HD_IDLE_VERSION).tgz
HD_IDLE_SITE = https://sourceforge.net/projects/hd-idle/files

$(DL_DIR)/$(HD_IDLE_SOURCE):
	$(download) $(HD_IDLE_SITE)/$(HD_IDLE_SOURCE)

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

DJMOUNT_VERSION = 0.71
DJMOUNT_DIR = djmount-$(DJMOUNT_VERSION)
DJMOUNT_SOURCE = djmount-$(DJMOUNT_VERSION).tar.gz
DJMOUNT_SITE = https://sourceforge.net/projects/djmount/files/djmount/$(DJMOUNT_VERSION)

$(DL_DIR)/$(DJMOUNT_SOURCE):
	$(download) $(DJMOUNT_SITE)/$(DJMOUNT_SOURCE)

DJMOUNT_DEPENDENCIES = libfuse

DJMOUNT_AUTORECONF = YES

DJMOUNT_CONF_OPTS = \
	--with-fuse-prefix=$(TARGET_prefix) \
	--disable-debug

djmount: $(DJMOUNT_DEPENDENCIES) $(DL_DIR)/$(DJMOUNT_SOURCE) | $(TARGET_DIR)
	$(REMOVE)/$(PKG_DIR)
	$(UNTAR)/$(PKG_SOURCE)
	$(call APPLY_PATCHES,$(PKG_PATCHES_DIR))
	$(CHDIR)/$(PKG_DIR); \
		touch libupnp/config.aux/config.rpath; \
		$(CONFIGURE); \
		$(MAKE1); \
		$(MAKE1) install DESTDIR=$(TARGET_DIR)
	$(INSTALL_EXEC) -D $(PKG_FILES_DIR)/djmount.init $(TARGET_sysconfdir)/init.d/djmount
	$(UPDATE-RC.D) djmount defaults 75 25
	$(REMOVE)/$(PKG_DIR)
	$(TOUCH)

# -----------------------------------------------------------------------------

USHARE_VERSION = 1.1a
USHARE_DIR = ushare-uShare_v$(USHARE_VERSION)
USHARE_SOURCE = uShare_v$(USHARE_VERSION).tar.gz
USHARE_SITE = https://github.com/GeeXboX/ushare/archive

$(DL_DIR)/$(USHARE_SOURCE):
	$(download) $(USHARE_SITE)/$(USHARE_SOURCE)

USHARE_DEPENDENCIES = libupnp

USHARE_CONF_OPTS = \
	--prefix=$(prefix) \
	--sysconfdir=$(sysconfdir) \
	--disable-dlna \
	--disable-nls \
	--cross-compile \
	--cross-prefix=$(TARGET_CROSS)

ushare: $(USHARE_DEPENDENCIES) $(DL_DIR)/$(USHARE_SOURCE) | $(TARGET_DIR)
	$(REMOVE)/$(PKG_DIR)
	$(UNTAR)/$(PKG_SOURCE)
	$(call APPLY_PATCHES,$(PKG_PATCHES_DIR))
	$(CHDIR)/$(PKG_DIR); \
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

VSFTPD_VERSION = 3.0.3
VSFTPD_DIR = vsftpd-$(VSFTPD_VERSION)
VSFTPD_SOURCE = vsftpd-$(VSFTPD_VERSION).tar.gz
VSFTPD_SITE = https://security.appspot.com/downloads

$(DL_DIR)/$(VSFTPD_SOURCE):
	$(download) $(VSFTPD_SITE)/$(VSFTPD_SOURCE)

VSFTPD_LIBS += -lcrypt $$($(PKG_CONFIG) --libs libssl libcrypto)

VSFTPD_DEPENDENCIES = openssl

vsftpd: $(VSFTPD_DEPENDENCIES) $(DL_DIR)/$(VSFTPD_SOURCE) | $(TARGET_DIR)
	$(REMOVE)/$(PKG_DIR)
	$(UNTAR)/$(PKG_SOURCE)
	$(call APPLY_PATCHES,$(PKG_PATCHES_DIR))
	$(CHDIR)/$(PKG_DIR); \
		$(SED) 's/.*VSF_BUILD_PAM/#undef VSF_BUILD_PAM/' builddefs.h; \
		$(SED) 's/.*VSF_BUILD_SSL/#define VSF_BUILD_SSL/' builddefs.h; \
		$(MAKE) clean; \
		$(MAKE) $(TARGET_CONFIGURE_ENV) LIBS="$($(PKG)_LIBS)"; \
		$(INSTALL_EXEC) -D vsftpd $(TARGET_sbindir)/vsftpd
	$(INSTALL) -d $(TARGET_datadir)/empty
	$(INSTALL_DATA) -D $(PKG_FILES_DIR)/vsftpd.conf $(TARGET_sysconfdir)/vsftpd.conf
	$(INSTALL_DATA) -D $(PKG_FILES_DIR)/vsftpd.chroot_list $(TARGET_sysconfdir)/vsftpd.chroot_list
	$(INSTALL_EXEC) -D $(PKG_FILES_DIR)/vsftpd.init $(TARGET_sysconfdir)/init.d/vsftpd
	$(UPDATE-RC.D) vsftpd defaults 75 25
	$(REMOVE)/$(PKG_DIR)
	$(TOUCH)

# -----------------------------------------------------------------------------

NANO_VERSION = 5.8
NANO_DIR = nano-$(NANO_VERSION)
NANO_SOURCE = nano-$(NANO_VERSION).tar.gz
NANO_SITE = $(GNU_MIRROR)/nano

$(DL_DIR)/$(NANO_SOURCE):
	$(download) $(NANO_SITE)/$(NANO_SOURCE)

NANO_DEPENDENCIES = ncurses

ifeq ($(BS_PACKAGE_NCURSES_WCHAR),y)
  NANO_CONF_ENV = \
	ac_cv_prog_NCURSESW_CONFIG=$(HOST_DIR)/bin/$(NCURSES_CONFIG_SCRIPTS)
else
  NANO_CONF_ENV = \
	ac_cv_prog_NCURSESW_CONFIG=false
  NANO_MAKE_ENV = \
	CURSES_LIB="-lncurses"
endif

NANO_CONF_OPTS = \
	--datarootdir=$(REMOVE_datarootdir) \
	--disable-nls \
	--disable-libmagic \
	--enable-tiny \
	--without-slang \
	--with-wordbounds

nano: $(NANO_DEPENDENCIES) $(DL_DIR)/$(NANO_SOURCE) | $(TARGET_DIR)
	$(REMOVE)/$(PKG_DIR)
	$(UNTAR)/$(PKG_SOURCE)
	$(CHDIR)/$(PKG_DIR); \
		$(CONFIGURE); \
		$(NANO_MAKE_ENV) $(MAKE); \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
	$(INSTALL) -d $(TARGET_sysconfdir)/profile.d
	echo "export EDITOR=nano" > $(TARGET_sysconfdir)/profile.d/editor.sh
	$(REMOVE)/$(PKG_DIR)
	$(TOUCH)

# -----------------------------------------------------------------------------

AUTOFS_VERSION = 5.1.7
AUTOFS_DIR = autofs-$(AUTOFS_VERSION)
AUTOFS_SOURCE = autofs-$(AUTOFS_VERSION).tar.xz
AUTOFS_SITE = $(KERNEL_MIRROR)/linux/daemons/autofs/v5

$(DL_DIR)/$(AUTOFS_SOURCE):
	$(download) $(AUTOFS_SITE)/$(AUTOFS_SOURCE)

# cd package/autofs/patches
# wget -N https://mirrors.edge.kernel.org/pub/linux/daemons/autofs/v5/patches-5.1.8/patch_order_5.1.7
# for p in $(cat patch_order_5.1.7); do test -f $p || wget https://mirrors.edge.kernel.org/pub/linux/daemons/autofs/v5/patches-5.1.8/$p; done

AUTOFS_PATCH  = 0000-force-STRIP-to-emtpy.patch
AUTOFS_PATCH += $(shell cat $(PKG_PATCHES_DIR)/patch_order_$(AUTOFS_VERSION))

AUTOFS_DEPENDENCIES = libtirpc

AUTOFS_AUTORECONF = YES

AUTOFS_CONF_ENV = \
	ac_cv_path_E2FSCK=/sbin/fsck \
	ac_cv_path_E3FSCK=no \
	ac_cv_path_E4FSCK=no \
	ac_cv_path_KRB5_CONFIG=no \
	ac_cv_path_MODPROBE=/sbin/modprobe \
	ac_cv_path_MOUNT=/bin/mount \
	ac_cv_path_MOUNT_NFS=/sbin/mount.nfs \
	ac_cv_path_UMOUNT=/bin/umount \
	ac_cv_linux_procfs=yes

AUTOFS_CONF_OPTS = \
	--datarootdir=$(REMOVE_datarootdir) \
	--disable-mount-locking \
	--enable-ignore-busy \
	--without-openldap \
	--without-sasl \
	--with-path="$(PATH)" \
	--with-hesiod=no \
	--with-libtirpc \
	--with-confdir=/etc \
	--with-mapdir=/etc \
	--with-fifodir=/var/run \
	--with-flagdir=/var/run

AUTOFS_MAKE_ENV = \
	DONTSTRIP=1

autofs: $(AUTOFS_DEPENDENCIES) $(DL_DIR)/$(AUTOFS_SOURCE) | $(TARGET_DIR)
	$(REMOVE)/$(PKG_DIR)
	$(UNTAR)/$(PKG_SOURCE)
	$(call APPLY_PATCHES,$($(PKG)_PATCH))
	$(CHDIR)/$(PKG_DIR); \
		$(SED) "s|nfs/nfs.h|linux/nfs.h|" include/rpc_subs.h; \
		$(CONFIGURE); \
		$($(PKG)_MAKE_ENV) \
		$(MAKE); \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
	$(INSTALL_COPY) $(PKG_FILES_DIR)-skel/* $(TARGET_DIR)/
	$(UPDATE-RC.D) autofs defaults 75 25
	$(REMOVE)/$(PKG_DIR)
	$(TOUCH)

# -----------------------------------------------------------------------------

samba: $(if $(filter $(BOXSERIES),hd1),samba33,samba36)
	$(TOUCH)

# -----------------------------------------------------------------------------

SAMBA33_VERSION = 3.3.16
SAMBA33_DIR = samba-$(SAMBA33_VERSION)
SAMBA33_SOURCE = samba-$(SAMBA33_VERSION).tar.gz
SAMBA33_SITE = https://download.samba.org/pub/samba

$(DL_DIR)/$(SAMBA33_SOURCE):
	$(download) $(SAMBA33_SITE)/$(SAMBA33_SOURCE)

SAMBA33_DEPENDENCIES = zlib

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

samba33: $(SAMBA33_DEPENDENCIES) $(DL_DIR)/$(SAMBA33_SOURCE) | $(TARGET_DIR)
	$(REMOVE)/$(PKG_DIR)
	$(UNTAR)/$(PKG_SOURCE)
	$(call APPLY_PATCHES,$(PKG_PATCHES_DIR))
	$(CHDIR)/$(PKG_DIR)/source; \
		./autogen.sh; \
		$(CONFIGURE); \
		$(MAKE1) all; \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
	$(INSTALL) -d $(TARGET_localstatedir)/samba/locks
	$(INSTALL_DATA) -D $(PKG_FILES_DIR)/smb3.conf $(TARGET_sysconfdir)/samba/smb.conf
	$(INSTALL_EXEC) -D $(PKG_FILES_DIR)/samba3.init $(TARGET_sysconfdir)/init.d/samba
	$(UPDATE-RC.D) samba defaults 75 25
	$(TARGET_RM) $(addprefix $(TARGET_bindir)/,testparm findsmb smbtar smbclient smbpasswd)
	$(REMOVE)/$(PKG_DIR)
	$(TOUCH)

# -----------------------------------------------------------------------------

SAMBA36_VERSION = 3.6.25
SAMBA36_DIR = samba-$(SAMBA36_VERSION)
SAMBA36_SOURCE = samba-$(SAMBA36_VERSION).tar.gz
SAMBA36_SITE = https://download.samba.org/pub/samba/stable

$(DL_DIR)/$(SAMBA36_SOURCE):
	$(download) $(SAMBA36_SITE)/$(SAMBA36_SOURCE)

SAMBA36_DEPENDENCIES = zlib

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

samba36: $(SAMBA36_DEPENDENCIES) $(DL_DIR)/$(SAMBA36_SOURCE) | $(TARGET_DIR)
	$(REMOVE)/$(PKG_DIR)
	$(UNTAR)/$(PKG_SOURCE)
	$(call APPLY_PATCHES,$(PKG_PATCHES_DIR))
	$(CHDIR)/$(PKG_DIR)/source3; \
		./autogen.sh; \
		$(CONFIGURE); \
		$(MAKE); \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
	$(INSTALL) -d $(TARGET_localstatedir)/samba/locks
	$(INSTALL_DATA) -D $(PKG_FILES_DIR)/smb3.conf $(TARGET_sysconfdir)/samba/smb.conf
	$(INSTALL_EXEC) -D $(PKG_FILES_DIR)/samba3.init $(TARGET_sysconfdir)/init.d/samba
	$(UPDATE-RC.D) samba defaults 75 25
	$(TARGET_RM) $(addprefix $(TARGET_bindir)/,testparm findsmb smbtar smbclient smbpasswd)
	$(REMOVE)/$(PKG_DIR)
	$(TOUCH)

# -----------------------------------------------------------------------------

DROPBEAR_VERSION = 2019.78
DROPBEAR_DIR = dropbear-$(DROPBEAR_VERSION)
DROPBEAR_SOURCE = dropbear-$(DROPBEAR_VERSION).tar.bz2
DROPBEAR_SITE = http://matt.ucc.asn.au/dropbear/releases

$(DL_DIR)/$(DROPBEAR_SOURCE):
	$(download) $(DROPBEAR_SITE)/$(DROPBEAR_SOURCE)

DROPBEAR_DEPENDENCIES = zlib

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

dropbear: $(DROPBEAR_DEPENDENCIES) $(DL_DIR)/$(DROPBEAR_SOURCE) | $(TARGET_DIR)
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
	$(INSTALL) -d $(TARGET_sysconfdir)/dropbear
	$(INSTALL_EXEC) -D $(PKG_FILES_DIR)/dropbear.init $(TARGET_sysconfdir)/init.d/dropbear
	$(UPDATE-RC.D) dropbear defaults 75 25
	$(REMOVE)/$(PKG_DIR)
	$(TOUCH)

# -----------------------------------------------------------------------------

FBSHOT_VERSION = 0.3
FBSHOT_DIR = fbshot-$(FBSHOT_VERSION)
FBSHOT_SOURCE = fbshot-$(FBSHOT_VERSION).tar.gz
FBSHOT_SITE = http://distro.ibiblio.org/amigolinux/download/Utils/fbshot

$(DL_DIR)/$(FBSHOT_SOURCE):
	$(download) $(FBSHOT_SITE)/$(FBSHOT_SOURCE)

FBSHOT_DEPENDENCIES = libpng

fbshot: $(FBSHOT_DEPENDENCIES) $(DL_DIR)/$(FBSHOT_SOURCE) | $(TARGET_DIR)
	$(REMOVE)/$(PKG_DIR)
	$(UNTAR)/$(PKG_SOURCE)
	$(call APPLY_PATCHES,$(PKG_PATCHES_DIR))
	$(CHDIR)/$(PKG_DIR); \
		$(SED) 's|	gcc |	$(TARGET_CC) $(TARGET_CFLAGS) $(TARGET_LDFLAGS) |' Makefile; \
		$(SED) '/strip fbshot/d' Makefile; \
		$(MAKE); \
		$(INSTALL_EXEC) -D fbshot $(TARGET_bindir)/fbshot
	$(REMOVE)/$(PKG_DIR)
	$(TOUCH)

# -----------------------------------------------------------------------------

LCD4LINUX_VERSION = git
LCD4LINUX_DIR = lcd4linux.$(LCD4LINUX_VERSION)
LCD4LINUX_SOURCE = lcd4linux.$(LCD4LINUX_VERSION)
LCD4LINUX_SITE = https://github.com/TangoCash

LCD4LINUX_DEPENDENCIES = ncurses libgd libdpf

LCD4LINUX_CONF_OPTS = \
	--libdir=$(TARGET_libdir) \
	--includedir=$(TARGET_includedir) \
	--bindir=$(TARGET_bindir) \
	--docdir=$(REMOVE_docdir) \
	--with-ncurses=$(TARGET_libdir) \
	--with-drivers='DPF, SamsungSPF, PNG' \
	--with-plugins='all,!dbus,!mpris_dbus,!asterisk,!isdn,!pop3,!ppp,!seti,!huawei,!imon,!kvv,!sample,!w1retap,!wireless,!xmms,!gps,!mpd,!mysql,!qnaplog,!iconv' \

lcd4linux: $(LCD4LINUX_DEPENDENCIES) | $(TARGET_DIR)
	$(REMOVE)/$(PKG_DIR)
	$(GET_GIT_SOURCE) $(PKG_SITE)/$(PKG_SOURCE) $(DL_DIR)/$(PKG_SOURCE)
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

SAMSUNGLCD4LINUX_VERSION = git
SAMSUNGLCD4LINUX_DIR = samsunglcd4linux.$(LCD4LINUX_VERSION)
SAMSUNGLCD4LINUX_SOURCE = samsunglcd4linux.$(LCD4LINUX_VERSION)
SAMSUNGLCD4LINUX_SITE = https://github.com/horsti58

samsunglcd4linux: | $(TARGET_DIR)
	$(REMOVE)/$(PKG_DIR)
	$(GET_GIT_SOURCE) $(PKG_SITE)/$(PKG_SOURCE) $(DL_DIR)/$(PKG_SOURCE)
	$(CPDIR)/$(PKG_SOURCE)
	$(CHDIR)/$(PKG_DIR)/ni; \
		$(INSTALL) -m 0600 etc/lcd4linux.conf $(TARGET_sysconfdir); \
		$(INSTALL_COPY) share/* $(TARGET_datadir)
	$(REMOVE)/$(PKG_DIR)
	$(TOUCH)

# -----------------------------------------------------------------------------

WPA_SUPPLICANT_VERSION = 0.7.3
WPA_SUPPLICANT_DIR = wpa_supplicant-$(WPA_SUPPLICANT_VERSION)
WPA_SUPPLICANT_SOURCE = wpa_supplicant-$(WPA_SUPPLICANT_VERSION).tar.gz
WPA_SUPPLICANT_SITE = https://w1.fi/releases

$(DL_DIR)/$(WPA_SUPPLICANT_SOURCE):
	$(download) $(WPA_SUPPLICANT_SITE)/$(WPA_SUPPLICANT_SOURCE)

WPA_SUPPLICANT_DEPENDENCIES = openssl

wpa_supplicant: $(WPA_SUPPLICANT_DEPENDENCIES) $(DL_DIR)/$(WPA_SUPPLICANT_SOURCE) | $(TARGET_DIR)
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

XUPNPD_VERSION = git
XUPNPD_DIR = xupnpd.$(XUPNPD_VERSION)
XUPNPD_SOURCE = xupnpd.$(XUPNPD_VERSION)
XUPNPD_SITE = https://github.com/clark15b

XUPNPD_CHECKOUT = 25d6d44

XUPNPD_DEPENDENCIES = lua openssl

XUPNPD_MAKE_OPTS = \
	TARGET=$(TARGET) LUAFLAGS="$(TARGET_LDFLAGS) -I$(TARGET_includedir)"

define XUPNPD_TARGET_CLEANUP
	$(TARGET_RM) $(TARGET_datadir)/xupnpd/plugins/staff/xupnpd_18plus.lua
endef
XUPNPD_TARGET_FINALIZE_HOOKS += XUPNPD_TARGET_CLEANUP

define XUPNPD_INSTALL_PLUGINS
	$(INSTALL_DATA) -D $(SOURCE_DIR)/$(NI_NEUTRINO_PLUGINS)/scripts-lua/xupnpd/xupnpd_18plus.lua $(TARGET_datadir)/xupnpd/plugins/
	$(INSTALL_DATA) -D $(SOURCE_DIR)/$(NI_NEUTRINO_PLUGINS)/scripts-lua/xupnpd/xupnpd_cczwei.lua $(TARGET_datadir)/xupnpd/plugins/
	$(INSTALL_DATA) -D $(SOURCE_DIR)/$(NI_NEUTRINO_PLUGINS)/scripts-lua/xupnpd/xupnpd_neutrino.lua $(TARGET_datadir)/xupnpd/plugins/
	$(INSTALL_DATA) -D $(SOURCE_DIR)/$(NI_NEUTRINO_PLUGINS)/scripts-lua/xupnpd/xupnpd_vimeo.lua $(TARGET_datadir)/xupnpd/plugins/
	$(INSTALL_DATA) -D $(SOURCE_DIR)/$(NI_NEUTRINO_PLUGINS)/scripts-lua/xupnpd/xupnpd_youtube.lua $(TARGET_datadir)/xupnpd/plugins/
endef
XUPNPD_TARGET_FINALIZE_HOOKS += XUPNPD_INSTALL_PLUGINS

define XUPNPD_INSTALL_SKEL
	$(INSTALL_COPY) $(PKG_FILES_DIR)-skel/* $(TARGET_DIR)/
	$(UPDATE-RC.D) xupnpd defaults 75 25
endef
XUPNPD_TARGET_FINALIZE_HOOKS += XUPNPD_INSTALL_SKEL

xupnpd: $(XUPNPD_DEPENDENCIES) | $(TARGET_DIR)
	$(call DEPENDENCIES)
	$(call DOWNLOAD,$($(PKG)_SOURCE))
	$(call STARTUP)
	$(call EXTRACT,$(BUILD_DIR))
	$(call APPLY_PATCHES,$(PKG_PATCHES_DIR))
	$(CHDIR)/$(PKG_DIR); \
		$(TARGET_CONFIGURE_ENV) \
		$(MAKE) -C src $($(PKG)_MAKE_OPTS) embedded
	$(INSTALL_EXEC) -D $(PKG_BUILD_DIR)/src/xupnpd $(TARGET_bindir)/xupnpd
	$(INSTALL) -d $(TARGET_datadir)/xupnpd/config
	$(INSTALL_COPY) $(PKG_BUILD_DIR)/src/{plugins,profiles,ui,www,*.lua} $(TARGET_datadir)/xupnpd/
	$(call TARGET_FOLLOWUP)

# -----------------------------------------------------------------------------

STREAMRIPPER_DEPENDENCIES = libvorbisidec libmad glib2

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

streamripper: $(STREAMRIPPER_DEPENDENCIES) | $(TARGET_DIR)
	$(REMOVE)/$(NI_STREAMRIPPER)
	tar -C $(SOURCE_DIR) -cp $(NI_STREAMRIPPER) | tar -C $(BUILD_DIR) -x
	$(CHDIR)/$(NI_STREAMRIPPER); \
		$(CONFIGURE); \
		$(MAKE); \
		$(INSTALL_EXEC) -D streamripper $(TARGET_bindir)/streamripper
	$(INSTALL_EXEC) $(PKG_FILES_DIR)/streamripper.sh $(TARGET_bindir)/
	$(REMOVE)/$(NI_STREAMRIPPER)
	$(TOUCH)

# -----------------------------------------------------------------------------

GETTEXT_VERSION = 0.19.8.1
GETTEXT_DIR = gettext-$(GETTEXT_VERSION)
GETTEXT_SOURCE = gettext-$(GETTEXT_VERSION).tar.xz
GETTEXT_SITE = $(GNU_MIRROR)/gettext

$(DL_DIR)/$(GETTEXT_SOURCE):
	$(download) $(GETTEXT_SITE)/$(GETTEXT_SOURCE)

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

ofgwrite: $(SOURCE_DIR)/$(NI_OFGWRITE) | $(TARGET_DIR)
	$(REMOVE)/$(NI_OFGWRITE)
	tar -C $(SOURCE_DIR) -cp $(NI_OFGWRITE) | tar -C $(BUILD_DIR) -x
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

DVB_APPS_VERSION = git
DVB_APPS_DIR = dvb-apps.$(DVB_APPS_VERSION)
DVB_APPS_SOURCE = dvb-apps.$(DVB_APPS_VERSION)
DVB_APPS_SITE = https://github.com/openpli-arm

DVB_APPS_DEPENDENCIES = kernel-headers libiconv

DVB_APPS_MAKE_OPTS = \
	KERNEL_HEADERS=$(KERNEL_HEADERS_DIR) \
	enable_shared=no \
	PERL5LIB=$(PKG_BUILD_DIR)/util/scan \

dvb-apps: $(DVB_APPS_DEPENDENCIES) | $(TARGET_DIR)
	$(REMOVE)/$(PKG_DIR)
	$(GET_GIT_SOURCE) $(PKG_SITE)/$(PKG_SOURCE) $(DL_DIR)/$(PKG_SOURCE)
	$(CPDIR)/$(PKG_SOURCE)
	$(call APPLY_PATCHES,$(PKG_PATCHES_DIR))
	$(CHDIR)/$(PKG_DIR); \
		$(TARGET_CONFIGURE_ENV) LDLIBS="-liconv" \
		$(MAKE) $($(PKG)_MAKE_OPTS); \
		$(MAKE) $($(PKG)_MAKE_OPTS) install DESTDIR=$(TARGET_DIR)
	$(REMOVE)/$(PKG_DIR)
	$(TOUCH)

# -----------------------------------------------------------------------------

MINISATIP_VERSION = git
MINISATIP_DIR = minisatip.$(MINISATIP_VERSION)
MINISATIP_SOURCE = minisatip.$(MINISATIP_VERSION)
MINISATIP_SITE = https://github.com/catalinii

MINISATIP_DEPENDENCIES = libdvbcsa openssl dvb-apps

MINISATIP_CONF_OPTS = \
	--enable-static \
	--enable-enigma \
	--disable-netcv

minisatip: $(MINISATIP_DEPENDENCIES) | $(TARGET_DIR)
	$(REMOVE)/$(PKG_DIR)
	$(GET_GIT_SOURCE) $(PKG_SITE)/$(PKG_SOURCE) $(DL_DIR)/$(PKG_SOURCE)
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

GPTFDISK_VERSION = 1.0.8
GPTFDISK_DIR = gptfdisk-$(GPTFDISK_VERSION)
GPTFDISK_SOURCE = gptfdisk-$(GPTFDISK_VERSION).tar.gz
GPTFDISK_SITE = https://sourceforge.net/projects/gptfdisk/files/gptfdisk/$(GPTFDISK_VERSION)

$(DL_DIR)/$(GPTFDISK_SOURCE):
	$(download) $(GPTFDISK_SITE)/$(GPTFDISK_SOURCE)

GPTFDISK_DEPENDENCIES = popt e2fsprogs ncurses

GPTFDISK_SBINARIES = sgdisk

gptfdisk: $(GPTFDISK_DEPENDENCIES) $(DL_DIR)/$(GPTFDISK_SOURCE) | $(TARGET_DIR)
	$(REMOVE)/$(PKG_DIR)
	$(UNTAR)/$(PKG_SOURCE)
	$(call APPLY_PATCHES,$(PKG_PATCHES_DIR))
	$(CHDIR)/$(PKG_DIR); \
		$(TARGET_CONFIGURE_ENV) \
		$(MAKE) $($(PKG)_SBINARIES); \
		for sbin in $($(PKG)_SBINARIES); do \
			$(INSTALL_EXEC) -D $$sbin $(TARGET_sbindir)/$$sbin; \
		done
	$(REMOVE)/$(PKG_DIR)
	$(TOUCH)

# -----------------------------------------------------------------------------

CA_BUNDLE_SOURCE = cacert.pem
CA_BUNDLE_SITE = https://curl.se/ca

$(DL_DIR)/$(CA_BUNDLE_SOURCE):
	$(download) $(CA_BUNDLE_SITE)/$(CA_BUNDLE_SOURCE)

CA_BUNDLE_CRT = ca-certificates.crt
CA_BUNDLE_DIR = /etc/ssl/certs

ca-bundle: $(DL_DIR)/$(CA_BUNDLE_SOURCE) | $(TARGET_DIR)
	$(CD) $(DL_DIR); \
		curl --remote-name --remote-time -z $(PKG_SOURCE) $(PKG_SITE)/$(PKG_SOURCE) || true
	$(INSTALL_DATA) -D $(DL_DIR)/$(PKG_SOURCE) $(TARGET_DIR)/$(CA_BUNDLE_DIR)/$(CA_BUNDLE_CRT)
	$(TOUCH)
