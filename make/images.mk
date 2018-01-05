
# makefile to generate images; also holds useful variables.

# Release date
IMAGE_DATE	= $(shell date +%Y%m%d%H%M)

# Version Strings
IMAGE_VERSION	= 350
IMAGE_PREFIX	= ni$(IMAGE_VERSION)-$(IMAGE_DATE)
IMAGE_SUFFIX	= $(BOXTYPE_SC)-$(BOXMODEL)

# Image-Type
# Release	= 0
# Beta		= 1
# Nightly	= 2
IMAGE_TYPE	?= 0

# JFFS2-Summary
SUMMARIZE	= yes

# newimage-flag
NEWIMAGE	= no

# Beta/Release Server
NI-SERVER	= http://neutrino-images.de/neutrino-images
ifeq ($(IMAGE_TYPE), 0)
  # Release
  NI-SUBDIR	= release
  IMAGE_TYPE_STRING = release
else ifeq ($(IMAGE_TYPE), 1)
  # Beta
  NI-SUBDIR	= beta
  IMAGE_TYPE_STRING = beta
else
  # Nightly
  NI-SUBDIR	= nightly
  IMAGE_TYPE_STRING = nightly
endif

IMAGE_URL	= $(NI-SERVER)/$(NI-SUBDIR)
IMAGE_VERSION_STRING = $(shell echo $(IMAGE_VERSION) | sed -e :a -e 's/\(.*[0-9]\)\([0-9]\{2\}\)/\1.\2/;ta')

BOX		= $(BUILD_TMP)/rootfs

MKFSFLAGS	= -U -D $(BUILD_TMP)/devtable-$(BOXSERIES).txt -r $(BOX)
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

images:
ifeq ($(BOXMODEL), nevis)
	make flash-image-cst ERASE_SIZE=0x20000 BOXNAME="HD1, BSE, Neo, Neo², Zee"
endif
ifeq ($(BOXFAMILY), apollo)
	make flash-image-cst ERASE_SIZE=0x40000 BOXNAME="Tank"    IMAGE_SUFFIX=$(BOXTYPE_SC)-apollo
	make flash-image-cst ERASE_SIZE=0x20000 BOXNAME="Trinity" IMAGE_SUFFIX=$(BOXTYPE_SC)-shiner
endif
ifeq ($(BOXMODEL), kronos)
	make flash-image-cst ERASE_SIZE=0x20000 BOXNAME="Zee², Trinity V2"
endif
ifeq ($(BOXMODEL), kronos_v2)
	make flash-image-cst ERASE_SIZE=0x20000 BOXNAME="Link, Trinity Duo"
endif
ifeq ($(BOXMODEL), hd51)
	make flash-image-arm
	make flash-image-arm-multi
endif

flash-image-cst: IMAGE_NAME=$(IMAGE_PREFIX)-$(IMAGE_SUFFIX)
flash-image-cst: IMAGE_DESC="$(BOXNAME) [$(IMAGE_SUFFIX)][$(BOXSERIES)] $(shell echo $(IMAGE_TYPE_STRING) | sed 's/.*/\u&/')"
flash-image-cst: IMAGE_MD5FILE=$(IMAGE_TYPE_STRING)-$(IMAGE_SUFFIX).txt
flash-image-cst: IMAGE_DATE=$(shell cat $(BOX)/.version | grep "^version=" | cut -d= -f2 | cut -c 5-)
flash-image-cst:
	make devtable
	mkfs.jffs2 -e $(ERASE_SIZE) $(MKFSFLAGS) -o $(IMAGE_DIR)/$(IMAGE_NAME).img
	make devtable-remove
ifeq ($(SUMMARIZE), yes)
	sumtool -e $(ERASE_SIZE) $(SUMFLAGS) -i $(IMAGE_DIR)/$(IMAGE_NAME).img -o $(IMAGE_DIR)/$(IMAGE_NAME)-sum.img
	rm -f $(IMAGE_DIR)/$(IMAGE_NAME).img
	mv $(IMAGE_DIR)/$(IMAGE_NAME)-sum.img $(IMAGE_DIR)/$(IMAGE_NAME).img
endif
	echo $(IMAGE_URL)/$(IMAGE_NAME).img $(IMAGE_TYPE)$(IMAGE_VERSION)$(IMAGE_DATE) `md5sum $(IMAGE_DIR)/$(IMAGE_NAME).img | cut -c1-32` $(IMAGE_DESC) $(IMAGE_VERSION_STRING) >> $(IMAGE_DIR)/$(IMAGE_MD5FILE)
	make check-image-size IMAGE_TO_CHECK=$(IMAGE_DIR)/$(IMAGE_NAME).img

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

