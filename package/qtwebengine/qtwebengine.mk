################################################################################
#
# qtwebengine
#
################################################################################

QTWEBENGINE_VERSION = $(QT5_VERSION)
QTWEBENGINE_DIR = qtwebengine-everywhere-src-$(QTWEBENGINE_VERSION)
QTWEBENGINE_SOURCE = qtwebengine-everywhere-opensource-src-$(QTWEBENGINE_VERSION).tar.xz
QTWEBENGINE_SITE = $(QT5_SITE)

# host: python 2.7 (host-python2), nodejs, gperf, bison, flex, ninja, the
# host dev packages of the README and a 32-bit capable g++ (g++-multilib)
# for the v8 snapshot of 32-bit ARM
QTWEBENGINE_DEPENDENCIES = \
	host-python2 \
	qtdeclarative qtwebchannel \
	nss dbus ffmpeg opus libwebp alsa-lib \
	fontconfig freetype harfbuzz libpng libjpeg-turbo zlib

# chromium dlopen()s libudev.so.1 and stops (CHECK) without it; the image
# runs mdev, so use the daemonless libudev
QTWEBENGINE_DEPENDENCIES += libudev-zero

QTWEBENGINE_WRAP_DIR = $(PKG_BUILD_DIR)/cross-wrapper

# the wrappers carry the target compiler names and come first in PATH, so
# only the target toolchain goes through them, the host one does not;
# python2 there is what configure looks for
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
	QMAKE_PYTHON2=$(HOST_PYTHON2_BINARY) \
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
	ln -sf $(HOST_PYTHON2_BINARY) $(QTWEBENGINE_WRAP_DIR)/python2
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

qtwebengine: | $(TARGET_DIR)
	$(call generic-package)
