#
# makefile to generate images
#
# -----------------------------------------------------------------------------

MKFSFLAGS	= -U -D $(BUILD_TMP)/devtable-$(BOXSERIES).txt -r $(ROOTFS)
ifeq ($(BOXSERIES), hd1)
  MKFSFLAGS	+= -p
endif
ifeq ($(BOXSERIES), hd2)
  MKFSFLAGS	+= -n -l
endif

ifeq ($(BOXSERIES), hd1)
  SUMFLAGS	= -p
endif
ifeq ($(BOXSERIES), hd2)
  SUMFLAGS	= -n -l
endif

# -----------------------------------------------------------------------------

devtable: $(BUILD_TMP)/devtable-$(BOXSERIES).txt

$(BUILD_TMP)/devtable-hd1.txt:
	#	<name>		<type>	<mode>	<uid>	<gid>	<major>	<minor>	<start>	<inc>	<count>
	echo	"/dev/pts	d	755	0	0	-	-	-	-	-"	 > $(@)
	echo	"/dev/shm	d	755	0	0	-	-	-	-	-"	>> $(@)
	echo	"/dev/shm/usb	d	755	0	0	-	-	-	-	-"	>> $(@)
	echo	"/dev/null	c	666	0	0	1	3	0	0	-"	>> $(@)
	echo	"/dev/console	c	666	0	0	5	1	-	-	-"	>> $(@)
	echo	"/dev/ttyRI0	c	666	0	0	204	16	-	-	-"	>> $(@)
	echo	"/dev/mtd	c	640	0	0	90	0	0	2	6"	>> $(@)
	echo	"/dev/mtdblock	b	640	0	0	31	0	0	1	6"	>> $(@)

$(BUILD_TMP)/devtable-hd2.txt:
	#	<name>		<type>	<mode>	<uid>	<gid>	<major>	<minor>	<start>	<inc>	<count>
	echo	"/dev/pts	d	755	0	0	-	-	-	-	-"	 > $(@)
	echo	"/dev/shm	d	755	0	0	-	-	-	-	-"	>> $(@)
	echo	"/dev/shm/usb	d	755	0	0	-	-	-	-	-"	>> $(@)
	echo	"/dev/null	c	666	0	0	1	3	0	0	-"	>> $(@)
	echo	"/dev/console	c	666	0	0	5	1	-	-	-"	>> $(@)
	echo	"/dev/ttyS0	c	666	0	0	4	64	-	-	-"	>> $(@)
	echo	"/dev/mtd	c	640	0	0	90	0	0	2	9"	>> $(@)
	echo	"/dev/mtdblock	b	640	0	0	31	0	0	1	9"	>> $(@)

devtable-remove:
	$(REMOVE)/devtable-$(BOXSERIES).txt

# -----------------------------------------------------------------------------

flash-image:
ifeq ($(BOXMODEL), $(filter $(BOXMODEL), nevis kronos kronos_v2))
	make flash-image-coolstream ERASE_SIZE=0x20000
endif
ifeq ($(BOXMODEL), $(filter $(BOXMODEL), apollo shiner))
	make flash-image-coolstream ERASE_SIZE=0x40000 IMAGE_SUFFIX=$(BOXTYPE_SC)-apollo
	make flash-image-coolstream ERASE_SIZE=0x20000 IMAGE_SUFFIX=$(BOXTYPE_SC)-shiner
endif
ifeq ($(BOXMODEL), $(filter $(BOXMODEL), hd51 bre2ze4k h7))
	make flash-image-hd51
	make flash-image-hd51-multi
endif
ifeq ($(BOXMODEL), $(filter $(BOXMODEL), hd60 hd61))
	make flash-image-hd6x
	make flash-image-hd6x-multi
endif
ifeq ($(BOXMODEL), $(filter $(BOXMODEL), vusolo4k vuduo4k vuduo4kse vuultimo4k vuzero4k vuuno4k vuuno4kse))
	make flash-image-vuplus
	make flash-image-vuplus-multi
endif
ifeq ($(BOXMODEL), $(filter $(BOXMODEL), vuduo))
	make flash-image-vuduo
endif

# -----------------------------------------------------------------------------

flash-image-coolstream: IMAGE_DATE=$(shell cat $(ROOTFS)/.version | grep "^version=" | cut -d= -f2 | cut -c 5-)
flash-image-coolstream: | $(IMAGE_DIR)
	make devtable
	mkfs.jffs2 -e $(ERASE_SIZE) $(MKFSFLAGS) -o $(IMAGE_DIR)/$(IMAGE_NAME).img
	make devtable-remove
