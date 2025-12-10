################################################################################
#
# python-hatch-fancy-pypi-readme
#
################################################################################

PYTHON_HATCH_FANCY_PYPI_README_VERSION = 25.1.0
PYTHON_HATCH_FANCY_PYPI_README_DIR = hatch_fancy_pypi_readme-$(PYTHON_HATCH_FANCY_PYPI_README_VERSION)
PYTHON_HATCH_FANCY_PYPI_README_SOURCE = hatch_fancy_pypi_readme-$(PYTHON_HATCH_FANCY_PYPI_README_VERSION).tar.gz
PYTHON_HATCH_FANCY_PYPI_README_SITE = $(PYPI_MIRROR)/h/hatch-fancy-pypi-readme

PYTHON_HATCH_FANCY_PYPI_README_SETUP_TYPE = hatch

# -----------------------------------------------------------------------------

HOST_PYTHON_HATCH_FANCY_PYPI_README_DEPENDENCIES = host-python-setuptools-scm

host-python-hatch-fancy-pypi-readme: | $(HOST_DIR)
	$(call host-python-package)
