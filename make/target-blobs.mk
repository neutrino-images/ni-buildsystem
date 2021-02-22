#
# makefile to add binary large objects
#
# -----------------------------------------------------------------------------

#BLOBS_DEPS = kernel # because of depmod

blobs: $(BLOBS_DEPS)
	$(MAKE) firmware
	$(MAKE) $(BOXMODEL)-drivers
ifeq ($(BOXMODEL),$(filter $(BOXMODEL),hd51 bre2ze4k h7 hd60 hd61 vusolo4k vuduo4k vuduo4kse vuultimo4k vuzero4k vuuno4k vuuno4kse))
	$(MAKE) $(BOXMODEL)-libgles
  ifeq ($(BOXMODEL),$(filter $(BOXMODEL),hd60 hd61))
	$(MAKE) $(BOXMODEL)-libs
  endif
endif
ifeq ($(BOXMODEL),$(filter $(BOXMODEL),vusolo4k vuduo4k vuduo4kse vuultimo4k vuzero4k vuuno4k vuuno4kse))
	$(MAKE) vuplus-platform-util
endif

# -----------------------------------------------------------------------------

firmware: firmware-boxmodel firmware-wireless

firmware-boxmodel: $(SOURCE_DIR)/$(NI-DRIVERS-BIN) | $(TARGET_DIR)
	$(call INSTALL_EXIST,$(SOURCE_DIR)/$(NI-DRIVERS-BIN)/$(DRIVERS-BIN_DIR)/lib-firmware/.,$(TARGET_base_libdir)/firmware)
	$(call INSTALL_EXIST,$(SOURCE_DIR)/$(NI-DRIVERS-BIN)/$(DRIVERS-BIN_DIR)/lib-firmware-dvb/.,$(TARGET_base_libdir)/firmware)

ifeq ($(BOXMODEL),nevis)
  FIRMWARE-WIRELESS  = rt2870.bin
  FIRMWARE-WIRELESS += rt3070.bin
  FIRMWARE-WIRELESS += rt3071.bin
  FIRMWARE-WIRELESS += rtlwifi/rtl8192cufw.bin
  FIRMWARE-WIRELESS += rtlwifi/rtl8712u.bin
else
  FIRMWARE-WIRELESS  = $(shell cd $(SOURCE_DIR)/$(NI-DRIVERS-BIN)/general/firmware-wireless; find * -type f)
endif

firmware-wireless: $(SOURCE_DIR)/$(NI-DRIVERS-BIN) | $(TARGET_DIR)
	for firmware in $(FIRMWARE-WIRELESS); do \
		$(INSTALL_DATA) -D $(SOURCE_DIR)/$(NI-DRIVERS-BIN)/general/firmware-wireless/$$firmware $(TARGET_base_libdir)/firmware/$$firmware; \
	done

# -----------------------------------------------------------------------------

HD51-DRIVERS_VER    = 20191120
HD51-DRIVERS_SOURCE = hd51-drivers-$(KERNEL_VER)-$(HD51-DRIVERS_VER).zip
HD51-DRIVERS_SITE   = http://source.mynonpublic.com/gfutures

BRE2ZE4K-DRIVERS_VER    = 20191120
BRE2ZE4K-DRIVERS_SOURCE = bre2ze4k-drivers-$(KERNEL_VER)-$(BRE2ZE4K-DRIVERS_VER).zip
BRE2ZE4K-DRIVERS_SITE   = http://source.mynonpublic.com/gfutures

H7-DRIVERS_VER    = 20191123
H7-DRIVERS_SOURCE = h7-drivers-$(KERNEL_VER)-$(H7-DRIVERS_VER).zip
H7-DRIVERS_SITE   = http://source.mynonpublic.com/zgemma

HD60-DRIVERS_VER    = 20200731
HD60-DRIVERS_SOURCE = hd60-drivers-$(KERNEL_VER)-$(HD60-DRIVERS_VER).zip
HD60-DRIVERS_SITE   = http://source.mynonpublic.com/gfutures

HD61-DRIVERS_VER    = 20200731
HD61-DRIVERS_SOURCE = hd61-drivers-$(KERNEL_VER)-$(HD61-DRIVERS_VER).zip
HD61-DRIVERS_SITE   = http://source.mynonpublic.com/gfutures

