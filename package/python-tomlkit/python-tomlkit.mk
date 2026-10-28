################################################################################
#
# python-tomlkit
#
################################################################################

PYTHON_TOMLKIT_VERSION = 0.15.2
PYTHON_TOMLKIT_DIR = tomlkit-$(PYTHON_TOMLKIT_VERSION)
PYTHON_TOMLKIT_SOURCE = tomlkit-$(PYTHON_TOMLKIT_VERSION).tar.gz
PYTHON_TOMLKIT_SITE = $(PYPI_MIRROR)/t/tomlkit

PYTHON_TOMLKIT_SETUP_TYPE = pep517

# -----------------------------------------------------------------------------

HOST_PYTHON_TOMLKIT_DEPENDENCIES = host-python-poetry-core

host-python-tomlkit: | $(HOST_DIR)
	$(call host-python-package)