ifeq ($(IMAGE_SUMMARIZE), yes)
	sumtool -e $(ERASE_SIZE) $(SUMFLAGS) -i $(IMAGE_DIR)/$(IMAGE_NAME).img -o $(IMAGE_DIR)/$(IMAGE_NAME)-sum.img
	rm -f $(IMAGE_DIR)/$(IMAGE_NAME).img
	mv $(IMAGE_DIR)/$(IMAGE_NAME)-sum.img $(IMAGE_DIR)/$(IMAGE_NAME).img
endif
	echo $(IMAGE_SITE)/$(IMAGE_NAME).img $(IMAGE_TYPE)$(IMAGE_VER)$(IMAGE_DATE) `md5sum $(IMAGE_DIR)/$(IMAGE_NAME).img | cut -c1-32` $(IMAGE_DESC) $(IMAGE_VERSION) >> $(IMAGE_DIR)/$(IMAGE_MD5FILE)
	make check-image-size IMAGE_TO_CHECK=$(IMAGE_DIR)/$(IMAGE_NAME).img

# -----------------------------------------------------------------------------

# ROOTFS_SIZE detected with 'df -k'
ifeq ($(BOXMODEL), nevis)
  ROOTFS_SIZE = 28160
else ifeq ($(BOXMODEL), $(filter $(BOXMODEL), apollo shiner kronos))
  ROOTFS_SIZE = 262144
else ifeq ($(BOXMODEL), kronos_v2)
  ROOTFS_SIZE = 57344
endif
ifdef ROOTFS_SIZE
  ROOTFS_SIZE := $$(( $(ROOTFS_SIZE)*1024 ))
endif

check-image-size:
ifdef IMAGE_TO_CHECK
	@IMAGE_SIZE=$(shell wc -c < $(IMAGE_TO_CHECK)); \
	if [ $$IMAGE_SIZE -ge $(ROOTFS_SIZE) ]; then \
		echo -e "$(TERM_RED_BOLD)$(IMAGE_TO_CHECK) is too big$(TERM_NORMAL)"; \
		false; \
	fi
endif

# -----------------------------------------------------------------------------

flash-image-hd51: IMAGE_DATE=$(shell cat $(ROOTFS)/.version | grep "^version=" | cut -d= -f2 | cut -c 5-)
flash-image-hd51: | $(IMAGE_DIR)
	rm -rf $(IMAGE_BUILD_TMP)
	mkdir -p $(IMAGE_BUILD_TMP)/$(IMAGE_SUBDIR)
	cp $(KERNEL_ZIMAGE_DTB) $(IMAGE_BUILD_TMP)/$(IMAGE_SUBDIR)/kernel.bin
	$(CD) $(ROOTFS); \
		tar -cvf $(IMAGE_BUILD_TMP)/$(IMAGE_SUBDIR)/rootfs.tar -C $(ROOTFS) . >/dev/null 2>&1; \
		bzip2 $(IMAGE_BUILD_TMP)/$(IMAGE_SUBDIR)/rootfs.tar
	# Create minimal image
	$(CD) $(IMAGE_BUILD_TMP)/$(IMAGE_SUBDIR); \
		tar -czf $(IMAGE_DIR)/$(IMAGE_NAME).tgz kernel.bin rootfs.tar.bz2
	echo $(IMAGE_SITE)/$(IMAGE_NAME).tgz $(IMAGE_TYPE)$(IMAGE_VER)$(IMAGE_DATE) `md5sum $(IMAGE_DIR)/$(IMAGE_NAME).tgz | cut -c1-32` $(IMAGE_DESC) $(IMAGE_VERSION) >> $(IMAGE_DIR)/$(IMAGE_MD5FILE)
	rm -rf $(IMAGE_BUILD_TMP)

# -----------------------------------------------------------------------------

# hd51, bre2ze4k, h7
HD51_IMAGE_NAME = disk
HD51_BOOT_IMAGE = boot.img
HD51_IMAGE_LINK = $(HD51_IMAGE_NAME).ext4

# emmc image
EMMC_IMAGE_SIZE = 3817472
EMMC_IMAGE = $(IMAGE_BUILD_TMP)/$(HD51_IMAGE_NAME).img

BLOCK_SIZE = 512
BLOCK_SECTOR = 2

# partition offsets/sizes
IMAGE_ROOTFS_ALIGNMENT = 1024
BOOT_PARTITION_SIZE = 3072