VUSOLO4K-DRIVERS_VER    = 20190424
VUSOLO4K-DRIVERS_SOURCE = vuplus-dvb-proxy-vusolo4k-3.14.28-$(VUSOLO4K-DRIVERS_VER).r0.tar.gz
VUSOLO4K-DRIVERS_SITE   = http://code.vuplus.com/download/release/vuplus-dvb-proxy

ifeq ($(VUPLUS-DRIVERS_LATEST),yes)
VUDUO4K-DRIVERS_VER    = 20191218
else
VUDUO4K-DRIVERS_VER    = 20190212
endif
VUDUO4K-DRIVERS_SOURCE = vuplus-dvb-proxy-vuduo4k-4.1.45-$(VUDUO4K-DRIVERS_VER).r0.tar.gz
VUDUO4K-DRIVERS_SITE   = http://code.vuplus.com/download/release/vuplus-dvb-proxy

VUDUO4KSE-DRIVERS_VER    = 20200903
VUDUO4KSE-DRIVERS_SOURCE = vuplus-dvb-proxy-vuduo4kse-4.1.45-$(VUDUO4KSE-DRIVERS_VER).r0.tar.gz
VUDUO4KSE-DRIVERS_SITE   = http://code.vuplus.com/download/release/vuplus-dvb-proxy

ifeq ($(VUPLUS-DRIVERS_LATEST),yes)
VUULTIMO4K-DRIVERS_VER    = 20190424
else
VUULTIMO4K-DRIVERS_VER    = 20190104
endif
VUULTIMO4K-DRIVERS_SOURCE = vuplus-dvb-proxy-vuultimo4k-3.14.28-$(VUULTIMO4K-DRIVERS_VER).r0.tar.gz
VUULTIMO4K-DRIVERS_SITE   = http://code.vuplus.com/download/release/vuplus-dvb-proxy

VUZERO4K-DRIVERS_VER    = 20190424
VUZERO4K-DRIVERS_SOURCE = vuplus-dvb-proxy-vuzero4k-4.1.20-$(VUZERO4K-DRIVERS_VER).r0.tar.gz
VUZERO4K-DRIVERS_SITE   = http://code.vuplus.com/download/release/vuplus-dvb-proxy

ifeq ($(VUPLUS-DRIVERS_LATEST),yes)
VUUNO4K-DRIVERS_VER    = 20190424
else
VUUNO4K-DRIVERS_VER    = 20190104
endif
VUUNO4K-DRIVERS_SOURCE = vuplus-dvb-proxy-vuuno4k-3.14.28-$(VUUNO4K-DRIVERS_VER).r0.tar.gz
VUUNO4K-DRIVERS_SITE   = http://code.vuplus.com/download/release/vuplus-dvb-proxy

ifeq ($(VUPLUS-DRIVERS_LATEST),yes)
VUUNO4KSE-DRIVERS_VER    = 20190424
else
VUUNO4KSE-DRIVERS_VER    = 20190104
endif
VUUNO4KSE-DRIVERS_SOURCE = vuplus-dvb-proxy-vuuno4kse-4.1.20-$(VUUNO4KSE-DRIVERS_VER).r0.tar.gz
VUUNO4KSE-DRIVERS_SITE   = http://code.vuplus.com/download/release/vuplus-dvb-proxy

VUDUO-DRIVERS_VER    = 20151124
VUDUO-DRIVERS_SOURCE = vuplus-dvb-modules-bm750-3.9.6-$(VUDUO-DRIVERS_VER).tar.gz
VUDUO-DRIVERS_SITE   = http://code.vuplus.com/download/release/vuplus-dvb-modules

# -----------------------------------------------------------------------------

BOXMODEL-DRIVERS_VER    = $($(call UPPERCASE,$(BOXMODEL))-DRIVERS_VER)
BOXMODEL-DRIVERS_SOURCE = $($(call UPPERCASE,$(BOXMODEL))-DRIVERS_SOURCE)
BOXMODEL-DRIVERS_SITE   = $($(call UPPERCASE,$(BOXMODEL))-DRIVERS_SITE)

