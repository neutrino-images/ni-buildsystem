################################################################################
#
# cortex-strings
#
################################################################################

# Optimized memcpy, memset, strlen, strcmp, ... for ARM Cortex-A cores by
# Linaro. Used for hd2 only: its uClibc-ng has less optimized routines than
# glibc on the other arm boxes. Built as static library only; hd2 links it
# into every binary via -lcortex-strings in CORTEX_STRINGS_LDFLAG (see
# make/environment-build.mk), so the linker takes these routines instead
# of the ones from the C library. Nothing of it gets into the image itself.
#
# cortex-strings is no longer developed; its successor are the Arm
# Optimized Routines, which are no drop-in replacement (other build system,
# other symbol names). This version builds with the options below.

CORTEX_STRINGS_VERSION = 499d1a6
CORTEX_STRINGS_DIR = cortex-strings.git
CORTEX_STRINGS_SOURCE = cortex-strings.git
CORTEX_STRINGS_SITE = http://git.linaro.org/git-ro/toolchain
CORTEX_STRINGS_SITE_METHOD = git

# own flags instead of TARGET_*FLAGS, as TARGET_LDFLAGS contains
# -lcortex-strings, i.e. the library to be built here
CORTEX_STRINGS_CONF_ENV = \
	CFLAGS="-pipe -O2 $(TARGET_DEBUGGING) $(CXX11_ABI) -I$(TARGET_includedir)" \
	CPPFLAGS="-pipe -O2 $(TARGET_DEBUGGING) $(CXX11_ABI) -I$(TARGET_includedir)" \
	CXXFLAGS="-pipe -O2 $(TARGET_DEBUGGING) $(CXX11_ABI) -I$(TARGET_includedir)" \
	LDFLAGS="-Wl,-O1 -L$(TARGET_libdir)"

# tuned routines for the Cortex-A9 of hd2, which has VFP but no NEON
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

# hd2 has VFPv3 with 16 double registers only;
# build for this FPU, as TARGET_ABI does
define CORTEX_STRINGS_PATCH_MAKEFILE
	$(SED) 's|-mfpu=vfp|-mfpu=vfpv3-d16|' $(PKG_BUILD_DIR)/Makefile.am
endef
CORTEX_STRINGS_POST_PATCH_HOOKS += CORTEX_STRINGS_PATCH_MAKEFILE

# must be installed before the first target package is linked; therefore
# part of 'bootstrap' (see make/buildsystem-bootstrap.mk)
cortex-strings: | $(TARGET_DIR)
	$(call autotools-package)