KERNEL_PARTITION_OFFSET = "$(shell expr $(IMAGE_ROOTFS_ALIGNMENT) \+ $(BOOT_PARTITION_SIZE))"
KERNEL_PARTITION_SIZE = 8192

ROOTFS_PARTITION_OFFSET = "$(shell expr $(KERNEL_PARTITION_OFFSET) \+ $(KERNEL_PARTITION_SIZE))"
ROOTFS_PARTITION_SIZE = 1048576

SECOND_KERNEL_PARTITION_OFFSET = "$(shell expr $(ROOTFS_PARTITION_OFFSET) \+ $(ROOTFS_PARTITION_SIZE))"
THIRD_KERNEL_PARTITION_OFFSET = "$(shell expr $(SECOND_KERNEL_PARTITION_OFFSET) \+ $(KERNEL_PARTITION_SIZE))"
FOURTH_KERNEL_PARTITION_OFFSET = "$(shell expr $(THIRD_KERNEL_PARTITION_OFFSET) \+ $(KERNEL_PARTITION_SIZE))"

# USERDATA_PARTITION values
MULTI_ROOTFS_PARTITION_OFFSET = "$(shell expr $(FOURTH_KERNEL_PARTITION_OFFSET) \+ $(KERNEL_PARTITION_SIZE))"
MULTI_ROOTFS_PARTITION_SIZE = 2321408 # 2731008 - 204800 - 204800

LINUX_SWAP_PARTITION_OFFSET = "$(shell expr $(MULTI_ROOTFS_PARTITION_OFFSET) \+ $(MULTI_ROOTFS_PARTITION_SIZE))"
LINUX_SWAP_PARTITION_SIZE = 204800

STORAGE_PARTITION_OFFSET = "$(shell expr $(LINUX_SWAP_PARTITION_OFFSET) \+ $(LINUX_SWAP_PARTITION_SIZE))"
#STORAGE_PARTITION_SIZE = 204800 # remaining flash memory

