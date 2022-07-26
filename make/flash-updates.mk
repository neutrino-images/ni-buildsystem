#
# makefile for image updates
#
# -----------------------------------------------------------------------------

BOXSERIES_UPDATE = hd2 hd5x hd6x vusolo4k vuduo4k vuduo4kse vuultimo4k vuzero4k vuuno4k vuuno4kse vuduo
ifneq ($(DEBUG),yes)
	BOXSERIES_UPDATE += hd1
endif

neutrino-update \
ni-neutrino-update:
	make u-neutrino

neutrino-updates \
ni-neutrino-updates:
	for boxseries in $(BOXSERIES_UPDATE); do \
		$(MAKE) BOXSERIES=$${boxseries} clean neutrino-update || exit; \
	done;
	make clean

neutrino-full-update \
ni-neutrino-full-update:
	make u-neutrino-full

neutrino-full-updates \
ni-neutrino-full-updates:
	for boxseries in $(BOXSERIES_UPDATE); do \
		$(MAKE) BOXSERIES=$${boxseries} clean neutrino-full-update || exit; \
	done;
	make clean

# -----------------------------------------------------------------------------

u-neutrino: neutrino-clean
	$(MAKE) u-init
	echo "killall start_neutrino neutrino; sleep 5"	>> $(PREINSTALL_SH)
	echo "sync; reboot"				>> $(POSTINSTALL_SH)
	$(MAKE) neutrino
	$(INSTALL_EXEC) -D $(TARGET_sysconfdir)/init.d/start_neutrino $(UPDATE_INST_DIR)$(sysconfdir)/init.d/start_neutrino
	$(INSTALL_EXEC) -D $(TARGET_bindir)/neutrino $(UPDATE_INST_DIR)$(bindir)/neutrino
	$(INSTALL_DATA) -D $(TARGET_datadir)/tuxbox/neutrino/locale/deutsch.locale $(UPDATE_INST_DIR)$(datadir)/tuxbox/neutrino/locale/deutsch.locale
	$(INSTALL_DATA) -D $(TARGET_datadir)/tuxbox/neutrino/locale/english.locale $(UPDATE_INST_DIR)$(datadir)/tuxbox/neutrino/locale/english.locale
ifneq ($(DEBUG),yes)
	find $(UPDATE_INST_DIR)$(bindir) -type f ! -name *.sh -print0 | xargs -0 $(TARGET_STRIP) || true
endif
	$(MAKE) u-update-bin \
			UPDATE_DATE=$(shell date +%Y%m%d%H%M) \
			UPDATE_MD5FILE=$(UPDATE_MD5FILE_BOXSERIES) \
			UPDATE_NAME=$(UPDATE_PREFIX)-$(UPDATE_SUFFIX) \
			UPDATE_DESC="Neutrino [$(BOXTYPE_SC)][$(BOXSERIES)] Update \(simple\)"

# -----------------------------------------------------------------------------

u-neutrino-full: neutrino-clean
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

# -----------------------------------------------------------------------------

u-update.urls: update.urls
	$(MAKE) u-init
	echo "wget -q "http://localhost/control/message?popup=update.urls%20installed." -O /dev/null"	>> $(POSTINSTALL_SH)
	$(INSTALL) -d $(UPDATE_INST_DIR)/var/etc
	cp -f $(TARGET_localstatedir)/etc/update.urls $(UPDATE_INST_DIR)/var/etc/
	$(MAKE) u-update-bin \
			UPDATE_NAME=update.urls \
			UPDATE_DESC=update.urls

# -----------------------------------------------------------------------------

