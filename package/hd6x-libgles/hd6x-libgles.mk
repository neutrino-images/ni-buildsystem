################################################################################
#
# hd6x-libgles
#
################################################################################

HD60_LIBGLES_VERSION = 20181201
HD60_LIBGLES_DIR = hd60-mali
HD60_LIBGLES_SOURCE = hd60-mali-$(HD60_LIBGLES_VERSION).zip
HD60_LIBGLES_SITE = http://downloads.mutant-digital.net/hd60

HD61_LIBGLES_VERSION = 20181201
HD61_LIBGLES_DIR = hd61-mali
HD61_LIBGLES_SOURCE = hd61-mali-$(HD61_LIBGLES_VERSION).zip
HD61_LIBGLES_SITE = http://downloads.mutant-digital.net/hd61

MULTIBOX_LIBGLES_VERSION = 20190104
MULTIBOX_LIBGLES_DIR = maxytec-mali
MULTIBOX_LIBGLES_SOURCE = maxytec-mali-3798mv200-$(MULTIBOXSE_LIBGLES_VERSION).zip
MULTIBOX_LIBGLES_SITE = http://source.mynonpublic.com/maxytec

MULTIBOXSE_LIBGLES_VERSION = 20190104
MULTIBOXSE_LIBGLES_DIR = maxytec-mali
MULTIBOXSE_LIBGLES_SOURCE = maxytec-mali-3798mv200-$(MULTIBOXSE_LIBGLES_VERSION).zip
MULTIBOXSE_LIBGLES_SITE = http://source.mynonpublic.com/maxytec

hd60-libgles \
hd61-libgles \
multibox-libgles \
multiboxse-libgles: hd6x-libgles

# -----------------------------------------------------------------------------

HD6X_LIBGLES_VERSION = $($(call UPPERCASE,$(BOXMODEL))_LIBGLES_VERSION)
HD6X_LIBGLES_DIR = $($(call UPPERCASE,$(BOXMODEL))_LIBGLES_DIR)
HD6X_LIBGLES_SOURCE = $($(call UPPERCASE,$(BOXMODEL))_LIBGLES_SOURCE)
HD6X_LIBGLES_SITE = $($(call UPPERCASE,$(BOXMODEL))_LIBGLES_SITE)

# fix non-existing subdir in zip
HD6X_LIBGLES_EXTRACT_DIR = $($(PKG)_DIR)

define HD6X_LIBGLES_INSTALL_FILES
	$(INSTALL_COPY) $(PKG_BUILD_DIR)/* $(TARGET_libdir)
endef
HD6X_LIBGLES_INDIVIDUAL_HOOKS += HD6X_LIBGLES_INSTALL_FILES

define HD6X_LIBGLES_LINKING_FILES
	$(CD) $(TARGET_libdir); \
		ln -sf libMali.so libmali.so; \
		ln -sf libMali.so libEGL.so.1.4; ln -sf libEGL.so.1.4 libEGL.so.1; ln -sf libEGL.so.1 libEGL.so; \
		ln -sf libMali.so libGLESv1_CM.so.1.1; ln -sf libGLESv1_CM.so.1.1 libGLESv1_CM.so.1; ln -sf libGLESv1_CM.so.1 libGLESv1_CM.so; \
		ln -sf libMali.so libGLESv2.so.2.0; ln -sf libGLESv2.so.2.0 libGLESv2.so.2; ln -sf libGLESv2.so.2 libGLESv2.so; \
		ln -sf libMali.so libgbm.so
endef
HD6X_LIBGLES_INDIVIDUAL_HOOKS += HD6X_LIBGLES_LINKING_FILES

hd6x-libgles: | $(TARGET_DIR)
	$(call individual-package)
