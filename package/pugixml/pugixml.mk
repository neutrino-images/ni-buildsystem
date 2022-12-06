################################################################################
#
# pugixml
#
################################################################################

PUGIXML_VERSION = 1.13
PUGIXML_DIR = pugixml-$(PUGIXML_VERSION)
PUGIXML_SOURCE = pugixml-$(PUGIXML_VERSION).tar.gz
PUGIXML_SITE = https://github.com/zeux/pugixml/releases/download/v$(PUGIXML_VERSION)

pugixml: | $(TARGET_DIR)
	$(call cmake-package)
