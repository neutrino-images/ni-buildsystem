################################################################################
#
# qt5base
#
################################################################################

# the 5.15.19 LTS state of KDE's branch (as buildroot)
QT5BASE_VERSION = fbed962c3195ab3952fa54d40e012ad1a4fdc42b
QT5BASE_DIR = qtbase-$(QT5BASE_VERSION)
QT5BASE_SOURCE = qtbase-$(QT5BASE_VERSION).tar.bz2
QT5BASE_SITE = $(QT5_SITE)/qtbase/-/archive/$(QT5BASE_VERSION)

QT5BASE_DEPENDENCIES = zlib openssl freetype fontconfig harfbuzz libpng libjpeg-turbo

# EGL/GLES through the Broadcom Nexus platform layer (eglfs_nxpl)
ifeq ($(BOXMODEL),$(filter $(BOXMODEL),hd51 bre2ze4k h7 e4hdultra protek4k))
QT5BASE_DEPENDENCIES += hd5x-libgles khronos-headers
QT5BASE_EGLFS_DEVICE = EGLFS_DEVICE_INTEGRATION = eglfs_nxpl
QT5BASE_GL_OPTS = -opengl es2 -eglfs -feature-eglfs_nxpl -qpa eglfs
# EGL/GLES through the Mali fbdev driver of the HiSilicon boxes (eglfs_mali);
# the driver comes without headers, the Khronos ones go with it (as Mesa's
# in oe-alliance), and hd6x-libgles adds the fbdev_window.h of the driver
else ifeq ($(BOXMODEL),$(filter $(BOXMODEL),hd60 hd61 multibox multiboxse))
QT5BASE_DEPENDENCIES += hd6x-libgles khronos-headers
QT5BASE_EGLFS_DEVICE = EGLFS_DEVICE_INTEGRATION = eglfs_mali
# (eglfs_nxpl, our patch, is on wherever eglfs is: it needs libnexus)
QT5BASE_GL_OPTS = -opengl es2 -eglfs -feature-eglfs_mali -no-feature-eglfs_nxpl -qpa eglfs
else
QT5BASE_EGLFS_DEVICE =
QT5BASE_GL_OPTS = -no-opengl -no-eglfs -qpa linuxfb
endif

QT5BASE_MKSPEC_DIR = $(PKG_BUILD_DIR)/mkspecs/devices/linux-nibuild-g++

# -no-libudev: the image runs mdev; libudev-zero (there for chromium) makes
# the udev device discovery of evdev/eglfs crash at start (pthread_join)
QT5BASE_CONF_OPTS = \
	-silent \
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
	$(QT5BASE_GL_OPTS)

# qmake and the bootstrap tools (moc, rcc, ...) are built with the host
# compiler: wrappers adding -w come first in PATH (the target compiler gets
# -w from the device mkspec)
QT5BASE_HOST_WRAP_DIR = $(PKG_BUILD_DIR)/host-wrapper
QT5BASE_MAKE_ENV = \
	PATH=$(QT5BASE_HOST_WRAP_DIR):$(PATH)

define QT5BASE_CONFIGURE_CMDS
	$(call QT5_HOST_COMPILER_WRAPPERS,$(QT5BASE_HOST_WRAP_DIR))
	$(INSTALL) -d $(QT5BASE_MKSPEC_DIR)
	sed 's/@EGLFS_DEVICE@/$(QT5BASE_EGLFS_DEVICE)/' $(PKG_FILES_DIR)/qmake.conf.in > $(QT5BASE_MKSPEC_DIR)/qmake.conf
	$(INSTALL_DATA) $(PKG_FILES_DIR)/qplatformdefs.h $(QT5BASE_MKSPEC_DIR)/qplatformdefs.h
	$(CD) $(PKG_BUILD_DIR); \
		$(TARGET_MAKE_ENV) \
		$(QT5BASE_MAKE_ENV) \
		PKG_CONFIG="$(PKG_CONFIG)" \
		PKG_CONFIG_LIBDIR="$(PKG_CONFIG_PATH)" \
		PKG_CONFIG_SYSROOT_DIR="$(PKG_CONFIG_SYSROOT_DIR)" \
		./configure $(QT5BASE_CONF_OPTS)
endef

define QT5BASE_INSTALL_CMDS
	$(CD) $(PKG_BUILD_DIR); \
		$(TARGET_MAKE_ENV) $(MAKE) install
endef

QT5BASE_PRE_CONFIGURE_HOOKS += QT5_SYNC_QT_HEADERS

qt5base: | $(TARGET_DIR)
	$(call generic-package)
