################################################################################
#
# python-trio-websocket
#
################################################################################

PYTHON_TRIO_WEBSOCKET_VERSION = 0.12.2
PYTHON_TRIO_WEBSOCKET_DIR = trio_websocket-$(PYTHON_TRIO_WEBSOCKET_VERSION)
PYTHON_TRIO_WEBSOCKET_SOURCE = trio_websocket-$(PYTHON_TRIO_WEBSOCKET_VERSION).tar.gz
PYTHON_TRIO_WEBSOCKET_SITE = $(PYPI_MIRROR)/t/trio-websocket

PYTHON_TRIO_WEBSOCKET_SETUP_TYPE = setuptools

python-trio-websocket: | $(TARGET_DIR)
	$(call python-package)
