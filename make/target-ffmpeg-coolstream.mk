#
# makefile to build ffmpeg
#
# -----------------------------------------------------------------------------

FFMPEG_DEPS = $(D)/openssl $(D)/librtmp $(D)/libbluray $(D)/libass

# -----------------------------------------------------------------------------

ifeq ($(NI-FFMPEG_BRANCH), ni/ffmpeg/2.8)
  FFMPEG_DEPS += $(D)/libroxml
  FFMPEG_CONFIGURE_BRANCH =
else
  FFMPEG_DEPS +=  $(D)/libxml2
  FFMPEG_CONFIGURE_BRANCH =	\
			--enable-demuxer=dash \
			--enable-libxml2
endif

# -----------------------------------------------------------------------------

FFMPEG_CONFIGURE_GENERIC = \
			--prefix=/ \
			--cross-prefix=$(TARGET_CROSS) \
			--datadir=$(remove-datadir) \
			\
			--disable-doc \
			--disable-htmlpages \
			--disable-manpages \
			--disable-podpages \
			--disable-txtpages \
			\
			--disable-ffmpeg \
			--disable-ffplay \
			--disable-ffprobe \
			--disable-ffserver \
			\
			--disable-altivec \
			--disable-mmx \
			--disable-neon \
			--disable-swscale \
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
			--disable-encoders \
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
			--disable-muxers \
				--enable-muxer=mpegts \
			\
			--disable-filters \
			\
			--disable-devices \
			\
			--disable-extra-warnings \
			--disable-postproc \
			\
			--enable-bsfs \
			--enable-libass \
			--enable-libbluray \
			--enable-librtmp \
			--enable-network \
			--enable-nonfree \
			--enable-openssl \
			--enable-swresample \
			\
			--disable-debug \
			--enable-cross-compile \
			--enable-stripping \
			--disable-static \
			--enable-shared \
			\
			--target-os=linux \
			--arch=$(BOXARCH) \
			--extra-ldflags="$(TARGET_LDFLAGS)"

# -----------------------------------------------------------------------------

ifeq ($(BOXSERIES), hd1)
  FFMPEG_CONFIGURE_PLATFORM = \
			--enable-small \
			--cpu=armv6 \
			--extra-cflags="-Wno-deprecated-declarations -I$(TARGET_INCLUDE_DIR)"
endif

ifeq ($(BOXSERIES), hd2)
  FFMPEG_CONFIGURE_PLATFORM = \
			--enable-decoder=h264 \
			--enable-decoder=vc1 \
			--enable-hardcoded-tables \
			--cpu=cortex-a9 \
			--extra-cflags="-Wno-deprecated-declarations -I$(TARGET_INCLUDE_DIR) -mfpu=vfpv3-d16 -mfloat-abi=hard"
endif

# -----------------------------------------------------------------------------

$(D)/ffmpeg: $(FFMPEG_DEPS) | $(TARGET_DIR)
	$(REMOVE)/$(NI-FFMPEG)
	$(CD) $(SOURCE_DIR)/$(NI-FFMPEG); \
		git checkout $(NI-FFMPEG_BRANCH)
	tar -C $(SOURCE_DIR) -cp $(NI-FFMPEG) --exclude-vcs | tar -C $(BUILD_TMP) -x
	$(CHDIR)/$(NI-FFMPEG); \
		./configure \
			$(FFMPEG_CONFIGURE_GENERIC) \
			$(FFMPEG_CONFIGURE_PLATFORM) \
			$(FFMPEG_CONFIGURE_BRANCH) \
			; \
		$(MAKE); \
		make install DESTDIR=$(TARGET_DIR)
	$(REWRITE_PKGCONF)/libavcodec.pc
	$(REWRITE_PKGCONF)/libavdevice.pc
	$(REWRITE_PKGCONF)/libavfilter.pc
	$(REWRITE_PKGCONF)/libavformat.pc
	$(REWRITE_PKGCONF)/libavutil.pc
	$(REWRITE_PKGCONF)/libswresample.pc
	$(REMOVE)/$(NI-FFMPEG)
	$(TOUCH)
