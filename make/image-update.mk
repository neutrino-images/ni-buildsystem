# makefile for image updates

UPDATE_INST_DIR	= $(BUILD_TMP)/temp_inst/inst
UPDATE_CTRL_DIR	= $(BUILD_TMP)/temp_inst/ctrl

POSTINSTALL_SH	= $(UPDATE_CTRL_DIR)/postinstall.sh
PREINSTALL_SH	= $(UPDATE_CTRL_DIR)/preinstall.sh

# defaults for Neutrino-Update
UPDATE_DATE	= $(shell date +%Y%m%d%H%M)
UPDATE_VERSION	= $(IMAGE_VERSION)
UPDATE_VERSION_STRING = $(IMAGE_VERSION_STRING)

UPDATE_PREFIX	= $(IMAGE_PREFIX)
UPDATE_SUFFIX	= $(BOXTYPE_SC)-$(BOXSERIES)-update

UPDATE_NAME	= $(UPDATE_PREFIX)-$(UPDATE_SUFFIX)
UPDATE_DESC	= "Neutrino [$(BOXTYPE_SC)][$(BOXSERIES)] Update"
UPDATE_TYPE	= U
# 0 = "Release"
# 1 = "Beta"
# 2 = "Internal"
# L = "Locale"
# S = "Settings"
# U = "Update"
# A = "Addon"
# T = "Text"

UPDATE_URL	= $(NI-SERVER)/$(NI-SUBDIR)
UPDATE_MD5FILE	= update.txt
UPDATE_MD5FILE-BOXSERIES= update-$(BOXTYPE_SC)-$(BOXSERIES).txt
UPDATE_MD5FILE-BOXMODEL	= update-$(BOXTYPE_SC)-$(BOXMODEL).txt

CHANLIST_URL	= $(NI-SERVER)/channellists
CHANLIST_MD5FILE= lists.txt

channellists: matze-19 matze-19-13 pathauf_HD-19

u-FritzCallMonitor:
	$(MAKE) u-init
	echo "killall FritzCallMonitor"										>> $(PREINSTALL_SH)
	echo "wget -q \"http://localhost/control/message?popup=FritzCallMonitor%20installed.\" -O /dev/null"	>> $(POSTINSTALL_SH)
	echo "sleep 5"												>> $(POSTINSTALL_SH)
	echo "/bin/sync"											>> $(POSTINSTALL_SH)
	mkdir -pv $(UPDATE_INST_DIR)/bin && \
	mkdir -pv $(UPDATE_INST_DIR)/var/tuxbox/config && \
	cp -f $(BIN)/FritzCallMonitor $(UPDATE_INST_DIR)/bin/ && \
	cp -f $(TARGET_DIR)/var/tuxbox/config/FritzCallMonitor.cfg $(UPDATE_INST_DIR)/var/tuxbox/config/
	$(MAKE) u-update-bin \
			UPDATE_MD5FILE=$(UPDATE_MD5FILE-BOXMODEL) \
			UPDATE_NAME=FritzCallMonitor-$(BOXMODEL) \
			UPDATE_DESC=FritzCallMonitor-$(BOXMODEL) \
			UPDATE_VERSION_STRING=`cat $(SOURCES)/FritzCallMonitor/FritzCallMonitor.h | grep 'define VERSION' | cut -d\" -f2`

u-FritzInfoMonitor:
	$(MAKE) u-init
	echo "killall FritzCallMonitor"										>> $(PREINSTALL_SH)
	echo "wget -q \"http://localhost/control/message?popup=FritzInfoMonitor%20installed.\" -O /dev/null"	>> $(POSTINSTALL_SH)
	echo "sleep 5"												>> $(POSTINSTALL_SH)
	echo "/bin/sync"											>> $(POSTINSTALL_SH)
	mkdir -pv $(UPDATE_INST_DIR)/var/tuxbox/config && \
	mkdir -pv $(UPDATE_INST_DIR)/lib/tuxbox/plugins && \
	cp -f $(LIBPLUGINS)/FritzInfoMonitor.cfg $(UPDATE_INST_DIR)/lib/tuxbox/plugins/ && \
	cp -f $(LIBPLUGINS)/FritzInfoMonitor.so $(UPDATE_INST_DIR)/lib/tuxbox/plugins/ && \
	cp -f $(TARGET_DIR)/var/tuxbox/config/FritzCallMonitor.cfg $(UPDATE_INST_DIR)/var/tuxbox/config/
	$(MAKE) u-update-bin \
			UPDATE_MD5FILE=$(UPDATE_MD5FILE-BOXMODEL) \
			UPDATE_NAME=FritzInfoMonitor-$(BOXMODEL) \
			UPDATE_DESC=FritzInfoMonitor-$(BOXMODEL) \
			UPDATE_VERSION_STRING=`cat $(SOURCES)/FritzCallMonitor/FritzInfoMonitor/FritzInfoMonitor.h | grep 'define VERSION' | cut -d\" -f2`

