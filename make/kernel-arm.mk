# makefile to build armbox kernel

DTB		= $(BUILD_TMP)/linux-$(KERNEL_VERSION)/arch/arm/boot/dts/$(KERNEL_DTB).dtb
ZIMAGE		= $(BUILD_TMP)/linux-$(KERNEL_VERSION)/arch/arm/boot/zImage
ZIMAGE_DTB	= $(BUILD_TMP)/linux-$(KERNEL_VERSION)/arch/arm/boot/zImage_DTB
MODULES_DIR	= $(BUILD_TMP)/linux-$(KERNEL_VERSION)-modules/lib/modules/$(KERNEL_VERSION_FULL)

TARGETMODULES	= $(TARGET_LIB_DIR)/modules/$(KERNEL_VERSION_FULL)

$(D)/kernel-arm: $(SOURCE_DIR)/$(NI_LINUX-KERNEL) | $(TARGET_DIR)
	$(REMOVE)/linux-$(KERNEL_VERSION)
	cd $(SOURCE_DIR)/$(NI_LINUX-KERNEL); \
		git checkout $(KERNEL_BRANCH)
	tar -C $(SOURCE_DIR) -cp $(NI_LINUX-KERNEL) --exclude-vcs | tar -C $(BUILD_TMP) -x
	cd $(BUILD_TMP); \
		mv $(NI_LINUX-KERNEL) linux-$(KERNEL_VERSION)
	$(CHDIR)/linux-$(KERNEL_VERSION); \
		touch .scmversion; \
		cp $(CONFIGS)/kernel-4.10-$(BOXFAMILY).config $(BUILD_TMP)/linux-$(KERNEL_VERSION)/.config; \
		mkdir -p $(BUILD_TMP)/linux-$(KERNEL_VERSION)-modules; \
		$(MAKE) ARCH=arm CROSS_COMPILE=$(TARGET)- INSTALL_MOD_PATH=$(BUILD_TMP)/linux-$(KERNEL_VERSION)-modules silentoldconfig; \
		$(MAKE) ARCH=arm CROSS_COMPILE=$(TARGET)- INSTALL_MOD_PATH=$(BUILD_TMP)/linux-$(KERNEL_VERSION)-modules $(DTB_VER); \
		$(MAKE) ARCH=arm CROSS_COMPILE=$(TARGET)- INSTALL_MOD_PATH=$(BUILD_TMP)/linux-$(KERNEL_VERSION)-modules zImage; \
		cat $(ZIMAGE) $(DTB) > $(ZIMAGE_DTB); \
		$(MAKE) ARCH=arm CROSS_COMPILE=$(TARGET)- INSTALL_MOD_PATH=$(BUILD_TMP)/linux-$(KERNEL_VERSION)-modules modules; \
		$(MAKE) ARCH=arm CROSS_COMPILE=$(TARGET)- INSTALL_MOD_PATH=$(BUILD_TMP)/linux-$(KERNEL_VERSION)-modules modules_install
	$(TOUCH)

kernel-arm-modules: $(D)/kernel-arm
	cp -a $(MODULES_DIR)/kernel $(TARGETMODULES)
	cp -a $(MODULES_DIR)/modules.builtin $(TARGETMODULES)
	cp -a $(MODULES_DIR)/modules.order $(TARGETMODULES)
	make depmod-arm

depmod-arm:
	PATH=$(PATH):/sbin:/usr/sbin depmod -b $(TARGET_DIR) $(KERNEL_VERSION_FULL)
