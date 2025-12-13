################################################################################
#
# python-wsproto
#
################################################################################

PYTHON_WSPROTO_VERSION = 1.3.2
PYTHON_WSPROTO_DIR = wsproto-$(PYTHON_WSPROTO_VERSION)
PYTHON_WSPROTO_SOURCE = wsproto-$(PYTHON_WSPROTO_VERSION).tar.gz
PYTHON_WSPROTO_SITE = $(PYPI_MIRROR)/w/wsproto

PYTHON_WSPROTO_SETUP_TYPE = setuptools

PYTHON_WSPROTO_DEPENDENCIES = python-h11

python-wsproto: | $(TARGET_DIR)
	$(call python-package)
