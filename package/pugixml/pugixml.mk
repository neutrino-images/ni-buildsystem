################################################################################
#
# pugixml
#
################################################################################

PUGIXML_VERSION = 1.11.1
PUGIXML_DIR = pugixml-$(PUGIXML_VERSION)
PUGIXML_SOURCE = pugixml-$(PUGIXML_VERSION).tar.gz
PUGIXML_SITE = https://github.com/zeux/pugixml/releases/download/v$(PUGIXML_VERSION)

$(DL_DIR)/$(PUGIXML_SOURCE):
	$(download) $(PUGIXML_SITE)/$(PUGIXML_SOURCE)

pugixml: $(DL_DIR)/$(PUGIXML_SOURCE) | $(TARGET_DIR)
	$(call cmake-package)
