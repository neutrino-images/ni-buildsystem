################################################################################
#
# python-packaging
#
################################################################################

PYTHON_PACKAGING_VERSION = 23.1
PYTHON_PACKAGING_DIR = packaging-$(PYTHON_PACKAGING_VERSION)
PYTHON_PACKAGING_SOURCE = packaging-$(PYTHON_PACKAGING_VERSION).tar.gz
PYTHON_PACKAGING_SITE = https://files.pythonhosted.org/packages/b9/6c/7c6658d258d7971c5eb0d9b69fa9265879ec9a9158031206d47800ae2213

# -----------------------------------------------------------------------------

HOST_PYTHON_PACKAGING_SETUP_TYPE = flit-bootstrap

host-python-packaging: | $(HOST_DIR)
	$(call host-python-package)
