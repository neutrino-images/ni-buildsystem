# makefile to build static libraries

cortex-strings: $(STATICLIB)/libcortex-strings.la
$(STATICLIB)/libcortex-strings.la: $(ARCHIVE)/cortex-strings-$(CORTEX-STRINGS_VER).tar.bz2 | $(TARGETPREFIX)
	$(UNTAR)/cortex-strings-$(CORTEX-STRINGS_VER).tar.bz2
	pushd $(BUILD_TMP)/cortex-strings-$(CORTEX-STRINGS_VER) && \
		$(CONFIGURE_NON_CORTEX) \
			--prefix= \
			--disable-shared \
			--enable-static \
			--without-neon && \
		$(MAKE) && \
		$(MAKE) install DESTDIR=$(STATIC_DIR) && \
	$(REWRITE_LIBTOOL_STATIC)/libcortex-strings.la
	$(REMOVE)/cortex-strings-$(CORTEX-STRINGS_VER)
