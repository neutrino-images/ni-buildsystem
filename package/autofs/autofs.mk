################################################################################
#
# autofs
#
################################################################################

AUTOFS_VERSION = 5.1.7
AUTOFS_DIR = autofs-$(AUTOFS_VERSION)
AUTOFS_SOURCE = autofs-$(AUTOFS_VERSION).tar.xz
AUTOFS_SITE = $(KERNEL_MIRROR)/linux/daemons/autofs/v5

$(DL_DIR)/$(AUTOFS_SOURCE):
	$(download) $(AUTOFS_SITE)/$(AUTOFS_SOURCE)

# cd package/autofs/patches
# wget -N https://mirrors.edge.kernel.org/pub/linux/daemons/autofs/v5/patches-5.1.8/patch_order_5.1.7
# for p in $(cat patch_order_5.1.7); do test -f $p || wget https://mirrors.edge.kernel.org/pub/linux/daemons/autofs/v5/patches-5.1.8/$p; done

AUTOFS_PATCH  = 0000-force-STRIP-to-emtpy.patch
AUTOFS_PATCH += $(shell cat $(PKG_PATCHES_DIR)/patch_order_$(AUTOFS_VERSION))

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

AUTOFS_MAKE_ENV = \
	DONTSTRIP=1

define AUTOFS_PATCH_RPC_SUBS_H
	$(SED) "s|nfs/nfs.h|linux/nfs.h|" $(PKG_BUILD_DIR)/include/rpc_subs.h
endef
AUTOFS_POST_PATCH_HOOKS += AUTOFS_PATCH_RPC_SUBS_H

autofs: $(AUTOFS_DEPENDENCIES) $(DL_DIR)/$(AUTOFS_SOURCE) | $(TARGET_DIR)
	$(REMOVE)/$(PKG_DIR)
	$(UNTAR)/$(PKG_SOURCE)
	$(call APPLY_PATCHES,$($(PKG)_PATCH))
	$(call TARGET_CONFIGURE)
	$(CHDIR)/$(PKG_DIR); \
		$($(PKG)_MAKE_ENV) \
		$(MAKE); \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
	$(INSTALL_COPY) $(PKG_FILES_DIR)-skel/* $(TARGET_DIR)/
	$(UPDATE-RC.D) autofs defaults 75 25
	$(REMOVE)/$(PKG_DIR)
	$(TOUCH)
