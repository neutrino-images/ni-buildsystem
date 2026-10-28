################################################################################
#
# python-vcs-versioning
#
################################################################################

PYTHON_VCS_VERSIONING_VERSION = 2.6.0
PYTHON_VCS_VERSIONING_DIR = vcs_versioning-$(PYTHON_VCS_VERSIONING_VERSION)
PYTHON_VCS_VERSIONING_SOURCE = vcs_versioning-$(PYTHON_VCS_VERSIONING_VERSION).tar.gz
PYTHON_VCS_VERSIONING_SITE = $(PYPI_MIRROR)/v/vcs-versioning

PYTHON_VCS_VERSIONING_SETUP_TYPE = pep517

# -----------------------------------------------------------------------------

HOST_PYTHON_VCS_VERSIONING_DEPENDENCIES = \
	host-python-packaging \
	host-python-setuptools

host-python-vcs-versioning: | $(HOST_DIR)
	$(call host-python-package)
