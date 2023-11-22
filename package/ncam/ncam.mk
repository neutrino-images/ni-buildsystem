################################################################################
#
# ncam
#
################################################################################

NCAM_VERSION = master
NCAM_DIR = ncam.git
NCAM_SOURCE = ncam.git
NCAM_SITE = https://github.com/fairbird
NCAM_SITE_METHOD = git

# inherit $(OSCAM_DEPENDENCIES) except oscam-emu
NCAM_DEPENDENCIES = $(subst oscam-emu,,$(OSCAM_DEPENDENCIES))

NCAM_KEEP_BUILD_DIR = $(OSCAM_KEEP_BUILD_DIR)

NCAM_CONF_OPTS = $(OSCAM_CONF_OPTS)
NCAM_CONFIGURE_CMDS = $(OSCAM_CONFIGURE_CMDS)

NCAM_LIST_SMARGO_BIN =# $(TARGET_localstatedir)/bin/ncam_list_smargo
NCAM_OSCAM_BIN = $(TARGET_localstatedir)/bin/ncam

NCAM_MAKE_ENV = $(OSCAM_MAKE_ENV)
NCAM_MAKE_OPTS = $(subst OSCAM_BIN,NCAM_BIN,$(OSCAM_MAKE_OPTS))

# enable libcurl
NCAM_DEPENDENCIES += libcurl
NCAM_MAKE_OPTS += \
	USE_LIBCURL=1 \

# enable emu by default
NCAM_CONF_OPTS += \
	WITH_EMU \
	WITH_SOFTCAM

ifeq ($(BOXMODEL),$(filter $(BOXMODEL),kronos kronos_v2))
NCAM_POST_PATCH_HOOKS += OSCAM_FIXUP_MAX_COOL_DMX
endif

NCAM_TARGET_FINALIZE_HOOKS += OSCAM_TARGET_CLEANUP

ncam: | $(TARGET_DIR)
	$(call generic-package,$(PKG_NO_INSTALL))
