################################################################################
#
# rtl8822bu
#
################################################################################

RTL8822BU_VERSION = 1.0.0.9-20180511a
RTL8822BU_DIR = rtl8822bu
RTL8822BU_SOURCE = rtl8822bu-driver-$(RTL8822BU_VERSION).zip
RTL8822BU_SITE = http://source.mynonpublic.com

define RTL8822BU_INSTALL_CMDS
	$(INSTALL_DATA) -D $(PKG_BUILD_DIR)/88x2bu.ko $(TARGET_modulesdir)/kernel/drivers/net/wireless/88x2bu.ko
endef

rtl8822bu: | $(TARGET_DIR)
	$(call kernel-module)
