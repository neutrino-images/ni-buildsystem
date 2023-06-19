################################################################################
#
# minisatip
#
################################################################################

MINISATIP_VERSION = master
MINISATIP_DIR = minisatip.git
MINISATIP_SOURCE = minisatip.git
MINISATIP_SITE = https://github.com/catalinii
MINISATIP_SITE_METHOD = git

MINISATIP_DEPENDENCIES = libdvbcsa openssl

MINISATIP_CONF_ENV = \
	CFLAGS+=" -ldl"

MINISATIP_CONF_OPTS = \
	--enable-static \
	--disable-netcv

MINISATIP_MAKE_ENV = \
	$(TARGET_CONFIGURE_ENV)

define MINISATIP_INSTALL_CMDS
	$(INSTALL_EXEC) -D $(PKG_BUILD_DIR)/minisatip $(TARGET_bindir)/minisatip
	$(INSTALL) -d $(TARGET_datadir)/minisatip
	$(INSTALL_COPY) $(PKG_BUILD_DIR)/html $(TARGET_datadir)/minisatip
endef

define MINISATIP_INSTALL_DEFAULTS
	$(INSTALL) -d $(TARGET_sysconfdir)/default
	echo 'MINISATIP_OPTS="-x 9090 -t -o /tmp/camd.socket"' > $(TARGET_sysconfdir)/default/minisatip
endef
MINISATIP_TARGET_FINALIZE_HOOKS += MINISATIP_INSTALL_DEFAULTS

define MINISATIP_INSTALL_INIT_SYSV
	$(INSTALL_EXEC) -D $(PKG_FILES_DIR)/minisatip.init $(TARGET_sysconfdir)/init.d/minisatip
	$(UPDATE-RC.D) minisatip defaults 75 25
endef

minisatip: | $(TARGET_DIR)
	$(call autotools-package)
