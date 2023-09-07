################################################################################
#
# busybox
#
################################################################################

BUSYBOX_VERSION = 1.36.1
BUSYBOX_DIR = busybox-$(BUSYBOX_VERSION)
BUSYBOX_SOURCE = busybox-$(BUSYBOX_VERSION).tar.bz2
BUSYBOX_SITE = https://busybox.net/downloads

BUSYBOX_DEPENDENCIES = libtirpc

BUSYBOX_CFLAGS = \
	$(TARGET_CFLAGS)

# Link busybox against libtirpc so that we can leverage its RPC support for NFS
# mounting with BusyBox
BUSYBOX_CFLAGS += "`$(PKG_CONFIG) --cflags libtirpc`"

# Don't use LDFLAGS for -ltirpc, because LDFLAGS is used for the non-final link
# of modules as well.
BUSYBOX_CFLAGS_busybox = "`$(PKG_CONFIG) --libs libtirpc`"

# Allows the buildsystem to tweak CFLAGS
BUSYBOX_MAKE_ENV = \
	CFLAGS="$(BUSYBOX_CFLAGS)" \
	CFLAGS_busybox="$(BUSYBOX_CFLAGS_busybox)"

BUSYBOX_MAKE_ARGS = \
	busybox

BUSYBOX_MAKE_INSTALL_ARGS = \
	install-noclobber

BUSYBOX_MAKE_OPTS = \
	$(TARGET_CONFIGURE_ENVIRONMENT) \
	CFLAGS_EXTRA="$(TARGET_CFLAGS)" \
	EXTRA_LDFLAGS="$(TARGET_LDFLAGS)" \
	CONFIG_PREFIX="$(TARGET_DIR)"

BUSYBOX_CONFIG = $(PKG_FILES_DIR)/busybox-minimal.config
BUSYBOX_BUILD_CONFIG = $(PKG_BUILD_DIR)/$($(PKG)_KCONFIG_FILE)

define BUSYBOX_INSTALL_CONFIG
	$(INSTALL_DATA) $(BUSYBOX_CONFIG) $(BUSYBOX_BUILD_CONFIG)
	$(call KCONFIG_SET_OPT,CONFIG_PREFIX,"$(TARGET_DIR)")
endef
BUSYBOX_POST_PATCH_HOOKS += BUSYBOX_INSTALL_CONFIG

# BUSYBOX_MODIFY_CONFIG start
ifeq ($(BOXSERIES),$(filter $(BOXSERIES),hd2 hd5x hd6x vusolo4k vuduo4k vuduo4kse vuultimo4k vuzero4k vuuno4k vuuno4kse vuduo))

  define BUSYBOX_SET_IPV6
	$(call KCONFIG_ENABLE_OPT,CONFIG_FEATURE_IPV6)
	$(call KCONFIG_ENABLE_OPT,CONFIG_FEATURE_IFUPDOWN_IPV6)
  endef

  ifeq ($(BOXSERIES),$(filter $(BOXSERIES),hd5x hd6x vusolo4k vuduo4k vuduo4kse vuultimo4k vuzero4k vuuno4k vuuno4kse vuduo))

    define BUSYBOX_SET_SWAP
	$(call KCONFIG_ENABLE_OPT,CONFIG_SWAPON)
	$(call KCONFIG_ENABLE_OPT,CONFIG_SWAPOFF)
    endef
    define BUSYBOX_INSTALL_SWAP_INIT_SCRIPT
	$(INSTALL_EXEC) -D $(PKG_FILES_DIR)/swap.init $(TARGET_sysconfdir)/init.d/swap
	$(UPDATE-RC.D) swap stop 98 0 6 .
    endef
    BUSYBOX_TARGET_FINALIZE_HOOKS += BUSYBOX_INSTALL_SWAP_INIT_SCRIPT

    define BUSYBOX_SET_HEXDUMP
	$(call KCONFIG_ENABLE_OPT,CONFIG_HEXDUMP)
    endef

    define BUSYBOX_SET_PKILL
	$(call KCONFIG_ENABLE_OPT,CONFIG_PKILL)
    endef

    define BUSYBOX_SET_FBSET
	$(call KCONFIG_ENABLE_OPT,CONFIG_FBSET)
	$(call KCONFIG_ENABLE_OPT,CONFIG_FEATURE_FBSET_FANCY)
	$(call KCONFIG_ENABLE_OPT,CONFIG_FEATURE_FBSET_READMODE)
    endef
    define BUSYBOX_INSTALL_FB_MODES
	$(INSTALL_DATA) -D $(PKG_FILES_DIR)/fb.modes $(TARGET_sysconfdir)/fb.modes
    endef
    BUSYBOX_TARGET_FINALIZE_HOOKS += BUSYBOX_INSTALL_FB_MODES

    ifeq ($(BOXSERIES),$(filter $(BOXSERIES),vusolo4k vuduo4k vuduo4kse vuultimo4k vuzero4k vuuno4k vuuno4kse vuduo))

      define BUSYBOX_SET_START_STOP_DAEMON
	$(call KCONFIG_ENABLE_OPT,CONFIG_START_STOP_DAEMON)
	$(call KCONFIG_ENABLE_OPT,CONFIG_FEATURE_START_STOP_DAEMON_LONG_OPTIONS)
	$(call KCONFIG_ENABLE_OPT,CONFIG_FEATURE_START_STOP_DAEMON_FANCY)
      endef

    endif

  endif

