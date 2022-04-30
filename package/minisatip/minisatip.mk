################################################################################
#
# minisatip
#
################################################################################

MINISATIP_VERSION = git
MINISATIP_DIR = minisatip.$(MINISATIP_VERSION)
MINISATIP_SOURCE = minisatip.$(MINISATIP_VERSION)
MINISATIP_SITE = https://github.com/catalinii

MINISATIP_DEPENDENCIES = libdvbcsa openssl dvb-apps

MINISATIP_CONF_ENV = \
	CFLAGS+=" -ldl"

MINISATIP_CONF_OPTS = \
	--enable-static \
	--disable-netcv

minisatip: $(MINISATIP_DEPENDENCIES) | $(TARGET_DIR)
	$(REMOVE)/$(PKG_DIR)
	$(GET_GIT_SOURCE) $(PKG_SITE)/$(PKG_SOURCE) $(DL_DIR)/$(PKG_SOURCE)
	$(CPDIR)/$(PKG_SOURCE)
	$(CHDIR)/$(PKG_DIR); \
		$(CONFIGURE); \
		$(TARGET_CONFIGURE_ENV) \
		$(MAKE)
	$(INSTALL_EXEC) -D $(PKG_BUILD_DIR)/minisatip $(TARGET_bindir)/minisatip
	$(INSTALL) -d $(TARGET_datadir)/minisatip
	$(INSTALL_COPY) $(PKG_BUILD_DIR)/html $(TARGET_datadir)/minisatip
	$(INSTALL) -d $(TARGET_sysconfdir)/default
	echo 'MINISATIP_OPTS="-x 9090 -t -o /tmp/camd.socket"' > $(TARGET_sysconfdir)/default/minisatip
	$(INSTALL_EXEC) -D $(PKG_FILES_DIR)/minisatip.init $(TARGET_sysconfdir)/init.d/minisatip
	$(UPDATE-RC.D) minisatip defaults 75 25
	$(REMOVE)/$(PKG_DIR)
	$(TOUCH)
