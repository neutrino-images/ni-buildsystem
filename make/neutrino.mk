# makefile to build NEUTRINO

NEUTRINO_DEPS = libcurl freetype libjpeg giflib ffmpeg openthreads openssl libdvbsi ntp libsigc++ luaposix pugixml libfribidi

ifeq ($(BOXTYPE)-$(HAS_LIBCS), coolstream-yes)
	NEUTRINO_DEPS += libcoolstream
endif
ifeq ($(USE_LIBSTB-HAL), yes)
	NEUTRINO_DEPS += libstb-hal
endif

ifeq ($(BOXSERIES), ax)
	NEUTRINO_DEPS += $(D)/gst_plugins_dvbmediasink
endif

# uncomment next line to build neutrino without --enable-ffmpegdec
#NEUTRINO_DEPS += libvorbisidec libid3tag libmad libFLAC

N_CFLAGS = -Wall -W -Wshadow -D__STDC_CONSTANT_MACROS -DENABLE_FREESATEPG
ifeq ($(BOXSERIES), hd1)
	N_CFLAGS += -DCPU_FREQ
endif
ifeq ($(BOXSERIES), hd2)
	N_CFLAGS += -DFB_HW_ACCELERATION
endif
ifeq ($(BOXSERIES), ax)
	N_CFLAGS += $(shell $(PKG_CONFIG) --cflags --libs gstreamer-1.0)
	N_CFLAGS += $(shell $(PKG_CONFIG) --cflags --libs gstreamer-audio-1.0)
	N_CFLAGS += $(shell $(PKG_CONFIG) --cflags --libs gstreamer-video-1.0)
	N_CFLAGS += $(shell $(PKG_CONFIG) --cflags --libs glib-2.0)
endif

ifeq ($(DEBUG), yes)
	N_CFLAGS += -ggdb3 -rdynamic -I$(TARGETINCLUDE)
else
	N_CFLAGS += $(TARGET_CFLAGS)
endif

N_LDFLAGS = -lcrypto -ldl -lz $(CORTEX-STRINGS) -L$(TARGETLIB)
ifeq ($(DEBUG), yes)
	N_LDFLAGS += -Wl,-rpath-link,$(TARGETLIB)
else
	N_LDFLAGS += -Wl,-O1 -Wl,-rpath-link,$(TARGETLIB) $(TARGET_EXTRA_LDFLAGS)
endif

N_CONFIGURE_DEBUG =
ifeq ($(HAS_LIBCS), yes)
ifeq ($(DEBUG), yes)
	N_CONFIGURE_DEBUG += \
		--enable-libcoolstream-static \
		--with-libcoolstream-static-dir=$(TARGETLIB)
endif
endif

N_CONFIGURE_LIBSTB-HAL =
ifeq ($(USE_LIBSTB-HAL), yes)
	N_CONFIGURE_LIBSTB-HAL += \
		--with-stb-hal-includes=$(LH_OBJDIR)/include \
		--with-stb-hal-build=$(LH_OBJDIR)
endif

N_CONFIGURE_ADDITIONS =
ifeq ($(BOXSERIES), ax)
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

# finally we can build outside of the source directory
N_OBJDIR = $(BUILD_TMP)/$(FLAVOUR)
LH_OBJDIR = $(BUILD_TMP)/libstb-hal

$(N_OBJDIR)/config.status: $(NEUTRINO_DEPS) $(MAKE_DIR)/neutrino.mk
	test -d $(N_OBJDIR) || mkdir -p $(N_OBJDIR)
ifeq ($(ORIGINAL), yes)
	cd $(N_HD_SOURCE) && \
		git checkout $(TUXBOX_REMOTE_REPO)/$(TUXBOX_NEUTRINO_BRANCH)
else ifeq ($(FLAVOUR), ni-neutrino-hd)
	cd $(N_HD_SOURCE) && \
		git checkout $(NI_NEUTRINO_BRANCH)
endif
	$(N_HD_SOURCE)/autogen.sh
	pushd $(N_OBJDIR) && \
		test -e version.h || touch version.h && \
		export PKG_CONFIG=$(PKG_CONFIG) && \
		export PKG_CONFIG_PATH=$(PKG_CONFIG_PATH) && \
		$(N_BUILDENV) \
		$(N_HD_SOURCE)/configure \
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
			$(N_CONFIGURE_LIBSTB-HAL) \
			--with-tremor \
			--with-target=cdk \
			--with-targetprefix= \
			--with-boxtype=$(BOXTYPE) \
			--with-boxmodel=$(BOXSERIES)

$(LH_OBJDIR)/config.status: $(NEUTRINO_DEPS)
	# let's use tango's libstb-hal until we have ported the relevant stuff
	rm -rf $(LH_OBJDIR)
	git clone https://github.com/TangoCash/libstb-hal-cst-next.git $(LH_OBJDIR)
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
			--with-target=cdk \
			--with-boxtype=armbox

NEUTRINO_INST_DIR ?= $(TARGETPREFIX)
$(D)/neutrino: $(N_OBJDIR)/config.status
	PKG_CONFIG_PATH=$(PKG_CONFIG_PATH) \
	$(MAKE) -C $(N_OBJDIR) all     DESTDIR=$(TARGETPREFIX)
	$(MAKE) -C $(N_OBJDIR) install DESTDIR=$(NEUTRINO_INST_DIR)
	make $(TARGETPREFIX)/.version
	touch $@

$(D)/libstb-hal: $(LH_OBJDIR)/config.status
	PKG_CONFIG_PATH=$(PKG_CONFIG_PATH) \
	$(MAKE) -C $(LH_OBJDIR) all     DESTDIR=$(TARGETPREFIX)
	$(MAKE) -C $(LH_OBJDIR) install DESTDIR=$(NEUTRINO_INST_DIR)
	$(REWRITE_LIBTOOL)/libstb-hal.la
	touch $@

neutrino-bin:
ifeq ($(CLEAN), yes)
	$(MAKE) neutrino-clean
endif
	$(MAKE) $(N_OBJDIR)/config.status
	PKG_CONFIG_PATH=$(PKG_CONFIG_PATH) \
	$(MAKE) -C $(N_OBJDIR) all DESTDIR=$(TARGETPREFIX)
	install -D -m 755 $(N_OBJDIR)/src/neutrino $(TARGETPREFIX)/bin/neutrino
ifneq ($(DEBUG), yes)
	$(TARGET)-strip $(TARGETPREFIX)/bin/neutrino
endif
	make done

neutrino-clean:
	-make -C $(N_OBJDIR) uninstall
	-make -C $(N_OBJDIR) distclean
	-rm $(N_OBJDIR)/config.status
	-rm $(D)/neutrino

neutrino-clean-all: neutrino-clean
	-rm -r $(N_OBJDIR)

PHONY += neutrino-clean
