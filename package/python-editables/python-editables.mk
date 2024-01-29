################################################################################
#
# python-editables
#
################################################################################

PYTHON_EDITABLES_VERSION = 0.5
PYTHON_EDITABLES_DIR = editables-$(PYTHON_EDITABLES_VERSION)
PYTHON_EDITABLES_SOURCE = editables-$(PYTHON_EDITABLES_VERSION).tar.gz
PYTHON_EDITABLES_SITE = $(PYPI_MIRROR)/e/editables

# -----------------------------------------------------------------------------

HOST_PYTHON_EDITABLES_SETUP_TYPE = pep517

host-python-editables: | $(HOST_DIR)
	$(call host-python-package)
