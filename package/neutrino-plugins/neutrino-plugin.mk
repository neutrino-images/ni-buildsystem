################################################################################
#
# neutrino-plugin
#
################################################################################

# To build single plugins from neutrino-plugins repository call
# make neutrino-plugin-<subdir>; e.g. make neutrino-plugin-tuxwetter

neutrino-plugin-%: $(NEUTRINO_PLUGINS_BUILD_DIR)/config.status
	$(MAKE) -C $(NEUTRINO_PLUGINS_BUILD_DIR)/$(subst neutrino-plugin-,,$(@))
	$(MAKE) -C $(NEUTRINO_PLUGINS_BUILD_DIR)/$(subst neutrino-plugin-,,$(@)) install DESTDIR=$(TARGET_DIR)
