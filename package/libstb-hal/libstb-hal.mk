################################################################################
#
# libstb-hal
#
################################################################################

LIBSTB_HAL_OBJ       = $(NI_LIBSTB_HAL)-obj
LIBSTB_HAL_BUILD_DIR = $(BUILD_DIR)/$(LIBSTB_HAL_OBJ)

# -----------------------------------------------------------------------------

LIBSTB_HAL_DEPENDENCIES = ffmpeg openthreads

# -----------------------------------------------------------------------------

LIBSTB_HAL_CONF_ENV = \
	$(NEUTRINO_CONF_ENV)

# -----------------------------------------------------------------------------

LIBSTB_HAL_CONF_OPTS = \
	--build=$(GNU_HOST_NAME) \
	--host=$(GNU_TARGET_NAME) \
	--target=$(GNU_TARGET_NAME) \
	--prefix=$(prefix) \
	$(if $(findstring 1,$(KBUILD_VERBOSE)),--disable-silent-rules,--enable-silent-rules) \
	--enable-maintainer-mode \
	--enable-shared=no \
	\
	--with-target=cdk \
	--with-targetprefix=$(prefix) \
	--with-boxtype=$(BOXTYPE)

ifeq ($(BOXSERIES),$(filter $(BOXSERIES),hd1 hd2))
  LIBSTB_HAL_CONF_OPTS += --with-boxmodel=$(BOXSERIES)
else
  LIBSTB_HAL_CONF_OPTS += --with-boxmodel=$(BOXMODEL)
endif

# -----------------------------------------------------------------------------

$(LIBSTB_HAL_BUILD_DIR)/config.status: $(LIBSTB_HAL_DEPENDENCIES)
	test -d $(LIBSTB_HAL_BUILD_DIR) || $(INSTALL) -d $(LIBSTB_HAL_BUILD_DIR)
	$(SOURCE_DIR)/$(NI_LIBSTB_HAL)/autogen.sh
	$(CD) $(LIBSTB_HAL_BUILD_DIR); \
		$(LIBSTB_HAL_CONF_ENV) \
		$(SOURCE_DIR)/$(NI_LIBSTB_HAL)/configure \
			$(LIBSTB_HAL_CONF_OPTS)

# -----------------------------------------------------------------------------

libstb-hal: $(LIBSTB_HAL_BUILD_DIR)/config.status
	$(MAKE) -C $(LIBSTB_HAL_BUILD_DIR)
	$(MAKE) -C $(LIBSTB_HAL_BUILD_DIR) install DESTDIR=$(NEUTRINO_INST_DIR)
	$(call REWRITE_LIBTOOL)
	$(call TOUCH)

# -----------------------------------------------------------------------------

libstb-hal-uninstall:
	-make -C $(LIBSTB_HAL_BUILD_DIR) uninstall DESTDIR=$(TARGET_DIR)

libstb-hal-distclean:
	-make -C $(LIBSTB_HAL_BUILD_DIR) distclean

libstb-hal-clean: libstb-hal-uninstall libstb-hal-distclean
	rm -f $(LIBSTB_HAL_BUILD_DIR)/config.status
	rm -f $(DEPS_DIR)/libstb-hal

libstb-hal-clean-all: libstb-hal-clean
	rm -rf $(LIBSTB_HAL_BUILD_DIR)
