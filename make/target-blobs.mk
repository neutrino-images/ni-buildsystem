#
# makefile to add binary large objects
#
# -----------------------------------------------------------------------------

#BLOBS_DEPENDENCIES = kernel # because of $(LINUX_RUN_DEPMOD)

blobs: $(BLOBS_DEPENDENCIES)
	$(MAKE) firmware
	$(MAKE) $(BOXMODEL)-drivers
ifeq ($(BOXMODEL),$(filter $(BOXMODEL),hd51 bre2ze4k h7 e4hdultra hd60 hd61 multibox multiboxse vusolo4k vuduo4k vuduo4kse vuultimo4k vuzero4k vuuno4k vuuno4kse))
	$(MAKE) $(BOXMODEL)-libgles
  ifeq ($(BOXMODEL),$(filter $(BOXMODEL),hd60 hd61 multibox multiboxse))
	$(MAKE) $(BOXMODEL)-libs
  endif
endif
ifeq ($(BOXMODEL),$(filter $(BOXMODEL),vusolo4k vuduo4k vuduo4kse vuultimo4k vuzero4k vuuno4k vuuno4kse))
	$(MAKE) vuplus-platform-util
endif
	$(call TOUCH)

# -----------------------------------------------------------------------------

firmware: firmware-boxmodel firmware-wireless
	$(call TOUCH)

firmware-boxmodel: $(SOURCE_DIR)/$(NI_DRIVERS_BIN) | $(TARGET_DIR)
	$(call INSTALL_EXIST,$(SOURCE_DIR)/$(NI_DRIVERS_BIN)/$(DRIVERS_BIN_DIR)/lib-firmware/.,$(TARGET_base_libdir)/firmware)
	$(call INSTALL_EXIST,$(SOURCE_DIR)/$(NI_DRIVERS_BIN)/$(DRIVERS_BIN_DIR)/lib-firmware-dvb/.,$(TARGET_base_libdir)/firmware)
	$(call TOUCH)

ifeq ($(BOXMODEL),nevis)
  FIRMWARE_WIRELESS  = rt2870.bin
  FIRMWARE_WIRELESS += rt3070.bin
  FIRMWARE_WIRELESS += rt3071.bin
  FIRMWARE_WIRELESS += rtlwifi/rtl8192cufw.bin
  FIRMWARE_WIRELESS += rtlwifi/rtl8712u.bin
else
  FIRMWARE_WIRELESS  = $(shell cd $(SOURCE_DIR)/$(NI_DRIVERS_BIN)/general/firmware-wireless; find * -type f)
endif

firmware-wireless: $(SOURCE_DIR)/$(NI_DRIVERS_BIN) | $(TARGET_DIR)
	for firmware in $(FIRMWARE_WIRELESS); do \
		$(INSTALL_DATA) -D $(SOURCE_DIR)/$(NI_DRIVERS_BIN)/general/firmware-wireless/$$firmware $(TARGET_base_libdir)/firmware/$$firmware; \
	done
	$(call TOUCH)

# -----------------------------------------------------------------------------

HD51_DRIVERS_VERSION = 20191120
HD51_DRIVERS_SOURCE = hd51-drivers-$(KERNEL_VERSION)-$(HD51_DRIVERS_VERSION).zip
HD51_DRIVERS_SITE = http://source.mynonpublic.com/gfutures

BRE2ZE4K_DRIVERS_VERSION = 20191120
BRE2ZE4K_DRIVERS_SOURCE = bre2ze4k-drivers-$(KERNEL_VERSION)-$(BRE2ZE4K_DRIVERS_VERSION).zip
BRE2ZE4K_DRIVERS_SITE = http://source.mynonpublic.com/gfutures

H7_DRIVERS_VERSION = 20191123
H7_DRIVERS_SOURCE = h7-drivers-$(KERNEL_VERSION)-$(H7_DRIVERS_VERSION).zip
H7_DRIVERS_SITE = http://source.mynonpublic.com/zgemma

