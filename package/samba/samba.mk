################################################################################
#
# samba
#
################################################################################

SAMBA_DEPENDENCIES = $(if $(filter $(BOXSERIES),hd1),samba33,samba36)

samba: | $(TARGET_DIR)
	$(call virtual-package)
