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
	$(DOWNLOAD) https://gstreamer.freedesktop.org/src/gstreamer/$(GSTREAMER_SOURCE)

GSTREAMER_PATCH  = gstreamer-$(GSTREAMER_VER)-revert-use-new-gst-adapter-get-buffer.patch

$(D)/gstreamer: $(D)/glib2 $(D)/libxml2 $(D)/glib-networking $(ARCHIVE)/$(GSTREAMER_SOURCE)
	$(REMOVE)/gstreamer-$(GSTREAMER_VER)
	$(UNTAR)/$(GSTREAMER_SOURCE)
	$(CHDIR)/gstreamer-$(GSTREAMER_VER); \
		$(call apply_patches, $(GSTREAMER_PATCH)); \
		./autogen.sh --noconfigure; \
		$(CONFIGURE) \
			--prefix= \
			--libexecdir=/lib \
			--datarootdir=$(remove-datarootdir) \
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
	$(REWRITE_PKGCONF)/gstreamer-1.0.pc
	$(REWRITE_PKGCONF)/gstreamer-base-1.0.pc
	$(REWRITE_PKGCONF)/gstreamer-controller-1.0.pc
	$(REWRITE_PKGCONF)/gstreamer-net-1.0.pc
	$(REWRITE_LIBTOOL)/libgstreamer-1.0.la
	$(REWRITE_LIBTOOL)/libgstbase-1.0.la
	$(REWRITE_LIBTOOL)/libgstcontroller-1.0.la
	$(REWRITE_LIBTOOL)/libgstnet-1.0.la
	$(REMOVE)/gstreamer-$(GSTREAMER_VER)
	$(TOUCH)

# -----------------------------------------------------------------------------

GST_PLUGINS_BASE_VER = $(GSTREAMER_VER)
GST_PLUGINS_BASE_SOURCE = gst-plugins-base-$(GST_PLUGINS_BASE_VER).tar.xz

$(ARCHIVE)/$(GST_PLUGINS_BASE_SOURCE):
	$(DOWNLOAD) https://gstreamer.freedesktop.org/src/gst-plugins-base/$(GST_PLUGINS_BASE_SOURCE)

GST_PLUGINS_BASE_PATCH  = gst-plugins-base-$(GST_PLUGINS_BASE_VER)-0003-riff-add-missing-include-directories-when-calling-in.patch
#GST_PLUGINS_BASE_PATCH += gst-plugins-base-$(GST_PLUGINS_BASE_VER)-0004-rtsp-drop-incorrect-reference-to-gstreamer-sdp-in-Ma.patch
GST_PLUGINS_BASE_PATCH += gst-plugins-base-$(GST_PLUGINS_BASE_VER)-get-caps-from-src-pad-when-query-caps.patch
GST_PLUGINS_BASE_PATCH += gst-plugins-base-$(GST_PLUGINS_BASE_VER)-0004-subparse-set-need_segment-after-sink-pad-received-GS.patch
GST_PLUGINS_BASE_PATCH += gst-plugins-base-$(GST_PLUGINS_BASE_VER)-make-gio_unix_2_0-dependency-configurable.patch
GST_PLUGINS_BASE_PATCH += gst-plugins-base-$(GST_PLUGINS_BASE_VER)-0003-riff-media-added-fourcc-to-all-ffmpeg-mpeg4-video-caps.patch

$(D)/gst-plugins-base: $(ARCHIVE)/$(GST_PLUGINS_BASE_SOURCE) $(D)/gstreamer $(D)/zlib $(D)/glib2 $(D)/orc $(D)/alsa-lib $(D)/libogg $(D)/libvorbisidec | $(TARGET_DIR)
	$(REMOVE)/gst-plugins-base-$(GST_PLUGINS_BASE_VER)
	$(UNTAR)/$(GST_PLUGINS_BASE_SOURCE)
	$(CHDIR)/gst-plugins-base-$(GST_PLUGINS_BASE_VER); \
		$(call apply_patches, $(GST_PLUGINS_BASE_PATCH)); \
		./autogen.sh --noconfigure; \
		$(CONFIGURE) \
			--prefix= \
			--datarootdir=$(remove-datarootdir) \
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
	$(REWRITE_PKGCONF)/gstreamer-allocators-1.0.pc
	$(REWRITE_PKGCONF)/gstreamer-app-1.0.pc
	$(REWRITE_PKGCONF)/gstreamer-audio-1.0.pc
	$(REWRITE_PKGCONF)/gstreamer-fft-1.0.pc
	$(REWRITE_PKGCONF)/gstreamer-pbutils-1.0.pc
	$(REWRITE_PKGCONF)/gstreamer-riff-1.0.pc
	$(REWRITE_PKGCONF)/gstreamer-rtp-1.0.pc
	$(REWRITE_PKGCONF)/gstreamer-rtsp-1.0.pc
	$(REWRITE_PKGCONF)/gstreamer-sdp-1.0.pc
	$(REWRITE_PKGCONF)/gstreamer-tag-1.0.pc
	$(REWRITE_PKGCONF)/gstreamer-video-1.0.pc
	$(REWRITE_PKGCONF)/gstreamer-plugins-base-1.0.pc
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
	$(REMOVE)/gst-plugins-base-$(GST_PLUGINS_BASE_VER)
	$(TOUCH)

