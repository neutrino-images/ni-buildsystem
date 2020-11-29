#
# makefile to install system files
#
# -----------------------------------------------------------------------------

files-etc: \
	$(TARGET_sysconfdir)/default/rcS \
	$(TARGET_sysconfdir)/fstab \
	$(TARGET_sysconfdir)/inittab

$(TARGET_sysconfdir)/default/rcS:
	$(INSTALL_DATA) -D $(TARGET_FILES)/files-etc/default/rcS $(@)

$(TARGET_sysconfdir)/fstab:
	$(INSTALL_DATA) -D $(TARGET_FILES)/files-etc/fstab $(@)

$(TARGET_sysconfdir)/inittab:
	$(INSTALL_DATA) -D $(TARGET_FILES)/files-etc/inittab $(@)

# -----------------------------------------------------------------------------

files-var-etc: \
	$(TARGET_localstatedir)/etc/fstab

$(TARGET_localstatedir)/etc/fstab:
	$(INSTALL_DATA) -D $(TARGET_FILES)/files-etc/fstab-var $(@)
