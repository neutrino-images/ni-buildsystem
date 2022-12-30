#
# makefile to generate images
#
# -----------------------------------------------------------------------------

MKFSFLAGS = -U -D $(BUILD_DIR)/devtable-$(BOXSERIES).txt -r $(ROOTFS_DIR)
ifeq ($(BOXSERIES),hd1)
  MKFSFLAGS += -p
endif
ifeq ($(BOXSERIES),hd2)
  MKFSFLAGS += -n -l
endif

ifeq ($(BOXSERIES),hd1)
  SUMFLAGS = -p
endif
ifeq ($(BOXSERIES),hd2)
  SUMFLAGS = -n -l
endif

# -----------------------------------------------------------------------------

devtable: $(BUILD_DIR)/devtable-$(BOXSERIES).txt

$(BUILD_DIR)/devtable-hd1.txt:
	#	<name>		<type>	<mode>	<uid>	<gid>	<major>	<minor>	<start>	<inc>	<count>
	echo	"/dev/pts	d	755	0	0	-	-	-	-	-"	 > $(@)
	echo	"/dev/shm	d	755	0	0	-	-	-	-	-"	>> $(@)
	echo	"/dev/shm/usb	d	755	0	0	-	-	-	-	-"	>> $(@)
	echo	"/dev/null	c	666	0	0	1	3	0	0	-"	>> $(@)
	echo	"/dev/console	c	666	0	0	5	1	-	-	-"	>> $(@)
	echo	"/dev/ttyRI0	c	666	0	0	204	16	-	-	-"	>> $(@)
	echo	"/dev/mtd	c	640	0	0	90	0	0	2	6"	>> $(@)
	echo	"/dev/mtdblock	b	640	0	0	31	0	0	1	6"	>> $(@)

$(BUILD_DIR)/devtable-hd2.txt:
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

define create_md5file # image-file
	echo $(IMAGE_SITE)/$(1) $(IMAGE_VERSION_STRING) $$(md5sum $(IMAGE_DIR)/$(1) | cut -c1-32) $(IMAGE_DESC) $(IMAGE_VERSION) >> $(IMAGE_DIR)/$(IMAGE_MD5FILE)
endef

# -----------------------------------------------------------------------------

flash-image: PATH="$(BS_PATH)"
flash-image:
ifeq ($(BOXMODEL),$(filter $(BOXMODEL),nevis kronos kronos_v2))
	make flash-image-coolstream ERASE_SIZE=0x20000
endif
ifeq ($(BOXMODEL),$(filter $(BOXMODEL),apollo shiner))
	make flash-image-coolstream ERASE_SIZE=0x40000 IMAGE_SUFFIX=$(BOXTYPE_SC)-apollo BOXNAME="Tank"
	make flash-image-coolstream ERASE_SIZE=0x20000 IMAGE_SUFFIX=$(BOXTYPE_SC)-shiner BOXNAME="Trinity"
endif
ifeq ($(BOXMODEL),$(filter $(BOXMODEL),hd51 bre2ze4k h7 e4hdultra protek4k))
	make flash-image-hd5x
	make flash-image-hd5x-multi
endif
ifeq ($(BOXMODEL),$(filter $(BOXMODEL),hd60 hd61 multibox multiboxse))
	make flash-image-hd6x
	make flash-image-hd6x-single
endif
ifeq ($(BOXMODEL),$(filter $(BOXMODEL),vusolo4k vuduo4k vuduo4kse vuultimo4k vuzero4k vuuno4k vuuno4kse))
	make flash-image-vuplus
	make flash-image-vuplus-multi
endif
ifeq ($(BOXMODEL),$(filter $(BOXMODEL),vuduo))
	make flash-image-vuduo
endif

# -----------------------------------------------------------------------------

flash-image-coolstream: IMAGE_DATE=$(shell cat $(ROOTFS_DIR)/.version | grep "^version=" | cut -d= -f2 | cut -c 5-)
flash-image-coolstream: | $(IMAGE_DIR)
	make devtable
	mkfs.jffs2 -e $(ERASE_SIZE) $(MKFSFLAGS) -o $(IMAGE_DIR)/$(IMAGE_NAME).img
	make devtable-remove
ifeq ($(IMAGE_SUMMARIZE),yes)
	sumtool -e $(ERASE_SIZE) $(SUMFLAGS) -i $(IMAGE_DIR)/$(IMAGE_NAME).img -o $(IMAGE_DIR)/$(IMAGE_NAME)-sum.img
	rm -f $(IMAGE_DIR)/$(IMAGE_NAME).img
	mv $(IMAGE_DIR)/$(IMAGE_NAME)-sum.img $(IMAGE_DIR)/$(IMAGE_NAME).img
endif
	$(call create_md5file,$(IMAGE_NAME).img)
	make check-image-size IMAGE_TO_CHECK=$(IMAGE_DIR)/$(IMAGE_NAME).img

# -----------------------------------------------------------------------------

# ROOTFS_SIZE detected with 'df -k'
ifeq ($(BOXMODEL),nevis)
  ROOTFS_SIZE = 28160
else ifeq ($(BOXMODEL),$(filter $(BOXMODEL),apollo shiner kronos))
  ROOTFS_SIZE = 262144
else ifeq ($(BOXMODEL),kronos_v2)
  ROOTFS_SIZE = 57344
endif
ifdef ROOTFS_SIZE
  ROOTFS_SIZE := $$(( $(ROOTFS_SIZE)*1024 ))
endif

check-image-size:
ifdef IMAGE_TO_CHECK
	@IMAGE_SIZE=$(shell wc -c < $(IMAGE_TO_CHECK)); \
	if [ $$IMAGE_SIZE -ge $(ROOTFS_SIZE) ]; then \
		$(call WARNING,"$(IMAGE_TO_CHECK) is too big"); \
		false; \
	fi
endif

# -----------------------------------------------------------------------------

flash-image-hd5x: IMAGE_DATE=$(shell cat $(ROOTFS_DIR)/.version | grep "^version=" | cut -d= -f2 | cut -c 5-)
flash-image-hd5x: | $(IMAGE_DIR)
	rm -rf $(IMAGE_BUILD_DIR)
	$(INSTALL) -d $(IMAGE_BUILD_DIR)/$(IMAGE_SUBDIR)
	cp $(KERNEL_ZIMAGE_DTB) $(IMAGE_BUILD_DIR)/$(IMAGE_SUBDIR)/kernel.bin
	$(CD) $(ROOTFS_DIR); \
		tar -cvf $(IMAGE_BUILD_DIR)/$(IMAGE_SUBDIR)/rootfs.tar -C $(ROOTFS_DIR) . >/dev/null 2>&1; \
		bzip2 $(IMAGE_BUILD_DIR)/$(IMAGE_SUBDIR)/rootfs.tar
	# Create minimal image
	$(CD) $(IMAGE_BUILD_DIR)/$(IMAGE_SUBDIR); \
		tar -czf $(IMAGE_DIR)/$(IMAGE_NAME).tgz kernel.bin rootfs.tar.bz2
	$(call create_md5file,$(IMAGE_NAME).tgz)
	rm -rf $(IMAGE_BUILD_DIR)

# -----------------------------------------------------------------------------

ifeq ($(BOXMODEL),$(filter $(BOXMODEL),hd51 bre2ze4k h7 e4hdultra protek4k))
ifeq ($(BOXMODEL),$(filter $(BOXMODEL),e4hdultra))
HD5X_DRIVER = e4hd
else
HD5X_DRIVER = $(BOXMODEL)
endif
endif

# hd51, bre2ze4k, h7, e4hdultra, protek4k
HD5X_IMAGE_NAME = disk
HD5X_BOOT_IMAGE = boot.img
HD5X_IMAGE_LINK = $(HD5X_IMAGE_NAME).ext4

# emmc image
EMMC_IMAGE_SIZE = 3817472
EMMC_IMAGE = $(IMAGE_BUILD_DIR)/$(HD5X_IMAGE_NAME).img

BLOCK_SIZE = 512
BLOCK_SECTOR = 2

# partition offsets/sizes
IMAGE_ROOTFS_ALIGNMENT = 1024
BOOT_PARTITION_SIZE = 3072

KERNEL_PARTITION_OFFSET = "$(shell expr $(IMAGE_ROOTFS_ALIGNMENT) \+ $(BOOT_PARTITION_SIZE))"
KERNEL_PARTITION_SIZE = 8192

