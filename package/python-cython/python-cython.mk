################################################################################
#
# python-cython
#
################################################################################

PYTHON_CYTHON_VERSION = 3.2.2
PYTHON_CYTHON_DIR = Cython-$(PYTHON_CYTHON_VERSION)
PYTHON_CYTHON_SOURCE = Cython-$(PYTHON_CYTHON_VERSION).tar.gz
PYTHON_CYTHON_SITE = $(PYPI_MIRROR)/c/cython

PYTHON_CYTHON_SETUP_TYPE = setuptools

# -----------------------------------------------------------------------------

host-python-cython: | $(HOST_DIR)
	$(call host-python-package)
