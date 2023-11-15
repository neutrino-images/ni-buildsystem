################################################################################
#
# libjpeg-turbo
#
################################################################################

LIBJPEG_TURBO_VERSION = 3.0.1
LIBJPEG_TURBO_DIR = libjpeg-turbo-$(LIBJPEG_TURBO_VERSION)
LIBJPEG_TURBO_SOURCE = libjpeg-turbo-$(LIBJPEG_TURBO_VERSION).tar.gz
LIBJPEG_TURBO_SITE = https://sourceforge.net/projects/libjpeg-turbo/files/$(LIBJPEG_TURBO_VERSION)

LIBJPEG_TURBO_CONF_OPTS = \
	-DCMAKE_INSTALL_BINDIR="$(REMOVE_bindir)" \
	-DCMAKE_SKIP_INSTALL_RPATH=ON \
	-DWITH_SIMD=OFF \
	-DWITH_JAVA=OFF \
	-DWITH_TURBOJPEG=OFF \
	-DWITH_JPEG8=80

LIBJPEG_TURBO_CMAKE_BACKEND = ninja

libjpeg-turbo: | $(TARGET_DIR)
	$(call cmake-package)
