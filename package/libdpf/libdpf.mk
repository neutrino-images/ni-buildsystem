################################################################################
#
# libdpf
#
################################################################################

LIBDPF_VERSION = git
LIBDPF_DIR = dpf-ax.$(LIBDPF_VERSION)
LIBDPF_SOURCE = dpf-ax.$(LIBDPF_VERSION)
LIBDPF_SITE = $(GITHUB)/MaxWiesel

LIBDPF_DEPENDENCIES = libusb-compat

LIBDPF_MAKE_OPTS = \
	CC=$(TARGET_CC) PREFIX=$(TARGET_prefix)

libdpf: $(LIBDPF_DEPENDENCIES) | $(TARGET_DIR)
	$(REMOVE)/$(PKG_DIR)
	$(GET_GIT_SOURCE) $(PKG_SITE)/$(PKG_SOURCE) $(DL_DIR)/$(PKG_SOURCE)
	$(CPDIR)/$(PKG_SOURCE)
	$(call APPLY_PATCHES,$(PKG_PATCHES_DIR))
	$(CHDIR)/$(PKG_DIR); \
		$(MAKE1) -C dpflib libdpf.a $($(PKG)_MAKE_OPTS)
	$(INSTALL_DATA) -D $(PKG_BUILD_DIR)/dpflib/libdpf.a $(TARGET_libdir)/libdpf.a
	$(INSTALL_DATA) -D $(PKG_BUILD_DIR)/dpflib/dpf.h $(TARGET_includedir)/libdpf/libdpf.h
	$(INSTALL_DATA) -D $(PKG_BUILD_DIR)/include/spiflash.h $(TARGET_includedir)/libdpf/spiflash.h
	$(INSTALL_DATA) -D $(PKG_BUILD_DIR)/include/usbuser.h $(TARGET_includedir)/libdpf/usbuser.h
	$(REMOVE)/$(PKG_DIR)
	$(TOUCH)
