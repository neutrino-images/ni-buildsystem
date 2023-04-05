################################################################################
#
# libfuse3
#
################################################################################

LIBFUSE3_VERSION = 3.14.1
LIBFUSE3_DIR     = fuse-$(LIBFUSE3_VERSION)
LIBFUSE3_SOURCE  = fuse-$(LIBFUSE3_VERSION).tar.xz
LIBFUSE3_SITE    = https://github.com/libfuse/libfuse/releases/download/fuse-$(LIBFUSE3_VERSION)

LIBFUSE3_CONF_OPTS = \
	-Ddisable-mtab=true \
	-Dudevrulesdir=/dev/null \
	-Dutils=false \
	-Dexamples=false \
	-Duseroot=false

libfuse3: | $(TARGET_DIR)
	$(call meson-package)
