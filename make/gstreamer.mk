# makefile to build gstreamer and all it's dependencies

# change to activate debug
GSTREAMER_DEBUG = yes

GST_MAIN_CONFIG_DEBUG = --disable-gst-debug
GST_PLUGIN_CONFIG_DEBUG = --disable-debug
ifeq ($(GSTREAMER_DEBUG), yes)
  GST_MAIN_CONFIG_DEBUG = --enable-gst-debug
  GST_PLUGIN_CONFIG_DEBUG = --enable-debug
endif

#
# gstreamer
#
GSTREAMER_VER = 1.12.3
GSTREAMER_SOURCE = gstreamer-$(GSTREAMER_VER).tar.xz

$(ARCHIVE)/$(GSTREAMER_SOURCE):
	$(WGET) https://gstreamer.freedesktop.org/src/gstreamer/$(GSTREAMER_SOURCE)

$(D)/gstreamer: $(D)/libglib2 $(D)/libxml2 $(D)/glib_networking $(ARCHIVE)/$(GSTREAMER_SOURCE)
	$(UNTAR)/$(GSTREAMER_SOURCE)
	set -e; cd $(BUILD_TMP)/gstreamer-$(GSTREAMER_VER); \
		$(PATCH)/gstreamer-$(GSTREAMER_VER)-revert-use-new-gst-adapter-get-buffer.patch; \
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
			--disable-gtk-doc-html \
			ac_cv_header_valgrind_valgrind_h=no \
		; \
		$(MAKE); \
		$(MAKE) install DESTDIR=$(TARGETPREFIX)
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
	touch $@

#
# gst_plugins_base
#
GST_PLUGINS_BASE_VER = $(GSTREAMER_VER)
GST_PLUGINS_BASE_SOURCE = gst-plugins-base-$(GST_PLUGINS_BASE_VER).tar.xz

$(ARCHIVE)/$(GST_PLUGINS_BASE_SOURCE):
	$(WGET) https://gstreamer.freedesktop.org/src/gst-plugins-base/$(GST_PLUGINS_BASE_SOURCE)

$(D)/gst_plugins_base: $(D)/zlib $(D)/libglib2 $(D)/orc $(D)/gstreamer $(D)/alsa_lib $(D)/libogg $(D)/libvorbisidec $(ARCHIVE)/$(GST_PLUGINS_BASE_SOURCE)
	$(UNTAR)/$(GST_PLUGINS_BASE_SOURCE)
	set -e; cd $(BUILD_TMP)/gst-plugins-base-$(GST_PLUGINS_BASE_VER); \
		$(PATCH)/gst-plugins-base-$(GSTREAMER_VER)-Makefile.am-don-t-hardcode-libtool-name-when-running.patch; \
		$(PATCH)/gst-plugins-base-$(GSTREAMER_VER)-Makefile.am-prefix-calls-to-pkg-config-with-PKG_CONF.patch; \
		$(PATCH)/gst-plugins-base-$(GSTREAMER_VER)-riff-media-added-fourcc-to-all-ffmpeg-mpeg4-video-caps.patch; \
		$(PATCH)/gst-plugins-base-$(GSTREAMER_VER)-rtsp-drop-incorrect-reference-to-gstreamer-sdp-in-Ma.patch; \
		$(PATCH)/gst-plugins-base-$(GSTREAMER_VER)-subparse-avoid-false-negatives-dealing-with-UTF-8.patch; \
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
		$(MAKE) install DESTDIR=$(TARGETPREFIX)
	for i in `cd $(TARGETPREFIX)/lib/gstreamer-1.0; echo *.la`; do \
		$(REWRITE_LIBTOOL)/gstreamer-1.0/$$i; done
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
	touch $@

#
# gst_plugins_good
#
GST_PLUGINS_GOOD_VER = $(GSTREAMER_VER)
GST_PLUGINS_GOOD_SOURCE = gst-plugins-good-$(GST_PLUGINS_GOOD_VER).tar.xz

