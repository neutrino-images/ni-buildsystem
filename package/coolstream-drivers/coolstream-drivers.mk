################################################################################
#
# coolstream-drivers
#
################################################################################

nevis-drivers \
apollo-drivers \
shiner-drivers \
kronos-drivers \
kronos_v2-drivers: coolstream-drivers

# -----------------------------------------------------------------------------

COOLSTREAM_DRIVERS_VERSION = master
COOLSTREAM_DRIVERS_DIR = $(NI_DRIVERS_BIN)
COOLSTREAM_DRIVERS_SOURCE = $(NI_DRIVERS_BIN)
COOLSTREAM_DRIVERS_SITE = https://github.com/neutrino-images
COOLSTREAM_DRIVERS_SITE_METHOD = ni-git

define COOLSTREAM_DRIVERS_INSTALL_MODULES
	$(INSTALL) -d $(TARGET_modulesdir)
	$(INSTALL_COPY) $(PKG_BUILD_DIR)/$(DRIVERS_BIN_DIR)/lib-modules/$(KERNEL_VERSION)/. $(TARGET_modulesdir)
endef
COOLSTREAM_DRIVERS_INDIVIDUAL_HOOKS += COOLSTREAM_DRIVERS_INSTALL_MODULES

ifeq ($(BOXMODEL),nevis)
define COOLSTREAM_DRIVERS_LINKING_MODULESDIR
	ln -sf $(KERNEL_VERSION) $(TARGET_modulesdir)-$(BOXMODEL)
endef
COOLSTREAM_DRIVERS_INDIVIDUAL_HOOKS += COOLSTREAM_DRIVERS_LINKING_MODULESDIR
endif

define COOLSTREAM_DRIVERS_LINUX_RUN_DEPMOD
	$(LINUX_RUN_DEPMOD)
endef
COOLSTREAM_DRIVERS_TARGET_FINALIZE_HOOKS += COOLSTREAM_DRIVERS_LINUX_RUN_DEPMOD

coolstream-drivers: | $(TARGET_DIR)
	$(call individual-package)
