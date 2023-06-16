################################################################################
#
# coolstream-libs
#
################################################################################

nevis-libs \
apollo-libs \
shiner-libs \
kronos-libs \
kronos_v2-libs: coolstream-libs

# -----------------------------------------------------------------------------

COOLSTREAM_LIBS_VERSION = master
COOLSTREAM_LIBS_DIR = $(NI_DRIVERS_BIN)
COOLSTREAM_LIBS_SOURCE = $(NI_DRIVERS_BIN)
COOLSTREAM_LIBS_SITE = https://github.com/neutrino-images
COOLSTREAM_LIBS_SITE_METHOD = ni-git

define COOLSTREAM_LIBS_INSTALL_MODULES
	$(INSTALL) -d $(TARGET_libdir)
	$(INSTALL_COPY) $($(PKG)_BUILD_DIR)/$(DRIVERS_BIN_DIR)/lib/. $(TARGET_libdir)
	$(INSTALL_COPY) $($(PKG)_BUILD_DIR)/$(DRIVERS_BIN_DIR)/libcoolstream/$(shell echo -n $(BS_PACKAGE_FFMPEG2_BRANCH) | sed 's,/,-,g')/. $(TARGET_libdir)
endef
COOLSTREAM_LIBS_INDIVIDUAL_HOOKS += COOLSTREAM_LIBS_INSTALL_MODULES

ifeq ($(BOXMODEL),nevis)
define COOLSTREAM_LIBS_LINKING_LIBCONEXANT
	ln -sf libnxp.so $(TARGET_libdir)/libconexant.so
endef
COOLSTREAM_LIBS_INDIVIDUAL_HOOKS += COOLSTREAM_LIBS_LINKING_LIBCONEXANT
endif

coolstream-libs: | $(TARGET_DIR)
	$(call individual-package)
