################################################################################
#
# python-brotli
#
################################################################################

PYTHON_BROTLI_VERSION = 1.2.0
PYTHON_BROTLI_DIR = brotli-$(PYTHON_BROTLI_VERSION)
PYTHON_BROTLI_SOURCE = brotli-$(PYTHON_BROTLI_VERSION).tar.gz
PYTHON_BROTLI_SITE = $(PYPI_MIRROR)/b/brotli

PYTHON_BROTLI_SETUP_TYPE = setuptools

python-brotli: | $(TARGET_DIR)
	$(call python-package)
