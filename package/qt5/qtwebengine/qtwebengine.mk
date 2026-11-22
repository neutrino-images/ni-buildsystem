################################################################################
#
# qtwebengine
#
################################################################################

QTWEBENGINE_VERSION = $(QT5_VERSION)
QTWEBENGINE_DIR = qtwebengine-v$(QTWEBENGINE_VERSION)-lts
QTWEBENGINE_SOURCE = qtwebengine-v$(QTWEBENGINE_VERSION)-lts.tar.bz2
QTWEBENGINE_SITE = $(QT5_SITE)/qtwebengine/-/archive/v$(QTWEBENGINE_VERSION)-lts

# src/3rdparty is a submodule, the archive of the tag lacks it: chromium
# (and gn) of KDE's branch, the commit buildroot uses for 5.15.19
QTWEBENGINE_CHROMIUM_VERSION = 6d29e9cfcfffa7632cc3858ceaf8940677ba9c91
QTWEBENGINE_CHROMIUM_SOURCE = qtwebengine-chromium-$(QTWEBENGINE_CHROMIUM_VERSION).tar.bz2
QTWEBENGINE_CHROMIUM_SITE = $(QT5_SITE)/qtwebengine-chromium/-/archive/$(QTWEBENGINE_CHROMIUM_VERSION)

# the catapult of that chromium is python 2 only; a later one runs with
# python 3 (as buildroot)
QTWEBENGINE_CATAPULT_VERSION = 7534569f99827c0ed4df818254ba7daca4606bca
QTWEBENGINE_CATAPULT_SOURCE = qt5webengine-chromium-catapult-$(QTWEBENGINE_CATAPULT_VERSION).tar.gz
QTWEBENGINE_CATAPULT_SITE = https://chromium.googlesource.com/catapult/+archive

define QTWEBENGINE_DOWNLOAD_CHROMIUM
	if [ ! -f $(DL_DIR)/$(QTWEBENGINE_CHROMIUM_SOURCE) ]; then \
		$(GET_ARCHIVE) $(DL_DIR) $(QTWEBENGINE_CHROMIUM_SITE)/$(QTWEBENGINE_CHROMIUM_SOURCE); \
	fi
	if [ ! -f $(DL_DIR)/$(QTWEBENGINE_CATAPULT_SOURCE) ]; then \
		wget --no-check-certificate -t3 -T60 -O $(DL_DIR)/$(QTWEBENGINE_CATAPULT_SOURCE).part \
			$(QTWEBENGINE_CATAPULT_SITE)/$(QTWEBENGINE_CATAPULT_VERSION).tar.gz && \
		mv $(DL_DIR)/$(QTWEBENGINE_CATAPULT_SOURCE).part $(DL_DIR)/$(QTWEBENGINE_CATAPULT_SOURCE); \
	fi
endef
QTWEBENGINE_PRE_DOWNLOAD_HOOKS += QTWEBENGINE_DOWNLOAD_CHROMIUM

# before the patches, they touch chromium too
define QTWEBENGINE_EXTRACT_CHROMIUM
	rm -rf $(PKG_BUILD_DIR)/src/3rdparty
	$(INSTALL) -d $(PKG_BUILD_DIR)/src/3rdparty
	tar -C $(PKG_BUILD_DIR)/src/3rdparty --strip-components=1 \
		-xjf $(DL_DIR)/$(QTWEBENGINE_CHROMIUM_SOURCE)
	rm -rf $(PKG_BUILD_DIR)/src/3rdparty/chromium/third_party/catapult
	$(INSTALL) -d $(PKG_BUILD_DIR)/src/3rdparty/chromium/third_party/catapult
	tar -C $(PKG_BUILD_DIR)/src/3rdparty/chromium/third_party/catapult \
		-xzf $(DL_DIR)/$(QTWEBENGINE_CATAPULT_SOURCE)
endef
QTWEBENGINE_PRE_PATCH_HOOKS += QTWEBENGINE_EXTRACT_CHROMIUM

# host: python 3 (host-python3), nodejs, gperf, bison, flex, ninja, the
# host dev packages of the README and a 32-bit capable g++ (g++-multilib)
# for the v8 snapshot of 32-bit ARM
QTWEBENGINE_DEPENDENCIES = \
	host-python3 \
	qtdeclarative qtwebchannel \
	nss dbus ffmpeg opus libwebp alsa-lib \
	fontconfig freetype harfbuzz libpng libjpeg-turbo zlib

# chromium dlopen()s libudev.so.1 and stops (CHECK) without it; the image
# runs mdev, so use the daemonless libudev
QTWEBENGINE_DEPENDENCIES += libudev-zero

QTWEBENGINE_WRAP_DIR = $(PKG_BUILD_DIR)/cross-wrapper

