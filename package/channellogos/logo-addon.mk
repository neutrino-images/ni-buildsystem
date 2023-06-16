################################################################################
#
# logo-addon
#
################################################################################

LOGO_ADDON_VERSION = master
LOGO_ADDON_DIR = $(NI_LOGO_STUFF)
LOGO_ADDON_SOURCE = $(NI_LOGO_STUFF)
LOGO_ADDON_SITE = https://github.com/neutrino-images
LOGO_ADDON_SITE_METHOD = ni-git

define LOGO_ADDON_INSTALL
	$(INSTALL) -d $(SHARE_PLUGINS)
	$(INSTALL_EXEC) $($(PKG)_BUILD_DIR)/logo-addon/logo-addon.sh $(SHARE_PLUGINS)/
	$(INSTALL_DATA) $($(PKG)_BUILD_DIR)/logo-addon/logo-addon.cfg $(SHARE_PLUGINS)/
	$(INSTALL_DATA) $($(PKG)_BUILD_DIR)/logo-addon/logo-addon_hint.png $(SHARE_PLUGINS)/
endef
LOGO_ADDON_INDIVIDUAL_HOOKS += LOGO_ADDON_INSTALL

logo-addon: | $(TARGET_DIR)
	$(call individual-package)