endif
# BUSYBOX_MODIFY_CONFIG end

define BUSYBOX_MODIFY_CONFIG
	$(call BUSYBOX_SET_IPV6)
	$(call BUSYBOX_SET_SWAP)
	$(call BUSYBOX_SET_HEXDUMP)
	$(call BUSYBOX_SET_PKILL)
	$(call BUSYBOX_SET_FBSET)
	$(call BUSYBOX_SET_START_STOP_DAEMON)
endef
BUSYBOX_POST_PATCH_HOOKS += BUSYBOX_MODIFY_CONFIG

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
BUSYBOX_POST_INSTALL_HOOKS += BUSYBOX_ADD_TO_SHELLS

ifeq ($(PERSISTENT_VAR_PARTITION),yes)
define BUSYBOX_INSTALL_LINK_RESOLV_CONF
	ln -sf /var/etc/resolv.conf $(TARGET_sysconfdir)/resolv.conf
endef
BUSYBOX_TARGET_FINALIZE_HOOKS += BUSYBOX_INSTALL_LINK_RESOLV_CONF
endif

define BUSYBOX_INSTALL_UDHCPC_DEFAULT_SCRIPT
	$(INSTALL_EXEC) -D $(PKG_FILES_DIR)/udhcpc-default.script $(TARGET_datadir)/udhcpc/default.script
endef
BUSYBOX_TARGET_FINALIZE_HOOKS += BUSYBOX_INSTALL_UDHCPC_DEFAULT_SCRIPT

define BUSYBOX_INSTALL_CROND
	$(INSTALL_EXEC) -D $(PKG_FILES_DIR)/crond.init $(TARGET_sysconfdir)/init.d/crond
	$(UPDATE-RC.D) crond defaults 50
	$(INSTALL) -d $(TARGET_localstatedir)/spool/cron/crontabs
	$(INSTALL) -d $(TARGET_sysconfdir)/cron.{daily,hourly,monthly,weekly}
endef
BUSYBOX_TARGET_FINALIZE_HOOKS += BUSYBOX_INSTALL_CROND

define BUSYBOX_INSTALL_INETD
	$(INSTALL_DATA) -D $(PKG_FILES_DIR)/inetd.conf $(TARGET_sysconfdir)/inetd.conf
	$(INSTALL_EXEC) -D $(PKG_FILES_DIR)/inetd.init $(TARGET_sysconfdir)/init.d/inetd
	$(UPDATE-RC.D) inetd defaults 50
endef
BUSYBOX_TARGET_FINALIZE_HOOKS += BUSYBOX_INSTALL_INETD

define BUSYBOX_INSTALL_SYSLOGD
	$(INSTALL_EXEC) -D $(PKG_FILES_DIR)/syslogd.init $(TARGET_sysconfdir)/init.d/syslogd
	$(UPDATE-RC.D) syslogd stop 98 0 6 .
endef
BUSYBOX_TARGET_FINALIZE_HOOKS += BUSYBOX_INSTALL_SYSLOGD

define BUSYBOX_MAKE_MDEV
	$(MAKE) mdev
endef
BUSYBOX_TARGET_FINALIZE_HOOKS += BUSYBOX_MAKE_MDEV

define BUSYBOX_MAKE_IFUPDOWN_SCRIPTS
	$(MAKE) ifupdown-scripts
endef
BUSYBOX_TARGET_FINALIZE_HOOKS += BUSYBOX_MAKE_IFUPDOWN_SCRIPTS

busybox: | $(TARGET_DIR)
	$(call kconfig-package)
