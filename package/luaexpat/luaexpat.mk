################################################################################
#
# luaexpat
#
################################################################################

LUAEXPAT_VERSION = 1.3.3
LUAEXPAT_DIR = luaexpat-$(LUAEXPAT_VERSION)
LUAEXPAT_SOURCE = luaexpat-$(LUAEXPAT_VERSION).tar.gz
LUAEXPAT_SITE = $(call github,tomasguisasola,luaexpat,v$(LUAEXPAT_VERSION))

LUAEXPAT_DEPENDENCIES = expat lua

LUAEXPAT_MAKE_ENV = \
	$(TARGET_CONFIGURE_ENV)

LUAEXPAT_MAKE_OPTS = \
	PREFIX=$(TARGET_prefix) \
	LUA_SYS_VER=$(LUA_ABIVERSION)

define LUAEXPAT_PATCH_MAKEFILE
	$(SED) 's|^EXPAT_INC=.*|EXPAT_INC= $(TARGET_includedir)|' $(PKG_BUILD_DIR)/makefile
	$(SED) 's|^CFLAGS =.*|& -L$(TARGET_libdir)|' $(PKG_BUILD_DIR)/makefile
	$(SED) 's|^CC =.*|CC = $(TARGET_CC)|' $(PKG_BUILD_DIR)/makefile
endef
LUAEXPAT_POST_PATCH_HOOKS += LUAEXPAT_PATCH_MAKEFILE

luaexpat: | $(TARGET_DIR)
	$(call PREPARE)
	$(CHDIR)/$($(PKG)_DIR); \
		$($(PKG)_MAKE_ENV) $(MAKE) $($(PKG)_MAKE_OPTS); \
		$($(PKG)_MAKE_ENV) $(MAKE) $($(PKG)_MAKE_OPTS) install
	$(call TARGET_FOLLOWUP)
