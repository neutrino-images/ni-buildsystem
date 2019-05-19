#
# makefile to build gstreamer and all it's dependencies
#
# -----------------------------------------------------------------------------

gstreamer-all: \
	$(D)/gstreamer \
	$(D)/gst-plugins-base \
	$(D)/gst-plugins-good \
	$(D)/gst-plugins-bad \
	$(D)/gst-plugins-ugly \
	$(D)/gst-plugin-subsink \
	$(D)/gst-plugin-dvbmediasink

# -----------------------------------------------------------------------------

# change to activate debug
GSTREAMER_DEBUG = yes

ifeq ($(GSTREAMER_DEBUG), yes)
  GST_MAIN_CONFIG_DEBUG   = --enable-gst-debug
  GST_PLUGIN_CONFIG_DEBUG = --enable-debug
else
  GST_MAIN_CONFIG_DEBUG   = --disable-gst-debug
  GST_PLUGIN_CONFIG_DEBUG = --disable-debug
endif

# -----------------------------------------------------------------------------

GSTREAMER_VER = 1.14.4
GSTREAMER_SOURCE = gstreamer-$(GSTREAMER_VER).tar.xz

$(ARCHIVE)/$(GSTREAMER_SOURCE):
	$(WGET) https://gstreamer.freedesktop.org/src/gstreamer/$(GSTREAMER_SOURCE)

GSTREAMER_PATCH  = gstreamer-$(GSTREAMER_VER)-revert-use-new-gst-adapter-get-buffer.patch

$(D)/gstreamer: $(D)/libglib2 $(D)/libxml2 $(D)/glib-networking $(ARCHIVE)/$(GSTREAMER_SOURCE)
	$(REMOVE)/gstreamer-$(GSTREAMER_VER)
	$(UNTAR)/$(GSTREAMER_SOURCE)
	$(CHDIR)/gstreamer-$(GSTREAMER_VER); \
		$(call apply_patches, $(GSTREAMER_PATCH)); \
		./autogen.sh --noconfigure; \
		$(CONFIGURE) \
			--prefix= \
			--libexecdir=/lib \
			--datarootdir=/.remove \
			--enable-silent-rules \
			$(GST_PLUGIN_CONFIG_DEBUG) \
			--disable-tests \
			--disable-valgrind \
			--disable-gst-tracer-hooks \
			--disable-dependency-tracking \
			--disable-examples \
			--disable-check \
			$(GST_MAIN_CONFIG_DEBUG) \
			--disable-benchmarks \
			--disable-gtk-doc \
			--disable-gtk-doc-html \
			--disable-gtk-doc-pdf \
			--enable-introspection=no \
			ac_cv_header_valgrind_valgrind_h=no \
			ac_cv_header_sys_poll_h=no \
			; \
		$(MAKE); \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
	$(REWRITE_PKGCONF) $(PKG_CONFIG_PATH)/gstreamer-1.0.pc
	$(REWRITE_PKGCONF) $(PKG_CONFIG_PATH)/gstreamer-base-1.0.pc
	$(REWRITE_PKGCONF) $(PKG_CONFIG_PATH)/gstreamer-controller-1.0.pc
	$(REWRITE_PKGCONF) $(PKG_CONFIG_PATH)/gstreamer-net-1.0.pc
	$(REWRITE_LIBTOOL)/libgstreamer-1.0.la
	$(REWRITE_LIBTOOL)/libgstbase-1.0.la
	$(REWRITE_LIBTOOL)/libgstcontroller-1.0.la
	$(REWRITE_LIBTOOL)/libgstnet-1.0.la
	$(REWRITE_LIBTOOLDEP)/libgstbase-1.0.la
	$(REWRITE_LIBTOOLDEP)/libgstcontroller-1.0.la
	$(REWRITE_LIBTOOLDEP)/libgstnet-1.0.la
	$(REMOVE)/gstreamer-$(GSTREAMER_VER)
	$(TOUCH)

# -----------------------------------------------------------------------------

GST_PLUGINS_BASE_VER = $(GSTREAMER_VER)
GST_PLUGINS_BASE_SOURCE = gst-plugins-base-$(GST_PLUGINS_BASE_VER).tar.xz

$(ARCHIVE)/$(GST_PLUGINS_BASE_SOURCE):
	$(WGET) https://gstreamer.freedesktop.org/src/gst-plugins-base/$(GST_PLUGINS_BASE_SOURCE)

