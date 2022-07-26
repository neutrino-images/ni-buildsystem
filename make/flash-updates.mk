#
# makefile for image updates
#
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

PHONY += u-update.urls
PHONY += u-custom
PHONY += u-init
PHONY += u-clean
PHONY += u-clean-all
PHONY += u-update-bin
