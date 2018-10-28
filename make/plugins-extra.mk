# makefile for plugins (currently unused in ni-image)

#links
links: $(SOURCE_DIR)/$(TUXBOX_PLUGINS) $(LIBPLUGINS)/links.so

$(LIBPLUGINS)/links.so: $(D)/zlib $(D)/openssl $(D)/libpng $(D)/libjpeg $(D)/giflib $(LIBPLUGINS) $(VARCONF)
	$(REMOVE)/links
	tar -C $(SOURCE_DIR)/$(TUXBOX_PLUGINS) -cp links --exclude-vcs | tar -C $(BUILD_TMP) -x
	$(CHDIR)/links && \
		export CC=$(TARGET)-gcc && \
		export AR=$(TARGET)-ar && \
		export NM=$(TARGET)-nm && \
		export RANLIB=$(TARGET)-ranlib && \
		export OBJDUMP=$(TARGET)-objdump && \
		export STRIP=$(TARGET)-strip && \
		export SYSROOT=$(TARGET_DIR) && \
		export PKG_CONFIG_PATH=$(PKG_CONFIG_PATH) && \
		export LD_LIBRARY_PATH=$(TARGET_LIB_DIR) && \
		export CFLAGS="$(TARGET_CFLAGS)" && \
		export LIBS="$(TARGET_LDFLAGS) $(CORTEX-STRINGS)" && \
		./configure \
			--host=$(TARGET) \
			--build=$(BUILD) \
			--prefix= \
			--mandir=$(BUILD_TMP)/.remove \
			--without-svgalib \
			--without-directfb \
			--without-x \
			--without-libtiff \
			--enable-graphics \
			--enable-javascript && \
		$(MAKE) && \
		DESTDIR=$(TARGET_DIR) make install prefix=$(TARGET_DIR)
	$(REMOVE)/links
	mv -f $(BIN)/links $(LIBPLUGINS)/links.so
	echo "name=Links Webbrowser"	 > $(LIBPLUGINS)/links.cfg
	echo "desc=Webbrowser"		>> $(LIBPLUGINS)/links.cfg
	echo "type=2"			>> $(LIBPLUGINS)/links.cfg
	echo "needfb=1"			>> $(LIBPLUGINS)/links.cfg
	echo "needrc=1"			>> $(LIBPLUGINS)/links.cfg
	echo "needoffsets=1"		>> $(LIBPLUGINS)/links.cfg
	echo "bookmarkcount=0"		 > $(VARCONF)/bookmarks
	mkdir -p $(VARCONF)/links
	touch $(VARCONF)/links/links.his
	install -m644 $(IMAGEFILES)/scripts/tables.tar.gz $(VARCONF)/links/
	install -m644 $(IMAGEFILES)/scripts/bookmarks.html $(VARCONF)/links/

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
$(BIN)/blockad: $(D)/freetype $(BIN) $(VARCONF)
	pushd $(SOURCE_DIR)/$(TUXBOX_PLUGINS)/blockads && \
	$(TARGET)-gcc $(TARGET_CFLAGS) $(TARGET_LDFLAGS) -I$(TARGET_INCLUDE_DIR)/freetype2 -lfreetype -lz $(CORTEX-STRINGS) -o $@ blockad.c globals.c http.c && \
	install -m644 blockads.conf $(VARCONF)/

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
