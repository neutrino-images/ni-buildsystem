################################################################################
#
# neutrino updates
#
################################################################################

neutrino-update: neutrino-clean
	$(MAKE) u-init
	echo "killall start_neutrino neutrino; sleep 5"	>> $(PREINSTALL_SH)
	echo "sync; reboot"				>> $(POSTINSTALL_SH)
	$(MAKE) neutrino
	$(INSTALL_EXEC) -D $(TARGET_sysconfdir)/init.d/start_neutrino $(UPDATE_INST_DIR)$(sysconfdir)/init.d/start_neutrino
	$(INSTALL_EXEC) -D $(TARGET_bindir)/neutrino $(UPDATE_INST_DIR)$(bindir)/neutrino
	$(INSTALL_DATA) -D $(TARGET_datadir)/tuxbox/neutrino/locale/deutsch.locale $(UPDATE_INST_DIR)$(datadir)/tuxbox/neutrino/locale/deutsch.locale
	$(INSTALL_DATA) -D $(TARGET_datadir)/tuxbox/neutrino/locale/english.locale $(UPDATE_INST_DIR)$(datadir)/tuxbox/neutrino/locale/english.locale
	$(INSTALL) -d $(UPDATE_INST_DIR)$(datadir)/tuxbox/neutrino/httpd
	$(INSTALL_COPY) $(TARGET_datadir)/tuxbox/neutrino/httpd/ni-web $(UPDATE_INST_DIR)$(datadir)/tuxbox/neutrino/httpd
ifneq ($(DEBUG),yes)
	find $(UPDATE_INST_DIR)$(bindir) -type f ! -name *.sh -print0 | xargs -0 $(TARGET_STRIP) || true
endif
	$(MAKE) u-update-bin \
			UPDATE_DATE=$(shell date +%Y%m%d%H%M) \
			UPDATE_MD5FILE=$(UPDATE_MD5FILE_BOXSERIES) \
			UPDATE_NAME=$(UPDATE_PREFIX)-$(UPDATE_SUFFIX) \
			UPDATE_DESC="Neutrino [$(BOXTYPE_SC)][$(BOXSERIES)] Update \(simple\)"

neutrino-update-full: neutrino-clean
	$(MAKE) u-init
	echo "killall start_neutrino neutrino; sleep 5"	>> $(PREINSTALL_SH)
	echo "sync; reboot"				>> $(POSTINSTALL_SH)
	$(MAKE) neutrino NEUTRINO_INST_DIR=$(UPDATE_INST_DIR)
	$(INSTALL_EXEC) -D $(TARGET_sysconfdir)/init.d/start_neutrino $(UPDATE_INST_DIR)$(sysconfdir)/init.d/start_neutrino
ifneq ($(DEBUG),yes)
	find $(UPDATE_INST_DIR)$(bindir) -type f ! -name *.sh -print0 | xargs -0 $(TARGET_STRIP) || true
endif
ifeq ($(PERSISTENT_VAR_PARTITION),yes)
	# avoid overrides in user's var-partition
	mv $(UPDATE_INST_DIR)/var $(UPDATE_INST_DIR)/var_init
endif
	$(MAKE) u-update-bin \
			UPDATE_DATE=$(shell date +%Y%m%d%H%M) \
			UPDATE_MD5FILE=$(UPDATE_MD5FILE_BOXSERIES) \
			UPDATE_NAME=$(UPDATE_PREFIX)-$(UPDATE_SUFFIX)-full \
			UPDATE_DESC="Neutrino [$(BOXTYPE_SC)][$(BOXSERIES)] Update \(full\)"
