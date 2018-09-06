# makefile to build coolstream kernel

DTB		= $(SOURCE_DIR)/$(NI_DRIVERS-BIN)/$(DRIVERS_DIR)/device-tree-overlay/$(KERNEL_DTB).dtb
IMAGE		= $(BUILD_TMP)/linux-$(KERNEL_VERSION)/arch/arm/boot/Image
ZIMAGE		= $(BUILD_TMP)/linux-$(KERNEL_VERSION)/arch/arm/boot/zImage
MODULES_DIR	= $(BUILD_TMP)/linux-$(KERNEL_VERSION)-modules/lib/modules/$(KERNEL_VERSION_FULL)

TARGETMODULES	= $(TARGET_LIB_DIR)/modules/$(KERNEL_VERSION_FULL)

ifneq ($(wildcard $(SKEL_ROOT)-$(BOXFAMILY)),)
  KERNEL_DESTDIR = $(SKEL_ROOT)-$(BOXFAMILY)/var/update
else
  KERNEL_DESTDIR = $(SKEL_ROOT)/var/update
endif

kernel-cst: kernel-cst-$(BOXSERIES)
kernel-cst-install: kernel-cst-install-$(BOXSERIES)

kernel-cst-install-all:
	make clean BOXFAMILY=nevis
	make -j$(NUM_CPUS) kernel-cst-hd1 BOXFAMILY=nevis
	make kernel-cst-install-hd1 BOXFAMILY=nevis
	#
	make clean BOXFAMILY=apollo
	make -j$(NUM_CPUS) kernel-cst-hd2 BOXFAMILY=apollo
	make kernel-cst-install-hd2 BOXFAMILY=apollo
	#
	make clean BOXFAMILY=kronos
	make -j$(NUM_CPUS) kernel-cst-hd2 BOXFAMILY=kronos
	make kernel-cst-install-hd2 BOXFAMILY=kronos
	#
	make clean BOXFAMILY=nevis > /dev/null 2>&1
	make get-update-info-hd1 BOXFAMILY=nevis
	#
	make clean BOXFAMILY=apollo > /dev/null 2>&1
	make get-update-info-hd2 BOXFAMILY=apollo
	#
	make clean BOXFAMILY=kronos > /dev/null 2>&1
	make get-update-info-hd2 BOXFAMILY=kronos
	#
	make clean > /dev/null 2>&1

$(D)/kernel-cst-hd2: $(SOURCE_DIR)/$(NI_LINUX-KERNEL) $(SOURCE_DIR)/$(NI_DRIVERS-BIN) | $(TARGET_DIR)
	$(REMOVE)/linux-$(KERNEL_VERSION)
	cd $(SOURCE_DIR)/$(NI_LINUX-KERNEL); \
		git checkout $(KERNEL_BRANCH)
	tar -C $(SOURCE_DIR) -cp $(NI_LINUX-KERNEL) --exclude-vcs | tar -C $(BUILD_TMP) -x
	cd $(BUILD_TMP); \
		mv $(NI_LINUX-KERNEL) linux-$(KERNEL_VERSION)
	$(CHDIR)/linux-$(KERNEL_VERSION); \
		touch .scmversion; \
		cp $(CONFIGS)/kernel-3.10-$(BOXFAMILY).config $(BUILD_TMP)/linux-$(KERNEL_VERSION)/.config; \
		sed -i -e 's/SUBLEVEL = 108/SUBLEVEL = 93/g' Makefile; \
		mkdir -p $(BUILD_TMP)/linux-$(KERNEL_VERSION)-modules; \
		$(MAKE) ARCH=arm CROSS_COMPILE=$(TARGET)- INSTALL_MOD_PATH=$(BUILD_TMP)/linux-$(KERNEL_VERSION)-modules silentoldconfig; \
		$(MAKE) ARCH=arm CROSS_COMPILE=$(TARGET)- INSTALL_MOD_PATH=$(BUILD_TMP)/linux-$(KERNEL_VERSION)-modules zImage; \
		$(MAKE) ARCH=arm CROSS_COMPILE=$(TARGET)- INSTALL_MOD_PATH=$(BUILD_TMP)/linux-$(KERNEL_VERSION)-modules modules; \
		$(MAKE) ARCH=arm CROSS_COMPILE=$(TARGET)- INSTALL_MOD_PATH=$(BUILD_TMP)/linux-$(KERNEL_VERSION)-modules modules_install; \
		cat $(ZIMAGE) $(DTB) > zImage_DTB; \
		mkimage -A ARM -O linux -T kernel -C none -a 0x8000 -e 0x8000 -n "$(KERNEL_NAME)" -d zImage_DTB $(IMAGE_DIR)/kernel-$(BOXTYPE_SC)-$(BOXMODEL)-vmlinux.ub.gz
