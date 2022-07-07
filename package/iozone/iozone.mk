################################################################################
#
# iozone
#
################################################################################

IOZONE_VERSION = 3_493
IOZONE_DIR = iozone$(IOZONE_VERSION)
IOZONE_SOURCE = iozone$(IOZONE_VERSION).tgz
IOZONE_SITE = http://www.iozone.org/src/current

IOZONE_SUBDIR = src/current

# AIO support not available on uClibc, use the linux (non-aio) target.
ifeq ($(BOXTYPE),coolstream)
IOZONE_TARGET = linux-noaio
else
IOZONE_TARGET = linux-arm
endif

IOZONE_MAKE_ENV = \
	$(TARGET_CONFIGURE_ENV)

IOZONE_MAKE_OPTS = \
	$(IOZONE_TARGET)

define IOZONE_PATCH_MAKEFILE
	$(SED) "s/= gcc/= $(TARGET_CC)/" $(PKG_BUILD_DIR)/makefile
	$(SED) "s/= cc/= $(TARGET_CC)/" $(PKG_BUILD_DIR)/makefile
endef
IOZONE_POST_PATCH_HOOKS += IOZONE_PATCH_MAKEFILE

define IOZONE_INSTALL_CMDS
	$(INSTALL_EXEC) -D $(PKG_BUILD_DIR)/iozone $(TARGET_bindir)/iozone
endef

iozone: | $(TARGET_DIR)
	$(call generic-package)