ifneq ($(BOXMODEL-DRIVERS_SOURCE),$(EMPTY))
$(DL_DIR)/$(BOXMODEL-DRIVERS_SOURCE):
	$(DOWNLOAD) $(BOXMODEL-DRIVERS_SITE)/$(BOXMODEL-DRIVERS_SOURCE)
endif

nevis-drivers \
apollo-drivers \
shiner-drivers \
kronos-drivers \
kronos_v2-drivers \
coolstream-drivers: $(SOURCE_DIR)/$(NI-DRIVERS-BIN) | $(TARGET_DIR)
	mkdir -p $(TARGET_libdir)
	$(INSTALL_COPY) $(SOURCE_DIR)/$(NI-DRIVERS-BIN)/$(DRIVERS-BIN_DIR)/lib/. $(TARGET_libdir)
	$(INSTALL_COPY) $(SOURCE_DIR)/$(NI-DRIVERS-BIN)/$(DRIVERS-BIN_DIR)/libcoolstream/$(shell echo -n $(FFMPEG_BRANCH) | sed 's,/,-,g')/. $(TARGET_libdir)
ifeq ($(BOXMODEL),nevis)
	ln -sf libnxp.so $(TARGET_libdir)/libconexant.so
endif
	mkdir -p $(TARGET_modulesdir)
	$(INSTALL_COPY) $(SOURCE_DIR)/$(NI-DRIVERS-BIN)/$(DRIVERS-BIN_DIR)/lib-modules/$(KERNEL_VER)/. $(TARGET_modulesdir)
ifeq ($(BOXMODEL),nevis)
	ln -sf $(KERNEL_VER) $(TARGET_modulesdir)-$(BOXMODEL)
endif
	make depmod
	$(TOUCH)

hd51-drivers \
bre2ze4k-drivers \
h7-drivers: $(DL_DIR)/$(BOXMODEL-DRIVERS_SOURCE) | $(TARGET_DIR)
	mkdir -p $(TARGET_modulesdir)/extra
	unzip -o $(DL_DIR)/$(BOXMODEL-DRIVERS_SOURCE) -d $(TARGET_modulesdir)/extra
	make depmod
	$(TOUCH)

hd60-drivers \
hd61-drivers: $(DL_DIR)/$(BOXMODEL-DRIVERS_SOURCE) | $(TARGET_DIR)
	mkdir -p $(TARGET_modulesdir)/extra
	unzip -o $(DL_DIR)/$(BOXMODEL-DRIVERS_SOURCE) -d $(TARGET_modulesdir)/extra
	rm -f $(TARGET_modulesdir)/extra/hi_play.ko
	mv $(TARGET_modulesdir)/extra/turnoff_power $(TARGET_bindir)
	make depmod
	$(TOUCH)

vusolo4k-drivers \
vuduo4k-drivers \
vuduo4kse-drivers \
vuultimo4k-drivers \
vuzero4k-drivers \
vuuno4k-drivers \
vuuno4kse-drivers \
vuduo-drivers \
vuplus-drivers: $(DL_DIR)/$(BOXMODEL-DRIVERS_SOURCE) | $(TARGET_DIR)
	mkdir -p $(TARGET_modulesdir)/extra
	tar -xf $(DL_DIR)/$(BOXMODEL-DRIVERS_SOURCE) -C $(TARGET_modulesdir)/extra
	make depmod
	$(TOUCH)

# -----------------------------------------------------------------------------

HD51-LIBGLES_VER    = 20191101
HD51-LIBGLES_DIR    = $(EMPTY)
HD51-LIBGLES_SOURCE = hd51-v3ddriver-$(HD51-LIBGLES_VER).zip
HD51-LIBGLES_SITE   = http://downloads.mutant-digital.net/v3ddriver

BRE2ZE4K-LIBGLES_VER    = 20191101
BRE2ZE4K-LIBGLES_DIR    = $(EMPTY)
BRE2ZE4K-LIBGLES_SOURCE = bre2ze4k-v3ddriver-$(BRE2ZE4K-LIBGLES_VER).zip
BRE2ZE4K-LIBGLES_SITE   = http://downloads.mutant-digital.net/v3ddriver

