#
# makefile to build static libraries
#
# -----------------------------------------------------------------------------

STATIC_LIBS =
ifeq ($(BOXSERIES), $(filter $(BOXSERIES), hd2 hd51 bre2ze4k))
  STATIC_LIBS += cortex-strings
endif

static-libs: $(STATIC_LIBS)

# -----------------------------------------------------------------------------

CORTEX-STRINGS_VER    = 48fd30c
CORTEX-STRINGS_TMP    = cortex-strings-$(CORTEX-STRINGS_VER)
CORTEX-STRINGS_SOURCE = cortex-strings-$(CORTEX-STRINGS_VER).tar.bz2
CORTEX-STRINGS_URL    = http://git.linaro.org/git-ro/toolchain/cortex-strings.git

$(ARCHIVE)/$(CORTEX-STRINGS_SOURCE):
	$(GET-GIT-ARCHIVE) $(CORTEX-STRINGS_URL) $(CORTEX-STRINGS_VER) $(@F) $(ARCHIVE)

CORTEX-STRINGS_CONF   = $(if $(filter $(BOXSERIES), hd51 bre2ze4k), --with-neon, --without-neon)

cortex-strings: $(STATIC_LIB_DIR)/libcortex-strings.la
$(STATIC_LIB_DIR)/libcortex-strings.la: $(ARCHIVE)/$(CORTEX-STRINGS_SOURCE) | $(TARGET_DIR)
	$(REMOVE)/$(CORTEX-STRINGS_TMP)
	$(UNTAR)/$(CORTEX-STRINGS_SOURCE)
	$(CHDIR)/$(CORTEX-STRINGS_TMP); \
		./autogen.sh; \
		CFLAGS="-pipe -O2 $(TARGET_DEBUGGING) $(CXX11_ABI) -I$(TARGET_INCLUDE_DIR)" \
		CPPFLAGS="-pipe -O2 $(TARGET_DEBUGGING) $(CXX11_ABI) -I$(TARGET_INCLUDE_DIR)" \
		CXXFLAGS="-pipe -O2 $(TARGET_DEBUGGING) $(CXX11_ABI) -I$(TARGET_INCLUDE_DIR)" \
		LDFLAGS="-Wl,-O1 -L$(TARGET_LIB_DIR)" \
		PKG_CONFIG_PATH=$(PKG_CONFIG_PATH) \
		./configure $(CONFIGURE_OPTS) \
			--prefix= \
			--disable-shared \
			--enable-static \
			$(CORTEX-STRINGS_CONF) \
			; \
		$(MAKE); \
		$(MAKE) install DESTDIR=$(STATIC_DIR)
	$(REWRITE_LIBTOOL_STATIC)/libcortex-strings.la
	$(REMOVE)/$(CORTEX-STRINGS_TMP)

# -----------------------------------------------------------------------------

PHONY += static-libs
PHONY += cortex-strings