u-lcd4linux: $(D)/lcd4linux
ifneq ($(DEBUG), yes)
	$(TARGET)-strip $(TARGET_DIR)/bin/lcd4linux
endif
	$(MAKE) u-init
	echo "service lcd4linux stop"									>> $(PREINSTALL_SH)
	echo "wget -q \"http://localhost/control/message?popup=LCD4Linux%20installed.\" -O /dev/null"	>> $(POSTINSTALL_SH)
	echo "sleep 5"											>> $(POSTINSTALL_SH)
	echo "/bin/sync"										>> $(POSTINSTALL_SH)
	echo "service lcd4linux start"									>> $(POSTINSTALL_SH)
	mkdir -pv $(UPDATE_INST_DIR)/bin && \
	cp -f $(TARGET_DIR)/bin/lcd4linux $(UPDATE_INST_DIR)/bin/ && \
	$(MAKE) u-update-bin \
			UPDATE_MD5FILE=$(UPDATE_MD5FILE-BOXSERIES) \
			UPDATE_NAME=lcd4linux-$(BOXSERIES) \
			UPDATE_DESC="LCD4Linux [$(BOXSERIES)]" \
			UPDATE_VERSION_STRING=`strings $(TARGET_DIR)/bin/lcd4linux | grep -m1 LCD4Linux | cut -d" " -f2`

