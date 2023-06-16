################################################################################
#
# libdpf
#
################################################################################

LIBDPF_VERSION = dreamlayers
LIBDPF_DIR = dpf-ax.git
LIBDPF_SOURCE = dpf-ax.git
LIBDPF_SITE = $(GITHUB)/MaxWiesel
LIBDPF_SITE_METHOD = git

LIBDPF_DEPENDENCIES = libusb-compat

LIBDPF_MAKE = \
	$(MAKE1)

LIBDPF_MAKE_OPTS = \
	-C dpflib libdpf.a \
	CC=$(TARGET_CC) PREFIX=$(TARGET_prefix)

define LIBDPF_INSTALL_CMDS
	$(INSTALL_DATA) -D $($(PKG)_BUILD_DIR)/dpflib/libdpf.a $(TARGET_libdir)/libdpf.a
	$(INSTALL_DATA) -D $($(PKG)_BUILD_DIR)/dpflib/dpf.h $(TARGET_includedir)/libdpf/libdpf.h
	$(INSTALL_DATA) -D $($(PKG)_BUILD_DIR)/include/spiflash.h $(TARGET_includedir)/libdpf/spiflash.h
	$(INSTALL_DATA) -D $($(PKG)_BUILD_DIR)/include/usbuser.h $(TARGET_includedir)/libdpf/usbuser.h
endef

libdpf: | $(TARGET_DIR)
	$(call generic-package)
