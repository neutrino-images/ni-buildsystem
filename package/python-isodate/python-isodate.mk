################################################################################
#
# python-isodate
#
################################################################################

PYTHON_ISODATE_VERSION = 0.7.2
PYTHON_ISODATE_DIR = isodate-$(PYTHON_ISODATE_VERSION)
PYTHON_ISODATE_SOURCE = isodate-$(PYTHON_ISODATE_VERSION).tar.gz
PYTHON_ISODATE_SITE = $(PYPI_MIRROR)/i/isodate

PYTHON_ISODATE_SETUP_TYPE = setuptools

python-isodate: | $(TARGET_DIR)
	$(call python-package)
