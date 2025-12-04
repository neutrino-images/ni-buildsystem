################################################################################
#
# python-pycryptodomex
#
################################################################################

PYTHON_PYCRYPTODOMEX_VERSION = 3.23.0
PYTHON_PYCRYPTODOMEX_DIR = pycryptodomex-$(PYTHON_PYCRYPTODOMEX_VERSION)
PYTHON_PYCRYPTODOMEX_SOURCE = pycryptodomex-$(PYTHON_PYCRYPTODOMEX_VERSION).tar.gz
PYTHON_PYCRYPTODOMEX_SITE = $(PYPI_MIRROR)/p/pycryptodomex

PYTHON_PYCRYPTODOMEX_SETUP_TYPE = setuptools

python-pycryptodomex: | $(TARGET_DIR)
	$(call python-package)
