################################################################################
#
# python-orderedmultidict
#
################################################################################

PYTHON_ORDEREDMULTIDICT_VERSION = 1.0.2
PYTHON_ORDEREDMULTIDICT_DIR = orderedmultidict-$(PYTHON_ORDEREDMULTIDICT_VERSION)
PYTHON_ORDEREDMULTIDICT_SOURCE = orderedmultidict-$(PYTHON_ORDEREDMULTIDICT_VERSION).tar.gz
PYTHON_ORDEREDMULTIDICT_SITE = $(PYPI_MIRROR)/o/orderedmultidict

PYTHON_ORDEREDMULTIDICT_SETUP_TYPE = setuptools

python-orderedmultidict: | $(TARGET_DIR)
	$(call python-package)
