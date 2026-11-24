################################################################################
#
# qt5webengine
#
################################################################################

QT5WEBENGINE_VERSION = $(QT5_VERSION)
QT5WEBENGINE_DIR = qtwebengine-v$(QT5WEBENGINE_VERSION)-lts
QT5WEBENGINE_SOURCE = qtwebengine-v$(QT5WEBENGINE_VERSION)-lts.tar.bz2
QT5WEBENGINE_SITE = $(QT5_SITE)/qtwebengine/-/archive/v$(QT5WEBENGINE_VERSION)-lts

# src/3rdparty is a submodule the archive of the tag lacks: chromium,
# unpacked and patched by qt5webengine-chromium (as in Buildroot)
define QT5WEBENGINE_COPY_CHROMIUM
	rm -rf $(PKG_BUILD_DIR)/src/3rdparty
	cp -a $(BUILD_DIR)/$(QT5WEBENGINE_CHROMIUM_DIR) $(PKG_BUILD_DIR)/src/3rdparty
endef
QT5WEBENGINE_POST_PATCH_HOOKS += QT5WEBENGINE_COPY_CHROMIUM

# host: python 3 (host-python3), node (host-nodejs), ninja (host-ninja),
# the system libraries for the host toolchain of chromium (host-nss,
# host-libwebp, ..., as in Buildroot), gperf, bison, flex, the host dev
# packages of the README and a 32-bit capable g++ (g++-multilib) for the
# v8 snapshot of 32-bit ARM
QT5WEBENGINE_DEPENDENCIES = \
	host-python3 host-nodejs host-ninja \
	host-nss host-libwebp host-freetype host-harfbuzz \
	host-libjpeg-turbo host-libpng host-zlib \
	qt5declarative qt5webchannel qt5webengine-chromium \
	nss dbus ffmpeg opus libwebp alsa-lib \
	fontconfig freetype harfbuzz libpng libjpeg-turbo zlib

# chromium dlopen()s libudev.so.1 and stops (CHECK) without it; the image
# runs mdev, so use the daemonless libudev
QT5WEBENGINE_DEPENDENCIES += libudev-zero

QT5WEBENGINE_WRAP_DIR = $(PKG_BUILD_DIR)/cross-wrapper

# the wrappers carry the target compiler names and come first in PATH, so
# only the target toolchain goes through them, the host one does not;
# configure would take a python2 of the build host first, so
# -webengine-python-version selects python3, the one in the wrapper dir;
# configure and chromium look for nodejs before node in all of PATH, so
# both names in the wrapper dir point to the node of host-nodejs;
# host/include and host/lib for the host toolchain: libjpeg comes in
# without pkg-config, and the rpath lets host tools find the libraries
# when they run (chromium's pkg-config.py passes on only -I, -L and -l)
QT5WEBENGINE_ENV = \
	PATH=$(QT5WEBENGINE_WRAP_DIR):$(PATH) \
	PKG_CONFIG="$(PKG_CONFIG)" \
	PKG_CONFIG_LIBDIR="$(PKG_CONFIG_PATH)" \
	PKG_CONFIG_SYSROOT_DIR="$(PKG_CONFIG_SYSROOT_DIR)" \
	GN_PKG_CONFIG_HOST=$(QT5WEBENGINE_WRAP_DIR)/host-pkg-config \
	GN_HOST_TOOLCHAIN_EXTRA_CPPFLAGS="-I$(HOST_DIR)/include" \
	GN_HOST_TOOLCHAIN_EXTRA_LDFLAGS="-L$(HOST_DIR)/lib -Wl,-rpath,$(HOST_DIR)/lib" \
	NINJAFLAGS="-j$(QT5WEBENGINE_NINJA_JOBS)"

# ninja jobs: one per core, but at most one per 2 GB of memory; a compiler
# job on the big jumbo files of blink takes well over 1 GB, and with one
# job per core the OOM killer stopped cc1plus after hours; set
# QT5WEBENGINE_NINJA_JOBS in config.local to override
QT5WEBENGINE_NINJA_JOBS ?= $(shell \
	cpus=$$(nproc); \
	mem=$$(awk '/^MemTotal:/ { print int($$2 / 2097152) }' /proc/meminfo); \
	[ $$mem -lt 1 ] && mem=1; \
	[ $$mem -lt $$cpus ] && echo $$mem || echo $$cpus)

# CC_host/CXX_host: host compiler of the host and gn toolchains (the
# host toolchain patch takes them from qmake, as OE passes them); gcc and
# g++ in the wrapper directory add -w
QT5WEBENGINE_QMAKE_OPTS = \
	QMAKE_PYTHON2=$(HOST_PYTHON_BINARY) \
	CC_host=gcc \
	CXX_host=g++ \
	-- \
	-webengine-python-version python3 \
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

