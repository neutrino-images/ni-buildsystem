
# makefile to generate images; also holds useful variables.

# Release date
IMAGE_DATE	= $(shell date +%Y%m%d%H%M)

# Version Strings
IMAGE_VERSION	= 340
IMAGE_PREFIX	= ni$(IMAGE_VERSION)-$(IMAGE_DATE)
IMAGE_SUFFIX	= $(BOXTYPE_SC)-$(BOXMODEL)

# Image-Type
# Release	= 0
# Beta		= 1
# Internal	= 2 <- not used atm
IMAGE_TYPE	= 0

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
else
  # Beta
  NI-SUBDIR	= beta
  IMAGE_TYPE_STRING = beta
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
	make flash-image ERASE_SIZE=0x20000 BOXNAME="HD1, BSE, Neo, Neo², Zee"
endif
ifeq ($(BOXFAMILY), apollo)
	make flash-image ERASE_SIZE=0x40000 BOXNAME="Tank"    IMAGE_SUFFIX=$(BOXTYPE_SC)-apollo
	make flash-image ERASE_SIZE=0x20000 BOXNAME="Trinity" IMAGE_SUFFIX=$(BOXTYPE_SC)-shiner
endif
ifeq ($(BOXMODEL), kronos)
	make flash-image ERASE_SIZE=0x20000 BOXNAME="Zee², Trinity V2"
endif
ifeq ($(BOXMODEL), kronos_v2)
	make flash-image ERASE_SIZE=0x20000 BOXNAME="Link, Trinity Duo"
endif
ifeq ($(BOXMODEL), hd51)
	make flash-image-axt
endif

flash-image: IMAGE_NAME=$(IMAGE_PREFIX)-$(IMAGE_SUFFIX)
flash-image: IMAGE_DESC="$(BOXNAME) [$(IMAGE_SUFFIX)][$(BOXSERIES)] $(shell echo $(IMAGE_TYPE_STRING) | sed 's/.*/\u&/')"
flash-image: IMAGE_MD5FILE=$(IMAGE_TYPE_STRING)-$(IMAGE_SUFFIX).txt
flash-image: IMAGE_DATE=$(shell cat $(BOX)/.version | grep "^version=" | cut -d= -f2 | cut -c 5-)
flash-image:
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

### AX-TECH

# general
AX_IMAGE_NAME = disc
AX_BOOT_IMAGE = boot.img
AX_IMAGE_LINK = $(AX_IMAGE_NAME).ext4
AX_IMAGE_ROOTFS_SIZE = 294912

# emmc image
EMMC_IMAGE_SIZE = 3817472
EMMC_IMAGE = $(BUILD_TMP)/$(AX_IMAGE_NAME).img

# partition sizes
GPT_OFFSET = 0
GPT_SIZE = 1024
BOOT_PARTITION_OFFSET = $(shell expr $(GPT_OFFSET) \+ $(GPT_SIZE))
BOOT_PARTITION_SIZE = 3072
KERNEL_PARTITION_OFFSET = $(shell expr $(BOOT_PARTITION_OFFSET) \+ $(BOOT_PARTITION_SIZE))
KERNEL_PARTITION_SIZE = 8192
ROOTFS_PARTITION_OFFSET = $(shell expr $(KERNEL_PARTITION_OFFSET) \+ $(KERNEL_PARTITION_SIZE))
ROOTFS_PARTITION_SIZE = 1048576
STORAGE_PARTITION_OFFSET = $(shell expr $(ROOTFS_PARTITION_OFFSET) \+ $(ROOTFS_PARTITION_SIZE))

