################################################################################
#
# fuse-exfat
#
################################################################################

FUSE_EXFAT_VERSION = 1.4.0
FUSE_EXFAT_DIR = fuse-exfat-$(FUSE_EXFAT_VERSION)
FUSE_EXFAT_SOURCE = fuse-exfat-$(FUSE_EXFAT_VERSION).tar.gz
FUSE_EXFAT_SITE = https://github.com/relan/exfat/releases/download/v$(FUSE_EXFAT_VERSION)

FUSE_EXFAT_DEPENDENCIES = libfuse
#FUSE_EXFAT_DEPENDENCIES = libfuse3

FUSE_EXFAT_AUTORECONF = YES

FUSE_EXFAT_CONF_OPTS = \
	--prefix=$(base_prefix) \
	--exec_prefix=$(base_prefix) \
	--includedir=$(includedir) \
	--libdir=$(libdir) \
	--docdir=$(REMOVE_docdir)

fuse-exfat: | $(TARGET_DIR)
	$(call autotools-package)
