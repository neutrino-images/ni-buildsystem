
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
