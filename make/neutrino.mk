#
# makefile to build Neutrino
#
# -----------------------------------------------------------------------------

YOUTUBE_DEV_KEY ?= AIzaSyBLdZe7M3rpNMZqSj-3IEvjbb2hATWJIdM
OMDB_API_KEY ?= 20711f9e
TMDB_DEV_KEY ?= 7270f1b571c4ecbb5b204ddb7f8939b1
SHOUTCAST_DEV_KEY ?= fa1669MuiRPorUBw

N_DEPS = libcurl freetype libjpeg giflib ffmpeg openthreads openssl libdvbsi ntp libsigc++ luaposix pugixml libfribidi zlib

LH_DEPS = ffmpeg openthreads

ifeq ($(BOXTYPE)-$(HAS_LIBCS), coolstream-yes)
	N_DEPS += libcoolstream
endif

ifeq ($(USE_LIBSTB-HAL), yes)
	N_DEPS += libstb-hal
endif

USE_GSTREAMER = no
ifeq ($(BOXSERIES), hd51)
  ifeq ($(USE_GSTREAMER), yes)
	LH_DEPS += gst_plugins_dvbmediasink
  endif
endif

# uncomment next line to build neutrino without --enable-ffmpegdec
#N_DEPS += libvorbisidec libid3tag libmad libFLAC

N_CFLAGS = -Wall -W -Wshadow -D__STDC_CONSTANT_MACROS -DENABLE_FREESATEPG
ifeq ($(BOXSERIES), hd1)
	N_CFLAGS += -DCPU_FREQ
endif
ifeq ($(BOXSERIES), hd2)
	N_CFLAGS += -DFB_HW_ACCELERATION
endif

ifeq ($(BOXSERIES), hd51)
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

N_LDFLAGS = -lcrypto -ldl -lz $(CORTEX-STRINGS) -L$(TARGET_LIB_DIR)
ifeq ($(DEBUG), yes)
	N_LDFLAGS += -Wl,-rpath-link,$(TARGET_LIB_DIR)
else
	N_LDFLAGS += -Wl,-O1 -Wl,-rpath-link,$(TARGET_LIB_DIR) $(TARGET_EXTRA_LDFLAGS)
endif

N_CONFIGURE_DEBUG =
ifeq ($(HAS_LIBCS), yes)
  ifeq ($(DEBUG), yes)
	N_CONFIGURE_DEBUG += \
		--enable-libcoolstream-static \
		--with-libcoolstream-static-dir=$(TARGET_LIB_DIR)
  endif
endif

N_CONFIGURE_LIBSTB-HAL =
ifeq ($(USE_LIBSTB-HAL), yes)
	N_CONFIGURE_LIBSTB-HAL += \
		--with-stb-hal-includes=$(LH_OBJDIR)/include \
		--with-stb-hal-build=$(LH_OBJDIR)
endif

N_CONFIGURE_ADDITIONS =
ifeq ($(BOXSERIES), hd51)
	N_CONFIGURE_ADDITIONS += \
		--enable-reschange
endif

N_BUILDENV = \
	CC=$(TARGET)-gcc \
	CXX=$(TARGET)-g++ \
	LD=$(TARGET)-ld \
	NM=$(TARGET)-nm \
	AR=$(TARGET)-ar \
	AS=$(TARGET)-as \
	LDD=$(TARGET)-ldd \
	RANLIB=$(TARGET)-ranlib \
	STRIP=$(TARGET)-strip \
	OBJCOPY=$(TARGET)-objcopy \
	OBJDUMP=$(TARGET)-objdump \
	READELF=$(TARGET)-readelf \
	CFLAGS="$(N_CFLAGS)" \
	CPPFLAGS="$(N_CFLAGS)" \
	CXXFLAGS="$(N_CFLAGS)" \
	LDFLAGS="$(N_LDFLAGS)"

# -----------------------------------------------------------------------------

N_OBJDIR = $(BUILD_TMP)/$(NI_NEUTRINO)
LH_OBJDIR = $(BUILD_TMP)/$(NI_LIBSTB-HAL-NEXT)

