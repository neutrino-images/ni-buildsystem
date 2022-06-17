################################################################################
#
# python-setuptools
#
################################################################################

PYTHON_SETUPTOOLS_VERSION = 62.1.0
PYTHON_SETUPTOOLS_DIR = setuptools-$(PYTHON_SETUPTOOLS_VERSION)
PYTHON_SETUPTOOLS_SOURCE = setuptools-$(PYTHON_SETUPTOOLS_VERSION).tar.gz
PYTHON_SETUPTOOLS_SITE = https://files.pythonhosted.org/packages/ea/a3/3d3cbbb7150f90c4cf554048e1dceb7c6ab330e4b9138a40e130a4cc79e1

# -----------------------------------------------------------------------------

HOST_PYTHON_SETUPTOOLS_VERSION = $(PYTHON_SETUPTOOLS_VERSION)
HOST_PYTHON_SETUPTOOLS_DIR = $(PYTHON_SETUPTOOLS_DIR)
HOST_PYTHON_SETUPTOOLS_SOURCE = $(PYTHON_SETUPTOOLS_SOURCE)
HOST_PYTHON_SETUPTOOLS_SITE = $(PYTHON_SETUPTOOLS_SITE)

HOST_PYTHON_SETUPTOOLS_DEPENDENCIES = host-python3

host-python-setuptools: | $(HOST_DIR)
	$(call host-python3-package)