flash-image-hd51-multi: | $(IMAGE_DIR)
	rm -rf $(IMAGE_BUILD_TMP)
	mkdir -p $(IMAGE_BUILD_TMP)
	# Create a sparse image block
	dd if=/dev/zero of=$(IMAGE_BUILD_TMP)/$(HD51_IMAGE_LINK) seek=$(shell expr $(ROOTFS_PARTITION_SIZE) \* $(BLOCK_SECTOR)) count=0 bs=$(BLOCK_SIZE)
	mkfs.ext4 -v -F $(IMAGE_BUILD_TMP)/$(HD51_IMAGE_LINK) -d $(ROOTFS)/..
	# Error codes 0-3 indicate successfull operation of fsck (no errors or errors corrected)
	fsck.ext4 -pvfD $(IMAGE_BUILD_TMP)/$(HD51_IMAGE_LINK) || [ $? -le 3 ]
	dd if=/dev/zero of=$(EMMC_IMAGE) bs=$(BLOCK_SIZE) count=0 seek=$(shell expr $(EMMC_IMAGE_SIZE) \* $(BLOCK_SECTOR))
	parted -s $(EMMC_IMAGE) mklabel gpt
	parted -s $(EMMC_IMAGE) unit KiB mkpart boot fat16 $(IMAGE_ROOTFS_ALIGNMENT) $(shell expr $(IMAGE_ROOTFS_ALIGNMENT) \+ $(BOOT_PARTITION_SIZE))
	parted -s $(EMMC_IMAGE) unit KiB mkpart linuxkernel $(KERNEL_PARTITION_OFFSET) $(shell expr $(KERNEL_PARTITION_OFFSET) \+ $(KERNEL_PARTITION_SIZE))
	parted -s $(EMMC_IMAGE) unit KiB mkpart linuxrootfs ext4 $(ROOTFS_PARTITION_OFFSET) $(shell expr $(ROOTFS_PARTITION_OFFSET) \+ $(ROOTFS_PARTITION_SIZE))
	parted -s $(EMMC_IMAGE) unit KiB mkpart linuxkernel2 $(SECOND_KERNEL_PARTITION_OFFSET) $(shell expr $(SECOND_KERNEL_PARTITION_OFFSET) \+ $(KERNEL_PARTITION_SIZE))
	parted -s $(EMMC_IMAGE) unit KiB mkpart linuxkernel3 $(THIRD_KERNEL_PARTITION_OFFSET) $(shell expr $(THIRD_KERNEL_PARTITION_OFFSET) \+ $(KERNEL_PARTITION_SIZE))
	parted -s $(EMMC_IMAGE) unit KiB mkpart linuxkernel4 $(FOURTH_KERNEL_PARTITION_OFFSET) $(shell expr $(FOURTH_KERNEL_PARTITION_OFFSET) \+ $(KERNEL_PARTITION_SIZE))
	parted -s $(EMMC_IMAGE) unit KiB mkpart userdata ext4 $(MULTI_ROOTFS_PARTITION_OFFSET) $(shell expr $(MULTI_ROOTFS_PARTITION_OFFSET) \+ $(MULTI_ROOTFS_PARTITION_SIZE))
	parted -s $(EMMC_IMAGE) unit KiB mkpart swap linux-swap $(LINUX_SWAP_PARTITION_OFFSET) $(shell expr $(LINUX_SWAP_PARTITION_OFFSET) \+ $(LINUX_SWAP_PARTITION_SIZE))
	parted -s $(EMMC_IMAGE) unit KiB mkpart storage ext4 $(STORAGE_PARTITION_OFFSET) 100%
	dd if=/dev/zero of=$(IMAGE_BUILD_TMP)/$(HD51_BOOT_IMAGE) bs=$(BLOCK_SIZE) count=$(shell expr $(BOOT_PARTITION_SIZE) \* $(BLOCK_SECTOR))
	mkfs.msdos -S 512 $(IMAGE_BUILD_TMP)/$(HD51_BOOT_IMAGE)
	echo "boot emmcflash0.linuxkernel  'root=/dev/mmcblk0p3 rootsubdir=linuxrootfs1 kernel=/dev/mmcblk0p2 rw rootwait $(BOXMODEL)_4.boxmode=1'" > $(IMAGE_BUILD_TMP)/STARTUP
	echo "boot emmcflash0.linuxkernel  'root=/dev/mmcblk0p3 rootsubdir=linuxrootfs1 kernel=/dev/mmcblk0p2 rw rootwait $(BOXMODEL)_4.boxmode=1'" > $(IMAGE_BUILD_TMP)/STARTUP_1
	echo "boot emmcflash0.linuxkernel2 'root=/dev/mmcblk0p7 rootsubdir=linuxrootfs2 kernel=/dev/mmcblk0p4 rw rootwait $(BOXMODEL)_4.boxmode=1'" > $(IMAGE_BUILD_TMP)/STARTUP_2
	echo "boot emmcflash0.linuxkernel3 'root=/dev/mmcblk0p7 rootsubdir=linuxrootfs3 kernel=/dev/mmcblk0p5 rw rootwait $(BOXMODEL)_4.boxmode=1'" > $(IMAGE_BUILD_TMP)/STARTUP_3
	echo "boot emmcflash0.linuxkernel4 'root=/dev/mmcblk0p7 rootsubdir=linuxrootfs4 kernel=/dev/mmcblk0p6 rw rootwait $(BOXMODEL)_4.boxmode=1'" > $(IMAGE_BUILD_TMP)/STARTUP_4
	mcopy -i $(IMAGE_BUILD_TMP)/$(HD51_BOOT_IMAGE) -v $(IMAGE_BUILD_TMP)/STARTUP ::
	mcopy -i $(IMAGE_BUILD_TMP)/$(HD51_BOOT_IMAGE) -v $(IMAGE_BUILD_TMP)/STARTUP_1 ::
	mcopy -i $(IMAGE_BUILD_TMP)/$(HD51_BOOT_IMAGE) -v $(IMAGE_BUILD_TMP)/STARTUP_2 ::
	mcopy -i $(IMAGE_BUILD_TMP)/$(HD51_BOOT_IMAGE) -v $(IMAGE_BUILD_TMP)/STARTUP_3 ::
	mcopy -i $(IMAGE_BUILD_TMP)/$(HD51_BOOT_IMAGE) -v $(IMAGE_BUILD_TMP)/STARTUP_4 ::
	dd conv=notrunc if=$(IMAGE_BUILD_TMP)/$(HD51_BOOT_IMAGE) of=$(EMMC_IMAGE) bs=$(BLOCK_SIZE) seek=$(shell expr $(IMAGE_ROOTFS_ALIGNMENT) \* $(BLOCK_SECTOR))
	dd conv=notrunc if=$(KERNEL_ZIMAGE_DTB) of=$(EMMC_IMAGE) bs=$(BLOCK_SIZE) seek=$(shell expr $(KERNEL_PARTITION_OFFSET) \* $(BLOCK_SECTOR))
	resize2fs $(IMAGE_BUILD_TMP)/$(HD51_IMAGE_LINK) $(ROOTFS_PARTITION_SIZE)k
	# Truncate on purpose
	dd if=$(IMAGE_BUILD_TMP)/$(HD51_IMAGE_LINK) of=$(EMMC_IMAGE) bs=$(BLOCK_SIZE) seek=$(shell expr $(ROOTFS_PARTITION_OFFSET) \* $(BLOCK_SECTOR))
	# Create final USB-image
	mkdir -p $(IMAGE_BUILD_TMP)/$(IMAGE_SUBDIR)
	cp $(EMMC_IMAGE) $(IMAGE_BUILD_TMP)/$(IMAGE_SUBDIR)
	cp $(TARGET_FILES)/splash-images/ni-splash.bmp $(IMAGE_BUILD_TMP)/$(IMAGE_SUBDIR)/splash.bin
	cp $(KERNEL_ZIMAGE_DTB) $(IMAGE_BUILD_TMP)/$(IMAGE_SUBDIR)/kernel.bin
	$(CD) $(ROOTFS); \
		tar -cvf $(IMAGE_BUILD_TMP)/$(IMAGE_SUBDIR)/rootfs.tar -C $(ROOTFS) . >/dev/null 2>&1; \
		bzip2 $(IMAGE_BUILD_TMP)/$(IMAGE_SUBDIR)/rootfs.tar
	echo $(IMAGE_PREFIX) > $(IMAGE_BUILD_TMP)/$(IMAGE_SUBDIR)/imageversion
	$(CD) $(IMAGE_BUILD_TMP); \
		zip -r $(IMAGE_DIR)/$(IMAGE_NAME)_multi_usb.zip $(IMAGE_SUBDIR)/*
	rm -rf $(IMAGE_BUILD_TMP)

# -----------------------------------------------------------------------------

# hd60, hd61
flash-image-hd6x: IMAGE_DATE=$(shell cat $(ROOTFS)/.version | grep "^version=" | cut -d= -f2 | cut -c 5-)
flash-image-hd6x: | $(IMAGE_DIR)
	rm -rf $(IMAGE_BUILD_TMP)
	mkdir -p $(IMAGE_BUILD_TMP)/$(IMAGE_SUBDIR)
	cp $(KERNEL_ZIMAGE_DTB) $(IMAGE_BUILD_TMP)/$(IMAGE_SUBDIR)/uImage
	$(CD) $(ROOTFS); \
		tar -cvf $(IMAGE_BUILD_TMP)/$(IMAGE_SUBDIR)/rootfs.tar -C $(ROOTFS) . >/dev/null 2>&1; \
		bzip2 $(IMAGE_BUILD_TMP)/$(IMAGE_SUBDIR)/rootfs.tar
	# Create minimal image
	$(CD) $(IMAGE_BUILD_TMP)/$(IMAGE_SUBDIR); \
		tar -czf $(IMAGE_DIR)/$(IMAGE_NAME).tgz uImage rootfs.tar.bz2
	echo $(IMAGE_SITE)/$(IMAGE_NAME).tgz $(IMAGE_TYPE)$(IMAGE_VER)$(IMAGE_DATE) `md5sum $(IMAGE_DIR)/$(IMAGE_NAME).tgz | cut -c1-32` $(IMAGE_DESC) $(IMAGE_VERSION) >> $(IMAGE_DIR)/$(IMAGE_MD5FILE)
	rm -rf $(IMAGE_BUILD_TMP)

# -----------------------------------------------------------------------------

flash-image-hd6x-multi:

# -----------------------------------------------------------------------------

# armbox vu+
flash-image-vuplus: IMAGE_DATE=$(shell cat $(ROOTFS)/.version | grep "^version=" | cut -d= -f2 | cut -c 5-)
flash-image-vuplus: | $(IMAGE_DIR)
	rm -rf $(IMAGE_BUILD_TMP)
	mkdir -p $(IMAGE_BUILD_TMP)/$(IMAGE_SUBDIR)
	cp $(KERNEL_ZIMAGE) $(IMAGE_BUILD_TMP)/$(IMAGE_SUBDIR)/kernel_auto.bin
	$(CD) $(ROOTFS); \
		tar -cvf $(IMAGE_BUILD_TMP)/$(IMAGE_SUBDIR)/rootfs.tar -C $(ROOTFS) . >/dev/null 2>&1; \
		bzip2 $(IMAGE_BUILD_TMP)/$(IMAGE_SUBDIR)/rootfs.tar
	# Create minimal image
	$(CD) $(IMAGE_BUILD_TMP)/$(IMAGE_SUBDIR); \
		tar -czf $(IMAGE_DIR)/$(IMAGE_NAME).tgz kernel_auto.bin rootfs.tar.bz2
	echo $(IMAGE_SITE)/$(IMAGE_NAME).tgz $(IMAGE_TYPE)$(IMAGE_VER)$(IMAGE_DATE) `md5sum $(IMAGE_DIR)/$(IMAGE_NAME).tgz | cut -c1-32` $(IMAGE_DESC) $(IMAGE_VERSION) >> $(IMAGE_DIR)/$(IMAGE_MD5FILE)
	rm -rf $(IMAGE_BUILD_TMP)

flash-image-vuplus-multi: vmlinuz-initrd
flash-image-vuplus-multi: | $(IMAGE_DIR)
	rm -rf $(IMAGE_BUILD_TMP)
	mkdir -p $(IMAGE_BUILD_TMP)/$(IMAGE_SUBDIR)
	cp $(TARGET_FILES)/splash-images/ni-splash.bmp $(IMAGE_BUILD_TMP)/$(IMAGE_SUBDIR)/splash_auto.bin
	cp $(BUILD_TMP)/$(VMLINUZ-INITRD) $(IMAGE_BUILD_TMP)/$(IMAGE_SUBDIR)/initrd_auto.bin
	echo Dummy for update. > $(IMAGE_BUILD_TMP)/$(IMAGE_SUBDIR)/kernel_auto.bin
	cp $(KERNEL_ZIMAGE) $(IMAGE_BUILD_TMP)/$(IMAGE_SUBDIR)/kernel1_auto.bin
	cp $(KERNEL_ZIMAGE) $(IMAGE_BUILD_TMP)/$(IMAGE_SUBDIR)/kernel2_auto.bin
	cp $(KERNEL_ZIMAGE) $(IMAGE_BUILD_TMP)/$(IMAGE_SUBDIR)/kernel3_auto.bin
	cp $(KERNEL_ZIMAGE) $(IMAGE_BUILD_TMP)/$(IMAGE_SUBDIR)/kernel4_auto.bin
	echo Dummy for update. > $(IMAGE_BUILD_TMP)/$(IMAGE_SUBDIR)/rootfs.tar.bz2
	$(CD) $(ROOTFS); \
		tar -cvf $(IMAGE_BUILD_TMP)/$(IMAGE_SUBDIR)/rootfs1.tar -C $(ROOTFS) . >/dev/null 2>&1; \
		bzip2 $(IMAGE_BUILD_TMP)/$(IMAGE_SUBDIR)/rootfs1.tar
	echo Dummy for update. > $(IMAGE_BUILD_TMP)/$(IMAGE_SUBDIR)/rootfs2.tar.bz2
	echo Dummy for update. > $(IMAGE_BUILD_TMP)/$(IMAGE_SUBDIR)/rootfs3.tar.bz2
	echo Dummy for update. > $(IMAGE_BUILD_TMP)/$(IMAGE_SUBDIR)/rootfs4.tar.bz2
ifeq ($(BOXMODEL), $(filter $(BOXMODEL), vuzero4k vuuno4k))
	echo This file forces the update. > $(IMAGE_BUILD_TMP)/$(IMAGE_SUBDIR)/force.update
else
	echo This file forces a reboot after the update. > $(IMAGE_BUILD_TMP)/$(IMAGE_SUBDIR)/reboot.update
endif
	echo This file forces creating partitions. > $(IMAGE_BUILD_TMP)/$(IMAGE_SUBDIR)/mkpart.update
	echo $(IMAGE_PREFIX) > $(IMAGE_BUILD_TMP)/$(IMAGE_SUBDIR)/imageversion
	# Create final USB-image
	$(CD) $(IMAGE_BUILD_TMP); \
		zip -r $(IMAGE_DIR)/$(IMAGE_NAME)_multi_usb.zip $(IMAGE_SUBDIR)/*
	rm -rf $(IMAGE_BUILD_TMP)

# -----------------------------------------------------------------------------

flash-image-vuduo:

# -----------------------------------------------------------------------------

PHONY += devtable
PHONY += devtable-remove
PHONY += flash-image-coolstream
PHONY += check-image-size
PHONY += flash-image-hd51
PHONY += flash-image-hd51-multi
PHONY += flash-image-vuplus
PHONY += flash-image-vuplus-multi
