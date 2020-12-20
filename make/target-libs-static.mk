#
# makefile to build static libraries
#
# -----------------------------------------------------------------------------

LIBS-STATIC =
ifeq ($(BOXSERIES),$(filter $(BOXSERIES),hd2 hd5x hd6x vusolo4k vuduo4k vuduo4kse vuultimo4k vuzero4k vuuno4k vuuno4kse))
  LIBS-STATIC += cortex-strings
endif

libs-static: $(LIBS-STATIC) | $(TARGET_DIR)
	$(INSTALL_COPY) $(STATIC_DIR)/. $(TARGET_DIR)/
	$(REWRITE_LIBTOOL_LA)
	$(REWRITE_PKGCONF_PC)

# -----------------------------------------------------------------------------

CORTEX-STRINGS_VER    = 48fd30c
CORTEX-STRINGS_DIR    = cortex-strings-$(CORTEX-STRINGS_VER)
CORTEX-STRINGS_SOURCE = cortex-strings-$(CORTEX-STRINGS_VER).tar.bz2
CORTEX-STRINGS_SITE   = http://git.linaro.org/git-ro/toolchain/cortex-strings.git

$(DL_DIR)/$(CORTEX-STRINGS_SOURCE):
	$(GET-GIT-ARCHIVE) $(CORTEX-STRINGS_SITE) $(CORTEX-STRINGS_VER) $(@F) $(DL_DIR)

CORTEX-STRINGS_CONF   = $(if $(filter $(BOXSERIES),hd5x hd6x vusolo4k vuduo4k vuultimo4k vuzero4k vuuno4k vuuno4kse),--with-neon,--without-neon)

cortex-strings: $(STATIC_libdir)/libcortex-strings.la
$(STATIC_libdir)/libcortex-strings.la: $(DL_DIR)/$(CORTEX-STRINGS_SOURCE) | $(STATIC_DIR)
	$(REMOVE)/$(CORTEX-STRINGS_DIR)
	$(UNTAR)/$(CORTEX-STRINGS_SOURCE)
	$(CHDIR)/$(CORTEX-STRINGS_DIR); \
		./autogen.sh; \
		CFLAGS="-pipe -O2 $(TARGET_DEBUGGING) $(CXX11_ABI) -I$(TARGET_includedir)" \
		CPPFLAGS="-pipe -O2 $(TARGET_DEBUGGING) $(CXX11_ABI) -I$(TARGET_includedir)" \
		CXXFLAGS="-pipe -O2 $(TARGET_DEBUGGING) $(CXX11_ABI) -I$(TARGET_includedir)" \
		LDFLAGS="-Wl,-O1 -L$(TARGET_libdir)" \
		PKG_CONFIG_PATH=$(PKG_CONFIG_PATH) \
		./configure $(CONFIGURE_OPTS) \
			--prefix=$(prefix) \
			--disable-shared \
			--enable-static \
			$(CORTEX-STRINGS_CONF) \
			; \
		$(MAKE); \
		$(MAKE) install DESTDIR=$(STATIC_DIR)
	$(REMOVE)/$(CORTEX-STRINGS_DIR)

# -----------------------------------------------------------------------------

PHONY += libs-static
PHONY += cortex-strings
