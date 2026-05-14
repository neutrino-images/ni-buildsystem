################################################################################
#
# dtv-scan-tables
#
################################################################################

DTV_SCAN_TABLES_VERSION = 15661aabc342b72f539d4600ad87df6663e23aa4
DTV_SCAN_TABLES_DIR = dtv-scan-tables.git
DTV_SCAN_TABLES_SOURCE = dtv-scan-tables.git
DTV_SCAN_TABLES_SITE = https://git.linuxtv.org
DTV_SCAN_TABLES_SITE_METHOD = git

define DTV_SCAN_TABLES_INSTALL
	for f in atsc dvb-c dvb-s dvb-t; do \
		$(INSTALL) -d $(TARGET_datarootdir)/dvb/$$f; \
		$(INSTALL_DATA) $(PKG_BUILD_DIR)/$$f/* $(TARGET_datarootdir)/dvb/$$f; \
	done
endef
DTV_SCAN_TABLES_INDIVIDUAL_HOOKS += DTV_SCAN_TABLES_INSTALL

dtv-scan-tables: | $(TARGET_DIR)
	$(call individual-package)