$(ARCHIVE)/$(GST_PLUGINS_GOOD_SOURCE):
	$(WGET) https://gstreamer.freedesktop.org/src/gst-plugins-good/$(GST_PLUGINS_GOOD_SOURCE)

$(D)/gst_plugins_good: $(D)/libpng $(D)/libjpeg $(D)/gstreamer $(D)/gst_plugins_base $(D)/libsoup $(D)/libFLAC $(ARCHIVE)/$(GST_PLUGINS_GOOD_SOURCE)
	$(UNTAR)/$(GST_PLUGINS_GOOD_SOURCE)
	set -e; cd $(BUILD_TMP)/gst-plugins-good-$(GST_PLUGINS_GOOD_VER); \
		$(PATCH)/gst-plugins-good-$(GSTREAMER_VER)-gstrtpmp4gpay-set-dafault-value-for-MPEG4-without-co.patch; \
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
		$(MAKE) install DESTDIR=$(TARGETPREFIX)
	for i in `cd $(TARGETPREFIX)/lib/gstreamer-1.0; echo *.la`; do \
		$(REWRITE_LIBTOOL)/gstreamer-1.0/$$i; done
	$(REMOVE)/gst-plugins-good-$(GST_PLUGINS_GOOD_VER)
	touch $@

#
# gst_plugins_bad
#
GST_PLUGINS_BAD_VER = $(GSTREAMER_VER)
GST_PLUGINS_BAD_SOURCE = gst-plugins-bad-$(GST_PLUGINS_BAD_VER).tar.xz

$(ARCHIVE)/$(GST_PLUGINS_BAD_SOURCE):
	$(WGET) https://gstreamer.freedesktop.org/src/gst-plugins-bad/$(GST_PLUGINS_BAD_SOURCE)

