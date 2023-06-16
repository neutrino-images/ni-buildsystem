################################################################################
#
# libstb-hal
#
################################################################################

LIBSTB_HAL_VERSION = master
LIBSTB_HAL_DIR = $(NI_LIBSTB_HAL)
LIBSTB_HAL_SOURCE = $(NI_LIBSTB_HAL)
LIBSTB_HAL_SITE = https://github.com/neutrino-images
LIBSTB_HAL_SITE_METHOD = ni-git

LIBSTB_HAL_DEPENDENCIES = ffmpeg openthreads

LIBSTB_HAL_OBJ_DIR = $(BUILD_DIR)/$(LIBSTB_HAL_DIR)-obj
LIBSTB_HAL_CONFIG_STATUS = $(wildcard $(LIBSTB_HAL_OBJ_DIR)/config.status)

LIBSTB_HAL_CONF_ENV = \
	$(NEUTRINO_CONF_ENV)

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

define LIBSTB_HAL_AUTOGEN_SH
	$($(PKG)_BUILD_DIR)/autogen.sh
endef
LIBSTB_HAL_PRE_CONFIGURE_HOOKS += LIBSTB_HAL_AUTOGEN_SH

define LIBSTB_HAL_CONFIGURE_CMDS
	$(INSTALL) -d $(LIBSTB_HAL_OBJ_DIR)
	$(CD) $(LIBSTB_HAL_OBJ_DIR); \
		$($(PKG)_CONF_ENV) \
		$($(PKG)_BUILD_DIR)/configure \
			$($(PKG)_CONF_OPTS)
endef

define LIBSTB_HAL_BUILD_CMDS
	$(MAKE) -C $(LIBSTB_HAL_OBJ_DIR)
endef

define LIBSTB_HAL_INSTALL_CMDS
	$(MAKE) -C $(LIBSTB_HAL_OBJ_DIR) install DESTDIR=$(NEUTRINO_INST_DIR)
endef

libstb-hal: | $(TARGET_DIR)
	$(call autotools-package,$(if $(LIBSTB_HAL_CONFIG_STATUS),$(PKG_NO_CONFIGURE)))
