################################################################################
#
# python-h11
#
################################################################################

PYTHON_H11_VERSION = 0.16.0
PYTHON_H11_DIR = h11-$(PYTHON_H11_VERSION)
PYTHON_H11_SOURCE = h11-$(PYTHON_H11_VERSION).tar.gz
PYTHON_H11_SITE = $(PYPI_MIRROR)/h/h11

PYTHON_H11_SETUP_TYPE = setuptools

python-h11: | $(TARGET_DIR)
	$(call python-package)
