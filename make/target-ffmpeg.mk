#
# makefile to build ffmpeg
#
# -----------------------------------------------------------------------------

FFMPEG_VERSION = 4.3.1
FFMPEG_DIR = ffmpeg-$(FFMPEG_VERSION)
FFMPEG_SOURCE = ffmpeg-$(FFMPEG_VERSION).tar.xz
FFMPEG_SITE = http://www.ffmpeg.org/releases

$(DL_DIR)/$(FFMPEG_SOURCE):
	$(DOWNLOAD) $(FFMPEG_SITE)/$(FFMPEG_SOURCE)

FFMPEG_UNPATCHED := no

FFMPEG_CONF_OPTS = \
	--prefix=$(prefix) \
	--cross-prefix=$(TARGET_CROSS) \
	--datadir=$(REMOVE_datadir) \
	\
	--disable-doc \
	--disable-htmlpages \
	--disable-manpages \
	--disable-podpages \
	--disable-txtpages \
	\
	--enable-ffprobe \
	\
	--disable-altivec \
	--disable-amd3dnow \
	--disable-amd3dnowext \
	--disable-armv5te \
	--disable-armv6 \
	--disable-armv6t2 \
	--disable-avx \
	--disable-avx2 \
	--disable-fast-unaligned \
	--disable-fma3 \
	--disable-fma4 \
	--disable-inline-asm \
	--disable-mips32r2 \
	--disable-mipsdsp \
	--disable-mipsdspr2 \
	--disable-mmx \
	--disable-mmxext \
	--disable-sse \
	--disable-sse2 \
	--disable-sse3 \
	--disable-sse4 \
	--disable-sse42 \
	--disable-ssse3 \
	--disable-vfp \
	--disable-xop \
	--disable-x86asm \
	\
	--disable-dxva2 \
	--disable-vaapi \
	--disable-vdpau \
	\
	--disable-parsers \
		--enable-parser=aac \
		--enable-parser=aac_latm \
		--enable-parser=ac3 \
		--enable-parser=dca \
		--enable-parser=dvbsub \
		--enable-parser=dvd_nav \
		--enable-parser=dvdsub \
		--enable-parser=flac \
		--enable-parser=h264 \
		--enable-parser=hevc \
		--enable-parser=mjpeg \
		--enable-parser=mpeg4video \
		--enable-parser=mpegaudio \
		--enable-parser=mpegvideo \
		--enable-parser=png \
		--enable-parser=vc1 \
		--enable-parser=vorbis \
		--enable-parser=vp8 \
		--enable-parser=vp9 \
	\
	--disable-decoders \
		--enable-decoder=aac \
		--enable-decoder=aac_latm \
		--enable-decoder=adpcm_ct \
		--enable-decoder=adpcm_g722 \
		--enable-decoder=adpcm_g726 \
		--enable-decoder=adpcm_g726le \
		--enable-decoder=adpcm_ima_amv \
		--enable-decoder=adpcm_ima_oki \
		--enable-decoder=adpcm_ima_qt \
		--enable-decoder=adpcm_ima_rad \
		--enable-decoder=adpcm_ima_wav \
		--enable-decoder=adpcm_ms \
		--enable-decoder=adpcm_sbpro_2 \
		--enable-decoder=adpcm_sbpro_3 \
		--enable-decoder=adpcm_sbpro_4 \
		--enable-decoder=adpcm_swf \
		--enable-decoder=adpcm_yamaha \
		--enable-decoder=alac \
		--enable-decoder=ape \
		--enable-decoder=ass \
		--enable-decoder=atrac1 \
		--enable-decoder=atrac3 \
		--enable-decoder=atrac3p \
		--enable-decoder=cook \
		--enable-decoder=dca \
		--enable-decoder=dsd_lsbf \
		--enable-decoder=dsd_lsbf_planar \
		--enable-decoder=dsd_msbf \
		--enable-decoder=dsd_msbf_planar \
		--enable-decoder=dvbsub \
		--enable-decoder=dvdsub \
		--enable-decoder=eac3 \
		--enable-decoder=evrc \
		--enable-decoder=flac \
		--enable-decoder=flv \
		--enable-decoder=g723_1 \
		--enable-decoder=g729 \
		--enable-decoder=gif \
		--enable-decoder=h261 \
		--enable-decoder=h263 \
		--enable-decoder=h263i \
		--enable-decoder=h264 \
		--enable-decoder=hevc \
		--enable-decoder=iac \
		--enable-decoder=imc \
		--enable-decoder=jpeg2000 \
		--enable-decoder=jpegls \
		--enable-decoder=mace3 \
		--enable-decoder=mace6 \
		--enable-decoder=metasound \
		--enable-decoder=mjpeg \
		--enable-decoder=mlp \
		--enable-decoder=movtext \
		--enable-decoder=mp1 \
		--enable-decoder=mp3 \
		--enable-decoder=mp3adu \
		--enable-decoder=mp3adufloat \
		--enable-decoder=mp3float \
		--enable-decoder=mp3on4 \
		--enable-decoder=mp3on4float \
		--enable-decoder=mpeg1video \
		--enable-decoder=mpeg2video \
		--enable-decoder=mpeg4 \
		--enable-decoder=nellymoser \
		--enable-decoder=opus \
		--enable-decoder=pcm_alaw \
		--enable-decoder=pcm_bluray \
		--enable-decoder=pcm_dvd \
		--enable-decoder=pcm_f32be \
		--enable-decoder=pcm_f32le \
		--enable-decoder=pcm_f64be \
		--enable-decoder=pcm_f64le \
		--enable-decoder=pcm_lxf \
		--enable-decoder=pcm_mulaw \
		--enable-decoder=pcm_s16be \
		--enable-decoder=pcm_s16be_planar \
		--enable-decoder=pcm_s16le \
		--enable-decoder=pcm_s16le_planar \
		--enable-decoder=pcm_s24be \
		--enable-decoder=pcm_s24daud \
		--enable-decoder=pcm_s24le \
		--enable-decoder=pcm_s24le_planar \
		--enable-decoder=pcm_s32be \
		--enable-decoder=pcm_s32le \
		--enable-decoder=pcm_s32le_planar \
		--enable-decoder=pcm_s8 \
		--enable-decoder=pcm_s8_planar \
		--enable-decoder=pcm_u16be \
		--enable-decoder=pcm_u16le \
		--enable-decoder=pcm_u24be \
		--enable-decoder=pcm_u24le \
		--enable-decoder=pcm_u32be \
		--enable-decoder=pcm_u32le \
		--enable-decoder=pcm_u8 \
		--enable-decoder=pcm_zork \
		--enable-decoder=pgssub \
		--enable-decoder=png \
		--enable-decoder=qcelp \
		--enable-decoder=qdm2 \
		--enable-decoder=ra_144 \
		--enable-decoder=ra_288 \
		--enable-decoder=ralf \
		--enable-decoder=s302m \
		--enable-decoder=shorten \
		--enable-decoder=sipr \
		--enable-decoder=sonic \
		--enable-decoder=srt \
		--enable-decoder=ssa \
		--enable-decoder=subrip \
		--enable-decoder=subviewer \
		--enable-decoder=subviewer1 \
		--enable-decoder=tak \
		--enable-decoder=text \
		--enable-decoder=truehd \
		--enable-decoder=truespeech \
		--enable-decoder=tta \
		--enable-decoder=vorbis \
		--enable-decoder=wavpack \
		--enable-decoder=wmalossless \
		--enable-decoder=wmapro \
		--enable-decoder=wmav1 \
		--enable-decoder=wmav2 \
		--enable-decoder=wmavoice \
		--enable-decoder=xsub \
	\
	--disable-encoders \
		--enable-encoder=aac \
		--enable-encoder=h261 \
		--enable-encoder=h263 \
		--enable-encoder=h263p \
		--enable-encoder=jpeg2000 \
		--enable-encoder=jpegls \
		--enable-encoder=ljpeg \
		--enable-encoder=mjpeg \
		--enable-encoder=mpeg1video \
		--enable-encoder=mpeg2video \
		--enable-encoder=mpeg4 \
		--enable-encoder=png \
		--enable-encoder=rawvideo \
	\
	--disable-demuxers \
		--enable-demuxer=aac \
		--enable-demuxer=ac3 \
		--enable-demuxer=apng \
		--enable-demuxer=ass \
		--enable-demuxer=avi \
		--enable-demuxer=dash \
		--enable-demuxer=dts \
		--enable-demuxer=ffmetadata \
		--enable-demuxer=flac \
		--enable-demuxer=flv \
		--enable-demuxer=gif \
		--enable-demuxer=h264 \
		--enable-demuxer=hls \
		--enable-demuxer=live_flv \
		--enable-demuxer=image_bmp_pipe \
		--enable-demuxer=image_jpeg_pipe \
		--enable-demuxer=image_jpegls_pipe \
		--enable-demuxer=image_png_pipe \
		--enable-demuxer=image2 \
		--enable-demuxer=image2pipe \
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
		--enable-demuxer=rawvideo \
		--enable-demuxer=realtext \
		--enable-demuxer=rm \
		--enable-demuxer=rtp \
		--enable-demuxer=rtsp \
		--enable-demuxer=srt \
		--enable-demuxer=vc1 \
		--enable-demuxer=wav \
		--enable-demuxer=webm_dash_manifest \
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
	--disable-filters \
		--enable-filter=drawtext \
		--enable-filter=overlay \
		--enable-filter=scale \
	\
	--disable-extra-warnings \
	--disable-postproc \
	\
	--enable-bsfs \
	--enable-libass \
	--enable-libbluray \
	--enable-libfreetype \
	--enable-librtmp \
	--enable-network \
	--enable-nonfree \
	--enable-openssl \
	--enable-zlib \
	\
	--disable-xlib \
	--disable-libxcb \
	--disable-libxcb-shm \
	--disable-libxcb-xfixes \
	--disable-libxcb-shape \
	\
	--disable-debug \
	--enable-cross-compile \
	--enable-stripping \
	--disable-static \
	--enable-shared \
	--disable-runtime-cpudetect \
	--enable-pic \
	--enable-pthreads \
	--enable-swresample \
	--enable-hardcoded-tables \
	\
	--target-os=linux \
	--arch=$(TARGET_ARCH) \
	--extra-ldflags="$(TARGET_LDFLAGS)"

