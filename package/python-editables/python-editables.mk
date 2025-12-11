################################################################################
#
# python-editables
#
################################################################################

PYTHON_EDITABLES_VERSION = 0.5
PYTHON_EDITABLES_DIR = editables-$(PYTHON_EDITABLES_VERSION)
PYTHON_EDITABLES_SOURCE = editables-$(PYTHON_EDITABLES_VERSION).tar.gz
PYTHON_EDITABLES_SITE = $(PYPI_MIRROR)/e/editables

PYTHON_EDITABLES_SETUP_TYPE = flit

# -----------------------------------------------------------------------------

host-python-editables: | $(HOST_DIR)
	$(call host-python-package)