ALL_KERNEL_PARTITION_SIZE = $(shell expr 4 \* $(KERNEL_PARTITION_SIZE))

SWAP_PARTITION_SIZE = 262144

# just needed for MULTI_ROOTFS_PARTITION_SIZE; STORAGE_PARTITION uses remaining flash memory
STORAGE_PARTITION_SIZE = 262144

ROOTFS_PARTITION_OFFSET = "$(shell expr $(KERNEL_PARTITION_OFFSET) \+ $(KERNEL_PARTITION_SIZE))"
ifeq ($(IMAGE_LAYOUT),subdirboot)
  ROOTFS_PARTITION_SIZE = 1048576

  SECOND_KERNEL_PARTITION_OFFSET = "$(shell expr $(ROOTFS_PARTITION_OFFSET) \+ $(ROOTFS_PARTITION_SIZE))"
  THIRD_KERNEL_PARTITION_OFFSET = "$(shell expr $(SECOND_KERNEL_PARTITION_OFFSET) \+ $(KERNEL_PARTITION_SIZE))"
  FOURTH_KERNEL_PARTITION_OFFSET = "$(shell expr $(THIRD_KERNEL_PARTITION_OFFSET) \+ $(KERNEL_PARTITION_SIZE))"

  SWAP_PARTITION_OFFSET = "$(shell expr $(FOURTH_KERNEL_PARTITION_OFFSET) \+ $(KERNEL_PARTITION_SIZE))"

  # USERDATA_PARTITION values
  MULTI_ROOTFS_PARTITION_OFFSET = "$(shell expr $(SWAP_PARTITION_OFFSET) \+ $(SWAP_PARTITION_SIZE))"
  MULTI_ROOTFS_PARTITION_SIZE = $(shell expr $(EMMC_IMAGE_SIZE) \- $(BLOCK_SECTOR) \* $(IMAGE_ROOTFS_ALIGNMENT) \- $(BOOT_PARTITION_SIZE) \- $(ALL_KERNEL_PARTITION_SIZE) \- $(SWAP_PARTITION_SIZE) \- $(ROOTFS_PARTITION_SIZE) \- $(STORAGE_PARTITION_SIZE))

  STORAGE_PARTITION_OFFSET = "$(shell expr $(MULTI_ROOTFS_PARTITION_OFFSET) \+ $(MULTI_ROOTFS_PARTITION_SIZE))"
else
  ROOTFS_PARTITION_SIZE = 768000

  SECOND_KERNEL_PARTITION_OFFSET = $(shell expr $(ROOTFS_PARTITION_OFFSET) \+ $(ROOTFS_PARTITION_SIZE))
  SECOND_ROOTFS_PARTITION_OFFSET = $(shell expr $(SECOND_KERNEL_PARTITION_OFFSET) \+ $(KERNEL_PARTITION_SIZE))

  THIRD_KERNEL_PARTITION_OFFSET = $(shell expr $(SECOND_ROOTFS_PARTITION_OFFSET) \+ $(ROOTFS_PARTITION_SIZE))
  THIRD_ROOTFS_PARTITION_OFFSET = $(shell expr $(THIRD_KERNEL_PARTITION_OFFSET) \+ $(KERNEL_PARTITION_SIZE))

  FOURTH_KERNEL_PARTITION_OFFSET = $(shell expr $(THIRD_ROOTFS_PARTITION_OFFSET) \+ $(ROOTFS_PARTITION_SIZE))
  FOURTH_ROOTFS_PARTITION_OFFSET = $(shell expr $(FOURTH_KERNEL_PARTITION_OFFSET) \+ $(KERNEL_PARTITION_SIZE))

  SWAP_PARTITION_OFFSET = $(shell expr $(FOURTH_ROOTFS_PARTITION_OFFSET) \+ $(ROOTFS_PARTITION_SIZE))

  STORAGE_PARTITION_OFFSET = $(shell expr $(SWAP_PARTITION_OFFSET) \+ $(SWAP_PARTITION_SIZE))
endif

flash-image-hd5x-multi: | $(IMAGE_DIR)
	rm -rf $(IMAGE_BUILD_DIR)
	$(INSTALL) -d $(IMAGE_BUILD_DIR)
	# Create a sparse image block
	dd if=/dev/zero of=$(IMAGE_BUILD_DIR)/$(HD5X_IMAGE_LINK) seek=$(shell expr $(ROOTFS_PARTITION_SIZE) \* $(BLOCK_SECTOR)) count=0 bs=$(BLOCK_SIZE)
	mkfs.ext4 -v -F $(IMAGE_BUILD_DIR)/$(HD5X_IMAGE_LINK) -d $(ROOTFS_BASE)
	# Error codes 0-3 indicate successfull operation of fsck (no errors or errors corrected)
	fsck.ext4 -pvfD $(IMAGE_BUILD_DIR)/$(HD5X_IMAGE_LINK) || [ $? -le 3 ]
	dd if=/dev/zero of=$(EMMC_IMAGE) bs=$(BLOCK_SIZE) count=0 seek=$(shell expr $(EMMC_IMAGE_SIZE) \* $(BLOCK_SECTOR))
	parted -s $(EMMC_IMAGE) mklabel gpt
	parted -s $(EMMC_IMAGE) unit KiB mkpart boot fat16 $(IMAGE_ROOTFS_ALIGNMENT) $(shell expr $(IMAGE_ROOTFS_ALIGNMENT) \+ $(BOOT_PARTITION_SIZE))
ifeq ($(IMAGE_LAYOUT),subdirboot)
	parted -s $(EMMC_IMAGE) unit KiB mkpart linuxkernel $(KERNEL_PARTITION_OFFSET) $(shell expr $(KERNEL_PARTITION_OFFSET) \+ $(KERNEL_PARTITION_SIZE))
	parted -s $(EMMC_IMAGE) unit KiB mkpart linuxrootfs ext4 $(ROOTFS_PARTITION_OFFSET) $(shell expr $(ROOTFS_PARTITION_OFFSET) \+ $(ROOTFS_PARTITION_SIZE))
	parted -s $(EMMC_IMAGE) unit KiB mkpart linuxkernel2 $(SECOND_KERNEL_PARTITION_OFFSET) $(shell expr $(SECOND_KERNEL_PARTITION_OFFSET) \+ $(KERNEL_PARTITION_SIZE))
	parted -s $(EMMC_IMAGE) unit KiB mkpart linuxkernel3 $(THIRD_KERNEL_PARTITION_OFFSET) $(shell expr $(THIRD_KERNEL_PARTITION_OFFSET) \+ $(KERNEL_PARTITION_SIZE))
	parted -s $(EMMC_IMAGE) unit KiB mkpart linuxkernel4 $(FOURTH_KERNEL_PARTITION_OFFSET) $(shell expr $(FOURTH_KERNEL_PARTITION_OFFSET) \+ $(KERNEL_PARTITION_SIZE))
	parted -s $(EMMC_IMAGE) unit KiB mkpart swap linux-swap $(SWAP_PARTITION_OFFSET) $(shell expr $(SWAP_PARTITION_OFFSET) \+ $(SWAP_PARTITION_SIZE))
	parted -s $(EMMC_IMAGE) unit KiB mkpart userdata ext4 $(MULTI_ROOTFS_PARTITION_OFFSET) $(shell expr $(MULTI_ROOTFS_PARTITION_OFFSET) \+ $(MULTI_ROOTFS_PARTITION_SIZE))
	parted -s $(EMMC_IMAGE) unit KiB mkpart storage ext4 $(STORAGE_PARTITION_OFFSET) 100%
	dd if=/dev/zero of=$(IMAGE_BUILD_DIR)/$(HD5X_BOOT_IMAGE) bs=$(BLOCK_SIZE) count=$(shell expr $(BOOT_PARTITION_SIZE) \* $(BLOCK_SECTOR))
	mkfs.msdos -S 512 $(IMAGE_BUILD_DIR)/$(HD5X_BOOT_IMAGE)
