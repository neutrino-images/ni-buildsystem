#
# makefile to build linux-drivers
#
# -----------------------------------------------------------------------------

RTL8192EU_VER = git
RTL8192EU_SOURCE = rtl8192eu-linux-driver.$(RTL8192EU_VER)
RTL8192EU_URL = https://github.com/mange/$(RTL8192EU_SOURCE)

rtl8192eu: kernel-$(BOXTYPE) | $(TARGET_DIR)
	$(REMOVE)/$(RTL8192EU_SOURCE)
	$(GET-GIT-SOURCE) $(RTL8192EU_URL) $(ARCHIVE)/$(RTL8192EU_SOURCE)
	$(CPDIR)/$(RTL8192EU_SOURCE)
	$(CHDIR)/$(RTL8192EU_SOURCE); \
		$(MAKE) $(KERNEL_MAKEVARS); \
		$(INSTALL_DATA) 8192eu.ko $(TARGET_MODULES_DIR)/kernel/drivers/net/wireless/
	make depmod
	$(REMOVE)/$(RTL8192EU_SOURCE)
	$(TOUCH)
