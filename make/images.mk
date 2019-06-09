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
	echo	"/dev/pts	d	755	0	0	-	-	-	-	-"	> $@
	echo	"/dev/shm	d	755	0	0	-	-	-	-	-"	>> $@
	echo	"/dev/shm/usb	d	755	0	0	-	-	-	-	-"	>> $@
	echo	"/dev/null	c	666	0	0	1	3	0	0	-"	>> $@
	echo	"/dev/console	c	666	0	0	5	1	-	-	-"	>> $@
	echo	"/dev/ttyRI0	c	666	0	0	204	16	-	-	-"	>> $@
	echo	"/dev/mtd	c	640	0	0	90	0	0	2	6"	>> $@
	echo	"/dev/mtdblock	b	640	0	0	31	0	0	1	6"	>> $@

$(BUILD_TMP)/devtable-hd2.txt:
	#	<name>		<type>	<mode>	<uid>	<gid>	<major>	<minor>	<start>	<inc>	<count>
	echo	"/dev/pts	d	755	0	0	-	-	-	-	-"	> $@
	echo	"/dev/shm	d	755	0	0	-	-	-	-	-"	>> $@
	echo	"/dev/shm/usb	d	755	0	0	-	-	-	-	-"	>> $@
	echo	"/dev/null	c	666	0	0	1	3	0	0	-"	>> $@
	echo	"/dev/console	c	666	0	0	5	1	-	-	-"	>> $@
	echo	"/dev/ttyS0	c	666	0	0	4	64	-	-	-"	>> $@
	echo	"/dev/mtd	c	640	0	0	90	0	0	2	9"	>> $@
	echo	"/dev/mtdblock	b	640	0	0	31	0	0	1	9"	>> $@

devtable-remove:
	$(REMOVE)/devtable-$(BOXSERIES).txt

# -----------------------------------------------------------------------------

flash-image:
ifeq ($(BOXMODEL), nevis)
	make flash-image-coolstream ERASE_SIZE=0x20000 BOXNAME="HD1, BSE, Neo, Neo², Zee"
endif
ifeq ($(BOXFAMILY), apollo)
	make flash-image-coolstream ERASE_SIZE=0x40000 BOXNAME="Tank"    IMAGE_SUFFIX=$(BOXTYPE_SC)-apollo
	make flash-image-coolstream ERASE_SIZE=0x20000 BOXNAME="Trinity" IMAGE_SUFFIX=$(BOXTYPE_SC)-shiner
endif
ifeq ($(BOXMODEL), kronos)
	make flash-image-coolstream ERASE_SIZE=0x20000 BOXNAME="Zee², Trinity V2"
endif
ifeq ($(BOXMODEL), kronos_v2)
	make flash-image-coolstream ERASE_SIZE=0x20000 BOXNAME="Link, Trinity Duo"
endif
ifeq ($(BOXMODEL), hd51)
	make flash-image-armbox BOXNAME="AX/Mut@nt HD51"
	make flash-image-armbox-multi
endif
ifeq ($(BOXMODEL), bre2ze4k)
	make flash-image-armbox BOXNAME="WWIO BRE2ZE4K"
	make flash-image-armbox-multi
endif

# -----------------------------------------------------------------------------

flash-image-coolstream: IMAGE_NAME=$(IMAGE_PREFIX)-$(IMAGE_SUFFIX)
flash-image-coolstream: IMAGE_DESC="$(BOXNAME) [$(IMAGE_SUFFIX)][$(BOXSERIES)] $(shell echo $(IMAGE_TYPE_STRING) | sed 's/.*/\u&/')"
flash-image-coolstream: IMAGE_MD5FILE=$(IMAGE_TYPE_STRING)-$(IMAGE_SUFFIX).txt
flash-image-coolstream: IMAGE_DATE=$(shell cat $(ROOTFS)/.version | grep "^version=" | cut -d= -f2 | cut -c 5-)
flash-image-coolstream:
	make devtable
	mkfs.jffs2 -e $(ERASE_SIZE) $(MKFSFLAGS) -o $(IMAGE_DIR)/$(IMAGE_NAME).img
	make devtable-remove
ifeq ($(IMAGE_SUMMARIZE), yes)
	sumtool -e $(ERASE_SIZE) $(SUMFLAGS) -i $(IMAGE_DIR)/$(IMAGE_NAME).img -o $(IMAGE_DIR)/$(IMAGE_NAME)-sum.img
	rm -f $(IMAGE_DIR)/$(IMAGE_NAME).img
	mv $(IMAGE_DIR)/$(IMAGE_NAME)-sum.img $(IMAGE_DIR)/$(IMAGE_NAME).img
