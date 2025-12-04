################################################################################
#
# python-setuptools-scm
#
################################################################################

PYTHON_SETUPTOOLS_SCM_VERSION = 8.3.1
PYTHON_SETUPTOOLS_SCM_DIR = setuptools_scm-$(PYTHON_SETUPTOOLS_SCM_VERSION)
PYTHON_SETUPTOOLS_SCM_SOURCE = setuptools_scm-$(PYTHON_SETUPTOOLS_SCM_VERSION).tar.gz
PYTHON_SETUPTOOLS_SCM_SITE = $(PYPI_MIRROR)/s/setuptools-scm

# -----------------------------------------------------------------------------

HOST_PYTHON_SETUPTOOLS_SCM_SETUP_TYPE = pep517

HOST_PYTHON_SETUPTOOLS_SCM_DEPENDENCIES = \
	host-python-packaging \
	host-python-typing-extensions

host-python-setuptools-scm: | $(HOST_DIR)
	$(call host-python-package)
