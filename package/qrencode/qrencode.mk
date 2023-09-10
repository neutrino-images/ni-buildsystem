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

HOST_QRENCODE_DEPENDENCIES = host-libpng

HOST_QRENCODE_BINARY = $(HOST_DIR)/bin/qrencode

host-qrencode: | $(HOST_DIR)
	$(call host-autotools-package)
