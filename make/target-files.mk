#
# makefile to install system files
#
# -----------------------------------------------------------------------------

files-etc: \
	$(TARGET_sysconfdir)/default/rcS \
	$(TARGET_sysconfdir)/network/interfaces \
	$(TARGET_sysconfdir)/date-dummy \
	$(TARGET_sysconfdir)/exports \
	$(TARGET_sysconfdir)/filesystems \
	$(TARGET_sysconfdir)/fstab \
	$(TARGET_sysconfdir)/group \
	$(TARGET_sysconfdir)/hosts \
	$(TARGET_sysconfdir)/inetd.conf \
	$(TARGET_sysconfdir)/issue.net \
	$(TARGET_sysconfdir)/nsswitch.conf \
	$(TARGET_sysconfdir)/passwd \
	$(TARGET_sysconfdir)/profile \
	$(TARGET_sysconfdir)/profile.local \
	$(TARGET_sysconfdir)/profile.d \
	$(TARGET_sysconfdir)/protocols \
	$(TARGET_sysconfdir)/services

PHONY += $(TARGET_sysconfdir)/profile.d

# -----------------------------------------------------------------------------

$(TARGET_sysconfdir)/default/rcS:
	$(INSTALL_DATA) -D $(TARGET_FILES)/files-etc/default/rcS $(@)

$(TARGET_sysconfdir)/network/interfaces:
ifeq ($(PERSISTENT_VAR_PARTITION),yes)
	$(INSTALL_DATA) -D $(TARGET_FILES)/files-etc/network/interfaces $(TARGET_localstatedir)/etc/network/interfaces
else
	$(INSTALL_DATA) -D $(TARGET_FILES)/files-etc/network/interfaces $(@)
endif

$(TARGET_sysconfdir)/date-dummy:
	echo "$(shell date +%Y)01010000" > $(@)

$(TARGET_sysconfdir)/exports:
ifeq ($(PERSISTENT_VAR_PARTITION),yes)
	$(INSTALL_DATA) -D $(TARGET_FILES)/files-etc/exports-var $(TARGET_localstatedir)/etc/exports
else
	$(INSTALL_DATA) -D $(TARGET_FILES)/files-etc/exports $(@)
endif

$(TARGET_sysconfdir)/filesystems:
	$(INSTALL_DATA) -D $(TARGET_FILES)/files-etc/filesystems $(@)

$(TARGET_sysconfdir)/fstab:
	$(INSTALL_DATA) -D $(TARGET_FILES)/files-etc/fstab $(@)

$(TARGET_sysconfdir)/group:
	$(INSTALL_DATA) -D $(TARGET_FILES)/files-etc/group $(@)

$(TARGET_sysconfdir)/hosts:
	$(INSTALL_DATA) -D $(TARGET_FILES)/files-etc/hosts $(@)

$(TARGET_sysconfdir)/inetd.conf:
	$(INSTALL_DATA) -D $(TARGET_FILES)/files-etc/inetd.conf $(@)

$(TARGET_sysconfdir)/issue.net:
	$(INSTALL_DATA) -D $(TARGET_FILES)/files-etc/issue.net $(@)

$(TARGET_sysconfdir)/nsswitch.conf:
	$(INSTALL_DATA) -D $(TARGET_FILES)/files-etc/nsswitch.conf $(@)

$(TARGET_sysconfdir)/passwd:
ifeq ($(PERSISTENT_VAR_PARTITION),yes)
	$(INSTALL_DATA) -D $(TARGET_FILES)/files-etc/passwd $(TARGET_localstatedir)/etc/passwd
else
	$(INSTALL_DATA) -D $(TARGET_FILES)/files-etc/passwd $(@)
endif

$(TARGET_sysconfdir)/profile:
	$(INSTALL_DATA) -D $(TARGET_FILES)/files-etc/profile $(@)

$(TARGET_sysconfdir)/profile.local:
ifeq ($(PERSISTENT_VAR_PARTITION),yes)
	$(INSTALL_DATA) -D $(TARGET_FILES)/files-etc/profile.local-var $(TARGET_localstatedir)/etc/profile.local
else
	$(INSTALL_DATA) -D $(TARGET_FILES)/files-etc/profile.local $(@)
endif

$(TARGET_sysconfdir)/profile.d:
	$(foreach p,$(wildcard $(TARGET_FILES)/files-etc/profile.d/*.sh),\
		$(INSTALL_DATA) -D $(p) $(TARGET_sysconfdir)/profile.d/$(notdir $(p))$(sep))

$(TARGET_sysconfdir)/services:
	$(INSTALL_DATA) -D $(TARGET_FILES)/files-etc/services $(@)

$(TARGET_sysconfdir)/protocols:
	$(INSTALL_DATA) -D $(TARGET_FILES)/files-etc/protocols $(@)

# -----------------------------------------------------------------------------

files-var-etc: \
	$(TARGET_localstatedir)/etc/fstab

# -----------------------------------------------------------------------------

$(TARGET_localstatedir)/etc/fstab:
	$(INSTALL_DATA) -D $(TARGET_FILES)/files-etc/fstab-var $(@)