# -----------------------------------------------------------------------------

GST_PLUGINS_GOOD_VER = $(GSTREAMER_VER)
GST_PLUGINS_GOOD_SOURCE = gst-plugins-good-$(GST_PLUGINS_GOOD_VER).tar.xz

$(ARCHIVE)/$(GST_PLUGINS_GOOD_SOURCE):
	$(DOWNLOAD) https://gstreamer.freedesktop.org/src/gst-plugins-good/$(GST_PLUGINS_GOOD_SOURCE)

GST_PLUGINS_GOOD_PATCH  = gst-plugins-good-$(GST_PLUGINS_GOOD_VER)-0001-gstrtpmp4gpay-set-dafault-value-for-MPEG4-without-co.patch

$(D)/gst-plugins-good: $(ARCHIVE)/$(GST_PLUGINS_GOOD_SOURCE) $(D)/gst-plugins-base $(D)/libpng $(D)/libjpeg $(D)/libsoup $(D)/libFLAC | $(TARGET_DIR)
	$(REMOVE)/gst-plugins-good-$(GST_PLUGINS_GOOD_VER)
	$(UNTAR)/$(GST_PLUGINS_GOOD_SOURCE)
	$(CHDIR)/gst-plugins-good-$(GST_PLUGINS_GOOD_VER); \
		$(call apply_patches, $(GST_PLUGINS_GOOD_PATCH)); \
		./autogen.sh --noconfigure; \
		$(CONFIGURE) \
			--prefix= \
			--datarootdir=$(remove-datarootdir) \
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
	$(DOWNLOAD) https://gstreamer.freedesktop.org/src/gst-plugins-bad/$(GST_PLUGINS_BAD_SOURCE)

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
			--datarootdir=$(remove-datarootdir) \
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
	$(REWRITE_PKGCONF)/gstreamer-bad-audio-1.0.pc
	$(REWRITE_PKGCONF)/gstreamer-bad-video-1.0.pc
	$(REWRITE_PKGCONF)/gstreamer-codecparsers-1.0.pc
	$(REWRITE_PKGCONF)/gstreamer-insertbin-1.0.pc
	$(REWRITE_PKGCONF)/gstreamer-mpegts-1.0.pc
	$(REWRITE_PKGCONF)/gstreamer-player-1.0.pc
	$(REWRITE_PKGCONF)/gstreamer-plugins-bad-1.0.pc
	$(REWRITE_PKGCONF)/gstreamer-webrtc-1.0.pc
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
	$(REMOVE)/gst-plugins-bad-$(GST_PLUGINS_BAD_VER)
	$(TOUCH)

# -----------------------------------------------------------------------------

GST_PLUGINS_UGLY_VER = $(GSTREAMER_VER)
GST_PLUGINS_UGLY_SOURCE = gst-plugins-ugly-$(GST_PLUGINS_UGLY_VER).tar.xz

$(ARCHIVE)/$(GST_PLUGINS_UGLY_SOURCE):
	$(DOWNLOAD) https://gstreamer.freedesktop.org/src/gst-plugins-ugly/$(GST_PLUGINS_UGLY_SOURCE)

$(D)/gst-plugins-ugly: $(ARCHIVE)/$(GST_PLUGINS_UGLY_SOURCE) $(D)/gst-plugins-base | $(TARGET_DIR)
	$(REMOVE)/gst-plugins-ugly-$(GST_PLUGINS_UGLY_VER)
	$(UNTAR)/$(GST_PLUGINS_UGLY_SOURCE)
	$(CHDIR)/gst-plugins-ugly-$(GST_PLUGINS_UGLY_VER); \
		./autogen.sh --noconfigure; \
		$(CONFIGURE) \
			--prefix= \
			--datarootdir=$(remove-datarootdir) \
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

$(D)/gst-plugin-subsink: $(D)/gst-plugins-base | $(TARGET_DIR)
	$(REMOVE)/gstreamer$(GST_PLUGIN_SUBSINK_VER)-plugin-subsink.git
	$(GET-GIT-SOURCE) git://github.com/christophecvr/gstreamer$(GST_PLUGIN_SUBSINK_VER)-plugin-subsink.git $(ARCHIVE)/gstreamer$(GST_PLUGIN_SUBSINK_VER)-plugin-subsink.git
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

