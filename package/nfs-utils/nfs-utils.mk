################################################################################
#
# nfs-utils
#
################################################################################

NFS_UTILS_VERSION = 2.6.1
NFS_UTILS_DIR = nfs-utils-$(NFS_UTILS_VERSION)
NFS_UTILS_SOURCE = nfs-utils-$(NFS_UTILS_VERSION).tar.xz
NFS_UTILS_SITE = $(KERNEL_MIRROR)/linux/utils/nfs-utils/$(NFS_UTILS_VERSION)

NFS_UTILS_DEPENDENCIES = libtirpc rpcbind e2fsprogs

NFS_UTILS_AUTORECONF = YES

NFS_UTILS_CONF_ENV = \
	knfsd_cv_bsd_signals=no

NFS_UTILS_CONF_OPTS = \
	--docdir=$(REMOVE_docdir) \
	$(if $(filter $(BOXSERIES),hd1),--disable-ipv6,--enable-ipv6) \
	--disable-gss \
	--disable-svcgss \
	--disable-caps \
	--disable-nfsdcltrack \
	--disable-nfsv4 \
	--disable-nfsv41 \
	--enable-mount \
	--enable-libmount-mount \
	--without-tcp-wrappers \
	--without-systemd \
	--with-statduser=rpcuser \
	--with-statdpath=/var/lib/nfs/statd \
	--with-statedir=/var/lib/nfs

define NFS_UTILS_TARGET_CLEANUP
	chmod 0755 $(TARGET_base_sbindir)/mount.nfs
	$(TARGET_RM) $(addprefix $(TARGET_base_sbindir)/,mount.nfs4 osd_login umount.nfs umount.nfs4)
	$(TARGET_RM) $(addprefix $(TARGET_sbindir)/,mountstats nfsiostat)
endef
NFS_UTILS_TARGET_FINALIZE_HOOKS += NFS_UTILS_TARGET_CLEANUP

ifeq ($(PERSISTENT_VAR_PARTITION),yes)
  define NFS_UTILS_INSTALL_EXPORTS_FILE
	$(INSTALL_DATA) -D $(PKG_FILES_DIR)/exports-var $(TARGET_localstatedir)/etc/exports
	ln -sf /var/etc/exports $(TARGET_sysconfdir)/exports
  endef
else
  define NFS_UTILS_INSTALL_EXPORTS_FILE
	$(INSTALL_DATA) -D $(PKG_FILES_DIR)/exports $(TARGET_sysconfdir)/exports
  endef
endif
NFS_UTILS_TARGET_FINALIZE_HOOKS += NFS_UTILS_INSTALL_EXPORTS_FILE

define NFS_UTILS_INSTALL_NFSD_INIT
	$(INSTALL_EXEC) -D $(PKG_FILES_DIR)/nfsd.init $(TARGET_sysconfdir)/init.d/nfsd
	$(UPDATE-RC.D) nfsd defaults 75 25
endef
NFS_UTILS_TARGET_FINALIZE_HOOKS += NFS_UTILS_INSTALL_NFSD_INIT

nfs-utils: | $(TARGET_DIR)
	$(call autotools-package)
