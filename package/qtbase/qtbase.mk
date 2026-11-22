################################################################################
#
# qtbase
#
################################################################################

QTBASE_VERSION = $(QT5_VERSION)
QTBASE_DIR = qtbase-everywhere-src-$(QTBASE_VERSION)
QTBASE_SOURCE = qtbase-everywhere-opensource-src-$(QTBASE_VERSION).tar.xz
QTBASE_SITE = $(QT5_SITE)

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

qtbase: | $(TARGET_DIR)
	$(call generic-package)
