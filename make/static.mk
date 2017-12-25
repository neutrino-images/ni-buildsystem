# makefile to build static libraries

static: cortex-strings

CORTEX-STRINGS_CONF =
ifneq ($(BOXSERIES), hd51)
	CORTEX-STRINGS_CONF = --without-neon
endif

cortex-strings: $(STATIC_LIB_DIR)/libcortex-strings.la
$(STATIC_LIB_DIR)/libcortex-strings.la: $(ARCHIVE)/cortex-strings-$(CORTEX-STRINGS_VER).tar.bz2 | $(TARGET_DIR)
	$(UNTAR)/cortex-strings-$(CORTEX-STRINGS_VER).tar.bz2
	pushd $(BUILD_TMP)/cortex-strings-$(CORTEX-STRINGS_VER) && \
		./autogen.sh && \
		CFLAGS="-pipe -O2 $(CXX11_ABI) -g -I$(TARGETINCLUDE)" \
		CPPFLAGS="-pipe -O2 $(CXX11_ABI) -g -I$(TARGETINCLUDE)" \
		CXXFLAGS="-pipe -O2 $(CXX11_ABI) -g -I$(TARGETINCLUDE)" \
		LDFLAGS="-Wl,-O1 -L$(TARGET_LIB_DIR)" \
		PKG_CONFIG_PATH=$(PKG_CONFIG_PATH) \
		./configure $(CONFIGURE_OPTS) \
			--prefix= \
			--disable-shared \
			--enable-static \
			$(CORTEX-STRINGS_CONF) && \
		$(MAKE) && \
		$(MAKE) install DESTDIR=$(STATIC_DIR) && \
	$(REWRITE_LIBTOOL_STATIC)/libcortex-strings.la
	$(REMOVE)/cortex-strings-$(CORTEX-STRINGS_VER)