ifeq ($(BOXMODEL),$(filter $(BOXMODEL),e4hdultra protek4k))
	echo "boot emmcflash0.linuxkernel  'brcm_cma=504M@264M brcm_cma=192M@768M brcm_cma=1024M@2048M root=/dev/mmcblk0p3 rootsubdir=linuxrootfs1 kernel=/dev/mmcblk0p2 rw rootwait $(HD5X_DRIVER)_4.boxmode=5'" > $(IMAGE_BUILD_DIR)/STARTUP
	echo "boot emmcflash0.linuxkernel  'brcm_cma=504M@264M brcm_cma=192M@768M brcm_cma=1024M@2048M root=/dev/mmcblk0p3 rootsubdir=linuxrootfs1 kernel=/dev/mmcblk0p2 rw rootwait $(HD5X_DRIVER)_4.boxmode=5'" > $(IMAGE_BUILD_DIR)/STARTUP_1
	echo "boot emmcflash0.linuxkernel2 'brcm_cma=504M@264M brcm_cma=192M@768M brcm_cma=1024M@2048M root=/dev/mmcblk0p8 rootsubdir=linuxrootfs2 kernel=/dev/mmcblk0p4 rw rootwait $(HD5X_DRIVER)_4.boxmode=5'" > $(IMAGE_BUILD_DIR)/STARTUP_2
	echo "boot emmcflash0.linuxkernel3 'brcm_cma=504M@264M brcm_cma=192M@768M brcm_cma=1024M@2048M root=/dev/mmcblk0p8 rootsubdir=linuxrootfs3 kernel=/dev/mmcblk0p5 rw rootwait $(HD5X_DRIVER)_4.boxmode=5'" > $(IMAGE_BUILD_DIR)/STARTUP_3
	echo "boot emmcflash0.linuxkernel4 'brcm_cma=504M@264M brcm_cma=192M@768M brcm_cma=1024M@2048M root=/dev/mmcblk0p8 rootsubdir=linuxrootfs4 kernel=/dev/mmcblk0p6 rw rootwait $(HD5X_DRIVER)_4.boxmode=5'" > $(IMAGE_BUILD_DIR)/STARTUP_4
else
	echo "boot emmcflash0.linuxkernel  'brcm_cma=520M@248M brcm_cma=192M@768M root=/dev/mmcblk0p3 rootsubdir=linuxrootfs1 kernel=/dev/mmcblk0p2 rw rootwait $(HD5X_DRIVER)_4.boxmode=12'" > $(IMAGE_BUILD_DIR)/STARTUP
	echo "boot emmcflash0.linuxkernel  'root=/dev/mmcblk0p3 rootsubdir=linuxrootfs1 kernel=/dev/mmcblk0p2 rw rootwait $(HD5X_DRIVER)_4.boxmode=1'" > $(IMAGE_BUILD_DIR)/STARTUP_1
	echo "boot emmcflash0.linuxkernel2 'root=/dev/mmcblk0p8 rootsubdir=linuxrootfs2 kernel=/dev/mmcblk0p4 rw rootwait $(HD5X_DRIVER)_4.boxmode=1'" > $(IMAGE_BUILD_DIR)/STARTUP_2
	echo "boot emmcflash0.linuxkernel3 'root=/dev/mmcblk0p8 rootsubdir=linuxrootfs3 kernel=/dev/mmcblk0p5 rw rootwait $(HD5X_DRIVER)_4.boxmode=1'" > $(IMAGE_BUILD_DIR)/STARTUP_3
	echo "boot emmcflash0.linuxkernel4 'root=/dev/mmcblk0p8 rootsubdir=linuxrootfs4 kernel=/dev/mmcblk0p6 rw rootwait $(HD5X_DRIVER)_4.boxmode=1'" > $(IMAGE_BUILD_DIR)/STARTUP_4
endif
else # ($(IMAGE_LAYOUT),single)
	parted -s $(EMMC_IMAGE) unit KiB mkpart kernel1 $(KERNEL_PARTITION_OFFSET) $(shell expr $(KERNEL_PARTITION_OFFSET) \+ $(KERNEL_PARTITION_SIZE))
	parted -s $(EMMC_IMAGE) unit KiB mkpart rootfs1 ext4 $(ROOTFS_PARTITION_OFFSET) $(shell expr $(ROOTFS_PARTITION_OFFSET) \+ $(ROOTFS_PARTITION_SIZE))
	parted -s $(EMMC_IMAGE) unit KiB mkpart kernel2 $(SECOND_KERNEL_PARTITION_OFFSET) $(shell expr $(SECOND_KERNEL_PARTITION_OFFSET) \+ $(KERNEL_PARTITION_SIZE))
	parted -s $(EMMC_IMAGE) unit KiB mkpart rootfs2 ext4 $(SECOND_ROOTFS_PARTITION_OFFSET) $(shell expr $(SECOND_ROOTFS_PARTITION_OFFSET) \+ $(ROOTFS_PARTITION_SIZE))
	parted -s $(EMMC_IMAGE) unit KiB mkpart kernel3 $(THIRD_KERNEL_PARTITION_OFFSET) $(shell expr $(THIRD_KERNEL_PARTITION_OFFSET) \+ $(KERNEL_PARTITION_SIZE))
	parted -s $(EMMC_IMAGE) unit KiB mkpart rootfs3 ext4 $(THIRD_ROOTFS_PARTITION_OFFSET) $(shell expr $(THIRD_ROOTFS_PARTITION_OFFSET) \+ $(ROOTFS_PARTITION_SIZE))
	parted -s $(EMMC_IMAGE) unit KiB mkpart kernel4 $(FOURTH_KERNEL_PARTITION_OFFSET) $(shell expr $(FOURTH_KERNEL_PARTITION_OFFSET) \+ $(KERNEL_PARTITION_SIZE))
	parted -s $(EMMC_IMAGE) unit KiB mkpart rootfs4 ext4 $(FOURTH_ROOTFS_PARTITION_OFFSET) $(shell expr $(FOURTH_ROOTFS_PARTITION_OFFSET) \+ $(ROOTFS_PARTITION_SIZE))
	parted -s $(EMMC_IMAGE) unit KiB mkpart swap linux-swap $(SWAP_PARTITION_OFFSET) $(shell expr $(SWAP_PARTITION_OFFSET) \+ $(SWAP_PARTITION_SIZE))
	parted -s $(EMMC_IMAGE) unit KiB mkpart storage ext4 $(STORAGE_PARTITION_OFFSET) 100%
	dd if=/dev/zero of=$(IMAGE_BUILD_DIR)/$(HD5X_BOOT_IMAGE) bs=$(BLOCK_SIZE) count=$(shell expr $(BOOT_PARTITION_SIZE) \* $(BLOCK_SECTOR))
	mkfs.msdos -S 512 $(IMAGE_BUILD_DIR)/$(HD5X_BOOT_IMAGE)
ifeq ($(BOXMODEL),$(filter $(BOXMODEL),e4hdultra protek4k))
	echo "boot emmcflash0.kernel1 'brcm_cma=504M@264M brcm_cma=192M@768M brcm_cma=1024M@2048M root=/dev/mmcblk0p3 rw rootwait $(HD5X_DRIVER)_4.boxmode=5'" > $(IMAGE_BUILD_DIR)/STARTUP
	echo "boot emmcflash0.kernel1 'brcm_cma=504M@264M brcm_cma=192M@768M brcm_cma=1024M@2048M root=/dev/mmcblk0p3 rw rootwait $(HD5X_DRIVER)_4.boxmode=5'" > $(IMAGE_BUILD_DIR)/STARTUP_1
	echo "boot emmcflash0.kernel2 'brcm_cma=504M@264M brcm_cma=192M@768M brcm_cma=1024M@2048M root=/dev/mmcblk0p5 rw rootwait $(HD5X_DRIVER)_4.boxmode=5'" > $(IMAGE_BUILD_DIR)/STARTUP_2
	echo "boot emmcflash0.kernel3 'brcm_cma=504M@264M brcm_cma=192M@768M brcm_cma=1024M@2048M root=/dev/mmcblk0p7 rw rootwait $(HD5X_DRIVER)_4.boxmode=5'" > $(IMAGE_BUILD_DIR)/STARTUP_3
	echo "boot emmcflash0.kernel4 'brcm_cma=504M@264M brcm_cma=192M@768M brcm_cma=1024M@2048M root=/dev/mmcblk0p9 rw rootwait $(HD5X_DRIVER)_4.boxmode=5'" > $(IMAGE_BUILD_DIR)/STARTUP_4