### armbox hd51

# general
HD51_IMAGE_NAME = disk
HD51_BOOT_IMAGE = boot.img
HD51_IMAGE_LINK = $(HD51_IMAGE_NAME).ext4
HD51_IMAGE_ROOTFS_SIZE = 294912
HD51_BUILD_TMP = $(BUILD_TMP)/tmp

# emmc image
EMMC_IMAGE_SIZE = 3817472
EMMC_IMAGE = $(HD51_BUILD_TMP)/$(HD51_IMAGE_NAME).img

# partition sizes
BLOCK_SIZE = 512
BLOCK_SECTOR = 2
IMAGE_ROOTFS_ALIGNMENT = 1024
BOOT_PARTITION_SIZE = 3072
KERNEL_PARTITION_OFFSET = $(shell expr $(IMAGE_ROOTFS_ALIGNMENT) \+ $(BOOT_PARTITION_SIZE))
KERNEL_PARTITION_SIZE = 8192
ROOTFS_PARTITION_OFFSET = $(shell expr $(KERNEL_PARTITION_OFFSET) \+ $(KERNEL_PARTITION_SIZE))
ROOTFS_PARTITION_SIZE_MULTI = 819200
SECOND_KERNEL_PARTITION_OFFSET = $(shell expr $(ROOTFS_PARTITION_OFFSET) \+ $(ROOTFS_PARTITION_SIZE_MULTI))

SECOND_ROOTFS_PARTITION_OFFSET = $(shell expr $(SECOND_KERNEL_PARTITION_OFFSET) \+ $(KERNEL_PARTITION_SIZE))
THIRD_KERNEL_PARTITION_OFFSET = $(shell expr $(SECOND_ROOTFS_PARTITION_OFFSET) \+ $(ROOTFS_PARTITION_SIZE_MULTI))
THIRD_ROOTFS_PARTITION_OFFSET = $(shell expr $(THIRD_KERNEL_PARTITION_OFFSET) \+ $(KERNEL_PARTITION_SIZE))
FOURTH_KERNEL_PARTITION_OFFSET = $(shell expr $(THIRD_ROOTFS_PARTITION_OFFSET) \+ $(ROOTFS_PARTITION_SIZE_MULTI))
FOURTH_ROOTFS_PARTITION_OFFSET = $(shell expr $(FOURTH_KERNEL_PARTITION_OFFSET) \+ $(KERNEL_PARTITION_SIZE))
SWAP_PARTITION_OFFSET = $(shell expr $(FOURTH_ROOTFS_PARTITION_OFFSET) \+ $(ROOTFS_PARTITION_SIZE_MULTI))

