################################################################################
#
# python-streamlink
#
################################################################################

PYTHON_STREAMLINK_VERSION = 8.0.0
PYTHON_STREAMLINK_DIR = streamlink-$(PYTHON_STREAMLINK_VERSION)
PYTHON_STREAMLINK_SOURCE = streamlink-$(PYTHON_STREAMLINK_VERSION).tar.gz
PYTHON_STREAMLINK_SITE = $(PYPI_MIRROR)/s/streamlink

PYTHON_STREAMLINK_DEPENDENCIES = python3 \
    host-python-hatch-fancy-pypi-readme \
    python-requests \
    python-lxml \
    python-pycryptodome \
    python-websocket-client \
    python-isodate \
    python-pycountry \
    python-certifi \
    python-pysocks \
    python-urllib3 \
    python-trio \
    python-trio-websocket \
    python-attr \
    python-attrs \
    python-outcome \
    python-sniffio \
    python-sortedcontainers


PYTHON_STREAMLINK_SETUP_TYPE = setuptools

python-streamlink: | $(TARGET_DIR)
	$(call python-package)
