################################################################################
#
# python-websockets
#
################################################################################

PYTHON_WEBSOCKETS_VERSION = 12.0
PYTHON_WEBSOCKETS_DIR = websockets-$(PYTHON_WEBSOCKETS_VERSION)
PYTHON_WEBSOCKETS_SOURCE = websockets-$(PYTHON_WEBSOCKETS_VERSION).tar.gz
PYTHON_WEBSOCKETS_SITE = $(PYPI_MIRROR)/w/websockets

PYTHON_WEBSOCKETS_SETUP_TYPE = setuptools

python-websockets: | $(TARGET_DIR)
	$(call python-package)
