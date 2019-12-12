#
# makefile to install system files
#
# -----------------------------------------------------------------------------

files-etc: \
	$(TARGET_DIR)/etc/default/rcS \
	$(TARGET_DIR)/etc/fstab \
	$(TARGET_DIR)/etc/inittab

$(TARGET_DIR)/etc/default/rcS:
	$(INSTALL_DATA) -D $(TARGET_FILES)/files-etc/default/rcS $(@)

$(TARGET_DIR)/etc/fstab:
	$(INSTALL_DATA) -D $(TARGET_FILES)/files-etc/fstab $(@)

$(TARGET_DIR)/etc/inittab:
	$(INSTALL_DATA) -D $(TARGET_FILES)/files-etc/inittab $(@)

# -----------------------------------------------------------------------------

files-var-etc: \
	$(TARGET_DIR)/var/etc/fstab

$(TARGET_DIR)/var/etc/fstab:
	$(INSTALL_DATA) -D $(TARGET_FILES)/files-etc/fstab-var $(@)
