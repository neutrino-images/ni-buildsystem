################################################################################
#
# autofs
#
################################################################################

AUTOFS_VERSION = 5.1.8
AUTOFS_DIR = autofs-$(AUTOFS_VERSION)
AUTOFS_SOURCE = autofs-$(AUTOFS_VERSION).tar.xz
AUTOFS_SITE = $(KERNEL_MIRROR)/linux/daemons/autofs/v5

AUTOFS_DEPENDENCIES = libtirpc

AUTOFS_AUTORECONF = YES

# autofs looks on the build machine for the path of modprobe, mount,
# umount and fsck programs so tell it explicitly where they will be
# located on the target.
AUTOFS_CONF_ENV = \
	ac_cv_path_E2FSCK=/sbin/fsck \
	ac_cv_path_E3FSCK=no \
	ac_cv_path_E4FSCK=no \
	ac_cv_path_KRB5_CONFIG=no \
	ac_cv_path_MODPROBE=/sbin/modprobe \
	ac_cv_path_MOUNT=/bin/mount \
	ac_cv_path_MOUNT_NFS=/sbin/mount.nfs \
	ac_cv_path_UMOUNT=/bin/umount \
	ac_cv_linux_procfs=yes

# instead of looking in the PATH like any reasonable package, autofs
# configure looks only in an hardcoded search path for host tools,
# which we have to override with --with-path.
AUTOFS_CONF_OPTS = \
	--datarootdir=$(REMOVE_datarootdir) \
	--disable-mount-locking \
	--enable-ignore-busy \
	--without-openldap \
	--without-sasl \
	--with-path="$(PATH)" \
	--with-hesiod=no \
	--with-libtirpc \
	--with-confdir=/etc \
	--with-mapdir=/etc \
	--with-fifodir=/var/run \
	--with-flagdir=/var/run

AUTOFS_MAKE_ENV = \
	DONTSTRIP=1

AUTOFS_MAKE = \
	$(MAKE1)

define AUTOFS_PATCH_RPC_SUBS_H
	$(SED) "s|nfs/nfs.h|linux/nfs.h|" $(PKG_BUILD_DIR)/include/rpc_subs.h
endef
AUTOFS_POST_PATCH_HOOKS += AUTOFS_PATCH_RPC_SUBS_H

define AUTOFS_INSTALL_SKEL
	$(INSTALL_COPY) $(PKG_FILES_DIR)-skel/* $(TARGET_DIR)/
endef
AUTOFS_TARGET_FINALIZE_HOOKS += AUTOFS_INSTALL_SKEL

define AUTOFS_INSTALL_INIT_SYSV
	$(INSTALL_EXEC) -D $(PKG_FILES_DIR)/autofs.init $(TARGET_sysconfdir)/init.d/autofs
	$(UPDATE-RC.D) autofs defaults 75 25
endef

autofs: | $(TARGET_DIR)
	$(call autotools-package)