$(D)/gst-plugin-dvbmediasink: $(D)/gst-plugins-base $(D)/libdca | $(TARGET_DIR)
	$(REMOVE)/gstreamer$(GST_PLUGINS_DVBMEDIASINK_VER)-plugin-dvbmediasink.git
	$(GET-GIT-SOURCE) https://github.com/OpenPLi/gst-plugin-dvbmediasink.git $(ARCHIVE)/gstreamer$(GST_PLUGINS_DVBMEDIASINK_VER)-plugin-dvbmediasink.git
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
	$(DOWNLOAD) https://gstreamer.freedesktop.org/src/gst-libav/$(GST_LIBAV_SOURCE)

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
			--cross-prefix=$(TARGET_CROSS) \
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

$(D)/gmrender-resurrect: $(D)/gst-plugins-base $(D)/libupnp | $(TARGET_DIR)
	$(REMOVE)/gmrender-resurrect.git
	$(GET-GIT-SOURCE) https://github.com/hzeller/gmrender-resurrect.git $(ARCHIVE)/gmrender-resurrect.git
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
	$(DOWNLOAD) https://gstreamer.freedesktop.org/src/orc/$(ORC_SOURCE)

$(D)/orc: $(ARCHIVE)/$(ORC_SOURCE)
	$(REMOVE)/orc-$(ORC_VER)
	$(UNTAR)/$(ORC_SOURCE)
	$(CHDIR)/orc-$(ORC_VER); \
		$(CONFIGURE) \
			--datarootdir=$(remove-datarootdir) \
			--prefix= \
			; \
		$(MAKE) all; \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
	$(REWRITE_PKGCONF)/orc-0.4.pc
	$(REWRITE_LIBTOOL)/liborc-0.4.la
	$(REWRITE_LIBTOOL)/liborc-test-0.4.la
	rm -f $(addprefix $(TARGET_DIR)/bin/,orc-bugreport orcc)
	$(REMOVE)/orc-$(ORC_VER)
	$(TOUCH)

# -----------------------------------------------------------------------------

LIBDCA_VER = 0.0.5
LIBDCA_SOURCE = libdca-$(LIBDCA_VER).tar.bz2

$(ARCHIVE)/$(LIBDCA_SOURCE):
	$(DOWNLOAD) http://download.videolan.org/pub/videolan/libdca/$(LIBDCA_VER)/$(LIBDCA_SOURCE)

$(D)/libdca: $(ARCHIVE)/$(LIBDCA_SOURCE)
	$(REMOVE)/libdca-$(LIBDCA_VER)
	$(UNTAR)/$(LIBDCA_SOURCE)
	$(CHDIR)/libdca-$(LIBDCA_VER); \
		$(CONFIGURE) \
			--prefix= \
			--mandir=$(remove-mandir) \
			; \
		$(MAKE) all; \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
	$(REWRITE_PKGCONF)/libdca.pc
	$(REWRITE_PKGCONF)/libdts.pc
	$(REWRITE_LIBTOOL)/libdca.la
	rm -f $(addprefix $(TARGET_DIR)/bin/,extract_dca extract_dts)
	$(REMOVE)/libdca-$(LIBDCA_VER)
	$(TOUCH)

# -----------------------------------------------------------------------------

NETTLE_VER = 3.4
NETTLE_SOURCE = nettle-$(NETTLE_VER).tar.gz

$(ARCHIVE)/$(NETTLE_SOURCE):
	$(DOWNLOAD) https://ftp.gnu.org/gnu/nettle/$(NETTLE_SOURCE)

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
	$(REWRITE_PKGCONF)/hogweed.pc
	$(REWRITE_PKGCONF)/nettle.pc
	rm -f $(addprefix $(TARGET_DIR)/bin/,sexp-conv nettle-hash nettle-pbkdf2 nettle-lfib-stream pkcs1-conv)
	$(REMOVE)/nettle-$(NETTLE_VER)
	$(TOUCH)

# -----------------------------------------------------------------------------

GMP_VER = 6.1.2
GMP_SOURCE = gmp-$(GMP_VER).tar.xz

$(ARCHIVE)/$(GMP_SOURCE):
	$(DOWNLOAD) ftp://ftp.gmplib.org/pub/gmp-$(GMP_VER)/$(GMP_SOURCE)

$(D)/gmp: $(ARCHIVE)/$(GMP_SOURCE)
	$(REMOVE)/gmp-$(GMP_VER)
	$(UNTAR)/$(GMP_SOURCE)
	$(CHDIR)/gmp-$(GMP_VER); \
		$(CONFIGURE) \
			--prefix= \
			--infodir=$(remove-infodir) \
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
	$(DOWNLOAD) ftp://ftp.gnutls.org/gcrypt/gnutls/v$(GNUTLS_VER_MAJOR)/$(GNUTLS_SOURCE)