endif
	echo $(IMAGE_URL)/$(IMAGE_NAME).img $(IMAGE_TYPE)$(IMAGE_VER)$(IMAGE_DATE) `md5sum $(IMAGE_DIR)/$(IMAGE_NAME).img | cut -c1-32` $(IMAGE_DESC) $(IMAGE_VERSION) >> $(IMAGE_DIR)/$(IMAGE_MD5FILE)
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

flash-image-armbox: IMAGE_NAME=$(IMAGE_PREFIX)-$(IMAGE_SUFFIX)
flash-image-armbox: IMAGE_DESC="$(BOXNAME) [$(IMAGE_SUFFIX)] $(shell echo $(IMAGE_TYPE_STRING) | sed 's/.*/\u&/')"
flash-image-armbox: IMAGE_MD5FILE=$(IMAGE_TYPE_STRING)-$(IMAGE_SUFFIX).txt
flash-image-armbox: IMAGE_DATE=$(shell cat $(ROOTFS)/.version | grep "^version=" | cut -d= -f2 | cut -c 5-)
flash-image-armbox:
	mkdir -p $(IMAGE_BUILD_TMP)/$(BOXMODEL)
	cp $(KERNEL_ZIMAGE_DTB) $(IMAGE_BUILD_TMP)/$(BOXMODEL)/kernel.bin
	$(CD) $(ROOTFS); \
		tar -cvf $(IMAGE_BUILD_TMP)/$(BOXMODEL)/rootfs.tar -C $(ROOTFS) . >/dev/null 2>&1; \
		bzip2 $(IMAGE_BUILD_TMP)/$(BOXMODEL)/rootfs.tar
	# Create minimal image
	$(CD) $(IMAGE_BUILD_TMP)/$(BOXMODEL); \
		tar -czf $(IMAGE_DIR)/$(IMAGE_NAME).tgz kernel.bin rootfs.tar.bz2
	echo $(IMAGE_URL)/$(IMAGE_NAME).tgz $(IMAGE_TYPE)$(IMAGE_VER)$(IMAGE_DATE) `md5sum $(IMAGE_DIR)/$(IMAGE_NAME).tgz | cut -c1-32` $(IMAGE_DESC) $(IMAGE_VERSION) >> $(IMAGE_DIR)/$(IMAGE_MD5FILE)
	rm -rf $(IMAGE_BUILD_TMP)/$(BOXMODEL)

# -----------------------------------------------------------------------------

# hd51 / bre2ze4k
HD51_IMAGE_NAME = disk
HD51_BOOT_IMAGE = boot.img
HD51_IMAGE_LINK = $(HD51_IMAGE_NAME).ext4
HD51_IMAGE_ROOTFS_SIZE = 294912

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

flash-image-armbox-multi: IMAGE_NAME=$(IMAGE_PREFIX)-$(IMAGE_SUFFIX)
flash-image-armbox-multi:
	mkdir -p $(IMAGE_BUILD_TMP)
	# Create a sparse image block
	dd if=/dev/zero of=$(IMAGE_BUILD_TMP)/$(HD51_IMAGE_LINK) seek=$(shell expr $(HD51_IMAGE_ROOTFS_SIZE) \* $(BLOCK_SECTOR)) count=0 bs=$(BLOCK_SIZE)
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
	mkdir -p $(IMAGE_DIR)/$(BOXMODEL)
	cp $(KERNEL_ZIMAGE_DTB) $(IMAGE_DIR)/$(BOXMODEL)/kernel.bin
	cp $(EMMC_IMAGE) $(IMAGE_DIR)/$(BOXMODEL)
	$(CD) $(ROOTFS); \
		tar -cvf $(IMAGE_DIR)/$(BOXMODEL)/rootfs.tar -C $(ROOTFS) . >/dev/null 2>&1; \
		bzip2 $(IMAGE_DIR)/$(BOXMODEL)/rootfs.tar
	echo $(IMAGE_PREFIX) > $(IMAGE_DIR)/$(BOXMODEL)/imageversion
	$(CD) $(IMAGE_DIR); \
		zip -r $(IMAGE_NAME)_multi_usb.zip $(BOXMODEL)/*
	# cleanup
	rm -rf $(IMAGE_DIR)/$(BOXMODEL)
	rm -rf $(IMAGE_BUILD_TMP)

# -----------------------------------------------------------------------------

PHONY += devtable
PHONY += devtable-remove
PHONY += flash-image-coolstream
PHONY += check-image-size
PHONY += flash-image-armbox
PHONY += flash-image-armbox-multi
