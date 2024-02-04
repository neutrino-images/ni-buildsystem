################################################################################
#
# lzo
#
################################################################################

LZO_VERSION = 2.10
LZO_DIR = lzo-$(LZO_VERSION)
LZO_SOURCE = lzo-$(LZO_VERSION).tar.gz
LZO_SITE = https://www.oberhumer.com/opensource/lzo/download

LZO_SUPPORTS_IN_SOURCE_BUILD = NO

define LZO_TARGET_CLEANUP
	$(TARGET_RM) $(TARGET_libexecdir)/lzo
endef
LZO_TARGET_FINALIZE_HOOKS += LZO_TARGET_CLEANUP

lzo: | $(TARGET_DIR)
	$(call cmake-package)

# -----------------------------------------------------------------------------

HOST_LZO_CONF_OPTS += \
	-DENABLE_SHARED=ON \
	-DENABLE_STATIC=OFF

host-lzo: | $(HOST_DIR)
	$(call host-cmake-package)
