################################################################################
#
# hd6x-libs
#
################################################################################

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

HD6X_LIBS_VERSION = $($(call UPPERCASE,$(BOXMODEL))_LIBS_VERSION)
HD6X_LIBS_DIR = $($(call UPPERCASE,$(BOXMODEL))_LIBS_DIR)
HD6X_LIBS_SOURCE = $($(call UPPERCASE,$(BOXMODEL))_LIBS_SOURCE)
HD6X_LIBS_SITE = $($(call UPPERCASE,$(BOXMODEL))_LIBS_SITE)

# fix non-existing subdir in zip
HD6X_LIBS_EXTRACT_DIR = $($(PKG)_DIR)

define HD6X_LIBS_INSTALL
	$(INSTALL) -d $(TARGET_libdir)/hisilicon
	$(INSTALL_EXEC) $(PKG_BUILD_DIR)/hisilicon/* $(TARGET_libdir)/hisilicon
	$(INSTALL_EXEC) $(PKG_BUILD_DIR)/ffmpeg/* $(TARGET_libdir)/hisilicon
	ln -sf /lib/ld-linux-armhf.so.3 $(TARGET_libdir)/hisilicon/ld-linux.so
endef
HD6X_LIBS_INDIVIDUAL_HOOKS += HD6X_LIBS_INSTALL

hd6x-libs: | $(TARGET_DIR)
	$(call individual-package)