E4HDULTRA_DRIVERS_VERSION = 20191101
E4HDULTRA_DRIVERS_SOURCE = e4hd-drivers-$(KERNEL_VERSION)-$(E4HDULTRA_DRIVERS_VERSION).zip
E4HDULTRA_DRIVERS_SITE = http://source.mynonpublic.com/ceryon

HD60_DRIVERS_VERSION = 20200731
HD60_DRIVERS_SOURCE = hd60-drivers-$(KERNEL_VERSION)-$(HD60_DRIVERS_VERSION).zip
HD60_DRIVERS_SITE = http://source.mynonpublic.com/gfutures

HD61_DRIVERS_VERSION = 20200731
HD61_DRIVERS_SOURCE = hd61-drivers-$(KERNEL_VERSION)-$(HD61_DRIVERS_VERSION).zip
HD61_DRIVERS_SITE = http://source.mynonpublic.com/gfutures

MULTIBOX_DRIVERS_VERSION = 20201204
MULTIBOX_DRIVERS_SOURCE = multibox-drivers-$(KERNEL_VERSION)-$(MULTIBOX_DRIVERS_VERSION).zip
MULTIBOX_DRIVERS_SITE = http://source.mynonpublic.com/maxytec

MULTIBOXSE_DRIVERS_VERSION = 20211129
MULTIBOXSE_DRIVERS_SOURCE = multiboxse-drivers-$(KERNEL_VERSION)-$(MULTIBOXSE_DRIVERS_VERSION).zip
MULTIBOXSE_DRIVERS_SITE = http://source.mynonpublic.com/maxytec

ifeq ($(VUPLUS_DRIVERS_LATEST),yes)
VUSOLO4K_DRIVERS_VERSION = 20190424
else
VUSOLO4K_DRIVERS_VERSION = 20190424
endif
VUSOLO4K_DRIVERS_SOURCE = vuplus-dvb-proxy-vusolo4k-3.14.28-$(VUSOLO4K_DRIVERS_VERSION).r0.tar.gz
VUSOLO4K_DRIVERS_SITE = http://code.vuplus.com/download/release/vuplus-dvb-proxy

ifeq ($(VUPLUS_DRIVERS_LATEST),yes)
VUDUO4K_DRIVERS_VERSION = 20191218
else
VUDUO4K_DRIVERS_VERSION = 20191218
endif
VUDUO4K_DRIVERS_SOURCE = vuplus-dvb-proxy-vuduo4k-4.1.45-$(VUDUO4K_DRIVERS_VERSION).r0.tar.gz
VUDUO4K_DRIVERS_SITE = http://code.vuplus.com/download/release/vuplus-dvb-proxy

ifeq ($(VUPLUS_DRIVERS_LATEST),yes)
VUDUO4KSE_DRIVERS_VERSION = 20210407
else
VUDUO4KSE_DRIVERS_VERSION = 20210407
#VUDUO4KSE_DRIVERS_VERSION = 20200903
endif
VUDUO4KSE_DRIVERS_SOURCE = vuplus-dvb-proxy-vuduo4kse-4.1.45-$(VUDUO4KSE_DRIVERS_VERSION).r0.tar.gz
VUDUO4KSE_DRIVERS_SITE = http://code.vuplus.com/download/release/vuplus-dvb-proxy

ifeq ($(VUPLUS_DRIVERS_LATEST),yes)
VUULTIMO4K_DRIVERS_VERSION = 20190424
else
VUULTIMO4K_DRIVERS_VERSION = 20190424
endif
VUULTIMO4K_DRIVERS_SOURCE = vuplus-dvb-proxy-vuultimo4k-3.14.28-$(VUULTIMO4K_DRIVERS_VERSION).r0.tar.gz
VUULTIMO4K_DRIVERS_SITE = http://code.vuplus.com/download/release/vuplus-dvb-proxy

