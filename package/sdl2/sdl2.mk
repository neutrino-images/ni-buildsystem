################################################################################
#
# sdl2
#
################################################################################

SDL2_VERSION = 2.0.14
SDL2_DIR = SDL2-$(SDL2_VERSION)
SDL2_SOURCE = SDL2-$(SDL2_VERSION).tar.gz
SDL2_SITE = http://www.libsdl.org/release

$(DL_DIR)/$(SDL2_SOURCE):
	$(download) $(SDL2_SITE)/$(SDL2_SOURCE)

SDL2_DEPENDENCIES = alsa-lib

SDL2_CONFIG_SCRIPTS = sdl2-config

SDL2_CONF_OPTS += \
	--datarootdir=$(REMOVE_datarootdir) \
	--enable-static \
	--disable-3dnow \
	--disable-arts \
	--disable-dbus \
	--disable-esd \
	--disable-input-tslib \
	--disable-libudev \
	--disable-pulseaudio \
	--disable-sse \
	--disable-video-directfb \
	--disable-video-kmsdrm \
	--disable-video-opengl \
	--disable-video-rpi \
	--disable-video-wayland \
	--disable-video-x11 \
	--enable-alsa \
	--enable-video-opengles \
	--without-x

sdl2: $(SDL2_DEPENDENCIES) $(DL_DIR)/$(SDL2_SOURCE) | $(TARGET_DIR)
	$(call autotools-package)
	-rm -r $(TARGET_libdir)/cmake
