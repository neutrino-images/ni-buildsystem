################################################################################
#
# mc
#
################################################################################

MC_VERSION = 4.8.29
MC_DIR = mc-$(MC_VERSION)
MC_SOURCE = mc-$(MC_VERSION).tar.xz
MC_SITE = http://ftp.midnight-commander.org

MC_DEPENDENCIES = glib2 ncurses

MC_AUTORECONF = YES

MC_CONF_OPTS = \
	--disable-charset \
	--disable-nls \
	--disable-vfs-extfs \
	--disable-vfs-fish \
	--disable-vfs-sfs \
	--disable-vfs-sftp \
	--with-screen=ncurses \
	--without-diff-viewer \
	--without-gpm-mouse \
	--without-x

define MC_TARGET_CLEANUP
	$(TARGET_RM) $(TARGET_datadir)/mc/examples
	find $(TARGET_datadir)/mc/skins -type f ! -name default.ini | xargs --no-run-if-empty $(TARGET_RM)
endef
MC_TARGET_FINALIZE_HOOKS += MC_TARGET_CLEANUP

mc: | $(TARGET_DIR)
	$(call autotools-package)