$(D)/gst_plugins_bad: $(D)/libass $(D)/libcurl $(D)/libxml2 $(D)/openssl $(D)/librtmp $(D)/gstreamer $(D)/gst_plugins_base $(ARCHIVE)/$(GST_PLUGINS_BAD_SOURCE)
	$(UNTAR)/$(GST_PLUGINS_BAD_SOURCE)
	set -e; cd $(BUILD_TMP)/gst-plugins-bad-$(GST_PLUGINS_BAD_VER); \
		$(PATCH)/gst-plugins-bad-$(GSTREAMER_VER)-Makefile.am-don-t-hardcode-libtool-name-when-running-pbad.patch; \
		$(PATCH)/gst-plugins-bad-$(GSTREAMER_VER)-rtmp-fix-seeking-and-potential-segfault.patch; \
		$(PATCH)/gst-plugins-bad-$(GSTREAMER_VER)-rtmp-hls-tsdemux-fix.patch; \
		$(PATCH)/gst-plugins-bad-$(GSTREAMER_VER)-configure-allow-to-disable-libssh2.patch; \
		$(PATCH)/gst-plugins-bad-$(GSTREAMER_VER)-dvbapi5-fix-old-kernel.patch; \
		$(PATCH)/gst-plugins-bad-$(GSTREAMER_VER)-fix-maybe-uninitialized-warnings-when-compiling-with-Os.patch; \
		$(PATCH)/gst-plugins-bad-$(GSTREAMER_VER)-hls-main-thread-block.patch; \
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
		$(MAKE) install DESTDIR=$(TARGETPREFIX)
	for i in `cd $(TARGETPREFIX)/lib/gstreamer-1.0; echo *.la`; do \
		$(REWRITE_LIBTOOL)/gstreamer-1.0/$$i; done
	$(REWRITE_PKGCONF) $(PKG_CONFIG_PATH)/gstreamer-codecparsers-1.0.pc
	$(REWRITE_PKGCONF) $(PKG_CONFIG_PATH)/gstreamer-bad-audio-1.0.pc
	$(REWRITE_PKGCONF) $(PKG_CONFIG_PATH)/gstreamer-bad-base-1.0.pc
	$(REWRITE_PKGCONF) $(PKG_CONFIG_PATH)/gstreamer-bad-video-1.0.pc
	$(REWRITE_PKGCONF) $(PKG_CONFIG_PATH)/gstreamer-insertbin-1.0.pc
	$(REWRITE_PKGCONF) $(PKG_CONFIG_PATH)/gstreamer-mpegts-1.0.pc
	$(REWRITE_PKGCONF) $(PKG_CONFIG_PATH)/gstreamer-player-1.0.pc
	$(REWRITE_PKGCONF) $(PKG_CONFIG_PATH)/gstreamer-plugins-bad-1.0.pc
	$(REWRITE_LIBTOOL)/libgstbasecamerabinsrc-1.0.la
	$(REWRITE_LIBTOOL)/libgstcodecparsers-1.0.la
	$(REWRITE_LIBTOOL)/libgstphotography-1.0.la
	$(REWRITE_LIBTOOL)/libgstadaptivedemux-1.0.la
	$(REWRITE_LIBTOOL)/libgstbadbase-1.0.la
	$(REWRITE_LIBTOOL)/libgstbadaudio-1.0.la
	$(REWRITE_LIBTOOL)/libgstbadvideo-1.0.la
	$(REWRITE_LIBTOOL)/libgstinsertbin-1.0.la
	$(REWRITE_LIBTOOL)/libgstmpegts-1.0.la
	$(REWRITE_LIBTOOL)/libgstplayer-1.0.la
	$(REWRITE_LIBTOOL)/libgsturidownloader-1.0.la
	$(REWRITE_LIBTOOLDEP)/libgstbadaudio-1.0.la
	$(REWRITE_LIBTOOLDEP)/libgstadaptivedemux-1.0.la
	$(REWRITE_LIBTOOLDEP)/libgstbadvideo-1.0.la
	$(REMOVE)/gst-plugins-bad-$(GST_PLUGINS_BAD_VER)
	touch $@

#
# gst_plugins_ugly
#
GST_PLUGINS_UGLY_VER = $(GSTREAMER_VER)
GST_PLUGINS_UGLY_SOURCE = gst-plugins-ugly-$(GST_PLUGINS_UGLY_VER).tar.xz

$(ARCHIVE)/$(GST_PLUGINS_UGLY_SOURCE):
	$(WGET) https://gstreamer.freedesktop.org/src/gst-plugins-ugly/$(GST_PLUGINS_UGLY_SOURCE)

$(D)/gst_plugins_ugly: $(D)/gstreamer $(D)/gst_plugins_base $(ARCHIVE)/$(GST_PLUGINS_UGLY_SOURCE)
	$(UNTAR)/$(GST_PLUGINS_UGLY_SOURCE)
	set -e; cd $(BUILD_TMP)/gst-plugins-ugly-$(GST_PLUGINS_UGLY_VER); \
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
		$(MAKE) install DESTDIR=$(TARGETPREFIX)
	for i in `cd $(TARGETPREFIX)/lib/gstreamer-1.0; echo *.la`; do \
		$(REWRITE_LIBTOOL)/gstreamer-1.0/$$i; done
	$(REMOVE)/gst-plugins-ugly-$(GST_PLUGINS_UGLY_VER)
	touch $@

#
# gst_plugin_subsink
#
GST_PLUGIN_SUBSINK_VER = 1.0

