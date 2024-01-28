################################################################################
#
# python-pycryptodomex
#
################################################################################

PYTHON_PYCRYPTODOMEX_VERSION = 3.20.0
PYTHON_PYCRYPTODOMEX_DIR = pycryptodomex-$(PYTHON_PYCRYPTODOMEX_VERSION)
PYTHON_PYCRYPTODOMEX_SOURCE = pycryptodomex-$(PYTHON_PYCRYPTODOMEX_VERSION).tar.gz
PYTHON_PYCRYPTODOMEX_SITE = https://files.pythonhosted.org/packages/source/p/pycryptodomex

PYTHON_PYCRYPTODOMEX_SETUP_TYPE = setuptools

python-pycryptodomex: | $(TARGET_DIR)
	$(call python-package)
