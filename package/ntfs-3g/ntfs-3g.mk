################################################################################
#
# ntfs-3g
#
################################################################################

NTFS_3G_VERSION = 2022.10.3
NTFS_3G_DIR = ntfs-3g_ntfsprogs-$(NTFS_3G_VERSION)
NTFS_3G_SOURCE = ntfs-3g_ntfsprogs-$(NTFS_3G_VERSION).tgz
#NTFS_3G_SITE = https://tuxera.com/opensource
NTFS_3G_SITE = https://www.neutrino-images.de/neutrino-images/archives

NTFS_3G_DEPENDENCIES = libfuse

NTFS_3G_CONF_OPTS = \
	--prefix=$(base_prefix) \
	--exec_prefix=$(base_prefix) \
	--includedir=$(includedir) \
	--libdir=$(libdir) \
	--docdir=$(REMOVE_docdir) \
	--disable-ntfsprogs \
	--disable-ldconfig \
	--disable-library \
	--with-fuse=external

define NTFS_3G_TARGET_CLEANUP
	$(TARGET_RM) $(addprefix $(TARGET_base_bindir)/,lowntfs-3g ntfs-3g.probe)
	$(TARGET_RM) $(addprefix $(TARGET_base_sbindir)/,mount.lowntfs-3g)
endef
NTFS_3G_TARGET_FINALIZE_HOOKS += NTFS_3G_TARGET_CLEANUP

define NTFS_3G_SYMLINK_MOUNT_NTFS
	ln -sf $(base_bindir)/ntfs-3g $(TARGET_base_sbindir)/mount.ntfs
endef
NTFS_3G_TARGET_FINALIZE_HOOKS += NTFS_3G_SYMLINK_MOUNT_NTFS

ntfs-3g: | $(TARGET_DIR)
	$(call autotools-package)
