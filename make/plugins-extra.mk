# makefile for plugins (currently unused in ni-image)

FritzBoxAction: convert
	mkdir -p $(VARPLUGINS) && \
	pushd $(SOURCES)/FritzBoxAction && \
	cp -f FritzBoxAction $(VARPLUGINS)/ && \
	mkdir -pv $(FLEX) && \
	cp -f flex_FritzBoxAction.conf $(FLEX)/

convert: $(BIN)/convert
$(BIN)/convert:
	mkdir -p $(BIN) && \
	pushd $(SOURCES)/FritzBoxAction/convert && \
	$(TARGET)-gcc $(TARGET_CFLAGS) -o $@ convert.c

#logoview
logoview: $(SOURCE_DIR)/$(TUXBOX_PLUGINS) $(D)/neutrino $(BIN)/logoview
$(BIN)/logoview: $(BIN)
	pushd $(SOURCE_DIR)/$(TUXBOX_PLUGINS)/logoview && \
	$(MAKE) logoview CROSS_CDK=$(CROSS_DIR) BUILDSYSTEM=$(BASE_DIR) N_HD_SOURCE=$(SOURCE_DIR)/$(NI_NEUTRINO) TARGET=$(TARGET) && \
	install -m755 logoview $@ && \
	$(MAKE) clean

#blockads
blockads: $(SOURCE_DIR)/$(TUXBOX_PLUGINS) $(BIN)/blockad $(LIBPLUGINS)/blockads.so
$(BIN)/blockad: $(D)/freetype $(BIN) $(VARCONFIG)
	pushd $(SOURCE_DIR)/$(TUXBOX_PLUGINS)/blockads && \
	$(TARGET)-gcc $(TARGET_CFLAGS) $(TARGET_LDFLAGS) -I$(TARGET_INCLUDE_DIR)/freetype2 -lfreetype -lz $(CORTEX-STRINGS) -o $@ blockad.c globals.c http.c && \
	install -m644 blockads.conf $(VARCONFIG)/

$(LIBPLUGINS)/blockads.so: $(LIBPLUGINS)
	pushd $(SOURCE_DIR)/$(TUXBOX_PLUGINS)/blockads && \
	$(TARGET)-gcc $(TARGET_CFLAGS) $(TARGET_LDFLAGS) -I$(TARGET_INCLUDE_DIR)/freetype2 -lfreetype -lz $(CORTEX-STRINGS) -o $@ blockads.c gfx.c io.c text.c globals.c http.c && \
	install -m644 blockads.cfg $(LIBPLUGINS)/

stbup: $(BIN)/stbup
$(BIN)/stbup: $(BIN)
	pushd $(SOURCES)/stbup && \
	$(TARGET)-gcc $(TARGET_CFLAGS) $(TARGET_LDFLAGS) stbup.c -o $@ && \
	install -m 644 stbup.conf $(TARGET_DIR)/etc && \
	install -m 755 stbup.init $(TARGET_DIR)/etc/init.d/stbup
	ln -s stbup $(TARGET_DIR)/etc/init.d/S99stbup
	ln -s stbup $(TARGET_DIR)/etc/init.d/K01stbup
