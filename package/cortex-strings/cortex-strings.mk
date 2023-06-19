################################################################################
#
# cortex-strings
#
################################################################################

CORTEX_STRINGS_VERSION = 499d1a6
CORTEX_STRINGS_DIR = cortex-strings.git
CORTEX_STRINGS_SOURCE = cortex-strings.git
CORTEX_STRINGS_SITE = http://git.linaro.org/git-ro/toolchain
CORTEX_STRINGS_SITE_METHOD = git

CORTEX_STRINGS_CONF_ENV = \
	CFLAGS="-pipe -O2 $(TARGET_DEBUGGING) $(CXX11_ABI) -I$(TARGET_includedir)" \
	CPPFLAGS="-pipe -O2 $(TARGET_DEBUGGING) $(CXX11_ABI) -I$(TARGET_includedir)" \
	CXXFLAGS="-pipe -O2 $(TARGET_DEBUGGING) $(CXX11_ABI) -I$(TARGET_includedir)" \
	LDFLAGS="-Wl,-O1 -L$(TARGET_libdir)"

CORTEX_STRINGS_CONF_OPTS = \
	$(TARGET_CONFIGURE_OPTS) \
	--with-cpu=cortex-a9 \
	--with-vfp \
	--without-neon \
	--enable-static \
	--disable-shared

define CORTEX_STRINGS_AUTOGEN_SH
	$(CD) $(PKG_BUILD_DIR); \
		./autogen.sh
endef
CORTEX_STRINGS_PRE_CONFIGURE_HOOKS += CORTEX_STRINGS_AUTOGEN_SH

define CORTEX_STRINGS_PATCH_MAKEFILE
	$(SED) 's|-mfpu=vfp|-mfpu=vfpv3-d16|' $(PKG_BUILD_DIR)/Makefile.am
endef
CORTEX_STRINGS_POST_PATCH_HOOKS += CORTEX_STRINGS_PATCH_MAKEFILE

cortex-strings: | $(STATIC_DIR)
	$(call autotools-package)
