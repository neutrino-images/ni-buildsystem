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
	$(REWRITE_LIBTOOL)

# -----------------------------------------------------------------------------

CORTEX_STRINGS_VERSION = 48fd30c
CORTEX_STRINGS_DIR = cortex-strings-$(CORTEX_STRINGS_VERSION)
CORTEX_STRINGS_SOURCE = cortex-strings-$(CORTEX_STRINGS_VERSION).tar.bz2
CORTEX_STRINGS_SITE = http://git.linaro.org/git-ro/toolchain/cortex-strings.git

$(DL_DIR)/$(CORTEX_STRINGS_SOURCE):
	$(GET-GIT-ARCHIVE) $(CORTEX_STRINGS_SITE) $(CORTEX_STRINGS_VERSION) $(@F) $(DL_DIR)

CORTEX_STRINGS_CONF_ENV = \
	CFLAGS="-pipe -O2 $(TARGET_DEBUGGING) $(CXX11_ABI) -I$(TARGET_includedir)" \
	CPPFLAGS="-pipe -O2 $(TARGET_DEBUGGING) $(CXX11_ABI) -I$(TARGET_includedir)" \
	CXXFLAGS="-pipe -O2 $(TARGET_DEBUGGING) $(CXX11_ABI) -I$(TARGET_includedir)" \
	LDFLAGS="-Wl,-O1 -L$(TARGET_libdir)"

CORTEX_STRINGS_CONF_OPTS = \
	$(TARGET_CONFIGURE_OPTS) \
	$(if $(filter $(BOXSERIES),hd5x hd6x vusolo4k vuduo4k vuultimo4k vuzero4k vuuno4k vuuno4kse),--with-neon,--without-neon) \
	--enable-static \
	--disable-shared

cortex-strings: $(STATIC_libdir)/libcortex-strings.la
$(STATIC_libdir)/libcortex-strings.la: $(DL_DIR)/$(CORTEX_STRINGS_SOURCE) | $(STATIC_DIR)
	$(REMOVE)/$(CORTEX_STRINGS_DIR)
	$(UNTAR)/$(CORTEX_STRINGS_SOURCE)
	$(CHDIR)/$(CORTEX_STRINGS_DIR); \
		./autogen.sh; \
		$(CORTEX_STRINGS_CONF_ENV) ./configure $(CORTEX_STRINGS_CONF_OPTS); \
		$(MAKE); \
		$(MAKE) install DESTDIR=$(STATIC_DIR)
	$(REMOVE)/$(CORTEX_STRINGS_DIR)

# -----------------------------------------------------------------------------

PHONY += libs-static
PHONY += cortex-strings