$(D)/gnutls: $(D)/nettle $(D)/ca-bundle $(ARCHIVE)/$(GNUTLS_SOURCE)
	$(REMOVE)/gnutls-$(GNUTLS_VER)
	$(UNTAR)/$(GNUTLS_SOURCE)
	$(CHDIR)/gnutls-$(GNUTLS_VER); \
		$(CONFIGURE) \
			--prefix= \
			--datarootdir=$(remove-datarootdir) \
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
	$(REWRITE_PKGCONF)/gnutls.pc
	$(REWRITE_LIBTOOL)/libgnutls.la
	$(REWRITE_LIBTOOL)/libgnutlsxx.la
	rm -f $(addprefix $(TARGET_DIR)/bin/,psktool gnutls-cli-debug certtool srptool ocsptool gnutls-serv gnutls-cli)
	$(REMOVE)/gnutls-$(GNUTLS_VER)
	$(TOUCH)

# -----------------------------------------------------------------------------

GLIB-NETWORKING_VER_MAJOR = 2.54
GLIB-NETWORKING_VER_MINOR = 1
GLIB-NETWORKING_VER = $(GLIB-NETWORKING_VER_MAJOR).$(GLIB-NETWORKING_VER_MINOR)
GLIB-NETWORKING_SOURCE = glib-networking-$(GLIB-NETWORKING_VER).tar.xz

$(ARCHIVE)/$(GLIB-NETWORKING_SOURCE):
	$(DOWNLOAD) https://ftp.acc.umu.se/pub/GNOME/sources/glib-networking/$(GLIB-NETWORKING_VER_MAJOR)/$(GLIB-NETWORKING_SOURCE)

$(D)/glib-networking: $(D)/gnutls $(D)/glib2 $(ARCHIVE)/$(GLIB-NETWORKING_SOURCE)
	$(REMOVE)/glib-networking-$(GLIB-NETWORKING_VER)
	$(UNTAR)/$(GLIB-NETWORKING_SOURCE)
	$(CHDIR)/glib-networking-$(GLIB-NETWORKING_VER); \
		$(CONFIGURE) \
			--prefix= \
			--datarootdir=$(remove-datarootdir) \
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
	$(DOWNLOAD) https://download.gnome.org/sources/libsoup/$(LIBSOUP_VER_MAJOR)/$(LIBSOUP_SOURCE)

$(D)/libsoup: $(D)/sqlite $(D)/libxml2 $(D)/glib2 $(ARCHIVE)/$(LIBSOUP_SOURCE)
	$(REMOVE)/libsoup-$(LIBSOUP_VER)
	$(UNTAR)/$(LIBSOUP_SOURCE)
	$(CHDIR)/libsoup-$(LIBSOUP_VER); \
		$(CONFIGURE) \
			--prefix= \
			--datarootdir=$(remove-datarootdir) \
			--disable-more-warnings \
			--without-gnome \
			--disable-gtk-doc \
			--disable-gtk-doc-html \
			--disable-gtk-doc-pdf \
			; \
		$(MAKE); \
		$(MAKE) install DESTDIR=$(TARGET_DIR) itlocaledir=$(remove-localedir)
	$(REWRITE_PKGCONF)/libsoup-2.4.pc
	$(REWRITE_LIBTOOL)/libsoup-2.4.la
	$(REMOVE)/libsoup-$(LIBSOUP_VER)
	$(TOUCH)

# -----------------------------------------------------------------------------

SQLITE_VER = 3280000
SQLITE_SOURCE = sqlite-autoconf-$(SQLITE_VER).tar.gz

$(ARCHIVE)/$(SQLITE_SOURCE):
	$(DOWNLOAD) http://www.sqlite.org/2019/$(SQLITE_SOURCE)

$(D)/sqlite: $(ARCHIVE)/$(SQLITE_SOURCE)
	$(REMOVE)/sqlite-autoconf-$(SQLITE_VER)
	$(UNTAR)/$(SQLITE_SOURCE)
	$(CHDIR)/sqlite-autoconf-$(SQLITE_VER); \
		$(CONFIGURE) \
			--prefix= \
			--mandir=$(remove-mandir) \
			; \
		$(MAKE) all; \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
	$(REWRITE_PKGCONF)/sqlite3.pc
	$(REWRITE_LIBTOOL)/libsqlite3.la
	rm -f $(addprefix $(TARGET_DIR)/bin/,sqlite3)
	$(REMOVE)/sqlite-autoconf-$(SQLITE_VER)
	$(TOUCH)
