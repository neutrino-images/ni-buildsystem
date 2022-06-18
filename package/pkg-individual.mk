################################################################################
#
# Individual packages
#
################################################################################

define individual-package
	$(call PREPARE)
	$(call INDIVIDUAL)
	$(call TARGET_FOLLOWUP)
endef

define host-individual-package
	$(call PREPARE)
	$(call INDIVIDUAL)
	$(call HOST_FOLLOWUP)
endef
