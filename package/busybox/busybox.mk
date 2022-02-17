################################################################################
#
# busybox
#
################################################################################

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
