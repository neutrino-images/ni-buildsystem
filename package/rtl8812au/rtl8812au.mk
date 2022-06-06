################################################################################
#
# rtl8812au
#
################################################################################

RTL8812AU_VERSION = 4.3.14
RTL8812AU_DIR = rtl8812AU-driver-$(RTL8812AU_VERSION)
RTL8812AU_SOURCE = rtl8812AU-driver-$(RTL8812AU_VERSION).zip
RTL8812AU_SITE = http://source.mynonpublic.com

RTL8812AU_DEPENDENCIES = kernel-$(BOXTYPE)

define RTL8812AU_INSTALL_BINARY
	$(INSTALL_DATA) -D $(PKG_BUILD_DIR)/8812au.ko $(TARGET_modulesdir)/kernel/drivers/net/wireless/8812au.ko
endef
RTL8812AU_PRE_FOLLOWUP_HOOKS += RTL8812AU_INSTALL_BINARY

define RTL8812AU_RUN_DEPMOD
	$(LINUX_RUN_DEPMOD)
endef
RTL8812AU_TARGET_FINALIZE_HOOKS += RTL8812AU_RUN_DEPMOD

rtl8812au: | $(TARGET_DIR)
	$(call PREPARE)
	$(CHDIR)/$($(PKG)_DIR); \
		$(MAKE) $(KERNEL_MAKE_VARS)
	$(call TARGET_FOLLOWUP)
