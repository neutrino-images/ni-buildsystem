################################################################################
#
# python-charset-normalizer
#
################################################################################

PYTHON_CHARSET_NORMALIZER_VERSION = 3.4.4
PYTHON_CHARSET_NORMALIZER_DIR = charset_normalizer-$(PYTHON_CHARSET_NORMALIZER_VERSION)
PYTHON_CHARSET_NORMALIZER_SOURCE = charset_normalizer-$(PYTHON_CHARSET_NORMALIZER_VERSION).tar.gz
PYTHON_CHARSET_NORMALIZER_SITE = $(PYPI_MIRROR)/c/charset-normalizer

PYTHON_CHARSET_NORMALIZER_SETUP_TYPE = setuptools

python-charset-normalizer: | $(TARGET_DIR)
	$(call python-package)
