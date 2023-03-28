################################################################################
#
# samba
#
################################################################################

SAMBA36_VERSION = 3.6.25
SAMBA36_DIR = samba-$(SAMBA36_VERSION)
SAMBA36_SOURCE = samba-$(SAMBA36_VERSION).tar.gz
SAMBA36_SITE = https://download.samba.org/pub/samba/stable

SAMBA36_SUBDIR = source3

SAMBA36_DEPENDENCIES = zlib

SAMBA36_CONF_ENV = \
	CONFIG_SITE=$(PKG_FILES_DIR)/samba36-config.site

SAMBA36_CONF_OPTS = \
	--datadir=/var/samba \
	--datarootdir=$(REMOVE_datarootdir) \
	--localstatedir=/var/samba \
	--sysconfdir=/etc/samba \
	--with-configdir=/etc/samba \
	--with-privatedir=/etc/samba \
	--with-modulesdir=$(REMOVE_libdir)/samba \
	--with-piddir=/var/run \
	--with-sys-quotas=no \
	--enable-static \
	--disable-shared \
	--without-acl-support \
	--without-ads \
	--without-cluster-support \
	--without-dmapi \
	--without-dnsupdate \
	--without-krb5 \
	--without-ldap \
	--without-libnetapi \
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

define SAMBA36_AUTOGEN_SH
	$(CHDIR)/$($(PKG)_DIR)/$($(PKG)_SUBDIR); \
		./autogen.sh
endef
SAMBA36_PRE_CONFIGURE_HOOKS += SAMBA36_AUTOGEN_SH

ifeq ($(AUTOCONF_VER_ge_270),1)
define SAMBA36_PATCH_AUTOCONF
	$(call APPLY_PATCHES,autoconf2.71.patch-custom)
endef
SAMBA36_PRE_CONFIGURE_HOOKS += SAMBA36_PATCH_AUTOCONF
endif

define SAMBA36_INSTALL_FILES
	$(INSTALL) -d $(TARGET_localstatedir)/samba/locks
	$(INSTALL_DATA) -D $(PKG_FILES_DIR)/smb3.conf $(TARGET_sysconfdir)/samba/smb.conf
endef
SAMBA36_POST_INSTALL_HOOKS += SAMBA36_INSTALL_FILES

define SAMBA36_INSTALL_INIT_SYSV
	$(INSTALL_EXEC) -D $(PKG_FILES_DIR)/samba3.init $(TARGET_sysconfdir)/init.d/samba
	$(UPDATE-RC.D) samba defaults 75 25
endef

define SAMBA36_TARGET_CLEANUP
	$(TARGET_RM) $(addprefix $(TARGET_bindir)/,testparm findsmb smbtar smbclient smbpasswd)
endef
SAMBA36_TARGET_FINALIZE_HOOKS += SAMBA36_TARGET_CLEANUP

samba36: | $(TARGET_DIR)
	$(call autotools-package)