$(N_OBJDIR)/config.status: $(N_DEPS) $(MAKE_DIR)/neutrino.mk
	test -d $(N_OBJDIR) || mkdir -p $(N_OBJDIR)
	cd $(SOURCE_DIR)/$(NI_NEUTRINO) && \
		git checkout $(NI_NEUTRINO_BRANCH)
	$(SOURCE_DIR)/$(NI_NEUTRINO)/autogen.sh
	pushd $(N_OBJDIR) && \
		export PKG_CONFIG=$(PKG_CONFIG) && \
		export PKG_CONFIG_PATH=$(PKG_CONFIG_PATH) && \
		$(N_BUILDENV) \
		$(SOURCE_DIR)/$(NI_NEUTRINO)/configure \
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
			--enable-fribidi \
			--enable-giflib \
			--enable-lua \
			--enable-mdev \
			--enable-pip \
			--enable-pugixml \
			\
			--with-youtube-dev-key="$(YOUTUBE_DEV_KEY)" \
			--with-omdb-api-key="$(OMDB_API_KEY)" \
			--with-tmdb-dev-key="$(TMDB_DEV_KEY)" \
			--with-shoutcast-dev-key="$(SHOUTCAST_DEV_KEY)" \
			\
			$(N_CONFIGURE_LIBSTB-HAL) \
			--with-tremor \
			--with-target=cdk \
			--with-targetprefix= \
			--with-boxtype=$(BOXTYPE) \
			--with-boxmodel=$(BOXSERIES)

LH_CONFIGURE_GSTREAMER =
ifeq ($(BOXSERIES), hd51)
  ifeq ($(USE_GSTREAMER), yes)
	LH_CONFIGURE_GSTREAMER += \
			--enable-gstreamer_10
  endif
endif

$(LH_OBJDIR)/config.status: $(LH_DEPS)
	rm -rf $(LH_OBJDIR)
	tar -C $(SOURCE_DIR) -cp $(NI_LIBSTB-HAL-NEXT) --exclude-vcs | tar -C $(BUILD_TMP) -x
	pushd $(LH_OBJDIR) && \
		./autogen.sh && \
		\
		export PKG_CONFIG=$(PKG_CONFIG) && \
		export PKG_CONFIG_PATH=$(PKG_CONFIG_PATH) && \
		$(N_BUILDENV) \
		./configure \
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

NEUTRINO_INST_DIR ?= $(TARGET_DIR)
$(D)/neutrino: $(N_OBJDIR)/config.status
	PKG_CONFIG_PATH=$(PKG_CONFIG_PATH) \
	$(MAKE) -C $(N_OBJDIR) all     DESTDIR=$(TARGET_DIR)
	$(MAKE) -C $(N_OBJDIR) install DESTDIR=$(NEUTRINO_INST_DIR)
	$(TOUCH)

$(D)/libstb-hal: $(LH_OBJDIR)/config.status
	PKG_CONFIG_PATH=$(PKG_CONFIG_PATH) \
	$(MAKE) -C $(LH_OBJDIR) all     DESTDIR=$(TARGET_DIR)
	$(MAKE) -C $(LH_OBJDIR) install DESTDIR=$(NEUTRINO_INST_DIR)
	$(REWRITE_LIBTOOL)/libstb-hal.la
	$(TOUCH)

# -----------------------------------------------------------------------------

neutrino-bin:
ifeq ($(CLEAN), yes)
	$(MAKE) neutrino-clean
endif
	$(MAKE) $(N_OBJDIR)/config.status
	PKG_CONFIG_PATH=$(PKG_CONFIG_PATH) \
	$(MAKE) -C $(N_OBJDIR) all DESTDIR=$(TARGET_DIR)
	install -D -m 0755 $(N_OBJDIR)/src/neutrino $(TARGET_DIR)/bin/neutrino
ifneq ($(DEBUG), yes)
	$(TARGET)-strip $(TARGET_DIR)/bin/neutrino
endif
	make done

# -----------------------------------------------------------------------------

neutrino-clean:
	-make -C $(N_OBJDIR) uninstall
	-make -C $(N_OBJDIR) distclean
	rm -f $(N_OBJDIR)/config.status
	rm -f $(D)/neutrino

neutrino-clean-all: neutrino-clean
	rm -rf $(N_OBJDIR)

libstb-hal-clean:
	-make -C $(LH_OBJDIR) clean
	rm -f $(LH_OBJDIR)/config.status
	rm -f $(D)/libstb-hal

libstb-hal-clean-all: libstb-hal-clean
	rm -rf $(LH_OBJDIR)

# -----------------------------------------------------------------------------

PHONY += neutrino-bin
PHONY += neutrino-clean neutrino-clean-all
PHONY += libstb-hal-clean libstb-hal-clean-all
