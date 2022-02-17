################################################################################
#
# samba
#
################################################################################

SAMBA33_VERSION = 3.3.16
SAMBA33_DIR = samba-$(SAMBA33_VERSION)
SAMBA33_SOURCE = samba-$(SAMBA33_VERSION).tar.gz
SAMBA33_SITE = https://download.samba.org/pub/samba

$(DL_DIR)/$(SAMBA33_SOURCE):
	$(download) $(SAMBA33_SITE)/$(SAMBA33_SOURCE)

SAMBA33_DEPENDENCIES = zlib

SAMBA33_CONF_ENV = \
	CONFIG_SITE=$(PKG_FILES_DIR)/samba33-config.site

SAMBA33_CONF_OPTS = \
	--datadir=/var/samba \
	--datarootdir=$(REMOVE_datarootdir) \
	--localstatedir=/var/samba \
	--sysconfdir=/etc/samba \
	--with-configdir=/etc/samba \
	--with-privatedir=/etc/samba \
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

samba33: $(SAMBA33_DEPENDENCIES) $(DL_DIR)/$(SAMBA33_SOURCE) | $(TARGET_DIR)
	$(REMOVE)/$(PKG_DIR)
	$(UNTAR)/$(PKG_SOURCE)
	$(call APPLY_PATCHES,$(PKG_PATCHES_DIR))
	$(CHDIR)/$(PKG_DIR)/source; \
		./autogen.sh; \
		$(CONFIGURE); \
		$(MAKE1) all; \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
	$(INSTALL) -d $(TARGET_localstatedir)/samba/locks
	$(INSTALL_DATA) -D $(PKG_FILES_DIR)/smb3.conf $(TARGET_sysconfdir)/samba/smb.conf
	$(INSTALL_EXEC) -D $(PKG_FILES_DIR)/samba3.init $(TARGET_sysconfdir)/init.d/samba
	$(UPDATE-RC.D) samba defaults 75 25
	$(TARGET_RM) $(addprefix $(TARGET_bindir)/,testparm findsmb smbtar smbclient smbpasswd)
	$(REMOVE)/$(PKG_DIR)
	$(TOUCH)
