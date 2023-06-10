################################################################################
#
# channellists
#
################################################################################

CHANNELLISTS_SITE = $(NI_SERVER)/channellists
CHANNELLISTS_MD5FILE = channellists.txt

channellists: matze-192 matze-192-130

# -----------------------------------------------------------------------------

MATZE_192_VERSION = 10.06.2023
MATZE_192_130_VERSION = $(MATZE_192_VERSION)

matze-192 \
matze-192-130:
	$(MAKE) u-init
	$(INSTALL_EXEC) $(PACKAGE_DIR)/channellists/files/update-ctrl/preinstall.sh $(PREINSTALL_SH)
	$(INSTALL_EXEC) $(PACKAGE_DIR)/channellists/files/update-ctrl/postinstall.sh $(POSTINSTALL_SH)
	$(INSTALL) -d $(UPDATE_INST_DIR)/var/tuxbox/config/zapit
	$(INSTALL_COPY) $(PACKAGE_DIR)/channellists/files/$(@)/* $(UPDATE_INST_DIR)/var/tuxbox/config/zapit/
	# remove non-printable chars and re-format xml-files
	$(CD) $(UPDATE_INST_DIR)/var/tuxbox/config/zapit/; \
	for file in *.xml; do \
		$(SED) 's/[^[:print:]]//g' $$file; \
		XMLLINT_INDENT="	" \
		xmllint --format $$file > _$$file; \
		mv _$$file $$file; \
	done
	# sync sat-names with current satellites.xml
	# Astra 19.2
	P192=`grep -m 1 'position=\"192\"' $(SOURCE_DIR)/$(NI_NEUTRINO)/data/config/satellites.xml`; \
	P192=`echo $$P192`; \
	$(SED) "/position=\"192\"/c\	$$P192" $(UPDATE_INST_DIR)/var/tuxbox/config/zapit/services.xml
	# Hotbird 13.0
	P130=`grep -m 1 'position=\"130\"' $(SOURCE_DIR)/$(NI_NEUTRINO)/data/config/satellites.xml`; \
	P130=`echo $$P130`; \
	$(SED) "/position=\"130\"/c\	$$P130" $(UPDATE_INST_DIR)/var/tuxbox/config/zapit/services.xml
	#
	DIR[0]="#directory"	; DESC[0]="#description"		; DATE[0]="#version"			; \
	DIR[1]="matze-192"	; DESC[1]="matze-Settings 19.2"		; DATE[1]="$(MATZE_192_VERSION)"	; \
	DIR[2]="matze-192-130"	; DESC[2]="matze-Settings 19.2, 13.0"	; DATE[2]="$(MATZE_192_130_VERSION)"	; \
	#; \
	i=0; \
	for dir in $${DIR[*]}; do \
		if [ $$dir = $(@) ]; \
		then \
			desc=$${DESC[$$i]}; \
			date=$${DATE[$$i]}; \
			break; \
		else \
			i=$$((i+1)); \
		fi; \
	done; \
	$(MAKE) u-update-bin \
			UPDATE_TYPE=S \
			UPDATE_SITE=$(CHANNELLISTS_SITE) \
			UPDATE_MD5FILE=$(CHANNELLISTS_MD5FILE) \
			UPDATE_NAME=$(@) \
			UPDATE_DESC="$$desc - " \
			UPDATE_VERSION="$$date"
