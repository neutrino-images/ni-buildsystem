################################################################################
#
# meson
#
################################################################################

MESON_VERSION = 0.62.2
MESON_DIR = meson-$(MESON_VERSION)
MESON_SOURCE = meson-$(MESON_VERSION).tar.gz
MESON_SITE = https://github.com/mesonbuild/meson/releases/download/$(MESON_VERSION)

# -----------------------------------------------------------------------------

HOST_MESON_DEPENDENCIES = host-ninja host-python3 host-python-setuptools

HOST_MESON_BINARY = $(HOST_DIR)/bin/meson

# Avoid interpreter shebang longer than 128 chars
define HOST_MESON_SET_INTERPRETER
	$(SED) '1s:.*:#!/usr/bin/env python3:' $(HOST_MESON_BINARY)
endef
HOST_MESON_HOST_FINALIZE_HOOKS += HOST_MESON_SET_INTERPRETER

host-meson: | $(HOST_DIR)
	$(call host-python3-package)
