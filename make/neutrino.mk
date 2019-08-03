#
# makefile to build libstb-hal and neutrino
#
# -----------------------------------------------------------------------------

N_INST_DIR ?= $(TARGET_DIR)
N_OBJ_DIR = $(BUILD_TMP)/$(NI-NEUTRINO)

# -----------------------------------------------------------------------------

N_DEPS  =
N_DEPS += $(D)/ffmpeg
N_DEPS += $(D)/freetype
N_DEPS += $(D)/giflib
N_DEPS += $(D)/libcurl
N_DEPS += $(D)/libdvbsi
N_DEPS += $(D)/fribidi
N_DEPS += $(D)/libjpeg
N_DEPS += $(D)/libsigc++
N_DEPS += $(D)/lua
N_DEPS += $(D)/ntp
N_DEPS += $(D)/openssl
N_DEPS += $(D)/openthreads
N_DEPS += $(D)/pugixml
N_DEPS += $(D)/zlib

ifeq ($(BOXTYPE)-$(HAS_LIBCS), coolstream-yes)
  N_DEPS += $(D)/libcoolstream
endif

ifneq ($(BOXTYPE), coolstream)
  N_DEPS += $(D)/libstb-hal
endif

# uncomment next lines to build neutrino without --enable-ffmpegdec
#N_DEPS += $(D)/libFLAC
#N_DEPS += $(D)/libid3tag
#N_DEPS += $(D)/libmad
#N_DEPS += $(D)/libvorbisidec

# -----------------------------------------------------------------------------

N_CFLAGS = -Wall -W -Wshadow -D__STDC_CONSTANT_MACROS
ifeq ($(BOXSERIES), hd1)
  N_CFLAGS += -DCPU_FREQ
endif
ifeq ($(BOXSERIES), hd2)
  N_CFLAGS += -DFB_HW_ACCELERATION
endif

ifeq ($(BOXSERIES), $(filter $(BOXSERIES), hd51 bre2ze4k))
  ifeq ($(USE_GSTREAMER), yes)
    N_CFLAGS += $(shell $(PKG_CONFIG) --cflags --libs gstreamer-1.0)
    N_CFLAGS += $(shell $(PKG_CONFIG) --cflags --libs gstreamer-audio-1.0)
    N_CFLAGS += $(shell $(PKG_CONFIG) --cflags --libs gstreamer-video-1.0)
    N_CFLAGS += $(shell $(PKG_CONFIG) --cflags --libs glib-2.0)
  endif
endif

ifeq ($(DEBUG), yes)
  N_CFLAGS += -ggdb3 -rdynamic -I$(TARGET_INCLUDE_DIR)
else
  N_CFLAGS += $(TARGET_CFLAGS)
endif

# -----------------------------------------------------------------------------

N_LDFLAGS = -lcrypto -ldl -lz $(CORTEX-STRINGS_LDFLAG) -L$(TARGET_LIB_DIR)
ifeq ($(DEBUG), yes)
  N_LDFLAGS += -Wl,-rpath-link,$(TARGET_LIB_DIR)
else
  N_LDFLAGS += -Wl,-O1 -Wl,-rpath-link,$(TARGET_LIB_DIR) $(TARGET_EXTRA_LDFLAGS)
endif

# -----------------------------------------------------------------------------

N_CONFIGURE_DEBUG =
ifeq ($(BOXTYPE)-$(HAS_LIBCS), coolstream-yes)
  ifeq ($(DEBUG), yes)
    N_CONFIGURE_DEBUG += \
		--enable-libcoolstream-static \
		--with-libcoolstream-static-dir=$(TARGET_LIB_DIR)
  endif
endif

# -----------------------------------------------------------------------------

N_CONFIGURE_LIBSTB-HAL =
ifneq ($(BOXTYPE), coolstream)
  N_CONFIGURE_LIBSTB-HAL += \
		--with-stb-hal-includes=$(SOURCE_DIR)/$(NI-LIBSTB-HAL)/include \
		--with-stb-hal-build=$(LH_OBJ_DIR)
endif

# -----------------------------------------------------------------------------

