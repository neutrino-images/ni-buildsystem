################################################################################
#
# xupnpd
#
################################################################################

XUPNPD_VERSION = 25d6d44
XUPNPD_DIR = xupnpd.git
XUPNPD_SOURCE = xupnpd.git
XUPNPD_SITE = https://github.com/clark15b
XUPNPD_SITE_METHOD = git

XUPNPD_SUBDIR = src

XUPNPD_DEPENDENCIES = lua openssl

XUPNPD_MAKE_ENV = \
	$(TARGET_CONFIGURE_ENV)

XUPNPD_MAKE_OPTS = \
	TARGET=$(GNU_TARGET_NAME) \
	LUAFLAGS="$(TARGET_LDFLAGS) \
	-I$(TARGET_includedir)" \
	embedded

define XUPNPD_INSTALL_CMDS
	$(INSTALL_EXEC) -D $(PKG_BUILD_DIR)/xupnpd $(TARGET_bindir)/xupnpd
	$(INSTALL) -d $(TARGET_datadir)/xupnpd/config
	$(INSTALL_COPY) $(PKG_BUILD_DIR)/{plugins,profiles,ui,www,*.lua} $(TARGET_datadir)/xupnpd/
endef

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
endef
XUPNPD_TARGET_FINALIZE_HOOKS += XUPNPD_INSTALL_SKEL

define XUPNPD_INSTALL_INIT_SYSV
	$(INSTALL_EXEC) -D $(PKG_FILES_DIR)/xupnpd.init $(TARGET_sysconfdir)/init.d/xupnpd
	$(UPDATE-RC.D) xupnpd defaults 75 25
endef

xupnpd: | $(TARGET_DIR)
	$(call generic-package)
