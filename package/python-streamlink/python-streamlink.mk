################################################################################
#
# python-streamlink
#
################################################################################

PYTHON_STREAMLINK_VERSION = 8.0.0
PYTHON_STREAMLINK_DIR = streamlink-$(PYTHON_STREAMLINK_VERSION)
PYTHON_STREAMLINK_SOURCE = streamlink-$(PYTHON_STREAMLINK_VERSION).tar.gz
PYTHON_STREAMLINK_SITE = $(PYPI_MIRROR)/s/streamlink

PYTHON_STREAMLINK_DEPENDENCIES = \
	python-attr \
	python-attrs \
	python-certifi \
	python-isodate \
	python-lxml \
	python-outcome \
	python-pycountry \
	python-pycryptodome \
	python-pysocks \
	python-requests \
	python-sniffio \
	python-sortedcontainers \
	python-trio-websocket \
	python-trio \
	python-urllib3 \
	python-websocket-client

PYTHON_STREAMLINK_SETUP_TYPE = setuptools

python-streamlink: | $(TARGET_DIR)
	$(call python-package)