N_CONFIGURE_ADDITIONS =
ifeq ($(BOXTYPE), coolstream)
  N_CONFIGURE_ADDITIONS += \
		--enable-pip
endif

# -----------------------------------------------------------------------------

N_OMDB_API_KEY ?= 20711f9e
N_SHOUTCAST_DEV_KEY ?= fa1669MuiRPorUBw
N_TMDB_DEV_KEY ?= 7270f1b571c4ecbb5b204ddb7f8939b1
N_YOUTUBE_DEV_KEY ?= AIzaSyBLdZe7M3rpNMZqSj-3IEvjbb2hATWJIdM
N_WEATHER_DEV_KEY ?=

# -----------------------------------------------------------------------------

N_BUILD_ENV = \
	$(MAKE_OPTS) \
	\
	CFLAGS="$(N_CFLAGS)" \
	CPPFLAGS="$(N_CFLAGS)" \
	CXXFLAGS="$(N_CFLAGS) -std=c++11" \
	LDFLAGS="$(N_LDFLAGS)"

N_BUILD_ENV += \
	PKG_CONFIG=$(PKG_CONFIG) \
	PKG_CONFIG_PATH=$(PKG_CONFIG_PATH)

# -----------------------------------------------------------------------------

$(N_OBJ_DIR)/config.status: $(N_DEPS)
	test -d $(N_OBJ_DIR) || mkdir -p $(N_OBJ_DIR)
	$(CD) $(SOURCE_DIR)/$(NI-NEUTRINO); \
		git checkout $(NI-NEUTRINO_BRANCH)
	$(SOURCE_DIR)/$(NI-NEUTRINO)/autogen.sh
	$(CD) $(N_OBJ_DIR); \
		$(N_BUILD_ENV) \
		$(SOURCE_DIR)/$(NI-NEUTRINO)/configure \
			--host=$(TARGET) \
			--build=$(BUILD) \
			--prefix= \
			$(N_CONFIGURE_DEBUG) \
			--enable-maintainer-mode \
			--enable-silent-rules \
			\
			$(N_CONFIGURE_ADDITIONS) \
			--enable-ffmpegdec \
			--enable-flac \
			--enable-freesatepg \
			--enable-fribidi \
			--enable-giflib \
			--enable-lua \
			--enable-mdev \
			--enable-pugixml \
			\
			--with-omdb-api-key="$(N_OMDB_API_KEY)" \
			--with-shoutcast-dev-key="$(N_SHOUTCAST_DEV_KEY)" \
			--with-tmdb-dev-key="$(N_TMDB_DEV_KEY)" \
			--with-youtube-dev-key="$(N_YOUTUBE_DEV_KEY)" \
			--with-weather-dev-key="$(N_WEATHER_DEV_KEY)" \
			\
			$(N_CONFIGURE_LIBSTB-HAL) \
			--with-tremor \
			--with-target=cdk \
			--with-targetprefix= \
			--with-boxtype=$(BOXTYPE) \
			--with-boxmodel=$(BOXSERIES)

# -----------------------------------------------------------------------------

$(D)/neutrino: $(N_OBJ_DIR)/config.status
	PKG_CONFIG_PATH=$(PKG_CONFIG_PATH) \
	$(MAKE) -C $(N_OBJ_DIR) all     DESTDIR=$(TARGET_DIR)
	$(MAKE) -C $(N_OBJ_DIR) install DESTDIR=$(N_INST_DIR)
	$(MAKE) $(TARGET_DIR)/etc/init.d/start_neutrino
	$(TOUCH)

# -----------------------------------------------------------------------------

$(TARGET_DIR)/etc/init.d/start_neutrino:
	$(INSTALL_EXEC) -D $(IMAGEFILES)/scripts/start_neutrino.$(BOXTYPE) $@

# -----------------------------------------------------------------------------

LH_OBJ_DIR = $(BUILD_TMP)/$(NI-LIBSTB-HAL)

# -----------------------------------------------------------------------------

LH_DEPS  =
LH_DEPS += $(D)/ffmpeg
LH_DEPS += $(D)/openthreads

