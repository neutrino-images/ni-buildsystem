################################################################################
#
# python-charset-normalizer
#
################################################################################

PYTHON_CHARSET_NORMALIZER_VERSION = 3.3.2
PYTHON_CHARSET_NORMALIZER_DIR = charset-normalizer-$(PYTHON_CHARSET_NORMALIZER_VERSION)
PYTHON_CHARSET_NORMALIZER_SOURCE = charset-normalizer-$(PYTHON_CHARSET_NORMALIZER_VERSION).tar.gz
PYTHON_CHARSET_NORMALIZER_SITE = $(PYPI_MIRROR)/c/charset-normalizer

PYTHON_CHARSET_NORMALIZER_SETUP_TYPE = setuptools

python-charset-normalizer: | $(TARGET_DIR)
	$(call python-package)
