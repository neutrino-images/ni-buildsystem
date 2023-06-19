################################################################################
#
# vuplus-libgles
#
################################################################################

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

vusolo4k-libgles \
vuduo4k-libgles \
vuduo4kse-libgles \
vuultimo4k-libgles \
vuzero4k-libgles \
vuuno4k-libgles \
vuuno4kse-libgles: vuplus-libgles

# -----------------------------------------------------------------------------

VUPLUS_LIBGLES_VERSION = $($(call UPPERCASE,$(BOXMODEL))_LIBGLES_VERSION)
VUPLUS_LIBGLES_DIR = $($(call UPPERCASE,$(BOXMODEL))_LIBGLES_DIR)
VUPLUS_LIBGLES_SOURCE = $($(call UPPERCASE,$(BOXMODEL))_LIBGLES_SOURCE)
VUPLUS_LIBGLES_SITE = $($(call UPPERCASE,$(BOXMODEL))_LIBGLES_SITE)

define VUPLUS_LIBGLES_INSTALL_FILES
	$(INSTALL_COPY) $(PKG_BUILD_DIR)/lib/* $(TARGET_libdir)
	$(INSTALL_COPY) $(PKG_BUILD_DIR)/include/* $(TARGET_includedir)
endef
VUPLUS_LIBGLES_INDIVIDUAL_HOOKS += VUPLUS_LIBGLES_INSTALL_FILES

define VUPLUS_LIBGLES_LINKING_FILES
	ln -sf libv3ddriver.so $(TARGET_libdir)/libEGL.so
	ln -sf libv3ddriver.so $(TARGET_libdir)/libGLESv2.so
endef
VUPLUS_LIBGLES_INDIVIDUAL_HOOKS += VUPLUS_LIBGLES_LINKING_FILES

vuplus-libgles: | $(TARGET_DIR)
	$(call individual-package)
