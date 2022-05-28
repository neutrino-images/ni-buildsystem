################################################################################
#
# iozone
#
################################################################################

IOZONE_VERSION = 3_493
IOZONE_DIR = iozone$(IOZONE_VERSION)
IOZONE_SOURCE = iozone$(IOZONE_VERSION).tgz
IOZONE_SITE = http://www.iozone.org/src/current

# AIO support not available on uClibc, use the linux (non-aio) target.
ifeq ($(BOXTYPE),coolstream)
IOZONE_TARGET = linux-noaio
else
IOZONE_TARGET = linux-arm
endif

define IOZONE_PATCH_MAKEFILE
	$(SED) "s/= gcc/= $(TARGET_CC)/" $(PKG_BUILD_DIR)/src/current/makefile
	$(SED) "s/= cc/= $(TARGET_CC)/" $(PKG_BUILD_DIR)/src/current/makefile
endef
IOZONE_POST_PATCH_HOOKS += IOZONE_PATCH_MAKEFILE

define IOZONE_INSTALL_BINARY
	$(INSTALL_EXEC) -D $(PKG_BUILD_DIR)/src/current/iozone $(TARGET_bindir)/iozone
endef
IOZONE_PRE_FOLLOWUP_HOOKS += IOZONE_INSTALL_BINARY

iozone: | $(TARGET_DIR)
	$(call PREPARE)
	$(CHDIR)/$($(PKG)_DIR)/src/current; \
		$(TARGET_CONFIGURE_ENV) \
		$(MAKE) $($(PKG)_TARGET)
	$(call TARGET_FOLLOWUP)
