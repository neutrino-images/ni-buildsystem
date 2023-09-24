################################################################################
#
# minisatip
#
################################################################################

MINISATIP_VERSION = 1.3.0
MINISATIP_DIR = minisatip-$(MINISATIP_VERSION)
MINISATIP_SOURCE = minisatip-$(MINISATIP_VERSION).tar.gz
MINISATIP_SITE = $(call github,catalinii,minisatip,v$(MINISATIP_VERSION))

MINISATIP_DEPENDENCIES = libdvbcsa libxml2 openssl

MINISATIP_CONF_ENV = \
	CFLAGS+=" -ldl"

MINISATIP_CONF_OPTS = \
	--enable-static \
	--disable-netcv \
	--enable-dvbca \
	--enable-dvbcsa \
	--with-xml2=$(TARGET_includedir)/libxml2

MINISATIP_MAKE_ENV = \
	$(TARGET_CONFIGURE_ENV)

define MINISATIP_INSTALL_CMDS
	$(INSTALL_EXEC) -D $(PKG_BUILD_DIR)/minisatip $(TARGET_bindir)/minisatip
	$(INSTALL) -d $(TARGET_datadir)/minisatip
	$(INSTALL_COPY) $(PKG_BUILD_DIR)/html $(TARGET_datadir)/minisatip
endef

define MINISATIP_INSTALL_DEFAULTS
	$(INSTALL) -d $(TARGET_sysconfdir)/default
	echo 'MINISATIP_OPTS="-x 9090 -t -o /tmp/camd.socket"' > $(TARGET_sysconfdir)/default/minisatip
endef
MINISATIP_TARGET_FINALIZE_HOOKS += MINISATIP_INSTALL_DEFAULTS

define MINISATIP_INSTALL_INIT_SYSV
	$(INSTALL_EXEC) -D $(PKG_FILES_DIR)/minisatip.init $(TARGET_sysconfdir)/init.d/minisatip
	$(UPDATE-RC.D) minisatip defaults 75 25
endef

minisatip: | $(TARGET_DIR)
	$(call autotools-package)
