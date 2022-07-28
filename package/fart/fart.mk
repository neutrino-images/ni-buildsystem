################################################################################
#
# fart
#
################################################################################

FART_VERSION = git
FART_DIR = fart-it.$(LUA_CURL_VERSION)
FART_SOURCE = fart-it.$(LUA_CURL_VERSION)
FART_SITE = https://github.com/lionello

define FART_BUILD_CMDS
	$(CHDIR)/$($(PKG)_DIR); \
		$(TARGET_CC) fart.cpp fart_shared.c wildmat.c -o fart
endef

define FART_INSTALL_CMDS
	$(INSTALL_EXEC) -D $(PKG_BUILD_DIR)/fart $(TARGET_bindir)/fart
endef

fart: | $(TARGET_DIR)
	$(call generic-package)
