################################################################################
#
# libfuse3
#
################################################################################

LIBFUSE3_VERSION = 3.17.4
LIBFUSE3_DIR = fuse-$(LIBFUSE3_VERSION)
LIBFUSE3_SOURCE = fuse-$(LIBFUSE3_VERSION).tar.gz
LIBFUSE3_SITE = https://github.com/libfuse/libfuse/releases/download/fuse-$(LIBFUSE3_VERSION)

LIBFUSE3_CONF_OPTS = \
	-Dexamples=false \
	-Dudevrulesdir=/dev/null \
	-Duseroot=false \
	-Dtests=false \
	-Dutils=false

libfuse3: | $(TARGET_DIR)
	$(call meson-package)