USE_GSTREAMER = no
ifeq ($(BOXSERIES), $(filter $(BOXSERIES), hd51 bre2ze4k))
  ifeq ($(USE_GSTREAMER), yes)
    LH_DEPS += $(D)/gstreamer-all
  endif
endif

# -----------------------------------------------------------------------------

LH_CONFIGURE_GSTREAMER =
ifeq ($(BOXSERIES), $(filter $(BOXSERIES), hd51 bre2ze4k))
  ifeq ($(USE_GSTREAMER), yes)
    LH_CONFIGURE_GSTREAMER += \
			--enable-gstreamer_10
  endif
endif

# -----------------------------------------------------------------------------

$(LH_OBJ_DIR)/config.status: $(LH_DEPS)
	test -d $(LH_OBJ_DIR) || mkdir -p $(LH_OBJ_DIR)
	$(SOURCE_DIR)/$(NI-LIBSTB-HAL)/autogen.sh
	$(CD) $(LH_OBJ_DIR); \
		$(N_BUILD_ENV) \
		$(SOURCE_DIR)/$(NI-LIBSTB-HAL)/configure \
			--host=$(TARGET) \
			--build=$(BUILD) \
			--prefix= \
			--enable-maintainer-mode \
			--enable-silent-rules \
			--enable-shared=no \
			\
			$(LH_CONFIGURE_GSTREAMER) \
			\
			--with-target=cdk \
			--with-boxtype=$(BOXTYPE) \
			--with-boxmodel=$(BOXSERIES)

# -----------------------------------------------------------------------------

$(D)/libstb-hal: $(LH_OBJ_DIR)/config.status
	PKG_CONFIG_PATH=$(PKG_CONFIG_PATH) \
	$(MAKE) -C $(LH_OBJ_DIR) all     DESTDIR=$(TARGET_DIR)
	$(MAKE) -C $(LH_OBJ_DIR) install DESTDIR=$(N_INST_DIR)
	$(REWRITE_LIBTOOL)/libstb-hal.la
	$(TOUCH)

# -----------------------------------------------------------------------------

neutrino-bin:
ifeq ($(CLEAN), yes)
	$(MAKE) neutrino-clean
endif
	$(MAKE) $(N_OBJ_DIR)/config.status
	PKG_CONFIG_PATH=$(PKG_CONFIG_PATH) \
	$(MAKE) -C $(N_OBJ_DIR) all DESTDIR=$(TARGET_DIR)
	$(INSTALL_EXEC) -D $(N_OBJ_DIR)/src/neutrino $(TARGET_DIR)/bin/neutrino
ifneq ($(DEBUG), yes)
	$(TARGET_STRIP) $(TARGET_DIR)/bin/neutrino
endif
	make done

# -----------------------------------------------------------------------------

neutrino-uninstall:
	-make -C $(N_OBJ_DIR) uninstall DESTDIR=$(TARGET_DIR)

neutrino-distclean:
	-make -C $(N_OBJ_DIR) distclean

neutrino-clean: neutrino-uninstall neutrino-distclean
	rm -f $(N_OBJ_DIR)/config.status
	rm -f $(D)/neutrino
	rm -f $(TARGET_DIR)/etc/init.d/start_neutrino

neutrino-clean-all: neutrino-clean
	rm -rf $(N_OBJ_DIR)

# -----------------------------------------------------------------------------

libstb-hal-uninstall:
	-make -C $(LH_OBJ_DIR) uninstall DESTDIR=$(TARGET_DIR)

libstb-hal-distclean:
	-make -C $(LH_OBJ_DIR) distclean

libstb-hal-clean: libstb-hal-uninstall libstb-hal-distclean
	rm -f $(LH_OBJ_DIR)/config.status
	rm -f $(D)/libstb-hal

libstb-hal-clean-all: libstb-hal-clean
	rm -rf $(LH_OBJ_DIR)

# -----------------------------------------------------------------------------

PHONY += neutrino-bin
PHONY += neutrino-uninstall neutrino-distclean
PHONY += neutrino-clean neutrino-clean-all

PHONY += libstb-hal-uninstall libstb-hal-distclean
PHONY += libstb-hal-clean libstb-hal-clean-all
