################################################################################
#
# python-setuptools-scm
#
################################################################################

#PYTHON_SETUPTOOLS_SCM_VERSION = 7.1.0
#PYTHON_SETUPTOOLS_SCM_DIR = setuptools_scm-$(PYTHON_SETUPTOOLS_SCM_VERSION)
#PYTHON_SETUPTOOLS_SCM_SOURCE = setuptools_scm-$(PYTHON_SETUPTOOLS_SCM_VERSION).tar.gz
#PYTHON_SETUPTOOLS_SCM_SITE = https://files.pythonhosted.org/packages/source/s/setuptools_scm
PYTHON_SETUPTOOLS_SCM_VERSION = 8.0.4
PYTHON_SETUPTOOLS_SCM_DIR = setuptools-scm-$(PYTHON_SETUPTOOLS_SCM_VERSION)
PYTHON_SETUPTOOLS_SCM_SOURCE = setuptools-scm-$(PYTHON_SETUPTOOLS_SCM_VERSION).tar.gz
PYTHON_SETUPTOOLS_SCM_SITE = https://files.pythonhosted.org/packages/source/s/setuptools-scm

# -----------------------------------------------------------------------------

HOST_PYTHON_SETUPTOOLS_SCM_SETUP_TYPE = pep517

HOST_PYTHON_SETUPTOOLS_SCM_DEPENDENCIES = \
	host-python-packaging \
	host-python-typing-extensions

host-python-setuptools-scm: | $(HOST_DIR)
	$(call host-python-package)
