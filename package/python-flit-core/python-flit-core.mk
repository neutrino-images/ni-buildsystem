################################################################################
#
# python-flit-core
#
################################################################################

PYTHON_FLIT_CORE_VERSION = 3.9.0
PYTHON_FLIT_CORE_DIR = flit_core-$(PYTHON_FLIT_CORE_VERSION)
PYTHON_FLIT_CORE_SOURCE = flit_core-$(PYTHON_FLIT_CORE_VERSION).tar.gz
PYTHON_FLIT_CORE_SITE = $(PYPI_MIRROR)/f/flit_core

# -----------------------------------------------------------------------------

HOST_PYTHON_FLIT_CORE_SETUP_TYPE = flit-bootstrap

# Use flit built in bootstrap_install for installing host-python-flit-core.
# This is due to host-python-installer depending on host-python-flit-core.
#
HOST_PYTHON_FLIT_CORE_PYTHON_BASE_INSTALL_CMD = \
	-m bootstrap_install dist/* $(HOST_PKG_PYTHON_PEP517_BOOTSTRAP_INSTALL_OPTS)

host-python-flit-core: | $(HOST_DIR)
	$(call host-python-package)
