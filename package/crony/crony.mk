################################################################################
#
# crony
#
################################################################################

CRONY_VERSION = 4.8
CRONY_DIR = chrony-$(CRONY_VERSION)
CRONY_SOURCE = chrony-$(CRONY_VERSION).tar.gz
CRONY_SITE = https://chrony-project.org/releases

crony: | $(TARGET_DIR)
	$(call autotools-package)
