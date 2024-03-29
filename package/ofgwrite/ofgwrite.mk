################################################################################
#
# ofgwrite
#
################################################################################

OFGWRITE_VERSION = master
OFGWRITE_DIR = $(NI_OFGWRITE)
OFGWRITE_SOURCE = $(NI_OFGWRITE)
OFGWRITE_SITE = https://github.com/neutrino-images
OFGWRITE_SITE_METHOD = ni-git

OFGWRITE_DEPENDENCIES = openssl

OFGWRITE_MAKE_ENV = \
	$(TARGET_CONFIGURE_ENV)

define OFGWRITE_INSTALL_CMDS
	$(INSTALL_EXEC) $(PKG_BUILD_DIR)/ofgwrite_bin $(TARGET_bindir)
	$(INSTALL_EXEC) $(PKG_BUILD_DIR)/ofgwrite_caller $(TARGET_bindir)
	$(INSTALL_EXEC) $(PKG_BUILD_DIR)/ofgwrite $(TARGET_bindir)
	$(SED) 's|prefix=.*|prefix=$(prefix)|' $(TARGET_bindir)/ofgwrite
endef

ofgwrite: | $(TARGET_DIR)
	$(call generic-package)
