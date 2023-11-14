################################################################################
#
# python-setuptools
#
################################################################################

PYTHON_SETUPTOOLS_VERSION = 68.0.0
PYTHON_SETUPTOOLS_DIR = setuptools-$(PYTHON_SETUPTOOLS_VERSION)
PYTHON_SETUPTOOLS_SOURCE = setuptools-$(PYTHON_SETUPTOOLS_VERSION).tar.gz
PYTHON_SETUPTOOLS_SITE = https://files.pythonhosted.org/packages/dc/98/5f896af066c128669229ff1aa81553ac14cfb3e5e74b6b44594132b8540e

PYTHON_SETUPTOOLS_SETUP_TYPE = pep517

PYTHON_SETUPTOOLS_DEPENDENCIES = host-python-wheel

python-setuptools: | $(TARGET_DIR)
	$(call python-package)

# -----------------------------------------------------------------------------

HOST_PYTHON_SETUPTOOLS_DEPENDENCIES = host-python-wheel

host-python-setuptools: | $(HOST_DIR)
	$(call host-python-package)
