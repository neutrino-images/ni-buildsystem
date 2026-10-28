################################################################################
#
# neutrino-cleanup
#
################################################################################

neutrino.uninstall:
	$(foreach hook,$(NEUTRINO_PRE_UNINSTALL_HOOKS),$(call $(hook))$(sep))
	-$(MAKE) -C $(NEUTRINO_OBJ_DIR) uninstall DESTDIR=$(TARGET_DIR)

neutrino.distclean:
	-$(MAKE) -C $(NEUTRINO_OBJ_DIR) distclean

neutrino.clean: neutrino.uninstall neutrino.distclean
	rm -f $(NEUTRINO_OBJ_DIR)/config.status
	-$(MAKE) neutrino-clean

neutrino.clean-all: neutrino.clean
	rm -rf $(NEUTRINO_OBJ_DIR)
