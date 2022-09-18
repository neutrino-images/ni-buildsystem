################################################################################
#
# astra-sm
#
################################################################################

ASTRA_SM_VERSION = git
ASTRA_SM_DIR = astra-sm.$(ASTRA_SM_VERSION)
ASTRA_SM_SOURCE = astra-sm.$(ASTRA_SM_VERSION)
ASTRA_SM_SITE = https://github.com/crazycat69

ASTRA_SM_DEPENDENCIES = openssl

ASTRA_SM_AUTORECONF = YES

ASTRA_SM_CONF_OPTS = \
	--without-lua

define ASTRA_SM_PATCH_MAKEFILE
	$(SED) 's:(CFLAGS):(CFLAGS_FOR_BUILD):' $(PKG_BUILD_DIR)/tools/Makefile.am
endef
ASTRA_SM_POST_PATCH_HOOKS = ASTRA_SM_PATCH_MAKEFILE

astra-sm: | $(TARGET_DIR)
	$(call autotools-package)
