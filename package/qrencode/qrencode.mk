################################################################################
#
# qrencode
#
################################################################################

QRENCODE_VERSION = 4.1.1
QRENCODE_DIR = qrencode-$(QRENCODE_VERSION)
QRENCODE_SOURCE = qrencode-$(QRENCODE_VERSION).tar.gz
QRENCODE_SITE = https://fukuchi.org/works/qrencode

# -----------------------------------------------------------------------------

HOST_QRENCODE_VERSION = $(QRENCODE_VERSION)
HOST_QRENCODE_DIR = $(QRENCODE_DIR)
HOST_QRENCODE_SOURCE = $(QRENCODE_SOURCE)
HOST_QRENCODE_SITE = $(QRENCODE_SITE)

HOST_QRENCODE_DEPENDENCIES = host-libpng

HOST_QRENCODE = $(HOST_DIR)/bin/qrencode

host-qrencode: | $(HOST_DIR)
	$(call host-autotools-package)
