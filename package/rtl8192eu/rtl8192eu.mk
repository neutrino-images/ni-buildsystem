################################################################################
#
# rtl8192eu
#
################################################################################

RTL8192EU_VERSION = git
RTL8192EU_DIR = rtl8192eu-linux-driver.$(RTL8192EU_VERSION)
RTL8192EU_SOURCE = rtl8192eu-linux-driver.$(RTL8192EU_VERSION)
RTL8192EU_SITE = https://github.com/mange/$(RTL8192EU_SOURCE)

RTL8192EU_CHECKOUT = 60aa279428024ea78dcffe2c181ffee3cc1495f5

RTL8192EU_DEPENDENCIES = kernel-$(BOXTYPE)

define RTL8192EU_INSTALL_BINARY
	$(INSTALL_DATA) -D $(PKG_BUILD_DIR)/8192eu.ko $(TARGET_modulesdir)/kernel/drivers/net/wireless/8192eu.ko
endef
RTL8192EU_PRE_FOLLOWUP_HOOKS += RTL8192EU_INSTALL_BINARY

rtl8192eu: | $(TARGET_DIR)
	$(call kernel-module)
