################################################################################
#
# luaexpat
#
################################################################################

LUAEXPAT_VERSION = 1.3.3
LUAEXPAT_DIR = luaexpat-$(LUAEXPAT_VERSION)
LUAEXPAT_SOURCE = luaexpat-$(LUAEXPAT_VERSION).tar.gz
LUAEXPAT_SITE = https://github.com/tomasguisasola/luaexpat/archive

$(DL_DIR)/$(LUAEXPAT_SOURCE):
	$(download) $(LUAEXPAT_SITE)/v$(LUAEXPAT_VERSION).tar.gz -O $(@)

LUAEXPAT_DEPENDENCIES = expat lua

LUAEXPAT_MAKE_ENV = \
	$(TARGET_CONFIGURE_ENV)

LUAEXPAT_MAKE_OPTS = \
	PREFIX=$(TARGET_prefix) \
	LUA_SYS_VER=$(LUA_ABIVERSION)

luaexpat: $(LUAEXPAT_DEPENDENCIES) $(DL_DIR)/$(LUAEXPAT_SOURCE) | $(TARGET_DIR)
	$(REMOVE)/$(PKG_DIR)
	$(UNTAR)/$(PKG_SOURCE)
	$(CHDIR)/$(PKG_DIR); \
		$(SED) 's|^EXPAT_INC=.*|EXPAT_INC= $(TARGET_includedir)|' makefile; \
		$(SED) 's|^CFLAGS =.*|& -L$(TARGET_libdir)|' makefile; \
		$(SED) 's|^CC =.*|CC = $(TARGET_CC)|' makefile; \
		$($(PKG)_MAKE_ENV) $(MAKE) $($(PKG)_MAKE_OPTS); \
		$($(PKG)_MAKE_ENV) $(MAKE) $($(PKG)_MAKE_OPTS) install
	$(REMOVE)/$(PKG_DIR)
	$(TOUCH)
