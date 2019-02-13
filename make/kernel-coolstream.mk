#
# makefile to build coolstream kernel
#
# -----------------------------------------------------------------------------

DTB		= $(SOURCE_DIR)/$(NI_DRIVERS-BIN)/$(BOXTYPE)/$(DRIVERS_DIR)/kernel-dtb/$(KERNEL_DTB).dtb
IMAGE		= $(BUILD_TMP)/linux-$(KERNEL_VERSION)/arch/$(BOXARCH)/boot/Image
ZIMAGE		= $(BUILD_TMP)/linux-$(KERNEL_VERSION)/arch/$(BOXARCH)/boot/zImage
MODULES_DIR	= $(BUILD_TMP)/linux-$(KERNEL_VERSION)-modules/lib/modules/$(KERNEL_VERSION_FULL)

ifneq ($(wildcard $(SKEL_ROOT)-$(BOXFAMILY)),)
  KERNEL_DESTDIR = $(SKEL_ROOT)-$(BOXFAMILY)/var/update
else
  KERNEL_DESTDIR = $(SKEL_ROOT)/var/update
endif

kernel-coolstream: kernel-coolstream-$(BOXSERIES)
kernel-coolstream-install: kernel-coolstream-install-$(BOXSERIES)

kernel-coolstream-install-all:
	make clean BOXFAMILY=nevis
	$(MAKE) kernel-coolstream-hd1 BOXFAMILY=nevis
	make kernel-coolstream-install-hd1 BOXFAMILY=nevis
	#
	make clean BOXFAMILY=apollo
	$(MAKE) kernel-coolstream-hd2 BOXFAMILY=apollo
	make kernel-coolstream-install-hd2 BOXFAMILY=apollo
	#
	make clean BOXFAMILY=kronos
	$(MAKE) kernel-coolstream-hd2 BOXFAMILY=kronos
	make kernel-coolstream-install-hd2 BOXFAMILY=kronos
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

$(D)/kernel-coolstream-hd2: $(SOURCE_DIR)/$(NI_LINUX-KERNEL) $(SOURCE_DIR)/$(NI_DRIVERS-BIN) | $(TARGET_DIR)
	$(REMOVE)/linux-$(KERNEL_VERSION)
	cd $(SOURCE_DIR)/$(NI_LINUX-KERNEL); \
		git checkout $(KERNEL_BRANCH)
	tar -C $(SOURCE_DIR) -cp $(NI_LINUX-KERNEL) --exclude-vcs | tar -C $(BUILD_TMP) -x
	cd $(BUILD_TMP); \
		mv $(NI_LINUX-KERNEL) linux-$(KERNEL_VERSION)
	$(CHDIR)/linux-$(KERNEL_VERSION); \
		touch .scmversion; \
		cp $(CONFIGS)/kernel-$(KERNEL_VERSION_MAJOR)-$(BOXFAMILY).config $(BUILD_TMP)/linux-$(KERNEL_VERSION)/.config; \
		sed -i -e 's/SUBLEVEL = 108/SUBLEVEL = 93/g' Makefile; \
		$(MKDIR)/linux-$(KERNEL_VERSION)-modules; \
		$(MAKE) ARCH=$(BOXARCH) CROSS_COMPILE=$(TARGET)- INSTALL_MOD_PATH=$(BUILD_TMP)/linux-$(KERNEL_VERSION)-modules silentoldconfig; \
		$(MAKE) ARCH=$(BOXARCH) CROSS_COMPILE=$(TARGET)- INSTALL_MOD_PATH=$(BUILD_TMP)/linux-$(KERNEL_VERSION)-modules zImage; \
		$(MAKE) ARCH=$(BOXARCH) CROSS_COMPILE=$(TARGET)- INSTALL_MOD_PATH=$(BUILD_TMP)/linux-$(KERNEL_VERSION)-modules modules; \
		$(MAKE) ARCH=$(BOXARCH) CROSS_COMPILE=$(TARGET)- INSTALL_MOD_PATH=$(BUILD_TMP)/linux-$(KERNEL_VERSION)-modules modules_install; \
		cat $(ZIMAGE) $(DTB) > zImage_DTB; \
		mkimage -A $(BOXARCH) -O linux -T kernel -C none -a 0x8000 -e 0x8000 -n "$(KERNEL_NAME)" -d zImage_DTB $(IMAGE_DIR)/kernel-$(BOXTYPE_SC)-$(BOXMODEL)-vmlinux.ub.gz
