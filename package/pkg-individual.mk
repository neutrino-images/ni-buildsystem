################################################################################
#
# Individual package infrastructure
#
################################################################################

define INDIVIDUAL
	@$(call MESSAGE,"Individual build and/or install $(pkgname)")
	$(foreach hook,$($(PKG)_INDIVIDUAL_HOOKS),$(call $(hook))$(sep))
endef

# -----------------------------------------------------------------------------

define individual-package
	$(eval PKG_MODE = $(pkg-mode))
	$(call PREPARE,$(1))
	$(if $($(PKG)_INDIVIDUAL_HOOKS),$(call INDIVIDUAL))
	$(call TARGET_FOLLOWUP)
endef

# -----------------------------------------------------------------------------

define host-individual-package
	$(eval PKG_MODE = $(pkg-mode))
	$(call PREPARE,$(1))
	$(if $($(PKG)_INDIVIDUAL_HOOKS),$(call INDIVIDUAL))
	$(call HOST_FOLLOWUP)
endef

################################################################################
#
# Virtual package infrastructure
#
# - just to resolve dependencies and call $($(PKG)_INDIVIDUAL_HOOKS)
#
################################################################################

define virtual-package
	$(call individual-package,$(PKG_NO_DOWNLOAD) $(PKG_NO_EXTRACT) $(PKG_NO_PATCHES))
endef

# -----------------------------------------------------------------------------

define host-virtual-package
	$(call host-individual-package,$(PKG_NO_DOWNLOAD) $(PKG_NO_EXTRACT) $(PKG_NO_PATCHES))
endef
