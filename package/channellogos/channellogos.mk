################################################################################
#
# channellogos
#
################################################################################

CHANNELLOGOS_VERSION = master
CHANNELLOGOS_DIR = $(NI_LOGO_STUFF)
CHANNELLOGOS_SOURCE = $(NI_LOGO_STUFF)
CHANNELLOGOS_SITE = https://github.com/neutrino-images
CHANNELLOGOS_SITE_METHOD = ni-git

define CHANNELLOGOS_REMOVE_LOGODIR
	rm -rf $(SHARE_LOGOS)
endef
CHANNELLOGOS_INDIVIDUAL_HOOKS += CHANNELLOGOS_REMOVE_LOGODIR

define CHANNELLOGOS_INSTALL_CHANNELLOGOS
	$(INSTALL) -d $(SHARE_LOGOS)
	$(INSTALL_DATA) $($(PKG)_BUILD_DIR)/logos/* $(SHARE_LOGOS)
endef
CHANNELLOGOS_INDIVIDUAL_HOOKS += CHANNELLOGOS_INSTALL_CHANNELLOGOS

define CHANNELLOGOS_LINK_CHANNELLOGOS
	$(CD) $($(PKG)_BUILD_DIR)/logo-links; \
		./logo-linker.sh logo-links.db $(SHARE_LOGOS)
endef
CHANNELLOGOS_INDIVIDUAL_HOOKS += CHANNELLOGOS_LINK_CHANNELLOGOS

define CHANNELLOGOS_INSTALL_EVENTLOGOS
	$(INSTALL) -d $(SHARE_LOGOS)/events
	$(INSTALL_DATA) $($(PKG)_BUILD_DIR)/logos-events/* $(SHARE_LOGOS)/events
endef
CHANNELLOGOS_INDIVIDUAL_HOOKS += CHANNELLOGOS_INSTALL_EVENTLOGOS

channellogos: | $(TARGET_DIR)
	$(call individual-package)
