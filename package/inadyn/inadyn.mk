################################################################################
#
# inadyn
#
################################################################################

INADYN_VERSION = 2.6
INADYN_DIR = inadyn-$(INADYN_VERSION)
INADYN_SOURCE = inadyn-$(INADYN_VERSION).tar.xz
INADYN_SITE = https://github.com/troglobit/inadyn/releases/download/v$(INADYN_VERSION)

INADYN_DEPENDENCIES = openssl confuse libite

INADYN_AUTORECONF = YES

INADYN_CONF_OPTS = \
	--docdir=$(REMOVE_docdir) \
	--enable-openssl

define INADYN_INSTALL_NFSD_CONF
	$(INSTALL_DATA) -D $(PKG_FILES_DIR)/inadyn.conf $(TARGET_localstatedir)/etc/inadyn.conf
	ln -sf /var/etc/inadyn.conf $(TARGET_sysconfdir)/inadyn.conf
endef
INADYN_TARGET_FINALIZE_HOOKS += INADYN_INSTALL_NFSD_CONF

define INADYN_INSTALL_NFSD_INIT
	$(INSTALL_EXEC) -D $(PKG_FILES_DIR)/inadyn.init $(TARGET_sysconfdir)/init.d/inadyn
	$(UPDATE-RC.D) inadyn defaults 75 25
endef
INADYN_TARGET_FINALIZE_HOOKS += INADYN_INSTALL_NFSD_INIT

inadyn: | $(TARGET_DIR)
	$(call autotools-package)