ifeq ($(BOXFAMILY), apollo)
  ifeq ($(BOXMODEL), apollo)
		cp -a $(IMAGE_DIR)/kernel-$(BOXTYPE_SC)-$(BOXMODEL)-vmlinux.ub.gz $(IMAGE_DIR)/kernel-$(BOXTYPE_SC)-shiner-vmlinux.ub.gz
  else ifeq ($(BOXMODEL), shiner)
		cp -a $(IMAGE_DIR)/kernel-$(BOXTYPE_SC)-$(BOXMODEL)-vmlinux.ub.gz $(IMAGE_DIR)/kernel-$(BOXTYPE_SC)-apollo-vmlinux.ub.gz
  endif
endif
	$(TOUCH)

kernel-cst-install-hd2: $(D)/kernel-cst-hd2
	cp -af $(IMAGE_DIR)/kernel-$(BOXTYPE_SC)-$(BOXMODEL)-vmlinux.ub.gz $(KERNEL_DESTDIR)/vmlinux.ub.gz

$(D)/kernel-cst-hd1: $(SOURCE_DIR)/$(NI_LINUX-KERNEL) | $(TARGET_DIR)
	$(REMOVE)/linux-$(KERNEL_VERSION)
	cd $(SOURCE_DIR)/$(NI_LINUX-KERNEL); \
		git checkout $(KERNEL_BRANCH)
	tar -C $(SOURCE_DIR) -cp $(NI_LINUX-KERNEL) --exclude-vcs | tar -C $(BUILD_TMP) -x
	cd $(BUILD_TMP); \
		mv $(NI_LINUX-KERNEL) linux-$(KERNEL_VERSION)
	$(CHDIR)/linux-$(KERNEL_VERSION); \
		touch .scmversion; \
		cp $(CONFIGS)/kernel-$(KERNEL_VERSION).config $(BUILD_TMP)/linux-$(KERNEL_VERSION)/.config; \
		sed -i -e 's/EXTRAVERSION = .15/EXTRAVERSION = .13/g' Makefile; \
		mkdir -p $(BUILD_TMP)/linux-$(KERNEL_VERSION)-modules; \
		$(MAKE) ARCH=arm CROSS_COMPILE=$(TARGET)- INSTALL_MOD_PATH=$(BUILD_TMP)/linux-$(KERNEL_VERSION)-modules silentoldconfig; \
		$(MAKE) ARCH=arm CROSS_COMPILE=$(TARGET)- INSTALL_MOD_PATH=$(BUILD_TMP)/linux-$(KERNEL_VERSION)-modules zImage; \
		$(MAKE) ARCH=arm CROSS_COMPILE=$(TARGET)- INSTALL_MOD_PATH=$(BUILD_TMP)/linux-$(KERNEL_VERSION)-modules modules; \
		$(MAKE) ARCH=arm CROSS_COMPILE=$(TARGET)- INSTALL_MOD_PATH=$(BUILD_TMP)/linux-$(KERNEL_VERSION)-modules modules_install; \
		mkimage -A arm -O linux -T kernel -C none -a 0x48000 -e 0x48000 -n "$(KERNEL_NAME)" -d $(IMAGE) $(IMAGE_DIR)/kernel-$(BOXTYPE_SC)-$(BOXMODEL)-uImage.img; \
		mkimage -A arm -O linux -T kernel -C none -a 0x48000 -e 0x48000 -n "$(KERNEL_NAME)" -d $(ZIMAGE) $(IMAGE_DIR)/kernel-$(BOXTYPE_SC)-$(BOXMODEL)-zImage.img
	$(TOUCH)

