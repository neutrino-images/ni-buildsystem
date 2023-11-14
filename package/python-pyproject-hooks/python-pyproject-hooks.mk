################################################################################
#
# python-pyproject-hooks
#
################################################################################

PYTHON_PYPROJECT_HOOKS_VERSION = 1.0.0
PYTHON_PYPROJECT_HOOKS_DIR = pyproject_hooks-$(PYTHON_PYPROJECT_HOOKS_VERSION)
PYTHON_PYPROJECT_HOOKS_SOURCE = pyproject_hooks-$(PYTHON_PYPROJECT_HOOKS_VERSION).tar.gz
PYTHON_PYPROJECT_HOOKS_SITE = https://files.pythonhosted.org/packages/25/c1/374304b8407d3818f7025457b7366c8e07768377ce12edfe2aa58aa0f64c

# -----------------------------------------------------------------------------

HOST_PYTHON_PYPROJECT_HOOKS_SETUP_TYPE = flit-bootstrap

host-python-pyproject-hooks: | $(HOST_DIR)
	$(call host-python-package)
