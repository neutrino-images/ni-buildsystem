################################################################################
#
# oscam-smod
#
################################################################################

OSCAM_SMOD_VERSION = master
OSCAM_SMOD_DIR = oscam-smod.git
OSCAM_SMOD_SOURCE = oscam-smod.git
OSCAM_SMOD_SITE = https://github.com/schimmelreiter
OSCAM_SMOD_SITE_METHOD = git

# inherit $(OSCAM_DEPENDENCIES) except oscam-emu
OSCAM_SMOD_DEPENDENCIES = $(subst oscam-emu,,$(OSCAM_DEPENDENCIES))

OSCAM_SMOD_KEEP_BUILD_DIR = $(OSCAM_KEEP_BUILD_DIR)

OSCAM_SMOD_CONF_OPTS = $(OSCAM_CONF_OPTS)
OSCAM_SMOD_CONFIGURE_CMDS = $(OSCAM_CONFIGURE_CMDS)

OSCAM_SMOD_LIST_SMARGO_BIN =# $(TARGET_localstatedir)/bin/osmod_list_smargo
OSCAM_SMOD_OSCAM_BIN = $(TARGET_localstatedir)/bin/osmod

OSCAM_SMOD_MAKE_ENV = $(OSCAM_MAKE_ENV)
OSCAM_SMOD_MAKE_OPTS = $(OSCAM_MAKE_OPTS)

ifeq ($(BOXMODEL),$(filter $(BOXMODEL),kronos kronos_v2))
OSCAM_SMOD_POST_PATCH_HOOKS += OSCAM_FIXUP_MAX_COOL_DMX
endif

OSCAM_SMOD_TARGET_FINALIZE_HOOKS += OSCAM_TARGET_CLEANUP

oscam-smod: | $(TARGET_DIR)
	$(call generic-package,$(PKG_NO_INSTALL))
