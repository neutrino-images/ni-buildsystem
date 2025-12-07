################################################################################
#
# exfat-utils
#
################################################################################

EXFAT_UTILS_VERSION = 1.4.0
EXFAT_UTILS_DIR = exfat-utils-$(EXFAT_UTILS_VERSION)
EXFAT_UTILS_SOURCE = exfat-utils-$(EXFAT_UTILS_VERSION).tar.gz
EXFAT_UTILS_SITE = https://github.com/relan/exfat/releases/download/v$(EXFAT_UTILS_VERSION)

EXFAT_UTILS_DEPENDENCIES = fuse-exfat

EXFAT_UTILS_AUTORECONF = YES

EXFAT_UTILS_CONF_OPTS = \
	--prefix=$(base_prefix) \
	--exec_prefix=$(base_prefix) \
	--includedir=$(includedir) \
	--libdir=$(libdir) \
	--docdir=$(REMOVE_docdir)

exfat-utils: | $(TARGET_DIR)
	$(call autotools-package)
