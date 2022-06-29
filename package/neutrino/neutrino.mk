################################################################################
#
# neutrino
#
################################################################################

NEUTRINO_INST_DIR ?= $(TARGET_DIR)

NEUTRINO_OBJ       = $(NI_NEUTRINO)-obj
NEUTRINO_BUILD_DIR = $(BUILD_DIR)/$(NEUTRINO_OBJ)

#ifeq ($(BOXTYPE),coolstream)
#  NEUTRINO_BRANCH = ni/$(BOXTYPE)
#else
  NEUTRINO_BRANCH ?= master
#endif

# -----------------------------------------------------------------------------

NEUTRINO_DEPENDENCIES = ffmpeg freetype giflib libcurl libdvbsi fribidi \
	libjpeg-turbo libsigc lua ntp openssl openthreads pugixml zlib

# -----------------------------------------------------------------------------

NEUTRINO_CFLAGS = -Wall -W -Wshadow -D__STDC_CONSTANT_MACROS
ifeq ($(BOXSERIES),hd1)
  NEUTRINO_CFLAGS += -DCPU_FREQ
endif
ifeq ($(BOXSERIES),hd2)
  NEUTRINO_CFLAGS += -DFB_HW_ACCELERATION
endif

ifeq ($(DEBUG),yes)
  NEUTRINO_CFLAGS += -ggdb3 -rdynamic -I$(TARGET_includedir) $(CXX11_ABI)
else
  NEUTRINO_CFLAGS += $(TARGET_CFLAGS)
endif

NEUTRINO_CFLAGS += -Wno-psabi

# -----------------------------------------------------------------------------

NEUTRINO_LDFLAGS  = $(CORTEX_STRINGS_LDFLAG)
NEUTRINO_LDFLAGS += -L$(TARGET_base_libdir) -L$(TARGET_libdir)
NEUTRINO_LDFLAGS += -Wl,-rpath,$(TARGET_libdir) -Wl,-rpath-link,$(TARGET_libdir)
ifeq ($(DEBUG),yes)
  NEUTRINO_LDFLAGS += -Wl,-O0
else
  NEUTRINO_LDFLAGS += -Wl,-O1 $(TARGET_EXTRA_LDFLAGS)
endif
NEUTRINO_LDFLAGS += -lcrypto -ldl -lz

# -----------------------------------------------------------------------------

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

# -----------------------------------------------------------------------------

NEUTRINO_CONF_OPTS = \
	--build=$(GNU_HOST_NAME) \
	--host=$(TARGET) \
	--target=$(TARGET) \
	--prefix=$(prefix) \
	$(if $(findstring 1,$(KBUILD_VERBOSE)),--disable-silent-rules,--enable-silent-rules) \
	--enable-maintainer-mode \
	\
	--disable-youtube-player \
	\
	--enable-freesatepg \
	--enable-fribidi \
	--enable-giflib \
	--enable-lua \
	--enable-mdev \
	--enable-pip \
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
	--with-stb-hal-build=$(LIBSTB_HAL_BUILD_DIR)

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

# -----------------------------------------------------------------------------

$(NEUTRINO_BUILD_DIR)/config.status: $(NEUTRINO_DEPENDENCIES)
	test -d $(NEUTRINO_BUILD_DIR) || $(INSTALL) -d $(NEUTRINO_BUILD_DIR)
	$(CD) $(SOURCE_DIR)/$(NI_NEUTRINO); \
		git checkout $(NEUTRINO_BRANCH)
	$(SOURCE_DIR)/$(NI_NEUTRINO)/autogen.sh
	$(CD) $(NEUTRINO_BUILD_DIR); \
		$(NEUTRINO_CONF_ENV) \
		$(SOURCE_DIR)/$(NI_NEUTRINO)/configure \
			$(NEUTRINO_CONF_OPTS)

# -----------------------------------------------------------------------------

neutrino: $(NEUTRINO_BUILD_DIR)/config.status
	$(MAKE) -C $(NEUTRINO_BUILD_DIR)
	$(MAKE) -C $(NEUTRINO_BUILD_DIR) install DESTDIR=$(NEUTRINO_INST_DIR)
	$(INSTALL_EXEC) $(PKG_FILES_DIR)/start_neutrino $(TARGET_sysconfdir)/init.d/start_neutrino
	$(call TOUCH)

# -----------------------------------------------------------------------------

neutrino-bin:
ifeq ($(CLEAN),yes)
	$(MAKE) neutrino-clean
endif
	$(MAKE) $(NEUTRINO_BUILD_DIR)/config.status
	$(MAKE) -C $(NEUTRINO_BUILD_DIR)
	$(INSTALL_EXEC) -D $(NEUTRINO_BUILD_DIR)/src/neutrino $(TARGET_bindir)/neutrino
ifneq ($(DEBUG),yes)
	$(TARGET_STRIP) $(TARGET_bindir)/neutrino
endif
	@make done

# -----------------------------------------------------------------------------

neutrino-uninstall:
	-make -C $(NEUTRINO_BUILD_DIR) uninstall DESTDIR=$(TARGET_DIR)

neutrino-distclean:
	-make -C $(NEUTRINO_BUILD_DIR) distclean

neutrino-clean: neutrino-uninstall neutrino-distclean
	rm -f $(NEUTRINO_BUILD_DIR)/config.status
	rm -f $(DEPS_DIR)/neutrino
	rm -f $(TARGET_sysconfdir)/init.d/start_neutrino

neutrino-clean-all: neutrino-clean
	rm -rf $(NEUTRINO_BUILD_DIR)
