################################################################################
#
# python-pycryptodomex
#
################################################################################

PYTHON_PYCRYPTODOMEX_VERSION = 3.18.0
PYTHON_PYCRYPTODOMEX_DIR = pycryptodomex-$(PYTHON_PYCRYPTODOMEX_VERSION)
PYTHON_PYCRYPTODOMEX_SOURCE = pycryptodomex-$(PYTHON_PYCRYPTODOMEX_VERSION).tar.gz
PYTHON_PYCRYPTODOMEX_SITE = https://files.pythonhosted.org/packages/40/92/efd675dba957315d705f792b28d900bddc36f39252f6713961b4221ee9af

PYTHON_PYCRYPTODOMEX_SETUP_TYPE = setuptools

python-pycryptodomex: | $(TARGET_DIR)
	$(call python-package)
