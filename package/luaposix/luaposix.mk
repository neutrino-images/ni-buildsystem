################################################################################
#
# luaposix
#
################################################################################

LUAPOSIX_VERSION = 31
LUAPOSIX_DIR = luaposix-$(LUAPOSIX_VERSION)
LUAPOSIX_SOURCE = luaposix-$(LUAPOSIX_VERSION).tar.gz
LUAPOSIX_SITE = https://github.com/luaposix/luaposix/archive

$(DL_DIR)/$(LUAPOSIX_SOURCE):
	$(download) $(LUAPOSIX_SITE)/v$(LUAPOSIX_VERSION).tar.gz -O $(@)

LUAPOSIX_DEPENDENCIES = $(HOST_LUA) lua luaexpat

LUAPOSIX_AUTORECONF = YES

LUAPOSIX_CONF_ENV = \
	LUA=$(HOST_LUA)

LUAPOSIX_CONF_OPTS = \
	--libdir=$(TARGET_libdir)/lua/$(LUA_ABIVERSION) \
	--datadir=$(TARGET_datadir)/lua/$(LUA_ABIVERSION) \
	--mandir=$(TARGET_DIR)$(REMOVE_mandir) \
	--docdir=$(TARGET_DIR)$(REMOVE_docdir)

GNULIB_VERSION = 20140202
GNULIB_SOURCE = gnulib-$(GNULIB_VERSION)-stable.tar.gz
GNULIB_SITE = http://erislabs.net/ianb/projects/gnulib

$(DL_DIR)/$(GNULIB_SOURCE):
	$(download) $(GNULIB_SITE)/$(GNULIB_SOURCE)

SLINGSHOT_VERSION = 6
SLINGSHOT_SOURCE = slingshot-$(SLINGSHOT_VERSION).tar.gz
SLINGSHOT_SITE = https://github.com/gvvaughan/slingshot/archive

$(DL_DIR)/$(SLINGSHOT_SOURCE):
	$(download) $(SLINGSHOT_SITE)/v$(SLINGSHOT_VERSION).tar.gz -O $(@)

luaposix: $(LUAPOSIX_DEPENDENCIES) $(DL_DIR)/$(SLINGSHOT_SOURCE) $(DL_DIR)/$(GNULIB_SOURCE) $(DL_DIR)/$(LUAPOSIX_SOURCE) | $(TARGET_DIR)
	$(REMOVE)/$(PKG_DIR)
	$(UNTAR)/$(PKG_SOURCE)
	$(call APPLY_PATCHES,$(PKG_PATCHES_DIR))
	$(CHDIR)/$(PKG_DIR); \
		tar -C gnulib --strip=1 -xf $(DL_DIR)/$(GNULIB_SOURCE); \
		tar -C slingshot --strip=1 -xf $(DL_DIR)/$(SLINGSHOT_SOURCE); \
		./bootstrap; \
		$(CONFIGURE); \
		$(MAKE); \
		$(MAKE) install
	$(REMOVE)/$(PKG_DIR)
	$(TOUCH)