else
	echo "boot emmcflash0.kernel1 'brcm_cma=520M@248M brcm_cma=192M@768M root=/dev/mmcblk0p3 rw rootwait $(HD5X_DRIVER)_4.boxmode=12'" > $(IMAGE_BUILD_DIR)/STARTUP
	echo "boot emmcflash0.kernel1 'root=/dev/mmcblk0p3 rw rootwait $(HD5X_DRIVER)_4.boxmode=1'" > $(IMAGE_BUILD_DIR)/STARTUP_1
	echo "boot emmcflash0.kernel2 'root=/dev/mmcblk0p5 rw rootwait $(HD5X_DRIVER)_4.boxmode=1'" > $(IMAGE_BUILD_DIR)/STARTUP_2
	echo "boot emmcflash0.kernel3 'root=/dev/mmcblk0p7 rw rootwait $(HD5X_DRIVER)_4.boxmode=1'" > $(IMAGE_BUILD_DIR)/STARTUP_3
	echo "boot emmcflash0.kernel4 'root=/dev/mmcblk0p9 rw rootwait $(HD5X_DRIVER)_4.boxmode=1'" > $(IMAGE_BUILD_DIR)/STARTUP_4
endif
endif
	mcopy -i $(IMAGE_BUILD_DIR)/$(HD5X_BOOT_IMAGE) -v $(IMAGE_BUILD_DIR)/STARTUP ::
	mcopy -i $(IMAGE_BUILD_DIR)/$(HD5X_BOOT_IMAGE) -v $(IMAGE_BUILD_DIR)/STARTUP_1 ::
	mcopy -i $(IMAGE_BUILD_DIR)/$(HD5X_BOOT_IMAGE) -v $(IMAGE_BUILD_DIR)/STARTUP_2 ::
	mcopy -i $(IMAGE_BUILD_DIR)/$(HD5X_BOOT_IMAGE) -v $(IMAGE_BUILD_DIR)/STARTUP_3 ::
	mcopy -i $(IMAGE_BUILD_DIR)/$(HD5X_BOOT_IMAGE) -v $(IMAGE_BUILD_DIR)/STARTUP_4 ::
	dd conv=notrunc if=$(IMAGE_BUILD_DIR)/$(HD5X_BOOT_IMAGE) of=$(EMMC_IMAGE) bs=$(BLOCK_SIZE) seek=$(shell expr $(IMAGE_ROOTFS_ALIGNMENT) \* $(BLOCK_SECTOR))
	dd conv=notrunc if=$(KERNEL_ZIMAGE_DTB) of=$(EMMC_IMAGE) bs=$(BLOCK_SIZE) seek=$(shell expr $(KERNEL_PARTITION_OFFSET) \* $(BLOCK_SECTOR))
	resize2fs $(IMAGE_BUILD_DIR)/$(HD5X_IMAGE_LINK) $(ROOTFS_PARTITION_SIZE)k
	# Truncate on purpose
	dd if=$(IMAGE_BUILD_DIR)/$(HD5X_IMAGE_LINK) of=$(EMMC_IMAGE) bs=$(BLOCK_SIZE) seek=$(shell expr $(ROOTFS_PARTITION_OFFSET) \* $(BLOCK_SECTOR))
	# Create final USB-image
	$(INSTALL) -d $(IMAGE_BUILD_DIR)/$(IMAGE_SUBDIR)
	cp $(EMMC_IMAGE) $(IMAGE_BUILD_DIR)/$(IMAGE_SUBDIR)
	cp $(SUPPORT_DIR)/splash-images/ni-splash.bmp $(IMAGE_BUILD_DIR)/$(IMAGE_SUBDIR)/splash.bin
ifeq ($(BOXMODEL),$(filter $(BOXMODEL),e4hdultra protek4k))
	cp $(SUPPORT_DIR)/splash-images/lcdflashing_220x176.bmp $(IMAGE_BUILD_DIR)/$(IMAGE_SUBDIR)/lcdflashing.bmp
