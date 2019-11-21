#
# makefile to install system files
#
# -----------------------------------------------------------------------------

files-etc: \
	$(TARGET_DIR)/etc/default/rcS \
	$(TARGET_DIR)/etc/inittab

$(TARGET_DIR)/etc/default/rcS:
	$(INSTALL_DATA) -D $(TARGET_FILES)/files-etc/default/rcS $(@)

$(TARGET_DIR)/etc/inittab:
	$(INSTALL_DATA) -D $(TARGET_FILES)/files-etc/inittab $(@)