GST_PLUGINS_BASE_PATCH  = gst-plugins-base-$(GST_PLUGINS_BASE_VER)-0003-riff-add-missing-include-directories-when-calling-in.patch
#GST_PLUGINS_BASE_PATCH += gst-plugins-base-$(GST_PLUGINS_BASE_VER)-0004-rtsp-drop-incorrect-reference-to-gstreamer-sdp-in-Ma.patch
GST_PLUGINS_BASE_PATCH += gst-plugins-base-$(GST_PLUGINS_BASE_VER)-get-caps-from-src-pad-when-query-caps.patch
GST_PLUGINS_BASE_PATCH += gst-plugins-base-$(GST_PLUGINS_BASE_VER)-0004-subparse-set-need_segment-after-sink-pad-received-GS.patch
GST_PLUGINS_BASE_PATCH += gst-plugins-base-$(GST_PLUGINS_BASE_VER)-make-gio_unix_2_0-dependency-configurable.patch
GST_PLUGINS_BASE_PATCH += gst-plugins-base-$(GST_PLUGINS_BASE_VER)-0003-riff-media-added-fourcc-to-all-ffmpeg-mpeg4-video-caps.patch

$(D)/gst-plugins-base: $(ARCHIVE)/$(GST_PLUGINS_BASE_SOURCE) $(D)/gstreamer $(D)/zlib $(D)/libglib2 $(D)/orc $(D)/alsa-lib $(D)/libogg $(D)/libvorbisidec | $(TARGET_DIR)
	$(REMOVE)/gst-plugins-base-$(GST_PLUGINS_BASE_VER)
	$(UNTAR)/$(GST_PLUGINS_BASE_SOURCE)
	$(CHDIR)/gst-plugins-base-$(GST_PLUGINS_BASE_VER); \
		$(call apply_patches, $(GST_PLUGINS_BASE_PATCH)); \
		./autogen.sh --noconfigure; \
		$(CONFIGURE) \
			--prefix= \
			--datarootdir=/.remove \
			--enable-silent-rules \
			--disable-valgrind \
			$(GST_PLUGIN_CONFIG_DEBUG) \
			--disable-examples \
			--disable-gtk-doc-html \
			; \
		$(MAKE); \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
	for i in `cd $(TARGET_LIB_DIR)/gstreamer-1.0; echo *.la`; do \
		$(REWRITE_LIBTOOL)/gstreamer-1.0/$$i; \
	done
	$(REWRITE_PKGCONF) $(PKG_CONFIG_PATH)/gstreamer-allocators-1.0.pc
	$(REWRITE_PKGCONF) $(PKG_CONFIG_PATH)/gstreamer-app-1.0.pc
	$(REWRITE_PKGCONF) $(PKG_CONFIG_PATH)/gstreamer-audio-1.0.pc
	$(REWRITE_PKGCONF) $(PKG_CONFIG_PATH)/gstreamer-fft-1.0.pc
	$(REWRITE_PKGCONF) $(PKG_CONFIG_PATH)/gstreamer-pbutils-1.0.pc
	$(REWRITE_PKGCONF) $(PKG_CONFIG_PATH)/gstreamer-riff-1.0.pc
	$(REWRITE_PKGCONF) $(PKG_CONFIG_PATH)/gstreamer-rtp-1.0.pc
	$(REWRITE_PKGCONF) $(PKG_CONFIG_PATH)/gstreamer-rtsp-1.0.pc
	$(REWRITE_PKGCONF) $(PKG_CONFIG_PATH)/gstreamer-sdp-1.0.pc
	$(REWRITE_PKGCONF) $(PKG_CONFIG_PATH)/gstreamer-tag-1.0.pc
	$(REWRITE_PKGCONF) $(PKG_CONFIG_PATH)/gstreamer-video-1.0.pc
	$(REWRITE_PKGCONF) $(PKG_CONFIG_PATH)/gstreamer-plugins-base-1.0.pc
	$(REWRITE_LIBTOOL)/libgstallocators-1.0.la
	$(REWRITE_LIBTOOL)/libgstapp-1.0.la
	$(REWRITE_LIBTOOL)/libgstaudio-1.0.la
	$(REWRITE_LIBTOOL)/libgstfft-1.0.la
	$(REWRITE_LIBTOOL)/libgstpbutils-1.0.la
	$(REWRITE_LIBTOOL)/libgstriff-1.0.la
	$(REWRITE_LIBTOOL)/libgstrtp-1.0.la
	$(REWRITE_LIBTOOL)/libgstrtsp-1.0.la
	$(REWRITE_LIBTOOL)/libgstsdp-1.0.la
	$(REWRITE_LIBTOOL)/libgsttag-1.0.la
	$(REWRITE_LIBTOOL)/libgstvideo-1.0.la
	$(REWRITE_LIBTOOLDEP)/libgstallocators-1.0.la
	$(REWRITE_LIBTOOLDEP)/libgstapp-1.0.la
	$(REWRITE_LIBTOOLDEP)/libgstaudio-1.0.la
	$(REWRITE_LIBTOOLDEP)/libgstfft-1.0.la
	$(REWRITE_LIBTOOLDEP)/libgstpbutils-1.0.la
	$(REWRITE_LIBTOOLDEP)/libgstriff-1.0.la
	$(REWRITE_LIBTOOLDEP)/libgstrtp-1.0.la
	$(REWRITE_LIBTOOLDEP)/libgstrtsp-1.0.la
	$(REWRITE_LIBTOOLDEP)/libgstsdp-1.0.la
	$(REWRITE_LIBTOOLDEP)/libgsttag-1.0.la
	$(REWRITE_LIBTOOLDEP)/libgstvideo-1.0.la
	$(REMOVE)/gst-plugins-base-$(GST_PLUGINS_BASE_VER)
	$(TOUCH)

