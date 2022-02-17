################################################################################
#
# samba
#
################################################################################

SAMBA36_VERSION = 3.6.25
SAMBA36_DIR = samba-$(SAMBA36_VERSION)
SAMBA36_SOURCE = samba-$(SAMBA36_VERSION).tar.gz
SAMBA36_SITE = https://download.samba.org/pub/samba/stable

$(DL_DIR)/$(SAMBA36_SOURCE):
	$(download) $(SAMBA36_SITE)/$(SAMBA36_SOURCE)

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
	--disable-swat \

samba36: $(SAMBA36_DEPENDENCIES) $(DL_DIR)/$(SAMBA36_SOURCE) | $(TARGET_DIR)
	$(REMOVE)/$(PKG_DIR)
	$(UNTAR)/$(PKG_SOURCE)
	$(call APPLY_PATCHES,$(PKG_PATCHES_DIR))
	$(CHDIR)/$(PKG_DIR)/source3; \
		./autogen.sh; \
		$(CONFIGURE); \
		$(MAKE); \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
	$(INSTALL) -d $(TARGET_localstatedir)/samba/locks
	$(INSTALL_DATA) -D $(PKG_FILES_DIR)/smb3.conf $(TARGET_sysconfdir)/samba/smb.conf
	$(INSTALL_EXEC) -D $(PKG_FILES_DIR)/samba3.init $(TARGET_sysconfdir)/init.d/samba
	$(UPDATE-RC.D) samba defaults 75 25
	$(TARGET_RM) $(addprefix $(TARGET_bindir)/,testparm findsmb smbtar smbclient smbpasswd)
	$(REMOVE)/$(PKG_DIR)
	$(TOUCH)