# the wrappers carry the target compiler names and come first in PATH, so
# only the target toolchain goes through them, the host one does not;
# python2, python3 and python are searched in that order by configure:
# the host python 3 is found first (no python2 on the host)
QTWEBENGINE_ENV = \
	PATH=$(QTWEBENGINE_WRAP_DIR):$(PATH) \
	PKG_CONFIG="$(PKG_CONFIG)" \
	PKG_CONFIG_LIBDIR="$(PKG_CONFIG_PATH)" \
	PKG_CONFIG_SYSROOT_DIR="$(PKG_CONFIG_SYSROOT_DIR)" \
	GN_PKG_CONFIG_HOST=$(QTWEBENGINE_WRAP_DIR)/host-pkg-config \
	NINJAFLAGS="-j$(shell nproc)"

# CC_host/CXX_host: host compiler of the host and gn toolchains (the
# host toolchain patch takes them from qmake, as OE passes them)
QTWEBENGINE_QMAKE_OPTS = \
	QMAKE_PYTHON2=$(HOST_PYTHON_BINARY) \
	CC_host=gcc \
	CXX_host=g++ \
	-- \
	-feature-webengine-embedded-build \
	-feature-webengine-system-ninja \
	-no-feature-webengine-system-gn \
	-feature-webengine-proprietary-codecs \
	-feature-webengine-system-ffmpeg \
	-feature-webengine-system-opus \
	-feature-webengine-system-libwebp \
	-feature-webengine-alsa \
	-no-feature-webengine-pulseaudio \
	-feature-webengine-system-png \
	-feature-webengine-system-jpeg \
	-feature-webengine-system-zlib \
	-feature-webengine-system-harfbuzz \
	-feature-webengine-system-freetype \
	-feature-webengine-system-fontconfig \
	-no-feature-webengine-system-glib \
	-no-feature-webengine-system-libevent \
	-no-feature-webengine-system-icu \
	-no-feature-webengine-system-libvpx \
	-no-feature-webengine-system-minizip \
	-no-feature-webengine-system-re2 \
	-no-feature-webengine-system-snappy \
	-no-feature-webengine-system-lcms2 \
	-no-feature-webengine-system-libxml2 \
	-no-feature-webengine-geolocation \
	-no-feature-webengine-spellchecker \
	-no-feature-webengine-printing-and-pdf \
	-no-feature-webengine-webrtc \
	-no-feature-webengine-pepper-plugins \
	-no-feature-webengine-kerberos \
	-no-feature-webengine-extensions \
	-no-feature-build-qtpdf

define QTWEBENGINE_CROSS_WRAPPER
	$(INSTALL) -d $(QTWEBENGINE_WRAP_DIR)
	for c in $(TARGET_CC) $(TARGET_CXX); do \
		sed "s|@COMPILER@|$(CROSS_DIR)/bin/$$c|" $(PKG_FILES_DIR)/cross-wrapper.in > $(QTWEBENGINE_WRAP_DIR)/$$c; \
		chmod 755 $(QTWEBENGINE_WRAP_DIR)/$$c; \
	done
	$(INSTALL_EXEC) $(PKG_FILES_DIR)/host-pkg-config.in $(QTWEBENGINE_WRAP_DIR)/host-pkg-config
	ln -sf $(HOST_PYTHON_BINARY) $(QTWEBENGINE_WRAP_DIR)/python3
	ln -sf $(HOST_PYTHON_BINARY) $(QTWEBENGINE_WRAP_DIR)/python
endef
QTWEBENGINE_PRE_CONFIGURE_HOOKS += QTWEBENGINE_CROSS_WRAPPER

define QTWEBENGINE_CONFIGURE_CMDS
	$(CD) $(PKG_BUILD_DIR); \
		$(QTWEBENGINE_ENV) $(QT5_QMAKE) $(QTWEBENGINE_QMAKE_OPTS)
endef

# configure only warns when a host tool (nodejs, g++-multilib, ...) is
# missing and then builds an empty module; stop here instead
define QTWEBENGINE_CHECK_CORE
	if [ ! -e $(PKG_BUILD_DIR)/lib/libQt5WebEngineCore.so.5 ]; then \
		echo "qtwebengine: QtWebEngineCore was not built, see 'will not be built' above"; \
		exit 1; \
	fi
endef
QTWEBENGINE_POST_BUILD_HOOKS += QTWEBENGINE_CHECK_CORE

define QTWEBENGINE_BUILD_CMDS
	$(CD) $(PKG_BUILD_DIR); \
		$(QTWEBENGINE_ENV) $(MAKE)
endef

define QTWEBENGINE_INSTALL_CMDS
	$(CD) $(PKG_BUILD_DIR); \
		$(QTWEBENGINE_ENV) $(MAKE) install
endef

QTWEBENGINE_PRE_CONFIGURE_HOOKS += QT5_SYNC_QT_HEADERS

qtwebengine: | $(TARGET_DIR)
	$(call generic-package)
