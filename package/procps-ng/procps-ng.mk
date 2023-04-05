################################################################################
#
# procps-ng
#
################################################################################

ifeq ($(BOXTYPE),coolstream)
PROCPS_NG_VERSION = 3.3.17
PROCPS_NG_DIR = procps-$(PROCPS_NG_VERSION)
else
PROCPS_NG_VERSION = 4.0.3
PROCPS_NG_DIR = procps-ng-$(PROCPS_NG_VERSION)
endif
PROCPS_NG_SOURCE = procps-ng-$(PROCPS_NG_VERSION).tar.xz
PROCPS_NG_SITE = http://sourceforge.net/projects/procps-ng/files/Production

PROCPS_NG_DEPENDENCIES = ncurses

PROCPS_NG_AUTORECONF = YES

PROCPS_NG_CONF_OPTS = \
	--prefix=$(base_prefix) \
	--exec_prefix=$(base_prefix) \
	--includedir=$(includedir) \
	--libdir=$(libdir) \
	--bindir=$(base_bindir).$(@F) \
	--datarootdir=$(REMOVE_datarootdir) \
	--disable-numa \
	--without-systemd

# Allows unicode characters to show in 'watch'
ifeq ($(BS_PACKAGE_NCURSES_WCHAR),y)
PROCPS_NG_CONF_OPTS += \
	--enable-watch8bit

PROCPS_NG_CONF_OPTS += \
	CPPFLAGS=-DOFF_XTRAWIDE
endif

PROCPS_NG_BINARIES = ps top

define PROCPS_NG_INSTALL_BINARIES
	$(foreach binary,$($(PKG)_BINARIES),\
		rm -f $(TARGET_base_bindir)/$(binary); \
		$(INSTALL_EXEC) -D $(TARGET_base_bindir).$(@F)/$(binary) $(TARGET_base_bindir)/$(binary); \
		rm -f $(TARGET_base_bindir).$(@F)/$(binary)$(sep) \
	)
	$(TARGET_RM) $(TARGET_base_bindir).$(@F)
endef
PROCPS_NG_TARGET_FINALIZE_HOOKS += PROCPS_NG_INSTALL_BINARIES

define PROCPS_NG_INSTALL_SYSCTL_FILES
	$(INSTALL_DATA) -D $(PKG_FILES_DIR)/sysctl.conf $(TARGET_sysconfdir)/sysctl.conf
	$(INSTALL) -d $(TARGET_sysconfdir)/sysctl.d
	$(INSTALL) -d $(TARGET_localstatedir)/etc/sysctl.d
	$(INSTALL_EXEC) -D $(PKG_FILES_DIR)/sysctl.init $(TARGET_sysconfdir)/init.d/sysctl
endef
PROCPS_NG_TARGET_FINALIZE_HOOKS += PROCPS_NG_INSTALL_SYSCTL_FILES

procps-ng: | $(TARGET_DIR)
	$(call autotools-package)