ifeq ($(VUPLUS_DRIVERS_LATEST),yes)
VUZERO4K_DRIVERS_VERSION = 20210407
else
VUZERO4K_DRIVERS_VERSION = 20210407
#VUZERO4K_DRIVERS_VERSION = 20190424
endif
VUZERO4K_DRIVERS_SOURCE = vuplus-dvb-proxy-vuzero4k-4.1.20-$(VUZERO4K_DRIVERS_VERSION).r0.tar.gz
VUZERO4K_DRIVERS_SITE = http://code.vuplus.com/download/release/vuplus-dvb-proxy

ifeq ($(VUPLUS_DRIVERS_LATEST),yes)
VUUNO4K_DRIVERS_VERSION = 20190424
else
VUUNO4K_DRIVERS_VERSION = 20190424
endif
VUUNO4K_DRIVERS_SOURCE = vuplus-dvb-proxy-vuuno4k-3.14.28-$(VUUNO4K_DRIVERS_VERSION).r0.tar.gz
VUUNO4K_DRIVERS_SITE = http://code.vuplus.com/download/release/vuplus-dvb-proxy

ifeq ($(VUPLUS_DRIVERS_LATEST),yes)
VUUNO4KSE_DRIVERS_VERSION = 20210407
else
VUUNO4KSE_DRIVERS_VERSION = 20210407
#VUUNO4KSE_DRIVERS_VERSION = 20190424
endif
VUUNO4KSE_DRIVERS_SOURCE = vuplus-dvb-proxy-vuuno4kse-4.1.20-$(VUUNO4KSE_DRIVERS_VERSION).r0.tar.gz
VUUNO4KSE_DRIVERS_SITE = http://code.vuplus.com/download/release/vuplus-dvb-proxy

VUDUO_DRIVERS_VERSION = 20151124
VUDUO_DRIVERS_SOURCE = vuplus-dvb-modules-bm750-3.9.6-$(VUDUO_DRIVERS_VERSION).tar.gz
VUDUO_DRIVERS_SITE = http://code.vuplus.com/download/release/vuplus-dvb-modules

# -----------------------------------------------------------------------------

BOXMODEL_DRIVERS_VERSION = $($(call UPPERCASE,$(BOXMODEL))_DRIVERS_VERSION)
BOXMODEL_DRIVERS_SOURCE = $($(call UPPERCASE,$(BOXMODEL))_DRIVERS_SOURCE)
BOXMODEL_DRIVERS_SITE = $($(call UPPERCASE,$(BOXMODEL))_DRIVERS_SITE)

ifneq ($(BOXMODEL_DRIVERS_SOURCE),$(empty))
$(DL_DIR)/$(BOXMODEL_DRIVERS_SOURCE):
	$(download) $(BOXMODEL_DRIVERS_SITE)/$(BOXMODEL_DRIVERS_SOURCE)
endif

nevis-drivers \
apollo-drivers \
shiner-drivers \
kronos-drivers \
kronos_v2-drivers \
coolstream-drivers: $(SOURCE_DIR)/$(NI_DRIVERS_BIN) | $(TARGET_DIR)
	$(INSTALL) -d $(TARGET_libdir)
	$(INSTALL_COPY) $(SOURCE_DIR)/$(NI_DRIVERS_BIN)/$(DRIVERS_BIN_DIR)/lib/. $(TARGET_libdir)
	$(INSTALL_COPY) $(SOURCE_DIR)/$(NI_DRIVERS_BIN)/$(DRIVERS_BIN_DIR)/libcoolstream/$(shell echo -n $(BS_PACKAGE_FFMPEG2_BRANCH) | sed 's,/,-,g')/. $(TARGET_libdir)
ifeq ($(BOXMODEL),nevis)
	ln -sf libnxp.so $(TARGET_libdir)/libconexant.so
endif
	$(INSTALL) -d $(TARGET_modulesdir)
	$(INSTALL_COPY) $(SOURCE_DIR)/$(NI_DRIVERS_BIN)/$(DRIVERS_BIN_DIR)/lib-modules/$(KERNEL_VERSION)/. $(TARGET_modulesdir)
