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

define LIBDPF_INSTALL_FILES
	$(INSTALL_DATA) -D $(PKG_BUILD_DIR)/dpflib/libdpf.a $(TARGET_libdir)/libdpf.a
	$(INSTALL_DATA) -D $(PKG_BUILD_DIR)/dpflib/dpf.h $(TARGET_includedir)/libdpf/libdpf.h
	$(INSTALL_DATA) -D $(PKG_BUILD_DIR)/include/spiflash.h $(TARGET_includedir)/libdpf/spiflash.h
	$(INSTALL_DATA) -D $(PKG_BUILD_DIR)/include/usbuser.h $(TARGET_includedir)/libdpf/usbuser.h
endef
LIBDPF_PRE_FOLLOWUP_HOOKS += LIBDPF_INSTALL_FILES

libdpf: | $(TARGET_DIR)
	$(call PREPARE)
	$(CHDIR)/$($(PKG)_DIR); \
		$(MAKE1) -C dpflib libdpf.a $($(PKG)_MAKE_OPTS)
	$(call TARGET_FOLLOWUP)