$(D)/gst_plugin_subsink: $(D)/gstreamer $(D)/gst_plugins_base $(D)/gst_plugins_good $(D)/gst_plugins_bad $(D)/gst_plugins_ugly
	set -e; if [ -d $(ARCHIVE)/gstreamer$(GST_PLUGIN_SUBSINK_VER)-plugin-subsink.git ]; \
		then cd $(ARCHIVE)/gstreamer$(GST_PLUGIN_SUBSINK_VER)-plugin-subsink.git; git pull; \
		else cd $(ARCHIVE); git clone git://github.com/christophecvr/gstreamer$(GST_PLUGIN_SUBSINK_VER)-plugin-subsink.git gstreamer$(GST_PLUGIN_SUBSINK_VER)-plugin-subsink.git; \
		fi
	cp -ra $(ARCHIVE)/gstreamer$(GST_PLUGIN_SUBSINK_VER)-plugin-subsink.git $(BUILD_TMP)/gstreamer$(GST_PLUGIN_SUBSINK_VER)-plugin-subsink
	set -e; cd $(BUILD_TMP)/gstreamer$(GST_PLUGIN_SUBSINK_VER)-plugin-subsink; \
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
		$(MAKE) install DESTDIR=$(TARGETPREFIX)
	for i in `cd $(TARGETPREFIX)/lib/gstreamer-1.0; echo *.la`; do \
		$(REWRITE_LIBTOOL)/gstreamer-1.0/$$i; done
	$(REMOVE)/gstreamer$(GST_PLUGIN_SUBSINK_VER)-plugin-subsink
	touch $@

#
# gst_plugins_dvbmediasink
#
GST_PLUGINS_DVBMEDIASINK_VER = 1.0

$(D)/gst_plugins_dvbmediasink: $(D)/gstreamer $(D)/gst_plugins_base $(D)/gst_plugins_good $(D)/gst_plugins_bad $(D)/gst_plugins_ugly $(D)/gst_plugin_subsink $(D)/libdca
	set -e; if [ -d $(ARCHIVE)/gstreamer$(GST_PLUGINS_DVBMEDIASINK_VER)-plugin-dvbmediasink.git ]; \
		then cd $(ARCHIVE)/gstreamer$(GST_PLUGINS_DVBMEDIASINK_VER)-plugin-dvbmediasink.git; git pull; \
		else cd $(ARCHIVE); git clone -b gst-1.0 https://github.com/OpenPLi/gst-plugin-dvbmediasink.git gstreamer$(GST_PLUGINS_DVBMEDIASINK_VER)-plugin-dvbmediasink.git; \
		fi
	cp -ra $(ARCHIVE)/gstreamer$(GST_PLUGINS_DVBMEDIASINK_VER)-plugin-dvbmediasink.git $(BUILD_TMP)/gstreamer$(GST_PLUGINS_DVBMEDIASINK_VER)-plugin-dvbmediasink
	set -e; cd $(BUILD_TMP)/gstreamer$(GST_PLUGINS_DVBMEDIASINK_VER)-plugin-dvbmediasink; \
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
		$(MAKE) install DESTDIR=$(TARGETPREFIX)
	for i in `cd $(TARGETPREFIX)/lib/gstreamer-1.0; echo *.la`; do \
		$(REWRITE_LIBTOOL)/gstreamer-1.0/$$i; done
	$(REMOVE)/gstreamer$(GST_PLUGINS_DVBMEDIASINK_VER)-plugin-dvbmediasink
	touch $@

##########################################################################################################

#
# orc
#
ORC_VER = 0.4.27
ORC_SOURCE = orc-$(ORC_VER).tar.xz

$(ARCHIVE)/$(ORC_SOURCE):
	$(WGET) https://gstreamer.freedesktop.org/src/orc/$(ORC_SOURCE)

$(D)/orc: $(ARCHIVE)/$(ORC_SOURCE)
	$(UNTAR)/$(ORC_SOURCE)
	set -e; cd $(BUILD_TMP)/orc-$(ORC_VER); \
		$(CONFIGURE) \
			--datarootdir=/.remove \
			--prefix= \
		; \
		$(MAKE) all; \
		$(MAKE) install DESTDIR=$(TARGETPREFIX)
	$(REWRITE_PKGCONF) $(PKG_CONFIG_PATH)/orc-0.4.pc
	$(REWRITE_LIBTOOL)/liborc-0.4.la
	$(REWRITE_LIBTOOL)/liborc-test-0.4.la
	$(REWRITE_LIBTOOLDEP)/liborc-test-0.4.la
	rm -f $(addprefix $(TARGETPREFIX)/bin/,orc-bugreport orcc)
	$(REMOVE)/orc-$(ORC_VER)
	touch $@

