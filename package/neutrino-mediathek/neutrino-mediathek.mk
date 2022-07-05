################################################################################
#
# neutrino-mediathek
#
################################################################################

NEUTRINO_MEDIATHEK_VERSION = git
NEUTRINO_MEDIATHEK_DIR = mediathek.$(NEUTRINO_MEDIATHEK_VERSION)
NEUTRINO_MEDIATHEK_SOURCE = mediathek.$(NEUTRINO_MEDIATHEK_VERSION)
NEUTRINO_MEDIATHEK_SITE = https://github.com/neutrino-mediathek

ifeq ($(BS_PACKAGE_NEUTRINO_MEDIATHEK_ORIGIN_NI),y)
NEUTRINO_MEDIATHEK_DEPENDENCIES = $(SOURCE_DIR)/$(NI_NEUTRINO_PLUGINS)
NEUTRINO_MEDIATHEK_ORIGIN = $(SOURCE_DIR)/$(NI_NEUTRINO_PLUGINS)/scripts-lua/plugins/mediathek
else
NEUTRINO_MEDIATHEK_ORIGIN = $(PKG_BUILD_DIR)/plugins
endif

define NEUTRINO_MEDIATHEK_INSTALL_PLUGIN
	$(INSTALL) -d $(TARGET_datadir)
	$(INSTALL_COPY) $(PKG_BUILD_DIR)/share/* $(TARGET_datadir)
	$(INSTALL) -d $(SHARE_PLUGINS)
	$(INSTALL_COPY) $($(PKG)_ORIGIN)/* $(SHARE_PLUGINS)
endef
NEUTRINO_MEDIATHEK_INDIVIDUAL_HOOKS += NEUTRINO_MEDIATHEK_INSTALL_PLUGIN

neutrino-mediathek: | $(TARGET_DIR)
	$(call individual-package)
