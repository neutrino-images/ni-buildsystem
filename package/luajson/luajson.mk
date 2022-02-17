################################################################################
#
# luajson
#
################################################################################

LUAJSON_SOURCE = JSON.lua
LUAJSON_SITE = http://regex.info/code

$(DL_DIR)/$(LUAJSON_SOURCE):
	$(download) $(LUAJSON_SITE)/$(LUAJSON_SOURCE)

luajson: $(DL_DIR)/$(LUAJSON_SOURCE) | $(TARGET_DIR)
	$(CD) $(DL_DIR); \
		curl --remote-name --time-cond $(PKG_SOURCE) $(PKG_SITE)/$(PKG_SOURCE) || true
	$(INSTALL_DATA) -D $(DL_DIR)/$(PKG_SOURCE) $(TARGET_datadir)/lua/$(LUA_ABIVERSION)
	ln -sf $(PKG_SOURCE) $(TARGET_datadir)/lua/$(LUA_ABIVERSION)/json.lua
	$(TOUCH)