H7-LIBGLES_VER    = 20191110
H7-LIBGLES_DIR    = $(EMPTY)
H7-LIBGLES_SOURCE = h7-v3ddriver-$(H7-LIBGLES_VER).zip
H7-LIBGLES_SITE   = http://source.mynonpublic.com/zgemma

HD60-LIBGLES_VER    = 20181201
HD60-LIBGLES_DIR    = $(EMPTY)
HD60-LIBGLES_SOURCE = hd60-mali-$(HD60-LIBGLES_VER).zip
HD60-LIBGLES_SITE   = http://downloads.mutant-digital.net/hd60

HD61-LIBGLES_VER    = 20181201
HD61-LIBGLES_DIR    = $(EMPTY)
HD61-LIBGLES_SOURCE = hd61-mali-$(HD61-LIBGLES_VER).zip
HD61-LIBGLES_SITE   = http://downloads.mutant-digital.net/hd61

HD6x-LIBGLES-HEADERS_SOURCE = libgles-mali-utgard-headers.zip
HD6x-LIBGLES-HEADERS_SITE   = https://github.com/HD-Digital/meta-gfutures/raw/release-6.2/recipes-bsp/mali/files

VUSOLO4K-LIBGLES_VER    = $(VUSOLO4K-DRIVERS_VER)
VUSOLO4K-LIBGLES_DIR    = libgles-vusolo4k
VUSOLO4K-LIBGLES_SOURCE = libgles-vusolo4k-17.1-$(VUSOLO4K-LIBGLES_VER).r0.tar.gz
VUSOLO4K-LIBGLES_SITE   = http://code.vuplus.com/download/release/libgles

VUDUO4K-LIBGLES_VER    = $(VUDUO4K-DRIVERS_VER)
VUDUO4K-LIBGLES_DIR    = libgles-vuduo4k
VUDUO4K-LIBGLES_SOURCE = libgles-vuduo4k-18.1-$(VUDUO4K-LIBGLES_VER).r0.tar.gz
VUDUO4K-LIBGLES_SITE   = http://code.vuplus.com/download/release/libgles

VUDUO4KSE-LIBGLES_VER    = $(VUDUO4KSE-DRIVERS_VER)
VUDUO4KSE-LIBGLES_DIR    = libgles-vuduo4kse
VUDUO4KSE-LIBGLES_SOURCE = libgles-vuduo4kse-17.1-$(VUDUO4KSE-LIBGLES_VER).r0.tar.gz
VUDUO4KSE-LIBGLES_SITE   = http://code.vuplus.com/download/release/libgles

VUULTIMO4K-LIBGLES_VER    = $(VUULTIMO4K-DRIVERS_VER)
VUULTIMO4K-LIBGLES_DIR    = libgles-vuultimo4k
VUULTIMO4K-LIBGLES_SOURCE = libgles-vuultimo4k-17.1-$(VUULTIMO4K-LIBGLES_VER).r0.tar.gz
VUULTIMO4K-LIBGLES_SITE   = http://code.vuplus.com/download/release/libgles

VUZERO4K-LIBGLES_VER    = $(VUZERO4K-DRIVERS_VER)
VUZERO4K-LIBGLES_DIR    = libgles-vuzero4k
VUZERO4K-LIBGLES_SOURCE = libgles-vuzero4k-17.1-$(VUZERO4K-LIBGLES_VER).r0.tar.gz
VUZERO4K-LIBGLES_SITE   = http://code.vuplus.com/download/release/libgles

VUUNO4K-LIBGLES_VER    = $(VUUNO4K-DRIVERS_VER)
VUUNO4K-LIBGLES_DIR    = libgles-vuuno4k
VUUNO4K-LIBGLES_SOURCE = libgles-vuuno4k-17.1-$(VUUNO4K-LIBGLES_VER).r0.tar.gz
VUUNO4K-LIBGLES_SITE   = http://code.vuplus.com/download/release/libgles

VUUNO4KSE-LIBGLES_VER    = $(VUUNO4KSE-DRIVERS_VER)
VUUNO4KSE-LIBGLES_DIR    = libgles-vuuno4kse
VUUNO4KSE-LIBGLES_SOURCE = libgles-vuuno4kse-17.1-$(VUUNO4KSE-LIBGLES_VER).r0.tar.gz
VUUNO4KSE-LIBGLES_SITE   = http://code.vuplus.com/download/release/libgles