# ffplay
FFMPEG_DEPENDENCIES += sdl2
FFMPEG_CONF_OPTS += --enable-ffplay
FFMPEG_CONF_ENV += SDL_CONFIG=$(HOST_DIR)/bin/sdl2-config

ifeq ($(TARGET_ARCH),arm)
  FFMPEG_CONF_OPTS += \
	--cpu=cortex-a15 \
	--extra-cflags="-Wno-deprecated-declarations -I$(TARGET_includedir) -mfpu=neon-vfpv4 -mfloat-abi=hard"

else ifeq ($(TARGET_ARCH),mips)
  FFMPEG_CONF_OPTS += \
	--cpu=generic \
	--extra-cflags="-Wno-deprecated-declarations -I$(TARGET_includedir)"
endif

FFMPEG_DEPENDENCIES = openssl freetype rtmpdump libbluray libass libxml2 alsa-lib

ffmpeg: $(FFMPEG_DEPENDENCIES) $(DL_DIR)/$(FFMPEG_SOURCE) | $(TARGET_DIR)
	$(REMOVE)/$(PKG_DIR)
	$(UNTAR)/$(PKG_SOURCE)
ifneq ($($(PKG)_UNPATCHED),yes)
	$(CHDIR)/$(PKG_DIR); \
		$(APPLY_PATCHES)
endif
	$(CHDIR)/$(PKG_DIR); \
		./configure $($(PKG)_CONF_OPTS); \
		$(MAKE); \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
	$(REMOVE)/$(PKG_DIR)
	$(TOUCH)
