################################################################################
#
# python-websocket-client
#
################################################################################

PYTHON_WEBSOCKET_CLIENT_VERSION = 1.9.0
PYTHON_WEBSOCKET_CLIENT_DIR = websocket_client-$(PYTHON_WEBSOCKET_CLIENT_VERSION)
PYTHON_WEBSOCKET_CLIENT_SOURCE = websocket_client-$(PYTHON_WEBSOCKET_CLIENT_VERSION).tar.gz
PYTHON_WEBSOCKET_CLIENT_SITE = $(PYPI_MIRROR)/w/websocket-client

PYTHON_WEBSOCKET_CLIENT_SETUP_TYPE = setuptools

python-websocket-client: | $(TARGET_DIR)
	$(call python-package)