#
# libdca
#
LIBDCA_VER = 0.0.5
LIBDCA_SOURCE = libdca-$(LIBDCA_VER).tar.bz2

$(ARCHIVE)/$(LIBDCA_SOURCE):
	$(WGET) http://download.videolan.org/pub/videolan/libdca/$(LIBDCA_VER)/$(LIBDCA_SOURCE)

$(D)/libdca: $(ARCHIVE)/$(LIBDCA_SOURCE)
	$(UNTAR)/$(LIBDCA_SOURCE)
	set -e; cd $(BUILD_TMP)/libdca-$(LIBDCA_VER); \
		$(CONFIGURE) \
			--prefix= \
			--mandir=/.remove \
		; \
		$(MAKE) all; \
		$(MAKE) install DESTDIR=$(TARGETPREFIX)
	$(REWRITE_PKGCONF) $(PKG_CONFIG_PATH)/libdca.pc
	$(REWRITE_PKGCONF) $(PKG_CONFIG_PATH)/libdts.pc
	$(REWRITE_LIBTOOL)/libdca.la
	rm -f $(addprefix $(TARGETPREFIX)/bin/,extract_dca extract_dts)
	$(REMOVE)/libdca-$(LIBDCA_VER)
	touch $@

#
# nettle
#
NETTLE_VER = 3.3
NETTLE_SOURCE = nettle-$(NETTLE_VER).tar.gz

$(ARCHIVE)/$(NETTLE_SOURCE):
	$(WGET) https://ftp.gnu.org/gnu/nettle/$(NETTLE_SOURCE)

$(D)/nettle: $(D)/gmp $(ARCHIVE)/$(NETTLE_SOURCE)
	$(UNTAR)/$(NETTLE_SOURCE)
	set -e; cd $(BUILD_TMP)/nettle-$(NETTLE_VER); \
		$(PATCH)/nettle-$(NETTLE_VER).patch; \
		$(CONFIGURE) \
			--prefix= \
			--disable-documentation \
		; \
		$(MAKE) all; \
		$(MAKE) install DESTDIR=$(TARGETPREFIX)
	$(REWRITE_PKGCONF) $(PKG_CONFIG_PATH)/hogweed.pc
	$(REWRITE_PKGCONF) $(PKG_CONFIG_PATH)/nettle.pc
	rm -f $(addprefix $(TARGETPREFIX)/bin/,sexp-conv nettle-hash nettle-pbkdf2 nettle-lfib-stream pkcs1-conv)
	$(REMOVE)/nettle-$(NETTLE_VER)
	touch $@

#
# gmp
#
GMP_VER_MAJOR = 6.1.2
GMP_VER_MINOR =
GMP_VER = $(GMP_VER_MAJOR)$(GMP_VER_MINOR)
GMP_SOURCE = gmp-$(GMP_VER).tar.xz

$(ARCHIVE)/$(GMP_SOURCE):
	$(WGET) ftp://ftp.gmplib.org/pub/gmp-$(GMP_VER_MAJOR)/$(GMP_SOURCE)

$(D)/gmp: $(ARCHIVE)/$(GMP_SOURCE)
	$(UNTAR)/$(GMP_SOURCE)
	set -e; cd $(BUILD_TMP)/gmp-$(GMP_VER_MAJOR); \
		$(CONFIGURE) \
			--prefix= \
			--infodir=/.remove \
		; \
		$(MAKE); \
		$(MAKE) install DESTDIR=$(TARGETPREFIX)
	$(REWRITE_LIBTOOL)/libgmp.la
	$(REMOVE)/gmp-$(GMP_VER_MAJOR)
	touch $@

