################################################################################
#
# python-pathspec
#
################################################################################

PYTHON_PATHSPEC_VERSION = 0.12.1
PYTHON_PATHSPEC_DIR = pathspec-$(PYTHON_PATHSPEC_VERSION)
PYTHON_PATHSPEC_SOURCE = pathspec-$(PYTHON_PATHSPEC_VERSION).tar.gz
PYTHON_PATHSPEC_SITE = https://files.pythonhosted.org/packages/source/p/pathspec

PYTHON_PATHSPEC_SETUP_TYPE = setuptools

# -----------------------------------------------------------------------------

host-python-pathspec: | $(HOST_DIR)
	$(call host-python-package)
