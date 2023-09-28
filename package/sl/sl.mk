################################################################################
#
# sl
#
################################################################################

SL_VERSION = 5.02
SL_DIR = sl-$(SL_VERSION)
SL_SOURCE = sl-$(SL_VERSION).tar.gz
SL_SITE = $(call github,mtoyoda,sl,$(SL_VERSION))

SL_DEPENDENCIES = ncurses

define SL_BUILD_CMDS
	$(CD) $(PKG_BUILD_DIR); \
		$(TARGET_CC) $(TARGET_CFLAGS) $(TARGET_LDFLAGS) sl.c -o sl -lncurses
endef

define SL_INSTALL_CMDS
	$(INSTALL_EXEC) -D $(PKG_BUILD_DIR)/sl $(TARGET_bindir)/sl
endef

sl: | $(TARGET_DIR)
	$(call generic-package)
