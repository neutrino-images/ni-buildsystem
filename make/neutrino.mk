#
# makefile to build libstb-hal and neutrino
#
# -----------------------------------------------------------------------------

NEUTRINO_INST_DIR ?= $(TARGET_DIR)

NEUTRINO_OBJ       = $(NI-NEUTRINO)-obj
NEUTRINO_BUILD_DIR = $(BUILD_DIR)/$(NEUTRINO_OBJ)

LIBSTB-HAL_OBJ       = $(NI-LIBSTB-HAL)-obj
LIBSTB-HAL_BUILD_DIR = $(BUILD_DIR)/$(LIBSTB-HAL_OBJ)

# -----------------------------------------------------------------------------

NEUTRINO_DEPS  =
NEUTRINO_DEPS += ffmpeg
NEUTRINO_DEPS += freetype
NEUTRINO_DEPS += giflib
NEUTRINO_DEPS += libcurl
NEUTRINO_DEPS += libdvbsi
NEUTRINO_DEPS += fribidi
NEUTRINO_DEPS += libjpeg-turbo
NEUTRINO_DEPS += libsigc
NEUTRINO_DEPS += lua
NEUTRINO_DEPS += ntp
NEUTRINO_DEPS += openssl
NEUTRINO_DEPS += openthreads
NEUTRINO_DEPS += pugixml
NEUTRINO_DEPS += zlib

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

NEUTRINO_LDFLAGS  = $(CORTEX-STRINGS_LDFLAG)
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
	$(MAKE_OPTS) \
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
	--host=$(TARGET) \
	--build=$(BUILD) \
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

# -----------------------------------------------------------------------------

ifeq ($(BOXTYPE),coolstream)
  NEUTRINO_DEPS += coolstream-drivers
  ifeq ($(HAS_LIBCS),yes)
    NEUTRINO_DEPS += libcoolstream
    ifeq ($(DEBUG),yes)
      NEUTRINO_CONF_OPTS += \
	--enable-libcoolstream-static \
	--with-libcoolstream-static-dir=$(TARGET_libdir)
    endif
  endif

  NEUTRINO_CONF_OPTS += --enable-pip
else
  NEUTRINO_DEPS += libstb-hal
  NEUTRINO_CONF_OPTS += \
	--with-stb-hal-includes=$(SOURCE_DIR)/$(NI-LIBSTB-HAL)/include \
	--with-stb-hal-build=$(LIBSTB-HAL_BUILD_DIR)

  NEUTRINO_DEPS += graphlcd-base
  NEUTRINO_CONF_OPTS += --enable-graphlcd

  ifeq ($(BOXTYPE),armbox)
    NEUTRINO_CONF_OPTS += --disable-arm-acc
  endif
  ifeq ($(BOXTYPE),mipsbox)
    NEUTRINO_CONF_OPTS += --disable-mips-acc
  endif
endif

# enable ffmpeg audio decoder in neutrino
NEUTRINO_AUDIODEC = ffmpeg

ifeq ($(NEUTRINO_AUDIODEC),ffmpeg)
  NEUTRINO_CONF_OPTS += --enable-ffmpegdec
else
  NEUTRINO_DEPS += libid3tag
  NEUTRINO_DEPS += libmad

  NEUTRINO_DEPS += libvorbisidec
  NEUTRINO_CONF_OPTS += --with-tremor

  NEUTRINO_DEPS += flac
  NEUTRINO_CONF_OPTS += --enable-flac
endif

# -----------------------------------------------------------------------------

$(NEUTRINO_BUILD_DIR)/config.status: $(NEUTRINO_DEPS)
	test -d $(NEUTRINO_BUILD_DIR) || mkdir -p $(NEUTRINO_BUILD_DIR)
	$(CD) $(SOURCE_DIR)/$(NI-NEUTRINO); \
		git checkout $(NI-NEUTRINO_BRANCH)
	$(SOURCE_DIR)/$(NI-NEUTRINO)/autogen.sh
	$(CD) $(NEUTRINO_BUILD_DIR); \
		$(NEUTRINO_CONF_ENV) \
		$(SOURCE_DIR)/$(NI-NEUTRINO)/configure \
			$(NEUTRINO_CONF_OPTS)