# -----------------------------------------------------------------------------

GST_PLUGINS_GOOD_VER = $(GSTREAMER_VER)
GST_PLUGINS_GOOD_SOURCE = gst-plugins-good-$(GST_PLUGINS_GOOD_VER).tar.xz

$(ARCHIVE)/$(GST_PLUGINS_GOOD_SOURCE):
	$(WGET) https://gstreamer.freedesktop.org/src/gst-plugins-good/$(GST_PLUGINS_GOOD_SOURCE)

GST_PLUGINS_GOOD_PATCH  = gst-plugins-good-$(GST_PLUGINS_GOOD_VER)-0001-gstrtpmp4gpay-set-dafault-value-for-MPEG4-without-co.patch

$(D)/gst-plugins-good: $(ARCHIVE)/$(GST_PLUGINS_GOOD_SOURCE) $(D)/gst-plugins-base $(D)/libpng $(D)/libjpeg $(D)/libsoup $(D)/libFLAC | $(TARGET_DIR)
	$(REMOVE)/gst-plugins-good-$(GST_PLUGINS_GOOD_VER)
	$(UNTAR)/$(GST_PLUGINS_GOOD_SOURCE)
	$(CHDIR)/gst-plugins-good-$(GST_PLUGINS_GOOD_VER); \
		$(call apply_patches, $(GST_PLUGINS_GOOD_PATCH)); \
		./autogen.sh --noconfigure; \
		$(CONFIGURE) \
			--prefix= \
			--datarootdir=/.remove \
			--enable-silent-rules \
			--disable-valgrind \
			$(GST_PLUGIN_CONFIG_DEBUG) \
			--disable-examples \
			--disable-gtk-doc-html \
			; \
		$(MAKE); \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
	for i in `cd $(TARGET_LIB_DIR)/gstreamer-1.0; echo *.la`; do \
		$(REWRITE_LIBTOOL)/gstreamer-1.0/$$i; \
	done
	$(REMOVE)/gst-plugins-good-$(GST_PLUGINS_GOOD_VER)
	$(TOUCH)

# -----------------------------------------------------------------------------

GST_PLUGINS_BAD_VER = $(GSTREAMER_VER)
GST_PLUGINS_BAD_SOURCE = gst-plugins-bad-$(GST_PLUGINS_BAD_VER).tar.xz

$(ARCHIVE)/$(GST_PLUGINS_BAD_SOURCE):
	$(WGET) https://gstreamer.freedesktop.org/src/gst-plugins-bad/$(GST_PLUGINS_BAD_SOURCE)

GST_PLUGINS_BAD_PATCH  = gst-plugins-bad-$(GST_PLUGINS_BAD_VER)-configure-allow-to-disable-libssh2.patch
GST_PLUGINS_BAD_PATCH += gst-plugins-bad-$(GST_PLUGINS_BAD_VER)-fix-maybe-uninitialized-warnings-when-compiling-with-Os.patch
GST_PLUGINS_BAD_PATCH += gst-plugins-bad-$(GST_PLUGINS_BAD_VER)-avoid-including-sys-poll.h-directly.patch
GST_PLUGINS_BAD_PATCH += gst-plugins-bad-$(GST_PLUGINS_BAD_VER)-ensure-valid-sentinels-for-gst_structure_get-etc.patch
GST_PLUGINS_BAD_PATCH += gst-plugins-bad-$(GST_PLUGINS_BAD_VER)-0001-rtmp-fix-seeking-and-potential-segfault.patch
GST_PLUGINS_BAD_PATCH += gst-plugins-bad-$(GST_PLUGINS_BAD_VER)-0004-rtmp-hls-tsdemux-fix.patch
GST_PLUGINS_BAD_PATCH += gst-plugins-bad-$(GST_PLUGINS_BAD_VER)-dvbapi5-fix-old-kernel.patch
GST_PLUGINS_BAD_PATCH += gst-plugins-bad-$(GST_PLUGINS_BAD_VER)-hls-main-thread-block.patch

