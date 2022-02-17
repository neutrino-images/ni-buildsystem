################################################################################
#
# fbshot
#
################################################################################

FBSHOT_VERSION = 0.3
FBSHOT_DIR = fbshot-$(FBSHOT_VERSION)
FBSHOT_SOURCE = fbshot-$(FBSHOT_VERSION).tar.gz
FBSHOT_SITE = http://distro.ibiblio.org/amigolinux/download/Utils/fbshot

$(DL_DIR)/$(FBSHOT_SOURCE):
	$(download) $(FBSHOT_SITE)/$(FBSHOT_SOURCE)

FBSHOT_DEPENDENCIES = libpng

fbshot: $(FBSHOT_DEPENDENCIES) $(DL_DIR)/$(FBSHOT_SOURCE) | $(TARGET_DIR)
	$(REMOVE)/$(PKG_DIR)
	$(UNTAR)/$(PKG_SOURCE)
	$(call APPLY_PATCHES,$(PKG_PATCHES_DIR))
	$(CHDIR)/$(PKG_DIR); \
		$(SED) 's|	gcc |	$(TARGET_CC) $(TARGET_CFLAGS) $(TARGET_LDFLAGS) |' Makefile; \
		$(SED) '/strip fbshot/d' Makefile; \
		$(MAKE); \
		$(INSTALL_EXEC) -D fbshot $(TARGET_bindir)/fbshot
	$(REMOVE)/$(PKG_DIR)
	$(TOUCH)
