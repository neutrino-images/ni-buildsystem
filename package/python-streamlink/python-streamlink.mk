################################################################################
#
# python-streamlink
#
################################################################################

PYTHON_STREAMLINK_VERSION = 8.6.2
PYTHON_STREAMLINK_DIR = streamlink-$(PYTHON_STREAMLINK_VERSION)
PYTHON_STREAMLINK_SOURCE = streamlink-$(PYTHON_STREAMLINK_VERSION).tar.gz
PYTHON_STREAMLINK_SITE = $(PYPI_MIRROR)/s/streamlink

# pep517, not setuptools: only a wheel brings the RECORD file, which
# streamlink checks its _plugins.json against. Without it every Streamlink()
# session runs all plugin modules instead of loading the one it needs.
PYTHON_STREAMLINK_SETUP_TYPE = pep517

PYTHON_STREAMLINK_DEPENDENCIES = \
	host-python-setuptools \
	python-certifi \
	python-isodate \
	python-lxml \
	python-pycountry \
	python-pycryptodome \
	python-pysocks \
	python-requests \
	python-trio \
	python-trio-websocket \
	python-urllib3 \
	python-websocket-client

define PYTHON_STREAMLINK_INSTALL_CONFIG
	$(INSTALL_DATA) -D $(PKG_FILES_DIR)/config $(TARGET_localstatedir)/root/.config/streamlink/config
endef
PYTHON_STREAMLINK_TARGET_FINALIZE_HOOKS += PYTHON_STREAMLINK_INSTALL_CONFIG

python-streamlink: | $(TARGET_DIR)
	$(call python-package)
