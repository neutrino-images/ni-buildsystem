#
# makefile to build libstb-hal and neutrino
#
# -----------------------------------------------------------------------------

NEUTRINO_INST_DIR ?= $(TARGET_DIR)

NEUTRINO_OBJ       = $(NI_NEUTRINO)-obj
NEUTRINO_BUILD_DIR = $(BUILD_DIR)/$(NEUTRINO_OBJ)

ifeq ($(BOXTYPE),coolstream)
  NEUTRINO_BRANCH = ni/$(BOXTYPE)
else
  NEUTRINO_BRANCH ?= master
endif

LIBSTB_HAL_OBJ       = $(NI_LIBSTB_HAL)-obj
LIBSTB_HAL_BUILD_DIR = $(BUILD_DIR)/$(LIBSTB_HAL_OBJ)

# -----------------------------------------------------------------------------

NEUTRINO_DEPENDENCIES =
NEUTRINO_DEPENDENCIES += ffmpeg
NEUTRINO_DEPENDENCIES += freetype
NEUTRINO_DEPENDENCIES += giflib
NEUTRINO_DEPENDENCIES += libcurl
NEUTRINO_DEPENDENCIES += libdvbsi
NEUTRINO_DEPENDENCIES += fribidi
NEUTRINO_DEPENDENCIES += libjpeg-turbo
NEUTRINO_DEPENDENCIES += libsigc
NEUTRINO_DEPENDENCIES += lua
NEUTRINO_DEPENDENCIES += ntp
NEUTRINO_DEPENDENCIES += openssl
NEUTRINO_DEPENDENCIES += openthreads
NEUTRINO_DEPENDENCIES += pugixml
NEUTRINO_DEPENDENCIES += zlib

# -----------------------------------------------------------------------------

NEUTRINO_CFLAGS = -Wall -W -Wshadow -D__STDC_CONSTANT_MACROS
ifeq ($(BOXSERIES),hd1)
  NEUTRINO_CFLAGS += -DCPU_FREQ
endif
ifeq ($(BOXSERIES),hd2)
  NEUTRINO_CFLAGS += -DFB_HW_ACCELERATION
endif

ifeq ($(DEBUG),yes)
  NEUTRINO_CFLAGS += -ggdb3 -rdynamic -I$(TARGET_includedir)
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

NEUTRINO_OMDB_API_KEY ?= 20711f9e
NEUTRINO_SHOUTCAST_DEV_KEY ?= fa1669MuiRPorUBw
NEUTRINO_TMDB_DEV_KEY ?= 7270f1b571c4ecbb5b204ddb7f8939b1
NEUTRINO_YOUTUBE_DEV_KEY ?= AIzaSyBLdZe7M3rpNMZqSj-3IEvjbb2hATWJIdM
NEUTRINO_WEATHER_DEV_KEY ?=

# -----------------------------------------------------------------------------

NEUTRINO_CONF_ENV = \
	$(TARGET_MAKE_OPTS) \
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
	--enable-maintainer-mode \
	--enable-silent-rules \
	\
	--enable-freesatepg \
	--enable-fribidi \
	--enable-giflib \
	--enable-lua \
	--enable-mdev \
	--enable-pugixml \
	\
	--with-omdb-api-key="$(NEUTRINO_OMDB_API_KEY)" \
	--with-shoutcast-dev-key="$(NEUTRINO_SHOUTCAST_DEV_KEY)" \
	--with-tmdb-dev-key="$(NEUTRINO_TMDB_DEV_KEY)" \
	--with-youtube-dev-key="$(NEUTRINO_YOUTUBE_DEV_KEY)" \
	--with-weather-dev-key="$(NEUTRINO_WEATHER_DEV_KEY)" \
	\
	--with-target=cdk \
	--with-targetprefix=$(prefix) \
	--with-boxtype=$(BOXTYPE)

ifeq ($(BOXSERIES),$(filter $(BOXSERIES),hd1 hd2))
  NEUTRINO_CONF_OPTS += --with-boxmodel=$(BOXSERIES)
else
  NEUTRINO_CONF_OPTS += --with-boxmodel=$(BOXMODEL)
endif

NEUTRINO_CONF_OPTS += --enable-pip

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

# enable ffmpeg audio decoder in neutrino
NEUTRINO_AUDIODEC = ffmpeg

ifeq ($(NEUTRINO_AUDIODEC),ffmpeg)
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
	test -d $(NEUTRINO_BUILD_DIR) || mkdir -p $(NEUTRINO_BUILD_DIR)
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
	$(INSTALL_EXEC) $(PKG_FILES_DIR)/start_neutrino.$(BOXTYPE) $(TARGET_sysconfdir)/init.d/start_neutrino
	$(TOUCH)

# -----------------------------------------------------------------------------

LIBSTB_HAL_DEPENDENCIES =
LIBSTB_HAL_DEPENDENCIES += ffmpeg
LIBSTB_HAL_DEPENDENCIES += openthreads

# -----------------------------------------------------------------------------

LIBSTB_HAL_CONF_ENV = \
	$(NEUTRINO_CONF_ENV)

# -----------------------------------------------------------------------------

LIBSTB_HAL_CONF_OPTS = \
	--build=$(GNU_HOST_NAME) \
	--host=$(TARGET) \
	--target=$(TARGET) \
	--prefix=$(prefix) \
	--enable-maintainer-mode \
	--enable-silent-rules \
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
	test -d $(LIBSTB_HAL_BUILD_DIR) || mkdir -p $(LIBSTB_HAL_BUILD_DIR)
	$(SOURCE_DIR)/$(NI_LIBSTB_HAL)/autogen.sh
	$(CD) $(LIBSTB_HAL_BUILD_DIR); \
		$(LIBSTB_HAL_CONF_ENV) \
		$(SOURCE_DIR)/$(NI_LIBSTB_HAL)/configure \
			$(LIBSTB_HAL_CONF_OPTS)

# -----------------------------------------------------------------------------

libstb-hal: $(LIBSTB_HAL_BUILD_DIR)/config.status
	$(MAKE) -C $(LIBSTB_HAL_BUILD_DIR)
	$(MAKE) -C $(LIBSTB_HAL_BUILD_DIR) install DESTDIR=$(NEUTRINO_INST_DIR)
	$(REWRITE_LIBTOOL)
	$(TOUCH)

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
	make done

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

# -----------------------------------------------------------------------------

PHONY += neutrino-bin
PHONY += neutrino-uninstall neutrino-distclean
PHONY += neutrino-clean neutrino-clean-all

PHONY += libstb-hal-uninstall libstb-hal-distclean
PHONY += libstb-hal-clean libstb-hal-clean-all