endif
	cp $(KERNEL_ZIMAGE_DTB) $(IMAGE_BUILD_DIR)/$(IMAGE_SUBDIR)/kernel.bin
	$(CD) $(ROOTFS_DIR); \
		tar -cvf $(IMAGE_BUILD_DIR)/$(IMAGE_SUBDIR)/rootfs.tar -C $(ROOTFS_DIR) . >/dev/null 2>&1; \
		bzip2 $(IMAGE_BUILD_DIR)/$(IMAGE_SUBDIR)/rootfs.tar
	echo $(IMAGE_PREFIX) > $(IMAGE_BUILD_DIR)/$(IMAGE_SUBDIR)/imageversion
	$(CD) $(IMAGE_BUILD_DIR); \
		zip -r $(IMAGE_DIR)/$(IMAGE_NAME)_multi_usb.zip $(IMAGE_SUBDIR)/*
	rm -rf $(IMAGE_BUILD_DIR)

# -----------------------------------------------------------------------------

flash-image-hd6x: IMAGE_DATE=$(shell cat $(ROOTFS_DIR)/.version | grep "^version=" | cut -d= -f2 | cut -c 5-)
flash-image-hd6x: | $(IMAGE_DIR)
	rm -rf $(IMAGE_BUILD_DIR)
	$(INSTALL) -d $(IMAGE_BUILD_DIR)/$(IMAGE_SUBDIR)
	cp $(KERNEL_UIMAGE) $(IMAGE_BUILD_DIR)/$(IMAGE_SUBDIR)/uImage
	$(CD) $(ROOTFS_DIR); \
		tar -cvf $(IMAGE_BUILD_DIR)/$(IMAGE_SUBDIR)/rootfs.tar -C $(ROOTFS_DIR) . >/dev/null 2>&1; \
		bzip2 $(IMAGE_BUILD_DIR)/$(IMAGE_SUBDIR)/rootfs.tar
	# Create minimal image
	$(CD) $(IMAGE_BUILD_DIR)/$(IMAGE_SUBDIR); \
		tar -czf $(IMAGE_DIR)/$(IMAGE_NAME).tgz uImage rootfs.tar.bz2
	$(call create_md5file,$(IMAGE_NAME).tgz)
	rm -rf $(IMAGE_BUILD_DIR)

# -----------------------------------------------------------------------------

# hd60, hd61
HD6X_IMAGE_NAME = disk
HD6X_BOOT_IMAGE = bootoptions.img
HD6X_IMAGE_LINK = $(HD6X_IMAGE_NAME).ext4

# partition offsets/sizes
HD6X_BOOTOPTIONS_PARTITION_SIZE = 32768
HD6X_IMAGE_ROOTFS_SIZE = 1024M

HD6X_BOOTARGS_DATE = 20200504
HD6X_BOOTARGS_SOURCE = $(BOXMODEL)-bootargs-$(HD6X_BOOTARGS_DATE).zip
HD6X_PARTITONS_DATE = 20200319
HD6X_PARTITONS_SOURCE = $(BOXMODEL)-partitions-$(HD6X_PARTITONS_DATE).zip
HD6X_RECOVERY_DATE = 20200424
HD6X_RECOVERY_SOURCE = $(BOXMODEL)-recovery-$(HD6X_RECOVERY_DATE).zip

HD6X_MULTI_RECOVERY_SITE = http://downloads.mutant-digital.net/$(BOXMODEL)

# avoid warning: overriding recipe
ifeq ($(BOXMODEL),$(filter $(BOXMODEL),hd60 hd61))
$(DL_DIR)/$(HD6X_BOOTARGS_SOURCE):
	$(download) $(HD6X_MULTI_RECOVERY_SITE)/$(HD6X_BOOTARGS_SOURCE)
endif

$(DL_DIR)/$(HD6X_PARTITONS_SOURCE):
	$(download) $(HD6X_MULTI_RECOVERY_SITE)/$(HD6X_PARTITONS_SOURCE)

$(DL_DIR)/$(HD6X_RECOVERY_SOURCE):
	$(download) $(HD6X_MULTI_RECOVERY_SITE)/$(HD6X_RECOVERY_SOURCE)

flash-image-hd6x-multi-recovery: $(DL_DIR)/$(HD6X_BOOTARGS_SOURCE)
flash-image-hd6x-multi-recovery: $(DL_DIR)/$(HD6X_PARTITONS_SOURCE)
flash-image-hd6x-multi-recovery: $(DL_DIR)/$(HD6X_RECOVERY_SOURCE)
flash-image-hd6x-multi-recovery: | $(IMAGE_DIR)
	rm -rf $(IMAGE_BUILD_DIR)
	$(INSTALL) -d $(IMAGE_BUILD_DIR)/$(IMAGE_SUBDIR)
	unzip -o $(DL_DIR)/$(HD6X_BOOTARGS_SOURCE) -d $(IMAGE_BUILD_DIR)
	unzip -o $(DL_DIR)/$(HD6X_PARTITONS_SOURCE) -d $(IMAGE_BUILD_DIR)
	unzip -o $(DL_DIR)/$(HD6X_RECOVERY_SOURCE) -d $(IMAGE_BUILD_DIR)
	$(INSTALL_EXEC) $(IMAGE_BUILD_DIR)/bootargs-8gb.bin $(ROOTFS_DIR)$(datadir)/bootargs.bin
	$(INSTALL_EXEC) $(IMAGE_BUILD_DIR)/fastboot.bin $(ROOTFS_DIR)$(datadir)/fastboot.bin
	dd if=/dev/zero of=$(IMAGE_BUILD_DIR)/$(IMAGE_SUBDIR)/$(HD6X_BOOT_IMAGE) bs=1024 count=$(HD6X_BOOTOPTIONS_PARTITION_SIZE)
	mkfs.msdos -S 512 $(IMAGE_BUILD_DIR)/$(IMAGE_SUBDIR)/$(HD6X_BOOT_IMAGE)
	echo "bootcmd=setenv bootargs \$$(bootargs) \$$(bootargs_common); mmc read 0 0x1000000 0x3BD000 0x8000; bootm 0x1000000; run bootcmd_fallback" > $(IMAGE_BUILD_DIR)/STARTUP
	echo "bootargs=root=/dev/mmcblk0p23 rootsubdir=linuxrootfs1 rootfstype=ext4 kernel=/dev/mmcblk0p19" >> $(IMAGE_BUILD_DIR)/STARTUP
	echo "bootcmd=setenv vfd_msg andr;setenv bootargs \$$(bootargs) \$$(bootargs_common); run bootcmd_android; run bootcmd_fallback" > $(IMAGE_BUILD_DIR)/STARTUP_ANDROID
	echo "bootargs=androidboot.selinux=disable androidboot.serialno=0123456789" >> $(IMAGE_BUILD_DIR)/STARTUP_ANDROID
	echo "bootcmd=setenv vfd_msg andr;setenv bootargs \$$(bootargs) \$$(bootargs_common); run bootcmd_android; run bootcmd_fallback" > $(IMAGE_BUILD_DIR)/STARTUP_ANDROID_DISABLE_LINUXSE
	echo "bootargs=androidboot.selinux=disable androidboot.serialno=0123456789" >> $(IMAGE_BUILD_DIR)/STARTUP_ANDROID_DISABLE_LINUXSE
	echo "bootcmd=setenv bootargs \$$(bootargs) \$$(bootargs_common); mmc read 0 0x1000000 0x3BD000 0x8000; bootm 0x1000000; run bootcmd_fallback" > $(IMAGE_BUILD_DIR)/STARTUP_LINUX_1
	echo "bootargs=root=/dev/mmcblk0p23 rootsubdir=linuxrootfs1 rootfstype=ext4 kernel=/dev/mmcblk0p19" >> $(IMAGE_BUILD_DIR)/STARTUP_LINUX_1
	echo "bootcmd=setenv bootargs \$$(bootargs) \$$(bootargs_common); mmc read 0 0x1000000 0x3C5000 0x8000; bootm 0x1000000; run bootcmd_fallback" > $(IMAGE_BUILD_DIR)/STARTUP_LINUX_2
	echo "bootargs=root=/dev/mmcblk0p23 rootsubdir=linuxrootfs2 rootfstype=ext4 kernel=/dev/mmcblk0p20" >> $(IMAGE_BUILD_DIR)/STARTUP_LINUX_2
	echo "bootcmd=setenv bootargs \$$(bootargs) \$$(bootargs_common); mmc read 0 0x1000000 0x3CD000 0x8000; bootm 0x1000000; run bootcmd_fallback" > $(IMAGE_BUILD_DIR)/STARTUP_LINUX_3
	echo "bootargs=root=/dev/mmcblk0p23 rootsubdir=linuxrootfs3 rootfstype=ext4 kernel=/dev/mmcblk0p21" >> $(IMAGE_BUILD_DIR)/STARTUP_LINUX_3
	echo "bootcmd=setenv bootargs \$$(bootargs) \$$(bootargs_common); mmc read 0 0x1000000 0x3D5000 0x8000; bootm 0x1000000; run bootcmd_fallback" > $(IMAGE_BUILD_DIR)/STARTUP_LINUX_4
	echo "bootargs=root=/dev/mmcblk0p23 rootsubdir=linuxrootfs4 rootfstype=ext4 kernel=/dev/mmcblk0p22" >> $(IMAGE_BUILD_DIR)/STARTUP_LINUX_4
	echo "bootcmd=setenv bootargs \$$(bootargs_common); mmc read 0 0x1000000 0x1000 0x9000; bootm 0x1000000" > $(IMAGE_BUILD_DIR)/STARTUP_RECOVERY
	echo "bootcmd=setenv bootargs \$$(bootargs_common); mmc read 0 0x1000000 0x1000 0x9000; bootm 0x1000000" > $(IMAGE_BUILD_DIR)/STARTUP_ONCE
	$(INSTALL_DATA) -D $(PACKAGE_DIR)/bootmenu/files/$(BOXMODEL)/bootmenu.conf $(IMAGE_BUILD_DIR)/bootmenu.conf
	mcopy -i $(IMAGE_BUILD_DIR)/$(IMAGE_SUBDIR)/$(HD6X_BOOT_IMAGE) -v $(IMAGE_BUILD_DIR)/STARTUP ::
	mcopy -i $(IMAGE_BUILD_DIR)/$(IMAGE_SUBDIR)/$(HD6X_BOOT_IMAGE) -v $(IMAGE_BUILD_DIR)/STARTUP_ANDROID ::
	mcopy -i $(IMAGE_BUILD_DIR)/$(IMAGE_SUBDIR)/$(HD6X_BOOT_IMAGE) -v $(IMAGE_BUILD_DIR)/STARTUP_ANDROID_DISABLE_LINUXSE ::
	mcopy -i $(IMAGE_BUILD_DIR)/$(IMAGE_SUBDIR)/$(HD6X_BOOT_IMAGE) -v $(IMAGE_BUILD_DIR)/STARTUP_LINUX_1 ::
	mcopy -i $(IMAGE_BUILD_DIR)/$(IMAGE_SUBDIR)/$(HD6X_BOOT_IMAGE) -v $(IMAGE_BUILD_DIR)/STARTUP_LINUX_2 ::
	mcopy -i $(IMAGE_BUILD_DIR)/$(IMAGE_SUBDIR)/$(HD6X_BOOT_IMAGE) -v $(IMAGE_BUILD_DIR)/STARTUP_LINUX_3 ::
	mcopy -i $(IMAGE_BUILD_DIR)/$(IMAGE_SUBDIR)/$(HD6X_BOOT_IMAGE) -v $(IMAGE_BUILD_DIR)/STARTUP_LINUX_4 ::
	mcopy -i $(IMAGE_BUILD_DIR)/$(IMAGE_SUBDIR)/$(HD6X_BOOT_IMAGE) -v $(IMAGE_BUILD_DIR)/STARTUP_RECOVERY ::
	mcopy -i $(IMAGE_BUILD_DIR)/$(IMAGE_SUBDIR)/$(HD6X_BOOT_IMAGE) -v $(IMAGE_BUILD_DIR)/bootmenu.conf ::
	mv $(IMAGE_BUILD_DIR)/bootargs-8gb.bin $(IMAGE_BUILD_DIR)/bootargs.bin
	mv $(IMAGE_BUILD_DIR)/$(IMAGE_SUBDIR)/bootargs-8gb.bin $(IMAGE_BUILD_DIR)/$(IMAGE_SUBDIR)/bootargs.bin
	mv $(IMAGE_BUILD_DIR)/$(IMAGE_SUBDIR)/pq_param.bin $(IMAGE_BUILD_DIR)/$(IMAGE_SUBDIR)/pqparam.bin
	echo boot-recovery > $(IMAGE_BUILD_DIR)/$(IMAGE_SUBDIR)/misc-boot.img
	rm -rf $(IMAGE_BUILD_DIR)/STARTUP*
	rm -rf $(IMAGE_BUILD_DIR)/*.conf
	rm -rf $(IMAGE_BUILD_DIR)/*.txt
	rm -rf $(IMAGE_BUILD_DIR)/$(IMAGE_SUBDIR)/*.txt
	rm -rf $(IMAGE_BUILD_DIR)/$(HD6X_IMAGE_LINK)
	cp $(SUPPORT_DIR)/splash-images/ni-splash-$(BOXSERIES).img $(IMAGE_BUILD_DIR)/$(IMAGE_SUBDIR)/logo.img
	echo $(IMAGE_NAME)_recovery > $(IMAGE_BUILD_DIR)/$(IMAGE_SUBDIR)/recoveryversion
	echo "***** ACHTUNG *****" >$(IMAGE_BUILD_DIR)/recovery_$(BOXMODEL)_lies.mich
	echo "Das RECOVERY wird nur benötigt wenn es Probleme beim Zugriff auf das MULTIBOOT MENÜ gibt." >> $(IMAGE_BUILD_DIR)/recovery_$(BOXMODEL)_lies.mich
	echo "Das $(IMAGE_NAME)_multi_recovery.zip sollte normalerweise nur einmal installiert werden (oder wenn es ein Update gibt)." >> $(IMAGE_BUILD_DIR)/recovery_$(BOXMODEL)_lies.mich
	echo "Dies ist erforderlich, um Probleme mit dem Images zuvermeiden, wenn sich der Aufbau der Partition (bootargs) ändert." >> $(IMAGE_BUILD_DIR)/recovery_$(BOXMODEL)_lies.mich
	echo "Die Änderungen können alle Daten im Flash löschen. Nur installieren, wenn es notwendig ist." >> $(IMAGE_BUILD_DIR)/recovery_$(BOXMODEL)_lies.mich
	echo "***** ATTENTION *****" > $(IMAGE_BUILD_DIR)/recovery_$(BOXMODEL)_read.me
	echo "This RECOVERY is only needed when you have issues access the MULTIBOOT MENU." >> $(IMAGE_BUILD_DIR)/recovery_$(BOXMODEL)_read.me
	echo "The $(IMAGE_NAME)_multi_recovery.zip should been installed just once (or if there is an update)." >> $(IMAGE_BUILD_DIR)/recovery_$(BOXMODEL)_read.me
	echo "This is necessary to avoid problems with the image if the partition structure (bootargs) changes." >> $(IMAGE_BUILD_DIR)/recovery_$(BOXMODEL)_read.me
	echo "A small change can destroy all your installed images. So you better leave it and don't install it if it's not needed." >> $(IMAGE_BUILD_DIR)/recovery_$(BOXMODEL)_read.me
	$(CD) $(IMAGE_BUILD_DIR); \
		zip -r $(IMAGE_DIR)/$(IMAGE_NAME)_multi_recovery.zip *
	rm -rf $(IMAGE_BUILD_DIR)

# multibox, multiboxse
MULTIBOX_IMAGE_NAME = disk
MULTIBOX_BOOT_IMAGE = bootoptions.img
MULTIBOX_IMAGE_LINK = $(HD6X_IMAGE_NAME).ext4

# partition offsets/sizes
MULTIBOX_BOOTOPTIONS_PARTITION_SIZE = 2048
MULTIBOX_IMAGE_ROOTFS_SIZE = 1024M

ifeq ($(BOXMODEL),multibox)
MULTIBOX_BOOTARGS_DATE = 20200504
else ifeq ($(BOXMODEL),multiboxse)
MULTIBOX_BOOTARGS_DATE = 20201110
endif
MULTIBOX_BOOTARGS_SOURCE = $(BOXMODEL)-bootargs-$(MULTIBOX_BOOTARGS_DATE).zip
ifeq ($(BOXMODEL),multibox)
MULTIBOX_FASTBOOT_DATE = 20200319
else ifeq ($(BOXMODEL),multiboxse)
MULTIBOX_FASTBOOT_DATE = 20201110
endif
MULTIBOX_FASTBOOT_SOURCE = $(BOXMODEL)-fastboot-$(MULTIBOX_FASTBOOT_DATE).zip
MULTIBOX_PARAM_DATE = 20200630
MULTIBOX_PARAM_SOURCE = 3798mv200-param-$(MULTIBOX_PARAM_DATE).zip
ifeq ($(BOXMODEL),multibox)
MULTIBOX_RECOVERY_DATE = 20210118
else ifeq ($(BOXMODEL),multiboxse)
MULTIBOX_RECOVERY_DATE = 20201110
endif
MULTIBOX_RECOVERY_SOURCE = $(BOXMODEL)-recovery-$(MULTIBOX_RECOVERY_DATE).zip

MULTIBOX_MULTI_RECOVERY_SITE = http://source.mynonpublic.com/maxytec

# avoid warning: overriding recipe
ifeq ($(BOXMODEL),$(filter $(BOXMODEL),multibox multiboxse))
$(DL_DIR)/$(MULTIBOX_BOOTARGS_SOURCE):
	$(download) $(MULTIBOX_MULTI_RECOVERY_SITE)/$(MULTIBOX_BOOTARGS_SOURCE)
endif

$(DL_DIR)/$(MULTIBOX_FASTBOOT_SOURCE):
	$(download) $(MULTIBOX_MULTI_RECOVERY_SITE)/$(MULTIBOX_FASTBOOT_SOURCE)

$(DL_DIR)/$(MULTIBOX_PARAM_SOURCE):
	$(download) $(MULTIBOX_MULTI_RECOVERY_SITE)/$(MULTIBOX_PARAM_SOURCE)

$(DL_DIR)/$(MULTIBOX_RECOVERY_SOURCE):
	$(download) $(MULTIBOX_MULTI_RECOVERY_SITE)/$(MULTIBOX_RECOVERY_SOURCE)

flash-image-multibox-multi-recovery: $(DL_DIR)/$(MULTIBOX_BOOTARGS_SOURCE)
flash-image-multibox-multi-recovery: $(DL_DIR)/$(MULTIBOX_FASTBOOT_SOURCE)
flash-image-multibox-multi-recovery: $(DL_DIR)/$(MULTIBOX_PARAM_SOURCE)
flash-image-multibox-multi-recovery: $(DL_DIR)/$(MULTIBOX_RECOVERY_SOURCE)
flash-image-multibox-multi-recovery: | $(IMAGE_DIR)
	rm -rf $(IMAGE_BUILD_DIR)
	$(INSTALL) -d $(IMAGE_BUILD_DIR)/$(IMAGE_SUBDIR)
	unzip -o $(DL_DIR)/$(MULTIBOX_BOOTARGS_SOURCE) -d $(IMAGE_BUILD_DIR)
	unzip -o $(DL_DIR)/$(MULTIBOX_FASTBOOT_SOURCE) -d $(IMAGE_BUILD_DIR)
	unzip -o $(DL_DIR)/$(MULTIBOX_PARAM_SOURCE) -d $(IMAGE_BUILD_DIR)
	unzip -o $(DL_DIR)/$(MULTIBOX_RECOVERY_SOURCE) -d $(IMAGE_BUILD_DIR)
	$(INSTALL_EXEC) $(IMAGE_BUILD_DIR)/update_bootargs_$(BOXMODEL).bin $(ROOTFS_DIR)$(datadir)/update_bootargs_$(BOXMODEL).bin
	dd if=/dev/zero of=$(IMAGE_BUILD_DIR)/$(IMAGE_SUBDIR)/$(MULTIBOX_BOOT_IMAGE) bs=1024 count=$(MULTIBOX_BOOTOPTIONS_PARTITION_SIZE)
	mkfs.msdos -S 512 $(IMAGE_BUILD_DIR)/$(IMAGE_SUBDIR)/$(MULTIBOX_BOOT_IMAGE)
	echo "bootcmd=setenv bootargs \$$(bootargs) \$$(bootargs_common); mmc read 0 0x1000000 0x3BD000 0x8000; bootm 0x1000000; run bootcmd_fallback" > $(IMAGE_BUILD_DIR)/STARTUP
	echo "bootargs=root=/dev/mmcblk0p23 rootsubdir=linuxrootfs1 rootfstype=ext4 kernel=/dev/mmcblk0p19" >> $(IMAGE_BUILD_DIR)/STARTUP
	echo "bootcmd=setenv bootargs \$$(bootargs) \$$(bootargs_common); run bootcmd_android; run bootcmd_fallback" > $(IMAGE_BUILD_DIR)/STARTUP_ANDROID
	echo "bootargs=androidboot.selinux=disabled androidboot.serialno=0123456789" >> $(IMAGE_BUILD_DIR)/STARTUP_ANDROID
	echo "bootcmd=setenv bootargs \$$(bootargs) \$$(bootargs_common); run bootcmd_android; run bootcmd_fallback" > $(IMAGE_BUILD_DIR)/STARTUP_ANDROID_DISABLE_LINUXSE
	echo "bootargs=androidboot.selinux=disabled androidboot.serialno=0123456789" >> $(IMAGE_BUILD_DIR)/STARTUP_ANDROID_DISABLE_LINUXSE
	echo "bootcmd=setenv bootargs \$$(bootargs) \$$(bootargs_common); mmc read 0 0x1000000 0x3BD000 0x8000; bootm 0x1000000; run bootcmd_fallback" > $(IMAGE_BUILD_DIR)/STARTUP_LINUX_1
	echo "bootargs=root=/dev/mmcblk0p23 rootsubdir=linuxrootfs1 rootfstype=ext4 kernel=/dev/mmcblk0p19" >> $(IMAGE_BUILD_DIR)/STARTUP_LINUX_1
	echo "bootcmd=setenv bootargs \$$(bootargs) \$$(bootargs_common); mmc read 0 0x1000000 0x3C5000 0x8000; bootm 0x1000000; run bootcmd_fallback" > $(IMAGE_BUILD_DIR)/STARTUP_LINUX_2
	echo "bootargs=root=/dev/mmcblk0p23 rootsubdir=linuxrootfs2 rootfstype=ext4 kernel=/dev/mmcblk0p20" >> $(IMAGE_BUILD_DIR)/STARTUP_LINUX_2
	echo "bootcmd=setenv bootargs \$$(bootargs) \$$(bootargs_common); mmc read 0 0x1000000 0x3CD000 0x8000; bootm 0x1000000; run bootcmd_fallback" > $(IMAGE_BUILD_DIR)/STARTUP_LINUX_3
	echo "bootargs=root=/dev/mmcblk0p23 rootsubdir=linuxrootfs3 rootfstype=ext4 kernel=/dev/mmcblk0p21" >> $(IMAGE_BUILD_DIR)/STARTUP_LINUX_3
	echo "bootcmd=setenv bootargs \$$(bootargs) \$$(bootargs_common); mmc read 0 0x1000000 0x3D5000 0x8000; bootm 0x1000000; run bootcmd_fallback" > $(IMAGE_BUILD_DIR)/STARTUP_LINUX_4
	echo "bootargs=root=/dev/mmcblk0p23 rootsubdir=linuxrootfs4 rootfstype=ext4 kernel=/dev/mmcblk0p22" >> $(IMAGE_BUILD_DIR)/STARTUP_LINUX_4
	echo "bootcmd=setenv bootargs \$$(bootargs_common); mmc read 0 0x1000000 0x1000 0x9000; bootm 0x1000000" > $(IMAGE_BUILD_DIR)/STARTUP_RECOVERY
	$(INSTALL_DATA) -D $(PACKAGE_DIR)/bootmenu/files/$(BOXMODEL)/bootmenu.conf $(IMAGE_BUILD_DIR)/bootmenu.conf
	mcopy -i $(IMAGE_BUILD_DIR)/$(IMAGE_SUBDIR)/$(MULTIBOX_BOOT_IMAGE) -v $(IMAGE_BUILD_DIR)/STARTUP ::
	mcopy -i $(IMAGE_BUILD_DIR)/$(IMAGE_SUBDIR)/$(MULTIBOX_BOOT_IMAGE) -v $(IMAGE_BUILD_DIR)/STARTUP_ANDROID ::
	mcopy -i $(IMAGE_BUILD_DIR)/$(IMAGE_SUBDIR)/$(MULTIBOX_BOOT_IMAGE) -v $(IMAGE_BUILD_DIR)/STARTUP_ANDROID_DISABLE_LINUXSE ::
	mcopy -i $(IMAGE_BUILD_DIR)/$(IMAGE_SUBDIR)/$(MULTIBOX_BOOT_IMAGE) -v $(IMAGE_BUILD_DIR)/STARTUP_LINUX_1 ::
	mcopy -i $(IMAGE_BUILD_DIR)/$(IMAGE_SUBDIR)/$(MULTIBOX_BOOT_IMAGE) -v $(IMAGE_BUILD_DIR)/STARTUP_LINUX_2 ::
	mcopy -i $(IMAGE_BUILD_DIR)/$(IMAGE_SUBDIR)/$(MULTIBOX_BOOT_IMAGE) -v $(IMAGE_BUILD_DIR)/STARTUP_LINUX_3 ::
	mcopy -i $(IMAGE_BUILD_DIR)/$(IMAGE_SUBDIR)/$(MULTIBOX_BOOT_IMAGE) -v $(IMAGE_BUILD_DIR)/STARTUP_LINUX_4 ::
	mcopy -i $(IMAGE_BUILD_DIR)/$(IMAGE_SUBDIR)/$(MULTIBOX_BOOT_IMAGE) -v $(IMAGE_BUILD_DIR)/STARTUP_RECOVERY ::
	mcopy -i $(IMAGE_BUILD_DIR)/$(IMAGE_SUBDIR)/$(MULTIBOX_BOOT_IMAGE) -v $(IMAGE_BUILD_DIR)/bootmenu.conf ::
	mv $(IMAGE_BUILD_DIR)/pq_param.bin $(IMAGE_BUILD_DIR)/$(IMAGE_SUBDIR)
	mv $(IMAGE_BUILD_DIR)/baseparam.img $(IMAGE_BUILD_DIR)/$(IMAGE_SUBDIR)
	echo boot-recovery > $(IMAGE_BUILD_DIR)/$(IMAGE_SUBDIR)/misc-boot.img
	rm -rf $(IMAGE_BUILD_DIR)/STARTUP*
	rm -rf $(IMAGE_BUILD_DIR)/*.conf
	rm -rf $(IMAGE_BUILD_DIR)/*.txt
	rm -rf $(IMAGE_BUILD_DIR)/$(IMAGE_SUBDIR)/*.txt
	rm -rf $(IMAGE_BUILD_DIR)/$(MULTIBOX_IMAGE_LINK)
	cp $(SUPPORT_DIR)/splash-images/ni-splash-$(BOXSERIES).img $(IMAGE_BUILD_DIR)/$(IMAGE_SUBDIR)/logo.img
	echo $(IMAGE_NAME)_recovery > $(IMAGE_BUILD_DIR)/$(IMAGE_SUBDIR)/recoveryversion
	echo "***** ACHTUNG *****" >$(IMAGE_BUILD_DIR)/recovery_$(BOXMODEL)_lies.mich
	echo "Das RECOVERY wird nur benötigt wenn es Probleme beim Zugriff auf das MULTIBOOT MENÜ gibt." >> $(IMAGE_BUILD_DIR)/recovery_$(BOXMODEL)_lies.mich
	echo "Das $(IMAGE_NAME)_multi_recovery.zip sollte normalerweise nur einmal installiert werden (oder wenn es ein Update gibt)." >> $(IMAGE_BUILD_DIR)/recovery_$(BOXMODEL)_lies.mich
	echo "Dies ist erforderlich, um Probleme mit dem Images zuvermeiden, wenn sich der Aufbau der Partition (bootargs) ändert." >> $(IMAGE_BUILD_DIR)/recovery_$(BOXMODEL)_lies.mich
	echo "Die Änderungen können alle Daten im Flash löschen. Nur installieren, wenn es notwendig ist." >> $(IMAGE_BUILD_DIR)/recovery_$(BOXMODEL)_lies.mich
	echo "***** ATTENTION *****" > $(IMAGE_BUILD_DIR)/recovery_$(BOXMODEL)_read.me
	echo "This RECOVERY is only needed when you have issues access the MULTIBOOT MENU." >> $(IMAGE_BUILD_DIR)/recovery_$(BOXMODEL)_read.me
	echo "The $(IMAGE_NAME)_multi_recovery.zip should been installed just once (or if there is an update)." >> $(IMAGE_BUILD_DIR)/recovery_$(BOXMODEL)_read.me
	echo "This is necessary to avoid problems with the image if the partition structure (bootargs) changes." >> $(IMAGE_BUILD_DIR)/recovery_$(BOXMODEL)_read.me
	echo "A small change can destroy all your installed images. So you better leave it and don't install it if it's not needed." >> $(IMAGE_BUILD_DIR)/recovery_$(BOXMODEL)_read.me
	$(CD) $(IMAGE_BUILD_DIR); \
		zip -r $(IMAGE_DIR)/$(IMAGE_NAME)_multi_recovery.zip *
	rm -rf $(IMAGE_BUILD_DIR)

flash-image-hd6x-single: $(if $(filter $(BOXMODEL),hd60 hd61),flash-image-hd6x-multi-recovery)
flash-image-hd6x-single: $(if $(filter $(BOXMODEL),multibox multiboxse),flash-image-multibox-multi-recovery)
flash-image-hd6x-single: | $(IMAGE_DIR)
	rm -rf $(IMAGE_BUILD_DIR)
	$(INSTALL) -d $(IMAGE_BUILD_DIR)/$(IMAGE_SUBDIR)
	cp $(KERNEL_UIMAGE) $(IMAGE_BUILD_DIR)/$(IMAGE_SUBDIR)/uImage
	$(CD) $(ROOTFS_DIR); \
		tar -cvf $(IMAGE_BUILD_DIR)/$(IMAGE_SUBDIR)/rootfs.tar -C $(ROOTFS_DIR) . >/dev/null 2>&1; \
		bzip2 $(IMAGE_BUILD_DIR)/$(IMAGE_SUBDIR)/rootfs.tar
	echo $(IMAGE_NAME) > $(IMAGE_BUILD_DIR)/$(IMAGE_SUBDIR)/imageversion
	echo "$(IMAGE_NAME)_single_mmc.zip" > $(IMAGE_BUILD_DIR)/unforce_$(BOXMODEL).txt
	echo "Rename the unforce_$(BOXMODEL).txt to force_$(BOXMODEL).txt and move it to the root of your usb-stick" > $(IMAGE_BUILD_DIR)/$(IMAGE_SUBDIR)/force_$(BOXMODEL)_read.me
	echo "When you enter the recovery menu then it will force to install the image $(IMAGE_NAME)_single_mmc.zip into image-slot1" >> $(IMAGE_BUILD_DIR)/$(IMAGE_SUBDIR)/force_$(BOXMODEL)_read.me
	$(CD) $(IMAGE_BUILD_DIR); \
		zip -r $(IMAGE_DIR)/$(IMAGE_NAME)_single_mmc.zip *
	rm -rf $(IMAGE_BUILD_DIR)

# -----------------------------------------------------------------------------

# armbox vu+
flash-image-vuplus: IMAGE_DATE=$(shell cat $(ROOTFS_DIR)/.version | grep "^version=" | cut -d= -f2 | cut -c 5-)
flash-image-vuplus: | $(IMAGE_DIR)
	rm -rf $(IMAGE_BUILD_DIR)
	$(INSTALL) -d $(IMAGE_BUILD_DIR)/$(IMAGE_SUBDIR)
	cp $(KERNEL_ZIMAGE) $(IMAGE_BUILD_DIR)/$(IMAGE_SUBDIR)/kernel_auto.bin
	$(CD) $(ROOTFS_DIR); \
		tar -cvf $(IMAGE_BUILD_DIR)/$(IMAGE_SUBDIR)/rootfs.tar -C $(ROOTFS_DIR) . >/dev/null 2>&1; \
		bzip2 $(IMAGE_BUILD_DIR)/$(IMAGE_SUBDIR)/rootfs.tar
	# Create minimal image
	$(CD) $(IMAGE_BUILD_DIR)/$(IMAGE_SUBDIR); \
		tar -czf $(IMAGE_DIR)/$(IMAGE_NAME).tgz kernel_auto.bin rootfs.tar.bz2
	$(call create_md5file,$(IMAGE_NAME).tgz)
	rm -rf $(IMAGE_BUILD_DIR)

flash-image-vuplus-multi: vmlinuz-initrd
flash-image-vuplus-multi: | $(IMAGE_DIR)
	rm -rf $(IMAGE_BUILD_DIR)
	$(INSTALL) -d $(IMAGE_BUILD_DIR)/$(IMAGE_SUBDIR)
	cp $(SUPPORT_DIR)/splash-images/ni-splash.bmp $(IMAGE_BUILD_DIR)/$(IMAGE_SUBDIR)/splash_auto.bin
	cp $(BUILD_DIR)/$(VMLINUZ_INITRD) $(IMAGE_BUILD_DIR)/$(IMAGE_SUBDIR)/initrd_auto.bin
	echo Dummy for update. > $(IMAGE_BUILD_DIR)/$(IMAGE_SUBDIR)/kernel_auto.bin
	cp $(KERNEL_ZIMAGE) $(IMAGE_BUILD_DIR)/$(IMAGE_SUBDIR)/kernel1_auto.bin
	cp $(KERNEL_ZIMAGE) $(IMAGE_BUILD_DIR)/$(IMAGE_SUBDIR)/kernel2_auto.bin
	cp $(KERNEL_ZIMAGE) $(IMAGE_BUILD_DIR)/$(IMAGE_SUBDIR)/kernel3_auto.bin
	cp $(KERNEL_ZIMAGE) $(IMAGE_BUILD_DIR)/$(IMAGE_SUBDIR)/kernel4_auto.bin
	echo Dummy for update. > $(IMAGE_BUILD_DIR)/$(IMAGE_SUBDIR)/rootfs.tar.bz2
	$(CD) $(ROOTFS_DIR); \
		tar -cvf $(IMAGE_BUILD_DIR)/$(IMAGE_SUBDIR)/rootfs1.tar -C $(ROOTFS_DIR) . >/dev/null 2>&1; \
		bzip2 $(IMAGE_BUILD_DIR)/$(IMAGE_SUBDIR)/rootfs1.tar
	echo Dummy for update. > $(IMAGE_BUILD_DIR)/$(IMAGE_SUBDIR)/rootfs2.tar.bz2
	echo Dummy for update. > $(IMAGE_BUILD_DIR)/$(IMAGE_SUBDIR)/rootfs3.tar.bz2
	echo Dummy for update. > $(IMAGE_BUILD_DIR)/$(IMAGE_SUBDIR)/rootfs4.tar.bz2
ifeq ($(BOXMODEL),$(filter $(BOXMODEL),vuzero4k vuuno4k))
	echo This file forces the update. > $(IMAGE_BUILD_DIR)/$(IMAGE_SUBDIR)/force.update
else
	echo This file forces a reboot after the update. > $(IMAGE_BUILD_DIR)/$(IMAGE_SUBDIR)/reboot.update
endif
	echo This file forces creating partitions. > $(IMAGE_BUILD_DIR)/$(IMAGE_SUBDIR)/mkpart.update
	echo $(IMAGE_PREFIX) > $(IMAGE_BUILD_DIR)/$(IMAGE_SUBDIR)/imageversion
	# Create final USB-image
	$(CD) $(IMAGE_BUILD_DIR); \
		zip -r $(IMAGE_DIR)/$(IMAGE_NAME)_multi_usb.zip $(IMAGE_SUBDIR)/*
	rm -rf $(IMAGE_BUILD_DIR)

# -----------------------------------------------------------------------------

flash-image-vuduo:

# -----------------------------------------------------------------------------

PHONY += devtable
PHONY += devtable-remove
PHONY += flash-image-coolstream
PHONY += check-image-size
PHONY += flash-image-hd5x
PHONY += flash-image-hd5x-multi
PHONY += flash-image-hd6x
PHONY += flash-image-hd6x-multi-recovery
PHONY += flash-image-hd6x-single
PHONY += flash-image-vuplus
PHONY += flash-image-vuplus-multi
