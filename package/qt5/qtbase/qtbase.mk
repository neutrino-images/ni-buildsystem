################################################################################
#
# qtbase
#
################################################################################

# the 5.15.19 LTS state of KDE's branch (as buildroot)
QTBASE_VERSION = fbed962c3195ab3952fa54d40e012ad1a4fdc42b
QTBASE_DIR = qtbase-$(QTBASE_VERSION)
QTBASE_SOURCE = qtbase-$(QTBASE_VERSION).tar.bz2
QTBASE_SITE = $(QT5_SITE)/qtbase/-/archive/$(QTBASE_VERSION)

QTBASE_DEPENDENCIES = zlib openssl freetype fontconfig harfbuzz libpng libjpeg-turbo

# EGL/GLES through the Broadcom Nexus platform layer (eglfs_nxpl)
ifeq ($(BOXMODEL),$(filter $(BOXMODEL),hd51 bre2ze4k h7 e4hdultra protek4k))
QTBASE_DEPENDENCIES += hd5x-libgles khronos-headers
QTBASE_EGLFS_DEVICE = EGLFS_DEVICE_INTEGRATION = eglfs_nxpl
QTBASE_GL_OPTS = -opengl es2 -eglfs -feature-eglfs_nxpl -qpa eglfs
else
QTBASE_EGLFS_DEVICE =
QTBASE_GL_OPTS = -no-opengl -no-eglfs -qpa linuxfb
endif

QTBASE_MKSPEC_DIR = $(PKG_BUILD_DIR)/mkspecs/devices/linux-nibuild-g++

# -no-libudev: the image runs mdev; libudev-zero (there for chromium) makes
# the udev device discovery of evdev/eglfs crash at start (pthread_join)
QTBASE_CONF_OPTS = \
	-v \
	-prefix $(prefix) \
	-hostprefix $(HOST_DIR) \
	-headerdir $(prefix)/include/qt5 \
	-plugindir $(prefix)/lib/qt/plugins \
	-examplesdir $(prefix)/lib/qt/examples \
	-sysroot $(TARGET_DIR) \
	-no-gcc-sysroot \
	-device nibuild \
	-device-option CROSS_COMPILE="$(TARGET_CROSS)" \
	-device-option NI_CFLAGS="$(TARGET_CFLAGS)" \
	-device-option NI_CXXFLAGS="$(TARGET_CXXFLAGS)" \
	-device-option NI_LDFLAGS="$(TARGET_LDFLAGS)" \
	-device-option NI_INCDIR="$(TARGET_includedir)" \
	-opensource -confirm-license \
	-release -shared -no-pch -no-rpath \
	-optimized-qmake \
	-no-feature-relocatable \
	-nomake tests -nomake examples \
	-no-iconv -no-icu -no-dbus -no-glib -no-cups -no-gtk \
	-no-journald -no-syslog -no-zstd -no-tslib -no-libinput \
	-no-libudev \
	-no-xcb -no-kms -no-gbm -no-directfb -no-feature-vulkan \
	-system-zlib -qt-pcre -system-freetype -system-harfbuzz \
	-system-libpng -system-libjpeg -fontconfig \
	-openssl-linked \
	-gui -widgets -linuxfb -evdev \
	-no-sql-mysql -no-sql-psql -no-sql-sqlite \
	$(QTBASE_GL_OPTS)

define QTBASE_CONFIGURE_CMDS
	$(INSTALL) -d $(QTBASE_MKSPEC_DIR)
	sed 's/@EGLFS_DEVICE@/$(QTBASE_EGLFS_DEVICE)/' $(PKG_FILES_DIR)/qmake.conf.in > $(QTBASE_MKSPEC_DIR)/qmake.conf
	$(INSTALL_DATA) $(PKG_FILES_DIR)/qplatformdefs.h $(QTBASE_MKSPEC_DIR)/qplatformdefs.h
	$(CD) $(PKG_BUILD_DIR); \
		$(TARGET_MAKE_ENV) \
		PKG_CONFIG="$(PKG_CONFIG)" \
		PKG_CONFIG_LIBDIR="$(PKG_CONFIG_PATH)" \
		PKG_CONFIG_SYSROOT_DIR="$(PKG_CONFIG_SYSROOT_DIR)" \
		./configure $(QTBASE_CONF_OPTS)
endef

define QTBASE_INSTALL_CMDS
	$(CD) $(PKG_BUILD_DIR); \
		$(TARGET_MAKE_ENV) $(MAKE) install
endef

QTBASE_PRE_CONFIGURE_HOOKS += QT5_SYNC_QT_HEADERS

qtbase: | $(TARGET_DIR)
	$(call generic-package)
