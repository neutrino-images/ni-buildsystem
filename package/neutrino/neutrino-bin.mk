################################################################################
#
# neutrino-bin
#
################################################################################

define NEUTRINO_BIN_BUILD
	$(MAKE) neutrino-clean neutrino NEUTRINO_PKG_FLAGS="$(PKG_NO_DOWNLOAD) $(PKG_NO_INSTALL)"
endef
NEUTRINO_BIN_INDIVIDUAL_HOOKS += NEUTRINO_BIN_BUILD

define NEUTRINO_BIN_INSTALL
	$(INSTALL_EXEC) -D $(NEUTRINO_OBJ_DIR)/src/neutrino $(TARGET_bindir)/neutrino
endef
NEUTRINO_BIN_INDIVIDUAL_HOOKS += NEUTRINO_BIN_INSTALL

ifneq ($(DEBUG),yes)
define NEUTRINO_BIN_STRIP
	$(TARGET_STRIP) $(TARGET_bindir)/neutrino
endef
NEUTRINO_BIN_TARGET_FINALIZE_HOOKS += NEUTRINO_BIN_STRIP
endif

neutrino-bin: | $(TARGET_DIR)
	$(call virtual-package)

# force build
PHONY += neutrino-bin
