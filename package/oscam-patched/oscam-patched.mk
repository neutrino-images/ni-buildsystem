################################################################################
#
# oscam-patched
#
################################################################################

OSCAM_PATCHED_VERSION = master
OSCAM_PATCHED_DIR = oscam-patched.git
OSCAM_PATCHED_SOURCE = oscam-patched.git
OSCAM_PATCHED_SITE = https://github.com/oscam-emu
OSCAM_PATCHED_SITE_METHOD = git

# inherit $(OSCAM_DEPENDENCIES) except oscam-emu
OSCAM_PATCHED_DEPENDENCIES = $(subst oscam-emu,,$(OSCAM_DEPENDENCIES))

OSCAM_PATCHED_KEEP_BUILD_DIR = $(OSCAM_KEEP_BUILD_DIR)

OSCAM_PATCHED_CONF_OPTS = $(OSCAM_CONF_OPTS)
OSCAM_PATCHED_CONFIGURE_CMDS = $(OSCAM_CONFIGURE_CMDS)

OSCAM_PATCHED_LIST_SMARGO_BIN =# $(TARGET_localstatedir)/bin/osmod_list_smargo
OSCAM_PATCHED_OSCAM_BIN = $(TARGET_localstatedir)/bin/oscam

OSCAM_PATCHED_MAKE_ENV = $(OSCAM_MAKE_ENV)
OSCAM_PATCHED_MAKE_OPTS = $(OSCAM_MAKE_OPTS)

ifeq ($(BOXMODEL),$(filter $(BOXMODEL),kronos kronos_v2))
OSCAM_PATCHED_POST_PATCH_HOOKS += OSCAM_FIXUP_MAX_COOL_DMX
endif

OSCAM_PATCHED_TARGET_FINALIZE_HOOKS += OSCAM_TARGET_CLEANUP

oscam-patched: | $(TARGET_DIR)
	$(call generic-package,$(PKG_NO_INSTALL))
