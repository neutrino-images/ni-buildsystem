################################################################################
#
# rtl8822bu
#
################################################################################

RTL8822BU_VERSION = 1.0.0.9-20180511a
RTL8822BU_DIR = rtl8822bu
RTL8822BU_SOURCE = rtl8822bu-driver-$(RTL8822BU_VERSION).zip
RTL8822BU_SITE = http://source.mynonpublic.com

RTL8822BU_DEPENDENCIES = kernel-$(BOXTYPE)

define RTL8822BU_INSTALL_BINARY
	$(INSTALL_DATA) -D $(PKG_BUILD_DIR)/88x2bu.ko $(TARGET_modulesdir)/kernel/drivers/net/wireless/88x2bu.ko
endef
RTL8822BU_PRE_FOLLOWUP_HOOKS += RTL8822BU_INSTALL_BINARY

rtl8822bu: | $(TARGET_DIR)
	$(call kernel-module)
