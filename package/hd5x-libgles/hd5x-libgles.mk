################################################################################
#
# hd5x-libgles
#
################################################################################

HD51_LIBGLES_VERSION = 20191101
HD51_LIBGLES_DIR = hd51-v3ddriver
HD51_LIBGLES_SOURCE = hd51-v3ddriver-$(HD51_LIBGLES_VERSION).zip
HD51_LIBGLES_SITE = http://downloads.mutant-digital.net/v3ddriver

BRE2ZE4K_LIBGLES_VERSION = 20191101
BRE2ZE4K_LIBGLES_DIR = bre2ze4k-v3ddriver
BRE2ZE4K_LIBGLES_SOURCE = bre2ze4k-v3ddriver-$(BRE2ZE4K_LIBGLES_VERSION).zip
BRE2ZE4K_LIBGLES_SITE = http://downloads.mutant-digital.net/v3ddriver

H7_LIBGLES_VERSION = 20191110
H7_LIBGLES_DIR = h7-v3ddriver
H7_LIBGLES_SOURCE = h7-v3ddriver-$(H7_LIBGLES_VERSION).zip
H7_LIBGLES_SITE = http://source.mynonpublic.com/zgemma

E4HDULTRA_LIBGLES_VERSION = 20191101
E4HDULTRA_LIBGLES_DIR = 8100s-v3ddriver
E4HDULTRA_LIBGLES_SOURCE = 8100s-v3ddriver-$(E4HDULTRA_LIBGLES_VERSION).zip
E4HDULTRA_LIBGLES_SITE = https://source.mynonpublic.com/ceryon

PROTEK4K_LIBGLES_VERSION = 20191101
PROTEK4K_LIBGLES_DIR = 8100s-v3ddriver
PROTEK4K_LIBGLES_SOURCE = 8100s-v3ddriver-$(PROTEK4K_LIBGLES_VERSION).zip
PROTEK4K_LIBGLES_SITE = https://source.mynonpublic.com/ceryon

hd51-libgles \
bre2ze4k-libgles \
h7-libgles \
e4hdultra-libgles \
protek4k-libgles: hd5x-libgles

# -----------------------------------------------------------------------------

HD5X_LIBGLES_VERSION = $($(call UPPERCASE,$(BOXMODEL))_LIBGLES_VERSION)
HD5X_LIBGLES_DIR = $($(call UPPERCASE,$(BOXMODEL))_LIBGLES_DIR)
HD5X_LIBGLES_SOURCE = $($(call UPPERCASE,$(BOXMODEL))_LIBGLES_SOURCE)
HD5X_LIBGLES_SITE = $($(call UPPERCASE,$(BOXMODEL))_LIBGLES_SITE)

# fix non-existing subdir in zip
HD5X_LIBGLES_EXTRACT_DIR = $($(PKG)_DIR)

define HD5X_LIBGLES_INSTALL_FILES
	$(INSTALL_COPY) $(PKG_BUILD_DIR)/* $(TARGET_libdir)
endef
HD5X_LIBGLES_INDIVIDUAL_HOOKS += HD5X_LIBGLES_INSTALL_FILES

define HD5X_LIBGLES_LINKING_FILES
	ln -sf libv3ddriver.so $(TARGET_libdir)/libEGL.so
	ln -sf libv3ddriver.so $(TARGET_libdir)/libGLESv2.so
endef
HD5X_LIBGLES_INDIVIDUAL_HOOKS += HD5X_LIBGLES_LINKING_FILES

hd5x-libgles: | $(TARGET_DIR)
	$(call individual-package)
