#
# makefile to build static libraries
#
# -----------------------------------------------------------------------------

LIBS-STATIC =
ifeq ($(BOXSERIES), $(filter $(BOXSERIES), hd2 hd5x hd6x vusolo4k vuduo4k vuduo4kse vuultimo4k vuzero4k vuuno4k vuuno4kse))
  LIBS-STATIC += cortex-strings
endif

libs-static: $(LIBS-STATIC)

# -----------------------------------------------------------------------------

CORTEX-STRINGS_VER    = 48fd30c
CORTEX-STRINGS_TMP    = cortex-strings-$(CORTEX-STRINGS_VER)
CORTEX-STRINGS_SOURCE = cortex-strings-$(CORTEX-STRINGS_VER).tar.bz2
CORTEX-STRINGS_SITE   = http://git.linaro.org/git-ro/toolchain/cortex-strings.git

$(DL_DIR)/$(CORTEX-STRINGS_SOURCE):
	$(GET-GIT-ARCHIVE) $(CORTEX-STRINGS_SITE) $(CORTEX-STRINGS_VER) $(@F) $(DL_DIR)

CORTEX-STRINGS_CONF   = $(if $(filter $(BOXSERIES), hd5x hd6x vusolo4k vuduo4k vuultimo4k vuzero4k vuuno4k vuuno4kse),--with-neon,--without-neon)

cortex-strings: $(STATIC_LIB_DIR)/libcortex-strings.la
$(STATIC_LIB_DIR)/libcortex-strings.la: $(DL_DIR)/$(CORTEX-STRINGS_SOURCE) | $(STATIC_DIR)
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

PHONY += libs-static
PHONY += cortex-strings
