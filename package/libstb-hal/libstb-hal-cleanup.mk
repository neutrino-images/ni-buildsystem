################################################################################
#
# libstb-hal-cleanup
#
################################################################################

libstb-hal.uninstall:
	-make -C $(LIBSTB_HAL_OBJ_DIR) uninstall DESTDIR=$(TARGET_DIR)

libstb-hal.distclean:
	-make -C $(LIBSTB_HAL_OBJ_DIR) distclean

libstb-hal.clean: libstb-hal.uninstall libstb-hal.distclean
	rm -f $(LIBSTB_HAL_OBJ_DIR)/config.status
	-make libstb-hal-clean

libstb-hal.clean-all: libstb-hal.clean
	rm -rf $(LIBSTB_HAL_OBJ_DIR)
