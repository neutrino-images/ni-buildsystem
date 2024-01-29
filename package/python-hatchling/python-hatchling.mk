################################################################################
#
# python-hatchling
#
################################################################################

PYTHON_HATCHLING_VERSION = 1.21.0
PYTHON_HATCHLING_DIR = hatchling-$(PYTHON_HATCHLING_VERSION)
PYTHON_HATCHLING_SOURCE = hatchling-$(PYTHON_HATCHLING_VERSION).tar.gz
PYTHON_HATCHLING_SITE = https://files.pythonhosted.org/packages/source/h/hatchling

PYTHON_HATCHLING_SETUP_TYPE = pep517

# -----------------------------------------------------------------------------

HOST_PYTHON_HATCHLING_DEPENDENCIES = \
	host-python-editables \
	host-python-packaging \
	host-python-pathspec \
	host-python-pluggy \
	host-python-trove-classifiers

host-python-hatchling: | $(HOST_DIR)
	$(call host-python-package)
