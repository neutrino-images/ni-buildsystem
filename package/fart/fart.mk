################################################################################
#
# fart
#
################################################################################

FART_VERSION = master
FART_DIR = fart-it.git
FART_SOURCE = fart-it.git
FART_SITE = https://github.com/lionello
FART_SITE_METHOD = git

define FART_BUILD_CMDS
	$(CHDIR)/$($(PKG)_DIR); \
		$(TARGET_CC) fart.cpp fart_shared.c wildmat.c -o fart
endef

define FART_INSTALL_CMDS
	$(INSTALL_EXEC) -D $(PKG_BUILD_DIR)/fart $(TARGET_bindir)/fart
endef

fart: | $(TARGET_DIR)
	$(call generic-package)
