################################################################################
#
# firmware
#
################################################################################

FIRMWARE_VERSION = ni-git
FIRMWARE_DIR = $(NI_DRIVERS_BIN)
FIRMWARE_SOURCE = $(NI_DRIVERS_BIN)
FIRMWARE_SITE = https://github.com/neutrino-images

define FIRMWARE_INSTALL
	$(call INSTALL_EXIST,$(SOURCE_DIR)/$(NI_DRIVERS_BIN)/$(DRIVERS_BIN_DIR)/lib-firmware/.,$(TARGET_base_libdir)/firmware)
	$(call INSTALL_EXIST,$(SOURCE_DIR)/$(NI_DRIVERS_BIN)/$(DRIVERS_BIN_DIR)/lib-firmware-dvb/.,$(TARGET_base_libdir)/firmware)
endef
FIRMWARE_INDIVIDUAL_HOOKS += FIRMWARE_INSTALL

ifeq ($(BOXMODEL),nevis)
FIRMWARE_WIRELESS  = rt2870.bin
FIRMWARE_WIRELESS += rt3070.bin
FIRMWARE_WIRELESS += rt3071.bin
FIRMWARE_WIRELESS += rtlwifi/rtl8192cufw.bin
FIRMWARE_WIRELESS += rtlwifi/rtl8712u.bin
else
FIRMWARE_WIRELESS  = $(shell cd $(SOURCE_DIR)/$(NI_DRIVERS_BIN)/general/firmware-wireless; find * -type f)
endif

define FIRMWARE_WIRELESS_INSTALL
	$(foreach f,$(FIRMWARE_WIRELESS),
		$(INSTALL_DATA) -D $(SOURCE_DIR)/$(NI_DRIVERS_BIN)/general/firmware-wireless/$(f) $(TARGET_base_libdir)/firmware/$(f))
endef
FIRMWARE_INDIVIDUAL_HOOKS += FIRMWARE_WIRELESS_INSTALL

firmware: | $(TARGET_DIR)
	$(call individual-package)
