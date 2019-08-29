#
# makefile to build linux-kernel
#
# -----------------------------------------------------------------------------

KERNEL_NAME		= NI $(shell echo $(BOXMODEL) | sed 's/.*/\u&/') Kernel
KERNEL_BRANCH		= ni/$(KERNEL_VERSION_MAJOR).x

KERNEL_SRC		= linux-$(KERNEL_VERSION)
KERNEL_OBJ		= linux-$(KERNEL_VERSION)-obj
KERNEL_MODULES		= linux-$(KERNEL_VERSION)-modules

KERNEL_MODULES_DIR	= $(BUILD_TMP)/$(KERNEL_MODULES)/lib/modules/$(KERNEL_VERSION)
KERNEL_CONFIG		= $(CONFIGS)/kernel-$(KERNEL_VERSION_MAJOR)-$(BOXFAMILY).config

KERNEL_UIMAGE		= $(BUILD_TMP)/$(KERNEL_OBJ)/arch/$(BOXARCH)/boot/Image
KERNEL_ZIMAGE		= $(BUILD_TMP)/$(KERNEL_OBJ)/arch/$(BOXARCH)/boot/zImage
KERNEL_ZIMAGE_DTB	= $(BUILD_TMP)/$(KERNEL_OBJ)/arch/$(BOXARCH)/boot/zImage_dtb

# -----------------------------------------------------------------------------

KERNEL_DTB = $(EMPTY)
ifeq ($(BOXSERIES)-$(BOXFAMILY), hd2-apollo)
  KERNEL_DTB = $(SOURCE_DIR)/$(NI-DRIVERS-BIN)/$(BOXTYPE)/$(DRIVERS_DIR)/kernel-dtb/hd849x.dtb
else ifeq ($(BOXSERIES)-$(BOXFAMILY), hd2-kronos)
  KERNEL_DTB = $(SOURCE_DIR)/$(NI-DRIVERS-BIN)/$(BOXTYPE)/$(DRIVERS_DIR)/kernel-dtb/en75x1.dtb
else ifeq ($(BOXSERIES), $(filter $(BOXSERIES), hd51 bre2ze4k))
  KERNEL_DTB = $(BUILD_TMP)/$(KERNEL_OBJ)/arch/$(BOXARCH)/boot/dts/bcm7445-bcm97445svmb.dtb
endif

# -----------------------------------------------------------------------------

KERNEL_MAKEVARS := \
	ARCH=$(BOXARCH) \
	CROSS_COMPILE=$(TARGET_CROSS) \
	INSTALL_MOD_PATH=$(BUILD_TMP)/$(KERNEL_MODULES) \
	LOCALVERSION= \
	O=$(BUILD_TMP)/$(KERNEL_OBJ)

# Compatibility variables
KERNEL_MAKEVARS += \
	KVER=$(KERNEL_VERSION) \
	KSRC=$(BUILD_TMP)/$(KERNEL_SRC)

KERNEL_MAKEOPTS = $(EMPTY)
ifeq ($(BOXSERIES), $(filter $(BOXSERIES), hd1 hd2))
  KERNEL_MAKEOPTS = zImage modules
else ifeq ($(BOXSERIES), $(filter $(BOXSERIES), hd51 bre2ze4k))
  KERNEL_MAKEOPTS = zImage modules $(notdir $(KERNEL_DTB))
endif

# -----------------------------------------------------------------------------

kernel.do_checkout: $(SOURCE_DIR)/$(NI-LINUX-KERNEL)
	$(CD) $(SOURCE_DIR)/$(NI-LINUX-KERNEL); \
		git checkout $(KERNEL_BRANCH)

kernel.do_prepare:
	make kernel.do_checkout
	#
	$(REMOVE)/$(KERNEL_SRC)
	$(REMOVE)/$(KERNEL_OBJ)
	$(REMOVE)/$(KERNEL_MODULES)
	tar -C $(SOURCE_DIR) -cp $(NI-LINUX-KERNEL) --exclude-vcs | tar -C $(BUILD_TMP) -x
	$(CD) $(BUILD_TMP); \
		mv $(NI-LINUX-KERNEL) $(KERNEL_SRC)
	$(MKDIR)/$(KERNEL_OBJ)
	$(MKDIR)/$(KERNEL_MODULES)
	$(INSTALL_DATA) $(KERNEL_CONFIG) $(BUILD_TMP)/$(KERNEL_OBJ)/.config