u-pr-auto-timer:
	$(MAKE) u-init
	$(INSTALL_EXEC) $(SOURCE_DIR)/$(NI_NEUTRINO_PLUGINS)/scripts-sh/plugins/pr-auto-timer/update-ctrl/preinstall.sh $(PREINSTALL_SH)
	$(INSTALL_EXEC) $(SOURCE_DIR)/$(NI_NEUTRINO_PLUGINS)/scripts-sh/plugins/pr-auto-timer/update-ctrl/postinstall.sh $(POSTINSTALL_SH)
	$(INSTALL) -d $(UPDATE_INST_DIR)/share/tuxbox/neutrino/plugins
	$(INSTALL_EXEC) $(SOURCE_DIR)/$(NI_NEUTRINO_PLUGINS)/scripts-sh/plugins/pr-auto-timer/pr-auto-timer.sh $(UPDATE_INST_DIR)/share/tuxbox/neutrino/plugins/
	$(INSTALL_DATA) $(SOURCE_DIR)/$(NI_NEUTRINO_PLUGINS)/scripts-sh/plugins/pr-auto-timer/pr-auto-timer.cfg $(UPDATE_INST_DIR)/share/tuxbox/neutrino/plugins/
	$(INSTALL_EXEC) $(SOURCE_DIR)/$(NI_NEUTRINO_PLUGINS)/scripts-sh/plugins/pr-auto-timer/pr-auto-timer $(UPDATE_INST_DIR)/share/tuxbox/neutrino/plugins/
	$(INSTALL_EXEC) $(SOURCE_DIR)/$(NI_NEUTRINO_PLUGINS)/scripts-sh/plugins/pr-auto-timer/pr-auto-timer_hint.png $(UPDATE_INST_DIR)/share/tuxbox/neutrino/plugins/
	$(INSTALL_EXEC) $(SOURCE_DIR)/$(NI_NEUTRINO_PLUGINS)/scripts-sh/plugins/pr-auto-timer/auto-record-cleaner $(UPDATE_INST_DIR)/share/tuxbox/neutrino/plugins/
	$(INSTALL) -d $(UPDATE_INST_DIR)/var/tuxbox/config
	$(INSTALL_DATA) $(SOURCE_DIR)/$(NI_NEUTRINO_PLUGINS)/scripts-sh/plugins/pr-auto-timer/pr-auto-timer.conf.template $(UPDATE_INST_DIR)/var/tuxbox/config/
	$(INSTALL_DATA) $(SOURCE_DIR)/$(NI_NEUTRINO_PLUGINS)/scripts-sh/plugins/pr-auto-timer/pr-auto-timer.rules.template $(UPDATE_INST_DIR)/var/tuxbox/config/
	$(INSTALL_DATA) $(SOURCE_DIR)/$(NI_NEUTRINO_PLUGINS)/scripts-sh/plugins/pr-auto-timer/auto-record-cleaner.conf.template $(UPDATE_INST_DIR)/var/tuxbox/config/
	$(INSTALL_DATA) $(SOURCE_DIR)/$(NI_NEUTRINO_PLUGINS)/scripts-sh/plugins/pr-auto-timer/auto-record-cleaner.rules.template $(UPDATE_INST_DIR)/var/tuxbox/config/
	PKG_VERSION=`cat $(SOURCE_DIR)/$(NI_NEUTRINO_PLUGINS)/scripts-sh/plugins/pr-auto-timer/pr-auto-timer | grep '^VERSION' | cut -d= -f2`; \
	$(MAKE) u-update-bin \
			UPDATE_MD5FILE=pr-auto-timer.txt \
			UPDATE_SITE=$(NI_SERVER)/plugins/pr-auto-timer \
			UPDATE_NAME=pr-auto-timer_$${PKG_VERSION//./} \
			UPDATE_DESC=Auto-Timer \
			UPDATE_VERSION=$$PKG_VERSION

# -----------------------------------------------------------------------------

u-custom:
	$(MAKE) u-update-bin \
			UPDATE_MD5FILE=custom_bin.txt \
			UPDATE_NAME=custom_bin \
			UPDATE_DESC="Custom Package" \
			UPDATE_VERSION="0.00"

# -----------------------------------------------------------------------------

u-init: u-clean | $(UPDATE_DIR)
	$(INSTALL) -d $(UPDATE_INST_DIR)
	$(INSTALL) -d $(UPDATE_CTRL_DIR)
	echo -e "#!/bin/sh\n#"	> $(PREINSTALL_SH)
	chmod 0755 $(PREINSTALL_SH)
	echo -e "#!/bin/sh\n#"	> $(POSTINSTALL_SH)
	chmod 0755 $(POSTINSTALL_SH)

u-clean:
	rm -rf $(UPDATE_TEMP_DIR)

u-clean-all: u-clean
	rm -rf $(UPDATE_DIR)

u-update-bin:
	$(CD) $(BUILD_DIR); \
		tar -czvf $(UPDATE_DIR)/$(UPDATE_NAME).bin temp_inst
	echo $(UPDATE_SITE)/$(UPDATE_NAME).bin $(UPDATE_VERSION_STRING) `md5sum $(UPDATE_DIR)/$(UPDATE_NAME).bin | cut -c1-32` $(UPDATE_DESC) $(UPDATE_VERSION) >> $(UPDATE_DIR)/$(UPDATE_MD5FILE)
	$(MAKE) u-clean

# -----------------------------------------------------------------------------

PHONY += neutrino-update ni-neutrino-update
PHONY += neutrino-updates ni-neutrino-updates
PHONY += neutrino-full-update ni-neutrino-full-update
PHONY += neutrino-full-updates ni-neutrino-full-updates

PHONY += u-neutrino
PHONY += u-neutrino-full
PHONY += u-update.urls
PHONY += u-pr-auto-timer
PHONY += u-custom
PHONY += u-init
PHONY += u-clean
PHONY += u-clean-all
PHONY += u-update-bin
