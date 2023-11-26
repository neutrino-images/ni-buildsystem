################################################################################
#
# libcoolstream
#
################################################################################

LIBCOOLSTREAM_VERSION = master
LIBCOOLSTREAM_DIR = $(NI_LIBCOOLSTREAM)
LIBCOOLSTREAM_SOURCE = $(NI_LIBCOOLSTREAM)
LIBCOOLSTREAM_SITE = https://github.com/neutrino-images
LIBCOOLSTREAM_SITE_METHOD = ni-git

LIBCOOLSTREAM_DEPENDENCIES = ffmpeg openthreads libbluray

LIBCOOLSTREAM_SUBDIR = $(BOXSERIES)

# because of libnxp don't use $(PKG_BUILD_DIR) in CNXT_BASE_ROOT
LIBCOOLSTREAM_MAKE_ENV = \
	CROSS_COMPILE=$(TARGET_CROSS) \
	CNXT_BASE_ROOT=$(BUILD_DIR)/$(LIBCOOLSTREAM_DIR)/$(BOXSERIES)/includes \
	EXTRA_INCLUDE_PATH=-I$(TARGET_includedir) \
	EXTRA_LIBRARY_PATH=-L$(TARGET_libdir) \
	LIBCS_DEBUG=$(if $(filter $(DEBUG),no),off,on) \
	LIBCS_CXX11_ABI=$(CXX11_ABI) \
	PLATFORM=$(BOXFAMILY)

define LIBCOOLSTREAM_INSTALL_CMDS
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/build/libcoolstream.a $(TARGET_libdir)
	$(INSTALL_COPY) $(PKG_BUILD_DIR)/build/libcoolstream.so* $(TARGET_libdir)
endef

libcoolstream: | $(TARGET_DIR)
	$(call generic-package)

################################################################################
#
# libnxp
#
################################################################################

ifeq ($(BOXMODEL),nevis)

LIBNXP_VERSION = $(LIBCOOLSTREAM_VERSION)
LIBNXP_DIR = $(LIBCOOLSTREAM_DIR)
LIBNXP_SOURCE = $(LIBCOOLSTREAM_SOURCE)
LIBNXP_SITE = $(LIBCOOLSTREAM_SITE)
LIBNXP_SITE_METHOD = $(LIBCOOLSTREAM_SITE_METHOD)

LIBNXP_SUBDIR = hd1-libnxp

LIBNXP_MAKE_ENV = \
	$(LIBCOOLSTREAM_MAKE_ENV)

define LIBNXP_INSTALL_CMDS
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/build/libnxp.a $(TARGET_libdir)
	$(INSTALL_COPY) $(PKG_BUILD_DIR)/build/libnxp.so* $(TARGET_libdir)
endef

libnxp: | $(TARGET_DIR)
	$(call generic-package)

endif