flash-image-axt:
	# Create a sparse image block
	dd if=/dev/zero of=$(BUILD_TMP)/$(AX_IMAGE_LINK) seek=$(AX_IMAGE_ROOTFS_SIZE) count=0 bs=1024
	mkfs.ext4 -F $(BUILD_TMP)/$(AX_IMAGE_LINK) -d $(BOX)
	# Error codes 0-3 indicate successfull operation of fsck (no errors or errors corrected)
	fsck.ext4 -pvfD $(BUILD_TMP)/$(AX_IMAGE_LINK) || [ $? -le 3 ]
	dd if=/dev/zero of=$(EMMC_IMAGE) bs=1024 count=0 seek=$(EMMC_IMAGE_SIZE)
	parted -s $(EMMC_IMAGE) mklabel gpt
	parted -s $(EMMC_IMAGE) unit KiB mkpart boot fat16 $(BOOT_PARTITION_OFFSET) $(shell expr $(BOOT_PARTITION_OFFSET) \+ $(BOOT_PARTITION_SIZE))
	parted -s $(EMMC_IMAGE) unit KiB mkpart kernel1 $(KERNEL_PARTITION_OFFSET) $(shell expr $(KERNEL_PARTITION_OFFSET) \+ $(KERNEL_PARTITION_SIZE))
	parted -s $(EMMC_IMAGE) unit KiB mkpart rootfs1 ext2 $(ROOTFS_PARTITION_OFFSET) $(shell expr $(ROOTFS_PARTITION_OFFSET) \+ $(ROOTFS_PARTITION_SIZE))
	parted -s $(EMMC_IMAGE) unit KiB mkpart storage ext2 $(STORAGE_PARTITION_OFFSET) $(shell expr $(EMMC_IMAGE_SIZE) \- 1024)
	dd if=/dev/zero of=$(BUILD_TMP)/$(AX_BOOT_IMAGE) bs=1024 count=$(BOOT_PARTITION_SIZE)
	mkfs.msdos -S 512 $(BUILD_TMP)/$(AX_BOOT_IMAGE)
	echo "boot emmcflash0.kernel1 'root=/dev/mmcblk0p2 rw rootwait $(BOXMODEL)_4.boxmode=12'" > $(BUILD_TMP)/STARTUP_1
	mcopy -i $(BUILD_TMP)/$(AX_BOOT_IMAGE) -v $(BUILD_TMP)/STARTUP_1 ::
	dd conv=notrunc if=$(BUILD_TMP)/$(AX_BOOT_IMAGE) of=$(EMMC_IMAGE) bs=1024 seek=$(BOOT_PARTITION_OFFSET)
	dd conv=notrunc if=$(ZIMAGE_DTB) of=$(EMMC_IMAGE) bs=1024 seek=$(KERNEL_PARTITION_OFFSET)
	resize2fs $(BUILD_TMP)/$(AX_IMAGE_LINK) $(ROOTFS_PARTITION_SIZE)k
	# Truncate on purpose
	dd if=$(BUILD_TMP)/$(AX_IMAGE_LINK) of=$(EMMC_IMAGE) bs=1024 seek=$(ROOTFS_PARTITION_OFFSET) count=$(AX_IMAGE_ROOTFS_SIZE)
	# Create final USB-image
	mkdir -p $(IMAGE_DIR)/$(BOXMODEL)
	cp $(ZIMAGE_DTB) $(IMAGE_DIR)/$(BOXMODEL)/kernel.bin
	cp $(EMMC_IMAGE) $(IMAGE_DIR)/$(BOXMODEL)
	cd $(BOX); \
	tar -cvf $(IMAGE_DIR)/$(BOXMODEL)/rootfs.tar -C $(BOX) .  > /dev/null 2>&1; \
	bzip2 $(IMAGE_DIR)/$(BOXMODEL)/rootfs.tar
	echo $(IMAGE_VERSION) > $(IMAGE_DIR)/$(BOXMODEL)/imageversion
	cd $(IMAGE_DIR); \
	zip -r $(IMAGE_PREFIX)-$(IMAGE_SUFFIX)_usb.zip $(BOXMODEL)/*
	# cleanup
	rm -rf $(IMAGE_DIR)/$(BOXMODEL)
