################################################################################
#
# rtl8812au
#
################################################################################

RTL8812AU_VERSION = 4.3.14
RTL8812AU_DIR = rtl8812AU-driver-$(RTL8812AU_VERSION)
RTL8812AU_SOURCE = rtl8812AU-driver-$(RTL8812AU_VERSION).zip
RTL8812AU_SITE = http://source.mynonpublic.com

define RTL8812AU_INSTALL_CMDS
	$(INSTALL_DATA) -D $($(PKG)_BUILD_DIR)/8812au.ko $(TARGET_modulesdir)/kernel/drivers/net/wireless/8812au.ko
endef

rtl8812au: | $(TARGET_DIR)
	$(call kernel-module)
