################################################################################
#
# rsync
#
################################################################################

RSYNC_VERSION = 3.1.3
RSYNC_DIR = rsync-$(RSYNC_VERSION)
RSYNC_SOURCE = rsync-$(RSYNC_VERSION).tar.gz
RSYNC_SITE = https://download.samba.org/pub/rsync/src/

RSYNC_DEPENDENCIES = zlib popt

RSYNC_CONF_OPTS = \
	--disable-debug \
	--disable-locale \
	--disable-acl-support \
	--with-included-zlib=no \
	--with-included-popt=no

rsync: | $(TARGET_DIR)
	$(call autotools-package)