flash-image-arm-multi:
	mkdir -p $(HD51_BUILD_TMP)
	# Create a sparse image block
	dd if=/dev/zero of=$(HD51_BUILD_TMP)/$(HD51_IMAGE_LINK) seek=$(shell expr $(HD51_IMAGE_ROOTFS_SIZE) \* $(BLOCK_SECTOR)) count=0 bs=$(BLOCK_SIZE)
	mkfs.ext4 -F $(HD51_BUILD_TMP)/$(HD51_IMAGE_LINK) -d $(BOX)
	# Error codes 0-3 indicate successfull operation of fsck (no errors or errors corrected)
	fsck.ext4 -pvfD $(HD51_BUILD_TMP)/$(HD51_IMAGE_LINK) || [ $? -le 3 ]
	dd if=/dev/zero of=$(EMMC_IMAGE) bs=$(BLOCK_SIZE) count=0 seek=$(shell expr $(EMMC_IMAGE_SIZE) \* $(BLOCK_SECTOR))
	parted -s $(EMMC_IMAGE) mklabel gpt
	parted -s $(EMMC_IMAGE) unit KiB mkpart boot fat16 $(IMAGE_ROOTFS_ALIGNMENT) $(shell expr $(IMAGE_ROOTFS_ALIGNMENT) \+ $(BOOT_PARTITION_SIZE))
	parted -s $(EMMC_IMAGE) unit KiB mkpart kernel1 $(KERNEL_PARTITION_OFFSET) $(shell expr $(KERNEL_PARTITION_OFFSET) \+ $(KERNEL_PARTITION_SIZE))
	parted -s $(EMMC_IMAGE) unit KiB mkpart rootfs1 ext4 $(ROOTFS_PARTITION_OFFSET) $(shell expr $(ROOTFS_PARTITION_OFFSET) \+ $(ROOTFS_PARTITION_SIZE_MULTI))
	parted -s $(EMMC_IMAGE) unit KiB mkpart kernel2 $(SECOND_KERNEL_PARTITION_OFFSET) $(shell expr $(SECOND_KERNEL_PARTITION_OFFSET) \+ $(KERNEL_PARTITION_SIZE))
	parted -s $(EMMC_IMAGE) unit KiB mkpart rootfs2 ext4 $(SECOND_ROOTFS_PARTITION_OFFSET) $(shell expr $(SECOND_ROOTFS_PARTITION_OFFSET) \+ $(ROOTFS_PARTITION_SIZE_MULTI))
	parted -s $(EMMC_IMAGE) unit KiB mkpart kernel3 $(THIRD_KERNEL_PARTITION_OFFSET) $(shell expr $(THIRD_KERNEL_PARTITION_OFFSET) \+ $(KERNEL_PARTITION_SIZE))
	parted -s $(EMMC_IMAGE) unit KiB mkpart rootfs3 ext4 $(THIRD_ROOTFS_PARTITION_OFFSET) $(shell expr $(THIRD_ROOTFS_PARTITION_OFFSET) \+ $(ROOTFS_PARTITION_SIZE_MULTI))
	parted -s $(EMMC_IMAGE) unit KiB mkpart kernel4 $(FOURTH_KERNEL_PARTITION_OFFSET) $(shell expr $(FOURTH_KERNEL_PARTITION_OFFSET) \+ $(KERNEL_PARTITION_SIZE))
	parted -s $(EMMC_IMAGE) unit KiB mkpart rootfs4 ext4 $(FOURTH_ROOTFS_PARTITION_OFFSET) $(shell expr $(FOURTH_ROOTFS_PARTITION_OFFSET) \+ $(ROOTFS_PARTITION_SIZE_MULTI))
	parted -s $(EMMC_IMAGE) unit KiB mkpart swap linux-swap $(SWAP_PARTITION_OFFSET) $(shell expr $(EMMC_IMAGE_SIZE) \- 1024)
	dd if=/dev/zero of=$(HD51_BUILD_TMP)/$(HD51_BOOT_IMAGE) bs=$(BLOCK_SIZE) count=$(shell expr $(BOOT_PARTITION_SIZE) \* $(BLOCK_SECTOR))
	mkfs.msdos -S 512 $(HD51_BUILD_TMP)/$(HD51_BOOT_IMAGE)
	echo "boot emmcflash0.kernel1 'brcm_cma=520M@248M brcm_cma=200M@768M root=/dev/mmcblk0p3 rw rootwait $(BOXMODEL)_4.boxmode=12'" > $(HD51_BUILD_TMP)/STARTUP
	echo "boot emmcflash0.kernel1 'brcm_cma=520M@248M brcm_cma=200M@768M root=/dev/mmcblk0p3 rw rootwait $(BOXMODEL)_4.boxmode=12'" > $(HD51_BUILD_TMP)/STARTUP_1
	echo "boot emmcflash0.kernel2 'brcm_cma=520M@248M brcm_cma=200M@768M root=/dev/mmcblk0p5 rw rootwait $(BOXMODEL)_4.boxmode=12'" > $(HD51_BUILD_TMP)/STARTUP_2
	echo "boot emmcflash0.kernel3 'brcm_cma=520M@248M brcm_cma=200M@768M root=/dev/mmcblk0p7 rw rootwait $(BOXMODEL)_4.boxmode=12'" > $(HD51_BUILD_TMP)/STARTUP_3
	echo "boot emmcflash0.kernel4 'brcm_cma=520M@248M brcm_cma=200M@768M root=/dev/mmcblk0p9 rw rootwait $(BOXMODEL)_4.boxmode=12'" > $(HD51_BUILD_TMP)/STARTUP_4
	mcopy -i $(HD51_BUILD_TMP)/$(HD51_BOOT_IMAGE) -v $(HD51_BUILD_TMP)/STARTUP ::
	mcopy -i $(HD51_BUILD_TMP)/$(HD51_BOOT_IMAGE) -v $(HD51_BUILD_TMP)/STARTUP_1 ::
	mcopy -i $(HD51_BUILD_TMP)/$(HD51_BOOT_IMAGE) -v $(HD51_BUILD_TMP)/STARTUP_2 ::
	mcopy -i $(HD51_BUILD_TMP)/$(HD51_BOOT_IMAGE) -v $(HD51_BUILD_TMP)/STARTUP_3 ::
	mcopy -i $(HD51_BUILD_TMP)/$(HD51_BOOT_IMAGE) -v $(HD51_BUILD_TMP)/STARTUP_4 ::
	dd conv=notrunc if=$(HD51_BUILD_TMP)/$(HD51_BOOT_IMAGE) of=$(EMMC_IMAGE) bs=$(BLOCK_SIZE) seek=$(shell expr $(IMAGE_ROOTFS_ALIGNMENT) \* $(BLOCK_SECTOR))
	dd conv=notrunc if=$(ZIMAGE_DTB) of=$(EMMC_IMAGE) bs=$(BLOCK_SIZE) seek=$(shell expr $(KERNEL_PARTITION_OFFSET) \* $(BLOCK_SECTOR))
	resize2fs $(HD51_BUILD_TMP)/$(HD51_IMAGE_LINK) $(ROOTFS_PARTITION_SIZE_MULTI)k
	# Truncate on purpose
	dd if=$(HD51_BUILD_TMP)/$(HD51_IMAGE_LINK) of=$(EMMC_IMAGE) bs=$(BLOCK_SIZE) seek=$(shell expr $(ROOTFS_PARTITION_OFFSET) \* $(BLOCK_SECTOR)) count=$(shell expr $(HD51_IMAGE_ROOTFS_SIZE) \* $(BLOCK_SECTOR))
	# Create final USB-image
	mkdir -p $(IMAGE_DIR)/$(BOXMODEL)
	cp $(ZIMAGE_DTB) $(IMAGE_DIR)/$(BOXMODEL)/kernel.bin
	cp $(EMMC_IMAGE) $(IMAGE_DIR)/$(BOXMODEL)
	cd $(BOX); \
	tar -cvf $(IMAGE_DIR)/$(BOXMODEL)/rootfs.tar -C $(BOX) .  > /dev/null 2>&1; \
	bzip2 $(IMAGE_DIR)/$(BOXMODEL)/rootfs.tar
	echo $(IMAGE_PREFIX) > $(IMAGE_DIR)/$(BOXMODEL)/imageversion
	cd $(IMAGE_DIR); \
	zip -r $(IMAGE_PREFIX)-$(IMAGE_SUFFIX)_multi_usb.zip $(BOXMODEL)/*
	# cleanup
	rm -rf $(IMAGE_DIR)/$(BOXMODEL)
	rm -rf $(HD51_BUILD_TMP)

flash-image-arm: BOXNAME="AX/Mut@nt"
flash-image-arm: IMAGE_NAME=$(IMAGE_PREFIX)-$(IMAGE_SUFFIX)
flash-image-arm: IMAGE_DESC="$(BOXNAME) [$(IMAGE_SUFFIX)] $(shell echo $(IMAGE_TYPE_STRING) | sed 's/.*/\u&/')"
flash-image-arm: IMAGE_MD5FILE=$(IMAGE_TYPE_STRING)-$(IMAGE_SUFFIX).txt
flash-image-arm: IMAGE_DATE=$(shell cat $(BOX)/.version | grep "^version=" | cut -d= -f2 | cut -c 5-)
flash-image-arm:
	mkdir -p $(IMAGE_DIR)/$(BOXMODEL)
	cp $(ZIMAGE_DTB) $(IMAGE_DIR)/$(BOXMODEL)/kernel.bin
	cd $(BOX); \
	tar -cvf $(IMAGE_DIR)/$(BOXMODEL)/rootfs.tar -C $(BOX) .  > /dev/null 2>&1; \
	bzip2 $(IMAGE_DIR)/$(BOXMODEL)/rootfs.tar
	# Create minimal image
	cd $(IMAGE_DIR)/$(BOXMODEL); \
	tar -czf $(IMAGE_DIR)/$(IMAGE_NAME).tgz kernel.bin rootfs.tar.bz2
	rm -rf $(IMAGE_DIR)/$(BOXMODEL)
	echo $(IMAGE_URL)/$(IMAGE_NAME).tgz $(IMAGE_TYPE)$(IMAGE_VERSION)$(IMAGE_DATE) `md5sum $(IMAGE_DIR)/$(IMAGE_NAME).tgz | cut -c1-32` $(IMAGE_DESC) $(IMAGE_VERSION_STRING) >> $(IMAGE_DIR)/$(IMAGE_MD5FILE)