$(D)/gst-plugins-bad: $(ARCHIVE)/$(GST_PLUGINS_BAD_SOURCE) $(D)/gst-plugins-base $(D)/libass $(D)/libcurl $(D)/libxml2 $(D)/openssl $(D)/librtmp | $(TARGET_DIR)
	$(REMOVE)/gst-plugins-bad-$(GST_PLUGINS_BAD_VER)
	$(UNTAR)/$(GST_PLUGINS_BAD_SOURCE)
	$(CHDIR)/gst-plugins-bad-$(GST_PLUGINS_BAD_VER); \
		$(call apply_patches, $(GST_PLUGINS_BAD_PATCH)); \
		./autogen.sh --noconfigure; \
		$(CONFIGURE) \
			--build=$(BUILD) \
			--host=$(TARGET) \
			--prefix= \
			--datarootdir=/.remove \
			--enable-silent-rules \
			--disable-valgrind \
			$(GST_PLUGIN_CONFIG_DEBUG) \
			--disable-examples \
			--disable-gtk-doc-html \
			; \
		$(MAKE); \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
	for i in `cd $(TARGET_LIB_DIR)/gstreamer-1.0; echo *.la`; do \
		$(REWRITE_LIBTOOL)/gstreamer-1.0/$$i; \
	done
	$(REWRITE_PKGCONF) $(PKG_CONFIG_PATH)/gstreamer-bad-audio-1.0.pc
	$(REWRITE_PKGCONF) $(PKG_CONFIG_PATH)/gstreamer-bad-video-1.0.pc
	$(REWRITE_PKGCONF) $(PKG_CONFIG_PATH)/gstreamer-codecparsers-1.0.pc
	$(REWRITE_PKGCONF) $(PKG_CONFIG_PATH)/gstreamer-insertbin-1.0.pc
	$(REWRITE_PKGCONF) $(PKG_CONFIG_PATH)/gstreamer-mpegts-1.0.pc
	$(REWRITE_PKGCONF) $(PKG_CONFIG_PATH)/gstreamer-player-1.0.pc
	$(REWRITE_PKGCONF) $(PKG_CONFIG_PATH)/gstreamer-plugins-bad-1.0.pc
	$(REWRITE_PKGCONF) $(PKG_CONFIG_PATH)/gstreamer-webrtc-1.0.pc
	$(REWRITE_LIBTOOL)/libgstbasecamerabinsrc-1.0.la
	$(REWRITE_LIBTOOL)/libgstcodecparsers-1.0.la
	$(REWRITE_LIBTOOL)/libgstphotography-1.0.la
	$(REWRITE_LIBTOOL)/libgstadaptivedemux-1.0.la
	$(REWRITE_LIBTOOL)/libgstbadaudio-1.0.la
	$(REWRITE_LIBTOOL)/libgstbadvideo-1.0.la
	$(REWRITE_LIBTOOL)/libgstinsertbin-1.0.la
	$(REWRITE_LIBTOOL)/libgstisoff-1.0.la
	$(REWRITE_LIBTOOL)/libgstmpegts-1.0.la
	$(REWRITE_LIBTOOL)/libgstplayer-1.0.la
	$(REWRITE_LIBTOOL)/libgsturidownloader-1.0.la
	$(REWRITE_LIBTOOL)/libgstwebrtc-1.0.la
	$(REWRITE_LIBTOOLDEP)/libgstbadaudio-1.0.la
	$(REWRITE_LIBTOOLDEP)/libgstadaptivedemux-1.0.la
	$(REWRITE_LIBTOOLDEP)/libgstbadvideo-1.0.la
	$(REMOVE)/gst-plugins-bad-$(GST_PLUGINS_BAD_VER)
	$(TOUCH)

# -----------------------------------------------------------------------------

GST_PLUGINS_UGLY_VER = $(GSTREAMER_VER)
GST_PLUGINS_UGLY_SOURCE = gst-plugins-ugly-$(GST_PLUGINS_UGLY_VER).tar.xz

$(ARCHIVE)/$(GST_PLUGINS_UGLY_SOURCE):
	$(WGET) https://gstreamer.freedesktop.org/src/gst-plugins-ugly/$(GST_PLUGINS_UGLY_SOURCE)

