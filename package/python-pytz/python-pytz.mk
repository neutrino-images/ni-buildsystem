################################################################################
#
# python-pytz
#
################################################################################

PYTHON_PYTZ_VERSION = 2025.2
PYTHON_PYTZ_DIR = pytz-$(PYTHON_PYTZ_VERSION)
PYTHON_PYTZ_SOURCE = pytz-$(PYTHON_PYTZ_VERSION).tar.gz
PYTHON_PYTZ_SITE = $(PYPI_MIRROR)/p/pytz

PYTHON_PYTZ_SETUP_TYPE = setuptools

python-pytz: | $(TARGET_DIR)
	$(call python-package)
