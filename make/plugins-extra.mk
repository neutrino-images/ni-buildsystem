# makefile for plugins (currently unused in ni-image)

#links
links: $(SOURCE_DIR)/$(TUXBOX_PLUGINS) $(LIBPLUG)/links.so

$(LIBPLUG)/links.so: $(D)/zlib $(D)/openssl $(D)/libpng $(D)/libjpeg $(D)/giflib $(LIBPLUG) $(VARCONF)
	tar -C $(SOURCE_DIR)/$(TUXBOX_PLUGINS) -cp links --exclude-vcs | tar -C $(BUILD_TMP) -x
	cd $(BUILD_TMP)/links && \
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
	mv -f $(BIN)/links $(LIBPLUG)/links.so
	echo "name=Links Webbrowser"	 > $(LIBPLUG)/links.cfg
	echo "desc=Webbrowser"		>> $(LIBPLUG)/links.cfg
	echo "type=2"			>> $(LIBPLUG)/links.cfg
	echo "needfb=1"			>> $(LIBPLUG)/links.cfg
	echo "needrc=1"			>> $(LIBPLUG)/links.cfg
	echo "needoffsets=1"		>> $(LIBPLUG)/links.cfg
	echo "bookmarkcount=0"		 > $(VARCONF)/bookmarks
	mkdir -p $(VARCONF)/links
	touch $(VARCONF)/links/links.his
	install -m644 $(IMAGEFILES)/scripts/tables.tar.gz $(VARCONF)/links/
	install -m644 $(IMAGEFILES)/scripts/bookmarks.html $(VARCONF)/links/

FritzBoxAction: convert
	mkdir -p $(VARPLUG) && \
	pushd $(SOURCES)/FritzBoxAction && \
	cp -f FritzBoxAction $(VARPLUG)/ && \
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
	$(MAKE) logoview CROSS_CDK=$(CROSS_DIR) BUILDSYSTEM=$(BASE_DIR) N_HD_SOURCE=$(N_HD_SOURCE) TARGET=$(TARGET) && \
	install -m755 logoview $@ && \
	$(MAKE) clean

#blockads
blockads: $(SOURCE_DIR)/$(TUXBOX_PLUGINS) $(BIN)/blockad $(LIBPLUG)/blockads.so
$(BIN)/blockad: $(D)/freetype $(BIN) $(VARCONF)
	pushd $(SOURCE_DIR)/$(TUXBOX_PLUGINS)/blockads && \
	$(TARGET)-gcc $(TARGET_CFLAGS) $(TARGET_LDFLAGS) -I$(TARGETINCLUDE)/freetype2 -lfreetype -lz $(CORTEX-STRINGS) -o $@ blockad.c globals.c http.c && \
	install -m644 blockads.conf $(VARCONF)/

$(LIBPLUG)/blockads.so: $(LIBPLUG)
	pushd $(SOURCE_DIR)/$(TUXBOX_PLUGINS)/blockads && \
	$(TARGET)-gcc $(TARGET_CFLAGS) $(TARGET_LDFLAGS) -I$(TARGETINCLUDE)/freetype2 -lfreetype -lz $(CORTEX-STRINGS) -o $@ blockads.c gfx.c io.c text.c globals.c http.c && \
	install -m644 blockads.cfg $(LIBPLUG)/

stbup: $(BIN)/stbup
$(BIN)/stbup: $(BIN)
	pushd $(SOURCES)/stbup && \
	$(TARGET)-gcc $(TARGET_CFLAGS) $(TARGET_LDFLAGS) stbup.c -o $@ && \
	install -m 644 stbup.conf $(TARGET_DIR)/etc && \
	install -m 755 stbup.init $(TARGET_DIR)/etc/init.d/stbup
	ln -s stbup $(TARGET_DIR)/etc/init.d/S99stbup
	ln -s stbup $(TARGET_DIR)/etc/init.d/K01stbup