$(D)/gst-plugins-ugly: $(ARCHIVE)/$(GST_PLUGINS_UGLY_SOURCE) $(D)/gst-plugins-base | $(TARGET_DIR)
	$(REMOVE)/gst-plugins-ugly-$(GST_PLUGINS_UGLY_VER)
	$(UNTAR)/$(GST_PLUGINS_UGLY_SOURCE)
	$(CHDIR)/gst-plugins-ugly-$(GST_PLUGINS_UGLY_VER); \
		./autogen.sh --noconfigure; \
		$(CONFIGURE) \
			--prefix= \
			--datarootdir=/.remove \
			--enable-silent-rules \
			--disable-valgrind \
			$(GST_PLUGIN_CONFIG_DEBUG) \
			--disable-examples \
			--disable-gtk-doc-html \
			; \
		$(MAKE); \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
	for i in `cd $(TARGET_LIB_DIR)/gstreamer-1.0; echo *.la`; do \
		$(REWRITE_LIBTOOL)/gstreamer-1.0/$$i; \
	done
	$(REMOVE)/gst-plugins-ugly-$(GST_PLUGINS_UGLY_VER)
	$(TOUCH)

# -----------------------------------------------------------------------------

GST_PLUGIN_SUBSINK_VER = 1.0

$(ARCHIVE)/gstreamer$(GST_PLUGIN_SUBSINK_VER)-plugin-subsink.git:
	get-git-source.sh git://github.com/christophecvr/gstreamer$(GST_PLUGIN_SUBSINK_VER)-plugin-subsink.git $@

PHONY += $(ARCHIVE)/gstreamer$(GST_PLUGIN_SUBSINK_VER)-plugin-subsink.git

$(D)/gst-plugin-subsink: $(ARCHIVE)/gstreamer$(GST_PLUGIN_SUBSINK_VER)-plugin-subsink.git $(D)/gst-plugins-base | $(TARGET_DIR)
	$(REMOVE)/gstreamer$(GST_PLUGIN_SUBSINK_VER)-plugin-subsink.git
	$(CPDIR)/gstreamer$(GST_PLUGIN_SUBSINK_VER)-plugin-subsink.git
	$(CHDIR)/gstreamer$(GST_PLUGIN_SUBSINK_VER)-plugin-subsink.git; \
		aclocal --force -I m4; \
		libtoolize --copy --ltdl --force; \
		autoconf --force; \
		autoheader --force; \
		automake --add-missing --copy --force-missing --foreign; \
		$(CONFIGURE) \
			--prefix= \
			--enable-silent-rules \
			; \
		$(MAKE); \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
	for i in `cd $(TARGET_LIB_DIR)/gstreamer-1.0; echo *.la`; do \
		$(REWRITE_LIBTOOL)/gstreamer-1.0/$$i; \
	done
	$(REMOVE)/gstreamer$(GST_PLUGIN_SUBSINK_VER)-plugin-subsink.git
	$(TOUCH)

# -----------------------------------------------------------------------------

GST_PLUGINS_DVBMEDIASINK_VER = 1.0

$(ARCHIVE)/gstreamer$(GST_PLUGINS_DVBMEDIASINK_VER)-plugin-dvbmediasink.git:
	get-git-source.sh https://github.com/OpenPLi/gst-plugin-dvbmediasink.git $@

PHONY += $(ARCHIVE)/gstreamer$(GST_PLUGIN_SUBSINK_VER)-plugin-subsink.git

$(D)/gst-plugin-dvbmediasink: $(ARCHIVE)/gstreamer$(GST_PLUGINS_DVBMEDIASINK_VER)-plugin-dvbmediasink.git $(D)/gst-plugins-base $(D)/libdca | $(TARGET_DIR)
	$(REMOVE)/gstreamer$(GST_PLUGINS_DVBMEDIASINK_VER)-plugin-dvbmediasink.git
	$(CPDIR)/gstreamer$(GST_PLUGINS_DVBMEDIASINK_VER)-plugin-dvbmediasink.git
	$(CHDIR)/gstreamer$(GST_PLUGINS_DVBMEDIASINK_VER)-plugin-dvbmediasink.git; \
		git checkout gst-1.0; \
		aclocal --force -I m4; \
		libtoolize --copy --ltdl --force; \
		autoconf --force; \
		autoheader --force; \
		automake --add-missing --copy --force-missing --foreign; \
		$(CONFIGURE) \
			--prefix= \
			--enable-silent-rules \
			--with-wma \
			--with-wmv \
			--with-pcm \
			--with-dts \
			--with-eac3 \
			--with-h265 \
			--with-vb6 \
			--with-vb8 \
			--with-vb9 \
			--with-spark \
			--with-gstversion=1.0 \
			; \
		$(MAKE) all; \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
	for i in `cd $(TARGET_LIB_DIR)/gstreamer-1.0; echo *.la`; do \
		$(REWRITE_LIBTOOL)/gstreamer-1.0/$$i; \
	done
	$(REMOVE)/gstreamer$(GST_PLUGINS_DVBMEDIASINK_VER)-plugin-dvbmediasink.git
	$(TOUCH)

# -----------------------------------------------------------------------------

