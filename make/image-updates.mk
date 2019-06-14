#
# makefile for image updates
#
# -----------------------------------------------------------------------------

BOXSERIES_UPDATE = hd2 hd51 bre2ze4k
ifneq ($(DEBUG), yes)
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
	echo "sync; /bin/busybox reboot"		>> $(POSTINSTALL_SH)
	$(MAKE) neutrino
	install -D -m 0755 $(TARGET_DIR)/etc/init.d/start_neutrino $(UPDATE_INST_DIR)/etc/init.d/start_neutrino
	install -D -m 0755 $(TARGET_DIR)/bin/neutrino $(UPDATE_INST_DIR)/bin/neutrino
	install -D -m 0644 $(TARGET_SHARE_DIR)/tuxbox/neutrino/locale/deutsch.locale $(UPDATE_INST_DIR)/share/tuxbox/neutrino/locale/deutsch.locale
	install -D -m 0644 $(TARGET_SHARE_DIR)/tuxbox/neutrino/locale/english.locale $(UPDATE_INST_DIR)/share/tuxbox/neutrino/locale/english.locale
ifneq ($(DEBUG), yes)
	find $(UPDATE_INST_DIR)/bin -type f ! -name *.sh -print0 | xargs -0 $(TARGET)-strip || true
endif
	$(MAKE) u-update-bin \
			UPDATE_MD5FILE=$(UPDATE_MD5FILE-BOXSERIES)

# -----------------------------------------------------------------------------

u-neutrino-full: neutrino-clean
	$(MAKE) u-init
	echo "killall start_neutrino neutrino; sleep 5"	>> $(PREINSTALL_SH)
	echo "sync; /bin/busybox reboot"		>> $(POSTINSTALL_SH)
	$(MAKE) neutrino N_INST_DIR=$(UPDATE_INST_DIR)
	install -D -m 0755 $(TARGET_DIR)/etc/init.d/start_neutrino $(UPDATE_INST_DIR)/etc/init.d/start_neutrino
ifneq ($(DEBUG), yes)
	find $(UPDATE_INST_DIR)/bin -type f ! -name *.sh -print0 | xargs -0 $(TARGET)-strip || true
endif
ifeq ($(BOXSERIES), hd2)
	# avoid overrides in user's var-partition
	mv $(UPDATE_INST_DIR)/var $(UPDATE_INST_DIR)/var_init
endif
	$(MAKE) u-update-bin \
			UPDATE_MD5FILE=$(UPDATE_MD5FILE-BOXSERIES)

# -----------------------------------------------------------------------------

u-update.urls: update.urls
	$(MAKE) u-init
	echo "wget -q "http://localhost/control/message?popup=update.urls%20installed." -O /dev/null"	>> $(POSTINSTALL_SH)
	mkdir -pv $(UPDATE_INST_DIR)/var/etc
	cp -f $(TARGET_DIR)/var/etc/update.urls $(UPDATE_INST_DIR)/var/etc/
	$(MAKE) u-update-bin \
			UPDATE_NAME=update.urls \
			UPDATE_DESC=update.urls

# -----------------------------------------------------------------------------

