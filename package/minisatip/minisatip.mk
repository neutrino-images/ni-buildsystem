################################################################################
#
# minisatip
#
################################################################################

MINISATIP_VERSION = git
MINISATIP_DIR = minisatip.$(MINISATIP_VERSION)
MINISATIP_SOURCE = minisatip.$(MINISATIP_VERSION)
MINISATIP_SITE = https://github.com/catalinii

MINISATIP_DEPENDENCIES = libdvbcsa openssl

MINISATIP_CONF_ENV = \
	CFLAGS+=" -ldl"

MINISATIP_CONF_OPTS = \
	--enable-static \
	--disable-netcv

define MINISATIP_INSTALL
	$(INSTALL_EXEC) -D $(PKG_BUILD_DIR)/minisatip $(TARGET_bindir)/minisatip
	$(INSTALL) -d $(TARGET_datadir)/minisatip
	$(INSTALL_COPY) $(PKG_BUILD_DIR)/html $(TARGET_datadir)/minisatip
endef
MINISATIP_PRE_FOLLOWUP_HOOKS += MINISATIP_INSTALL

define MINISATIP_INSTALL_DEFAULTS
	$(INSTALL) -d $(TARGET_sysconfdir)/default
	echo 'MINISATIP_OPTS="-x 9090 -t -o /tmp/camd.socket"' > $(TARGET_sysconfdir)/default/minisatip
endef
MINISATIP_TARGET_FINALIZE_HOOKS += MINISATIP_INSTALL_DEFAULTS

define MINISATIP_INSTALL_INIT_SCRIPT
	$(INSTALL_EXEC) -D $(PKG_FILES_DIR)/minisatip.init $(TARGET_sysconfdir)/init.d/minisatip
	$(UPDATE-RC.D) minisatip defaults 75 25
endef
MINISATIP_TARGET_FINALIZE_HOOKS += MINISATIP_INSTALL_INIT_SCRIPT

minisatip: | $(TARGET_DIR)
	$(call PREPARE)
	$(call TARGET_CONFIGURE)
	$(CHDIR)/$($(PKG)_DIR); \
		$(TARGET_CONFIGURE_ENV) \
		$(MAKE)
	$(call TARGET_FOLLOWUP)
