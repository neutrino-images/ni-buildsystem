#
# ffmpeg
#

# -----------------------------------------------------------------------------

FFMPEG_VER = 3.3
FFMPEG_SOURCE = ffmpeg-$(FFMPEG_VER).tar.xz

$(ARCHIVE)/$(FFMPEG_SOURCE):
	$(WGET) http://www.ffmpeg.org/releases/$(FFMPEG_SOURCE)

# -----------------------------------------------------------------------------

FFMPEG_PATCH  = ffmpeg-$(FFMPEG_VER)-fix-hls.patch
FFMPEG_PATCH += ffmpeg-$(FFMPEG_VER)-buffer-size.patch
FFMPEG_PATCH += ffmpeg-$(FFMPEG_VER)-aac.patch
FFMPEG_PATCH += ffmpeg-$(FFMPEG_VER)-fix-edit-list-parsing.patch
# ffmpeg exteplayer3 patches
FFMPEG_PATCH += ffmpeg-$(FFMPEG_VER)-fix-mpegts.patch
FFMPEG_PATCH += ffmpeg-$(FFMPEG_VER)-allow-to-choose-rtmp-impl-at-runtime.patch
FFMPEG_PATCH += ffmpeg-$(FFMPEG_VER)-add-dash-demux.patch
FFMPEG_PATCH += ffmpeg-$(FFMPEG_VER)-hls-replace-key-uri.patch
FFMPEG_PATCH += ffmpeg-$(FFMPEG_VER)-chunked_transfer_fix_eof.patch

# -----------------------------------------------------------------------------

FFMPEG_DEPS = $(D)/openssl $(D)/librtmp $(D)/libbluray $(D)/libass $(D)/libxml2

# -----------------------------------------------------------------------------

FFMPEG_CONFIGURE_GENERIC = \
			--prefix=/ \
			--cross-prefix=$(TARGET)- \
			--mandir=/.remove \
			--datadir=/.remove \
			--docdir=/.remove \
			\
			--disable-doc \
			--disable-htmlpages \
			--disable-manpages \
			--disable-podpages \
			--disable-txtpages \
			\
			--disable-ffplay \
			--disable-ffserver \
			--disable-ffprobe \
			\
			--disable-altivec \
			--disable-mmx \
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
				--enable-decoder=ass \
				--enable-decoder=dca \
				--enable-decoder=dvbsub \
				--enable-decoder=dvdsub \
				--enable-decoder=flac \
				--enable-decoder=mjpeg \
				--enable-decoder=movtext \
				--enable-decoder=mp3 \
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
				--enable-encoder=mpeg2video \
			\
			--disable-demuxers \
				--enable-demuxer=aac \
				--enable-demuxer=ac3 \
				--enable-demuxer=ass \
				--enable-demuxer=avi \
				--enable-demuxer=dash \
				--enable-demuxer=dts \
				--enable-demuxer=flac \
				--enable-demuxer=flv \
				--enable-demuxer=hls \
				--enable-demuxer=image2 \
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
				--enable-demuxer=rtsp \
				--enable-demuxer=srt \
				--enable-demuxer=vc1 \
				--enable-demuxer=wav \
			\
			--disable-muxers \
				--enable-muxer=mpegts \
				--enable-muxer=mpeg2video \
			\
			--disable-filters \
				--enable-filter=scale \
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
			--enable-hardcoded-tables \
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

FFMPEG_CONFIGURE_PLATFORM = \
			--cpu=cortex-a15 \
			--extra-cflags="-Wno-deprecated-declarations -I$(TARGET_INCLUDE_DIR) -mfpu=neon-vfpv4 -mfloat-abi=hard"

# -----------------------------------------------------------------------------

$(D)/ffmpeg: $(FFMPEG_DEPS) $(ARCHIVE)/$(FFMPEG_SOURCE) | $(TARGET_DIR)
	$(REMOVE)/ffmpeg-$(FFMPEG_VER)
	$(UNTAR)/$(FFMPEG_SOURCE)
	set -e; cd $(BUILD_TMP)/ffmpeg-$(FFMPEG_VER); \
		$(call apply_patches, $(FFMPEG_PATCH)); \
		./configure \
			$(FFMPEG_CONFIGURE_GENERIC) \
			$(FFMPEG_CONFIGURE_PLATFORM) \
			; \
		$(MAKE); \
		make install DESTDIR=$(TARGET_DIR)
	$(REWRITE_PKGCONF) $(PKG_CONFIG_PATH)/libavcodec.pc
	$(REWRITE_PKGCONF) $(PKG_CONFIG_PATH)/libavdevice.pc
	$(REWRITE_PKGCONF) $(PKG_CONFIG_PATH)/libavfilter.pc
	$(REWRITE_PKGCONF) $(PKG_CONFIG_PATH)/libavformat.pc
	$(REWRITE_PKGCONF) $(PKG_CONFIG_PATH)/libavutil.pc
	$(REWRITE_PKGCONF) $(PKG_CONFIG_PATH)/libswresample.pc
	$(REWRITE_PKGCONF) $(PKG_CONFIG_PATH)/libswscale.pc
	$(REMOVE)/ffmpeg-$(FFMPEG_VER)
	touch $@
