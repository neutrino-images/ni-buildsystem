################################################################################
#
# xupnpd
#
################################################################################

XUPNPD_VERSION = git
XUPNPD_DIR = xupnpd.$(XUPNPD_VERSION)
XUPNPD_SOURCE = xupnpd.$(XUPNPD_VERSION)
XUPNPD_SITE = https://github.com/clark15b

XUPNPD_SUBDIR = src

XUPNPD_CHECKOUT = 25d6d44

XUPNPD_DEPENDENCIES = lua openssl

XUPNPD_MAKE_ENV = \
	$(TARGET_CONFIGURE_ENV)

XUPNPD_MAKE_OPTS = \
	TARGET=$(TARGET) \
	LUAFLAGS="$(TARGET_LDFLAGS) \
	-I$(TARGET_includedir)" \
	embedded

define XUPNPD_INSTALL_BINARY
	$(INSTALL_EXEC) -D $(PKG_BUILD_DIR)/xupnpd $(TARGET_bindir)/xupnpd
endef
XUPNPD_PRE_FOLLOWUP_HOOKS += XUPNPD_INSTALL_BINARY

define XUPNPD_INSTALL_DATA
	$(INSTALL) -d $(TARGET_datadir)/xupnpd/config
	$(INSTALL_COPY) $(PKG_BUILD_DIR)/{plugins,profiles,ui,www,*.lua} $(TARGET_datadir)/xupnpd/
endef
XUPNPD_PRE_FOLLOWUP_HOOKS += XUPNPD_INSTALL_DATA

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

xupnpd: | $(TARGET_DIR)
	$(call generic-package,$(PKG_NO_INSTALL))
