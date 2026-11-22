################################################################################
#
# openhbbtvbrowser
#
################################################################################

OPENHBBTVBROWSER_VERSION = 3a5ea3363ba90781fb9f53688ec7ce9f8823581a
OPENHBBTVBROWSER_DIR = openhbbtvbrowser.git
OPENHBBTVBROWSER_SOURCE = openhbbtvbrowser.git
OPENHBBTVBROWSER_SITE = https://github.com/oe-alliance
OPENHBBTVBROWSER_SITE_METHOD = git

OPENHBBTVBROWSER_DEPENDENCIES = qtwebengine

# cross_compile turns on EMBEDDED_BUILD (remote control input, no desktop)
OPENHBBTVBROWSER_QMAKE_OPTS = CONFIG+=cross_compile

OPENHBBTVBROWSER_CONFIGURE_CMDS = $(QT5_QMAKE_CONFIGURE_CMDS)

# the browser, and the neutrino plugin that starts it with the application
# of the AIT of the current channel
define OPENHBBTVBROWSER_INSTALL_CMDS
	$(INSTALL_EXEC) -D $(PKG_BUILD_DIR)/openhbbtvbrowser $(TARGET_bindir)/openhbbtvbrowser
	$(INSTALL_DATA) -D $(PKG_FILES_DIR)/fonts.conf $(TARGET_sysconfdir)/openhbbtvbrowser/fonts.conf
	$(INSTALL_DATA) -D $(PKG_FILES_DIR)/hbbtv.lua $(SHARE_PLUGINS)/hbbtv.lua
	$(INSTALL_DATA) -D $(PKG_FILES_DIR)/hbbtv.cfg $(SHARE_PLUGINS)/hbbtv.cfg
endef

openhbbtvbrowser: | $(TARGET_DIR)
	$(call generic-package)
