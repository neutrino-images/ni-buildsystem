################################################################################
#
# python-trove-classifiers
#
################################################################################

PYTHON_TROVE_CLASSIFIERS_VERSION = 2024.1.8
PYTHON_TROVE_CLASSIFIERS_DIR = trove-classifiers-$(PYTHON_TROVE_CLASSIFIERS_VERSION)
PYTHON_TROVE_CLASSIFIERS_SOURCE = trove-classifiers-$(PYTHON_TROVE_CLASSIFIERS_VERSION).tar.gz
PYTHON_TROVE_CLASSIFIERS_SITE = $(PYPI_MIRROR)/t/trove-classifiers

PYTHON_TROVE_CLASSIFIERS_SETUP_TYPE = setuptools

# -----------------------------------------------------------------------------

HOST_PYTHON_TROVE_CLASSIFIERS_DEPENDENCIES = \
	host-python-calver

host-python-trove-classifiers: | $(HOST_DIR)
	$(call host-python-package)
