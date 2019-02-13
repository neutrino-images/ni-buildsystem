#
# makefile to build armbox kernel
#
# -----------------------------------------------------------------------------

DTB		= $(BUILD_TMP)/linux-$(KERNEL_VERSION)/arch/$(BOXARCH)/boot/dts/$(KERNEL_DTB).dtb
ZIMAGE		= $(BUILD_TMP)/linux-$(KERNEL_VERSION)/arch/$(BOXARCH)/boot/zImage
ZIMAGE_DTB	= $(BUILD_TMP)/linux-$(KERNEL_VERSION)/arch/$(BOXARCH)/boot/zImage_DTB
MODULES_DIR	= $(BUILD_TMP)/linux-$(KERNEL_VERSION)-modules/lib/modules/$(KERNEL_VERSION_FULL)

KERNEL_MAKEVARS := \
	ARCH=$(BOXARCH) \
	CROSS_COMPILE=$(TARGET)- \
	INSTALL_MOD_PATH=$(BUILD_TMP)/linux-$(KERNEL_VERSION)-modules

# -----------------------------------------------------------------------------

$(D)/kernel-armbox: $(SOURCE_DIR)/$(NI_LINUX-KERNEL) | $(TARGET_DIR)
	$(REMOVE)/linux-$(KERNEL_VERSION)
	cd $(SOURCE_DIR)/$(NI_LINUX-KERNEL); \
		git checkout $(KERNEL_BRANCH)
	tar -C $(SOURCE_DIR) -cp $(NI_LINUX-KERNEL) --exclude-vcs | tar -C $(BUILD_TMP) -x
	cd $(BUILD_TMP); \
		mv $(NI_LINUX-KERNEL) linux-$(KERNEL_VERSION)
	$(CHDIR)/linux-$(KERNEL_VERSION); \
		touch .scmversion; \
		cp $(CONFIGS)/kernel-$(KERNEL_VERSION_MAJOR)-$(BOXFAMILY).config $(BUILD_TMP)/linux-$(KERNEL_VERSION)/.config; \
		$(MKDIR)/linux-$(KERNEL_VERSION)-modules; \
		$(MAKE) $(KERNEL_MAKEVARS) silentoldconfig; \
		$(MAKE) $(KERNEL_MAKEVARS) $(DTB_VER); \
		$(MAKE) $(KERNEL_MAKEVARS) zImage; \
		cat $(ZIMAGE) $(DTB) > $(ZIMAGE_DTB); \
		$(MAKE) $(KERNEL_MAKEVARS) modules; \
		$(MAKE) $(KERNEL_MAKEVARS) modules_install
	$(TOUCH)

kernel-armbox-modules: $(D)/kernel-armbox
	cp -a $(MODULES_DIR)/kernel $(TARGET_MODULES_DIR)
	cp -a $(MODULES_DIR)/modules.builtin $(TARGET_MODULES_DIR)
	cp -a $(MODULES_DIR)/modules.order $(TARGET_MODULES_DIR)
	make depmod-armbox

depmod-armbox:
	PATH=$(PATH):/sbin:/usr/sbin depmod -b $(TARGET_DIR) $(KERNEL_VERSION_FULL)
