################################################################################
#
# python-trio
#
################################################################################

PYTHON_TRIO_VERSION = 0.30.0
PYTHON_TRIO_DIR = trio-$(PYTHON_TRIO_VERSION)
PYTHON_TRIO_SOURCE = trio-$(PYTHON_TRIO_VERSION).tar.gz
PYTHON_TRIO_SITE = $(PYPI_MIRROR)/t/trio

PYTHON_TRIO_SETUP_TYPE = setuptools

python-trio: | $(TARGET_DIR)
	$(call python-package)
