################################################################################
#
# python-pysocks
#
################################################################################

PYTHON_PYSOCKS_VERSION = 1.7.1
PYTHON_PYSOCKS_DIR = PySocks-$(PYTHON_PYSOCKS_VERSION)
PYTHON_PYSOCKS_SOURCE = PySocks-$(PYTHON_PYSOCKS_VERSION).tar.gz
PYTHON_PYSOCKS_SITE = $(PYPI_MIRROR)/p/pysocks

PYTHON_PYSOCKS_SETUP_TYPE = setuptools

python-pysocks: | $(TARGET_DIR)
	$(call python-package)