GST_LIBAV_VER = $(GSTREAMER_VER)
GST_LIBAV_SOURCE = gst-libav-$(GST_LIBAV_VER).tar.xz

$(ARCHIVE)/$(GST_LIBAV_SOURCE):
	$(WGET) https://gstreamer.freedesktop.org/src/gst-libav/$(GST_LIBAV_SOURCE)

GST_LIBAV_PATCH  = gst-libav-$(GST_LIBAV_VER)-0001-Disable-yasm-for-libav-when-disable-yasm.patch
GST_LIBAV_PATCH += gst-libav-$(GST_LIBAV_VER)-workaround-to-build-gst-libav-for-i586-with-gcc.patch
GST_LIBAV_PATCH += gst-libav-$(GST_LIBAV_VER)-mips64_cpu_detection.patch
GST_LIBAV_PATCH += gst-libav-$(GST_LIBAV_VER)-0001-configure-check-for-armv7ve-variant.patch

$(D)/gst_libav: $(ARCHIVE)/$(GST_LIBAV_SOURCE) $(D)/gstreamer $(D)/gst-plugins-base | $(TARGET_DIR)
	$(REMOVE)/gst-libav-$(GST_LIBAV_VER)
	$(UNTAR)/$(GST_LIBAV_SOURCE)
	$(CHDIR)/gst-libav-$(GST_LIBAV_VER); \
		$(call apply_patches, $(GST_LIBAV_PATCH)); \
		$(CONFIGURE) \
			--prefix= \
			--disable-fatal-warnings \
			\
			--with-libav-extra-configure=" \
			--enable-gpl \
			--enable-static \
			--enable-pic \
			--disable-protocols \
			--disable-devices \
			--disable-network \
			--disable-hwaccels \
			--disable-filters \
			--disable-doc \
			--enable-optimizations \
			--enable-cross-compile \
			--target-os=linux \
			--arch=$(BOXARCH) \
			--cross-prefix=$(TARGET)- \
			\
			--disable-muxers \
			--disable-encoders \
			--disable-decoders \
			--enable-decoder=ogg \
			--enable-decoder=vorbis \
			--enable-decoder=flac \
			\
			--disable-demuxers \
			--enable-demuxer=ogg \
			--enable-demuxer=vorbis \
			--enable-demuxer=flac \
			--enable-demuxer=mpegts \
			\
			--disable-debug \
			--disable-bsfs \
			--enable-pthreads \
			--enable-bzlib" \
			; \
		$(MAKE); \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
	$(REMOVE)/gst-libav-$(GST_LIBAV_VER)
	$(TOUCH)

# -----------------------------------------------------------------------------

$(ARCHIVE)/gmrender-resurrect.git:
	get-git-source.sh https://github.com/hzeller/gmrender-resurrect.git $@

PHONY += $(ARCHIVE)/gmrender-resurrect.git

$(D)/gmrender-resurrect: $(ARCHIVE)/gmrender-resurrect.git $(D)/gst-plugins-base $(D)/libupnp | $(TARGET_DIR)
	$(REMOVE)/gmrender-resurrect.git
	$(CPDIR)/gmrender-resurrect.git
	$(CHDIR)/gmrender-resurrect.git; \
		$(CONFIGURE) \
			--prefix= \
		; \
		$(MAKE); \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
	$(REMOVE)/gmrender-resurrect.git
	$(TOUCH)

# -----------------------------------------------------------------------------

ORC_VER = 0.4.28
ORC_SOURCE = orc-$(ORC_VER).tar.xz

$(ARCHIVE)/$(ORC_SOURCE):
	$(WGET) https://gstreamer.freedesktop.org/src/orc/$(ORC_SOURCE)

$(D)/orc: $(ARCHIVE)/$(ORC_SOURCE)
	$(REMOVE)/orc-$(ORC_VER)
	$(UNTAR)/$(ORC_SOURCE)
	$(CHDIR)/orc-$(ORC_VER); \
		$(CONFIGURE) \
			--datarootdir=/.remove \
			--prefix= \
			; \
		$(MAKE) all; \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
	$(REWRITE_PKGCONF) $(PKG_CONFIG_PATH)/orc-0.4.pc
	$(REWRITE_LIBTOOL)/liborc-0.4.la
	$(REWRITE_LIBTOOL)/liborc-test-0.4.la
	$(REWRITE_LIBTOOLDEP)/liborc-test-0.4.la
	rm -f $(addprefix $(TARGET_DIR)/bin/,orc-bugreport orcc)
	$(REMOVE)/orc-$(ORC_VER)
	$(TOUCH)

# -----------------------------------------------------------------------------

LIBDCA_VER = 0.0.5
LIBDCA_SOURCE = libdca-$(LIBDCA_VER).tar.bz2

