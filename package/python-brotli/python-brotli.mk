################################################################################
#
# python-brotli
#
################################################################################

PYTHON_BROTLI_VERSION = 1.1.0
PYTHON_BROTLI_DIR = Brotli-$(PYTHON_BROTLI_VERSION)
PYTHON_BROTLI_SOURCE = Brotli-$(PYTHON_BROTLI_VERSION).tar.gz
PYTHON_BROTLI_SITE = https://files.pythonhosted.org/packages/source/b/brotli

PYTHON_BROTLI_SETUP_TYPE = setuptools

python-brotli: | $(TARGET_DIR)
	$(call python-package)