ifeq ($(BOXFAMILY), apollo)
  ifeq ($(BOXMODEL), apollo)
		cp -a $(IMAGE_DIR)/kernel-$(BOXTYPE_SC)-$(BOXMODEL)-vmlinux.ub.gz $(IMAGE_DIR)/kernel-$(BOXTYPE_SC)-shiner-vmlinux.ub.gz
  else ifeq ($(BOXMODEL), shiner)
		cp -a $(IMAGE_DIR)/kernel-$(BOXTYPE_SC)-$(BOXMODEL)-vmlinux.ub.gz $(IMAGE_DIR)/kernel-$(BOXTYPE_SC)-apollo-vmlinux.ub.gz
  endif
endif
	$(TOUCH)

kernel-coolstream-install-hd2: $(D)/kernel-coolstream-hd2
	cp -af $(IMAGE_DIR)/kernel-$(BOXTYPE_SC)-$(BOXMODEL)-vmlinux.ub.gz $(KERNEL_DESTDIR)/vmlinux.ub.gz

$(D)/kernel-coolstream-hd1: $(SOURCE_DIR)/$(NI_LINUX-KERNEL) | $(TARGET_DIR)
	$(REMOVE)/linux-$(KERNEL_VERSION)
	cd $(SOURCE_DIR)/$(NI_LINUX-KERNEL); \
		git checkout $(KERNEL_BRANCH)
	tar -C $(SOURCE_DIR) -cp $(NI_LINUX-KERNEL) --exclude-vcs | tar -C $(BUILD_TMP) -x
	cd $(BUILD_TMP); \
		mv $(NI_LINUX-KERNEL) linux-$(KERNEL_VERSION)
	$(CHDIR)/linux-$(KERNEL_VERSION); \
		touch .scmversion; \
		cp $(CONFIGS)/kernel-$(KERNEL_VERSION_MAJOR)-$(BOXFAMILY).config $(BUILD_TMP)/linux-$(KERNEL_VERSION)/.config; \
		sed -i -e 's/EXTRAVERSION = .15/EXTRAVERSION = .13/g' Makefile; \
		$(MKDIR)/linux-$(KERNEL_VERSION)-modules; \
		$(MAKE) ARCH=$(BOXARCH) CROSS_COMPILE=$(TARGET)- INSTALL_MOD_PATH=$(BUILD_TMP)/linux-$(KERNEL_VERSION)-modules silentoldconfig; \
		$(MAKE) ARCH=$(BOXARCH) CROSS_COMPILE=$(TARGET)- INSTALL_MOD_PATH=$(BUILD_TMP)/linux-$(KERNEL_VERSION)-modules zImage; \
		$(MAKE) ARCH=$(BOXARCH) CROSS_COMPILE=$(TARGET)- INSTALL_MOD_PATH=$(BUILD_TMP)/linux-$(KERNEL_VERSION)-modules modules; \
		$(MAKE) ARCH=$(BOXARCH) CROSS_COMPILE=$(TARGET)- INSTALL_MOD_PATH=$(BUILD_TMP)/linux-$(KERNEL_VERSION)-modules modules_install; \
		mkimage -A $(BOXARCH) -O linux -T kernel -C none -a 0x48000 -e 0x48000 -n "$(KERNEL_NAME)" -d $(IMAGE) $(IMAGE_DIR)/kernel-$(BOXTYPE_SC)-$(BOXMODEL)-uImage.img; \
		mkimage -A $(BOXARCH) -O linux -T kernel -C none -a 0x48000 -e 0x48000 -n "$(KERNEL_NAME)" -d $(ZIMAGE) $(IMAGE_DIR)/kernel-$(BOXTYPE_SC)-$(BOXMODEL)-zImage.img
	$(TOUCH)

kernel-coolstream-install-hd1: $(D)/kernel-coolstream-hd1
	cp -af $(IMAGE_DIR)/kernel-$(BOXTYPE_SC)-$(BOXMODEL)-zImage.img $(KERNEL_DESTDIR)/zImage

