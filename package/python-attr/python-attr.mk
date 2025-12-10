################################################################################
#
# python-attr
#
################################################################################

PYTHON_ATTR_VERSION = 0.3.2
PYTHON_ATTR_DIR = attr-$(PYTHON_ATTR_VERSION)
PYTHON_ATTR_SOURCE = attr-$(PYTHON_ATTR_VERSION).tar.gz
PYTHON_ATTR_SITE = $(PYPI_MIRROR)/a/attr

PYTHON_ATTR_SETUP_TYPE = setuptools

# -----------------------------------------------------------------------------

python-attr: | $(TARGET_DIR)
	$(call python-package)