ifeq ($(BOXMODEL),nevis)
	ln -sf $(KERNEL_VERSION) $(TARGET_modulesdir)-$(BOXMODEL)
endif
	$(LINUX_RUN_DEPMOD)
	$(call TOUCH)

hd51-drivers \
bre2ze4k-drivers \
h7-drivers \
e4hdultra-drivers: $(DL_DIR)/$(BOXMODEL_DRIVERS_SOURCE) | $(TARGET_DIR)
	$(INSTALL) -d $(TARGET_modulesdir)/extra
	unzip -o $(DL_DIR)/$(BOXMODEL_DRIVERS_SOURCE) -d $(TARGET_modulesdir)/extra
	$(LINUX_RUN_DEPMOD)
	$(call TOUCH)

hd60-drivers \
hd61-drivers \
multibox-drivers \
multiboxse-drivers: $(DL_DIR)/$(BOXMODEL_DRIVERS_SOURCE) | $(TARGET_DIR)
	$(INSTALL) -d $(TARGET_modulesdir)/extra
	unzip -o $(DL_DIR)/$(BOXMODEL_DRIVERS_SOURCE) -d $(TARGET_modulesdir)/extra
	$(TARGET_RM) $(TARGET_modulesdir)/extra/hi_play.ko
	mv $(TARGET_modulesdir)/extra/turnoff_power $(TARGET_bindir)
	$(LINUX_RUN_DEPMOD)
	$(call TOUCH)

vusolo4k-drivers \
vuduo4k-drivers \
vuduo4kse-drivers \
vuultimo4k-drivers \
vuzero4k-drivers \
vuuno4k-drivers \
vuuno4kse-drivers \
vuduo-drivers \
vuplus-drivers: $(DL_DIR)/$(BOXMODEL_DRIVERS_SOURCE) | $(TARGET_DIR)
	$(INSTALL) -d $(TARGET_modulesdir)/extra
	tar -xf $(DL_DIR)/$(BOXMODEL_DRIVERS_SOURCE) -C $(TARGET_modulesdir)/extra
	$(LINUX_RUN_DEPMOD)
	$(call TOUCH)

# -----------------------------------------------------------------------------

HD51_LIBGLES_VERSION = 20191101
HD51_LIBGLES_DIR = $(empty)
HD51_LIBGLES_SOURCE = hd51-v3ddriver-$(HD51_LIBGLES_VERSION).zip
HD51_LIBGLES_SITE = http://downloads.mutant-digital.net/v3ddriver

BRE2ZE4K_LIBGLES_VERSION = 20191101
BRE2ZE4K_LIBGLES_DIR = $(empty)
BRE2ZE4K_LIBGLES_SOURCE = bre2ze4k-v3ddriver-$(BRE2ZE4K_LIBGLES_VERSION).zip
BRE2ZE4K_LIBGLES_SITE = http://downloads.mutant-digital.net/v3ddriver

H7_LIBGLES_VERSION = 20191110
H7_LIBGLES_DIR = $(empty)
H7_LIBGLES_SOURCE = h7-v3ddriver-$(H7_LIBGLES_VERSION).zip
H7_LIBGLES_SITE = http://source.mynonpublic.com/zgemma

E4HDULTRA_LIBGLES_VERSION = 20191101
E4HDULTRA_LIBGLES_DIR = $(empty)
E4HDULTRA_LIBGLES_SOURCE = 8100s-v3ddriver-$(E4HDULTRA_LIBGLES_VERSION).zip
E4HDULTRA_LIBGLES_SITE = https://source.mynonpublic.com/ceryon

HD60_LIBGLES_VERSION = 20181201
HD60_LIBGLES_DIR = $(empty)
HD60_LIBGLES_SOURCE = hd60-mali-$(HD60_LIBGLES_VERSION).zip
HD60_LIBGLES_SITE = http://downloads.mutant-digital.net/hd60

HD61_LIBGLES_VERSION = 20181201
HD61_LIBGLES_DIR = $(empty)
HD61_LIBGLES_SOURCE = hd61-mali-$(HD61_LIBGLES_VERSION).zip
HD61_LIBGLES_SITE = http://downloads.mutant-digital.net/hd61

