################################################################################
#
# neutrino-plugins-cleanup
#
################################################################################

neutrino-plugins.uninstall:
	$(foreach hook,$(NEUTRINO_PLUGINS_PRE_UNINSTALL_HOOKS),$(call $(hook))$(sep))
	-make -C $(NEUTRINO_PLUGINS_OBJ_DIR) uninstall DESTDIR=$(TARGET_DIR)

neutrino-plugins.distclean:
	-make -C $(NEUTRINO_PLUGINS_OBJ_DIR) distclean

neutrino-plugins.clean: neutrino-plugins.uninstall neutrino-plugins.distclean
	rm -f $(NEUTRINO_PLUGINS_OBJ_DIR)/config.status
	-make neutrino-plugins-clean

neutrino-plugins.clean-all: neutrino-plugins.clean
	rm -rf $(NEUTRINO_PLUGINS_OBJ_DIR)
