################################################################################
#
# libjpeg-turbo
#
################################################################################

LIBJPEG_TURBO_VERSION = 2.0.6
LIBJPEG_TURBO_DIR = libjpeg-turbo-$(LIBJPEG_TURBO_VERSION)
LIBJPEG_TURBO_SOURCE = libjpeg-turbo-$(LIBJPEG_TURBO_VERSION).tar.gz
LIBJPEG_TURBO_SITE = https://sourceforge.net/projects/libjpeg-turbo/files/$(LIBJPEG_TURBO_VERSION)

$(DL_DIR)/$(LIBJPEG_TURBO_SOURCE):
	$(download) $(LIBJPEG_TURBO_SITE)/$(LIBJPEG_TURBO_SOURCE)

LIBJPEG_TURBO_CONF_OPTS = \
	-DWITH_SIMD=False \
	-DWITH_JPEG8=80

define LIBJPEG_TURBO_TARGET_CLEANUP
	-rm $(addprefix $(TARGET_bindir)/,cjpeg djpeg jpegtran rdjpgcom tjbench wrjpgcom)
endef
LIBJPEG_TURBO_TARGET_FINALIZE_HOOKS += LIBJPEG_TURBO_TARGET_CLEANUP

libjpeg-turbo: $(DL_DIR)/$(LIBJPEG_TURBO_SOURCE) | $(TARGET_DIR)
	$(call cmake-package)
