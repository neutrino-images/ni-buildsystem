#
# makefile to add binary large objects
#
# -----------------------------------------------------------------------------

#BLOBS_DEPENDENCIES = kernel # because of $(LINUX_RUN_DEPMOD)

blobs: $(BLOBS_DEPENDENCIES)
	$(MAKE) firmware
	$(MAKE) $(BOXMODEL)-drivers
ifeq ($(BOXMODEL),$(filter $(BOXMODEL),nevis apollo shiner kronos kronos_v2 hd60 hd61 multibox multiboxse))
	$(MAKE) $(BOXMODEL)-libs
endif
ifeq ($(BOXMODEL),$(filter $(BOXMODEL),hd51 bre2ze4k h7 e4hdultra protek4k hd60 hd61 multibox multiboxse vusolo4k vuduo4k vuduo4kse vuultimo4k vuzero4k vuuno4k vuuno4kse))
	$(MAKE) $(BOXMODEL)-libgles
endif
ifeq ($(BOXMODEL),$(filter $(BOXMODEL),vusolo4k vuduo4k vuduo4kse vuultimo4k vuzero4k vuuno4k vuuno4kse))
	$(MAKE) vuplus-platform-util
endif
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

PROTEK4K_LIBGLES_VERSION = 20191101
PROTEK4K_LIBGLES_DIR = $(empty)
PROTEK4K_LIBGLES_SOURCE = 8100s-v3ddriver-$(PROTEK4K_LIBGLES_VERSION).zip
PROTEK4K_LIBGLES_SITE = https://source.mynonpublic.com/ceryon

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
e4hdultra-libgles \
protek4k-libgles: $(DL_DIR)/$(BOXMODEL_LIBGLES_SOURCE) | $(TARGET_DIR)
	unzip -o $(DL_DIR)/$(BOXMODEL_LIBGLES_SOURCE) -d $(TARGET_libdir)
	ln -sf libv3ddriver.so $(TARGET_libdir)/libEGL.so
	ln -sf libv3ddriver.so $(TARGET_libdir)/libGLESv2.so
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
