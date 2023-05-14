################################################################################
#
# ffmpeg2
#
################################################################################

FFMPEG2_VERSION = $(BS_PACKAGE_FFMPEG2_BRANCH)
FFMPEG2_DIR = $(NI_FFMPEG)
FFMPEG2_SOURCE = $(NI_FFMPEG)
FFMPEG2_SITE = https://github.com/neutrino-images
FFMPEG2_SITE_METHOD = ni-git

FFMPEG2_DEPENDENCIES = openssl rtmpdump libbluray libass

FFMPEG2_CONF_OPTS = \
	--disable-ffplay \
	--disable-ffprobe \
	--disable-ffserver \
	\
	--disable-doc \
	--disable-htmlpages \
	--disable-manpages \
	--disable-podpages \
	--disable-txtpages \
	\
	--disable-altivec \
	--disable-mmx \
	--disable-neon \
	--disable-swscale \
	\
	--disable-muxers \
	--enable-muxer=apng \
	--enable-muxer=flac \
	--enable-muxer=h261 \
	--enable-muxer=h263 \
	--enable-muxer=h264 \
	--enable-muxer=hevc \
	--enable-muxer=image2 \
	--enable-muxer=image2pipe \
	--enable-muxer=m4v \
	--enable-muxer=matroska \
	--enable-muxer=mjpeg \
	--enable-muxer=mp3 \
	--enable-muxer=mp4 \
	--enable-muxer=mpeg1video \
	--enable-muxer=mpeg2video \
	--enable-muxer=mpegts \
	--enable-muxer=ogg \
	\
	--disable-parsers \
	--enable-parser=aac \
	--enable-parser=aac_latm \
	--enable-parser=ac3 \
	--enable-parser=dca \
	--enable-parser=dvbsub \
	--enable-parser=dvdsub \
	--enable-parser=flac \
	--enable-parser=h264 \
	--enable-parser=mjpeg \
	--enable-parser=mpeg4video \
	--enable-parser=mpegaudio \
	--enable-parser=mpegvideo \
	--enable-parser=vc1 \
	--enable-parser=vorbis \
	\
	--disable-encoders \
	\
	--disable-decoders \
	--enable-decoder=aac \
	--enable-decoder=aac_latm \
	--enable-decoder=ass \
	--enable-decoder=adpcm_ms \
	--enable-decoder=dca \
	--enable-decoder=dvbsub \
	--enable-decoder=dvdsub \
	--enable-decoder=flac \
	--enable-decoder=flv \
	--enable-decoder=gif \
	--enable-decoder=mjpeg \
	--enable-decoder=movtext \
	--enable-decoder=mp3 \
	--enable-decoder=mp3adu \
	--enable-decoder=mp3adufloat \
	--enable-decoder=mp3float \
	--enable-decoder=mp3on4 \
	--enable-decoder=mp3on4float \
	--enable-decoder=pcm_s16le \
	--enable-decoder=pcm_s16le_planar \
	--enable-decoder=pgssub \
	--enable-decoder=srt \
	--enable-decoder=ssa \
	--enable-decoder=subrip \
	--enable-decoder=subviewer \
	--enable-decoder=subviewer1 \
	--enable-decoder=text \
	--enable-decoder=vorbis \
	--enable-decoder=xsub \
	\
	--disable-demuxers \
	--enable-demuxer=aac \
	--enable-demuxer=ac3 \
	--enable-demuxer=ass \
	--enable-demuxer=avi \
	--enable-demuxer=dts \
	--enable-demuxer=flac \
	--enable-demuxer=flv \
	--enable-demuxer=gif \
	--enable-demuxer=hds \
	--enable-demuxer=hls \
	--enable-demuxer=live_flv \
	--enable-demuxer=m4v \
	--enable-demuxer=matroska \
	--enable-demuxer=mjpeg \
	--enable-demuxer=mov \
	--enable-demuxer=mp3 \
	--enable-demuxer=mpegps \
	--enable-demuxer=mpegts \
	--enable-demuxer=mpegtsraw \
	--enable-demuxer=mpegvideo \
	--enable-demuxer=mpjpeg \
	--enable-demuxer=ogg \
	--enable-demuxer=pcm_s16be \
	--enable-demuxer=pcm_s16le \
	--enable-demuxer=rm \
	--enable-demuxer=rtp \
	--enable-demuxer=rtsp \
	--enable-demuxer=srt \
	--enable-demuxer=vc1 \
	--enable-demuxer=wav \
	\
	--disable-filters \
	\
	--disable-devices \
	\
	--enable-bsfs \
	--enable-libass \
	--enable-libbluray \
	--enable-librtmp \
	--enable-network \
	--enable-nonfree \
	--enable-openssl \
	--enable-swresample

ifeq ($(BS_PACKAGE_FFMPEG2_BRANCH),ni/ffmpeg/2.8)
  FFMPEG2_DEPENDENCIES += libroxml
else
  FFMPEG2_DEPENDENCIES +=  libxml2
  FFMPEG2_CONF_OPTS += \
	--enable-demuxer=dash \
	--enable-libxml2
endif

ifeq ($(BOXSERIES),hd1)
  FFMPEG2_CONF_OPTS += \
	--disable-ffmpeg \
	\
	--enable-small \
	\
	--cpu=armv6 \
	--extra-cflags="-Wno-deprecated-declarations -I$(TARGET_includedir)"
endif

ifeq ($(BOXSERIES),hd2)
  FFMPEG2_CONF_OPTS += \
	--enable-decoder=h264 \
	--enable-decoder=vc1 \
	--enable-hardcoded-tables \
	\
	--cpu=cortex-a9 \
	--extra-cflags="-Wno-deprecated-declarations -I$(TARGET_includedir) -mfpu=vfpv3-d16 -mfloat-abi=hard"
endif

FFMPEG2_CONF_OPTS += \
	--prefix=$(prefix) \
	--datadir=$(REMOVE_datadir) \
	--enable-cross-compile \
	--cross-prefix=$(TARGET_CROSS) \
	--arch=$(TARGET_ARCH) \
	--target-os=linux \
	--disable-debug \
	--disable-stripping \
	--disable-static \
	--enable-shared \
	--disable-extra-warnings \
	--disable-postproc \
	--pkg-config="$(PKG_CONFIG)" \
	--extra-ldflags="$(TARGET_LDFLAGS)"

define FFMPEG2_CONFIGURE_CMDS
	$(CHDIR)/$($(PKG)_DIR); \
		$($(PKG)_CONF_ENV) ./configure $($(PKG)_CONF_OPTS)
endef

ffmpeg2: | $(TARGET_DIR)
	$(call autotools-package)
