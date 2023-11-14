################################################################################
#
# python-installer
#
################################################################################

PYTHON_INSTALLER_VERSION = 0.7.0
PYTHON_INSTALLER_DIR = installer-$(PYTHON_INSTALLER_VERSION)
PYTHON_INSTALLER_SOURCE = installer-$(PYTHON_INSTALLER_VERSION).tar.gz
PYTHON_INSTALLER_SITE = https://files.pythonhosted.org/packages/05/18/ceeb4e3ab3aa54495775775b38ae42b10a92f42ce42dfa44da684289b8c8

# -----------------------------------------------------------------------------

HOST_PYTHON_INSTALLER_SETUP_TYPE = flit-bootstrap

HOST_PYTHON_INSTALLER_DEPENDENCIES = host-python-flit-core

HOST_PYTHON_INSTALLER_ENV = \
	PYTHONPATH="$(PKG_BUILD_DIR)/src"

host-python-installer: | $(HOST_DIR)
	$(call host-python-package)