kernel-coolstream-modules: kernel-coolstream-modules-$(BOXSERIES)

kernel-coolstream-modules-hd1: kernel-coolstream
	$(TARGET)-objcopy --strip-unneeded $(MODULES_DIR)/kernel/drivers/mtd/devices/mtdram.ko
	cp -af $(MODULES_DIR)/kernel/drivers/mtd/devices/mtdram.ko $(TARGET_MODULES_DIR)
	$(TARGET)-objcopy --strip-unneeded $(MODULES_DIR)/kernel/drivers/mtd/devices/block2mtd.ko
	cp -af $(MODULES_DIR)/kernel/drivers/mtd/devices/block2mtd.ko $(TARGET_MODULES_DIR)
	$(TARGET)-objcopy --strip-unneeded $(MODULES_DIR)/kernel/drivers/net/tun.ko
	cp -af $(MODULES_DIR)/kernel/drivers/net/tun.ko $(TARGET_MODULES_DIR)
	$(TARGET)-objcopy --strip-unneeded $(MODULES_DIR)/kernel/drivers/staging/rt2870/rt2870sta.ko
	cp -af $(MODULES_DIR)/kernel/drivers/staging/rt2870/rt2870sta.ko $(TARGET_MODULES_DIR)
	$(TARGET)-objcopy --strip-unneeded $(MODULES_DIR)/kernel/drivers/usb/serial/ftdi_sio.ko
	cp -af $(MODULES_DIR)/kernel/drivers/usb/serial/ftdi_sio.ko $(TARGET_MODULES_DIR)
	$(TARGET)-objcopy --strip-unneeded $(MODULES_DIR)/kernel/drivers/usb/serial/pl2303.ko
	cp -af $(MODULES_DIR)/kernel/drivers/usb/serial/pl2303.ko $(TARGET_MODULES_DIR)
	$(TARGET)-objcopy --strip-unneeded $(MODULES_DIR)/kernel/drivers/usb/serial/usbserial.ko
	cp -af $(MODULES_DIR)/kernel/drivers/usb/serial/usbserial.ko $(TARGET_MODULES_DIR)
	$(TARGET)-objcopy --strip-unneeded $(MODULES_DIR)/kernel/fs/autofs4/autofs4.ko
	cp -af $(MODULES_DIR)/kernel/fs/autofs4/autofs4.ko $(TARGET_MODULES_DIR)
	$(TARGET)-objcopy --strip-unneeded $(MODULES_DIR)/kernel/fs/cifs/cifs.ko
	cp -af $(MODULES_DIR)/kernel/fs/cifs/cifs.ko $(TARGET_MODULES_DIR)
	$(TARGET)-objcopy --strip-unneeded $(MODULES_DIR)/kernel/fs/fuse/fuse.ko
	cp -af $(MODULES_DIR)/kernel/fs/fuse/fuse.ko $(TARGET_MODULES_DIR)
	rm -rf $(TARGET_MODULES_DIR)/usb-storage.ko # builtin already
	make depmod-hd1

kernel-coolstream-modules-hd2: kernel-coolstream
	rm -rf $(TARGET_MODULES_DIR)/kernel # nuke coolstream kernel-drivers but leave coolstream extra-drivers
	cp -a $(MODULES_DIR)/kernel $(TARGET_MODULES_DIR) # copy own kernel-drivers
	cp -a $(MODULES_DIR)/modules.builtin $(TARGET_MODULES_DIR)
	cp -a $(MODULES_DIR)/modules.order $(TARGET_MODULES_DIR)
	make depmod-hd2

depmod-hd1:
	PATH=$(PATH):/sbin:/usr/sbin depmod -b $(TARGET_DIR) $(KERNEL_VERSION_FULL)
	mv $(TARGET_MODULES_DIR)/modules.dep $(TARGET_MODULES_DIR)/.modules.dep
	rm $(TARGET_MODULES_DIR)/modules.*
	mv $(TARGET_MODULES_DIR)/.modules.dep $(TARGET_MODULES_DIR)/modules.dep

depmod-hd2:
	PATH=$(PATH):/sbin:/usr/sbin depmod -b $(TARGET_DIR) $(KERNEL_VERSION_FULL)