MULTIBOX_LIBGLES_VERSION = 20190104
MULTIBOX_LIBGLES_DIR = $(empty)
MULTIBOX_LIBGLES_SOURCE = maxytec-mali-3798mv200-$(MULTIBOXSE_LIBGLES_VERSION).zip
MULTIBOX_LIBGLES_SITE = http://source.mynonpublic.com/maxytec

MULTIBOXSE_LIBGLES_VERSION = 20190104
MULTIBOXSE_LIBGLES_DIR = $(empty)
MULTIBOXSE_LIBGLES_SOURCE = maxytec-mali-3798mv200-$(MULTIBOXSE_LIBGLES_VERSION).zip
MULTIBOXSE_LIBGLES_SITE = http://source.mynonpublic.com/maxytec

HD6X_LIBGLES_HEADERS_SOURCE = libgles-mali-utgard-headers.zip
HD6X_LIBGLES_HEADERS_SITE = https://github.com/HD-Digital/meta-gfutures/raw/release-6.2/recipes-bsp/mali/files

VUSOLO4K_LIBGLES_VERSION = $(VUSOLO4K_DRIVERS_VERSION)
VUSOLO4K_LIBGLES_DIR = libgles-vusolo4k
VUSOLO4K_LIBGLES_SOURCE = libgles-vusolo4k-17.1-$(VUSOLO4K_LIBGLES_VERSION).r0.tar.gz
VUSOLO4K_LIBGLES_SITE = http://code.vuplus.com/download/release/libgles

VUDUO4K_LIBGLES_VERSION = $(VUDUO4K_DRIVERS_VERSION)
VUDUO4K_LIBGLES_DIR = libgles-vuduo4k
VUDUO4K_LIBGLES_SOURCE = libgles-vuduo4k-18.1-$(VUDUO4K_LIBGLES_VERSION).r0.tar.gz
VUDUO4K_LIBGLES_SITE = http://code.vuplus.com/download/release/libgles

VUDUO4KSE_LIBGLES_VERSION = $(VUDUO4KSE_DRIVERS_VERSION)
VUDUO4KSE_LIBGLES_DIR = libgles-vuduo4kse
VUDUO4KSE_LIBGLES_SOURCE = libgles-vuduo4kse-17.1-$(VUDUO4KSE_LIBGLES_VERSION).r0.tar.gz
VUDUO4KSE_LIBGLES_SITE = http://code.vuplus.com/download/release/libgles

VUULTIMO4K_LIBGLES_VERSION = $(VUULTIMO4K_DRIVERS_VERSION)
VUULTIMO4K_LIBGLES_DIR = libgles-vuultimo4k
VUULTIMO4K_LIBGLES_SOURCE = libgles-vuultimo4k-17.1-$(VUULTIMO4K_LIBGLES_VERSION).r0.tar.gz
VUULTIMO4K_LIBGLES_SITE = http://code.vuplus.com/download/release/libgles

VUZERO4K_LIBGLES_VERSION = $(VUZERO4K_DRIVERS_VERSION)
VUZERO4K_LIBGLES_DIR = libgles-vuzero4k
VUZERO4K_LIBGLES_SOURCE = libgles-vuzero4k-17.1-$(VUZERO4K_LIBGLES_VERSION).r0.tar.gz
VUZERO4K_LIBGLES_SITE = http://code.vuplus.com/download/release/libgles

VUUNO4K_LIBGLES_VERSION = $(VUUNO4K_DRIVERS_VERSION)
VUUNO4K_LIBGLES_DIR = libgles-vuuno4k
VUUNO4K_LIBGLES_SOURCE = libgles-vuuno4k-17.1-$(VUUNO4K_LIBGLES_VERSION).r0.tar.gz
VUUNO4K_LIBGLES_SITE = http://code.vuplus.com/download/release/libgles