#
# gnutls
#
GNUTLS_VER_MAJOR = 3.6
GNUTLS_VER_MINOR = 0
GNUTLS_VER = $(GNUTLS_VER_MAJOR).$(GNUTLS_VER_MINOR)
GNUTLS_SOURCE = gnutls-$(GNUTLS_VER).tar.xz

$(ARCHIVE)/$(GNUTLS_SOURCE):
	$(WGET) ftp://ftp.gnutls.org/gcrypt/gnutls/v$(GNUTLS_VER_MAJOR)/$(GNUTLS_SOURCE)

$(D)/gnutls: $(D)/nettle $(D)/ca-bundle $(ARCHIVE)/$(GNUTLS_SOURCE)
	$(UNTAR)/$(GNUTLS_SOURCE)
	set -e; cd $(BUILD_TMP)/gnutls-$(GNUTLS_VER); \
		$(CONFIGURE) \
			--prefix= \
			--mandir=/.remove \
			--infodir=/.remove \
			--datarootdir=/.remove \
			--with-included-libtasn1 \
			--enable-local-libopts \
			--with-libpthread-prefix=$(TARGETPREFIX) \
			--with-included-unistring \
			--with-default-trust-store-dir=$(CA_BUNDLE_DIR)/ \
			--disable-guile \
			--without-p11-kit \
		; \
		$(MAKE); \
		$(MAKE) install DESTDIR=$(TARGETPREFIX)
	$(REWRITE_PKGCONF) $(PKG_CONFIG_PATH)/gnutls.pc
	$(REWRITE_LIBTOOL)/libgnutls.la
	$(REWRITE_LIBTOOL)/libgnutlsxx.la
	$(REWRITE_LIBTOOLDEP)/libgnutlsxx.la
	rm -f $(addprefix $(TARGETPREFIX)/bin/,psktool gnutls-cli-debug certtool srptool ocsptool gnutls-serv gnutls-cli)
	$(REMOVE)/gnutls-$(GNUTLS_VER)
	touch $@

#
# glib-networking
#
GLIB_NETWORKING_VER_MAJOR = 2.54
GLIB_NETWORKING_VER_MINOR = 0
GLIB_NETWORKING_VER = $(GLIB_NETWORKING_VER_MAJOR).$(GLIB_NETWORKING_VER_MINOR)
GLIB_NETWORKING_SOURCE = glib-networking-$(GLIB_NETWORKING_VER).tar.xz

$(ARCHIVE)/$(GLIB_NETWORKING_SOURCE):
	$(WGET) https://ftp.acc.umu.se/pub/GNOME/sources/glib-networking/$(GLIB_NETWORKING_VER_MAJOR)/$(GLIB_NETWORKING_SOURCE)

$(D)/glib_networking: $(D)/gnutls $(D)/libglib2 $(ARCHIVE)/$(GLIB_NETWORKING_SOURCE)
	$(UNTAR)/$(GLIB_NETWORKING_SOURCE)
	set -e; cd $(BUILD_TMP)/glib-networking-$(GLIB_NETWORKING_VER); \
		$(CONFIGURE) \
			--prefix= \
			--datadir=/.remove \
			--datarootdir=/.remove \
			--localedir=/.remove \
		; \
		$(MAKE); \
		$(MAKE) install prefix=$(TARGETPREFIX)
	$(REMOVE)/glib-networking-$(GLIB_NETWORKING_VER)
	touch $@

#
# alsa_lib
#
ALSA_LIB_VER = 1.1.4.1
ALSA_LIB_SOURCE = alsa-lib-$(ALSA_LIB_VER).tar.bz2

