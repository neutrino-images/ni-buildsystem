################################################################################
#
# python-hatchling
#
################################################################################

PYTHON_HATCHLING_VERSION = 1.32.4
PYTHON_HATCHLING_DIR = hatchling-$(PYTHON_HATCHLING_VERSION)
PYTHON_HATCHLING_SOURCE = hatchling-$(PYTHON_HATCHLING_VERSION).tar.gz
PYTHON_HATCHLING_SITE = $(PYPI_MIRROR)/h/hatchling

PYTHON_HATCHLING_SETUP_TYPE = pep517

# -----------------------------------------------------------------------------

HOST_PYTHON_HATCHLING_DEPENDENCIES = \
	host-python-packaging \
	host-python-pathspec \
	host-python-pluggy \
	host-python-tomlkit \
	host-python-trove-classifiers

host-python-hatchling: | $(HOST_DIR)
	$(call host-python-package)