VUUNO4KSE_LIBGLES_VERSION = $(VUUNO4KSE_DRIVERS_VERSION)
VUUNO4KSE_LIBGLES_DIR = libgles-vuuno4kse
VUUNO4KSE_LIBGLES_SOURCE = libgles-vuuno4kse-17.1-$(VUUNO4KSE_LIBGLES_VERSION).r0.tar.gz
VUUNO4KSE_LIBGLES_SITE = http://code.vuplus.com/download/release/libgles

# -----------------------------------------------------------------------------

BOXMODEL_LIBGLES_VERSION = $($(call UPPERCASE,$(BOXMODEL))_LIBGLES_VERSION)
BOXMODEL_LIBGLES_DIR = $($(call UPPERCASE,$(BOXMODEL))_LIBGLES_DIR)
BOXMODEL_LIBGLES_SOURCE = $($(call UPPERCASE,$(BOXMODEL))_LIBGLES_SOURCE)
BOXMODEL_LIBGLES_SITE = $($(call UPPERCASE,$(BOXMODEL))_LIBGLES_SITE)

ifneq ($(BOXMODEL_LIBGLES_SOURCE),$(empty))
$(DL_DIR)/$(BOXMODEL_LIBGLES_SOURCE):
	$(download) $(BOXMODEL_LIBGLES_SITE)/$(BOXMODEL_LIBGLES_SOURCE)
endif

hd51-libgles \
bre2ze4k-libgles \
h7-libgles \
e4hdultra-libgles: $(DL_DIR)/$(BOXMODEL_LIBGLES_SOURCE) | $(TARGET_DIR)
	unzip -o $(DL_DIR)/$(BOXMODEL_LIBGLES_SOURCE) -d $(TARGET_libdir)
	ln -sf libv3ddriver.so $(TARGET_libdir)/libEGL.so
	ln -sf libv3ddriver.so $(TARGET_libdir)/libGLESv2.so
	$(call TOUCH)

$(DL_DIR)/$(HD6X_LIBGLES_HEADERS_SOURCE):
	$(download) $(HD6X_LIBGLES_HEADERS_SITE)/$(HD6X_LIBGLES_HEADERS_SOURCE)

hd6x-libgles-headers: $(DL_DIR)/$(HD6X_LIBGLES_HEADERS_SOURCE) | $(TARGET_DIR)
	unzip -o $(DL_DIR)/$(HD6X_LIBGLES_HEADERS_SOURCE) -d $(TARGET_includedir)
	$(call TOUCH)

hd60-libgles \
hd61-libgles \
multibox-libgles \
multiboxse-libgles: $(DL_DIR)/$(BOXMODEL_LIBGLES_SOURCE) | $(TARGET_DIR)
	unzip -o $(DL_DIR)/$(BOXMODEL_LIBGLES_SOURCE) -d $(TARGET_libdir)
	$(CD) $(TARGET_libdir); \
		ln -sf libMali.so libmali.so; \
		ln -sf libMali.so libEGL.so.1.4; ln -sf libEGL.so.1.4 libEGL.so.1; ln -sf libEGL.so.1 libEGL.so; \
		ln -sf libMali.so libGLESv1_CM.so.1.1; ln -sf libGLESv1_CM.so.1.1 libGLESv1_CM.so.1; ln -sf libGLESv1_CM.so.1 libGLESv1_CM.so; \
		ln -sf libMali.so libGLESv2.so.2.0; ln -sf libGLESv2.so.2.0 libGLESv2.so.2; ln -sf libGLESv2.so.2 libGLESv2.so; \
		ln -sf libMali.so libgbm.so
	$(call TOUCH)

