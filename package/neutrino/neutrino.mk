################################################################################
#
# neutrino
#
################################################################################

NEUTRINO_VERSION = $(BS_PACKAGE_NEUTRINO_BRANCH)
NEUTRINO_DIR = $(NI_NEUTRINO)
NEUTRINO_SOURCE = $(NI_NEUTRINO)
NEUTRINO_SITE = https://github.com/neutrino-images
NEUTRINO_SITE_METHOD = ni-git

NEUTRINO_DEPENDENCIES = ffmpeg freetype giflib libcurl libdvbsi fribidi \
	libjpeg-turbo libsigc lua ntp openssl openthreads pugixml zlib

NEUTRINO_OBJ_DIR = $(BUILD_DIR)/$(NEUTRINO_DIR)-obj
NEUTRINO_CONFIG_STATUS = $(wildcard $(NEUTRINO_OBJ_DIR)/config.status)

NEUTRINO_INST_DIR ?= $(TARGET_DIR)

NEUTRINO_CFLAGS = -Wall -W -Wshadow -D__STDC_CONSTANT_MACROS
ifeq ($(DEBUG),yes)
  NEUTRINO_CFLAGS += -ggdb3 -rdynamic -I$(TARGET_includedir) $(CXX11_ABI)
else
  NEUTRINO_CFLAGS += $(TARGET_CFLAGS)
endif
NEUTRINO_CFLAGS += -Wno-psabi

NEUTRINO_LDFLAGS  = $(CORTEX_STRINGS_LDFLAG)
NEUTRINO_LDFLAGS += -L$(TARGET_base_libdir) -L$(TARGET_libdir)
NEUTRINO_LDFLAGS += -Wl,-rpath,$(TARGET_libdir) -Wl,-rpath-link,$(TARGET_libdir)
ifeq ($(DEBUG),yes)
  NEUTRINO_LDFLAGS += -Wl,-O0
else
  NEUTRINO_LDFLAGS += -Wl,-O1 $(TARGET_EXTRA_LDFLAGS)
endif
NEUTRINO_LDFLAGS += -lcrypto -ldl -lz

NEUTRINO_CONF_ENV = \
	$(TARGET_CONFIGURE_ENVIRONMENT) \
	\
	CFLAGS="$(NEUTRINO_CFLAGS)" \
	CPPFLAGS="$(NEUTRINO_CFLAGS)" \
	CXXFLAGS="$(NEUTRINO_CFLAGS) -std=c++11" \
	LDFLAGS="$(NEUTRINO_LDFLAGS)"

NEUTRINO_CONF_ENV += \
	PKG_CONFIG=$(PKG_CONFIG) \
	PKG_CONFIG_PATH="$(PKG_CONFIG_PATH)" \
	PKG_CONFIG_SYSROOT_DIR=$(PKG_CONFIG_SYSROOT_DIR)

NEUTRINO_CONF_OPTS = \
	--build=$(GNU_HOST_NAME) \
	--host=$(GNU_TARGET_NAME) \
	--target=$(GNU_TARGET_NAME) \
	--prefix=$(prefix) \
	$(if $(findstring 1,$(KBUILD_VERBOSE)),--disable-silent-rules,--enable-silent-rules) \
	--enable-maintainer-mode \
	\
	--enable-freesatepg \
	--enable-fribidi \
	--enable-giflib \
	--enable-lua \
	--enable-mdev \
	--enable-pugixml \
	\
	--with-omdb-api-key="$(BS_PACKAGE_NEUTRINO_OMDB_API_KEY)" \
	--with-shoutcast-dev-key="$(BS_PACKAGE_NEUTRINO_SHOUTCAST_DEV_KEY)" \
	--with-tmdb-dev-key="$(BS_PACKAGE_NEUTRINO_TMDB_DEV_KEY)" \
	--with-youtube-dev-key="$(BS_PACKAGE_NEUTRINO_YOUTUBE_DEV_KEY)" \
	--with-weather-dev-key="$(BS_PACKAGE_NEUTRINO_WEATHER_DEV_KEY)" \
	\
	--with-target=cdk \
	--with-targetprefix=$(prefix) \
	--with-boxtype=$(BOXTYPE)

ifeq ($(BOXSERIES),$(filter $(BOXSERIES),hd1 hd2))
  NEUTRINO_CONF_OPTS += --with-boxmodel=$(BOXSERIES)
