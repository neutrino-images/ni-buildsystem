################################################################################
#
# luajson
#
################################################################################

LUAJSON_VERSION = curl-controlled
LUAJSON_DIR =
LUAJSON_SOURCE = JSON.lua
LUAJSON_SITE = http://regex.info/code

define LUAJSON_INSTALL
	$(INSTALL_DATA) -D $(DL_DIR)/$($(PKG)_SOURCE) $(TARGET_datadir)/lua/$(LUA_ABIVERSION)/$($(PKG)_SOURCE)
	ln -sf $($(PKG)_SOURCE) $(TARGET_datadir)/lua/$(LUA_ABIVERSION)/json.lua
endef
LUAJSON_INDIVIDUAL_HOOKS += LUAJSON_INSTALL

luajson: | $(TARGET_DIR)
	$(call individual-package,$(PKG_NO_EXTRACT) $(PKG_NO_PATCHES))
