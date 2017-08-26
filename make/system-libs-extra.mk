# makefile to build system libs (currently unused in ni-image)

LIBID3TAG_VER=0.15.1b
$(ARCHIVE)/libid3tag-$(LIBID3TAG_VER).tar.gz:
	$(WGET) http://downloads.sourceforge.net/project/mad/libid3tag/$(LIBID3TAG_VER)/libid3tag-$(LIBID3TAG_VER).tar.gz

$(D)/libid3tag: $(D)/zlib $(ARCHIVE)/libid3tag-$(LIBID3TAG_VER).tar.gz | $(TARGETPREFIX)
	$(UNTAR)/libid3tag-$(LIBID3TAG_VER).tar.gz
	pushd $(BUILD_TMP)/libid3tag-$(LIBID3TAG_VER) && \
		$(PATCH)/libid3tag.diff && \
		$(CONFIGURE) \
			--prefix= \
			--enable-shared=yes && \
		$(MAKE) all && \
		make install DESTDIR=$(TARGETPREFIX) && \
		sed "s!^prefix=.*!prefix=$(TARGETPREFIX)!;" id3tag.pc > $(PKG_CONFIG_PATH)/libid3tag.pc
	$(REWRITE_LIBTOOL)/libid3tag.la
	$(REMOVE)/libid3tag-$(LIBID3TAG_VER)
	touch $@

LIBFLAC_VER=1.3.2
$(ARCHIVE)/flac-$(LIBFLAC_VER).tar.xz:
	$(WGET) http://prdownloads.sourceforge.net/sourceforge/flac/flac-$(LIBFLAC_VER).tar.xz

$(D)/libFLAC: $(ARCHIVE)/flac-$(LIBFLAC_VER).tar.xz | $(TARGETPREFIX)
	$(UNTAR)/flac-$(LIBFLAC_VER).tar.xz
	cp -f $(HELPERS_DIR)/new_autoconfig/* $(BUILD_TMP)/flac-$(LIBFLAC_VER)
	set -e; cd $(BUILD_TMP)/flac-$(LIBFLAC_VER); \
		$(CONFIGURE) \
			--prefix= \
			--datarootdir=/.remove \
			--enable-shared \
			--disable-static \
			--disable-cpplibs \
			--disable-xmms-plugin \
			--disable-ogg \
			--disable-altivec; \
		$(MAKE) all && \
		make install DESTDIR=$(TARGETPREFIX) && \
	$(REWRITE_PKGCONF) $(PKG_CONFIG_PATH)/flac.pc
	$(REWRITE_LIBTOOL)/libFLAC.la
	rm -rf $(TARGETPREFIX)/bin/flac
	rm -rf $(TARGETPREFIX)/bin/metaflac
	$(REMOVE)/flac-$(LIBFLAC_VER)
	touch $@

LIBROXML_VER=2.3.0
$(ARCHIVE)/libroxml-$(LIBROXML_VER).tar.gz:
	$(WGET) http://download.libroxml.net/pool/v2.x/libroxml-$(LIBROXML_VER).tar.gz

$(D)/libroxml: $(ARCHIVE)/libroxml-$(LIBROXML_VER).tar.gz | $(TARGETPREFIX)
	$(UNTAR)/libroxml-$(LIBROXML_VER).tar.gz
	set -e; cd $(BUILD_TMP)/libroxml-$(LIBROXML_VER); \
		$(CONFIGURE) \
			--prefix= \
			--disable-xml-read-write \
			--enable-xml-small-input-file \
			--disable-xml-commit-xml-tree \
			--disable-xml-xpath-engine \
		$(MAKE); \
		$(MAKE) install DESTDIR=$(TARGETPREFIX)
		$(REWRITE_PKGCONF) $(PKG_CONFIG_PATH)/libroxml.pc
	$(REMOVE)/libroxml-$(LIBROXML_VER)
	touch $@