ifeq ($(BOXTYPE)-$(BOXSERIES), coolstream-hd1)
	sed -i -e 's/EXTRAVERSION = .15/EXTRAVERSION = .13/g' $(BUILD_TMP)/$(KERNEL_SRC)/Makefile
else ifeq ($(BOXTYPE)-$(BOXSERIES), coolstream-hd2)
	sed -i -e 's/SUBLEVEL = 108/SUBLEVEL = 93/g' $(BUILD_TMP)/$(KERNEL_SRC)/Makefile
else ifeq ($(BOXTYPE), armbox)
	$(INSTALL_DATA) $(PATCHES)/initramfs-subdirboot.cpio.gz $(BUILD_TMP)/$(KERNEL_OBJ)
endif
	$(TOUCH)

kernel.do_compile: kernel.do_prepare
	$(CHDIR)/$(KERNEL_SRC); \
		$(MAKE) $(KERNEL_MAKEVARS) silentoldconfig; \
		$(MAKE) $(KERNEL_MAKEVARS) $(KERNEL_MAKEOPTS); \
		$(MAKE) $(KERNEL_MAKEVARS) modules_install
ifneq ($(KERNEL_DTB), $(EMPTY))
	cat $(KERNEL_ZIMAGE) $(KERNEL_DTB) > $(KERNEL_ZIMAGE_DTB)
endif
	$(TOUCH)

# -----------------------------------------------------------------------------

kernel: kernel-$(BOXTYPE) kernel-modules-$(BOXTYPE)
	$(TOUCH)

# -----------------------------------------------------------------------------

kernel-coolstream: kernel-coolstream-$(BOXSERIES)
	$(TOUCH)

kernel-coolstream-hd1: kernel.do_compile | $(IMAGE_DIR)
	mkimage -A $(BOXARCH) -O linux -T kernel -C none -a 0x48000 -e 0x48000 -n "$(KERNEL_NAME)" -d $(KERNEL_UIMAGE) $(IMAGE_DIR)/kernel-$(BOXTYPE_SC)-$(BOXMODEL)-uImage.img
	mkimage -A $(BOXARCH) -O linux -T kernel -C none -a 0x48000 -e 0x48000 -n "$(KERNEL_NAME)" -d $(KERNEL_ZIMAGE) $(IMAGE_DIR)/kernel-$(BOXTYPE_SC)-$(BOXMODEL)-zImage.img
	$(TOUCH)

kernel-coolstream-hd2: kernel.do_compile | $(IMAGE_DIR)
	mkimage -A $(BOXARCH) -O linux -T kernel -C none -a 0x8000 -e 0x8000 -n "$(KERNEL_NAME)" -d $(KERNEL_ZIMAGE_DTB) $(IMAGE_DIR)/kernel-$(BOXTYPE_SC)-$(BOXMODEL)-vmlinux.ub.gz
ifeq ($(BOXFAMILY), apollo)
  ifeq ($(BOXMODEL), apollo)
	cp -a $(IMAGE_DIR)/kernel-$(BOXTYPE_SC)-$(BOXMODEL)-vmlinux.ub.gz $(IMAGE_DIR)/kernel-$(BOXTYPE_SC)-shiner-vmlinux.ub.gz
  else ifeq ($(BOXMODEL), shiner)
	cp -a $(IMAGE_DIR)/kernel-$(BOXTYPE_SC)-$(BOXMODEL)-vmlinux.ub.gz $(IMAGE_DIR)/kernel-$(BOXTYPE_SC)-apollo-vmlinux.ub.gz
  endif
endif
	$(TOUCH)

kernel-armbox: kernel.do_compile | $(IMAGE_DIR)
	cp -a $(KERNEL_ZIMAGE_DTB) $(IMAGE_DIR)/kernel-$(BOXTYPE_SC)-$(BOXMODEL).bin
	$(TOUCH)

# -----------------------------------------------------------------------------

kernel-modules-coolstream: kernel-modules-coolstream-$(BOXSERIES)
	$(TOUCH)

STRIP-MODULES-COOLSTREAM-HD1  =
STRIP-MODULES-COOLSTREAM-HD1 += kernel/drivers/mtd/devices/mtdram.ko
STRIP-MODULES-COOLSTREAM-HD1 += kernel/drivers/mtd/devices/block2mtd.ko
STRIP-MODULES-COOLSTREAM-HD1 += kernel/drivers/net/tun.ko
STRIP-MODULES-COOLSTREAM-HD1 += kernel/drivers/staging/rt2870/rt2870sta.ko
STRIP-MODULES-COOLSTREAM-HD1 += kernel/drivers/usb/serial/ftdi_sio.ko
STRIP-MODULES-COOLSTREAM-HD1 += kernel/drivers/usb/serial/pl2303.ko
STRIP-MODULES-COOLSTREAM-HD1 += kernel/drivers/usb/serial/usbserial.ko
STRIP-MODULES-COOLSTREAM-HD1 += kernel/fs/autofs4/autofs4.ko
STRIP-MODULES-COOLSTREAM-HD1 += kernel/fs/cifs/cifs.ko
STRIP-MODULES-COOLSTREAM-HD1 += kernel/fs/fuse/fuse.ko

