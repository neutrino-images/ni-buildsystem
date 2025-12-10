################################################################################
#
# python-pycountry
#
################################################################################

PYTHON_PYCOUNTRY_VERSION = 24.6.1
PYTHON_PYCOUNTRY_DIR = pycountry-$(PYTHON_PYCOUNTRY_VERSION)
PYTHON_PYCOUNTRY_SOURCE = pycountry-$(PYTHON_PYCOUNTRY_VERSION).tar.gz
PYTHON_PYCOUNTRY_SITE = $(PYPI_MIRROR)/p/pycountry

PYTHON_PYCOUNTRY_SETUP_TYPE = hatch

PYTHON_PYCOUNTRY_DEPENDENCIES = host-python-poetry-core

python-pycountry: | $(TARGET_DIR)
	$(call python-package)