u-pr-auto-timer:
	$(MAKE) u-init
	install -m755 $(SOURCE_DIR)/$(NI_NEUTRINO-PLUGINS)/scripts-sh/plugins/pr-auto-timer/update-ctrl/preinstall.sh $(PREINSTALL_SH)
	install -m755 $(SOURCE_DIR)/$(NI_NEUTRINO-PLUGINS)/scripts-sh/plugins/pr-auto-timer/update-ctrl/postinstall.sh $(POSTINSTALL_SH)
	mkdir -pv $(UPDATE_INST_DIR)/lib/tuxbox/plugins
	install -m755 $(SOURCE_DIR)/$(NI_NEUTRINO-PLUGINS)/scripts-sh/plugins/pr-auto-timer/pr-auto-timer.sh $(UPDATE_INST_DIR)/lib/tuxbox/plugins/
	install -m644 $(SOURCE_DIR)/$(NI_NEUTRINO-PLUGINS)/scripts-sh/plugins/pr-auto-timer/pr-auto-timer.cfg $(UPDATE_INST_DIR)/lib/tuxbox/plugins/
	install -m755 $(SOURCE_DIR)/$(NI_NEUTRINO-PLUGINS)/scripts-sh/plugins/pr-auto-timer/pr-auto-timer $(UPDATE_INST_DIR)/lib/tuxbox/plugins/
	install -m755 $(SOURCE_DIR)/$(NI_NEUTRINO-PLUGINS)/scripts-sh/plugins/pr-auto-timer/pr-auto-timer_hint.png $(UPDATE_INST_DIR)/lib/tuxbox/plugins/
	install -m755 $(SOURCE_DIR)/$(NI_NEUTRINO-PLUGINS)/scripts-sh/plugins/pr-auto-timer/auto-record-cleaner $(UPDATE_INST_DIR)/lib/tuxbox/plugins/
	mkdir -pv $(UPDATE_INST_DIR)/var/tuxbox/config
	install -m644 $(SOURCE_DIR)/$(NI_NEUTRINO-PLUGINS)/scripts-sh/plugins/pr-auto-timer/pr-auto-timer.conf.template $(UPDATE_INST_DIR)/var/tuxbox/config/
	install -m644 $(SOURCE_DIR)/$(NI_NEUTRINO-PLUGINS)/scripts-sh/plugins/pr-auto-timer/pr-auto-timer.rules.template $(UPDATE_INST_DIR)/var/tuxbox/config/
	install -m644 $(SOURCE_DIR)/$(NI_NEUTRINO-PLUGINS)/scripts-sh/plugins/pr-auto-timer/auto-record-cleaner.conf.template $(UPDATE_INST_DIR)/var/tuxbox/config/
	install -m644 $(SOURCE_DIR)/$(NI_NEUTRINO-PLUGINS)/scripts-sh/plugins/pr-auto-timer/auto-record-cleaner.rules.template $(UPDATE_INST_DIR)/var/tuxbox/config/
	VERSION_STRING=`cat $(SOURCE_DIR)/$(NI_NEUTRINO-PLUGINS)/scripts-sh/plugins/pr-auto-timer/pr-auto-timer | grep '^VERSION' | cut -d= -f2`; \
	$(MAKE) u-update-bin \
			UPDATE_MD5FILE=pr-auto-timer.txt \
			UPDATE_URL=$(NI-SERVER)/plugins/pr-auto-timer \
			UPDATE_NAME=pr-auto-timer_$${VERSION_STRING//./} \
			UPDATE_DESC=Auto-Timer \
			UPDATE_VERSION_STRING=$$VERSION_STRING

u-neutrino: neutrino-clean
	$(MAKE) u-init
	echo "killall start_neutrino neutrino; sleep 5"	>> $(PREINSTALL_SH)
	echo "sync; /bin/busybox reboot"		>> $(POSTINSTALL_SH)
	$(MAKE) neutrino
	install -D -m 0644 $(TARGET_DIR)/.version $(UPDATE_INST_DIR)/.version
	install -D -m 0755 $(TARGET_DIR)/etc/init.d/start_neutrino $(UPDATE_INST_DIR)/etc/init.d/start_neutrino
	install -D -m 0755 $(TARGET_DIR)/bin/neutrino $(UPDATE_INST_DIR)/bin/neutrino
	install -D -m 0644 $(TARGET_DIR)/share/tuxbox/neutrino/locale/deutsch.locale $(UPDATE_INST_DIR)/share/tuxbox/neutrino/locale/deutsch.locale
	install -D -m 0644 $(TARGET_DIR)/share/tuxbox/neutrino/locale/english.locale $(UPDATE_INST_DIR)/share/tuxbox/neutrino/locale/english.locale
ifneq ($(DEBUG), yes)
	find $(UPDATE_INST_DIR)/bin -type f ! -name *.sh -print0 | xargs -0 $(TARGET)-strip || true
endif
	$(MAKE) u-update-bin \
			UPDATE_MD5FILE=$(UPDATE_MD5FILE-BOXSERIES)

u-neutrino-full: neutrino-clean
	$(MAKE) u-init
	echo "killall start_neutrino neutrino; sleep 5"	>> $(PREINSTALL_SH)
	echo "sync; /bin/busybox reboot"		>> $(POSTINSTALL_SH)
	$(MAKE) neutrino NEUTRINO_INST_DIR=$(UPDATE_INST_DIR)
	install -D -m 0644 $(TARGET_DIR)/.version $(UPDATE_INST_DIR)/.version
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

u-openvpn-setup:
	$(MAKE) u-init
	echo "rm -f /var/etc/init.d/openvpn"									>> $(PREINSTALL_SH)
	echo "cd /tmp/"												>> $(POSTINSTALL_SH)
	echo "wget -q "http://localhost/control/message?popup=OpenVPN-Plugin%20installed." -O /dev/null"	>> $(POSTINSTALL_SH)
	echo "wget -q "http://localhost/control/reloadplugins" -O /dev/null"					>> $(POSTINSTALL_SH)
	#$(MAKE) openvpn
	#$(TARGET)-strip $(TARGET_DIR)/sbin/openvpn
	#mkdir -p $(UPDATE_INST_DIR)/var/sbin  && \
	#cp -f $(TARGET_DIR)/sbin/openvpn $(UPDATE_INST_DIR)/var/sbin
	cp -a $(SOURCES)/openvpn-setup/* $(UPDATE_INST_DIR)/
	$(MAKE) u-update-bin \
			UPDATE_NAME=openvpn-setup-$(BOXSERIES)-v011 \
			UPDATE_DESC="OpenVPN-Setup" \
			UPDATE_VERSION_STRING="0.11"

u-update.urls: update.urls
	$(MAKE) u-init
	echo "wget -q "http://localhost/control/message?popup=update.urls%20installed." -O /dev/null"	>> $(POSTINSTALL_SH)
	mkdir -pv $(UPDATE_INST_DIR)/var/etc
	cp -f $(TARGET_DIR)/var/etc/update.urls $(UPDATE_INST_DIR)/var/etc/
	$(MAKE) u-update-bin \
			UPDATE_NAME=update.urls \
			UPDATE_DESC=update.urls

u-custom:
	$(MAKE) u-update-bin \
			UPDATE_MD5FILE=custom_bin.txt \
			UPDATE_NAME=custom_bin \
			UPDATE_DESC="Custom Package" \
			UPDATE_VERSION_STRING="0.00"

# --- channellists ---

matze-19 \
matze-19-13 \
pathauf_HD-19:
	$(MAKE) u-init
	install -m755 $(IMAGEFILES)/channellists/update-ctrl/preinstall.sh $(PREINSTALL_SH)
	install -m755 $(IMAGEFILES)/channellists/update-ctrl/postinstall.sh $(POSTINSTALL_SH)
	mkdir -pv $(UPDATE_INST_DIR)/var/tuxbox/config/zapit && \
	cp -f $(IMAGEFILES)/channellists/$@/* $(UPDATE_INST_DIR)/var/tuxbox/config/zapit/
	# remove non-printable chars and re-format xml-files
	cd $(UPDATE_INST_DIR)/var/tuxbox/config/zapit/; \
	for file in *.xml; do \
		sed -i 's/[^[:print:]]//g' $$file; \
		XMLLINT_INDENT="	" \
		xmllint --format $$file > _$$file; \
		mv _$$file $$file; \
	done
	# sync sat-names with current satellites.xml
	# Astra 19.2
	A192=`grep 'position=\"192\"' $(SOURCE_DIR)/$(NI_NEUTRINO)/data/satellites.xml`; \
	A192=`echo $$A192`; \
	sed -i "/position=\"192\"/c\	$$A192" $(UPDATE_INST_DIR)/var/tuxbox/config/zapit/services.xml
	# Hotbird 13.0
	H130=`grep 'position=\"130\"' $(SOURCE_DIR)/$(NI_NEUTRINO)/data/satellites.xml`; \
	H130=`echo $$H130`; \
	sed -i "/position=\"130\"/c\	$$H130" $(UPDATE_INST_DIR)/var/tuxbox/config/zapit/services.xml
	#
	# we should try to keep this array table up-to-date ;-)
	#
	DIR[0]="#directory"	&& DESC[0]="#description"			&& DATE[0]="#date"	 ; \
	DIR[1]="matze-19"	&& DESC[1]="Matze-Settings 19.2"		&& DATE[1]="21.10.2018"	 ; \
	DIR[2]="matze-19-13"	&& DESC[2]="Matze-Settings 19.2, 13.0"		&& DATE[2]="21.10.2018"	 ; \
	DIR[3]="pathauf_HD-19"	&& DESC[3]="pathAuf-HD+-Settings 19.2"		&& DATE[3]="29.06.2018"	 ; \
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
			UPDATE_URL=$(CHANLIST_URL) \
			UPDATE_MD5FILE=$(CHANLIST_MD5FILE) \
			UPDATE_NAME=$@ \
			UPDATE_DESC="$$desc - " \
			UPDATE_VERSION_STRING="$$date" \

u-update-bin:
	pushd $(BUILD_TMP) && \
		tar -czvf $(UPDATE_DIR)/$(UPDATE_NAME).bin temp_inst
	echo $(UPDATE_URL)/$(UPDATE_NAME).bin $(UPDATE_TYPE)$(UPDATE_VERSION)$(UPDATE_DATE) `md5sum $(UPDATE_DIR)/$(UPDATE_NAME).bin | cut -c1-32` $(UPDATE_DESC) $(UPDATE_VERSION_STRING) >> $(UPDATE_DIR)/$(UPDATE_MD5FILE)
	$(MAKE) u-clean

u-clean:
	rm -rf $(BUILD_TMP)/temp_inst

u-clean-all: u-clean
	rm -rf $(UPDATE_DIR)

u-init: u-clean | $(UPDATE_DIR)
	mkdir -p $(UPDATE_INST_DIR)
	mkdir -p $(UPDATE_CTRL_DIR)
	echo -e "#!/bin/sh\n#"	> $(PREINSTALL_SH)
	chmod 0755 $(PREINSTALL_SH)
	echo -e "#!/bin/sh\n#"	> $(POSTINSTALL_SH)
	chmod 0755 $(POSTINSTALL_SH)