# -----------------------------------------------------------------------------

neutrino: $(NEUTRINO_BUILD_DIR)/config.status
	$(MAKE) -C $(NEUTRINO_BUILD_DIR)
	$(MAKE) -C $(NEUTRINO_BUILD_DIR) install DESTDIR=$(NEUTRINO_INST_DIR)
	$(MAKE) $(TARGET_sysconfdir)/init.d/start_neutrino
	$(TOUCH)

# -----------------------------------------------------------------------------

$(TARGET_sysconfdir)/init.d/start_neutrino:
	$(INSTALL_EXEC) -D $(TARGET_FILES)/scripts/start_neutrino.$(BOXTYPE) $(@)

# -----------------------------------------------------------------------------

LIBSTB-HAL_DEPS  =
LIBSTB-HAL_DEPS += ffmpeg
LIBSTB-HAL_DEPS += openthreads

# -----------------------------------------------------------------------------

LIBSTB-HAL_CONF_ENV = \
	$(NEUTRINO_CONF_ENV)

# -----------------------------------------------------------------------------

LIBSTB-HAL_CONF_OPTS = \
	--host=$(TARGET) \
	--build=$(BUILD) \
	--prefix=$(prefix) \
	--enable-maintainer-mode \
	--enable-silent-rules \
	--enable-shared=no \
	\
	--with-target=cdk \
	--with-targetprefix=$(prefix) \
	--with-boxtype=$(BOXTYPE)

ifeq ($(BOXSERIES),$(filter $(BOXSERIES),hd1 hd2))
  LIBSTB-HAL_CONF_OPTS += --with-boxmodel=$(BOXSERIES)
else
  LIBSTB-HAL_CONF_OPTS += --with-boxmodel=$(BOXMODEL)
endif

# -----------------------------------------------------------------------------

$(LIBSTB-HAL_BUILD_DIR)/config.status: $(LIBSTB-HAL_DEPS)
	test -d $(LIBSTB-HAL_BUILD_DIR) || mkdir -p $(LIBSTB-HAL_BUILD_DIR)
	$(SOURCE_DIR)/$(NI-LIBSTB-HAL)/autogen.sh
	$(CD) $(LIBSTB-HAL_BUILD_DIR); \
		$(LIBSTB-HAL_CONF_ENV) \
		$(SOURCE_DIR)/$(NI-LIBSTB-HAL)/configure \
			$(LIBSTB-HAL_CONF_OPTS)

# -----------------------------------------------------------------------------

libstb-hal: $(LIBSTB-HAL_BUILD_DIR)/config.status
	$(MAKE) -C $(LIBSTB-HAL_BUILD_DIR)
	$(MAKE) -C $(LIBSTB-HAL_BUILD_DIR) install DESTDIR=$(NEUTRINO_INST_DIR)
	$(REWRITE_LIBTOOL_LA)
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
	-make -C $(LIBSTB-HAL_BUILD_DIR) uninstall DESTDIR=$(TARGET_DIR)

libstb-hal-distclean:
	-make -C $(LIBSTB-HAL_BUILD_DIR) distclean

libstb-hal-clean: libstb-hal-uninstall libstb-hal-distclean
	rm -f $(LIBSTB-HAL_BUILD_DIR)/config.status
	rm -f $(DEPS_DIR)/libstb-hal

libstb-hal-clean-all: libstb-hal-clean
	rm -rf $(LIBSTB-HAL_BUILD_DIR)

# -----------------------------------------------------------------------------

PHONY += neutrino-bin
PHONY += neutrino-uninstall neutrino-distclean
PHONY += neutrino-clean neutrino-clean-all

PHONY += libstb-hal-uninstall libstb-hal-distclean
PHONY += libstb-hal-clean libstb-hal-clean-all