kernel-cst-install-hd1: $(D)/kernel-cst-hd1
	cp -af $(IMAGE_DIR)/kernel-$(BOXTYPE_SC)-$(BOXMODEL)-zImage.img $(KERNEL_DESTDIR)/zImage

kernel-cst-modules: kernel-cst-modules-$(BOXSERIES)

kernel-cst-modules-hd1: kernel-cst
	$(TARGET)-objcopy --strip-unneeded $(MODULES_DIR)/kernel/drivers/mtd/devices/mtdram.ko
	cp -af $(MODULES_DIR)/kernel/drivers/mtd/devices/mtdram.ko $(TARGETMODULES)
	$(TARGET)-objcopy --strip-unneeded $(MODULES_DIR)/kernel/drivers/mtd/devices/block2mtd.ko
	cp -af $(MODULES_DIR)/kernel/drivers/mtd/devices/block2mtd.ko $(TARGETMODULES)
	$(TARGET)-objcopy --strip-unneeded $(MODULES_DIR)/kernel/drivers/net/tun.ko
	cp -af $(MODULES_DIR)/kernel/drivers/net/tun.ko $(TARGETMODULES)
	$(TARGET)-objcopy --strip-unneeded $(MODULES_DIR)/kernel/drivers/staging/rt2870/rt2870sta.ko
	cp -af $(MODULES_DIR)/kernel/drivers/staging/rt2870/rt2870sta.ko $(TARGETMODULES)
	$(TARGET)-objcopy --strip-unneeded $(MODULES_DIR)/kernel/drivers/usb/serial/ftdi_sio.ko
	cp -af $(MODULES_DIR)/kernel/drivers/usb/serial/ftdi_sio.ko $(TARGETMODULES)
	$(TARGET)-objcopy --strip-unneeded $(MODULES_DIR)/kernel/drivers/usb/serial/pl2303.ko
	cp -af $(MODULES_DIR)/kernel/drivers/usb/serial/pl2303.ko $(TARGETMODULES)
	$(TARGET)-objcopy --strip-unneeded $(MODULES_DIR)/kernel/drivers/usb/serial/usbserial.ko
	cp -af $(MODULES_DIR)/kernel/drivers/usb/serial/usbserial.ko $(TARGETMODULES)
	$(TARGET)-objcopy --strip-unneeded $(MODULES_DIR)/kernel/fs/autofs4/autofs4.ko
	cp -af $(MODULES_DIR)/kernel/fs/autofs4/autofs4.ko $(TARGETMODULES)
	$(TARGET)-objcopy --strip-unneeded $(MODULES_DIR)/kernel/fs/cifs/cifs.ko
	cp -af $(MODULES_DIR)/kernel/fs/cifs/cifs.ko $(TARGETMODULES)
	$(TARGET)-objcopy --strip-unneeded $(MODULES_DIR)/kernel/fs/fuse/fuse.ko
	cp -af $(MODULES_DIR)/kernel/fs/fuse/fuse.ko $(TARGETMODULES)
	rm -rf $(TARGETMODULES)/usb-storage.ko # builtin already
	make depmod-hd1

kernel-cst-modules-hd2: kernel-cst
	rm -rf $(TARGETMODULES)/kernel # nuke cst kernel-drivers but leave cst extra-drivers
	cp -a $(MODULES_DIR)/kernel $(TARGETMODULES) # copy own kernel-drivers
	cp -a $(MODULES_DIR)/modules.builtin $(TARGETMODULES)
	cp -a $(MODULES_DIR)/modules.order $(TARGETMODULES)
	make depmod-hd2

depmod-hd1:
	PATH=$(PATH):/sbin:/usr/sbin depmod -b $(TARGET_DIR) $(KERNEL_VERSION_FULL)
	mv $(TARGETMODULES)/modules.dep $(TARGETMODULES)/.modules.dep
	rm $(TARGETMODULES)/modules.*
	mv $(TARGETMODULES)/.modules.dep $(TARGETMODULES)/modules.dep

depmod-hd2:
	PATH=$(PATH):/sbin:/usr/sbin depmod -b $(TARGET_DIR) $(KERNEL_VERSION_FULL)
