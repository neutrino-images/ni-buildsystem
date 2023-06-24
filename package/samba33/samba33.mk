################################################################################
#
# samba
#
################################################################################

SAMBA33_VERSION = 3.3.16
SAMBA33_DIR = samba-$(SAMBA33_VERSION)
SAMBA33_SOURCE = samba-$(SAMBA33_VERSION).tar.gz
SAMBA33_SITE = https://download.samba.org/pub/samba

SAMBA33_SUBDIR = source

SAMBA33_DEPENDENCIES = zlib

SAMBA33_CONF_ENV = \
	CONFIG_SITE=$(PKG_FILES_DIR)/samba33-config.site

SAMBA33_CONF_OPTS = \
	--datadir=/var/samba \
	--localstatedir=/var/samba \
	--sysconfdir=/etc/samba \
	--with-configdir=/etc/samba \
	--with-privatedir=/etc/samba \
	--with-localedir=$(REMOVE_localedir) \
	--with-mandir=$(REMOVE_mandir) \
	--with-modulesdir=$(REMOVE_libdir)/samba \
	--with-sys-quotas=no \
	--with-piddir=/var/run \
	--enable-static \
	--disable-shared \
	--without-cifsmount \
	--without-acl-support \
	--without-ads \
	--without-cluster-support \
	--without-dnsupdate \
	--without-krb5 \
	--without-ldap \
	--without-libnetapi \
	--without-libtalloc \
	--without-libtdb \
	--without-libsmbsharemodes \
	--without-libsmbclient \
	--without-libaddns \
	--without-pam \
	--without-winbind \
	--disable-shared-libs \
	--disable-avahi \
	--disable-cups \
	--disable-iprint \
	--disable-pie \
	--disable-relro \
	--disable-swat

SAMBA33_MAKE = \
	$(MAKE1)

define SAMBA33_AUTOGEN_SH
	$(CD) $(PKG_BUILD_DIR); \
		./autogen.sh
endef
SAMBA33_PRE_CONFIGURE_HOOKS += SAMBA33_AUTOGEN_SH

ifeq ($(AUTOCONF_VER_ge_270),1)
define SAMBA33_PATCH_AUTOCONF
	$(call APPLY_PATCHES,autoconf2.71.patch-custom)
endef
SAMBA33_PRE_CONFIGURE_HOOKS += SAMBA33_PATCH_AUTOCONF
endif

define SAMBA33_INSTALL_FILES
	$(INSTALL) -d $(TARGET_localstatedir)/samba/locks
	$(INSTALL_DATA) -D $(PKG_FILES_DIR)/smb3.conf $(TARGET_sysconfdir)/samba/smb.conf
endef
SAMBA33_POST_INSTALL_HOOKS += SAMBA33_INSTALL_FILES

define SAMBA33_INSTALL_INIT_SYSV
	$(INSTALL_EXEC) -D $(PKG_FILES_DIR)/samba3.init $(TARGET_sysconfdir)/init.d/samba
	$(UPDATE-RC.D) samba defaults 75 25
endef

define SAMBA33_TARGET_CLEANUP
	$(TARGET_RM) $(addprefix $(TARGET_bindir)/,testparm findsmb smbtar smbclient smbpasswd)
	$(TARGET_RM) $(addprefix $(TARGET_sbindir)/,smbd.old nmbd.old)
endef
SAMBA33_TARGET_FINALIZE_HOOKS += SAMBA33_TARGET_CLEANUP

samba33: | $(TARGET_DIR)
	$(call autotools-package)
