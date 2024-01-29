################################################################################
#
# python-cchardet
#
################################################################################

PYTHON_CCHARDET_VERSION = 2.1.7
PYTHON_CCHARDET_DIR = cchardet-$(PYTHON_CCHARDET_VERSION)
PYTHON_CCHARDET_SOURCE = cchardet-$(PYTHON_CCHARDET_VERSION).tar.gz
PYTHON_CCHARDET_SITE = https://files.pythonhosted.org/packages/source/c/cchardet

PYTHON_CCHARDET_SETUP_TYPE = setuptools

PYTHON_CCHARDET_DEPENDENCIES = host-python-cython

python-cchardet: | $(TARGET_DIR)
	$(call python-package)