u-pr-auto-timer:
	$(MAKE) u-init
	install -m 0755 $(SOURCE_DIR)/$(NI_NEUTRINO-PLUGINS)/scripts-sh/plugins/pr-auto-timer/update-ctrl/preinstall.sh $(PREINSTALL_SH)
	install -m 0755 $(SOURCE_DIR)/$(NI_NEUTRINO-PLUGINS)/scripts-sh/plugins/pr-auto-timer/update-ctrl/postinstall.sh $(POSTINSTALL_SH)
	install -d $(UPDATE_INST_DIR)/share/tuxbox/neutrino/plugins
	install -m 0755 $(SOURCE_DIR)/$(NI_NEUTRINO-PLUGINS)/scripts-sh/plugins/pr-auto-timer/pr-auto-timer.sh $(UPDATE_INST_DIR)/share/tuxbox/neutrino/plugins/
	install -m 0644 $(SOURCE_DIR)/$(NI_NEUTRINO-PLUGINS)/scripts-sh/plugins/pr-auto-timer/pr-auto-timer.cfg $(UPDATE_INST_DIR)/share/tuxbox/neutrino/plugins/
	install -m 0755 $(SOURCE_DIR)/$(NI_NEUTRINO-PLUGINS)/scripts-sh/plugins/pr-auto-timer/pr-auto-timer $(UPDATE_INST_DIR)/share/tuxbox/neutrino/plugins/
	install -m 0755 $(SOURCE_DIR)/$(NI_NEUTRINO-PLUGINS)/scripts-sh/plugins/pr-auto-timer/pr-auto-timer_hint.png $(UPDATE_INST_DIR)/share/tuxbox/neutrino/plugins/
	install -m 0755 $(SOURCE_DIR)/$(NI_NEUTRINO-PLUGINS)/scripts-sh/plugins/pr-auto-timer/auto-record-cleaner $(UPDATE_INST_DIR)/share/tuxbox/neutrino/plugins/
	install -d $(UPDATE_INST_DIR)/var/tuxbox/config
	install -m 0644 $(SOURCE_DIR)/$(NI_NEUTRINO-PLUGINS)/scripts-sh/plugins/pr-auto-timer/pr-auto-timer.conf.template $(UPDATE_INST_DIR)/var/tuxbox/config/
	install -m 0644 $(SOURCE_DIR)/$(NI_NEUTRINO-PLUGINS)/scripts-sh/plugins/pr-auto-timer/pr-auto-timer.rules.template $(UPDATE_INST_DIR)/var/tuxbox/config/
	install -m 0644 $(SOURCE_DIR)/$(NI_NEUTRINO-PLUGINS)/scripts-sh/plugins/pr-auto-timer/auto-record-cleaner.conf.template $(UPDATE_INST_DIR)/var/tuxbox/config/
	install -m 0644 $(SOURCE_DIR)/$(NI_NEUTRINO-PLUGINS)/scripts-sh/plugins/pr-auto-timer/auto-record-cleaner.rules.template $(UPDATE_INST_DIR)/var/tuxbox/config/
	PKG_VERSION=`cat $(SOURCE_DIR)/$(NI_NEUTRINO-PLUGINS)/scripts-sh/plugins/pr-auto-timer/pr-auto-timer | grep '^VERSION' | cut -d= -f2`; \
	$(MAKE) u-update-bin \
			UPDATE_MD5FILE=pr-auto-timer.txt \
			UPDATE_URL=$(NI-SERVER)/plugins/pr-auto-timer \
			UPDATE_NAME=pr-auto-timer_$${PKG_VERSION//./} \
			UPDATE_DESC=Auto-Timer \
			UPDATE_VERSION=$$PKG_VERSION

# -----------------------------------------------------------------------------

CHANNELLISTS_URL = $(NI-SERVER)/channellists
CHANNELLISTS_MD5FILE = lists.txt

channellists: matze-192 matze-192-130 pathauf-192

matze-192 \
matze-192-130 \
pathauf-192:
	$(MAKE) u-init
	install -m 0755 $(IMAGEFILES)/channellists/update-ctrl/preinstall.sh $(PREINSTALL_SH)
	install -m 0755 $(IMAGEFILES)/channellists/update-ctrl/postinstall.sh $(POSTINSTALL_SH)
	mkdir -pv $(UPDATE_INST_DIR)/var/tuxbox/config/zapit && \
	cp -f $(IMAGEFILES)/channellists/$@/* $(UPDATE_INST_DIR)/var/tuxbox/config/zapit/
	# remove non-printable chars and re-format xml-files
	$(CD) $(UPDATE_INST_DIR)/var/tuxbox/config/zapit/; \
	for file in *.xml; do \
		sed -i 's/[^[:print:]]//g' $$file; \
		XMLLINT_INDENT="	" \
		xmllint --format $$file > _$$file; \
		mv _$$file $$file; \
	done
	# sync sat-names with current satellites.xml
	# Astra 19.2
	A192=`grep 'position=\"192\"' $(SOURCE_DIR)/$(NI_NEUTRINO)/data/config/satellites.xml`; \
	A192=`echo $$A192`; \
	sed -i "/position=\"192\"/c\	$$A192" $(UPDATE_INST_DIR)/var/tuxbox/config/zapit/services.xml
	# Hotbird 13.0
	H130=`grep 'position=\"130\"' $(SOURCE_DIR)/$(NI_NEUTRINO)/data/config/satellites.xml`; \
	H130=`echo $$H130`; \
	sed -i "/position=\"130\"/c\	$$H130" $(UPDATE_INST_DIR)/var/tuxbox/config/zapit/services.xml
	#
	# we should try to keep this array table up-to-date ;-)
	#
	DIR[0]="#directory"	&& DESC[0]="#description"		&& DATE[0]="#date"	 ; \
	DIR[1]="matze-192"	&& DESC[1]="matze-Settings 19.2"	&& DATE[1]="10.06.2019"	 ; \
	DIR[2]="matze-192-130"	&& DESC[2]="matze-Settings 19.2, 13.0"	&& DATE[2]="10.06.2019"	 ; \
	DIR[3]="pathauf-192"	&& DESC[3]="pathAuf-Settings 19.2"	&& DATE[3]="10.01.2019"	 ; \
	#; \
	i=0; \
	for dir in $${DIR[*]}; do \
		if [ $$dir = $@ ]; \
		then \
			desc=$${DESC[$$i]}; \
			date=$${DATE[$$i]}; \
			break; \
		else \
			i=$$((i+1)); \
		fi; \
	done && \
	$(MAKE) u-update-bin \
			UPDATE_TYPE=S \
			UPDATE_URL=$(CHANNELLISTS_URL) \
			UPDATE_MD5FILE=$(CHANNELLISTS_MD5FILE) \
			UPDATE_NAME=$@ \
			UPDATE_DESC="$$desc - " \
			UPDATE_VERSION="$$date" \

# -----------------------------------------------------------------------------

u-custom:
	$(MAKE) u-update-bin \
			UPDATE_MD5FILE=custom_bin.txt \
			UPDATE_NAME=custom_bin \
			UPDATE_DESC="Custom Package" \
			UPDATE_VERSION="0.00"

# -----------------------------------------------------------------------------

u-init: u-clean | $(UPDATE_DIR)
	mkdir -p $(UPDATE_INST_DIR)
	mkdir -p $(UPDATE_CTRL_DIR)
	echo -e "#!/bin/sh\n#"	> $(PREINSTALL_SH)
	chmod 0755 $(PREINSTALL_SH)
	echo -e "#!/bin/sh\n#"	> $(POSTINSTALL_SH)
	chmod 0755 $(POSTINSTALL_SH)

u-clean:
	rm -rf $(UPDATE_TEMP_DIR)

u-clean-all: u-clean
	rm -rf $(UPDATE_DIR)

u-update-bin:
	$(CD) $(BUILD_TMP); \
		tar -czvf $(UPDATE_DIR)/$(UPDATE_NAME).bin temp_inst
	echo $(UPDATE_URL)/$(UPDATE_NAME).bin $(UPDATE_TYPE)$(UPDATE_VER)$(UPDATE_DATE) `md5sum $(UPDATE_DIR)/$(UPDATE_NAME).bin | cut -c1-32` $(UPDATE_DESC) $(UPDATE_VERSION) >> $(UPDATE_DIR)/$(UPDATE_MD5FILE)
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
PHONY += channellists
PHONY += matze-192
PHONY += matze-192-130
PHONY += pathauf-192
PHONY += u-custom
PHONY += u-init
PHONY += u-clean
PHONY += u-clean-all
PHONY += u-update-bin
