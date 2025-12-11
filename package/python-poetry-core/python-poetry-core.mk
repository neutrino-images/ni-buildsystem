################################################################################
#
# python-poetry-core
#
################################################################################

PYTHON_POETRY_CORE_VERSION = 2.2.0
PYTHON_POETRY_CORE_DIR = poetry_core-$(PYTHON_POETRY_CORE_VERSION)
PYTHON_POETRY_CORE_SOURCE = poetry_core-$(PYTHON_POETRY_CORE_VERSION).tar.gz
PYTHON_POETRY_CORE_SITE = $(PYPI_MIRROR)/p/poetry-core

PYTHON_POETRY_CORE_SETUP_TYPE = pep517

# -----------------------------------------------------------------------------

host-python-poetry-core: | $(HOST_DIR)
	$(call host-python-package)