else
  NEUTRINO_CONF_OPTS += --with-boxmodel=$(BOXMODEL)
endif

ifeq ($(BOXTYPE),coolstream)
  NEUTRINO_DEPENDENCIES += coolstream-drivers
  ifeq ($(HAS_LIBCOOLSTREAM),yes)
    NEUTRINO_DEPENDENCIES += libcoolstream
    ifeq ($(DEBUG),yes)
      NEUTRINO_CONF_OPTS += \
	--enable-libcoolstream-static \
	--with-libcoolstream-static-dir=$(TARGET_libdir)
    endif
  endif

  NEUTRINO_CONF_OPTS += --disable-aitscan

else
  NEUTRINO_DEPENDENCIES += libstb-hal
  NEUTRINO_CONF_OPTS += \
	--with-stb-hal-includes=$(SOURCE_DIR)/$(NI_LIBSTB_HAL)/include \
	--with-stb-hal-build=$(LIBSTB_HAL_OBJ_DIR)

  NEUTRINO_DEPENDENCIES += graphlcd-base
  NEUTRINO_CONF_OPTS += --enable-graphlcd

  ifeq ($(BOXTYPE),armbox)
    #NEUTRINO_CONF_OPTS += --disable-arm-acc
  endif
  ifeq ($(BOXTYPE),mipsbox)
    #NEUTRINO_CONF_OPTS += --disable-mips-acc
  endif
  #NEUTRINO_CONF_OPTS += --enable-dynamicdemux

endif

NEUTRINO_DEPENDENCIES += lcd4linux
NEUTRINO_CONF_OPTS += --enable-lcd4linux

ifeq ($(BS_PACKAGE_NEUTRINO_PIP),y)
  NEUTRINO_CONF_OPTS += --enable-pip
endif

ifeq ($(BS_PACKAGE_NEUTRINO_AUDIODEC_FFMPEG),y)
  NEUTRINO_CONF_OPTS += --enable-ffmpegdec
else
  NEUTRINO_DEPENDENCIES += libid3tag
  NEUTRINO_DEPENDENCIES += libmad

  NEUTRINO_DEPENDENCIES += libvorbisidec
  NEUTRINO_CONF_OPTS += --with-tremor

  NEUTRINO_DEPENDENCIES += flac
  NEUTRINO_CONF_OPTS += --enable-flac
endif

define NEUTRINO_AUTOGEN_SH
	$(PKG_BUILD_DIR)/autogen.sh
endef
NEUTRINO_PRE_CONFIGURE_HOOKS += NEUTRINO_AUTOGEN_SH

define NEUTRINO_CONFIGURE_CMDS
	$(INSTALL) -d $(NEUTRINO_OBJ_DIR)
	$(CD) $(NEUTRINO_OBJ_DIR); \
		$($(PKG)_CONF_ENV) \
		$(PKG_BUILD_DIR)/configure \
			$($(PKG)_CONF_OPTS)
endef

define NEUTRINO_BUILD_CMDS
	$(MAKE) -C $(NEUTRINO_OBJ_DIR)
endef

define NEUTRINO_INSTALL_CMDS
	$(MAKE) -C $(NEUTRINO_OBJ_DIR) install DESTDIR=$(NEUTRINO_INST_DIR)
endef

define NEUTRINO_INSTALL_STARTSCRIPT
	$(INSTALL_EXEC) $(PKG_FILES_DIR)/start_neutrino $(TARGET_sysconfdir)/init.d/start_neutrino
endef
NEUTRINO_POST_INSTALL_HOOKS += NEUTRINO_INSTALL_STARTSCRIPT

define NEUTRINO_UNINSTALL_STARTSCRIPT
	rm -f $(TARGET_sysconfdir)/init.d/start_neutrino
endef
NEUTRINO_PRE_UNINSTALL_HOOKS += NEUTRINO_UNINSTALL_STARTSCRIPT

# needed to build neutrino-bin target only
NEUTRINO_PKG_FLAGS ?=

neutrino: | $(TARGET_DIR)
	$(call autotools-package,$(if $(NEUTRINO_CONFIG_STATUS),$(PKG_NO_CONFIGURE)) $(NEUTRINO_PKG_FLAGS))
