################################################################################
#
# Kconfig package infrastructure
#
################################################################################

#
# Manipulation of .config files based on the Kconfig infrastructure.
# Used by the BusyBox package, the Linux kernel package, and more.
#

# KCONFIG_DOT_CONFIG ([file])
# Returns the path to the .config file that should be used, which will
# be $(1) if provided, or the current package .config file otherwise.
KCONFIG_DOT_CONFIG = $(strip \
	$(if $(strip $(1)), $(1), \
		$(PKG_BUILD_DIR)/$($(PKG)_KCONFIG_DOTCONFIG) \
	) \
)

# KCONFIG_MUNGE_DOT_CONFIG (option, newline [, file])
define KCONFIG_MUNGE_DOT_CONFIG
	$(SED) "/\\<$(strip $(1))\\>/d" $(call KCONFIG_DOT_CONFIG,$(3))
	echo '$(strip $(2))' >> $(call KCONFIG_DOT_CONFIG,$(3))
endef

# KCONFIG_ENABLE_OPT (option [, file])
KCONFIG_ENABLE_OPT  = $(call KCONFIG_MUNGE_DOT_CONFIG, $(1), $(1)=y, $(2))
# KCONFIG_SET_OPT (option, value [, file])
KCONFIG_SET_OPT     = $(call KCONFIG_MUNGE_DOT_CONFIG, $(1), $(1)=$(2), $(3))
# KCONFIG_DISABLE_OPT  (option [, file])
KCONFIG_DISABLE_OPT = $(call KCONFIG_MUNGE_DOT_CONFIG, $(1), $(SHARP_SIGN) $(1) is not set, $(2))

# -----------------------------------------------------------------------------

define kconfig-package
	$(eval PKG_MODE = $(pkg-mode))
	$(call PREPARE,$(1))
	$(if $(filter $(1),$(PKG_NO_BUILD)),,$(call TARGET_MAKE_BUILD))
	$(if $(filter $(1),$(PKG_NO_INSTALL)),,$(call TARGET_MAKE_INSTALL))
	$(call TARGET_FOLLOWUP)
endef