vusolo4k-libgles \
vuduo4k-libgles \
vuduo4kse-libgles \
vuultimo4k-libgles \
vuzero4k-libgles \
vuuno4k-libgles \
vuuno4kse-libgles \
vuplus-libgles: $(DL_DIR)/$(BOXMODEL_LIBGLES_SOURCE) | $(TARGET_DIR)
	$(REMOVE)/$(BOXMODEL_LIBGLES_DIR)
	$(UNTAR)/$(BOXMODEL_LIBGLES_SOURCE)
	$(INSTALL_EXEC) $(BUILD_DIR)/$(BOXMODEL_LIBGLES_DIR)/lib/* $(TARGET_libdir)
	ln -sf libv3ddriver.so $(TARGET_libdir)/libEGL.so
	ln -sf libv3ddriver.so $(TARGET_libdir)/libGLESv2.so
	$(INSTALL_COPY) $(BUILD_DIR)/$(BOXMODEL_LIBGLES_DIR)/include/* $(TARGET_includedir)
	$(REMOVE)/$(BOXMODEL_LIBGLES_DIR)
	$(call TOUCH)

# -----------------------------------------------------------------------------

HD60_LIBS_VERSION = 20200622
HD60_LIBS_DIR = hiplay
HD60_LIBS_SOURCE = gfutures-libs-3798mv200-$(HD60_LIBS_VERSION).zip
HD60_LIBS_SITE = http://source.mynonpublic.com/gfutures

HD61_LIBS_VERSION = 20200622
HD61_LIBS_DIR = hiplay
HD61_LIBS_SOURCE = gfutures-libs-3798mv200-$(HD61_LIBS_VERSION).zip
HD61_LIBS_SITE = http://source.mynonpublic.com/gfutures

MULTIBOX_LIBS_VERSION = 20200622
MULTIBOX_LIBS_DIR = hiplay
MULTIBOX_LIBS_SOURCE = maxytec-libs-3798mv200-$(MULTIBOXSE_LIBS_VERSION).zip
MULTIBOX_LIBS_SITE = http://source.mynonpublic.com/maxytec

MULTIBOXSE_LIBS_VERSION = 20200622
MULTIBOXSE_LIBS_DIR = hiplay
MULTIBOXSE_LIBS_SOURCE = maxytec-libs-3798mv200-$(MULTIBOXSE_LIBS_VERSION).zip
MULTIBOXSE_LIBS_SITE = http://source.mynonpublic.com/maxytec

# -----------------------------------------------------------------------------

BOXMODEL_LIBS_VERSION = $($(call UPPERCASE,$(BOXMODEL))_LIBS_VERSION)
BOXMODEL_LIBS_DIR = $($(call UPPERCASE,$(BOXMODEL))_LIBS_DIR)
BOXMODEL_LIBS_SOURCE = $($(call UPPERCASE,$(BOXMODEL))_LIBS_SOURCE)
BOXMODEL_LIBS_SITE = $($(call UPPERCASE,$(BOXMODEL))_LIBS_SITE)

ifneq ($(BOXMODEL_LIBS_SOURCE),$(empty))
$(DL_DIR)/$(BOXMODEL_LIBS_SOURCE):
	$(download) $(BOXMODEL_LIBS_SITE)/$(BOXMODEL_LIBS_SOURCE)
endif

hd60-libs \
hd61-libs \
multibox-libs \
multiboxse-libs: $(DL_DIR)/$(BOXMODEL_LIBS_SOURCE) | $(TARGET_DIR)
	$(REMOVE)/$(BOXMODEL_LIBS_DIR)
	unzip -o $(DL_DIR)/$(BOXMODEL_LIBS_SOURCE) -d $(BUILD_DIR)/$(BOXMODEL_LIBS_DIR)
	$(INSTALL) -d $(TARGET_libdir)/hisilicon
	$(INSTALL_EXEC) $(BUILD_DIR)/$(BOXMODEL_LIBS_DIR)/hisilicon/* $(TARGET_libdir)/hisilicon
	$(INSTALL_EXEC) $(BUILD_DIR)/$(BOXMODEL_LIBS_DIR)/ffmpeg/* $(TARGET_libdir)/hisilicon
	ln -sf /lib/ld-linux-armhf.so.3 $(TARGET_libdir)/hisilicon/ld-linux.so
	$(REMOVE)/$(BOXMODEL_LIBS_DIR)
	$(call TOUCH)