define QT5WEBENGINE_CROSS_WRAPPER
	$(INSTALL) -d $(QT5WEBENGINE_WRAP_DIR)
	for c in $(TARGET_CC) $(TARGET_CXX); do \
		sed "s|@COMPILER@|$(CROSS_DIR)/bin/$$c|" $(PKG_FILES_DIR)/cross-wrapper.in > $(QT5WEBENGINE_WRAP_DIR)/$$c; \
		chmod 755 $(QT5WEBENGINE_WRAP_DIR)/$$c; \
	done
	$(call QT5_HOST_COMPILER_WRAPPERS,$(QT5WEBENGINE_WRAP_DIR))
	sed "s|@HOST_DIR@|$(HOST_DIR)|" $(PKG_FILES_DIR)/host-pkg-config.in > $(QT5WEBENGINE_WRAP_DIR)/host-pkg-config
	chmod 755 $(QT5WEBENGINE_WRAP_DIR)/host-pkg-config
	ln -sf $(HOST_PYTHON_BINARY) $(QT5WEBENGINE_WRAP_DIR)/python3
	ln -sf $(HOST_PYTHON_BINARY) $(QT5WEBENGINE_WRAP_DIR)/python
	ln -sf $(HOST_DIR)/bin/node $(QT5WEBENGINE_WRAP_DIR)/nodejs
	ln -sf $(HOST_DIR)/bin/node $(QT5WEBENGINE_WRAP_DIR)/node
endef
QT5WEBENGINE_PRE_CONFIGURE_HOOKS += QT5WEBENGINE_CROSS_WRAPPER

# the v8 snapshot of 32-bit targets is built for the 32-bit variant of
# the host (toolchain v8_snapshot, g++ -m32); configure does not check
# that, and without g++-multilib the build stops hours later, so check
# here that g++ -m32 compiles, links and runs a C++ program
ifeq ($(shell uname -m),x86_64)
define QT5WEBENGINE_CHECK_M32
	printf '#include <cstddef>\n#include <string>\nint main() { return std::string("v8").size() == 2 ? 0 : 1; }\n' \
		> $(PKG_BUILD_DIR)/check-m32.cpp
	if ! g++ -m32 -o $(PKG_BUILD_DIR)/check-m32 $(PKG_BUILD_DIR)/check-m32.cpp || \
	   ! $(PKG_BUILD_DIR)/check-m32; then \
		echo "qt5webengine: 'g++ -m32' does not work, but the v8 snapshot needs it;"; \
		echo "qt5webengine: install g++-multilib (Debian, Ubuntu) or its equivalent"; \
		exit 1; \
	fi
	rm -f $(PKG_BUILD_DIR)/check-m32 $(PKG_BUILD_DIR)/check-m32.cpp
endef
QT5WEBENGINE_PRE_CONFIGURE_HOOKS += QT5WEBENGINE_CHECK_M32
endif

define QT5WEBENGINE_CONFIGURE_CMDS
	$(CD) $(PKG_BUILD_DIR); \
		$(QT5WEBENGINE_ENV) $(QT5_QMAKE) $(QT5WEBENGINE_QMAKE_OPTS)
endef

# configure only warns when a host tool (nodejs, g++-multilib, ...) is
# missing and then builds an empty module; stop here instead
define QT5WEBENGINE_CHECK_CORE
	if [ ! -e $(PKG_BUILD_DIR)/lib/libQt5WebEngineCore.so.5 ]; then \
		echo "qt5webengine: QtWebEngineCore was not built, see 'will not be built' above"; \
		exit 1; \
	fi
endef
QT5WEBENGINE_POST_BUILD_HOOKS += QT5WEBENGINE_CHECK_CORE

define QT5WEBENGINE_BUILD_CMDS
	@echo "qt5webengine: building with $(QT5WEBENGINE_NINJA_JOBS) ninja jobs ($$(nproc) cores, $$(awk '/^MemTotal:/ { print int($$2 / 1048576) }' /proc/meminfo) GB memory)"
	$(CD) $(PKG_BUILD_DIR); \
		$(QT5WEBENGINE_ENV) $(MAKE)
endef

define QT5WEBENGINE_INSTALL_CMDS
	$(CD) $(PKG_BUILD_DIR); \
		$(QT5WEBENGINE_ENV) $(MAKE) install
endef

QT5WEBENGINE_PRE_CONFIGURE_HOOKS += QT5_SYNC_QT_HEADERS

qt5webengine: | $(TARGET_DIR)
	$(call generic-package)
