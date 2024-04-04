################################################################################
#
# mc
#
################################################################################

MC_VERSION = tags/4.8.31
MC_DIR = mc.git
MC_SOURCE = mc.git
MC_SITE = $(GITHUB)/MidnightCommander
MC_SITE_METHOD = git

MC_DEPENDENCIES = glib2 ncurses

MC_CONF_OPTS = \
	--enable-charset \
	--disable-nls \
	--disable-vfs-extfs \
	--disable-vfs-shell \
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
