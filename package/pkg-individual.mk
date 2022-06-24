################################################################################
#
# Individual packages
#
################################################################################

define INDIVIDUAL
	@$(call MESSAGE,"Individual build")
	$(foreach hook,$($(PKG)_INDIVIDUAL_HOOKS),$(call $(hook))$(sep))
	$(TOUCH)
endef

# -----------------------------------------------------------------------------

define individual-package
	$(call PREPARE)
	$(call INDIVIDUAL)
	$(call TARGET_FOLLOWUP)
endef

# -----------------------------------------------------------------------------

define host-individual-package
	$(call PREPARE)
	$(call INDIVIDUAL)
	$(call HOST_FOLLOWUP)
endef
