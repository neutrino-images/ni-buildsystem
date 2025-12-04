################################################################################
#
# python-tzlocal
#
################################################################################

PYTHON_TZLOCAL_VERSION = 5.3.1
PYTHON_TZLOCAL_DIR = tzlocal-$(PYTHON_TZLOCAL_VERSION)
PYTHON_TZLOCAL_SOURCE = tzlocal-$(PYTHON_TZLOCAL_VERSION).tar.gz
PYTHON_TZLOCAL_SITE = $(PYPI_MIRROR)/t/tzlocal

PYTHON_TZLOCAL_SETUP_TYPE = setuptools

python-tzlocal: | $(TARGET_DIR)
	$(call python-package)
