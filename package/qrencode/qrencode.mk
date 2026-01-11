################################################################################
#
# qrencode
#
################################################################################

QRENCODE_VERSION = 4.1.1
QRENCODE_DIR = libqrencode-$(QRENCODE_VERSION)
QRENCODE_SOURCE = libqrencode-$(QRENCODE_VERSION).tar.gz
QRENCODE_SITE = $(call github,fukuchi,libqrencode,v$(QRENCODE_VERSION))

# -----------------------------------------------------------------------------

HOST_QRENCODE_DEPENDENCIES = host-libpng

HOST_QRENCODE_BINARY = $(HOST_DIR)/bin/qrencode

host-qrencode: | $(HOST_DIR)
	$(call host-autotools-package)
