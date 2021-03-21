################################################################################
#
# f2fs-tools
#
################################################################################

F2FS_TOOLS_VERSION = 1.14.0
F2FS_TOOLS_DIR = f2fs-tools-$(F2FS_TOOLS_VERSION)
F2FS_TOOLS_SOURCE = f2fs-tools-$(F2FS_TOOLS_VERSION).tar.gz
F2FS_TOOLS_SITE = https://git.kernel.org/pub/scm/linux/kernel/git/jaegeuk/f2fs-tools.git/snapshot

F2FS_TOOLS_DEPENDENCIES = util-linux

F2FS_TOOLS_AUTORECONF = YES

F2FS_TOOLS_CONF_ENV = \
	ac_cv_file__git=no

F2FS_TOOLS_CONF_OPTS = \
	--prefix=$(base_prefix) \
	--exec_prefix=$(base_prefix) \
	--includedir=$(includedir) \
	--libdir=$(libdir) \
	--without-selinux

define F2FS_TOOLS_TARGET_CLEANUP
	$(TARGET_RM) $(addprefix $(TARGET_base_sbindir)/,sg_write_buffer)
endef
F2FS_TOOLS_TARGET_FINALIZE_HOOKS += F2FS_TOOLS_TARGET_CLEANUP

f2fs-tools: | $(TARGET_DIR)
	$(call autotools-package)