kernel-modules-coolstream-hd1: kernel-coolstream
	for module in $(STRIP-MODULES-COOLSTREAM-HD1); do \
		mkdir -p $(TARGET_MODULES_DIR)/$(dir "$$module"); \
		$(TARGET_OBJCOPY) --strip-unneeded $(KERNEL_MODULES_DIR)/$$module $(TARGET_MODULES_DIR)/$$module; \
	done;
	rm -f $(TARGET_MODULES_DIR)/usb-storage.ko # already builtin
	make depmod
	$(TOUCH)

kernel-modules-coolstream-hd2: kernel-coolstream
	rm -rf $(TARGET_MODULES_DIR)/kernel # nuke coolstream kernel-drivers but leave coolstream extra-drivers
	cp -a $(KERNEL_MODULES_DIR)/kernel $(TARGET_MODULES_DIR) # copy own kernel-drivers
	cp -a $(KERNEL_MODULES_DIR)/modules.builtin $(TARGET_MODULES_DIR)
	cp -a $(KERNEL_MODULES_DIR)/modules.order $(TARGET_MODULES_DIR)
	make depmod
	make rtl8192eu
	$(TOUCH)

kernel-modules-armbox: kernel-armbox
	cp -a $(KERNEL_MODULES_DIR)/kernel $(TARGET_MODULES_DIR)
	cp -a $(KERNEL_MODULES_DIR)/modules.builtin $(TARGET_MODULES_DIR)
	cp -a $(KERNEL_MODULES_DIR)/modules.order $(TARGET_MODULES_DIR)
	make depmod
	make rtl8192eu
	$(TOUCH)

# -----------------------------------------------------------------------------

depmod:
	PATH=$(PATH):/sbin:/usr/sbin depmod -b $(TARGET_DIR) $(KERNEL_VERSION)
ifeq ($(BOXSERIES), hd1)
	mv $(TARGET_MODULES_DIR)/modules.dep $(TARGET_MODULES_DIR)/.modules.dep
	rm $(TARGET_MODULES_DIR)/modules.*
	mv $(TARGET_MODULES_DIR)/.modules.dep $(TARGET_MODULES_DIR)/modules.dep
endif

# -----------------------------------------------------------------------------

# install coolstream kernels to skel-root

ifneq ($(wildcard $(SKEL_ROOT)-$(BOXFAMILY)),)
  KERNEL_DESTDIR = $(SKEL_ROOT)-$(BOXFAMILY)/var/update
else
  KERNEL_DESTDIR = $(SKEL_ROOT)/var/update
endif

kernel-install-coolstream: kernel-install-coolstream-$(BOXSERIES)

kernel-install-coolstream-hd1: kernel-coolstream-hd1
	cp -af $(IMAGE_DIR)/kernel-$(BOXTYPE_SC)-$(BOXMODEL)-zImage.img $(KERNEL_DESTDIR)/zImage

kernel-install-coolstream-hd2: kernel-coolstream-hd2
	cp -af $(IMAGE_DIR)/kernel-$(BOXTYPE_SC)-$(BOXMODEL)-vmlinux.ub.gz $(KERNEL_DESTDIR)/vmlinux.ub.gz

kernel-install-coolstream-all:
	make clean BOXFAMILY=nevis
	$(MAKE) kernel-coolstream-hd1 BOXFAMILY=nevis
	make kernel-install-coolstream-hd1 BOXFAMILY=nevis
	#
	make clean BOXFAMILY=apollo
	$(MAKE) kernel-coolstream-hd2 BOXFAMILY=apollo
	make kernel-install-coolstream-hd2 BOXFAMILY=apollo
	#
	make clean BOXFAMILY=kronos
	$(MAKE) kernel-coolstream-hd2 BOXFAMILY=kronos
	make kernel-install-coolstream-hd2 BOXFAMILY=kronos
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

# -----------------------------------------------------------------------------

PHONY += kernel.do_checkout
