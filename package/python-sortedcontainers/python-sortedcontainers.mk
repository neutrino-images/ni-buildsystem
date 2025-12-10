################################################################################
#
# python-sortedcontainers
#
################################################################################

PYTHON_SORTEDCONTAINERS_VERSION = 2.4.0
PYTHON_SORTEDCONTAINERS_DIR = sortedcontainers-$(PYTHON_SORTEDCONTAINERS_VERSION)
PYTHON_SORTEDCONTAINERS_SOURCE = sortedcontainers-$(PYTHON_SORTEDCONTAINERS_VERSION).tar.gz
PYTHON_SORTEDCONTAINERS_SITE = $(PYPI_MIRROR)/s/sortedcontainers

PYTHON_SORTEDCONTAINERS_SETUP_TYPE = setuptools

# -----------------------------------------------------------------------------

python-sortedcontainers: | $(TARGET_DIR)
	$(call python-package)
