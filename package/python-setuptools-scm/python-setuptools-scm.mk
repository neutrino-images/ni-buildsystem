################################################################################
#
# python-setuptools-scm
#
################################################################################

PYTHON_SETUPTOOLS_SCM_VERSION = 10.3.4
PYTHON_SETUPTOOLS_SCM_DIR = setuptools_scm-$(PYTHON_SETUPTOOLS_SCM_VERSION)
PYTHON_SETUPTOOLS_SCM_SOURCE = setuptools_scm-$(PYTHON_SETUPTOOLS_SCM_VERSION).tar.gz
PYTHON_SETUPTOOLS_SCM_SITE = $(PYPI_MIRROR)/s/setuptools-scm

PYTHON_SETUPTOOLS_SCM_SETUP_TYPE = pep517

# -----------------------------------------------------------------------------

HOST_PYTHON_SETUPTOOLS_SCM_DEPENDENCIES = \
	host-python-packaging \
	host-python-setuptools \
	host-python-vcs-versioning

host-python-setuptools-scm: | $(HOST_DIR)
	$(call host-python-package)