$(ARCHIVE)/$(ALSA_LIB_SOURCE):
	$(WGET) ftp://ftp.alsa-project.org/pub/lib/$(ALSA_LIB_SOURCE)

$(D)/alsa_lib: $(ARCHIVE)/$(ALSA_LIB_SOURCE)
	$(UNTAR)/$(ALSA_LIB_SOURCE)
	set -e; cd $(BUILD_TMP)/alsa-lib-$(ALSA_LIB_VER); \
		$(PATCH)/alsa-lib-$(ALSA_LIB_VER)-link_fix.patch; \
		$(PATCH)/alsa-lib-$(ALSA_LIB_VER).patch; \
		$(CONFIGURE) \
			--prefix= \
			--datarootdir=/.remove \
			--with-alsa-devdir=/dev/snd/ \
			--with-plugindir=/lib/alsa \
			--without-debug \
			--with-debug=no \
			--with-versioned=no \
			--enable-symbolic-functions \
			--disable-aload \
			--disable-rawmidi \
			--disable-resmgr \
			--disable-old-symbols \
			--disable-alisp \
			--disable-hwdep \
			--disable-python \
		; \
		$(MAKE); \
		$(MAKE) install DESTDIR=$(TARGETPREFIX)
	$(REWRITE_PKGCONF) $(PKG_CONFIG_PATH)/alsa.pc
	$(REWRITE_LIBTOOL)/libasound.la
	$(REMOVE)/alsa-lib-$(ALSA_LIB_VER)
	touch $@

#
# libsoup
#
LIBSOUP_VER_MAJOR = 2.60
LIBSOUP_VER_MINOR = 0
LIBSOUP_VER = $(LIBSOUP_VER_MAJOR).$(LIBSOUP_VER_MINOR)
LIBSOUP_SOURCE = libsoup-$(LIBSOUP_VER).tar.xz

$(ARCHIVE)/$(LIBSOUP_SOURCE):
	$(WGET) https://download.gnome.org/sources/libsoup/$(LIBSOUP_VER_MAJOR)/$(LIBSOUP_SOURCE)

$(D)/libsoup: $(D)/sqlite $(D)/libxml2 $(D)/libglib2 $(ARCHIVE)/$(LIBSOUP_SOURCE)
	$(UNTAR)/$(LIBSOUP_SOURCE)
	set -e; cd $(BUILD_TMP)/libsoup-$(LIBSOUP_VER); \
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
		$(MAKE) install DESTDIR=$(TARGETPREFIX) itlocaledir=$$(TARGETPREFIX)/.remove
	$(REWRITE_PKGCONF) $(PKG_CONFIG_PATH)/libsoup-2.4.pc
	$(REWRITE_LIBTOOL)/libsoup-2.4.la
	$(REMOVE)/libsoup-$(LIBSOUP_VER)
	touch $@

#
# sqlite
#
SQLITE_VER = 3200100
SQLITE_SOURCE = sqlite-autoconf-$(SQLITE_VER).tar.gz

$(ARCHIVE)/$(SQLITE_SOURCE):
	$(WGET) http://www.sqlite.org/2017/$(SQLITE_SOURCE)

$(D)/sqlite: $(ARCHIVE)/$(SQLITE_SOURCE)
	$(UNTAR)/$(SQLITE_SOURCE)
	set -e; cd $(BUILD_TMP)/sqlite-autoconf-$(SQLITE_VER); \
		$(CONFIGURE) \
			--prefix= \
			--mandir=/.remove \
		; \
		$(MAKE) all; \
		$(MAKE) install DESTDIR=$(TARGETPREFIX)
	$(REWRITE_PKGCONF) $(PKG_CONFIG_PATH)/sqlite3.pc
	$(REWRITE_LIBTOOL)/libsqlite3.la
	rm -f $(addprefix $(TARGETPREFIX)/bin/,sqlite3)
	$(REMOVE)/sqlite-autoconf-$(SQLITE_VER)
	touch $@
