################################################################################
#
# python-calver
#
################################################################################

PYTHON_CALVER_VERSION = 2022.6.26
PYTHON_CALVER_DIR = calver-$(PYTHON_CALVER_VERSION)
PYTHON_CALVER_SOURCE = calver-$(PYTHON_CALVER_VERSION).tar.gz
PYTHON_CALVER_SITE = https://files.pythonhosted.org/packages/source/c/calver

PYTHON_CALVER_SETUP_TYPE = setuptools

# -----------------------------------------------------------------------------

host-python-calver: | $(HOST_DIR)
	$(call host-python-package)
