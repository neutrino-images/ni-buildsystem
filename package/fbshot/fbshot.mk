################################################################################
#
# fbshot
#
################################################################################

FBSHOT_VERSION = 0.3
FBSHOT_DIR = fbshot-$(FBSHOT_VERSION)
FBSHOT_SOURCE = fbshot-$(FBSHOT_VERSION).tar.gz
FBSHOT_SITE = http://distro.ibiblio.org/amigolinux/download/Utils/fbshot

FBSHOT_DEPENDENCIES = libpng

define FBSHOT_PATCH_MAKEFILE
	$(SED) 's|	gcc |	$(TARGET_CC) $(TARGET_CFLAGS) $(TARGET_LDFLAGS) |' $(PKG_BUILD_DIR)/Makefile
	$(SED) '/strip fbshot/d' $(PKG_BUILD_DIR)/Makefile
endef
FBSHOT_POST_PATCH_HOOKS += FBSHOT_PATCH_MAKEFILE

fbshot: | $(TARGET_DIR)
	$(call PREPARE)
	$(CHDIR)/$($(PKG)_DIR); \
		$(MAKE); \
		$(INSTALL_EXEC) -D fbshot $(TARGET_bindir)/fbshot
	$(call TARGET_FOLLOWUP)
