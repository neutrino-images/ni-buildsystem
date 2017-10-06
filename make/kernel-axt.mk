# makefile to build axtech kernel

DTB_VER		= bcm7445-bcm97445svmb.dtb

DTB		= $(BUILD_TMP)/linux-$(KVERSION)/arch/arm/boot/dts/$(DTB_VER)
ZIMAGE		= $(BUILD_TMP)/linux-$(KVERSION)/arch/arm/boot/zImage
ZIMAGE_DTB	= $(BUILD_TMP)/linux-$(KVERSION)/arch/arm/boot/zImage_DTB
MODULES_DIR	= $(BUILD_TMP)/linux-$(KVERSION)-modules/lib/modules/$(KVERSION_FULL)

TARGETMODULES	= $(TARGETLIB)/modules/$(KVERSION_FULL)

$(D)/kernel-axt: $(SOURCE_DIR)/$(NI_LINUX-KERNEL) | $(TARGETPREFIX)
	cd $(SOURCE_DIR)/$(NI_LINUX-KERNEL) && \
		git checkout $(KBRANCH) && \
	tar -C $(SOURCE_DIR) -cp $(NI_LINUX-KERNEL) --exclude-vcs | tar -C $(BUILD_TMP) -x
	cd $(BUILD_TMP) && \
	mv $(NI_LINUX-KERNEL) linux-$(KVERSION) && \
	cd $(BUILD_TMP)/linux-$(KVERSION) && \
	touch .scmversion && \
	cp $(CONFIGS)/kernel-4.10-$(BOXFAMILY).config $(BUILD_TMP)/linux-$(KVERSION)/.config && \
	mkdir -p $(BUILD_TMP)/linux-$(KVERSION)-modules && \
		$(MAKE) ARCH=arm CROSS_COMPILE=$(TARGET)- INSTALL_MOD_PATH=$(BUILD_TMP)/linux-$(KVERSION)-modules silentoldconfig && \
		$(MAKE) ARCH=arm CROSS_COMPILE=$(TARGET)- INSTALL_MOD_PATH=$(BUILD_TMP)/linux-$(KVERSION)-modules $(DTB_VER) && \
		$(MAKE) ARCH=arm CROSS_COMPILE=$(TARGET)- INSTALL_MOD_PATH=$(BUILD_TMP)/linux-$(KVERSION)-modules zImage && \
		cat $(ZIMAGE) $(DTB) > $(ZIMAGE_DTB) && \
		$(MAKE) ARCH=arm CROSS_COMPILE=$(TARGET)- INSTALL_MOD_PATH=$(BUILD_TMP)/linux-$(KVERSION)-modules modules && \
		$(MAKE) ARCH=arm CROSS_COMPILE=$(TARGET)- INSTALL_MOD_PATH=$(BUILD_TMP)/linux-$(KVERSION)-modules modules_install && \
	touch $@

kernel-axt-modules: $(D)/kernel-axt
	cp -a $(MODULES_DIR)/kernel $(TARGETMODULES)
	cp -a $(MODULES_DIR)/modules.builtin $(TARGETMODULES)
	cp -a $(MODULES_DIR)/modules.order $(TARGETMODULES)
	make depmod-axt

depmod-axt:
	PATH=$(PATH):/sbin:/usr/sbin depmod -b $(TARGETPREFIX) $(KVERSION_FULL)