# -----------------------------------------------------------------------------

BOXMODEL-LIBGLES_VER    = $($(call UPPERCASE,$(BOXMODEL))-LIBGLES_VER)
BOXMODEL-LIBGLES_DIR    = $($(call UPPERCASE,$(BOXMODEL))-LIBGLES_DIR)
BOXMODEL-LIBGLES_SOURCE = $($(call UPPERCASE,$(BOXMODEL))-LIBGLES_SOURCE)
BOXMODEL-LIBGLES_SITE   = $($(call UPPERCASE,$(BOXMODEL))-LIBGLES_SITE)

ifneq ($(BOXMODEL-LIBGLES_SOURCE),$(EMPTY))
$(DL_DIR)/$(BOXMODEL-LIBGLES_SOURCE):
	$(DOWNLOAD) $(BOXMODEL-LIBGLES_SITE)/$(BOXMODEL-LIBGLES_SOURCE)
endif

hd51-libgles \
bre2ze4k-libgles \
h7-libgles: $(DL_DIR)/$(BOXMODEL-LIBGLES_SOURCE) | $(TARGET_DIR)
	unzip -o $(DL_DIR)/$(BOXMODEL-LIBGLES_SOURCE) -d $(TARGET_libdir)
	ln -sf libv3ddriver.so $(TARGET_libdir)/libEGL.so
	ln -sf libv3ddriver.so $(TARGET_libdir)/libGLESv2.so
	$(TOUCH)

$(DL_DIR)/$(HD6x-LIBGLES-HEADERS_SOURCE):
	$(DOWNLOAD) $(HD6x-LIBGLES-HEADERS_SITE)/$(HD6x-LIBGLES-HEADERS_SOURCE)

hd6x-libgles-headers: $(DL_DIR)/$(HD6x-LIBGLES-HEADERS_SOURCE) | $(TARGET_DIR)
	unzip -o $(DL_DIR)/$(HD6x-LIBGLES-HEADERS_SOURCE) -d $(TARGET_includedir)
	$(TOUCH)

hd60-libgles \
hd61-libgles: $(DL_DIR)/$(BOXMODEL-LIBGLES_SOURCE) | $(TARGET_DIR)
	unzip -o $(DL_DIR)/$(BOXMODEL-LIBGLES_SOURCE) -d $(TARGET_libdir)
	$(CD) $(TARGET_libdir); \
		ln -sf libMali.so libmali.so; \
		ln -sf libMali.so libEGL.so.1.4; ln -sf libEGL.so.1.4 libEGL.so.1; ln -sf libEGL.so.1 libEGL.so; \
		ln -sf libMali.so libGLESv1_CM.so.1.1; ln -sf libGLESv1_CM.so.1.1 libGLESv1_CM.so.1; ln -sf libGLESv1_CM.so.1 libGLESv1_CM.so; \
		ln -sf libMali.so libGLESv2.so.2.0; ln -sf libGLESv2.so.2.0 libGLESv2.so.2; ln -sf libGLESv2.so.2 libGLESv2.so; \
		ln -sf libMali.so libgbm.so
	$(TOUCH)

