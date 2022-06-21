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

# We're patching Makefile.rules, so there's no need to set DONTSTRIP
#AUTOFS_MAKE_ENV = \
#	DONTSTRIP=1

define AUTOFS_PATCH_RPC_SUBS_H
	$(SED) "s|nfs/nfs.h|linux/nfs.h|" $(PKG_BUILD_DIR)/include/rpc_subs.h
endef
AUTOFS_POST_PATCH_HOOKS += AUTOFS_PATCH_RPC_SUBS_H

define AUTOFS_INSTALL_FILES
	$(INSTALL_COPY) $(PKG_FILES_DIR)-skel/* $(TARGET_DIR)/
	$(UPDATE-RC.D) autofs defaults 75 25
endef
AUTOFS_TARGET_FINALIZE_HOOKS += AUTOFS_INSTALL_FILES

autofs: | $(TARGET_DIR)
	$(call autotools-package)