$(ARCHIVE)/$(LIBDCA_SOURCE):
	$(WGET) http://download.videolan.org/pub/videolan/libdca/$(LIBDCA_VER)/$(LIBDCA_SOURCE)

$(D)/libdca: $(ARCHIVE)/$(LIBDCA_SOURCE)
	$(REMOVE)/libdca-$(LIBDCA_VER)
	$(UNTAR)/$(LIBDCA_SOURCE)
	$(CHDIR)/libdca-$(LIBDCA_VER); \
		$(CONFIGURE) \
			--prefix= \
			--mandir=/.remove \
			; \
		$(MAKE) all; \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
	$(REWRITE_PKGCONF) $(PKG_CONFIG_PATH)/libdca.pc
	$(REWRITE_PKGCONF) $(PKG_CONFIG_PATH)/libdts.pc
	$(REWRITE_LIBTOOL)/libdca.la
	rm -f $(addprefix $(TARGET_DIR)/bin/,extract_dca extract_dts)
	$(REMOVE)/libdca-$(LIBDCA_VER)
	$(TOUCH)

# -----------------------------------------------------------------------------

NETTLE_VER = 3.4
NETTLE_SOURCE = nettle-$(NETTLE_VER).tar.gz

$(ARCHIVE)/$(NETTLE_SOURCE):
	$(WGET) https://ftp.gnu.org/gnu/nettle/$(NETTLE_SOURCE)

$(D)/nettle: $(D)/gmp $(ARCHIVE)/$(NETTLE_SOURCE)
	$(REMOVE)/nettle-$(NETTLE_VER)
	$(UNTAR)/$(NETTLE_SOURCE)
	$(CHDIR)/nettle-$(NETTLE_VER); \
		$(CONFIGURE) \
			--prefix= \
			--disable-documentation \
			; \
		$(MAKE) all; \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
	$(REWRITE_PKGCONF) $(PKG_CONFIG_PATH)/hogweed.pc
	$(REWRITE_PKGCONF) $(PKG_CONFIG_PATH)/nettle.pc
	rm -f $(addprefix $(TARGET_DIR)/bin/,sexp-conv nettle-hash nettle-pbkdf2 nettle-lfib-stream pkcs1-conv)
	$(REMOVE)/nettle-$(NETTLE_VER)
	$(TOUCH)

# -----------------------------------------------------------------------------

GMP_VER = 6.1.2
GMP_SOURCE = gmp-$(GMP_VER).tar.xz

$(ARCHIVE)/$(GMP_SOURCE):
	$(WGET) ftp://ftp.gmplib.org/pub/gmp-$(GMP_VER)/$(GMP_SOURCE)

$(D)/gmp: $(ARCHIVE)/$(GMP_SOURCE)
	$(REMOVE)/gmp-$(GMP_VER)
	$(UNTAR)/$(GMP_SOURCE)
	$(CHDIR)/gmp-$(GMP_VER); \
		$(CONFIGURE) \
			--prefix= \
			--infodir=/.remove \
			; \
		$(MAKE); \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
	$(REWRITE_LIBTOOL)/libgmp.la
	$(REMOVE)/gmp-$(GMP_VER)
	$(TOUCH)

# -----------------------------------------------------------------------------

GNUTLS_VER_MAJOR = 3.6
GNUTLS_VER_MINOR = 1
GNUTLS_VER = $(GNUTLS_VER_MAJOR).$(GNUTLS_VER_MINOR)
GNUTLS_SOURCE = gnutls-$(GNUTLS_VER).tar.xz

$(ARCHIVE)/$(GNUTLS_SOURCE):
	$(WGET) ftp://ftp.gnutls.org/gcrypt/gnutls/v$(GNUTLS_VER_MAJOR)/$(GNUTLS_SOURCE)

$(D)/gnutls: $(D)/nettle $(D)/ca-bundle $(ARCHIVE)/$(GNUTLS_SOURCE)
	$(REMOVE)/gnutls-$(GNUTLS_VER)
	$(UNTAR)/$(GNUTLS_SOURCE)
	$(CHDIR)/gnutls-$(GNUTLS_VER); \
		$(CONFIGURE) \
			--prefix= \
			--mandir=/.remove \
			--infodir=/.remove \
			--datarootdir=/.remove \
			--with-included-libtasn1 \
			--enable-local-libopts \
			--with-libpthread-prefix=$(TARGET_DIR) \
			--with-included-unistring \
			--with-default-trust-store-dir=$(CA-BUNDLE_DIR)/ \
			--disable-guile \
			--disable-doc \
			--without-p11-kit \
			; \
		$(MAKE); \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
	$(REWRITE_PKGCONF) $(PKG_CONFIG_PATH)/gnutls.pc
	$(REWRITE_LIBTOOL)/libgnutls.la
	$(REWRITE_LIBTOOL)/libgnutlsxx.la
	$(REWRITE_LIBTOOLDEP)/libgnutlsxx.la
	rm -f $(addprefix $(TARGET_DIR)/bin/,psktool gnutls-cli-debug certtool srptool ocsptool gnutls-serv gnutls-cli)
	$(REMOVE)/gnutls-$(GNUTLS_VER)
	$(TOUCH)