vusolo4k-libgles \
vuduo4k-libgles \
vuduo4kse-libgles \
vuultimo4k-libgles \
vuzero4k-libgles \
vuuno4k-libgles \
vuuno4kse-libgles \
vuplus-libgles: $(DL_DIR)/$(BOXMODEL-LIBGLES_SOURCE) | $(TARGET_DIR)
	$(REMOVE)/$(BOXMODEL-LIBGLES_DIR)
	$(UNTAR)/$(BOXMODEL-LIBGLES_SOURCE)
	$(INSTALL_EXEC) $(BUILD_DIR)/$(BOXMODEL-LIBGLES_DIR)/lib/* $(TARGET_libdir)
	ln -sf libv3ddriver.so $(TARGET_libdir)/libEGL.so
	ln -sf libv3ddriver.so $(TARGET_libdir)/libGLESv2.so
	$(INSTALL_COPY) $(BUILD_DIR)/$(BOXMODEL-LIBGLES_DIR)/include/* $(TARGET_includedir)
	$(REMOVE)/$(BOXMODEL-LIBGLES_DIR)
	$(TOUCH)

# -----------------------------------------------------------------------------

HD60-LIBS_VER    = 20200622
HD60-LIBS_DIR    = hiplay
HD60-LIBS_SOURCE = gfutures-libs-3798mv200-$(HD60-LIBS_VER).zip
HD60-LIBS_SITE   = http://source.mynonpublic.com/gfutures

HD61-LIBS_VER    = 20200622
HD61-LIBS_DIR    = hiplay
HD61-LIBS_SOURCE = gfutures-libs-3798mv200-$(HD61-LIBS_VER).zip
HD61-LIBS_SITE   = http://source.mynonpublic.com/gfutures

# -----------------------------------------------------------------------------

BOXMODEL-LIBS_VER    = $($(call UPPERCASE,$(BOXMODEL))-LIBS_VER)
BOXMODEL-LIBS_DIR    = $($(call UPPERCASE,$(BOXMODEL))-LIBS_DIR)
BOXMODEL-LIBS_SOURCE = $($(call UPPERCASE,$(BOXMODEL))-LIBS_SOURCE)
BOXMODEL-LIBS_SITE   = $($(call UPPERCASE,$(BOXMODEL))-LIBS_SITE)

ifneq ($(BOXMODEL-LIBS_SOURCE),$(EMPTY))
$(DL_DIR)/$(BOXMODEL-LIBS_SOURCE):
	$(DOWNLOAD) $(BOXMODEL-LIBS_SITE)/$(BOXMODEL-LIBS_SOURCE)
endif

hd60-libs \
hd61-libs: $(DL_DIR)/$(BOXMODEL-LIBS_SOURCE) | $(TARGET_DIR)
	$(REMOVE)/$(BOXMODEL-LIBS_DIR)
	unzip -o $(DL_DIR)/$(BOXMODEL-LIBS_SOURCE) -d $(BUILD_DIR)/$(BOXMODEL-LIBS_DIR)
	mkdir -p $(TARGET_libdir)/hisilicon
	$(INSTALL_EXEC) $(BUILD_DIR)/$(BOXMODEL-LIBS_DIR)/hisilicon/* $(TARGET_libdir)/hisilicon
	$(INSTALL_EXEC) $(BUILD_DIR)/$(BOXMODEL-LIBS_DIR)/ffmpeg/* $(TARGET_libdir)/hisilicon
	ln -sf /lib/ld-linux-armhf.so.3 $(TARGET_libdir)/hisilicon/ld-linux.so
	$(REMOVE)/$(BOXMODEL-LIBS_DIR)
	$(TOUCH)

# -----------------------------------------------------------------------------

VUSOLO4K-PLATFORM-UTIL_VER    = $(VUSOLO4K-DRIVERS_VER)
VUSOLO4K-PLATFORM-UTIL_DIR    = platform-util-vusolo4k
VUSOLO4K-PLATFORM-UTIL_SOURCE = platform-util-vusolo4k-17.1-$(VUSOLO4K-PLATFORM-UTIL_VER).r0.tar.gz
VUSOLO4K-PLATFORM-UTIL_SITE   = http://code.vuplus.com/download/release/platform-util

VUDUO4K-PLATFORM-UTIL_VER    = $(VUDUO4K-DRIVERS_VER)
VUDUO4K-PLATFORM-UTIL_DIR    = platform-util-vuduo4k
VUDUO4K-PLATFORM-UTIL_SOURCE = platform-util-vuduo4k-18.1-$(VUDUO4K-PLATFORM-UTIL_VER).r0.tar.gz
VUDUO4K-PLATFORM-UTIL_SITE   = http://code.vuplus.com/download/release/platform-util

VUDUO4KSE-PLATFORM-UTIL_VER    = $(VUDUO4KSE-DRIVERS_VER)
VUDUO4KSE-PLATFORM-UTIL_DIR    = platform-util-vuduo4kse
VUDUO4KSE-PLATFORM-UTIL_SOURCE = platform-util-vuduo4kse-17.1-$(VUDUO4KSE-PLATFORM-UTIL_VER).r0.tar.gz
VUDUO4KSE-PLATFORM-UTIL_SITE   = http://code.vuplus.com/download/release/platform-util

VUULTIMO4K-PLATFORM-UTIL_VER    = $(VUULTIMO4K-DRIVERS_VER)
VUULTIMO4K-PLATFORM-UTIL_DIR    = platform-util-vuultimo4k
VUULTIMO4K-PLATFORM-UTIL_SOURCE = platform-util-vuultimo4k-17.1-$(VUULTIMO4K-PLATFORM-UTIL_VER).r0.tar.gz
VUULTIMO4K-PLATFORM-UTIL_SITE   = http://code.vuplus.com/download/release/platform-util

VUZERO4K-PLATFORM-UTIL_VER    = $(VUZERO4K-DRIVERS_VER)
VUZERO4K-PLATFORM-UTIL_DIR    = platform-util-vuzero4k
VUZERO4K-PLATFORM-UTIL_SOURCE = platform-util-vuzero4k-17.1-$(VUZERO4K-PLATFORM-UTIL_VER).r0.tar.gz
VUZERO4K-PLATFORM-UTIL_SITE   = http://code.vuplus.com/download/release/platform-util

VUUNO4K-PLATFORM-UTIL_VER    = $(VUUNO4K-DRIVERS_VER)
VUUNO4K-PLATFORM-UTIL_DIR    = platform-util-vuuno4k
VUUNO4K-PLATFORM-UTIL_SOURCE = platform-util-vuuno4k-17.1-$(VUUNO4K-PLATFORM-UTIL_VER).r0.tar.gz
VUUNO4K-PLATFORM-UTIL_SITE   = http://code.vuplus.com/download/release/platform-util

VUUNO4KSE-PLATFORM-UTIL_VER    = $(VUUNO4KSE-DRIVERS_VER)
VUUNO4KSE-PLATFORM-UTIL_DIR    = platform-util-vuuno4kse
VUUNO4KSE-PLATFORM-UTIL_SOURCE = platform-util-vuuno4kse-17.1-$(VUUNO4KSE-PLATFORM-UTIL_VER).r0.tar.gz
VUUNO4KSE-PLATFORM-UTIL_SITE   = http://code.vuplus.com/download/release/platform-util

# -----------------------------------------------------------------------------

BOXMODEL-PLATFORM-UTIL_VER    = $($(call UPPERCASE,$(BOXMODEL))-PLATFORM-UTIL_VER)
BOXMODEL-PLATFORM-UTIL_DIR    = $($(call UPPERCASE,$(BOXMODEL))-PLATFORM-UTIL_DIR)
BOXMODEL-PLATFORM-UTIL_SOURCE = $($(call UPPERCASE,$(BOXMODEL))-PLATFORM-UTIL_SOURCE)
BOXMODEL-PLATFORM-UTIL_SITE   = $($(call UPPERCASE,$(BOXMODEL))-PLATFORM-UTIL_SITE)

ifneq ($(BOXMODEL-PLATFORM-UTIL_SOURCE),$(EMPTY))
$(DL_DIR)/$(BOXMODEL-PLATFORM-UTIL_SOURCE):
	$(DOWNLOAD) $(BOXMODEL-PLATFORM-UTIL_SITE)/$(BOXMODEL-PLATFORM-UTIL_SOURCE)
endif

vuplus-platform-util: $(DL_DIR)/$(BOXMODEL-PLATFORM-UTIL_SOURCE) | $(TARGET_DIR)
	$(REMOVE)/$(BOXMODEL-PLATFORM-UTIL_DIR)
	$(UNTAR)/$(BOXMODEL-PLATFORM-UTIL_SOURCE)
	$(INSTALL_EXEC) -D $(BUILD_DIR)/$(BOXMODEL-PLATFORM-UTIL_DIR)/* $(TARGET_bindir)
	$(INSTALL_EXEC) -D $(TARGET_FILES)/scripts/vuplus-platform-util.init $(TARGET_sysconfdir)/init.d/vuplus-platform-util
ifeq ($(BOXMODEL),$(filter $(BOXMODEL),vuduo4k))
	$(INSTALL_EXEC) -D $(TARGET_FILES)/scripts/bp3flash.sh $(TARGET_bindir)/bp3flash.sh
endif
	$(REMOVE)/$(BOXMODEL-PLATFORM-UTIL_DIR)
	$(TOUCH)
