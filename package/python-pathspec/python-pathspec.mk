################################################################################
#
# python-pathspec
#
################################################################################

PYTHON_PATHSPEC_VERSION = 0.12.1
PYTHON_PATHSPEC_DIR = pathspec-$(PYTHON_PATHSPEC_VERSION)
PYTHON_PATHSPEC_SOURCE = pathspec-$(PYTHON_PATHSPEC_VERSION).tar.gz
PYTHON_PATHSPEC_SITE = $(PYPI_MIRROR)/p/pathspec

PYTHON_PATHSPEC_SETUP_TYPE = flit

# -----------------------------------------------------------------------------

host-python-pathspec: | $(HOST_DIR)
	$(call host-python-package)