# -----------------------------------------------------------------------------

GLIB-NETWORKING_VER_MAJOR = 2.54
GLIB-NETWORKING_VER_MINOR = 1
GLIB-NETWORKING_VER = $(GLIB-NETWORKING_VER_MAJOR).$(GLIB-NETWORKING_VER_MINOR)
GLIB-NETWORKING_SOURCE = glib-networking-$(GLIB-NETWORKING_VER).tar.xz

$(ARCHIVE)/$(GLIB-NETWORKING_SOURCE):
	$(WGET) https://ftp.acc.umu.se/pub/GNOME/sources/glib-networking/$(GLIB-NETWORKING_VER_MAJOR)/$(GLIB-NETWORKING_SOURCE)

$(D)/glib-networking: $(D)/gnutls $(D)/libglib2 $(ARCHIVE)/$(GLIB-NETWORKING_SOURCE)
	$(REMOVE)/glib-networking-$(GLIB-NETWORKING_VER)
	$(UNTAR)/$(GLIB-NETWORKING_SOURCE)
	$(CHDIR)/glib-networking-$(GLIB-NETWORKING_VER); \
		$(CONFIGURE) \
			--prefix= \
			--datadir=/.remove \
			--datarootdir=/.remove \
			--localedir=/.remove \
			; \
		$(MAKE); \
		$(MAKE) install prefix=$(TARGET_DIR)
	$(REMOVE)/glib-networking-$(GLIB-NETWORKING_VER)
	$(TOUCH)

# -----------------------------------------------------------------------------

LIBSOUP_VER_MAJOR = 2.61
LIBSOUP_VER_MINOR = 1
LIBSOUP_VER = $(LIBSOUP_VER_MAJOR).$(LIBSOUP_VER_MINOR)
LIBSOUP_SOURCE = libsoup-$(LIBSOUP_VER).tar.xz

$(ARCHIVE)/$(LIBSOUP_SOURCE):
	$(WGET) https://download.gnome.org/sources/libsoup/$(LIBSOUP_VER_MAJOR)/$(LIBSOUP_SOURCE)

$(D)/libsoup: $(D)/sqlite $(D)/libxml2 $(D)/libglib2 $(ARCHIVE)/$(LIBSOUP_SOURCE)
	$(REMOVE)/libsoup-$(LIBSOUP_VER)
	$(UNTAR)/$(LIBSOUP_SOURCE)
	$(CHDIR)/libsoup-$(LIBSOUP_VER); \
		$(CONFIGURE) \
			--prefix= \
			--datarootdir=/.remove \
			--disable-more-warnings \
			--without-gnome \
			--disable-gtk-doc \
			--disable-gtk-doc-html \
			--disable-gtk-doc-pdf \
			; \
		$(MAKE); \
		$(MAKE) install DESTDIR=$(TARGET_DIR) itlocaledir=$$(TARGET_DIR)/.remove
	$(REWRITE_PKGCONF) $(PKG_CONFIG_PATH)/libsoup-2.4.pc
	$(REWRITE_LIBTOOL)/libsoup-2.4.la
	$(REMOVE)/libsoup-$(LIBSOUP_VER)
	$(TOUCH)

# -----------------------------------------------------------------------------

SQLITE_VER = 3210000
SQLITE_SOURCE = sqlite-autoconf-$(SQLITE_VER).tar.gz

$(ARCHIVE)/$(SQLITE_SOURCE):
	$(WGET) http://www.sqlite.org/2017/$(SQLITE_SOURCE)

$(D)/sqlite: $(ARCHIVE)/$(SQLITE_SOURCE)
	$(REMOVE)/sqlite-autoconf-$(SQLITE_VER)
	$(UNTAR)/$(SQLITE_SOURCE)
	$(CHDIR)/sqlite-autoconf-$(SQLITE_VER); \
		$(CONFIGURE) \
			--prefix= \
			--mandir=/.remove \
			; \
		$(MAKE) all; \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
	$(REWRITE_PKGCONF) $(PKG_CONFIG_PATH)/sqlite3.pc
	$(REWRITE_LIBTOOL)/libsqlite3.la
	rm -f $(addprefix $(TARGET_DIR)/bin/,sqlite3)
	$(REMOVE)/sqlite-autoconf-$(SQLITE_VER)
	$(TOUCH)
