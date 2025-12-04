################################################################################
#
# python-pip
#
################################################################################

PYTHON_PIP_VERSION = 25.3
PYTHON_PIP_DIR = pip-$(PYTHON_PIP_VERSION)
PYTHON_PIP_SOURCE = pip-$(PYTHON_PIP_VERSION).tar.gz
PYTHON_PIP_SITE = $(PYPI_MIRROR)/p/pip

PYTHON_PIP_SETUP_TYPE = setuptools

python-pip: | $(TARGET_DIR)
	$(call python-package)

# -----------------------------------------------------------------------------

host-python-pip: | $(HOST_DIR)
	$(call host-python-package)
